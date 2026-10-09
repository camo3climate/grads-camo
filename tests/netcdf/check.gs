function main(args)
  'sdfopen attributes.nc'
  if (rc!=0); say 'FAIL: attributes fixture open'; return 1; endif
  'q file'
  say result
  'q attr'
  say result
  'set x 1 3'
  'set y 1 2'
  'set t 1'
  'txtwrite -csv -header sample.csv sample'
  if (rc!=0); say 'FAIL: numeric sample read'; return 1; endif
  'txtwrite -csv -header packed.csv packed'
  if (rc!=0); say 'FAIL: unsigned missing-value read'; return 1; endif
  'close 1'
  i=1
  while (i<=12)
    file=subwrd('bad-array.nc bad-text.nc long-name.nc no-axis.nc irregular.nc extra-dim.nc bad-string-array.nc all-leap.nc julian.nc unknown-calendar.nc noleap.nc bad-numeric.nc',i)
    'sdfopen 'file
    if (rc=0); say 'FAIL: accepted malformed metadata 'file; return 1; endif
    say result
    i=i+1
  endwhile
  'sdfopen attributes.nc'
  if (rc!=0); say 'FAIL: reopen after rejected metadata'; return 1; endif
  'close 1'
  'sdfopen monthly.nc'
  if (rc!=0); say 'FAIL: calendar-month axis'; return 1; endif
  'set t 3'
  'q time'
  say result
  'close 1'
  'sdfopen proleptic.nc'
  if (rc!=0); say 'FAIL: modern proleptic Gregorian dates'; return 1; endif
  'close 1'
  'sdfopen year-alias.nc'
  if (rc!=0); say 'FAIL: yearly UDUNITS alias'; return 1; endif
  'set t 3'
  'q time'
  say result
  'close 1'
  'open bad-array.ctl'
  if (rc!=0); say 'FAIL: explicit descriptor open'; return 1; endif
  'set gxout stat'
  'd sample'
  if (rc=0); say 'FAIL: accepted array into scalar attribute'; return 1; endif
  say result
  'close 1'
  'xdfopen noleap.ctl'
  if (rc!=0); say 'FAIL: existing explicit noleap descriptor'; return 1; endif
  'close 1'
  say 'PASS: NetCDF metadata regression'
  'quit'
return
