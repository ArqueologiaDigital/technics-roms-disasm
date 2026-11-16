/* Phase 6, lane_p6 helper E, round 10, module 237 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   sequencer/smf_event_processor.s (built -Xr, cdecl), under the firmware names.  Form a; p6_E_10m237b.c has the
   same name.  SeqStep_FileSeekCleanup: see p6_E_9m237.c.  Round 9 form b (src declared before the result) was
   +36 in run 118, with two spots against the ROM:
   - the ROM's `return -1` for an error other than 13 after the failed "r" open comes AFTER the "d" retry: it is the
     else of `if (FILE_ERROR == 13) { ...retry... }`;
   - the volume compare: the ROM loads dst's volume into XBC and compares it with src's in memory; V4.23 loaded the
     right-hand operand into the register, so the compare is written `a->vol != b->vol` (form b keeps round 9's
     order, to separate the two changes). */
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
