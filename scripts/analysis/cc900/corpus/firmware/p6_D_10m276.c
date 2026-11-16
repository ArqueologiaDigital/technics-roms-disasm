/* Phase 6, lane_p6 helper D, round 10, module 276 (v10 ui/ui_mode_handlers.s): EffectMode_RunDiagSequence.  Step 0
   shows the five TEST5x views with a pause pair after each (A_Short_Pause, same module, calr); later steps cycle the
   interrupt title every 30 calls.  Constants are the .equ values: NAKA_VIEW_TEST51..55 0xf80006..0xf8000e,
   EVT_SHOW 0x1c00001, EVT_INTERRUPT_TITLE 0x1c00016, TITLE_PS 0x1a00000. */
/* cc900-module: A_Short_Pause */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern long ApPostEvent(long, long, long);
extern void A_Short_Pause(void);
extern unsigned char __near DIAG_ANIM_STEP;
extern unsigned char __near ram_8d78;
extern unsigned char EffectMode_DiagSeq_TitleCycle[];

void EffectMode_RunDiagSequence(void)
{
	unsigned char a, c;

	a = DIAG_ANIM_STEP;
	if (a == 0) {
		ApPostEvent(0xf80006L, 0x1c00001L, 0);
		A_Short_Pause();
		A_Short_Pause();
		ApPostEvent(0xf80008L, 0x1c00001L, 0);
		A_Short_Pause();
		A_Short_Pause();
		ApPostEvent(0xf8000aL, 0x1c00001L, 0);
		A_Short_Pause();
		A_Short_Pause();
		ApPostEvent(0xf8000cL, 0x1c00001L, 0);
		A_Short_Pause();
		A_Short_Pause();
		ApPostEvent(0xf8000eL, 0x1c00001L, 0);
		A_Short_Pause();
		A_Short_Pause();
		DIAG_ANIM_STEP++;
		return;
	}
	c = ram_8d78;
	if (c == 0) {
		ApPostEvent(-1L, 0x1c00016L, 0x1a00000L + EffectMode_DiagSeq_TitleCycle[a]);
		a = DIAG_ANIM_STEP;
		if (a == 5) DIAG_ANIM_STEP = 1;
		else DIAG_ANIM_STEP = a + 1;
		ram_8d78 = 30;
		return;
	}
	ram_8d78 = c - 1;
}
