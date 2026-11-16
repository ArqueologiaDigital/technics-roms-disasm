/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2a.c (2026-11-16-35-p6-r3)
   sha256 c97b2399af5c6580229970cea088ec622459e83731fa38d6c7f60b660d01c853 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_TRACK_MASK;
unsigned char Chan_IsActive(unsigned char a)
{
  if (a >= 1 && a <= 16 && !(SEQ_TRACK_MASK & (1 << (a - 1)))) return 0;
  return 1;
}
