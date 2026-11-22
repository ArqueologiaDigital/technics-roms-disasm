/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m280b.c (2026-11-22-15-p6-r82)
   sha256 51699e9bc7c57ad8d0323a4379d0f019e3176866728dac17cea682e5e7eb34c0 (tar-sha256); compiled at -O3 -Xr */
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
void SndParam_FetchSequencerParams(void)
{
    MIDI_MSG_STATUS = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    ram_912b = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
    MIDI_MSG_DATA1 = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    EXTDATA_TLV_OFFSET = MIDI_MSG_DATA1;
    EXTDATA_VALUE = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA2 = 0;
    EXTDATA_MASK = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA3 = 0;
}
