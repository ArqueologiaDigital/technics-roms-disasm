; =============================================================================
; KN5000 RHYTHM DATA ROM IC14 -- RECORD AND EVENT MACROS
; =============================================================================
; First written by scripts/generators/gen_rhythm_data_s.py; this file is now the source.
; Readers are main-CPU v10 routines (the same code is in v9 and v7); their addresses are in
; symbols/maincpu_v10_symbols_reference.txt.  Evidence and open questions:
; notes/rhythm-data-ic14-2026-10-29/README.md.

; -----------------------------------------------------------------------------
; TRACKS (the pattern banks)
; -----------------------------------------------------------------------------
; A track is one part's pattern for one slot.  The reader (AccVoice_ProcessEventLoop) is handed
; XHL = AccVoice_TableLookup(bank) = bank base + 0x8000 and IY = (slot word - 0x8000 + 6) by
; AccPart_GetParamAddr, so it starts 6 bytes into the track, past this header.
;   +0  0x80          start marker
;   +1  prev          u16 page link (0xffff: none)
;   +3  next          u16 page link: AccBuf_Advance, on a 0x87 byte, continues at the page
;                     the word at header +3 names (AccWave_BankResolve), offset 6
;   +5  0x87          page-end marker; every ROM track ends with one too (trk_end), so the
;                     links are never followed here: all 28,400 headers are 0xffff, 0xffff
.macro	trk_begin prev=0xffff, next=0xffff
	.byte	0x80
	.short	\prev, \next
	.byte	0x87
.endm

; 0x83 = end of the pattern (AccVoice_HandleMarker83: loop, next pick or stop), then the 0x87
; page-end marker.
.macro	trk_end
	.byte	0x83, 0x87
.endm

; 0x81: one beat passes (AccVoice_HandleBarEndEvent; 96 ticks per beat, AccTempo_PositionCompare).
.macro	beat count=1
	.rept	\count
	.byte	0x81
	.endr
.endm

; 0x90 note (AccMidi_ParseCommon -> ACC_EVENT+0..+5): tick within the beat (0..95), note
; number, velocity, duration = dur_beats * 96 + dur_ticks.  Parts 4..32 check the note
; against 0x78 (Rhythm_CheckVelocityThreshold); the two drum parts do not.
.macro	note tick, key, vel, dur_ticks, dur_beats
	.byte	0x90, \tick, \key, \vel, \dur_ticks, \dur_beats
.endm

; 0x91 note with two more bytes (AccMidi_ParseNoteOn stores them at RAM 0x3433 / 0x3434).
; What the two mean is not established (docs/accompaniment-style-format.md, NOTE2).
.macro	note2 tick, key, vel, dur_ticks, dur_beats, ext1, ext2
	.byte	0x91, \tick, \key, \vel, \dur_ticks, \dur_beats, \ext1, \ext2
.endm

; 0xD1..0xD5: controller events, 3 bytes (AccMidi_ParseDType: status & 0x0f = selector into
; ACC_EVENT+2, tick, value).  Selector meanings from SeqPerformance_EventDispatch
; (docs/accompaniment-style-format.md): 1 modulation (CC 1), 2 pitch bend, 3 damper (CC 64),
; 4 pan (CC 10), 5 expression (CC 11).
.macro	cc_mod tick, value
	.byte	0xd1, \tick, \value
.endm
.macro	cc_bend tick, value
	.byte	0xd2, \tick, \value
.endm
.macro	cc_damper tick, value
	.byte	0xd3, \tick, \value
.endm
.macro	cc_pan tick, value
	.byte	0xd4, \tick, \value
.endm
.macro	cc_expr tick, value
	.byte	0xd5, \tick, \value
.endm

