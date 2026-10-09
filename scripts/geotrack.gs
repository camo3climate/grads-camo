* CAMO26.2: run geotrack.gs FILE [SIZE [LABEL_EVERY]]
* Columns: lon lat [time [track_id [marktype]]], whitespace separated.
* Blank lines or '>' break tracks; # is a comment; NA coordinates break tracks.
* Draw a map first. SIZE is page units. No statistical/track inference is done.
function main(args)
  file=subwrd(args,1)
  size=subwrd(args,2)
  every=subwrd(args,3)
  if (file='')
    say 'Usage: run geotrack.gs FILE [SIZE [LABEL_EVERY]]'
    return 1
  endif
  if (size=''); size=0.08; endif
  if (every=''); every=0; endif
  if (valnum(size)=0 | valnum(every)=0)
    say 'geotrack: size/label interval must be numeric'
    return 1
  endif
  if (size<=0 | every<0 | math_int(every)!=every)
    say 'geotrack: size > 0; label interval must be an integer >= 0'
    return 1
  endif
  prev=0
  count=0
  line=0
  while (1)
    rec=read(file)
    code=sublin(rec,1)
    if (code=2); break; endif
    if (code!=0)
      say 'geotrack: read failed: 'file
      dummy=close(file)
      return 1
    endif
    line=line+1
    row=sublin(rec,2)
    lon=subwrd(row,1)
    if (substr(lon,1,1)='#'); continue; endif
    if (lon='' | lon='>')
      prev=0
      count=0
      continue
    endif
    lat=subwrd(row,2)
    if (lon='NA' | lat='NA')
      prev=0
      continue
    endif
    if (valnum(lon)=0 | valnum(lat)=0)
      say 'geotrack: invalid coordinates at line 'line
      dummy=close(file)
      return 1
    endif
    if (lat < -90 | lat > 90)
      say 'geotrack: latitude out of range at line 'line
      dummy=close(file)
      return 1
    endif
    label=subwrd(row,3)
    id=subwrd(row,4)
    mark=subwrd(row,5)
    if (mark=''); mark=3; endif
    if (valnum(mark)=0)
      say 'geotrack: invalid mark at line 'line
      dummy=close(file)
      return 1
    endif
    if (mark<0 | mark>12 | math_int(mark)!=mark | subwrd(row,6)!='')
      say 'geotrack: expected lon lat [time [track_id [marktype(0..12)]]] at line 'line
      dummy=close(file)
      return 1
    endif
    if (prev=1 & id=lastid)
      'draw geoline 'lastlon' 'lastlat' 'lon' 'lat
      if (rc!=0); dummy=close(file); return 1; endif
    else
      count=0
    endif
    'draw geomark 'mark' 'lon' 'lat' 'size
    if (rc!=0); dummy=close(file); return 1; endif
    if (every>0 & label!='')
      if (math_mod(count,every)=0)
        'draw geostring 'lon' 'lat' 'label
        if (rc!=0); dummy=close(file); return 1; endif
      endif
    endif
    count=count+1
    lastlon=lon
    lastlat=lat
    lastid=id
    prev=1
  endwhile
  dummy=close(file)
  say 'geotrack: input complete ('line' lines)'
  return 0
