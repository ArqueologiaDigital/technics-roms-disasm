/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/smf_event_processor_m0_xr.c (2026-11-16-91-p6-r17)
   sha256 5b788e5537c92d3bd7fe0368f0e4e88a18a5e940fb1cf95a53dbff398072bce3 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct buf;
struct file;
typedef int __cdecl SECFN(long, struct buf *);
typedef int __cdecl FILEFN(struct file *);
struct ops { char pad[20]; SECFN *wsec; char pad2[4]; FILEFN *f28; FILEFN *f32; };
struct file { char pad[14]; struct ops *ops; };
struct geom { char pad[48]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[14]; struct ops *ops; char pad2[8]; struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
extern struct file *__cdecl FileOpen(char *, char *);
extern int __cdecl FileClose(struct file *);
extern int FILE_ERROR;
extern char SeqStep_ByteBlockF245_Str_d[];
extern char SeqStep_ByteBlockF245_Str_wb[];
int __cdecl SeqStep_ByteBlockF245(char *name)
{
	struct file *fp;
	int e;
	int r;

	e = FILE_ERROR;
	FILE_ERROR = 0;
	fp = FileOpen(name, SeqStep_ByteBlockF245_Str_d);
	if (fp != 0) {
		FileClose(fp);
		FILE_ERROR = 21;
		return -1;
	}
	if (FILE_ERROR != 5)
		return -1;
	FILE_ERROR = (char)e;
	fp = FileOpen(name, SeqStep_ByteBlockF245_Str_wb);
	if (fp == 0)
		return -1;
	r = fp->ops->f28(fp);
	FileClose(fp);
	return r;
}
