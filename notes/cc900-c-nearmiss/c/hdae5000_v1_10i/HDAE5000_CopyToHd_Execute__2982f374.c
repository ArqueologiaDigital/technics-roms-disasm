/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of hdae5000_v1_10i/hd_r82b_fls_refresh__copytohd_exec.c (2026-11-19-79-hd-r82-v1notlx)
   sha256 2982f374a45bf35eb940b61164395d222d60ec02381f99ca2c1e208b40b36e90 (tar-sha256); compiled at -Xr */
/* Functions of hdae5000_filesystem.s.  (hdae5000_fls_refresh.c, v1.10i port of HDAE5000_CopyToHd_Execute)
   v1.x: eight song parts, so no TLX part lookup (no ".TLX" extension, no mask bit 0x100); the floppy list
   HDAE5000_RAM_FdList is at 0x22aa54 (v2.06i 0x22aa9c); the number format and the extensions are v1.10i's labels;
   the error objects are this tree's hdae_ids.h values.
   cc900-options: -Xr
   cc900-module: HDAE5000_PartList_Build HDAE5000_NameHistory_Recall HDAE5000_FlsName_StoreWithUi
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_FlsList_BuildPage HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_SongScreen_Refresh HDAE5000_YieldUntilSem1Zero
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_SaveSongWithUi HDAE5000_UiObj_SetCaption HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_DelOpt_ShowFlags HDAE5000_Count_Active_Files HDAE5000_CopyToHd_Execute
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
#define EVT_SHOW 0x1c00001L
#define EVT_HDAE_TIMER_BACK 0x1ca0002L
#define OBJ_CP_FD 0x7f00ceL
#define OBJ_ERR_NO_HK_DATA 0x7f0294L
#define OBJ_ERR_NO_HK_DATA_CATCH 0x7f0296L
#define OBJ_ERR_SAVE 0x7f0288L
#define OBJ_ERR_SAVE_CATCH 0x7f028aL
#define OBJ_ERR_SAVE_EXIT 0x7f0289L
/* ---- end of hdae_ids.h ---- */

struct FindData { char b[266]; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

/* other modules (call) */
/* r36: `int song`, so that CopyToHd_Execute's unsigned j is a converted argument (the ROM loads BC before WA) */
extern unsigned int HDAE5000_Song_IsUsed(unsigned int dir, int song);
extern unsigned int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask);
extern unsigned int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, const char *name, unsigned int mask,
                                            int a, int b);

/* this module (calr, cc900-module) */
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);

/* the floppy list (HDAE5000_RAM_FdList, 0x22aa54 in v1.x) as a flat byte array */
extern unsigned char ram_22aa54[];

/* ROM */
extern char ram_2cb398[];                               /* HDAE5000_Fmt_2_2d_CopyToHd_Execute */
extern char HDAE5000_Str_LSW[], HDAE5000_Str_PMT[], HDAE5000_Str_SQT[], HDAE5000_Str_CMP[], HDAE5000_Str_TM[],
    HDAE5000_Str_MSP[], HDAE5000_Str_RCM[], HDAE5000_Str_MD[];

/* one part file of the floppy song: name + extension looked up, its mask bit set when it exists */
#define PART(ext, setbit) \
    HDAE5000_StrCpy(&name[8], ext); \
    if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) { setbit; CALLV(HAMA->findclose)(h); }

/* the flat-array spellings of the list's members: selected flag i, and the name inside row i */
#define FD_SEL(i) ram_22aa54[(unsigned long)(i) + 0x114]
#define FD_ROWNAME(i) ((char *)&ram_22aa54[(unsigned long)((i) * 12 + 3) + 14])

/* copy the floppy songs selected in the copy screen's list into free songs of directory dir; sel (XWA) is not
   read: the list is HDAE5000_RAM_FdList itself.  j, mask, i declared in that order (the v2.06i main form). */
unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    unsigned int j;
    unsigned int mask;
    unsigned int i;
    long h;

    for (i = 0; i < count; i++) {
        if (FD_SEL(i) == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2cb398, i + 1);
            HDAE5000_StrNCpy(&num[2], FD_ROWNAME(i), 6);
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
                PART(HDAE5000_Str_LSW, mask = 1)
                PART(HDAE5000_Str_PMT, mask |= 0x002)
                PART(HDAE5000_Str_SQT, mask |= 0x004)
                PART(HDAE5000_Str_CMP, mask |= 0x008)
                PART(HDAE5000_Str_TM, mask |= 0x010)
                PART(HDAE5000_Str_MSP, mask |= 0x020)
                PART(HDAE5000_Str_RCM, mask |= 0x040)
                PART(HDAE5000_Str_MD, mask |= 0x080)
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
