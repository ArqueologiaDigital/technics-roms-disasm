/* The PC-link (PPORT) service module: further services, helper h_r27c's C that matches (module-local calls in cc900-module).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r27_c5.c.
   cc900-options: -Xr
   cc900-name: PP_Svc03=HDAE5000_PPORT_Svc03_SendInfosAboutHd
   cc900-name: PP_Svc04=HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock
   cc900-name: PP_Svc05=HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock
   cc900-name: PP_Svc06=HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock
   cc900-name: PP_Svc14=HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory
   cc900-name: PP_Svc15=HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd
   cc900-name: PP_Svc19=HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace
   cc900-name: PP_Svc27=HDAE5000_PPORT_Svc27_DeleteSongParts
   cc900-module: HDAE5000_DebugTrace
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned char *addr; unsigned long size; };
struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long usable; char model[42]; };
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };
struct SongRec { unsigned char name[26]; unsigned char part[9]; unsigned char pad; unsigned long slot[9];
                 unsigned char tail[4]; };

extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_PportReadState;
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char ram_23a04a;                  /* HDAE5000_RAM_FileFormat_VersionMajor (a .set, not resolvable) */
extern unsigned char ram_23a04c;                  /* HDAE5000_RAM_FileFormat_VersionMinor */

#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))

/* trace banners and blank lines (HDAE5000_PPORT_SvcNN_*_Str_<name>), passed in XWA: lda */
extern char ram_2f8f5e[], ram_2f8f8c[];                                   /* Svc01 GetInfoBlockPointer, Blank1 */
extern char ram_2f8f8e[], ram_2f8fa8[];                                   /* Svc02 */
extern char ram_2f8faa[], ram_2f900a[];                                   /* Svc03 */
extern char ram_2f900c[], ram_2f9058[];                                   /* Svc04 */
extern char ram_2f905a[], ram_2f90ac[];                                   /* Svc05 */
extern char ram_2f90ae[], ram_2f9108[];                                   /* Svc06 */
extern char ram_2f910a[], ram_2f9128[];                                   /* Svc07 */
extern char ram_2f912a[], ram_2f9148[];                                   /* Svc08 */
extern char ram_2f914a[], ram_2f9168[];                                   /* Svc09 */
extern char ram_2f916a[], ram_2f9186[];                                   /* Svc10 */
extern char ram_2f9188[], ram_2f91ac[];                                   /* Svc11 */
extern char ram_2f91ae[], ram_2f91ca[];                                   /* Svc12 */
extern char ram_2f91cc[], ram_2f9206[];                                   /* Svc13 */
extern char ram_2f9208[], ram_2f922a[];                                   /* Svc14 */
extern char ram_2f922c[], ram_2f924c[];                                   /* Svc15 */
extern char ram_2f924e[], ram_2f926e[];                                   /* Svc16 */
extern char ram_2f9270[], ram_2f9284[];                                   /* Svc17 */
extern char ram_2f9286[], ram_2f92be[];                                   /* Svc19 */
extern char ram_2f92c0[], ram_2f92e0[];                                   /* Svc20 */
extern char ram_2f92e2[];                                                 /* Svc21 */
extern char ram_2f9306[];                                                 /* Svc22 */
extern char ram_2f931e[];                                                 /* Svc23 */
extern char ram_2f9336[];                                                 /* Svc24 */
extern char ram_2f934c[];                                                 /* Svc25 */

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
extern char ram_2f8f7c[];
#define F_ppib_adr ram_2f8f7c
extern char ram_2f8fc6[];
#define F_hddname ram_2f8fc6
extern char ram_2f8fd2[];
#define F_hddtrck ram_2f8fd2
extern char ram_2f8fe0[];
#define F_hddhead ram_2f8fe0
extern char ram_2f8fee[];
#define F_hddsctr ram_2f8fee
extern char ram_2f8ffc[];
#define F_hddscby ram_2f8ffc
extern char ram_2f902e[];
#define F_FGB_ptr ram_2f902e
extern char ram_2f903c[];
#define F_FGB_wid ram_2f903c
extern char ram_2f904a[];
#define F_FGB_num ram_2f904a
extern char ram_2f9082[];
#define F_FEB_ptr ram_2f9082
extern char ram_2f9090[];
#define F_FEB_wid ram_2f9090
extern char ram_2f909e[];
#define F_FEB_num ram_2f909e
extern char ram_2f90d0[];
#define F_FLS_ptr ram_2f90d0
extern char ram_2f90de[];
#define F_FLS_wid ram_2f90de
extern char ram_2f90ec[];
#define F_FLS_num ram_2f90ec
extern char ram_2f90fa[];
#define F_FLS_ent ram_2f90fa
extern char ram_2f91ea[];
#define F_dirname ram_2f91ea
extern char ram_2f91f8[];
#define F_sngname ram_2f91f8
extern char ram_2f92ae[];
#define F_work_adr ram_2f92ae
extern char ram_2f92fa[];
#define F_SUFFIX ram_2f92fa

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int HDAE5000_ATA_Standby_Status(void);
extern void HDAE5000_HD_GetGeometry(struct HdGeom *g);
extern void HDAE5000_HD_GetBlockInfo(int block, struct HdBlockInfo *bi);
extern int HDAE5000_HD_LoadTables(int spin);
extern int HDAE5000_HD_StoreTables(int spin);
extern int HDAE5000_TlxPart_Describe(int kind, struct ResInfo *info);
extern int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *si);
extern int HDAE5000_LoadSong(unsigned int dir, unsigned int song, unsigned int mask, int spin, int sleep);
extern int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, unsigned int mask, int sleep,
                             int spin);
