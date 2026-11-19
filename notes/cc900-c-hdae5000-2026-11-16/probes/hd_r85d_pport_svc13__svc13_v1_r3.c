/* Functions of hdae5000_ui_display.s.  (hdae5000_pport_svc13.c, ported to hdae5000_v1_10i)
   Firmware C (cc900 phase 6), built by Toshiba V4.23.
   cc900-options: -Xr
   cc900-module: HDAE5000_DebugTrace
   v1.x: eight song parts (v1.x has no HDAE5000_TlxPart_Describe): no TLX record at +191, and the song's part
   flags stop at has[7]; dir is used directly (the ROM stores both arguments in the frame and keeps only ret in IZ,
   `pushw iz`, where v2.06i copied dir to IZ and kept ret in QIZ), so there is no local copy d.
   round 3: an old-style definition under the label's own name (run 2026-11-19-80: neither a volatile dir
   nor a register ret kept dir out of IZ; V4.23 may not give old-style parameters a register).
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned char *addr; unsigned long size; };
struct SongInfo { unsigned int mask; char dirname[16]; char songname[26]; unsigned char has[10]; };

extern unsigned char HDAE5000_RAM_PportInfoBlock[];

#define PPIB HDAE5000_RAM_PportInfoBlock
#define PP_W(o) (*(unsigned int *)(PPIB + (o)))
#define PP_L(o) (*(unsigned long *)(PPIB + (o)))

/* trace banner and blank line (HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_*, their first 31 characters
   shared, so ram_<hex>), passed in XWA: lda */
extern char ram_2e0b40[], ram_2e0b7a[];

/* format strings, stacked SPrintf arguments: pushw hi16 / pushw lo16 */
extern char ram_2e0b5e[];
#define F_dirname ram_2e0b5e
extern char ram_2e0b6c[];
#define F_sngname ram_2e0b6c

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int HDAE5000_HD_GetSongInfo(unsigned int dir, unsigned int song, struct SongInfo *si);
extern void HDAE5000_DebugTrace(char *s);

int HDAE5000_PPORT_Svc13_SendInfosAboutSong(dir, song)
unsigned int dir;
unsigned int song;
{
    struct SongInfo si;
    struct ResInfo info;
    char buf[64];
    int ret;

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
    if (HDAE5000_HD_GetSongInfo(dir, song, (void *)&si) != -1) {
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
        ret = 0;
    }
    HDAE5000_DebugTrace(ram_2e0b40);
    HDAE5000_SPrintf(buf, F_dirname, PPIB + 28);
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_sngname, PPIB + 2);
    HDAE5000_DebugTrace(buf);
    HDAE5000_DebugTrace(ram_2e0b7a);
    return ret;
}
