/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_bc58;
extern unsigned char __near ram_bc40;
extern unsigned char __near ram_bc42;
extern unsigned char __near ram_bc44;
extern unsigned char __near ram_bc46;
extern unsigned char __near ram_bc48;
extern unsigned char __near ram_bc4a;
extern unsigned char __near ram_bc4c;
extern unsigned char __near ram_bc4e;
extern unsigned char __near ram_bc50;
extern unsigned char __near ram_bc52;
extern unsigned char __near ram_bc54;
extern unsigned char __near ram_bc56;
extern void MidiSeq_SyncToneStates_Upper(void);

void MidiSeq_SyncToneStates_Upper(void)
{
    if (ram_bc58 & 0x40) {
        ram_bc40 &= ~0x80;
        ram_bc42 = ram_bc40;
        ram_bc44 &= ~0x80;
        ram_bc46 = ram_bc44;
        ram_bc48 &= ~0x80;
        ram_bc4a = ram_bc48;
    } else {
        ram_bc4c &= ~0x80;
        ram_bc4e = ram_bc4c;
        ram_bc50 &= ~0x80;
        ram_bc52 = ram_bc50;
        ram_bc54 &= ~0x80;
        ram_bc56 = ram_bc54;
    }
}
