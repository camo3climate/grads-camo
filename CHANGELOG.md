# Changelog

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
