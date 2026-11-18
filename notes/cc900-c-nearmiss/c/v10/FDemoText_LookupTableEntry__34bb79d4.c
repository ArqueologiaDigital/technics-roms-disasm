/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_1b.c (2026-11-18-12-p6-r35)
   sha256 34bb79d4d896ff2449eeb0db14b3b364d4910a57ff4ea715cfc91a9bfb82f6ad (tar-sha256); compiled at -O3 -Xr */
typedef unsigned char *ucp;
extern ucp *__near PART_RECORD_PTRS;
unsigned char *FDemoText_LookupTableEntry(unsigned char ch)
{
    return *(ucp *)((char *)PART_RECORD_PTRS + ((int)ch << 2));
}
