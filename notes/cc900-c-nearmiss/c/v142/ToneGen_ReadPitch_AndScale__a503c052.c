/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AO_23b.c (2026-11-19-16-sub-r23o-tg-dsp)
   sha256 a503c05206d6e0248384ed8603b3bcaddad3ee50db42fe3dd61bf6dd1b0ddd9c (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_430bb[];
void ToneGen_ReadPitch_AndScale(unsigned int reg, unsigned int *p)
{
    unsigned int *q;

    ram_18 &= ~0x80; ram_100000 = (reg + 0xc0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80;
    q = (unsigned int *)0x100002;
    *q = *(unsigned int *)(ram_430bb + (unsigned long)reg * 71) & ~0x8000;
    __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
