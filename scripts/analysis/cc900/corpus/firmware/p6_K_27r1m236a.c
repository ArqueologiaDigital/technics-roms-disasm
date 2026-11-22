/* lane_p6 helper K, round 27r1, form a: module 236 (sequencer/smf_event_processor.s), family of 2 x 73 B:
   FileRead / FileWrite, the fread / fwrite of the firmware's file layer (__cdecl: buf, size, count, file).
   A closed or null file sets FILE_ERROR 0x11, a file not open for reading (bit 0) / writing (bit 1) 0x0d, both
   return 0; else the driver's read / write entry (ops + 4 / + 12) gets (file, buf, size * count) and the result
   is divided by size.  The descriptor is the struct fd of the built smf_event_processor_m236_xr.c.
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
	return fp->ops->read(fp, buf, size * n) / size;
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
	return fp->ops->write(fp, buf, size * n) / size;
}
