/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_m298_xr.c (2026-11-16-68-p6-r12)
   sha256 470d2ac3f2e29c823fbcf47f0e2c72c696edd29d2931c2c99ee497d781e25f2d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
void Rhythm_DispatchCCCommand(unsigned char a, unsigned char c)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0x90; b[2] = 0x19; b[3] = a; b[4] = c;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}
