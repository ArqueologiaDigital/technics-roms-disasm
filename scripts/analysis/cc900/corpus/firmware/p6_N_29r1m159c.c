/* lane_p6 helper N, round 29r1, form c: module 159 (storage/flash_floppy_handlers.s), the slot-table fills
   SlotTable_InitBank1748 / SlotTable_InitBank1850 / Flash_SlotUpdateOpsBlock_Helper2 /
   Flash_InitBytecodeBlock_Helper4_Helper2.  One-spot retry of helper M's p6_M_28r1m159b (run r76, O3Xr, +16: equal
   up to the entry store, which the ROM writes through (XBC+DE) where V4.23 extended DE and added the base, the
   index arithmetic of a __near object).  M's form b with the table a plain (large) extern struct, to see the index and the base load it gets.
   cc900-options: -O3 -Xr
*/
/* cc900-name: Flash_SlotUpdOpsBlock_Helper2=Flash_SlotUpdateOpsBlock_Helper2 */
/* cc900-name: Flash_InitBcBlock_Helper4_Helper2=Flash_InitBytecodeBlock_Helper4_Helper2 */

struct slots { unsigned int head; unsigned int e[50]; };
extern struct slots ram_6d4;
extern struct slots ram_73a;
extern struct slots ram_c02;
extern struct slots ram_b9c;

void SlotTable_InitBank1748(void)
{
	unsigned char i;

	ram_6d4.head = 0xffff;
	for (i = 0; i < 50; i++)
		ram_6d4.e[i] = 0xffff;
}

void SlotTable_InitBank1850(void)
{
	unsigned char i;

	ram_73a.head = 0xffff;
	for (i = 0; i < 50; i++)
		ram_73a.e[i] = 0xffff;
}

void Flash_SlotUpdOpsBlock_Helper2(void)
{
	unsigned char i;

	ram_c02.head = 0xffff;
	for (i = 0; i < 50; i++)
		ram_c02.e[i] = 0xffff;
}

void Flash_InitBcBlock_Helper4_Helper2(void)
{
	unsigned char i;

	ram_b9c.head = 0xffff;
	for (i = 0; i < 50; i++)
		ram_b9c.e[i] = 0xffff;
}
