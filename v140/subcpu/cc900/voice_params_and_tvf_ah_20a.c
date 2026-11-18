/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41389[];
extern unsigned char ram_41333[];
extern unsigned char ram_412ff;
void Voice_ScanSlots_ReassignSources(unsigned char a);
unsigned char BitTest_Bit0_L(unsigned char a);
unsigned char BitTest_Mode2_L(unsigned char a);
unsigned char BitTest_Bit0_L_v2(unsigned char a);
unsigned char BitTest_Mode2_L_v2(unsigned char a);
void Instrument_LookupProgram_HiNibble(unsigned char part);
void Instrument_LookupProgram_LoNibble(unsigned char part);
void Voice_Env_ApplyVelocity_Type0(unsigned char a, unsigned char c);
unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c);

/* cc900-module: BitTest_Bit0_L BitTest_Bit0_L_v2 BitTest_Mode2_L BitTest_Mode2_L_v2 Instrument_LookupProgram_HiNibble Instrument_LookupProgram_LoNibble Voice_ScanSlots_ReassignSources */
void Voice_Env_ApplyVelocity_Type0(unsigned char a, unsigned char c)
{
    unsigned char r;
    ram_41389[a * 0x11f] = 0;
    switch (a) {
    case 0:
    case 1:
        switch (c) {
        case 0:
            if (ram_412ff & 8) r = 0;
            else r = BitTest_Bit0_L(ram_412ff);
            break;
        case 1:
            if (ram_412ff & 8) r = 0;
            else r = BitTest_Mode2_L(ram_412ff);
            break;
        case 2:
            if (ram_41333[a * 0x11f] & 8) r = 0;
            else r = BitTest_Bit0_L_v2(ram_41333[a * 0x11f]);
            break;
        case 3:
            if (ram_41333[a * 0x11f] & 8) r = 0;
            else r = BitTest_Mode2_L_v2(ram_41333[a * 0x11f]);
            break;
        default:
            r = 0;
            break;
        }
        if (r != 0) Instrument_LookupProgram_HiNibble(a);
        break;
    case 2:
        switch (c) {
        case 0:
            if (ram_412ff & 0x10) r = 0;
            else r = BitTest_Bit0_L(ram_412ff);
            break;
        case 1:
            if (ram_412ff & 0x10) r = 0;
            else r = BitTest_Mode2_L(ram_412ff);
            break;
        case 2:
            if (ram_41333[a * 0x11f] & 0x10) r = 0;
            else r = BitTest_Bit0_L_v2(ram_41333[a * 0x11f]);
            break;
        case 3:
            if (ram_41333[a * 0x11f] & 0x10) r = 0;
            else r = BitTest_Mode2_L_v2(ram_41333[a * 0x11f]);
            break;
        default:
            r = 0;
            break;
        }
        if (r != 0) Instrument_LookupProgram_LoNibble(a);
        break;
    }
}

unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c)
{
    c &= 0x3f;
    if (a >= 0x40) return (unsigned int)c << 8 | 0xff;
    Voice_ScanSlots_ReassignSources(a);
    return (unsigned int)c << 8 | 0xff;
}
