/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18a.c (2026-11-17-7-sub-r18)
   sha256 28995d12564daee79c182a1ebc86ab804043dda38b11687ee466a817e53c36e2 (name+funcs); compiled at -Xr */
extern unsigned long ToneDB_RelBase;
unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k);
void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned long t, int i);
void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned long t, int i);
void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned long t, int i);
void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned long t, int i);
void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned long t, int i);
void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned long t, int i);
void WaveSel_StageB_Build_Reg040(unsigned char *v)
{
    unsigned char *z;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char *p;
    unsigned char k;
    z = (*(unsigned char **)((v) + (31)));
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned char *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    p = (unsigned char *)*(unsigned long *)a1;
    p += ToneDB_RelBase;
    k = a1[(int)WaveSel_KeyTable_Lookup(p, (*(int *)((v) + (6)))) + 4];
    if (z[0] & 0x40) {
        if (z[0] & 0x80) {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S15(v, (unsigned long)a2, k);
            else WaveSel_Emit_ZoneRecord_S12(v, (unsigned long)a2, k);
        } else {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S13(v, (unsigned long)a2, k);
            else WaveSel_Emit_ZoneRecord_S10(v, (unsigned long)a2, k);
        }
    } else {
        if (z[0] & 0x80) WaveSel_Emit_ZoneRecord_S6(v, (unsigned long)a2, k);
        else WaveSel_Emit_ZoneRecord_S4(v, (unsigned long)a2, k);
    }
}
