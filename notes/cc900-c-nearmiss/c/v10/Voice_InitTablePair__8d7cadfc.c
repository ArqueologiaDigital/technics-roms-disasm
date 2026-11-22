/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m295a.c (2026-11-22-9-p6-r76)
   sha256 8d7cadfc6dee516dc7a5a705c0bbc07bdb024f08213bd95e58d130f9ffee20e2 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: NoteMap_LookupAllocStoreResult=NoteMap_LookupAllocAndStoreResult */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE[];
extern unsigned char RhythmMidi_SeqEvtMap[];
extern void NoteMap_LookupAllocStoreResult(struct nrec *, unsigned char *, unsigned char);
void Voice_InitTablePair(void)
{
	unsigned char *p;
	struct nrec r;
	unsigned char n;

	p = AUDIO_STATE;
	r.b0 = 0x90;
	r.b2 = 5;
	for (n = 0; n < 2; n++) {
		r.b3 = n;
		NoteMap_LookupAllocStoreResult(&r, p, RhythmMidi_SeqEvtMap[n]);
	}
}
