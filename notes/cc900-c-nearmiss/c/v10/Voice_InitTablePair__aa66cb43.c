/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m295a.c (2026-11-22-7-p6-r74)
   sha256 aa66cb43ba2207b3eef0d6be27ae0b046939d3d0e036ab2b6e8e92740464ff1b (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: NoteMap_LookupAllocStoreResult=NoteMap_LookupAllocAndStoreResult */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE[];
extern unsigned char RhythmMidi_SeqEvtMap[];
extern void NoteMap_LookupAllocStoreResult(void *, unsigned char *, unsigned char);
void Voice_InitTablePair(void)
{
	unsigned char *p;
	struct nrec r;
	register unsigned char n;

	p = AUDIO_STATE;
	r.b0 = 0x90;
	r.b2 = 5;
	for (n = 0; n < 2; n++) {
		r.b3 = n;
		NoteMap_LookupAllocStoreResult(&r, p, RhythmMidi_SeqEvtMap[n]);
	}
}
