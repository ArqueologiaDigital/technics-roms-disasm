/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2b.c (2026-11-16-35-p6-r3)
   sha256 454d777c57a47bdce681897b54082758f1f7c5ab8c73314b6fddcdcbecf34fe5 (tar-sha256); compiled at -Xr */
extern unsigned int __near ram_d0a8;
extern unsigned int __near ram_d0aa;
extern unsigned int __near ram_d0ac;
extern unsigned char __near ram_d0ae[];
int RingBuffer_ReadByte(void)
{
  int r;
  if (ram_d0a8 == ram_d0aa) return -1;
  r = ram_d0ae[ram_d0aa];
  ram_d0ac++;
  if (ram_d0aa == 2047) ram_d0aa = 0; else ram_d0aa++;
  return r;
}
