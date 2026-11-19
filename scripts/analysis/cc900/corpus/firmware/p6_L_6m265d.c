/* Phase 6, lane_p6 helper L, round 6, file d of module 265 (demo/fdemotext_routines.s, like 6m265c; a separate file
   so a failure of one does not cost the other).
   - Seq_LoadDisplayResource: a 16-byte name buffer initialised from Seq_LoadDisplayResource_NameBufInit (struct
     copy: ld xiy, imm + ldirw, as the matched GraphicsRender tables); disk state 0 / 5 -> -7, 1 -> -8 (a switch,
     compared 1, 5, 0: last case first, default written last); a negative encoded file size returned as is; the
     name + "PRE" appended (two __cdecl Strcat, one stack clean-up), opened "rt", its PRESENTATION block read into
     0x248c8, closed; the close's result returned. */
/* cc900-module: FDemoText_ReadTaggedBlock */   /* scripts/analysis/cc900/module_calls.py v10 */

struct nb16 { char s[16]; };
extern struct nb16 Seq_LoadDisplayResource_NameBufInit;
extern char Seq_LoadResource_Proceed_Str_PRE[];
extern char Seq_LoadResource_Proceed_Str_rt[];
extern char Seq_LoadResource_Proceed_Str_PRESENTATION[];
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
	Strcat(b.s, Seq_LoadResource_Proceed_Str_PRE);
	if ((r = FileIO_OpenWithMode(b.s, Seq_LoadResource_Proceed_Str_rt)) < 0)
		return r;
	FDemoText_ReadTaggedBlock((void *)0x248c8L, 0x100, Presentation_TagStrTable, Seq_LoadResource_Proceed_Str_PRESENTATION);
	return FileIO_CloseHandle();
}
