/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/smf_event_processor_m238_xr.c (2026-11-16-92-p6-r18)
   sha256 5e7e109461233b2efb10e32e3f97d971e38d062885e30ebc380c947ba967bd88 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern void *__cdecl Mem_Copy(void *, void *, int);
#define LO16(x) ((unsigned char)((x) & 0xff))
#define HI16(x) ((unsigned char)((x) >> 8))
#define B32(x, n) ((unsigned char)(((x) >> (n)) & 0xff))
#define LO32(x) ((unsigned char)((x) & 0xff))
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
