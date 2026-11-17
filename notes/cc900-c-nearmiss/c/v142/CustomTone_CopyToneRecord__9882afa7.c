/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_15c.c (2026-11-16-106-sub-r15)
   sha256 9882afa7f896ea4195aabe306b21db718bacce0972ccd5e0cd19826ec002366e (name+funcs); compiled at -Xr */
struct ctone { unsigned char pad[19111]; unsigned char rec[1][80]; };
extern struct ctone *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255), &ram_4531c->rec[e][0],
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}
