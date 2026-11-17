/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr
   cc900-name: ToneGen_WriteExtParam_1C0_Sgl=ToneGen_WriteExtParam_1C0_Single */
extern unsigned int ram_451cc[];
extern int ram_45204;
extern int DSP_ChanFreq_WritePacket1(int);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void ToneGen_WriteExtParam_1C0_Sgl(int, unsigned int *);
void Voice_DSP_SimpleCopy(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45204 = DSP_ChanFreq_WritePacket1(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    i = 0;
    while ((list[i] & 0xff) < 0x40) {
        ToneGen_WriteExtParam_1C0_Sgl((unsigned char)list[i], ram_451cc);
        i++;
    }
}
