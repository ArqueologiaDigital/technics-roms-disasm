/* lane_hd round 9, helper h_big1, form a: four C? functions (no calr, each stands alone), in ROM address order:
   HDAE5000_PartList_Build, HDAE5000_FormatDialog_CodeDigit, HDAE5000_Song_IsUsed, HDAE5000_Song_CheckFreeSpace.
   Options: -Xr.
   Left out as hand assembly: HDAE5000_HD_WriteFile (an inner subroutine that pushes all seven registers, absolute
   `jp cc,(L:24)` branches, register-convention calls to HD_UDiv32), HDAE5000_HD_FreeChain_Worker and
   HDAE5000_HD_ComputeDiskUsage (push/pop of every register they touch, results passed in XWA between
   HD_Mul32 / HD_UDiv32, `push xwa` as a temporary), HDAE5000_HD_InitTables_Skip (a label inside the hand-written
   HDAE5000_HD_InitTables loop nest, not a function).
   Reading of the hand source:
   - PartList_Build: (obj in XWA, dir in BC, song in DE, mask on the stack, popped by `retd 2`).  The mask lives in
     IZ (pushw iz), obj in a stack slot; dir / song are dead after the first test.  Outer test `dir == 0xffff ||
     song == 0xffff` falls into the blank copy; then `mask != 0xffff` falls into the nine bit tests, the else
     (blank copy) is placed after them.  MemCopy's arguments are extern ROM/RAM arrays (lda + push).
   - FormatDialog_CodeDigit: the digit goes through IToA into an 8-byte auto buffer; buf[0] is stored at
     ram_22ad9c[count + 2] (index count+2 computed in BC, bare symbol as base: the pointer form folds the 2 into the
     index); the two codes are pushed `pushw @hi16 / @lo16`, which V4.23 does for a string literal of the file
     (h_pport, run 56), so they are literals here ("050354", "965768" = HDAE5000_Str_HdFormatCode /
     _Str_Track0RecoverCode).  Result in IZ: 0 not full, 2 / 3 the codes, 1 no match.
   - Song_IsUsed: nine `SLOT(k) != 0xffffffff -> return 0` tests, then 0xffff; the integer-address idiom of
     DeleteSongPart_* (run 52).
   - Song_CheckFreeSpace: `int ret` at xsp+4, `struct ResInfo info` at xsp+6 (size at +10, as LoadSong_Tm), the
     total in XIZ; then total = ClusterCount(total) (XIZ reused), and `free <= total` gives ret = -1 (cp xhl,xiz;
     jr ugt). */
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_IToA(int, char *, int);
extern int __cdecl HDAE5000_StrPrefixCmp(const char *, const char *);
extern unsigned long HDAE5000_HD_ClusterCount(unsigned long bytes);
extern unsigned long HDAE5000_HD_CountFreeClusters_Status(void);

extern char HDAE5000_RAM_PartListText[];
extern char HDAE5000_PartNames_Text[];
extern char HDAE5000_PartNames_BlankText[];
extern char HDAE5000_PartName_Blank[];
extern unsigned char ram_22ad9c[];          /* [0] = digits typed; the digits from +2 */
extern char HDAE5000_RAM_FormatCodeDigits[]; /* ram_22ad9c + 2 */
extern unsigned char HDAE5000_RAM_DirNames[];

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(unsigned long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))

void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask)
{
    if (dir == 0xffff || song == 0xffff) {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x7f);
    } else {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_Text, 0x7f);
        if (mask != 0xffff) {
            if (!(mask & 0x001)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[0], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x002)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[14], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x004)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[28], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x008)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[42], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x010)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[56], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x020)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[70], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x040)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[84], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x080)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[98], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x100)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[112], HDAE5000_PartName_Blank, 14);
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x7f);
        }
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_PartListText);
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

int HDAE5000_FormatDialog_CodeDigit(int digit)
{
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[ram_22ad9c[0] + 2] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp(HDAE5000_RAM_FormatCodeDigits, "050354") == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp(HDAE5000_RAM_FormatCodeDigits, "965768") == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song)
{
    if (SLOT(0, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(1, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(2, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(3, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(4, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(5, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(6, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(7, dir, song) != 0xffffffffUL) return 0;
    if (SLOT(8, dir, song) != 0xffffffffUL) return 0;
    return -1;
}

int HDAE5000_Song_CheckFreeSpace(unsigned int mask)
{
    int ret;
    struct ResInfo info;
    unsigned long total;

    ret = 0;
    total = 0;
    if (mask & 0x001) {
        CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
        total += info.size;
        CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
        total += info.size;
    }
    if (mask & 0x002) {
        CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
        total += info.size;
    }
    if (mask & 0x004) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
        total += info.size;
        total += CALLR(unsigned long, HAMA->SeqSavePre)();
    }
    if (mask & 0x008)
        total += CALLR(unsigned long, HAMA->cmp_sv_mae)();
    if (mask & 0x010) {
        info.size = 0x72aaL;
        total += info.size;
    }
    if (mask & 0x020)
        total += CALLR(unsigned long, HAMA->msp_sv_mae)();
    if (mask & 0x040) {
        CALLV(HAMA->GetResouceInfo)(8, (char *)&info);
        total += info.size;
    }
    if (mask & 0x080) {
        CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
        total += info.size;
    }
    if (mask & 0x100)
        total += 0x5000L;
    total = HDAE5000_HD_ClusterCount(total);
    if (HDAE5000_HD_CountFreeClusters_Status() <= total)
        ret = -1;
    return ret;
}
