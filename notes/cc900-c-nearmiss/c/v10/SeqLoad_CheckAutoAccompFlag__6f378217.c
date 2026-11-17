/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5a.c (2026-11-16-45-p6-r9)
   sha256 6f3782173ed786acb5b8f0b9571ad10fbd5c29c845f28fb8a50c793a4f9e1a23 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern unsigned char __near ram_f23e;
void SeqLoad_CheckAutoAccompFlag(void)
{
  if (Part_ReadByteDirect(0, 6) < 3) {
    ram_f23e |= 0x01;
    if (Part_ReadByteDirect(0, 5) == 0 && Part_ReadByteDirect(0, 6) < 3) ram_f23e &= ~0x01;
  } else {
  }
  ram_f23e &= ~0x02;
}
