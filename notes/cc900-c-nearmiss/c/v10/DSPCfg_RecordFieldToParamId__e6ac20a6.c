/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/dsp_config_sysex_m293.c (2026-11-19-29-p6-r46)
   sha256 e6ac20a66802d577a67edb29da1a3f22a48cafadc83520882bf1583debe93473 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char *DSPCfg_LookupMidiMap(int);
extern unsigned int DSPCfg_GetParamCount(unsigned char *);
extern unsigned char *DspFxRecListPtrTable[];
extern int DSPCfg_FindParamAtRecordOffset(unsigned char *body, unsigned char *list, unsigned char off,
                                          unsigned char *mask);
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
