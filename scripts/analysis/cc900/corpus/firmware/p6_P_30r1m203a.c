/* lane_p6 helper P, round 30r1, form a: module 203 (ui/ui_playback_modes.s), CDlikeSwTtl_ShowSongTitle /
   CDlikeSwTtl_ShowDocTitle / CDlikeSwTtl_ShowPdTitle.  One-spot retry of helper N's p6_N_29r1m203b (run r78, O3Xr,
   +53 / +37 / +37: equal but for the title terminator, which the ROM stores through `lda xbc, (buf:16)` +
   `ld (xbc+n), 0` where every pointer spelling so far folded to an absolute store).  Form a: lane_hd's integer
   idiom, the terminator's address written as an integer, *(char *)((unsigned long)buf + n) = 0.
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
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	ApPostEvent(0x720006L, EVT_LYRICS_PLAY_START_INI, 0L);
	Strncpy(ram_1c1e, GetRecordPtrForFile(GetFirstPageBase()), 12);
	*(char *)((unsigned long)ram_1c1e + 12) = 0;
	if ((r = Acc_LoadAndStartPlayback(1)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}

void CDlikeSwTtl_ShowDocTitle(void)
{
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c2c, FileIO_GetFileEntryByIndex(FileIO_GetCurrentFileIndex_Alt()), 12);
	*(char *)((unsigned long)ram_1c2c + 12) = 0;
	if ((r = Acc_LoadAndStartPlayback(2)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}

void CDlikeSwTtl_ShowPdTitle(void)
{
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c3a, GetFileRecordPtr(GetCurrentFileIndexAlt()), 20);
	*(char *)((unsigned long)ram_1c3a + 20) = 0;
	if ((r = Acc_LoadAndStartPlayback(4)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}
