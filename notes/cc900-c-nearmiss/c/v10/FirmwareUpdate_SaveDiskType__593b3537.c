/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m5a.c (2026-11-19-19-p6-r43)
   sha256 593b3537bd4dc1d39d523cb64c64999e27a00c678800fe12e3027403e9d6de2d (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Bitmap_1bit_Change_FD_2_of_2[];
extern void Draw_FlashMemUpdate_message_bitmap(unsigned char *bmp, int x, int y, int a, int b);
extern unsigned char Check_for_Floppy_Disk_Change(void);
extern unsigned char Detect_Disk_Type(void);
extern void SHOW_FD_TO_FLASH_MEMORY_MESSAGE(void);
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
