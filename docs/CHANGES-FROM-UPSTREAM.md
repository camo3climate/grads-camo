# Changes from upstream GrADS 2.2.3

This file inventories the downstream patch material in `SOURCES`. Patches are
applied in the order declared by `rpm/grads.spec`. Unless noted otherwise,
some retained compatibility patches keep their historical `grads-2.2.1-`
filenames because they still apply cleanly to 2.2.3.

## grads-2.2.1-system-supplibs.patch

Changes the build rules from private static `supplibs` archives to normal
`-l...` system-library linkage under `/usr`. This is library/build
compatibility and affects how runtime dependencies are supplied; it does not
deliberately change GrADS plotting behavior.

## grads-2.2.1-fhs-paths.patch

Changes the built-in GrADS data directory from `/usr/local/lib/grads` to
`/usr/share/grads` and aligns build paths with the package layout. This is an
FHS packaging change and affects where runtime data is found.

## grads-2.2.1-timeunits-parse.patch

Corrects an offset used while parsing NetCDF time-unit strings. This is a
small runtime correctness fix associated with modern NetCDF/UDUNITS input.

## grads-2.2.1-format-security.patch

Casts the count returned by a write operation to match the `%ld` format used
by status messages. This is a compiler/format-security compatibility fix with
no intended data or display behavior change.

## grads-2.2.1-without-dap.patch

Adds a configure-level `--without-dap` switch and suppresses gridded NetCDF
OPeNDAP linkage when requested. The RPM uses it, so remote DAP access is a
deliberately disabled runtime feature; local NetCDF remains supported.

## grads-2.2.1-cairo-aflush.patch

Adds a small print-only flush stub required when linking the Cairo hardcopy
backend independently of the display backend. This is an EL8/link
compatibility fix, with no intended output-style change.

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
families and bundles no fonts. It also adds 13-color RGB tables sampled from
Matplotlib built-in colormaps, including perceptually uniform, sequential,
diverging, cyclic, and common legacy-style maps. `set rgbmap NAME_r` and
`set rgbmap NAME reverse` both select the reversed order. The patch also adds
simple panel viewports and compact hardcopy options. It updates the interactive
`help` summary, adds compact CAMO help topics such as `help camo` and
`help color`, and displays the CAMO identifier at startup and in `q config`.
The upstream GrADS version remains 2.2.3; the RPM spec supplies the downstream
release identifier.

## grads-2.2.3-modern-gxout2.patch

Adds a small modern-display preset layer on top of the CAMO theme work.
`set theme modern` now selects the `cividis` RGB map as the default rainbow
palette, while `set theme classic` clears the custom rainbow palette. It also
adds `set gxout stream2` and `set gxout vector2`, which keep the upstream
stream/vector algorithms but draw a semi-transparent background-colored outline
before the main streamlines or vectors. This leaves `stream` and `vector`
unchanged and makes the modern double-draw behavior explicit.

## grads-2.2.3-re-limited.patch

Adds `re()` as a CAMO limited compatibility wrapper around the existing GrADS
2.2.3 `lterp()` interpolation core. The wrapper creates a linear lon/lat
destination grid from common OpenGrADS-style `re()` arguments and supports
`bl`/`bilin`, `bs`/`bessel`, `ba`/`aave`, and `ma,FRACTION`. If no method is
specified, it follows the OpenGrADS convention of using area averaging for
coarser output grids and Bessel interpolation for finer output grids. This
patch does not add new library dependencies. Vote interpolation (`vt`) and
Gaussian-grid options (`ig`, `gaus`, `gaussian`) are intentionally rejected
with explicit errors pending separate numerical validation.

## grads-2.2.3-axis-label-size.patch

Raises the default X and Y axis tick-label sizes from 0.11 to 0.15. Users can
still override these values with the existing `set xlopts` and `set ylopts`
commands. Contour-label size and other text defaults are unchanged.

## grads-2.2.3-modern-startup-defaults.patch

Applies CAMO's modern display theme at startup and changes the default 2-D
grid display from contour lines to `gxout shade2`. The startup theme uses the
same code path as `set theme modern`, including the cividis RGB map from
`grads-2.2.3-modern-gxout2.patch`. Users can still restore the older look in
a session with `set theme classic` and `set gxout contour`.

## grads-2.2.3-percentile.patch

Adds `percentile(expr,dim1,dim2,pct[,tinc])`, an equal-weight reduction over
any one of the X, Y, Z, T, or E dimensions. Undefined values are omitted. The
result uses Type 7 linear interpolation between adjacent sorted values, making
the function suitable for ensemble medians and uncertainty bands while keeping
the dimension syntax consistent with `ave`, `min`, and `max`. The patch also
adds the corresponding upstream-style HTML function reference.

## grads-2.2.3-geo-draw.patch

