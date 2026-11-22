/* lane_p6 helper L, round 28r1, form a: module 203 (ui/ui_playback_modes.s), the CD-like title starters
   CDlikeSwTtl_ShowPdTitle / CDlikeSwTtl_ShowDocTitle (families28_L, 2 x 68 B) and their twin
   CDlikeSwTtl_ShowSongTitle (p6_N_8m203a, run p6-r52: +53; p6_N_9m203a never assembled): unless the sequencer
   state says otherwise, copy the current file's title (20 / 12 / 12 characters) into its RAM buffer (0x1c3a /
   0x1c2c / 0x1c1e), terminate it, load and start the file (Acc_LoadAndStartPlayback 4 / 2 / 1), and on failure
   hand the error code to SongMode_VoiceStateDisp (a conditional tail jump; it tests WA against -1 / -2 / -4), else
   enable record-only and clear 0x1155.
   r52's two spots: the terminator, which the ROM stores through `lda xbc, (buf:16)` + n (the address of a __near
   object kept in a register: a pointer local, as in round 27r1's slot-table fills), and the start result, which the
   ROM copies to WA before the compare: SongMode_VoiceStateDisp takes it as its argument.
   Form a: the pointer local assigned after the copy, the result in an int local tested on its own line.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqRecPlay_EnableRecordOnly */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_LYRICS_PLAY_START_INI 0x1c70010L
extern char __near ram_1c1e[];
extern char __near ram_1c2c[];
extern char __near ram_1c3a[];
extern unsigned char __near ram_1155;
extern int SeqState_GetFlags(void);
extern long ApPostEvent(long, long, long);
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_GetCurrentFileIndex_Alt(void);
extern char *FileIO_GetFileEntryByIndex(int);
extern int GetCurrentFileIndexAlt(void);
extern char *GetFileRecordPtr(int);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern int Acc_LoadAndStartPlayback(int);
extern void SongMode_VoiceStateDisp(int);
extern void SeqRecPlay_EnableRecordOnly(void);

void CDlikeSwTtl_ShowSongTitle(void)
{
	char *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	ApPostEvent(0x720006L, EVT_LYRICS_PLAY_START_INI, 0L);
	Strncpy(ram_1c1e, GetRecordPtrForFile(GetFirstPageBase()), 12);
	p = ram_1c1e;
	p[12] = 0;
	r = Acc_LoadAndStartPlayback(1);
	if (r != 0) {
		SongMode_VoiceStateDisp(r);
		return;
	}
	SeqRecPlay_EnableRecordOnly();
	ram_1155 = 0;
}

void CDlikeSwTtl_ShowDocTitle(void)
{
	char *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c2c, FileIO_GetFileEntryByIndex(FileIO_GetCurrentFileIndex_Alt()), 12);
	p = ram_1c2c;
	p[12] = 0;
	r = Acc_LoadAndStartPlayback(2);
	if (r != 0) {
		SongMode_VoiceStateDisp(r);
		return;
	}
	SeqRecPlay_EnableRecordOnly();
	ram_1155 = 0;
}

void CDlikeSwTtl_ShowPdTitle(void)
{
	char *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c3a, GetFileRecordPtr(GetCurrentFileIndexAlt()), 20);
	p = ram_1c3a;
	p[20] = 0;
	r = Acc_LoadAndStartPlayback(4);
	if (r != 0) {
		SongMode_VoiceStateDisp(r);
		return;
	}
	SeqRecPlay_EnableRecordOnly();
	ram_1155 = 0;
}
