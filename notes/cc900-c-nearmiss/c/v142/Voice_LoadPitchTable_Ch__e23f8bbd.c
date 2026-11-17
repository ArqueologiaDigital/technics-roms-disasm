/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_V_18b.c (2026-11-17-7-sub-r18)
   sha256 e23f8bbda13185568e9ea1e50b00b3980e963e23e491a0d490f247ed0b2500bf (name+funcs); compiled at -Xr */
extern unsigned char ram_413c3[];
extern unsigned char ram_413c5[];
extern unsigned int ram_451cc[];
extern unsigned int ram_45208;
extern unsigned int ram_4520c;
extern unsigned char Voice_PitchDepth_Scale[];
extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
void Voice_LoadPitchTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = DSP_AlgoType_Dispatch2(ch, 1);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x2c) {
        ram_45208 = 0x2c;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = 0x2c;
    } else {
        ram_45208 = v;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 1);
    v = v * (unsigned long)Voice_PitchDepth_Scale[depth];
    v >>= 8;
    ram_4520c = v;
    *(unsigned int *)&ram_413c3[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 13, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56(list[i] & 0xff, ram_451cc);
}
