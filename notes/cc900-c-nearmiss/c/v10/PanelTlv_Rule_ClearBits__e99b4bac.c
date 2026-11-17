/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/tonegen_fileio_handlers_m277.c (2026-11-16-92-p6-r18)
   sha256 e99b4bacf59febb81db71da15247b5269061619da4b94a2080f83be8f542372f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	rec[r[1]] &= ~r[2];
	return 3;
}
