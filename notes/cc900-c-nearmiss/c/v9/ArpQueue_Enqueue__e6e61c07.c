/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers.c (2026-11-16-33-p6-r2)
   sha256 e6e61c07b85f372ad7b1535762da9b28f897035e18935b54ce284b3ec7f8f7b8 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
typedef struct mq *mqp;
extern mqp __near ram_bc5c;
void ArpQueue_Enqueue(unsigned char *s, unsigned int n)
{
    struct mq *q;
    unsigned char **w;
    if (n--) {
        q = ram_bc5c;
        w = &q->wr;
        do {
            *(*w)++ = *s++;
            q->count++;
        } while (n--);
    }
    *ram_bc5c->wr = 0xff;
}
