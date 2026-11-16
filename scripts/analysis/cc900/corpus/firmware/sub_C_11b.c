/* lane_sub probe round 11, helper C, form b (other spellings of sub_C_11a.c: the last store of Catalog80 through
   plain pointer arithmetic, DSP_Config_Init's locals declared pointer first): DSP_Config_Init and
   VoiceParam_CustomTone_Apply_Catalog80
   (core/08_voice_noteon_and_tonegen.s, KN5000 sub-CPU payload v1.42), refined from round 10's listings.
   Both differed where the ROM stores a value to a stack local and goes on using the register it is in
   (`ld (xsp+2),xwa; ... ld xix,xwa`, `ld (xsp+12),a; extz wa`), and V4.23 reloaded the local: here the store is an
   assignment expression whose value is used.  Catalog80's last store computes its value first in the ROM (into E):
   here through a byte local.

   cc900-module: CustomTone_CopyToneRecord CustomTone_CopySubUnitRecord ToneGen_WriteGlobalConfig
   cc900-module: ToneGen_WriteVoiceParams ToneGen_WriteSingleReg ToneGen_WriteExtParams_15 ToneGen_WriteExtParams_56
   cc900-module: ToneGen_WriteExtParams_56b */

extern unsigned char __tiny ram_18;            /* P6 (sfr_tmp94c241.s) */
extern unsigned int ram_100000;                 /* ToneGen_RegAddrLatch */
extern unsigned int ram_100002;                 /* ToneGen_RegDataPort */
extern unsigned int __near ram_2aa4[];
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
extern unsigned char ToneGen_GlobalConfig_Defaults[];
extern unsigned int ToneGen_VoiceParamShadow_Defaults[];

struct shadow { unsigned int w[34]; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

extern void CustomTone_CopyToneRecord();
extern void CustomTone_CopySubUnitRecord();
extern void ToneGen_WriteGlobalConfig(unsigned char *cfg);
extern void ToneGen_WriteVoiceParams(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteSingleReg(unsigned int reg, unsigned int v);
extern void ToneGen_WriteExtParams_15(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteExtParams_56(unsigned int reg, unsigned int *p);
extern void ToneGen_WriteExtParams_56b(unsigned int reg, unsigned int *p);

/* cc900-name: CustomTone_Apply_Catalog80=VoiceParam_CustomTone_Apply_Catalog80 */
void CustomTone_Apply_Catalog80(unsigned int idx)
{
    unsigned char *rec;
    struct e16 *tbl;
    unsigned char e;
    unsigned char k;
    unsigned char *s;
    unsigned char v;
    rec = ram_4531c + ((int)(e = ram_4531c[29351]) * 80 + 19111);
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 128));
    CustomTone_CopyToneRecord(tbl[idx].a, tbl[idx].b, e);
    for (k = 0; k < 2; k++) {
        s = rec + ((int)k * 21 + 16);
        CustomTone_CopySubUnitRecord(k, s[1], s[2], e);
        s[2] &= 15;
        s[2] |= 80;
    }
    ram_4531c[(int)e * 2 + 18855] = tbl[idx].a;
    v = (tbl[idx].b & 31) | 96;
    (ram_4531c + ((int)e * 2 + 18855))[1] = v;
}

void DSP_Config_Init(void)
{
    unsigned int *p;
    unsigned int i;
    ToneGen_WriteGlobalConfig(ToneGen_GlobalConfig_Defaults);
    *(struct shadow *)(p = ram_2aa4) = *(struct shadow *)ToneGen_VoiceParamShadow_Defaults;
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
