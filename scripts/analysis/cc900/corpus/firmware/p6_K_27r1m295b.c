/* lane_p6 helper K, round 27r1, form b (form a without the register keyword): module 295 (audio/note_voice_mapping.s), family of 2 x 81 B:
   Voice_InitTablePair / Voice_InitTableGroup.  A 164-byte note record on the stack (the struct nrec of the built
   note_voice_mapping_m297_xr.c) with b0 = 0x90, b2 = 5 / 4; for parts 0..1 / 0..4 b3 = part and the part's map
   byte (RhythmMidi_SeqEvtMap / RhythmMidi_StatusMap) goes to the voice lookup with AUDIO_STATE.  -Xr (the
   constant loop is pre-tested); the part counter is a register byte (QIZ).
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
