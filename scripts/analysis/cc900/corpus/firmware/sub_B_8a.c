/* lane_sub helper B, round 8, form a: new routines of core/06_voice_envelopes_and_channels.s from pool_B_remaining and
   refinements of round 7's misses (KN5000 sub-CPU payload v1.42).  No inline assembly, no pseudo-registers.
   cc900-module: Int_ClampSignedToRange Pan_ScaleWithVelocity Voice_Clamp_Byte_HL Voice_Build_OutputLevel Voice_UpdateAllLFO Voice_Step_DelayTimers */

extern unsigned int ram_41343;
extern unsigned char ram_41342[];
extern int ram_41360;
extern int ram_41362;
extern int ram_41364;
extern unsigned char ram_4308e[][0x47];

extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451d2;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451d8;
extern unsigned int ram_451da;
extern unsigned int ram_451dc;
extern unsigned int ram_451de;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e4;
extern unsigned int ram_451e6;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned int ram_451ec;
extern unsigned int ram_451ee;
extern unsigned int ram_451f0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;

extern unsigned char Voice_OutputLevel_Table[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];

extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int Voice_Clamp_Byte_HL(int a);
extern int Voice_Build_OutputLevel(unsigned char *v, int t);
extern void Voice_UpdateAllLFO(void);
extern unsigned char *Voice_Query_AllChannels(void);
extern void Voice_Step_DelayTimers(unsigned char *v);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);

/* ---- scale-tune user offsets (round 2 indexed with an unsigned int, which V4.23 widens to 32 bits) ---- */

unsigned char ScaleTune_Get_User_Offset(unsigned char n) { return ram_41342[(int)n + 12]; }

void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v) { ram_41342[(int)n + 12] = v - 0x80; }

/* ---- channel pan shift: v[62] / v[64] are the left / right pan words; the voice's patch (v + 39) word 24 bit 8
   enables the shift, bit 9 makes it subtract; the shift is the signed byte 32 of the part data (v + 35) ---- */

void Voice_WriteChPanShift(unsigned char *v, unsigned char flag)
{
    int l, r;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            l = (*(unsigned int *)(v + 62) & 0x7f) - (*(char **)(v + 35))[32];
            r = (*(unsigned int *)(v + 64) & 0x7f) - (*(char **)(v + 35))[32];
        } else {
            l = (*(unsigned int *)(v + 62) & 0x7f) + (*(char **)(v + 35))[32];
            r = (*(unsigned int *)(v + 64) & 0x7f) + (*(char **)(v + 35))[32];
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451e8 = r | 0x8000;
        else ram_451e8 = (r & 0xff) | (*(unsigned int *)(v + 64) & 0xff00);
        ram_451e6 = (l & 0xff) | (*(unsigned int *)(v + 62) & 0xff00);
    } else {
        ram_451e6 = *(unsigned int *)(v + 62);
        ram_451e8 = *(unsigned int *)(v + 64);
    }
}

/* byte for byte the same code as Voice_WriteChPanShift */
void Voice_WriteChPanShift2(unsigned char *v, unsigned char flag)
{
    int l, r;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            l = (*(unsigned int *)(v + 62) & 0x7f) - (*(char **)(v + 35))[32];
            r = (*(unsigned int *)(v + 64) & 0x7f) - (*(char **)(v + 35))[32];
        } else {
            l = (*(unsigned int *)(v + 62) & 0x7f) + (*(char **)(v + 35))[32];
            r = (*(unsigned int *)(v + 64) & 0x7f) + (*(char **)(v + 35))[32];
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451e8 = r | 0x8000;
        else ram_451e8 = (r & 0xff) | (*(unsigned int *)(v + 64) & 0xff00);
        ram_451e6 = (l & 0xff) | (*(unsigned int *)(v + 62) & 0xff00);
    } else {
        ram_451e6 = *(unsigned int *)(v + 62);
        ram_451e8 = *(unsigned int *)(v + 64);
    }
}

/* ---- envelope level pair, EG type A: level from the slot (v + 23) byte 45 plus the part's signed byte 108, clamped
   0..100, through the level curve; capped by the hold level when the part's word 10 bit 0 is set and the voice's
   word 1 bit 8 is clear; then the velocity scaling when the slot's byte 53 is set ---- */

void Voice_Calc_LevelPair_EGA(unsigned char *v)
{
    unsigned char *s;
    int lv, t;
    s = *(unsigned char **)(v + 23);
    lv = Int_ClampSignedToRange(s[45] + (*(char **)(v + 35))[108], 100, 0);
    lv = Voice_EnvelopeLevel_Curve[(unsigned char)lv];
    if ((*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) && !(*(unsigned int *)(v + 1) & 0x100)) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[53] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[48], s[49], s[50], (char)s[53]);
        lv = Voice_Clamp_Byte_HL(lv);
    }
    ram_451f8 = (lv << 8) | 0x80;
    ram_451fa = lv << 8;
}

/* ---- round 7 misses ---- */

/* +38: the ROM loads word 12 and compares it in a register; compared here as unsigned with 0xfe00 */
int Voice_ApplyPortamento2(unsigned char *v)
{
    unsigned char *q;
    int t, u;
    q = *(unsigned char **)(v + 23);
    t = *(int *)(v + 13);
    if (q[5] != 0) t += (int)q[5] - 100;
    else t -= 0x200;
    if (ram_41343 & 2) {
        t -= *(int *)(*(unsigned char **)(v + 35) + 16);
        t -= *(int *)(*(unsigned char **)(v + 35) + 12);
        u = -512;
        if (*(unsigned int *)(*(unsigned char **)(v + 35) + 12) != 0xfe00) u = *(int *)(*(unsigned char **)(v + 35) + 12) >> 2;
        t += u;
    }
    return Voice_Build_OutputLevel(v, t);
}

/* +16: V4.23 reloaded the cursor before the first test; a guarded do-while here */
void Audio_Tick_ServiceVoices_A(void)
{
    unsigned char *q;
    unsigned char *v;
    Voice_UpdateAllLFO();
    q = Voice_Query_AllChannels() + 5;
    if (*q < 0x40) {
        do {
            v = &ram_4308e[*q][0];
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 32768) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            }
        } while (*++q < 0x40);
    }
}

/* +153: the output-level read without a local (V4.23 put the local in DE, the ROM uses BC) */
void Voice_InitVoiceState(unsigned char slot)
{
    ram_451ce = 0;
    ram_451da = ram_41360;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451d4 = 0x17f;
    ram_451d6 = 0x7f7f;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451e2 = 0;
    ram_451ea = 0;
    ram_451dc = 0;
    ram_451de = 0;
    ram_451d8 = 0x40;
    ram_451e0 = 0;
    ram_451d2 = 0;
    ram_451e4 = 0xff7f;
    ram_451e6 = ram_41362;
    ram_451e8 = ram_41362;
    ram_451d0 = *(int *)&Voice_OutputLevel_Table[ram_41364 << 1] << 1;
    *(unsigned int *)&ram_4308e[slot][0x2d] = 0xf000;
}
