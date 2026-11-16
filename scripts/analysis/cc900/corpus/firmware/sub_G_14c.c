/* lane_sub helper G, round 14, form c: idiom (a), reload after store, applied to six near misses of the KN5000
   sub-CPU payload v1.42.  Each function is its best earlier attempt (sub_B_10c, sub_E_7c, sub_C_10b, sub_A_7c,
   sub_B_7i) changed only where the ROM stores a value into a stack local and goes on using the register: a second
   plain local u receives the value, the kept local is assigned from u, and the next use reads u.
   Form c: the loops chain `q = u = list + 5;` and keep `if (*u < 0x40) do ... while`;
   DSP_WriteLUTParamSet chains `p = u = *pp;`; the Catalog80 index drops the (int) cast; EGEnv takes the
   record address as `&table[(int)n * 27]`. */

/* cc900-module: ToneGen_WriteVoice_Direct */
/* cc900-module: ToneGen_WriteVoice_6Words */
/* cc900-module: ToneGen_WriteNote2ch */
/* cc900-module: DSP_UnpackParam3B */
/* cc900-module: DSP_WriteFreqParam */
/* cc900-module: DSP_WriteCoeffData_5B */
/* cc900-module: CustomTone_CopyToneRecord */
/* cc900-module: CustomTone_CopySubUnitRecord */
/* cc900-module: EnvDepth_Cap */
/* cc900-module: Voice_UpdateAllLFO */
/* cc900-module: Voice_Step_DelayTimers */

extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];

extern void Voice_Calc_LevelPair_EGA(unsigned char *v);
extern void Voice_Calc_LevelPair_EGB(unsigned char *v);
extern void Voice_Calc_LevelPair_EGC(unsigned char *v);
extern void Voice_WriteVolume_SetFlag(unsigned char *v);
extern void Voice_WriteVolume_OrPan(unsigned char *v);
extern void ToneGen_WriteSegRegs_SameLevel(int ch, unsigned int *blk);
extern void Voice_Clear_HoldBit(int ch);
extern void ToneGen_WriteVoice_Direct(unsigned int a, unsigned int d);
extern void ToneGen_WriteVoice_6Words(unsigned int ch, unsigned int *p);
extern void ToneGen_WriteNote2ch(unsigned int ch, unsigned int *p);

void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *u;
    unsigned char *v;
    base = ram_4308e;
    q = u = list + 5;
    if (*u < 0x40) {
        do {
            v = base[*q];
            switch (*(unsigned int *)(v + 1) & 0x3c) {
            case 4:
            case 8:
            case 0x20:
                if ((*(unsigned int *)(v + 1) & 32768) || !(*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1)) {
                    if (*(unsigned int *)(v + 1) & 0x100) {
                        Voice_Calc_LevelPair_EGA(v);
                        ToneGen_WriteSegRegs_SameLevel(*q, ram_451cc);
                        ToneGen_WriteVoice_Direct(*q, *(unsigned int *)(v + 45));
                        Voice_Clear_HoldBit(*q);
                        *(unsigned int *)(v + 1) &= ~0x100;
                    } else {
                        Voice_Calc_LevelPair_EGA(v);
                        Voice_Calc_LevelPair_EGB(v);
                        Voice_Calc_LevelPair_EGC(v);
                        ToneGen_WriteVoice_6Words(*q, ram_451cc);
                    }
                } else if (*(unsigned int *)(v + 1) & 0x100) {
                    Voice_Calc_LevelPair_EGA(v);
                    ToneGen_WriteSegRegs_SameLevel(*q, ram_451cc);
                    ToneGen_WriteVoice_Direct(*q, *(unsigned int *)(v + 45));
                    Voice_Clear_HoldBit(*q);
                    *(unsigned int *)(v + 1) &= ~0x100;
                } else if (!(*(unsigned int *)(v + 64) & 0xff)) {
                    Voice_WriteVolume_SetFlag(v);
                    ToneGen_WriteNote2ch(*q, ram_451cc);
                }
                break;
            case 0x10:
                if (flag != 0) {
                    Voice_WriteVolume_OrPan(v);
                    ToneGen_WriteNote2ch(*q, ram_451cc);
                }
                break;
            }
            q++;
        } while (*q < 0x40);
    }
}

