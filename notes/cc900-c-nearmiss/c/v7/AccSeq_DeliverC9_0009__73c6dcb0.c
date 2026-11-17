/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine_m259.c (2026-11-16-68-p6-r12)
   sha256 73c6dcb0242b8fd2e6abd05e8f0b21d0469121a1cb41df6f35376d43aa70d690 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ACTIVE_TITLE;
extern void ApDeliveryEvent(unsigned long, unsigned long, unsigned long);
void AccSeq_DeliverC9_0009(void)
{
    if (ACTIVE_TITLE == 201)
        ApDeliveryEvent(0xc90009L, 0x1c0000bL, 0L);
}
