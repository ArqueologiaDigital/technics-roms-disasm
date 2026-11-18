/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_5m293a.c (2026-11-18-33-p6-r37)
   sha256 faf88eaa406bf31dbb116da452946e32c5c38c7b363cc8ba9bd2f0c8384f2ab0 (tar-sha256); compiled at -O3 -XS -Xr */
extern int DSPCfg_GetParamCount(unsigned char *);
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
