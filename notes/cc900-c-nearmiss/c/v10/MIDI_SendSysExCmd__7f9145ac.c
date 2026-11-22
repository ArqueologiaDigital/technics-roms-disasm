/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_36r1m301b.c (2026-11-22-25-p6-r92)
   sha256 7f9145aca6646993c81a03a6fe57cdbb0a713025d165f8008298f1ba530be620 (tar-sha256); compiled at (no flags) */
extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
void MIDI_SendSysExCmd(unsigned char cmd)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xf0; b[2] = 0x50; b[3] = 0x87; b[4] = cmd;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}
