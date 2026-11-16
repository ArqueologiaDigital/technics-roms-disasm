/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_widget_defs_m272.c (2026-11-16-91-p6-r17)
   sha256 ec850fa30ae6f66cb92ad2bee25bcb9c8c05f873ebd54c1c99015d7adbec68d0 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned long GetNextView(unsigned long id);
extern unsigned long GetSuperView(unsigned long id);
extern unsigned long GetSubView(unsigned long id);
unsigned long GetLinkView(unsigned long id)
{
    if (GetSubView(id) != 0xffffffffUL)
        return GetSubView(id);
    if (GetNextView(id) != 0xffffffffUL)
        return GetNextView(id);
    while (GetNextView(id) == 0xffffffffUL) {
        id = GetSuperView(id);
        if (id == 0xffffffffUL)
            return 0xffffffffUL;
    }
    return GetNextView(id);
}
