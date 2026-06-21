# Versioning

The central settings are the clearly marked `%global` lines at the top of
`rpm/grads.spec`.

```text
Upstream version:     2.2.1
CAMO release:         camo26.0
Public release:       2.2.1-camo26.0
RPM Version:          2.2.1
RPM Release:          1.camo26.0%{?dist}
Git tag:              v2.2.1-camo26.0
```

The RPM `Version` always remains the upstream version. CAMO metadata belongs
in RPM `Release`, the public release name, and the Git tag.

## Bump policy

- Documentation correction before public release: no tag is required.
- Documentation correction after public release: use `camo26.1`.
- Packaging or compatibility patch correction: use `camo26.1`, or a new
  major CAMO series when appropriate.
- Display behavior change: use a new series such as `camo27.0`.
- New upstream GrADS version: update the upstream version and begin a new CAMO
  series, for example `2.2.2-camo1.0`.

RPM `Release` must change whenever RPM contents change. Published files are
immutable and must not be silently overwritten.
