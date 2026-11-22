/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bitmap_out_routines_m274_xr.c (2026-11-21-5-p6-r60)
   sha256 7193e6d65ec30df821c6de65325af2765042fa6234c6dacc420a501c9f32e580 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_8c92;
unsigned char BitMapOut_GetRenderMode_CheckBit3(unsigned char a)
{
  unsigned char *p = &ram_8c92;
  *p |= a;
  return *p;
}
