/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_36r1m273a.c (2026-11-22-25-p6-r92)
   sha256 19e70e6cfbff3c167360f646a87bc366e397a72bd11b56b6bbf58d42ba02f919 (tar-sha256); compiled at -O3 -Xr */
extern void *__cdecl Malloc(unsigned int);
extern void __cdecl Free(void *);
extern void *__cdecl Mem_Copy(void *, void *, int);
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
