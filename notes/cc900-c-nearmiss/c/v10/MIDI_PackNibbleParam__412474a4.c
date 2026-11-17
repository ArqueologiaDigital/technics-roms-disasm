/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3b.c (2026-11-16-37-p6-r5)
   sha256 412474a4bcb1b07706b807e204b3c008566145fa8f25b4beb61a0e0ac464ffd3 (tar-sha256); compiled at -O3 -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
unsigned char MIDI_PackNibbleParam(struct mq *q)
{
    unsigned char **pp = &q->p6;
    unsigned char r, l;
    r = *(*pp)++;
    r <<= 4;
    l = *(*pp)++;
    r |= l & 0xf;
    return r;
}
