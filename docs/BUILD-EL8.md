# Build on EL8

Build in a clean AlmaLinux 8, Rocky Linux 8, or compatible RHEL 8 environment.
The script does not contain developer-specific absolute paths.

## Prerequisites

For the complete repository setup, dependency installation, build, and log
capture in one command, run:

```bash
./rpm/prepare-and-build-el8.sh
```

The manual equivalent is documented below. Enable EPEL and PowerTools, then
install the basic RPM toolchain:

```bash
sudo dnf install dnf-plugins-core epel-release
sudo dnf config-manager --set-enabled powertools
sudo dnf clean all
sudo dnf makecache --refresh
sudo dnf groupinstall "Development Tools"
sudo dnf install rpm-build rpmdevtools autoconf automake libtool gcc gcc-c++ make
```

PowerTools is required for dependencies such as `libaec-devel`. Confirm that
BaseOS, AppStream, Extras, EPEL, and PowerTools are enabled before `builddep`.

Install the exact `BuildRequires` declared in `rpm/grads.spec`. Where the
`dnf builddep` command is available, this is the simplest method:

```bash
sudo dnf builddep ./rpm/grads.spec
```

The declared dependencies include:

```text
gcc gcc-c++ glibc-devel glibc-headers binutils redhat-rpm-config
make autoconf automake libtool pkgconfig
readline-devel ncurses-devel zlib-devel libpng-devel libjpeg-turbo-devel
cairo-devel freetype-devel fontconfig-devel gd-devel
libX11-devel libXext-devel libXrender-devel
libXmu-devel
libgeotiff-devel shapelib-devel udunits2-devel netcdf-devel
hdf5-devel hdf-devel libaec-devel g2clib-devel g2clib-static
```

Package availability depends on enabled EL8 repositories. The original build
environment used EPEL and PowerTools.

## Build

Run the build as an ordinary user, not with `sudo`.

```bash
./rpm/build-el8.sh
```

The script creates `.rpmbuild/`, prepares the documentation source archive,
runs `rpmbuild -ba`, and writes `logs/rpmbuild.log`. Expected products are:

```text
.rpmbuild/RPMS/x86_64/grads-2.2.3-1.camo26.2.el8.x86_64.rpm
.rpmbuild/SRPMS/grads-2.2.3-1.camo26.2.el8.src.rpm
logs/rpmbuild.log
```

RPM may also generate debuginfo/debugsource packages. They are not normal-use
release requirements.

## Check and collect assets

```bash
./rpm/check-rpm.sh .rpmbuild/RPMS/x86_64/grads-2.2.3-1.camo26.2.el8.x86_64.rpm
./rpm/make-release-assets.sh
```

The second command generates the build kit and checksums under
`release/v2.2.3-camo26.2/`. The release script refuses to overwrite an
existing release directory.

The camo26.2 package passed native build/install, all 12 batch suites and
clean-runtime startup on AlmaLinux 8.10 x86_64. Interactive and independent
real-format checks remain partial; see [validation](VALIDATION-CAMO26.2.md).
