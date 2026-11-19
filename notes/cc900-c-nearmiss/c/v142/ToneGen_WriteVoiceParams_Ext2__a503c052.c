/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AO_23b.c (2026-11-19-16-sub-r23o-tg-dsp)
   sha256 a503c05206d6e0248384ed8603b3bcaddad3ee50db42fe3dd61bf6dd1b0ddd9c (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void ToneGen_WriteVoiceParams_Ext2(register unsigned int reg, unsigned char *volatile p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (*(unsigned int *)(p + 60)); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (*(unsigned int *)(p + 62)); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (*(unsigned int *)(p + 45)); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
