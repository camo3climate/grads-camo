function main(args)
  _fail=0
  _checks=0
  'open percentile-test.ctl'
  if (rc!=0); say 'FAIL: open'; return 1; endif
  'set gxout print'
  'set prnopts %g 1 1'
  'set x 1'
  'set y 1'
  'set z 1'
  'set t 3'
  check('percentile(v,e=1,e=3,0)', '131')
  check('percentile(v,e=1,e=3,5)', '141')
  check('percentile(v,e=1,e=3,50)', '231')
  check('percentile(v,ens=e1,ens=e3,50)', '231')
  check('percentile(v,e=1,e=3,95)', '321')
  check('percentile(v,e=1,e=3,100)', '331')
  check('percentile(v,e=1,e=2,25)', '156')
  check('percentile(-v,e=1,e=3,25)', '-281')
  check('percentile(v,e=1,e=3,0)-min(v,e=1,e=3)', '0')
  check('percentile(v,e=1,e=3,100)-max(v,e=1,e=3)', '0')
  check('percentile(percentile(v,t=1,t=5,50),e=1,e=3,50)', '231')
  check('percentile(7,e=1,e=3,50)', '7')
  'set x 2'
  check('percentile(v,e=1,e=3,50)', '232')
  check('percentile(v,e=1,e=2,95)', '132')
  check('percentile(v,e=2,e=2,50)', 'undef')
  'set x 1'
  'set t 1'
  check('percentile(v,t=1,t=5,25)', '121')
  check('percentile(v,t=1,t=5,50,2)', '131')
  check('percentile(v,t=1,t=5,25,2hr)', '121')
  check('percentile(v,t=1,t=5,25,1hr60mn)', '121')
  check('percentile(v,t=1,t=5,50,1dy)', '111')
  check('percentile(v,time=00z01jan2000,time=04z01jan2000,50)', '131')
  'set t 1 5'
  check('percentile(v,e=1,e=3,50)', '211 221 231 241 251')
  'set x 1 3'
  check('percentile(v,e=1,e=3,50)', '211 212 213 221 222 223 231 232 233 241 242 243 251 252 253')
  'set t 1'
  check('percentile(v,x=1,x=3,50)', '112')
  'set x 1'
  check('percentile(v,lon=0,lon=2,25)', '111.5')
  check('percentile(v,x=1.2,x=2.8,50)', '112')
  check('percentile(7,x=2147483647,x=2147483647,50)', '7')
  check('percentile(7,x=-2147483648,x=-2147483648,50)', '7')
  check('percentile(7,t=1,t=2,50,2147483647)', '7')
* Arithmetic expressions can create non-finite samples with a valid mask.
  check('percentile(exp(1000)+v,e=1,e=3,50)', 'undef')
  check('percentile((v-161)*3e306,e=1,e=2,50)', '0')
  check('percentile((v-161)*3e306,e=1,e=2,25)', '-7.5e307')
  reject('percentile(v,e=1,e=3)')
  reject('percentile(v,e=1,e=3,-1)')
  reject('percentile(v,e=1,e=3,101)')
  reject('percentile(v,e=1,e=3,nan)')
  reject('percentile(v,e=1,e=3,inf)')
  reject('percentile(v,e=1,e=3,50junk)')
  reject('percentile(v,e=3,e=1,50)')
  reject('percentile(v,e=1,t=3,50)')
  reject('percentile(v,e=1,bad,50)')
  reject('percentile(v,ens=missing,ens=e3,50)')
  reject('percentile(v,ens=e1,ens=missing,50)')
  reject('percentile(v,ens=e1,ens=e3junk,50)')
  reject('percentile(v,e=1junk,e=3,50)')
  reject('percentile(v,e=1,e=3junk,50)')
  reject('percentile(v,x=nan,x=3,50)')
  reject('percentile(v,x=1,x=inf,50)')
  reject('percentile(v,x=1e40,x=1e40,50)')
  reject('percentile(v,x=1.2,x=1.8,50)')
  reject('percentile(v,e=1,e=3,50,2)')
  reject('percentile(v,t=1,t=5,50,0)')
  reject('percentile(v,t=1,t=5,50,-1)')
  reject('percentile(v,t=1,t=5,50,30mn)')
  reject('percentile(v,t=1,t=5,50,1mo)')
  reject('percentile(v,t=1,t=5,50,2hrjunk)')
  reject('percentile(v,t=1,t=5,50,1hr1mo)')
  reject('percentile(v,t=1,t=5,50,99999999999999999999999)')
  reject('percentile(v,t=1,t=5,50,1hr99999999999999999999999mn)')
  check('percentile(v,e=1,e=3,50)', '211')
  'open percentile-monthly.ctl'
  'set dfile 2'
  'set x 1'
  'set t 1'
  check('percentile(v,t=1,t=5,25,2mo)', '121')
  check('percentile(v,t=1,t=5,50,1yr)', '111')
  reject('percentile(v,t=1,t=5,50,1dy)')
  'open percentile-xyz.ctl'
  'set dfile 3'
  'set x 1'
  'set y 1'
  'set z 1'
  'set t 1'
  'set e 1'
  check('percentile(v,x=1,x=4,50)', '11112.5')
  check('percentile(v,y=1,y=3,25)', '11116')
  check('percentile(v,lat=-30,lat=30,50)', '11121')
  check('percentile(v,z=1,z=3,50)', '11211')
  check('percentile(v,lev=1000,lev=500,25)', '11161')
  check('percentile(v,lev=900,lev=600,50)', '11211')
  'set x 1 4'
  'set y 1 3'
  check('percentile(v,t=1,t=2,50)', '11611 11612 11613 11614 11621 11622 11623 11624 11631 11632 11633 11634')
  check('percentile(v,x=1,x=4,50)', '11112.5 11122.5 11132.5')
  check('percentile(v,y=1,y=3,50)', '11121 11122 11123 11124')
  if (_fail!=0); say 'FAIL: '_fail' percentile checks'; return 1; endif
  say 'PASS: percentile regression ('_checks' checks)'
  return 0

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
        if (math_abs(delta)>0.00001); bad=1; endif
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

function reject(expr)
  _checks=_checks+1
  'd 'expr
  if (rc=0)
    say 'FAIL: invalid expression accepted: 'expr
    _fail=_fail+1
  endif
  return
