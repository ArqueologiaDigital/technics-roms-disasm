/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void VgaWriteReg(int reg, int val);
extern unsigned char VgaReadReg(int reg);
extern int Test_LCD_Controller_IC206(unsigned char st);

/* cc900-name: VgaWriteReg=_Write_VGA_Register */
/* cc900-name: VgaReadReg=_Read_VGA_Register */
int Test_LCD_Controller_IC206(unsigned char st)
{
	VgaWriteReg(0x3c3, 0);
	if (VgaReadReg(0x3c3) != 0)
		st |= 4;
	VgaWriteReg(0x3c3, 1);
	if (VgaReadReg(0x3c3) != 1)
		st |= 4;
	VgaWriteReg(0x3c3, 0);
	if (VgaReadReg(0x3c3) != 0)
		st |= 4;
	return st;
}
