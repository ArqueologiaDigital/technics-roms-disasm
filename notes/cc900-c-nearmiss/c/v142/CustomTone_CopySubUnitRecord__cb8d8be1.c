/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_R_17c.c (2026-11-16-126-sub-r17)
   sha256 cb8d8be11508728097d9e78ae3bf4fbe5f7b1c76f6a92dd24928a8442d7e7268 (name+funcs); compiled at -Xr */
extern unsigned char *ram_4531c;
extern unsigned long *ToneDB_RootPtr;
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned int *d, unsigned int n);
extern unsigned char *WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
void CustomTone_CopySubUnitRecord(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FindVelSplit(a, b, c, d, 255),
                             (unsigned int *)&((unsigned char *)(unsigned long)(ram_4531c + ((int)d * 80 + (int)a * 11)))[19169],
                             ((unsigned int *)ToneDB_RootPtr)[120]);
}
