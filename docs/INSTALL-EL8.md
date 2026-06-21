# Install on EL8

## Supported systems

The initial binary package targets AlmaLinux 8 x86_64. Rocky Linux 8 and
RHEL 8 compatible systems are expected to be compatible but may receive less
testing.

## Install

```bash
sudo dnf install ./grads-2.2.1-1.camo26.0.el8.x86_64.rpm
```

`dnf install` is preferred over `rpm -ivh` because `dnf` resolves package
dependencies. If the RPM was built with a different `%{dist}` or architecture,
use its actual filename.

## Verify

```bash
which grads
grads -blc "q config"
grads -blc "quit"
```

Review `q config` to confirm the expected Cairo/GD/data-format support and
that DAP/GADAP are disabled. `debuginfo` and `debugsource` packages are not
required for normal use.

The startup banner and `q config` identify both upstream GrADS 2.2.1 and the
unofficial CAMO build. At the interactive prompt, use `help camo` for the
downstream drawing commands.

## Data and backends

The package uses `/usr/share/grads` for GrADS data and `/usr/lib64/grads` on
x86_64 for loadable graphics backends. It does not add an automatic init
directory. A user may explicitly run an initialization script, for example:

```bash
grads -l -c 'run /path/to/init.gs'
```
