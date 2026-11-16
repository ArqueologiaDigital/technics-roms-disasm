/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
extern void MIDI_SendChannelPressure(unsigned char ch, unsigned char v);
extern void MIDI_SendControlChange(unsigned char ch, unsigned char cc, unsigned char v);
extern void MIDI_SendPitchBend(unsigned char ch, unsigned int v);

void MIDI_SendChannelPressure(unsigned char ch, unsigned char v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xd0; b[2] = ch; b[3] = 0; b[4] = v;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

void MIDI_SendControlChange(unsigned char ch, unsigned char cc, unsigned char v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xb0; b[2] = ch; b[3] = cc; b[4] = v;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

void MIDI_SendPitchBend(unsigned char ch, unsigned int v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xe0; b[2] = ch;
  b[3] = v & 0x7f;
  b[4] = (v & 0x3fff) >> 7;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}
