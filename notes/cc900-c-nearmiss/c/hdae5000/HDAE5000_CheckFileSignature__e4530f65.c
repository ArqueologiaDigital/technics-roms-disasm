/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_uigv.c (2026-11-16-119-hd-r30)
   sha256 e4530f65589667a0958c400294d464ae2886a650d8ee595f804a16717168f939 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: CFS_a=HDAE5000_CheckFileSignature */
extern int __cdecl HDAE5000_StrNCmp(char *, char *, int);
struct PartSig { char *sig; unsigned int offset; unsigned int len; };
extern struct PartSig HDAE5000_PartSignatureTable[];
extern unsigned char HDAE5000_PartSignatureTable_FileOffset[];
extern unsigned char HDAE5000_PartSignatureTable_Length[];
#define OFS_SYM HDAE5000_PartSignatureTable_FileOffset
#define LEN_SYM HDAE5000_PartSignatureTable_Length
int CFS_a(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + *(unsigned int *)(OFS_SYM + (unsigned long)part * 8)),
                         *(unsigned int *)(LEN_SYM + (unsigned long)part * 8)) == 0)
        r = 0;
    else
        r = -1;
    return r;
}
