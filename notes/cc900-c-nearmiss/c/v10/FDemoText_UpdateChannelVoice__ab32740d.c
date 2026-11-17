/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_12m265b.c (2026-11-16-100-p6-r19)
   sha256 ab32740dbc4912e8b8e9c67b8a75bf74520177a3de22e628b61d0d88076da834 (tar-sha256); compiled at -O3 -Xr */
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
