/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17b.c (2026-11-16-126-sub-r17)
   sha256 4e28647d6d2b9926d95f4c28b496455f9e4be5e2370c5e8065683c79b3734760 (name+funcs); compiled at -Xr */
extern unsigned char ram_413bf[];
extern unsigned char ram_413c1[];
extern unsigned int ram_451cc[];
extern unsigned int ram_4520a;
extern unsigned int ram_4520e;
extern unsigned char Voice_FilterDepth_Scale[];
extern unsigned int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
void Voice_LoadFilterTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = DSP_AlgoType_Dispatch2(ch, 0);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x1c) {
        ram_4520a = 0x1c;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = 0x1c;
    } else {
        ram_4520a = (unsigned int)v;
        *(unsigned int *)&ram_413c1[ch * 0x11f] = v;
    }
    v = DSP_AlgoType_Dispatch1(ch, 0);
    v = v * (unsigned long)Voice_FilterDepth_Scale[depth];
    v >>= 8;
    ram_4520e = (unsigned int)v;
    *(unsigned int *)&ram_413bf[ch * 0x11f] = v;
    list = Voice_BuildOutputList(ch, 12, 0);
    for (i = 0; (list[i] & 0xff) < 0x80; i++)
        ToneGen_WriteExtParams_56b(list[i] & 0xff, ram_451cc);
}
