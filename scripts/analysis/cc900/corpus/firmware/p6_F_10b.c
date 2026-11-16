/* lane_p6 helper F, round 10, form b: as form a (volatile frame-resident parameters), plus the ROM's early load of
   the list-box object: before the param == 7 test (Src) / param == 8 test (Dst) the ROM loads the saved object
   into XWA once, compares param in XBC, and the following ApPostEvent calls (and Src's 0x28 list-proc call) use
   it without reloading.  Written as a local assigned in an else block whose life ends at the first call. */

/* cc900-module: CmpSingleLoadSrcFunc FileIO_ValidateSignedValue InitializeOperationState SignalProgressUpdate SingleLoadDstBankFunc SingleLoadDstMemFunc SingleLoadModeFunc SingleLoadSrcBankFunc SingleLoadSrcFunc SingleLoadSrcMemFunc SingleLoad_FindNextArea SingleLoad_ScanAreas */

#define EVT_PAINT                     0x1c0000bL
#define EVT_SHOW                      0x1c00001L
#define EVT_HIDE                      0x1c00002L
#define EVT_INDEXSW_UP                0x1c00017L
#define EVT_INDEXSW_DOWN              0x1c00018L
#define EVT_SET_PARAM                 0x1e0003bL
#define EVT_SET_SELECTED_FILE_NUMBER  0x1e50002L
#define EVT_GET_SELECTED_FILE_NUMBER  0x1e50003L
#define EVT_PS_FILE_NAME_BOX_ID       0x1e50004L

extern long ApPostEvent(long, long, long);
extern void UI_InterruptTitleByIndex(int);
extern void InitializeOperationState(int);
extern unsigned char FileIO_ValidateSignedValue(int, int);
extern long SingleLoadSrcMemFunc(long, long, long);
extern long SingleLoadSrcBankFunc(long, long, long);
extern long SingleLoadDstMemFunc(long, long, long);
extern long SingleLoadDstBankFunc(long, long, long);
extern long CmpSingleLoadSrcFunc(long, long, long);

extern long __near ram_81f4;
extern long __near ram_81f8;
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern long (*CmpSingleLoadSrc_ListProcByMode[])(long, long, long);
extern long (*CmpSingleLoadDst_AreaListProcs[])(long, long, long);

#define EVT_PARA_DRAW                 0x1c0000fL
#define EVT_SET_VISIBLE               0x1e0009cL
extern long SingleLoadModeFunc(long, long, long);
extern long SingleLoadSrcFunc(long, long, long);
extern void SignalProgressUpdate(void);
extern void SingleLoad_ScanAreas(void);
extern unsigned char SingleLoad_FindNextArea(void);
extern int FileIO_ValidateWithExtHeader(void);
extern long __near ram_81f0;
extern unsigned char __near ram_8a0a;
extern long (*SingleLoadDst_AreaListProcs[])(long, long, long);

