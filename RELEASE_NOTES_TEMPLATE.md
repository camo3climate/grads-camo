# GrADS 2.2.3 CAMO build camo26.2

Unofficial GrADS downstream pre-release.

## Download and build

The common source buildkit contains GrADS source, CAMO patches, licenses,
Linux packaging recipes, the Apple Silicon MacPorts recipe and tests.
Prebuilt RPM/DEB downloads are currently unavailable.

Build recipes cover AlmaLinux 8/9/10, Fedora 44, Debian 13 and Ubuntu
24.04/26.04 on x86_64/amd64. EL10 requires x86-64-v3.
Apple Silicon macOS uses MacPorts; no macOS binary is supplied.

[導入手順](https://github.com/camo3climate/grads-camo/blob/main/docs/INSTALL-CAMO26.2-JA.md)
· [Validation](https://github.com/camo3climate/grads-camo/blob/main/docs/VALIDATION-CAMO26.2.md)
· [Features](https://camo3climate.github.io/grads-camo/grads-camo-features/en/)

Verify the buildkit against SHA256SUMS before unpacking.

## Features

- Projected/clipped geographic lines, text, markers and weather symbols.
- Track-file and grid-centered significance plotting scripts.
- Type 7 percentile reduction across X/Y/Z/T/E, with missing values omitted.
- Modern startup defaults and the optional paper theme.
- NetCDF metadata fixes and regular lon/lat descriptor assistance.
- System-library builds with OS-specific RPM, Debian and MacPorts recipes.

## Validation and limits

Earlier builds on all seven Linux targets passed installation, 12 batch
suites and clean-runtime startup. The current source distribution has
documentation and packaging-document selection changes; it does not contain
new runtime calculations or plotting algorithms.

Coverage remains partial: interactive X11, independent input-format coverage,
remote OPeNDAP, upgrades/removal and formal camo26.2 MacPorts installation are
not fully verified. EPS/PDF retain their traditional landscape rotation and margins.
No proprietary fonts or bundled supplement libraries are included.

## Acknowledgements

Based on [j-m-adams/GrADS](https://github.com/j-m-adams/GrADS).
We thank Jennifer M. Adams and all GrADS contributors.
This is not an official GrADS, COLA or George Mason University release.
