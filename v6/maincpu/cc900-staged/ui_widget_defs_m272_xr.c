/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: GetNextView GetPrevView GetSubView GetSuperView GetViewInstance SetChange */   /* scripts/analysis/cc900/module_calls.py v10 */

struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
extern struct viewable *GetViewInstance(unsigned long id);
extern void GetBox(unsigned long id, struct box *b);
extern int GetConst(unsigned long id);
extern int GetVisible(unsigned long id);
extern void SetChange(unsigned long id, int f);
extern void SetBox(unsigned long id, struct box *b);
extern void SetConst(unsigned long id, int f);
extern void SetVisible(unsigned long id, int f);

void GetBox(unsigned long id, struct box *b)
{
    *b = GetViewInstance(id)->box;
}

int GetConst(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x8) != 0;
}

int GetVisible(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x1) == 0;
}

void SetBox(unsigned long id, struct box *b)
{
    GetViewInstance(id)->box = *b;
    SetChange(id, 1);
}

void SetChange(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p |= 0x4;
    else
        *p &= 0xfffb;
}

void SetConst(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p |= 0x8;
    else
        *p &= 0xfff7;
}

void SetVisible(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p &= 0xfffe;
    else
        *p |= 0x1;
}
