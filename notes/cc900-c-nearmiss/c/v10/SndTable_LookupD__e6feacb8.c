/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_12m241a.c (2026-11-16-88-p6-r16)
   sha256 e6feacb88466fb87fc77f3999e214299ee74b8a6c8b3ac01d4158291ff800bcd (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ram_3e3ec;
extern unsigned int ram_23580;
extern unsigned char ram_2358a;
extern unsigned char *ram_3e3ee;
extern unsigned char ram_22d72[];
extern unsigned char SndTable_LookupD_CalcAddr(void);
extern void Kernel_StartTask(int task);
int SndTable_LookupD(void)
{
    ram_3e3ec = 1;
    ram_23580 = 0;
    ram_2358a = 1;
    ram_3e3ee = ram_22d72;
    if (SndTable_LookupD_CalcAddr() != 0) {
        ram_2358a = 2;
        ram_3e3ec = 0;
        return -1;
    }
    Kernel_StartTask(2);
    return 0;
}
