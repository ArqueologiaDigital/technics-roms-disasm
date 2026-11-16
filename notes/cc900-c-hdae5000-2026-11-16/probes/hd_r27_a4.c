/* hd_r27_a4.c (helper h_r27a): the hardware-test page of hd-ae5000_v2_06i.s and its helpers.
   Functions: HDAE5000_HardTest_Print HDAE5000_HardTestPage HDAE5000_PPI_Init HDAE5000_HardTest_PortTest
   HDAE5000_HardTest_HddIdRead.  HDAE5000_PPI_LoopbackByte (between PPI_Init and PortTest) is left as hand assembly.
   cc900-options: -Xr
   cc900-module: HDAE5000_HardTest_Print HDAE5000_HardTest_PortTest HDAE5000_HardTest_HddIdRead
   cc900-module: HDAE5000_PPI_Init HDAE5000_PPI_LoopbackByte
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

/* +0 cylinders, +2 heads, +4 sectors per track, +6 usable sectors, +10 the model string */
struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long sectors; char model[42]; };
/* four longs in units of 10,000 bytes: drive, system area, data area, free */
struct DiskUsage { unsigned long drive; unsigned long sys; unsigned long data; unsigned long free; };

/* other modules (call) */
extern void HDAE5000_YieldUntilSem1Zero(void);
extern int HDAE5000_HD_LoadTables(int spin);
extern void HDAE5000_HD_GetGeometry(struct HdGeom *g);
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *u);

/* hand assembly of this module (calr): A = byte, L = 0 or 0xff; the caller loads WA and sign-extends L */
extern char HDAE5000_PPI_LoopbackByte(int b);

void HDAE5000_HardTest_Print(char *line);
void HDAE5000_PPI_Init(void);
void HDAE5000_HardTest_PortTest(void);
void HDAE5000_HardTest_HddIdRead(void);

/* the 8255 */
extern unsigned char HDAE5000_IO_PpiPortA;
extern unsigned char HDAE5000_IO_PpiControl;

/* ROM */
extern char HDAE5000_Str_Test[];
extern char HDAE5000_Str_PPORTTEST[];
extern char HDAE5000_Str_HDDIDREAD[];
extern char HDAE5000_Str_FDTEST[];
extern char HDAE5000_Str_OK[];
extern char HDAE5000_Str_ERROR[];
extern char HDAE5000_Str_ERROR_HardTestPage[];
extern char HDAE5000_Str_STOPTESTLOOP[];
extern char HDAE5000_Str_STARTTESTLOOP[];
extern char HDAE5000_Str_PortTestOK[];
extern char HDAE5000_Str_PortTestError[];
extern char HDAE5000_Str_HDTYPE[];
extern char HDAE5000_Fmt_Fre_Capa_3_1f_MB[];
extern char HDAE5000_Str_Empty[];
extern char HDAE5000_Str_HDDOK[];
extern char HDAE5000_Str_HDDNG[];

/* one line into the test page's memo.  The ROM ends in `jp (xhl)` (a tail call): unsure V4.23 -Xr writes it. */
void HDAE5000_HardTest_Print(char *line)
{
    CALLV(ROOT->SendEvent)(-1L, EVT_MEMO_DRAW, line);
}

/* the hardware-test page: switches 9 (PPORT), 10 (HDD), 11 (FD) run a test and, while RUN/STOP is on, chain the
   next one through a timer; 12 toggles RUN/STOP */
