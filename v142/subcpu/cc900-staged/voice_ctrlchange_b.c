/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);

unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a)
{
    unsigned int r;
    r = ((a >> 8) & 0xf) * 81;
    r += ((a >> 4) & 0xf) * 9;
    r += a & 0xf;
    return r;
}
