/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_2a.c (2026-11-16-72-p6-r13)
   sha256 27282ed630352630d4812baadb0df6eca5bbea6fc9c92ba352fde8a4a60eba25 (tar-sha256); compiled at -Xr */
#define LO16(x) ((x) % 256)
#define HI16(x) ((x) >> 8)
void __cdecl SeqStep_FileSectorDone(unsigned int v, unsigned char **pp)
{
	*(*pp)++ = LO16(v);
	*(*pp)++ = HI16(v);
}
