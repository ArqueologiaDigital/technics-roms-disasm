/* Phase 6, lane_p6 helper L, round 2, form b: module 5, FirmwareUpdate_SaveDiskType with plain while loops, empty
   for loops for the debounce, and the bitmap passed as the array itself. */
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
		Draw_FlashMemUpdate_message_bitmap(Bitmap_1bit_Change_FD_2_of_2, 0x30, 0xa0, 8, 2);
		while (Check_for_Floppy_Disk_Change() != 0)
			;
		for (i = 0; ++i < 0x40000; )
			;
		while (Check_for_Floppy_Disk_Change() == 0)
			;
		for (i = 0; ++i < 0x200000; )
			;
	} while (Detect_Disk_Type() != type);
	SHOW_FD_TO_FLASH_MEMORY_MESSAGE();
}
