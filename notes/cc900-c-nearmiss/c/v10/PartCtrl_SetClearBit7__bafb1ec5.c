/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m234b.c (2026-11-21-3-p6-r59)
   sha256 bafb1ec50e4615f1aca50e01fb26d5f26fea7966125f481d24e4a421768ec32c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ram_b0000[];
void PartCtrl_SetClearBit7(unsigned int n, unsigned char c)
{
  unsigned char *p = &ram_b0000[(unsigned long)(n - 1) << 8];
  if (c == 0) {
    *p &= ~0x80;
    return;
  }
  *p |= 0x80;
}
