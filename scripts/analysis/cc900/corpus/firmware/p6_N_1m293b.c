/* lane_p6 helper N, round 1, form a: module 293 (audio/dsp_config_sysex.s).
   DSPCfg_RecordFieldToParamId: object code 'a'..'f' -> DSP block id base (0x4900 .. 0x4e00) and its MIDI map; for
   record offset 1..16, base + 0x10 + the parameter DSPCfg_FindParamAtRecordOffset finds at offset - 1.  The switch's
   offset table is DspCfg_OpLetter_JumpOffsets (cc900-data).  GetParamCount is declared unsigned here: the ROM
   zero-extends its result before indexing DspFxRecListPtrTable with it.
   Form b against a: the table indexed through an integer address (lane_hd's converted-pointer idiom: `ld xbc,Table;
   add xbc,xhl`), the id adjusted with a long cast.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DSPCfg_FindParamAtRecordOffset DSPCfg_GetParamCount DSPCfg_LookupMidiMap */

extern unsigned char *DSPCfg_LookupMidiMap(int);
extern unsigned int DSPCfg_GetParamCount(unsigned char *);
extern unsigned char *DspFxRecListPtrTable[];
extern int DSPCfg_FindParamAtRecordOffset(unsigned char *body, unsigned char *list, unsigned char off,
                                          unsigned char *mask);

/* cc900-data: DSPCfg_RecordFieldToParamId 1 = DspCfg_OpLetter_JumpOffsets */
int DSPCfg_RecordFieldToParamId(unsigned char op, unsigned char off, unsigned char mask, unsigned long *out)
{
	int r;
	unsigned char *m;
	unsigned char *list;
	unsigned long id;
	int g;
	int h;

	r = 0;
	switch (op) {
	case 'a': id = 0x4900; g = 0; break;
	case 'b': id = 0x4a00; g = 1; break;
	case 'c': id = 0x4b00; g = 1; break;
	case 'd': id = 0x4c00; g = 4; break;
	case 'e': id = 0x4d00; g = 2; break;
	case 'f': id = 0x4e00; g = 3; break;
	default: r = -1; break;
	}
	if (off >= 1 && off < 17) {
		m = DSPCfg_LookupMidiMap(g);
		list = *(unsigned char **)((unsigned long)DspFxRecListPtrTable
		                           + ((unsigned long)DSPCfg_GetParamCount(m) << 2));
		m++;
		h = DSPCfg_FindParamAtRecordOffset(m, list, off - 1, &mask);
		if (h == -1)
			r = -1;
		else
			id += (long)(h + 16);
	}
	*out = id;
	return r;
}
