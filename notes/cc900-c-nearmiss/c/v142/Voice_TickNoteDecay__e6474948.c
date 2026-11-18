/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AG_20a.c (2026-11-18-18-sub-r21a)
   sha256 e64749487a5b77e74adcadd02c8847171c6991e4cd15a61fe8c5172fc9c0813c (tar-sha256); compiled at -Xr */
extern unsigned char ram_4135e;
extern unsigned char ram_4135f;
extern unsigned char ram_430bb[];
extern unsigned int ram_451cc[];
extern void Voice_SetPanning(unsigned char *v);
extern void Voice_InitVoiceState(unsigned char slot);
extern void ToneGen_WriteVoiceParams(int ch, unsigned int *p);
extern void ToneGen_WriteSingleReg(int ch, unsigned int w);
void Voice_TickNoteDecay(void)
{
    unsigned char i;
    unsigned char buf[14];
    if (ram_4135e != 0) {
        ram_4135f--;
        if (ram_4135f == 0) {
            Voice_SetPanning(buf);
            if (buf[10] < 0x40) {
                i = buf[10];
                Voice_InitVoiceState(i);
                ToneGen_WriteVoiceParams(i, ram_451cc);
                ToneGen_WriteSingleReg(i, *(unsigned int *)&ram_430bb[i * 0x47]);
            }
            ram_4135e--;
            ram_4135f = 4;
        }
    }
}
