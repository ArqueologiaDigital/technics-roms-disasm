/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m203c.c (2026-11-22-11-p6-r78)
   sha256 e974d1013336982f345ab9e61851105dec2d18c81610942db574ae87adfd28e5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct t12 { char s[12]; char z; };
#define EVT_LYRICS_PLAY_START_INI 0x1c70010L
extern struct t12 __near ram_1c1e;
extern unsigned char __near ram_1155;
extern int SeqState_GetFlags(void);
extern long ApPostEvent(long, long, long);
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
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
	p = &ram_1c1e;
	Strncpy(p->s, GetRecordPtrForFile(GetFirstPageBase()), 12);
	p->z = 0;
	if ((r = Acc_LoadAndStartPlayback(1)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}
