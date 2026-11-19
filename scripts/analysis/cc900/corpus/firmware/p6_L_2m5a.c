/* Phase 6, lane_p6 helper L, round 2, form a: module 5 (boot/system_handlers.s).
   - FirmwareUpdate_SaveDiskType: show "Change FD (2/2)", wait for the disk to go and come back (busy-wait debounce
     counts 0x40000 / 0x200000), repeat until Detect_Disk_Type equals the wanted type, then the FD-to-flash
     message.  The type stays in the frame (-Xr).  Loops spelled `if (c) do ... while (c)` and `do i++ while`;
     the bitmap passed through a double conversion (the ROM loads it with `ld xwa, imm`, not lda); stack arguments
     8 then 2 pushed left to right (4th = 8, 5th = 2). */
/* cc900-module: Detect_Disk_Type SHOW_FD_TO_FLASH_MEMORY_MESSAGE */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char Bitmap_1bit_Change_FD_2_of_2[];
extern void Draw_FlashMemUpdate_message_bitmap(unsigned char *bmp, int x, int y, int a, int b);
extern unsigned char Check_for_Floppy_Disk_Change(void);
extern unsigned char Detect_Disk_Type(void);
extern void SHOW_FD_TO_FLASH_MEMORY_MESSAGE(void);
extern void FirmwareUpdate_SaveDiskType(unsigned char type);

void FirmwareUpdate_SaveDiskType(unsigned char type)
{
	unsigned long i;

	do {
		Draw_FlashMemUpdate_message_bitmap((unsigned char *)(long)Bitmap_1bit_Change_FD_2_of_2, 0x30, 0xa0, 8, 2);
		if (Check_for_Floppy_Disk_Change() != 0)
			do
				;
			while (Check_for_Floppy_Disk_Change() != 0);
		i = 0;
		do
			i++;
		while (i < 0x40000);
		if (Check_for_Floppy_Disk_Change() == 0)
			do
				;
			while (Check_for_Floppy_Disk_Change() == 0);
		i = 0;
		do
			i++;
		while (i < 0x200000);
	} while (Detect_Disk_Type() != type);
	SHOW_FD_TO_FLASH_MEMORY_MESSAGE();
}
