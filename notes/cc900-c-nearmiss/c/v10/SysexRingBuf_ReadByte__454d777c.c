/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2b.c (2026-11-16-35-p6-r3)
   sha256 454d777c57a47bdce681897b54082758f1f7c5ab8c73314b6fddcdcbecf34fe5 (tar-sha256); compiled at -Xr */
extern unsigned int __near ram_d8ae;
extern unsigned int __near ram_d8b0;
extern unsigned int __near ram_d8b2;
extern unsigned char __near ram_d8b4[];
int SysexRingBuf_ReadByte(void)
{
  int r;
  if (ram_d8ae == ram_d8b0) return -1;
  r = ram_d8b4[ram_d8b0];
  ram_d8b2++;
  if (ram_d8b0 == 2047) ram_d8b0 = 0; else ram_d8b0++;
  return r;
}
