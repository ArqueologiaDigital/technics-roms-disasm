/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m4a.c (2026-11-22-23-p6-r90)
   sha256 332bc108f1126bbb7b69f85f1521f6afde7103c7520657d7bd7e187e905ab893 (tar-sha256); compiled at -O3 -Xr */
extern int __cdecl String_Compare(void *, void *, int);
extern void SLIDE_Decompress_4K_Init(unsigned char *, void *);
extern void SLIDE_Decompress_8K_Init(unsigned char *, void *);
int SLIDE_Parse_Header(register unsigned char *p, void *dst)
{
    char sig[6] = "SLIDE";

    if (String_Compare(p, sig, 5) == 0) {
        p += 5;
        if (*p == '4') {
            p += 2;
            SLIDE_Decompress_4K_Init(p, dst);
        } else if (*p == '8') {
            p += 2;
            SLIDE_Decompress_8K_Init(p, dst);
        }
        return 0;
    }
    return -1;
}
