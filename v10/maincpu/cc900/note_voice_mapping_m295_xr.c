/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char __near AUDIO_STATE[];
extern unsigned char RhythmMidi_StatusMap[];
extern void NoteMap_LookupAndAllocVoice(void *, unsigned char *, unsigned char);
extern void Voice_InitTableGroup(void);
extern unsigned char RhythmMidi_SeqEvtMap[];
extern void NoteMap_LookupAllocStoreResult(void *, unsigned char *, unsigned char);
extern void Voice_InitTablePair(void);

void Voice_InitTableGroup(void)
{
	unsigned char *p;
	unsigned char r[164];
	unsigned char n;
	unsigned char m;

	p = AUDIO_STATE;
	r[0] = 0x90;
	r[2] = 4;
	for (n = 0; n < 5; n++) {
		r[3] = n;
		m = RhythmMidi_StatusMap[n];
		NoteMap_LookupAndAllocVoice(r, p, m);
	}
}

/* cc900-name: NoteMap_LookupAllocStoreResult=NoteMap_LookupAllocAndStoreResult */
void Voice_InitTablePair(void)
{
	unsigned char *p;
	unsigned char r[164];
	unsigned char n;
	unsigned char m;

	p = AUDIO_STATE;
	r[0] = 0x90;
	r[2] = 5;
	for (n = 0; n < 2; n++) {
		r[3] = n;
		m = RhythmMidi_SeqEvtMap[n];
		NoteMap_LookupAllocStoreResult(r, p, m);
	}
}
