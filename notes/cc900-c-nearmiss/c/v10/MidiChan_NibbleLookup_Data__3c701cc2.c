/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_1b.c (2026-11-16-32-p6-m18-olevels)
   sha256 3c701cc280ffa91c9be4bfde230be135727936b7adbcf85cb0819f84e269f11d (tar-sha256); compiled at -O2 -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
void MidiChan_NibbleLookup_Data(struct mq *q, unsigned char *s, unsigned int n)
{
    if (n--) do *q->wr++ = *s++; while (n--);
    *q->wr = 0xff;
}
