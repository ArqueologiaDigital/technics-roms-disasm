; ram_variables.s -- main-CPU RAM variables named in the technics-docs pages, beyond the constants
; files (cpanel_constants.s, midi_encoder_constants.s).  The pages give v10's addresses; these are
; v7's, derived by scripts/tools/name_kn5000_ram.py from the same instructions in the same routines
; (a corrected line says so).  Names it could not derive for v7 are left out (RHYTHM_PATTERN_SEL_A,
; RHYTHM_PATTERN_TYPE, and the boot-serial rings and TCBs BOOTSERIAL_RX_TAIL ..
; BOOTSERIAL_TX_TCB, which no v10 instruction names).  Each line cites the page that establishes the variable.

; MainTitleControl (the title / mode object) -- EVT_CHANGE_MODE: `ldmm8 PREVIOUS_MODE, CURRENT_MODE / ld (CURRENT_MODE), l`;
; EVT_CHANGE_TITLE -> MainTitleCtrl_ChangeTitle: PREVIOUS_TITLE := CURRENT_TITLE, CURRENT_TITLE := l.  sequencer.md
; called 0x8D36 the "master sequencer state": its skip range 0x10-0x16 is exactly the TT_STYLCNV* titles
	.equ CURRENT_MODE,		0x8c7c	; the current mode id (NAKA_MODE_* - 0x1800000), set by EVT_CHANGE_MODE	; v7: 0x8c98
	.equ PREVIOUS_MODE,		0x8c7d	; the mode before the last EVT_CHANGE_MODE	; v7: 0x8c99
	.equ CURRENT_TITLE,		0x8c7e	; the current title id (TITLE_* - 0x1A00000); Seq_DispatcherTick skips while a style-conversion title (0x10-0x16) is current	; v7: 0x8c9a
; sequencer.md "Key RAM Addresses"
	.equ PREVIOUS_TITLE,		0x8c7f	; the title before the last EVT_CHANGE_TITLE	; v7: 0x8c9b
	.equ RHYTHM_VARIATION_INDEX,	0x33be	; variation index, 0..0x1E	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x3476	; v7: 0x33da
	.equ TAP_TEMPO_LAST_TAP_TIME,	0x33d6	; SYSTEM_TIMESTAMP of the last TAP TEMPO press: AccProcess_InlinedCode stores it, AccProcess_TimerCompare ends the tap sequence 0x400 ticks later (was RHYTHM_PATTERN_SEL_B)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x348e	; v7: 0x33f2
	.equ RHYTHM_PATTERN_BUF_A,	0x94800	; pattern buffer A, 1,024 bytes per pattern
	.equ RHYTHM_PATTERN_BUF_B,	0x95c00	; pattern buffer B (double buffer)
; memory-map.md "Medley State Variables"
	.equ MEDLEY_PLAY_FLAG,		0x8446	; 0 = stopped, 1 = playing	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x84fe	; v7: 0x8462
	.equ MEDLEY_ORDER_ARRAY,	0x87d8	; play order, 10 bytes; 0xFF = unused, 0xFE = marked	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8890	; v7: 0x87f4
	.equ MEDLEY_SONG_COUNT,		0x87e2	; songs in the current playlist	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x889a	; v7: 0x87fe
	.equ MEDLEY_CURRENT_INDEX,	0x87e4	; the song playing	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x889c	; v7: 0x8800
	.equ MEDLEY_REPEAT_FLAG,	0x87e6	; 0 = no repeat, 1 = repeat all	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x889e	; v7: 0x8802
; data-wheel-investigation.md "Key DRAM Addresses"
	.equ SWBTWR_EVENT_QUEUE,	0xbc7c	; SwbtWr main event queue, 4-byte events, 0xFF sentinel	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xbd3c	; v7: 0xbca0
	.equ SWBTWR_PAYLOAD_1,		0xbfbd	; payload byte 1 (0x21 identifies the data wheel)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xc07d	; v7: 0xbfe1
	.equ SWBTWR_PAYLOAD_2,		0xbfbe	; payload byte 2 (the signed detent count)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xc07e	; v7: 0xbfe2
	.equ SWBTWR_PAYLOAD_3,		0xbfbf	; payload byte 3	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xc07f	; v7: 0xbfe3
	.equ SWBTWR_EVENT_TYPE,		0xbfc0	; event type, written during dispatch	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xc080	; v7: 0xbfe4
