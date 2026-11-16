/* hdae5000_v1_10i: the functions of hdae5000/cc900-staged/hdae5000_hardtest_port.c that V4.23 reproduces unchanged in HD-AE5000 v1.10i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_hardtest_port.c.
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

struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long sectors; char model[42]; };
struct DiskUsage { unsigned long drive; unsigned long sys; unsigned long data; unsigned long free; };

extern int HDAE5000_HD_LoadTables(int spin);
extern void HDAE5000_HD_GetGeometry(struct HdGeom *g);
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *u);

extern char HDAE5000_PPI_LoopbackByte(int b);
extern void HDAE5000_HardTest_Print(char *line);
extern void HDAE5000_PPI_Init(void);

extern char HDAE5000_Str_PortTestOK[];
extern char HDAE5000_Str_PortTestError[];
extern char HDAE5000_Str_HDTYPE[];
extern char HDAE5000_Fmt_Fre_Capa_3_1f_MB[];
extern char HDAE5000_Str_Empty[];
extern char HDAE5000_Str_HDDOK[];
extern char HDAE5000_Str_HDDNG[];

void HDAE5000_HardTest_PortTest(void)
{
    int i;
    int err;

    err = 0;
    HDAE5000_PPI_Init();
    for (i = 0; i < 0x100; i++)
        err |= HDAE5000_PPI_LoopbackByte((unsigned char)i);
    if (err == 0)
        HDAE5000_HardTest_Print(HDAE5000_Str_PortTestOK);
    else
        HDAE5000_HardTest_Print(HDAE5000_Str_PortTestError);
}
