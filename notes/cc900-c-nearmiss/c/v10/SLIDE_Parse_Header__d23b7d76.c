/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m4b.c (2026-11-22-23-p6-r90)
   sha256 d23b7d76f2742454fcc72d159f1b42da575124e5295f193b79fa13a495aa0582 (tar-sha256); compiled at -O3 -Xr */
extern int __cdecl String_Compare(void *, void *, int);
extern void SLIDE_Decompress_4K_Init(unsigned char *, void *);
extern void SLIDE_Decompress_8K_Init(unsigned char *, void *);
int SLIDE_Parse_Header(register unsigned char *p, void *dst)
{
    char sig[6] = "SLIDE";

    if (String_Compare(p, sig, 5) != 0)
        return -1;
    p += 5;
    if (*p == '4')
        SLIDE_Decompress_4K_Init(p += 2, dst);
    else if (*p == '8')
        SLIDE_Decompress_8K_Init(p += 2, dst);
    return 0;
}
