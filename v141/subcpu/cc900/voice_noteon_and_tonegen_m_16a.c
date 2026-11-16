/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct crec { unsigned char b[80]; };
extern unsigned char *ram_45304;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_Resolve_NamedToneRecord();
extern void BlockCopy_Words_BC_to_HL();

/* cc900-module: BlockCopy_Words_BC_to_HL */
void CustomTone_CopyToneRecord(unsigned char a, unsigned char b, unsigned char e)
{
    BlockCopy_Words_BC_to_HL(ToneDB_Resolve_NamedToneRecord(a, b, e, 255), (struct crec *)(ram_45304 + ((int)e * 80 + 19111)),
                             *(unsigned int *)(ToneDB_RootPtr + 238));
}
