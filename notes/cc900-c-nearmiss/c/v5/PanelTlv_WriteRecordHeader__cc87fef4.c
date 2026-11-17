/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/tonegen_fileio_handlers.c (2026-11-16-55-p6-r10)
   sha256 cc87fef4035126603ea440007312ba81aa4a94c12c6b1969bfb2430f571280c8 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
void PanelTlv_WriteRecordHeader(unsigned char *buf, unsigned char *rec)
{
	buf += *(long *)rec;
	buf[0] = rec[8];
	buf[1] = rec[9];
}
