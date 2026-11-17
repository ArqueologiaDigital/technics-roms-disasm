/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_1b.c (2026-11-16-55-p6-r10)
   sha256 a518fdcf192eae41509fa2813337216e1a2cc69827c693dcbb511205ae502c10 (tar-sha256); compiled at -O3 -Xr */
#define EVT_PAINT                     0x1c0000bL
#define EVT_INDEXSW_UP                0x1c00017L
#define EVT_INDEXSW_DOWN              0x1c00018L
#define EVT_SET_SELECTED_FILE_NUMBER  0x1e50002L
#define EVT_GET_SELECTED_FILE_NUMBER  0x1e50003L
#define EVT_PS_FILE_NAME_BOX_ID       0x1e50004L
extern long ApPostEvent(long, long, long);
extern long __near ram_81f4;
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern long (*CmpSingleLoadSrc_ListProcByMode[])(long, long, long);
long CmpSingleLoadSrcFunc(long obj, long evt, long param)
{
    if (evt == EVT_GET_SELECTED_FILE_NUMBER) return -1;
    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ram_81f4 = param;
        ApPostEvent(param, EVT_SET_SELECTED_FILE_NUMBER, -1);
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
