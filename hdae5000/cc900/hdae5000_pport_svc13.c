/* Functions of hdae5000_ui_display.s.  (hdae5000_pport_svc13.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_pport_svc13.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: PP13_c=HDAE5000_PPORT_Svc13_SendInfosAboutSong
   cc900-module: HDAE5000_DebugTrace
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned char *addr; unsigned long size; };
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };

extern unsigned char HDAE5000_RAM_PportInfoBlock[];

#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))

/* trace banner and blank line (HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_*), passed in XWA: lda */
extern char ram_2f91cc[], ram_2f9206[];

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
extern char ram_2f91ea[];
#define F_dirname ram_2f91ea
extern char ram_2f91f8[];
#define F_sngname ram_2f91f8

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int HDAE5000_TlxPart_Describe(int kind, struct ResInfo *info);
extern int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *si);
extern void HDAE5000_DebugTrace(char *s);

/* a use of dir that makes no code: a statement without effect */

/* a use of dir that makes no code: a trace line compiled out */

/* a local copy of dir, declared before ret */
int PP13_c(unsigned int dir, unsigned int song)
{
    struct SongInfo si;
    struct ResInfo info;
    char buf[64];
    unsigned int d;
    int ret;

    d = dir;
    ret = 1;
    PP_W(0) = 0;
    HDAE5000_MemFill(PPIB + 28, ' ', 16);
    HDAE5000_MemFill(PPIB + 2, ' ', 26);
    CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
    PP_L(70) = (unsigned long)info.addr;
    PP_L(74) = info.size;
    PPIB[78] = 0;
    CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
    PP_L(79) = (unsigned long)info.addr;
    PP_L(83) = info.size;
    PPIB[87] = 0;
    CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
    PP_L(88) = (unsigned long)info.addr;
    PP_L(92) = info.size;
    PPIB[96] = 0;
    CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
    PP_L(97) = (unsigned long)info.addr;
    PP_L(101) = info.size;
    PP_L(101) += CALLR(unsigned long, HAMA->SeqSavePre)();
    PPIB[105] = 0;
    CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
    PP_L(106) = (unsigned long)info.addr;
    PP_L(110) = CALLR(unsigned long, HAMA->cmp_sv_mae)();
    PPIB[114] = 0;
    CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
    PP_L(115) = (unsigned long)info.addr;
    PP_L(119) = 0x72aaL;
    PPIB[123] = 0;
    CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
    PP_L(124) = (unsigned long)info.addr;
    PP_L(128) = CALLR(unsigned long, HAMA->msp_sv_mae)();
    PPIB[132] = 0;
    CALLV(HAMA->GetResouceInfo)(8, (char *)&info);
    PP_L(133) = (unsigned long)info.addr;
    PP_L(137) = 0xad000L;
    PPIB[141] = 0;
    CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
    PP_L(142) = (unsigned long)info.addr;
    PP_L(146) = info.size;
    PPIB[150] = 0;
    HDAE5000_TlxPart_Describe(10, (void *)&info);
    PP_L(191) = (unsigned long)info.addr;
    PP_L(195) = info.size;
    PPIB[199] = 0;
    if (HDAE5000_HD_GetSongInfo(d, song, (void *)&si) != -1) {
        PP_W(0) = si.mask;
        HDAE5000_MemCopy(PPIB + 28, si.dirname, 16);
        HDAE5000_MemCopy(PPIB + 2, si.songname, 26);
        PPIB[78] = si.has[0];
        PPIB[96] = si.has[1];
        PPIB[105] = si.has[2];
        PPIB[114] = si.has[3];
        PPIB[123] = si.has[4];
        PPIB[132] = si.has[5];
        PPIB[141] = si.has[6];
        PPIB[150] = si.has[7];
        PPIB[199] = si.has[8];
        ret = 0;
    }
    HDAE5000_DebugTrace(ram_2f91cc);
    HDAE5000_SPrintf(buf, F_dirname, PPIB + 28);
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_sngname, PPIB + 2);
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2f9206);
    return ret;
}

/* unsigned ret with its initialiser, after the structure locals */

/* ret declared before the structure locals */
