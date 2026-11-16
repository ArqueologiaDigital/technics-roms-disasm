/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: ExtData_SetTlvField ExtData_ToggleTlvBits MIDI_WriteResetSequence SwbtWr_FlushAndAppendParams */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void ExtData_SetTlvField(unsigned int);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern unsigned char __near ram_90f9;
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near PANEL_STYLE[];
extern void MIDI_WriteResetSequence(void); void ExtData_Voice_CheckMode3_Helper(void);
extern void MIDI_WriteResetSequence(void);
extern void ExtData_Voice_UpdateFlags(void);

void ExtData_Voice_UpdateFlags(void)
{
	unsigned char *c;
	unsigned char a;

	ExtData_ToggleTlvBits(2);
	ExtData_SetTlvField(1);
	SwbtWr_FlushAndAppendParams();
	c = PANEL_CONDUCTOR;
	if (c[3] & 1) return;
	if ((PANEL_STYLE[3] & 7) != 1) return;
	c++;
	a = *c;
	if (a & 2) {
		ram_90f9 |= 1;
		a = *c;
		a &= ~2;
		*c = a;
		MIDI_WriteResetSequence();
	}
}
