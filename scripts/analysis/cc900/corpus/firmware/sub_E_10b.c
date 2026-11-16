/* cc900-options: -O3 -Xr */
/* lane_sub helper E, round 10, form b: other spellings of sub_E_10c.c's ring-buffer routines (subcpu_data_tables.s,
   KN5000 sub-CPU payload v1.42) at -O3 -Xr: a conditional expression, an explicit pointer to the read pointer, an
   int byte parameter and a separate decrement. */

struct ringbuf {
    unsigned char *start;
    unsigned char *end;
    unsigned char *rd;
    unsigned char *wr;
    long pad;
    unsigned int free;
};

unsigned int RING_BUFFER_HAS_OVERRUN(struct ringbuf *rb)
{
    return rb->wr == rb->rd ? 0xffff : 0;
}

unsigned int READ_BYTE_FROM_RING_BUFFER(struct ringbuf *rb)
{
    unsigned char **pr;
    unsigned char *p;
    unsigned char *n;
    unsigned int c;

    c = 0xffff;
    pr = &rb->rd;
    p = *pr;
    n = p;
    if (rb->wr != p) {
        c = *p;
        if (p == rb->end)
            n = rb->start;
        else
            n++;
        *pr = n;
        rb->free++;
    }
    return c;
}

unsigned int SAVE_BYTE_TO_RING_BUFFER(struct ringbuf *rb, int c)
{
    unsigned int *pf;
    unsigned char **pw;
    unsigned char *p;

    pf = &rb->free;
    pw = &rb->wr;
    p = *pw;
    if (*pf == 0)
        return 0;
    *p = c;
    if (p == rb->end)
        p = rb->start;
    else
        p++;
    *pw = p;
    (*pf)--;
    return *pf;
}
