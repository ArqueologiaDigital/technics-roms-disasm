/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/seq_step_routines_m0.c (2026-11-16-122-p6-r24-staged)
   sha256 2fca87e7b2a8ea4c2df09179e2f1db0047f4bdb33a8347c808105663cfcad87e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ram_2722;
extern unsigned int __near ram_2724;
extern unsigned char __near ram_2706;
extern unsigned int __near ram_270c;
extern unsigned char __near ram_2648;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
void SeqStep_DecrementPos(void)
{
    unsigned int w, r;
    w = ram_2724;
    if (w != 5) {
        w--;
        ram_2706 = w;
        ram_270c = ram_2722;
    } else {
        r = PartCtrl_ReadWord_Off1(ram_2722);
        if (r == 0) return;
        ram_270c = r;
        ram_2706 = 0xff;
    }
    ram_2648 = 1;
}
