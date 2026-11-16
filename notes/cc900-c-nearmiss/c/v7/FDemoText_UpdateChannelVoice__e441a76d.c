/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdemotext_routines_m265.c (2026-11-16-111-p6-r22-staged)
   sha256 e441a76dac1ea3bad7cb955c56776d85f3ce30ad8b6ef2af129eb5cb0d456d43 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
