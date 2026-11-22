/* lane_p6 helper P, round 30r1, form a: module 159 (storage/flash_floppy_handlers.s), the slot-table fills
   SlotTable_InitBank1748 / SlotTable_InitBank1850 / Flash_SlotUpdateOpsBlock_Helper2 /
   Flash_InitBytecodeBlock_Helper4_Helper2.  One-spot retry of helper M's p6_M_28r1m159b (run r76, O3Xr, +16, the
   closest so far: equal up to the entry store, which the ROM writes through (XBC+DE), the 16-bit offset as a
   signed index on the far base, where V4.23 did near arithmetic, `extz xde; add xde, xbc`; N's cast to a far
   struct pointer, r78, turned the loop into a pointer walk).  Form a: lane_hd's integer idiom, the base's address
   as an unsigned long and the entry's byte offset (i * 2 + 2, an int) added to it.
   cc900-options: -O3 -Xr
*/
/* cc900-name: Flash_SlotUpdOpsBlock_Helper2=Flash_SlotUpdateOpsBlock_Helper2 */
/* cc900-name: Flash_InitBcBlock_Helper4_Helper2=Flash_InitBytecodeBlock_Helper4_Helper2 */

struct slots { unsigned int head; unsigned int e[50]; };
extern struct slots __near ram_6d4;
extern struct slots __near ram_73a;
extern struct slots __near ram_c02;
extern struct slots __near ram_b9c;

void SlotTable_InitBank1748(void)
{
	unsigned char i;

	*(unsigned int *)((unsigned long)&ram_6d4) = 0xffff;
	for (i = 0; i < 50; i++)
		*(unsigned int *)((unsigned long)&ram_6d4 + (i * 2 + 2)) = 0xffff;
}

void SlotTable_InitBank1850(void)
{
	unsigned char i;

	*(unsigned int *)((unsigned long)&ram_73a) = 0xffff;
	for (i = 0; i < 50; i++)
		*(unsigned int *)((unsigned long)&ram_73a + (i * 2 + 2)) = 0xffff;
}

void Flash_SlotUpdOpsBlock_Helper2(void)
{
	unsigned char i;

	*(unsigned int *)((unsigned long)&ram_c02) = 0xffff;
	for (i = 0; i < 50; i++)
		*(unsigned int *)((unsigned long)&ram_c02 + (i * 2 + 2)) = 0xffff;
}

void Flash_InitBcBlock_Helper4_Helper2(void)
{
	unsigned char i;

	*(unsigned int *)((unsigned long)&ram_b9c) = 0xffff;
	for (i = 0; i < 50; i++)
		*(unsigned int *)((unsigned long)&ram_b9c + (i * 2 + 2)) = 0xffff;
}
