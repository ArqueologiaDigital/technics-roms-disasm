/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ApplyProgramChangeAs_LoadDRAM2 ApplyProgramChange_LoadDRAM FetchOscTableEntry_Prologue SoundRam_IdentifyImage */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char CHORD_NOTE_COUNT;
extern unsigned int ram_cec3;
extern unsigned int ram_cedb;
extern unsigned char ram_ce55;
extern void InitPartAllocState_Block4(void);
extern unsigned int __near ram_cdca;
extern unsigned char __near ram_ce16;
extern void Voice_ResetSearchState(void);

void InitPartAllocState_Block4(void)
{
  CHORD_NOTE_COUNT = 0;
  ram_cec3 = 0;
  ram_cedb = 0;
  ram_ce55 = 0;
}

void Voice_ResetSearchState(void)
{
  ram_cdca = 0;
  ram_ce16 = 0;
}
