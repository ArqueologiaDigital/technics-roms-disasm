/* hd_r27_a4b.c (helper h_r27a): second forms of two functions of hd_r27_a4.c.
   HDAE5000_HardTest_PortTest: i declared first, err cleared by a statement.
   HDAE5000_HardTest_HddIdRead: the free space through explicit locals (float f at +12, double d at +16 in the
   ROM's frame; the division in place, `FloatDiv(&f, &f, &100.0f)`).
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

void HDAE5000_HardTest_HddIdRead(void)
{
    struct HdGeom geo;
    struct DiskUsage usage;
    char line[32];
    double d;
    float f;

    if (HDAE5000_HD_LoadTables(0) == 0) {
        HDAE5000_HD_GetGeometry(&geo);
        HDAE5000_MemFill(line, 0, 32);
        HDAE5000_StrCpy(line, HDAE5000_Str_HDTYPE);
        HDAE5000_MemCopy(line + 10, geo.model, 10);
        HDAE5000_HardTest_Print(line);
        HDAE5000_HD_GetDiskUsage(&usage);
        HDAE5000_MemFill(line, 0, 32);
        f = usage.free;
        f /= 100.0f;
        d = f;
        HDAE5000_SPrintf(line, HDAE5000_Fmt_Fre_Capa_3_1f_MB, d);
        HDAE5000_HardTest_Print(line);
        HDAE5000_HardTest_Print(HDAE5000_Str_Empty);
        HDAE5000_HardTest_Print(HDAE5000_Str_HDDOK);
    } else
        HDAE5000_HardTest_Print(HDAE5000_Str_HDDNG);
}
