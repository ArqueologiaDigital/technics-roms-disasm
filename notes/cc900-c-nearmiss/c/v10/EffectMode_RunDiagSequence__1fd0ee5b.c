/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_12m276.c (2026-11-16-100-p6-r19)
   sha256 1fd0ee5b83b359f099d1e9c37952808b864b87682cde91a862817cf85c1aa209 (tar-sha256); compiled at -Xr */
extern long ApPostEvent(long, long, long);
extern void A_Short_Pause(void);
extern unsigned char __near DIAG_ANIM_STEP;
extern unsigned char __near ram_8d78;
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
