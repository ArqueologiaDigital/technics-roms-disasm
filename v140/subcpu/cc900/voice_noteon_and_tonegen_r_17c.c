/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_44f82[];
extern unsigned char *ram_452d0;
extern unsigned long *ToneDB_RootPtr;
extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned int *d, unsigned int n);
extern unsigned char *WaveSel_StageA1_FindVelSplit(int, int, int, int, int);
extern unsigned char *WaveSel_StageA1_FromPatchBlock();
void CustomTone_CopySubUnitRecord(unsigned char a, unsigned char b, unsigned char c, unsigned char d);
void VoiceSubSlot_Init(unsigned char a, unsigned char c);

/* cc900-module: BlockCopy_Words_BC_to_HL */
void CustomTone_CopySubUnitRecord(unsigned char a, unsigned char b, unsigned char c, unsigned char d)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FindVelSplit(a, b, c, d, 255),
                             (unsigned int *)&((unsigned char *)(unsigned long)(ram_452d0 + ((int)d * 80 + (int)a * 11)))[19169],
                             ((unsigned int *)ToneDB_RootPtr)[120]);
}

void VoiceSubSlot_Init(unsigned char a, unsigned char c)
{
    BlockCopy_Words_BC_to_HL(WaveSel_StageA1_FromPatchBlock(a, c),
                             ((unsigned int *)&ram_44f82[(int)(unsigned int)((int)c * 11 + 426)]),
                             ((unsigned int *)ToneDB_RootPtr)[117]);
}
