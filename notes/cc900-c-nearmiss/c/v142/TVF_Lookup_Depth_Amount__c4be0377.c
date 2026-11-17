/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
extern int __near ram_2940;
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int hi, lo, n;
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
