/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_E_4a.c (2026-11-16-62-sub-r4)
   sha256 044dfcf0a071d4efe674c111b3e359fdaed2ba3a9ddeec0c55a36074808fc82d (name+funcs); compiled at -Xr */
/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_4a.c (2026-11-16-62-sub-r4)
   sha256 044dfcf0a071d4efe674c111b3e359fdaed2ba3a9ddeec0c55a36074808fc82d (name+funcs); compiled at -Xr */
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);
int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                            unsigned int base, int unused)
{
    int st;
    unsigned int v;

    v = sub * 3 + (*DSP_TableWalk_Search(tbl, 0x78, type, &st) & 0xff);
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)v++, chip);
    if (type != 0x63) {
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
        st = DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
        st = DSP_DispatchData(0, chip);
    } else {
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x20, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0, chip);
    }
    if (sub == 0) {
        st = DSP_DispatchData(8, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x80, chip);
        st = DSP_DispatchData(0xb4, chip);
        st = DSP_DispatchData(7, chip);
    } else {
        st = DSP_DispatchData((unsigned char)(((v >> 7) & 2) + 0xc), chip);
        st = DSP_DispatchData((unsigned char)((v >> 7) & 1), chip);
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(7, chip);
    }
    return st;
}
/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_4a.c (2026-11-16-62-sub-r4)
   sha256 044dfcf0a071d4efe674c111b3e359fdaed2ba3a9ddeec0c55a36074808fc82d (name+funcs); compiled at -Xr */
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);
int DSP_OscAlgoSelect(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                      unsigned int base, int unused)
{
    int st;
    unsigned int v;

    v = sub * 3 + (*DSP_TableWalk_Search(tbl, 0x78, type, &st) & 0xff);
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)v++, chip);
    st = DSP_DispatchData(8, chip);
    st = DSP_DispatchData(1, chip);
    st = DSP_DispatchData((unsigned char)(((type + a) >> 4) & 0xf), chip);
    st = DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
    st = DSP_DispatchData(0x21, chip);
    if (sub == 0) {
        st = DSP_DispatchData(8, chip);
        st = DSP_DispatchData(0, chip);
        st = DSP_DispatchData(0x80, chip);
        st = DSP_DispatchData(0xb4, chip);
        st = DSP_DispatchData(8, chip);
    } else {
        st = DSP_DispatchData((unsigned char)(((v >> 7) & 2) + 0xc), chip);
        st = DSP_DispatchData((unsigned char)((v >> 7) & 1), chip);
        st = DSP_DispatchData((unsigned char)(v * 2), chip);
        st = DSP_DispatchData(4, chip);
        st = DSP_DispatchData(8, chip);
    }
    return st;
}
/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_4a.c (2026-11-16-62-sub-r4)
   sha256 044dfcf0a071d4efe674c111b3e359fdaed2ba3a9ddeec0c55a36074808fc82d (name+funcs); compiled at -Xr */
unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    unsigned int w;
    int r;
    int *s;

    s = st;
    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        if (n == 0) {
            r = 0;
            *out = p + w;
            p += 2;
            goto done;
        }
        p += w;
        n--;
    }
    r = 2;
done:
    *s = r;
    return p;
}
/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_4a.c (2026-11-16-62-sub-r4)
   sha256 044dfcf0a071d4efe674c111b3e359fdaed2ba3a9ddeec0c55a36074808fc82d (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
struct pent { char pad[4]; unsigned char f[52]; };
struct pblk { char pad[8]; struct pent e[100]; };
extern struct bcfg ToneGen_WorkArea[];
extern unsigned char DSP_Eff9_Param_Descriptors[];
extern unsigned char DSP_Eff9_Param_Values[];
extern unsigned char DSP_EffA_Param_Descriptors[];
extern unsigned char DSP_EffA_Param_Values[];
extern unsigned char *DSP_Param_Block_Ptrs_A[];
extern unsigned char *DSP_Param_Block_Ptrs_B[];
extern void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, void *vals, int v,
                                     unsigned char *rec);
void DSP_WriteParameter(unsigned int slot, unsigned int type, int v, struct pblk *p)
{
    if (slot == 1 && (type == 9 || type == 10)) {
        switch (type) {
        case 9:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Eff9_Param_Descriptors, DSP_Eff9_Param_Values, v,
                                     p->e[slot].f);
            break;
        case 10:
            DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_EffA_Param_Descriptors, DSP_EffA_Param_Values, v,
                                     p->e[slot].f);
            break;
        }
    } else {
        DSP_ParameterWriteEngine(slot, ToneGen_WorkArea, DSP_Param_Block_Ptrs_B[type], DSP_Param_Block_Ptrs_A[type],
                                 v, p->e[slot].f);
    }
}
