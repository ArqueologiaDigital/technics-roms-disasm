/* lane_p6 helper N, round 8, form a: module 203 (ui/ui_playback_modes.s), new function.
   CDlikeSwTtl_ShowSongTitle: unless the sequencer state says otherwise, starts the lyric player, copies the
   current file's 12-character title into 0x1c1e (terminated), loads and starts the song, and either shows the
   voice state (failure, conditional tail jump) or enables record-only and clears 0x1155.  The __cdecl Strncpy's
   arguments are pushed right to left while the source call runs between them (12 first, then the title, then
   the destination pushed in word halves: an extern object).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqRecPlay_EnableRecordOnly */

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
