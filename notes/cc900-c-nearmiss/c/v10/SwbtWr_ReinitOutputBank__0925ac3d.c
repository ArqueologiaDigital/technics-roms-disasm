/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_5b.c (2026-11-16-40-p6-r8)
   sha256 0925ac3d7624e564a79643524eac0977811cc2828328dc740296e5ffc2f35240 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SWBTWR_EVENT_QUEUE;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern void SwbtWr_InitBank2();
void SwbtWr_ReinitOutputBank(void)
{
    if (SWBTWR_EVENT_QUEUE == 255) return;
    SwbtWr_InitBank2();
    SWBTWR_EVENT_QUEUE = 255;
    SWBTWR_WRITE_INDEX = 0;
}
