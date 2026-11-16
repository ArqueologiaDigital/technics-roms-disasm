/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_14b.c (2026-11-16-101-sub-r14)
   sha256 bbeccd0d4360f3ac4a49496bd3e48bc2c26a024abdf4b72a929927d46ea7b73b (name+funcs); compiled at -Xr */
extern unsigned long ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255),
                             (unsigned char *)(ram_4531c + (e * 80 + 19111)),
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}
