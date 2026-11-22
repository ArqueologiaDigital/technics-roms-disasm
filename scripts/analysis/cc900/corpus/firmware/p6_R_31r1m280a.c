/* Probe round 31r1, helper R, form a: audio/audio_control_engine.s SndParam_FetchSequencerParams (module 280):
   read the next received 4-byte record of PANEL_EVENT_QUEUE into the MIDI message and the ExtData cells. */
/* cc900-module: PanelTlv_PayloadOfTag */

typedef unsigned char *ucp;
extern unsigned int __near EXT_RECORD_OFFSET;
extern unsigned char __near PANEL_EVENT_QUEUE[];
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near MIDI_MSG_DATA1;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern ucp __near ram_912b;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern void SndParam_FetchSequencerParams(void);

void SndParam_FetchSequencerParams(void)
{
    MIDI_MSG_STATUS = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    ram_912b = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
    EXTDATA_TLV_OFFSET = MIDI_MSG_DATA1 = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    EXTDATA_VALUE = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA2 = 0;
    EXTDATA_MASK = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA3 = 0;
}

/* The pair Audio_SendAfterTouchToParts / Audio_SendExpressionToParts: for every part tag of ram_90fb (0xff ends,
   at most 32), send a controller through MIDI_LoadParamsAndDispatchCC and record it with AddswbWr; the loop as in
   the built audio_control_engine_m0.c (ram_90fb walk). */
extern unsigned char __near ram_90fb[];
extern unsigned char __near ram_917e;
extern unsigned char __near ram_917f;
extern unsigned char __near ram_9180;
extern unsigned char __near ram_9181;
extern unsigned char __near PANEL_FOOT_CONTROLLERS[];
extern void MIDI_LoadParamsAndDispatchCC(void);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void Audio_SendAfterTouchToParts(unsigned char v, unsigned char m);
extern void Audio_SendExpressionToParts(unsigned char v);

void Audio_SendAfterTouchToParts(unsigned char v, unsigned char m)
{
    unsigned int i;
    unsigned char t;

    i = 0;
    do {
        t = ram_90fb[i];
        if (t == 255) break;
        if (t == 2 && m != 2) continue;
        if (PanelTlv_PayloadOfTag(t)[12] & 0x10) {
            ram_917e = 180;
            ram_917f = ram_90fb[i];
            ram_9180 = v;
            ram_9181 = 255;
            MIDI_LoadParamsAndDispatchCC();
            if (!(PanelTlv_PayloadOfTag(ram_90fb[i])[13] & 0x20))
                AddswbWr(ram_917e, ram_917f, ram_9180, ram_9181);
        }
    } while (++i < 32);
}

void Audio_SendExpressionToParts(unsigned char v)
{
    unsigned int i;
    unsigned char t;

    if (PANEL_FOOT_CONTROLLERS[2] == 183) {
        i = 0;
        do {
            t = ram_90fb[i];
            if (t == 255) break;
            if (PanelTlv_PayloadOfTag(t)[4] & 0x20) {
                ram_917e = 179;
                ram_917f = ram_90fb[i];
                ram_9180 = v;
                ram_9181 = 127;
                MIDI_LoadParamsAndDispatchCC();
                if (!(PanelTlv_PayloadOfTag(ram_90fb[i])[13] & 0x20))
                    AddswbWr(ram_917e, ram_917f, ram_9180, ram_9181);
            }
        } while (++i < 32);
    }
}
