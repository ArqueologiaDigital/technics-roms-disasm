/* Functions of core/11_ringbuf_and_midi_dispatch.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct ring { unsigned int wr; unsigned int rd; unsigned int count; unsigned char data[4096]; };
extern struct ring __near MIDI_RingBuffer;
int RingBuf_ReadByte(struct ring *r);

int RingBuf_ReadByte_MidiRing(void) { return RingBuf_ReadByte(&MIDI_RingBuffer); }