long HDAE5000_HardTestPage(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_Test);
        return 0;
    case EVT_SW_IN:
        switch (arg) {
        case 9:
            CALLV(ROOT->SendEvent)(OBJ_PPORT_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_PPORTTEST);
            HDAE5000_HardTest_PortTest();
            CALLV(ROOT->SendEvent)(OBJ_PPORT_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 10L);
            break;
        case 10:
            CALLV(ROOT->SendEvent)(OBJ_HDD_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_HDDIDREAD);
            HDAE5000_HardTest_HddIdRead();
            CALLV(ROOT->SendEvent)(OBJ_HDD_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 11L);
            break;
        case 11:
            CALLV(ROOT->SendEvent)(OBJ_FD_SW, EVT_PARA_DRAW, 1L);
            CALLV(ROOT->UpdateScreen)();
            HDAE5000_YieldUntilSem1Zero();
            HDAE5000_HardTest_Print(HDAE5000_Str_FDTEST);
            switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
            case 2:
            case 3:
                if (CALLR(int, HAMA->FDLoadSaveTest)() == 0)
                    HDAE5000_HardTest_Print(HDAE5000_Str_OK);
                else
                    HDAE5000_HardTest_Print(HDAE5000_Str_ERROR);
                break;
            default:
                HDAE5000_HardTest_Print(HDAE5000_Str_ERROR_HardTestPage);
                break;
            }
            CALLV(ROOT->SendEvent)(OBJ_FD_SW, EVT_PARA_DRAW, 0L);
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1)
                CALLV(ROOT->SetApTimer)(0x29L, obj, -1L, EVT_SW_IN, 9L);
            break;
        case 12:
            if (CALLR(long, ROOT->SendEvent)(OBJ_RUN_STOP, EVT_GET_PARAM, 0L) == 1) {
                CALLV(ROOT->SendEvent)(OBJ_RUN_STOP, EVT_SET_PARAM, 0L);
                HDAE5000_HardTest_Print(HDAE5000_Str_STOPTESTLOOP);
            } else {
                CALLV(ROOT->SendEvent)(OBJ_RUN_STOP, EVT_SET_PARAM, 1L);
                HDAE5000_HardTest_Print(HDAE5000_Str_STARTTESTLOOP);
                CALLV(ROOT->PostEvent)(-1L, EVT_SW_IN, 9L);
            }
            break;
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

/* 8255 control word 0x90 (mode 0, port A input), then 0xff to port A */
void HDAE5000_PPI_Init(void)
{
    HDAE5000_IO_PpiControl = 0x90;
    HDAE5000_IO_PpiPortA = 0xff;
}

/* "PPORT TEST": all 256 byte values through the loopback, the failures ORed.  The ROM keeps i in IZ and err in a
   stack slot (cleared before PPI_Init); the argument is `ld a,izl; extz wa`, the result `ld a,l; exts wa`. */
void HDAE5000_HardTest_PortTest(void)
{
    int err = 0;
    int i;

    HDAE5000_PPI_Init();
    for (i = 0; i < 0x100; i++)
        err |= HDAE5000_PPI_LoopbackByte((unsigned char)i);
    if (err == 0)
        HDAE5000_HardTest_Print(HDAE5000_Str_PortTestOK);
    else
        HDAE5000_HardTest_Print(HDAE5000_Str_PortTestError);
}

/* "HDD ID READ": "HD-TYPE : <model>", "Fre Capa: %3.1f [MB]", "=======> HDD OK" / "... HDD NG!".
   The ROM's frame is 124 bytes: geo at +72, usage at +56, line at +24, a double at +16 and a float at +12 (the
   compiler's temporaries for the conversion and the division by its constant 100.0f, HDAE5000_Float_100_HddIdRead). */
void HDAE5000_HardTest_HddIdRead(void)
{
    struct HdGeom geo;
    struct DiskUsage usage;
    char line[32];

    if (HDAE5000_HD_LoadTables(0) == 0) {
        HDAE5000_HD_GetGeometry(&geo);
        HDAE5000_MemFill(line, 0, 32);
        HDAE5000_StrCpy(line, HDAE5000_Str_HDTYPE);
        HDAE5000_MemCopy(line + 10, geo.model, 10);
        HDAE5000_HardTest_Print(line);
        HDAE5000_HD_GetDiskUsage(&usage);
        HDAE5000_MemFill(line, 0, 32);
        HDAE5000_SPrintf(line, HDAE5000_Fmt_Fre_Capa_3_1f_MB, (float)usage.free / 100.0f);
        HDAE5000_HardTest_Print(line);
        HDAE5000_HardTest_Print(HDAE5000_Str_Empty);
        HDAE5000_HardTest_Print(HDAE5000_Str_HDDOK);
    } else
        HDAE5000_HardTest_Print(HDAE5000_Str_HDDNG);
}
