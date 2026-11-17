/* lane_p6 helper F, round 13, form b: round 12 form a (local h for the early object load, `default: break;` in
   the Cmp* switches, `return -1` in the GET case) with the -O3 fixes of round 13 form a: if/else visibility
   posts, the stored parameter passed in the PS case, SINGLE_LOAD_ALL from an unsigned-char comparison.
   CmpSingleLoadSrcFunc: back to `&param;` (r25's frame was right with it; the local copy of evt lost XIZ to param),
   evt plain.  Round 12 form a's notes follow (the conditional-argument visibility post is replaced).
   Round 12, form a: file_io/single_load.s window procs (module 269).
   Run r25: `&evt; &param;` fixed the frame (+15 / +21 / +21) but made V4.23 treat the two as memory: it loads them
   into temporaries BEFORE computing the list-proc pointer, where the ROM loads them after it (for a spilled,
   not address-taken parameter, as with constant arguments).  So no address-of here.  Instead the value the ROM
   keeps in XIZ is a `register` LOCAL copied from its parameter (V4.23's micro probes, phase3a-status.md: a local
   beats a parameter for IZ), and the other parameters stay plain so the allocator spills them.
   Code after the switch: V4.23 lays it after the FIRST case when the switch has no default (micro sw_evtab, our
   r25 output, the ROM's SingleLoadDstFunc) but after the LAST case when it has one (micro sw_ev, the ROM's Cmp*
   procs, whose INDEXSW case falls into `return 0` and whose return -1 comes after it).  So the Cmp* switches get an
   empty `default: break;`.
   SingleLoadDstFunc: the two visibility posts are one call with a conditional argument (the ROM loads all three
   arguments in each arm and joins at one `call`, which V4.23 at -Xr does not do for an if/else of two calls).
   As round 11 form b: the list-box object loaded once before the param == 7 / 8 tests (local h). */

/* cc900-module: CmpSingleLoadSrcFunc FileIO_ValidateSignedValue InitializeOperationState SignalProgressUpdate SingleLoadDstBankFunc SingleLoadDstMemFunc SingleLoadModeFunc SingleLoadSrcBankFunc SingleLoadSrcFunc SingleLoadSrcMemFunc SingleLoad_FindNextArea SingleLoad_ScanAreas */

#define EVT_PAINT                     0x1c0000bL
#define EVT_SHOW                      0x1c00001L
#define EVT_HIDE                      0x1c00002L
#define EVT_PARA_DRAW                 0x1c0000fL
#define EVT_INDEXSW_UP                0x1c00017L
#define EVT_INDEXSW_DOWN              0x1c00018L
#define EVT_SET_PARAM                 0x1e0003bL
#define EVT_SET_VISIBLE               0x1e0009cL
#define EVT_SET_SELECTED_FILE_NUMBER  0x1e50002L
#define EVT_GET_SELECTED_FILE_NUMBER  0x1e50003L
#define EVT_PS_FILE_NAME_BOX_ID       0x1e50004L

extern long ApPostEvent(long, long, long);
extern void UI_InterruptTitleByIndex(int);
extern void InitializeOperationState(int);
extern unsigned char FileIO_ValidateSignedValue(int, int);
extern long SingleLoadModeFunc(long, long, long);
extern long SingleLoadSrcMemFunc(long, long, long);
extern long SingleLoadSrcBankFunc(long, long, long);
extern long SingleLoadDstMemFunc(long, long, long);
extern long SingleLoadDstBankFunc(long, long, long);
extern long SingleLoadSrcFunc(long, long, long);
extern long CmpSingleLoadSrcFunc(long, long, long);
extern void SignalProgressUpdate(void);
extern void SingleLoad_ScanAreas(void);
extern unsigned char SingleLoad_FindNextArea(void);
extern int FileIO_ValidateWithExtHeader(void);

extern long __near ram_81f0;
extern long __near ram_81f4;
extern long __near ram_81f8;
extern unsigned char __near ram_8a0a;
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern long (*SingleLoadDst_AreaListProcs[])(long, long, long);
extern long (*CmpSingleLoadSrc_ListProcByMode[])(long, long, long);
extern long (*CmpSingleLoadDst_AreaListProcs[])(long, long, long);

