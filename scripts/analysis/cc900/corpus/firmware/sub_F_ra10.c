/* spelling 10: k declared after p, p = call */
/* lane_sub round 14, idiom probe (XHL -> XDE copy), DSP_TuneOffset (KN5000 sub-CPU payload v1.42, core/14_dsp_control_routines.s); written by
   notes/cc900-c-subcpu-2026-11-16/gen_r14_probes.py.  Only the spelling of the DSP_TableWalk_Search call varies. */

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern unsigned char *DSP_TableWalk_Search(void *p, unsigned int key, unsigned int len, int *out);

int DSP_TuneOffset(long P, int chip, unsigned char *tbl, unsigned int mode, int flag)
{
    int st;
    unsigned int v;
    unsigned char *p;
    unsigned int k = 0x79;

    p = DSP_TableWalk_Search(tbl, k, mode, &st);
    v = *p;
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
