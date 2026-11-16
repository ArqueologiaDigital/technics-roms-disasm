/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int __near FDC_REQ_COUNT;
extern unsigned int __near FDC_COMMAND_INDEX;
extern unsigned int __near SYSTEM_TIMESTAMP;

int FDC_DRIVE_STATUS(void)
{
	if (FDC_REQ_COUNT != 0xffff) return 0;
	if (FDC_COMMAND_INDEX != 0) return 0;
	return -1;
}

void SOME_DELAY(unsigned int n)
{
	unsigned int i, t;

	n >>= 1;
	t = SYSTEM_TIMESTAMP;
	i = 0;
	while (i < 0xffff) {
		if (SYSTEM_TIMESTAMP - t > n) return;
		i++;
	}
}
