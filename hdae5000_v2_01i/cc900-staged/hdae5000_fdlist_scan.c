/* hdae5000_v2_01i: the functions of hdae5000/cc900/hdae5000_fdlist_scan.c that V4.23 reproduces in HD-AE5000 v2.01i with the tree's own object ids (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_fdlist_scan.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_PartList_Build HDAE5000_Lbn_ShowEntry
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

/* ---- library (stack arguments, caller pops) ---- */
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);

/* ---- this module (calr) ---- */
extern void HDAE5000_FdList_Clear(void);
extern int HDAE5000_FdName_SongNumber(char *name);
extern void HDAE5000_ShowErrorMessageTitle(int code);

/* ---- RAM ---- */
struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
/* the same object (0x22aa9c) as a flat char array of unknown length: label 0, rows 14 (20 x 12), flags 0x100 and
   0x114 */
extern char ram_22aa9c[];

/* ---- ROM ---- */
extern char HDAE5000_Str_AllFilesPattern[];

/* an array read as an lvalue member at offset 0: `lda xwa,(sym); ld xde,xwa` (hd_r9_b2.c, TitleInfo_Build) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

/* the main CPU's FAT driver's find block: the name at +6 */
struct FindBlk { char head[6]; char name[260]; };

/* ------------------------------------------------------------------------------------------------------------- */

/* the flag's index: an unsigned sum converted back to int */
int HDAE5000_FdList_Scan(void)
{
    struct FindBlk blk;
    int ret;
    char *label;
    long h;
    int n;
    unsigned int i;

    ret = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, -1L);
        HDAE5000_FdList_Clear();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, label, HDAE5000_StrLen(label));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
        if ((h = CALLR(long, HAMA->findfirst)((long)HDAE5000_Str_AllFilesPattern, (char *)&blk)) >= 0) {
            if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                ram_22aa9c[(int)((unsigned int)n + 0x100)] = 1;
                HDAE5000_MemCopy(&ram_22aa9c[17] + n * 12, &blk.name[2], 6);
            }
            while (CALLR(int, HAMA->findnext)(h, (char *)&blk) == 0) {
                if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                    ram_22aa9c[(int)((unsigned int)n + 0x100)] = 1;
                    HDAE5000_MemCopy(&ram_22aa9c[17] + n * 12, &blk.name[2], 6);
                }
            }
            CALLV(HAMA->findclose)(h);
        }
        for (i = 0; i < 20; i++) {
            ram_22aa9c[(unsigned long)(i * 12 + 10) + 14] = ' ';
            if (ram_22aa9c[(unsigned long)i + 0x114] == 1)
                ram_22aa9c[(unsigned long)(i * 12 + 10) + 14] = '*';
        }
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
        break;
    default:
        HDAE5000_ShowErrorMessageTitle(2);
        ret = -1;
    }
    return ret;
}

/* the flag's index: the value of a comma expression */

/* the flag's index: int plus an unsigned constant, converted back */

/* the flag's base: the structure's address converted to a char pointer */

/* the flag's base: the flat array as a member at offset 0 of a wrapper structure */
