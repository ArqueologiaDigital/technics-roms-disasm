/* lane_p6 helper J, round 27r1, form d: module 159 (storage/flash_floppy_handlers.s), the slot-table fills
   SlotTable_InitBank1748 / SlotTable_InitBank1850 / Flash_SlotUpdateOpsBlock_Helper2 (families27_J, 3 x 33 B) and
   their probed-before twin Flash_InitBytecodeBlock_Helper4_Helper2 (p6_D_1a / 1b used a constant pointer): 51 words
   at 0x6d4 / 0x73a / 0xc02 / 0xb9c set to 0xffff, the first one alone, then 50 in a counted loop (V4.23's
   strength-reduced offset in WA).  The ROM takes the base with `lda xbc, (N:16)`: the address of a __near object.
   (Forms a-c of this round's m159 hold PaintArrow_DrawFilled.)
   Form d: a pointer local initialised from a __near array, `p[0]`, then `p[i + 1]` for i = 0..49.
   cc900-options: -O3 -Xr
*/
/* cc900-name: Flash_SlotUpdOpsBlock_Helper2=Flash_SlotUpdateOpsBlock_Helper2 */
/* cc900-name: Flash_InitBcBlock_Helper4_Helper2=Flash_InitBytecodeBlock_Helper4_Helper2 */

extern unsigned int __near ram_6d4[];
extern unsigned int __near ram_73a[];
extern unsigned int __near ram_b9c[];
extern unsigned int __near ram_c02[];

void SlotTable_InitBank1748(void)
{
	unsigned int *p;
	unsigned char i;

	p = ram_6d4;
	p[0] = 0xffff;
	for (i = 0; i < 50; i++)
		p[i + 1] = 0xffff;
}

void SlotTable_InitBank1850(void)
{
	unsigned int *p;
	unsigned char i;

	p = ram_73a;
	p[0] = 0xffff;
	for (i = 0; i < 50; i++)
		p[i + 1] = 0xffff;
}

void Flash_SlotUpdOpsBlock_Helper2(void)
{
	unsigned int *p;
	unsigned char i;

	p = ram_c02;
	p[0] = 0xffff;
	for (i = 0; i < 50; i++)
		p[i + 1] = 0xffff;
}

void Flash_InitBcBlock_Helper4_Helper2(void)
{
	unsigned int *p;
	unsigned char i;

	p = ram_b9c;
	p[0] = 0xffff;
	for (i = 0; i < 50; i++)
		p[i + 1] = 0xffff;
}
