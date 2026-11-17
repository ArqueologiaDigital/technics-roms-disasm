/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/tonegen_fileio_handlers_m277.c (2026-11-16-68-p6-r12)
   sha256 dfaeaa54721de5ea0c1f1c404555b24e61510669e52ba78851096bff124d633c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec)
{
	buf += *(long *)rec;
	buf[0] = rec[8];
	buf[1] = rec[9];
}
