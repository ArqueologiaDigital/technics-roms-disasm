/* lane_p6 helper M, round 28r1, form b: module 159 (storage/flash_floppy_handlers.s), the slot-table fills
   SlotTable_InitBank1748 / SlotTable_InitBank1850 / Flash_SlotUpdateOpsBlock_Helper2 /
   Flash_InitBytecodeBlock_Helper4_Helper2.  One-spot retry of helper J's p6_J_27r1m159d / e (run r74,
   O3Xr equal to +3: the ROM keeps the base in XBC and stores through (XBC+DE) with DE = 2 * i + 2, V4.23
   walked a pointer).  No pointer local here: the table an extern __near struct used directly, t.head then t.e[i].
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
