/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_30r1m203a.c (2026-11-22-13-p6-r80)
   sha256 e0153b79ea66bb23181ca309e013d5b0d6431dd04ce5cc1124dcf831a5d37093 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern char __near ram_1c3a[];
extern unsigned char __near ram_1155;
extern int SeqState_GetFlags(void);
extern int GetCurrentFileIndexAlt(void);
extern char *GetFileRecordPtr(int);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern int Acc_LoadAndStartPlayback(int);
extern void SongMode_VoiceStateDisp(int);
extern void SeqRecPlay_EnableRecordOnly(void);
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
