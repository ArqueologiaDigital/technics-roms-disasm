/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7a.c (2026-11-16-79-sub-r7)
   sha256 f1451e8e2dd7ff70de4b56c6ae1a6bdc1104d403c6e642816ff3f60de709dfc2 (name+funcs); compiled at -Xr */
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
    v = (unsigned long)depth * DSP_AlgoType_Dispatch2(ch, 1) >> 8;
    if (v < 0x2c) {
        ram_45208 = 0x2c;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = 0x2c;
    } else {
        ram_45208 = (unsigned int)v;
        *(unsigned int *)&ram_413c5[ch * 0x11f] = v;
    }
    v = (unsigned long)Voice_PitchDepth_Scale[depth] * DSP_AlgoType_Dispatch1(ch, 1) >> 8;
    ram_4520c = (unsigned int)v;
    *(unsigned int *)&ram_413c3[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 13, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56(list[i] & 0xff, ram_451cc);
}
