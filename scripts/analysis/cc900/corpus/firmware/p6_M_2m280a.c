/* Phase 6, lane_p6 helper M, round 2, module 280 (audio/audio_control_engine.s, a -O file), form a.
   ExtData_SetTlvField: when the field bits m are in EXTDATA_MASK, merge EXTDATA_VALUE into those bits of the panel
   record byte (tag MIDI_MSG_STATUS, offset EXTDATA_TLV_OFFSET); if the byte changed, store it, record it as the new
   value and MIDI data 2, and add m to MIDI data 3.  `x & y` with the operand the ROM holds in A on the right. */
/* cc900-module: PanelTlv_PayloadOfTag */

extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern void ExtData_SetTlvField(unsigned char m);

void ExtData_SetTlvField(unsigned char m)
{
	unsigned char *p;
	unsigned char v;

	if ((m & EXTDATA_MASK) == 0)
		return;
	p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
	if (p == (unsigned char *)-1L)
		return;
	p += EXTDATA_TLV_OFFSET;
	v = (*p & ~m) | EXTDATA_VALUE;
	if (v == EXTDATA_NEW_VALUE)
		return;
	*p = v;
	EXTDATA_NEW_VALUE = v;
	MIDI_MSG_DATA2 = v;
	MIDI_MSG_DATA3 |= m;
}
