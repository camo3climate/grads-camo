# GrADS 2.2.1 CAMO downstream project summary

## 1. Purpose of this document

This document summarizes the investigation, decisions, implementation, EL8
packaging work, display extensions, licensing review, testing, and publication
plan developed during the GrADS modernization project.

It is intended to be the starting point for future work on EL9/EL10,
Debian/Ubuntu, MacPorts, and other platforms. It records both the current state
and the reasons behind it so that future packaging does not repeat the same
investigation.

## 2. Project objective

The project preserves GrADS 2.2.1 as a usable interactive climate and
meteorological analysis tool on current operating systems.

The current public identity is:

```text
Project:           GrADS 2.2.1 CAMO build
Public release:    grads-2.2.1-camo26.0
Git tag:           v2.2.1-camo26.0
RPM Name:          grads
RPM Version:       2.2.1
RPM Release:       1.camo26.0%{?dist}
Primary platform:  AlmaLinux 8 x86_64
```

This is an unofficial downstream project. It is not an official GrADS, COLA,
or George Mason University release.

## 3. Material investigated

The investigation used several historical archives supplied locally:

- official-style GrADS 2.2.1 source and CentOS 7 binary archives;
- OpenGrADS 2.2.1 OGA bundles, including a source-containing bundle;
- historical `supplibs` and `supptools` archives;
- an AlmaLinux 8 RPM kit developed and corrected during the work;
- Ubuntu/Debian, Fedora, AUR, and MacPorts packaging information used for
  comparison.

The public project does not distribute the historical `supplibs` or
`supptools` bundles. Their contents and individual licensing were not suitable
for assuming safe redistribution as a single bundle.

## 4. Application structure

GrADS 2.2.1 is primarily a C application built with Autoconf, Automake,
Libtool, `configure`, and `make`.

The principal parts are:

- the interactive `grads` executable and command interpreter;
- the GrADS scripting language and `run` command;
- data access for native GrADS files, GRIB/GRIB2, NetCDF, HDF4, and HDF5;
- command-line utilities such as `gribmap`, `gribscan`, `grib2scan`, `stnmap`,
  and `bufrscan`;
- graphics display backends, especially X11 and Cairo;
- hardcopy backends using Cairo and GD;
- optional GeoTIFF and shapefile functionality;
- optional OPeNDAP/GADAP remote-data support;
- an old libsx/Athena GUI layer;
- user-defined extension mechanisms found in GrADS/OpenGrADS.

The normal GrADS prompt and the X11 graphics window are separate parts of the
same application. The prompt accepts commands; the X11/Cairo backend displays
the result. The old GUI adds menus and widgets around this workflow and is not
required for prompt-driven use.

OpenGrADS also contains extension mechanisms for functions implemented
outside the core. Fortran-related extension support is useful when an
institution already has scientific routines written in Fortran. It is not
required to build or use the core GrADS application and is not part of the
current CAMO RPM scope.

## 5. Main maintenance decisions

The current project policy is:

1. Keep upstream GrADS version 2.2.1 unchanged.
2. Record downstream identity separately as CAMO release metadata.
3. Build against distribution libraries wherever possible.
4. Do not bundle or redistribute historical `supplibs`/`supptools`.
5. Disable gridded OPeNDAP/DAP and station GADAP for the initial release.
6. Disable the libsx/Athena GUI permanently for this project unless policy
   changes later.
7. Retain prompt-driven use, X11 display, Cairo/GD output, and local scientific
   data formats.
8. Use FHS-style paths under `/usr`.
9. Bundle no proprietary fonts.
10. Keep source changes narrow, patch-based, reviewable, and reproducible.

OPeNDAP may be restored later as an optional build flavor. If that happens, it
should use distribution-provided NetCDF/libcurl/TLS libraries rather than a
private SSL stack. It must not silently change the dependencies of the base
package.

## 6. Distribution libraries and portability

Ubuntu and MacPorts already demonstrate that GrADS can be maintained against
modern system libraries without the historical supplemental-library bundle.
They use the same upstream program with packaging-specific patches and build
recipes.

Distribution packaging is partly manual engineering:

- upstream source and scientific behavior can remain common;
- dependency names, compiler behavior, library paths, and packaging metadata
  vary by distribution;
- maintainers encode those differences in RPM spec files, Debian packaging,
  Portfiles, patches, and tests.

For RPM systems, the `.spec` file is the package specification: it describes
metadata, dependencies, patch order, configure options, build/install steps,
and files included in the RPM. It sits one level outside the Makefile and
invokes `configure` and `make`.

## 7. Current EL8 RPM configuration

The current RPM spec is `rpm/grads.spec`. Its central version section is:

