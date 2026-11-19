/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_pport_services3.c (2026-11-19-23-hd-r63-remap-ports)
   sha256 f89425b5dfba2e47e58b8c1f784b22e0c0fbe1c9acce57801943c87f7c2379ca (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc03=HDAE5000_PPORT_Svc03_SendInfosAboutHd */
struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long usable; char model[42]; };
extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char ram_23a04a;
extern unsigned char ram_23a04c;
#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
extern char ram_2e0aae[], ram_2e0b0e[];
extern char ram_2e0aca[];
#define F_hddname ram_2e0aca
extern char ram_2e0ad6[];
#define F_hddtrck ram_2e0ad6
extern char ram_2e0ae4[];
#define F_hddhead ram_2e0ae4
extern char ram_2e0af2[];
#define F_hddsctr ram_2e0af2
extern char ram_2e0b00[];
#define F_hddscby ram_2e0b00
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void HDAE5000_HD_GetGeometry(struct HdGeom *g);
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
    PPIB[200] = ram_23a04a;
    PPIB[201] = ram_23a04c;
    HDAE5000_DebugTrace(ram_2e0aae);
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
    HDAE5000_DebugTrace(ram_2e0b0e);
    return 0;
}
