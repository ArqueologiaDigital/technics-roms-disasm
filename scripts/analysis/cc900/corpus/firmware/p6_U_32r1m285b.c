/* lane_p6 helper U, round 32r1: roots of midi/midi_dispatch_handlers.s, module 285 (-O3 -Xr). */

extern unsigned char FileData_NNTag99ValueMap[];

/* form b: the three 7-bit fields of each 26-byte record as bitfields */
struct B7 {
	unsigned char hi : 1;
	unsigned char v : 7;
};

void DSPCfg_VoiceSlotB_ExtractData(unsigned char *s, unsigned char *d)
{
	unsigned char *p;
	unsigned char *q;
	unsigned char *e;
	unsigned char t;

	p = s + 373;
	if (*p & 7) {
		t = ((unsigned int)*p << 4) & 0x30;
		d[737] &= 0xcf;
		d[737] |= t;
	}
	p = s + 1006;
	q = d + 64;
	e = p + 16;
	do {
		((struct B7 *)(q - 2))->v = p[-36];
		((struct B7 *)(q + 1))->v = p[-18];
		((struct B7 *)(q - 1))->v = p[18];
		*q = *p++;
		q += 26;
	} while (p < e);
	d[948] = FileData_NNTag99ValueMap[s[389]];
	d[949] = FileData_NNTag99ValueMap[s[390]];
	d[970] = FileData_NNTag99ValueMap[s[394]];
	d[969] = FileData_NNTag99ValueMap[s[395]];
}
