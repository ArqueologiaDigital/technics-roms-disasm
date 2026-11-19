/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_7m265a.c (2026-11-19-56-p6-r51)
   sha256 931b221fe95e3ce85384aa3ec27c9c590841a6f054203e7f61734b1a3f8e7f09 (tar-sha256); compiled at -Xr */
extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern void AddswbWr(int, int, int, int);
extern unsigned char ram_247ee;
extern unsigned char __near PANEL_DSP_EFFECT[];
extern unsigned char __near PANEL_DRAWBAR_RIGHT1[];
extern void FDemoText_NotifyUIChange(int a, unsigned char v);
void FDemoText_UpdateVoiceDisplay(unsigned char ch)
{
	unsigned char *e;
	unsigned char *f;

	e = FDemoText_LookupTableEntry(ch);
	e += 5;
	if (*e != 0) {
		*e = 0;
		AddswbWr(ch, 5, 0, 0x7f);
		f = e + 2;
		if (*f == 0) {
			*f = 0x5a;
			AddswbWr(ch, 7, 0x5a, 0x7f);
		}
	}
	if ((ram_247ee & 0x38) == 0 && PANEL_DRAWBAR_RIGHT1[0] != PANEL_DSP_EFFECT[0])
		FDemoText_NotifyUIChange(0x61, PANEL_DRAWBAR_RIGHT1[0]);
}
