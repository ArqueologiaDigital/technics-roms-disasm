/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7a.c (2026-11-16-79-sub-r7)
   sha256 f70607b5111b1b73ae470351c728e34d55ce40ce7a9d878e58e34960dca5e443 (name+funcs); compiled at -Xr */
struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
struct pkt *Voice_Query_AllChannels(void);
void Voice_SetMasterTune(int a);
void Pitch_Refresh_Sounding_Voices(struct pkt *q);
void Voice_SetMasterTuneAndApply(char a)
{
    Voice_SetMasterTune(a);
    Pitch_Refresh_Sounding_Voices(Voice_Query_AllChannels());
}
