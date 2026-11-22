/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_28r1m203a.c (2026-11-22-9-p6-r76)
   sha256 d59f97daab99365d9c7358d641e1b464edc3536b5340017f43433075d3b11f03 (tar-sha256); compiled at -O3 -Xr
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
