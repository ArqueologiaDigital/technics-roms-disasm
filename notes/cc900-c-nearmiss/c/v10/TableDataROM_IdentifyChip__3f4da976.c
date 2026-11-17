/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3a.c (2026-11-16-37-p6-r5)
   sha256 3f4da9760305cc181a03f903f54adec3de046408b1665d02d1fe4258e884294e (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __tiny P7;
long TableDataROM_IdentifyChip(void)
{
    volatile long *p = (volatile long *)0x800000;
    do ; while (!(P7 & 0x20));
    p[0x5555] = 0x00aa00aaL;
    p[0x2aaa] = 0x00550055L;
    p[0x5555] = 0x00f000f0L;
    return p[0x1919];
}
