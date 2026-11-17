/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_F_rb12.c (2026-11-16-101-sub-r14)
   sha256 516712f592005825a8b43edf47d7121a6bd15a0ae3ab28e49c4c2b53dd3cded5 (name+funcs); compiled at -Xr */
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);
int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                            unsigned int base, int unused)
{
    int st;
    unsigned int v;
    unsigned int w;

    w = *DSP_TableWalk_Search(tbl, 0x78, type, &st) & 0xff;
    v = sub * 3 + w;
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
