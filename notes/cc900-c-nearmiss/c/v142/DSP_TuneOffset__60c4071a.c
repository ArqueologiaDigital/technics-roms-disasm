/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_ib16.c (2026-11-16-99-sub-r13-idioms)
   sha256 60c4071a9de131f8da38580044da3a780e9c74e301f1e1479a6e7221c82a821b (name+funcs); compiled at -Xr */
extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);
int DSP_TuneOffset(long P, int chip, unsigned char *tbl, unsigned int mode, int flag)
{
    int st;
    unsigned int v;

    v = *DSP_TableWalk_Search(tbl, (0x78 + 1), mode, &st);
    if (flag != 0) {
        switch (mode) {
        case 0:
            v--;
            break;
        case 1:
            v++;
            break;
        }
    }
    st = DSP_DispatchCommand(1, chip);
    st = DSP_DispatchData(1, chip);
    st = DSP_DispatchData(0x60, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData((unsigned char)(((v >> 4) & 0xf) + 0x10), chip);
    st = DSP_DispatchData((unsigned char)((v << 4) & 0xf0), chip);
    st = DSP_DispatchData(0, chip);
    st = DSP_DispatchData(0xa, chip);
    st = DSP_DispatchData((unsigned char)((P >> 17) & 0x7f), chip);
    st = DSP_DispatchData((unsigned char)((P >> 9) & 0xff), chip);
    st = DSP_DispatchData((unsigned char)((P >> 1) & 0xff), chip);
    st = DSP_DispatchData((unsigned char)(((P << 7) & 0x80) + 0x15), chip);
    st = DSP_DispatchCommand(3, chip);
    return st;
}
