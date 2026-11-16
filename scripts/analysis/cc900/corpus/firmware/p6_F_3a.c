/* lane_p6 helper F, round 3, form a: ui/ui_mode_handlers.s (module 276).
   Test_PROGRAM_and_TABLE_DATA_ROMs: the self-test sums the program ROM (from its first label) and the table-data
   ROM (0x800000) as two interleaved word sums, twice each (pass index in the byte register QA), and sets result
   bits 0..3 where the two passes disagree.  The ROM indexes the two sum pairs at (xsp+16) / (xsp+12). */

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
            a[j] += p[0];
            b[j] += p[1];
            p += 2;
        }
    }
    if (a[0] != a[1]) r |= 1;
    if (b[0] != b[1]) r |= 2;
    a[0] = 0;
    a[1] = 0;
    b[0] = 0;
    b[1] = 0;
    for (j = 0; j < 2; j++) {
        p = (unsigned int *)0x800000;
        for (k = 0; k < 0x40000; k++) {
            a[j] += p[0];
            b[j] += p[1];
            p += 2;
        }
    }
    if (a[0] != a[1]) r |= 4;
    if (b[0] != b[1]) r |= 8;
    return r;
}
