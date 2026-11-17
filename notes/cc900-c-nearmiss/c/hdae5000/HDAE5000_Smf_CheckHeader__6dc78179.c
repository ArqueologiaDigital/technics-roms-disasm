/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_smf_palette.c (2026-11-16-119-hd-r30)
   sha256 6dc78179bf2c17acaa3e5db30fc1ed94bb33af4e6f5287892b690031a722fb7e (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct SmfHdr { unsigned long magic; unsigned long len; unsigned int format; unsigned int tracks;
                unsigned int division; };
extern unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x);
extern unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x);
extern unsigned int HDAE5000_RAM_SmfFormat;
extern unsigned int HDAE5000_RAM_SmfTrackCount;
extern unsigned int HDAE5000_RAM_SmfDivision;
long HDAE5000_Smf_CheckHeader(struct SmfHdr *h)
{
    if (HDAE5000_Smf_SwapBytes32(h->magic) != 0x4d546864L)
        return -1;
    if (HDAE5000_Smf_SwapBytes32(h->len) != 6)
        return -2;
    HDAE5000_RAM_SmfFormat = HDAE5000_Smf_SwapBytes16(h->format);
    if (HDAE5000_RAM_SmfFormat > 1)
        return -3;
    HDAE5000_RAM_SmfTrackCount = HDAE5000_Smf_SwapBytes16(h->tracks);
    HDAE5000_RAM_SmfDivision = HDAE5000_Smf_SwapBytes16(h->division);
    if (HDAE5000_RAM_SmfDivision & 0x8000)
        return -4;
    return 0;
}
