/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_9a.c (2026-11-16-86-sub-r9)
   sha256 9e10bd7bedff2a73ff847ad14ce649a21986182a96e80f8e7b4788049a6affb6 (name+funcs); compiled at -Xr */
extern unsigned char ram_44fce[];
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *WaveSel_StageA1_FromPatchBlock();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c),
                             (unsigned char *)((long)((int)c * 11 + 426) + (unsigned long)ram_44fce),
                             *(unsigned int *)(ToneDB_RootPtr + 234));
}
