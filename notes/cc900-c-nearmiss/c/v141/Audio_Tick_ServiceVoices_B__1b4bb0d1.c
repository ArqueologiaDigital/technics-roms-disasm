/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 1b4bb0d186058d9acd2018736b641e21f68bf71d32d6b7249cfa49e3ef574558 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_4132b;
extern unsigned char ram_41350[];
extern unsigned char ram_43076[][0x47];
extern unsigned int ram_451b4[];
extern void Voice_Clear_HoldBit(int ch);
extern void Voice_Reload_Levels(int ch);
extern void Voice_ToneTableRamp_Up(unsigned char ch, unsigned char *s);
extern void Voice_ToneTableRamp_Down(unsigned char ch, unsigned char *s);
extern void Voice_ToneTableApply_Filter(unsigned char ch, unsigned char *r);
extern void Voice_ToneTableApply_Pitch(unsigned char ch, unsigned char *r);
extern void Pitch_Bend_Ramp_Tick(void);
extern void Pitch_Emit_Reg400(unsigned char *v);
extern void Voice_Step_DelayTimers(unsigned char *p);
extern unsigned char *Voice_Query_AllChannels(void);
extern void ToneGen_WriteVoicePitch(int ch, unsigned int *p);
void Voice_Step_ExprRamp(unsigned char *v);
void Voice_TickNoteDecay(void);
void Audio_Tick_ServiceVoices_B(void)
{
    unsigned char f;
    unsigned char *q;
    unsigned char *v;
    unsigned char i;
    unsigned char *rec;
    unsigned char *u;
    Voice_TickNoteDecay();
    Pitch_Bend_Ramp_Tick();
    if (ram_4132b & 0x400) {
        u = Voice_Query_AllChannels() + 5;
        q = u;
        if (*u < 0x40) do {
            v = ram_43076[*q];
            if (*(unsigned int *)(v + 1) & 0x400) {
                Pitch_Emit_Reg400(v);
                ToneGen_WriteVoicePitch(*q, ram_451b4);
            }
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 0x8000L) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
                else if (*(unsigned int *)(v + 49) & 0x8000L) Voice_Step_ExprRamp(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            } else if (*(unsigned int *)(v + 49) & 0x8000L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 49) = 0;
            }
            q++;
        } while (*q < 0x40);
    } else {
        u = Voice_Query_AllChannels() + 5;
        q = u;
        if (*u < 0x40) do {
            v = ram_43076[*q];
            if (*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 0x8000L) {
                if (*(unsigned int *)(v + 47) & 0x8080L) Voice_Step_DelayTimers(v);
                else if (*(unsigned int *)(v + 49) & 0x8000L) Voice_Step_ExprRamp(v);
            } else if (*(unsigned int *)(v + 47) & 0x8080L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 47) = 0;
            } else if (*(unsigned int *)(v + 49) & 0x8000L) {
                Voice_Clear_HoldBit(*v);
                Voice_Reload_Levels(*v);
                *(unsigned int *)(v + 49) = 0;
            }
            q++;
        } while (*q < 0x40);
    }
    for (i = 0; i < 26; i++) {
        rec = &ram_41350[i * 0x11f];
        f = rec[99];
        if (f & 1) {
            if (f & 2) {
                if (f & 4) {
                    if (!(f & 8)) Voice_ToneTableRamp_Up(i, rec);
                } else {
                    rec[99] |= 4;
                    Voice_ToneTableApply_Filter(i, rec);
                }
            } else if (!(f & 4)) {
                if (!(f & 0x10)) Voice_ToneTableRamp_Down(i, rec);
            } else {
                rec[99] &= ~4;
                Voice_ToneTableApply_Pitch(i, rec);
            }
        }
    }
}
