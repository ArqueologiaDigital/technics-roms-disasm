/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_11a.c (2026-11-16-94-sub-r11)
   sha256 ba7e976bde16b85fedfb252361581282074eaa7d79e997dbc6d1d538b6573ff9 (name+funcs); compiled at -Xr
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
    unsigned char v;
    rec = ram_4531c + ((int)(e = ram_4531c[29351]) * 80 + 19111);
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 128));
    CustomTone_CopyToneRecord(tbl[idx].a, tbl[idx].b, e);
    for (k = 0; k < 2; k++) {
        s = rec + ((int)k * 21 + 16);
        CustomTone_CopySubUnitRecord(k, s[1], s[2], e);
        s[2] &= 15;
        s[2] |= 80;
    }
    ram_4531c[(int)e * 2 + 18855] = tbl[idx].a;
    v = (tbl[idx].b & 31) | 96;
    ((unsigned char *)(unsigned long)(ram_4531c + ((int)e * 2 + 18855)))[1] = v;
}
