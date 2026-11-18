/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/ringbuf_and_midi_dispatch_ae_21a.c (2026-11-18-22-sub-r21d-staged)
   sha256 31c64b8f5c56601bf829488bda6f4b3662dfc63a648e9a5f796c8948e1f181c5 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
int RingBuf_ReadByte(unsigned char *r)
{
    unsigned int i;
    int c;
    unsigned int u;
    if ((*(unsigned int *)((r) + (4))) != 0) {
        i = (*(unsigned int *)((r) + (2)))++ & 0xfff;
        u = *((unsigned long)i + 6 + r);
        c = u;
        (*(unsigned int *)((r) + (4)))--;
    } else
        c = -1;
    return c;
}
