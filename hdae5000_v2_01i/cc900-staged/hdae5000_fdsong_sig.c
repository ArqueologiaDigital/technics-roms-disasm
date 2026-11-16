/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_fdsong_sig.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_fdsong_sig.c.
   cc900-options: -Xr
   cc900-name: CFS_e=HDAE5000_CheckFileSignature
*/
extern int __cdecl HDAE5000_StrNCmp(char *, char *, int);

struct PartSig { char *sig; unsigned int offset; unsigned int len; };
struct Row8 { unsigned int v; unsigned char pad[6]; };
extern struct PartSig HDAE5000_PartSignatureTable[];
extern unsigned char HDAE5000_PartSignatureTable_FileOffset[];
extern unsigned char HDAE5000_PartSignatureTable_Length[];
/* the same two addresses as arrays of 8-byte rows (0x2f8e24, 0x2f8e26), for CFS_d */
extern struct Row8 ram_2f8e24[];
extern struct Row8 ram_2f8e26[];

#define OFS_SYM HDAE5000_PartSignatureTable_FileOffset
#define LEN_SYM HDAE5000_PartSignatureTable_Length

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
