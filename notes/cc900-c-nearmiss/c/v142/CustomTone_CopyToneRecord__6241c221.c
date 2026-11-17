/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_14c.c (2026-11-16-101-sub-r14)
   sha256 6241c22152c9e442038de0e7e597e2e4f496a9449560f5f520c5051b26962272 (name+funcs); compiled at -Xr */
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255),
                             (unsigned char *)((unsigned long)ram_4531c + ((int)e * 80 + 19111)),
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}
