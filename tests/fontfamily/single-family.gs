function main(family)
  'reinit'
  'set display color white'
  'clear'
  'set theme modern'
  'set fontfamily 'family
  if (rc!=0); say 'FAIL: set fontfamily'; return 1; endif
  'set string 1 l 3 0'
  'set strsiz 0.22'
  'draw string 1 6 AgMWQxy 0123456789 850 hPa 25.4 mm/day'
  'set font 2'
  'draw string 1 5 AgMWQxy 0123456789 850 hPa 25.4 mm/day'
  'set font 4'
  'draw string 1 4 AgMWQxy 0123456789 850 hPa 25.4 mm/day'
  'gxprint font.png x1000'
  if (rc!=0); say 'FAIL: font PNG'; return 1; endif
  'gxprint font.pdf'
  if (rc!=0); say 'FAIL: font PDF'; return 1; endif
  say 'PASS: single family 'family
  return 0
