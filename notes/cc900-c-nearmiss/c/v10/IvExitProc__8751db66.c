/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_11m271b.c (2026-11-16-118-p6-r23)
   sha256 8751db664d745c68147e3aa1eca4a46726254b7f87eef8e02c8b346676d1a750 (tar-sha256); compiled at -O3 -Xr */
#define EVT_DRAW            0x1c0000dL
#define EVT_PARA_DRAW       0x1c0000fL
#define EVT_CHECK_EDIT_SW   0x1e00053L
extern long SendEvent(long, long, long);
#define EVT_GET_STRING      0x1e0003aL
extern long PsInvisibleBoxProc(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern char IvExit_GetText_Str_EXIT[];
long IvExitProc(long obj, long evt, long p)
{
    switch (evt) {
    default:
        return PsInvisibleBoxProc(obj, evt, p);
    case EVT_DRAW:
        PsInvisibleBoxProc(obj, evt, p);
        SendEvent(obj, EVT_PARA_DRAW, 0);
        return 0;
    case EVT_GET_STRING:
        Strcpy((char *)p, IvExit_GetText_Str_EXIT);
        return 0;
    case EVT_CHECK_EDIT_SW:
        return p == 0xf;
    }
}
