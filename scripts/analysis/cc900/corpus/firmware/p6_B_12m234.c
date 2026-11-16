/* Phase 6, helper B, round 12, module 234 of v10's sequencer/sequencer_engine.s (-O3 -Xr):
   Part_InitVoiceDefaults (refined from round 10, which matched up to the region-byte call: Boot_ReadFDCStatus is
   called before the slot number is loaded, so its result goes through a temporary).  The song-slot accessors are
   declared without a prototype: every argument is widened to int, as the firmware's callers do. */
/* cc900-module: Part_WriteByte Part_WriteWord SeqStatus_CheckBit2 */

extern void Part_WriteByte();
extern void Part_WriteWord();
extern unsigned char Boot_ReadFDCStatus(void);
extern unsigned char SeqStatus_CheckBit2(void);

void Part_InitVoiceDefaults(unsigned char a)
{
  unsigned int i;
  unsigned char r;
  Part_WriteByte(a, 0, 0x5a);
  Part_WriteByte(a, 1, 0x5a);
  Part_WriteByte(a, 2, 0x5a);
  Part_WriteByte(a, 3, 0x5a);
  Part_WriteByte(a, 4, 0);
  Part_WriteByte(a, 5, 1);
  Part_WriteByte(a, 6, 8);
  Part_WriteByte(a, 7, 0);
  r = Boot_ReadFDCStatus();
  Part_WriteByte(a, 8, r);
  Part_WriteWord(a, 0x14, 0);
  Part_WriteWord(a, 0x16, 0x100);
  Part_WriteWord(a, 0x18, 0x2e);
  Part_WriteWord(a, 0x1a, 0x520);
  i = 0;
  do { Part_WriteByte(a, i + 0x42, 0); i++; } while (i < 12);
  if (SeqStatus_CheckBit2() == 0) Part_WriteByte(a, 0xbd, 0);
  else Part_WriteByte(a, 0xbd, 0xff);
}
