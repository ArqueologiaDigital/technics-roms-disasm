/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr */
extern unsigned char ram_430ad[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451f8;
extern unsigned int ram_451fa;
extern unsigned char Voice_VibratoDepth_Table[];
extern unsigned char *Voice_Query_PartVoices(int);
extern void ToneGen_WriteLevelPair(int, unsigned int *);
void Voice_WriteChPitchWithVib(unsigned char part, unsigned char slot)
{
    unsigned char *v;
    unsigned char n;
    unsigned char *q;
    v = *(unsigned char **)&ram_430ad[slot * 0x47];
    if (*v & 8) {
        n = v[14];
        ram_451f8 = (Voice_VibratoDepth_Table[n] << 8) | 0x80;
        ram_451fa = Voice_VibratoDepth_Table[n] << 8;
        for (q = Voice_Query_PartVoices(part) + 5; *q < 0x40; q++)
            if (n == (*(unsigned char **)&ram_430ad[*q * 0x47])[14])
                ToneGen_WriteLevelPair(*q, ram_451cc);
    }
}
