/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m295a.c (2026-11-22-7-p6-r74)
   sha256 aa66cb43ba2207b3eef0d6be27ae0b046939d3d0e036ab2b6e8e92740464ff1b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE[];
extern unsigned char RhythmMidi_StatusMap[];
extern void NoteMap_LookupAndAllocVoice(void *, unsigned char *, unsigned char);
void Voice_InitTableGroup(void)
{
	unsigned char *p;
	struct nrec r;
	register unsigned char n;

	p = AUDIO_STATE;
	r.b0 = 0x90;
	r.b2 = 4;
	for (n = 0; n < 5; n++) {
		r.b3 = n;
		NoteMap_LookupAndAllocVoice(&r, p, RhythmMidi_StatusMap[n]);
	}
}
