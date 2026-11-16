/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct vs { unsigned char pad[8]; unsigned long v8; unsigned long v12; };
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd1c;
extern unsigned char __near ram_bd04;
extern unsigned char __near ram_bd10;
extern struct vs __near ram_bcbc;
extern struct vs __near ram_bcdc;

void MidiSeq_UpdateVolumeScale(void)
{
    unsigned long v;
    struct vs *q;
    unsigned char *p = &ram_bd1c;
    if (*p & 0x80) return;
    if (ram_bd18 & 0x40) {
        q = &ram_bcbc;
        v = q->v8 >> 5;
        q->v12 = v;
        ram_bd04 = 160;
    } else {
        q = &ram_bcdc;
        v = q->v8 >> 5;
        q->v12 = v;
        ram_bd10 = 160;
    }
    if (v != 0) *p |= 0x80;
}
