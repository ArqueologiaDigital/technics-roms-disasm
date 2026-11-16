/* lane_hd round 1, form a: first C guesses for HD-AE5000 v2.06i functions (hdae5000/), to learn the option set and
   the idioms (the main CPU's workspace function tables, register arguments, struct records).
   Checked with notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --check RUN_DIR. */

typedef void (*VFN)();
struct ObjTab { VFN *fns; char pad[10]; };              /* 14-byte object-table entry: its function table first */
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOTF(t, i) ((t (*)())HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns[i])
#define HAMAF(t, i) ((t (*)())HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns[i])
#define RF_DeleteEvent 333
#define RF_ApPostEvent 73
#define RF_GetViewInstance 177
#define HF_rot_rdq 46
#define HF_ref_sem 52

struct HdBlockInfo { void *base; unsigned int size; unsigned int count; unsigned int extra; };
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct HdTables { unsigned char dir[120][16]; unsigned char song[120][16][76]; unsigned char fls[120][144]; };
struct LyricFile { unsigned char hdr[22]; unsigned char data[0x5000 - 22]; };

extern unsigned char HDAE5000_RAM_DirNames[120][16];
extern unsigned char HDAE5000_RAM_SongRecords[1920][76];
extern unsigned char HDAE5000_RAM_FlsRecords[120][144];
extern struct HdTables ram_201632;
extern struct LyricFile HDAE5000_RAM_LyricBuffer;
extern unsigned int ram_23085e;
extern unsigned char HDAE5000_RAM_DirBrowserCursors[5];
extern unsigned char HDAE5000_RAM_DirBrowserPage;
extern unsigned char HDAE5000_RAM_FlsBrowserCursors[5];
extern unsigned char HDAE5000_RAM_FlsBrowserPage;
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern unsigned char HDAE5000_RAM_FlsSeqStopPending;
extern unsigned int HDAE5000_RAM_RcmStreamResult;
extern unsigned char HDAE5000_RAM_HdInitResult;
extern unsigned char HDAE5000_RAM_AtaError;
extern void HDAE5000_HD_Init(void);
extern void HDAE5000_HD_ReadTables(void);

void HDAE5000_RequestMode(unsigned char mode)
{
    ROOTF(void, RF_DeleteEvent)(-1L, 0x01c00014L);
    ROOTF(void, RF_ApPostEvent)(-1L, 0x01c00014L, (long)mode + 0x01800000L);
}

void HDAE5000_RequestTitle15(unsigned char title)
{
    ROOTF(void, RF_DeleteEvent)(-1L, 0x01c00015L);
    ROOTF(void, RF_ApPostEvent)(-1L, 0x01c00015L, (long)title + 0x01a00000L);
}

void HDAE5000_RequestTitle16(unsigned char title)
{
    ROOTF(void, RF_DeleteEvent)(-1L, 0x01c00016L);
    ROOTF(void, RF_ApPostEvent)(-1L, 0x01c00016L, (long)title + 0x01a00000L);
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

void HDAE5000_TypeSel_BuildMask(struct TypeSel *r)
{
    r->mask = 0;
    if (r->flag[0] == 2) r->mask = 1;
    if (r->flag[1] == 2) r->mask |= 2;
    if (r->flag[2] == 2) r->mask |= 4;
    if (r->flag[3] == 2) r->mask |= 8;
    if (r->flag[4] == 2) r->mask |= 0x10;
    if (r->flag[5] == 2) r->mask |= 0x20;
    if (r->flag[6] == 2) r->mask |= 0x40;
    if (r->flag[7] == 2) r->mask |= 0x80;
    if (r->flag[8] == 2) r->mask |= 0x100;
}

long HDAE5000_Lyrics_ReadVarLen(unsigned int pos)
{
    long v = 0;
    int i;
    for (i = 0; i < 4; i++) {
        v += HDAE5000_RAM_LyricBuffer.data[pos + i] & 0x7f;
        if (HDAE5000_RAM_LyricBuffer.data[pos + i] < 0x80) {
            ram_23085e = i + 1;
            return v;
        }
        v <<= 7;
    }
    return -1L;
}

unsigned char HDAE5000_DirBrowser_GetCursor(void)
{
    return HDAE5000_RAM_DirBrowserCursors[HDAE5000_RAM_DirBrowserPage];
}

unsigned char HDAE5000_FlsBrowser_GetCursor(void)
{
    return HDAE5000_RAM_FlsBrowserCursors[HDAE5000_RAM_FlsBrowserPage];
}

unsigned char HDAE5000_Fls_GetAutoLoadPending(void)
{
    return HDAE5000_RAM_FlsAutoLoadPending;
}

void HDAE5000_Fls_SetSeqStopPending(unsigned char v)
{
    HDAE5000_RAM_FlsSeqStopPending = v;
}

unsigned int HDAE5000_RcmStream_LastResult(void)
{
    return HDAE5000_RAM_RcmStreamResult;
}

unsigned char *HDAE5000_DirName_Address(unsigned int dir)
{
    return ram_201632.dir[dir];
}

unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls)
{
    return ram_201632.fls[fls];
}

unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song)
{
    return ram_201632.song[dir][song];
}

unsigned int HDAE5000_SwapBytes16(unsigned int x)
{
    return ((x & 0xff) << 8) + (x >> 8);
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

unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x)
{
    return ((x & 0xff) << 8) + ((x >> 8) & 0xff);
}

unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x)
{
    unsigned long r = x & 0xff;
    x >>= 8; r <<= 8; r += x & 0xff;
    x >>= 8; r <<= 8; r += x & 0xff;
    x >>= 8; r <<= 8; r += x & 0xff;
    return r;
}

void HDAE5000_YieldUntilSem1Zero(void)
{
    while (HAMAF(int, HF_ref_sem)(1) != 0)
        HAMAF(void, HF_rot_rdq)(3);
}

void HDAE5000_UiObj_SetCaption(long obj, long caption)
{
    unsigned char *v = ROOTF(unsigned char *, RF_GetViewInstance)(obj);
    *(long *)(v + 0x16) = caption;
}

int HDAE5000_Check_HD_Present(void)
{
    HDAE5000_RAM_HdInitResult = 0;
    HDAE5000_HD_Init();
    return HDAE5000_RAM_HdInitResult;
}

int HDAE5000_HD_ReadTables_Status(void)
{
    HDAE5000_HD_ReadTables();
    if (HDAE5000_RAM_AtaError != 0)
        return -1;
    return 0;
}

void HDAE5000_Delay_Loop(unsigned long n)
{
    while (n--)
        ;
}
