/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AO_23a.c (2026-11-19-16-sub-r23o-tg-dsp)
   sha256 9d77906e695201f617c33c3d3aacad3987e493e5ad5b7fe88aefe1751fad332e (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: TG_WriteVoice_TvfRegs_Dup=ToneGen_WriteVoice_TvfRegs_Dup */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void TG_WriteVoice_TvfRegs_Dup(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 256); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 320); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
