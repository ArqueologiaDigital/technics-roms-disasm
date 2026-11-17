/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/tonegen_fileio_handlers.c (2026-11-16-45-p6-r9)
   sha256 d1b667eb0ed145cf8f3ab824cd360a85670169eb573b763e37e678633df655c4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	rec[r[1]] &= ~r[2];
	return 3;
}
