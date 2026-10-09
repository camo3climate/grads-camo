#!/usr/bin/env bash
# Non-installing native build with existing MacPorts dependencies.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
[[ $(uname -s) == Darwin && $(uname -m) == arm64 ]] || {
  echo 'This helper requires native arm64 macOS and existing MacPorts dependencies.' >&2
  exit 2
}
build=${1:-"$root/work/macos-local"}
bash "$root/tools/prepare-source.sh" macports "$build"
build=$(cd "$build" && pwd)
tree="$build/grads-2.2.3"
prefix=/opt/local
cp "$root/SOURCES/cairo.m4" "$tree/m4/cairo.m4"
cp "$root/SOURCES/libshp.m4" "$tree/m4/libshp.m4"
sed -i '' 's|SUPPLIBS.*= /usr|SUPPLIBS = /opt/local|' "$tree/src/Makefile.am"
cd "$tree"
export PATH="/opt/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export LIBTOOLIZE=glibtoolize
export CPPFLAGS="-I$prefix/include -I$prefix/include/udunits2"
export LDFLAGS="-L$prefix/lib"
export CFLAGS="-O2 -fPIC -Wno-trigraphs"
export PKG_CONFIG_PATH="$prefix/lib/pkgconfig"
autoreconf -fvi
./configure --prefix="$build/install" --enable-dyn-supplibs --without-gadap \
  --with-x --with-shp="$prefix" --with-geotiff="$prefix" --with-hdf4="$prefix" \
  --with-hdf5="$prefix" --with-netcdf="$prefix" --libdir="$build/install/lib/grads"
version=$(awk '$1=="%global" && $2=="camo_version" {print $3}' "$root/rpm/grads.spec")
printf '\n#define CAMO_VERSION "%s"\n' "$version" >> src/config.h
make -j"${JOBS:-4}"
make install
cmp src/grads "$build/install/bin/grads"
mkdir -p "$build/install/share/grads"
cp -R data/. "$build/install/share/grads/"
sed -e "s|@LIBDIR@|$build/install/lib|g" -e 's/\.so/.dylib/g' \
  "$root/SOURCES/udpt.in" > "$build/install/share/grads/udpt"
env GADDIR="$build/install/share/grads" "$build/install/bin/grads" -blc 'q config' </dev/null
echo "Run with CAMO_LOCAL_INSTALL=$build/install bash $root/tools/run-local.sh"
