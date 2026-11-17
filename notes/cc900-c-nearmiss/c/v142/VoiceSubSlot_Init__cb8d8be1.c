/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17c.c (2026-11-16-126-sub-r17)
   sha256 cb8d8be11508728097d9e78ae3bf4fbe5f7b1c76f6a92dd24928a8442d7e7268 (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
extern unsigned long *ToneDB_RootPtr;
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned int *d, unsigned int n);
extern unsigned char *WaveSel_StageA1_FromPatchBlock();
void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c),
                             ((unsigned int *)&ram_44fce[(int)(unsigned int)((int)c * 11 + 426)]),
                             ((unsigned int *)ToneDB_RootPtr)[117]);
}
