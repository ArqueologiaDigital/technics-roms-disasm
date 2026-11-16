/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers.c (2026-11-16-40-p6-r8)
   sha256 bbb40955759a1b5e6bf2ce15d4a26d79eb43a2aab04e15fc2fbb3ada3efa3cd7 (tar-sha256); compiled at -O3 -XS -Xr
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
