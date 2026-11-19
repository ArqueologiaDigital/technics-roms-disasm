/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AO_23c.c (2026-11-19-16-sub-r23o-tg-dsp)
   sha256 8433e2c87cc4a1d72c71069c36f43442fe84fae0c4c65ef7ab657c9eaa30b56c (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned char ram_430bb[];
struct tgv { unsigned int w[36]; };
void ToneGen_ReadPitch_AndScale(unsigned int reg, struct tgv *p)
{
    unsigned int *q;

    ram_18 &= ~0x80; ram_100000 = (reg + 0xc0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80;
    q = (unsigned int *)0x100002;
    *q = *(unsigned int *)(ram_430bb + (long)reg * 71) & 0x7fff;
    __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
