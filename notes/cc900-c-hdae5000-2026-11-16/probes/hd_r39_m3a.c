/* lane_hd round 39, helper h_m3: HDAE5000_PPORT_Svc13_SendInfosAboutSong (hdae5000_ui_display.s), five forms.
   From hd_r36_fix4p.c (run 2026-11-17-3-hd-r36: PP_Svc13 / b / c all compiled to the same code).
   cc900-options: -Xr
   cc900-module: HDAE5000_DebugTrace
   cc900-name: PP13_a=HDAE5000_PPORT_Svc13_SendInfosAboutSong
   cc900-name: PP13_b=HDAE5000_PPORT_Svc13_SendInfosAboutSong
   cc900-name: PP13_c=HDAE5000_PPORT_Svc13_SendInfosAboutSong
   cc900-name: PP13_d=HDAE5000_PPORT_Svc13_SendInfosAboutSong
   cc900-name: PP13_e=HDAE5000_PPORT_Svc13_SendInfosAboutSong
   Run r36 against the ROM: every instruction agrees except the frame.  The ROM keeps dir in IZ and ret in QIZ
   (frame 128, `push xiz`, only song in a stack word, at xsp+130); V4.23 kept ret in IZ and both parameters in
   stack words (frame 130, `pushw iz`), whatever `register` said (three forms, one result).
   Reading of the matched functions (their built code under hdae5000/includes/generated/cc900/):
   - PPORT_Svc25 (dst used twice, ret assigned three times): the PARAMETER dst has XIZ and ret a stack word;
   - PPORT_Svc23 (src used once, ret as here): ret has IZ, as r36 gave here;
   - LoadSong (dir nine uses, ret many): dir IZ, ret QIZ, song and mask in stack words: this function's ROM shape.
   So a parameter with two uses or more is served before the locals, one with a single use after them (and then
   only IZ is offered, never QIZ).  The ROM's shape needs dir to count as used twice although it is loaded once:
   a use that makes no code (a statement without effect, or a debug line compiled out).  That is forms a and b.
   - PP13_a: `(void)dir;` as the first statement (r36's declarations, no `register`);
   - PP13_b: a trace line under `if (0)` that names dir, before the last blank trace line;
   - PP13_c: a local copy `d = dir;` declared before ret (dir dies at the copy, d and ret are the two locals);
   - PP13_d: the brief's idiom, `unsigned int ret = 1;` declared after the structure locals, nothing else;
   - PP13_e: declaration order, `int ret;` before the structure locals, nothing else.
   Not sure: whether V4.23 drops `(void)dir;` and the `if (0)` body without code; whether such a use counts.
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
int PP13_a(unsigned int dir, unsigned int song)
{
    struct SongInfo si;
    struct ResInfo info;
    char buf[64];
    int ret;

    (void)dir;
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

/* a use of dir that makes no code: a trace line compiled out */
int PP13_b(unsigned int dir, unsigned int song)
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
    HDAE5000_TlxPart_Describe(10, (void *)&info);
    PP_L(191) = (unsigned long)info.addr;
    PP_L(195) = info.size;
    PPIB[199] = 0;
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
        PPIB[199] = si.has[8];
        ret = 0;
    }
    HDAE5000_DebugTrace(ram_2f91cc);
    HDAE5000_SPrintf(buf, F_dirname, PPIB + 28);
    HDAE5000_DebugTrace(buf);
    HDAE5000_SPrintf(buf, F_sngname, PPIB + 2);
    HDAE5000_DebugTrace(buf);
    if (0) {
        HDAE5000_SPrintf(buf, F_dirname, dir);
        HDAE5000_DebugTrace(buf);
    }
    HDAE5000_DebugTrace(ram_2f9206);
    return ret;
}

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
int PP13_d(unsigned int dir, unsigned int song)
{
    struct SongInfo si;
    struct ResInfo info;
    char buf[64];
    unsigned int ret = 1;

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

/* ret declared before the structure locals */
int PP13_e(unsigned int dir, unsigned int song)
{
    int ret;
    struct SongInfo si;
    struct ResInfo info;
    char buf[64];

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
