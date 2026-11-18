/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AD_20a.c (2026-11-18-6-sub-r20a)
   sha256 8d205696704d19cde930fd2f245296e8098d145f2b7f30d3059fc4b55cb75ba3 (tar-sha256); compiled at -Xr
   cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern void ToneGen_WriteVoice_Reg21_Reg22(unsigned int ch, unsigned int *p);
extern void Voice_WriteChPanShift2(unsigned char *v, int flag);
extern void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void AudioChannel_AllVoices_UpdVar3(unsigned char *list)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    unsigned char *f;
    base = ram_4308e;
    list += 5;
    q = list;
    if (*list < 0x40) {
        do {
            v = base[*q];
            switch (*(unsigned int *)(v + 1) & 0x3c) {
            case 0x20:
            case 8:
                break;
            case 0x10:
                f = *(unsigned char **)(v + 19);
                Voice_Calc_LevelPair_FixedAtk(v);
                Voice_WriteChPanShift2(v, 0);
                ToneGen_WriteVoice_Reg21_Reg22(*q, ram_451cc);
                break;
            }
        } while (*++q < 0x40);
    }
}
