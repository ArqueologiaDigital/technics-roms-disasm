/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_9a.c (2026-11-16-86-sub-r9)
   sha256 9e10bd7bedff2a73ff847ad14ce649a21986182a96e80f8e7b4788049a6affb6 (name+funcs); compiled at -Xr
   cc900-name: CustomTone_Apply_Catalog8C=VoiceParam_CustomTone_Apply_Catalog8C */
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
extern void CustomTone_CopySubUnitRecord();
void CustomTone_Apply_Catalog8C(unsigned int idx, unsigned char c)
{
    unsigned char e;
    struct e16 *tbl;
    unsigned char lo;
    unsigned char *rec;
    e = ram_4531c[29351];
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 140));
    lo = c & 15;
    rec = ram_4531c + ((int)e * 80 + (int)lo * 21);
    rec += 19127;
    CustomTone_CopySubUnitRecord(lo, tbl[idx].a, tbl[idx].b, e);
    rec[1] = tbl[idx].a;
    rec[2] = (tbl[idx].b & 15) | 80;
}
