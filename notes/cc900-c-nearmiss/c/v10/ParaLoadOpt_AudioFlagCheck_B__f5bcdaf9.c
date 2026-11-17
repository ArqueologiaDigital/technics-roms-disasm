/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_21m264c.c (2026-11-17-2-p6-r29)
   sha256 f5bcdaf9f26cd067f57c55f9ececa6cc865b96f13b219c9cdde15a2414bc56c1 (tar-sha256); compiled at -O3 -Xr */
struct flagbits { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
                  unsigned char b3 : 1; unsigned char b2 : 1; unsigned char b1 : 1; unsigned char b0 : 1; };
extern struct flagbits __near ram_bd36;
extern struct flagbits __near ram_bd10;
extern struct flagbits __near ram_bd14;
extern struct flagbits __near ram_bd0c;
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
    if (ram_bd36.b1) {
        ram_bd36.b1 = 0;
        ApPostEvent(0x570011L, 0x1c00001L, 0L);
    }
    if (ram_bd10.b7) {
        ram_bd10.b7 = 0;
        ram_2475c = c;
        ApPostEvent(0x57001bL, 0x1e000a7L, 0L);
    }
    if (ram_bd14.b7) {
        ram_bd14.b7 = 0;
        ram_2475e = e;
        ApPostEvent(0x57001bL, 0x1e000a7L, 0L);
    }
    if (ram_bd0c.b7) {
        ram_bd0c.b7 = 0;
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
