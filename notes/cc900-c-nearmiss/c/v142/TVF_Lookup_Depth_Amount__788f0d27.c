/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3b.c (2026-11-16-58-sub-r3)
   sha256 788f0d271359aef4ace536ce58c994c054403ce241712b29d2f7e0b99f5470cf (name+funcs); compiled at -Xr */
extern int __near ram_2940;
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int n, hi, lo;
    n = a & 0xf;
    if (a & 0x80) {
        hi = (unsigned int)TVF_DepthRecords_B[n][1] << 8;
        lo = TVF_DepthRecords_B[n][0];
        ram_2940 = (char)TVF_DepthRecords_B[n][2];
    } else {
        hi = (unsigned int)TVF_DepthRecords_A[n][1] << 8;
        lo = TVF_DepthRecords_A[n][0];
        ram_2940 = (char)TVF_DepthRecords_A[n][2];
    }
    return hi | lo;
}
