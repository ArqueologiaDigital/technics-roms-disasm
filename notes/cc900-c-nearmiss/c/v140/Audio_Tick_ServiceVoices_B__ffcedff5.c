/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 ffcedff560f1dc88ff9d34b0d6db4e4b13655df466d77899e99df330f4d6543b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_412f7;
extern unsigned char ram_4131c[];
extern unsigned char ram_43042[][0x47];
extern unsigned int ram_45180[];
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
    if (ram_412f7 & 0x400) {
        u = Voice_Query_AllChannels() + 5;
        q = u;
        if (*u < 0x40) do {
            v = ram_43042[*q];
            if (*(unsigned int *)(v + 1) & 0x400) {
                Pitch_Emit_Reg400(v);
                ToneGen_WriteVoicePitch(*q, ram_45180);
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
            v = ram_43042[*q];
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
        rec = &ram_4131c[i * 0x11f];
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
