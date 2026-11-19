/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AO_23c.c (2026-11-19-16-sub-r23o-tg-dsp)
   sha256 8433e2c87cc4a1d72c71069c36f43442fe84fae0c4c65ef7ab657c9eaa30b56c (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
struct tgv { unsigned int w[36]; };
void ToneGen_WriteVoiceParams(unsigned int reg, struct tgv *p)
{
    0;
    ram_18 &= ~0x80; ram_100000 = (reg + 0x40); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[1]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[2] | 0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xc0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x100); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x140); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x180); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x400); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x440); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x480); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x4c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x500); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[11]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[12]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[13]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x880); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[14]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x8c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[15]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x900); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[16]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x940); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[17]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x980); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[18]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x9c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[19]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[20]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa40); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[21]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p->w[2] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
