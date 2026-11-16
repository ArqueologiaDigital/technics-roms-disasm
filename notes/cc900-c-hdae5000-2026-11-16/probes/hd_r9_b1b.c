/* lane_hd round 9, helper h_big1, form b: hd_r9_b1.c's functions (same names) where there is a real alternative;
   Song_IsUsed has none and is only in form a.  Options: -Xr.
   - PartList_Build: the mask copied to a local first (`m = mask;`), in case V4.23 keeps a stack parameter in its
     slot and only a local gets IZ (the ROM loads IZ from the stack argument before the first test);
   - FormatDialog_CodeDigit: the 10 cleared bytes as a struct (count byte, one unused byte, the digits), so the
     store is `fc.digits[fc.count]` (the member offset 2 folded into the index, bare symbol as base) and the
     compare string is `fc.digits`;
   - Song_CheckFreeSpace: ret and total initialised in their declarations, total declared `register`. */
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };
struct FmtCode { unsigned char count; unsigned char unused; char digits[8]; };

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
extern struct FmtCode ram_22ad9c;   /* HDAE5000_RAM_FormatCodeDigits = ram_22ad9c.digits */

void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask)
{
    unsigned int m;

    m = mask;
    if (dir == 0xffff || song == 0xffff) {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x7f);
    } else {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_Text, 0x7f);
        if (m != 0xffff) {
            if (!(m & 0x001)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[0], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x002)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[14], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x004)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[28], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x008)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[42], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x010)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[56], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x020)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[70], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x040)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[84], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x080)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[98], HDAE5000_PartName_Blank, 14);
            if (!(m & 0x100)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[112], HDAE5000_PartName_Blank, 14);
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
    ram_22ad9c.digits[ram_22ad9c.count] = buf[0];
    ram_22ad9c.count++;
    if (ram_22ad9c.count == 6) {
        if (HDAE5000_StrPrefixCmp(ram_22ad9c.digits, "050354") == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp(ram_22ad9c.digits, "965768") == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(&ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

int HDAE5000_Song_CheckFreeSpace(unsigned int mask)
{
    int ret = 0;
    struct ResInfo info;
    register unsigned long total = 0;

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
