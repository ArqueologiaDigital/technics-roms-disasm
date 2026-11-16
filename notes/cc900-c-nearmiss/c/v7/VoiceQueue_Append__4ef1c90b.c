/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers.c (2026-11-16-38-p6-r6)
   sha256 4ef1c90b4a28c88a39cf0adeee143c22bc508f3392b514db83520bbd149e8d2e (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
void VoiceQueue_Append(unsigned char c)
{
    *MIDISEQ_ACTIVE_BLOCK_PTR->wr++ = c;
    *MIDISEQ_ACTIVE_BLOCK_PTR->wr = 0xff;
    if (c == 0xf0) MIDISEQ_ACTIVE_BLOCK_PTR->count = 1;
    else MIDISEQ_ACTIVE_BLOCK_PTR->count++;
}
