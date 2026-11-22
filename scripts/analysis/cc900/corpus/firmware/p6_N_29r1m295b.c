/* lane_p6 helper N, round 29r1, form b: module 295 (audio/note_voice_mapping.s), family of 2 x 87 B:
   Voice_InitTablePair / Voice_InitTableGroup.  One-spot retry of helper M's p6_M_28r1m295c / K's p6_K_27r1m295b
   (runs r76 / r74, Xr, +30: the ROM loads the part's map byte straight into E before it computes &r into XWA and
   extends DE after that, where V4.23 computed &r first, parked it in XHL and loaded the byte through A).
   Here the map byte is a char local assigned on its own line (-Xr homing it in E, the third argument's register).
   Form b: the record a struct nrec (K's form b), the byte local m declared last.
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
	unsigned char m;

	p = AUDIO_STATE;
	r.b0 = 0x90;
	r.b2 = 5;
	for (n = 0; n < 2; n++) {
		r.b3 = n;
		m = RhythmMidi_SeqEvtMap[n];
		NoteMap_LookupAllocStoreResult(&r, p, m);
	}
}

void Voice_InitTableGroup(void)
{
	unsigned char *p;
	struct nrec r;
	unsigned char n;
	unsigned char m;

	p = AUDIO_STATE;
	r.b0 = 0x90;
	r.b2 = 4;
	for (n = 0; n < 5; n++) {
		r.b3 = n;
		m = RhythmMidi_StatusMap[n];
		NoteMap_LookupAndAllocVoice(&r, p, m);
	}
}
