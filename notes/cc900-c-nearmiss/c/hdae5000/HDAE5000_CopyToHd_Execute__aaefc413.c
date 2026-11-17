/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_fs.c (2026-11-16-119-hd-r30)
   sha256 aaefc413b546bf5be564c3000c3954b72e2e681e1994a2bdf7f425ed7108b381 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define OBJ_CP_FD 0x7f00d2L
#define OBJ_ERR_NO_HK_DATA 0x7f02a3L
#define OBJ_ERR_NO_HK_DATA_CATCH 0x7f02a5L
#define OBJ_ERR_SAVE 0x7f0297L
#define OBJ_ERR_SAVE_CATCH 0x7f0299L
#define OBJ_ERR_SAVE_EXIT 0x7f0298L
struct FdList { char label[14]; char rows[242]; unsigned char present[20]; unsigned char sel[20]; };
struct FindData { char b[266]; };
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern unsigned int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask);
extern unsigned int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, const char *name, unsigned int mask,
                                            int a, int b);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern struct FdList HDAE5000_RAM_FdList;
extern char ram_2e2f24[];
extern char HDAE5000_Str_LSW[], HDAE5000_Str_PMT[], HDAE5000_Str_SQT[], HDAE5000_Str_CMP[], HDAE5000_Str_TM[],
    HDAE5000_Str_MSP[], HDAE5000_Str_RCM[], HDAE5000_Str_MD[], HDAE5000_Str_TLX[];
unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    unsigned int i;     /* r27: no `register` (run 109: it was served first and got QIZ); declared before j / mask */
    unsigned int j;
    unsigned int mask;
    long h;

    for (i = 0; i < count; i++) {
        if (HDAE5000_RAM_FdList.sel[(unsigned long)i] == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2e2f24, i + 1);
            HDAE5000_StrNCpy(&num[2], &HDAE5000_RAM_FdList.rows[i * 12 + 3], 6);
            slot = -1;
            for (j = 0; j < 16; j++) {
                if (HDAE5000_Song_IsUsed(dir, j) == 0xffff) {
                    slot = j;
                    break;
                }
            }
            if (slot != -1) {
                HDAE5000_MemCopy(name, num, 8);
                mask = 0;
                CALLV(HAMA->GetMediaType)();
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_LSW);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask = 1;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_PMT);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x002;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_SQT);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x004;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_CMP);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x008;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_TM);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x010;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_MSP);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x020;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_RCM);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x040;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_MD);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x080;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_TLX);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x100;
                    CALLV(HAMA->findclose)(h);
                }
                if (HDAE5000_FdSong_CheckFiles(num, mask) != 0xffff) {
                    if (HDAE5000_CopyFdSongToHd(dir, slot, num, mask, 0, 0) == 0xffff) {
                        CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
                        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_CP_FD);
                        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        return 0xffff;
                    }
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_ERR_NO_HK_DATA, EVT_SHOW, 3L);
                    CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    return 0xffff;
                }
            }
        }
    }
    return 0;
}
