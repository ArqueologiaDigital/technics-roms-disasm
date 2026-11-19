/* Phase 6, lane_p6 helper L, round 2, form a: module 276 (ui/ui_mode_handlers.s).
   - FDC_CommandAndPostEvent: a type-3 floppy command block in the frame, then EVT_PAGE_CHANGE 2 when
     FDC_ERROR_CODE is 0xfc, else 1 (the ROM shares the ApPostEvent call between the branches).
   - EffectMode_MidiParseLoop (the routine after it in the same pool row): read panel records from the __near
     buffer at 0x8d6c until -1, setting the LEDs for each.
   - Test_LCD_Controller_IC206: write 0 / 1 / 0 to VGA register 0x3c3 and read each back; a mismatch sets bit 2 of
     the incoming status byte (kept in the frame: an -Xr routine). */
/* cc900-module: EffectMode_MidiSetLEDs */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_PAGE_CHANGE 0x1c0001eL
struct fdccmd { int op; int f2; int b; int a; int c; int count; void *buf; };
extern int __cdecl FDC_CommandEntry(struct fdccmd *cmd);
extern unsigned char __near FDC_ERROR_CODE;
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

extern unsigned char __near ram_8d6c[];
extern int PanelInput_ReadRxRecord(unsigned char *rec);
extern void EffectMode_MidiSetLEDs(unsigned char *rec);
extern void EffectMode_MidiParseLoop(void);

void EffectMode_MidiParseLoop(void)
{
	unsigned char *p;

	p = ram_8d6c;
	while (PanelInput_ReadRxRecord(p) != -1)
		EffectMode_MidiSetLEDs(p);
}

extern void _Write_VGA_Register(int reg, int val);
extern unsigned char _Read_VGA_Register(int reg);
extern int Test_LCD_Controller_IC206(unsigned char st);

int Test_LCD_Controller_IC206(unsigned char st)
{
	_Write_VGA_Register(0x3c3, 0);
	if (_Read_VGA_Register(0x3c3) != 0)
		st |= 4;
	_Write_VGA_Register(0x3c3, 1);
	if (_Read_VGA_Register(0x3c3) != 1)
		st |= 4;
	_Write_VGA_Register(0x3c3, 0);
	if (_Read_VGA_Register(0x3c3) != 0)
		st |= 4;
	return st;
}
