/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_8b.c (2026-11-16-82-sub-r8)
   sha256 09f3a845bbb5aa4e74311adad2cc93f6921ff52351e467e9009b30eedd2a75fa (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[][11];
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *WaveSel_StageA1_FromPatchBlock();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c), &ram_44fce[c][426],
                             *(unsigned int *)(ToneDB_RootPtr + 234));
}
