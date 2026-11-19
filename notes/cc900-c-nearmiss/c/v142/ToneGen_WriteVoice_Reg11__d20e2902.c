/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3b.c (2026-11-19-10-sub-r23w-asm)
   sha256 d20e29023118a40f2a271ad82f83ef4675b92a35036e76a09e526311c9db51e7 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void ToneGen_WriteVoice_Reg11(unsigned int ch, unsigned int *p)
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
