# Changes from upstream GrADS 2.2.1

This file inventories the downstream patch material in `SOURCES`. Patches are
applied in the order declared by `rpm/grads.spec`. Unless noted otherwise,
filenames beginning with `grads-2.2.1-` are applied during `%prep`.

## grads-2.2.1-system-supplibs.patch

Changes the build rules from private static `supplibs` archives to normal
`-l...` system-library linkage under `/usr`. This is library/build
compatibility and affects how runtime dependencies are supplied; it does not
deliberately change GrADS plotting behavior.

## grads-2.2.1-fhs-paths.patch

Changes the built-in GrADS data directory from `/usr/local/lib/grads` to
`/usr/share/grads` and aligns build paths with the package layout. This is an
FHS packaging change and affects where runtime data is found.

## grads-2.2.1-udunits2.patch

Updates configure checks and link flags from legacy `udunits` to `udunits2`.
This is library compatibility. Data time-unit handling continues to use the
system UDUNITS implementation.

## grads-2.2.1-timeunits-parse.patch

Corrects an offset used while parsing NetCDF time-unit strings. This is a
small runtime correctness fix associated with modern NetCDF/UDUNITS input.

## grads-2.2.1-format-security.patch

Casts the count returned by a write operation to match the `%ld` format used
by status messages. This is a compiler/format-security compatibility fix with
no intended data or display behavior change.

## grads-2.2.1-png16.patch

Updates build detection and supplemental-library documentation from libpng15
to libpng16. This is library compatibility and enables use of the EL8 libpng
generation.

## grads-2.2.1-remove-jpeg.patch

Removes the obsolete Jasper requirement from the bundled GRIB2 detection path
and leaves GRIB2 linkage to g2clib. Despite the historical filename, this does
not remove GD JPEG image output. It is GRIB2/library compatibility.

## grads-2.2.1-without-dap.patch

Adds a configure-level `--without-dap` switch and suppresses gridded NetCDF
OPeNDAP linkage when requested. The RPM uses it, so remote DAP access is a
deliberately disabled runtime feature; local NetCDF remains supported.

## grads-2.2.1-cairo-aflush.patch

Adds a small print-only flush stub required when linking the Cairo hardcopy
backend independently of the display backend. This is an EL8/link
compatibility fix, with no intended output-style change.

## grads-2.2.1-udunits2-m4.patch

Updates the UDUNITS Autoconf macro to detect and link `libudunits2`. This is
build-system/library compatibility and complements the main udunits2 patch.

## grads-2.2.1-gcc14.patch

Adds missing GUI declarations/includes and fixes return types exposed by
newer C compilers. The RPM disables the libsx GUI, but keeping the source
compiler-clean avoids configure/build failures. No enabled GUI behavior is
claimed.

## grads-2.2.1-gcc15.patch

Adds explicit function prototypes and correct argument lists where old-style C
declarations fail with newer GCC defaults. This is compiler compatibility;
no intentional scientific or display behavior change is included.

## grads-2.2.1-disable-gadap-macro.patch

Disables fallback probing for a system GADAP library. Together with
`--without-gadap`, this makes station OPeNDAP unambiguously disabled and avoids
accidental host-dependent linkage.

## grads-2.2.1-themes-rgbmap.patch

Adds the CAMO drawing commands `set theme`, `set rgbmap`, `set fontfamily`,
`set panels`, `set panel`, and `export`. This patch intentionally changes
runtime display behavior only when these commands or themes are selected.
`modern` uses a 1.0 latitude/longitude aspect factor and lighter map/grid
presentation; `classic` restores the traditional 1.2 factor and presentation.
Vector defaults remain unchanged. Font selection uses Cairo/fontconfig system
families and bundles no fonts. It also adds discrete viridis, plasma, magma,
and cividis maps, simple panel viewports, and compact hardcopy options.
It also updates the interactive `help` summary, adds `help camo`, and displays
the CAMO identifier at startup and in `q config`. The upstream GrADS version
remains 2.2.1; the RPM spec supplies the downstream release identifier.

## grads-2.2.1-g2c.patch (retained, not directly applied)

This imported compatibility patch records an alternative g2clib adaptation.
The current spec does **not** apply it. Instead, `%prep` adjusts the library
name using the EL8 `%{?g2clib}` RPM macro (falling back to `grib2c`) and updates
the configure input before `autoreconf`. It is retained for provenance and
comparison, not as an additional source change.

## Auxiliary replacement files

`cairo.m4` replaces the upstream Cairo detection macro for system-library
discovery. `libshp.m4` ensures shapefile detection propagates `-lshp` to the
final link. `udpt.in` installs the loadable-backend table for Cairo, X11,
GD, and dummy backends under `/usr/lib64/grads` (through the RPM `%{_libdir}`
macro). These files affect build/link and backend discovery.

## Spec-only configuration

The RPM configures dynamic supplemental libraries, X11, HDF4, NetCDF, and the
system library directories. It explicitly passes `--without-dap` and
`--without-gadap`; the libsx GUI is not enabled. Build requirements request
Cairo, GD, NetCDF, HDF4, HDF5, g2clib, GeoTIFF, shapefile, and related system
development packages. Actual detected features must be verified in the build
log and with `grads -blc "q config"` on the produced RPM.
