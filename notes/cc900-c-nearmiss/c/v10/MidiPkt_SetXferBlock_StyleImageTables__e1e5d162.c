/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2a.c (2026-11-16-33-p6-r2)
   sha256 e1e5d1622a68bbc27489c801d6928dde38f9ceff8816827f2bfd0be724fc352c (tar-sha256); compiled at -Xr
   cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char ram_94860;
extern unsigned char ram_95bc0;
void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *x)
{
    unsigned char *p = &ram_94860;
    long n;
    x->start = p;
    n = &ram_95bc0 - p;
    p += n;
    x->end = p;
    x->size = n;
}
