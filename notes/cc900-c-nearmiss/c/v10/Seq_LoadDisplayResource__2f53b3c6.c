/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_8m265a.c (2026-11-19-68-p6-r52)
   sha256 2f53b3c6dd43ce00b884c63308be6919970f41edc1c43c927d07a5859c2d34b2 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SldrStrPre=Seq_LoadResource_Proceed_Str_PRE
   cc900-name: SldrStrPres=Seq_LoadResource_Proceed_Str_PRESENTATION */
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
int Seq_LoadDisplayResource(char *name)
{
	struct nb32 b;
	int r;

	b = Seq_LoadDisplayResource_NameBufInit;
	switch ((unsigned int)GetDiskSizeInfo()) {
	case 0:
	case 5:
		return -7;
	case 1:
		return -8;
	default:
		if ((r = GetEncodedFileSizeData()) < 0)
			return r;
	}
	Strcat(b.s, name);
	Strcat(b.s, SldrStrPre);
	if ((r = FileIO_OpenWithMode(b.s, Seq_LoadResource_Proceed_Str_rt)) < 0)
		return r;
	FDemoText_ReadTaggedBlock((void *)0x248c8L, 0x100, Presentation_TagStrTable, SldrStrPres);
	return FileIO_CloseHandle();
}
