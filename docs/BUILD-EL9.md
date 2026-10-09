# Build on AlmaLinux 9

Build in a clean AlmaLinux 9, Rocky Linux 9, or compatible RHEL 9 environment.
The EL8, EL9, and EL10 builds share one spec, source archive, and patch set.

## Prerequisites

For the complete repository setup, dependency probe, build, and log capture
in one command, follow `ALMA9-QUICKSTART.md` and run:

```bash
./rpm/prepare-and-build-el9.sh
```

The manual equivalent is documented below.

Enable CRB and EPEL, then install the RPM tooling:

```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --set-enabled crb
sudo dnf install -y epel-release
sudo dnf clean all
sudo dnf makecache --refresh
sudo dnf install -y rpm-build rpmdevtools autoconf automake libtool gcc gcc-c++ make
```

Confirm that BaseOS, AppStream, Extras, CRB, and EPEL are enabled, then install
the exact dependencies declared by the spec:

```bash
dnf repolist --enabled
sudo dnf builddep -y ./rpm/grads.spec
```

HDF4, g2clib, shapelib, and udunits2 development packages are supplied by
EPEL 9. The EPEL 9 g2clib package uses a versioned static library and an RPM
macro to publish its link name; the spec resolves that macro during `%prep`.
The X11 backend also requires `libXmu-devel` for `X11/Xmu/WinUtil.h`.

For a detailed dependency inventory before building, run:

```bash
./rpm/probe-el9.sh
```

## Build

Run the build as an ordinary user:

```bash
./rpm/build-el9.sh
```

The script creates `.rpmbuild/`, prepares the documentation source archive,
runs `rpmbuild -ba`, and records `logs/rpmbuild-el9.log`. Unlike the EL8
helper, it does not replace the distribution compiler or linker flags. The
spec uses EL9's `%set_build_flags` hardening configuration.

Expected primary products on x86_64 are:

```text
.rpmbuild/RPMS/x86_64/grads-2.2.3-1.camo26.2.el9.x86_64.rpm
.rpmbuild/SRPMS/grads-2.2.3-1.camo26.2.el9.src.rpm
```

## Check

```bash
./rpm/check-rpm.sh .rpmbuild/RPMS/x86_64/grads-2.2.3-1.camo26.2.el9.x86_64.rpm
```

Continue with `docs/TESTING-EL9.md`. A successful package build alone is not
enough: local scientific formats, X11, and export backends must be tested on
the target machine.