extern int HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int spin, int sleep);
extern int HDAE5000_HD_FormatDrive(int sleep);
extern int HDAE5000_HD_WriteOpen(unsigned long *slot);
extern int HDAE5000_HD_WriteClose(void);
extern int HDAE5000_HD_WriteStream(void *src, unsigned long n);
extern int HDAE5000_HD_ReadFile(void *dst, unsigned long n, unsigned long *slot);
extern int HDAE5000_HD_ReadFileNext(void *dst, unsigned long n, unsigned long *slot);

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
    HDAE5000_DebugTrace(ram_2f8faa);
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
    HDAE5000_DebugTrace(ram_2f900a);
    return 0;
}

void PP_Svc04(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(0, (void *)&bi);
    PP_L(44) = (unsigned long)bi.base;
    PP_W(48) = bi.size;
    PP_W(50) = bi.count;
    HDAE5000_DebugTrace(ram_2f900c);
    HDAE5000_SPrintf(buf, F_FGB_ptr, PP_L(44));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FGB_wid, PP_W(48));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FGB_num, PP_W(50));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f9058);
}

void PP_Svc05(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(1, (void *)&bi);
    PP_L(52) = (unsigned long)bi.base;
    PP_W(56) = bi.size;
    PP_W(58) = bi.count;
    HDAE5000_DebugTrace(ram_2f905a);
    HDAE5000_SPrintf(buf, F_FEB_ptr, PP_L(52));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FEB_wid, PP_W(56));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FEB_num, PP_W(58));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f90ac);
}

void PP_Svc06(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(2, (void *)&bi);
    PP_L(60) = (unsigned long)bi.base;
    PP_W(64) = bi.size;
    PP_W(66) = bi.count;
    PP_W(68) = bi.extra;
    HDAE5000_DebugTrace(ram_2f90ae);
    HDAE5000_SPrintf(buf, F_FLS_ptr, PP_L(60));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_wid, PP_W(64));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_num, PP_W(66));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_ent, PP_W(68));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f9108);
}

int PP_Svc14(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_LoadSong(dir, song, PP_W(0), 0, 1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f9208);
    HDAE5000_DebugTrace(ram_2f922a);
    return ret;
}

int PP_Svc15(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_SaveSong(dir, song, (char *)(PPIB + 2), PP_W(0), 0, 1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f922c);
    HDAE5000_DebugTrace(ram_2f924c);
    return ret;
}

unsigned char *PP_Svc19(void)
{
    char buf[64];

    HDAE5000_DebugTrace(ram_2f9286);
    HDAE5000_SPrintf(buf, F_work_adr, (unsigned long)PPIB[202]);
    HDAE5000_DebugTrace(ram_2f92be);
    return PPIB + 202;
}

int PP_Svc27(unsigned int dir, unsigned int song)
{
    HDAE5000_DeleteSongParts(dir, song, PP_W(0), 0, 1);
    return 0;
}
