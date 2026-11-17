/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2a.c (2026-11-16-35-p6-r3)
   sha256 c97b2399af5c6580229970cea088ec622459e83731fa38d6c7f60b660d01c853 (tar-sha256); compiled at -Xr */
extern unsigned int __near ACTIVE_TITLE;
unsigned char CommPort_StatusCheck_Compare(unsigned char a, unsigned char c)
{
  unsigned char r;
  if (a == c) {
    switch ((unsigned char)ACTIVE_TITLE) {
    case 0x0a: case 0x0b: case 0x0c: case 0x0e: case 0xd6: r = 0; break;
    default: r = 0xff;
    }
  } else r = 0xff;
  return r;
}
