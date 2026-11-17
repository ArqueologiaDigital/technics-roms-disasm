/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/tonegen_fileio_handlers_m277.c (2026-11-16-68-p6-r12)
   sha256 71135102b49292555756dbdc38a260b9f54109de8625585afd755ba5b763d38e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec)
{
	buf += *(long *)rec;
	buf[0] = rec[8];
	buf[1] = rec[9];
}
