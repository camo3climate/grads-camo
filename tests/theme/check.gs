* Run in a fresh Cairo-backed GrADS process; state.c checks non-Cairo fallback.
function main(args)
  'q font 0'
  if (subwrd(result,3)!='generic'); say 'FAIL: startup font'; return 1; endif
  'q gxout'
  if (sublin(result,1)!='General = Display'); say 'FAIL: startup General'; return 1; endif
  line=sublin(result,4)
  if (subwrd(line,6)!='Shaded2'); say 'FAIL: startup shaded2'; return 1; endif
  'open field.ctl'
  if (rc!=0); say 'FAIL: fixture open'; return 1; endif
  'd field'
  if (rc!=0); say 'FAIL: startup display'; return 1; endif
  'q shades'
  line=sublin(result,2)
  if (subwrd(line,1)!=16); say 'FAIL: startup cividis'; return 1; endif
  'gxprint modern-startup.png x800'
  if (rc!=0); say 'FAIL: startup PNG'; return 1; endif

* Explicit classic and output selection survive clear and opening another file.
  'set theme classic'
  'set gxout contour'
  'clear'
  'open field.ctl'
  'q font 0'
  if (subwrd(result,3)!='hershey'); say 'FAIL: clear/open font override'; return 1; endif
  'q gxout'
  line=sublin(result,4)
  if (subwrd(line,6)!='Contour'); say 'FAIL: clear/open gxout'; return 1; endif
  'close 2'

* Paper must preserve a user's non-default palette, custom colors/levels and
* gxout. Compare the actual plotted levels and page coordinates before/after.
  'set rgbmap RdBu_r 100'
  'set gxout shaded'
  'set clevs -1 -0.25 0.25 1'
  'set ccols 100 102 104 106 108'
  'set rbrange -2 2'
  'set cthick 7'
  'd field'
  'q shades'
  shades=result
  'q gxout'
  gxout=result
  'q col 100'
  col100=result
  'q w2xy 0 30'
  position=result
* Display consumes per-plot clevs/ccols; restore them BEFORE the theme under test.
  'set clevs -1 -0.25 0.25 1'
  'set ccols 100 102 104 106 108'
  'set rbrange -2 2'
  'set theme paper'
  if (rc!=0); say 'FAIL: paper command'; return 1; endif
  'q gxout'
  if (result!=gxout); say 'FAIL: paper changed gxout'; return 1; endif
  'q col 100'
  if (result!=col100); say 'FAIL: paper changed palette'; return 1; endif
  'q bcol'
  if (subwrd(result,4)!=1); say 'FAIL: paper background'; return 1; endif
  'q font 0'
  if (subwrd(result,3)!='generic'); say 'FAIL: paper font'; return 1; endif
  'd field'
  'q shades'
  if (result!=shades)
    say 'Before: 'shades
    say 'After: 'result
    say 'FAIL: paper changed levels or colors'
    return 1
  endif
  'q w2xy 0 30'
  if (result!=position); say 'FAIL: paper changed map aspect'; return 1; endif

* Start a clean paper page. Clear has its ordinary GrADS semantics: reapply
* contour levels/colors after it, while the palette and theme styling remain.
  'clear'
  'q bcol'
  if (subwrd(result,4)!=1); say 'FAIL: clear paper background'; return 1; endif
  'q font 0'
  if (subwrd(result,3)!='generic'); say 'FAIL: clear paper font'; return 1; endif
  'set clevs -1 -0.25 0.25 1'
  'set ccols 100 102 104 106 108'
  'd field'
  'draw title Paper theme: user RdBu palette and fixed contour levels'
  'gxprint paper.png x800'
  if (rc!=0); say 'FAIL: paper PNG'; return 1; endif
  'gxprint paper.pdf'
  if (rc!=0); say 'FAIL: paper PDF'; return 1; endif
  'gxprint paper.svg'
  if (rc!=0); say 'FAIL: paper SVG'; return 1; endif

* Reset matches modern startup, retaining the existing background convention.
  'set theme classic'
  'set gxout contour'
  'reset'
  'q font 0'
  if (subwrd(result,3)!='generic'); say 'FAIL: reset font'; return 1; endif
  'q gxout'
  line=sublin(result,4)
  if (subwrd(line,6)!='Shaded2'); say 'FAIL: reset gxout'; return 1; endif
  'q bcol'
  if (subwrd(result,4)!=1); say 'FAIL: reset background compatibility'; return 1; endif
  'd field'
  'q shades'
  line=sublin(result,2)
  if (subwrd(line,1)!=16); say 'FAIL: reset cividis'; return 1; endif
  'set theme classic'
  'reinit'
  'q font 0'
  if (subwrd(result,3)!='generic'); say 'FAIL: reinit font'; return 1; endif
  'q gxout'
  line=sublin(result,4)
  if (subwrd(line,6)!='Shaded2'); say 'FAIL: reinit gxout'; return 1; endif
  'q bcol'
  if (subwrd(result,4)!=0); say 'FAIL: reinit black background'; return 1; endif
  'open field.ctl'
  'd field'
  'q shades'
  line=sublin(result,2)
  if (subwrd(line,1)!=16); say 'FAIL: reinit cividis'; return 1; endif

* Query previously indexed a three-item array with the 1-D style (0..4).
  'set gxout linefill'
  'q gxout'
  if (sublin(result,1)!='General = Display'); say 'FAIL: linefill General'; return 1; endif
  'set gxout errbar'
  'q gxout'
  if (sublin(result,1)!='General = Display'); say 'FAIL: errbar General'; return 1; endif
  'set gxout stat'
  'q gxout'
  if (sublin(result,1)!='General = Stat'); say 'FAIL: stat General'; return 1; endif
  'set gxout print'
  'q gxout'
  if (sublin(result,1)!='General = Print'); say 'FAIL: print General'; return 1; endif
  'set gxout writegds'
  'q gxout'
  if (sublin(result,1)!='General = WriteGDS'); say 'FAIL: writegds General'; return 1; endif
  'set gxout shade2b'
  'q gxout'
  line=sublin(result,4)
  if (subwrd(line,6)!='Shaded2b'); say 'FAIL: shade2b label'; return 1; endif
  'set gxout contour'
  'set theme modern'
  'q gxout'
  line=sublin(result,4)
  if (subwrd(line,6)!='Contour'); say 'FAIL: explicit modern changed gxout'; return 1; endif
  'help theme'
  say 'PASS: theme lifecycle, paper preservation, gxout query and exports'
  return 0
