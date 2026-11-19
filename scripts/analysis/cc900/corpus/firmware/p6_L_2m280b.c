/* Phase 6, lane_p6 helper L, round 2, form b: module 280, VoiceParam_CompareAndUpdate with m on the left of each &,
   one combined early return, the payload indexed in place, and the new value compared as `!=` around the stores. */
/* cc900-module: PanelTlv_PayloadOfTag */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern void VoiceParam_CompareAndUpdate(unsigned char m);

void VoiceParam_CompareAndUpdate(unsigned char m)
{
	unsigned char *p;
	unsigned char v;

	if ((m & EXTDATA_MASK) != 0 && (m & EXTDATA_VALUE) != 0) {
		p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
		if (p != (unsigned char *)-1L) {
			p = &p[EXTDATA_TLV_OFFSET];
			v = *p & ~m | EXTDATA_VALUE;
			if (v != EXTDATA_NEW_VALUE) {
				*p = v;
				EXTDATA_NEW_VALUE = v;
				MIDI_MSG_DATA2 = v;
				MIDI_MSG_DATA3 |= m;
			}
		}
	}
}