extern unsigned char DSP_Op74_LUT_Rows9_Var0[];
extern unsigned char DSP_Op74_LUT_Rows9_Var1[];
extern unsigned char DSP_Op74_LUT_Rows9_Var2[];
extern unsigned char DSP_Op74_LUT_Rows8_Var0[];
extern unsigned char DSP_Op74_LUT_Rows8_Var1[];
extern unsigned char DSP_Op74_LUT_Rows8_Var2[];

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern long DSP_UnpackParam3B(unsigned char **pp);
extern int DSP_WriteFreqParam(unsigned int a, long v, int chip, unsigned int base);
extern int DSP_WriteCoeffData_5B(long v, int chip, unsigned int base);

int DSP_WriteLUTParamSet(unsigned char **pp, unsigned int b, long type, int chip, unsigned int base)
{
    unsigned int rows;
    unsigned int i;
    unsigned char *p;
    unsigned char *lut;
    int st;
    unsigned char *u;
    unsigned char c;

    p = u = *pp;
    c = *u++;
    p = u;
    switch (c) {
    default:
        rows = 0x24;
        switch (type) {
        default:
            lut = DSP_Op74_LUT_Rows9_Var0;
            break;
        case 1:
            lut = DSP_Op74_LUT_Rows9_Var1;
            break;
        case 2:
            lut = DSP_Op74_LUT_Rows9_Var2;
            break;
        }
        break;
    case 1:
        rows = 0x20;
        switch (type) {
        default:
            lut = DSP_Op74_LUT_Rows8_Var0;
            break;
        case 1:
            lut = DSP_Op74_LUT_Rows8_Var1;
            break;
        case 2:
            lut = DSP_Op74_LUT_Rows8_Var2;
            break;
        }
        break;
    }
    b = *lut++;
    for (i = 0; i < rows >> 2; i++) {
        if (i != 0) {
            st = DSP_DispatchCommand(1, chip);
            st = DSP_DispatchData(1, chip);
            st = DSP_DispatchData(0x60, chip);
        }
        st = DSP_WriteFreqParam((i << 2) + b, DSP_UnpackParam3B(&lut), chip, base);
        st = DSP_WriteCoeffData_5B(DSP_UnpackParam3B(&lut), chip, base);
        st = DSP_WriteCoeffData_5B(DSP_UnpackParam3B(&lut), chip, base);
        st = DSP_WriteCoeffData_5B(DSP_UnpackParam3B(&lut), chip, base);
        DSP_DispatchCommand(3, chip);
    }
    *pp = p;
    return st;
}

extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;

struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

extern void CustomTone_CopyToneRecord();
extern void CustomTone_CopySubUnitRecord();

/* cc900-name: CustomTone_Apply_Catalog80=VoiceParam_CustomTone_Apply_Catalog80 */
void CustomTone_Apply_Catalog80(unsigned int idx)
{
    unsigned char *rec;
    struct e16 *tbl;
    unsigned char e;
    unsigned char k;
    unsigned char *s;
    unsigned char u;
    u = ram_4531c[29351];
    e = u;
    rec = ram_4531c + (u * 80 + 19111);
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 128));
    CustomTone_CopyToneRecord(tbl[idx].a, tbl[idx].b, e);
    for (k = 0; k < 2; k++) {
        s = rec + ((int)k * 21 + 16);
        CustomTone_CopySubUnitRecord(k, s[1], s[2], e);
        s[2] &= 15;
        s[2] |= 80;
    }
    ram_4531c[(int)e * 2 + 18855] = tbl[idx].a;
    ((unsigned char *)(unsigned long)(ram_4531c + ((int)e * 2 + 18855)))[1] = (tbl[idx].b & 31) | 96;
}

extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);

unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = &ram_4424e[(int)n * 27];
    p = u;
    x = EGEnv_BaseCurve_A[u[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}

unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = &ram_44257[(int)n * 27];
    p = u;
    x = EGEnv_BaseCurve_B[u[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}

extern void Voice_UpdateAllLFO(void);
extern unsigned char *Voice_Query_AllChannels(void);
extern void Voice_Step_DelayTimers(unsigned char *);
extern void Voice_Reload_Levels(int);

/* the voice record in XIZ, the channel-list cursor on the stack */
void Audio_Tick_ServiceVoices_A(void)
{
    unsigned char *q;
    unsigned char *u;
    unsigned char *v;
    Voice_UpdateAllLFO();
    q = u = Voice_Query_AllChannels() + 5;
    if (*u < 0x40) {
        do {
            v = &ram_4308e[*q][0];
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 32768) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            }
            q++;
        } while (*q < 0x40);
    }
}
