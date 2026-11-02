# APPLIED 2026-11-02 by the lane lead in commit 5a5311c56 (see notes/open6-kn5000-d/README.md).
# Renames proposed by sub-lane open6/kn5000-d subcmd (kn5000-1gu, kn5000-a1f).  Main CPU only:
# apply to v10/maincpu, v9/maincpu, v7/maincpu, v6/maincpu, v5/maincpu (every old name below is present
# in all five, checked 2026-11-02) and regenerate symbols/maincpu_*_symbols_reference.txt.  Evidence:
# notes/open6-kn5000-d/subcmd/README.md (addresses v10).  No new name collides with an existing label.
#
# --- kn5000-1gu (system sub-command 0x09) ---
# 0xFEBC36: builds the packet {4, 0xF0, A, C, E} and sends it (MIDI_SendCmdPacket): the generic sender of a
# sub-CPU system record F0 <b1> <sub-command> <value>; 24 callers (probes/subcmd_probe.py syssenders).
s/\bSeqVoice_CheckAndRet_Prologue\b/SubCPU_SendSystemRecord/g
# 0xFEBDD2: A != 0 -> 1, A == 0 -> 2; sends F0 7F 09 <mode> (Voice_SetPolyphonyMode) then re-sends CC7 to
# parts 0..0x18 (0 when the part's mute Lsw 0x008 is 1).  Only caller MidiCtrl_GmBitToPolyphonyMode.
s/\bCOMM_WriteAndCheck\b/SubCPU_SetPolyphonyModeAndResendVolumes/g
s/\bWriteAndCheck_LoadParam\b/SubCPU_SetPolyphonyMode_Send/g
# 0xFD8BE9: C = 1 when bit 2 (PANEL_GM+3, GM ON) of A is set, else 0, then the routine above.  Nothing
# about channels.
s/\bMidiCtrl_Bit2ToChannel_Store\b/MidiCtrl_GmBitToPolyphonyMode_Send/g
s/\bMidiCtrl_Bit2ToChannel\b/MidiCtrl_GmBitToPolyphonyMode/g
# 0xFD8BCC: bank-2 listener of panel code 0x91 (SwbtB2_Code91_Listeners): on field 3 bit 2 (GM ON/OFF,
# registry key 0xC0) it calls MidiCtrl_GmBitToPolyphonyMode; skipped while 0xB7EE bit 0 is set.  Code, not data.
s/\bMidiCtrl_ModeSwitch_Data\b/MidiCtrl_GmSwitchListener/g
# 0xF20C2F..: copies the song record's GM flag (SEQ_SONG_RECORD+0xBD, 0xFF = GM, written by
# FloppyIO_ConfigureSwitchboard for SMF playback) to PANEL_GM+3 bit 2 and posts {0x91, 3, value, 4}.
# Nothing about accompaniment.  (Its second half, +0xCB -> bit 0, keeps its name SongBank_CheckBassMode:
# bit 0 is registry key 0xC1 -> sub-command 0x99, not identified as "bass" or otherwise here.)
s/\bSongBank_CheckAccompanimentMode\b/SongBank_ApplySongGmFlag/g
s/\bSongBank_EnableAccompaniment\b/SongBank_SetGmOn/g
s/\bSongBank_SendAccompEvent\b/SongBank_PostGmEvent/g
# 0xF2026C..: the same GM-flag copy in the SetWall song sync.
s/\bSetWall_Sync_CheckPanelBit\b/SetWall_Sync_ApplySongGmFlag/g
s/\bSetWall_Sync_PanelOff\b/SetWall_Sync_SetGmOn/g
s/\bSetWall_Sync_PostEvent\b/SetWall_Sync_PostGmEvent/g
#
# --- kn5000-a1f (song controller events) ---
# 0xF3B1F3: the 0xD0/0xD1/0xD3 case: stores the track's part (track - 1) after the value and writes the
# 4-byte event {Dn, tick, value, part} with SeqBuf_WriteMidiEvent.  No note-off.
s/\bSeqNote_SendNoteOff\b/SeqNoteCh_SendControllerEvent/g
# 0xF3B225: the 0xD2 case: {D2, tick, lsb, msb, part}, 5 bytes.
s/\bSeqNote_NoteOff_WritePart\b/SeqNoteCh_SendPitchBendEvent/g
# 0xFCB47F / 0xFCB497 / 0xFCB8C4..: the 0x94D2 array holds event 0xD0's value and is sent as panel record
# 0xB4 = Lsw 0x1B2 ChannelPressure (README-lsw-param-namespace-map.md) -> MIDI_SendChannelPressure;
# the recorder maps {0xB4, tag} back to emitter 6 = MIDI_EmitRecord_D0.
s/\bVoiceParam_StorePendingB4\b/VoiceParam_StorePendingChanPressure/g
s/\bVoiceParam_SendPendingB4_Guard\b/VoiceParam_SendPendingChanPressure_Guard/g
s/\bVoiceParam_SendPendingB4_Done\b/VoiceParam_SendPendingChanPressure_Done/g
s/\bVoiceParam_SendPendingB4\b/VoiceParam_SendPendingChanPressure/g
s/\bPendingB4_ScanEntry\b/PendingChanPressure_ScanEntry/g
s/\bPendingB4_NextEntry\b/PendingChanPressure_NextEntry/g
# 0xFCB626 / 0xFCB644: event 0xD3 -> the 0x9432 array that MIDI CC11 also fills
# (MidiCC_SetPendingPartExpression), sent as panel record 0xB3 = Lsw 0x00B (CC11 expression), or on a
# CONTROL track (TRACK ASSIGN 15) as {0xB0, 1} = the expression pedal (ANALOG_EXPRESSION_PEDAL_PENDING).
# No bank select anywhere.
s/\bVoiceNote_StoreBankSelect\b/VoiceParam_StorePendingExpression/g
s/\bVoiceNote_WriteBankAndCC\b/VoiceParam_SendPendingExpression/g
s/\bVoiceNote_SetupCCParams\b/VoiceParam_SendPendingExpression_SetupParams/g
s/\bVoiceNote_CheckBankSelect\b/VoiceParam_SendPendingExpression_CheckPedal/g
s/\bVoiceNote_ApplyBankSelect\b/VoiceParam_SendPendingExpression_ApplyPedal/g
# 0xFCA2D9: posts the pending analog controls as panel events {0xB0, 0} (main volume,
# ANALOG_MAIN_VOLUME_PENDING) and {0xB0, 1} (expression pedal, ANALOG_EXPRESSION_PEDAL_PENDING).
s/\bAudio_WriteBankSelectParams\b/Audio_PostPendingAnalogControls/g
# 0xFCA924: emitter 0 of MidiStream_ProcessorDispatchC_Data, the recorder of event 0xCn {C0|flags, tick,
# tag, field, +0 & 0x7F, +1 & 0x7F, track}; sibling of MIDI_EmitRecord_B0 / _80 / _D0.._D3.
s/\bTempoCC_TransmitBytecodeBlock\b/MIDI_EmitRecord_C0/g
# 0xFCAFD2: on playback of a 0xCn event puts status bits 0 / 1 back as bit 7 of bytes +4 / +5 and drops a
# DRUMS (tag 0x0F) record that MIDI_ParamValidate_CheckBit2 rejects.
s/\bVoiceMode_CheckPendingFlags\b/VoiceMode4_RestoreValueHighBits/g
