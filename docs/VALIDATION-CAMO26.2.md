# camo26.2 validation and limits

The following results describe earlier native builds on dedicated Linux VMs.
Current downloads provide source, packaging recipes and tests.
Prebuilt RPM/DEB downloads are currently unavailable.

| OS / architecture | Build/install | Batch suites | Clean runtime startup |
| --- | --- | --- | --- |
| AlmaLinux 8.10 x86_64 | PASS | 12/12 | PASS |
| AlmaLinux 9.8 x86_64 | PASS | 12/12 | PASS |
| AlmaLinux 10.2 x86-64-v3 | PASS | 12/12 | PASS |
| Ubuntu 24.04.5 amd64 | PASS | 12/12 | PASS |
| Ubuntu 26.04.1 amd64 | PASS | 12/12 | PASS |
| Fedora 44 x86_64 | PASS | 12/12 | PASS |
| Debian 13 amd64 | PASS | 12/12 | PASS |

Checks covered percentile (72 numerical/parser and 6 station-rejection checks),
sdfctl (126 checks), geographic drawing, NetCDF metadata, themes, transparency
and GRIB2 fixture values. Current source export, package metadata, patch-series
consistency, geometry and documentation selection checks passed.
Documentation and package-document selection changed since the native tests;
no runtime calculations or plotting algorithms were changed.

Apple Silicon macOS source/batch checks using MacPorts libraries passed.
Formal camo26.2 Port destroot/install/activation remains unverified.
Intel Mac, Linux ARM64, Mint, Homebrew and other OS versions are not validated.

HDF4 is enabled on all seven Linux targets.
RPM disables gridded OPeNDAP; Debian/Ubuntu enable it. GADAP is disabled.

Coverage remains partial. Interactive X11 resize/redraw/input, independent
GRIB1/HDF4/HDF5 fixtures, GRIB2 missing bitmaps, GeoTIFF/KML/Shapefile export,
remote OPeNDAP, upgrades and removal are not fully verified.
Sanitizer checks do not cover the entire application or external libraries.

EPS/PDF retain traditional landscape rotation and page margins.
Font availability depends on the OS; DejaVu italic on Debian/Ubuntu may need
`fonts-dejavu-extra`. No proprietary fonts are included.
