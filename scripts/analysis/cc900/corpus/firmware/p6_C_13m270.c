/* Phase 6, lane_p6 helper C, round 13, module 270 (modules_v10.tsv) of v10 storage/fdc_routines.s: five more small
   routines of the floppy driver.  FDC_CheckHead / FDC_Validate_Drive_Head end in a calr to FDC_Set_Status and a ret;
   the call is written inside the `if` so that V4.23 keeps it a call (a call that is the last statement becomes a jump).
   FDC_Send_Command / FDC_NOP_Delay / FDC_Set_Status take a byte the callers zero-extend: int prototypes. */
/* cc900-module: FDC_Send_Command SOME_DELAY FDC_Set_Status FDC_NOP_Delay */

/* __near: 16-bit absolute operand; __tiny: 8-bit (an SFR). */
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned char __near ram_8a6e;
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern unsigned char __near FDC_PARAM_DTL;
extern unsigned char __near FDC_FORMAT_FILL;
extern unsigned char __near ram_8a3b;
extern unsigned char __near ram_8a3c;
extern unsigned char __near ram_8a3d;
extern unsigned char __near ram_8a3e;
extern unsigned char __near ram_8a3f;
extern unsigned int __near FDC_REQ_HEAD;
extern unsigned char __near FDC_PARAM_H;
extern unsigned char __near FDC_HEAD;
extern unsigned char __tiny PH;

extern void FDC_Send_Command(int);
extern void SOME_DELAY(int);
extern unsigned char FDC_Set_Status(int);
extern void FDC_NOP_Delay(int);

void FDC_INIT(void)
{
    FDC_Send_Command(54);
    SOME_DELAY(2);
    FDC_CURRENT_CYLINDER = 255;
}

void FDC_InitStateVars(void)
{
    FDC_SPECIFY_SRT = (ram_8a6e >> 4) & 0xf;
    FDC_PARAM_DTL = 255;
    FDC_FORMAT_FILL = 0;
    FDC_SPECIFY_HUT = 15;
    FDC_SPECIFY_HLT = 1;
    ram_8a3c = 0;
    ram_8a3b = 0;
    ram_8a3d = 0;
    ram_8a3e = 0;
    ram_8a3f = 0;
    FDC_SPECIFY_ND = 0;
}

void FDC_CheckHead(void)
{
    FDC_HEAD = FDC_PARAM_H = FDC_REQ_HEAD;
    if (FDC_HEAD != 0 && FDC_HEAD != 1) FDC_Set_Status(0xfe);
}

void FDC_Validate_Drive_Head(void)
{
    if (FDC_REQ_HEAD != 0 && FDC_REQ_HEAD != 1) FDC_Set_Status(0xfe);
}

void FDC_Pulse_PH0(void)
{
    PH |= 1;
    FDC_NOP_Delay(10);
    PH &= ~1;
}
