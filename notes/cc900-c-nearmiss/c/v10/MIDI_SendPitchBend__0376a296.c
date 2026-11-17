/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_4b.c (2026-11-16-40-p6-r8)
   sha256 0376a2964c573ce15297eb22e016ddee3a48777d9bcdc1cb9292bc07c50265c4 (tar-sha256); compiled at -Xr */
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
void MIDI_SendPitchBend(unsigned char ch, unsigned int v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xe0; b[2] = ch;
  b[3] = (unsigned char)v & 0x7f;
  b[4] = (unsigned char)((v & 0x3fff) >> 7);
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}
