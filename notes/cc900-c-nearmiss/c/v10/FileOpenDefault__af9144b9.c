/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_1b.c (2026-11-16-53-p6-r11)
   sha256 af9144b9a9bddfd9059a29fa80db190b75b8eb25bbb020704296290ca40e1b5a (tar-sha256); compiled at -O3 -Xr */
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
extern char FileOpenDefault_Str_w[];
int __cdecl FileOpenDefault(char *name)
{
	struct file *fp;

	if ((fp = FileOpen(name, FileOpenDefault_Str_w)) == 0)
		return -1;
	return fp->ops->f32(fp);
}
