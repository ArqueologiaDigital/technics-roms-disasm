/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: GetNextView GetPrevView GetSubView GetSuperView GetViewInstance MainFuncCall SetChange */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int TITLE_FLAGS;
extern long MainFuncCall(long, long, long);
extern long TitleProc_ClearResourceDirtyFlag(unsigned int m);
extern unsigned long GetNextView(unsigned long id);
extern unsigned long GetSuperView(unsigned long id);
extern unsigned long GetSubView(unsigned long id);
extern unsigned long GetLinkView(unsigned long id);

long TitleProc_ClearResourceDirtyFlag(unsigned int m)
{
	TITLE_FLAGS &= ~m;
	return MainFuncCall(0x1400001L, 0x1e000baL, (unsigned long)TITLE_FLAGS);
}

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
