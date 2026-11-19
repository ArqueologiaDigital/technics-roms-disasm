/* Functions of storage/flash_floppy_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Flash_InitBytecodeBlock_Helper8 Flash_InitBytecodeBlock_Helper9 Flash_InitExtMemAddrs */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void Flash_InitExtMemAddrs(void);
extern void Flash_InitBytecodeBlock_Helper8(unsigned int, unsigned int, unsigned int);
extern void Flash_InitBytecodeBlock_Helper9(unsigned int, unsigned int, unsigned int);
extern unsigned char __near ram_c68;
extern unsigned char __near ram_c6a;
extern unsigned char __near ram_c6c;
extern unsigned char CstmCpTtl_ResolvePendingCopy(unsigned char mode);

unsigned char CstmCpTtl_ResolvePendingCopy(unsigned char mode)
{
	unsigned char a;
	unsigned char b;
	unsigned char c;

	Flash_InitExtMemAddrs();
	a = ram_c68;
	b = ram_c6a;
	c = ram_c6c;
	switch (mode) {
	case 0:
		if (a < 10)
			Flash_InitBytecodeBlock_Helper8(a, b, c);
		else
			Flash_InitBytecodeBlock_Helper9(a, b, c);
		break;
	case 2:
		break;
	}
	return 0;
}
