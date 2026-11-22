/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m278b.c (2026-11-22-7-p6-r74)
   sha256 d88afafff705bab66bbf3833474b42c376b8ce31386f78676f73d219992a3b99 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near LED_REQUEST_HOLD_1;
extern unsigned int __near LED_REQUEST_HOLD_2;
extern unsigned int __near LED_REQUEST_HOLD_3;
extern unsigned int __near ram_8f48;
extern unsigned long CtrlPanel_LookupIndicatorEntry(unsigned char a);
void CtrlPanel_IndicatorDispatch(unsigned char a)
{
	unsigned char g;
	unsigned int m;

	g = a & 0xf0;
	m = CtrlPanel_LookupIndicatorEntry(a & 0x0f);
	switch (g) {
	case 0x00:
		LED_REQUEST_HOLD_1 |= m;
		break;
	case 0x20:
		LED_REQUEST_HOLD_2 |= m;
		break;
	case 0x40:
		LED_REQUEST_HOLD_3 |= m;
		break;
	case 0x60:
		ram_8f48 |= m;
		break;
	}
}
