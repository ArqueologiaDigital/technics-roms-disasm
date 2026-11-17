/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

/* cc900-module: Voice_InterpolatePanCurve */
int Voice_InterpolatePanCurve(unsigned char *p, unsigned char *q)
{
    int h, r;
    h = (*(int *)(p + 8) & 0x7f00) >> 8;
    if (h < q[30]) {
        if (h < q[31]) r = -512;
        else r = ((int)q[30] - h) * -64 / (q[30] - (int)q[31]);
    } else if (h > q[32]) {
        if (h > q[33]) r = -512;
        else r = (h - (int)q[32]) * -64 / (q[33] - (int)q[32]);
    } else r = 0;
    return r;
}
