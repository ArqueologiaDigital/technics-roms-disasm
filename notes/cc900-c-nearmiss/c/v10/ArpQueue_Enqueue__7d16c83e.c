/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-31-p6-r1b)
   sha256 7d16c83e6f1cf5e299730f8d1d1afaeca30c78536fe0c0f5702fb6c24ee9316d (tar-sha256); compiled at -O3 -XS -Xr */
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
