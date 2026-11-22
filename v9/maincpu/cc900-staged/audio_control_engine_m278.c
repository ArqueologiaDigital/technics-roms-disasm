/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Audio_CheckAndFlagChanges DispatchBitmaskHandlers MidiChOut_DetectChanges */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void MIDI_ProcessChangedChannels(void);

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
