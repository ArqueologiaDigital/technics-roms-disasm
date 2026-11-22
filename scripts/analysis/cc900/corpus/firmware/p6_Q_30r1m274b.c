/* lane_p6 helper Q, round 30r1, form b: module 274 (ui/bitmap_out_routines.s), BitMapOut_DeltaEncode_TypeDefault
   (345 B, roots30_Q): appends the change of panel record byte idx (PANEL_RECORDS against
   PANEL_RECALL_BACKUP) to the output stream out at n, for status bytes below 0x20: sub 0 = a {ch, 1, next, 0x7f, ch,
   0, this, 0xff} pair (and sets bit 0 of the flags), sub 1 = the same with the previous byte when the 7-bit values
   differ and bit 0 is clear, else {ch, sub, new, new ^ old}; sets flag bit 6 and returns the new n (the caller,
   BitMapOut_DetectChanges, keeps n in HL across the call).  Its siblings for status 0x48 and 0x90,
   BitMapOut_DeltaEncode_Type48Handler (430 B: style bytes 5 / 6 send {0, 0}; no flag bit 6) and
   BitMapOut_DeltaEncode_Type90Handler (324 B, not in a pool: flag bit 1, the flags read once at entry; pairs
   {.., 6, ch, sub - 1, prev, 3} / {.., 3, ch, sub + 1, next, 6}); BitMapOut_DeltaEncode_Type90Return (122 B: for the
   23 rows of PanelMemory_PartResolveTable, fills a 5-byte entry, SndParam_ResolveVoiceEntry, stores the result in
   the row's companion column); BitMapOut_RefreshDisplay_ClearDirty (195 B: sends PANEL_CONDUCTOR's two bytes as
   {0x90, 0, b0, 3, 0x90, 1, b1, 6} when they differ from the backup, ends the stream, copies them to the backup).
   Form b: the record cell on the left of the 7-bit compare (form a: the backup cell); Type90's flags tested as (f & 2) == 0; ClearDirty through a backup pointer q kept for the copy back.
   cc900-options: -O3 -Xr
*/
/* cc900-name: BmoDelta_TypeDefault=BitMapOut_DeltaEncode_TypeDefault */
/* cc900-name: BmoDelta_Type48Handler=BitMapOut_DeltaEncode_Type48Handler */
/* cc900-name: BmoDelta_Type90Handler=BitMapOut_DeltaEncode_Type90Handler */
/* cc900-name: BmoDelta_Type90Return=BitMapOut_DeltaEncode_Type90Return */
/* cc900-name: BmoRefreshDisplay_ClearDirty=BitMapOut_RefreshDisplay_ClearDirty */

extern unsigned char __near PANEL_RECORDS[];
extern unsigned char PANEL_RECALL_BACKUP[];
extern unsigned char __near ram_8d46;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_CONDUCTOR[];
extern unsigned int __near ram_90e2;
extern unsigned char __near ram_bf39[];
struct resolve_ent { unsigned char *p0; unsigned char *p4; unsigned char b8; unsigned char b9; unsigned char *col; };
struct voice_ent { unsigned char idx; unsigned char val; unsigned char b2; unsigned char b3; unsigned char b4; };
extern struct resolve_ent PanelMemory_PartResolveTable[];
extern void SndParam_ResolveVoiceEntry(struct voice_ent *);
extern unsigned int BmoDelta_TypeDefault(unsigned char ch, unsigned char sub, unsigned int idx,
                                         unsigned int n, unsigned char *out);
extern unsigned int BmoDelta_Type48Handler(unsigned char ch, unsigned char sub, unsigned int idx,
                                           unsigned int n, unsigned char *out);
extern unsigned int BmoDelta_Type90Handler(unsigned char ch, unsigned char sub, unsigned int idx,
                                           unsigned int n, unsigned char *out);
extern void BmoDelta_Type90Return(void);
extern void BmoRefreshDisplay_ClearDirty(void);

unsigned int BmoDelta_TypeDefault(unsigned char ch, unsigned char sub, unsigned int idx,
                                  unsigned int n, unsigned char *out)
{
	unsigned char *rec;
	unsigned char *bak;

	rec = &PANEL_RECORDS[idx];
	if (sub != 0) {
		bak = &PANEL_RECALL_BACKUP[idx];
		if (sub != 1) {
			out[n++] = ch;
			out[n++] = sub;
			out[n++] = *rec;
			out[n++] = *bak ^ *rec;
		} else if ((*rec & 0x7f) != (*bak & 0x7f) && !(ram_8d46 & 1)) {
			out[n++] = ch;
			out[n++] = 1;
			out[n++] = *rec;
			out[n++] = 0x7f;
			out[n++] = ch;
			out[n++] = 0;
			out[n++] = PANEL_RECORDS[idx - 1];
			out[n++] = 0xff;
		}
	} else {
		ram_8d46 |= 1;
		out[n++] = ch;
		out[n++] = 1;
		out[n++] = PANEL_RECORDS[idx + 1];
		out[n++] = 0x7f;
		out[n++] = ch;
		out[n++] = 0;
		out[n++] = *rec;
		out[n++] = 0xff;
	}
	ram_8d46 |= 0x40;
	return n;
}

