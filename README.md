# GrADS 2.2.3 CAMO build

**camo26.2 pre-release** — GrADS with geographic annotations, `percentile()`,
modern/paper themes and conservative NetCDF opening assistance.

[Download packages and source](https://github.com/camo3climate/grads-camo/releases/tag/v2.2.3-camo26.2)
· [日本語インストールガイド](docs/INSTALL-CAMO26.2-JA.md)
· [Validation and limitations](docs/VALIDATION-CAMO26.2.md)

Illustrated features: [English](https://camo3climate.github.io/grads-camo/grads-camo-features/en/)
· [日本語](https://camo3climate.github.io/grads-camo/grads-camo-features/ja/).
Uses distribution/MacPorts libraries; no bundled supplibs or proprietary fonts.

This is an unofficial downstream build and packaging project for GrADS 2.2.3,
maintained for CAMO/climate research use.

For the AlmaLinux 9 validation build, start with
[ALMA9-QUICKSTART.md](ALMA9-QUICKSTART.md).

> **This is not an official GrADS, COLA, or George Mason University release.**
> Upstream GrADS is developed and maintained separately. This repository
> provides downstream patches, packaging files, and release binaries.

## Target platforms

| Target | Distribution artifact | camo26.2 verification |
| --- | --- | --- |
| AlmaLinux 8 / 9 x86_64 | Separate EL8 / EL9 RPMs | Build, install, 12/12 batch suites, clean-runtime startup |
| AlmaLinux 10 x86-64-v3 | EL10 RPM | Same; standard v3 CPU required |
| Fedora 44 x86_64 | Fedora 44 RPM | Same |
| Debian 13 amd64 | Debian 13 DEB | Same |
| Ubuntu 24.04 / 26.04 amd64 | Separate Ubuntu DEBs | Same |
| Apple Silicon macOS | MacPorts source recipe in the common buildkit | Native source build and batch checks; formal camo26.2 port installation pending |

Linux Mint is not included. Homebrew is not supported in this release.
Other RHEL-compatible distributions, Intel Macs and Linux ARM64 are not certified.

Full interactive and data-format matrices remain pending where noted below.

## Validation status

Seven Linux packages passed native build/install, all 12 regression suites,
and separate clean runtime-only installation/startup checks. GRIB2, NetCDF,
HDF4/HDF5 and Cairo are enabled. RPM disables gridded OPeNDAP; Debian/Ubuntu
enable it (remote servers were not tested). HDF4 is now enabled on Ubuntu 24.04.

Interactive X11, several independent real-format fixtures and upgrade/removal
remain untested. EPS/PDF keep their historical landscape rotation and margins;
this is accepted compatibility behavior, not a new regression. This is a
pre-release, not a claim that every format and interaction has been tested.

EL8, EL9, and EL10 use the same source archive, patch set, and RPM spec. The spec
retains only the demonstrated compiler-flag differences between the two
generations. See [EL8/EL9/EL10 compatibility](docs/EL8-EL9-COMPATIBILITY.md).

## Install on EL8

Use `dnf`, which resolves dependencies:

```bash
sudo dnf install ./grads-2.2.3-1.camo26.2.el8.x86_64.rpm
```

Do not prefer raw `rpm -ivh` for normal installation because it does not
resolve missing dependencies.

Basic test:

```bash
grads -blc "q config"
grads -blc "quit"
```

At the interactive prompt, `help` shows the basic command summary and
`help camo` shows the downstream themes, palettes, panels, geographic
drawing, font selection, and export commands. `help color` lists the compact
`set rgbmap NAME [start] [reverse]` syntax, including Matplotlib-style
`NAME_r` reversed palettes.

## Changes from upstream

The current package:

- builds against EL8 system libraries instead of bundled `supplibs`;
- installs data and loadable backends in FHS-style locations;
- enables dynamic supplemental backends and builds with Cairo, GD, NetCDF,
  HDF4, HDF5, GRIB2, GeoTIFF, shapefile, and X11 dependencies;
- disables the libsx GUI and GADAP; RPM additionally disables gridded DAP;
- uses the upstream native UDUNITS2 and corrected HDF5 interfaces;
- carries compatibility fixes for libpng16, shapelib, GCC, and EL8;
- adds CAMO drawing commands, including `classic` and `modern` themes,
  13-color sampled colormaps, configurable system font families, panels,
  projection-aware geographic vectors, circles, rectangles, and export;
- removes the obsolete `outxwd` and `printim` command aliases; use `gxprint`
  or the CAMO `export` alias.

The `modern` theme changes the latitude/longitude aspect factor from 1.2 to
1.0 and adjusts map/grid presentation. The `classic` theme restores the
traditional factor and presentation. Vector defaults are unchanged. No font
files are bundled; `set fontfamily NAME` only selects an installed
fontconfig/Cairo family. See [changes from upstream](docs/CHANGES-FROM-UPSTREAM.md).

Geographic annotations use the current map projection and `set line`
settings. `draw geocirc[f] LON LAT` uses a default page radius of 0.12;
an explicit radius may be followed by `km` for a geodesic distance circle.
`draw georec[f] LON1 LAT1 LON2 LAT2` interpolates its edges before projection.
`draw geovec LON LAT U V` treats `U` as eastward and `V` as northward,
rotates the vector with the local derivative of the active projection, and
uses `set arrscl` and `set arrowhead`. Without `set arrscl`, vectors use a
fixed page length of 0.5. Projection singularities such as an exact pole or
the orthographic limb may reject a vector whose direction is not defined.
Draw a longitude/latitude field or map first so GrADS has established the
active geographic scaling.

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

## Build on EL8, EL9, or EL10

From this repository or the build kit:

```bash
./rpm/build-el8.sh
./rpm/build-el9.sh
./rpm/build-el10.sh
./rpm/make-release-assets.sh
```

The build kit is named `grads-2.2.3-camo26.2-buildkit.tar.gz`. Detailed
instructions are in [BUILD-EL8.md](docs/BUILD-EL8.md) and
[BUILD-EL9.md](docs/BUILD-EL9.md).
EL10 instructions are in [BUILD-EL10.md](docs/BUILD-EL10.md).

Runtime checks are listed in [TESTING-EL8.md](docs/TESTING-EL8.md) and
[TESTING-EL9.md](docs/TESTING-EL9.md).
The EL10 matrix is in [TESTING-EL10.md](docs/TESTING-EL10.md).

## Ubuntu and macOS builds

Fedora 44 uses `bash rpm/build-fedora.sh` ([guide](docs/BUILD-FEDORA.md));
Debian 13 uses `bash debian/build-debian.sh` ([guide](docs/BUILD-DEBIAN.md)).

Ubuntu 24.04 and 26.04 use the same source and quilt patch series through
`debian/build-ubuntu.sh`; see [BUILD-UBUNTU.md](docs/BUILD-UBUNTU.md).
In an extracted buildkit, run `./verify-buildkit.sh` before building. In the
repository tree, where the tarball is also present under `outputs/`, use
`./verify-buildkit.sh --require-buildkit` to verify its external identity too.

The macOS target is native Apple Silicon only, uses MacPorts libraries, and
requires an interactive X11 server. Prepare the local Port with
`macports/prepare-local-port.sh` and follow
[BUILD-MACOS-ARM64.md](docs/BUILD-MACOS-ARM64.md). Rosetta, x86_64-only
dependencies, and batch-only support are outside the target.

## License

The upstream `COPYRIGHT` identifies GrADS as GNU GPL version 2. An upstream
source component also carries the MIT license. Downstream patches and
packaging files are distributed under GPL-2.0-only unless a file states
otherwise. License texts are preserved in `LICENSE`, `LICENSES/`, and the
generated RPMs. No proprietary fonts are bundled. See
[LICENSE-NOTES.md](docs/LICENSE-NOTES.md).

## Release assets

The `v2.2.3-camo26.2` pre-release provides the common source buildkit,
`SHA256SUMS` and release notes. Prebuilt RPM/DEB packages are currently
unavailable. Linux build recipes cover EL8/9/10, Fedora 44, Debian 13 and
Ubuntu 24.04/26.04. Apple Silicon macOS uses the MacPorts recipe.

## Related documents

https://camo.fpark.tmu.ac.jp/grads-camo-colormap-en.html
https://camo.fpark.tmu.ac.jp/grads-reference-en.html

## Acknowledgements

This downstream project is based on GrADS 2.2.3 from
[j-m-adams/GrADS](https://github.com/j-m-adams/GrADS).

We thank Jennifer M. Adams and all GrADS developers and contributors
for developing and maintaining GrADS.
