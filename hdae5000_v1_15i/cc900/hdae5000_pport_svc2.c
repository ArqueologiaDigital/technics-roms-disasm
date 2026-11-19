/* Functions of hdae5000_ui_display.s.  (hdae5000_pport_svc2.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_pport_svc2.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: PP_Svc01=HDAE5000_PPORT_Svc01_GetInfoBlockPointer
   cc900-module: HDAE5000_DebugTrace
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned char *addr; unsigned long size; };
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };
struct SongRec { unsigned char name[26]; unsigned char part[10]; unsigned long slot[9]; unsigned char tail[4]; };
struct SongRecB { unsigned char name[26]; unsigned char part[9]; unsigned long slot[9]; unsigned char tail[4]; };

extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_PportReadState;
extern unsigned char HDAE5000_RAM_DirNames[];

#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))
#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))
#define SRECB(d, s) ((struct SongRecB *)(HDAE5000_RAM_DirNames + SONG_OFS(d, s)))

/* trace banners and blank lines (HDAE5000_PPORT_SvcNN_*_Str_<name>), passed in XWA: lda */
extern char ram_2e0a62[], ram_2e0a90[];                                   /* Svc01 GetInfoBlockPointer, Blank1 */
extern char ram_2e0cd0[], ram_2e0d0a[];                                   /* Svc13 */
extern char ram_2e0de6[];                                                 /* Svc21 */
extern char ram_2e0e3a[];                                                 /* Svc24 */

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
extern char ram_2e0a80[];
#define F_ppib_adr ram_2e0a80
extern char ram_2e0cee[];
#define F_dirname ram_2e0cee
extern char ram_2e0cfc[];
#define F_sngname ram_2e0cfc
extern char ram_2e0dfe[];
#define F_SUFFIX ram_2e0dfe

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int HDAE5000_TlxPart_Describe(int kind, struct ResInfo *info);
extern int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *si);
extern int HDAE5000_HD_WriteOpen(unsigned long *slot);
extern void HDAE5000_DebugTrace(char *s);

unsigned char *PP_Svc01(void)
{
    char buf[32];

    HDAE5000_DebugTrace(ram_2e0a62);
    HDAE5000_SPrintf(buf, F_ppib_adr, (unsigned long)HDAE5000_RAM_PportInfoBlock);
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2e0a90);
    return HDAE5000_RAM_PportInfoBlock;
}

/* ---- second forms ---- */

/* only dir `register` */

/* only ret `register` */
