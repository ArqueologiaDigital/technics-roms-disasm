/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_envelopes_and_channels_b_callnames.c (2026-11-16-89-sub-staged3)
   sha256 b1b32a5865f529d67c62066cf7a554ba5f73e4f91bb000e15e4ed9aa657f0c40 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: ToneGen_WriteExtParam_1C0_Sgl=ToneGen_WriteExtParam_1C0_Single */
extern unsigned int ram_451cc[];
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern int ram_45204;
extern int DSP_ChanFreq_WritePacket1(int);
extern void ToneGen_WriteExtParam_1C0_Sgl(int, unsigned int *);
void Voice_DSP_SimpleCopy(unsigned char ch)
{
    unsigned int *list;
    unsigned int i;
    ram_45204 = DSP_ChanFreq_WritePacket1(ch);
    list = Voice_BuildOutputList(ch, 16, 0);
    for (i = 0; (list[i] & 0xff) < 0x40; i++)
        ToneGen_WriteExtParam_1C0_Sgl(list[i] & 0xff, ram_451cc);
}
