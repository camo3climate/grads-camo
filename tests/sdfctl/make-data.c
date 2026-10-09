/* Small NetCDF-C fixtures: no NetCDF-Fortran or external scientific data.
 * field(t,y,x) = 100*t + 10*y + x using 1-based logical south-to-north y.
 * packed contains the same raw integers, with value = raw*0.5 + 1000.
 */
#include <netcdf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NC(call) do { int status_=(call); if (status_!=NC_NOERR) { \
  fprintf(stderr,"%s:%d: %s\n",__FILE__,__LINE__,nc_strerror(status_)); exit(1); } } while (0)

enum variant { BASELINE, REGULAR, DESCENDING, CURVILINEAR, IRREGULAR_XY,
               CALENDAR360, AMBIGUOUS, GROUPS, PACKED_AXIS, IRREGULAR_TIME,
               ALIAS_COLLISION };

static void text_att(int ncid, int varid, const char *name, const char *value) {
  NC(nc_put_att_text(ncid,varid,name,strlen(value),value));
}

static void create(const char *filename, enum variant kind) {
  int ncid, xd, yd, td, xv, yv, tv, fv, pv, av=-1, child;
  int xy[2], dims[3], t, j, i, n;
  double lon[3]={100,110,120}, lat[3]={-10,0,10}, time[3]={0,24,48};
  double mesh_lon[9], mesh_lat[9];
  float field[27], missing=-9999, factor=0.5f, offset=1000;
  short packed[27], packed_missing=-32767;
  NC(nc_create(filename,NC_CLOBBER | (kind==GROUPS ? NC_NETCDF4 : 0),&ncid));
  NC(nc_def_dim(ncid,kind==BASELINE ? "lon" : "i",3,&xd));
  NC(nc_def_dim(ncid,kind==BASELINE ? "lat" : "j",3,&yd));
  NC(nc_def_dim(ncid,"time",3,&td));
  xy[0]=yd; xy[1]=xd;
  NC(nc_def_var(ncid,"lon",NC_DOUBLE,kind==CURVILINEAR ? 2 : 1,
                kind==CURVILINEAR ? xy : &xd,&xv));
  NC(nc_def_var(ncid,"lat",NC_DOUBLE,kind==CURVILINEAR ? 2 : 1,
                kind==CURVILINEAR ? xy : &yd,&yv));
  NC(nc_def_var(ncid,"time",NC_DOUBLE,1,&td,&tv));
  text_att(ncid,xv,"units","degrees_east");
  text_att(ncid,xv,"standard_name","longitude");
  text_att(ncid,yv,"units","degrees_north");
  text_att(ncid,yv,"standard_name","latitude");
  text_att(ncid,tv,"units","hours since 2000-01-01 00:00:00");
  text_att(ncid,tv,"calendar",kind==CALENDAR360 ? "360_day" : "standard");
  dims[0]=td; dims[1]=yd; dims[2]=xd;
  NC(nc_def_var(ncid,"field",NC_FLOAT,3,dims,&fv));
  NC(nc_def_var(ncid,"packed",NC_SHORT,3,dims,&pv));
  text_att(ncid,fv,"units","K");
  text_att(ncid,pv,"units","K");
  NC(nc_put_att_float(ncid,fv,"_FillValue",NC_FLOAT,1,&missing));
  NC(nc_put_att_float(ncid,fv,"missing_value",NC_FLOAT,1,&missing));
  NC(nc_put_att_short(ncid,pv,"_FillValue",NC_SHORT,1,&packed_missing));
  NC(nc_put_att_float(ncid,pv,"scale_factor",NC_FLOAT,1,&factor));
  NC(nc_put_att_float(ncid,pv,"add_offset",NC_FLOAT,1,&offset));
  if (kind==AMBIGUOUS) {
    NC(nc_def_var(ncid,"other_lon",NC_DOUBLE,1,&xd,&av));
    text_att(ncid,av,"units","degrees_east");
  }
  if (kind==GROUPS) NC(nc_def_grp(ncid,"nested",&child));
  if (kind==PACKED_AXIS) NC(nc_put_att_float(ncid,xv,"scale_factor",NC_FLOAT,1,&factor));
  if (kind==ALIAS_COLLISION) {
    /* Both names become abcdefghijklmno after the reader's 15-byte alias cap. */
    NC(nc_def_var(ncid,"abcdefghijklmno_one",NC_FLOAT,3,dims,&child));
    NC(nc_def_var(ncid,"abcdefghijklmno_two",NC_FLOAT,3,dims,&child));
  }
  NC(nc_enddef(ncid));
  if (kind==DESCENDING) { lat[0]=10; lat[2]=-10; }
  if (kind==IRREGULAR_XY) lon[2]=121;
  if (kind==IRREGULAR_TIME) time[2]=49;
  for (j=0;j<3;j++) for (i=0;i<3;i++) {
    mesh_lon[j*3+i]=lon[i]; mesh_lat[j*3+i]=lat[j];
  }
  NC(nc_put_var_double(ncid,xv,kind==CURVILINEAR ? mesh_lon : lon));
  NC(nc_put_var_double(ncid,yv,kind==CURVILINEAR ? mesh_lat : lat));
  NC(nc_put_var_double(ncid,tv,time));
  if (av>=0) NC(nc_put_var_double(ncid,av,lon));
  n=0;
  for (t=1;t<=3;t++) for (j=1;j<=3;j++) for (i=1;i<=3;i++) {
    int y=kind==DESCENDING ? 4-j : j;
    packed[n]=(short)(100*t+10*y+i);
    field[n]=(float)packed[n];
    if (t==2 && y==2 && i==2) { field[n]=missing; packed[n]=packed_missing; }
    n++;
  }
  NC(nc_put_var_float(ncid,fv,field));
  NC(nc_put_var_short(ncid,pv,packed));
  NC(nc_close(ncid));
}

