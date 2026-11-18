/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_15a.c (2026-11-18-1-p6-r33)
   sha256 94d7dff51f06ad6384be90fa0aa6b465b81b8e820307fc4ad08c0e40318353ab (tar-sha256); compiled at -O3 -Xr */
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
extern void SignalProgressUpdate(void);
extern void SingleLoad_ScanAreas(void);
extern unsigned char SingleLoad_FindNextArea(void);
extern int FileIO_ValidateWithExtHeader(void);
extern long __near ram_81f0;
extern unsigned char __near ram_8a0a;
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern long (*SingleLoadDst_AreaListProcs[])(long, long, long);
long SingleLoadDstFunc(long obj, long evt, long param)
{
    register long ob = obj;

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
        if (SINGLE_LOAD_AREA != 0 || FileIO_ValidateWithExtHeader() == 0) ram_8a0a = 0;
        else ram_8a0a = 1;
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
        } else if (param == 8) {
            if (SINGLE_LOAD_AREA == 1) {
                ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, 2);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            } else if (SINGLE_LOAD_ALL == 0) {
                ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, 3);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            } else {
                ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
                SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
            }
        } else if (param == 5) {
            ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
            SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
        } else if (param == 6) {
            ApPostEvent(ram_81f0, EVT_SET_SELECTED_FILE_NUMBER, -1);
            SingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f0, evt, param);
        }
        break;
    case EVT_GET_SELECTED_FILE_NUMBER:
        return -1;
    }
    return 0;
}
