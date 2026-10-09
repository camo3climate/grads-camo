# Existing-feature compatibility smoke

Run against the newly built binary, not the system GrADS:

```bash
FC=/opt/local/bin/gfortran bash tests/compat/run.sh "$PWD/work/macos-local/install/bin/grads"
```

Uses the existing geographic Fortran fixture. Requires a C/Fortran compiler,
pkg-config and the existing libpng development dependency. Tests do not install
anything, alter original data, or require Python. Results remain in a new
`outputs/compat-test.*` directory even on failure.

Checks 1-D/2-D text coordinates, record counts, missing-value tokens and
mixed-case output names;
constant-field preservation on a small interior grid for `re()` bl/bs/ba/ma;
classic/modern themes and rgbmap commands; and PNG pixel values for two
half-transparent rectangles in known drawing order. This is deliberately a
smoke regression, not an OpenGrADS numerical-equivalence certification.

An optional second argument reads an existing GFS NetCDF wind fixture containing
`UGRD_850mb`/`VGRD_850mb`; it is never downloaded or modified:

```bash
FC=/opt/local/bin/gfortran bash tests/compat/run.sh \
  "$PWD/work/macos-local/install/bin/grads" \
  "$PWD/work/wind-demo/data/gfs_20260703_18_f000_easia_wind.nc"
```

This optional test is one representative NetCDF input, not GRIB/HDF/NetCDF
coverage for every format, calendar or grid.
