/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_29r1m203a.c (2026-11-22-11-p6-r78)
   sha256 d00dfb02534695448eec75e47202c7038c8fb04c8dacb67816a9aa1961164e31 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct t12 { char s[12]; char z; };
extern struct t12 __near ram_1c2c;
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
