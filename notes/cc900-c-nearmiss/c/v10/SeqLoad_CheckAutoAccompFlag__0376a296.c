/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4b.c (2026-11-16-40-p6-r8)
   sha256 0376a2964c573ce15297eb22e016ddee3a48777d9bcdc1cb9292bc07c50265c4 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char Part_ReadByteDirect(int, int);
extern unsigned char __near ram_f23e;
void SeqLoad_CheckAutoAccompFlag(void)
{
  if (Part_ReadByteDirect(0, 6) < 3) {
    ram_f23e |= 0x01;
    if (Part_ReadByteDirect(0, 5) == 0 && Part_ReadByteDirect(0, 6) < 3) ram_f23e &= ~0x01;
  }
  ram_f23e &= ~0x02;
}
