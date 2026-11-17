/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_4a.c (2026-11-16-39-p6-r7)
   sha256 3463f1aae6c33574e20f2ee81cb11a9209f625d63976be3d448a39b81d910ff2 (tar-sha256); compiled at -Xr */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct l4 { unsigned char h : 4; unsigned char v : 4; };
struct eq2 { unsigned char h : 2; unsigned char f54 : 2; unsigned char b3 : 1; unsigned char b2 : 1; unsigned char l : 2; };
extern unsigned int __near ram_b7ea;
void DataBuf_CopyEQBlock7(unsigned char *s, unsigned char *d)
{
    struct eq2 *pd = (struct eq2 *)(d + 2);
    struct eq2 *ps = (struct eq2 *)(s + 2);
    pd->f54 = ps->f54;
    pd->b3 = ps->b3;
    pd->b2 = ps->b2;
    pd->l = ps->l;
    ((struct l7 *)(d + 3))->v = ((struct l7 *)(s + 3))->v;
    d[4] = s[4];
    ((struct l4 *)(d + 6))->v = ((struct l4 *)(s + 6))->v;
    if (ram_b7ea != 2) return;
    d[5] = s[5];
}
