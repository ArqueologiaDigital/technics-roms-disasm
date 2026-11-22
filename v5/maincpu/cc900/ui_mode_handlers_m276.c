/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/



void A_Short_Pause(void)
{
	unsigned int i, j;

	for (i = 0; i < 0x1000; i++)
		for (j = 0; j < 0x100; j++)
			;
}

unsigned char SelfTest_PopCount(unsigned char a)
{
	unsigned char n, i;

	n = 0;
	for (i = 0; i < 8; i++) {
		if (a & 1) n++;
		a >>= 1;
	}
	return n;
}

#define EVT_PAGE_CHANGE 0x1c0001eL
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern unsigned char __near FDC_ERROR_CODE;
extern long ApPostEvent(long, long, long);
extern void FDC_CommandAndPostEvent(void);

void FDC_CommandAndPostEvent(void)
{
	struct fdccmd cmd;
	unsigned char e;

	cmd.op = 3;
	FDC_CommandEntry(&cmd);
	e = FDC_ERROR_CODE;
	if (e == 0xfc)
		ApPostEvent(-1, EVT_PAGE_CHANGE, 2);
	else
		ApPostEvent(-1, EVT_PAGE_CHANGE, 1);
}

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

/* cc900-module: EffectMode_InitSwbWr_DiagMode EffectMode_RestoreSwbWr_NormalMode EffectMode_RunDiagSequence EffectMode_SetAllLEDs LED_SetAll_WithBlank */
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near ram_8cc0;
extern unsigned char __near ram_8cc2;
extern unsigned char __near ram_e2f4;
extern void EffectMode_InitSwbWr_DiagMode(void);
extern void EffectMode_SetAllLEDs(void);
extern void EffectMode_RestoreSwbWr_NormalMode(void);
extern void LED_SetAll_WithBlank(void);
extern void EffectMode_HandleTimerEvents(void);
extern void EffectMode_ModeChangeTransition(void);
extern void EffectMode_RunDiagSequence(void);
extern void EffectMode_CheckAndDispatch(void);

void EffectMode_CheckAndDispatch(void)
{
    unsigned char f;

    if (CURRENT_TITLE == 251) {
        if (ram_8cc2 != 2) {
            f = ram_8cc0;
            if (f & 1) {
                if (!(f & 0x10)) {
                    ram_8cc0 = f | 0x10;
                    if (ram_8cc2 != 1) {
                        ram_8cc2 = 1;
                        EffectMode_InitSwbWr_DiagMode();
                        EffectMode_SetAllLEDs();
                    }
                }
            } else {
                if (f & 0x10) {
                    ram_8cc0 = f & ~0x10;
                    if (ram_8cc2 != 0) {
                        ram_8cc2 = 0;
                        EffectMode_RestoreSwbWr_NormalMode();
                        LED_SetAll_WithBlank();
                        ram_e2f4 = 16;
                    }
                }
            }
        } else {
            ram_8cc2 = 0;
            LED_SetAll_WithBlank();
            EffectMode_RestoreSwbWr_NormalMode();
        }
    }
    if (CURRENT_TITLE == 248) EffectMode_HandleTimerEvents();
    if (CURRENT_TITLE == 247) EffectMode_ModeChangeTransition();
    if (CURRENT_TITLE == 251) EffectMode_RunDiagSequence();
}
