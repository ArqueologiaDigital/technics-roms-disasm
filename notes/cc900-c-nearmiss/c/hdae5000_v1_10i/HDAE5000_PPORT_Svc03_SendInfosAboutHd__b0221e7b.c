/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_pport_services3__svc03_r75.c (2026-11-19-64-hd-r76-staged)
   sha256 b0221e7b769e15a57bc6c7a4222246af1bb50e4cccc69f620fdd8c84c60ace5b (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc03=HDAE5000_PPORT_Svc03_SendInfosAboutHd */
struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long usable; char model[42]; };
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
extern char ram_2e091e[], ram_2e097e[];
extern char ram_2e093a[];
#define F_hddname ram_2e093a
extern char ram_2e0946[];
#define F_hddtrck ram_2e0946
extern char ram_2e0954[];
#define F_hddhead ram_2e0954
extern char ram_2e0962[];
#define F_hddsctr ram_2e0962
extern char ram_2e0970[];
#define F_hddscby ram_2e0970
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void HDAE5000_HD_GetGeometry(struct HdGeom *g);
extern void HDAE5000_DebugTrace(char *s);
int PP_Svc03(void)
{
    struct HdGeom geom;
    char buf[64];

    HDAE5000_HD_GetGeometry(&geom);
    HDAE5000_MemCopy(PPIB + 151, geom.model, 30);
    PP_L(181) = geom.cyl;
    PP_W(185) = geom.heads;
    PP_W(187) = geom.spt;
    PP_W(189) = 512;
    HDAE5000_DebugTrace(ram_2e091e);
    HDAE5000_SPrintf(buf, F_hddname);
    HDAE5000_MemCopy(buf + 10, PPIB + 151, 30);
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_hddtrck, PP_L(181));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_hddhead, PP_W(185));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_hddsctr, PP_W(187));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_hddscby, PP_W(189));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2e097e);
    return 0;
}
