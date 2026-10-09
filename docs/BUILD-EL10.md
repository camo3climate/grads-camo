# Build on AlmaLinux 10

Build on a clean standard AlmaLinux 10 x86_64 installation. The initial CAMO
target is the normal x86-64-v3 architecture; AlmaLinux's optional x86-64-v2
repository set is not supported by this package.

The camo26.2 package passed native build/install, 12/12 batch suites and
clean-runtime startup on AlmaLinux 10.2. See [validation](VALIDATION-CAMO26.2.md).

## Repositories and dependencies

```bash
sudo dnf install -y dnf-plugins-core epel-release
sudo dnf config-manager --set-enabled crb
sudo dnf clean all
sudo dnf makecache --refresh
dnf repolist --enabled
./rpm/probe-el10.sh
sudo dnf builddep -y ./rpm/grads.spec
```

Do not enable testing or unrelated third-party repositories to satisfy a
missing dependency. Keep the probe output with the validation record.

## Build and check

Run as an ordinary user:

```bash
./rpm/build-el10.sh
./rpm/check-rpm.sh \
  .rpmbuild/RPMS/x86_64/grads-2.2.3-1.camo26.2.el10.x86_64.rpm
```

Expected products are the binary RPM above and
`.rpmbuild/SRPMS/grads-2.2.3-1.camo26.2.el10.src.rpm`. Continue with
`docs/TESTING-EL10.md`; a package build alone does not establish support.
