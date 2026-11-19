/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_8m203a.c (2026-11-19-68-p6-r52)
   sha256 5ea0691cbfc08685659f1f1bf6a783e9a0e623ce99ad8ff96443efd3f442f67d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_LYRICS_PLAY_START_INI 0x1c70010L
extern char __near ram_1c1e[];
extern unsigned char __near ram_1155;
extern int SeqState_GetFlags(void);
extern long ApPostEvent(long, long, long);
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern int Acc_LoadAndStartPlayback(int);
extern void SongMode_VoiceStateDisp(void);
extern void SeqRecPlay_EnableRecordOnly(void);
void CDlikeSwTtl_ShowSongTitle(void)
{
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	ApPostEvent(0x720006L, EVT_LYRICS_PLAY_START_INI, 0L);
	Strncpy(ram_1c1e, GetRecordPtrForFile(GetFirstPageBase()), 12);
	ram_1c1e[12] = 0;
	if ((r = Acc_LoadAndStartPlayback(1)) != 0) {
		SongMode_VoiceStateDisp();
		return;
	}
	SeqRecPlay_EnableRecordOnly();
	ram_1155 = 0;
}
