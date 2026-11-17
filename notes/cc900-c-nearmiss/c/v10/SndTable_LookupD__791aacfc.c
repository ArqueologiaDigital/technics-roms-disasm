/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m241a.c (2026-11-16-100-p6-r19)
   sha256 791aacfcb7f3421ef35c9be7989bb5f9624d22c3c3a7a85f223c62d05482258a (tar-sha256); compiled at -O3 -Xr */
extern unsigned char ram_3e3ec;
extern unsigned int ram_23580;
extern unsigned char ram_2358a;
extern unsigned char *ram_3e3ee;
extern unsigned char ram_22d72[];
extern unsigned char SndTable_LookupD_CalcAddr(void);
extern void Kernel_StartTask(int task);
int SndTable_LookupD(void)
{
    unsigned char *p;
    ram_3e3ec = 1;
    ram_23580 = 0;
    ram_2358a = 1;
    p = ram_22d72;
    ram_3e3ee = p;
    if (SndTable_LookupD_CalcAddr() != 0) {
        ram_2358a = 2;
        ram_3e3ec = 0;
        return -1;
    }
    Kernel_StartTask(2);
    return 0;
}
