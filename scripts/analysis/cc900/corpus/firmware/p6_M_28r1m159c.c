/* lane_p6 helper M, round 28r1, form c: module 159 (storage/flash_floppy_handlers.s), the slot-table fills
   SlotTable_InitBank1748 / SlotTable_InitBank1850 / Flash_SlotUpdateOpsBlock_Helper2 /
   Flash_InitBytecodeBlock_Helper4_Helper2.  One-spot retry of helper J's p6_J_27r1m159d / e (run r74,
   O3Xr equal to +3: the ROM keeps the base in XBC and stores through (XBC+DE) with DE = 2 * i + 2, V4.23
   walked a pointer).  No pointer local here: the table an extern __near word array indexed directly with an int index, t[(int)i + 1].
   cc900-options: -O3 -Xr
*/
/* cc900-name: Flash_SlotUpdOpsBlock_Helper2=Flash_SlotUpdateOpsBlock_Helper2 */
/* cc900-name: Flash_InitBcBlock_Helper4_Helper2=Flash_InitBytecodeBlock_Helper4_Helper2 */

extern unsigned int __near ram_6d4[];
extern unsigned int __near ram_73a[];
extern unsigned int __near ram_c02[];
extern unsigned int __near ram_b9c[];

void SlotTable_InitBank1748(void)
{
	unsigned char i;

	ram_6d4[0] = 0xffff;
	for (i = 0; i < 50; i++)
		ram_6d4[(int)i + 1] = 0xffff;
}

void SlotTable_InitBank1850(void)
{
	unsigned char i;

	ram_73a[0] = 0xffff;
	for (i = 0; i < 50; i++)
		ram_73a[(int)i + 1] = 0xffff;
}

void Flash_SlotUpdOpsBlock_Helper2(void)
{
	unsigned char i;

	ram_c02[0] = 0xffff;
	for (i = 0; i < 50; i++)
		ram_c02[(int)i + 1] = 0xffff;
}

void Flash_InitBcBlock_Helper4_Helper2(void)
{
	unsigned char i;

	ram_b9c[0] = 0xffff;
	for (i = 0; i < 50; i++)
		ram_b9c[(int)i + 1] = 0xffff;
}