; named from the writer census (python3 scripts/analysis/kn5000_ram_writers.py --tree v10 <addr>)
	.equ SEQ_ERROR_CODE,		0x285e	; sequencer-data error code: 0 = none; 1..11 / 255 set by the end-mark, overflow and bad-parameter paths (SeqData_HandleEndMark_SetError1, SeqBuf_PageOverflowError, Part_ValidateSetup_ErrorEnd ...); cleared before operations, tested against 0 after	; v7: 0x287a
	.equ GLOBAL_ERROR_CODE,		0x7e8a	; set by SetGlobalError and the error / status paths of disk, medley, drum-kit, password ... code (values 1..74, 255); compared against constants	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x7f42	; v7: 0x7ea6
; MidiSeq_SwapActiveBuffers exchanges (0xBCAC) with (0xBCB0) and (0xBC54) with (0xBC58): two
; active / spare pointer pairs (MidiChan_InitAllBufferPtrs sets them up)
	.equ MIDISEQ_ACTIVE_BUF_PTR,	0xbbec	; the active buffer; read at 220 sites	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xbcac	; v7: 0xbc10
	.equ MIDISEQ_SPARE_BUF_PTR,	0xbbf0	; the one MidiSeq_SwapActiveBuffers exchanges it with	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xbcb0	; v7: 0xbc14
	.equ MIDISEQ_ACTIVE_BLOCK_PTR,	0xbb94	; the second pair's active pointer (its +10 / +14 words are compared)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xbc54	; v7: 0xbbb8
	.equ MIDISEQ_SPARE_BLOCK_PTR,	0xbb98	; and its spare	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0xbc58	; v7: 0xbbbc
; the ACTIVE title: EVT_CHANGE_TITLE, EVT_RETURN_TITLE and EVT_INTERRUPT_TITLE all set it (`ldmm8
; ACTIVE_TITLE_PREVIOUS, ACTIVE_TITLE / ld (ACTIVE_TITLE), l`)
	.equ ACTIVE_TITLE,	0x8c80	; the title on screen: CURRENT_TITLE, or an interrupting / returned-to one	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8d38	; v7: 0x8c9c
	.equ ACTIVE_TITLE_PREVIOUS,	0x8c81	; its previous value, saved before each change	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8d39	; v7: 0x8c9d
; held panel switches, kept by SwbtB3_OnPanelEvent from the 0xA9 switch records: group N = payload byte 1
; (0..16), bit N of a mask = CtrlPanel_SwitchRowBit[N].  Payload bit 1 is the group's UP switch (switch
; number N), bit 0 its DOWN switch (N | 0x80; ES_Left1..5 are 0x88..0x8C).  MainTitleControl clears all three
; on every mode or title change, so a held switch is forgotten across screens.  (Named TRANSITION_PROGRESS /
; _TIMER / _FLAGS until 2026-10-31: nothing in the firmware animates a title change.)
	.equ PANEL_SW_HELD_UP,	0x2749a	; groups whose UP switch is held (set on press, cleared on release)
	.equ PANEL_SW_HELD_DOWN,	0x2749e	; groups whose DOWN switch is held
	.equ PANEL_SW_HELD_BOTH,	0x274a2	; PANEL_SW_HELD_UP & PANEL_SW_HELD_DOWN: 0x1100 -> CaptureLcd (version 0xff), 0xa1 -> TITLE_SOFTVER, 0x91 -> TITLE_PS, 0x89 -> EVT_SHOW to view 7
; MainTitleControl's delayed requests (MT_SetTitleFlag 0x01E000BA, MT_OtherPartLed 0x01E000AB): the handler
; stores the parameter and a count of 10; MT_MainLoopCount (0x01E000BB, once per main-loop pass) counts down
	.equ TITLE_FLAGS_LATCHED,	0x274a6	; title-flags word, copied from TITLE_FLAGS_PENDING when the count ends; read by CtrlPanel_GetSelectionState
	.equ TITLE_FLAGS_PENDING,	0x274a8	; the flags MT_SetTitleFlag last sent
	.equ TITLE_FLAGS_DELAY,	0x274aa	; passes left before TITLE_FLAGS_PENDING is latched
	.equ OTHER_PART_LED_PENDING,	0x274ac	; MT_OtherPartLed's request: non-zero = LED on (MainTitleCtrl_OnMainLoopCount sets bit 0 of a panel-state byte, 0x8f5c in v10)
	.equ OTHER_PART_LED_DELAY,	0x274ae	; passes left before the request is applied (CtrlPanel_SetIndicatorBit 0x60)
