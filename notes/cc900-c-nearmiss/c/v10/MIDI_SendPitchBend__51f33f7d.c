/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4a.c (2026-11-16-40-p6-r8)
   sha256 51f33f7d2a542dcabaa0b35f2dc5bf07089f5d28b53e49e44f8cfe457d787e3c (tar-sha256); compiled at -Xr */
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
void MIDI_SendPitchBend(unsigned char ch, unsigned int v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xe0; b[2] = ch;
  b[3] = v & 0x7f;
  b[4] = (v & 0x3fff) >> 7;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}
