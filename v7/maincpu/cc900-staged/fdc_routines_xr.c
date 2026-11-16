/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int __near FDC_REQ_TRACK;
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned int __near FDC_COMMAND_INDEX;
extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_PROBE_FLAG;
extern unsigned int __near FDC_REQ_SECTOR;

int FDC_DRIVE_DETECT(void)
{
	if (FDC_REQ_TRACK != 0) return 0;
	if (FDC_REQ_HEAD != 0) return 0;
	if (FDC_COMMAND_INDEX != 3) return 0;
	if (FDC_REQ_COUNT != 1) return 0;
	if (FDC_PROBE_FLAG != 0xffff) return 0;
	if (FDC_REQ_SECTOR == 2 || FDC_REQ_SECTOR == 255) return -1;
	return 0;
}

int FDC_DETECT_CHECK(void)
{
	if (FDC_REQ_TRACK != 0) return 0;
	if (FDC_REQ_HEAD != 0) return 0;
	if (FDC_COMMAND_INDEX != 3) return 0;
	if (FDC_REQ_COUNT != 1) return 0;
	if (FDC_PROBE_FLAG != 0xffff) return 0;
	if (FDC_REQ_SECTOR != 1) return 0;
	return -1;
}
