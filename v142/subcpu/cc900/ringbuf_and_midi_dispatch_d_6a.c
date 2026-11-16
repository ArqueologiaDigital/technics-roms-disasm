/* Functions of core/11_ringbuf_and_midi_dispatch.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct ring4k { unsigned int w, r, n; unsigned char buf[4096]; };
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern void DSP_FlushAllSlots(int, int);
extern int RingBuf_ReadByte(struct ring4k *);

/* cc900-module: DSP_FlushAllSlots RingBuf_ReadByte */
void DSP_FlushAllSlots_ForPart(unsigned char part)
{
    DSP_FlushAllSlots(ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
}

void RingBuf_SkipToEnd(struct ring4k *r)
{
    while (RingBuf_ReadByte(r) >= 0) {
    }
    r->w = r->r;
}