long SingleLoadDstFunc(long obj, long evt, long param)
{
    register long ob = obj;
    long h;

    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ram_81f0 = param;
        InitializeOperationState(0);
        SignalProgressUpdate();
        SingleLoad_ScanAreas();
        SignalProgressUpdate();
        if (SINGLE_LOAD_AREA != 1) ApPostEvent(0x61004aL, EVT_SET_VISIBLE, 1);
        else ApPostEvent(0x61004aL, EVT_SET_VISIBLE, 0);
        ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
        if (SINGLE_LOAD_AREA == 0 && FileIO_ValidateWithExtHeader() != 0) ram_8a0a = 1;
        else ram_8a0a = 0;
        break;
    case EVT_PAINT:
        SingleLoadModeFunc(ob, evt, param);
        SingleLoadSrcBankFunc(ob, evt, param);
        SingleLoadSrcMemFunc(ob, evt, param);
        SingleLoadDstBankFunc(ob, evt, param);
        SingleLoadDstMemFunc(ob, evt, param);
        ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
        ApPostEvent(0x610036L, EVT_SET_PARAM, 0);
        SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
        break;
    case EVT_PARA_DRAW:
        ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
        SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, EVT_PAINT, 0);
        break;
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN:
        if (param == 3 && SINGLE_LOAD_AREA != 1) {
            SINGLE_LOAD_ALL = (unsigned char)(evt == EVT_INDEXSW_UP);
            SingleLoadSrcMemFunc(ob, EVT_PAINT, 0);
            SingleLoadDstMemFunc(ob, EVT_PAINT, 0);
            ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
            ApPostEvent(0x610036L, EVT_SET_PARAM, 0);
            SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, EVT_PAINT, 0);
            SingleLoadSrcFunc(ob, EVT_PAINT, 0);
        } else if (param == 4) {
            if (SingleLoad_FindNextArea() != 0) {
                if (SINGLE_LOAD_AREA != 1) ApPostEvent(0x61004aL, EVT_SET_VISIBLE, 1);
                else ApPostEvent(0x61004aL, EVT_SET_VISIBLE, 0);
                SingleLoadModeFunc(ob, EVT_PAINT, 0);
                SingleLoadSrcBankFunc(ob, EVT_PAINT, 0);
                SingleLoadSrcMemFunc(ob, EVT_PAINT, 0);
                SingleLoadDstBankFunc(ob, EVT_PAINT, 0);
                SingleLoadDstMemFunc(ob, EVT_PAINT, 0);
                ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
                ApPostEvent(0x610036L, EVT_SET_PARAM, 0);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, EVT_PAINT, 0);
                SingleLoadSrcFunc(ob, EVT_PAINT, 0);
            }
        } else if (param == 10 && SINGLE_LOAD_AREA != 4) {
            ApPostEvent(0x600026L, EVT_SHOW, 5);
            InitializeOperationState(0);
            GLOBAL_ERROR_CODE = FileIO_ValidateSignedValue(
                (int)SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param), 1);
            ApPostEvent(0x600026L, EVT_HIDE, 0);
            UI_InterruptTitleByIndex(0xee);
        } else if (param == 7) {
            if (SINGLE_LOAD_AREA != 1) {
                ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, 1);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            } else {
                ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            }
        } else {
            h = ram_81f0;
            if (param == 8) {
                if (SINGLE_LOAD_AREA == 1) {
                    ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, 2);
                    SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
                } else if (SINGLE_LOAD_ALL == 0) {
                    ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, 3);
                    SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
                } else {
                    ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, -1);
                    SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
                }
            } else if (param == 5) {
                ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, -1);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            } else if (param == 6) {
                ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, -1);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            }
        }
        break;
    case EVT_GET_SELECTED_FILE_NUMBER:
        return -1;
    }
    return 0;
}

long CmpSingleLoadSrcFunc(long obj, long ev, long param)
{
    long h;

    &param;
    switch (ev) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ram_81f4 = param;
        ApPostEvent(param, EVT_SET_SELECTED_FILE_NUMBER, -1);
        break;
    case EVT_PAINT:
        ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
        CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, ev, param);
        break;
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN:
        if (param == 5) {
            ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, 1);
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, ev, param);
        } else if (param == 6) {
            if (SINGLE_LOAD_ALL == 0) {
                ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, 3);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, ev, param);
            } else {
                ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, ev, param);
            }
        } else {
            h = ram_81f4;
            if (param == 7) {
                ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, ev, param);
            } else if (param == 8 && SINGLE_LOAD_ALL == 0) {
                ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, ev, param);
            } else if (param == 0x28) {
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](h, ev, param);
            }
        }
        break;
    case EVT_GET_SELECTED_FILE_NUMBER:
        return -1;
    default:
        break;
    }
    return 0;
}

long CmpSingleLoadDstFunc(long obj, long evt, long param)
{
    register long ob = obj;
    long h;

    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ram_81f8 = param;
        ApPostEvent(param, EVT_SET_SELECTED_FILE_NUMBER, -1);
        break;
    case EVT_PAINT:
        SingleLoadSrcMemFunc(ob, evt, param);
        SingleLoadSrcBankFunc(ob, evt, param);
        SingleLoadDstMemFunc(ob, evt, param);
        SingleLoadDstBankFunc(ob, evt, param);
        ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, -1);
        ApPostEvent(0x61007eL, EVT_SET_PARAM, 0);
        CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
        break;
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN:
        if (param == 3) {
            SINGLE_LOAD_ALL = (unsigned char)(evt == EVT_INDEXSW_UP);
            SingleLoadSrcMemFunc(ob, EVT_PAINT, 0);
            SingleLoadDstMemFunc(ob, EVT_PAINT, 0);
            ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, -1);
            ApPostEvent(0x61007eL, EVT_SET_PARAM, 0);
            CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, EVT_PAINT, 0);
            CmpSingleLoadSrcFunc(ob, EVT_PAINT, 0);
        } else if (param == 10 && SINGLE_LOAD_AREA != 4) {
            ApPostEvent(0x600026L, EVT_SHOW, 5);
            InitializeOperationState(0);
            GLOBAL_ERROR_CODE = FileIO_ValidateSignedValue(
                (int)CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param), 1);
            ApPostEvent(0x600026L, EVT_HIDE, 0);
            UI_InterruptTitleByIndex(0xee);
        } else if (param == 7) {
            ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, 1);
            CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
        } else {
            h = ram_81f8;
            if (param == 8) {
                if (SINGLE_LOAD_ALL == 0) {
                    ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, 3);
                    CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
                } else {
                    ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, -1);
                    CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
                }
            } else if (param == 5) {
                ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
            } else if (param == 6 && SINGLE_LOAD_ALL == 0) {
                ApPostEvent(h, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
            }
        }
        break;
    case EVT_GET_SELECTED_FILE_NUMBER:
        return -1;
    default:
        break;
    }
    return 0;
}
