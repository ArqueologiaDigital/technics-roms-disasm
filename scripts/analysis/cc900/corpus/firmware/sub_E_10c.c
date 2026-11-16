/* cc900-options: -O3 -Xr */
/* lane_sub helper E, round 10, form c: the ring-buffer routines of subcpu_data_tables.s (KN5000 sub-CPU payload
   v1.42), compiled at -O3 -Xr: Serial1_DataTransmit_Loop of the same hand source matched only with -O, and these
   three have -O traits in the ROM (a return value loaded before the test, `ret z` / `ret nz`, &rb->rd computed once).
   Ring buffer record: start +0, end +4, read pointer +8, write pointer +12, free count (int) +20. */

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
    if (rb->wr != rb->rd)
        return 0;
    return 0xffff;
}

unsigned int READ_BYTE_FROM_RING_BUFFER(struct ringbuf *rb)
{
    unsigned char *p;
    unsigned char c;

    p = rb->rd;
    if (rb->wr == p)
        return 0xffff;
    c = *p;
    if (p == rb->end)
        rb->rd = rb->start;
    else
        rb->rd = p + 1;
    rb->free++;
    return c;
}

unsigned int SAVE_BYTE_TO_RING_BUFFER(struct ringbuf *rb, unsigned char c)
{
    unsigned char *p;

    if (rb->free == 0)
        return 0;
    p = rb->wr;
    *p = c;
    if (p == rb->end)
        rb->wr = rb->start;
    else
        rb->wr = p + 1;
    return --rb->free;
}
