/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/accompaniment_engine.c (2026-11-16-55-p6-r10)
   sha256 a9eee1fcda8fa9465b31781feb610f2639591717becebe6aeb9ac9dc89c378fe (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ACTIVE_TITLE;
void AccSeq_DeliverC9_0009(void)
{
    if (ACTIVE_TITLE == 201)
        ApDeliveryEvent(0xc90009L, 0x1c0000bL, 0L);
}
