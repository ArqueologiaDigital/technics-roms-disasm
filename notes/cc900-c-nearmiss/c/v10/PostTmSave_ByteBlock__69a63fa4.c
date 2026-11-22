/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m300a.c (2026-11-21-3-p6-r59)
   sha256 69a63fa403ce65595c492222cf1e93a0af96b686139ae3c687a7135df2da4736 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char SoundRam_IdentifyImage(unsigned char *);
int PostTmSave_ByteBlock(unsigned char *p)
{
  unsigned char k = SoundRam_IdentifyImage(p);
  if (k > 6 || k < 1) return -0x66;
  return 0;
}
