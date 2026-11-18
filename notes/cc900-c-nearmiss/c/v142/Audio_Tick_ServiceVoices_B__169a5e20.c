/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_envelopes_and_channels_ag_21a.c (2026-11-18-32-sub-r21g-staged)
   sha256 169a5e2055979a6e2611f549812fd19ea8357c1809485d3c025a465401095fd4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int ram_41343;
extern unsigned char ram_41368[];
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
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
    if (ram_41343 & 0x400) {
        u = Voice_Query_AllChannels() + 5;
        q = u;
        if (*u < 0x40) do {
            v = ram_4308e[*q];
            if (*(unsigned int *)(v + 1) & 0x400) {
                Pitch_Emit_Reg400(v);
                ToneGen_WriteVoicePitch(*q, ram_451cc);
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
            v = ram_4308e[*q];
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
        rec = &ram_41368[i * 0x11f];
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
