/* lane_p6 helper M, round 28r1, form c: module 236 (sequencer/smf_event_processor.s), family of 2 x 73 B:
   FileRead / FileWrite.  One-spot retry of helper K's p6_K_27r1m236b (run r74, Xr equal to +43: the ROM
   multiplies size * count with muls and divides the driver's sign-extended result with divs, where V4.23
   used mul / div).  K's form b with size and count unsigned as before, the product and quotient cast to int.
   cc900-options: -Xr
*/

struct fd;
typedef int __cdecl IOFN(struct fd *, void *, unsigned int);
struct ops { char pad[4]; IOFN *read; char pad1[4]; IOFN *write; };
struct fd { char p0[4]; unsigned char open; unsigned char slot; char p6[8]; struct ops *ops; };
extern int FILE_ERROR;
extern int __cdecl FileRead(void *buf, unsigned int size, unsigned int n, struct fd *fp);
extern int __cdecl FileWrite(void *buf, unsigned int size, unsigned int n, struct fd *fp);

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
	return fp->ops->read(fp, buf, (int)size * (int)n) / (int)size;
}

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
	return fp->ops->write(fp, buf, (int)size * (int)n) / (int)size;
}
