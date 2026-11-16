/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1a.c (2026-11-16-31-p6-r1b)
   sha256 55d0abda1f1ad176b6cda9b0417d1d509cf0856109b356f9c81748eff869e473 (tar-sha256); compiled at -Xr */
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PREVIOUS_TITLE;
extern unsigned char __near ram_3989;
extern unsigned char __near ram_398e;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near ram_398f;
extern unsigned char __near ram_3990;
extern unsigned char __near ram_3991;
extern unsigned char __near ram_3992;
extern unsigned char __near ram_3993;
extern unsigned char __near ram_3994;
extern unsigned char __near ram_3995;
extern unsigned int __near ram_398a;
extern unsigned int __near ram_398c;
void S2cTtl_InitOnTitleChange(void)
{
    if (CURRENT_TITLE == PREVIOUS_TITLE)
        return;
    ram_3989 = SEQ_CURRENT_SONG + 1;
    if (ram_398a != 0)
        return;
    ram_398a = 1;
    ram_398c = 1;
    ram_398e = 25;
    ram_398f = 0;
    ram_3990 = 0;
    ram_3991 = 0;
    ram_3992 = 0;
    ram_3993 = 0;
    ram_3994 = 0;
    ram_3995 = 0;
}
