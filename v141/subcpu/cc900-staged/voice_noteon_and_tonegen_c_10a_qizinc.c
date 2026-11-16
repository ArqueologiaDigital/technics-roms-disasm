/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): V4.23 increments a byte of QIZ (inc 0x1,QIZH / QIZL), which the build's translation does not write as llvm-mc's inc1b_erp yet.
*/

extern unsigned char ram_41350[];
extern unsigned char *ram_45304;
extern unsigned char *ToneDB_RootPtr;
extern unsigned char *ToneDB_RelBase;
struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };
struct e16 { unsigned char pad[14]; unsigned char a; unsigned char b; };
extern void VoiceSubSlot_Init();
extern void WaveSel_Cache_SetDescPtr();
extern void CustomTone_CopySubUnitRecord();
void CustomTone_Apply_Catalog8C(unsigned int idx, unsigned char c);
void SubSlot_Apply_Catalog50(unsigned char part, unsigned int idx, unsigned char sel);

/* cc900-name: SubSlot_Apply_Catalog50=VoiceParam_SubSlot_Apply_Catalog50 */
/* cc900-name: CustomTone_Apply_Catalog8C=VoiceParam_CustomTone_Apply_Catalog8C */
/* cc900-module: CustomTone_CopySubUnitRecord VoiceSubSlot_Init */


void SubSlot_Apply_Catalog50(unsigned char part, unsigned int idx, unsigned char sel)
{
    struct e16 *tbl;
    unsigned char j;
    unsigned char k;
    tbl = (struct e16 *)((unsigned long)ToneDB_RelBase + *(long *)(ToneDB_RootPtr + 80));
    k = sel;
    k &= 15;
    (*(unsigned char **)((struct partrec *)(ram_41350 + part * 0x11f))->partial[k])[2] = tbl[idx].a;
    (*(unsigned char **)((struct partrec *)(ram_41350 + part * 0x11f))->partial[k])[3] = tbl[idx].b;
    VoiceSubSlot_Init(part, k);
    for (j = 0; j < 4; j++) WaveSel_Cache_SetDescPtr(part, k, j);
}
