/* Functions of hdae5000_ui_display.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions'
   ROM bytes (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); the build does not compile the HD-AE5000 trees yet.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.  ROOT / HAMA: the main CPU's function
   tables (hdae_ws.h).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
extern unsigned char HDAE5000_RAM_DirNames[120][16];
extern unsigned char HDAE5000_RAM_SongRecords[1920][76];
extern unsigned char HDAE5000_RAM_FlsRecords[120][144];
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern unsigned char HDAE5000_RAM_FlsSeqStopPending;
extern unsigned int HDAE5000_RAM_RcmStreamResult;

unsigned char HDAE5000_Fls_GetAutoLoadPending(void)
{
    return HDAE5000_RAM_FlsAutoLoadPending;
}

void HDAE5000_Fls_SetSeqStopPending(unsigned char v)
{
    HDAE5000_RAM_FlsSeqStopPending = v;
}

void HDAE5000_UiObj_SetCaption(long obj, long caption)
{
    unsigned char *v = CALLR(unsigned char *, ROOT->GetViewInstance)(obj);
    *(long *)(v + 0x16) = caption;
}

unsigned long HDAE5000_SwapBytes32(unsigned long x)
{
    unsigned long r = x & 0xff;
    int i;
    for (i = 0; i < 3; i++) {
        x >>= 8;
        r <<= 8;
        r += x & 0xff;
    }
    return r;
}

void HDAE5000_Delay_Loop(unsigned long n)
{
    while (n--)
        ;
}

unsigned int HDAE5000_RcmStream_LastResult(void)
{
    return HDAE5000_RAM_RcmStreamResult;
}

void HDAE5000_HD_GetBlockInfo(int block, struct HdBlockInfo *bi)
{
    switch (block) {
    case 0:
        bi->base = HDAE5000_RAM_DirNames; bi->size = 16; bi->count = 120;
        break;
    case 1:
        bi->base = HDAE5000_RAM_SongRecords; bi->size = 76; bi->count = 1920;
        break;
    case 2:
        bi->base = HDAE5000_RAM_FlsRecords; bi->size = 144; bi->count = 120; bi->extra = 32;
        break;
    }
}

unsigned int HDAE5000_SwapBytes16(unsigned int x)
{
    unsigned int r;
    r = x & 0xff;
    x >>= 8;
    r <<= 8;
    r += x;
    return r;
}

unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x)
{
    unsigned int r;
    r = x & 0xff;
    x >>= 8;
    r <<= 8;
    r += x & 0xff;
    return r;
}

unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x)
{
    unsigned long t, r;
    t = x;
    r = t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    return r;
}

void HDAE5000_RequestMode(unsigned char mode)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_CHANGE_MODE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_CHANGE_MODE, (long)mode + NAKA_MODE_MD_PS);
}

void HDAE5000_RequestTitle15(unsigned char title)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_CHANGE_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_CHANGE_TITLE, (long)title + TITLE_PS);
}

void HDAE5000_RequestTitle16(unsigned char title)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_INTERRUPT_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_INTERRUPT_TITLE, (long)title + TITLE_PS);
}

void HDAE5000_YieldUntilSem1Zero(void)
{
    while (CALLR(int, HAMA->ref_sem_X)(1) != 0)
        CALLV(HAMA->rot_rdq_X)(3);
}

void HDAE5000_Set_Menu_Visibility(unsigned char hide)
{
    int v;
    if (hide == 0)
        v = 1;
    else
        v = 0;
    CALLV(ROOT->SetVisible)(OBJ_SELECT_DIR_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_SAVE, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DEL, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_SELECT_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_FILE_LOAD_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DELFILE, v);
    CALLV(ROOT->SetVisible)(OBJ_CP_FD_HDSWTO, v);
    CALLV(ROOT->SetVisible)(OBJ_CP_FD_HDSWSEL, v);
    CALLV(ROOT->SetVisible)(OBJ_SW_HD_FORMAT, v);
}
