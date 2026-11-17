/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3a.c (2026-11-16-37-p6-r5)
   sha256 3f4da9760305cc181a03f903f54adec3de046408b1665d02d1fe4258e884294e (tar-sha256); compiled at -O3 -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
unsigned char MidiChan_DequeueVoiceEntry(struct mq *q)
{
    unsigned char c = 0xff;
    unsigned char **pp = &q->rd;
    unsigned char *r = *pp;
    if (*r != 0xff) {
        c = *r++;
        *pp = r;
    }
    return c;
}
