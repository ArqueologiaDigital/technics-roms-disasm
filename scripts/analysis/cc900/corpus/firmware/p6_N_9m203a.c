/* lane_p6 helper N, round 9, form a: module 203 (ui/ui_playback_modes.s), retry of p6_N_8m203a
   (p6-r52 O3Xr: +53).  CDlikeSwTtl_ShowSongTitle: the listing was the ROM's code except two spots -- the title's
   terminator, which the ROM stores through `lda xbc,(0x1c1e:16)` + 12 (a constant pointer at -O3) where V4.23
   stored to `ram_1c1e + 12` directly, and the start result, which the ROM copies to WA before the compare.
   Form a: the terminator through a constant pointer, the result tested on an assignment to an int local.
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
	((char *)0x1c1e)[12] = 0;
	r = Acc_LoadAndStartPlayback(1);
	if (r != 0) {
		SongMode_VoiceStateDisp();
		return;
	}
	SeqRecPlay_EnableRecordOnly();
	ram_1155 = 0;
}
