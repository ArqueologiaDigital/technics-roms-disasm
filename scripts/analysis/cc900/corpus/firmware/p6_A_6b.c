/* Phase 6, lane_p6 helper A, round 6, form b: SoundCtrl_CalcScaledTempo (v10 sequencer/accompaniment_engine.s).
   Round 5 form b matched its first 41 bytes at -Xr; only the final store differed (the ROM stores L directly). */
extern unsigned int __near STYLE_FREE_BLOCKS;
extern unsigned char __near ram_39ab;
extern unsigned long Math_Multiply32(unsigned long, unsigned long);
extern unsigned long Math_DivideU32(unsigned long, unsigned long);

void SoundCtrl_CalcScaledTempo(void)
{
    unsigned long r;
    r = 100;
    r = Math_Multiply32(r, (unsigned long)STYLE_FREE_BLOCKS);
    r = Math_DivideU32(r, 190L);
    if (r >= 100)
        r = 99;
    ram_39ab = (unsigned char)r;
}
