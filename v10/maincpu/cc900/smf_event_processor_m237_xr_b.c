/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FileOpenDefault SeqStep_FileSeekError */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern int __cdecl SeqStep_FileSeekCleanup(char *src, char *dst);

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
	if (a->vol != b->vol) {
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
