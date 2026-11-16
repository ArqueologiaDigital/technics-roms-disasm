/* lane_sub probe round 10, helper C, form a: calr callers of core/08_voice_noteon_and_tonegen.s, KN5000 sub-CPU payload
   v1.42.  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.

   DSP_Config_Init keeps its voice index in IZ and the shadow-block pointer on the stack across its calls, which is what
   V4.23 does by itself with two locals live across calls: no pseudo-register is needed here.  Its own register writes
   are the tone-generator idiom (inline nops, leading space).  ToneGen_SelfTest_ProbeVoice0 follows it in the ROM (its
   result in IZ, its loop counter in QIZ; the counter is never initialised in the ROM).
   VoiceParam_SubSlot_Apply_Catalog50 / CustomTone_Apply_Catalog8C: round 9's spellings with the byte local declared
   last (V4.23 gave the first declared byte QIZL; the ROM has the nibble in QIZH, the loop counter in QIZL) and the
   nibble computed into its own register (`lo = c; lo &= 15;`).

   cc900-module: ToneGen_WriteGlobalConfig ToneGen_WriteVoiceParams ToneGen_WriteSingleReg
   cc900-module: ToneGen_WriteExtParams_15 ToneGen_WriteExtParams_56 ToneGen_WriteExtParams_56b
   cc900-module: VoiceSubSlot_Init CustomTone_CopySubUnitRecord */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */
extern unsigned int __near ram_2aa4[];
extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
extern unsigned char ToneGen_GlobalConfig_Defaults[];
extern unsigned int ToneGen_VoiceParamShadow_Defaults[];
extern unsigned int ToneGen_ProbeVoice_ParamBlock[];

struct shadow { unsigned int w[34]; };
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

extern void ToneGen_WriteGlobalConfig(unsigned char *cfg);
extern void ToneGen_WriteVoiceParams(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v);
extern void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p);
extern unsigned int ToneGen_Read_Register(unsigned int reg);
extern void VoiceSubSlot_Init();
extern void WaveSel_Cache_SetDescPtr();
extern void CustomTone_CopySubUnitRecord();

void DSP_Config_Init(void)
{
    unsigned int *p;
    unsigned int i;
    ToneGen_WriteGlobalConfig(ToneGen_GlobalConfig_Defaults);
    p = ram_2aa4;
    *(struct shadow *)p = *(struct shadow *)ToneGen_VoiceParamShadow_Defaults;
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
        ram_100000 = i;
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

unsigned int ToneGen_SelfTest_ProbeVoice0(void)
{
    unsigned int r;
    unsigned int k;
    r = 0xffff;
    ram_18 &= ~0x80;
    ram_100000 = 0x840;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0xff00;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = 0x800;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0xff80;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ToneGen_WriteVoiceParams(0, ToneGen_ProbeVoice_ParamBlock);
    ToneGen_WriteSingleReg(0, 0xf000);
    for (; k < 1000; k++) {
        if (ToneGen_Read_Register(0) != 0) {
            r = 0;
            ram_18 &= ~0x80;
            ram_100000 = 0x840;
            __ASM(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xff00;
            __ASM(" jr $+2");
            __ASM(" nop");
            __ASM(" nop");
            __ASM(" nop");
            ram_18 &= ~0x80;
            ram_100000 = 0x800;
            __ASM(" nop");
            ram_18 |= 0x80;
            ram_100002 = 0xff80;
            __ASM(" jr $+2");
            __ASM(" nop");
            __ASM(" nop");
            __ASM(" nop");
            break;
        }
    }
    ram_18 &= ~0x80;
    ram_100000 = 0xc0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= ~0x80;
    ram_100000 = 0;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0x7e00;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    return r;
}

/* cc900-name: SubSlot_Apply_Catalog50=VoiceParam_SubSlot_Apply_Catalog50 */
void SubSlot_Apply_Catalog50(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char j;
    unsigned char k;
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 80));
    k = sel;
    k &= 15;
    (*(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[k])[2] = tbl[idx].a;
    (*(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[k])[3] = tbl[idx].b;
    VoiceSubSlot_Init(part, k);
    for (j = 0; j < 4; j++) WaveSel_Cache_SetDescPtr(part, k, j);
}

/* cc900-name: CustomTone_Apply_Catalog8C=VoiceParam_CustomTone_Apply_Catalog8C */
void CustomTone_Apply_Catalog8C(unsigned int idx, unsigned char c)
{
    unsigned char e;
    struct e16 *tbl;
    unsigned char lo;
    unsigned char *rec;
    e = ram_4531c[29351];
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 140));
    lo = c;
    lo &= 15;
    rec = ram_4531c + ((int)e * 80 + (int)lo * 21);
    rec += 19127;
    CustomTone_CopySubUnitRecord(lo, tbl[idx].a, tbl[idx].b, e);
    rec[1] = tbl[idx].a;
    rec[2] = (tbl[idx].b & 15) | 80;
}
