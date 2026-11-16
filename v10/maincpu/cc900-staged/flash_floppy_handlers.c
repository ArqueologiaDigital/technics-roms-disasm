/* Functions of storage/flash_floppy_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

/* cc900-name: Flash_StoreBaseAccPatch_Helper=Flash_StoreBaseAndInitAccPatch_Helper (the label shares its first 31
   characters with the other Flash_StoreBaseAndInitAccPatch_* labels) */
unsigned char Flash_StoreBaseAccPatch_Helper(unsigned char a)
{
	unsigned char r;

	if (a < 10) r = a + 48;
	else if (a < 20) r = a + 38;
	else if (a < 30) r = a + 28;
	else if (a < 40) r = a + 18;
	else r = a + 8;
	return r;
}

unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}
