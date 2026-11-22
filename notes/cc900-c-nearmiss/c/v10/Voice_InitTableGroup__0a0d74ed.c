/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m295b.c (2026-11-22-9-p6-r76)
   sha256 0a0d74eda895fbf8d594934931dabaf99c116fed9b7361f8df8da620e7638622 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE[];
extern unsigned char RhythmMidi_StatusMap[];
extern void NoteMap_LookupAndAllocVoice();
void Voice_InitTableGroup(void)
{
	unsigned char *p;
	struct nrec r;
	unsigned char n;

	p = AUDIO_STATE;
	r.b0 = 0x90;
	r.b2 = 4;
	for (n = 0; n < 5; n++) {
		r.b3 = n;
		NoteMap_LookupAndAllocVoice(&r, p, RhythmMidi_StatusMap[n]);
	}
}
