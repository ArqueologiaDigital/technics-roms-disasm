/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-31-p6-r1b)
   sha256 3c701cc280ffa91c9be4bfde230be135727936b7adbcf85cb0819f84e269f11d (tar-sha256); compiled at -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
struct tmpl16 { unsigned int w[8]; };
extern struct tmpl16 ArpQueue_InitTemplate;
void ArpQueue_InitBuffer(struct mq *q, struct tmpl16 *t)
{
    unsigned char *b;
    q->count = 0;
    b = q->buf;
    q->wr = q->p6 = q->rd = b;
    *b = 0xff;
    *t = ArpQueue_InitTemplate;
}
