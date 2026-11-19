/* lane_p6 helper N, round 1, form a: module 280 (audio/audio_control_engine.s).
   SndParam_ApplyAndFetch / SndParam_ApplyFromPointer: twins of the built SndParam_ResolveVoiceEntry and
   RegBitManip_Handler_4_Helper (cc900/audio_control_engine_m280.c), the program-change direction.
   ExtData_StepTlvField: steps the masked field of the panel TLV byte (tag MIDI_MSG_STATUS, offset
   EXTDATA_TLV_OFFSET) by the step at 0x9153, wrapping to 0x9155 at the limit 0x9154, and posts the new byte.
   Form b against a: ApplyAndFetch through a pointer to the local, the step's operands swapped (`m & MASK`,
   `*p & ~f`), the limit test on an int sum.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_PayloadOfTag */

extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void Rhythm_LookupTempoVelocity_Wrap(void);

void SndParam_ApplyAndFetch(void)
{
	unsigned char b[6];
	unsigned char *s;
	unsigned char *d;
	unsigned char c;

	d = b;
	s = ram_90ea;
	d[0] = s[0];
	d[1] = s[1];
	d[2] = c = s[2];
	if (c <= 0x1f) {
		SndParam_ApplyProgramChange(d);
		s = ram_90ee;
		d = b;
		s[0] = d[3];
		s[1] = d[4];
	} else if (c == 0x48)
		Rhythm_LookupTempoVelocity_Wrap();
}

void SndParam_ApplyFromPointer(unsigned char *r)
{
	unsigned char *t = r + 2;
	unsigned char *b;

	if (*t <= 0x1f)
		SndParam_ApplyProgramChange(r);
	else if (*t == 0x48) {
		b = ram_90ea;
		b[0] = r[0];
		b[1] = r[1];
		b[2] = *t;
		Rhythm_LookupTempoVelocity_Wrap();
		b = ram_90ee;
		r[3] = b[0];
		r[4] = b[1];
	}
}

extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_NEW_VALUE;
extern unsigned char __near ram_9153;
extern unsigned char __near ram_9154;
extern unsigned char __near ram_9155;
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);

void ExtData_StepTlvField(unsigned char m, unsigned char f)
{
	unsigned char *p;
	unsigned char v;
	unsigned char k;

	if ((m & EXTDATA_MASK) == 0)
		return;
	if ((m & EXTDATA_VALUE) == 0)
		return;
	p = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
	if (p == (unsigned char *)-1L)
		return;
	p += EXTDATA_TLV_OFFSET;
	v = f & *p;
	k = ram_9153;
	if (v + k < ram_9154)
		v += k;
	else
		v = ram_9155;
	v |= *p & ~f;
	if (v == EXTDATA_NEW_VALUE)
		return;
	*p = v;
	EXTDATA_NEW_VALUE = v;
	MIDI_MSG_DATA2 = v;
	MIDI_MSG_DATA3 |= f;
}
