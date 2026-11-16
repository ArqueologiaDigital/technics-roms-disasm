/* Functions of core/12_dsp2_init.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
extern unsigned char __near ram_4369[];
extern int DSP_RingBuf_Read(struct ring2k *);

/* cc900-module: DSP_RingBuf_Read */
void DSP_Cmd_DequeueHeader(struct ring2k *r)
{
    ram_4369[0] = DSP_RingBuf_Read(r);
    ram_4369[1] = DSP_RingBuf_Read(r);
    ram_4369[2] = DSP_RingBuf_Read(r);
    ram_4369[3] = DSP_RingBuf_Read(r);
    ram_4369[4] = DSP_RingBuf_Read(r);
    ram_4369[5] = DSP_RingBuf_Read(r);
    ram_4369[6] = DSP_RingBuf_Read(r);
}

void DSP_RingBuf_Skip(struct ring2k *r)
{
    while (DSP_RingBuf_Read(r) >= 0) {
    }
    r->w = r->r;
}
