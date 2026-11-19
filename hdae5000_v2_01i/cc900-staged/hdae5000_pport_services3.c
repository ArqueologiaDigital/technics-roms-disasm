/* hdae5000_v2_01i: the functions of hdae5000/cc900/hdae5000_pport_services3.c that V4.23 reproduces in HD-AE5000 v2.01i with the tree's own object ids and ram_ addresses (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_pport_services3.c.
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
extern unsigned char ram_239fd2;                  /* HDAE5000_RAM_FileFormat_VersionMajor (a .set, not resolvable) */
extern unsigned char ram_239fd4;                  /* HDAE5000_RAM_FileFormat_VersionMinor */

#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))

/* trace banners and blank lines (HDAE5000_PPORT_SvcNN_*_Str_<name>), passed in XWA: lda */
extern char ram_2f844a[], ram_2f8478[];                                   /* Svc01 GetInfoBlockPointer, Blank1 */
extern char ram_2f847a[], ram_2f8494[];                                   /* Svc02 */
extern char ram_2f8496[], ram_2f84f6[];                                   /* Svc03 */
extern char ram_2f84f8[], ram_2f8544[];                                   /* Svc04 */
extern char ram_2f8546[], ram_2f8598[];                                   /* Svc05 */
extern char ram_2f859a[], ram_2f85f4[];                                   /* Svc06 */
extern char ram_2f85f6[], ram_2f8614[];                                   /* Svc07 */
extern char ram_2f8616[], ram_2f8634[];                                   /* Svc08 */
extern char ram_2f8636[], ram_2f8654[];                                   /* Svc09 */
extern char ram_2f8656[], ram_2f8672[];                                   /* Svc10 */
extern char ram_2f8674[], ram_2f8698[];                                   /* Svc11 */
extern char ram_2f869a[], ram_2f86b6[];                                   /* Svc12 */
extern char ram_2f86b8[], ram_2f86f2[];                                   /* Svc13 */
extern char ram_2f86f4[], ram_2f8716[];                                   /* Svc14 */
extern char ram_2f8718[], ram_2f8738[];                                   /* Svc15 */
extern char ram_2f873a[], ram_2f875a[];                                   /* Svc16 */
extern char ram_2f875c[], ram_2f8770[];                                   /* Svc17 */
extern char ram_2f8772[], ram_2f87aa[];                                   /* Svc19 */
extern char ram_2f87ac[], ram_2f87cc[];                                   /* Svc20 */
extern char ram_2f87ce[];                                                 /* Svc21 */
extern char ram_2f87f2[];                                                 /* Svc22 */
extern char ram_2f880a[];                                                 /* Svc23 */
extern char ram_2f8822[];                                                 /* Svc24 */
extern char ram_2f8838[];                                                 /* Svc25 */

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
extern char ram_2f8468[];
#define F_ppib_adr ram_2f8468
extern char ram_2f84b2[];
#define F_hddname ram_2f84b2
extern char ram_2f84be[];
#define F_hddtrck ram_2f84be
extern char ram_2f84cc[];
#define F_hddhead ram_2f84cc
extern char ram_2f84da[];
#define F_hddsctr ram_2f84da
extern char ram_2f84e8[];
#define F_hddscby ram_2f84e8
extern char ram_2f851a[];
#define F_FGB_ptr ram_2f851a
extern char ram_2f8528[];
#define F_FGB_wid ram_2f8528
extern char ram_2f8536[];
#define F_FGB_num ram_2f8536
extern char ram_2f856e[];
#define F_FEB_ptr ram_2f856e
extern char ram_2f857c[];
#define F_FEB_wid ram_2f857c
extern char ram_2f858a[];
#define F_FEB_num ram_2f858a
extern char ram_2f85bc[];
#define F_FLS_ptr ram_2f85bc
extern char ram_2f85ca[];
#define F_FLS_wid ram_2f85ca
extern char ram_2f85d8[];
#define F_FLS_num ram_2f85d8
extern char ram_2f85e6[];
#define F_FLS_ent ram_2f85e6
extern char ram_2f86d6[];
#define F_dirname ram_2f86d6
extern char ram_2f86e4[];
#define F_sngname ram_2f86e4
extern char ram_2f879a[];
#define F_work_adr ram_2f879a
extern char ram_2f87e6[];
#define F_SUFFIX ram_2f87e6

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
    PPIB[200] = ram_239fd2;
    PPIB[201] = ram_239fd4;
    HDAE5000_DebugTrace(ram_2f8496);
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
    HDAE5000_DebugTrace(ram_2f84f6);
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
    HDAE5000_DebugTrace(ram_2f84f8);
    HDAE5000_SPrintf(buf, F_FGB_ptr, PP_L(44));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FGB_wid, PP_W(48));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FGB_num, PP_W(50));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f8544);
}

void PP_Svc05(void)
{
    struct HdBlockInfo bi;
    char buf[64];

    HDAE5000_HD_GetBlockInfo(1, (void *)&bi);
    PP_L(52) = (unsigned long)bi.base;
    PP_W(56) = bi.size;
    PP_W(58) = bi.count;
    HDAE5000_DebugTrace(ram_2f8546);
    HDAE5000_SPrintf(buf, F_FEB_ptr, PP_L(52));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FEB_wid, PP_W(56));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FEB_num, PP_W(58));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f8598);
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
    HDAE5000_DebugTrace(ram_2f859a);
    HDAE5000_SPrintf(buf, F_FLS_ptr, PP_L(60));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_wid, PP_W(64));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_num, PP_W(66));
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_FLS_ent, PP_W(68));
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f85f4);
}

int PP_Svc14(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_LoadSong(dir, song, PP_W(0), 0, 1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f86f4);
    HDAE5000_DebugTrace(ram_2f8716);
    return ret;
}

int PP_Svc15(unsigned int dir, unsigned int song)
{
    int ret;

    ret = 0;
    if (HDAE5000_SaveSong(dir, song, (char *)(PPIB + 2), PP_W(0), 0, 1) == -1)
        ret = 1;
    HDAE5000_DebugTrace(ram_2f8718);
    HDAE5000_DebugTrace(ram_2f8738);
    return ret;
}

unsigned char *PP_Svc19(void)
{
    char buf[64];

    HDAE5000_DebugTrace(ram_2f8772);
    HDAE5000_SPrintf(buf, F_work_adr, (unsigned long)PPIB[202]);
    HDAE5000_DebugTrace(ram_2f87aa);
    return PPIB + 202;
}

int PP_Svc27(unsigned int dir, unsigned int song)
{
    HDAE5000_DeleteSongParts(dir, song, PP_W(0), 0, 1);
    return 0;
}
