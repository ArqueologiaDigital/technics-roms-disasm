/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine.c (2026-11-16-38-p6-r6)
   sha256 a5857c65f223d6324e3b3975946e788d0d8d250134e448741a69293b0c729561 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PREVIOUS_TITLE;
extern unsigned char __near ram_38ed;
extern unsigned char __near ram_38f2;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near ram_38f3;
extern unsigned char __near ram_38f4;
extern unsigned char __near ram_38f5;
extern unsigned char __near ram_38f6;
extern unsigned char __near ram_38f7;
extern unsigned char __near ram_38f8;
extern unsigned char __near ram_38f9;
extern unsigned int __near ram_38ee;
extern unsigned int __near ram_38f0;
void S2cTtl_InitOnTitleChange(void)
{
    if (CURRENT_TITLE == PREVIOUS_TITLE)
        return;
    ram_38ed = SEQ_CURRENT_SONG + 1;
    if (ram_38ee != 0)
        return;
    ram_38ee = 1;
    ram_38f0 = 1;
    ram_38f2 = 25;
    ram_38f3 = 0;
    ram_38f4 = 0;
    ram_38f5 = 0;
    ram_38f6 = 0;
    ram_38f7 = 0;
    ram_38f8 = 0;
    ram_38f9 = 0;
}
