/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m236a.c (2026-11-22-7-p6-r74)
   sha256 e1b45e15e26ec46b421013d28a2345d2eed435a88914690c55ab57e00cf9717b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct fd;
typedef int __cdecl IOFN(struct fd *, void *, unsigned int);
struct ops { char pad[4]; IOFN *read; char pad1[4]; IOFN *write; };
struct fd { char p0[4]; unsigned char open; unsigned char slot; char p6[8]; struct ops *ops; };
extern int FILE_ERROR;
int __cdecl FileRead(void *buf, unsigned int size, unsigned int n, struct fd *fp)
{
	if (fp == 0 || fp->open == 0) {
		FILE_ERROR = 0x11;
		return 0;
	}
	if (!(fp->open & 1)) {
		FILE_ERROR = 0x0d;
		return 0;
	}
	return fp->ops->read(fp, buf, size * n) / size;
}
