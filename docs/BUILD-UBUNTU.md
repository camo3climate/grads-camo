# Build on Ubuntu 24.04 or 26.04

The Ubuntu package uses the same GrADS source archive and CAMO patches as the
RPM builds. Debian quilt applies the patch series; only dependency names and
the HDF4 alternate library names are Ubuntu-specific.

camo26.2 uses `libhdf4-alt-dev` and `dfalt`/`mfhdfalt` on Ubuntu 24.04.
Ubuntu 26.04 instead provides `libhdf4-dev >= 4.3.1` and `df`/`mfhdf`;
the recipe accepts that package and selects the new names when the alternate
libraries are absent. Both paths passed native build/install and the batch
suite. Independent HDF4 data-file reading remains untested. See the
[validation](VALIDATION-CAMO26.2.md); results below are historical camo26.1.

```bash
sudo apt update
sudo apt install -y build-essential devscripts equivs dpkg-dev
sudo mk-build-deps -i -r -t 'apt-get -y' debian/package/control
./debian/build-ubuntu.sh
```

Artifacts are written below `outputs/ubuntu-24.04/` or
`outputs/ubuntu-26.04/`. Install the local file with `apt`, not raw `dpkg`, so
dependencies are resolved:

```bash
sudo apt install ./outputs/ubuntu-24.04/grads-camo_*.deb
```

If `dpkg-source` reports `unexpected end of diff` for any patch, the extracted
tree is stale or incomplete. Re-extract the latest buildkit and confirm
`BUILDKIT-ID.txt` before rerunning `./debian/build-ubuntu.sh`. In an extracted
buildkit run `./verify-buildkit.sh`. Use
`./verify-buildkit.sh --require-buildkit` in the repository tree when the
canonical tarball is also present under `outputs/`.

Ubuntu 24.04 and Ubuntu 26.04 amd64 completed native package builds,
installation, and basic runtime checks for the exact 2.2.3/camo26.1 packages.
On Ubuntu 24.04, GRIB2, NetCDF4, HDF5, Cairo display/print plug-ins, and
`help camo` were confirmed; HDF4 is disabled. If another GrADS distribution
precedes `/usr/bin` in `PATH`, use `/usr/bin/grads` explicitly for validation.
The extended interactive and representative data-format matrix remains ongoing.
