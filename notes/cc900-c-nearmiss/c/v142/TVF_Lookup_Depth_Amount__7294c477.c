/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_41b.c (2026-11-19-95-sub-r41r)
   sha256 7294c4771cbaf6a2898d5aa773f481a1fb646d2b0f62a4beec63b24a781e052a (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern int __near ram_2940;
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned char lo;
    unsigned int hi;
    {
        unsigned int n;
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
    }
    return hi | lo;
}
