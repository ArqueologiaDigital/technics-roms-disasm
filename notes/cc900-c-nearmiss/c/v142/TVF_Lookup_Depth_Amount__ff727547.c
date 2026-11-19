/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_41c.c (2026-11-19-95-sub-r41r)
   sha256 ff727547f1a611bd0c20c3a970636b76e667cab61d501a927a202746ad8de4fc (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern int __near ram_2940;
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int n;
    register unsigned int hi;
    unsigned int lo;
    n = a & 0xf;
    if (a & 0x80) {
        hi = *(unsigned char *)((unsigned long)&TVF_DepthRecords_B[0][1] + (unsigned long)n * 3);
        hi <<= 8;
        lo = TVF_DepthRecords_B[n][0];
        ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_B[0][2] + (unsigned long)n * 3);
    } else {
        hi = *(unsigned char *)((unsigned long)&TVF_DepthRecords_A[0][1] + (unsigned long)n * 3);
        hi <<= 8;
        lo = TVF_DepthRecords_A[n][0];
        ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_A[0][2] + (unsigned long)n * 3);
    }
    return hi | lo;
}
