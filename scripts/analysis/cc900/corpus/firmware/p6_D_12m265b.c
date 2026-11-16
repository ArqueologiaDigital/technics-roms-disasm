/* Phase 6, lane_p6 helper D, round 12, module 265 (v10 demo/fdemotext_routines.s, an -O file), form b:
   FDemoText_UpdateChannelVoice with a separate AddswbWr call on each path (see p6_D_12m265.c). */
/* cc900-module: FDemoText_CheckVoiceState FDemoText_LookupTableEntry */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern unsigned char FDemoText_CheckVoiceState(unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);

void FDemoText_UpdateChannelVoice(unsigned char ch)
{
	unsigned char *e;

	e = FDemoText_LookupTableEntry(ch) + 5;
	if (FDemoText_CheckVoiceState(ch) != 1) {
		*e = 0;
		AddswbWr(ch, 5, 0, 0x7f);
		return;
	}
	if (*e != 0) return;
	*e = 0x50;
	AddswbWr(ch, 5, 0x50, 0x7f);
	if (e[2] == 0) return;
	e[2] = 0;
	AddswbWr(ch, 7, 0, 0x7f);
}
