/* helper Q, round 20r1, module 253 (sequencer/accompaniment_engine.s). */
/* cc900-module: DrumKit_SendProgramChange */

extern unsigned char __near CURRENT_TITLE;
extern void DrumKit_SendProgramChange(void);

void RhythmConfig_InlineCode2_Data(void)
{
  if (CURRENT_TITLE != 180)
    DrumKit_SendProgramChange();
}
