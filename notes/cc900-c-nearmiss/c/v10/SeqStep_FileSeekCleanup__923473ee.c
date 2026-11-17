/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_10m237b.c (2026-11-16-123-p6-r25)
   sha256 923473eea910a6cfce9e4fe59ac085ba28c7015bc566b17b0c54dbdb437e2e99 (tar-sha256); compiled at -O3 -Xr */
struct vol2;
struct file { char pad[14]; void *ops; struct vol2 *vol; };
extern struct file *__cdecl FileOpen(char *, char *);
extern int __cdecl FileClose(struct file *);
extern int __cdecl FileOpenDefault(char *name);
extern int __cdecl SeqStep_FileSeekError(struct file *src, struct file *dst);
extern int FILE_ERROR;
extern char SeqStep_FileSeekCleanup_Str_r[];
extern char SeqStep_FileSeekCleanup_Str_d[];
extern char SeqStep_FileTellReturn_Str_r[];
extern char SeqStep_FileTellProcess_Str_a[];
int __cdecl SeqStep_FileSeekCleanup(char *src, char *dst)
{
	struct file *a;
	int r;
	struct file *b;

	a = FileOpen(src, SeqStep_FileSeekCleanup_Str_r);
	if (a == 0) {
		if (FILE_ERROR == 13) {
			FILE_ERROR = 0;
			a = FileOpen(src, SeqStep_FileSeekCleanup_Str_d);
			if (a == 0 && FILE_ERROR == 13)
				return -1;
		} else
			return -1;
	}
	b = FileOpen(dst, SeqStep_FileTellReturn_Str_r);
	if (b != 0) {
		FileClose(a);
		FileClose(b);
		FILE_ERROR = 21;
		return -1;
	}
	FILE_ERROR = 0;
	b = FileOpen(dst, SeqStep_FileTellProcess_Str_a);
	if (b == 0) {
		FileClose(a);
		return -1;
	}
	if (b->vol != a->vol) {
		FileClose(a);
		FileClose(b);
		FileOpenDefault(dst);
		FILE_ERROR = 26;
		return -1;
	}
	r = SeqStep_FileSeekError(a, b);
	FileClose(a);
	FileClose(b);
	return r;
}