unsigned int BmoDelta_Type48Handler(unsigned char ch, unsigned char sub, unsigned int idx,
                                    unsigned int n, unsigned char *out)
{
	unsigned char *rec;
	unsigned char *bak;

	rec = &PANEL_RECORDS[idx];
	if (sub != 0) {
		bak = &PANEL_RECALL_BACKUP[idx];
		if (sub != 1) {
			out[n++] = ch;
			out[n++] = sub;
			if (idx == &PANEL_STYLE[5] - PANEL_RECORDS || idx == &PANEL_STYLE[6] - PANEL_RECORDS) {
				out[n++] = 0;
				out[n++] = 0;
			} else {
				out[n++] = PANEL_RECORDS[idx];
				out[n++] = *bak ^ PANEL_RECORDS[idx];
			}
		} else if ((*rec & 0x7f) != (*bak & 0x7f) && !(ram_8d46 & 1)) {
			out[n++] = ch;
			out[n++] = 1;
			out[n++] = *rec;
			out[n++] = 0x7f;
			out[n++] = ch;
			out[n++] = 0;
			out[n++] = PANEL_RECORDS[idx - 1];
			out[n++] = 0xff;
		}
	} else {
		ram_8d46 |= 1;
		out[n++] = ch;
		out[n++] = 1;
		out[n++] = PANEL_RECORDS[idx + 1];
		out[n++] = 0x7f;
		out[n++] = ch;
		out[n++] = 0;
		out[n++] = *rec;
		out[n++] = 0xff;
	}
	return n;
}

unsigned int BmoDelta_Type90Handler(unsigned char ch, unsigned char sub, unsigned int idx,
                                    unsigned int n, unsigned char *out)
{
	unsigned char f;
	unsigned char *rec;

	f = ram_8d46;
	rec = &PANEL_RECORDS[idx];
	if (sub != 0) {
		if (sub != 1) {
			out[n++] = ch;
			out[n++] = sub;
			out[n++] = *rec;
			out[n++] = PANEL_RECALL_BACKUP[idx] ^ *rec;
		} else if ((f & 2) == 0) {
			ram_8d46 = f | 2;
			out[n++] = ch;
			out[n++] = sub;
			out[n++] = *rec;
			out[n++] = 6;
			out[n++] = ch;
			out[n++] = sub - 1;
			out[n++] = PANEL_RECORDS[idx - 1];
			out[n++] = 3;
		}
	} else if ((f & 2) == 0) {
		ram_8d46 = f | 2;
		out[n++] = ch;
		out[n++] = sub;
		out[n++] = *rec;
		out[n++] = 3;
		out[n++] = ch;
		out[n++] = sub + 1;
		out[n++] = PANEL_RECORDS[idx + 1];
		out[n++] = 6;
	}
	return n;
}

void BmoDelta_Type90Return(void)
{
	struct voice_ent v;
	unsigned int i;

	for (i = 0; i < 23; i++) {
		v.b3 = *PanelMemory_PartResolveTable[i].p0 & 0xff;
		v.b4 = *PanelMemory_PartResolveTable[i].p4 & 0x7f;
		v.b2 = PanelMemory_PartResolveTable[i].b8;
		SndParam_ResolveVoiceEntry(&v);
		PanelMemory_PartResolveTable[i].col[v.idx] = v.val;
	}
}

void BmoRefreshDisplay_ClearDirty(void)
{
	unsigned int n;
	unsigned char *out;
	unsigned char *p;
	unsigned char *q;

	n = ram_90e2;
	out = ram_bf39;
	p = PANEL_CONDUCTOR;
	q = &PANEL_RECALL_BACKUP[p - PANEL_RECORDS];
	if (*p != *q || p[1] != PANEL_RECALL_BACKUP[p + 1 - PANEL_RECORDS]) {
		out[n++] = 0x90;
		out[n++] = 0;
		out[n++] = *p;
		out[n++] = 3;
		out[n++] = 0x90;
		out[n++] = 1;
		out[n++] = p[1];
		out[n++] = 6;
	}
	out[n] = 0xff;
	ram_90e2 = n;
	*q = *p;
	PANEL_RECALL_BACKUP[p + 1 - PANEL_RECORDS] = p[1];
}