```spec
%global upstream_version 2.2.1
%global camo_version camo26.0
%global camo_release 1.%{camo_version}
%global public_release_name grads-%{upstream_version}-%{camo_version}
%global github_tag v%{upstream_version}-%{camo_version}
```

The build uses:

```text
--enable-dyn-supplibs
--without-gadap
--without-dap
--with-x
system HDF4 paths
system NetCDF paths
/usr/lib64/grads for loadable libraries on x86_64 EL8
```

Important build dependencies include Cairo, GD, fontconfig, FreeType, X11,
NetCDF, HDF4, HDF5, udunits2, g2clib, libaec, GeoTIFF, and shapelib development
packages.

The RPM installs the main files under:

```text
/usr/bin/
/usr/lib64/grads/
/usr/share/grads/
/usr/share/doc/grads/
/usr/share/licenses/grads/
```

## 8. EL8 problems encountered and their resolution

### Compiler could not create executables

An early build inherited an RPM hardening flag that referenced a missing
GCC Toolset 11 annobin plugin under `/opt/rh`. The ordinary `/usr/bin/gcc` was
not itself broken. The final EL8 build wrapper supplies a controlled set of
compiler/linker flags and avoids the stale external toolset reference.

### Autoconf macro patch failure

An early `udunits2` M4 patch did not match the source state. The M4 replacement
and patch order were corrected and are now validated with zero fuzz.

### g2clib naming

EL8 g2clib naming can vary through RPM macros and package versions. `%prep`
uses the distribution `%{?g2clib}` value when available and falls back to
`grib2c`, then regenerates the build system with `autoreconf`.

The retained `grads-2.2.1-g2c.patch` is reference material and is not directly
applied by the current spec.

### shapelib link failure

Configure could detect `SHPOpen` but fail to propagate `-lshp` to the final
link, producing undefined `SHP*` and `DBF*` symbols. The replacement
`libshp.m4` explicitly sets `SHP_LIBS="-lshp"`. This is preferred over keeping
a global `LIBS=-lshp` workaround in the final spec.

### libaec and PowerTools

On AlmaLinux 8, dependencies such as `libaec-devel` and the provider of
`libsz.so.2` require the appropriate repositories. The confirmed environment
used BaseOS, AppStream, Extras, EPEL, and PowerTools. `dnf builddep` against
the spec is the preferred dependency installation method.

### VM X11 behavior

One VM showed inconsistent `clear` behavior while an operational server did
not. X11 forwarding, SSH configuration, the local X server, and the virtual
graphics environment can affect interactive testing. A clean VM is appropriate
for reproducible builds; a representative user/server environment remains
necessary for final X11 testing.

## 9. Downstream patch set

The active patch set is documented in detail in
`docs/CHANGES-FROM-UPSTREAM.md`. Its main categories are:

- system-library linkage instead of static `supplibs` archives;
- FHS data paths;
- udunits2 and time-unit parsing compatibility;
- libpng16 and GRIB2 dependency compatibility;
- compiler/format-security fixes for newer GCC;
- explicit DAP/GADAP disabling;
- Cairo print linkage support;
- CAMO display, help, font, panel, palette, and export additions.

All active patches have been tested in RPM order against the included upstream
source archive using `patch -p1 --fuzz=0`.

## 10. Display modernization analysis

The discussion distinguished visual modernity from scientific readability.
Thin, smooth Python-style plots are not automatically easier to interpret.
In particular:

- wind vectors need strong orientation, shaft/head contrast, and adequate
  spacing; making them thin can reduce recognition;
- continuous or high-step color maps may look smooth but obscure scientific
  thresholds and category boundaries;
- discrete levels and visually distinct vectors are often preferable in
  research plots;
- GrADS' vector defaults were therefore intentionally preserved.

Factors that made traditional GrADS output look old included the 1.2
latitude/longitude aspect factor, heavy borders/grid treatment, Hershey fonts,
limited palette choices, and cumbersome font selection.

The result is two selectable approaches rather than a forced new default:

- `classic`: traditional aspect factor 1.2 and classic presentation;
- `modern`: aspect factor 1.0, lighter map/grid presentation, and backend font
  support where available.

## 11. New CAMO commands

The current patch provides:

```text
set theme classic
set theme modern

set rgbmap viridis
set rgbmap plasma
set rgbmap magma
set rgbmap cividis
set rgbmap NAME [start] [reverse]

set fontfamily DejaVu Sans

set panels ROW COL [gap]
set panel N
set panels off

export figure.png
export figure.png transparent
export figure.png scale 2
export figure.png width 1600
export figure.png size 1600 1200
export figure.pdf
export figure.svg
```

