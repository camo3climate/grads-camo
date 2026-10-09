# NetCDF safety regression

Run against a newly built executable; the optional source argument enables an
AddressSanitizer/UBSan test of the **actual** attribute function bodies:

```bash
NC_CONFIG=/opt/local/bin/nc-config bash tests/netcdf/run.sh \
  /path/to/install/bin/grads /path/to/grads-2.2.3
```

Fixtures are created by a small C program using the already-required NetCDF C
library. This tests its native integer and string types without adding the
NetCDF Fortran library or Python as dependencies. All data and evidence are
generated under ignored `outputs/netcdf-test.*`; source datasets are untouched.

Checks cover every primitive numeric attribute type, exact signed/unsigned
64-bit `q attr` output, string metadata lengths and arrays, unsigned missing
values, malformed scalar/text attributes, overlong names, normal reopening
after failed opens, and calendar-month time coordinates. The isolated sanitizer
harness includes allocation-failure and NetCDF-read-error injection, invalid
NetCDF handles, and scalar-attribute type/length checks. The native `open` path
is also tested with an explicit descriptor containing array-valued missing data.
Non-regular UDUNITS time coordinates and unassigned singleton dimensions are
rejected explicitly, not silently relabelled or sliced. The time check covers
NetCDF's UDUNITS path; legacy CDC/YYMMDDHH time encoding is not validated here.
Modern `proleptic_gregorian`, the UDUNITS `yr` alias, and a hand-written
`xdfopen` descriptor with `OPTIONS 365_day_calendar` are checked. Automatic
decoding rejects `all_leap`, `julian`, and unknown calendars explicitly; this
does not add new calendar support or certify historical Gregorian cutovers.

These checks do not establish support for curvilinear grids, hierarchical
groups, unusual calendars, arbitrary dimensions, or every compression filter.
