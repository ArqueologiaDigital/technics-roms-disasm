/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, int e);
void Voice_Selector_FindBestSlot(unsigned int *w, unsigned char *cnt, unsigned char *idx, unsigned char *val);

/* cc900-module: Voice_Selector_FindBestSlot Voice_Selector_Unpack3Groups */
void Voice_Selector_FindBestSlot(unsigned int *w, unsigned char *cnt, unsigned char *idx, unsigned char *val)
{
    unsigned char g[10];
    unsigned char d, lo, hi;
    Voice_Selector_Unpack3Groups(g, w[0], 0);
    Voice_Selector_Unpack3Groups(g, w[1], 1);
    Voice_Selector_Unpack3Groups(g, w[2], 2);
    hi = 0xff;
    lo = 0xff;
    *cnt = 0;
    for (d = 0; d < 9; d++) {
        if (lo == 0xff && g[d] != 0) lo = d;
        if (g[d] >= 4) {
            (*cnt)++;
            if (hi == 0xff) hi = d;
        }
    }
    if (hi != 0xff) {
        *idx = hi;
        *val = g[hi];
    } else {
        *idx = lo;
        *val = g[lo];
    }
}
