/* Functions of storage/flash_floppy_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

/* cc900-name: Flash_StoreBaseAccPatch_Helper2=Flash_StoreBaseAndInitAccPatch_Helper2 (the label shares its first 31
   characters with the other Flash_StoreBaseAndInitAccPatch_* labels) */
unsigned char Flash_StoreBaseAccPatch_Helper2(unsigned char a)
{
	unsigned char r;

	if (a < 10) r = 48;
	else if (a < 20) r = 49;
	else if (a < 30) r = 50;
	else {
		r = 52;
		if (a >= 40) return r;
		r = 51;
	}
	return r;
}
