/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: Note_CheckTransposeRange */   /* scripts/analysis/cc900/module_calls.py v10 */

struct nent5 { unsigned char e0, e1, e2, e3, e4; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))
struct trn { signed char x7 : 4; signed char oct : 3; signed char x0 : 1;
             signed char semi : 4; signed char y0 : 4; };
struct vrec { unsigned char pad[0x124]; struct trn tr[16]; };
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern int SndParam_LookupReadOnly(long);
extern unsigned char Note_CheckTransposeRange();
extern unsigned char SndParam_LookupByChannel();
extern void NoteMap_ComputePitchOffset(unsigned char *r, struct vrec *q, unsigned char e);
extern void SndParam_ComputeVoiceTuning(unsigned char *r, struct vrec *q, unsigned char e);

void NoteMap_ComputePitchOffset(unsigned char *r, struct vrec *q, unsigned char e)
{
	unsigned int i;
	signed char t;
	unsigned char dir;
	int lk1;
	int lk2;
	unsigned char x;
	register unsigned char n;

	t = q->tr[e].oct * 12 + q->tr[e].semi;
	lk1 = SndParam_LookupViaEncode(e, 0);
	lk2 = SndParam_LookupViaEncode(e, 0x20);
	x = 2;
	switch (SndParam_LookupReadOnly(0x2205L)) {
	case 0:
		dir = 1;
		x = 2;
		break;
	case 1:
		dir = 0xff;
		x = 0xff;
		break;
	case 3:
		dir = 3;
		x = 4;
		break;
	}
	for (i = 0; i < r[1]; i++) {
		NM_E(r, i)->e4 = 0;
		if (NM_E(r, i)->e1 != 0) {
			n = NM_E(r, i)->e0;
			NM_E(r, i)->e2 = n;
			if (Note_CheckTransposeRange((unsigned char)lk1, (unsigned char)lk2) == 0) {
				if (t != 0) {
					if ((n += t) > 127) {
						if (t > 0) {
							while ((x = n) > 127)
								n -= 12;
						} else {
							while ((signed char)n < 0)
								n += 12;
						}
					}
				}
				if (n >= 120)
					n = 0xff;
			} else if (dir != 0xff)
				n = SndParam_LookupByChannel(dir, (unsigned char)lk1, (unsigned char)lk2, n);
			NM_E(r, i)->e3 = n;
		}
	}
}

void SndParam_ComputeVoiceTuning(unsigned char *r, struct vrec *q, unsigned char e)
{
	unsigned int i;
	signed char t;
	unsigned char dir;
	int lk1;
	int lk2;
	unsigned char x;
	register unsigned char n;

	t = q->tr[e].oct * 12 + q->tr[e].semi;
	lk1 = SndParam_LookupViaEncode(e, 0);
	lk2 = SndParam_LookupViaEncode(e, 0x20);
	x = 2;
	switch (SndParam_LookupReadOnly(0x2205L)) {
	case 0:
		dir = 1;
		x = 2;
		break;
	case 1:
		dir = 0xff;
		x = 0xff;
		break;
	case 3:
		dir = 3;
		x = 4;
		break;
	}
	for (i = 0; i < r[1]; i++) {
		NM_E(r, i)->e4 = 0;
		if (NM_E(r, i)->e1 != 0) {
			n = NM_E(r, i)->e0;
			NM_E(r, i)->e2 = n;
			if (Note_CheckTransposeRange((unsigned char)lk1, (unsigned char)lk2) == 0) {
				if (t != 0) {
					if ((n += t) > 127) {
						if (t > 0) {
							while ((x = n) > 127)
								n -= 12;
						} else {
							while ((signed char)n < 0)
								n += 12;
						}
					}
				}
				if (n >= 120)
					n = 0xff;
			} else if (dir != 0xff)
				n = SndParam_LookupByChannel(dir, (unsigned char)lk1, (unsigned char)lk2, n);
			NM_E(r, i)->e3 = n;
		}
	}
}
