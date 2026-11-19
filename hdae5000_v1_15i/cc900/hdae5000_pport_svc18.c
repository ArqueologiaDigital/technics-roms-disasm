/* Functions of hdae5000_ui_display.s.  (hdae5000_pport_svc18.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_pport_svc18.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: PP_Svc18=HDAE5000_PPORT_Svc18_RequestNormalMode
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
extern char ram_2e0a62[], ram_2e0a90[];                                   /* Svc01 GetInfoBlockPointer, Blank1 */
extern char ram_2e0a92[], ram_2e0aac[];                                   /* Svc02 */
extern char ram_2e0aae[], ram_2e0b0e[];                                   /* Svc03 */
extern char ram_2e0b10[], ram_2e0b5c[];                                   /* Svc04 */
extern char ram_2e0b5e[], ram_2e0bb0[];                                   /* Svc05 */
extern char ram_2e0bb2[], ram_2e0c0c[];                                   /* Svc06 */
extern char ram_2e0c0e[], ram_2e0c2c[];                                   /* Svc07 */
extern char ram_2e0c2e[], ram_2e0c4c[];                                   /* Svc08 */
extern char ram_2e0c4e[], ram_2e0c6c[];                                   /* Svc09 */
extern char ram_2e0c6e[], ram_2e0c8a[];                                   /* Svc10 */
extern char ram_2e0c8c[], ram_2e0cb0[];                                   /* Svc11 */
extern char ram_2e0cb2[], ram_2e0cce[];                                   /* Svc12 */
extern char ram_2e0cd0[], ram_2e0d0a[];                                   /* Svc13 */
extern char ram_2e0d0c[], ram_2e0d2e[];                                   /* Svc14 */
extern char ram_2e0d30[], ram_2e0d50[];                                   /* Svc15 */
extern char ram_2e0d52[], ram_2e0d72[];                                   /* Svc16 */
extern char ram_2e0d74[], ram_2e0d88[];                                   /* Svc17 */
extern char ram_2e0d8a[], ram_2e0dc2[];                                   /* Svc19 */
extern char ram_2e0dc4[], ram_2e0de4[];                                   /* Svc20 */
extern char ram_2e0de6[];                                                 /* Svc21 */
extern char ram_2e0e0a[];                                                 /* Svc22 */
extern char ram_2e0e22[];                                                 /* Svc23 */
extern char ram_2e0e3a[];                                                 /* Svc24 */
extern char ram_2e0e50[];                                                 /* Svc25 */

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
extern char ram_2e0a80[];
#define F_ppib_adr ram_2e0a80
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
extern char ram_2e0b32[];
#define F_FGB_ptr ram_2e0b32
extern char ram_2e0b40[];
#define F_FGB_wid ram_2e0b40
extern char ram_2e0b4e[];
#define F_FGB_num ram_2e0b4e
extern char ram_2e0b86[];
#define F_FEB_ptr ram_2e0b86
extern char ram_2e0b94[];
#define F_FEB_wid ram_2e0b94
extern char ram_2e0ba2[];
#define F_FEB_num ram_2e0ba2
extern char ram_2e0bd4[];
#define F_FLS_ptr ram_2e0bd4
extern char ram_2e0be2[];
#define F_FLS_wid ram_2e0be2
extern char ram_2e0bf0[];
#define F_FLS_num ram_2e0bf0
extern char ram_2e0bfe[];
#define F_FLS_ent ram_2e0bfe
extern char ram_2e0cee[];
#define F_dirname ram_2e0cee
extern char ram_2e0cfc[];
#define F_sngname ram_2e0cfc
extern char ram_2e0db2[];
#define F_work_adr ram_2e0db2
extern char ram_2e0dfe[];
#define F_SUFFIX ram_2e0dfe

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

void PP_Svc18(void)
{
    CALLV(ROOT->ApPostEvent)(-1L, EVT_CHANGE_MODE, NAKA_MODE_MD_NORMAL);
}
