# Versioning

Current upstream version: GrADS 2.2.3.
Current CAMO release: camo26.2.
Public tag: `v2.2.3-camo26.2`.

RPM `Version` identifies the upstream version; RPM `Release` carries the
CAMO identifier and OS suffix. Debian and MacPorts recipes also identify
the upstream and CAMO versions.

The central RPM settings are the `%global` lines in `rpm/grads.spec`.
Check the version and patch lists with:

```bash
bash tools/check-package-metadata.sh
bash tools/check-source-series.sh
```

See [validation and limitations](VALIDATION-CAMO26.2.md) for the tested
platforms and checks. Current downloads contain source; prebuilt RPM/DEB
packages are unavailable.
