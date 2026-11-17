/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr */
extern unsigned int ram_451cc[];
extern int ram_4520a;
extern int ram_4520e;
extern int DSP_AlgoType_Dispatch1(int, int);
extern int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParams_56b(int, unsigned int *);
void Voice_LoadFilterTable_All(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_4520a = DSP_AlgoType_Dispatch2(ch, 0);
    ram_4520e = DSP_AlgoType_Dispatch1(ch, 0);
    list = Voice_BuildOutputList(ch, 12, 0);
    i = 0;
    while ((list[i] & 0xff) < 0x80) {
        ToneGen_WriteExtParams_56b((unsigned char)list[i], ram_451cc);
        i++;
    }
}
