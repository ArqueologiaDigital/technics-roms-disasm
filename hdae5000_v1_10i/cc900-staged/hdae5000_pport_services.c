/* hdae5000_v1_10i: the functions of hdae5000/cc900-staged/hdae5000_pport_services.c that V4.23 reproduces unchanged in HD-AE5000 v1.10i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_pport_services.c.
   cc900-options: -Xr
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

void HDAE5000_DebugTrace(char *s)
{
}
