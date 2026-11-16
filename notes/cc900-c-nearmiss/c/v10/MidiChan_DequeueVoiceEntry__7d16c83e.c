/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1a.c (2026-11-16-32-p6-m18-olevels)
   sha256 7d16c83e6f1cf5e299730f8d1d1afaeca30c78536fe0c0f5702fb6c24ee9316d (tar-sha256); compiled at -O1 -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
unsigned char MidiChan_DequeueVoiceEntry(struct mq *q)
{
    unsigned char **pp = &q->rd;
    unsigned char c = 0xff;
    if (**pp != 0xff) c = *(*pp)++;
    return c;
}
