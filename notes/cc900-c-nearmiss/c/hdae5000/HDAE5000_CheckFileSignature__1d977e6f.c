/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_uig.c (2026-11-16-119-hd-r30)
   sha256 1d977e6f09451c0f1fe510bf928eeaffc32a11f27381a4a8c5c2599eb125e26b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern int __cdecl HDAE5000_StrNCmp(char *, char *, int);
struct PartSig { char *sig; unsigned int offset; unsigned int len; };
extern struct PartSig HDAE5000_PartSignatureTable[];
extern unsigned char HDAE5000_PartSignatureTable_FileOffset[];
extern unsigned char HDAE5000_PartSignatureTable_Length[];
int HDAE5000_CheckFileSignature(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + *(unsigned int *)(&HDAE5000_PartSignatureTable_FileOffset[0] + (unsigned long)part * 8)),
                         *(unsigned int *)(&HDAE5000_PartSignatureTable_Length[0] + (unsigned long)part * 8)) == 0)
        r = 0;
    else
        r = -1;
    return r;
}
