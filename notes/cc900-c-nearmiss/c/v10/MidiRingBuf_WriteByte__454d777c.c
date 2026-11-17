/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2b.c (2026-11-16-35-p6-r3)
   sha256 454d777c57a47bdce681897b54082758f1f7c5ab8c73314b6fddcdcbecf34fe5 (tar-sha256); compiled at -Xr */
extern unsigned int __near ram_e0b4;
extern unsigned int __near ram_e0b8;
extern unsigned char __near ram_e0ba[];
int MidiRingBuf_WriteByte(unsigned char a)
{
  if (ram_e0b8 == 0) return -1;
  ram_e0ba[ram_e0b4] = a;
  ram_e0b8--;
  if (ram_e0b4 == 127) ram_e0b4 = 0; else ram_e0b4++;
  return 0;
}
