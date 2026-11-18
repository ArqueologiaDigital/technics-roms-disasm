/* Functions of midi/param_load_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_bd36;
extern unsigned char ram_2475a;
extern unsigned char ram_2475c;
extern unsigned char ram_2475e;
extern unsigned char ram_24760;
extern unsigned char ram_24762;
extern unsigned char ram_24764;
extern unsigned char ram_24766;
extern unsigned char ram_24768;
extern long ApPostEvent(long, long, long);
extern void ParaLoadOpt_AudioFlagCheck(unsigned char a, unsigned char c, unsigned char e);
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd14;
extern unsigned char __near ram_bd0c;
extern void ParaLoadOpt_AudioFlagCheck_B(unsigned char a, unsigned char c, unsigned char e);

void ParaLoadOpt_AudioFlagCheck(unsigned char a, unsigned char c, unsigned char e)
{
    if (ram_bd36 & 1) {
        ram_bd36 &= ~1;
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