; the palette routine's header (ui/ui_window_procs.s) and UpdateScreen's (ui/ui_widget_defs.s)
	.equ PALETTE_DATA_PTR_CACHED,	0x3ef90	; current palette data pointer (cached)	; v7: 0x3ef94
	.equ PALETTE_INDEX_CACHED,	0x3ef9a	; current palette index (cached); a pending update is checked here	; v7: 0x3ef9e
	.equ PALETTE_UPDATE_FLAG,	0x30460	; set to 1 to trigger the VRAM palette update
	.equ DIRTY_BBOX,		0x30456	; dirty bounding box Gfx_BlitDirtyRegions examines
; ColorBlit / ColorBlit2 (ui/ui_window_procs.s): the caller's (0x3EFA8) is copied to (0x3EFAA) -- or
; into the deferred draw-queue entry -- and ColorBlit_Impl dispatches on (0x3EFAA): 2 -> ColorBlit_Mode2_Entry,
; 1 -> ColorBlit_Mode1_Entry, 0 -> the mode-0 path
	.equ COLORBLIT_MODE,		0x3efa4	; the blit mode the next ColorBlit uses, 0..2 (set by ~150 drawing sites)	; v7: 0x3efa8
	.equ FONTID_NAME_TABLE,	0x3efa8	; the font-name pointer list FontIDProc reads (RAM copy of FontIDProc_FontNameTable, made by Boot_InitWorkRAM; no code writes it after boot: notes/kn5000-a-2026-10-31/probes/fontid_table_writers.py)
	.equ COLORBLIT_MODE_ACTIVE,	0x3efa6	; the mode ColorBlit_Impl is running with	; v7: 0x3efaa
; FileIO_ReadBlockToBuffer stores FileIO_ReadBlock's result (it reads 0x400 bytes into 0x13FA) here; the
; 113 readers do `ld xwa,(this) / cp xwa,xbc / jr lt, ..._FileUnderflow` -- fewer bytes than they need.
; SMF_WriteByte also stores 2 here (not explained)
	.equ FILEIO_BLOCK_BYTES,	0x1a2d	; bytes the last block read returned (32-bit)
; custom-data-flash.md "Section Pointer Table": Flash_InitExtMemAddrs computes the eight section pointers
; of the Custom Data Flash (0x300000 + 0, 0x19800, 0x30000 ...) and stores them here; it also points
; RHYTHM_PATTERN_BUF_PTR at RHYTHM_PATTERN_BUF_A
	.equ FLASH_SECTION_PTR_0,	0x0c76	; section 0: custom accompaniment styles
	.equ FLASH_SECTION_PTR_1,	0x0c7a	; section 1: custom accompaniment styles
	.equ FLASH_SECTION_PTR_2,	0x0c7e	; section 2: custom accompaniment styles
	.equ FLASH_SECTION_PTR_3,	0x0c82	; section 3: custom accompaniment styles
	.equ FLASH_SECTION_PTR_4,	0x0c86	; section 4: custom accompaniment styles
	.equ FLASH_SECTION_PTR_5,	0x0c8a	; section 5: custom accompaniment styles
	.equ FLASH_SECTION_PTR_6,	0x0c8e	; section 6: custom accompaniment styles
	.equ FLASH_SECTION_PTR_7,	0x0c92	; section 7: sub-CPU performance data
	.equ RHYTHM_PATTERN_BUF_PTR,	0x0c6e	; set to RHYTHM_PATTERN_BUF_A by Flash_InitExtMemAddrs
; FDC state (fdc-subsystem.md "FDC Memory Map", taken only where the code agrees -- the page and
; reverse-engineering.md disagree about 0x8A2B-0x8A4A)
	.equ FDC_SECTOR_COUNT,		0x8964	; cleared per command, incremented per sector	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8a1c	; v7: 0x8980
	.equ FDC_ERROR_CODE,		0x896c	; cleared at command start, set by FDC_Set_Status; 32 compares	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8a24	; v7: 0x8988
	.equ FDC_TARGET_TRACK,		0x897e	; the caller's target track (fdc_routines.s's own comment)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8a36	; v7: 0x899a
	.equ FDC_COMMAND_INDEX,		0x8988	; the command FDC dispatches on, 0..11 (12 handlers)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8a40	; v7: 0x89a4
