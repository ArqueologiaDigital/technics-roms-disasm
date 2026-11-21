/* helper Q, round 20r1, module 301 (audio/note_voice_mapping.s).  The ROM loads WA / BC / DE as words for
   SubCPU_SendSystemRecord, whose built definition takes chars: the caller presumably had no prototype (K&R call). */
/* cc900-module: SubCPU_SendSystemRecord */

extern void SubCPU_SendSystemRecord();
extern void MIDI_PostSendStub(void);

void MIDI_SendAllVoicesPitchUpdate(void)
{
  SubCPU_SendSystemRecord(80, 146, 0);
  MIDI_PostSendStub();
}
