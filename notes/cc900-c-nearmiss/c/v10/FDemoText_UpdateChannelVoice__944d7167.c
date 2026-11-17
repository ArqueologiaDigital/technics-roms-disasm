/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_12m265.c (2026-11-16-100-p6-r19)
   sha256 944d7167d845582c4084b4dd56992e13f66f8da71fb239f112f49b147bbfaa96 (tar-sha256); compiled at -O3 -Xr */
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
