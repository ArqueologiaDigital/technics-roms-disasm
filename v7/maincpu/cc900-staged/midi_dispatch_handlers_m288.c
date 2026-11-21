/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char ram_340f9;
extern unsigned char __near ram_b750;
extern void SndParam_ApplyAndSync(void);
extern void SoundMode_SetChorusType(void);

void SoundMode_SetChorusType(void)
{
  switch (ram_340f9) {
  default:
    return;
  case 1:
    ram_b750 = 91;
    break;
  case 2:
    ram_b750 = 92;
    break;
  case 3:
    ram_b750 = 93;
    break;
  }
  SndParam_ApplyAndSync();
}