; control-panel-protocol.md "MIDI Message Format (at 0x9127-0x912A)": one MIDI message staged before it is
; sent -- statuses 0xB0..0xB3 written, word stores of status + first data byte
	.equ MIDI_MSG_STATUS,		0x9067	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x9127	; v7: 0x908b
	.equ MIDI_MSG_DATA1,		0x9068	; e.g. the controller number	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x9128	; v7: 0x908c
	.equ MIDI_MSG_DATA2,		0x9069	; e.g. the value	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x9129	; v7: 0x908d
	.equ MIDI_MSG_DATA3,		0x906a	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x912a	; v7: 0x908e
; feature-demo.md / ssf-presentation.md "Key DRAM Addresses" -- the demo selection's own writers agree
	.equ DEMO_TIMER_COUNTDOWN,	0x0d2f	; Demo_ResetCountdownTimer sets 15, Demo_SelectEntry_TimerTick counts
	.equ DEMO_TARGET_SONG,		0x1157	; target song index
	.equ DEMO_CURRENT_SONG,		0x1158	; current song index (Demo_SelectEntry_*, clamped to 18)
	.equ DEMO_ACTIVE_ENTRY,		0x2888	; active demo entry index	; v7: 0x28a4
	.equ DEMO_CONTROL_FLAGS,	0x2891	; demo control flags, bit 3 = auto-play	; v7: 0x28ad
; boot-cpserial-link.md "Rings and transfer-control blocks": the boot-time control-panel serial driver
	.equ BOOTSERIAL_STATE,		0x0f62	; state byte, a raw dispatch-table offset
	.equ BOOTSERIAL_FLAGS,		0x0f64	; bit 0 RX active, 1 TX pending, 2 RX busy, 4 decode-collapse sentinel, 7:6 link mode
	.equ BOOTSERIAL_STATUS,		0x0f6a	; bit 0 RX overflow, 1 TX arbitration failed, 3 frame discarded, 7 done / abort
; data-wheel-investigation.md "Dial Callback Table (RAM 0x3EF50-0x3EF6A)"
	.equ DIAL_ENABLE,		0x3ef4c	; enable flag (word)	; v7: 0x3ef50
	.equ DIAL_UP_CALLBACK,		0x3ef4e	; SetDialUp callback (the XWA component, clockwise)	; v7: 0x3ef52
	.equ DIAL_DOWN_CALLBACK,	0x3ef52	; SetDialDown callback (XWA, counter-clockwise)	; v7: 0x3ef56
	.equ DIAL_UP_EVENT,		0x3ef56	; SetDialUp event (XBC, e.g. 0x1C00007)	; v7: 0x3ef5a
	.equ DIAL_DOWN_EVENT,		0x3ef5a	; SetDialDown event (XBC)	; v7: 0x3ef5e
	.equ DIAL_UP_PARAM,		0x3ef5e	; SetDialUp parameter (XDE)	; v7: 0x3ef62
	.equ DIAL_DOWN_PARAM,		0x3ef62	; SetDialDown parameter (XDE)	; v7: 0x3ef66
	.equ DIAL_FOCUS,		0x3ef66	; the UI object the dial is focused on (32-bit)	; v7: 0x3ef6a
; boot-sequence.md / hdae5000-homebrew.md: "the flag at 0x03DD04 is the only gate" for the extension ROM
	.equ XAPR_PRESENT_FLAG,		0x3dd04	; 1 = extension ROM (XAPR) detected
; display-subsystem.md "Change Tracking" / "Palette-Based Fade Effects"
	.equ DISPLAY_UPDATE_FLAG,	0x3045e	; non-zero = needs refresh
	.equ PALETTE_INDEX_PREVIOUS,	0x3ef9c	; previous palette index, for partial updates	; v7: 0x3efa0
; the song clock -- the firmware exports these three by name (GetAdr_sq_beadt / GetAdr_sqbtof / GetAdr_sqsrtc,
; Hama Function table entries 65 / 64 / 66) for the HD-AE5000's lyric display (hdae5000-filesystem.md
; "Lyric Files").  The timer ISR (INTTR4_CheckAltSeqEnable) and the MIDI-clock path
; (ClkTick_Src3ClickCheck, +4 per clock = 24 ppqn) advance them while SEQ_TRANSPORT_STATE bit 2 is set.
	.equ SEQ_BEAT_TICK,		0x041b	; sq_beadt: tick within the beat, 0..95 (96 per quarter note); wraps into SEQ_BEAT_COUNT
	.equ SEQ_BEAT_COUNT,		0x041c	; sqbtof: beats since the start (word)
	.equ SEQ_TRANSPORT_STATE,	0x0421	; sqsrtc, bit set: 0 start pending, 1-2 running (2 gates the clock), 3 stop requested (the ISR then writes 16), 4 stopped; 0 = idle
