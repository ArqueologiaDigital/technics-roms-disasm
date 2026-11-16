/* Functions of core/13_audio_process_dsp_and_effects.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct slot { unsigned int type; unsigned int a[1]; int param[17]; int idx; int q[1]; int r42[6]; int on; };
struct cfg {
    unsigned int f0, f2, f4, f6;
    union {
        struct slot s[5];
        struct { int pad; unsigned int a[5][28]; } A;
        struct { int pad[2]; int param[5][28]; } P;
        struct { int pad[20]; int q[5][28]; } Q;
    } u;
};
struct rec { unsigned int f0; unsigned int a[1]; unsigned int flags[17]; unsigned int q[1]; unsigned int g[5]; };
struct fxflags { unsigned int active[5]; unsigned int chip[2]; unsigned int algochg; struct rec r[5]; };
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern struct fxflags __near EFF_SlotActiveFlags;
extern char Str_EffMute_Prefix[], Str_EffMute_Suffix[];
extern char Str_DspMute_Prefix[], Str_DspMute_Suffix[];
extern char Str_DspUnmute_Prefix[], Str_DspUnmute_Suffix[];
extern char Str_DspReset_Prefix[], Str_DspReset_Suffix[];
extern char Str_DspAntiReset_Prefix[], Str_DspAntiReset_Suffix[];
extern char Str_EffDisconnect_Prefix[], Str_EffDisconnect_Suffix[];
extern char Str_EffLink_Prefix[], Str_EffLink_Suffix[];
extern char Str_EffDataChange_Prefix[], Str_EffDataChange_Suffix[];
extern char Str_EffChange_Prefix[], Str_EffChange_Suffix[];
extern unsigned char *EFF_Mute_Program_PtrTable[];
extern unsigned char *DSP_Mute_Program_PtrTable[];
extern unsigned char *DSP_Unmute_Program_PtrTable[];
extern unsigned char *EFF_Disconnect_Program_PtrTable[][3];
extern unsigned char *EFF_Link_Program_PtrTable[][3];
extern unsigned char *EFF_CoefProgram_PtrTable[];
extern unsigned char *EFF_AlgoProgram_PtrTable[];
extern unsigned char EFF_SlotToChip_Table[];
extern unsigned char DSP_Eff09_Slot1_Algo_Bytecode[], DSP_Eff09_Slot1_Coef_Bytecode[];
extern unsigned char DSP_Eff10_Slot1_Algo_Bytecode[], DSP_Eff10_Slot1_Coef_Bytecode[];
extern void Debug_Print_String(char *);
extern void Debug_Print_Byte(unsigned int);
extern void DSP_WriteEFFConfig(unsigned int, unsigned char *);
extern void DSP_WriteGlobalConfig(unsigned int, unsigned char *);
extern int DSP_MixerCoeff_Compute(unsigned int, unsigned int, unsigned int);
extern void DSP1_Deassert_Reset(void);
extern void DSP2_Deassert_Reset(void);
extern void DSP1_Assert_Reset(void);
extern void DSP2_Assert_Reset(void);

unsigned char *CalcSampleAddr(unsigned char *p)
{
    unsigned int v;
    unsigned int lo;
    lo = p[1] & 0xff;
    v = (((unsigned int)p[0] << 8) & 0xff00) + lo;
    if ((v >> 8) != 240)
        p += v;
    return p;
}

void DSP_AntiReset_WithDebug(unsigned int chip)
{
    Debug_Print_String(Str_DspAntiReset_Prefix);
    Debug_Print_Byte(chip);
    Debug_Print_String(Str_DspAntiReset_Suffix);
    DSP2_Deassert_Reset();
}

void DSP_Mute_WithDebug(unsigned int chip)
{
    Debug_Print_String(Str_DspMute_Prefix);
    Debug_Print_Byte(chip);
    Debug_Print_String(Str_DspMute_Suffix);
    DSP_WriteGlobalConfig(chip, DSP_Mute_Program_PtrTable[chip]);
}

void DSP_Reset_WithDebug(unsigned int chip)
{
    Debug_Print_String(Str_DspReset_Prefix);
    Debug_Print_Byte(chip);
    Debug_Print_String(Str_DspReset_Suffix);
    DSP1_Deassert_Reset();
    DSP2_Deassert_Reset();
    DSP1_Assert_Reset();
    DSP2_Assert_Reset();
    DSP1_Deassert_Reset();
}

int DSP_Set_MixParam_45B2(unsigned char v)
{
    return DSP_MixerCoeff_Compute(ram_45b2 = v, ram_45b4, ram_45b6);
}

void DSP_Unmute_WithDebug(unsigned int chip)
{
    Debug_Print_String(Str_DspUnmute_Prefix);
    Debug_Print_Byte(chip);
    Debug_Print_String(Str_DspUnmute_Suffix);
    DSP_WriteGlobalConfig(chip, DSP_Unmute_Program_PtrTable[chip]);
}

void EFF_Change_WithDebug(unsigned int slot, unsigned int eff)
{
    Debug_Print_String(Str_EffChange_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffChange_Suffix);
    Debug_Print_Byte(eff);
    switch (slot) {
    case 1:
        switch (eff) {
        case 9:
            DSP_WriteEFFConfig(slot, DSP_Eff09_Slot1_Algo_Bytecode);
            DSP_WriteEFFConfig(slot, DSP_Eff09_Slot1_Coef_Bytecode);
            break;
        case 10:
            DSP_WriteEFFConfig(slot, DSP_Eff10_Slot1_Algo_Bytecode);
            DSP_WriteEFFConfig(slot, DSP_Eff10_Slot1_Coef_Bytecode);
            break;
        default:
            DSP_WriteEFFConfig(slot, EFF_AlgoProgram_PtrTable[eff]);
            DSP_WriteEFFConfig(slot, EFF_CoefProgram_PtrTable[eff]);
            break;
        }
        break;
    default:
        DSP_WriteEFFConfig(slot, EFF_AlgoProgram_PtrTable[eff]);
        DSP_WriteEFFConfig(slot, EFF_CoefProgram_PtrTable[eff]);
        break;
    }
}

void EFF_DataChange_WithDebug(unsigned int slot, unsigned int prog)
{
    Debug_Print_String(Str_EffDataChange_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffDataChange_Suffix);
    Debug_Print_Byte(prog);
    DSP_WriteEFFConfig(slot, EFF_CoefProgram_PtrTable[prog]);
}

void EFF_Disconnect(unsigned int slot, unsigned int n)
{
    unsigned int chip;
    Debug_Print_String(Str_EffDisconnect_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffDisconnect_Suffix);
    chip = EFF_SlotToChip_Table[slot];
    DSP_WriteGlobalConfig(chip, EFF_Disconnect_Program_PtrTable[n][slot]);
}

void EFF_Link(unsigned int slot, unsigned int n)
{
    unsigned int chip;
    Debug_Print_String(Str_EffLink_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffLink_Suffix);
    chip = EFF_SlotToChip_Table[slot];
    DSP_WriteGlobalConfig(chip, EFF_Link_Program_PtrTable[n][slot]);
}

void EFF_LinkLoop(struct cfg *p)
{
    int i;
    for (i = 4; i > -1; i--)
        if ((EFF_SlotActiveFlags.r[i].g[3]) == 1 && ((p)->u.s[i]).on == 1)
            EFF_Link(i, p->f6);
}

void EFF_Mute_WithDebug(unsigned int slot)
{
    Debug_Print_String(Str_EffMute_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffMute_Suffix);
    DSP_WriteEFFConfig(slot, EFF_Mute_Program_PtrTable[slot]);
}

extern char Str_EffHeader_Prefix[], Str_EffHeader_Suffix[];
extern unsigned char EFF_Header_Program[];

void EFF_WriteHeader(unsigned int slot)
{
    unsigned int chip;

    Debug_Print_String(Str_EffHeader_Prefix);
    Debug_Print_Byte(slot + 1);
    Debug_Print_String(Str_EffHeader_Suffix);
    chip = EFF_SlotToChip_Table[slot];
    if (chip == 0)
        DSP_WriteGlobalConfig(chip, (unsigned char *)(unsigned long)EFF_Header_Program);
}
