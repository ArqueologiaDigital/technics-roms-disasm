/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned int __near LED_REQUEST_HOLD_1;
extern unsigned int __near LED_REQUEST_HOLD_2;
extern unsigned int __near LED_REQUEST_HOLD_3;
extern unsigned int __near ram_8eac;
extern unsigned long CtrlPanel_LookupIndicatorEntry(unsigned int a);
extern void CtrlPanel_IndicatorDispatch(unsigned char a);
extern unsigned int __near LED_REQUEST_1;
extern unsigned int __near LED_REQUEST_2;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near ram_8eaa;
extern void CtrlPanel_SetIndicatorBit(unsigned char a);

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
		ram_8eac |= m;
		break;
	}
}

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
		ram_8eaa |= m;
		break;
	}
}
