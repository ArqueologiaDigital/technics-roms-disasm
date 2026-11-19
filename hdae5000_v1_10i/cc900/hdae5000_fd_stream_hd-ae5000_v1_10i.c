/* Functions of hd-ae5000_v1_10i.s.  (hdae5000_fd_stream_hd-ae5000_v1_10i.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_fd_stream_hd-ae5000_v1_10i.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();

/* an array read as an lvalue member at offset 0 (see the header comment) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
extern char HDAE5000_Str_Blank12Tab[];
extern char HDAE5000_FdList_RowsTemplate[];

typedef char DirRow[21];
typedef char FlsRow[21];
extern char HDAE5000_RAM_DirListText[];
extern char HDAE5000_RAM_FlsListText[];
extern unsigned int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_FlsPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage[];
/* the formats are pushed as 32-bit constants (pushw hi16 / pushw lo16), as SeparateOutput_Apply's (hd_r4_g3.c) */
#define FMT_DIR ((const char *)0x2e23d2L)   /* HDAE5000_Fmt_3_3d, "%3.3d" */
#define FMT_FLS ((const char *)0x2e2e76L)   /* HDAE5000_Fmt_3_3d_FlsList_BuildPage, "%3.3d" */

struct ResInfo { unsigned long addr; unsigned long size; };
struct SqtHdr { unsigned char pad[199]; unsigned char bank; };
struct SqtBlk { unsigned char pad[78]; unsigned int len[1]; };

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[0x8000];
extern unsigned char HDAE5000_RAM_RcmStreamState[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;      /* the open write's first-cluster slot */
extern unsigned char HDAE5000_RAM_HdStreamState;

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
/* the workspace's object 0x148 (ws + 0x11fa), function +0x18 (hd_r4_ppa.c PP_Svc16 gave the single load, run 56) */
#define OBJ148_FN6 (((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])

void HDAE5000_FdList_Clear(void)
{
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, HDAE5000_Str_Blank12Tab, 14);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.rows, HDAE5000_FdList_RowsTemplate, 0xf1);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line1, 0, 20);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line2, 0, 20);
}

/* part 1 (PMT): a 16-byte header first; header byte 15 == 8 marks the old 0x1eb0-byte layout, which is loaded and
   then given the new mark 0x50 and the header copied over the loaded data's start */

/* part 2 (SQT): a 0x5000-byte read into the stream buffer gives the length word of the current bank (header byte 199
   selects a 2048-byte bank; the word at +78 of it, in 16-byte units), added to resource 3's size */

/* ret is never assigned in the ROM: the WriteFile result is only compared, and SeqSavePost / the return read the
   uninitialised slot */
