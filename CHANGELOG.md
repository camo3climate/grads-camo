# Changelog

## Unreleased

- Updated the upstream source base from GrADS 2.2.1 to 2.2.3, bringing in
  the corrected HDF5 interface, native UDUNITS2 API, and extended weekday
  calculation.
- Added `draw geocirc`, `draw geocircf`, `draw georec`, and `draw georecf`.
  Geographic circles use a fixed page radius by default and accept an
  optional `km` unit for geodesic distance circles. Geographic rectangles
  interpolate their edges before applying the active map projection.
- Added `draw geovec lon lat u v` for ad-hoc earth-relative vectors. Vector
  direction is transformed with a centered local derivative of the active map
  projection, including Robinson, Mollweide, and orthographic maps away from
  their singular boundaries.
- Removed the obsolete `outxwd` and `printim` command aliases. Use `gxprint`
  or `export` for image and vector output.
- Added an AlmaLinux 9 build helper and dependency probe.
- Kept one common RPM spec and source patch set for EL8, EL9, and EL10.
- Added initial AlmaLinux 10 x86-64-v3 build, probe, and validation helpers.
- Added experimental native Debian packaging for Ubuntu 24.04 and 26.04.
- Completed the Ubuntu 24.04 amd64 package build, installation, and basic
  runtime validation with GRIB2, NetCDF4, HDF5, Cairo display/print plug-ins,
  and CAMO help enabled. HDF4 remains disabled on this target.
- Corrected Ubuntu's HDF4/NetCDF header priority, system g2c link names, and
  multiarch plug-in paths without changing the common source patch set or the
  RPM and MacPorts packaging paths.
- Added an experimental Apple Silicon-only MacPorts definition with mandatory
  interactive X11 and Mach-O arm64 validation.
- Added a repository-local 2.2.3 coordination plan and a buildkit verification
  helper so repository-local checks can confirm patch hashes before host-side debugging.
- Added HDF5 1.12/2.x object-info API compatibility and a persistent
  UDUNITS2 include path for current distribution library layouts.
- Added a common HDF5 serial-library search-path patch for Debian/Ubuntu-style
  HDF5 layouts.
- Added a common GRIB2 portability patch that removes direct Jasper gating and
  accepts either `G2C_VERSION` or `G2_VERSION` in the message scanner.
- Added `txtwrite [-csv] [-header] [-undef VALUE] FILE EXPR` for simple 1-D
  and 2-D text export of grid expression results without new library
  dependencies.
- Added `re()` CAMO limited compatibility for linear lon/lat 2-D grids using
  the existing `lterp()` core, with `bl`, `bs`, `ba`, and `ma,FRACTION`
  support.
- Raised the default X/Y axis tick-label size from 0.11 to 0.15 while keeping
  `set xlopts` and `set ylopts` overrides unchanged.
- Changed startup display defaults to CAMO modern theme and `gxout shade2`;
  users can still choose `set theme classic` and `set gxout contour`.
- Verified a native arm64 macOS source build against MacPorts HDF5 2.1.1,
  including Cairo/X11 plug-ins and batch `gxprint` geographic drawing output.
- Retained the EL8 compiler flag workaround while using distribution
  hardening flags on EL9.
- Added AlmaLinux 9 build and runtime validation procedures. EL9 support
  remains experimental until the exact RPM is tested on a real host.
- Added the missing `libXmu-devel` BuildRequires found by the first AlmaLinux
  9 validation build.

## 2.2.1-camo26.0

Initial CAMO downstream build of GrADS 2.2.1.

### Added / changed

- AlmaLinux 8 RPM packaging.
- Build against EL8 system libraries where possible.
- FHS-style installation paths.
- Cairo, GD, NetCDF, HDF4, HDF5, GRIB2, GeoTIFF, shapefile, and X11 build support.
- OPeNDAP DAP/GADAP and libsx GUI disabled.
- udunits2, libpng16, shapelib, GCC, and EL8 compatibility fixes.
- CAMO drawing themes, discrete color maps, font-family selection, panels, and export commands.
- Optional-at-runtime classic/modern aspect handling; modern uses factor 1.0 and classic uses 1.2.
- Updated interactive help, including `help camo` for downstream commands.
- Added a CAMO build identifier to startup and `q config` without changing the upstream version.
- Documented the successful AlmaLinux 8.10 build and operational-server checks.

### Notes

- This is an unofficial downstream build.
- Upstream GrADS version remains 2.2.1.
- No font files or bundled `supplibs`/`supptools` are distributed.
