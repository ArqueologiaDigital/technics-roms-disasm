/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m203b.c (2026-11-22-11-p6-r78)
   sha256 e6a3dfc047599489e74f925e041bbdfdda9dd8a268ddfb80c0aa5c6e741811f4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern char __near ram_1c2c[];
extern unsigned char __near ram_1155;
extern int SeqState_GetFlags(void);
extern int FileIO_GetCurrentFileIndex_Alt(void);
extern char *FileIO_GetFileEntryByIndex(int);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern int Acc_LoadAndStartPlayback(int);
extern void SongMode_VoiceStateDisp(int);
extern void SeqRecPlay_EnableRecordOnly(void);
void CDlikeSwTtl_ShowDocTitle(void)
{
	register char *p;
	int r;

	if (SeqState_GetFlags() & 1)
		return;
	Strncpy(ram_1c2c, FileIO_GetFileEntryByIndex(FileIO_GetCurrentFileIndex_Alt()), 12);
	p = ram_1c2c;
	p[12] = 0;
	if ((r = Acc_LoadAndStartPlayback(2)) != 0)
		SongMode_VoiceStateDisp(r);
	else {
		SeqRecPlay_EnableRecordOnly();
		ram_1155 = 0;
	}
}
