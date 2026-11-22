/* lane_p6 helper N, round 29r1, form a: module 159 (storage/flash_floppy_handlers.s), the slot-table fills
   SlotTable_InitBank1748 / SlotTable_InitBank1850 / Flash_SlotUpdateOpsBlock_Helper2 /
   Flash_InitBytecodeBlock_Helper4_Helper2.  One-spot retry of helper M's p6_M_28r1m159b (run r76, O3Xr, +16: equal
   up to the entry store, which the ROM writes through (XBC+DE) where V4.23 extended DE and added the base, the
   index arithmetic of a __near object).  M's form b with the table a numeric constant cast to a plain struct pointer (-O3 loads 8..0xffff with lda).
   cc900-options: -O3 -Xr
*/
/* cc900-name: Flash_SlotUpdOpsBlock_Helper2=Flash_SlotUpdateOpsBlock_Helper2 */
/* cc900-name: Flash_InitBcBlock_Helper4_Helper2=Flash_InitBytecodeBlock_Helper4_Helper2 */

struct slots { unsigned int head; unsigned int e[50]; };
#define T_6d4 ((struct slots *)0x6d4L)
#define T_73a ((struct slots *)0x73aL)
#define T_c02 ((struct slots *)0xc02L)
#define T_b9c ((struct slots *)0xb9cL)

void SlotTable_InitBank1748(void)
{
	unsigned char i;

	T_6d4->head = 0xffff;
	for (i = 0; i < 50; i++)
		T_6d4->e[i] = 0xffff;
}

void SlotTable_InitBank1850(void)
{
	unsigned char i;

	T_73a->head = 0xffff;
	for (i = 0; i < 50; i++)
		T_73a->e[i] = 0xffff;
}

void Flash_SlotUpdOpsBlock_Helper2(void)
{
	unsigned char i;

	T_c02->head = 0xffff;
	for (i = 0; i < 50; i++)
		T_c02->e[i] = 0xffff;
}

void Flash_InitBcBlock_Helper4_Helper2(void)
{
	unsigned char i;

	T_b9c->head = 0xffff;
	for (i = 0; i < 50; i++)
		T_b9c->e[i] = 0xffff;
}
