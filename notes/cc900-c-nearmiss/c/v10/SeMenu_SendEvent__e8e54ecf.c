/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines_m129.c (2026-11-16-111-p6-r22-staged)
   sha256 e8e54ecf7f562beef010be3aa4cf15cfc9811abb7ea644b41fbd0a9d48c045ad (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void UI_ChangeTitleByIndex(unsigned char i);
extern void UI_PostRefreshEvent(void);
extern void SeMenu_StoreEventId(unsigned char id);
void SeMenu_SendEvent(unsigned char title, unsigned char refresh)
{
    if (refresh == 0)
        UI_ChangeTitleByIndex(title);
    else
        UI_PostRefreshEvent();
    SeMenu_StoreEventId(refresh);
}
