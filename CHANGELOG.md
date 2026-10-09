# Changelog

## camo26.2 release preparation — 2026-10-05

- Add tested Fedora 44 RPM and Debian 13 DEB build helpers. Distribute seven
  Linux binary targets including EL10; macOS uses the MacPorts source recipe.
  Mint is excluded and Homebrew work is deferred.

- Integrate strict patch-context corrections and Ubuntu 26.04 HDF4 package/link
  compatibility; no runtime algorithms changed by the Linux validation fixes.
- Verify native Linux build/install and all 12 batch suites on AlmaLinux 8/9/10
  and Ubuntu 24.04/26.04, with separate clean-runtime checks. Interactive X11
  and several real-format checks remain untested; see the Linux return review.
- Retain traditional EPS/PDF rotation and page margins.
  Document optional Ubuntu italic-font installation; no new renderer or cropping.

- Fix modern font initialization at startup and restore modern/cividis/shaded2
  consistently on reset/reinit. Preserve explicit styling across clear/open.
- Add experimental `set theme paper`, a white-page style preset that preserves
  the user's palette, contour levels, output type and projection. Fix `q gxout`
  general-mode indexing and shaded2 labels.
- Harden NetCDF attribute reads and add conservative diagnostics and `sdfctl`
  XDF-descriptor preview/save assistance. No source data modifications or new
  runtime dependencies; no automatic input prompt or descriptor overwrite.
- Verify package versions/patch lists and RPM metadata, include validation
  tools/assets in buildkits, and omit unused historical inputs from new kits
  without deleting their repository history. Clarify historical documentation.
- Added `percentile(expr,dim1,dim2,pct[,tinc])` for equal-weight percentile
  reductions over X, Y, Z, T, or E. Missing values are omitted and adjacent
  order statistics use Type 7 linear interpolation.
- Add projected/clipped `geoline`, `geostring`, `geomark` and `geowxsym`,
  plus `geotrack.gs` and `sigplot.gs` helpers.
- Validate numeric input, propagate drawing errors to scripts, and test
  missing values, percentile dimensions and significance thresholds.
- Correct MacPorts shapefile prefix and residual GRIB2 libpng linkage;
  maintain existing system-library dependencies without new runtime libraries.
- Consolidate development, fresh-source reconstruction and local test tools.
- Fix `txtwrite -undef` token capture and preserve filename/token case; detect
  buffered output errors before reporting success.
- Prevent legacy geographic longitude wrapping from hanging on huge inputs.
- Align the Ubuntu HDF4 dependency with its alternate library names and
  bootstrap missing RPM build tools in the EL9 preparation helper.
- Publication pending; validation results above supersede the original
  Linux-pending status. This preparation entry is not a claim of publication.

## camo26.1 changes (previously listed as Unreleased)

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
- Completed build, installation, and basic runtime checks for the exact
  camo26.1 packages on AlmaLinux 8, Ubuntu 26.04 amd64, and Apple Silicon
  macOS with MacPorts.
- Corrected Ubuntu's HDF4/NetCDF header priority, system g2c link names, and
  multiarch plug-in paths without changing the common source patch set or the
  RPM and MacPorts packaging paths.
- Added an Apple Silicon-only MacPorts definition with native arm64 checks;
  extended interactive X11 validation remains ongoing.
- Added a buildkit verification helper for source and patch checksums.
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
- Added AlmaLinux 9 build and runtime validation procedures and confirmed the
  exact RPM on a real host.
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
