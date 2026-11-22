/* lane_p6 helper P, round 30r1, form b: module 159 (storage/flash_floppy_handlers.s), the slot-table fills
   SlotTable_InitBank1748 / SlotTable_InitBank1850 / Flash_SlotUpdateOpsBlock_Helper2 /
   Flash_InitBytecodeBlock_Helper4_Helper2.  One-spot retry of helper M's p6_M_28r1m159b (run r76, O3Xr, +16:
   equal up to the entry store, which the ROM writes through (XBC+DE), a signed 16-bit offset on the far base,
   where V4.23 did near arithmetic, `extz xde; add xde, xbc`).  Form b: a far byte-pointer local p set to the
   table's address, the head through p, each entry at p + (i * 2 + 2) (a char pointer plus an int: the signed
   index form).
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
	char *p;
	unsigned char i;

	p = (char *)&ram_6d4;
	*(unsigned int *)p = 0xffff;
	for (i = 0; i < 50; i++)
		*(unsigned int *)(p + (i * 2 + 2)) = 0xffff;
}

void SlotTable_InitBank1850(void)
{
	char *p;
	unsigned char i;

	p = (char *)&ram_73a;
	*(unsigned int *)p = 0xffff;
	for (i = 0; i < 50; i++)
		*(unsigned int *)(p + (i * 2 + 2)) = 0xffff;
}

void Flash_SlotUpdOpsBlock_Helper2(void)
{
	char *p;
	unsigned char i;

	p = (char *)&ram_c02;
	*(unsigned int *)p = 0xffff;
	for (i = 0; i < 50; i++)
		*(unsigned int *)(p + (i * 2 + 2)) = 0xffff;
}

void Flash_InitBcBlock_Helper4_Helper2(void)
{
	char *p;
	unsigned char i;

	p = (char *)&ram_b9c;
	*(unsigned int *)p = 0xffff;
	for (i = 0; i < 50; i++)
		*(unsigned int *)(p + (i * 2 + 2)) = 0xffff;
}
