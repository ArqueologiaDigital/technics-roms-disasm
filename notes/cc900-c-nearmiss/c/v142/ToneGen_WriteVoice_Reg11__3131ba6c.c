/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3a.c (2026-11-19-10-sub-r23w-asm)
   sha256 3131ba6ce52619a70fd697c12df6ce15b0df07ab4801545fe99e86ef6e816881 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void ToneGen_WriteVoice_Reg11(unsigned int ch, register unsigned int *p)
{
    ram_18 &= ~0x80;
    ram_100000 = ch + 1088;
    __asm("	nop");
    ram_18 |= 0x80;
    ram_100002 = p[8];
    goto gap;
gap:
    __asm("	nop");
    __asm("	nop");
    __asm("	nop");
}
