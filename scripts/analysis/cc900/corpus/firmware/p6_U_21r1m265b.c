/* helper U, round 21r1, module 265, form b: FDemo_MultiGuardCheck's guards as nested ifs around `return 1`;
   the string pointer through a long local initialised from the number. */

extern unsigned char __near ACTIVE_TITLE;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern long ApPostEvent(long, long, long);

#define EVT_EXEC_PRESENTATION 0x1c10007L

int FDemo_MultiGuardCheck(void)
{
  if (ACTIVE_TITLE == 228)
    if (SEQ_ACTIVE_PARTS == 0)
      if (DEMO_TIMER_COUNTDOWN == 0)
        if (!(DEMO_CONTROL_FLAGS & 0x08))
          return 1;
  return 0;
}

void FDemo_LoadRegsAndPostEvent(void)
{
  long s = 0xea009eL;
  ApPostEvent(-1L, EVT_EXEC_PRESENTATION, s);
}
