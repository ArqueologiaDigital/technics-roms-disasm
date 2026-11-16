/* lane_sub helper B, round 5, form c: the tone-generator writers once more, the record kept in XIZ read as
   *((unsigned int *)__XIZ + k) (KN5000 sub-CPU payload v1.42). */

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;

void ToneGen_WriteVoice_Long(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x400;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 7);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Short(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 0x80;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 2) & 0x7fff;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_EnvLevel(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 384;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 6);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg11(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1088;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 8);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg13(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1216;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 10);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg18(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1536;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 32);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg16(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1408;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 30);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg07(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 448;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 28);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg15(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 1344;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 29);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg21(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    ram_18 &= ~0x80;
    ram_100000 = ch + 2112;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = *((unsigned int *)__XIZ + 23);
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: ToneGen_WriteVoice_Reg07_Or_18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
void ToneGen_WriteVoice_Reg07_Or_18(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    if (ch < 64) {
        ram_18 &= ~0x80;
        ram_100000 = ch + 448;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *((unsigned int *)__XIZ + 28);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1536;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *((unsigned int *)__XIZ + 33);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}

/* cc900-name: ToneGen_WriteVoice_Reg15_Or_16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
void ToneGen_WriteVoice_Reg15_Or_16(unsigned int ch, unsigned int *p)
{
    __XIZ = (unsigned long)p;
    if (ch < 64) {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1344;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *((unsigned int *)__XIZ + 29);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    } else {
        ram_18 &= ~0x80;
        ram_100000 = ch + 1408;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = *((unsigned int *)__XIZ + 31);
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
    }
}

void ToneGen_WriteVoice_TvfPair(unsigned int ch, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 256;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][4];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 320;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][5];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 2112;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][13];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 2176;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][14];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteNote2ch(unsigned int ch, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][22];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteVoice_6Words(unsigned int ch, unsigned int *p)
{
    unsigned int *q[1];
    q[0] = p;
    __IZ = ch;
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][23];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x940;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][25];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0xa00;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][27];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][22];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x900;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][24];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = __IZ + 0x9c0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = q[0][26];
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}
