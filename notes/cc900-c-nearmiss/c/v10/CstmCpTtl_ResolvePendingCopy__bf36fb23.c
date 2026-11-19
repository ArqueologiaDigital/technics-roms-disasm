/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_2m159a.c (2026-11-19-15-p6-r42)
   sha256 bf36fb23b697e550affdff4a3fcfa9be6850611a0892da61cc3dad72c5c59e75 (tar-sha256); compiled at -Xr */
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
