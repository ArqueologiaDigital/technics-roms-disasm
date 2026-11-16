/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n)
{
    unsigned int i;
    for (i = 0; i < n; i++) *d++ = *s++;
}

extern unsigned char ram_41350[];
extern unsigned char ram_41356[];
extern unsigned char ram_4135a[];
extern void Voice_DSP_OutputConfig2(unsigned int part, unsigned int slot);
#define PART_FLAGS(p)   (*(unsigned int *)(ram_41350 + (p) * 0x11f))
#define PART_W72(p)     (*(unsigned int *)(ram_4135a + (p) * 0x11f))
#define PART_PATCH(p)   (*(unsigned char **)(ram_41356 + (p) * 0x11f))

int DSP_EffectStateQuery(unsigned char part, unsigned char *out)
{
    if (PART_FLAGS(part) & 1) *out = 1;
    else *out = 0;
    return 1;
}

void Voice_DSPOut_Second_B(unsigned char part)
{
    switch (PART_PATCH(part)[93] & 0xf) {
    case 4:
    case 5:
        Voice_DSP_OutputConfig2(part, 1);
        break;
    case 7:
        if (PART_W72(part) & 0x4000) Voice_DSP_OutputConfig2(part, 1);
        break;
    }
}

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
#define TG_WAIT2 __ASM("	db	0x68,0x00"); __ASM("	nop"); __ASM("	nop"); __ASM("	nop")
#define TG_WRITE(r, v) ram_18 &= ~0x80; ram_100000 = (r); __ASM("	nop"); ram_18 |= 0x80; ram_100002 = (v); TG_WAIT2

/* cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch */
void ToneGen_Mute_Reg05C0(unsigned int reg)
{
    TG_WRITE(reg + 0x5c0, 0x8100);
}

void ToneGen_WriteExtParam_540_Mute(unsigned int reg)
{
    TG_WRITE(reg + 0x540, 0x8100);
}

void ToneGen_WriteExtParam_600_Mute(unsigned int reg)
{
    TG_WRITE(reg + 0x580, 0x8100);
}

void TG_WriteExtParam_Mute_TypeDisp(unsigned int reg)
{
    if (reg < 0x40) {
        TG_WRITE(reg + 0x540, 0x8100);
    } else {
        TG_WRITE(reg + 0x580, 0x8100);
    }
}

int CheckStatusBits_40(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_41356 + (unsigned long)part * 0x11f))[16] & 0xc0) == 0x40;
}

int CheckStatusBits_80(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_41356 + (unsigned long)part * 0x11f))[16] & 0xc0) == 0x80;
}

void ToneGen_WriteExprReg(unsigned int reg, unsigned int v)
{
    __IZ = v;
    ram_18 &= ~0x80;
    ram_100000 = reg + 0x180;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = __IZ;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v)
{
    __IZ = v;
    ram_18 &= ~0x80;
    ram_100000 = reg;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = __IZ;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

int Voice_Part_Mode_Is_C0(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_41356 + (unsigned long)part * 0x11f))[16] & 0xc0) == 0xc0;
}
