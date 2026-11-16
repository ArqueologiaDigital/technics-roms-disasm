/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers.c (2026-11-16-33-p6-r2)
   sha256 d6843c84d3ee2b69260c89583d89ec35521b78e4bb5a2372152c1444072395ed (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
typedef struct mq *mqp;
extern mqp __near ram_bbc0;
void ArpQueue_Enqueue(unsigned char *s, unsigned int n)
{
    struct mq *q;
    unsigned char **w;
    if (n--) {
        q = ram_bbc0;
        w = &q->wr;
        do {
            *(*w)++ = *s++;
            q->count++;
        } while (n--);
    }
    *ram_bbc0->wr = 0xff;
}
