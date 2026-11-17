/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/voice_envelopes_and_channels_b_callnames.c (2026-11-16-89-sub-staged3)
   sha256 b1b32a5865f529d67c62066cf7a554ba5f73e4f91bb000e15e4ed9aa657f0c40 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_Write_ExtParam_05C0_Stb=ToneGen_Write_ExtParam_05C0_Strobe */
extern unsigned int ram_451cc[];
extern int ram_45208;
extern int ram_4520a;
extern int DSP_AlgoType_Dispatch2(int, int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_Write_ExtParam_05C0_Stb(int, unsigned int *);
extern void ToneGen_WriteExtParams_56_Alt(int, unsigned int *);
void Voice_DSP_OutputConfig2(unsigned char ch, unsigned char mode)
{
    unsigned int *list;
    unsigned int i;
    if (mode == 0) {
        ram_4520a = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((unsigned int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_Write_ExtParam_05C0_Stb(list[i] & 0xff, ram_451cc);
    } else {
        ram_45208 = DSP_AlgoType_Dispatch2(ch, mode);
        list = Voice_BuildOutputList(ch, (unsigned char)((unsigned int)mode | 12), 0);
        for (i = 0; (list[i] & 0xff) < 0x80; i++)
            ToneGen_WriteExtParams_56_Alt(list[i] & 0xff, ram_451cc);
    }
}
