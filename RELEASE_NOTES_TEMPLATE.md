# GrADS 2.2.1 CAMO build camo26.0

This is an unofficial downstream build of GrADS 2.2.1 for EL8-compatible systems.

## Assets

- Binary RPM for EL8 x86_64
- Source RPM
- Build kit tarball
- SHA256SUMS

## Install

```bash
sudo dnf install ./grads-2.2.1-1.camo26.0.el8.x86_64.rpm
```

## Test

```bash
grads -blc "q config"
```

## Changes from upstream GrADS 2.2.1

- Build against EL8 system libraries where possible.
- FHS-style paths.
- Cairo, GD, NetCDF, HDF4, HDF5, GRIB2, GeoTIFF, shapefile, and X11 support.
- OPeNDAP DAP/GADAP and libsx GUI disabled.
- CAMO compatibility and display patches, including selectable 1.0/1.2 lat-lon aspect handling.
- Updated interactive help and an explicit CAMO build identifier at startup.

## Notes

This is not an official GrADS release. No proprietary fonts are bundled.
