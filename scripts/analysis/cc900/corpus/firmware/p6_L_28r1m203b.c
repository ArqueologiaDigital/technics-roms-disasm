/* lane_p6 helper L, round 28r1, form b: module 203 (ui/ui_playback_modes.s), CDlikeSwTtl_ShowPdTitle /
   CDlikeSwTtl_ShowDocTitle and their twin CDlikeSwTtl_ShowSongTitle (see p6_L_28r1m203a.c).
   Form b: the result assigned inside the test (`(r = ...) != 0`), the terminator through a pointer local whose
   assignment is the indexed expression itself, the failure branch as if / else.
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
	(p = ram_1c1e)[12] = 0;
	if ((r = Acc_LoadAndStartPlayback(1)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}

void CDlikeSwTtl_ShowDocTitle(void)
{
	char *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c2c, FileIO_GetFileEntryByIndex(FileIO_GetCurrentFileIndex_Alt()), 12);
	(p = ram_1c2c)[12] = 0;
	if ((r = Acc_LoadAndStartPlayback(2)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}

void CDlikeSwTtl_ShowPdTitle(void)
{
	char *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c3a, GetFileRecordPtr(GetCurrentFileIndexAlt()), 20);
	(p = ram_1c3a)[20] = 0;
	if ((r = Acc_LoadAndStartPlayback(4)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}
