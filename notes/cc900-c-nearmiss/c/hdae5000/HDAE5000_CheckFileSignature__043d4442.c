/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_fdsong_sig.c (2026-11-16-121-hd-r32-staged)
   sha256 043d4442539f942c4d5509a6c213994ea1ed2a0c7f265c3fad8d8a115b11edb4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: CFS_e=HDAE5000_CheckFileSignature */
extern int __cdecl HDAE5000_StrNCmp(char *, char *, int);
struct PartSig { char *sig; unsigned int offset; unsigned int len; };
extern struct PartSig HDAE5000_PartSignatureTable[];
int CFS_e(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + HDAE5000_PartSignatureTable[part].offset),
                         HDAE5000_PartSignatureTable[part].len) == 0)
        r = 0;
    else
        r = -1;
    return r;
}
