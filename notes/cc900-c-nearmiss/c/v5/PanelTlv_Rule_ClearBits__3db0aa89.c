/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/tonegen_fileio_handlers_m277.c (2026-11-16-91-p6-r17)
   sha256 3db0aa89f7d851dbe0ab6024d009098a50b661746992928c948e9f3fa7733a74 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	rec[r[1]] &= ~r[2];
	return 3;
}
