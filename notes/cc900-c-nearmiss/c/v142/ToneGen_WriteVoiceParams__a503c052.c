/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AO_23b.c (2026-11-19-16-sub-r23o-tg-dsp)
   sha256 a503c05206d6e0248384ed8603b3bcaddad3ee50db42fe3dd61bf6dd1b0ddd9c (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
void ToneGen_WriteVoiceParams(register unsigned int reg, unsigned int *volatile p)
{
    unsigned int i;

    i = 0;
    ram_18 &= ~0x80; ram_100000 = (reg + 0x40); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[1]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[2] | 0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xc0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x100); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x140); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x180); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x400); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x440); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x480); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x4c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x500); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[11]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[12]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (0x8100); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[13]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x880); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[14]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x8c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[15]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x900); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[16]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x940); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[17]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x980); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[18]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x9c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[19]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[20]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa40); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[21]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x80); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[2] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
