* Optional read-only smoke test for the existing East Asia GFS wind fixture.
function main(file)
  'sdfopen 'file
  if (rc!=0); say 'FAIL: NetCDF open'; return 1; endif
  'set lon 120 130'
  'set lat 20 30'
  'set gxout shaded'
  'd mag(ugrd_850mb,vgrd_850mb)'
  if (rc!=0); say 'FAIL: NetCDF wind evaluation'; return 1; endif
  'gxprint netcdf-wind.png x800'
  if (rc!=0); say 'FAIL: NetCDF export'; return 1; endif
  'set x 1 3'
  'set y 1 3'
  'txtwrite -csv -header netcdf-wind.csv mag(ugrd_850mb,vgrd_850mb)'
  if (rc!=0); say 'FAIL: NetCDF text evaluation'; return 1; endif
  say 'PASS: existing GFS NetCDF fixture'
  return 0
