#include <assert.h>
#include <math.h>
#include <stdio.h>
typedef double gadouble;
typedef int gaint;
struct gacmn { int mpflg,mproj,lincol,linthk,linstl; double mpvals[4],dmin[2],dmax[2],xsiz1,xsiz2,ysiz1,ysiz2,xsiz,ysiz; };
static int projection,draws,midpage,moves; static double px,py,length;
static int gadraw_geo_ready(struct gacmn *p) { (void)p; return 1; }
static void gxconv(double lon,double lat,double *x,double *y,int level) {
  (void)level; *x=lon; *y=lat;
  if (projection==1) *y=lat+lon*lon*0.01;
  if (projection==2 && fabs(lon)<0.01) *x=NAN;
}
static void gxplot(double x,double y,int pen) {
  assert(isfinite(x)&&isfinite(y));
  if (pen==3) moves++;
  if (pen==2) { draws++; length+=hypot(x-px,y-py); if(fabs(x)<100)midpage++;
    assert(hypot(x-px,y-py)<=0.250001); }
  px=x;py=y;
}
static void gxclip(double a,double b,double c,double d) {(void)a;(void)b;(void)c;(void)d;}
static void gxcolr(int c) {(void)c;}
static void gxwide(int c) {(void)c;}
static void gxstyl(int c) {(void)c;}
static void gaprnt(int c,char *s) {(void)c;(void)s;}
#include "camo_geo_annotations.inc"
int main(void) {
  struct gacmn p={0}; double a[2],z[2],b[4]={-10,10,-5,5},x,y;
  int integer;
  assert(camo_geo_number("-1.25e2 ",&x) && x==-125);
  assert(!camo_geo_number("1junk",&x));
  assert(!camo_geo_number("nan",&x));
  assert(!camo_geo_number("1e999",&x));
  assert(camo_geo_integer("+12 ",&integer) && integer==12);
  assert(!camo_geo_integer("3.5",&integer));
  assert(!camo_geo_integer("2oops",&integer));
  assert(!camo_geo_integer("4294967296",&integer));
  assert(!camo_geo_integer("999999999999999999999999",&integer));
  p.dmin[0]=-180;p.dmax[0]=180;p.dmin[1]=-90;p.dmax[1]=90;
  p.xsiz1=-180;p.xsiz2=180;p.ysiz1=-90;p.ysiz2=90;
  a[0]=-20;a[1]=0;z[0]=20;z[1]=0;
  assert(camo_geo_clip(a,z,b)); assert(a[0]==-10 && z[0]==10);
  a[0]=-20;a[1]=6;z[0]=20;z[1]=6; assert(!camo_geo_clip(a,z,b));
  assert(camo_geo_line(&p,170,0,-170,0)==0);
  assert(draws>0 && !midpage && fabs(length-20)<1e-9);
  assert(moves==2); /* Preserve dash phase within each seam-delimited run. */
  draws=0;length=0; assert(camo_geo_line(&p,1e300,0,1e300,1)==0);
  assert(fabs(length-1)<1e-9);
  assert(camo_geo_line(&p,NAN,0,1,1)==1);
  assert(camo_geo_line(&p,0,91,1,1)==1);
  projection=1;draws=0;assert(!camo_geo_line(&p,-5,0,5,0));assert(draws>40);
  projection=2;draws=0;assert(!camo_geo_line(&p,-1,0,1,0));assert(draws>0);
  projection=0;p.dmin[0]=0;p.dmax[0]=90;
  x=270;y=0;assert(camo_geo_anchor(&p,&x,&y)==0);
  x=370;y=2;assert(camo_geo_anchor(&p,&x,&y)==1 && x==10);
  x=10;y=NAN;assert(camo_geo_anchor(&p,&x,&y)==-1);
  /* Respect a projection's explicit geographic bounds rather than data bounds. */
  p.mpflg=4;p.mproj=5;
  p.mpvals[0]=100;p.mpvals[1]=120;p.mpvals[2]=-10;p.mpvals[3]=10;
  x=110;y=2;assert(camo_geo_anchor(&p,&x,&y)==1);
  x=10;y=2;assert(camo_geo_anchor(&p,&x,&y)==0);
  /* Orthographic mpvals are page offsets, not longitude/latitude bounds. */
  p.mproj=7;x=10;y=2;assert(camo_geo_anchor(&p,&x,&y)==1);
  puts("geometry regression passed");
}
