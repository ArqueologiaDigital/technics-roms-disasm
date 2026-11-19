/* hdae5000_v1_15i: per-tree C written from the tree's hand source, MATCH in run 2026-11-19-60-hd-r72-v1parts (hd_r72p_uistate_hd_driver__typesel_init.c).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r72p_uistate_hd_driver__typesel_init.c.
   cc900-options: -Xr
   cc900-name: TypeSelInit_b=HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_TypeSel_Init
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct TypeSel { unsigned int mask; unsigned char flag[10]; };

/* v1.15i: eight song parts, so no "mask & 0x100: flag[8]" */
void TypeSelInit_b(struct TypeSel *rec, unsigned int mask, struct TypeSel *tmpl, unsigned char flag)
{
    *rec = *tmpl;
    rec->mask = mask;
    if (mask & 0x001)
        rec->flag[0] = flag;
    if (mask & 0x002)
        rec->flag[1] = flag;
    if (mask & 0x004)
        rec->flag[2] = flag;
    if (mask & 0x008)
        rec->flag[3] = flag;
    if (mask & 0x010)
        rec->flag[4] = flag;
    if (mask & 0x020)
        rec->flag[5] = flag;
    if (mask & 0x040)
        rec->flag[6] = flag;
    if (mask & 0x080)
        rec->flag[7] = flag;
}
