/* Native NetCDF API fixtures: no netcdf-fortran or Python dependency. */
#include <netcdf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NC(call) do { int rc_=(call); if(rc_!=NC_NOERR) { \
  fprintf(stderr,"%s: %s\n",#call,nc_strerror(rc_)); exit(1); } } while(0)

static void textatt(int file,int var,const char *name,const char *text) {
  NC(nc_put_att_string(file,var,name,1,&text));
}

static void fixture(const char *path, int kind) {
  int file,dt,dy,dx,extra=-1,t,y,x,v,u,shape[4],rank=3,i;
  double lon[]={130,140,150},lat[]={-10,10},time[]={0,1,2};
  double data[18];
  unsigned int packed[18],fill=4294967295U;
  signed char bytes[]={-128,0,127};
  unsigned char ubytes[]={0,128,255};
  short shorts[]={-32768,0,32767};
  unsigned short ushorts[]={0,32768,65535};
  int ints[]={-2147483647,0,2147483647};
  unsigned int uints[]={0,2147483648U,4294967295U};
  long long int64[]={-9223372036854775807LL,0,9223372036854775807LL};
  unsigned long long uint64[]={0,9223372036854775808ULL,18446744073709551615ULL};
  float floats[]={-1.25f,0,1.25f};
  double doubles[]={-2.5,0,2.5},missing[]={-999,-888};
  const char *strings[]={"first string","second string",""};
  const char *axis_strings[]={"degrees_east","degrees_north"};
  char longname[NC_MAX_NAME+1];
  for(i=0;i<18;i++) {data[i]=i+1;packed[i]=(unsigned int)(i+1);}
  packed[4]=fill;
  NC(nc_create(path,NC_NETCDF4|NC_NOCLOBBER,&file));
  NC(nc_def_dim(file,"time",3,&dt));
  NC(nc_def_dim(file,"lat",2,&dy));
  NC(nc_def_dim(file,"lon",3,&dx));
  NC(nc_def_var(file,"time",NC_DOUBLE,1,&dt,&t));
  NC(nc_def_var(file,"lat",NC_DOUBLE,1,&dy,&y));
  NC(nc_def_var(file,"lon",NC_DOUBLE,1,&dx,&x));
  shape[0]=dt;shape[1]=dy;shape[2]=dx;
  if(kind==7) {
    NC(nc_def_dim(file,"expver",1,&extra));
    shape[0]=dt;shape[1]=extra;shape[2]=dy;shape[3]=dx;rank=4;
  }
  NC(nc_def_var(file,"sample",NC_DOUBLE,rank,shape,&v));
  NC(nc_def_var(file,"packed",NC_UINT,rank,shape,&u));
  textatt(file,NC_GLOBAL,"title","NetCDF string title intact");
  textatt(file,t,"units",kind==5 ? "days since 2024-01-01 00:00:00" : "hours since 2024-01-01 00:00:00");
  if(kind==9) textatt(file,t,"calendar","all_leap");
  if(kind==10) textatt(file,t,"calendar","julian");
  if(kind==11) textatt(file,t,"calendar","unknown_calendar");
  if(kind==12) textatt(file,t,"calendar","proleptic_gregorian");
  if(kind==13) textatt(file,t,"units","yr since 2024-01-01 00:00:00");
  if(kind==14) textatt(file,t,"calendar","noleap");
  if(kind==15) textatt(file,v,"scale_factor","not a number");
  textatt(file,y,"units","degrees_north");
  if(kind==2) NC(nc_put_att_int(file,x,"units",NC_INT,3,ints));
  else if(kind==8) NC(nc_put_att_string(file,x,"units",2,axis_strings));
  else if(kind!=6) textatt(file,x,"units","degrees_east");
  textatt(file,v,"long_name","Readable string variable description");
  NC(nc_put_att_uint(file,u,"_FillValue",NC_UINT,1,&fill));
  if(kind==1) NC(nc_put_att_double(file,v,"missing_value",NC_DOUBLE,2,missing));
  if(kind==3) {
    memset(longname,'a',sizeof(longname)-1);longname[sizeof(longname)-1]='\0';
    textatt(file,NC_GLOBAL,longname,"long attribute name");
  }
  NC(nc_put_att_schar(file,NC_GLOBAL,"bytes",NC_BYTE,3,bytes));
  NC(nc_put_att_uchar(file,NC_GLOBAL,"ubytes",NC_UBYTE,3,ubytes));
  NC(nc_put_att_short(file,NC_GLOBAL,"shorts",NC_SHORT,3,shorts));
  NC(nc_put_att_ushort(file,NC_GLOBAL,"ushorts",NC_USHORT,3,ushorts));
  NC(nc_put_att_int(file,NC_GLOBAL,"ints",NC_INT,3,ints));
  NC(nc_put_att_uint(file,NC_GLOBAL,"uints",NC_UINT,3,uints));
  NC(nc_put_att_longlong(file,NC_GLOBAL,"int64",NC_INT64,3,int64));
  NC(nc_put_att_ulonglong(file,NC_GLOBAL,"uint64",NC_UINT64,3,uint64));
  NC(nc_put_att_float(file,NC_GLOBAL,"floats",NC_FLOAT,3,floats));
  NC(nc_put_att_double(file,NC_GLOBAL,"doubles",NC_DOUBLE,3,doubles));
  NC(nc_put_att_string(file,NC_GLOBAL,"strings",3,strings));
  NC(nc_put_att_text(file,NC_GLOBAL,"empty",0,""));
  NC(nc_enddef(file));
  if(kind==4) time[2]=3;
  if(kind==5) {time[1]=31;time[2]=60;}
  NC(nc_put_var_double(file,t,time));
  NC(nc_put_var_double(file,y,lat));
  NC(nc_put_var_double(file,x,lon));
  NC(nc_put_var_double(file,v,data));
  NC(nc_put_var_uint(file,u,packed));
  NC(nc_close(file));
}

int main(void) {
  const char *names[]={"attributes.nc","bad-array.nc","bad-text.nc","long-name.nc",
    "irregular.nc","monthly.nc","no-axis.nc","extra-dim.nc","bad-string-array.nc",
    "all-leap.nc","julian.nc","unknown-calendar.nc","proleptic.nc","year-alias.nc","noleap.nc",
    "bad-numeric.nc"};
  unsigned int i;
  for(i=0;i<sizeof(names)/sizeof(names[0]);i++) fixture(names[i],(int)i);
  return 0;
}
