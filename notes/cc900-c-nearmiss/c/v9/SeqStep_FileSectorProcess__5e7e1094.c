/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/smf_event_processor_m238_xr.c (2026-11-16-92-p6-r18)
   sha256 5e7e109461233b2efb10e32e3f97d971e38d062885e30ebc380c947ba967bd88 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
unsigned long __cdecl SeqStep_FileSectorProcess(unsigned char **pp)
{
	unsigned long v;

	v = *(*pp)++;
	v += (unsigned long)*(*pp)++ << 8;
	v += (unsigned long)*(*pp)++ << 16;
	v += (unsigned long)*(*pp)++ << 24;
	return v;
}
