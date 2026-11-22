/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/bitmap_out_routines_m274_xr.c (2026-11-21-5-p6-r60)
   sha256 fad96d13955ab0305366c04b2111b43fece24e54c408706c7e3da0d14291c1da (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_8d4a;
unsigned char BitMapOut_GetRenderMode_CheckBit3(unsigned char a)
{
  unsigned char *p = &ram_8d4a;
  *p |= a;
  return *p;
}
