/* Phase 6, lane_p6 helper L, round 9, form a: module 265 (demo/fdemotext_routines.s).  Retry of
   Seq_LoadDisplayResource (r52 O3Xr +28): right up to the switch; the ROM places the default body (the encoded
   file size check, falling through to the open) right after the compares and the -7 / -8 returns after it: the
   default written FIRST (as SetWallColor). */
/* cc900-module: FDemoText_ReadTaggedBlock */   /* scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: SldrStrPre=Seq_LoadResource_Proceed_Str_PRE */
/* cc900-name: SldrStrPres=Seq_LoadResource_Proceed_Str_PRESENTATION */
struct nb32 { char s[32]; };
extern struct nb32 Seq_LoadDisplayResource_NameBufInit;
extern char SldrStrPre[];
extern char Seq_LoadResource_Proceed_Str_rt[];
extern char SldrStrPres[];
extern char Presentation_TagStrTable[];
extern unsigned char GetDiskSizeInfo(void);
extern int GetEncodedFileSizeData(void);
extern char *__cdecl Strcat(char *, char *);
extern int FileIO_OpenWithMode(char *name, char *mode);
extern void FDemoText_ReadTaggedBlock(void *dst, long n, char *tbl, char *tag);
extern int FileIO_CloseHandle(void);
extern int Seq_LoadDisplayResource(char *name);

int Seq_LoadDisplayResource(char *name)
{
	struct nb32 b;
	int r;

	b = Seq_LoadDisplayResource_NameBufInit;
	switch ((unsigned int)GetDiskSizeInfo()) {
	default:
		if ((r = GetEncodedFileSizeData()) < 0)
			return r;
		break;
	case 0:
	case 5:
		return -7;
	case 1:
		return -8;
	}
	Strcat(b.s, name);
	Strcat(b.s, SldrStrPre);
	if ((r = FileIO_OpenWithMode(b.s, Seq_LoadResource_Proceed_Str_rt)) < 0)
		return r;
	FDemoText_ReadTaggedBlock((void *)0x248c8L, 0x100, Presentation_TagStrTable, SldrStrPres);
	return FileIO_CloseHandle();
}
