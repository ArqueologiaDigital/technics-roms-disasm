/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_ad_21a.c (2026-11-18-19-sub-r21b-staged)
   sha256 edaa27fbd836cf269762f237553e96160e8a663e2ede85c4db8ffa3ccd019013 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
extern unsigned char ram_43076[][0x47];
extern unsigned int ram_451b4[];
extern void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
extern void Voice_WriteChPanShift2(unsigned char *v, int flag);
extern void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void AudioChannel_AllVoices_UpdVar3(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    unsigned char *f;
    base = ram_43076;
    list += 5;
    q = list;
    if (*list < 0x40) {
        do {
            v = base[*q];
            switch (*(unsigned int *)(v + 1) & 0x3c) {
            case 4:
            case 0x20:
            case 8:
                break;
            case 0x10:
                f = *(unsigned char **)(v + 19);
                Voice_Calc_LevelPair_FixedAtk(v);
                Voice_WriteChPanShift2(v, 0);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451b4);
                break;
            }
        } while (*++q < 0x40);
    }
}
