/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/accompaniment_engine.c (2026-11-16-40-p6-r8)
   sha256 4c280a5d9acc951dc889467c8cbe194c5422bdd08990b396a7ed2edd97739535 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
