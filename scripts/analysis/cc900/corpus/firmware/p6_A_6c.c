/* Phase 6, lane_p6 helper A, round 6, form c: SoundCtrl_CalcScaledTempo (v10 sequencer/accompaniment_engine.s).
   Round 5 form b matched its first 41 bytes at -Xr; only the final store differed (the ROM stores L directly). */
extern unsigned int __near STYLE_FREE_BLOCKS;
extern unsigned char __near ram_39ab;
extern unsigned long Math_Multiply32(unsigned long, unsigned long);
extern unsigned long Math_DivideU32(unsigned long, unsigned long);

/* The plain unsigned arithmetic: V4.23 calls its runtime C9H_mullu / C9H_divlu, which are the tree's Math_Multiply32 /
   Math_DivideU32 (their headers say so); the checker needs that mapping for this form. */
void SoundCtrl_CalcScaledTempo(void)
{
    unsigned long r;
    r = 100UL * STYLE_FREE_BLOCKS / 190UL;
    if (r > 99)
        r = 99;
    ram_39ab = r;
}
