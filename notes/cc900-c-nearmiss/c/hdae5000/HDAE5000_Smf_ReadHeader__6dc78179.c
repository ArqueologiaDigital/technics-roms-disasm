/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v2_01i/hdae5000_smf_palette.c (2026-11-16-119-hd-r30)
   sha256 6dc78179bf2c17acaa3e5db30fc1ed94bb33af4e6f5287892b690031a722fb7e (tar-sha256); compiled at -Xr */
/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_smf_palette.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_smf_palette.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_Smf_SwapBytes32 HDAE5000_Smf_SwapBytes16 HDAE5000_Smf_CheckHeader
   cc900-module: HDAE5000_Delay_Loop HDAE5000_VGA_Port_Write
*/
/* ---- hdae_ws.h (inlined) ---- */
/* the main CPU workspace and its function tables (gen_ws_header.py, from the RootFn_* / HamaFn_* .equ) */
typedef void (*VFN)();
struct RootFns {
    void *pad0[33];
    void *UpdateScreen;
    void *pad1[5];
    void *DrawLine;
    void *pad2[1];
    void *DrawBox;
    void *DrawFrame;
    void *pad3[1];
    void *MovePixels;
    void *pad4[4];
    void *DrawString;
    void *pad5[5];
    void *InheritedProc;
    void *pad6[1];
    void *RegisterObjectTable;
    void *pad7[6];
    void *SendEvent;
    void *PostEvent;
    void *pad8[7];
    void *ApPostEvent;
    void *pad9[5];
    void *ResEventProc;
    void *ResMethodProc;
    void *pad10[1];
    void *ResNameProc;
    void *pad11[1];
    void *GetCharHeight;
    void *GetCharDescent;
    void *GetCenteredDelta;
    void *ConvertStrings;
    void *pad12[2];
    void *ClassProc;
    void *pad13[54];
    void *FunctionProc;
    void *ApFunctionProc;
    void *MainFunctionProc;
    void *ApFuncCall;
    void *MainFuncCall;
    void *pad14[6];
    void *RegisterTitle;
    void *pad15[1];
    void *GetTitleNow;
    void *pad16[1];
    void *ViewableProc;
    void *pad17[4];
    void *SetVisible;
    void *pad18[11];
    void *GetViewInstance;
    void *pad19[3];
    void *GetClientBox;
    void *pad20[1];
    void *DrawDesignBox;
    void *pad21[57];
    void *SetDialEnable;
    void *SetDialUp;
    void *SetDialDown;
    void *pad22[16];
    void *SetApTimer;
    void *pad23[1];
    void *KillApTimer;
    void *pad24[4];
    void *SetAutoInc;
    void *pad25[55];
    void *GetNamingWindowID;
    void *pad26[9];
    void *DeleteEvent;
    void *SleepMainTask;
    void *WakeUpMainTask;
};
struct HamaFns {
    void *pad0[1];
    void *FDLoadSaveTest;
    void *GetMediaType;
    void *PreLswLoad;
    void *PostLswLoad;
    void *PreLswSave;
    void *PostLswSave;
    void *PrePmLoad;
    void *PostPmLoad;
    void *PrePmSave;
    void *PostPmSave;
    void *SeqLoadPre;
    void *SeqLoadPost;
    void *SeqSavePre;
    void *SeqSavePost;
    void *cmp_ld_mae;
    void *cmp_ld_ato;
    void *cmp_sv_mae;
    void *cmp_sv_ato;
    void *PreTmLoad;
    void *PostTmLoad;
    void *PreTmSave;
    void *PostTmSave;
    void *msp_ld_mae;
    void *msp_ld_ato;
    void *msp_sv_mae;
    void *msp_sv_ato;
    void *PreMidiLoad;
    void *PostMidiLoad;
    void *PreMidiSave;
    void *PostMidiSave;
    void *FlashWrite;
    void *GetResouceInfo;
    void *SetSepaOutMode;
    void *pad1[2];
    void *GetVolumeLabel;
    void *findfirst;
    void *findnext;
    void *findclose;
    void *fopen_ext;
    void *pad2[1];
    void *fread_ext;
    void *fclose_ext;
    void *rcm_ld_XAPR_j;
    void *rcm_sv_XAPR_j;
    void *rot_rdq_X;
    void *pad3[5];
    void *ref_sem_X;
    void *pad4[4];
    void *pdly_tim_X;
    void *PlayHalt;
    void *PlayStandBy;
    void *EditSwRefresh;
    void *pad5[3];
    void *GetAdr_sqbtof;
    void *GetAdr_sq_beadt;
    void *GetAdr_sqsrtc;
    void *pad6[2];
    void *sendCOMM;
    void *pad7[2];
    void *SwbtWr;
    void *pad8[2];
    void *SetGlobalError;
    void *malloc_X;
    void *free_X;
    void *ChangePalette;
    void *ChangeWall;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)
