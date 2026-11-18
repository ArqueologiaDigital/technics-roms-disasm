/* Functions of audio/dsp_config_sysex.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DSPCfg_DecodeParamIdRange DSPCfg_GetParamCount DSPCfg_GetSlotCount DSPCfg_LookupMidiMap DSPCfg_PackAddress */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int DSPCfg_GetParamCount(unsigned char *);
extern int DSPCfg_DecodeParamIdRange(unsigned long id, int *offs, int *kind, unsigned char *map, int *cnt);
extern unsigned char *DSPCfg_LookupMidiMap(int);
extern int DSPCfg_ResolveParamToSlot(unsigned long id, unsigned char **slot, int *grp, int *offs, int *kind, int *cnt);
extern unsigned char *DspFxRecListPtrTable[];
extern int DSPCfg_GetSlotCount(int fx);
extern unsigned char *DSPCfg_PackAddress(unsigned char *);
extern int DSPCfg_FindSlot63(int fx);

/* cc900-data: DSPCfg_DecodeParamIdRange 1 = DspParamId4900_ByteMap */
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

/* cc900-data: DSPCfg_DecodeParamIdRange 1 = DspParamId4900_ByteMap */
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

int DSPCfg_FindSlot63(int fx)
{
    int r;
    int n;
    int i;
    unsigned char *p;

    r = -1;
    n = DSPCfg_GetSlotCount(fx);
    p = DspFxRecListPtrTable[fx];
    for (i = 0; i < n; i++) {
        if (p[2] == 0x63)
            r = i;
        p = DSPCfg_PackAddress(p);
    }
    return r;
}
