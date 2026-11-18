/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_2m238a.c (2026-11-18-28-p6-r36)
   sha256 f24805d5dee7a93dd223604a38b533be554f9952e02ca78dd9cdc211956c4a76 (tar-sha256); compiled at -O3 -Xr */
extern void *__cdecl Mem_Copy(void *, void *, int);
extern unsigned int __cdecl SeqStep_FileSectorRead(unsigned char **pp);
extern unsigned long __cdecl SeqStep_FileSectorProcess(unsigned char **pp);
void __cdecl SeqStep_FileSectorComplete(unsigned char *e, unsigned char *raw)
{
	unsigned char *p;

	p = raw + 22;
	Mem_Copy(e, raw, 11);
	e[11] = 0;
	e[12] = raw[11];
	*(unsigned int *)(e + 13) = SeqStep_FileSectorRead(&p);
	*(unsigned int *)(e + 15) = SeqStep_FileSectorRead(&p);
	*(unsigned int *)(e + 17) = SeqStep_FileSectorRead(&p);
	*(unsigned long *)(e + 19) = SeqStep_FileSectorProcess(&p);
}
