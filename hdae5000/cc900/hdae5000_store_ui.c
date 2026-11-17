/* Functions of hdae5000_ui_display.s.  (hdae5000_store_ui.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_store_ui.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: RcmRead_b=HDAE5000_RcmStream_Read
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_UiObj_SetCaption HDAE5000_NameHistory_Push
   cc900-module: HDAE5000_HD_WriteStream
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

/* other modules (call) */
extern int HDAE5000_DirName_SetAndStore(unsigned int dir, char *name, int keep);
extern int HDAE5000_FlsName_SetAndStore(unsigned int fls, char *name, int keep);
extern int HDAE5000_SaveSong(unsigned int dir, unsigned int song, char *name, unsigned int mask, int sleep, int keep);
extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_ReadFileNext();

/* this module (calr, cc900-module) */
extern void HDAE5000_YieldUntilSem1Zero(void);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern void HDAE5000_NameHistory_Push();        /* (history, name): no prototype, both loaded straight */
extern int HDAE5000_HD_WriteStream(void *src, unsigned long n);

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_DirNameHistory[];
extern unsigned char HDAE5000_RAM_FlsNameHistory[];
extern unsigned char ram_22ac7e[];              /* the song-name history */
extern unsigned int HDAE5000_RAM_RcmStreamState;
extern unsigned int HDAE5000_RAM_RcmStreamDir;
extern unsigned int HDAE5000_RAM_RcmStreamSong;
extern int HDAE5000_RAM_RcmStreamResult;

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
#define RCM_SLOT SLOT(6, HDAE5000_RAM_RcmStreamDir, HDAE5000_RAM_RcmStreamSong)
#define RCM_HAS HAS(6, HDAE5000_RAM_RcmStreamDir, HDAE5000_RAM_RcmStreamSong)

/* rename directory dir with the "please wait" and error messages; the name goes on the directory-name history */
void HDAE5000_DirName_StoreWithUi(unsigned int dir, char *name, long obj)
{
    char buf[18];

    HDAE5000_StrNCpy(buf, name, 16);
    buf[16] = 0;
    CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 3L);
    HDAE5000_YieldUntilSem1Zero();
    if (HDAE5000_DirName_SetAndStore(dir, (void *)buf, 0) != -1) {
        CALLV(ROOT->PostEvent)(obj, EVT_SHOW, 0L);
    } else {
        CALLV(ROOT->SendEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, obj);
        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
    }
    HDAE5000_NameHistory_Push(HDAE5000_RAM_DirNameHistory, buf);
}

/* the same for an FLS */
void HDAE5000_FlsName_StoreWithUi(unsigned int fls, char *name, long obj)
{
    char buf[18];

    HDAE5000_StrNCpy(buf, name, 16);
    buf[16] = 0;
    CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 3L);
    HDAE5000_YieldUntilSem1Zero();
    if (HDAE5000_FlsName_SetAndStore(fls, (void *)buf, 0) != -1) {
        CALLV(ROOT->PostEvent)(obj, EVT_SHOW, 0L);
    } else {
        CALLV(ROOT->SendEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, obj);
        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
    }
    HDAE5000_NameHistory_Push(HDAE5000_RAM_FlsNameHistory, buf);
}

/* save a song under a name with the "please wait" and error messages; the name goes on the song-name history */
int HDAE5000_SaveSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, char *name, int flag, long obj)
{
    char buf[28];
    int ret;

    CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 0L);
    HDAE5000_StrNCpy(buf, name, 26);
    buf[26] = 0;
    if ((ret = HDAE5000_SaveSong(dir, song, (void *)buf, mask, flag, 0)) != -1) {
        CALLV(ROOT->PostEvent)(obj, EVT_SHOW, 0L);
    } else {
        CALLV(ROOT->SendEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, obj);
        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
    }
    HDAE5000_NameHistory_Push(ram_22ac7e, buf);
    return ret;
}

/* the main CPU's read callback for a song's RCM part */

/* the main CPU's write callback for a song's RCM part */
unsigned long HDAE5000_RcmStream_Write(unsigned char *data, unsigned long n)
{
    int ret;

    switch (HDAE5000_RAM_RcmStreamState) {
    case 0:
        if (HDAE5000_HD_WriteStream(data, n) != -1) {
            ret = 0;
            RCM_HAS = 1;
            HDAE5000_RAM_RcmStreamState = 2;
        } else {
            ret = -1;
        }
        HDAE5000_RAM_RcmStreamResult = ret;
        break;
    case 2:
        if (HDAE5000_HD_WriteStream(data, n) != -1) {
            ret = 0;
            RCM_HAS = 1;
            HDAE5000_RAM_RcmStreamState = 2;
        } else {
            ret = -1;
        }
        HDAE5000_RAM_RcmStreamResult = ret;
        break;
    default:
        HDAE5000_RAM_RcmStreamResult = -1;
        HDAE5000_RAM_RcmStreamState = 0;
        break;
    }
    return n;
}

/* ---- second forms ---- */

/* an unsigned char buffer */

/* ret assigned in its own statement */

/* the two locals declared in the other order */
unsigned long RcmRead_b(unsigned char *buf, unsigned long n)
{
    unsigned char *p;
    unsigned long cnt;

    switch (HDAE5000_RAM_RcmStreamState) {
    case 0:
        p = buf;
        cnt = n;
        HDAE5000_RAM_RcmStreamResult = HDAE5000_HD_ReadFile(p, cnt, &RCM_SLOT);
        HDAE5000_RAM_RcmStreamState = 1;
        break;
    case 1:
        p = buf;
        cnt = n;
        HDAE5000_RAM_RcmStreamResult = HDAE5000_HD_ReadFileNext(p, cnt, &RCM_SLOT);
        HDAE5000_RAM_RcmStreamState = 1;
        break;
    default:
        HDAE5000_RAM_RcmStreamResult = -1;
        HDAE5000_RAM_RcmStreamState = 0;
        break;
    }
    return n;
}
