/* Functions of audio/audio_control_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PanelTlv_PayloadOfTag */   /* scripts/analysis/cc900/module_calls.py v10 */

typedef unsigned char *ucp;
extern unsigned int __near EXT_RECORD_OFFSET;
extern unsigned char __near PANEL_EVENT_QUEUE[];
extern unsigned char __near MIDI_MSG_STATUS;
extern unsigned char __near MIDI_MSG_DATA1;
extern unsigned char __near MIDI_MSG_DATA2;
extern unsigned char __near MIDI_MSG_DATA3;
extern ucp __near ram_906b;
extern unsigned char __near EXTDATA_TLV_OFFSET;
extern unsigned char __near EXTDATA_VALUE;
extern unsigned char __near EXTDATA_MASK;
extern unsigned char *PanelTlv_PayloadOfTag(unsigned int);
extern void SndParam_FetchSequencerParams(void);

void SndParam_FetchSequencerParams(void)
{
    MIDI_MSG_STATUS = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    ram_906b = PanelTlv_PayloadOfTag(MIDI_MSG_STATUS);
    EXTDATA_TLV_OFFSET = MIDI_MSG_DATA1 = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    EXTDATA_VALUE = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA2 = 0;
    EXTDATA_MASK = PANEL_EVENT_QUEUE[EXT_RECORD_OFFSET++];
    MIDI_MSG_DATA3 = 0;
}
