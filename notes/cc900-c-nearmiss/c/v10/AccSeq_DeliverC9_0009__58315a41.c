/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_5a.c (2026-11-16-40-p6-r8)
   sha256 58315a41666f04ee926133487ef86173e174b0df3b0582b8acb925367c6d231d (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ACTIVE_TITLE;
extern void ApDeliveryEvent(unsigned long, unsigned long, unsigned long);
void AccSeq_DeliverC9_0009(void)
{
    if (ACTIVE_TITLE != 201)
        return;
    ApDeliveryEvent(0xc90009L, 0x1c0000bL, 0L);
}
