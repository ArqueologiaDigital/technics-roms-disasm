/* helper Q, round 20r1, module 240, form b: format_FD with an int parameter (its callers load WA) narrowed to a char,
   as an if chain; the handle test on a pointer. */
/* cc900-module: FDC_Format2DD_Start FDC_Format2HD_Start */

extern int FDC_Format2HD_Start(void);
extern int FDC_Format2DD_Start(void);

int format_FD(int t)
{
  unsigned int k;
  k = (unsigned char)t;
  if (k == 3) return FDC_Format2HD_Start();
  if (k == 2) return FDC_Format2DD_Start();
  return 0;
}

int FileIO_ValidateHandle(void *h)
{
  if (!h) return -1;
  return 0;
}
