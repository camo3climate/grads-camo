# AlmaLinux 9 validation quick start

The build kit contains the complete common EL8/EL9 source and patch set. It
is not only a collection of shell scripts. `SOURCES/` contains the upstream
GrADS archive and all downstream patches, and `rpm/grads.spec` defines the
package.

Copy `grads-2.2.3-camo26.1-buildkit.tar.gz` to the AlmaLinux 9 host, then run
the following as an ordinary user with `sudo` access:

```bash
tar -xzf grads-2.2.3-camo26.1-buildkit.tar.gz
cd grads-2.2.3-camo26.1
./rpm/prepare-and-build-el9.sh
```

The wrapper enables CRB and EPEL, installs the spec's BuildRequires, records a
dependency probe, and builds the binary RPM and SRPM. It asks for the user's
sudo password when repository or package changes require it.

The main files to return for review are:

```text
logs/alma9-validation.log
logs/alma9-probe.txt
logs/rpmbuild-el9.log
.rpmbuild/RPMS/x86_64/grads-2.2.3-1.camo26.1.el9.x86_64.rpm
.rpmbuild/SRPMS/grads-2.2.3-1.camo26.1.el9.src.rpm
```

When a build fails during `configure`, also return the `config.log` below
`.rpmbuild/BUILD/`.
