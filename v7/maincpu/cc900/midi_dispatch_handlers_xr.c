/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct vs { unsigned char pad[8]; unsigned long v8; unsigned long v12; };
extern unsigned char __near ram_bc7c;
extern unsigned char __near ram_bc80;
extern unsigned char __near ram_bc68;
extern unsigned char __near ram_bc74;
extern struct vs __near ram_bc20;
extern struct vs __near ram_bc40;

void MidiSeq_UpdateVolumeScale(void)
{
    unsigned long v;
    struct vs *q;
    unsigned char *p = &ram_bc80;
    if (*p & 0x80) return;
    if (ram_bc7c & 0x40) {
        q = &ram_bc20;
        v = q->v8 >> 5;
        q->v12 = v;
        ram_bc68 = 160;
    } else {
        q = &ram_bc40;
        v = q->v8 >> 5;
        q->v12 = v;
        ram_bc74 = 160;
    }
    if (v != 0) *p |= 0x80;
}
