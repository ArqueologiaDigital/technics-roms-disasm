/* The song screen's list refresh.
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r36_fix1.c.
   cc900-options: -Xr
   cc900-name: SongScr_q=HDAE5000_SongScreen_Refresh
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_PartList_Build HDAE5000_Lbn_ShowEntry
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

/* ---- library (stack arguments, caller pops) ---- */
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_StrNCat(char *, char *, int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

/* ---- this module (calr) ---- */
extern void HDAE5000_FdList_Clear(void);
extern int HDAE5000_FdName_SongNumber(char *name);
extern void HDAE5000_ShowErrorMessageTitle(int code);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
/* the same object (0x22aa9c) as a flat char array of unknown length: label 0, rows 14 (20 x 12), flags 0x100 and
   0x114 */
extern char ram_22aa9c[];
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern char HDAE5000_RAM_SongScreenTitle[];
extern char HDAE5000_RAM_SongListText[];

/* ---- ROM ---- */
extern char HDAE5000_Str_AllFilesPattern[];
extern char HDAE5000_Str_DIRECTORY[];
extern char ram_2e2512[];   /* HDAE5000_Str_Chr3A_SongScreen_Refresh */
extern char HDAE5000_Str_Blank0Tab[];
extern char HDAE5000_Str_Chr3A2020202020[];
extern char HDAE5000_Str_TLBN[];
extern char ram_2e250c[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh, "%2.2d" */
extern char ram_2e2534[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh_2 */
extern unsigned long ram_2e24e8[];   /* HDAE5000_SongScreen_Refresh_ObjIds */
extern unsigned long ram_2e24f0[];   /* HDAE5000_SongScreen_Refresh_ObjIds_2 */
extern unsigned long ram_2e24f8[];   /* HDAE5000_SongScreen_Refresh_ObjIds_3 */

/* an array read as an lvalue member at offset 0: `lda xwa,(sym); ld xde,xwa` (hd_r9_b2.c, TitleInfo_Build) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

/* the main CPU's FAT driver's find block: the name at +6 */
struct FindBlk { char head[6]; char name[260]; };

/* The row length 30 is written `(0, 30) * i`: only a comma expression makes V4.23 load the constant into WA and
   multiply by the loop register, as the ROM does (run 2026-11-17-3-hd-r36). */

/* the row length as an enum constant; the row address as pointer + product */

/* the row length as a file-scope static const int */

/* a long product narrowed to int */

/* the row length as the value of a comma expression; the row address as product + pointer */
void SongScr_q(unsigned char page, unsigned char skip)
{
    char buf[22];
    int i;
    unsigned int m;
    const void *rec;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2e250c, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, ram_2e2512);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongScreenTitle);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[2], HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2e2534, i + 1);
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[0], buf, 2);
            rec = HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i);
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[3], rec, 26);
        }
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongListText);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2e24f8[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2e24f8[page], 0xffff, 0xffff, 0xffff);
}

/* ------------------------------------------------------------------------------------------------------------- */

/* unchanged from hdae5000/cc900/hdae5000_drv_screens4_ui_display.c (MATCH there) */
