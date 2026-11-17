/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/tonegen_fileio_handlers_m277.c (2026-11-16-91-p6-r17)
   sha256 49d0d9c1524f602485f384592dbac6cdb359c3c4ab8a77e9d202972be1fbea91 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	rec[r[1]] &= ~r[2];
	return 3;
}
