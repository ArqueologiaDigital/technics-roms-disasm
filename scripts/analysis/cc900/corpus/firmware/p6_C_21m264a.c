/* Phase 6, lane_p6 helper C, round 21, module 264 (modules_v10.tsv) of v10 midi/ac_listener_handlers.s, form a:
   ParaLoadOpt_AudioFlagCheck and ParaLoadOpt_AudioFlagCheck_B (new, poolnew_C; 419 / 430 B), two twins.
   Each takes three bytes (status a, two values c and e), clears pending flag bits in the 0xbd.. cells and posts
   their events, stores c / e when they changed (A) or when their flag is set (B), and on a changed status (A) or
   its flag (B) maps the status 0..12 through a jump table to the memory-transfer state bytes (P / S memory,
   compare, sequence, MSP: 1 or 2 = sending / receiving, 3 = completed; 0 clears all five) and posts one event.
   The parameters live on the stack (-Xr).  The jump tables are the trees' ParaLoadOpt_AudioFlagCheck_CaseTable and
   ParaLoadOpt_AudioFlagCheck_B_CaseTable (cc900-data).  Every case ends in the same ApPostEvent call, which the ROM
   shares.  The flag bit is tested in A and cleared in A (res) before the store.
   Form a: the flag cell tested and cleared as `if (x & m) { x &= ~m; ... }`.
   Form b (p6_C_21m264b.c): through a byte local; form c (p6_C_21m264c.c): as an unsigned char bitfield. */
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
