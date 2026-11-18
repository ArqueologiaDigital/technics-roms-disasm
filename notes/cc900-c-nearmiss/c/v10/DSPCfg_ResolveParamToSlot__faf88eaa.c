/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_J_5m293a.c (2026-11-18-33-p6-r37)
   sha256 faf88eaa406bf31dbb116da452946e32c5c38c7b363cc8ba9bd2f0c8384f2ab0 (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper J, round 5, module 293 (audio/dsp_config_sysex.s), form a: DSPCfg_DecodeParamIdRange
   and its caller DSPCfg_ResolveParamToSlot.
   DecodeParamIdRange as one switch: 0x4900..0x4907 assign the kind from V4.23's value table (the ROM's
   DspParamId4900_ByteMap, {0,2,6,3,8,5,9,7}, read after sub 0x4900 / range check), 0x4910..0x4927 kind 1 and
   0x4940..0x4947 kind 4 with the offset from the range base (one shared offset store, hence base in a variable);
   anything else -1 everywhere.  The parameter count (DSPCfg_GetParamCount of the map) is taken first and stored
   through the last stack parameter at the end.
   ResolveParamToSlot: ids 0x4900..0x4f00 by page: group / map / id rebase, then DecodeParamIdRange; map and group
   are stored through slot / grp on every path (unset when out of range, as in the ROM). */
/* cc900-data: DSPCfg_DecodeParamIdRange 1 = DspParamId4900_ByteMap */
/* cc900-module: DSPCfg_DecodeParamIdRange DSPCfg_GetParamCount DSPCfg_LookupMidiMap */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int DSPCfg_GetParamCount(unsigned char *);
extern unsigned char *DSPCfg_LookupMidiMap(int);
extern int DSPCfg_DecodeParamIdRange(unsigned long id, int *offs, int *kind, unsigned char *map, int *cnt);

int DSPCfg_DecodeParamIdRange(unsigned long id, int *offs, int *kind, unsigned char *map, int *cnt)
{
	int r;
	int n;
	unsigned long base;

	r = 0;
	n = DSPCfg_GetParamCount(map);
	switch (id) {
	case 0x4900: *kind = 0; break;
	case 0x4901: *kind = 2; break;
	case 0x4902: *kind = 6; break;
	case 0x4903: *kind = 3; break;
	case 0x4904: *kind = 8; break;
	case 0x4905: *kind = 5; break;
	case 0x4906: *kind = 9; break;
	case 0x4907: *kind = 7; break;
	case 0x4910: case 0x4911: case 0x4912: case 0x4913: case 0x4914: case 0x4915:
	case 0x4916: case 0x4917: case 0x4918: case 0x4919: case 0x491a: case 0x491b:
	case 0x491c: case 0x491d: case 0x491e: case 0x491f: case 0x4920: case 0x4921:
	case 0x4922: case 0x4923: case 0x4924: case 0x4925: case 0x4926: case 0x4927:
		*kind = 1;
		base = 0x4910;
		goto calc;
	case 0x4940: case 0x4941: case 0x4942: case 0x4943: case 0x4944: case 0x4945:
	case 0x4946: case 0x4947:
		*kind = 4;
		base = 0x4940;
calc:
		*offs = id - base;
		break;
	default:
		*kind = -1;
		*offs = -1;
		r = -1;
		break;
	}
	*cnt = n;
	return r;
}

int DSPCfg_ResolveParamToSlot(unsigned long id, unsigned char **slot, int *grp, int *offs, int *kind, int *cnt)
{
	unsigned char *map;
	int g;
	int r;

	if (id > 0x4f00 || id < 0x4900)
		r = -1;
	else if (id < 0x4a00) {
		g = 0;
		map = DSPCfg_LookupMidiMap(0);
		r = DSPCfg_DecodeParamIdRange(id, offs, kind, map, cnt);
	} else if (id < 0x4b00) {
		g = 1;
		map = DSPCfg_LookupMidiMap(1);
		r = DSPCfg_DecodeParamIdRange(id - 0x200, offs, kind, map, cnt);
	} else if (id < 0x4c00) {
		g = 1;
		map = DSPCfg_LookupMidiMap(1);
		r = DSPCfg_DecodeParamIdRange(id - 0x200, offs, kind, map, cnt);
	} else if (id < 0x4d00) {
		g = 4;
		map = DSPCfg_LookupMidiMap(4);
		r = DSPCfg_DecodeParamIdRange(id - 0x300, offs, kind, map, cnt);
	} else if (id < 0x4e00) {
		g = 2;
		map = DSPCfg_LookupMidiMap(2);
		r = DSPCfg_DecodeParamIdRange(id - 0x400, offs, kind, map, cnt);
	} else {
		g = 3;
		map = DSPCfg_LookupMidiMap(3);
		r = DSPCfg_DecodeParamIdRange(id - 0x500, offs, kind, map, cnt);
	}
	*slot = map;
	*grp = g;
	return r;
}
