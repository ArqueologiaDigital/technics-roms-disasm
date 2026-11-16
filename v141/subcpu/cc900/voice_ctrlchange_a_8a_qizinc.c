/* Functions of core/07_voice_ctrlchange.s.
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
extern unsigned char ram_4145a[];
extern unsigned char ram_4145b[];
extern unsigned char ram_4145c[];
extern unsigned char ram_4145d[];
void Voice_UpdateFlagsFromSlot(int part);
void Voice_Selector_ComputeMixWeights(int part);
void Voice_Artic_SetWord0Word2_Nibble2(unsigned char part, unsigned char b);
void Voice_Artic_SetWord1Nibble2_And_Word3(unsigned char part, unsigned char b);
void Voice_Artic_SetWord2Word1_Nibble0(unsigned char part, unsigned char b);
void Voice_Artic_SetW2W1_Nibble1(unsigned char part, unsigned char b);
void Voice_InitFromSlot(unsigned char part);
void Voice_SetArticWord0_LowByte(unsigned char part, unsigned char b);

/* cc900-name: Voice_Artic_SetW2W1_Nibble1=Voice_Artic_SetWord2Word1_Nibble1 */
/* cc900-module: Voice_Selector_ComputeMixWeights Voice_UpdateFlagsFromSlot */












void Voice_PerVoice_PortaPitchUpd(int n);

/* cc900-name: Voice_PerVoice_PortaPitchUpd=Voice_PerVoice_PortamentoPitchUpdate */
/* cc900-module: Voice_PerVoice_PortamentoPitchUpdate */
void Voice_AllVoices_PortamentoUpdate(void)
{
    unsigned char i;
    for (i = 0; i < 0x1a; i++) Voice_PerVoice_PortaPitchUpd(i);
}
