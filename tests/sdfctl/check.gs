function main(args)
  _fail=0
  _checks=0
  ok('sdfopen baseline.nc')
  ok('set x 2')
  ok('set y 3')
  ok('set t 2')
  ok('set gxout print')
  ok('set prnopts %g 1 1')
  'q files'
  _files=result
  'q dims'
  _dims=result
  reject('sdfopen regular.nc')
  unchanged('failed sdfopen')
  ok('sdfctl regular.nc PreviewCase.ctl')
  unchanged('explicit preview')
  ok('sdfctl regular.nc')
  unchanged('default preview')
  ok('sdfctl floatregular.nc FloatPreview.ctl')
  unchanged('float-coordinate preview')
  reject('sdfctl')
  reject('sdfctl regular.nc bad-args.ctl yes extra')
  reject('sdfctl regular.nc bad-answer.ctl no')
  reject('sdfctl regular.nc bad-case.ctl Yes')
  reject('sdfctl regular.nc existing.ctl yes')
  reject('sdfctl regular.nc input-link.ctl yes')
  reject('sdfctl regular.nc regular.nc yes')
  reject('sdfctl curvilinear.nc bad-curvilinear.ctl yes')
  reject('sdfctl irregularxy.nc bad-irregularxy.ctl yes')
  reject('sdfctl calendar360.nc bad-calendar360.ctl yes')
  reject('sdfctl ambiguous.nc bad-ambiguous.ctl yes')
  reject('sdfctl groups.nc bad-groups.ctl yes')
  reject('sdfctl packedaxis.nc bad-packedaxis.ctl yes')
  reject('sdfctl irregulartime.nc bad-irregulartime.ctl yes')
  reject('sdfctl aliascollision.nc bad-aliascollision.ctl yes')
  reject('sdfctl oversizedgrid.nc bad-oversizedgrid.ctl yes')
  unchanged('all rejected commands')
  check('field','232')
  check('packed','1116')
  ok('sdfctl regular.nc RegularCase.ctl yes')
  unchanged('explicit save')
  ok('sdfctl descending.nc DescendingCase.ctl yes')
  unchanged('descending save')
  ok('sdfctl floatregular.nc FloatRegular.ctl yes')
  unchanged('float-coordinate save')
  ok('xdfopen RegularCase.ctl')
  ok('set dfile 2')
  gridchecks()
  ok('xdfopen DescendingCase.ctl')
  ok('set dfile 3')
  gridchecks()
  ok('xdfopen FloatRegular.ctl')
  ok('set dfile 4')
  ok('set x 1')
  ok('set y 1')
  ok('set t 1')
  check('lon','130')
  check('field','111')
  ok('set x 50')
  check('lon','134.9')
  check('field','160')
  ok('set x 100')
  check('lon','139.9')
  check('field','210')
  ok('set lon 134.9')
  ok('set lat 10')
  ok('set time 00z03jan2000')
  check('field','380')
  if (_fail!=0); say 'FAIL: '_fail' sdfctl checks'; return 1; endif
  say 'PASS: sdfctl regression ('_checks' checks)'
  return 0

function gridchecks()
  ok('set x 1')
  ok('set y 1')
  ok('set z 1')
  ok('set t 1')
  check('lon','100')
  check('lat','-10')
  check('field','111')
  check('packed','1055.5')
  ok('set lon 120')
  ok('set lat 10')
  ok('set time 00z03jan2000')
  check('field','333')
  check('packed','1166.5')
  check('lon','120')
  check('lat','10')
  ok('set x 2')
  ok('set y 2')
  ok('set t 2')
  check('field','undef')
  check('packed','undef')
  ok('set x 1 3')
  ok('set y 1 3')
  check('field','211 212 213 221 undef 223 231 232 233')
  check('packed','1105.5 1106 1106.5 1110.5 undef 1111.5 1115.5 1116 1116.5')
  ok('set x 1')
  ok('set y 1')
  ok('set t 1 3')
  check('field','111 211 311')
  check('packed','1055.5 1105.5 1155.5')
  return

function unchanged(label)
  _checks=_checks+2
  'q files'
  if (result!=_files); say 'FAIL: open files changed after 'label; _fail=_fail+1; endif
  'q dims'
  if (result!=_dims); say 'FAIL: dimension environment changed after 'label; _fail=_fail+1; endif
  return

function ok(command)
  _checks=_checks+1
  command
  if (rc!=0)
    say 'FAIL: command rejected: 'command
    say result
    _fail=_fail+1
  endif
  return

function reject(command)
  _checks=_checks+1
  command
  if (rc=0)
    say 'FAIL: invalid command accepted: 'command
    _fail=_fail+1
  endif
  return

function check(expr,expected)
  _checks=_checks+1
  'd 'expr
  output=result
  if (rc!=0)
    say 'FAIL: expression rejected: 'expr
    _fail=_fail+1
    return
  endif
  first=1
  header=sublin(output,first)
  while (subwrd(header,1)!='Printing' & header!='')
    first=first+1
    header=sublin(output,first)
  endwhile
  if (header='')
    say 'FAIL: no printed grid for 'expr
    say output
    _fail=_fail+1
    return
  endif
  count=subwrd(header,4)
  undef=subwrd(header,9)
  n=1
  while (subwrd(expected,n)!='')
    want=subwrd(expected,n)
    line=sublin(output,n+first)
    got=subwrd(line,1)
    bad=0
    if (want='undef')
      if (got!=undef); bad=1; endif
    else
      if (got='' | got=undef)
        bad=1
      else
        delta=(got-want)/(1+math_abs(want))
        if (math_abs(delta)>0.000001); bad=1; endif
      endif
    endif
    if (bad)
      say 'FAIL: 'expr' sample 'n' expected 'want', got 'got
      _fail=_fail+1
    endif
    n=n+1
  endwhile
  if (count!=n-1)
    say 'FAIL: 'expr' returned 'count' values; expected 'n-1
    _fail=_fail+1
  endif
  return
