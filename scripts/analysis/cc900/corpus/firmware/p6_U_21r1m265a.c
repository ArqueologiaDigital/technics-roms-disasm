/* helper U, round 21r1, module 265 (demo/file_demo_proc.s), form a: one-spot retries of run r58.
   FDemo_MultiGuardCheck: the ROM places `return 1` first (all four guards in one && test).
   FDemo_LoadRegsAndPostEvent: the ROM loads the string's address as an immediate (`ld xde, N`), the shape of a
   numeric pointer argument (HANDOFF-2026-11-18: `0x8094L` gives ld, `(long)ram_8094` gives lda); 0xea009e is
   FDemo_LoadRegsAndPostEvent_Str_FEATURE in v10. */

extern unsigned char __near ACTIVE_TITLE;
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern long ApPostEvent(long, long, long);

#define EVT_EXEC_PRESENTATION 0x1c10007L
#define STR_FEATURE 0xea009eL

int FDemo_MultiGuardCheck(void)
{
  if (ACTIVE_TITLE == 228 && SEQ_ACTIVE_PARTS == 0 && DEMO_TIMER_COUNTDOWN == 0 && !(DEMO_CONTROL_FLAGS & 0x08))
    return 1;
  return 0;
}

void FDemo_LoadRegsAndPostEvent(void)
{
  ApPostEvent(-1L, EVT_EXEC_PRESENTATION, STR_FEATURE);
}
