/* Functions of core/09_dsp_algo_select.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41350[];
extern void VoiceParam_FullSetup(int);
extern void WaveSel_Rebuild_PartCaches(int, int, int);
extern void DSP_AdjustVoiceParams(unsigned char *);
extern void DSP_WriteAlgoBuffer(int, int);
extern void DSP_VoiceState_Dispatch(int, int);

/* cc900-module: DSP_AdjustVoiceParams VoiceParam_FullSetup */
int DSP_AlgoSelect(unsigned char part, unsigned int algo, unsigned char *err)
{
    unsigned char *rec;
    if (algo < 40) {
        rec = &ram_41350[part * 0x11f];
        if (!(*(unsigned int *)rec & 1)) {
            *(unsigned int *)rec |= 1;
            VoiceParam_FullSetup(part);
            WaveSel_Rebuild_PartCaches(part, rec[25], rec[26]);
        }
        if (*(unsigned int *)rec & 1) DSP_AdjustVoiceParams(rec);
        DSP_WriteAlgoBuffer(part, algo);
        DSP_VoiceState_Dispatch(0xff, 0xff);
        *err = 0;
    } else *err = 2;
    return 1;
}
