/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m278a.c (2026-11-22-17-p6-r84)
   sha256 9abcc2b2d0b04f062ab86db335f7662aba1ec8dd72246a03e7a7cedf50911041 (tar-sha256); compiled at -Xr */
extern unsigned int __near LED_REQUEST_HOLD_2;
extern unsigned char __near CURRENT_TITLE;
extern unsigned int __near LED_REQUEST_1;
extern unsigned int __near LED_REQUEST_HOLD_1;
extern unsigned int __near LED_REQUEST_2;
extern unsigned int __near LED_REQUEST_3;
extern unsigned int __near LED_REQUEST_HOLD_3;
extern unsigned int __near ram_8f46;
extern unsigned int __near ram_8f48;
extern void (*PanelLed_PendingGroup1Handlers[])(void);
extern void (*PanelLed_PendingGroup2Handlers[])(void);
extern void (*PanelLed_PendingGroup3Handlers[])(void);
extern void (*PanelLed_PendingGroup4Handlers[])(void);
extern void Audio_CheckAndFlagChanges(void);
extern void DispatchBitmaskHandlers(unsigned int, void (**)(void));
void MIDI_ProcessChangedChannels(void)
{
	unsigned int m;

	if (CURRENT_TITLE == 251) return;
	Audio_CheckAndFlagChanges();
	if ((m = ~LED_REQUEST_HOLD_1 & LED_REQUEST_1) != 0) {
		DispatchBitmaskHandlers(m, PanelLed_PendingGroup1Handlers);
		LED_REQUEST_1 = 0;
	}
	if ((m = ~LED_REQUEST_HOLD_2 & LED_REQUEST_2) != 0) {
		DispatchBitmaskHandlers(m, PanelLed_PendingGroup2Handlers);
		LED_REQUEST_2 = 0;
	}
	if ((m = ~LED_REQUEST_HOLD_3 & LED_REQUEST_3) != 0) {
		DispatchBitmaskHandlers(m, PanelLed_PendingGroup3Handlers);
		LED_REQUEST_3 = 0;
	}
	if ((m = ~ram_8f48 & ram_8f46) != 0) {
		DispatchBitmaskHandlers(m, PanelLed_PendingGroup4Handlers);
		ram_8f46 = 0;
	}
}
