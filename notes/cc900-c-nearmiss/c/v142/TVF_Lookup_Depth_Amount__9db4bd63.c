/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18b.c (2026-11-17-7-sub-r18)
   sha256 9db4bd630ae5363516e81e0b25f0380c9790ffacf02065aae572215e2138f5b7 (name+funcs); compiled at -Xr */
extern int __near ram_2940;
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int n;
    unsigned int hi;
    unsigned int lo;
    n = a & 0xf;
    if (a & 0x80) {
        hi = (unsigned int)*(unsigned char *)((unsigned long)&TVF_DepthRecords_B[0][1] + (unsigned long)n * 3) << 8;
        lo = TVF_DepthRecords_B[n][0];
        ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_B[0][2] + (unsigned long)n * 3);
    } else {
        hi = (unsigned int)*(unsigned char *)((unsigned long)&TVF_DepthRecords_A[0][1] + (unsigned long)n * 3) << 8;
        lo = TVF_DepthRecords_A[n][0];
        ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_A[0][2] + (unsigned long)n * 3);
    }
    hi |= lo;
    return hi;
}
