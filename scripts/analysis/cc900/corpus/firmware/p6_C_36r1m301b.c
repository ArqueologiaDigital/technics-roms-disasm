/* Probe round 36r1, helper C, form b (the mode ternary spelled m == 0 ? 2 : 1): audio/note_voice_mapping.s (module 301), the xr_screen.py shape.
   MIDI_SendSysExCmd(cmd): the 5-byte record 04 f0 50 87 cmd, sent (same shape as the built SubCPU_SendSystemRecord).
   SendSysExCmd_Data: system record (80, 133, 0), then the post-send stub (a tail call).
   SubCPU_SetPolyphonyModeAndResendVolumes(m): mode = m ? 1 : 2 to system record (0x7f, 9), then every part's
   volume (CC 7, 0 when lookup 8 says so) re-sent for parts 0..22 and the two extra parts 23 / 24.
   The module's callees are called without prototypes (int arguments in WA / BC / DE). */
/* cc900-module: SubCPU_SendSystemRecord MIDI_SendControlChange */

extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
extern void SubCPU_SendSystemRecord();
extern void MIDI_SendControlChange();
extern int SndParam_LookupViaEncode();
extern int SndParam_LookupReadOnly();
extern void MIDI_SendSysExCmd(unsigned char);
extern void SendSysExCmd_Data(void);
extern void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned char);

void MIDI_SendSysExCmd(unsigned char cmd)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xf0; b[2] = 0x50; b[3] = 0x87; b[4] = cmd;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}

void SendSysExCmd_Data(void)
{
  SubCPU_SendSystemRecord(80, 133, 0);
  MIDI_PostSendStub();
}

void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned char m)
{
  int i;

  m = (m == 0) ? 2 : 1;
  SubCPU_SendSystemRecord(0x7f, 9, m);
  i = 0;
  if (i <= 22)
    do {
      if (SndParam_LookupViaEncode(i, 8) == 1)
        m = 0;
      else
        m = SndParam_LookupViaEncode(i, 7);
      MIDI_SendControlChange(i, 7, m);
      i++;
    } while (i <= 22);
  if (SndParam_LookupReadOnly(0x2880bL) == 1)
    m = 0;
  else
    m = SndParam_LookupReadOnly(0x28801L);
  MIDI_SendControlChange(23, 7, m);
  MIDI_SendControlChange(24, 7, m);
  MIDI_PostSendStub();
}
