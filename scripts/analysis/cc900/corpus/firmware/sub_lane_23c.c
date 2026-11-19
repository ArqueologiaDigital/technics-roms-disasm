/* lane_sub, round 23, form c (KN5000 sub-CPU payload v1.42), 2026-11-19.
   DSP_VoiceState_Dispatch: every part (0 .. 25) whose state byte (+0x1a) is 0x10 or 0x50 gets
   Voice_PerVoice_PortamentoPitchUpdate's last two steps (built in voice_ctrlchange.c): its caches rebuilt and its
   slots re-initialised by the patch's type bits.  A byte loop counter (V4.23 puts it in QIZH); the two unused
   parameters its built caller DSP_AlgoSelect passes (0xff, 0xff).
   cc900-options: -Xr */

extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void VoiceSlot_FullInit(int n);
void VoiceSlot_AltInit(int n);
void Voice_PortamentoTargets_SetAll(int n);

void DSP_VoiceState_Dispatch(int a, int b)
{
    unsigned char i;

    for (i = 0; i < 0x1a; i++) {
        if (ram_41382[i * 287] == 0x10 || ram_41382[i * 287] == 0x50) {
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
}
