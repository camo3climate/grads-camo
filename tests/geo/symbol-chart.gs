function main(args)
  'reinit'
  'set display color white'
  'clear'
  'set line 1 1 3'
  'set string 1 c 2 0'
  'set strsiz 0.1'
  n=1
  while (n<=43)
    col=math_mod(n-1,9)
    row=(n-1)/9
    row=math_int(row)
    x=0.8+col*1.1
    y=7.2-row*1.05
    'draw wxsym 'n' 'x' 'y' 0.32'
    'draw string 'x' 'y-0.4' 'n
    n=n+1
  endwhile
  n=0
  while (n<=12)
    x=0.6+n*0.8
    'draw mark 'n' 'x' 1.25 0.22'
    'draw string 'x' 0.85 'n
    n=n+1
  endwhile
  'gxprint symbols.png x1200'
  if (rc!=0); return 1; endif
  say 'PASS: symbol chart'
  return 0
