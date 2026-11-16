/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41322[];
extern unsigned char ram_41382[];
extern void Voice_CC_SetSostenutoFlag(int, int);
extern void AlgoType_StateWrite(int, int);
extern void VoiceAlloc_WithRoutingFlag(int, int);
extern void Partial_Build_Present_Word(int);
extern void EnvTranspose_UpdateLoop(int);
extern void VoiceNoteParam_UpdateLoop(int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern unsigned char Voice_SecondaryParam_Epilogue(int);

/* cc900-module: Voice_CC_SetSostenutoFlag */
void Voice_Portamento_OnHandler(unsigned char part, unsigned char v)
{
    switch ((*(unsigned char **)&ram_41322[part * 0x11f])[16] & 0xc0) {
    case 0:
    case 0xc0:
        Voice_CC_SetSostenutoFlag(part, v);
        AlgoType_StateWrite(part, 1);
        VoiceAlloc_WithRoutingFlag(part, v);
        Partial_Build_Present_Word(part);
        EnvTranspose_UpdateLoop(part);
        VoiceNoteParam_UpdateLoop(part);
        Voice_ActiveFlag_CheckAndLoad(part);
        ram_41382[part * 0x11f] = Voice_SecondaryParam_Epilogue(part);
        break;
    case 0x40:
    case 0x80:
        break;
    }
}

extern unsigned int ram_412f7;
extern void Voice_Reset_Engine(int);
extern void VoiceSlot_ClearAll(void);
extern void Voice_PerVoice_PortaPitchUpd(int);

/* cc900-name: Voice_PerVoice_PortaPitchUpd=Voice_PerVoice_PortamentoPitchUpdate */
/* cc900-module: Voice_PerVoice_PortamentoPitchUpdate */
void Voice_SetPolyphonyMode(unsigned char m)
{
    unsigned char i;
    if (m == 1) {
        ram_412f7 |= 1;
        Voice_Reset_Engine(1);
    } else {
        ram_412f7 &= ~1;
        Voice_Reset_Engine(0);
    }
    VoiceSlot_ClearAll();
    for (i = 0; i <= 15; i++) Voice_PerVoice_PortaPitchUpd(i);
}
