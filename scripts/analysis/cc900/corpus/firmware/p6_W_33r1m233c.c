/* Probe round 33r1, helper W, form c: sequencer/sequencer_engine.s (module 233).
   Seq_DispatchVoiceConfigEvent(ev): with the mode (ram_1d92) and the position (ram_2326) copied to the frame,
   hand an 0x81 end mark to SeqVoice_HandleEndMark; in mode 1 reject a position before ram_232e (error 0x1e);
   note events 0x80 / 0x85 / 0x86 go to SeqVoice_ProcessAndAssign, controller events (0xbn) through
   SeqPart_CheckAndSetVoiceConfig (its result is the assign kind); then the event's track (byte count + 1) must be
   the selected track (mode 1) or armed (SEQ_REC_TRACKS), and the event is assigned with kind 6 (0xcn), 4 (0xd2) or
   3 (0xd0 / 0xd1 / 0xd3); 0x9n events go to SeqVoice_BufferSwapAndAssign.
   Plain frame scalars in declaration order (kind, mode, pos: +4 / +6 / +8); both switches written with their cases
   in reverse compare order; the final assign is an if / else with one call each. */
/* cc900-module: SeqPart_CheckAndSetVoiceConfig SeqVoice_BufferSwapAndAssign SeqVoice_HandleEndMark SeqVoice_ProcessAndAssign ToneVoice_AssignChannel VoiceConfig_FindChannelMatch */

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
extern unsigned char Seq_DispatchVoiceConfigEvent(unsigned char *ev);

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
    if (mode == 1) {
        VoiceConfig_FindChannelMatch(pos, ev[1]);
        ToneVoice_AssignChannel(0x12, ev, kind);
    } else
        ToneVoice_AssignChannel(t, ev, kind);
    return 0;
}
