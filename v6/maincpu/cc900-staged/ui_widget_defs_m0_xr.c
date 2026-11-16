/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: GetViewInstance */   /* scripts/analysis/cc900/module_calls.py v10 */

struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };

int GetChange(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x4) != 0;
}

int GetMovable(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x2) == 0;
}

void SetMovable(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p &= 0xfffd;
    else
        *p |= 0x2;
}
