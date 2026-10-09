* CAMO26.2: run sigplot.gs P_EXPR [ALPHA [sig|nonsig [STRIDE [SIZE [MARK]]]]]
* Draw one mark per selected native grid point, NOT a page-anchored tile.
* P_EXPR must be on the current default file's grid; fixed Z/T/E, varying X/Y.
* Missing and out-of-range p values are excluded. sig: p<alpha, nonsig: p>=alpha.
* SIZE=0 (default): 20% of local projected grid spacing, capped at 0.08 page units.
function main(args)
  expr=subwrd(args,1)
  alpha=subwrd(args,2)
  mode=subwrd(args,3)
  step=subwrd(args,4)
  size=subwrd(args,5)
  mark=subwrd(args,6)
  if (expr='')
    say 'Usage: run sigplot.gs P_EXPR [ALPHA [sig|nonsig [STRIDE [SIZE [MARK]]]]]'
    return 1
  endif
  if (alpha=''); alpha=0.05; endif
  if (mode=''); mode='sig'; endif
  if (step=''); step=1; endif
  if (size=''); size=0; endif
  if (mark=''); mark=3; endif
  if (valnum(alpha)=0 | valnum(step)=0 | valnum(size)=0 | valnum(mark)=0)
    say 'sigplot: nonnumeric option'
    return 1
  endif
  if (alpha<=0 | alpha>=1 | step<1 | math_int(step)!=step | size<0 | mark<1 | mark>12 | math_int(mark)!=mark)
    say 'sigplot: invalid threshold, stride, size or marker'
    return 1
  endif
  if (mode!='sig' & mode!='nonsig')
    say 'sigplot: mode must be sig or nonsig'
    return 1
  endif
  'q dims'
  if (rc!=0); return 1; endif
  dims=result
  xd=sublin(dims,2); yd=sublin(dims,3)
  if (subwrd(xd,3)!='varying' | subwrd(yd,3)!='varying')
    say 'sigplot: X/Y must vary'
    return 1
  endif
  k=4
  while (k<=6)
    row=sublin(dims,k)
    if (subwrd(row,3)='varying')
      say 'sigplot: Z/T/E must be fixed'
      return 1
    endif
    k=k+1
  endwhile
  xlo=subwrd(xd,11); xhi=subwrd(xd,13)
  ylo=subwrd(yd,11); yhi=subwrd(yd,13)
  xlo=math_int(xlo); xhi=math_int(xhi)
  ylo=math_int(ylo); yhi=math_int(yhi)
  if (xlo<subwrd(xd,11)); xlo=xlo+1; endif
  if (ylo<subwrd(yd,11)); ylo=ylo+1; endif
  'q gxinfo'
  if (rc!=0); return 1; endif
  info=result
  axes=sublin(info,5)
  if (subwrd(axes,3)!='Lon' | subwrd(axes,6)!='Lat')
    say 'sigplot: first display the background longitude/latitude map'
    return 1
  endif
  row=sublin(info,3)
  xmin=subwrd(row,4); xmax=subwrd(row,6)
  row=sublin(info,4)
  ymin=subwrd(row,4); ymax=subwrd(row,6)
  'q define'
  if (rc!=0); return 1; endif
  k=1
  while (sublin(result,k)!='')
    row=sublin(result,k)
    if (subwrd(row,1)='camsig26')
      say 'sigplot: reserved temporary variable camsig26 already exists; not overwritten'
      return 1
    endif
    k=k+1
  endwhile
  'define camsig26 = 'expr
  if (rc!=0); return 1; endif
* q defval prints six significant digits. Compare the sign of p-alpha, not
* a rounded p; mask invalid original p values before that formatting step.
* Redefinition evaluates the saved field, so the user's expression runs once.
  'define camsig26 = maskout(maskout(camsig26-('alpha'),camsig26),1-camsig26)'
  if (rc!=0); 'undefine camsig26'; return 1; endif
  count=0
  j=ylo
  while (j<=yhi)
    i=xlo
    while (i<=xhi)
      'q defval camsig26 'i' 'j
      if (rc!=0); 'undefine camsig26'; return 1; endif
      p=subwrd(result,3)
      ok=0
      if (valnum(p)!=0)
        if (mode='sig' & p<0); ok=1; endif
        if (mode='nonsig' & p>=0); ok=1; endif
      endif
      if (ok)
        'q gr2xy 'i' 'j
        x=subwrd(result,3); y=subwrd(result,6)
        if (x>=xmin & x<=xmax & y>=ymin & y<=ymax)
          s=size
          if (s=0)
            ni=i+1; nj=j+1
            if (i=xhi); ni=i-1; endif
            if (j=yhi); nj=j-1; endif
            'q gr2xy 'ni' 'j
            dx=subwrd(result,3)-x; dy=subwrd(result,6)-y
            h=math_sqrt(dx*dx+dy*dy)
            'q gr2xy 'i' 'nj
            dx=subwrd(result,3)-x; dy=subwrd(result,6)-y
            v=math_sqrt(dx*dx+dy*dy)
            s=0.2*h
            if (v<h); s=0.2*v; endif
            if (s>0.08); s=0.08; endif
          endif
          if (s>0)
            'q gr2w 'i' 'j
            lon=subwrd(result,3); lat=subwrd(result,6)
            'draw geomark 'mark' 'lon' 'lat' 's
            if (rc!=0); 'undefine camsig26'; return 1; endif
            count=count+1
          endif
        endif
      endif
      i=i+step
    endwhile
    j=j+step
  endwhile
  'undefine camsig26'
  say 'sigplot: 'count' markers; mode='mode' alpha='alpha
  return 0
