/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/audio_control_engine_m278.c (2026-11-22-8-p6-r75)
   sha256 dafc99d28d0c185aed4a4894cdd2f9f57a2cb7a348e90abccba959834f51016a (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned long CtrlPanel_LookupIndicatorEntry(unsigned int a);
extern unsigned int __near LED_REQUEST_1;
extern unsigned int __near LED_REQUEST_2;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near ram_8e86;
void CtrlPanel_SetIndicatorBit(unsigned char a)
{
	unsigned char g;
	unsigned int m;

	g = a & 0xf0;
	m = CtrlPanel_LookupIndicatorEntry(a & 0x0f);
	switch (g) {
	case 0x00:
		LED_REQUEST_1 |= m;
		break;
	case 0x20:
		LED_REQUEST_2 |= m;
		break;
	case 0x40:
		LED_REQUEST_3 |= m;
		break;
	case 0x60:
		ram_8e86 |= m;
		break;
	}
}
