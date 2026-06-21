# Test on EL8

## Install and inspect

Only the main `grads` RPM is required for normal use. Debuginfo and
debugsource packages are optional debugging aids.

```bash
sudo dnf install ./grads-2.2.1-1.camo26.0.el8.x86_64.rpm
which grads
rpm -q grads
grads -blc "q config"
grads -blc "quit"
```

Confirm that output identifies upstream version 2.2.1 and CAMO build
`camo26.0`, shows the expected data/graphics features, and reports DAP/GADAP
as disabled.

## Interactive display

With a working X11 display:

```bash
echo "$DISPLAY"
grads
```

At the GrADS prompt:

```text
help
help camo
clear
quit
```

If representative data is available, also open it, draw a field, clear the
page, and test PNG or PDF export.

## Recorded result

The packaging baseline was built successfully on AlmaLinux 8.10 x86_64. Its
RPM was installed on an operational server, where startup, `q config`, X11,
and `clear` worked successfully. Repeat this test for the exact RPM published
in each release.
