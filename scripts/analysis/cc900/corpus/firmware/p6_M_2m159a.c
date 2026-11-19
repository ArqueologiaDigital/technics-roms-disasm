/* Phase 6, lane_p6 helper M, round 2, module 159 (storage/flash_floppy_handlers.s), form a.
   CstmCpTtl_ResolvePendingCopy: after Flash_InitExtMemAddrs, read the three pending-copy cells; for mode 0 resolve
   the copy with Helper8 (first cell < 10) or Helper9; mode 2 does nothing.  The ROM reads the cells before the mode
   test (locals assigned first) and widens the arguments once before the < 10 test.  The test chain (2, then 0) is a
   switch written case 0, case 2 (V4.23 compares the last case first). */
/* cc900-module: Flash_InitBytecodeBlock_Helper8 Flash_InitBytecodeBlock_Helper9 Flash_InitExtMemAddrs */

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
