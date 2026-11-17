/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17a.c (2026-11-16-126-sub-r17)
   sha256 ac0e9204f80496a2a00e80ac0c4a0b41db26241507df15b2c4016b2c7863b004 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char AudioMod_BusRouting_EnableBits[];
extern unsigned char AudioMod_BusRouting_OrIXBits[];
void AudioMod_Apply_BusRouting(unsigned char part, unsigned char mask, unsigned int a, unsigned int b)
{
    unsigned char w;
    for (w = 0; w < 4; w++) {
        if (AudioMod_BusRouting_EnableBits[w] & mask) {
            if (AudioMod_BusRouting_OrIXBits[w] & mask) {
                (*(unsigned int *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e] + 24)) |= a | b;
            } else {
                (*(unsigned int *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e] + 24)) &= ~b;
                (*(unsigned int *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e] + 24)) |= a;
            }
        } else {
            (*(unsigned int *)(&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(w) * 37 + 0x6e] + 24)) &= ~(a | b);
        }
    }
}
