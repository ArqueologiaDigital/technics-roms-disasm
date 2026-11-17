/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/seq_step_routines_m0.c (2026-11-16-122-p6-r24-staged)
   sha256 3dd8aca8f560561914256908aba0e4143618806f0153944af37cbad352d01a26 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
