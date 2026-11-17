/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2b.c (2026-11-16-35-p6-r3)
   sha256 454d777c57a47bdce681897b54082758f1f7c5ab8c73314b6fddcdcbecf34fe5 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ACTIVE_TITLE;
unsigned char CommPort_StatusCheck_Compare(unsigned char a, unsigned char c)
{
  unsigned char t;
  if (a == c) {
    t = ACTIVE_TITLE;
    if (t == 0xd6 || t == 0x0e || t == 0x0c || t == 0x0b || t == 0x0a) return 0;
  }
  return 0xff;
}
