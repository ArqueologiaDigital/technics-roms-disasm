/* lane_p6 helper M, round 28r1, form c: module 295 (audio/note_voice_mapping.s), family of 2 x 87 B:
   Voice_InitTablePair / Voice_InitTableGroup.  One-spot retry of helper K's p6_K_27r1m295b (run r74, Xr
   equal to +30: the ROM loads the map byte, the third argument, first and then &r straight into XWA, where
   V4.23 computed &r first and parked it in XHL).  K's form b with the record a 164-byte array (passed by decay, no & operator).
   cc900-options: -Xr
*/
/* cc900-name: NoteMap_LookupAllocStoreResult=NoteMap_LookupAllocAndStoreResult */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
extern unsigned char __near AUDIO_STATE[];
extern unsigned char RhythmMidi_SeqEvtMap[];
extern unsigned char RhythmMidi_StatusMap[];
extern void NoteMap_LookupAllocStoreResult(void *, unsigned char *, unsigned char);
extern void NoteMap_LookupAndAllocVoice(void *, unsigned char *, unsigned char);

void Voice_InitTablePair(void)
{
	unsigned char *p;
	unsigned char r[164];
	unsigned char n;

	p = AUDIO_STATE;
	r[0] = 0x90;
	r[2] = 5;
	for (n = 0; n < 2; n++) {
		r[3] = n;
		NoteMap_LookupAllocStoreResult(r, p, RhythmMidi_SeqEvtMap[n]);
	}
}

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