/* SingleLoadDstFunc (new), form b: the early load of the list-box object from the param == 8 test on. */
long SingleLoadDstFunc(long obj, volatile long evt, volatile long param)
{
    long o;

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
        SingleLoadModeFunc(obj, evt, param);
        SingleLoadSrcBankFunc(obj, evt, param);
        SingleLoadSrcMemFunc(obj, evt, param);
        SingleLoadDstBankFunc(obj, evt, param);
        SingleLoadDstMemFunc(obj, evt, param);
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
            SINGLE_LOAD_ALL = (evt == EVT_INDEXSW_UP);
            SingleLoadSrcMemFunc(obj, EVT_PAINT, 0);
            SingleLoadDstMemFunc(obj, EVT_PAINT, 0);
            ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
            ApPostEvent(0x610036L, EVT_SET_PARAM, 0);
            SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, EVT_PAINT, 0);
            SingleLoadSrcFunc(obj, EVT_PAINT, 0);
        } else if (param == 4) {
            if (SingleLoad_FindNextArea() != 0) {
                if (SINGLE_LOAD_AREA != 1) ApPostEvent(0x61004aL, EVT_SET_VISIBLE, 1);
                else ApPostEvent(0x61004aL, EVT_SET_VISIBLE, 0);
                SingleLoadModeFunc(obj, EVT_PAINT, 0);
                SingleLoadSrcBankFunc(obj, EVT_PAINT, 0);
                SingleLoadSrcMemFunc(obj, EVT_PAINT, 0);
                SingleLoadDstBankFunc(obj, EVT_PAINT, 0);
                SingleLoadDstMemFunc(obj, EVT_PAINT, 0);
                ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
                ApPostEvent(0x610036L, EVT_SET_PARAM, 0);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, EVT_PAINT, 0);
                SingleLoadSrcFunc(obj, EVT_PAINT, 0);
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
            o = ram_81f0;
            if (param == 8) {
                if (SINGLE_LOAD_AREA == 1) {
                    ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, 2);
                    SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
                } else if (SINGLE_LOAD_ALL == 0) {
                    ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, 3);
                    SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
                } else {
                    ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, -1);
                    SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
                }
            } else if (param == 5) {
                ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, -1);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            } else if (param == 6) {
                ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, -1);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            }
        }
        break;
    case EVT_GET_SELECTED_FILE_NUMBER:
        return -1;
    }
    return 0;
}

long CmpSingleLoadSrcFunc(long obj, long evt, volatile long param)
{
    long o;

    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ApPostEvent(ram_81f4 = param, EVT_SET_SELECTED_FILE_NUMBER, -1);
        break;
    case EVT_PAINT:
        ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
        CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        break;
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN:
        if (param == 5) {
            ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, 1);
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        } else if (param == 6) {
            if (SINGLE_LOAD_ALL == 0) {
                ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, 3);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
            } else {
                ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
            }
        } else {
            o = ram_81f4;
            if (param == 7) {
                ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
            } else if (param == 8 && SINGLE_LOAD_ALL == 0) {
                ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
            } else if (param == 0x28) {
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](o, evt, param);
            }
        }
        break;
    case EVT_GET_SELECTED_FILE_NUMBER:
        return -1;
    }
    return 0;
}

long CmpSingleLoadDstFunc(long obj, volatile long evt, volatile long param)
{
    long o;

    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ApPostEvent(ram_81f8 = param, EVT_SET_SELECTED_FILE_NUMBER, -1);
        break;
    case EVT_PAINT:
        SingleLoadSrcMemFunc(obj, evt, param);
        SingleLoadSrcBankFunc(obj, evt, param);
        SingleLoadDstMemFunc(obj, evt, param);
        SingleLoadDstBankFunc(obj, evt, param);
        ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, -1);
        ApPostEvent(0x61007eL, EVT_SET_PARAM, 0);
        CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
        break;
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN:
        if (param == 3) {
            SINGLE_LOAD_ALL = (evt == EVT_INDEXSW_UP);
            SingleLoadSrcMemFunc(obj, EVT_PAINT, 0);
            SingleLoadDstMemFunc(obj, EVT_PAINT, 0);
            ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, -1);
            ApPostEvent(0x61007eL, EVT_SET_PARAM, 0);
            CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, EVT_PAINT, 0);
            CmpSingleLoadSrcFunc(obj, EVT_PAINT, 0);
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
            o = ram_81f8;
            if (param == 8) {
                if (SINGLE_LOAD_ALL == 0) {
                    ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, 3);
                    CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
                } else {
                    ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, -1);
                    CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
                }
            } else if (param == 5) {
                ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
            } else if (param == 6 && SINGLE_LOAD_ALL == 0) {
                ApPostEvent(o, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
            }
        }
        break;
    case EVT_GET_SELECTED_FILE_NUMBER:
        return -1;
    }
    return 0;
}
