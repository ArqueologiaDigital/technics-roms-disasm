/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/param_load_routines_m264.c (2026-11-18-12-p6-r35)
   sha256 67729beb3ed7b7b0edda56ed6ddc251fdd5a2886be08d1464ebc2949d62f198e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_bc9a;
extern unsigned char ram_2475a;
extern unsigned char ram_2475c;
extern unsigned char ram_2475e;
extern unsigned char ram_24760;
extern unsigned char ram_24762;
extern unsigned char ram_24764;
extern unsigned char ram_24766;
extern unsigned char ram_24768;
extern long ApPostEvent(long, long, long);
void ParaLoadOpt_AudioFlagCheck(unsigned char a, unsigned char c, unsigned char e)
{
    if (ram_bc9a & 1) {
        ram_bc9a &= ~1;
        ApPostEvent(0x570006L, 0x1c00001L, 0L);
    }
    if (ram_2475c != c) {
        ram_2475c = c;
        ApPostEvent(0x570010L, 0x1e000a7L, 0L);
    }
    if (ram_2475e != e) {
        ram_2475e = e;
        ApPostEvent(0x570010L, 0x1e000a7L, 0L);
    }
    if (ram_2475a != a) {
        ram_2475a = a;
        switch (a) {
        case 0:
            ram_24760 = 0;
            ram_24762 = 0;
            ram_24764 = 0;
            ram_24766 = 0;
            ram_24768 = 0;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 1:
            ram_24760 = 1;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 2:
            ram_24760 = 3;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 3:
            ram_24762 = 1;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 4:
            ram_24762 = 3;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 5:
            ram_24764 = 1;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 6:
            ram_24764 = 3;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 7:
            ram_24766 = 1;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 8:
            ram_24766 = 3;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 11:
            ram_24768 = 1;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        case 12:
            ram_24768 = 3;
            ApPostEvent(0x57000aL, 0x1c0000bL, 0L);
            break;
        }
    }
}
