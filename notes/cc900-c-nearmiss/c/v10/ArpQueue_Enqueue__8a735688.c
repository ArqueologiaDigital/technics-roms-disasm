/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-30-p6-r1)
   sha256 8a7356886e18f7ab911e798723ccf50ecdd2436ab818c9ee86a2ecf0d3209eb9 (tar-sha256); compiled at -O3 -XS -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
typedef struct mq *mqp;
extern mqp __near ram_bc5c, MIDISEQ_ACTIVE_BLOCK_PTR;
void ArpQueue_Enqueue(unsigned char *s, unsigned int n)
{
    struct mq *q;
    if (n--) {
        q = ram_bc5c;
        do {
            *q->wr++ = *s++;
            q->count++;
        } while (n--);
    }
    *ram_bc5c->wr = 0xff;
}
