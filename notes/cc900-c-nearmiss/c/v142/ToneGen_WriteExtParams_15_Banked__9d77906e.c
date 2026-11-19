/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AO_23a.c (2026-11-19-16-sub-r23o-tg-dsp)
   sha256 9d77906e695201f617c33c3d3aacad3987e493e5ad5b7fe88aefe1751fad332e (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: TG_WriteExtParams_15_Banked=ToneGen_WriteExtParams_15_Banked */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void TG_WriteExtParams_15_Banked(unsigned int reg, unsigned int *p)
{
    if (reg < 64) {
        if (p[29] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 448); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        if (p[31] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 1536); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}
