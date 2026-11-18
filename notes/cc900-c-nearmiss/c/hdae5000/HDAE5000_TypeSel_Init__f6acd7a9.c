/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_uistate.c (2026-11-18-26-hd-r56-ports)
   sha256 f6acd7a9012dc2ff626b9dafdb12c3a0cb7c373bda22102f1fe647082046d269 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: TypeSelInit_b=HDAE5000_TypeSel_Init */
struct TypeSel { unsigned int mask; unsigned char flag[10]; };
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
    if (mask & 0x100)
        rec->flag[8] = flag;
}
