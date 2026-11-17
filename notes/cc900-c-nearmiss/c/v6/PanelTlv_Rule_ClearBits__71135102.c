/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/tonegen_fileio_handlers_m277.c (2026-11-16-68-p6-r12)
   sha256 71135102b49292555756dbdc38a260b9f54109de8625585afd755ba5b763d38e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
int PanelTlv_Rule_ClearBits(unsigned char *rec, unsigned char *r)
{
	rec[r[1]] &= ~r[2];
	return 3;
}
