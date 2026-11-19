/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3a.c (2026-11-19-10-sub-r23w-asm)
   sha256 3131ba6ce52619a70fd697c12df6ce15b0df07ab4801545fe99e86ef6e816881 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
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
        ram_451f8 = (unsigned int)Voice_VibratoDepth_Table[n = v[14]] << 8 | 0x80;
        ram_451fa = (unsigned int)Voice_VibratoDepth_Table[n] << 8;
        for (q = Voice_Query_PartVoices(part) + 5; *q < 0x40; q++)
            if (n == (*(unsigned char **)&ram_4308e[*q][0x1f])[14])
                ToneGen_WriteLevelPair(*q, ram_451cc);
    }
}
