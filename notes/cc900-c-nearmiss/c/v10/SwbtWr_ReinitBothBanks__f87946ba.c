/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5a.c (2026-11-16-40-p6-r8)
   sha256 f87946baf95982e11078f1ac542bfcae2d882549a42730c571b8582dbb6869d2 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SWBTWR_EVENT_QUEUE;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern void SwbtWr_InitBank1(void);
extern void SwbtWr_InitBank2(void);
void SwbtWr_ReinitBothBanks(void)
{
    if (SWBTWR_EVENT_QUEUE == 255) return;
    SwbtWr_InitBank1();
    SwbtWr_InitBank2();
    SWBTWR_EVENT_QUEUE = 255;
    SWBTWR_WRITE_INDEX = 0;
}
