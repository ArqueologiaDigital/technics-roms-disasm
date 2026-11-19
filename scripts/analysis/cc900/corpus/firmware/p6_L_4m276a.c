/* Phase 6, lane_p6 helper L, round 4, form a: module 276 (ui_mode_handlers.s), retries.
   - Test_LCD_Controller_IC206 (r43 Xr +10, the first call's address): the listing name `._Write_VGA_Register`
     resolved to another label (Write_VGA_Register, 0xef5141), so the callees get short C names mapped to the
     ROM's _Write_VGA_Register / _Read_VGA_Register.
   - FDC_CommandAndPostEvent (r43 O3Xr +19): the ROM loads FDC_ERROR_CODE into A and compares the register
     (V4.23 compared the cell in memory): the cell volatile. */
/* (no module-local callee) */

/* cc900-name: VgaWriteReg=_Write_VGA_Register */
/* cc900-name: VgaReadReg=_Read_VGA_Register */
#define EVT_PAGE_CHANGE 0x1c0001eL
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern volatile unsigned char __near FDC_ERROR_CODE;
extern long ApPostEvent(long, long, long);
extern void FDC_CommandAndPostEvent(void);

void FDC_CommandAndPostEvent(void)
{
	struct fdccmd cmd;

	cmd.op = 3;
	FDC_CommandEntry(&cmd);
	if (FDC_ERROR_CODE == 0xfc)
		ApPostEvent(-1, EVT_PAGE_CHANGE, 2);
	else
		ApPostEvent(-1, EVT_PAGE_CHANGE, 1);
}

extern void VgaWriteReg(int reg, int val);
extern unsigned char VgaReadReg(int reg);
extern int Test_LCD_Controller_IC206(unsigned char st);

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
