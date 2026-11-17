/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_3b.c (2026-11-16-37-p6-r5)
   sha256 19ac9ffcc3dffa560a13cbac8f2a1110582b09bc1d1ec12568849df3c6318787 (tar-sha256); compiled at -Xr */
extern char __near RHYTHM_LOAD_PROGRAM;
extern unsigned char __near RHYTHM_LOAD_BANK;
extern unsigned char __near RHYTHM_LOAD_PART;
extern unsigned char __near STYLE_SECTION;
extern unsigned char __near ram_34cd;
unsigned char CmpRecSet_OnRhythmBank_Code_Helper2(void)
{
    unsigned char p;
    unsigned char c;
    p = RHYTHM_LOAD_PROGRAM & 0xff;
    if (p >= 240) {
        p = 128;
        RHYTHM_LOAD_PROGRAM = p;
        RHYTHM_LOAD_BANK = 0;
    }
    if (p >= 128 && RHYTHM_LOAD_BANK % 128 != 0)
        RHYTHM_LOAD_BANK = 0;
    if (p < 128)
        goto low;
    if (RHYTHM_LOAD_PART < 16)
        RHYTHM_LOAD_PART = 26;
join:
    if (RHYTHM_LOAD_PART == 26) {
        c = ram_34cd & 0x30;
        switch (c) {
        case 0: STYLE_SECTION = 30; break;
        case 0x20: STYLE_SECTION = 31; break;
        default: STYLE_SECTION = 32; break;
        }
    } else if (STYLE_SECTION >= 30) {
        c = ram_34cd & 0x30;
        switch (c) {
        case 0: STYLE_SECTION = 0; break;
        case 0x20: STYLE_SECTION = 4; break;
        default: STYLE_SECTION = 8; break;
        }
    }
    return p;
low:
    if (RHYTHM_LOAD_PART >= 16)
        RHYTHM_LOAD_PART = 26;
    goto join;
}
