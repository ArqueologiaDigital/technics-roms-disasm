/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/smf_event_processor_m0_xr.c (2026-11-16-92-p6-r18)
   sha256 95a486e1a5b5b7797925bc9768ee70739655c26374f2abbaa5b5eaacd7b566f7 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define LO16(x) ((x) % 256)
#define HI16(x) ((x) >> 8)
void __cdecl SeqStep_FileSectorDone(unsigned int v, unsigned char **pp)
{
	*(*pp)++ = LO16(v);
	*(*pp)++ = HI16(v);
}
