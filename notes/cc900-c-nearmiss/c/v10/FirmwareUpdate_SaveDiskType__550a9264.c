/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m5b.c (2026-11-19-19-p6-r43)
   sha256 550a92641da735954e12cd10b2642564afcfc2dcc095c806a0afceb878e1bf08 (tar-sha256); compiled at -O3 -Xr */
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
		for (i = 0; ++i < 0x40000; )
			;
		while (Check_for_Floppy_Disk_Change() == 0)
			;
		for (i = 0; ++i < 0x200000; )
			;
	} while (Detect_Disk_Type() != type);
	SHOW_FD_TO_FLASH_MEMORY_MESSAGE();
}
