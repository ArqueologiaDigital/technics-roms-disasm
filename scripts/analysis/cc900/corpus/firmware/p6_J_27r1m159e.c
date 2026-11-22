/* lane_p6 helper J, round 27r1, form e: module 159 (storage/flash_floppy_handlers.s), the slot-table fills
   SlotTable_InitBank1748 / SlotTable_InitBank1850 / Flash_SlotUpdateOpsBlock_Helper2 and
   Flash_InitBytecodeBlock_Helper4_Helper2 (see p6_J_27r1m159d.c).
   Form e: the table as a __near struct (a head word and 50 entries), a struct pointer from `&cell`, `p->e[i]`.
   cc900-options: -O3 -Xr
*/
/* cc900-name: Flash_SlotUpdOpsBlock_Helper2=Flash_SlotUpdateOpsBlock_Helper2 */
/* cc900-name: Flash_InitBcBlock_Helper4_Helper2=Flash_InitBytecodeBlock_Helper4_Helper2 */

struct slots { unsigned int head; unsigned int e[50]; };

extern struct slots __near ram_6d4;
extern struct slots __near ram_73a;
extern struct slots __near ram_b9c;
extern struct slots __near ram_c02;

void SlotTable_InitBank1748(void)
{
	struct slots *p;
	unsigned char i;

	p = &ram_6d4;
	p->head = 0xffff;
	for (i = 0; i < 50; i++)
		p->e[i] = 0xffff;
}

void SlotTable_InitBank1850(void)
{
	struct slots *p;
	unsigned char i;

	p = &ram_73a;
	p->head = 0xffff;
	for (i = 0; i < 50; i++)
		p->e[i] = 0xffff;
}

void Flash_SlotUpdOpsBlock_Helper2(void)
{
	struct slots *p;
	unsigned char i;

	p = &ram_c02;
	p->head = 0xffff;
	for (i = 0; i < 50; i++)
		p->e[i] = 0xffff;
}

void Flash_InitBcBlock_Helper4_Helper2(void)
{
	struct slots *p;
	unsigned char i;

	p = &ram_b9c;
	p->head = 0xffff;
	for (i = 0; i < 50; i++)
		p->e[i] = 0xffff;
}
