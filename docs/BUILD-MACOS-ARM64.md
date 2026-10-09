# Build on Apple Silicon macOS with MacPorts

The macOS target is native Apple Silicon only. Rosetta and x86_64-only
dependencies are not supported. Interactive X11 is required; this is not a
batch-only port.

camo26.2 is supplied as a local Port in the common source buildkit, not an
official MacPorts registry entry or a prebuilt macOS package. Native source
build and batch tests passed using MacPorts libraries; formal camo26.2
destroot/install/activation and interactive X11 checks are still pending.
Homebrew is outside this release. See [validation](VALIDATION-CAMO26.2.md).

Install current MacPorts for the host macOS release, then prepare the local
ports tree:

```bash
./macports/prepare-local-port.sh
```

The script creates and indexes `.macports-local/`. Do not run `portindex` in
the project root; the indexed tree is `.macports-local` itself. Add that tree
as a `file://` source before the standard MacPorts source in
`/opt/local/etc/macports/sources.conf`:

```text
file:///absolute/path/to/grads-2.2.3-camo26.2/.macports-local [nosync]
```

For example, if the build kit is unpacked under
`/path/to/grads-2.2.3-camo26.2`, add:

```text
file:///path/to/grads-2.2.3-camo26.2/.macports-local [nosync]
```

Then verify that MacPorts can see the local Port and install:

```bash
port info grads-camo
sudo port install grads-camo
./macports/check-native-arm64.sh
```

When updating the local Portfile after a failed attempt, re-run `portindex`
and clean the partially prepared work directory before retrying:

```bash
cd /opt/local/var/macports/sources/grads-camo-local
sudo /opt/local/bin/portindex
sudo port clean grads-camo
sudo port install grads-camo
```

The Port runs `autoreconf` because several CAMO patches modify
`Makefile.am` and `configure.ac`. If `autoreconf` is accidentally removed,
the generated `Makefile` may miss the UDUNITS2 include path and fail with
`fatal error: 'udunits2.h' file not found`.

`grads-camo` conflicts with the existing MacPorts `grads` Port because both
install `/opt/local/bin/grads`, helper commands, plug-ins, and data files. If
the build succeeds but activation fails with conflicts against `grads
@2.2.1_23`, deactivate the old Port and activate the already-built CAMO image:

```bash
sudo port deactivate grads
sudo port activate grads-camo
```

To switch back later:

```bash
sudo port deactivate grads-camo
sudo port activate grads
```

If `port info grads-camo` works but `sudo port install grads-camo` fails with
`Permission denied` while opening the Portfile under your home directory,
MacPorts is trying to read the local tree as its build user and cannot traverse
one of the parent directories. Copy the local tree to a MacPorts-readable
location instead:

```bash
sudo mkdir -p /opt/local/var/macports/sources/grads-camo-local
sudo rsync -a --delete .macports-local/ /opt/local/var/macports/sources/grads-camo-local/
sudo chown -R root:wheel /opt/local/var/macports/sources/grads-camo-local
cd /opt/local/var/macports/sources/grads-camo-local
sudo /opt/local/bin/portindex
```

Then use this source line in `/opt/local/etc/macports/sources.conf` instead
of the home-directory path:

```text
file:///opt/local/var/macports/sources/grads-camo-local [nosync]
```

The Port depends on MacPorts `xorg-server`, Cairo/X11, HDF4/HDF5, NetCDF,
UDUNITS2, wgrib2, GeoTIFF, and shapelib. Do not mix `/opt/homebrew` or the
Intel Homebrew `/usr/local` into compiler or linker flags.

After X11 starts, verify an interactive GrADS window, redraw and resize,
mouse position queries, each geographic drawing command, and `gxprint`.
Test `geovec` on lat/lon, polar, Robinson, Mollweide, and orthographic maps
away from exact poles and the orthographic limb.

Historical result only: the exact 2.2.3/camo26.1 Port completed native arm64 build, installation,
activation, and basic runtime checks against MacPorts HDF5 2.1.1. Clean-host
reproducibility and the extended interactive X11 matrix above remain ongoing
validation work.
