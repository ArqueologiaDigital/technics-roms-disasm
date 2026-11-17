/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2a.c (2026-11-16-47-sub-r2)
   sha256 53d7a593968fb87f84af530bceae3e1c306174f47db7d2c6980e60b72454f307 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
void Voice_NoteState_Clear(int n);
void Voice_SetLFO_ActiveFlag(int n);
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void VoiceSlot_FullInit(int n);
void VoiceSlot_AltInit(int n);
void Voice_PortamentoTargets_SetAll(int n);
void Voice_PerVoice_PortamentoPitchUpdate(unsigned char n)
{
    Voice_NoteState_Clear(n);
    Voice_SetLFO_ActiveFlag(n);
    WaveSel_Rebuild_PartCaches(n, ram_41381[n * 287], ram_41382[n * 287]);
    switch ((*(unsigned char **)&ram_4136e[n * 287])[16] & 0xc0) {
    case 0:
    case 0xc0:
        VoiceSlot_FullInit(n);
        break;
    case 0x40:
        Voice_PortamentoTargets_SetAll(n);
        VoiceSlot_AltInit(n);
        break;
    case 0x80:
        break;
    }
}
