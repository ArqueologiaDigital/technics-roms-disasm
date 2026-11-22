/* lane_p6 helper J, round 27r1, form b: module 278 (audio/audio_control_engine.s), the family
   CtrlPanel_SetIndicatorBit / CtrlPanel_IndicatorDispatch: the panel-LED group (A & 0xf0: 0x00, 0x20, 0x40, 0x60,
   homed in QIZ's high byte) picks the request word (LED_REQUEST_1..3, 0x8f46) or the held-back word
   (LED_REQUEST_HOLD_1..3, 0x8f48) that the bit mask CtrlPanel_LookupIndicatorEntry(A & 0x0f) is ORed into.
 a & 0xf0`=   Form b: as form a with the lookup declared unsigned char (its own C's prototype); `g = a & 0xf0`= a & 0xf0` before the lookup, a switch in source order 0, 0x20, 0x40, 0x60 (V4.23 compares in reverse
   order: 0x60 first, the case-0 body inline after the chain); the lookup declared with an unsigned int argument
   (the ROM's caller widens A with extz wa).
   cc900-options: -O3 -Xr
*/

extern unsigned int __near LED_REQUEST_1;
extern unsigned int __near LED_REQUEST_HOLD_1;
extern unsigned int __near LED_REQUEST_2;
extern unsigned int __near LED_REQUEST_HOLD_2;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;
extern unsigned int __near ram_8f46;
extern unsigned int __near ram_8f48;
extern unsigned long CtrlPanel_LookupIndicatorEntry(unsigned char a);

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
