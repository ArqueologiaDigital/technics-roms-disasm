/* Phase 6, lane_p6 helper D, round 12, module 265 (v10 demo/fdemotext_routines.s, an -O file), form a:
   FDemoText_UpdateChannelVoice.  It looks up the channel's record (+5 is its level byte), asks whether the voice is
   active and sends level changes with AddswbWr (4th argument on the stack).  In the ROM two paths share one
   AddswbWr call; form a writes that as one call after the branches (register-chosen argument), form b
   (p6_D_12m265b.c) as separate calls. */
/* cc900-module: FDemoText_CheckVoiceState FDemoText_LookupTableEntry */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern unsigned char FDemoText_CheckVoiceState(unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);

void FDemoText_UpdateChannelVoice(unsigned char ch)
{
	unsigned char *e;
	unsigned int c;

	e = FDemoText_LookupTableEntry(ch) + 5;
	if (FDemoText_CheckVoiceState(ch) == 1) {
		if (*e != 0) return;
		*e = 0x50;
		AddswbWr(ch, 5, 0x50, 0x7f);
		if (e[2] == 0) return;
		e[2] = 0;
		c = 7;
	} else {
		*e = 0;
		c = 5;
	}
	AddswbWr(ch, c, 0, 0x7f);
}
