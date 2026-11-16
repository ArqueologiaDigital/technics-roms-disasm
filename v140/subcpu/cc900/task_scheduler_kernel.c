/* Functions of core/03_task_scheduler_kernel.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void RingBuf_Reset_1K(int a, int b, int *p)
{
    p[-5] = 0;
    p[-4] = 0;
    p[-2] = 0;
    p[-3] = 0;
    p[-1] = 0x3ff;
}

void RingBuf_Reset_256(int a, int b, int *p)
{
    p[-5] = 0;
    p[-4] = 0;
    p[-2] = 0;
    p[-3] = 0;
    p[-1] = 0xff;
}

void RingBuf_Reset_512(int a, int b, int *p)
{
    p[-5] = 0;
    p[-4] = 0;
    p[-2] = 0;
    p[-3] = 0;
    p[-1] = 0x1ff;
}
