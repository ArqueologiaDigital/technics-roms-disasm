/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/tonegen_fileio_handlers_m0.c (2026-11-16-68-p6-r12)
   sha256 51fb4b43f2bb824fd1990fe10cc8aded1fc1f5c4454cda5966fb1fb0fb6d0720 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern unsigned char HELP_LANGUAGE;
extern unsigned char ram_340e6[], ram_340f2[], ram_340f6[], ram_340fa[];
void SndParamBank_LoadOptionBlock(void)
{
	Mem_Copy(&HELP_LANGUAGE, (void *)0x3d3400L, 2);
	Mem_Copy(ram_340e6, (void *)0x3d3410L, 12);
	Mem_Copy(ram_340f2, (void *)0x3d3420L, 4);
	Mem_Copy(ram_340f6, (void *)0x3d3430L, 4);
	Mem_Copy(ram_340fa, (void *)0x3d3440L, 6);
}
