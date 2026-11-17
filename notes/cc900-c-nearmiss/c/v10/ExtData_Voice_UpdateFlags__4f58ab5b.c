/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_D_10m280.c (2026-11-16-88-p6-r16)
   sha256 4f58ab5b83d626e83ac980db8742e788b904a09f13869de835b8b78640ff1592 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper D, round 10, module 280 (v10 audio/audio_control_engine.s, an -O file): the small TLV
   handlers that set fields and end in a jump to SwbtWr_FlushAndAppendParams (ExtData_Voice_CheckMode3_Helper and the
   _Join* handlers reached by jrl from the dispatchers), MIDI_WriteResetSequence (eight bytes appended to the
   SWBTWR event queue) and ExtData_Voice_UpdateFlags, which calls it.  The _Join* labels share their first 31
   characters with ExtData_Voice_CheckMode3_Helper, so they carry short C names. */
/* cc900-module: ExtData_SetTlvField ExtData_ToggleTlvBits MIDI_WriteResetSequence SwbtWr_FlushAndAppendParams */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern void ExtData_SetTlvField(unsigned int);
extern void ExtData_ToggleTlvBits(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);

extern unsigned char __near ram_90f9;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char __near SWBTWR_EVENT_QUEUE[];
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned char __near PANEL_STYLE[];

void MIDI_WriteResetSequence(void);

void ExtData_Voice_CheckMode3_Helper(void)
{
	ExtData_SetTlvField(128);
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_ToneParam_DispHnd_Join5=ExtData_ToneParam_DispatchHandler_Join5 */
void ExtData_ToneParam_DispHnd_Join5(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join2=ExtData_Voice_CheckMode3_Helper_Join2 */
void ExtData_VoiceCM3_Join2(void)
{
	ExtData_SetTlvField(127);
	ExtData_ToggleTlvBits(128);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join3=ExtData_Voice_CheckMode3_Helper_Join3 */
void ExtData_VoiceCM3_Join3(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join4=ExtData_Voice_CheckMode3_Helper_Join4 */
void ExtData_VoiceCM3_Join4(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join5=ExtData_Voice_CheckMode3_Helper_Join5 */
void ExtData_VoiceCM3_Join5(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join6=ExtData_Voice_CheckMode3_Helper_Join6 */
void ExtData_VoiceCM3_Join6(void)
{
	ExtData_SetTlvField(255);
	SwbtWr_FlushAndAppendParams();
}

/* cc900-name: ExtData_VoiceCM3_Join7=ExtData_Voice_CheckMode3_Helper_Join7 */
void ExtData_VoiceCM3_Join7(void)
{
	ExtData_SetTlvField(127);
	SwbtWr_FlushAndAppendParams();
}

void MIDI_WriteResetSequence(void)
{
	unsigned char a = ram_90f9;

	if (!(a & 1)) return;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0x90;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = PANEL_CONDUCTOR[0];
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0x1f;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0x90;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 1;
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = PANEL_CONDUCTOR[1];
	SWBTWR_EVENT_QUEUE[SWBTWR_WRITE_INDEX++] = 0x1f;
	a = ram_90f9;
	a &= ~1;
	ram_90f9 = a;
}

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
