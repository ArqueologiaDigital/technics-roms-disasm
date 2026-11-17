/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_7c.c (2026-11-16-79-sub-r7)
   sha256 650eeae51d68d405c677a408096d7d6e93bb8d1452054784e0988350f0418cdb (name+funcs); compiled at -Xr */
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
void DSP_RingBuf_Write2K(unsigned long r, unsigned char c)
{
    unsigned int i;

    i = ((struct ring2k *)r)->w++ & 2047;
    *(unsigned char *)(((unsigned long)i + 6) + r) = c;
    ((struct ring2k *)r)->n++;
}
