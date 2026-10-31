#!/usr/bin/env python3
"""Writes notes/floppy-kn5000-2026-10-29/specs/sqt_slot_header.json and checks that the fields tile each region."""
import json,sys
OUT=sys.argv[1]
S=0xf180
def F(off,size,name,kind,ev,inf=False,todo=None,rep=None):
    d={'off':off,'size':size,'name':name,'kind':kind,'evidence':ev,'inference':inf}
    if todo: d['todo']=todo
    if rep: d['repeat']={'count':rep[0],'stride':rep[1]}
    return d
IDF='SeqParams_InitDefaults (v10 sequencer_engine.s:12015) and SeqInit_Return (sequencer_engine.s:18929..19143, Part_WriteByte/Part_WriteWord with BC = this offset) write the default; '
a=[
F(0x07,1,'written_only_07','hex','Part_InitVoiceDefaults (sequencer_engine.s:16142) writes 0 (BC=7); 0x00 in 153/153 slots. No reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10: the one PART row is that write)'),
F(0x08,1,'panel_model_code','hex','Part_InitVoiceDefaults writes Boot_ReadFDCStatus() = RAM 0x8e6a (kn5000_v10_program.s:1654); SoundBank_InitTrack_ByteFields (smf_playback.s:125) does the same. 0x8e6a is set by CPanel_ButtonPollLoop (cpanel_routines.s:530-543) to 0x0c/0x0d/0x0e from bits 7/6 of control-panel status byte 0x8e55. 0x0c in 153/153 slots',True,'what the 0x0c/0x0d/0x0e codes distinguish (panel/model variant) is not established'),
F(0x09,9,'file_stem','ascii','measured: 31 of 153 slots hold an 8-character, "_"-padded DOS name stem plus NUL ("07STIMNG", "01HEITER", "04SOUL__"); the rest hold stale bytes (00 ff 3f d6 6d ..., ff fe bf ...). Not written by Part_InitVoiceDefaults or SoundBank_InitTrack (both write +0..+8 and +0x14..+0x1b only); no reference to 0xf189 or SEQ_SONG_RECORD+9 in v10',True,'writer not found (searched hex 0xf188..0xf19d, SEQ_SONG_RECORD+N and the Part_* slot accessors); which file the stem names (none of these stems exists on its own disk) is open'),
F(0x12,2,'stale_12','hex','RAM residue: ff ff in 109/153; nothing writes or reads it (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10: 0 ABS, 0 PART; the DISP candidates are stack locals)'),
F(0x14,2,'section0_offset16','u16','Part_InitVoiceDefaults writes 0 (BC=0x14), SoundBank_InitTrack_WordFields_Data the same; constant 0x0000 in 153/153. Read as the {offset/16, length} pair of section 0 (the song-parameter block +0..+0xff) by the values of its twin +0x18/+0x1a, which match the code (Part_CopyToBuffer copies 0x520 B from +0x2e0); the firmware reads none of +0x14..+0x1b (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10), so the pairing stays an inference',True),
F(0x16,2,'section0_length','u16','Part_InitVoiceDefaults writes 0x0100 (BC=0x16); constant in 153/153. 0x100 = the end of the song-parameter block (+0x100 is the name). Written only: no reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)',True),
F(0x18,2,'panel_section_offset16','u16','Part_InitVoiceDefaults writes 0x002e (BC=0x18); 0x2e * 16 = 0x2e0, the song panel copy (SEQ_SONG_RECORD+736 in Part_CopyToBuffer / BitMapOut_ComputeRegionDelta); constant in 153/153. Written only: no reader of the word in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py)',True),
F(0x1a,2,'panel_section_length','u16','Part_InitVoiceDefaults writes 0x0520 (BC=0x1a); Part_CopyToBuffer (sequencer_engine.s:15668) copies exactly 0x520 bytes from slot +0x2e0 (0x2e0 + 0x520 = 0x800); constant in 153/153. Written only: no reader of +0x14..+0x1b in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py), so the reading rests on the values',True),
F(0x1c,2,'password','u16','the song password: FmmPasswordFunc (file_io/filename_password.s) on EVT_SET_PASSWORD writes the entered password into +0x1c of all ten slots (ClearAllSongSlots -> SetSongSlotValue, file_io/medley.s, which also writes SEQ_SONG_RECORD+0x1c for the current song) and into the Composer image +0x0e; GetSongSlotValue / FindFirstEmptySlot read it back, SMF_InitPlaybackState tests it (cpw (SEQ_SONG_RECORD+28), 0), SeqInit_WriteDefaultsLoop (18862) releases the voices of a slot whose word is non-zero. Cleared (0) whenever a song is erased (SeqTempo_ApplyAndReturn, SeqBufPos_StoreResult, PartRelRange_WriteDefaults, SeqVoice_InitChannelLoop). 0 in 153/153'),
F(0x1e,2,'track_mask','u16','SEQ_TRACK_MASK 0xf19e (ram_variables_by_use.s): bit t-1 = track t holds data (Chan_SetActiveBit); measured: 108 of 132 present tracks (+0xd0 bit 7) have their bit set'),
F(0x20,1,'track_assign','dec','SEQ_TRACK_ASSIGN 0xf1a0: TRACK ASSIGN of each of the 16 tracks (13 CHORD, 14 APC, 15 CONTROL, 16 RHYTHM; Seq_FindRhythmTrack); Part_WriteSubBlock32 / Part_ReadSubBlock32; defaults PartSubBlkA/B_WriteLoop32_Table (0xe4454a / 0xe4455a)',rep=(16,1)),
F(0x30,1,'track_table_30','dec','Part_WriteSubBlock48 / Part_VoiceSearchBlock (sequencer_engine.s:15988, 16008): a second 16-entry per-track byte table at slot +0x30 (0xf1b0); default 0x10 for every track (PartSubBlkA_WriteLoop48_Table 0xe4456a, Part_WriteAllVoiceSubBlocks_A/_B); measured 0x10 x16 in 60 slots, 00 01 02 10 0e 0d 0f 03..0b in 90',True,'meaning not established (no caller of Part_VoiceSearchBlock found by name)',rep=(16,1)),
F(0x40,2,'stale_40','hex','RAM residue: varies (00 00 / 31 b1 / fe ff / b2 5c / 1e c8 ...); nothing writes or reads it (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10: 0 ABS, 0 DISP, 0 PART, .equ names and SEQ_SONG_RECORD+N included)'),
F(0x42,12,'written_only_42','hex','PartInit_WriteZeroLoop in Part_InitVoiceDefaults zeroes +0x42..+0x4d; 0 in 153/153. No reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0x4e,2,'event_used_size16','u16','SEQ_SONG_RECORD+78 (0xf1ce): SeqStep_FindAndCompact stores the used event-memory size / 16; MidiPkt_GetUsedSize_SeqEvents (midi_dispatch_handlers.s:10630) returns it * 16; SeqStep_ReinitPartTable copies it into every slot (SeqStep_ReinitLoop, BC=0x4e); SeqLoad_PostInitParts treats 0 as an empty heap. Measured: value * 16 == the file\'s cell bytes in 102/102 slots with a non-zero value'),
F(0x50,2,'track_mask_50','u16','per-track bit mask (Bit16Mask_Table[t]) tested by AudioInit_GroupA_DefaultMapping (audioinit_routines.s:938) and PartCtrl_CheckBitmaskBit (audio_control_engine.s:10735); set 0xffff by SeqInit_Return and MainExe_SeqStopFinish; 0xffff in 153/153',True,'what the bit selects in the channel mapping is not established'),
F(0x52,1,'written_only_52','dec',IDF+'0; it is cleared together with SQEDT_TRKCLR_MASK; 0 in 150/153. No reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10: the rows are those writes)'),
F(0x53,1,'sqedt_trkmrg_track_a','dec','SQEDT_TRKMRG_TRACK_A 0xf1d3 (TT_SQTRKMRG source track A); default 1'),
F(0x54,1,'sqedt_trkmrg_track_b','dec','SQEDT_TRKMRG_TRACK_B 0xf1d4; default 2'),
F(0x55,1,'sqedt_trkmrg_track_c','dec','SQEDT_TRKMRG_TRACK_C 0xf1d5 (destination); default 3'),
F(0x56,1,'sqedt_mdel_track','dec','SQEDT_MDEL_TRACK 0xf1d6 (TT_SQMDEL)'),
F(0x57,2,'sqedt_mdel_from','u16','SQEDT_MDEL_FROM 0xf1d7'),
F(0x59,2,'sqedt_mdel_count','u16','SEQ_SONG_RECORD+89: SeqEvent_MainHandler_OnTitleSqmdel sets SQEDT_MDEL_LAST = from + this - 1; AppEvtHandler_Branch_011 stores last - from + 1 (sequencer_engine.s:20603, 20970); default 1'),
F(0x5b,1,'sqedt_mers_track','dec','SQEDT_MERS_TRACK 0xf1db (TT_SQMERS)'),
F(0x5c,2,'sqedt_mers_from','u16','SQEDT_MERS_FROM 0xf1dc'),
F(0x5e,2,'sqedt_mers_count','u16','SEQ_SONG_RECORD+94: SeqEvent_MainHandler_OnTitleSqmers (last = from + this - 1), AppEvtHandler_Branch_013 (sequencer_engine.s:20620, 20979)'),
F(0x60,1,'sqedt_mers_choice','dec','SQEDT_MERS_CHOICE 0xf1e0'),
F(0x61,1,'sqedt_mins_track_a','dec','SQEDT_MINS_TRACK_A 0xf1e1 (TT_SQMINS)'),
F(0x62,2,'sqedt_mins_from','u16','SQEDT_MINS_FROM 0xf1e2'),
F(0x64,2,'sqedt_mins_count','u16','SEQ_SONG_RECORD+100: SeqEvent_MainHandler_OnTitleSqmins, sequencer_engine.s:21279'),
F(0x66,1,'sqedt_mins_track_b','dec','SQEDT_MINS_TRACK_B 0xf1e6'),
F(0x67,2,'sqedt_mins_at','u16','SQEDT_MINS_AT 0xf1e7'),
F(0x69,1,'sqedt_mcp_track_a','dec','SQEDT_MCP_TRACK_A 0xf1e9 (TT_SQMCP)'),
F(0x6a,2,'sqedt_mcp_from','u16','SQEDT_MCP_FROM 0xf1ea'),
F(0x6c,2,'sqedt_mcp_count','u16','SEQ_SONG_RECORD+108: SeqEvent_MainHandler_OnTitleSqmcp, sequencer_engine.s:21180'),
F(0x6e,1,'sqedt_mcp_track_b','dec','SQEDT_MCP_TRACK_B 0xf1ee'),
F(0x6f,2,'sqedt_mcp_at','u16','SQEDT_MCP_AT 0xf1ef'),
F(0x71,1,'sqedt_qtz_track','dec','SQEDT_QTZ_TRACK 0xf1f1 (TT_SQQTZ; 0x11 = all)'),
F(0x72,2,'sqedt_qtz_from','u16','SQEDT_QTZ_FROM 0xf1f2'),
F(0x74,2,'written_only_74','u16','SEQ_SONG_RECORD+116: SeqParams_InitDefaults writes 1 and SeqInit_Return (BC=0x74) the default, like the MDEL / MERS / MINS / MCP counts at +0x59 / +0x5e / +0x64 / +0x6c, whose title handlers read them (e.g. SeqEvent_MainHandler_OnTitleSqmcp, `add wa, (SEQ_SONG_RECORD+108)`). The TT_SQQTZ page keeps its range in SQEDT_QTZ_FROM and SQEDT_QTZ_LAST (RAM 0x25fc, outside the record) and never reads this word: no reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0x76,1,'sqedt_qtz_value','dec','SQEDT_QTZ_VALUE 0xf1f6; default 3'),
F(0x77,1,'written_only_77','dec','SeqInit_Return writes 0 (BC=0x77); 0 in 152/153. No reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0x78,2,'track_tail_cell','u16','Part_WriteWord_Indexed / Part_ReadWord_Indexed (sequencer_engine.s:15795..): word array at slot +0x78, entry t = track t+1; VoiceSlot_AssignToChannel / VoiceSlot_Overflow (demo_seq_bridge.s:1016-1110) append events at this cell and move it to a newly linked cell; DispatchHandler_InitAllSlots sets 0xffff. Measured: equals the last cell of the track\'s chain in 132/132 present tracks; 0xffff for all 2316 absent tracks',rep=(16,2)),
F(0x98,1,'track_tail_offset','dec','Part_WriteByte_Indexed / Part_ReadByte_Indexed: byte array at slot +0x98; VoiceSlot_AssignToChannel reads it as the write offset in the tail cell (5 = first payload byte, overflow past 0xff links a new cell); init 5. Measured: the tail cell\'s byte at this offset is the 0x82 end-of-track mark in 131/132 present tracks; 5 for all absent tracks',rep=(16,1)),
F(0xa8,1,'sqedt_velocng_track','dec','SQEDT_VELOCNG_TRACK 0xf228 (TT_SQVELOCNG)'),
F(0xa9,2,'sqedt_velocng_from','u16','SQEDT_VELOCNG_FROM 0xf229'),
F(0xab,2,'written_only_ab','u16','SEQ_SONG_RECORD+171: SeqParams_InitDefaults writes 1, SeqInit_Return (BC=0xab) the default, as for the quantize word at +0x74; TT_SQVELOCNG keeps its range in SQEDT_VELOCNG_FROM and SQEDT_VELOCNG_LAST (RAM 0x25fa) and never reads this word: no reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0xad,1,'written_only_ad','dec','SeqParams_InitDefaults / SeqInit_Return write 0 (SEQ_SONG_RECORD+173). No reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0xae,1,'sqedt_velocng_amount','dec','SQEDT_VELOCNG_AMOUNT 0xf22e'),
F(0xaf,2,'free_list_head','u16','SEQ_FREE_LIST_HEAD 0xf22f: first free cell (one-based), 0xffff = none (DispatchHandler_ResolveSlot); measured = cell count + 1 in 90 of the 102 slots with events'),
F(0xb1,2,'free_blocks','u16','SEQ_FREE_BLOCKS 0xf231 (Part_SetAllVoicePos writes it into every slot); measured: cells in file + this = 1240 (0x4d8, the heap size) in 90 slots'),
F(0xb3,4,'written_only_b3','hex','SeqParams_InitDefaults and SeqInit_Return write 0 to +0xb3, +0xb4, +0xb5, +0xb6 (bytes); 0 in 152/153. No reader in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0xb7,1,'stale_b7','hex','RAM residue (ff/bf/00); nothing writes or reads it (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0xb8,2,'punch_in_measure','u16','SEQ_PUNCH_IN_MEASURE 0xf238; default 1'),
F(0xba,2,'punch_out_measure','u16','SEQ_PUNCH_OUT_MEASURE 0xf23a; default 2'),
F(0xbc,1,'play_flags','bits','SEQ_SONG_RECORD+188: bit 0 = punch-in recording (SeqAcc_StartPlayback sets, SeqAcc_StopPlayback clears, SeqAcc_SetupRepeatCount tests; sequencer_engine.s:142-174); default 0'),
F(0xbd,1,'accomp_mode','hex','SEQ_SONG_RECORD+189: SongBank_CheckAccompanimentMode (ui_playback_modes.s:1075) and SetWall_Sync_CheckPanelBit compare it with 255; Part_InitVoiceDefaults writes 0 or 0xff (SeqStatus_CheckBit2); FloppyIO_ConfigureSwitchboard clears it. 0 in 153/153',True,'what 0xff switches on is only read from the branch targets (EnableAccompaniment)'),
F(0xbe,1,'song_flags','bits','SEQ_SONG_RECORD+190: SeqLoad_CheckAutoAccompFlag (sequencer_engine.s:27210) sets bit 0 when slot byte +6 < 3 and +5 != 0, clears bit 1; SeqInit_Return sets bit 0',True,'bit meanings beyond the version test are not established'),
F(0xbf,2,'count_in','u16','SEQ_COUNT_IN 0xf23f (play-screen parameter 10); SeqInit_Return writes it as a word (BC=0xbf); 0 or 2 measured'),
F(0xc1,6,'stale_c1','hex','six 0x20 in 100/153 slots, b3 23 20 00 20 20 in 53; nothing writes or reads it in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10). The KN7000 .SQF keeps an 8-character slot name at +0xC1 (docs/kn5000-sequencer-and-smf.md); no KN5000 build has that field: the bytes are residue'),
F(0xc7,1,'saved_current_song','dec','SeqStep_ReinitPartTable (seq_step_routines.s:3127) and SeqStep_ByteBlockEA5F write SEQ_CURRENT_SONG (0xffe3) here; MidiSysEx_RestoreSongSelection reads it back; SeqLoad_RestorePartConfig'),
F(0xc8,2,'saved_track_mask','u16','SeqStep_ReinitPartTable / SeqStep_ByteBlockEA5F write SEQ_TRACK_MASK_COPY (0xffec) here; MidiSysEx_RestoreSongSelection restores it'),
F(0xca,1,'stale_ca','hex','0 in 152/153; nothing writes or reads it (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0xcb,1,'bass_mode','hex','SEQ_SONG_RECORD+203: SongBank_CheckBassMode (ui_playback_modes.s:1098) compares it with 255 (SongBank_EnableBassMode); cleared with the track mask on erase and by SeqInit; 0 in 153/153',True,'meaning read from the branch target names'),
F(0xcc,4,'stale_cc','hex','RAM residue: 00 00 ff ff / 0a f3 ff ff / fe ff fe bf; nothing writes or reads it (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10)'),
F(0xd0,1,'track_flags','bits','SEQ_TRACK_TABLE 0xf250, 16 x 3 bytes: bit 7 = the track holds data (Part_ReadVoiceBit7 / Part_SetClearVoiceBit7, SqStep_CheckCursorTrackUsed); SeqSlot_ClearF250Loop writes 0. 132 present tracks over 153 slots',rep=(16,3)),
F(0xd1,2,'track_first_cell','u16','SEQ_TRACK_TABLE +1: Part_ReadVoiceWord / Part_WriteVoiceWord (slot + 0xd1 + 3*(t-1)), 0xffff when empty (SeqSlot_ClearF250Loop). Measured: for all 132 present tracks this cell exists and has PREV = 0 (a chain head), and walking NEXT ends at +0x78\'s tail cell. This refutes the README reading that SQT start fields are 0xffff: only absent entries are',rep=(16,3)),
]
b=[
F(0x110,2,'track_voice_mask','u16','SEQ_SONG_RECORD+272: per-track bit (Bit16Mask_Table[t]) tested by AudioInit (audioinit_routines.s:757, AudioInit_VoiceNotAssigned when clear); VoiceChannels_InitPanFromPreset takes it; SeqInit_ClearPartDataLoop and VoiceChannels_LoadPartMap_Mode1 write 0xffff; SeqStep_VoiceReassignCleanup copies it between slots',True,'"voice assigned" is read from the branch label'),
F(0x112,1,'pan_preset_done','dec','SeqLoad_InitPartPanPresets (sequencer_engine.s:27405): for a slot whose byte is not 1, sets it to 1 and turns a 0 in +0x110 into 0xffff; SeqInit writes 1',True,'reads as a format-upgrade marker; not proven'),
F(0x113,0x1cd,'reserved_113','hex','SeqInit_ClearPartDataLoop (sequencer_engine.s:19160) zeroes +0x113..+0x2df (0x1cd bytes); nothing else writes or reads it in v5..v10 (notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py, v5..v10: the ABS rows in that range are the constant 0xf400, a length)'),
F(0x2e0,0x20,'song_panel_header','hex','copy of the live panel header 0xf980..0xf99f (LIVE_PANEL_BLOCK): BitMapOut_ComputeRegionDelta (dsp_config_sysex.s:1245) copies 0x422 bytes 0xf980.. to slot +0x2e0 (SEQ_SONG_RECORD+736); Part_CopyToBuffer moves 0x520 bytes from +0x2e0 between slots. First 8 bytes 5a 5a 00 00 48 4b 00 00 in 153/153 (the LSW header shape, "HK" at +4)'),
F(0x300,0x3c0,'song_panel_block0','hex','panel block 0 (= LSW +0x20, RAM 0xf9a0): PanelTlv_ValidateSongPanel (tonegen_fileio_handlers.s:682) validates SEQ_SONG_RECORD+768 = 0xf480 with PanelTlv_ValidateBlock0. Measured with floppy/kn5000/formats.match_layout: all 46 PanelTlv_Block0_Layout records in 150/153 slots (ending exactly at +0x6c0), the first 43 in 3. Type it with emit_block like the LSW'),
F(0x6c0,0x48,'song_panel_block1_copy','hex','the first three records of panel block 1 (RAM 0xfd60..0xfda7: tags 0x17 (24 B), 0x18 (24 B), 0x98 (18 B), PanelTlv_Block1_Layout +0x000 / +0x01a / +0x034); BitMapOut_ComputeRegionDelta copies 0x422 bytes from 0xf980, which ends at PANEL_REC_98 + 12 = 0xfda2, six bytes into record 0x98; its last 6 payload bytes (+0x702..+0x707) are the slot RAM of an earlier copy and complete the record in 153/153 (match_layout ends the 3 records at +0x708). describe_sqt types them with the panel record macros'),
F(0x708,0xf8,'stale_708','hex','RAM residue: moved with the panel copy by Part_CopyToBuffer (0x520 B from +0x2e0) but written by no song-panel copy (BitMapOut_ComputeRegionDelta stops at +0x702); dozens of distinct byte values per offset over 153 slots'),
]
regs={'slot_a (0x07..0xff)':(0x07,0xf9,a),'slot_b (0x110..0x7ff)':(0x110,0x6f0,b)}
out={'regions':{}}
for rn,(base,size,fl) in regs.items():
    cov=[0]*size
    for f in fl:
        cnt,st=(f['repeat']['count'],f['repeat']['stride']) if 'repeat' in f else (1,0)
        for k in range(cnt):
            for x in range(f['size']):
                cov[f['off']-base+k*st+x]+=1
        f['off']-=base
    bad=[hex(base+i) for i,c in enumerate(cov) if c!=1]
    assert not bad, (rn,bad)
    out['regions'][rn]={'base':base,'size':size,'fields':fl}
out['notes']=("A slot is the RAM image of SEQ_SONG_RECORD 0xf180..0xf97f (the current song) / SEQ_SONG_SLOTS 0xab000 + 0x800*n; "
 "offsets are slot-relative, RAM name = 0xf180 + offset. Most names come from the .equ table v10/maincpu/shared/ram_variables_by_use.s "
 "and from the constant-offset calls to the slot accessors Part_ReadByteDirect/Part_WriteByte/Part_ReadWord/Part_WriteWord (BC = offset). "
 "Defaults: Part_InitVoiceDefaults writes +0..+8, +0x14..+0x1b, +0x42..+0x4d, +0xbd; SeqInit_Return / SeqParams_InitDefaults the edit block. "
 "File side: 72 SQT files, 153 slots (9 files have 10 slots, +4 = 1; the rest 1). +5/+6 (01 08) are written 1 and 8 by Part_InitVoiceDefaults and "
 "tested by SeqLoad_CheckAutoAccompFlag (+6 < 3, +5 == 0): a format version 1.08 [INFERENCE]. +4: SeqSavePre sets slot 0's byte to 1 for the save, SeqSavePost back to 0. "
 "CORRECTION to notes/floppy-kn5000-2026-10-29/README.md ('every start field read 0xffff'): the +0xd0 track table does hold the first cell of each present track "
 "(132/132 chain heads, tails = +0x78, end marks at +0x98); the slot links track t to its chain. The empty template slots carry stale bytes at +0xd0 with bit 7 clear. "
 "Probes (committed in notes/floppy-kn5000-2026-10-29/probes/): sqt_slots.py <extracted dir> var LO HI (per-offset variety), "
 "sqt_tracks.py <dir> (track table / tail / free-list / used-size checks), partcalls.py and ramrefs.py (run from the worktree root: accessor offsets and RAM references), "
 "write_sqt_spec.py (this file + tiling check); the reader search of every field over v5..v10: notes/kn5000-style-2026-10-31/probes/sqt_field_refs.py. Extract the disks first with floppy/tools/fat12_extract.py.")
json.dump(out,open(OUT,'w'),indent=1)
print('ok',sum(len(r['fields']) for r in out['regions'].values()),'fields')
