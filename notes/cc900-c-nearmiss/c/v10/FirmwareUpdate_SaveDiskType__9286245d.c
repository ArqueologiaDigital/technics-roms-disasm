/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_4m5a.c (2026-11-19-29-p6-r46)
   sha256 9286245d25fe064c4c17b0d4694da50dacc779c5845e81c1f1e5848e1d5cd7e1 (tar-sha256); compiled at -Xr */
extern unsigned char Bitmap_1bit_Change_FD_2_of_2[];
extern void Draw_FlashMemUpdate_message_bitmap(unsigned char *bmp, int x, int y, int a, int b);
extern unsigned char Check_for_Floppy_Disk_Change(void);
extern unsigned char Detect_Disk_Type(void);
extern void SHOW_FD_TO_FLASH_MEMORY_MESSAGE(void);
void FirmwareUpdate_SaveDiskType(unsigned char type)
{
	unsigned long i;

	do {
		Draw_FlashMemUpdate_message_bitmap(Bitmap_1bit_Change_FD_2_of_2, 0x30, 0xa0, 8, 2);
		while (Check_for_Floppy_Disk_Change() != 0)
			;
		for (i = 0; i < 0x40000; i++)
			;
		while (Check_for_Floppy_Disk_Change() == 0)
			;
		for (i = 0; i < 0x200000; i++)
			;
	} while (Detect_Disk_Type() != type);
	SHOW_FD_TO_FLASH_MEMORY_MESSAGE();
}
