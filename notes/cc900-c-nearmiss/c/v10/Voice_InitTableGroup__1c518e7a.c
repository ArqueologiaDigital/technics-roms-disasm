/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m295c.c (2026-11-22-9-p6-r76)
   sha256 1c518e7a73109db18157619fb1050ff8982583a0e246216a8db6fe7e19f2cd10 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near AUDIO_STATE[];
extern unsigned char RhythmMidi_StatusMap[];
extern void NoteMap_LookupAndAllocVoice(void *, unsigned char *, unsigned char);
void Voice_InitTableGroup(void)
{
	unsigned char *p;
	unsigned char r[164];
	unsigned char n;

	p = AUDIO_STATE;
	r[0] = 0x90;
	r[2] = 4;
	for (n = 0; n < 5; n++) {
		r[3] = n;
		NoteMap_LookupAndAllocVoice(r, p, RhythmMidi_StatusMap[n]);
	}
}
