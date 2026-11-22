/* helper W, round 21r2, module 288 (midi/midi_dispatch_handlers.s), form a: SoundMode_SetChorusType.  Run r58
   (p6_Q_20r1m288a, cases 1 / 2 / 3 then `default: return;`) was byte-exact up to the layout: V4.23 placed the shared
   `jp SndParam_ApplyAndSync` right after case 1's store with cases 2 and 3 jumping back to it; the ROM keeps the
   three stores in order with the jp last (case 1 and 2 `jr` forward), the layout of the built twin
   SoundMode_SetReverbType (cc900/midi_dispatch_handlers_m288_b.c), whose default label comes FIRST.  Here the
   default (return) is written first, as in the twin.
   cc900-options: -O3 -Xr
*/

extern unsigned char ram_340f9;
extern unsigned char __near ram_b7ec;
extern void SndParam_ApplyAndSync(void);

void SoundMode_SetChorusType(void)
{
  switch (ram_340f9) {
  default:
    return;
  case 1:
    ram_b7ec = 91;
    break;
  case 2:
    ram_b7ec = 92;
    break;
  case 3:
    ram_b7ec = 93;
    break;
  }
  SndParam_ApplyAndSync();
}
