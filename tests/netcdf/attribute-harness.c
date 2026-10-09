/* Compiles the actual read_ncatts/ncpattrs bodies extracted from tested source.
   Allocation injection and ASan exercise error cleanup independently of X11. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <netcdf.h>
#include "grads.h"
#define Success 0
#define Failure 1
static char pout[1256], messages[131072];
static int remaining=-1, allocations=0;
static int fail_string_read=0,fail_double_read=0;
static int checked_string_read(int file,int var,const char *name,char **value) {
  if(fail_string_read) return NC_EBADTYPE;
  return nc_get_att_string(file,var,name,value);
}
static int checked_double_read(int file,int var,const char *name,double *value) {
  if(fail_double_read) return NC_ERANGE;
  return nc_get_att_double(file,var,name,value);
}
#define nc_get_att_string checked_string_read
#define nc_get_att_double checked_double_read
void *galloc(size_t size,char *tag) {
  void *ptr;
  (void)tag;
  if(remaining==0) return NULL;
  if(remaining>0) remaining--;
  ptr=malloc(size);
  if(ptr) allocations++;
  return ptr;
}
void gree(void *ptr,char *tag) {
  (void)tag;
  if(ptr) {allocations--;free(ptr);}
}
void gaprnt(gaint level,char *text) {
  size_t len=strlen(messages), add=strlen(text);
  (void)level;
  if(add<sizeof(messages)-len) memcpy(messages+len,text,add+1);
}
void prntwrap(char *var,char *name,char *value) {
  (void)var;(void)name;
  gaprnt(2,value);gaprnt(2,"\n");
}
gaint cmpwrd(char *a,char *b) {return strcmp(a,b)==0;}
void handle_error(gaint rc) {gaprnt(0,(char*)nc_strerror(rc));}
#include "read_ncatts.inc"
#include "ncpattrs.inc"
#include "camo_nc_scalar.inc"

static void release(struct gafile *file) {
  struct gaattr *attr=file->attr,*next;
  while(attr) {next=attr->next;gree(attr->value,NULL);gree(attr,NULL);attr=next;}
  file->attr=NULL;
}
static void require(int condition,const char *text) {
  if(!condition) {fprintf(stderr,"FAIL: %s\n%s\n",text,messages);exit(1);}
}
int main(void) {
  struct gafile file;
  struct gaattr *attr;
  int ncid,natts,i,varid,success=0;
  double scalar=0;
  require(nc_open("attributes.nc",NC_NOWRITE,&ncid)==NC_NOERR,"fixture open");
  require(nc_inq_natts(ncid,&natts)==NC_NOERR,"attribute count");
  memset(&file,0,sizeof(file));
  require(read_ncatts(ncid,NC_GLOBAL,NULL,natts,&file)==Success,"metadata load");
  attr=file.attr;
  require(attr && strcmp(attr->name,"title")==0,"title node");
  require(attr->len==(int)strlen("NetCDF string title intact")+1,"string length");
  require(strcmp(attr->value,"NetCDF string title intact")==0,"string value");
  release(&file);
  messages[0]='\0';
  require(ncpattrs(ncid,"NC_GLOBAL","global",0,1,"")==natts,"q attr load");
  require(strstr(messages,"-2147483647,0,2147483647")!=NULL,"int array");
  require(strstr(messages,"0,9223372036854775808,18446744073709551615")!=NULL,"exact uint64");
  require(strstr(messages,"second string")!=NULL,"all string values");
  require(allocations==0,"normal allocations released");
  for(i=0;i<128;i++) {
    memset(&file,0,sizeof(file));messages[0]='\0';remaining=i;
    success=read_ncatts(ncid,NC_GLOBAL,NULL,natts,&file)==Success;
    release(&file);
    require(allocations==0,"metadata allocation failure cleanup");
    if(success) break;
  }
  require(success,"metadata allocation sweep complete");
  for(i=0;i<128;i++) {
    messages[0]='\0';remaining=i;
    success=ncpattrs(ncid,"NC_GLOBAL","global",0,1,"")==natts;
    require(allocations==0,"query allocation failure cleanup");
    if(success) break;
  }
  require(success,"query allocation sweep complete");
  remaining=-1;messages[0]='\0';
  require(ncpattrs(-1,"NC_GLOBAL","global",0,1,"")==0,"query invalid ncid");
  require(read_ncatts(-1,NC_GLOBAL,NULL,1,&file)==Failure,"read invalid ncid");
  require(allocations==0,"error allocations released");
  fail_string_read=1;messages[0]='\0';
  require(read_ncatts(ncid,NC_GLOBAL,NULL,natts,&file)==Failure,"string reader error propagated");
  release(&file);
  require(ncpattrs(ncid,"NC_GLOBAL","global",0,1,"")==0,"query string reader error");
  require(allocations==0,"string reader failure cleanup");
  fail_string_read=0;fail_double_read=1;messages[0]='\0';
  require(read_ncatts(ncid,NC_GLOBAL,NULL,natts,&file)==Failure,"numeric reader error propagated");
  release(&file);
  require(ncpattrs(ncid,"NC_GLOBAL","global",0,1,"")<natts,"query numeric reader error");
  require(allocations==0,"numeric reader failure cleanup");
  fail_double_read=0;
  require(camo_nc_scalar(ncid,NC_GLOBAL,"ints",&scalar)==NC_EINVAL,"scalar rejects attribute array");
  require(camo_nc_scalar(ncid,NC_GLOBAL,"title",&scalar)==NC_EINVAL,"scalar rejects text");
  require(camo_nc_scalar(ncid,NC_GLOBAL,"absent",&scalar)==NC_ENOTATT,"scalar absent attribute status");
  require(nc_inq_varid(ncid,"packed",&varid)==NC_NOERR,"packed variable lookup");
  require(camo_nc_scalar(ncid,varid,"_FillValue",&scalar)==NC_NOERR && scalar==4294967295.0,"numeric scalar conversion");
  nc_close(ncid);
  puts("PASS: actual NetCDF attribute functions and allocation-failure sweeps");
  return 0;
}
