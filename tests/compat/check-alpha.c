/* Test-only PNG pixel sampling. libpng is already a GrADS build dependency. */
#include <png.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int sample(const png_image *im, const unsigned char *pixels,
                  double page_x, double page_y, int r, int g, int b) {
  size_t x = (size_t)(page_x * im->width / 11.0);
  size_t y = (size_t)((8.5 - page_y) * im->height / 8.5);
  const unsigned char *p = pixels + 4 * (y * im->width + x);
  if (abs((int)p[0]-r)>3 || abs((int)p[1]-g)>3 ||
      abs((int)p[2]-b)>3 || p[3]!=255) {
    fprintf(stderr, "FAIL: pixel at %.1f,%.1f is %u,%u,%u,%u; expected %d,%d,%d,255\n",
            page_x,page_y,p[0],p[1],p[2],p[3],r,g,b);
    return 1;
  }
  return 0;
}

int main(int argc, char **argv) {
  png_image im;
  unsigned char *pixels;
  int failed;
  if (argc!=2) return 2;
  memset(&im,0,sizeof(im));
  im.version=PNG_IMAGE_VERSION;
  if (!png_image_begin_read_from_file(&im,argv[1])) {
    fprintf(stderr,"FAIL: read PNG: %s\n",im.message);
    return 1;
  }
  im.format=PNG_FORMAT_RGBA;
  if (im.width!=1100 || im.height!=850) {
    fprintf(stderr,"FAIL: unexpected PNG dimensions %u,%u\n",im.width,im.height);
    png_image_free(&im);
    return 1;
  }
  pixels=malloc(PNG_IMAGE_SIZE(im));
  if (pixels==NULL) { png_image_free(&im); return 1; }
  if (!png_image_finish_read(&im,NULL,pixels,0,NULL)) {
    fprintf(stderr,"FAIL: decode PNG: %s\n",im.message);
    free(pixels);
    png_image_free(&im);
    return 1;
  }
  failed=sample(&im,pixels,0.5,0.5,255,255,255);
  failed|=sample(&im,pixels,2.0,3.0,255,127,127);
  failed|=sample(&im,pixels,5.0,4.0,127,127,255);
  failed|=sample(&im,pixels,3.5,4.0,127,63,191);
  free(pixels);
  png_image_free(&im);
  if (failed) return 1;
  puts("PASS: PNG alpha compositing and overlap order");
  return 0;
}
