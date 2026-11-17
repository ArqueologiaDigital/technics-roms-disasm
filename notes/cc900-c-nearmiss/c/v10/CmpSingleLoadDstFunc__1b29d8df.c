/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_F_14a.c (2026-11-17-16-p6-r31)
   sha256 1b29d8dfdb596b096868621a967883cb45cc9dbea5378c215a268bc386b0c754 (tar-sha256); compiled at -O3 -Xr */
/* lane_p6 helper F, round 14, form a: file_io/single_load.s window procs (module 269).
   Run r29: SingleLoadDstFunc (round 13 form a, -O3) is the ROM's length, 1229 B, and differs only in its PS case
   tail.  The ROM ends the if/else as `ld 1; jr X` / `ld 0` falling into X = `return 0`; ours put `return 0` after
   the `ld 1` branch.  V4.23 lays the after-switch code at the first jump to it, so the `ld 1` branch now jumps to a
   label `done` after the `ld 0` branch, and the `break` there is the first one.
   Cmp*: the ROM's `return 0` follows the LAST case and `return -1` comes after it.  The result variable of round 13
   cost a frame slot (CmpSingleLoadDstFunc lost its frame), so here GET is tested by an `if` before the switch (at
   -O3 the switch re-uses the compared value) and the switch has no GET case.  PS case: -O3 re-read param after
   storing it; lane_sub's spelling (a), a second local for the stored value, keeps it in XWA.
   CmpSingleLoadSrcFunc: the old-style `register` parameter lost the frame; back to a `register` local copy of evt.
   Round 13 form a's notes follow (its return-variable and old-style parts are replaced).
   Round 13, form a: file_io/single_load.s window procs (module 269).
   Run r27: with the obj value in a local, V4.23 at -O3 gives the ROM's frame (obj in XIZ, evt and param in
   slots) to CmpSingleLoadDstFunc (+21) and SingleLoadDstFunc (+13); at -Xr param still wins XIZ.  The ROM's
   if/else visibility posts with one merged `call` are -O3 cross-jumping too, so these procs are -O3 code and
   round 13 aims at -O3:
   - the visibility posts are back to an if/else of two calls (-O3 merges them; the conditional argument made a
     value);
   - no hand-made early load of the list-box object (our local h): -O3 hoists the loads itself;
   - PS case: the stored parameter is passed as the argument (-O3 reloaded it for `ApPostEvent(ram = param, ..)`);
   - SINGLE_LOAD_ALL = the comparison as an unsigned char (the ROM's `scc z,A`; ours was `scc z,WA`);
   - Cmp* return value: -O3 still put the `return 0` block after the first case although the ROM has it after
     the last case with the -1 after it.  Here the result is a variable set to -1 by the GET case, so the
     after-switch code is `return r` and the last case (GET) falls into it.
   CmpSingleLoadSrcFunc: the local copy of evt went to a slot and param took XIZ even at -O3, so here evt is the
   `register` parameter of an old-style definition (the prototype above it stays). */

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
        if (SINGLE_LOAD_AREA == 0 && FileIO_ValidateWithExtHeader() != 0) {
            ram_8a0a = 1;
            goto done;
        }
        ram_8a0a = 0;
    done:
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

long CmpSingleLoadSrcFunc(long obj, long evt0, long param)
{
    register long evt = evt0;
    long t;

    if (evt == EVT_GET_SELECTED_FILE_NUMBER) return -1;
    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        t = param;
        ram_81f4 = t;
        ApPostEvent(t, EVT_SET_SELECTED_FILE_NUMBER, -1);
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
        } else if (param == 7) {
            ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        } else if (param == 8 && SINGLE_LOAD_ALL == 0) {
            ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        } else if (param == 0x28) {
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        }
        break;
    }
    return 0;
}

long CmpSingleLoadDstFunc(long obj, long evt, long param)
{
    register long ob = obj;
    long t;

    if (evt == EVT_GET_SELECTED_FILE_NUMBER) return -1;
    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        t = param;
        ram_81f8 = t;
        ApPostEvent(t, EVT_SET_SELECTED_FILE_NUMBER, -1);
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
        } else if (param == 8) {
            if (SINGLE_LOAD_ALL == 0) {
                ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, 3);
                CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
            } else {
                ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
            }
        } else if (param == 5) {
            ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, -1);
            CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
        } else if (param == 6 && SINGLE_LOAD_ALL == 0) {
            ApPostEvent(ram_81f8, EVT_SET_SELECTED_FILE_NUMBER, -1);
            CmpSingleLoadDst_AreaListProcs[SINGLE_LOAD_AREA](ram_81f8, evt, param);
        }
        break;
    }
    return 0;
}
