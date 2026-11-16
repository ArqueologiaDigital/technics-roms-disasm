/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v9/ui_widget_defs_m272.c (2026-11-16-111-p6-r22-staged)
   sha256 652599cc5bf7b62fab2df092d2dffccf0fb68e2f2bb54a1cedfe27597ad59374 (tar-sha256); compiled at -Xr */
/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: GetNextView GetPrevView GetSubView GetSuperView GetViewInstance SetChange */   /* scripts/analysis/cc900/module_calls.py v10 */

struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
extern void SetChange(unsigned long id, int f);
extern struct viewable *GetViewInstance(unsigned long id);
extern unsigned long GetNextView(unsigned long id);
extern unsigned long GetPrevView(unsigned long id);
extern unsigned long GetSuperView(unsigned long id);
extern unsigned long GetSubView(unsigned long id);
extern void Unlink(unsigned long id);
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];

void Unlink(unsigned long id)
{
    unsigned long prev, next;
    unsigned long x;
    int n;
    prev = GetPrevView(id);
    if (prev != 0xffffffffUL) {
        x = (unsigned long)GetViewInstance(prev);
        ((struct viewable *)x)->next = GetNextView(id);
        SetChange(prev, 1);
        GetViewInstance(id)->prev = -1;
        SetChange(id, 1);
    }
    next = GetNextView(id);
    if (next != 0xffffffffUL) {
        GetViewInstance(next)->prev = prev;
        SetChange(next, 1);
        GetViewInstance(id)->next = -1;
        SetChange(id, 1);
    }
    x = GetSuperView(id);
    if (x != 0xffffffffUL) {
        prev = (unsigned long)GetViewInstance(x);
        if (GetSubView(x) == id) {
            n = next;
            ((struct viewable *)prev)->sub = n;
            SetChange(id, 1);
        }
        GetViewInstance(id)->super = -1;
        SetChange(id, 1);
    }
}

struct viewable *GetViewInstance(unsigned long id)
{
    unsigned int i;
    unsigned long t;
    struct viewable **d;
    t = (id >> 16) & 0xfff;
    i = (unsigned int)(id & 0xffff);
    d = OBJECT_REGISTRY[(unsigned int)t].data;
    return d[i];
}
