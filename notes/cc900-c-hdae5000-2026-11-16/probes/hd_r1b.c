/* lane_hd round 1, form b: second C guesses for the functions of hd_r1a.c (same names), other spellings. */

typedef void (*VFN)();
struct ObjTab { VFN *fns; char pad[10]; };
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
struct ViewInst { char pad[0x16]; long caption; };

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_SongRecords[];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern unsigned char HDAE5000_RAM_LyricBuffer[];
extern unsigned int ram_23085e;
extern unsigned char HDAE5000_RAM_DirBrowserCursors[];
extern unsigned char HDAE5000_RAM_DirBrowserPage;
extern unsigned char HDAE5000_RAM_FlsBrowserCursors[];
extern unsigned char HDAE5000_RAM_FlsBrowserPage;
extern unsigned char HDAE5000_RAM_HdInitResult;
extern unsigned char HDAE5000_RAM_AtaError;
extern void HDAE5000_HD_Init(void);
extern void HDAE5000_HD_ReadTables(void);

void HDAE5000_RequestMode(unsigned char mode)
{
    unsigned long id;
    ROOTF(void, RF_DeleteEvent)(0xffffffffUL, 0x01c00014UL);
    id = mode;
    id += 0x01800000UL;
    ROOTF(void, RF_ApPostEvent)(0xffffffffUL, 0x01c00014UL, id);
}

void HDAE5000_RequestTitle15(unsigned char title)
{
    ROOTF(void, RF_DeleteEvent)(0xffffffffUL, 0x01c00015UL);
    ROOTF(void, RF_ApPostEvent)(0xffffffffUL, 0x01c00015UL, 0x01a00000UL + title);
}

void HDAE5000_RequestTitle16(unsigned char title)
{
    ROOTF(void, RF_DeleteEvent)(0xffffffffUL, 0x01c00016UL);
    ROOTF(void, RF_ApPostEvent)(0xffffffffUL, 0x01c00016UL, 0x01a00000UL + title);
}

void HDAE5000_HD_GetBlockInfo(int block, struct HdBlockInfo *bi)
{
    if (block == 2) {
        bi->base = HDAE5000_RAM_FlsRecords; bi->size = 144; bi->count = 120; bi->extra = 32;
    } else if (block == 1) {
        bi->base = HDAE5000_RAM_SongRecords; bi->size = 76; bi->count = 1920;
    } else if (block == 0) {
        bi->base = HDAE5000_RAM_DirNames; bi->size = 16; bi->count = 120;
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
    if (r->flag[8] != 2) return;
    r->mask |= 0x100;
}

long HDAE5000_Lyrics_ReadVarLen(unsigned int pos)
{
    long v;
    int i;
    v = 0;
    for (i = 0; i < 4; i++) {
        v += (unsigned char)(HDAE5000_RAM_LyricBuffer[(unsigned int)(pos + i) + 22L] & 0x7f);
        if (HDAE5000_RAM_LyricBuffer[(unsigned int)(pos + i) + 22L] < 0x80) {
            ram_23085e = i + 1;
            return v;
        }
        v <<= 7;
    }
    return -1;
}

unsigned char HDAE5000_DirBrowser_GetCursor(void)
{
    unsigned char *p = HDAE5000_RAM_DirBrowserCursors;
    p += HDAE5000_RAM_DirBrowserPage;
    return *p;
}

unsigned char HDAE5000_FlsBrowser_GetCursor(void)
{
    unsigned char *p = HDAE5000_RAM_FlsBrowserCursors;
    p += HDAE5000_RAM_FlsBrowserPage;
    return *p;
}

unsigned char *HDAE5000_DirName_Address(unsigned int dir)
{
    return HDAE5000_RAM_DirNames + (unsigned long)dir * 16;
}

unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls)
{
    return HDAE5000_RAM_DirNames + ((unsigned long)fls * 144 + 0x24180L);
}

unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song)
{
    return HDAE5000_RAM_DirNames + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76);
}

unsigned int HDAE5000_SwapBytes16(unsigned int x)
{
    unsigned int h = x & 0xff;
    return (h << 8) + (x >> 8);
}

unsigned long HDAE5000_SwapBytes32(unsigned long x)
{
    unsigned long r;
    int i;
    r = x & 0xff;
    for (i = 0; i < 3; i++) {
        x >>= 8;
        r = (r << 8) + (x & 0xff);
    }
    return r;
}

unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x)
{
    unsigned int h = x & 0xff;
    return (h << 8) + (unsigned char)(x >> 8);
}

unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x)
{
    unsigned long r;
    r = x & 0xff;
    x >>= 8; r <<= 8; r += x & 0xff;
    x >>= 8; r <<= 8; r += x & 0xff;
    x >>= 8; r <<= 8; r += x & 0xff;
    return r;
}

void HDAE5000_YieldUntilSem1Zero(void)
{
    for (;;) {
        if (HAMAF(int, HF_ref_sem)(1) == 0)
            break;
        HAMAF(void, HF_rot_rdq)(3);
    }
}

void HDAE5000_UiObj_SetCaption(long obj, long caption)
{
    ROOTF(struct ViewInst *, RF_GetViewInstance)(obj)->caption = caption;
}

int HDAE5000_Check_HD_Present(void)
{
    HDAE5000_RAM_HdInitResult = 0;
    HDAE5000_HD_Init();
    return (int)HDAE5000_RAM_HdInitResult;
}

int HDAE5000_HD_ReadTables_Status(void)
{
    HDAE5000_HD_ReadTables();
    return HDAE5000_RAM_AtaError ? -1 : 0;
}

void HDAE5000_Delay_Loop(unsigned long n)
{
    while (n-- != 0)
        ;
}
