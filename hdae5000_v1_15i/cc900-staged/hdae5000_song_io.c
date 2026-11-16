/* hdae5000_v1_15i: the functions of hdae5000/cc900-staged/hdae5000_song_io.c that V4.23 reproduces unchanged in HD-AE5000 v1.15i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_song_io.c.
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };
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

extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
/* the address as an integer, (unsigned long)&sym[field] + record offset: V4.23 then writes the ROM's
   lda xR,(sym+field) after the offset (run 2026-11-16-52-hd-r4v, DeleteSongPart_Sqt and FlsItem_Clear) */
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))

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
