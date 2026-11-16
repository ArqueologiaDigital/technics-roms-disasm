/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out);
int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                            unsigned int base, unsigned int len);
int DSP_OscAlgoSelect(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                      unsigned int base, unsigned int len);

int DSP_AlgoDescriptor_Emit(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                            unsigned int base, unsigned int len)
{
    int st;
    unsigned int v;
    int k;
    unsigned char *p;
    p = tbl;
    k = 0x78;
    p = DSP_TableWalk_Search(p, k, len, &st);
    v = (*p & 0xff) + sub * 3;
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

int DSP_OscAlgoSelect(unsigned int a, unsigned int sub, int chip, unsigned char *tbl, unsigned int type,
                      unsigned int base, unsigned int len)
{
    int st;
    unsigned int v;
    int k;
    unsigned char *p;
    p = tbl;
    k = 0x78;
    p = DSP_TableWalk_Search(p, k, len, &st);
    v = (*p & 0xff) + sub * 3;
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
