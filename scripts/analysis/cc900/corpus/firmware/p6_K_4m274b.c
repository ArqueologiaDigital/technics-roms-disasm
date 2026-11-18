/* Phase 6, lane_p6 helper K, round 4, module 274, form b of p6_K_4m274a.c: the same switch with the xor's operands
   swapped and PANEL_RECALL_BACKUP indexed through a converted pointer (the ROM loads its base as an immediate,
   `ld xbc, PANEL_RECALL_BACKUP`, then adds the zero-extended index). */

extern unsigned char __near PANEL_RECORDS[];
extern unsigned char PANEL_RECALL_BACKUP[];
extern unsigned char __near ram_8d46;

void BitMapOut_DeltaEncode_Type90Handler(unsigned char st, unsigned char ch, unsigned int idx, unsigned int n,
	unsigned char *buf)
{
	unsigned char *base;
	unsigned char fl;
	unsigned char *rec;

	fl = ram_8d46;
	base = PANEL_RECORDS;
	rec = &base[idx];
	switch (ch) {
	case 1:
		if (fl & 2)
			break;
		ram_8d46 = fl | 2;
		buf[n++] = st;
		buf[n++] = ch;
		buf[n++] = *rec;
		buf[n++] = 6;
		buf[n++] = st;
		buf[n++] = ch - 1;
		buf[n++] = base[idx - 1];
		buf[n++] = 3;
		break;
	case 0:
		if (fl & 2)
			break;
		ram_8d46 = fl | 2;
		buf[n++] = st;
		buf[n++] = ch;
		buf[n++] = *rec;
		buf[n++] = 3;
		buf[n++] = st;
		buf[n++] = ch + 1;
		buf[n++] = base[idx + 1];
		buf[n++] = 6;
		break;
	default:
		buf[n++] = st;
		buf[n++] = ch;
		buf[n++] = *rec;
		buf[n++] = *(unsigned char *)((unsigned long)PANEL_RECALL_BACKUP + idx) ^ *rec;
		break;
	}
}
