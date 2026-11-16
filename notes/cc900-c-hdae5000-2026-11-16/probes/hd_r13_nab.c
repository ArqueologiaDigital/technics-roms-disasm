/* lane_hd round 13, helper h_near2, form b: hd_r13_na.c's functions (same names, same order) with these second forms:
   - LoadSong_Cmp / _Msp / _Sqt: the widening and shift as a multiply, size = (unsigned long)n * 16 (in case only a
     multiply by a power of two is done in the converted value's register);
   - LoadSong_Pmt: the header buffer as &hdr[0] passed through a cast to an integer, (unsigned long)&hdr[0];
   - LoadSong_Sqt: the length word through an unsigned int member at +78 and an explicit address,
     *(unsigned int *)&blk->len, instead of a char array cast;
   - HD_WriteClose: prototypes with an unsigned long first parameter and the buffer passed as (unsigned long)Buffer
     (run 66 form b's computed argument, which V4.23 parked in XDE unprototyped), to test the prototype alone.
   Everything else as in form a. */
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };
struct CmpHdr { unsigned char pad[46]; unsigned int blocks; };
struct MspHdr { unsigned char pad[28]; unsigned int blocks; };
struct SqtHdr { unsigned char pad[198]; unsigned char pad198; unsigned char bank; };
struct SqtBlk { unsigned char pad[78]; unsigned int len; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
extern char HDAE5000_Str_Cphd[];
extern char HDAE5000_Str_Cphd_AttenCpToMarkSwCatch[];

extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
/* the address as an integer, (unsigned long)&sym[field] + record offset: V4.23 then writes the ROM's
   lda xR,(sym+field) after the offset (run 2026-11-16-52-hd-r4v, DeleteSongPart_Sqt and FlsItem_Clear) */
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
/* the workspace's object 0x148 (ws + 0x11fa), function +0x18 (hd_r4_ppa.c PP_Svc16 gave the single load, run 56) */
#define OBJ148_FN6 (((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])

long HDAE5000_AttenCpToHDSwCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_Cphd);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_HDDMENU, EVT_SHOW, 0L);
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
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_Cphd_AttenCpToMarkSwCatch);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 6:
        case 7:
            CALLV(ROOT->PostEvent)(OBJ_CP_FD, EVT_SHOW, 0L);
        }
        return 0;
    }
}

/* part 1 (PMT): a 16-byte header first; header byte 15 == 8 marks the old 0x1eb0-byte layout, which is loaded and
   then given the new mark 0x50 and the header copied over the loaded data's start */
int HDAE5000_LoadSong_Pmt(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned char hdr[16];
    int old = 0;

    if (SLOT(1, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
        ret = HDAE5000_HD_ReadFile((unsigned long)&hdr[0], 0x10L, &SLOT(1, dir, song));
        if (hdr[15] == 8) {
            old = 1;
            info.size = 0x1eb0L;
        }
        CALLV(HAMA->PrePmLoad)();
        ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(1, dir, song));
        if (old == 1) {
            hdr[15] = 0x50;
            HDAE5000_MemCopy((unsigned char *)info.addr, hdr, 0x10);
        }
        CALLV(HAMA->PostPmLoad)(ret);
    }
    return ret;
}

/* part 2 (SQT): a 0x5000-byte read into the stream buffer gives the length word of the current bank (header byte 199
   selects a 2048-byte bank; the word at +78 of it, in 16-byte units), added to resource 3's size */
int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info3;
    struct ResInfo info4;
    unsigned long size;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        size = (unsigned long)*(unsigned int *)&((struct SqtBlk *)((unsigned int *)HDAE5000_RAM_HdStreamBuffer
               + ((int)((struct SqtHdr *)HDAE5000_RAM_HdStreamBuffer)->bank << 10)))->len * 16;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}

