/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/smf_event_processor_m0_xr.c (2026-11-16-92-p6-r18)
   sha256 5b788e5537c92d3bd7fe0368f0e4e88a18a5e940fb1cf95a53dbff398072bce3 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define LO16(x) ((x) % 256)
#define HI16(x) ((x) >> 8)
void __cdecl SeqStep_FileSectorDone(unsigned int v, unsigned char **pp)
{
	*(*pp)++ = LO16(v);
	*(*pp)++ = HI16(v);
}
