/* lane_hd round 2, helper l, form a: the song part loaders / savers (HDAE5000_LoadSong_* / _SaveSong_*), the two
   "AttenCp..SwCatch" object procedures and HDAE5000_HD_WriteClose (hdae5000/, v2.06i).  Options: -Xr.
   Reading of the hand source behind these guesses:
   - the song record of (dir, song) is HDAE5000_RAM_DirNames + dir * 0x4c0 + 0x780 + song * 76; the ROM evaluates
     song * 76 first and folds the field offset into the symbol (lda xR, (SongRecords-0x780+52:24)), so the field
     offset is written next to the symbol: DirNames + 52 + (offset);
   - record fields: has[10] part bytes at +26 (cmp +29, tm +30, msp +31, md +33), slot[10] first-cluster longs at
     +36 (cmp +48, tm +52, msp +56, md +64);
   - GetResouceInfo(kind, &info) fills an 8-byte local {address, size}; an argument that is a member of it is spilled
     as its address before an argument with a call (the record offset), as V4.23 does for an lvalue argument;
   - ret = xsp+10 overlaps the argument temporaries (xsp+8..11): V4.23 seems to share the slot where ret is dead. */
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned char *addr; unsigned long size; };
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

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(d, s, o) ((long *)(HDAE5000_RAM_DirNames + (o) + SONG_OFS(d, s)))
#define HAS(d, s, o) (*(HDAE5000_RAM_DirNames + (o) + SONG_OFS(d, s)))

int HDAE5000_LoadSong_Tm(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    int ret;

    ret = 0;
    if (*SLOT(dir, song, 52) != -1L) {
        HAMA->GetResouceInfo(6, &info);
        info.size = 0x72aaL;
        HAMA->PreTmLoad();
        ret = HDAE5000_HD_ReadFile(info.addr, info.size, SLOT(dir, song, 52));
        HAMA->PostTmLoad(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    int ret;
    unsigned long size;

    ret = 0;
    if (*SLOT(dir, song, 48) != -1L) {
        HAMA->GetResouceInfo(5, &info);
        if (HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, 0x200L, SLOT(dir, song, 48)) == -1)
            return -1;
        size = (size = ((struct CmpHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks) << 4;
        HAMA->cmp_ld_mae();
        ret = HDAE5000_HD_ReadFile(info.addr, size, SLOT(dir, song, 48));
        HAMA->cmp_ld_ato(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    int ret;
    unsigned long size;

    ret = 0;
    if (*SLOT(dir, song, 56) != -1L) {
        HAMA->GetResouceInfo(7, &info);
        if (HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, 0x200L, SLOT(dir, song, 56)) == -1)
            return -1;
        size = (size = ((struct MspHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks) << 4;
        HAMA->msp_ld_mae();
        ret = HDAE5000_HD_ReadFile(info.addr, size, SLOT(dir, song, 56));
        HAMA->msp_ld_ato(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Md(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    int ret;

    ret = 0;
    if (*SLOT(dir, song, 64) != -1L) {
        HAMA->GetResouceInfo(9, &info);
        HAMA->PreMidiLoad();
        ret = HDAE5000_HD_ReadFile(HDAE5000_RAM_HdStreamBuffer, info.size, SLOT(dir, song, 64));
        HAMA->FlashWrite(1, HDAE5000_RAM_HdStreamBuffer, (unsigned int)info.size, 0x3d3000L);
        HAMA->PostMidiLoad(ret);
    }
    return ret;
}

int HDAE5000_SaveSong_Tm(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    int ret;

    HAMA->GetResouceInfo(6, &info);
    info.size = 0x72aaL;
    HAMA->PreTmSave();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, SLOT(dir, song, 52));
    if (ret != -1)
        HAS(dir, song, 30) = 1;
    HAMA->PostTmSave(ret);
    return ret;
}

int HDAE5000_SaveSong_Cmp(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    int ret;

    HAMA->GetResouceInfo(5, &info);
    info.size = CALLR(unsigned long, HAMA->cmp_sv_mae)();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, SLOT(dir, song, 48));
    if (ret != -1)
        HAS(dir, song, 29) = 1;
    HAMA->cmp_sv_ato(ret);
    return ret;
}

int HDAE5000_SaveSong_Msp(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    int ret;

    HAMA->GetResouceInfo(7, &info);
    info.size = CALLR(unsigned long, HAMA->msp_sv_mae)();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, SLOT(dir, song, 56));
    if (ret != -1)
        HAS(dir, song, 31) = 1;
    HAMA->msp_sv_ato(ret);
    return ret;
}

int HDAE5000_SaveSong_Md(unsigned int dir, unsigned int song)
{
    struct ResInfo info;
    int ret;

    HAMA->GetResouceInfo(9, &info);
    HAMA->PreMidiSave();
    ret = HDAE5000_HD_WriteFile(info.addr, info.size, SLOT(dir, song, 64));
    if (ret != -1)
        HAS(dir, song, 33) = 1;
    HAMA->PostMidiSave(ret);
    return ret;
}

/* switch: V4.23 compares the cases in reverse source order (HD_GetBlockInfo: cases 0,1,2 compared 2,1,0) and lays
   the bodies out in source order; the ROM's default body directly follows the compare chain, so default comes
   first.  ev and arg stay in XBC / XDE, so passing them on to InheritedProc costs no instruction. */
long HDAE5000_AttenCpToHDSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
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
    }
}

long HDAE5000_AttenCpToMarkSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
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
    }
}

void HDAE5000_HD_WriteClose(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
