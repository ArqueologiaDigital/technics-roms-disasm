/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/tonegen_fileio_handlers_m277.c (2026-11-16-92-p6-r18)
   sha256 fd7ed3617a9936b15abbb70ce590d65e86511d3177886aa0c76a09a404ecb449 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec)
{
	buf += *(long *)rec;
	buf[0] = rec[8];
	buf[1] = rec[9];
}
