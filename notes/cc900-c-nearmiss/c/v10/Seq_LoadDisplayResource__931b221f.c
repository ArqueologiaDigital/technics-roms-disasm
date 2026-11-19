/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_7m265a.c (2026-11-19-56-p6-r51)
   sha256 931b221fe95e3ce85384aa3ec27c9c590841a6f054203e7f61734b1a3f8e7f09 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SldrStrPre=Seq_LoadResource_Proceed_Str_PRE
   cc900-name: SldrStrPres=Seq_LoadResource_Proceed_Str_PRESENTATION */
struct nb16 { char s[16]; };
extern struct nb16 Seq_LoadDisplayResource_NameBufInit;
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
	struct nb16 b;
	int r;

	b = Seq_LoadDisplayResource_NameBufInit;
	switch (GetDiskSizeInfo()) {
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
