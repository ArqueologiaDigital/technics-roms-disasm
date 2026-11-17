/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/accompaniment_engine.c (2026-11-16-36-p6-staged-r4)
   sha256 882f54cba9ade7fa21eb4a9c666de6b3c042df1ad5a1cb269c90e9c18028bd3e (tar-sha256); compiled at -Xr
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
