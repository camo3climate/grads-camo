/* Isolated regression for the maintained theme implementation. No font, X11,
   NetCDF or Cairo link dependency: backend availability is explicitly mocked. */
#include <assert.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "grads.h"
#include "gx.h"

static char pout[1256];
static struct gxdsubs *dsubs;
static struct gxpsubs *psubs;
static int panel_rows=1, panel_cols=1;
static double panel_gap=0.12;
static struct gxdsubs display_backend;
static struct gxpsubs print_backend;
static int display_fonts=1, print_fonts=1, backend_available=1;
static int lookup_count, hershey_mode, default_font, background, color_calls;
static int colors[COLORMAX][4];
static double aspect=1.2;
static char family[80];

static int supports_display_font(void) { return display_fonts; }
static int supports_print_font(void) { return print_fonts; }
struct gxdsubs *getdsubs(void) {
  lookup_count++;
  return backend_available ? &display_backend : NULL;
}
struct gxpsubs *getpsubs(void) {
  lookup_count++;
  return backend_available ? &print_backend : NULL;
}
void gxdbsethersh(int mode) { hershey_mode=mode; }
void gxchdf(int font) { default_font=font; }
void gxdbck(int color) { background=color; }
void gxsetllasp(double value) { aspect=value; }
void gxdbsetfontfamily(char *name) { snprintf(family,sizeof family,"%s",name); }
void gxsignal(int signal) { assert(signal==3); }
int gxacol(int color,int red,int green,int blue,int alpha) {
  assert(color>=0 && color<COLORMAX);
  colors[color][0]=red; colors[color][1]=green;
  colors[color][2]=blue; colors[color][3]=alpha;
  color_calls++;
  return 0;
}
void gaprnt(int level,char *message) { (void)level; (void)message; }
void gxvpag(double a,double b,double c,double d,double e,double f) {
  (void)a; (void)b; (void)c; (void)d; (void)e; (void)f;
}
char *nxtwrd(char *s) {
  if (!s) return NULL;
  while (*s && !isspace((unsigned char)*s)) s++;
  while (*s && isspace((unsigned char)*s)) s++;
  return *s ? s : NULL;
}
int cmpwrdl(char *a,char *b) {
  while (*a && *b && !isspace((unsigned char)*a) && !isspace((unsigned char)*b)) {
    if (tolower((unsigned char)*a++)!=tolower((unsigned char)*b++)) return 0;
  }
  return (!*a || isspace((unsigned char)*a)) && (!*b || isspace((unsigned char)*b));
}
int cmpwrd(char *a,char *b) { return cmpwrdl(a,b); }
char *intprs(char *s,int *value) {
  char *end; long parsed=strtol(s,&end,10);
  if (end==s) return NULL;
  *value=(int)parsed; return end;
}
char *getdbl(char *s,double *value) {
  char *end; *value=strtod(s,&end);
  return end==s ? NULL : end;
}

#include "camo_colormap_impl.inc"

int main(void) {
  struct gacmn p, expected;
  int i, saved_colors[COLORMAX][4];
  memset(&p,0,sizeof p);
  display_backend.gxdckfont=supports_display_font;
  print_backend.gxpckfont=supports_print_font;
  default_font=99;
  /* Startup enters before gacmd() and must obtain both backend tables. */
  assert(!gacamo_apply_modern_defaults(&p));
  assert(lookup_count==2 && hershey_mode==1 && default_font==0);
  assert(p.grstyl==1 && p.grthck==1 && p.mapthk==2 && aspect==1.0);
  assert(p.rbflg==13 && color_calls==13);
  assert(colors[16][0]==0 && colors[16][1]==34 && colors[16][2]==78);
  for (i=0;i<13;i++) assert(p.rbcols[i]==16+i);
  /* Either unsupported backend must use the built-in Hershey fallback. */
  display_fonts=0;
  assert(!gaset_theme("modern",&p) && hershey_mode==0);
  display_fonts=1; print_fonts=0;
  assert(!gaset_theme("modern",&p) && hershey_mode==0);
  print_fonts=1;
  assert(!gaset_theme("modern",&p) && hershey_mode==1);
  backend_available=0; dsubs=NULL; psubs=NULL;
  assert(!gaset_theme("modern",&p) && hershey_mode==0);
  backend_available=1;

  /* Make accidental data-presentation changes observable. The whole struct
     comparison below allows only the explicitly listed paper style fields. */
  p.gout0=2; p.gout1=4; p.gout2a=17; p.gout2b=8; p.gxout2flg=1;
  p.rbflg=3; p.rbcols[0]=201; p.rbcols[1]=301; p.rbcols[2]=401;
  p.cflag=3; p.clevs[0]=-12.5; p.clevs[1]=0.0; p.clevs[2]=23.5;
  p.ccflg=4; p.ccols[0]=40; p.ccols[1]=41; p.ccols[2]=42; p.ccols[3]=43;
  p.cint=2.5; p.cmin=-10; p.cmax=30; p.cthick=9; p.cstyle=4;
  p.rainmn=-8; p.rainmx=7; p.mproj=3; p.zlog=1;
  p.strjst=5; p.strrot=25; p.grdsflg=0; p.timelabflg=0;
  aspect=1.234; color_calls=0;
  memcpy(saved_colors,colors,sizeof colors);
  memcpy(&expected,&p,sizeof p);
  expected.grflag=1; expected.grstyl=1; expected.grcolr=15; expected.grthck=1;
  expected.mapcol=1; expected.mapstl=1; expected.mapthk=2;
  expected.anncol=1; expected.annthk=3;
  expected.xlcol=expected.ylcol=1; expected.xlthck=expected.ylthck=3;
  expected.xlsiz=expected.ylsiz=0.12;
  expected.strcol=1; expected.strthk=3; expected.strhsz=expected.strvsz=0.12;
  expected.aaflg=1;
  assert(!gaset_theme("paper",&p));
  assert(!memcmp(&p,&expected,sizeof p));
  assert(!memcmp(colors,saved_colors,sizeof colors) && color_calls==0);
  assert(aspect==1.234 && background==1 && hershey_mode==1);
  assert(!strcmp(family,"sans-serif"));
  assert(!gaset_theme("paper",&p));
  assert(!memcmp(&p,&expected,sizeof p));
  print_fonts=0;
  assert(!gaset_theme("paper",&p) && hershey_mode==0);
  assert(!gaset_theme("classic",&p));
  assert(hershey_mode==0 && p.rbflg==0 && aspect==1.2);
  assert(p.gout0==2 && p.gout1==4 && p.gout2a==17);
  assert(gaset_theme("unknown",&p)==1 && gaset_theme(NULL,&p)==1);
  (void)gaset_panels; (void)gaset_rgbmap;
  puts("PASS: theme state, startup order, backend fallback, paper data preservation");
  return 0;
}
