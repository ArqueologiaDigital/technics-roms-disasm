/* Phase 6, helper B, round 10, module 234 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   Part_InitVoiceDefaults, which calls Part_WriteByte, Part_WriteWord and SeqStatus_CheckBit2 with calr.
   The callers of the song-slot accessors widen every argument to int (extz before each call): the accessors are
   declared without a prototype, so the default argument promotions apply. */
/* cc900-module: Part_WriteByte Part_WriteWord SeqStatus_CheckBit2 */

extern void Part_WriteByte();
extern void Part_WriteWord();
extern unsigned char Boot_ReadFDCStatus(void);
extern unsigned char SeqStatus_CheckBit2(void);

/* Writes the defaults of song slot a's header: 0x5a x4, 0, 1, 8, 0, the region byte at +8, the words at
   +0x14..+0x1b, twelve zero bytes from +0x42 and +0xbd = 0xff when bit 2 of PANEL_GM+3 is set, else 0. */
void Part_InitVoiceDefaults(unsigned char a)
{
  unsigned int i;
  Part_WriteByte(a, 0, 0x5a);
  Part_WriteByte(a, 1, 0x5a);
  Part_WriteByte(a, 2, 0x5a);
  Part_WriteByte(a, 3, 0x5a);
  Part_WriteByte(a, 4, 0);
  Part_WriteByte(a, 5, 1);
  Part_WriteByte(a, 6, 8);
  Part_WriteByte(a, 7, 0);
  Part_WriteByte(a, 8, Boot_ReadFDCStatus());
  Part_WriteWord(a, 0x14, 0);
  Part_WriteWord(a, 0x16, 0x100);
  Part_WriteWord(a, 0x18, 0x2e);
  Part_WriteWord(a, 0x1a, 0x520);
  i = 0;
  do { Part_WriteByte(a, i + 0x42, 0); i++; } while (i < 12);
  if (SeqStatus_CheckBit2() == 0) Part_WriteByte(a, 0xbd, 0);
  else Part_WriteByte(a, 0xbd, 0xff);
}
