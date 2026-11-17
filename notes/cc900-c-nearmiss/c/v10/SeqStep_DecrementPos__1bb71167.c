/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_17m236a.c (2026-11-16-118-p6-r23)
   sha256 1bb71167958e2844f2c7cb58de5a64ee319b1a4b8c75e09ec003eec5b5fd3dd3 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern unsigned char __near ram_2720;
extern unsigned int __near ram_2726;
extern unsigned char __near ram_2662;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
void SeqStep_DecrementPos(void)
{
    unsigned int w, r;
    w = ram_273e;
    if (w != 5) {
        ram_2720 = w - 1;
        ram_2726 = ram_273c;
    } else {
        r = PartCtrl_ReadWord_Off1(ram_273c);
        if (r == 0) return;
        ram_2726 = r;
        ram_2720 = 0xff;
    }
    ram_2662 = 1;
}
