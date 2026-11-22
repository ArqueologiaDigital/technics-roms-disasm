/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m236b.c (2026-11-22-7-p6-r74)
   sha256 9c1c12b831bf496657f74179c7a6a62457e3479dbb9a03372fb214bc3e764506 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct fd;
typedef int __cdecl IOFN(struct fd *, void *, unsigned int);
struct ops { char pad[4]; IOFN *read; char pad1[4]; IOFN *write; };
struct fd { char p0[4]; unsigned char open; unsigned char slot; char p6[8]; struct ops *ops; };
extern int FILE_ERROR;
int __cdecl FileWrite(void *buf, unsigned int size, unsigned int n, struct fd *fp)
{
	if (fp == 0 || fp->open == 0) {
		FILE_ERROR = 0x11;
		return 0;
	}
	if (!(fp->open & 2)) {
		FILE_ERROR = 0x0d;
		return 0;
	}
	return (unsigned long)(long)fp->ops->write(fp, buf, size * n) / size;
}
