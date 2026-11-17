/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17a.c (2026-11-16-126-sub-r17)
   sha256 4236702b3d6d2cd4a34bd2c4b4787b866c2680f5404a1df78ec1c7768ec2066d (name+funcs); compiled at -Xr */
extern unsigned long ToneDB_RelBase;
unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k);
void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, int i);
void WaveSel_StageB_Build_Reg040(unsigned char *v)
{
    unsigned char *z;
    unsigned char *a1;
    unsigned long a2;
    unsigned char k;
    z = (*(unsigned char **)((v) + (31)));
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = *(unsigned long *)(z + 5) + ToneDB_RelBase;
    k = a1[(int)WaveSel_KeyTable_Lookup((unsigned char *)*(unsigned long *)a1 + ToneDB_RelBase, (*(int *)((v) + (6)))) + 4];
    if (z[0] & 0x40) {
        if (z[0] & 0x80) {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S15(v, (unsigned char *)a2, k);
            else WaveSel_Emit_ZoneRecord_S12(v, (unsigned char *)a2, k);
        } else {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S13(v, (unsigned char *)a2, k);
            else WaveSel_Emit_ZoneRecord_S10(v, (unsigned char *)a2, k);
        }
    } else {
        if (z[0] & 0x80) WaveSel_Emit_ZoneRecord_S6(v, (unsigned char *)a2, k);
        else WaveSel_Emit_ZoneRecord_S4(v, (unsigned char *)a2, k);
    }
}
