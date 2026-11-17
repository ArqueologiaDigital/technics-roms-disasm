/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17c.c (2026-11-16-126-sub-r17)
   sha256 50a987cbc6cdbc37c89132eff20ee2e3fdc579b48bf25a3767fa1b68170ec996 (name+funcs); compiled at -Xr */
extern unsigned char ram_41368[];
extern unsigned char AudioMod_BusRouting_EnableBits[];
extern unsigned char AudioMod_BusRouting_OrIXBits[];
void AudioMod_Apply_BusRouting(unsigned char part, unsigned char mask, int a, int b)
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
