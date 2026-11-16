/* Phase 6, lane_p6 helper D, round 15, module 265 (v10 demo/fdemotext_routines.s), form b:
   FDemoText_UpdateChannelVoice (see p6_D_15m265.c) with one AddswbWr call on each path. */
/* cc900-module: FDemoText_CheckVoiceState FDemoText_LookupTableEntry */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern unsigned char FDemoText_CheckVoiceState(unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);

void FDemoText_UpdateChannelVoice(unsigned char ch)
{
	unsigned char *e, *e2;
	unsigned char s;
	unsigned int w;

	e = FDemoText_LookupTableEntry(ch);
	e += 5;
	s = FDemoText_CheckVoiceState(ch);
	w = ch;
	if (s != 1) {
		*e = 0;
		AddswbWr(w, 5, 0, 0x7f);
		return;
	}
	if (*e != 0) return;
	*e = 0x50;
	AddswbWr(w, 5, 0x50, 0x7f);
	e2 = e + 2;
	if (*e2 == 0) return;
	*e2 = 0;
	AddswbWr(ch, 7, 0, 0x7f);
}
