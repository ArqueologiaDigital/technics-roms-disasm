/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/system_handlers.c (2026-11-16-38-p6-r6)
   sha256 afe344179687cdc9a4a02f91d96a43303f329e90b45293f9e3de325cebbce998 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
typedef unsigned char *ucp;
extern unsigned int __near INTERCPU_XFER_COUNT;
extern ucp __near INTERCPU_XFER_PTR;
extern unsigned char INTER_CPU_COMM_LATCHES;
void Audio_DMA_Transfer(void)
{
    unsigned long i, n;
    unsigned char d;
    n = INTERCPU_XFER_COUNT;
    if (INTERCPU_XFER_COUNT == 0) n = 0x10000;
    for (i = 0; i < n; i++) {
        INTER_CPU_COMM_LATCHES = *INTERCPU_XFER_PTR++;
        d = 0;
        do d++; while (d < 3);
    }
}
