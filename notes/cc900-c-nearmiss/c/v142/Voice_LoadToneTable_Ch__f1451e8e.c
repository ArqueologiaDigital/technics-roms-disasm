/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7a.c (2026-11-16-79-sub-r7)
   sha256 f1451e8e2dd7ff70de4b56c6ae1a6bdc1104d403c6e642816ff3f60de709dfc2 (name+funcs); compiled at -Xr */
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
    v = (unsigned long)depth * DSP_ChanFreq_WritePacket2(ch) >> 8;
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
