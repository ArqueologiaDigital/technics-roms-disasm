/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern unsigned int ram_41343;
void ToneGen_WriteGlobalConfig(unsigned int *p);
void ToneGen_WriteReg0440_0480(unsigned int reg, unsigned int *p);
void ToneGen_Write_Reg0180(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg0440(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg0480(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg04C0(unsigned int reg, register unsigned int *p);
void TG_WriteExtParams_15_Banked(unsigned int reg, unsigned int *p);
void ToneGen_WriteLevelBurst(unsigned int reg, unsigned int *p);
void ToneGen_WriteLevelPair(unsigned int reg, unsigned int *p);
void ToneGen_WriteReg0840_Shadow2E(unsigned int reg, register unsigned int *p);
void TG_WriteVoice_TvfRegs_Dup(unsigned int reg, unsigned int *p);
void TG_WriteExtParams_TypeDispatch(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_15_Alt(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_15_Alt(unsigned int reg, unsigned int *p);
void TG_WriteExtParams_15_Banked(unsigned int reg, unsigned int *p);
void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p);
void TG_WriteExtParams_TypeDispatch(unsigned int reg, unsigned int *p);
void ToneGen_WriteGlobalConfig(unsigned int *p);
void ToneGen_WriteLevelBurst(unsigned int reg, unsigned int *p);
void ToneGen_WriteLevelPair(unsigned int reg, unsigned int *p);
void ToneGen_WriteReg0440_0480(unsigned int reg, unsigned int *p);
void ToneGen_WriteReg0840_Shadow2E(unsigned int reg, register unsigned int *p);
void TG_WriteVoice_TvfRegs_Dup(unsigned int reg, unsigned int *p);
void ToneGen_Write_Reg0180(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg0440(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg0480(unsigned int reg, register unsigned int *p);
void ToneGen_Write_Reg04C0(unsigned int reg, register unsigned int *p);

/* cc900-name: TG_WriteExtParams_15_Banked=ToneGen_WriteExtParams_15_Banked */
/* cc900-name: TG_WriteExtParams_TypeDispatch=ToneGen_WriteExtParams_TypeDispatch */
/* cc900-name: TG_WriteVoice_TvfRegs_Dup=ToneGen_WriteVoice_TvfRegs_Dup */
void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p)
{
    if (p[29] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x1c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[28]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteExtParams_15_Alt(unsigned int reg, unsigned int *p)
{
    if (p[29] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

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

void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p)
{
    if (p[31] & 0x8000) {
        ram_18 &= ~0x80; ram_100000 = (reg + 0x5c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
    ram_18 &= ~0x80; ram_100000 = (reg + 0x640); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[33]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x5c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteExtParams_TypeDispatch(unsigned int reg, unsigned int *p)
{
    if (reg < 0x40) {
        if (p[29] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 0x540); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[29] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    } else {
        if (p[31] & 0x8000) {
            ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
        }
        ram_18 &= ~0x80; ram_100000 = (reg + 0x580); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[31] & ~0x8000); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    }
}

void ToneGen_WriteGlobalConfig(unsigned int *p)
{
    if (ram_41343 & 8) p[0] &= ~8;
    else p[0] |= 8;
    ram_18 &= ~0x80; ram_100000 = (0x200); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[0]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x201); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[1]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x202); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[2]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x203); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[3]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x204); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0x205); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc01); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[7]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc02); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc03); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc04); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xc05); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[11]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (0xe00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[12]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteLevelBurst(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x940); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[25]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0xa00); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[27]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[22]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x900); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[24]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x9c0); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[26]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteLevelPair(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 0x840); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 0x800); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[22]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteReg0440_0480(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1088); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 1152); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_WriteReg0840_Shadow2E(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 2112); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[23]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void TG_WriteVoice_TvfRegs_Dup(unsigned int reg, unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 256); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[4]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
    ram_18 &= ~0x80; ram_100000 = (reg + 320); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[5]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0180(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 384); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[6]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0440(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1088); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[8]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg0480(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1152); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[9]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}

void ToneGen_Write_Reg04C0(unsigned int reg, register unsigned int *p)
{
    ram_18 &= ~0x80; ram_100000 = (reg + 1216); __asm(" nop"); ram_18 |= 0x80; ram_100002 = (p[10]); __asm(" jr $+2"); __asm(" nop"); __asm(" nop"); __asm(" nop");
}
