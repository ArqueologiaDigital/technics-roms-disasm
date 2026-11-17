/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18b.c (2026-11-17-7-sub-r18)
   sha256 9db4bd630ae5363516e81e0b25f0380c9790ffacf02065aae572215e2138f5b7 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
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
    unsigned int *a2;
    unsigned char *p;
    unsigned char k;
    z = P(v, 31);
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned int *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    p = *(unsigned char **)a1;
    p += ToneDB_RelBase;
    k = a1[(int)WaveSel_KeyTable_Lookup(p, SW(v, 6)) + 4];
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
