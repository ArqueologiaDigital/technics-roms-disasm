/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_2b.c (2026-11-16-72-p6-r13)
   sha256 a7078af977481bf63e6c415c1e9d9dd350bc6ebe373b96a02fe5a2304c8cc198 (tar-sha256); compiled at -Xr */
extern void *__cdecl Mem_Copy(void *, void *, int);
#define LO16(x) ((x) % 256)
#define HI16(x) ((x) / 256)
#define B32(x, n) (((x) >> (n)) % 256)
#define LO32(x) ((x) % 256)
void __cdecl SeqStep_FileSectorReturn(unsigned char *e, unsigned char *dst)
{
	unsigned char *p;

	p = dst;
	Mem_Copy(dst, e, 11);
	p[11] = e[12];
	p += 22;
	*p++ = LO16(*(unsigned int *)(e + 13));
	*p++ = HI16(*(unsigned int *)(e + 13));
	*p++ = LO16(*(unsigned int *)(e + 15));
	*p++ = HI16(*(unsigned int *)(e + 15));
	*p++ = LO16(*(unsigned int *)(e + 17));
	*p++ = HI16(*(unsigned int *)(e + 17));
	*p++ = LO32(*(unsigned long *)(e + 19));
	*p++ = B32(*(unsigned long *)(e + 19), 8);
	*p++ = B32(*(unsigned long *)(e + 19), 16);
	*p = *(unsigned long *)(e + 19) >> 24;
}
