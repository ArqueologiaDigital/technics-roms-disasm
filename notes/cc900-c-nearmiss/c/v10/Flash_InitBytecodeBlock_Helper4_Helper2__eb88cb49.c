/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m159b.c (2026-11-22-9-p6-r76)
   sha256 eb88cb49fd8fdd94888b0904aa5bf55efd1d7345f6d15bb61f833438bd5429ed (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: Flash_InitBcBlock_Helper4_Helper2=Flash_InitBytecodeBlock_Helper4_Helper2 */
struct slots { unsigned int head; unsigned int e[50]; };
extern struct slots __near ram_b9c;
void Flash_InitBcBlock_Helper4_Helper2(void)
{
	unsigned char i;

	ram_b9c.head = 0xffff;
	for (i = 0; i < 50; i++)
		ram_b9c.e[i] = 0xffff;
}
