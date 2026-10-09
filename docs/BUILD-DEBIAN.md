# Build on Debian 13 (trixie)

The camo26.2 amd64 package passed native build/install, 12/12 batch suites
and clean-runtime startup. See [validation](VALIDATION-CAMO26.2.md).
Use Debian's standard development libraries; do not install Ubuntu packages.

```bash
sudo apt update
sudo apt install build-essential devscripts equivs dpkg-dev
sudo mk-build-deps -i -r -t 'apt-get -y' debian/package/control
bash debian/build-debian.sh
```

Run the build helper as an ordinary user in a dedicated checkout. It recreates
`.debbuild/debian-13`; save previous build logs before rebuilding. Outputs go
to `outputs/debian-13`. This uses the same source patches and package recipe as
Ubuntu, with Debian-specific version/distribution metadata.

To install the release binary (without rebuilding):

```bash
sudo apt install ./grads-camo_2.2.3+camo26.2-1.debian13.1_amd64.deb
grads -blc 'q config'
```

The package conflicts with the distribution `grads` package; review apt's
proposed changes. HDF4/HDF5 and gridded OPeNDAP are enabled, but independent
HDF file fixtures and remote OPeNDAP servers were not tested. The build is
binary-only (`dpkg-buildpackage -b`); no `.dsc` is supplied. Corresponding
source and build instructions are in the common release buildkit.
