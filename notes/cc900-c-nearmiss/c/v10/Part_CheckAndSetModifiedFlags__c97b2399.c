/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2a.c (2026-11-16-35-p6-r3)
   sha256 c97b2399af5c6580229970cea088ec622459e83731fa38d6c7f60b660d01c853 (tar-sha256); compiled at -O3 -Xr */
void Part_CheckAndSetModifiedFlags(unsigned char *r)
{
  unsigned char *q;
  unsigned char c;
  q = r + 2; c = *q; if (c & 0x80) { c &= ~0x80; *q = c; *r |= 0x04; }
  q = r + 4; c = *q; if (c & 0x80) { c &= ~0x80; *q = c; *r |= 0x01; }
  q = r + 5; c = *q; if (c & 0x80) { c &= ~0x80; *q = c; *r |= 0x02; }
}
