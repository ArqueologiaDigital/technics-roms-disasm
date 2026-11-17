/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_widget_defs_m271.c (2026-11-16-125-p6-r26-staged)
   sha256 d3f9cce69a6ca593bb2e816904494ad0a9441f87fc3adf857e389b63d31ee647 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
        return (unsigned int)(p == 0xf);
    }
}
