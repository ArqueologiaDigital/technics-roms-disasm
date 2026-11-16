/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2b.c (2026-11-16-47-sub-r2)
   sha256 9aba00a0c3e557e6d713bd84f64750019cb84970fa0099d1aa9e45ad5763c846 (name+funcs); compiled at -Xr */
extern unsigned int ram_451cc[];
extern int ram_4520c;
extern int ram_4520e;
extern int DSP_AlgoType_Dispatch1(int, int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteReg0640(int, unsigned int *);
extern void ToneGen_WriteExtParam_600(int, unsigned int *);
void Voice_DSP_OutputConfig(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_4520e = DSP_AlgoType_Dispatch1(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)(mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteReg0640((unsigned char)list[i], ram_451cc);
    } else {
        ram_4520c = DSP_AlgoType_Dispatch1(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)(mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParam_600((unsigned char)list[i], ram_451cc);
    }
}
