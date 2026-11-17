/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_5b.c (2026-11-16-40-p6-r8)
   sha256 e092dfa680c8d9ce8506cdb5b8df148f8e610a6d1a4b2818f2b7087e306f1a75 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ACC_LANES_RESYNC;
extern unsigned char __near ram_32ec;
extern void RhythmPart_CopyData(void);
extern void RhythmPart1_ProcessAccentData(void);
extern void RhythmPart2_ProcessAccentData(void);
extern void RhythmPart3_ProcessAccentData(void);
extern void RhythmPart4_ProcessAccentData(void);
extern void RhythmPart5_ProcessAccentData(void);
void AccNote_FlushAll(void)
{
    unsigned char a;
    if (ACC_LANES_RESYNC & 0x3f) {
        RhythmPart_CopyData();
        RhythmPart1_ProcessAccentData();
        a = 1;
        ram_32ec = a;
        RhythmPart2_ProcessAccentData();
        RhythmPart3_ProcessAccentData();
        RhythmPart4_ProcessAccentData();
        RhythmPart5_ProcessAccentData();
        ACC_LANES_RESYNC &= 0xc0;
    }
}
