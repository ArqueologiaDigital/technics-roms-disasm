/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4a.c (2026-11-16-40-p6-r8)
   sha256 51f33f7d2a542dcabaa0b35f2dc5bf07089f5d28b53e49e44f8cfe457d787e3c (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern unsigned char __near ram_f23e;
void SeqLoad_CheckAutoAccompFlag(void)
{
  if (Part_ReadByteDirect(0, 6) < 3) {
    ram_f23e |= 0x01;
    if (Part_ReadByteDirect(0, 5) == 0 && Part_ReadByteDirect(0, 6) < 3) ram_f23e &= ~0x01;
  }
  ram_f23e &= ~0x02;
}
