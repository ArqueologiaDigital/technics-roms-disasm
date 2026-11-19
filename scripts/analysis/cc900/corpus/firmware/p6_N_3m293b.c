/* lane_p6 helper N, round 3, form b: module 293 (audio/dsp_config_sysex.s), retry of p6_N_1m293a / b.
   DSPCfg_RecordFieldToParamId: p6-r42's O3Xr listing of form a is the ROM's shape except that the id lives in the
   frame (+6) and the map pointer in XIZ, where the ROM has the id in XIZ and the map in the frame.  Form b keeps
   round 1's declaration order and pins the map pointer to the frame with a no-code `&m;`.
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

	&m;
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
		list = DspFxRecListPtrTable[(unsigned long)DSPCfg_GetParamCount(m)];
		m++;
		h = DSPCfg_FindParamAtRecordOffset(m, list, off - 1, &mask);
		if (h == -1)
			r = -1;
		else
			id += h + 16;
	}
	*out = id;
	return r;
}
