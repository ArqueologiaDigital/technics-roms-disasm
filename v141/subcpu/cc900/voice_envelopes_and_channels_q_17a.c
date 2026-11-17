/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_4132b;
extern unsigned char ram_41334;
extern unsigned char ram_41356[];
extern unsigned char ram_4135a[];
extern unsigned char ram_43076[][0x47];
extern unsigned int ram_451b4[];
extern unsigned int ram_451ce;
extern unsigned int ram_451d0;
extern unsigned int ram_451e0;
extern unsigned int ram_451e2;
extern unsigned int ram_451e8;
extern unsigned int ram_451ea;
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern unsigned char Voice_EnvLevel_IndexMap[];
extern unsigned char Voice_VibratoDepth_Table[];
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
extern int Voice_Build_OutputLevel(unsigned char *v, int t);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_Query_PartVoices_Mask7F(int part);
extern void Level_Build_Reg0C0(unsigned char *v);
extern void Voice_Build_GateCommand(unsigned char *v);
extern void Voice_ComputePitchBend2(unsigned char *v);
extern void Voice_Build_GateCmd_NoPartial(unsigned char *v);
extern void ToneGen_ReadPitch_AndScale(int ch);
extern void ToneGen_WriteLevelPair(int ch, unsigned int *p);
extern void ToneGen_WriteSingleReg(unsigned char ch, unsigned int w);
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);
extern void AudioMod_Apply_Porta_Curve(int part, unsigned int val, unsigned char *m);
extern void Pitch_Refresh_Sounding_Voices(unsigned char *list);
extern void TVF_Refresh_Sounding_Voices(unsigned char *list);
extern void AudioChannel_AllVoices_UpdPan(unsigned char *list);
void AudioMod_Apply_BusRouting(unsigned char part, unsigned char mask, unsigned int a, unsigned int b);
void AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m);
void AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m);
void AudioChannel_Handler_Cmd01(unsigned char part, unsigned int val, unsigned char *m);
void AudioChannel_Handler_Cmd02(unsigned char part, unsigned char val, unsigned char *m);
void AudioChannel_Handler_Cmd03(unsigned char part, unsigned char val, unsigned char *m);
void Voice_AllVoices_UpdateVelocity(unsigned char v);
int Voice_ApplyPortamento2(unsigned char *v);
void Voice_Calc_LevelPair_EGC(unsigned char *v);
int Int_ClampSignedToRange_B(int a, int hi, int lo);
void Voice_Step_DelayTimers(unsigned char *p);
void Voice_WriteChPanShift(unsigned char *v, unsigned char flag);
void Voice_WriteChPanShift2(unsigned char *v, unsigned char flag);
void Voice_WriteChPitchWithVib(unsigned char part, unsigned char slot);

/* cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
/* cc900-name: AudioChannel_AllVoices_UpdPan=AudioChannel_AllVoices_Update_PanShift */
/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
/* cc900-module: AudioChannel_AllVoices_UpdPan AudioChannel_AllVoices_Update_PanShift AudioMod_Apply_BusRouting AudioMod_Apply_Porta_Curve AudioMod_Scale_To_LevelPairShf AudioMod_Scale_To_LevelPairShift AudioMod_Scale_To_Part_1F Detune_ScaleSymmetric Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Pitch_Refresh_Sounding_Voices TVF_Refresh_Sounding_Voices Voice_Build_OutputLevel */
void AudioChannel_Handler_Cmd01(unsigned char part, unsigned int val, unsigned char *m)
{
    if (val & 32768) val &= ~0x8000;
    else val <<= 7;
    AudioMod_Apply_Porta_Curve(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 16, 32);
    Pitch_Refresh_Sounding_Voices(Voice_Query_PartVoices(part));
}

void AudioChannel_Handler_Cmd02(unsigned char part, unsigned char val, unsigned char *m)
{
    unsigned char *list;
    AudioMod_Scale_To_LevelPairShf(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 256, 512);
    switch ((*(unsigned char **)&ram_41356[part * 0x11f])[16] & 0xc0) {
    case 0:
        list = Voice_Query_PartVoices_Mask7F(part);
        break;
    case 0x80:
        list = Voice_Query_PartVoices(part);
        break;
    case 0x40:
        break;
    case 0xc0:
        break;
    }
    AudioChannel_AllVoices_UpdPan(list);
}

void AudioChannel_Handler_Cmd03(unsigned char part, unsigned char val, unsigned char *m)
{
    AudioMod_Scale_To_Part_1F(part, val, m);
    AudioMod_Apply_BusRouting(part, m[0], 64, 128);
    TVF_Refresh_Sounding_Voices(Voice_Query_PartVoices(part));
}

void Voice_AllVoices_UpdateVelocity(unsigned char v)
{
    unsigned char p;
    unsigned char u;
    unsigned char *q;
    ram_41334 = v & 0x0f;
    for (p = 0; p < 26; p++) {
        if (*(unsigned int *)&ram_4135a[p * 0x11f] & 2) {
            for (q = Voice_Query_PartVoices(p) + 5; *q < 0x40; q++) {
                u = ram_43076[*q][4];
                p = u;
                switch ((*(unsigned char **)&ram_41356[u * 0x11f])[16] & 0xc0) {
                case 0:
                case 0x40:
                case 0xc0:
                    Level_Build_Reg0C0(ram_43076[*q]);
                    Voice_Build_GateCommand(ram_43076[*q]);
                    break;
                case 0x80:
                    Voice_ComputePitchBend2(ram_43076[*q]);
                    Voice_Build_GateCmd_NoPartial(ram_43076[*q]);
                    break;
                }
                ToneGen_ReadPitch_AndScale(*q);
            }
        }
    }
}

