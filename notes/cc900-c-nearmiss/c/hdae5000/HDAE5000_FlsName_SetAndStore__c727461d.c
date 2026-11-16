/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hd/hd_r4_g2b.c (2026-11-16-57-hd-r7)
   sha256 c727461d81b5425c26f023d63974096554c4a290f628aa1a37397a63b7c4da91 (tar-sha256); compiled at -Xr */
/* lane_hd round 4, helper h_small, group 2, form b: hd_r4_g2.c's functions (same names) with the table block as
   typed arrays instead of byte offsets, in case V4.23 picks `ld xR, sym` for a row of a 2-D array argument
   (FlsList_BuildPage's `FlsListText[i]` did, run 49):
   - DirName_SetAndStore: `HDAE5000_RAM_DirNames[dir]` of a [][16] array;
   - SongName / FlsName: the byte table addressed as `HDAE5000_RAM_DirNames + offset` (pointer plus integer);
   - the *_SetAndStore functions void (the ROM leaves StoreTables' HL in place either way);
   - HD_StoreTables with an unsigned status. */
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

extern unsigned char HDAE5000_RAM_DirNames[][16];
extern unsigned char HDAE5000_RAM_FlsRecords[];
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern unsigned int HDAE5000_ATA_SoftReset_Status(void);
extern unsigned int HDAE5000_HD_WriteTables_Status(void);
extern unsigned int HDAE5000_ATA_Standby_Status(void);

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };

#define TBL ((unsigned char *)HDAE5000_RAM_DirNames)
#define FLSB(o, f, i) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_FlsRecords[o] + ((unsigned long)(f) * 144 + (i))))

unsigned int HDAE5000_HD_StoreTables(int keep);

void HDAE5000_DirName_SetAndStore(unsigned int dir, char *name, int keep)
{
    HDAE5000_StrNCpy(HDAE5000_RAM_DirNames[dir], name, 16);
    HDAE5000_HD_StoreTables(keep);
}

void HDAE5000_SongName_SetAndStore(unsigned int dir, unsigned int song, char *name, int keep)
{
    HDAE5000_StrNCpy(TBL + ((unsigned long)dir * 0x4c0 + 0x780 + (unsigned long)song * 76), name, 26);
    HDAE5000_HD_StoreTables(keep);
}

void HDAE5000_FlsName_SetAndStore(unsigned int fls, char *name, int keep)
{
    HDAE5000_StrNCpy(TBL + ((unsigned long)fls * 144 + 0x24180L), name, 16);
    HDAE5000_HD_StoreTables(keep);
}

void HDAE5000_FlsItem_Set(unsigned int fls, unsigned int item, struct FlsItem *src, int keep)
{
    FLSB(16, fls, item) = src->dir + 1;
    FLSB(48, fls, item) = src->song + 1;
    FLSB(80, fls, item) = src->as;
    FLSB(112, fls, item) = src->al;
    HDAE5000_HD_StoreTables(keep);
}

unsigned int HDAE5000_HD_StoreTables(int keep)
{
    unsigned int st;
    CALLV(HAMA->PlayHalt)(1);
    st = HDAE5000_ATA_SoftReset_Status();
    st |= HDAE5000_HD_WriteTables_Status();
    if (keep != 1)
        st |= HDAE5000_ATA_Standby_Status();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return st;
}
