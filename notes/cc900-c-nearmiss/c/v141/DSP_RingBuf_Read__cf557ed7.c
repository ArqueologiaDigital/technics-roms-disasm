/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/dsp2_init_ae_21a.c (2026-11-18-22-sub-r21d-staged)
   sha256 cf557ed788075e35354dc8d1f3c83536c120cc016d4947d311464857e4167f1d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
int DSP_RingBuf_Read(unsigned char *r)
{
    unsigned int i;
    int c;
    unsigned int u;
    if ((*(unsigned int *)((r) + (4))) != 0) {
        i = (*(unsigned int *)((r) + (2)))++ & 0x7ff;
        u = *((unsigned long)i + 6 + r);
        c = u;
        (*(unsigned int *)((r) + (4)))--;
    } else
        c = -1;
    return c;
}
