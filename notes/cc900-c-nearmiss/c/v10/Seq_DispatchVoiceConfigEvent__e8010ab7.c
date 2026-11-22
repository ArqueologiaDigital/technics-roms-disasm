/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_33r1m233d.c (2026-11-22-19-p6-r86)
   sha256 e8010ab7e077718defe7f4cf52e3b75809c582245eee6c546de81fde2bcb8f9d (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_1d92;
extern unsigned int __near ram_2326;
extern unsigned int __near ram_232e;
extern unsigned char __near ram_231a;
extern unsigned int __near SEQ_REC_TRACKS;
extern void SeqVoice_HandleEndMark(unsigned int, unsigned char *);
extern void SeqData_SetErrorCode(unsigned int);
extern void VoiceConfig_FindChannelMatch(unsigned int, unsigned int);
extern void SeqVoice_ProcessAndAssign(unsigned char *);
extern unsigned char SeqPart_CheckAndSetVoiceConfig(unsigned char *);
extern signed char SeqData_GetEventByteCount(unsigned char *);
extern void SeqVoice_BufferSwapAndAssign(unsigned int, unsigned char *);
extern void ToneVoice_AssignChannel(unsigned int, unsigned char *, unsigned int);
unsigned char Seq_DispatchVoiceConfigEvent(unsigned char *ev)
{
    unsigned char kind;
    unsigned char mode;
    unsigned int pos;
    signed char n;
    unsigned char t;

    mode = ram_1d92;
    pos = ram_2326;
    if (*ev == 0x81) {
        SeqVoice_HandleEndMark(mode, ev);
        return 0;
    }
    if (mode == 1 && pos < ram_232e) {
        SeqData_SetErrorCode(0x1e);
        return 0;
    }
    if (*ev == 0x80 || *ev == 0x85 || *ev == 0x86) {
        if (mode == 1)
            VoiceConfig_FindChannelMatch(pos, ev[1]);
        SeqVoice_ProcessAndAssign(ev);
        return 0;
    }
    if ((*ev & 0xf0) == 0xb0) {
        if (mode == 1)
            VoiceConfig_FindChannelMatch(pos, ev[1]);
        kind = SeqPart_CheckAndSetVoiceConfig(ev);
        if (kind == 0)
            return 0;
    }
    n = SeqData_GetEventByteCount(ev);
    if (n < 0)
        return 0xff;
    t = n + 1;
    if (mode == 1) {
        if (t != ram_231a)
            return 0;
    } else {
        if (((1 << (t - 1)) & SEQ_REC_TRACKS) == 0)
            return 0;
    }
    switch (*ev & 0xf0) {
    case 0x90:
        SeqVoice_BufferSwapAndAssign(mode, ev);
        return 0;
    case 0xc0:
        kind = 6;
        break;
    default:
        switch (*ev) {
        case 0xd0:
        case 0xd1:
        case 0xd3:
            kind = 3;
            break;
        case 0xd2:
            kind = 4;
            break;
        }
        break;
    }
    ToneVoice_AssignChannel(mode == 1 ? (VoiceConfig_FindChannelMatch(pos, ev[1]), 0x12) : t, ev, kind);
    return 0;
}
