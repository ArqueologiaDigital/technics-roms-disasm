/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_15m265.c (2026-11-16-107-p6-r21)
   sha256 a1bca624a164d343b4d27aca17291dc7869279e1651f89fc74871ba7301af4c9 (tar-sha256); compiled at -O3 -Xr */
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