; -----------------------------------------------------------------------------
; STYLE RECORDS: 2 KB, two 1 KB halves of this layout
; -----------------------------------------------------------------------------
;   +0x000  style_section_map   280 B   which slots each section plays, per part
;   +0x118  part_tracks x 6     228 B   19 track slots per part
;   +0x1fc  style_gap_1fc        76 B   FF
;   +0x248  8 sound blocks      392 B   5 part_sound + sound_block_end each
;   +0x3d0  style_tail           48 B   time signature, pattern bank, velocities, id
; The parts are the six one-hot part bits 1, 2, 4, 8, 16, 32 (ACC_PART_BIT) in this order.

; One section's pattern picks: up to four slot numbers played in turn, then 0x83, at which
; AccPart_IncrementIndex returns to the first pick of the group.  A pick p selects the part's
; track slot p (AccPart_LookupBoundVoiceParam: word p of AccPart_LookupBoundVoiceParam_Data).
.macro	sec_picks p0, p1, p2, p3
	.byte	\p0, \p1, \p2, \p3, 0x83
.endm

; +0x000: 7 blocks of 40 bytes.  AccStyle_ReadParamOffset reads block 0 for parts 1 and 2 and
; blocks 1..4 for parts 4, 8, 16, 32 (+40, +80, +120, +160); the slot index is the section's
; group of five (AccStyle_ReadParamOffset_Data: slots 0..19 in half 0, 0x400.. in half 1).
; The second 20 bytes of each block are read only by AccStyle_ByteDataBlock (+20 .. +180),
; which nothing in v10 calls; blocks 5 and 6 have no reader.  The map is the same in all 404
; halves of this ROM, so it is spelled once here.
.macro	style_section_map
	.rept	7
	sec_picks	0, 1, 4, 5
	sec_picks	0, 1, 4, 5
	sec_picks	0, 1, 4, 5
	sec_picks	2, 3, 6, 7
	sec_picks	0, 4, 1, 5
	sec_picks	0, 4, 1, 5
	sec_picks	0, 5, 1, 6
	sec_picks	0, 5, 1, 6
	.endr
.endm

; +0x118 + 0x26 * part: the part's 19 track slots, each the track's offset in the 64 KB pattern
; bank this half names at +0x3d1 (AccPart_GetParamAddr; AccVoice_TableLookup adds the bank).
;   slots 0..7    picked by the section map
;   slots 12..15  AccVoice_ComputeParamAddr: 0x18/0x1a (section slot < 15), 0x1c/0x1e (< 20),
;                 the same +0x400 in half 1; the second of each pair when RAM 0x3309 bit 0 is 0
;   slots 16..18  AccVoice_SelectPartOffset (0x20, 0x22, 0x420: RAM 0x32ff bits 0/1),
;                 AccVoice_Reset_SelectMode (0x330a), AccVoice_ThirdLayer_SelectMode (0x24/0x424)
;   slots 8..11   no reader traced yet
; Measured over all 404 halves x 6 parts (probes/slot_bars_probe.py): every track in slots
; 0..15 and 17 is exactly one bar; slots 16 and 18 hold 1..8 bars.  [INFERENCE] 12..15 are the
; fill-ins (AccPedal_DirectionA picks the pair member) and 16 / 18 intro / ending patterns.
.macro	part_tracks bank, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18
	.short	\s0 - (RhythmData_Base + (\bank << 16)), \s1 - (RhythmData_Base + (\bank << 16))
	.short	\s2 - (RhythmData_Base + (\bank << 16)), \s3 - (RhythmData_Base + (\bank << 16))
	.short	\s4 - (RhythmData_Base + (\bank << 16)), \s5 - (RhythmData_Base + (\bank << 16))
	.short	\s6 - (RhythmData_Base + (\bank << 16)), \s7 - (RhythmData_Base + (\bank << 16))
	.short	\s8 - (RhythmData_Base + (\bank << 16)), \s9 - (RhythmData_Base + (\bank << 16))
	.short	\s10 - (RhythmData_Base + (\bank << 16)), \s11 - (RhythmData_Base + (\bank << 16))
	.short	\s12 - (RhythmData_Base + (\bank << 16)), \s13 - (RhythmData_Base + (\bank << 16))
	.short	\s14 - (RhythmData_Base + (\bank << 16)), \s15 - (RhythmData_Base + (\bank << 16))
	.short	\s16 - (RhythmData_Base + (\bank << 16)), \s17 - (RhythmData_Base + (\bank << 16))
	.short	\s18 - (RhythmData_Base + (\bank << 16))
