/* Phase 6, lane_p6 helper C, round 21, module 264 (modules_v10.tsv) of v10 midi/ac_listener_handlers.s, form b of
   ParaLoadOpt_AudioFlagCheck and ParaLoadOpt_AudioFlagCheck_B (form a, p6_C_21m264a.c, describes them): each flag
   cell is read once into a byte local, tested, and stored back with the bit cleared, as the ROM keeps it in A. */
/* cc900-data: ParaLoadOpt_AudioFlagCheck 1 = ParaLoadOpt_AudioFlagCheck_CaseTable */
/* cc900-data: ParaLoadOpt_AudioFlagCheck_B 1 = ParaLoadOpt_AudioFlagCheck_B_CaseTable */

extern unsigned char __near ram_bd36;
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd14;
extern unsigned char __near ram_bd0c;
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
    unsigned char t;
    t = ram_bd36;
    if (t & 1) {
        ram_bd36 = t & ~1;
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
    unsigned char t;
    t = ram_bd36;
    if (t & 2) {
        ram_bd36 = t & ~2;
        ApPostEvent(0x570011L, 0x1c00001L, 0L);
    }
    t = ram_bd10;
    if (t & 0x80) {
        ram_bd10 = t & ~0x80;
        ram_2475c = c;
        ApPostEvent(0x57001bL, 0x1e000a7L, 0L);
    }
    t = ram_bd14;
    if (t & 0x80) {
        ram_bd14 = t & ~0x80;
        ram_2475e = e;
        ApPostEvent(0x57001bL, 0x1e000a7L, 0L);
    }
    t = ram_bd0c;
    if (t & 0x80) {
        ram_bd0c = t & ~0x80;
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