static void create_oversized(void) {
  /* Chunked, unwritten field: only ~270 KB of coordinate/header data, not a
   * multi-GB allocation or file. Product exceeds INT_MAX/8 on supported OSes. */
  const size_t count=16385;
  size_t i, chunks[2]={32,32};
  int ncid, xd, yd, xv, yv, fv, dims[2];
  double *values=malloc(count*sizeof(*values));
  if (!values) { fputs("coordinate allocation failed\n",stderr); exit(1); }
  NC(nc_create("oversizedgrid.nc",NC_CLOBBER|NC_NETCDF4,&ncid));
  NC(nc_set_fill(ncid,NC_NOFILL,NULL));
  NC(nc_def_dim(ncid,"i",count,&xd));
  NC(nc_def_dim(ncid,"j",count,&yd));
  NC(nc_def_var(ncid,"lon",NC_DOUBLE,1,&xd,&xv));
  NC(nc_def_var(ncid,"lat",NC_DOUBLE,1,&yd,&yv));
  text_att(ncid,xv,"units","degrees_east");
  text_att(ncid,yv,"units","degrees_north");
  dims[0]=yd; dims[1]=xd;
  NC(nc_def_var(ncid,"field",NC_FLOAT,2,dims,&fv));
  NC(nc_def_var_chunking(ncid,fv,NC_CHUNKED,chunks));
  NC(nc_enddef(ncid));
  for (i=0;i<count;i++) values[i]=(double)i/64.0;
  NC(nc_put_var_double(ncid,xv,values));
  for (i=0;i<count;i++) values[i]=-64.0+(double)i/128.0;
  NC(nc_put_var_double(ncid,yv,values));
  NC(nc_close(ncid));
  free(values);
}

static void create_float_regular(void) {
  /* Decimal 0.1-degree steps cannot be represented exactly in NC_FLOAT.
   * The first two stored values give a biased increment which, extrapolated
   * to x=100, is no longer within coordinate-storage rounding precision. */
  int ncid, xd, yd, td, xv, yv, tv, fv, dims[3], t, j, i, n=0;
  float lon[100], lat[3]={-10,0,10}, field[900];
  double time[3]={0,24,48};
  NC(nc_create("floatregular.nc",NC_CLOBBER,&ncid));
  NC(nc_def_dim(ncid,"i",100,&xd));
  NC(nc_def_dim(ncid,"j",3,&yd));
  NC(nc_def_dim(ncid,"time",3,&td));
  NC(nc_def_var(ncid,"lon",NC_FLOAT,1,&xd,&xv));
  NC(nc_def_var(ncid,"lat",NC_FLOAT,1,&yd,&yv));
  NC(nc_def_var(ncid,"time",NC_DOUBLE,1,&td,&tv));
  text_att(ncid,xv,"units","degrees_east");
  text_att(ncid,yv,"units","degrees_north");
  text_att(ncid,tv,"units","hours since 2000-01-01 00:00:00");
  text_att(ncid,tv,"calendar","standard");
  dims[0]=td; dims[1]=yd; dims[2]=xd;
  NC(nc_def_var(ncid,"field",NC_FLOAT,3,dims,&fv));
  NC(nc_enddef(ncid));
  for (i=0;i<100;i++) lon[i]=(float)(130.0+i*0.1);
  for (t=1;t<=3;t++) for (j=1;j<=3;j++) for (i=1;i<=100;i++)
    field[n++]=(float)(100*t+10*j+i);
  NC(nc_put_var_float(ncid,xv,lon));
  NC(nc_put_var_float(ncid,yv,lat));
  NC(nc_put_var_double(ncid,tv,time));
  NC(nc_put_var_float(ncid,fv,field));
  NC(nc_close(ncid));
}

int main(void) {
  create("baseline.nc",BASELINE);
  create("regular.nc",REGULAR);
  create("descending.nc",DESCENDING);
  create("curvilinear.nc",CURVILINEAR);
  create("irregularxy.nc",IRREGULAR_XY);
  create("calendar360.nc",CALENDAR360);
  create("ambiguous.nc",AMBIGUOUS);
  create("groups.nc",GROUPS);
  create("packedaxis.nc",PACKED_AXIS);
  create("irregulartime.nc",IRREGULAR_TIME);
  create("aliascollision.nc",ALIAS_COLLISION);
  create_oversized();
  create_float_regular();
  return 0;
}