/* every call goes through a cast: CALLR(int, ROOT->GetTitleNow)(), CALLV(ROOT->SendEvent)(obj, ev, arg) */
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
/* ---- end of hdae_ws.h ---- */
/* ---- hdae_ids.h (inlined) ---- */
/* HD-AE5000 UI object ids and event codes (gen_ids_header.py) */
/* ---- end of hdae_ids.h ---- */

struct SmfHdr { unsigned long magic; unsigned long len; unsigned int format; unsigned int tracks;
                unsigned int division; };

/* ---- this file (calr) ---- */
extern unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x);
extern unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x);
extern void HDAE5000_Delay_Loop(unsigned long n);
long HDAE5000_Smf_CheckHeader(struct SmfHdr *h);
extern void HDAE5000_VGA_Port_Write(unsigned int port, int v);   /* the callers' view: BC */
void VgaPortWrite_c(unsigned int port, unsigned char v);

/* ---- RAM / ROM ---- */
extern struct SmfHdr HDAE5000_RAM_SmfHeader;
extern unsigned int HDAE5000_RAM_SmfFormat;
extern unsigned int HDAE5000_RAM_SmfTrackCount;
extern unsigned int HDAE5000_RAM_SmfDivision;
extern char HDAE5000_Str_Rb_Smf_ReadHeader[];

#define IO_VGA_PORTS 0x170000L    /* HDAE5000_IO_VgaPorts */

long HDAE5000_Smf_ReadHeader(char *name)
{
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->SleepMainTask)();
        CALLV(HAMA->fopen_ext)(name, HDAE5000_Str_Rb_Smf_ReadHeader);
        CALLV(HAMA->fread_ext)(&HDAE5000_RAM_SmfHeader, 14L);
        CALLV(HAMA->fclose_ext)();
        CALLV(ROOT->WakeUpMainTask)();
    }
    return HDAE5000_Smf_CheckHeader(&HDAE5000_RAM_SmfHeader);
}

long HDAE5000_Smf_CheckHeader(struct SmfHdr *h)
{
    if (HDAE5000_Smf_SwapBytes32(h->magic) != 0x4d546864L)
        return -1;
    if (HDAE5000_Smf_SwapBytes32(h->len) != 6)
        return -2;
    HDAE5000_RAM_SmfFormat = HDAE5000_Smf_SwapBytes16(h->format);
    if (HDAE5000_RAM_SmfFormat > 1)
        return -3;
    HDAE5000_RAM_SmfTrackCount = HDAE5000_Smf_SwapBytes16(h->tracks);
    HDAE5000_RAM_SmfDivision = HDAE5000_Smf_SwapBytes16(h->division);
    if (HDAE5000_RAM_SmfDivision & 0x8000)
        return -4;
    return 0;
}

void HDAE5000_Palette_Setup(unsigned char index, unsigned char *rgb)
{
    HDAE5000_VGA_Port_Write(0x3c8, index);
    if (rgb[0] & 0x08) {
        if (rgb[0] < 0xf0)
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)((rgb[0] >> 4) + 1));
        else
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[0] >> 4));
    } else
        HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[0] >> 4));
    if (rgb[1] & 0x08) {
        if (rgb[1] < 0xf0)
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)((rgb[1] >> 4) + 1));
        else
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[1] >> 4));
    } else
        HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[1] >> 4));
    if (rgb[2] & 0x08) {
        if (rgb[2] < 0xf0)
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)((rgb[2] >> 4) + 1));
        else
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[2] >> 4));
    } else
        HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[2] >> 4));
}
