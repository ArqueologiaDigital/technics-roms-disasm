/* Phase 6, lane_p6 helper M, round 4, module 280, form a: ExtData_SetTlvField retry (run r42: the O3Xr listing
   differed only in the first test, which loaded m and anded EXTDATA_MASK; the ROM loads EXTDATA_MASK and ands m:
   operands swapped). */
/* cc900-module: PanelTlv_PayloadOfTag */   /* scripts/analysis/cc900/module_calls.py v10 */

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

	if ((EXTDATA_MASK & m) == 0)
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
