/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4131c[];
extern unsigned char ram_41426[];
extern unsigned char ram_41427[];
extern unsigned char ram_41428[];
extern unsigned char ram_41429[];
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
void Voice_Artic_SetWord0Word2_Nibble2(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_4131c[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (0))) &= 0xf0ff;
    (*(unsigned int *)((q) + (0))) |= (unsigned int)(b & 0xf) << 8;
    (*(unsigned int *)((q) + (4))) &= 0xf0ff;
    b &= 0xf0;
    (*(unsigned int *)((q) + (4))) |= (unsigned int)b << 4;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}

void Voice_Artic_SetWord1Nibble2_And_Word3(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_4131c[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (2))) &= 0xf0ff;
    (*(unsigned int *)((q) + (2))) |= (unsigned int)(b & 0xf) << 8;
    b >>= 4;
    (*(unsigned int *)((q) + (6))) = b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}

void Voice_Artic_SetWord2Word1_Nibble0(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_4131c[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (4))) &= 0xfff0;
    (*(unsigned int *)((q) + (4))) |= b & 0xf;
    (*(unsigned int *)((q) + (2))) &= 0xfff0;
    b >>= 4;
    (*(unsigned int *)((q) + (2))) |= b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}

void Voice_Artic_SetW2W1_Nibble1(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_4131c[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (4))) &= 0xff0f;
    (*(unsigned int *)((q) + (4))) |= (unsigned char)(b << 4);
    (*(unsigned int *)((q) + (2))) &= 0xff0f;
    b &= 0xf0;
    (*(unsigned int *)((q) + (2))) |= b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}

void Voice_InitFromSlot(unsigned char part)
{
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
    ram_41426[(int)part * 287] = 0;
    ram_41427[(int)part * 287] = 0;
    ram_41428[(int)part * 287] = 0;
    ram_41429[(int)part * 287] = 0;
}

void Voice_SetArticWord0_LowByte(unsigned char part, unsigned char b)
{
    unsigned char *q;
    q = &ram_4131c[(int)part * 287];
    q += 258;
    (*(unsigned int *)((q) + (0))) &= 0xff00;
    (*(unsigned int *)((q) + (0))) |= b;
    Voice_UpdateFlagsFromSlot(part);
    Voice_Selector_ComputeMixWeights(part);
}

void Voice_PerVoice_PortaPitchUpd(int n);

/* cc900-name: Voice_PerVoice_PortaPitchUpd=Voice_PerVoice_PortamentoPitchUpdate */
/* cc900-module: Voice_PerVoice_PortamentoPitchUpdate */