The new color maps use 13 discrete colors and populate `rbcols`, preserving
GrADS-style level boundaries rather than imposing continuous shading.

The font command selects a fontconfig/Cairo family already installed on the
system. No font files are included. Font family matching should be confirmed
on the target system.

Panels divide the current page into a simple row/column grid and select a
numbered viewport. This is intended for common multi-panel work without
introducing a large layout API.

`export` is a compact alias around existing hardcopy infrastructure. Cairo
supports vector and PNG output; GD provides additional raster formats. Exact
backend behavior should be tested when using GIF/JPEG or transparency.

## 12. Help and build identity

The historical `help` text referenced an obsolete COLA URL and listed only a
few old commands. It has been replaced with a concise current command summary.

```text
ga-> help
ga-> help camo
```

`help camo` lists themes, palettes, fonts, panels, and export examples.

Startup and `q config` identify the downstream build separately:

```text
Grid Analysis and Display System (GrADS) Version 2.2.1
Unofficial CAMO build camo26.0 (not an official upstream release)
```

`GRADS_VERSION` remains 2.2.1. The spec injects `CAMO_VERSION` from the central
CAMO version setting during the RPM build.

## 13. Output and animation direction

Current output paths include PNG, PDF, EPS/PS, SVG, and GD raster formats.
Transparent PNG and explicit raster dimensions/scaling are exposed through
the compact `export` command.

Video generation was deliberately deferred. A later implementation can render
numbered frames and invoke a distribution `ffmpeg` tool, but it should remain
an external/export workflow rather than adding a large video subsystem to the
GrADS core.

## 14. OpenGrADS functions

OpenGrADS functions may be technically valuable, but they should not be merged
wholesale without review.

The recommended process is:

1. inventory each desired function and source file;
2. identify copyright and license per file;
3. determine its external library requirements;
4. port one coherent function group at a time;
5. add tests and user documentation;
6. preserve attribution and license notices.

Rewriting or adapting selected functionality into the current GrADS command
style may be easier to maintain than importing the full OpenGrADS extension
stack. This remains future work.

## 15. Licensing status

The upstream `COPYRIGHT` file states GNU GPL version 2 terms. The upstream
`src/bufrstn.c` also contains a Simon Tatham linked-list mergesort under the
MIT license. The RPM therefore uses:

```text
GPL-2.0-only AND MIT
```

The complete upstream GPL text is retained in `LICENSE`, and the MIT notice is
copied to `LICENSES/MIT-Simon-Tatham.txt` and included in the RPM.

Downstream patches and packaging are intended to be GPL-2.0-compatible unless
a file states otherwise. Before broad publication, patch provenance and any
future imported OpenGrADS code should receive a final maintainer/legal review.

No proprietary fonts are bundled. In particular, the project must not include
Hiragino, Yu Gothic, Meiryo, Microsoft fonts, Adobe commercial fonts, Morisawa
fonts, or OS fonts with unclear redistribution terms.

Binary releases should be accompanied by the source RPM and build kit so that
recipients can obtain the corresponding source and build material.

## 16. Testing completed

The EL8 packaging baseline was built successfully on AlmaLinux 8.10 x86_64.
The RPM was installed on an operational server, where startup, `q config`, X11
display, and `clear` were checked successfully.

For the current source tree, the following static checks have also passed:

- all active patches apply with zero fuzz in spec order;
- changed C files pass a syntax-only compile in the available environment;
- RPM helper scripts pass `bash -n`;
- source checksums match `SHA256SUMS`;
- the build kit contains no proprietary fonts, local absolute paths, working
  directories, or macOS metadata entries.

The exact `camo26.0` RPM containing the latest help/banner changes must still
be rebuilt and run through the same EL8 tests before publication.

## 17. Current repository layout

```text
README.md
CHANGELOG.md
NOTICE.md
LICENSE
LICENSES/
RELEASE_NOTES_TEMPLATE.md
SHA256SUMS
docs/
rpm/
SOURCES/
```

Important commands are:

```bash
./rpm/build-el8.sh
./rpm/check-rpm.sh PATH_TO_RPM
./rpm/make-release-assets.sh
```

The build script runs `rpmbuild` as an ordinary user with a repository-local
top directory. It does not assume `/home/hiroshi3` or another developer path.

## 18. GitHub publication model

GitHub has two distinct publication areas:

- the repository contains source, patches, packaging, documentation, and
  licenses;
- a GitHub Release contains binary RPMs, SRPM, build kit, checksums, and
  release notes.

Do not upload the entire Codex workspace. Use the clean build kit as the
repository source. Do not commit built RPMs into normal Git history.

