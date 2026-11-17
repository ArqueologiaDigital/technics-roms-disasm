/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_mode_handlers_m276.c (2026-11-16-103-p6-r20-staged)
   sha256 2e4f31582e858bf106ac48b59d4b143c1e861f5a5f2aa582dfadac0caf82dda2 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
extern void A_Short_Pause(void);
extern unsigned char __near DIAG_ANIM_STEP;
extern unsigned char __near ram_8cdc;
extern unsigned char EffectMode_DiagSeq_TitleCycle[];
void EffectMode_RunDiagSequence(void)
{
	unsigned char c, a;

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
	c = ram_8cdc;
	if (c == 0) {
		ApPostEvent(-1L, 0x1c00016L, 0x1a00000L + EffectMode_DiagSeq_TitleCycle[a]);
		a = DIAG_ANIM_STEP;
		if (a == 5) DIAG_ANIM_STEP = 1;
		else DIAG_ANIM_STEP = a + 1;
		ram_8cdc = 30;
		return;
	}
	ram_8cdc = c - 1;
}
