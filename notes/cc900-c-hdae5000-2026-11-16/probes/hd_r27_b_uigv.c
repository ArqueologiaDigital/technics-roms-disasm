/* hd_r27_b_uigv.c (helper h_r27b, lane_hd round 27): named variants of HDAE5000_CheckFileSignature alone (its
   caller FdSong_CheckFiles is in hd_r27_b_uig.c, whose own CheckFileSignature is the spelling thought likeliest:
   `*(unsigned int *)(&Table_Length[0] + (unsigned long)part * 8)`).
   The ROM, per field: `ld de,wa; extz xde; sll xde,3; lda xhl,(HDAE5000_PartSignatureTable_Length:24); add
   xhl,xde; ld de,(xhl)`: the index scaled in place, the base in a fresh register.  Run 102's integer sum copied
   the index before the shift and loaded the base into the index's old register.  The rest of the function matched
   in run 102 (int length parameter, one exit through r, `const unsigned char *buf`), so every variant keeps it.
   - CFS_a: pointer + long, array name without &..[0]: `Table_Length + (unsigned long)part * 8`
   - CFS_b: pointer + long with a shift: `&Table_Length[0] + ((unsigned long)part << 3)`
   - CFS_c: array indexing with a long index: `&Table_Length[(unsigned long)part * 8]`
   - CFS_d: the fields as arrays of 8-byte rows (struct with the word first): `LenRows[part].v` (implicit scale)
   - CFS_e: the natural struct members, `HDAE5000_PartSignatureTable[part].len` / `.offset`
   - CFS_f: integer sum with the index on the LEFT: `(unsigned long)part * 8 + (unsigned long)&Table_Length[0]`
   - CFS_g: pointer + long, unsigned int pointer cast first: `*(unsigned int *)((char *)Table_Length + part * 8L)`
     (the multiplication's int operand converted implicitly, not by a cast)
   - CFS_h: pointer to 8-byte rows from an integer address:
     `((struct Row8 *)(unsigned long)&Table_Length[0])[part].v`
   cc900-options: -Xr
   cc900-name: CFS_a=HDAE5000_CheckFileSignature
   cc900-name: CFS_b=HDAE5000_CheckFileSignature
   cc900-name: CFS_c=HDAE5000_CheckFileSignature
   cc900-name: CFS_d=HDAE5000_CheckFileSignature
   cc900-name: CFS_e=HDAE5000_CheckFileSignature
   cc900-name: CFS_f=HDAE5000_CheckFileSignature
   cc900-name: CFS_g=HDAE5000_CheckFileSignature
   cc900-name: CFS_h=HDAE5000_CheckFileSignature
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

int CFS_b(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + *(unsigned int *)(&OFS_SYM[0] + ((unsigned long)part << 3))),
                         *(unsigned int *)(&LEN_SYM[0] + ((unsigned long)part << 3))) == 0)
        r = 0;
    else
        r = -1;
    return r;
}

int CFS_c(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + *(unsigned int *)&OFS_SYM[(unsigned long)part * 8]),
                         *(unsigned int *)&LEN_SYM[(unsigned long)part * 8]) == 0)
        r = 0;
    else
        r = -1;
    return r;
}

int CFS_d(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + ram_2f8e24[part].v),
                         ram_2f8e26[part].v) == 0)
        r = 0;
    else
        r = -1;
    return r;
}

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

int CFS_f(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + *(unsigned int *)((unsigned long)part * 8 + (unsigned long)&OFS_SYM[0])),
                         *(unsigned int *)((unsigned long)part * 8 + (unsigned long)&LEN_SYM[0])) == 0)
        r = 0;
    else
        r = -1;
    return r;
}

int CFS_g(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + *(unsigned int *)((char *)OFS_SYM + part * 8L)),
                         *(unsigned int *)((char *)LEN_SYM + part * 8L)) == 0)
        r = 0;
    else
        r = -1;
    return r;
}

int CFS_h(unsigned int part, const unsigned char *buf)
{
    int r;
    if (HDAE5000_StrNCmp(HDAE5000_PartSignatureTable[part].sig,
                         (char *)(buf + ((struct Row8 *)(unsigned long)&OFS_SYM[0])[part].v),
                         ((struct Row8 *)(unsigned long)&LEN_SYM[0])[part].v) == 0)
        r = 0;
    else
        r = -1;
    return r;
}
