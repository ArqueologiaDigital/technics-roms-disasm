/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/bitmap_out_routines_m274_xr.c (2026-11-21-5-p6-r60)
   sha256 c3771c5be75bc5c719fe4f74c54dd1259ac093831157fd376cb68398bade5beb (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_8cae;
unsigned char BitMapOut_GetRenderMode_CheckBit3(unsigned char a)
{
  unsigned char *p = &ram_8cae;
  *p |= a;
  return *p;
}
