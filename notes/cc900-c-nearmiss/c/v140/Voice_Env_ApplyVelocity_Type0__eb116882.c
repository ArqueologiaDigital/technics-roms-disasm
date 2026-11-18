/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_params_and_tvf_ah_20a.c (2026-11-18-19-sub-r21b-staged)
   sha256 eb116882d5a5f867232e9abfe14da45eee1a8a4278fbb0ea6d23d773758afb3d (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_41389[];
extern unsigned char ram_41333[];
extern unsigned char ram_412ff;
unsigned char BitTest_Bit0_L(unsigned char a);
unsigned char BitTest_Mode2_L(unsigned char a);
unsigned char BitTest_Bit0_L_v2(unsigned char a);
unsigned char BitTest_Mode2_L_v2(unsigned char a);
void Instrument_LookupProgram_HiNibble(unsigned char part);
void Instrument_LookupProgram_LoNibble(unsigned char part);
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
