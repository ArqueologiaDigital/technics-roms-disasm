/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/flash_floppy_handlers_m159.c (2026-11-19-29-p6-r46)
   sha256 6cc85d987eb6dbcc28e9e81735f5981f43a374049e5e9b94fb4af9aa6b0171e9 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void Flash_InitExtMemAddrs(void);
extern void Flash_InitBytecodeBlock_Helper8(unsigned int, unsigned int, unsigned int);
extern void Flash_InitBytecodeBlock_Helper9(unsigned int, unsigned int, unsigned int);
extern unsigned char __near ram_c68;
extern unsigned char __near ram_c6a;
extern unsigned char __near ram_c6c;
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
