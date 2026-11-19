/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_uistate_hd_driver.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 6a0683907d32108e89154d0bed7849245de04f4870cd35489dd099a42f76ae45 (tar-sha256); compiled at -Xr
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
