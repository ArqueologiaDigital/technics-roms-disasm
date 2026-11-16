/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_Demote_Decayed(unsigned char *p);
void Voice_Reprioritise(unsigned char *p);

/* cc900-module: Voice_List_MoveToPool */
void Voice_Reprioritise(unsigned char *p)
{
    if (p[34] & 0x80) return;
    if (p[37] < 0x80) Voice_Demote_Decayed(p);
    else if (p[34] & 8) {
        p[34] &= ~8;
        p[34] |= 4;
        Voice_List_MoveToPool(p, (*(unsigned char **)((p) + (29))), p[38]);
    }
}
