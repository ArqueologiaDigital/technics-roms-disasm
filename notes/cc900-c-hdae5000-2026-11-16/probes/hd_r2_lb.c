/* lane_hd round 2, helper l, form b: other spellings of hd_r2_la.c's functions.  Differences from form a:
   - the song record as a struct pointer (SONGREC(d, s)->slot[n] / ->has[n]) instead of DirNames + field + offset,
     in case V4.23 folds the member offset into the symbol itself;
   - ret declared before info, and initialised in its declaration;
   - LoadSong_Cmp / _Msp: size computed in two statements (size = blocks; size <<= 4;);
   - the AttenCp procedures with default last;
   - HD_WriteClose with the byte count as an unsigned long difference. */
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned char *addr; unsigned long size; };
struct SongRec { unsigned char name[26]; unsigned char has[10]; long slot[10]; };
struct CmpHdr { unsigned char pad[46]; unsigned int blocks; };
struct MspHdr { unsigned char pad[28]; unsigned int blocks; };

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
extern char HDAE5000_Str_Cphd[];
extern char HDAE5000_Str_Cphd_AttenCpToMarkSwCatch[];

extern int HDAE5000_HD_ReadFile(void *dst, unsigned long n, long *slot);
extern int HDAE5000_HD_WriteFile(void *src, unsigned long n, long *slot);
extern int HDAE5000_HD_AppendFile(void *src, unsigned long n, long *slot);

#define SONGREC(d, s) ((struct SongRec *)(HDAE5000_RAM_DirNames + \
                       ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)))

int HDAE5000_LoadSong_Tm(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SONGREC(dir, song)->slot[4] != -1L) {
        HAMA->GetResouceInfo(6, &info);
        info.size = 0x72aaL;
        HAMA->PreTmLoad();
        ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SONGREC(dir, song)->slot[4]);
        HAMA->PostTmLoad(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;

    if (SONGREC(dir, song)->slot[3] != -1L) {
        HAMA->GetResouceInfo(5, &info);
        if (HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, 0x200L, &SONGREC(dir, song)->slot[3]) == -1)
            return -1;
        size = ((struct CmpHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks;
        size <<= 4;
        HAMA->cmp_ld_mae();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SONGREC(dir, song)->slot[3]);
        HAMA->cmp_ld_ato(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;

    if (SONGREC(dir, song)->slot[5] != -1L) {
        HAMA->GetResouceInfo(7, &info);
        if (HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, 0x200L, &SONGREC(dir, song)->slot[5]) == -1)
            return -1;
        size = ((struct MspHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks;
        size <<= 4;
        HAMA->msp_ld_mae();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SONGREC(dir, song)->slot[5]);
        HAMA->msp_ld_ato(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Md(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SONGREC(dir, song)->slot[7] != -1L) {
        HAMA->GetResouceInfo(9, &info);
        HAMA->PreMidiLoad();
        ret = HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, info.size, &SONGREC(dir, song)->slot[7]);
        HAMA->FlashWrite(1, HDAE5000_RAM_HdStreamBuffer, (unsigned int)info.size, 0x3d3000L);
        HAMA->PostMidiLoad(ret);
    }
    return ret;
}

int HDAE5000_SaveSong_Tm(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HAMA->GetResouceInfo(6, &info);
    info.size = 0x72aaL;
    HAMA->PreTmSave();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SONGREC(dir, song)->slot[4]);
    if (ret != -1)
        SONGREC(dir, song)->has[4] = 1;
    HAMA->PostTmSave(ret);
    return ret;
}

int HDAE5000_SaveSong_Cmp(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HAMA->GetResouceInfo(5, &info);
    info.size = CALLR(unsigned long, HAMA->cmp_sv_mae)();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SONGREC(dir, song)->slot[3]);
    if (ret != -1)
        SONGREC(dir, song)->has[3] = 1;
    HAMA->cmp_sv_ato(ret);
    return ret;
}

int HDAE5000_SaveSong_Msp(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HAMA->GetResouceInfo(7, &info);
    info.size = CALLR(unsigned long, HAMA->msp_sv_mae)();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SONGREC(dir, song)->slot[5]);
    if (ret != -1)
        SONGREC(dir, song)->has[5] = 1;
    HAMA->msp_sv_ato(ret);
    return ret;
}

int HDAE5000_SaveSong_Md(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    HAMA->GetResouceInfo(9, &info);
    HAMA->PreMidiSave();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SONGREC(dir, song)->slot[7]);
    if (ret != -1)
        SONGREC(dir, song)->has[7] = 1;
    HAMA->PostMidiSave(ret);
    return ret;
}

long HDAE5000_AttenCpToHDSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        ROOT->InheritedProc(obj, ev, arg);
        ROOT->SendEvent(obj, EVT_PARA_DRAW, HDAE5000_Str_Cphd);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 6:
        case 7:
            ROOT->PostEvent(OBJ_HDDMENU, EVT_SHOW, 0L);
        }
        return 0;
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}

long HDAE5000_AttenCpToMarkSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        ROOT->InheritedProc(obj, ev, arg);
        ROOT->SendEvent(obj, EVT_PARA_DRAW, HDAE5000_Str_Cphd_AttenCpToMarkSwCatch);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 6:
        case 7:
            ROOT->PostEvent(OBJ_CP_FD, EVT_SHOW, 0L);
        }
        return 0;
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}

void HDAE5000_HD_WriteClose(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer,
                                  (unsigned long)HDAE5000_RAM_HdStreamFill
                                  - (unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer,
                                   (unsigned long)HDAE5000_RAM_HdStreamFill
                                   - (unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
