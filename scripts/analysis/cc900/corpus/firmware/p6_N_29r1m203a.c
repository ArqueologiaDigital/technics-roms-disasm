/* lane_p6 helper N, round 29r1, form a: module 203 (ui/ui_playback_modes.s), CDlikeSwTtl_ShowSongTitle /
   CDlikeSwTtl_ShowDocTitle / CDlikeSwTtl_ShowPdTitle.  One-spot retry of helper L's p6_L_28r1m203b (run r76,
   O3Xr, +53 / +37 / +37, equal but for the title terminator: the ROM keeps the buffer's address in XBC,
   `lda xbc, (buf:16); ld (xbc+n), 0`, where V4.23 folded it to an absolute store).  L's form b with struct objects, a struct pointer set after the copy, p->z = 0.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqRecPlay_EnableRecordOnly */   /* scripts/analysis/cc900/module_calls.py v10 */

struct t12 { char s[12]; char z; };
struct t20 { char s[20]; char z; };
#define EVT_LYRICS_PLAY_START_INI 0x1c70010L
extern struct t12 __near ram_1c1e;
extern struct t12 __near ram_1c2c;
extern struct t20 __near ram_1c3a;
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
	struct t12 *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	ApPostEvent(0x720006L, EVT_LYRICS_PLAY_START_INI, 0L);
	Strncpy(ram_1c1e.s, GetRecordPtrForFile(GetFirstPageBase()), 12);
	p = &ram_1c1e;
	p->z = 0;
	if ((r = Acc_LoadAndStartPlayback(1)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}

void CDlikeSwTtl_ShowDocTitle(void)
{
	struct t12 *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c2c.s, FileIO_GetFileEntryByIndex(FileIO_GetCurrentFileIndex_Alt()), 12);
	p = &ram_1c2c;
	p->z = 0;
	if ((r = Acc_LoadAndStartPlayback(2)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}

void CDlikeSwTtl_ShowPdTitle(void)
{
	struct t20 *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c3a.s, GetFileRecordPtr(GetCurrentFileIndexAlt()), 20);
	p = &ram_1c3a;
	p->z = 0;
	if ((r = Acc_LoadAndStartPlayback(4)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}
