#!/usr/bin/env bash
# Metadata/buildkit regression tests; no RPM installation, build or publication.
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
mkdir -p "$root/outputs"
out=$(mktemp -d "$root/outputs/packaging-test.XXXXXX")
fixture="$out/checkout"
mkdir -p "$fixture" "$out/bin"
for directory in SOURCES rpm debian macports docs LICENSES tools tests scripts; do
  cp -Rp "$root/$directory" "$fixture/"
done
for file in README.md ALMA9-QUICKSTART.md CHANGELOG.md NOTICE.md LICENSE \
  BUILDKIT-ID.txt RELEASE_NOTES_TEMPLATE.md SHA256SUMS .gitignore .gitattributes PUBLIC-FILES.txt verify-buildkit.sh; do
  cp -p "$root/$file" "$fixture/"
done
cp "$root/tests/packaging/fake-rpm.sh" "$out/bin/rpm"
chmod +x "$out/bin/rpm"
export PATH="$out/bin:$PATH"
upstream=$(awk '$1=="%global" && $2=="upstream_version" {print $3}' "$root/rpm/grads.spec")
camo=$(awk '$1=="%global" && $2=="camo_version" {print $3}' "$root/rpm/grads.spec")
release=$(awk '$1=="%global" && $2=="camo_release" {print $3}' "$root/rpm/grads.spec")
release=${release//\%\{camo_version\}/$camo}
release_dir="$fixture/release/v$upstream-$camo"
check_fail() {
  local label=$1
  shift
  if "$@" > "$out/$label.log" 2>&1; then
    echo "FAIL: $label unexpectedly succeeded" >&2; exit 1
  fi
}

bash "$fixture/tools/check-package-metadata.sh" > "$out/metadata.log"
sed 's/^CAMO_VERSION=.*/CAMO_VERSION=camo99.9/' "$root/debian/build-ubuntu.sh" > "$fixture/debian/build-ubuntu.sh"
check_fail debian-version bash "$fixture/tools/check-package-metadata.sh"
grep -q 'Packaging mismatch: Debian package version' "$out/debian-version.log"
cp "$root/debian/build-ubuntu.sh" "$fixture/debian/build-ubuntu.sh"
sed 's/^CAMO_VERSION=.*/CAMO_VERSION=camo99.9/' "$root/debian/build-debian.sh" > "$fixture/debian/build-debian.sh"
check_fail debian13-version bash "$fixture/tools/check-package-metadata.sh"
grep -q 'Packaging mismatch: Debian 13 package version' "$out/debian13-version.log"
cp "$root/debian/build-debian.sh" "$fixture/debian/build-debian.sh"
sed 's/camo[0-9][0-9.]*/camo99.9/g' "$root/macports/grads-camo/Portfile.in" > "$fixture/macports/grads-camo/Portfile.in"
check_fail macports-version bash "$fixture/tools/check-package-metadata.sh"
grep -q 'Packaging mismatch: MacPorts runtime version' "$out/macports-version.log"
cp "$root/macports/grads-camo/Portfile.in" "$fixture/macports/grads-camo/Portfile.in"
printf '\ngrads-2.2.3-percentile.patch\n' >> "$fixture/debian/package/patches/series"
check_fail duplicate-patch bash "$fixture/tools/check-package-metadata.sh"
grep -q 'Packaging mismatch: Debian patch order' "$out/duplicate-patch.log"
cp "$root/debian/package/patches/series" "$fixture/debian/package/patches/series"

mkdir -p "$fixture/.rpmbuild/RPMS/x86_64" "$fixture/.rpmbuild/SRPMS"
binary="$fixture/.rpmbuild/RPMS/x86_64/grads-$upstream-$release.el9.x86_64.rpm"
source="$fixture/.rpmbuild/SRPMS/grads-$upstream-$release.el9.src.rpm"
printf 'grads\t%s\t%s.el9\n' "$upstream" "$release" > "$source"
# Even a new-version filename must be rejected if its internal metadata is old.
printf 'grads\t%s\t1.camo00.0.el9\n' "$upstream" > "$binary"
check_fail stale-rpm bash "$fixture/rpm/make-release-assets.sh"
grep -q 'RPM version mismatch' "$out/stale-rpm.log"
[[ ! -e "$release_dir" ]]
printf 'not-grads\t%s\t%s.el9\n' "$upstream" "$release" > "$binary"
check_fail wrong-rpm-name bash "$fixture/rpm/make-release-assets.sh"
grep -q 'RPM version mismatch' "$out/wrong-rpm-name.log"
[[ ! -e "$release_dir" ]]
printf 'grads\t%s\t%s.el9\n' "$upstream" "$release" > "$binary"
bash "$fixture/rpm/make-release-assets.sh" > "$out/release.log" 2>&1

mkdir -p "$out/unpacked"
tar -xzf "$release_dir/grads-$upstream-$camo-buildkit.tar.gz" -C "$out/unpacked"
kit="$out/unpacked/grads-$upstream-$camo"
for file in verify-buildkit.sh PUBLIC-FILES.txt tools/check-source-series.sh \
  tools/check-package-metadata.sh tests/percentile/run.sh scripts/geotrack.gs \
  docs/assets/grads-camo-features/U003_modern_default.png; do
  [[ -f "$kit/$file" ]] || { echo "Missing from buildkit: $file" >&2; exit 1; }
done
for private in STATUS.md docs/WORKSPACE-POLICY-JA.md docs/NEXT-FEATURE-CANDIDATES.md \
  docs/GRADS-CAMO-SPECIFICATION-JA.md docs/DEVELOPER-PORTING-TECHNICAL-JA.md \
  docs/SERVER-VM-HANDOFF-JA.md docs/WORK-PLAN-2.2.3.md \
  docs/grads-camo-features/ja/developer/index.html; do
  [[ ! -e "$kit/$private" ]] || { echo "Private file in buildkit: $private" >&2; exit 1; }
done
for obsolete in src.tar.gz g2c.patch png16.patch remove-jpeg.patch udunits2-m4.patch udunits2.patch; do
  [[ ! -e "$kit/SOURCES/grads-2.2.1-$obsolete" ]] || { echo "Obsolete buildkit input: $obsolete" >&2; exit 1; }
  if [[ -f "$root/SOURCES/grads-2.2.1-$obsolete" ]]; then
    cmp "$root/SOURCES/grads-2.2.1-$obsolete" "$fixture/SOURCES/grads-2.2.1-$obsolete"
  fi
done
bash "$kit/verify-buildkit.sh" > "$out/unpacked-verify.log"
bash "$kit/tools/check-package-metadata.sh" > "$out/unpacked-metadata.log"
check_fail existing-release bash "$fixture/rpm/make-release-assets.sh"
grep -q 'release directory already exists' "$out/existing-release.log"
echo "PASS: version/patch checks, stale RPM rejection, complete current-only buildkit and no overwrite; evidence in $out"
