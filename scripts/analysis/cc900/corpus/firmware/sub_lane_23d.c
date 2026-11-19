/* lane_sub, round 23, form d (KN5000 sub-CPU payload v1.42), 2026-11-19.
   DSP_VoiceState_Dispatch as form c (sub_lane_23c.c) without parameters, and the state test as
   `if (s != 0x10 && s != 0x50) continue;`.
   cc900-options: -Xr */

extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void VoiceSlot_FullInit(int n);
void VoiceSlot_AltInit(int n);
void Voice_PortamentoTargets_SetAll(int n);

void DSP_VoiceState_Dispatch(void)
{
    unsigned char i;

    for (i = 0; i < 0x1a; i++) {
        if (ram_41382[i * 287] != 0x10 && ram_41382[i * 287] != 0x50)
            continue;
        WaveSel_Rebuild_PartCaches(i, ram_41381[i * 287], ram_41382[i * 287]);
        switch ((*(unsigned char **)&ram_4136e[i * 287])[16] & 0xc0) {
        case 0:
        case 0xc0:
            VoiceSlot_FullInit(i);
            break;
        case 0x40:
            Voice_PortamentoTargets_SetAll(i);
            VoiceSlot_AltInit(i);
            break;
        case 0x80:
            break;
        }
    }
}
