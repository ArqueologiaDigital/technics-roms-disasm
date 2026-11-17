/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_21m264a.c (2026-11-17-2-p6-r29)
   sha256 a1686daa7a053fad76f49643366f2cd0a30b2b1d0c6fbaf9f6a2d1b974232cbf (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_bd36;
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd14;
extern unsigned char __near ram_bd0c;
extern unsigned char ram_2475c;
extern unsigned char ram_2475e;
extern unsigned char ram_24760;
extern unsigned char ram_24762;
extern unsigned char ram_24764;
extern unsigned char ram_24766;
extern unsigned char ram_24768;
extern long ApPostEvent(long, long, long);
void ParaLoadOpt_AudioFlagCheck_B(unsigned char a, unsigned char c, unsigned char e)
{
    if (ram_bd36 & 2) {
        ram_bd36 &= ~2;
        ApPostEvent(0x570011L, 0x1c00001L, 0L);
    }
    if (ram_bd10 & 0x80) {
        ram_bd10 &= ~0x80;
        ram_2475c = c;
        ApPostEvent(0x57001bL, 0x1e000a7L, 0L);
    }
    if (ram_bd14 & 0x80) {
        ram_bd14 &= ~0x80;
        ram_2475e = e;
        ApPostEvent(0x57001bL, 0x1e000a7L, 0L);
    }
    if (ram_bd0c & 0x80) {
        ram_bd0c &= ~0x80;
        switch (a) {
        case 0:
            ram_24760 = 0;
            ram_24762 = 0;
            ram_24764 = 0;
            ram_24766 = 0;
            ram_24768 = 0;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 1:
            ram_24760 = 2;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 2:
            ram_24760 = 3;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 3:
            ram_24762 = 2;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 4:
            ram_24762 = 3;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 5:
            ram_24764 = 2;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 6:
            ram_24764 = 3;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 7:
            ram_24766 = 2;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 8:
            ram_24766 = 3;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 11:
            ram_24768 = 2;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        case 12:
            ram_24768 = 3;
            ApPostEvent(0x570015L, 0x1c0000bL, 0L);
            break;
        }
    }
}
