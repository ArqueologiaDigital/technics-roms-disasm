/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int SndParam_LookupReadOnly(long);
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
extern int SndParam_LookupViaEncode(int, int);
extern void SndParam_FetchOscTableEntry(unsigned char *);
extern unsigned char __near CURRENT_TITLE;

unsigned char Note_CheckTransposeRange(unsigned char a, unsigned char c)
{
  unsigned char r = 0;
  if (SndParam_LookupReadOnly(0xc0L) == 1) {
    if (c == 0x78) r = 1; else r = 0;
  } else {
    if ((a & 0xf0) == 0xf0) r = 1; else r = 0;
  }
  return r;
}

void Rhythm_DispatchCCCommand(unsigned char a, unsigned char c)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0x90; b[2] = 0x19; b[3] = a; b[4] = c;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

unsigned char SelectTone_Continue_Prologue(unsigned char a)
{
  unsigned char b[6];
  if (CURRENT_TITLE == 246) {
    b[3] = SndParam_LookupViaEncode(0, 0);
    b[4] = SndParam_LookupViaEncode(0, 0x20);
    b[2] = 0;
    SndParam_FetchOscTableEntry(b);
    a = b[0] + 0xf0;
  }
  return a;
}
