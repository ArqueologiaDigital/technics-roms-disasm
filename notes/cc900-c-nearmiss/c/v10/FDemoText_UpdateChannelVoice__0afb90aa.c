/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_15m265b.c (2026-11-16-107-p6-r21)
   sha256 0afb90aa0f1d1f3a747f5eb05c220032cb636e1bbd15da9b45523efbd111d5cd (tar-sha256); compiled at -Xr */
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
