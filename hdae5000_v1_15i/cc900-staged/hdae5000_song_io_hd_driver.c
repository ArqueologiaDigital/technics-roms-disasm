/* hdae5000_v1_15i: the functions of hdae5000/cc900/hdae5000_song_io_hd_driver.c that V4.23 reproduces in HD-AE5000 v1.15i with the tree's own object ids (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_song_io_hd_driver.c.
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct ResInfo { unsigned long addr; unsigned long size; };
struct CmpHdr { unsigned char pad[46]; unsigned int blocks; };
struct MspHdr { unsigned char pad[28]; unsigned int blocks; };
struct SqtHdr { unsigned char pad[198]; unsigned char pad198; unsigned char bank; };
struct SqtBlk { unsigned char pad[78]; unsigned char len[2]; };

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

/* part 2 (SQT): a 0x5000-byte read into the stream buffer gives the length word of the current bank (header byte 199
   selects a 2048-byte bank; the word at +78 of it, in 16-byte units), added to resource 3's size */

/* ret is never assigned in the ROM: the WriteFile result is only compared, and SeqSavePost / the return read the
   uninitialised slot */

/* prototypes for the last function only (see the header comment) */
extern int HDAE5000_HD_WriteFile(const void *, unsigned long, long *);
extern int HDAE5000_HD_AppendFile(const void *, unsigned long, long *);
