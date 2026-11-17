/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
int DSP_RingBuf_Read(struct ring2k *r)
{
    unsigned int i;
    int c;

    if (r->n != 0) {
        c = r->buf[r->r++ & 0x7ff];
        r->n--;
    } else
        c = -1;
    return c;
}