int HDAE5000_LoadSong_Cmp(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;

    if (SLOT(3, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(3, dir, song)) == -1)
            return -1;
        size = (unsigned long)((struct CmpHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks * 16;
        CALLV(HAMA->cmp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(3, dir, song));
        CALLV(HAMA->cmp_ld_ato)(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Tm(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SLOT(4, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
        info.size = 0x72aaL;
        CALLV(HAMA->PreTmLoad)();
        ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(4, dir, song));
        CALLV(HAMA->PostTmLoad)(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Msp(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;
    unsigned long size;

    if (SLOT(5, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
        if (HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, 0x200L, &SLOT(5, dir, song)) == -1)
            return -1;
        size = (unsigned long)((struct MspHdr *)HDAE5000_RAM_HdStreamBuffer)->blocks * 16;
        CALLV(HAMA->msp_ld_mae)();
        ret = HDAE5000_HD_ReadFile(info.addr, size, &SLOT(5, dir, song));
        CALLV(HAMA->msp_ld_ato)(ret);
    }
    return ret;
}

int HDAE5000_LoadSong_Md(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info;

    if (SLOT(7, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
        CALLV(HAMA->PreMidiLoad)();
        ret = HDAE5000_HD_ReadFile((unsigned long)HDAE5000_RAM_HdStreamBuffer, info.size, &SLOT(7, dir, song));
        CALLV(HAMA->FlashWrite)(1, (unsigned long)HDAE5000_RAM_HdStreamBuffer, (unsigned int)info.size, 0x3d3000L);
        CALLV(HAMA->PostMidiLoad)(ret);
    }
    return ret;
}

/* ret is never assigned in the ROM: the WriteFile result is only compared, and SeqSavePost / the return read the
   uninitialised slot */
int HDAE5000_SaveSong_Sqt(unsigned int dir, unsigned int song)
{
    int ret;
    unsigned long size;
    struct ResInfo info3;
    struct ResInfo info4;

    CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
    CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
    size = info3.size + CALLR(unsigned long, HAMA->SeqSavePre)();
    if (HDAE5000_HD_WriteFile(info3.addr, size, &SLOT(2, dir, song)) != -1)
        HAS(2, dir, song) = 1;
    CALLV(HAMA->SeqSavePost)(ret);
    return ret;
}

int HDAE5000_SaveSong_Cmp(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    CALLV(HAMA->GetResouceInfo)(5, (char *)&info);
    info.size = CALLR(unsigned long, HAMA->cmp_sv_mae)();
    if ((ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SLOT(3, dir, song))) != -1)
        HAS(3, dir, song) = 1;
    CALLV(HAMA->cmp_sv_ato)(ret);
    return ret;
}

int HDAE5000_SaveSong_Tm(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    CALLV(HAMA->GetResouceInfo)(6, (char *)&info);
    info.size = 0x72aaL;
    CALLV(HAMA->PreTmSave)();
    if ((ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SLOT(4, dir, song))) != -1)
        HAS(4, dir, song) = 1;
    CALLV(HAMA->PostTmSave)(ret);
    return ret;
}

int HDAE5000_SaveSong_Msp(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    CALLV(HAMA->GetResouceInfo)(7, (char *)&info);
    info.size = CALLR(unsigned long, HAMA->msp_sv_mae)();
    if ((ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SLOT(5, dir, song))) != -1)
        HAS(5, dir, song) = 1;
    CALLV(HAMA->msp_sv_ato)(ret);
    return ret;
}

int HDAE5000_SaveSong_Md(unsigned int dir, unsigned int song)
{
    int ret;
    struct ResInfo info;

    CALLV(HAMA->GetResouceInfo)(9, (char *)&info);
    CALLV(HAMA->PreMidiSave)();
    if ((ret = HDAE5000_HD_WriteFile(info.addr, info.size, &SLOT(7, dir, song))) != -1)
        HAS(7, dir, song) = 1;
    CALLV(HAMA->PostMidiSave)(ret);
    return ret;
}

/* prototypes for the last function only (see the header comment) */
extern int HDAE5000_HD_WriteFile(unsigned long, unsigned long, long *);
extern int HDAE5000_HD_AppendFile(unsigned long, unsigned long, long *);

void HDAE5000_HD_WriteClose(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
