/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char *ram_452d0;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };

/* cc900-name: CustomTone_Apply_Catalog94=VoiceParam_CustomTone_Apply_Catalog94 */
void CustomTone_Apply_Catalog94(unsigned int idx, unsigned char c)
{
    unsigned char e;
    struct e16 *tbl;
    unsigned char *rec;
    unsigned char hi;
    e = ram_452d0[29351];
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 148));
    rec = &((unsigned char *)(unsigned long)(ram_452d0 + ((int)e * 80 + (int)(c & 15) * 11)))[19169];
    hi = (c & 0xf0) >> 4;
    rec[(int)hi * 2 + 3] = tbl[idx].a;
    ((unsigned char *)(unsigned long)(rec + ((int)hi * 2 + 3)))[1] = tbl[idx].b;
}