int Voice_ApplyPortamento2(unsigned char *v)
{
    unsigned char *q;
    int t;
    unsigned int u;
    q = *(unsigned char **)(v + 23);
    t = *(int *)(v + 13);
    if (q[5] != 0) t += (int)q[5] - 100;
    else t -= 0x200;
    if (ram_4132b & 2) {
        t -= *(int *)(*(unsigned char **)(v + 35) + 16);
        t -= *(int *)(*(unsigned char **)(v + 35) + 12);
        u = 0xfe00;
        if (*(int *)(*(unsigned char **)(v + 35) + 12) != 0xfe00) u = *(int *)(*(unsigned char **)(v + 35) + 12) >> 2;
        t += u;
    }
    return Voice_Build_OutputLevel(v, t);
}

void Voice_Calc_LevelPair_EGC(unsigned char *v)
{
    unsigned char *p;
    unsigned char *s;
    int lv, t, d;
    p = *(unsigned char **)(v + 23);
    s = p;
    t = Voice_EnvelopeLevel_Curve[p[69]];
    lv = t;
    if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1) {
        t = Voice_EnvelopeLevel_Curve[Voice_EnvLevel_IndexMap[(*(unsigned char **)(v + 35))[24]]];
        if (t <= lv) lv = t;
    }
    if (s[76] != 0) {
        lv += Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[76]);
        if (s[71] != 0) {
            lv += PitchBend_Scale((char)s[71], v[12], 4);
            lv = Int_ClampSignedToRange(lv, 0xff, 0);
        } else lv = Int_ClampSignedToRange(lv, 0xff, 0);
    } else if (s[71] != 0) {
        lv += PitchBend_Scale((char)s[71], v[12], 4);
        lv = Int_ClampSignedToRange(lv, 0xff, 0);
    }
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[70] + (int)(char)s[61], 50, -50));
    t = (lv << 8) | (d & 0xff);
    ram_451e8 = t;
    ram_451ea = t;
}

int Int_ClampSignedToRange_B(int a, int hi, int lo)
{
    if (a < lo) a = lo;
    else if (a > hi) a = hi;
    return a;
}

void Voice_Step_DelayTimers(unsigned char *p)
{
    unsigned int t;
    t = *(unsigned int *)(p + 47);
    if (t & 32768) {
        t -= 0x100;
        if ((t & 0x7f00) == 0) {
            ToneGen_WriteSingleReg(*p, *(unsigned int *)(p + 45));
            Voice_Clear_HoldBit(*p);
            t &= ~0x8000;
        }
    }
    if (t & 0x80) {
        t--;
        if ((t & 0x7f) == 0) {
            Voice_Reload_Levels(*p);
            t &= 0x7f;
        }
    }
    *(unsigned int *)(p + 47) = t;
}

void Voice_WriteChPanShift(unsigned char *v, unsigned char flag)
{
    int l, r, s;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l -= s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r -= s;
        } else {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l += s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r += s;
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451d0 = r | 0x8000;
        else ram_451d0 = (*(unsigned int *)(v + 64) & 0xff00) | (r & 0xff);
        ram_451ce = (*(unsigned int *)(v + 62) & 0xff00) | (l & 0xff);
    } else {
        ram_451ce = *(unsigned int *)(v + 62);
        ram_451d0 = *(unsigned int *)(v + 64);
    }
}

void Voice_WriteChPanShift2(unsigned char *v, unsigned char flag)
{
    int l, r, s;
    if ((*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x100) && (*(unsigned int *)(v + 64) & 0xff)) {
        if (*(unsigned int *)(*(unsigned char **)(v + 39) + 24) & 0x200) {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l -= s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r -= s;
        } else {
            s = (*(char **)(v + 35))[32];
            l = *(unsigned int *)(v + 62) & 0x7f;
            l += s;
            s = (*(char **)(v + 35))[32];
            r = *(unsigned int *)(v + 64) & 0x7f;
            r += s;
        }
        l = Int_ClampSignedToRange(l, 0x7f, 4);
        r = Int_ClampSignedToRange(r, 0x7f, 0);
        if (flag != 0) ram_451d0 = r | 0x8000;
        else ram_451d0 = (*(unsigned int *)(v + 64) & 0xff00) | (r & 0xff);
        ram_451ce = (*(unsigned int *)(v + 62) & 0xff00) | (l & 0xff);
    } else {
        ram_451ce = *(unsigned int *)(v + 62);
        ram_451d0 = *(unsigned int *)(v + 64);
    }
}

void Voice_WriteChPitchWithVib(unsigned char part, unsigned char slot)
{
    unsigned char *v;
    unsigned char n;
    unsigned char u;
    unsigned char *q;
    v = *(unsigned char **)&ram_43076[slot][0x1f];
    if (v[0] & 8) {
        u = v[14];
        n = u;
        ram_451e0 = (unsigned int)Voice_VibratoDepth_Table[u] << 8 | 0x80;
        ram_451e2 = (unsigned int)Voice_VibratoDepth_Table[n] << 8;
        for (q = Voice_Query_PartVoices(part) + 5; *q < 0x40; q++)
            if (n == (*(unsigned char **)&ram_43076[*q][0x1f])[14])
                ToneGen_WriteLevelPair(*q, ram_451b4);
    }
}
