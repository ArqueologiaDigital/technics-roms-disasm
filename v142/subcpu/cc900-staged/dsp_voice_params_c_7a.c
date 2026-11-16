/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41368[];
extern unsigned char *WaveSel_StageA2_FromToneRec();

/* cc900-module: WaveSel_StageA2_FromToneRec */
void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e)
{
    *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + a * 0x11f)
                                                         + ((int)c * 37 + (int)e * 4)))[118] =
        WaveSel_StageA2_FromToneRec(a, c, e);
}
