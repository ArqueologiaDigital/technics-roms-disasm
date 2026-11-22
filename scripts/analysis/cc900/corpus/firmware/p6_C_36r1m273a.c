/* Probe round 36r1, helper C, form a: ui/ui_window_procs.s (module 273), the xr_screen.py shape at -O3 -Xr.
   Gfx_ProcessSplashData(dst, len, bpp): unpack a 1- or 4-bit-per-pixel picture in place to one byte per pixel:
   k = 8 / bpp pixels per byte (a `register` local: XIZ, unsigned `div`), total = k * len (the long multiply helper),
   copy total bytes of dst into a Malloc'd buffer, then expand the buffer's bytes back into dst; 24 bpp is left alone.
   Frame (last declared lowest): end +4, step +8, p +10, buf +14, total +18; i (long) stays in XBC. */

extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Mem_Copy(void *, void *, int);
extern void Gfx_ProcessSplashData(unsigned char *dst, long len, unsigned int bpp);

void Gfx_ProcessSplashData(unsigned char *dst, long len, unsigned int bpp)
{
	long total;
	unsigned char *buf;
	unsigned char *p;
	unsigned int step;
	long end;
	register unsigned int k;
	long i;

	if (bpp == 24)
		return;
	k = 8 / bpp;
	total = k * len;
	switch (bpp) {
	case 4:
		step = k;
		end = total;
		buf = Malloc(total);
		p = buf;
		Mem_Copy(p, dst, total);
		for (i = 0; i < end; i += step) {
			dst[i] = (*p & 0xf0) >> 4;
			dst[i + 1] = *p++ & 0xf;
		}
		Free(buf);
		break;
	case 1:
		step = k;
		end = total;
		buf = Malloc(total);
		p = buf;
		Mem_Copy(p, dst, total);
		for (i = 0; i < end; i += step) {
			dst[i] = (*p & 0x80) >> 7;
			dst[i + 1] = (*p & 0x40) >> 6;
			dst[i + 2] = (*p & 0x20) >> 5;
			dst[i + 3] = (*p & 0x10) >> 4;
			dst[i + 4] = (*p & 0x08) >> 3;
			dst[i + 5] = (*p & 0x04) >> 2;
			dst[i + 6] = (*p & 0x02) >> 1;
			dst[i + 7] = *p++ & 0x01;
		}
		Free(buf);
		break;
	}
}
