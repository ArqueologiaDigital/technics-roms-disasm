/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/note_voice_mapping_m301_xr.c (2026-11-16-92-p6-r18)
   sha256 f171a1d80d35d3a46187d02345a2dcd97690760b07c76139a3e594dbcd6cd46c (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
void MIDI_SendControlChange(unsigned char ch, unsigned char cc, unsigned char v)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xb0; b[2] = ch; b[3] = cc; b[4] = v;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}
