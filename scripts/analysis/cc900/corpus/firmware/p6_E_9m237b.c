/* Phase 6, lane_p6 helper E, round 9, module 237 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   sequencer/smf_event_processor.s (built -Xr, cdecl), under the firmware names.  FORM B of p6_E_9m237.c (form a):
   src's handle declared before the result.
   SeqStep_FileSeekCleanup(src, dst): opens src for reading (mode "r", else, when the error is 13, mode "d"), then
   checks that dst does not exist ("r" must fail: else error 21) and creates it ("a"); both must be on the same
   volume (file +18; else dst is removed with FileOpenDefault and the error is 26).  Then SeqStep_FileSeekError
   copies src to dst; both are closed and its result returned.  -1 on any failure.  As the ROM: when the "d"
   open fails with an error other than 13 it goes on with a null src.
   The ROM keeps dst's handle in XIZ, src's on the stack (+4) and the result at +8 (form a declares the result
   first, for the higher slot; form b declares src first).  The mode strings are the tree's labels. */
/* cc900-module: FileOpenDefault SeqStep_FileSeekError */

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
		if (FILE_ERROR != 13)
			return -1;
		FILE_ERROR = 0;
		a = FileOpen(src, SeqStep_FileSeekCleanup_Str_d);
		if (a == 0 && FILE_ERROR == 13)
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
