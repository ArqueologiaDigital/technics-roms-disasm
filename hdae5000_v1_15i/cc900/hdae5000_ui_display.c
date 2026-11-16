/* Functions of hdae5000_ui_display.s.  (hdae5000_ui_display.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_ui_display.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_SongRecords[1920][76];
extern unsigned char HDAE5000_RAM_FlsRecords[];
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

/* Song-record fields: part byte k at +26+k, first-cluster slot k at +36+4k; k = 0 LSW, 1 PMT, 2 SQT, 3 CMP,
   4 TM, 5 MSP, 6 RCM, 7 MD, 8 TLX.  The address is written as an integer, (unsigned long)&sym[field] + offset:
   that is what gives the ROM's lda xR,(sym+field) after the offset (run 2026-11-16-52-hd-r4v). */
extern void HDAE5000_HD_FreeChain(unsigned long first);

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(unsigned long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define PART(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
#define DELETE_PART(k)                                   \
    if (SLOT(k, dir, song) != 0xffffffffUL) {            \
        HDAE5000_HD_FreeChain(SLOT(k, dir, song));       \
        SLOT(k, dir, song) = 0xffffffffUL;               \
        PART(k, dir, song) = 0;                          \
    }

void HDAE5000_DeleteSongPart_Lsw(unsigned int dir, unsigned int song) { DELETE_PART(0) }
void HDAE5000_DeleteSongPart_Pmt(unsigned int dir, unsigned int song) { DELETE_PART(1) }
void HDAE5000_DeleteSongPart_Sqt(unsigned int dir, unsigned int song) { DELETE_PART(2) }
void HDAE5000_DeleteSongPart_Cmp(unsigned int dir, unsigned int song) { DELETE_PART(3) }
void HDAE5000_DeleteSongPart_Tm(unsigned int dir, unsigned int song) { DELETE_PART(4) }
void HDAE5000_DeleteSongPart_Msp(unsigned int dir, unsigned int song) { DELETE_PART(5) }
void HDAE5000_DeleteSongPart_Rcm(unsigned int dir, unsigned int song) { DELETE_PART(6) }
void HDAE5000_DeleteSongPart_Md(unsigned int dir, unsigned int song) { DELETE_PART(7) }

#define FLS(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

int HDAE5000_FlsItem_Clear(unsigned int fls, unsigned int item)
{
    FLS(16, fls, item) = 0;
    FLS(48, fls, item) = 0;
    FLS(80, fls, item) = 0;
    FLS(112, fls, item) = 0;
    return 0;
}
