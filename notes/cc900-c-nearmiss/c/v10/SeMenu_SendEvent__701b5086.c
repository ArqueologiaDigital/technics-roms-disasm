/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m129a.c (2026-11-16-100-p6-r19)
   sha256 701b50862cea8afdb7d4731ed7801af5090888e61b80a277453a14a39b81a886 (tar-sha256); compiled at -O3 -XS -Xr */
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
