# GrADS 2.2.1 CAMO build

This is an unofficial downstream build and packaging project for GrADS 2.2.1,
maintained for CAMO/climate research use.

Version: v2.2.1-camo26.0
Based on: GrADS 2.2.1

The complete project history, technical decisions, and cross-distribution
roadmap are in [PROJECT-SUMMARY.md](docs/PROJECT-SUMMARY.md).

> **This is not an official GrADS, COLA, or George Mason University release.**
> Upstream GrADS is developed and maintained separately. This repository
> provides downstream patches, packaging files, and release binaries.

## Supported platform

- AlmaLinux 8 x86_64
- Rocky Linux 8 x86_64
- RHEL 8 compatible systems (lightly tested or untested)

EL9, EL10, Ubuntu, and MacPorts support may be added later. They are not
currently provided or claimed by this repository.

## Downloads

Prebuilt RPMs are available from the GitHub Releases page:

https://github.com/camo3climate/grads-camo/releases/tag/v2.2.1-camo26.0

`grads-2.2.1-1.camo26.0.el8.x86_64.rpm`

### Experimental builds

A tentative AlmaLinux/RHEL 9 RPM build is temporarily available here:

- `grads-2.2.1-1.camo26.0.el8.x86_64.rpm`  [DROPBOX_LINK](https://www.dropbox.com/scl/fi/jjyr7rgis9ql493jt35dj/grads-2.2.1-1.camo26.0.el9.x86_64.rpm?rlkey=1bqb6qe6eed5ocpzycty5d4bj&dl=0)

This EL9 RPM is provided for testing only. It is not part of the tagged
GitHub release assets yet. Documentation and release packaging will be updated
later.

## Install on EL8

Use `dnf`, which resolves dependencies:

```bash
sudo dnf install ./grads-2.2.1-1.camo26.0.el8.x86_64.rpm
```

Do not prefer raw `rpm -ivh` for normal installation because it does not
resolve missing dependencies.

Basic test:

```bash
grads -blc "q config"
grads -blc "quit"
```

At the interactive prompt, `help` shows the basic command summary and
`help camo` shows the downstream themes, palettes, panels, font selection,
and export commands.

## EL8 test status

The packaging baseline was built successfully on AlmaLinux 8.10 x86_64. The
resulting RPM was installed on an operational server, where startup,
`q config`, X11 display, and `clear` were checked successfully. Rebuilds must
repeat these checks before release.

## Changes from upstream

The current package:

- builds against EL8 system libraries instead of bundled `supplibs`;
- installs data and loadable backends in FHS-style locations;
- enables dynamic supplemental backends and builds with Cairo, GD, NetCDF,
  HDF4, HDF5, GRIB2, GeoTIFF, shapefile, and X11 dependencies;
- disables the libsx GUI and both OPeNDAP paths (`DAP` and `GADAP`);
- carries compatibility fixes for udunits2, libpng16, shapelib, GCC, and EL8;
- adds CAMO drawing commands, including `classic` and `modern` themes,
  discrete color maps, configurable system font families, panels, and export.

The `modern` theme changes the latitude/longitude aspect factor from 1.2 to
1.0 and adjusts map/grid presentation. The `classic` theme restores the
traditional factor and presentation. Vector defaults are unchanged. No font
files are bundled; `set fontfamily NAME` only selects an installed
fontconfig/Cairo family. See [changes from upstream](docs/CHANGES-FROM-UPSTREAM.md).

## Package layout

The RPM installs these principal paths:

```text
/usr/bin/grads
/usr/bin/bufrscan, gribmap, grib2scan, gribscan, stnmap
/usr/lib64/grads/
/usr/share/grads/
/usr/share/doc/grads/
/usr/share/licenses/grads/
```

## Build on EL8

From this repository or the build kit:

```bash
./rpm/build-el8.sh
./rpm/make-release-assets.sh
```

The build kit is named `grads-2.2.1-camo26.0-buildkit.tar.gz`. Detailed
instructions are in [BUILD-EL8.md](docs/BUILD-EL8.md).

Runtime checks are listed in [TESTING-EL8.md](docs/TESTING-EL8.md).

## License

The upstream `COPYRIGHT` identifies GrADS as GNU GPL version 2. An upstream
source component also carries the MIT license. Downstream patches and
packaging files are distributed under GPL-2.0-only unless a file states
otherwise. License texts are preserved in `LICENSE`, `LICENSES/`, and the
generated RPMs. No proprietary fonts are bundled. See
[LICENSE-NOTES.md](docs/LICENSE-NOTES.md).

## Release assets

GitHub Releases should contain the EL8 binary RPM, source RPM, build kit,
`SHA256SUMS`, and release notes. See [RELEASE.md](docs/RELEASE.md).

For a first publication, follow the step-by-step
[GitHub publishing guide](docs/PUBLISH-GITHUB.md). It explains which files go
in the source repository and which files belong to a GitHub Release.
