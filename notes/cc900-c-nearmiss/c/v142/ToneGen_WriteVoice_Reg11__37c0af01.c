/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_3b.c (2026-11-16-58-sub-r3)
   sha256 37c0af016e565fee335c95be3cff7bb8f759446ff2d97b97f7bdcedab76f9756 (name+funcs); compiled at -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void ToneGen_WriteVoice_Reg11(unsigned int ch, register unsigned int *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 1088;
    __ASM("	nop");
    ram_18 |= 0x80;
    ram_100002 = p[8];
    goto gap;
gap:
    __ASM("	nop");
    __ASM("	nop");
    __ASM("	nop");
}
