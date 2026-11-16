/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/



void A_Short_Pause(void)
{
	unsigned int i, j;

	for (i = 0; i < 0x1000; i++)
		for (j = 0; j < 0x100; j++)
			;
}

unsigned char SelfTest_PopCount(unsigned char a)
{
	unsigned char n, i;

	n = 0;
	for (i = 0; i < 8; i++) {
		if (a & 1) n++;
		a >>= 1;
	}
	return n;
}

/* cc900-module: A_Short_Pause */
extern long ApPostEvent(long, long, long);
extern void A_Short_Pause(void);
extern unsigned char __near DIAG_ANIM_STEP;
extern unsigned char __near ram_8cdc;
extern unsigned char EffectMode_DiagSeq_TitleCycle[];
extern void EffectMode_RunDiagSequence(void);

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
