/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r54_misc_ui.c (2026-11-18-20-hd-r55)
   sha256 ed45ae77f9489cbc81c7e2457800fd0a7a693693caed4c576e2f1a55d8981484 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: TypeSelInit_c=HDAE5000_TypeSel_Init */
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
void TypeSelInit_c(struct TypeSel *rec, unsigned int mask, struct TypeSel *tmpl, int flag)
{
    struct TypeSel *s = tmpl;
    unsigned int m = mask;
    unsigned char v = flag;

    *rec = *s;
    rec->mask = m;
    if (m & 0x001)
        rec->flag[0] = v;
    if (m & 0x002)
        rec->flag[1] = v;
    if (m & 0x004)
        rec->flag[2] = v;
    if (m & 0x008)
        rec->flag[3] = v;
    if (m & 0x010)
        rec->flag[4] = v;
    if (m & 0x020)
        rec->flag[5] = v;
    if (m & 0x040)
        rec->flag[6] = v;
    if (m & 0x080)
        rec->flag[7] = v;
    if (m & 0x100)
        rec->flag[8] = v;
}
