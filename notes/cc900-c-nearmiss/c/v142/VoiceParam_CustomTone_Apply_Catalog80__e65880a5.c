/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_10b.c (2026-11-16-90-sub-r10)
   sha256 e65880a5240b9cbdd01df6fe1334ebb448aa232215a8d0695d965aaae80c68e2 (name+funcs); compiled at -Xr
   cc900-name: CustomTone_Apply_Catalog80=VoiceParam_CustomTone_Apply_Catalog80 */
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
extern void CustomTone_CopyToneRecord();
extern void CustomTone_CopySubUnitRecord();
void CustomTone_Apply_Catalog80(unsigned int idx)
{
    unsigned char *rec;
    struct e16 *tbl;
    unsigned char e;
    unsigned char k;
    unsigned char *s;
    e = ram_4531c[29351];
    rec = ram_4531c + ((int)e * 80 + 19111);
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 128));
    CustomTone_CopyToneRecord(tbl[idx].a, tbl[idx].b, e);
    for (k = 0; k < 2; k++) {
        s = rec + ((int)k * 21 + 16);
        CustomTone_CopySubUnitRecord(k, s[1], s[2], e);
        s[2] &= 15;
        s[2] |= 80;
    }
    ram_4531c[(int)e * 2 + 18855] = tbl[idx].a;
    ((unsigned char *)(unsigned long)(ram_4531c + ((int)e * 2 + 18855)))[1] = (tbl[idx].b & 31) | 96;
}
