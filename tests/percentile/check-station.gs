function main(args)
  'open percentile-station.ctl'
  if (rc!=0); say 'FAIL: station open'; return 1; endif
  'set lon 0'
  'set lat 0'
  'set lev 1000'
  'set t 1'
  dims='x y z t e ens'
  n=1
  while (n<=6)
    dim=subwrd(dims,n)
    'd percentile(7,'dim'=1,'dim'=1,50)'
    if (rc=0); say 'FAIL: station default accepted'; return 1; endif
    line=sublin(result,1)
    if (line!='Error from PERCENTILE: a gridded default file is required')
      say 'FAIL: expected station input rejection, got: 'line
      return 1
    endif
    n=n+1
  endwhile
  say 'PASS: percentile station rejection (6 checks)'
  return 0
