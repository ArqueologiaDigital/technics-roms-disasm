/* lane_hd round 39, helper h_m3: five functions of hdae5000_ui_display.s, first drafts (no earlier attempt of
   them is in the near-miss index), in ROM address order, then their second forms:
   HDAE5000_DirName_StoreWithUi HDAE5000_FlsName_StoreWithUi HDAE5000_SaveSongWithUi HDAE5000_RcmStream_Read
   HDAE5000_RcmStream_Write.
   cc900-options: -Xr
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_UiObj_SetCaption HDAE5000_NameHistory_Push
   cc900-module: HDAE5000_HD_WriteStream
   cc900-name: DirStoreUi_b=HDAE5000_DirName_StoreWithUi
   cc900-name: FlsStoreUi_b=HDAE5000_FlsName_StoreWithUi
   cc900-name: SaveSongUi_b=HDAE5000_SaveSongWithUi
   cc900-name: SaveSongUi_c=HDAE5000_SaveSongWithUi
   cc900-name: RcmRead_b=HDAE5000_RcmStream_Read
   Read from the hand source, with the matched HDAE5000_LoadSongWithUi (hdae5000/cc900/hdae5000_load_ui.c) and
   PP_Svc23 / PP_Svc25 (hdae5000_pport_services.c) as the models:
   - DirName_ / FlsName_StoreWithUi(dir, name, obj): frame 22 = IZ's word, an 18-byte name buffer at xsp+2 (NUL
     at [16]), obj's long at xsp+20.  dir is in IZ (the only word parameter alive over a call), name is pushed
     from XBC at once.  SetAndStore's buffer argument is taken into XWA first and copied to XBC (`lda xwa,(xsp+2);
     ld xbc,xwa`): a converted argument, written `(void *)buf`; NameHistory_Push's is loaded straight
     (`lda xbc,(xsp+2)`): no conversion, so that function is declared without a prototype.  The result is compared
     in HL (`cp hl,0xffff`): no local.
   - SaveSongWithUi(dir, song, mask, name, flag, obj): stacked name (xsp+46), flag (xsp+44), obj (xsp+40), retd
     10.  Frame 34: ret at xsp+2, a 28-byte buffer at xsp+4 (NUL at [26]), song at xsp+32, dir at xsp+34; mask in
     IZ.  ret is stored and reloaded for its test (`ld (xsp+2),hl; ld wa,(xsp+2); cp wa,0xffff`), LoadSongWithUi's
     `(ret = ..) != -1` shape, and stays in its stack word there too.
   - RcmStream_Read(buf, n): a switch on the stream state (compares 1, then 0: source order 0, 1, default); each
     case copies both parameters to locals (xsp+4, xsp+8) before the call; buf stays in XWA until then and n is
     returned from its slot.  The slot address is the song module's SLOT(6, ..) form.
   - RcmStream_Write(data, n): the same switch (0, 2, default); ret is a stack word (xsp+4) set to 0 or 0xffff
     and copied to the result cell; the part byte is the song module's HAS(6, ..) form.
   Second forms:
   - DirStoreUi_b / FlsStoreUi_b / SaveSongUi_b: an unsigned char buffer, cast `(char *)` where a char pointer
     is wanted (the conversion then comes from the types);
   - SaveSongUi_c: ret assigned in a statement of its own, then tested;
   - RcmRead_b: the two locals declared in the other order (which of the two orders puts p at xsp+4 is not
     known: Lbn_ShowEntry's `s[32]; ret` has the later one lower, HD_WriteStream's `room; r` the earlier one).
   Not sure: whether V4.23 pads a 17 / 27-byte buffer to an even size (18 / 28 are declared); whether the
   single-use dir / mask get IZ as in the ROM (HDAE5000_DirName_SetAndStore's keep does); which register the
   switch value takes while buf / data wait in XWA (the ROM: BC).
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
unsigned long HDAE5000_RcmStream_Read(unsigned char *buf, unsigned long n)
{
    unsigned long cnt;
    unsigned char *p;

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
void DirStoreUi_b(unsigned int dir, char *name, long obj)
{
    unsigned char buf[18];

    HDAE5000_StrNCpy((char *)buf, name, 16);
    buf[16] = 0;
    CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 3L);
    HDAE5000_YieldUntilSem1Zero();
    if (HDAE5000_DirName_SetAndStore(dir, (char *)buf, 0) != -1) {
        CALLV(ROOT->PostEvent)(obj, EVT_SHOW, 0L);
    } else {
        CALLV(ROOT->SendEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, obj);
        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
    }
    HDAE5000_NameHistory_Push(HDAE5000_RAM_DirNameHistory, buf);
}

void FlsStoreUi_b(unsigned int fls, char *name, long obj)
{
    unsigned char buf[18];

    HDAE5000_StrNCpy((char *)buf, name, 16);
    buf[16] = 0;
    CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 3L);
    HDAE5000_YieldUntilSem1Zero();
    if (HDAE5000_FlsName_SetAndStore(fls, (char *)buf, 0) != -1) {
        CALLV(ROOT->PostEvent)(obj, EVT_SHOW, 0L);
    } else {
        CALLV(ROOT->SendEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, obj);
        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, obj);
    }
    HDAE5000_NameHistory_Push(HDAE5000_RAM_FlsNameHistory, buf);
}

int SaveSongUi_b(unsigned int dir, unsigned int song, unsigned int mask, char *name, int flag, long obj)
{
    unsigned char buf[28];
    int ret;

    CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 0L);
    HDAE5000_StrNCpy((char *)buf, name, 26);
    buf[26] = 0;
    if ((ret = HDAE5000_SaveSong(dir, song, (char *)buf, mask, flag, 0)) != -1) {
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

/* ret assigned in its own statement */
int SaveSongUi_c(unsigned int dir, unsigned int song, unsigned int mask, char *name, int flag, long obj)
{
    char buf[28];
    int ret;

    CALLV(ROOT->SendEvent)(OBJ_HD_PLEASE, EVT_SHOW, 0L);
    HDAE5000_StrNCpy(buf, name, 26);
    buf[26] = 0;
    ret = HDAE5000_SaveSong(dir, song, (void *)buf, mask, flag, 0);
    if (ret != -1) {
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
