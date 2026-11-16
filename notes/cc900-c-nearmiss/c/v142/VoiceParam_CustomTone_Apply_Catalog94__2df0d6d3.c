/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_C_12b.c (2026-11-16-97-sub-r12)
   sha256 2df0d6d3d26d94de233afd035f9ee3d322467b68071f35ded7d2853511d71ae0 (name+funcs); compiled at -Xr
   cc900-name: CustomTone_Apply_Catalog94=VoiceParam_CustomTone_Apply_Catalog94 */
extern unsigned char *ram_4531c;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
void CustomTone_Apply_Catalog94(unsigned int idx, unsigned char c)
{
    unsigned char e;
    struct e16 *tbl;
    unsigned char *rec;
    unsigned char hi;
    e = ram_4531c[29351];
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 148));
    rec = &((unsigned char *)(unsigned long)(ram_4531c + ((int)e * 80 + (int)(c & 15) * 11)))[19169];
    hi = (c & 0xf0) >> 4;
    rec[(int)hi * 2 + 3] = tbl[idx].a;
    ((unsigned char *)(unsigned long)(rec + ((int)hi * 2 + 3)))[1] = tbl[idx].b;
}
