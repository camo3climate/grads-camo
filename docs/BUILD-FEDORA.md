# Fedora 44 native validation build

The camo26.2 Fedora 44 package passed build/install, 12/12 batch suites and
clean-runtime startup. Interactive X11 and independent format coverage remain
partial; see [validation](VALIDATION-CAMO26.2.md).
Use a dedicated Fedora 44 x86_64 VM and the distribution packages.

Install the build requirements from rpm/grads.spec with `sudo dnf builddep rpm/grads.spec`; additional tests need gcc-gfortran, libasan, libubsan, netcdf-devel, libpng-devel and fonts. Build as an ordinary user with `bash rpm/build-fedora.sh`. The helper retains the build tree for config.log and source-instrumenting tests. RPM and source RPM are under .rpmbuild.

To install the release binary (not rebuild):

```bash
sudo dnf install ./grads-2.2.3-1.camo26.2.fc44.x86_64.rpm
grads -blc 'q config'
```

The shared recipe uses Fedora system build flags rather than the historical EL8 fallback. The existing RPM feature choices (including --without-dap) remain visible; no feature is disabled to bypass a failure. Verify actual dependencies and feature configuration on this OS, then run all suites and manual checks in START-HERE/server handoff. The returned report is authoritative for actual validation.
