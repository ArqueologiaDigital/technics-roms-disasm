/* Phase 6, lane_p6 helper K, round 4, module 274 (ui/bitmap_out_routines.s), form a:
   BitMapOut_DeltaEncode_Type90Handler(st, ch, idx, n, buf), adecl with two stack arguments (retd 6): appends a panel
   record's change to buf at n.  ch 1 / 0 (each only once: bit 1 of the __near flag byte 0x8d46) write a pair of
   4-byte entries {st, ch, record byte, 6 or 3} for the record and its neighbour (idx - 1 / idx + 1, written
   idx + 0xffff in the ROM); any other ch writes {st, ch, record byte, record byte ^ PANEL_RECALL_BACKUP[idx]}.
   A switch with the cases 1 then 0 (V4.23 compares the last case first) and the default last.  The record base
   PANEL_RECORDS (__near) sits in a frame local, the record pointer in XIX. */

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
		buf[n++] = *rec ^ PANEL_RECALL_BACKUP[idx];
		break;
	}
}
