/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/note_voice_mapping_xr.c (2026-11-16-55-p6-r10)
   sha256 7f9dc272f0ae7c42ec7e47f66d37f8670ad846663da684051feaa5787610a128 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
void Rhythm_DispatchCCCommand(unsigned char a, unsigned char c)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0x90; b[2] = 0x19; b[3] = a; b[4] = c;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}
