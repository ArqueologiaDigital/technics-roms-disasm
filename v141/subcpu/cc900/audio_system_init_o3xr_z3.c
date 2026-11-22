/* Functions of core/02_audio_system_init.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's.  From probe sub_Z3_1a.c (lane_z3, feedback
   plan step Z3, the djnz pool; run 2026-11-22-35-sub-z3-r1): the djnz loop needs -O, which the payload's other C
   (-Xr) does not have, as for subcpu_data_tables_o3xr_e_8a.c.
   cc900-options: -O3 -Xr
*/

void DSP_FillMemWords(unsigned int *p, unsigned int v, unsigned int n)
{
    do
        *p++ = v;
    while (--n != 0);
}
