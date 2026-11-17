/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
int DSP_RingBuf_Read(struct ring2k *r)
{
    unsigned int i;
    int c;

    if (r->n != 0) {
        i = r->r++ & 0x7ff;
        c = r->buf[i];
        r->n--;
    } else
        c = -1;
    return c;
}