; ssf-presentation.md "Part select index" -- and the code: GetPartSelect / GetCurrentPartSelect read it,
; MainPmanCtrl_StorePartSelect / _SetPartSelectOne write it
	.equ PART_SELECT,		0x8c82	; the selected part	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8d3a	; v7: 0x8c9e
; code only (feature-demo-investigation.md calls 0x28B4 a "song list pointer"; the code does not agree):
; SeqReassign_OrPartBits ORs part bits in, SeqCh_ClearActive_ShiftDone and PartDeact_* clear them, and
; the playback and demo handlers test it with `cpw (..),0`
	.equ SEQ_ACTIVE_PARTS,		0x2898	; word: one bit per sequencer part that is playing	; v7: 0x28b4
; sequencer.md "10 song slots (0x800 bytes each)", 20 KB -- the code: a slot is `slot << 11` past it
; (file_demo_proc.s), MidiPkt_SetXferBlock_SongSlots records it with its size 0x5000
	.equ SEQ_SONG_SLOTS,		0xab000	; 10 song slots of 0x800 bytes
; code: one-instruction accessors with the firmware's own names (GetModeNow, GetTitleOld ... are entries
; of the exported name table) -- each `ld xhl,(N) / ret` or `ld (N),xwa / ret`
	.equ MODE_NOW,			0x3ef7e	; GetModeNow: the current mode as an event value (32-bit)	; v7: 0x3ef82
	.equ MODE_OLD,			0x3ef82	; GetModeOld: the previous one	; v7: 0x3ef86
	.equ TITLE_NOW,			0x3ef86	; GetTitleNow: the current title as an event value (32-bit, 0x01A0nnnn)	; v7: 0x3ef8a
	.equ TITLE_OLD,			0x3ef8a	; GetTitleOld: the previous one	; v7: 0x3ef8e
	.equ ROOT_OBJECT,		0x2bc18	; GetRootObject / SetRootObject
	.equ ROOT_EVENT,		0x2bc1c	; GetRootEvent / SetRootEvent
	.equ ROOT_PARAM,		0x2bc20	; GetRootParam / SetRootParam
	.equ FOCUS_OBJECT,		0x2bc24	; GetFocusObject
	.equ FOCUS_EVENT,		0x2bc28	; GetFocusEvent
	.equ FOCUS_PARAM,		0x2bc2c	; GetFocusParam
; code: accessors with the firmware's own names (exported name table)
	.equ DIRMD_FLAG,		0x276c4	; GetDirmdFlag returns it (word)
	.equ LSW_FILTER,		0x276c6	; SetLswFilter / ResetLswFilter store into it (32-bit)
; The SMF DIRECT PLAY page's two toggles (ui_widgets/naka_disk_menu_file_io.c)
	.equ SmfPlayAsGm,		0x888a	; PLAY AS: 1 = GM, 0 = TECH (widget DiskSmfDirectPlay_AcMonoIndexToggle_2, index 0x14); SeqInit_ResetAndSetupChannels picks SoundParam_InitDefaultBanks(1 / 0) by it
	.equ SmfMidiOut_OnOff,		0x888c	; MIDI OUT: 1 = on (the firmware's widget SmfMidiOut, index 0x18); the SMF send paths echo events to SeqOut_WriteTimedBytes while it is on
	.equ CURRENT_TARGET,		0x2f83c	; GetCurrentTarget returns it (32-bit)
; sound-parameter hash table (DRAM, the same address in every version): 2047 slots of
; {u32 key, u32 record pointer}.  SndParam_InitHashTable stamps {SNDPARAM_HASH_EMPTY_KEY, 0} over
; 0x34100 .. +16376; the probe loops (SndParam_ProbeEntry and its twins) index slot n at +8n,
; wrapping modulo 0x7FF.
	.equ SNDPARAM_HASH_TABLE,	0x34100
; variables named from their uses (audit WP17): one file, so that the naming lane owns it
	.include "shared/ram_variables_by_use.s"
; the live panel records (TLV payloads), named from SndParam_BlockRamPtrs
	.include "shared/ram_panel_records.s"
