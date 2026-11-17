/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_3a.c (2026-11-16-58-sub-r3)
   sha256 99e952f60a590931da21e8c6184efc818dce0d30099b96db61b5a5c174d03956 (name+funcs); compiled at -Xr */
extern unsigned char ram_4308e[][0x47];
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
    v = *(unsigned char **)&ram_4308e[slot][0x1f];
    if (v[0] & 8) {
        n = v[14];
        ram_451f8 = (unsigned int)Voice_VibratoDepth_Table[n] << 8 | 0x80;
        ram_451fa = (unsigned int)Voice_VibratoDepth_Table[n] << 8;
        for (q = Voice_Query_PartVoices(part) + 5; *q < 0x40; q++)
            if (n == (*(unsigned char **)&ram_4308e[*q][0x1f])[14])
                ToneGen_WriteLevelPair(*q, ram_451cc);
    }
}
