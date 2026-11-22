/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_36r1m301a.c (2026-11-22-25-p6-r92)
   sha256 1f5c06ff58a330813dc7f7fd778f964be7055294b728934cb983cebcd805404b (tar-sha256); compiled at -Xr */
extern void MIDI_PostSendStub(void);
extern void SubCPU_SendSystemRecord();
extern void MIDI_SendControlChange();
extern int SndParam_LookupViaEncode();
extern int SndParam_LookupReadOnly();
void SubCPU_SetPolyphonyModeAndResendVolumes(unsigned char m)
{
  int i;

  m = m ? 1 : 2;
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
