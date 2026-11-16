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
extern unsigned int __near ram_2aa4[];
extern unsigned char ToneGen_GlobalConfig_Defaults[];
extern unsigned int ToneGen_VoiceParamShadow_Defaults[];
struct shadow { unsigned int w[34]; };
extern void ToneGen_WriteGlobalConfig(unsigned char *cfg);
extern void ToneGen_WriteVoiceParams(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v);
extern void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p);

/* cc900-module: ToneGen_WriteExtParams_15 ToneGen_WriteExtParams_56 ToneGen_WriteExtParams_56b ToneGen_WriteGlobalConfig ToneGen_WriteSingleReg ToneGen_WriteVoiceParams */
void DSP_Config_Init(void)
{
    unsigned int i;
    unsigned int *q;
    unsigned int *p;
    unsigned int r;
    ToneGen_WriteGlobalConfig(ToneGen_GlobalConfig_Defaults);
    q = ram_2aa4;
    p = q;
    *(struct shadow *)q = *(struct shadow *)ToneGen_VoiceParamShadow_Defaults;
    for (i = 0; i < 0x40; i++) {
        ram_18 &= ~0x80;
        ram_100000 = i + 0x840;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff00;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = i + 0x800;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff80;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ToneGen_WriteVoiceParams(i, p);
        ToneGen_WriteSingleReg(i, *p);
        ram_18 &= ~0x80;
        ram_100000 = i + 0x840;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff00;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = i + 0x800;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0xff80;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        ram_100000 = i + 0xc0;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ram_18 &= ~0x80;
        r = i;
        ram_100000 = r;
        __ASM(" nop");
        ram_18 |= 0x80;
        ram_100002 = 0x7e00;
        __ASM(" jr $+2");
        __ASM(" nop");
        __ASM(" nop");
        __ASM(" nop");
        ToneGen_WriteExtParams_15(i, p);
        ToneGen_WriteExtParams_56(i, p);
        ToneGen_WriteExtParams_56b(i, p);
    }
}
