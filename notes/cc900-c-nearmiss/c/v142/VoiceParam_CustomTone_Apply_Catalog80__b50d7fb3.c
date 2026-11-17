/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_10c.c (2026-11-16-90-sub-r10)
   sha256 b50d7fb3c2a89348b0e80a7c607cbdcf7719e0d5e239824739c765e50e6eeb8d (name+funcs); compiled at -Xr
   cc900-name: CustomTone_Apply_Catalog80=VoiceParam_CustomTone_Apply_Catalog80 */
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
extern void CustomTone_CopyToneRecord();
extern void CustomTone_CopySubUnitRecord();
void CustomTone_Apply_Catalog80(unsigned int idx)
{
    unsigned char k;
    unsigned char e;
    struct e16 *tbl;
    unsigned char *rec;
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
    (ram_4531c + ((int)e * 2 + 18855))[1] = (tbl[idx].b & 31) | 96;
}
