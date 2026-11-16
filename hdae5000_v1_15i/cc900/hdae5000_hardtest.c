/* Functions of hd-ae5000_v1_15i.s.  (hdae5000_hardtest.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_hardtest.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
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

/* the hardware-test page: switches 9 (PPORT), 10 (HDD), 11 (FD) run a test and, while RUN/STOP is on, chain the
   next one through a timer; 12 toggles RUN/STOP */

/* 8255 control word 0x90 (mode 0, port A input), then 0xff to port A */
void HDAE5000_PPI_Init(void)
{
    HDAE5000_IO_PpiControl = 0x90;
    HDAE5000_IO_PpiPortA = 0xff;
}

/* "PPORT TEST": all 256 byte values through the loopback, the failures ORed.  The ROM keeps i in IZ and err in a
   stack slot (cleared before PPI_Init); the argument is `ld a,izl; extz wa`, the result `ld a,l; exts wa`. */

/* "HDD ID READ": "HD-TYPE : <model>", "Fre Capa: %3.1f [MB]", "=======> HDD OK" / "... HDD NG!".
   The ROM's frame is 124 bytes: geo at +72, usage at +56, line at +24, a double at +16 and a float at +12 (the
   compiler's temporaries for the conversion and the division by its constant 100.0f, HDAE5000_Float_100_HddIdRead). */
