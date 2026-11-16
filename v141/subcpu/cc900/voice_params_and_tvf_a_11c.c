/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void OutputBuf_Flush_A(unsigned char **pp, unsigned char *head, unsigned char key, char all)
{
    unsigned char *n;
    if (head != 0) {
        n = head;
        do {
            if (all != 0 || n[35] == key) {
                **pp = n[36];
                *pp += 1;
            }
            n = (*(unsigned char **)((n) + (8)));
        } while (n != head);
    }
    **pp = 0xff;
}
