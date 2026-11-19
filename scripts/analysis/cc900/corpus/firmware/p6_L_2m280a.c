/* Phase 6, lane_p6 helper L, round 2, form a: module 280 (audio/audio_control_engine.s).
   - VoiceParam_CompareAndUpdate: when mask bit m is set in both EXTDATA_MASK and EXTDATA_VALUE, patch the TLV
     payload byte (EXTDATA_TLV_OFFSET into tag MIDI_MSG_STATUS) to (~m & byte) | EXTDATA_VALUE and, when that
     changed, record it in EXTDATA_NEW_VALUE / MIDI_MSG_DATA2 and or m into MIDI_MSG_DATA3.  The ROM keeps m in
     the frame (an -Xr routine, or m's address matters).  Form a: cell & m. */
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

	if ((EXTDATA_MASK & m) == 0)
		return;
	if ((EXTDATA_VALUE & m) == 0)
		return;
	p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
	if (p == (unsigned char *)-1L)
		return;
	p += EXTDATA_TLV_OFFSET;
	v = (~m & *p) | EXTDATA_VALUE;
	if (v == EXTDATA_NEW_VALUE)
		return;
	*p = v;
	EXTDATA_NEW_VALUE = v;
	MIDI_MSG_DATA2 = v;
	MIDI_MSG_DATA3 |= m;
}
