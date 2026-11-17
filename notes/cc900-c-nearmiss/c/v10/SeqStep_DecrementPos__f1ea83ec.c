/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_17m236b.c (2026-11-16-118-p6-r23)
   sha256 f1ea83ec20e8c44a2de5a0f6c3be7c330b41c15f78f837d98d74f707d6166fde (tar-sha256); compiled at -O3 -XS -Xr */
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
        w--;
        ram_2720 = w;
        ram_2726 = ram_273c;
    } else {
        r = PartCtrl_ReadWord_Off1(ram_273c);
        if (r == 0) return;
        ram_2726 = r;
        ram_2720 = 0xff;
    }
    ram_2662 = 1;
}
