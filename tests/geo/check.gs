function main(args)
  'open field.ctl'
  if (rc!=0); say 'FAIL: open'; return 1; endif
  'set display color white'
  'clear'
  'set lon -180 180'
  'set lat -90 90'
  'set gxout shaded'
  'd field'
  'set line 2 1 5'
  'draw geoline 170 10 -170 30'
  if (rc!=0); say 'FAIL: seam'; return 1; endif
  'draw geoline -200 -20 -140 10'
  if (rc!=0); say 'FAIL: clipping'; return 1; endif
  'draw geoline 0 91 1 2'
  if (rc=0); say 'FAIL: latitude accepted'; return 1; endif
  'draw geoline 0 0 1 2 extra'
  if (rc=0); say 'FAIL: trailing argument'; return 1; endif
  'draw geoline 0junk 0 1 2'
  if (rc=0); say 'FAIL: malformed longitude accepted'; return 1; endif
  'draw geoline 0 0 1 2junk'
  if (rc=0); say 'FAIL: malformed latitude accepted'; return 1; endif
  'draw geoline 0 0 1e999 2'
  if (rc=0); say 'FAIL: infinite longitude accepted'; return 1; endif
  'draw geomark 13 10 20 0.1'
  if (rc=0); say 'FAIL: invalid mark'; return 1; endif
  'draw geomark 3 10 20 -0.1'
  if (rc=0); say 'FAIL: negative size'; return 1; endif
  'draw geomark 3.5 10 20 0.1'
  if (rc=0); say 'FAIL: fractional mark accepted'; return 1; endif
  'draw geomark 4294967299 10 20 0.1'
  if (rc=0); say 'FAIL: oversized mark accepted'; return 1; endif
  'draw geomark 3 10 20 0.1junk'
  if (rc=0); say 'FAIL: malformed size accepted'; return 1; endif
  'draw geostring 10 100 Invalid'
  if (rc=0); say 'FAIL: invalid text latitude'; return 1; endif
  'draw geostring 10junk 20 Invalid'
  if (rc=0); say 'FAIL: malformed text coordinate accepted'; return 1; endif
  'draw geowxsym 44 10 20 0.1'
  if (rc=0); say 'FAIL: invalid weather symbol'; return 1; endif
  'draw geowxsym 41 10 20 0.1 1 3 extra'
  if (rc=0); say 'FAIL: extra weather argument'; return 1; endif
  'draw geowxsym 41.5 10 20 0.1'
  if (rc=0); say 'FAIL: fractional weather symbol accepted'; return 1; endif
  'draw geowxsym 41 10 20 0.1 1.5'
  if (rc=0); say 'FAIL: fractional color accepted'; return 1; endif
  'draw geowxsym 41 10 20 0.1 1 3.5'
  if (rc=0); say 'FAIL: fractional thickness accepted'; return 1; endif
  'draw geocirc 40 0 0.1'
  if (rc!=0); say 'FAIL: existing geocirc'; return 1; endif
  'draw geovec 40 10 5 10'
  if (rc!=0); say 'FAIL: existing geovec'; return 1; endif
  'draw georec -20 -20 20 -10'
  if (rc!=0); say 'FAIL: existing georec'; return 1; endif
* Wrapping a large finite longitude must finish, not subtract 360 forever.
  'draw geocirc 1e300 0 0.1'
  if (rc!=0); say 'FAIL: large-longitude geocirc'; return 1; endif
  'draw geovec 1e300 10 5 10'
  if (rc!=0); say 'FAIL: large-longitude geovec'; return 1; endif
  'draw georec 1e300 -20 100 -10'
  if (rc!=0); say 'FAIL: large-longitude georec'; return 1; endif
  'draw geocirc inf 0 0.1'
  if (rc=0); say 'FAIL: infinite geocirc longitude accepted'; return 1; endif
  'draw geocirc 0 0 inf'
  if (rc=0); say 'FAIL: infinite geocirc radius accepted'; return 1; endif
  'draw geovec 0 nan 5 10'
  if (rc=0); say 'FAIL: NaN geovec latitude accepted'; return 1; endif
  'draw georec 0 -20 inf -10'
  if (rc=0); say 'FAIL: infinite georec coordinate accepted'; return 1; endif
  'set string 1 c 3'
  'set strsiz 0.12'
  'draw geostring 0 0 Text with spaces 850 hPa'
  if (rc!=0); say 'FAIL: text'; return 1; endif
  'draw geowxsym 41 80 30 0.3'
  if (rc!=0); say 'FAIL: weather symbol'; return 1; endif
  'draw geomark 12 0 40 0.2'
  if (rc!=0); say 'FAIL: diamond'; return 1; endif
  'run geotrack.gs track.txt 0.1 2'
  if (rc!=0); say 'FAIL: geotrack'; return 1; endif
  'gxprint geographic-latlon.png x1000'
  if (rc!=0); say 'FAIL: png'; return 1; endif
  'set x 2 5'
  'set y 2 3'
  'clear'
  'd field'
  'q dims'
  before=result
  'run sigplot.gs p 0.05 sig'
  if (rc!=0); say 'FAIL: sigplot'; return 1; endif
  'run sigplot.gs p 0.05 nonsig'
  if (rc!=0); say 'FAIL: nonsigplot'; return 1; endif
* Exact equality is nonsignificant; the expression's subtraction yields zero.
  'run sigplot.gs p*0+0.05 0.05 sig'
  if (rc!=0); say 'FAIL: exact-threshold sigplot'; return 1; endif
  'run sigplot.gs p*0+0.05 0.05 nonsig'
  if (rc!=0); say 'FAIL: exact-threshold nonsigplot'; return 1; endif
  'q dims'
  if (result!=before); say 'FAIL: dimensions changed'; return 1; endif
  'q define'
  if (subwrd(result,1)!='No'); say 'FAIL: temporary variable leaked'; return 1; endif
  'gxprint significance.png x800'
* Each projection must keep an inside line and clip crossing edges.
  projections='nps sps robinson mollweide orthogr'
  n=1
  while (n<=5)
    proj=subwrd(projections,n)
    'clear'
    'set lon -180 180'
    'set lat -90 90'
    if (proj='nps'); 'set lat 0 90'; endif
    if (proj='sps'); 'set lat -90 0'; endif
    if (proj='orthogr'); 'set lon -90 90'; endif
    'set mproj 'proj
    'd field'
    'set line 2 1 5'
    'draw geoline -100 -60 60 70'
    if (rc!=0); say 'FAIL: projection 'proj; return 1; endif
    'draw geoline 170 40 -170 50'
    if (rc!=0); say 'FAIL: seam projection 'proj; return 1; endif
    'set line 2 3 4'
    'draw geoline -60 20 60 30'
    'draw geomark 3 0 40 0.15'
    'draw geostring 0 30 'proj
    'gxprint geographic-'proj'.png x800'
    if (rc!=0); say 'FAIL: projection export'; return 1; endif
    n=n+1
  endwhile
  say 'PASS: geographic commands and helpers'
  return 0
