/* hdae5000_v1_10i: the functions of hdae5000/cc900/hdae5000_pport_services2.c that V4.23 reproduces in HD-AE5000 v1.10i with the tree's own object ids and ram_ addresses (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_pport_services2.c.
   cc900-options: -Xr
   cc900-name: PP_Svc16=HDAE5000_PPORT_Svc16_InitWholeSongInMemory
   cc900-name: PP_Svc20=HDAE5000_PPORT_Svc20_PreWholeSongInMemory
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
extern char ram_2e08d2[], ram_2e0900[];                                   /* Svc01 GetInfoBlockPointer, Blank1 */
extern char ram_2e0902[], ram_2e091c[];                                   /* Svc02 */
extern char ram_2e091e[], ram_2e097e[];                                   /* Svc03 */
extern char ram_2e0980[], ram_2e09cc[];                                   /* Svc04 */
extern char ram_2e09ce[], ram_2e0a20[];                                   /* Svc05 */
extern char ram_2e0a22[], ram_2e0a7c[];                                   /* Svc06 */
extern char ram_2e0a7e[], ram_2e0a9c[];                                   /* Svc07 */
extern char ram_2e0a9e[], ram_2e0abc[];                                   /* Svc08 */
extern char ram_2e0abe[], ram_2e0adc[];                                   /* Svc09 */
extern char ram_2e0ade[], ram_2e0afa[];                                   /* Svc10 */
extern char ram_2e0afc[], ram_2e0b20[];                                   /* Svc11 */
extern char ram_2e0b22[], ram_2e0b3e[];                                   /* Svc12 */
extern char ram_2e0b40[], ram_2e0b7a[];                                   /* Svc13 */
extern char ram_2e0b7c[], ram_2e0b9e[];                                   /* Svc14 */
extern char ram_2e0ba0[], ram_2e0bc0[];                                   /* Svc15 */
extern char ram_2e0bc2[], ram_2e0be2[];                                   /* Svc16 */
extern char ram_2e0be4[], ram_2e0bf8[];                                   /* Svc17 */
extern char ram_2e0bfa[], ram_2e0c32[];                                   /* Svc19 */
extern char ram_2e0c34[], ram_2e0c54[];                                   /* Svc20 */
extern char ram_2e0c56[];                                                 /* Svc21 */
extern char ram_2e0c7a[];                                                 /* Svc22 */
extern char ram_2e0c92[];                                                 /* Svc23 */
extern char ram_2e0caa[];                                                 /* Svc24 */
extern char ram_2e0cc0[];                                                 /* Svc25 */

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
#define F_ppib_adr  ((char *)0x2f8f7cL)
#define F_hddname   ((char *)0x2f8fc6L)
#define F_hddtrck   ((char *)0x2f8fd2L)
#define F_hddhead   ((char *)0x2f8fe0L)
#define F_hddsctr   ((char *)0x2f8feeL)
#define F_hddscby   ((char *)0x2f8ffcL)
#define F_FGB_ptr   ((char *)0x2f902eL)
#define F_FGB_wid   ((char *)0x2f903cL)
#define F_FGB_num   ((char *)0x2f904aL)
#define F_FEB_ptr   ((char *)0x2f9082L)
#define F_FEB_wid   ((char *)0x2f9090L)
#define F_FEB_num   ((char *)0x2f909eL)
#define F_FLS_ptr   ((char *)0x2f90d0L)
#define F_FLS_wid   ((char *)0x2f90deL)
#define F_FLS_num   ((char *)0x2f90ecL)
#define F_FLS_ent   ((char *)0x2f90faL)
#define F_dirname   ((char *)0x2f91eaL)
#define F_sngname   ((char *)0x2f91f8L)
#define F_work_adr  ((char *)0x2f92aeL)
#define F_SUFFIX    ((char *)0x2f92faL)

extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
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
extern int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, int spin, int sleep,
                             unsigned int mask);
extern int HDAE5000_DeleteSongParts(unsigned int dir, unsigned int song, unsigned int mask, int spin, int sleep);
extern int HDAE5000_HD_FormatDrive(int sleep);
extern int HDAE5000_HD_WriteOpen(unsigned long *slot);
extern int HDAE5000_HD_WriteClose(void);
extern int HDAE5000_HD_WriteStream(void *src, unsigned long n);
extern int HDAE5000_HD_ReadFile(void *dst, unsigned long n, unsigned long *slot);
extern int HDAE5000_HD_ReadFileNext(void *dst, unsigned long n, unsigned long *slot);

void PP_Svc16(void)
{
    if (PP_W(0) & 0x01)
        CALLV(HAMA->PostLswLoad)(0);
    if (PP_W(0) & 0x02)
        CALLV(HAMA->PostPmLoad)(0);
    if (PP_W(0) & 0x04) {
        CALLV(HAMA->SeqLoadPost)(0);
        CALLV(((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    if (PP_W(0) & 0x08)
        CALLV(HAMA->cmp_ld_ato)(0);
    if (PP_W(0) & 0x10)
        CALLV(HAMA->PostTmLoad)(0);
    if (PP_W(0) & 0x20)
        CALLV(HAMA->msp_ld_ato)(0);
    if (PP_W(0) & 0x80)
        CALLV(HAMA->PostMidiLoad)(0);
    HDAE5000_DebugTrace(ram_2e0bc2);
    HDAE5000_DebugTrace(ram_2e0be2);
}

void PP_Svc20(void)
{
    if (PP_W(0) & 0x01)
        CALLV(HAMA->PreLswLoad)();
    if (PP_W(0) & 0x02)
        CALLV(HAMA->PrePmLoad)();
    if (PP_W(0) & 0x04)
        CALLV(HAMA->SeqLoadPre)();
    if (PP_W(0) & 0x08)
        CALLV(HAMA->cmp_ld_mae)();
    if (PP_W(0) & 0x10)
        CALLV(HAMA->PreTmLoad)();
    if (PP_W(0) & 0x20)
        CALLV(HAMA->msp_ld_mae)();
    if (PP_W(0) & 0x80)
        CALLV(HAMA->PreMidiLoad)();
    HDAE5000_DebugTrace(ram_2e0c34);
    HDAE5000_DebugTrace(ram_2e0c54);
}
