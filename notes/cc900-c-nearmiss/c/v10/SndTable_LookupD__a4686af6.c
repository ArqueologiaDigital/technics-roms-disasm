/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m241b.c (2026-11-16-100-p6-r19)
   sha256 a4686af6e22fd617a2a889e0e53e693ebf6d32244325af9998df0e0dd04372e7 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ram_3e3ec;
extern unsigned int ram_23580;
extern unsigned char ram_2358a;
extern unsigned long ram_3e3ee;
extern unsigned char ram_22d72[];
extern unsigned char SndTable_LookupD_CalcAddr(void);
extern void Kernel_StartTask(int task);
int SndTable_LookupD(void)
{
    unsigned long p;
    ram_3e3ec = 1;
    ram_23580 = 0;
    ram_2358a = 1;
    p = (unsigned long)ram_22d72;
    ram_3e3ee = p;
    if (SndTable_LookupD_CalcAddr() != 0) {
        ram_2358a = 2;
        ram_3e3ec = 0;
        return -1;
    }
    Kernel_StartTask(2);
    return 0;
}
