/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_4132b;
extern int Voice_Build_OutputLevel(unsigned char *, int);
int Voice_ApplyPortamento(unsigned char *v);

/* cc900-module: Voice_Build_OutputLevel */
int Voice_ApplyPortamento(unsigned char *v)
{
    int t;
    t = *(int *)(v + 13);
    if ((*(unsigned char **)(v + 23))[23] != 0) t += (int)(*(unsigned char **)(v + 23))[23] - 100;
    else t -= 0x200;
    t += (*(char **)(v + 39))[34];
    if (ram_4132b & 2) {
        if (v[4] <= 1) {
            t -= *(int *)(*(unsigned char **)(v + 35) + 16);
            t -= 8;
        } else t -= 0x10;
    }
    return Voice_Build_OutputLevel(v, t);
}
