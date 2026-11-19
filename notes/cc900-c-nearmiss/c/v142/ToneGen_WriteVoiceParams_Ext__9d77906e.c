/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AO_23a.c (2026-11-19-16-sub-r23o-tg-dsp)
   sha256 9d77906e695201f617c33c3d3aacad3987e493e5ad5b7fe88aefe1751fad332e (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void ToneGen_WriteVoiceParams_Ext(unsigned int reg, unsigned int *p2, unsigned int *p3)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p3[30]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p3[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p2[2] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (*(unsigned int *)((unsigned char *)p3 + 45)); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