The intended repository is:

```text
https://github.com/camo3climate/grads-packaging
```

The intended first tag is:

```text
v2.2.1-camo26.0
```

The release should initially be marked as a pre-release. Published assets must
not be silently replaced; corrections require a new CAMO release.

See `docs/PUBLISH-GITHUB.md` for the beginner-oriented upload procedure.

## 19. Strategy for additional distributions

### Common layer

Keep these platform-independent:

- upstream source archive;
- scientific/runtime source patches where genuinely portable;
- CAMO commands and display behavior;
- license files;
- general user documentation and tests.

### RPM layer: EL8, EL9, EL10, Rocky, AlmaLinux, RHEL

Prefer one RPM spec where practical. Add narrow `%if 0%{?rhel}` conditions for
real differences in package names, repository locations, compiler behavior,
or library paths.

EL9 work should begin by testing the existing spec in a clean AlmaLinux 9 VM.
Likely review areas include:

- CRB instead of the EL8 PowerTools repository name;
- newer GCC diagnostics and default C language behavior;
- HDF4 and g2clib package availability;
- distribution hardening flags;
- whether `g2clib-static` is still required or available;
- final runtime dependencies and X11 operation.

Do not fork the source tree merely because the distribution version changes.
Fork or condition only the packaging settings that actually differ.

### Debian and Ubuntu

Debian-family packaging does not use an RPM spec. Add a `debian/` directory
containing at least `control`, `rules`, `install`, `copyright`, and quilt patch
metadata.

Use current Debian/Ubuntu GrADS packaging as a reference, then compare each
patch with the CAMO patch set. Avoid applying two different fixes for the same
upstream issue. Build with a clean `sbuild`/container/VM and produce `.deb`,
source package, logs, and checksums.

### MacPorts

MacPorts uses a `Portfile`. Keep the same upstream source and portable CAMO
patches, then express macOS dependencies and configure options in the
Portfile. Verify XQuartz/Cairo behavior and do not assume Linux filesystem
paths.

### Other systems

Fedora, Arch/AUR, Homebrew, and containers may be added later. Each should use
the common source/patch layer while keeping its own native package recipe.

## 20. Recommended test matrix

For each supported distribution, record:

```text
OS and exact version
architecture
compiler version
package recipe revision
configure summary / q config
binary package name and checksum
noninteractive startup result
representative local data open/display result
X11 result where applicable
PNG and PDF export result
CAMO help/theme/palette/panel result
```

Minimum commands include:

```bash
grads -blc "q config"
grads -blc "quit"
```

Interactive testing should include `help`, `help camo`, `clear`, one display,
and representative export operations.

## 21. Immediate next steps

1. Extract the latest `grads-2.2.1-camo26.0-buildkit.tar.gz` on AlmaLinux 8.
2. Run `./rpm/build-el8.sh` as an ordinary user.
3. Confirm the expected CAMO RPM and SRPM filenames.
4. Run `rpm/check-rpm.sh` and `docs/TESTING-EL8.md` checks.
5. Verify startup and `q config` show `camo26.0`.
6. Verify `help` and `help camo` output.
7. Test X11, `clear`, one real dataset, PNG transparency, and PDF export.
8. Run `./rpm/make-release-assets.sh`.
9. Create the GitHub repository and upload the clean source tree.
10. Create pre-release tag `v2.2.1-camo26.0` and attach generated assets.
11. Begin EL9 work from the same repository and patch set.

## 22. Open issues and cautions

- Confirm the final GitHub repository URL and remove the spec FIXME once it
  exists.
- Complete a final provenance review of every imported patch.
- Rebuild and test the exact CAMO-numbered RPM; the earlier successful EL8 RPM
  predates the latest help/banner changes.
- Confirm all advertised features from the new `q config` output rather than
  relying only on BuildRequires.
- Test GD-specific JPEG/GIF routing and transparent PNG behavior on EL8.
- Consider RPM signing only after the release process and key custody are
  understood.
- Add CI/build automation after the manual process is stable and reproducible.
- Do not add automatic GrADS init-directory loading without a separate design
  decision.
- Do not enable DAP, GUI, bundled libraries, fonts, or OpenGrADS code silently.

## 23. Current handoff point

The project now has a clean GitHub-ready source/build kit, a centralized CAMO
version scheme, an EL8 spec and build workflow, documented licenses, modern
optional drawing commands, updated help and startup identity, and a clear
publication process.

The highest-priority remaining action is not further source modification. It
is rebuilding and testing the exact `camo26.0` RPM on AlmaLinux 8, publishing
it as a pre-release, and then using the same common source layer to begin EL9
packaging validation.
