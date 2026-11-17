/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_5b.c (2026-11-16-45-p6-r9)
   sha256 f537949078528ed18dfc0b0b9e694946b4d167de54df22a7a21a6f0ca0494772 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern unsigned char __near ram_f23e;
void SeqLoad_CheckAutoAccompFlag(void)
{
  if (Part_ReadByteDirect(0, 6) >= 3) goto skip;
  ram_f23e |= 0x01;
  if (Part_ReadByteDirect(0, 5) != 0) goto skip;
  if (Part_ReadByteDirect(0, 6) >= 3) goto skip;
  ram_f23e &= ~0x01;
skip:
  goto clear;
clear:
  ram_f23e &= ~0x02;
}