Together with `grads-2.2.3-geo-commands.patch`, adds `draw geovec`,
`draw geocirc`, `draw geocircf`, `draw georec`, and `draw georecf` while leaving the
page-coordinate `circ`, `circf`, `rec`, and `recf` commands intact.
The default geographic circle is a fixed-size map annotation. Appending `km`
constructs a 72-segment geodesic circle on a spherical Earth before projection.
Geographic rectangles reuse GrADS' map-polygon interpolation so their edges
follow nonlinear projections instead of connecting only the four projected
corners. All commands use the existing `set line` color/style settings.
`draw geovec` interprets U/V as eastward/northward components. It projects a
short geodesic both forward and backward along the vector and uses the centered
difference as the on-page direction. Vector length remains controlled by
`set arrscl`, avoiding location-dependent magnitude changes on non-conformal
maps; the default is a fixed 0.5 page unit when no arrow scale has been set.

## grads-2.2.3-udunits2-include.patch

Adds the versioned UDUNITS2 header directory to both the main build and
GradsPy build. This is required by current MacPorts and also matches common
Linux distribution layouts.

## grads-2.2.3-hdf5-serial-ldflags.patch

Preserves `HDF5_LDFLAGS` when the system HDF5 probe succeeds. This is required
for serial HDF5 layouts such as Debian and Ubuntu, where the headers and
libraries live below versioned subdirectories instead of the default linker
search path.

## grads-2.2.3-hdf5-modern-api.patch

Uses `H5Oget_info3` when building with HDF5 1.12 or newer while retaining the
legacy call for older HDF5 releases. This permits current HDF5 2.x builds and
still preserves the EL8-compatible source path.

## grads-2.2.3-enable-grib2-g2c-portable.patch

Removes the direct Jasper dependency from GrADS' GRIB2 enablement logic and
uses the `g2_info` probe instead. It also accepts either `G2C_VERSION` or
`G2_VERSION` at runtime and switches the GRIB message scanner between
`g2c_gbit_int()` and `gbit()` so one common source patch can cover modern g2c
and older g2clib-style headers. Packaging layers still translate the library
token from `grib2c` to the target system's actual `g2c` name where needed.

## grads-2.2.3-txtwrite.patch

Adds `txtwrite [-csv] [-header] [-undef VALUE] FILE EXPR` for dependency-free
text export of 1-D and 2-D grid expression results. The default output is
space-separated text; `-csv` switches to comma-separated output. Coordinate
columns are named from the varying dimensions, so lon/lat grids produce
`lon,lat,value` with `-csv -header`, and time series produce `time,value`.
Station data and higher-dimensional expression results are intentionally out
of scope for this first text writer.

## grads-2.2.3-command-cleanup.patch

Removes the retired `outxwd` command stub. The CAMO themes patch also removes
the deprecated `printim` alias. `gxprint` remains the canonical upstream
hardcopy command and `export` remains CAMO's compact alias for the same path.

## Upstream 2.2.3 facilities now used directly

The 2.2.3 base supplies the native UDUNITS2 API and XML data, HDF5 identifier,
attribute, cache, and close handling fixes, `draw circ`/`draw circf`, and the
weekday calculation extension through year 3000. The old downstream UDUNITS2
linkage patches are no longer applied.

## grads-2.2.1-g2c.patch (retained, not directly applied)

This imported compatibility patch records an alternative g2clib adaptation.
The active 2.2.3 GRIB2 portability patch supersedes it. The older file is
retained for provenance and comparison, not as an additional source change.

## Auxiliary replacement files

`cairo.m4` replaces the upstream Cairo detection macro for system-library
discovery. `libshp.m4` is retained/copied, but the current configure path calls
`GA_CHECK_LIB_SHP` from `m4/shapelib.m4`; its mere presence does not establish
that this replacement is active. `udpt.in` installs the backend table for Cairo, X11,
GD, and dummy backends under `/usr/lib64/grads` (through the RPM `%{_libdir}`
macro). These files affect build/link and backend discovery.

## Spec-only configuration

The RPM configures dynamic supplemental libraries, X11, HDF4, NetCDF, and the
system library directories. It explicitly passes `--without-dap` and
`--without-gadap`; the libsx GUI is not enabled. Build requirements request
Cairo, GD, NetCDF, HDF4, HDF5, g2clib, GeoTIFF, shapefile, and related system
development packages. Actual detected features must be verified in the build
log and with `grads -blc "q config"` on the produced RPM.

## camo26.2 additions

`geo-annotations.patch` adds projected/clipped geographic lines, text, markers
and weather symbols; drawing errors propagate to script `rc`. Existing graphics
primitives are reused. `grib2-png-link.patch` removes hard-coded `-lpng15`.
`annotation-scripts.patch` installs track-file and grid-centered significance
helpers, generated from `scripts/`. `percentile.patch` supplies equal-weight,
missing-aware Type 7 reductions across X/Y/Z/T/E using the C standard library.
These additions require no new runtime libraries. Platform build results and
limitations are recorded in `docs/VALIDATION-CAMO26.2.md`.
