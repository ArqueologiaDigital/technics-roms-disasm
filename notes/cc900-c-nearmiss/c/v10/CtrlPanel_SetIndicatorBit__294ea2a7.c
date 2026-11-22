/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m278a.c (2026-11-22-7-p6-r74)
   sha256 294ea2a73e19676379cca924bb05be2a1f7d7861f87098e0bd81574835280ae9 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near LED_REQUEST_1;
extern unsigned int __near LED_REQUEST_2;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near ram_8f46;
extern unsigned long CtrlPanel_LookupIndicatorEntry(unsigned int a);
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
		ram_8f46 |= m;
		break;
	}
}