.endm

.macro	style_gap_1fc
	.fill	76, 1, 0xff
.endm

; +0x248 + 0x31 * block: a section's part sounds.  AccVoice_LoadTuningBlock copies block
; (AccPart_VoiceParamOffsets_*: 0x00, 0x31, ... 0x157, + 0x400 in half 1) to RAM 0x3246, and
; RhythmROM_PatternDisp_Handle90 copies its five records (RhythmROM_PatternDisp_BufOffsets).
; The records are DRUM, BASS, ACCOMP1, ACCOMP2, ACCOMP3: the Sound Arranger
; (AccTuning_LoadFromROM) overwrites record n's program / bank from its arrangement pair n.
;   +0 program    +1 bank (7 bits)
;   +2 forced     both loaders overwrite it with 0x40 / 0x0c / 0x74 / 0x40 in records 1..4
;   +3 bank_msb   AccTuning_LoadFromROM stores bit 7 of the arrangement's bank byte here
;   +4..+6        copied with the rest; no reader of these three bytes traced yet
.macro	part_sound program, bank, forced, bank_msb, f4, f5, f6
	.byte	\program, \bank, \forced, \bank_msb, \f4, \f5, \f6
.endm
.macro	sound_block_end
	.fill	14, 1, 0xff
.endm

; Time-signature codes (+0x3d0): the index of TimeSig_DisplayStrings, whose names they are;
; AccTone_LookupByProgram_Table holds the beats per bar.  Measured: every track in slots
; 0..15 and 17 of a half is exactly one bar of its half's code (probes/slot_bars_probe.py).
.equ	TIMESIG_3_4, 6
.equ	TIMESIG_4_4, 7
.equ	TIMESIG_6_4, 9
.equ	TIMESIG_8_4, 11

; +0x3d0: the half's tail.
;   +0x3d0 time_sig      AccStyle_ReadVoiceParam: beats per bar through AccTone_LookupByProgram_Table;
;                        Rhythm_LoadCurrentTimeSig: index into TimeSig_DisplayStrings (RAM 0x34f0)
;   +0x3d1 bank          the 64 KB pattern bank of this half's tracks (AccStyle_SetupPartAddresses ->
;                        ACC_STYLE_BANK, AccVoice_TableLookup)
;   +0x3d2 v<s>a, v<s>b  per section s of the half: Rhythm_LookupTuningRange -> RAM 0x333f / 0x3340,
;                        the two velocity settings AccMidi_SelectVelocitySource chooses between
;   +0x3da flag          AccStyle_ReadVoiceParam W -> RAM 0x32ef (written, no reader in v10)
;   +0x3db id            8 ASCII characters, "<style id>1n" / "<style id>1v"; no reader found
;   +0x3e3 m0, m1, 0, m3, w0..w3 (u16), c0..c3   16 bytes with no reader found (open question)
;   +0x3f3 13 zero bytes
.macro	style_tail time_sig, bank, v0a, v0b, v1a, v1b, v2a, v2b, v3a, v3b, flag, id, m0, m1, m3, w0, w1, w2, w3, c0, c1, c2, c3
	.byte	\time_sig, \bank, \v0a, \v0b, \v1a, \v1b, \v2a, \v2b, \v3a, \v3b, \flag
	.ascii	"\id"
	.byte	\m0, \m1, 0, \m3
	.short	\w0, \w1, \w2, \w3
	.byte	\c0, \c1, \c2, \c3
	.fill	13, 1, 0
.endm
