/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_15b.c (2026-11-16-106-sub-r15)
   sha256 66164b1cba1f65710cc1f15e377a49a501d9d6208ea26ea566d807fd9a7b9891 (name+funcs); compiled at -Xr */
struct crec { unsigned char b[80]; };
struct ctone { unsigned char pad[19111]; struct crec rec[1]; };
extern struct ctone *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255), (unsigned char *)&ram_4531c->rec[e],
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}
