# EL8, EL9, and EL10 compatibility

GrADS 2.2.3 CAMO uses one upstream archive, one downstream patch series, and
one RPM spec for Enterprise Linux 8, 9, and 10. The geographic drawing code uses
the existing GrADS projection API and standard C math routines, so it has no
OS-specific implementation.

## Shared dependencies

All builds use distribution packages for Cairo, GD, NetCDF, HDF4, HDF5,
UDUNITS2, g2clib, GeoTIFF, shapelib, readline, and X11. Updating the source
base to 2.2.3 does not introduce a new library family. It replaces CAMO's
legacy UDUNITS compatibility patches with upstream's native UDUNITS2 API and
uses the corrected upstream HDF5 implementation. The packaged UDUNITS2 XML
tables are installed below `/usr/share/grads` with the other GrADS data.

## Deliberate differences

- EL8 uses the spec's controlled compiler flags because host builds may
  inherit an obsolete annobin plugin.
- EL9 uses `%set_build_flags` and the distribution hardening configuration.
- EL10 also uses `%set_build_flags`; GCC 14 compatibility is already carried
  by the common patch set.
- EL8 enables PowerTools; EL9 and EL10 enable CRB. All require EPEL for several
  scientific development packages.
- The EL9 g2clib package can expose a versioned static link name through an
  RPM macro; `%prep` resolves that name without changing GrADS source logic.

## Validation boundary

The successful AlmaLinux 8.10 record belongs to the previous GrADS 2.2.1
baseline. It demonstrates that the packaging layout worked but does not
validate the 2.2.3/camo26.1 binaries. Before release, build the exact current
spec independently on clean EL8, EL9, and EL10 hosts and complete the matching
test documents, including HDF5, NetCDF/UDUNITS2 time coordinates, X11,
geographic drawing, and `gxprint`/`export` output.
