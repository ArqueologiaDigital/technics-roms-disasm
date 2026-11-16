/* Phase 6, lane_p6 helper D, round 14, module 280 (v10 audio/audio_control_engine.s): two TLV helpers with
   memory-to-memory moves (the moved cells __near). */
/* cc900-module: PanelTlv_PayloadOfTag SwbtWr_FlushAndAppendParams */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern void SwbtWr_FlushAndAppendParams(void);
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);

extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;

void ExtData_PostRawValueAndMask(void)
{
	MIDI_MSG_DATA2 = EXTDATA_VALUE;
	MIDI_MSG_DATA3 = EXTDATA_MASK;
	SwbtWr_FlushAndAppendParams();
}

void SndParam_WriteLookupAndStore(void)
{
	unsigned char *p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);

	if (p == (unsigned char *)-1L) return;
	EXTDATA_NEW_VALUE = p[EXTDATA_TLV_OFFSET];
}
