/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3b.c (2026-11-16-37-p6-r5)
   sha256 412474a4bcb1b07706b807e204b3c008566145fa8f25b4beb61a0e0ac464ffd3 (tar-sha256); compiled at -Xr
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
    p = p + n;
    x->end = p;
    x->size = n;
}
