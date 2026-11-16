/* Phase 6, lane_p6 helper D, round 15, module 265 (v10 demo/fdemotext_routines.s), form a:
   FDemoText_UpdateChannelVoice after run 100.  The ROM copies the looked-up pointer and then adds 5 (here: `e += 5`
   as its own statement), loads the channel for the following AddswbWr before testing the voice state (here: a
   second plain local, lane_sub's spelling (a)) and reaches byte +7 through its own pointer.  Form a shares the last
   AddswbWr call between two paths as the ROM does; form b (p6_D_15m265b.c) calls it on each path. */
/* cc900-module: FDemoText_CheckVoiceState FDemoText_LookupTableEntry */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern unsigned char FDemoText_CheckVoiceState(unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);

void FDemoText_UpdateChannelVoice(unsigned char ch)
{
	unsigned char *e, *e2;
	unsigned char s;
	unsigned int w, c;

	e = FDemoText_LookupTableEntry(ch);
	e += 5;
	s = FDemoText_CheckVoiceState(ch);
	w = ch;
	if (s == 1) {
		if (*e != 0) return;
		*e = 0x50;
		AddswbWr(w, 5, 0x50, 0x7f);
		e2 = e + 2;
		if (*e2 == 0) return;
		*e2 = 0;
		w = ch;
		c = 7;
	} else {
		*e = 0;
		c = 5;
	}
	AddswbWr(w, c, 0, 0x7f);
}
