/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/smf_event_processor_m238_xr.c (2026-11-18-33-p6-r37)
   sha256 a43c0ce42e23a5b397d80c57b3da18e1480040bdc15c4be8801f402a985d18e3 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
