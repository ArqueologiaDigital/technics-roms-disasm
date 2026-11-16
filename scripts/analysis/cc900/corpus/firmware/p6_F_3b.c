/* lane_p6 helper F, round 3, form b: ui/ui_mode_handlers.s (module 276).
   Test_PROGRAM_and_TABLE_DATA_ROMs as in form a, with the sums written `x = *p + x` (the ROM adds the ROM word
   first), the second word read through `*p++`, and the disagreement tests written second-sum first. */

extern unsigned int LED_patterns_indicating_firmware_version[];

int Test_PROGRAM_and_TABLE_DATA_ROMs(unsigned char r)
{
    unsigned int a[2];
    unsigned int b[2];
    unsigned char j;
    unsigned long k;
    unsigned int *p;

    a[0] = 0;
    a[1] = 0;
    b[0] = 0;
    b[1] = 0;
    for (j = 0; j < 2; j++) {
        p = LED_patterns_indicating_firmware_version;
        for (k = 0; k < 0x40000; k++) {
            a[j] = *p++ + a[j];
            b[j] = *p++ + b[j];
        }
    }
    if (a[1] != a[0]) r |= 1;
    if (b[1] != b[0]) r |= 2;
    a[0] = 0;
    a[1] = 0;
    b[0] = 0;
    b[1] = 0;
    for (j = 0; j < 2; j++) {
        p = (unsigned int *)0x800000;
        for (k = 0; k < 0x40000; k++) {
            a[j] = *p++ + a[j];
            b[j] = *p++ + b[j];
        }
    }
    if (a[1] != a[0]) r |= 4;
    if (b[1] != b[0]) r |= 8;
    return r;
}
