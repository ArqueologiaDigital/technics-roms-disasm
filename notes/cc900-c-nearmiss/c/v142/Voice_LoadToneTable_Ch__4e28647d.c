/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17b.c (2026-11-16-126-sub-r17)
   sha256 4e28647d6d2b9926d95f4c28b496455f9e4be5e2370c5e8065683c79b3734760 (name+funcs); compiled at -Xr */
extern unsigned char ram_413c9[];
extern unsigned int ram_451cc[];
extern unsigned int ram_45206;
extern unsigned int DSP_ChanFreq_WritePacket2(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_15_Alt(int, unsigned int *);
void Voice_LoadToneTable_Ch(unsigned char ch, unsigned char depth)
{
    unsigned long v;
    unsigned int *list;
    unsigned int i;
    v = DSP_ChanFreq_WritePacket2(ch);
    v = v * (unsigned long)depth;
    v >>= 8;
    if (v < 0x1c) {
        ram_45206 = 0x1c;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = 0x1c;
    } else {
        ram_45206 = (unsigned int)v;
        *(unsigned int *)&ram_413c9[ch * 0x11f] = v;
    }
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParams_15_Alt(list[i] & 0xff, ram_451cc);
}
