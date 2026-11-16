/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

long *TableData_ROM_Verify(long *p, long *end)
{
    if (*p == -1) do {
        p += 16;
        if (p == end) return 0;
    } while (*p == -1);
    return p;
}

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
