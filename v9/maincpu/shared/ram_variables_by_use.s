; ram_variables_by_use.s -- main-CPU RAM variables named from the code that uses them (audit WP17).
; The names and reasons are v10's (v10/maincpu/shared/ram_variables_by_use.s); the values here are
; v9's own, derived by scripts/tools/name_kn5000_ram.py from the same instructions in the same routines
; (a corrected line says so).  Names it could not derive for v9 are left out.
	.equ SEQ_EVENT_ABORT,		0x10e3	; 0 = carry on; 255 = the block chain ran out (ToneGen_AdvancePosition with no free block) or SeqTrack_ValidateAndAssignVoices found no dispatch slot.  The event handlers skip their register write when it is set and clear it after each event
	.equ SEQ_BLOCK_PTR,		0x10fd	; the 256-byte block being read or written: SMF_CalcPageAddress and its twins store SEQ_BLOCK_POOL + (n - 1) * 0x100 here; nested walks save and restore it
	.equ SEQ_BLOCK_POOL_COPY,	0x110a	; a copy of SEQ_BLOCK_POOL (DispatchHandler_* store it through `ld xhl, ...`), the base SeqNode_ResolveSlotPtr and SetWall_ResolveStreamPtr add to
	.equ SEQ_BLOCK_POOL,		0x1d5a	; base of the sequencer's pool of 256-byte data blocks: SeqInit_SetBaseAddress sets 0xB0000; block n (1-based) is at this + (n - 1) * 0x100
	.equ SEQ_BLOCK_TOTAL,		0x286d	; word: blocks in the pool, 1240 (SeqInit_SetBaseAddress); DispatchHandler_InitAllSlots starts SEQ_FREE_BLOCKS from it, the song-usage percentages divide by it
	.equ SEQ_TRACK,			0x2877	; the track (1..16) a sequencer operation or loop works on; 127 = all tracks (the edit titles' track 0x11, MainExeCall_OnTitleSq*); MainExe_SongMem* and SeqStep_MultiTrackProcess loop it over 1..16
	.equ SEQ_SONG,			0x2878	; the song (0..9) the song-memory routines (SeqVoice_InitEntry ...) address; SeqVoice_InitEntryForCurrentBank and SeqStep_TrackChange set it to SEQ_CURRENT_SONG or another song for one call and restore it
	.equ SEQ_WRITE_BLOCK_PTR,	0x2881	; the block SMF_Config* write output bytes into, at (this + IY); set from SEQ_BLOCK_PTR when a new block is started (IY = 5, past the block header)
	.equ SEQ_RTMCFG,		0x28a7	; rtmcfg, the firmware's own name (GetAdr_rtmcfg returns its address): sequencer / accompaniment playback flags; bit 2 = ignore incoming MIDI Start / Continue (Transport_EnableMidiStartContinue clears it)
	.equ SEQ_SCREEN_OBJECT,		0x2972	; the object EVT_PAINT gave the sequencer screen handlers (ApEditSyori, NoteEditSyori, ApPlaySyori, EffEditMain store its parameter); EVT_PARA_DRAW redraw requests are sent to it
	.equ ACC_PART_BIT,		0x33d4	; the accompaniment part being set up or played, one-hot: 1, 2, 4, 8, 16, 32 (AccVoice_SetupKbd1, _SetupKbd2, _SetupAcc1 .. _SetupAcc4); AccStyle_ReadParamOffset picks that part's field of a style record by it
	.equ SEQ_FREE_BLOCKS,		0xf231	; word: blocks still free; DispatchResolve_MarkCurrent takes one (sets bit 7 of its first byte, decrements); 0 makes ToneGen_AdvancePosition fail with SEQ_EVENT_ABORT = 255
	.equ SEQ_CURRENT_SONG,		0xffe3	; the selected song, 0..9: its record is SEQ_SONG_SLOTS + n * 0x800 (Display_CopyToneTableToRAM, SetSongSlotValue); set when a song is loaded (SMF_FinalizeAndStartPlayback)
