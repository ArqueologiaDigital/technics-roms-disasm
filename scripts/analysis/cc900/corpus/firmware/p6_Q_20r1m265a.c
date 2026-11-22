/* helper Q, round 20r1, module 265 (demo/file_demo_proc.s): feature-demo guard and presentation post. */

extern unsigned char __near ACTIVE_TITLE;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern char FDemo_LoadRegsAndPostEvent_Str_FEATURE[];
extern long ApPostEvent(long, long, long);

#define EVT_EXEC_PRESENTATION 0x1c10007L

int FDemo_MultiGuardCheck(void)
{
  if (ACTIVE_TITLE != 228) return 0;
  if (SEQ_ACTIVE_PARTS != 0) return 0;
  if (DEMO_TIMER_COUNTDOWN != 0) return 0;
  if (DEMO_CONTROL_FLAGS & 0x08) return 0;
  return 1;
}

void FDemo_LoadRegsAndPostEvent(void)
{
  ApPostEvent(-1L, EVT_EXEC_PRESENTATION, (long)FDemo_LoadRegsAndPostEvent_Str_FEATURE);
}
