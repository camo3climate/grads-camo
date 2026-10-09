* Existing CAMO feature smoke checks; not a full numerical equivalence suite.
function main(args)
  'open field.ctl'
  if (rc!=0); say 'FAIL: fixture open'; return 1; endif
  'set x 2 10'
  'set y 2 10'
  methods='bl bs ba ma'
  k=1
  while (k<=4)
    method=subwrd(methods,k)
    extra=''
    if (method='ma'); extra=',0.5'; endif
    'txtwrite -csv -header re-'method'.csv re(field*0+7,3,linear,-150,20,3,linear,-60,20,'method''extra')'
    if (rc!=0); say 'FAIL: re 'method; return 1; endif
    k=k+1
  endwhile
  'set x 2 5'
  'set y 2'
  'txtwrite -header row.txt p'
  if (rc!=0); say 'FAIL: txtwrite 1-D'; return 1; endif
  'set y 2 3'
  'txtwrite -CSV -HEADER -UNDEF NA GridCase.csv P'
  if (rc!=0); say 'FAIL: txtwrite 2-D'; return 1; endif

  'set x 1 37'
  'set y 1 19'
  'set theme classic'
  if (rc!=0); say 'FAIL: classic theme'; return 1; endif
  'clear'
  'set gxout contour'
  'd field'
  if (rc!=0); say 'FAIL: classic display'; return 1; endif
  'gxprint theme-classic.png x800'
  if (rc!=0); say 'FAIL: classic export'; return 1; endif
  'set theme modern'
  if (rc!=0); say 'FAIL: modern theme'; return 1; endif
  'clear'
  'set gxout shaded'
  'set rgbmap cividis'
  if (rc!=0); say 'FAIL: cividis rgbmap'; return 1; endif
  'd field'
  if (rc!=0); say 'FAIL: modern display'; return 1; endif
  'gxprint theme-modern.png x800'
  if (rc!=0); say 'FAIL: modern export'; return 1; endif
  'set rgbmap RdBu_r'
  if (rc!=0); say 'FAIL: reversed rgbmap'; return 1; endif

* Red below blue: pixel check distinguishes alpha blending and draw order.
  'set display color white'
  'clear'
  'set rgb 40 255 0 0 128'
  if (rc!=0); say 'FAIL: red alpha'; return 1; endif
  'set rgb 41 0 0 255 128'
  if (rc!=0); say 'FAIL: blue alpha'; return 1; endif
  'set line 40'
  'draw recf 1 2 4 5'
  if (rc!=0); say 'FAIL: red rectangle'; return 1; endif
  'set line 41'
  'draw recf 3 3 6 6'
  if (rc!=0); say 'FAIL: blue rectangle'; return 1; endif
  'gxprint alpha-overlap.png x1100 y850'
  if (rc!=0); say 'FAIL: alpha export'; return 1; endif
  say 'PASS: compatibility commands'
  return 0
