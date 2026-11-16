/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);

void SubCPU_SendSystemRecord(unsigned char a, unsigned char c, unsigned char e)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xf0; b[2] = a; b[3] = c; b[4] = e;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

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
