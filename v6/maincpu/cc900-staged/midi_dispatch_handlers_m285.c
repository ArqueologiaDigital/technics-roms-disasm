/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_bc58;
extern unsigned char __near ram_bc5c;
extern unsigned char __near ram_bc76;
extern unsigned char __near ram_bc78;
extern void MidiChan_SetStateMode(void);

void MidiChan_SetStateMode(void)
{
    if (ram_bc58 & 0x40) ram_bc76 = 1;
    else ram_bc76 = 2;
    if (ram_bc76 == ram_bc78) return;
    ram_bc5c |= 0x40;
    ram_bc78 = ram_bc76;
}
