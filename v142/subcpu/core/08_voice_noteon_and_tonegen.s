; ===========================================================================
; Voice_NoteOn - Process MIDI Note On messages
; ===========================================================================
; Entry: XWA = pointer to 4-byte note data:
;        +0 = status byte (0x9n where n=channel)
;        +1 = channel number (0-25)
;        +2 = note number (0-127)
;        +3 = velocity (0-127, 0 = note off)
; Exit:  Voice allocated and parameters set for new note
; Notes: Allocates voice slot, sets pitch via Voice_SetPitch
;        Sets velocity via Voice_SetVelocity
;        Velocity 0 triggers note-off via Voice_NoteOff
; ===========================================================================
; Existing name kept; the LLVM source already carries a good header. XWA points at a 4-byte
; MIDI-ish record: +0 status, +1 part/channel (rejected when >= 0x1A), +2 note, +3 velocity.
; Velocity != 0 -> RingBuf_SetOffsetLo(status & 8), then VOICE_SETVELOCITY and VOICE_SETPITCH.
; Velocity == 0 -> VOICE_ALLOCATE(part, note), VOICE_PARAMINIT on the returned packet, then
; VOICE_NOTEOFF. The pushed word for all four calls is (status & 7).
Voice_NoteOn:
	dec 2, xsp
	push xiz
	ld xiz, xwa
	cp (xiz + 1), 0x1A
	jr ge, Voice_NoteOn_Exit
	ld a, (xiz)
	and a, 0x7
	ld (xsp + 4), a
	ld a, (xiz + 3)
	res 7, a
	cp a, 0:i3
	jr z, Voice_NoteOn_ZeroVelocity
	ld a, (xiz)
	and a, 0x8
	call RingBuf_SetOffsetLo
	ld l, (xiz + 1)
	ld c, (xiz + 2)
	ld e, (xiz + 3)
	ld a, (xsp + 4)
	extz wa
	pushw wa
	ld a, l
	calr Voice_SetVelocity
	ld l, (xiz + 1)
	ld c, (xiz + 2)
	ld e, (xiz + 3)
	ld a, (xsp + 4)
	extz wa
	pushw wa
	ld a, l
	calr Voice_SetPitch
	jr Voice_NoteOn_Exit

Voice_NoteOn_ZeroVelocity:
	ld a, (xiz + 1)
	ld c, (xiz + 2)
	calr Voice_Allocate
	ld xwa, xhl
	calr Voice_ParamInit
	ld l, (xiz + 1)
	ld c, (xiz + 2)
	ld e, (xiz + 3)
	ld a, (xsp + 4)
	extz wa
	pushw wa
	ld a, l
	calr Voice_NoteOff

Voice_NoteOn_Exit:
	pop xiz
	inc 2, xsp
	ret

; XWA = a request packet buffer. Fills it with selector = (word at 0x041360 >> 8) | 0x1480,
; +2 = 0x80, +3..+6 = 0, calls Voice_Allocate_Nodes (0x022340), and reads the granted TG channel
; back from packet+10. If that channel is < 0x40 it initialises the whole voice struct at
; 0x04308E + ch*0x47 from scratch: +0x00 = ch, +0x01 = 1, +0x03 = 0, +0x04 = 0x14,
; +0x05 = high byte of 0x041360, +0x06 and +0x08 = the 0x041360 word, +0x0C = 0,
; +0x13/+0x17/+0x1B/+0x1F/+0x27 = 0 (longs), +0x2F = 0, +0x31 = 0x00FF, +0x35 = 0,
; +0x36/+0x38/+0x3A = 0.
; The LLVM build calls this Voice_SetPanning; nothing in the body supports that -- it is an
; acquire-and-zero-the-struct routine. See [UNCERTAIN].
Voice_SetPanning:
	push xiz
	ld xiz, xwa
	ld wa, (Payload_Bss_Start+0x24ea:24)
	srl wa, 8
	or wa, 0x1480
	ld (xiz), wa
	ld (xiz + 2), 0x80
	ld (xiz + 6), 0x0
	ld (xiz + 3), 0x0
	ld (xiz + 4), 0x0
	ld (xiz + 5), 0x0
	ld xwa, xiz
	call Voice_Allocate_Nodes
	cp (xiz + 10), 0x40
	jr nc, Voice_SetPanning_Exit
	ld a, (xiz + 10)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	lda	xbc, (xbc+wa)
	ld wa, (Payload_Bss_Start+0x24ea:24)
	ld (xbc + 8), wa
	ld wa, (Payload_Bss_Start+0x24ea:24)
	ld (xbc + 6), wa
	ldw (xbc + 1), 0x1
	ld xwa, 0:i3
	ld (xbc + 19), xwa
	ld xwa, 0:i3
	ld (xbc + 23), xwa
	ld xwa, 0:i3
	ld (xbc + 27), xwa
	ld xwa, 0:i3
	ld (xbc + 31), xwa
	ld xwa, 0:i3
	ld (xbc + 39), xwa
	ld (xbc + 12), 0x0
	ld (xbc + 4), 0x14
	ld wa, (Payload_Bss_Start+0x24ea:24)
	srl wa, 8
	ld (xbc + 5), a
	ld a, (xiz + 10)
	ld (xbc), a
	ld (xbc + 3), 0x0
	ldw (xbc + 47), 0x0
	ldw (xbc + 49), 0xFF
	ld (xbc + 53), 0x0
	ldw (xbc + 54), 0x0
	ldw (xbc + 58), 0x0
	ldw (xbc + 56), 0x0

Voice_SetPanning_Exit:
	pop xiz
	ret

; WA = TG channel, XBC = shadow block. Writes exactly one register: 0x0400 + ch <- shadow
; +0x0E.
;
; RESOLVED 2026-08-20 -- the curated name is right and the LLVM name ("pan") is wrong.
; Register +0x400 is the voice's ABSOLUTE LOG PITCH, 0x100 units per semitone, carrying
;
;     +0x400 = (note << 8) + 0x80 + C(recording) + 2*fine + detune
;
; where C is the constant belonging to the selected multisample. Two independent checks:
; decoding captured note-ons with C recovers an exact integer MIDI note for 83.8% of them
; on unambiguous selectors, against 22.0% for a C = 0 control (5956 events); and rendering
; the decoded notes gives a median MIDI note of 48.1 against 48.0 measured from a recording
; of a real KN5000 playing the same demo.
;
; Pan is a DIFFERENT register, +0x180, written from the staging word at 0x0451D8 with
; 0x0040 as centre.
ToneGen_WriteVoicePitch:
	push xiz
	ld xiz, xbc
	res	7, (P6:8)
	add wa, 0x400
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld wa, (xiz + 14)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoicePitch_NopCont

ToneGen_WriteVoicePitch_NopCont:
	nop
	nop
	nop
	pop xiz
	ret

; ** MISIDENTIFIED AS DATA (LLVM emits it as ToneGen_PanTable_02D0DC .byte). ** It is a
; standard single-register writer: WA = TG channel, XBC = shadow block; writes
; 0x0080 + ch <- (shadow +0x04) with bit15 CLEARED. Bit15 of the 0x0080 bank is the "load"
; strobe: ToneGen_WriteVoiceParams forces it SET with `set 0x0f,WA` at 0x02D145 (its write
; #2) and clears it again with `res 0x0f,WA` at 0x02D40A (its write #23). So this routine
; performs the "clear the strobe" half alone.
; (An earlier revision of this header gave 0x02D136 and 0x02D3F2. Both were wrong: 0x02D136
; is that write's ADDRESS-latch store `ld (0x100000),WA`, and 0x02D3F2 is the
; `res 7,(0x18)` that opens the final write.)
; Unreferenced in v142 (no call and no pointer to it anywhere in the ROM).
; ★ Renamed 2026-09-25 from ToneGen_PanTable_02D0DC: header: writes TG 0x0080+ch from shadow+0x04 with bit15 (the load strobe) cleared.
ToneGen_WriteReg0080_StrobeClear:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 128
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+4)
	res	15, wa
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteReg0080_StrobeClear_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteReg0080_StrobeClear_Next:
	nop
	nop
	nop
	pop	xiz
	ret

; ---------------------------------------------------------------------------------------
; ToneGen_WriteVoiceParams (0x02D101-0x02D41A, 794 bytes) -- THE IC303 PARAMETER-LATCH BURST
; Existing name kept; documentation only.
;
; In:  WA = tone-generator channel, 0..0x3F. XBC = long pointer to a 0x44-byte (34-word)
;      staging block. The routine reads 21 words at +0x02..+0x2A and nothing else, with
;      +0x04 read twice. Neither argument is range-checked -- see HAZARDS.
; Out: nothing. XBC and IZ come back unchanged; XWA is clobbered.
;
; THE BUS. IC303 is a register-indirect device on two word ports plus one hand-driven pin:
;
;     write 0x100000  = 16-bit REGISTER-ADDRESS latch
;     write 0x100002  = 16-bit DATA for the register last latched
;     read  0x100000  = the chip's status word. ToneGen_Read_Register (0x021023) is the only
;                       routine in the payload that reads it, and only two latch classes are
;                       ever read back: 0x0000..0x0003 -> the active-voice bitmap for that
;                       bank, 0x0180+ch -> that channel's envelope level.
;     P6.7 (SFR 0x18 bit 7) = an out-of-band select the firmware drives by hand
;
; SFR 0x18 is PORT 6 (shared/sfr_tmp94c241.s: `.equ P6, 0x18`); every INTE* register is at
; 0xE0..0xF0, so nothing about this pair masks an interrupt. RESET (0x01F924) does program
; the port -- `ldio 0x18,0xFF`, `ldio 0x1B,0x7F`, `ldio 0x1A,0x80`.
; [INFERENCE] that P6.7 is the CPU's A23 pin taken out of bus mode, i.e. that P6FC 0x7F
; leaves bits 0..6 as A16..A22 and makes bit 7 a plain port and P6CR 0x80 makes it an output.
; That is a bit-level reading of TMP94C241 registers for which this repo holds no datasheet
; and MAME models P6/P6CR/P6FC as SFR names only; symbols/proposals/subcpu-region-07.txt
; grades the same identification UNCERTAIN.
; STATIC SCAN of this file (grep over the source text, not a bus trace): every 0x10xxxx /
; 0x11xxxx access that is spelled as a direct address is preceded by a P6.7 write whose level
; matches bit 1 of that address -- LOW for 0x100000, HIGH for 0x100002 -- with no
; counter-example. Counts at the time of writing: 142 writes and 1 read at 0x100000, 140
; writes at 0x100002, and 4 keybed reads at 0x110000 / 0x110002. The scan has two blind
; spots, both of which occur in this file. (a) Register-indirect access:
; ToneGen_ReadPitch_AndScale loads the constant 0x00100002 into XWA and stores through it 36
; bytes later, across a call, so a text scan sees the port constant but not the bus cycle;
; (b) The dead routines ToneGen_WriteReg0840_Shadow2E and ToneGen_WriteVoice_TvfRegs_Dup spell
; the ports in decimal (1048576 / 1048578) and carry their P6.7 toggles as raw `.byte`.
; [INFERENCE] the chip needs the select valid before /CS, so the firmware presents it one
; instruction early and holds it across the cycle.
;
; ONE REGISTER WRITE. Every write is this shape:
;
;     res 7,(0x18)            ; select LOW
;     ld  wa,iz / add wa,BANK ; WA = register address = bank | channel
;     ld  (0x100000),WA
;     nop                     ; setup pad
;     set 7,(0x18)            ; select HIGH
;     ld  (0x100002),WA       ; WA = the data word, reloaded from the block via (xsp + 2)
;     jr  <next instruction>  ; pipeline flush (opcode 68 00, displacement 0)
;     nop / nop / nop         ; recovery pad
;
; Three writes vary from it: #2 and #23 insert `set 0x0f,WA` / `res 0x0f,WA` before the data
; store, and #13 omits the `add` (bank 0x0000) and stores an immediate. Every bank is a
; multiple of 0x40 and the channel is <= 0x3F, so the add acts as an OR: bits 5..0 = channel,
; bits 15..6 = register.
;
; NO HANDSHAKE, NO BUSY WAIT. 23 latch writes, 23 data writes, ZERO reads -- the routine
; never looks at the chip. No status bit is polled, no counter is kept, and there is no
; `ei`/`di`, no call and no conditional branch anywhere in 0x02D101..0x02D41A: the only flow
; control is the fixed padding above and the closing `ret` at 0x02D41A.
;
; ★ THE BOOT ROM RUNS THE SAME BURST WITH NO P6.7 AT ALL. HARDWARE_PARAM_BLOCK_WRITE
; (0xFF8D0A, subcpu/boot/kn5000_subcpu_boot.s) emits the same 23 writes, same order, same
; block offsets, same nop / jr / 3-nop padding -- and the whole boot ROM contains no
; `ldio 0x18`, no `ldio 0x1A`, no `ldio 0x1B` and no res/set of P6.7. On that path the pin
; sits at whatever reset leaves it and the transfer still works. Nothing here establishes why
; the payload toggles it on every word; the toggle may be redundant on real hardware. This is
; unresolved, and it is a second reason the P6.7 reading above is marked INFERENCE.
; The boot twin is likewise unconditional, but ITS caller HARDWARE_CALIBRATION_SEQUENCE
; (0xFF8C80) then polls a status word at 0x100004 up to 1000 times. The v1.42 payload never
; touches 0x100004 at all; 0x100000 and 0x100002 are its only TG ports.
;
; MEASURED IN EMULATION ONLY (harness in kn7000_mame, tools/kn5000_tgbus_trace.lua; organ
; demo, 65 gates): consecutive writes land ~3 us apart and ~31 us separate the mid-burst gate
; from the closing strobe. That is emulated TLCS-900 timing, not a hardware measurement, and
; nothing in this pass measured IC303's real setup/hold requirements or whether the padding
; has margin.
;
; THE BURST, IN ORDER. blk = XBC.
;
;    #   register       data                      notes
;    1   0x040 | ch     blk[+0x02]                recording selector -- BEFORE the strobe
;    2   0x080 | ch     blk[+0x04] | 0x8000       STROBE UP   (`set 0x0f,WA` @ 0x02D145)
;    3   0x0C0 | ch     blk[+0x06]
;    4   0x100 | ch     blk[+0x08]
;    5   0x140 | ch     blk[+0x0A]
;    6   0x180 | ch     blk[+0x0C]
;    7   0x400 | ch     blk[+0x0E]
;    8   0x440 | ch     blk[+0x10]
;    9   0x480 | ch     blk[+0x12]
;   10   0x4C0 | ch     blk[+0x14]
;   11   0x500 | ch     blk[+0x16]
;   12   0x800 | ch     blk[+0x18]
;   13   0x000 | ch     0x8100 IMMEDIATE          the gate command on the per-voice CONTROL
;                                                 register, mid-frame; never taken from the
;                                                 block (`ld (0x100002),0x8100` @ 0x02D2B4)
;   14   0x840 | ch     blk[+0x1A]
;   15   0x880 | ch     blk[+0x1C]
;   16   0x8C0 | ch     blk[+0x1E]
;   17   0x900 | ch     blk[+0x20]
;   18   0x940 | ch     blk[+0x22]
;   19   0x980 | ch     blk[+0x24]
;   20   0x9C0 | ch     blk[+0x26]
;   21   0xA00 | ch     blk[+0x28]
;   22   0xA40 | ch     blk[+0x2A]
;   23   0x080 | ch     blk[+0x04] & 0x7FFF       STROBE DOWN (`res 0x0f,WA` @ 0x02D40A)
;
; So: 23 writes to 22 DISTINCT registers. 0x080 is the only register written twice and
; blk[+0x04] the only word sent twice. blk[+0x00] is not read here (see THE BLOCK).
;
; THE MID-BURST 0x8100 lands on the per-voice CONTROL register (0x0000 + ch), the same
; register that word 0 of the block feeds. [INFERENCE] most likely the NOTE-ON gate, but that
; reading rests on position in the burst, not on a decoded field. Two facts about it, both
; from a scan of every bank-0x0000 access in the ROM:
;   - it is the literal 0x8100 at all three of its bank-0x0000 sites (here at 0x02D2B4, and
;     in ToneGen_WriteVoiceParams_Ext 0x02D6CA and _Ext2 0x02D777) -- never computed, and the
;     low byte is always 0x00. (0x8100 is also written five more times in this file, but to
;     banks 0x0540/0x0580/0x05C0, not to the control register.)
;   - this routine does NOT emit the block's own +0x00 word. On the voice-engine call sites
;     the control word arrives afterwards, from the live slot record +0x2D, through
;     ToneGen_WriteSingleReg (0x02D41B) -- see Voice_Build_GateCommand (0x025589) for the
;     command set and the demo capture (harness in kn7000_mame,
;     tools/rigs/kn5000_demo_capture.lua). _Ext and _Ext2 do both writes themselves.
;     Across the eight assembled call sites the pattern is not uniform: at three of them
;     (ToneGen_Config_Init and the two aux-pool routines at 0x0355xx) the word that follows
;     IS the block's own word 0 -- which is the actual proof that +0x00 is the control
;     word -- and at two others no control write follows in the same routine at all.
;
; THE BIT-15 STROBE. Bit 15 of the 0x080 word is a frame marker, not level data. Five
; independent places agree: this routine forces it set on write #2 and clear on write #23;
; the boot ROM's twin performs the same `set 15` / `res 15` on word +0x04 of the same record
; shape; Voice_Build_OutputLevel forces it set when it STAGES the word; the two ROM default
; records carry it already set (0x00F8D5 word 2 = 0x8000, 0x00F919 word 2 = 0x83FF); and the
; dead single-register writer at 0x02D0DC exists only to do the clear half.
; WHAT THE CHIP DOES BETWEEN THE EDGES IS NOT ESTABLISHED BY THE ROM. [INFERENCE], and the
; assumption MAME's HLE encodes: the framed writes are staged and commit on the falling edge.
; The ROM cannot separate that from "every write takes effect as it lands", and any model
; must respect two facts it does give: the 0x040 selector is written BEFORE the strobe rises,
; and the 0x8100 gate is written ten writes BEFORE it falls.
;
; THE BLOCK. Callers pass a 34-word (0x44-byte) record; only words 1..21 go out here.
;   word 0 (+0x00) is the value for register 0x000|ch. On the template-driven paths the
;     CALLER ships it itself right after this routine returns, via ToneGen_WriteSingleReg --
;     ToneGen_Config_Init (0x02DFCF), ToneGen_SetupPolyVoice (0x0355AD) and
;     ToneGen_SetupPercussionVoice (0x035656) all do exactly that.
;   At the main staging block 0x0451CC that word is never stored: all 47 references to
;     0x0451CC in this file -- and all 76 in original_ROMs/kn5000_subprogram_v142.rom.unidasm
;     -- are the single form `lda_24 xbc, 0x0451cc`, a pointer load. There is no store of any
;     addressing form, while every other word of the block, 0x0451CE..0x0451F6, does have
;     direct-address stores. Each of the 47 sites reaches a TG writer within one instruction
;     (45 call one immediately; 2 load XDE first, then call ToneGen_WriteVoiceParams_Ext).
;   words 22..33 (+0x2C..+0x42) complete the record shape and are not transmitted here; at
;     base 0x0451CC three of them are live -- see the staging-block table's RECORD TAIL note.
;
; BLOCK BASES ACTUALLY USED -- 9 call sites in the ROM: 8 assembled as call/calr, plus one
; that survives only as bytes inside the `.byte` blob ToneGen_ConfigInit_AltData:
;   0x0451CC  x5   main voice staging block (calls at 0x0273A0, 0x02B56E, 0x02BD7F,
;                  0x02C123, 0x02C448)
;   0x003B1C  x2   auxiliary 8-voice pool (0x035640, 0x0356B4)
;   caller's  x1   0x02E010 -- ToneGen_Config_Init passes (xsp + 2), the DRAM block at
;                  0x2AA4 that DSP_Config_Init `ldirw`s from the ROM template at 0x00F8D5
;   0x00F919  x1   0x02E0F7 -- the dormant liveness probe; unreachable in v1.42
;
; CROSS-CHECK against the staging-block table documented above Voice_Build_OutputLevel: the
; 21 transmitted words are exactly that table's 21 rows, in the table's own top-to-bottom
; order, one word each, 0x0451CE -> +0x040 through 0x0451F6 -> +0xA40. The table IS this
; burst read out sequentially. The map does not rest on this routine alone: the boot ROM
; annotates its own copy of the record field by field (ToneGen_ProbeVoice_ParamBlock at
; 0xFF824C, byte-identical to payload 0x00F919), labelling word 0 "TG reg 0x000" and words
; 1..21 as 0x040..0xA40 -- the same map, written down independently.
; A weaker corroboration, worth recording but NOT a test: ToneGen_Config_Init mutes a channel
; with two raw writes, 0x840|ch <- 0xFF00 and 0x800|ch <- 0xFF80, and then bursts a template
; whose words 13 and 12 are exactly those two values. It is only a value coincidence -- the
; same routine RE-MUTES immediately after the burst, so a shifted map would be invisible to
; the firmware, and 0xFF00 also appears at template words 14 and 23.
;
; HAZARDS for anyone implementing or emulating this:
;   * The channel is never masked here. `add wa,BANK` with a channel >= 0x40 would carry into
;     the register field. ToneGen_Config_Init gates its own loop with `cp iz,0x40`;
;     [INFERENCE] the remaining callers likewise pass a legal slot.
;   * Interrupts stay enabled for the whole burst and no lock is taken. The address latch is
;     a single shared register, so another TG writer entered from an interrupt between a
;     0x100000 write and its 0x100002 partner would mis-pair the two. That is the structure;
;     [INFERENCE] whether the race is reachable at run time was not established.
;   * `lds wa, 0` at 0x02D109 is dead code -- WA is reloaded from IZ two instructions later.
;
; This is the single biggest consumer of TG bandwidth in the firmware.
;
; The FIRST word of the burst -- register 0x0040 + ch -- is taken from shadow+0x02, and for
; the callers that pass the voice-engine block at 0x0451CC that word is 0x0451CE, the WAVE
; SELECTOR: (class << 12) | entry. Mind the scoping: this routine is SHARED and is reached
; with at least three shadow bases -- 0x0451CC (the voice-engine paths), 0x2AA4
; (ToneGen_Config_Init) and 0x3B1C (ToneGen_SetupPolyVoice, `lda_d16 xbc, 15132`) -- so
; shadow+0x02 = 0x0451CE holds for the first group only. For those callers that one word is
; the whole of what the firmware tells IC303 about which recording to play; [INFERENCE]
; IC303 resolves it itself, since no CPU on this machine can read the wave ROMs. See
; "WHAT +0x040 SELECTS" in the staging-block header for the directory format, the evidence
; that the walk is not done here, and the open questions.
ToneGen_WriteVoiceParams:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	ld wa, 0:i3
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x40
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 2)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont01

ToneGen_WriteVoiceParams_NopCont01:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x80
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 4)
	set 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont02

ToneGen_WriteVoiceParams_NopCont02:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0xC0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 6)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont03

ToneGen_WriteVoiceParams_NopCont03:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x100
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 8)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont04

ToneGen_WriteVoiceParams_NopCont04:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x140
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 10)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont05

ToneGen_WriteVoiceParams_NopCont05:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x180
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 12)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont06

ToneGen_WriteVoiceParams_NopCont06:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x400
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 14)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont07

ToneGen_WriteVoiceParams_NopCont07:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x440
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 16)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont08

ToneGen_WriteVoiceParams_NopCont08:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x480
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 18)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont09

ToneGen_WriteVoiceParams_NopCont09:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x4C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 20)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont10

ToneGen_WriteVoiceParams_NopCont10:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x500
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 22)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont11

ToneGen_WriteVoiceParams_NopCont11:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 24)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont12

ToneGen_WriteVoiceParams_NopCont12:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x8100
	jr ToneGen_WriteVoiceParams_NopCont13

ToneGen_WriteVoiceParams_NopCont13:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 26)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont14

ToneGen_WriteVoiceParams_NopCont14:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x880
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 28)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont15

ToneGen_WriteVoiceParams_NopCont15:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x8C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 30)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont16

ToneGen_WriteVoiceParams_NopCont16:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x900
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 32)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont17

ToneGen_WriteVoiceParams_NopCont17:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x940
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 34)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont18

ToneGen_WriteVoiceParams_NopCont18:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x980
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 36)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont19

ToneGen_WriteVoiceParams_NopCont19:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x9C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 38)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont20

ToneGen_WriteVoiceParams_NopCont20:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0xA00
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 40)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont21

ToneGen_WriteVoiceParams_NopCont21:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0xA40
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 42)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_NopCont22

ToneGen_WriteVoiceParams_NopCont22:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x80
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 4)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_Exit

ToneGen_WriteVoiceParams_Exit:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; Existing name kept. WA = full TG register address (NOT offset by a bank base), BC = 16-bit
; value.
;
; DESPITE THE GENERIC NAME IT IS THE CONTROL-REGISTER WRITER, and nothing else. All twelve call
; sites were read; every one passes WA = the bare physical slot number 0..0x3F, so the
; register selected is always (0x0000 + slot) -- the per-voice CONTROL/gate register:
;   Voice_TickNoteDecay (0x027363), Voice_SetPitch (0x02C6CD), Voice_NoteOff (0x02C7D7),
;   Voice_SetVelocity_Type0/_Type40/_Type80 Loop2Body, Voice_Reload_Levels branches A and C
;   (0x02CD71), ToneGen_Config_Init (0x02DFCF), and the dormant probe
;   ToneGen_SelfTest_ProbeVoice0 (call at 0x02E0FF).
; Eight of the ten pass BC = the word at 0x0430BB + slot*0x47 (live slot record +0x2D) --
; the HAND-OFF word, bit 15 SET, built by Voice_Build_GateCommand (0x025589) or its twin
; _NoPartial (0x0255F3), where the whole command set is documented. ToneGen_Config_Init
; passes word 0 of its 68-byte template (ROM 0x00F8D5, = 0x1200) and the dormant probe
; passes the literal 0xF000.
;
; ★ That ToneGen_Config_Init call is the proof that word 0 of a 68-byte parameter block IS
; the +0x000 control word: the block is handed to ToneGen_WriteVoiceParams, which emits
; +0x02 upwards, and word 0 is then sent here separately. The probe's own template at ROM
; 0x00F919 likewise starts with 0xF000, matching the literal it loads.
;
; MEASURED (demo capture, 1705 note-ons; harness in kn7000_mame,
; tools/rigs/kn5000_demo_capture.lua): the only hand-off values this register ever
; receives are F0FF, F000, F1D7 and F187, and their LOW BYTE is an output level (0xFF full,
; 0x00 silent). See Voice_Build_GateCommand for the value-by-value reconciliation.
; The bit-15-CLEARED counterpart is emitted by ToneGen_ReadPitch_AndScale (0x02E18D).
ToneGen_WriteSingleReg:
	pushw iz
	ld iz, bc
	res	7, (P6:8)
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld (ToneGen_RegDataPort:24), iz
	jr ToneGen_WriteSingleReg_NopCont

ToneGen_WriteSingleReg_NopCont:
	nop
	nop
	nop
	popw iz
	ret

; Existing curated name kept. WA = channel, XBC = shadow. Writes six envelope/level registers:
;   0x0840 <- +0x2E, 0x0940 <- +0x32, 0x0A00 <- +0x36, 0x0800 <- +0x2C, 0x0900 <- +0x30,
;   0x09C0 <- +0x34.
; (The LLVM build calls this ToneGen_WriteLevelBurst, which does not match the register set.)
ToneGen_WriteLevelBurst:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 46)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteLevelBurst_NopCont1

ToneGen_WriteLevelBurst_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x940
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 50)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteLevelBurst_NopCont2

ToneGen_WriteLevelBurst_NopCont2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0xA00
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 54)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteLevelBurst_NopCont3

ToneGen_WriteLevelBurst_NopCont3:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 44)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteLevelBurst_NopCont4

ToneGen_WriteLevelBurst_NopCont4:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x900
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 48)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteLevelBurst_NopCont5

ToneGen_WriteLevelBurst_NopCont5:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x9C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 52)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteLevelBurst_NopCont6

ToneGen_WriteLevelBurst_NopCont6:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; Existing curated name kept. Writes 0x0840+ch <- +0x2E and 0x0800+ch <- +0x2C. The two-register
; subset of ToneGen_WriteLevelBurst.
ToneGen_WriteLevelPair:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 46)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteLevelPair_NopCont1

ToneGen_WriteLevelPair_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 44)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteLevelPair_NopCont2

ToneGen_WriteLevelPair_NopCont2:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; ** MISIDENTIFIED AS DATA (LLVM: ToneGen_NoteTable_02D55E .byte). ** Single-register writer:
; WA = channel, XBC = shadow; 0x0840 + ch <- shadow +0x2E. Unreferenced in v142.
; ★ Renamed 2026-09-25 from ToneGen_NoteTable_02D55E: header: single-register writer, TG 0x0840+ch <- shadow+0x2E.
ToneGen_WriteReg0840_Shadow2E:
	push xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 2112
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+46)
	ld	(ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteReg0840_Shadow2E_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteReg0840_Shadow2E_Next:
	nop
	nop
	nop
	pop xiz
	ret
; ** Not present in either symbol source; it lives inside the same misidentified .byte blob. **
; WA = channel, XBC = shadow; writes 0x0100 + ch <- +0x08 and 0x0140 + ch <- +0x0A.
; Unreferenced in v142.
; ToneGen_WriteVoice_TvfRegs_Dup: Unreferenced, instruction-for-instruction copy of ToneGen_WriteVoice_Pan_Pair:
;   writes the voice's TVF (filter) register pair, TG 0x100+ch <- shadow +0x08 and 0x140+ch <- +0x0A. Basis: the live
;   twin's callers -- TVF_Refresh_Sounding_Voices (TVF_Refresh_Sounding_Voices) calls the twin right after
;   TVF_Emit_Registers / Voice_PanReg_WriteDispatchB have put the clamped cutoff word and the second filter word into
;   0x0451D4 / 0x0451D6 = staging +0x08 / +0x0A. (The twin's 'Pan' name is contradicted by the same evidence.)
ToneGen_WriteVoice_TvfRegs_Dup:
	dec	4, xsp
	pushw iz
	ld	(xsp+2), xbc
	ld	iz, wa
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 256
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+8)
	ld	(ToneGen_RegDataPort:24), wa
	jr ToneGen_Write_Regs0100_0140_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Write_Regs0100_0140_Next:
	nop
	nop
	nop
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 320
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+10)
	ld	(ToneGen_RegDataPort:24), wa
	jr ToneGen_Write_Regs0100_0140_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Write_Regs0100_0140_Next2:
	nop
	nop
	nop
	popw iz
	inc 4, xsp	; was mis-framed as `.byte 0xef` + `jr ov, 0x0e`: the bytes are ef 64 0e
	ret

; Existing curated name kept. Writes 0x0840+ch <- +0x1A and 0x0880+ch <- +0x1C.
ToneGen_WriteEnvSegments:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 26)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteEnvSegments_NopCont1

ToneGen_WriteEnvSegments_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x880
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 28)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteEnvSegments_NopCont2

ToneGen_WriteEnvSegments_NopCont2:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; Existing curated name kept, and it is accurate: 0x0840+ch and 0x0880+ch are BOTH written
; with the same shadow word +0x2E.
ToneGen_WriteSegRegs_SameLevel:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 46)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteSegRegs_SameLevel_NopCont1

ToneGen_WriteSegRegs_SameLevel_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x880
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 46)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteSegRegs_SameLevel_NopCont2

ToneGen_WriteSegRegs_SameLevel_NopCont2:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; Existing curated name kept. WA = channel, BC = value; writes 0x0180 + ch <- BC. Bank 0x0180
; is the same bank the hardware exposes for per-voice envelope-level READBACK (memory map:
; latch 0x0180+ch, read 0x100000).
ToneGen_WriteExprReg:
	pushw iz
	ld iz, bc
	res	7, (P6:8)
	add wa, 0x180
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld (ToneGen_RegDataPort:24), iz
	jr ToneGen_WriteExprReg_NopCont

ToneGen_WriteExprReg_NopCont:
	nop
	nop
	nop
	popw iz
	ret

; WA = channel, XDE = shadow A, XBC = shadow B. Four writes:
;   0x0800+ch <- A+0x3C, (0x0000+ch) <- 0x8100, 0x0840+ch <- A+0x3E,
;   0x0080+ch <- (B+0x04 with bit15 cleared), (0x0000+ch) <- A+0x2D.
; The last write is a real key-on: it pushes a 16-bit note word into bank 0x0000.
ToneGen_WriteVoiceParams_Ext:
	dec 8, xsp
	pushw iz
	ld (xsp + 2), xde
	ld (xsp + 6), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 60)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_Ext_NopCont1

ToneGen_WriteVoiceParams_Ext_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x8100
	jr ToneGen_WriteVoiceParams_Ext_NopCont2

ToneGen_WriteVoiceParams_Ext_NopCont2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 62)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_Ext_NopCont3

ToneGen_WriteVoiceParams_Ext_NopCont3:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x80
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 6)
	ld wa, (xwa + 4)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_Ext_NopCont4

ToneGen_WriteVoiceParams_Ext_NopCont4:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 45)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_Ext_NopCont5

ToneGen_WriteVoiceParams_Ext_NopCont5:
	nop
	nop
	nop
	popw iz
	inc 8, xsp
	ret

; One-shadow variant of the above: 0x0800+ch <- +0x3C, (0x0000+ch) <- 0x8100,
; 0x0840+ch <- +0x3E, (0x0000+ch) <- +0x2D. No 0x0080 write.
ToneGen_WriteVoiceParams_Ext2:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 60)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_Ext2_NopCont1

ToneGen_WriteVoiceParams_Ext2_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x8100
	jr ToneGen_WriteVoiceParams_Ext2_NopCont2

ToneGen_WriteVoiceParams_Ext2_NopCont2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 62)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_Ext2_NopCont3

ToneGen_WriteVoiceParams_Ext2_NopCont3:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 45)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteVoiceParams_Ext2_NopCont4

ToneGen_WriteVoiceParams_Ext2_NopCont4:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; Existing name kept. XWA = pointer to a 0x1A-byte GLOBAL config block (not per-voice).
; First it tests bit3 of the DRAM word at 0x041343 and forces bit3 of block word 0 to match
; (set when the flag is clear, cleared when it is set). Then it writes 13 global registers:
;   0x0200<-+0x00 0x0201<-+0x02 0x0202<-+0x04 0x0203<-+0x06 0x0204<-+0x08 0x0205<-+0x0A
;   0x0C00<-+0x0C 0x0C01<-+0x0E 0x0C02<-+0x10 0x0C03<-+0x12 0x0C04<-+0x14 0x0C05<-+0x16
;   0x0E00<-+0x18
; Called once, from DSP_CONFIG_INIT, with the ROM block at 0x00F8BB.
ToneGen_WriteGlobalConfig:
	push xiz
	ld xiz, xwa
	ld wa, (Voice_GlobalFlags:24)
	bit 3, wa
	jr z, ToneGen_WriteGlobalConfig_BranchA
	andmi16 (xiz), 0xFFF7
	jr ToneGen_WriteGlobalConfig_BranchB

ToneGen_WriteGlobalConfig_BranchA:
	ormi16 (xiz), 0x8

ToneGen_WriteGlobalConfig_BranchB:
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0200
	nop
	set	7, (P6:8)
	ld wa, (xiz)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont01

ToneGen_WriteGlobalConfig_NopCont01:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0201
	nop
	set	7, (P6:8)
	ld wa, (xiz + 2)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont02

ToneGen_WriteGlobalConfig_NopCont02:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0202
	nop
	set	7, (P6:8)
	ld wa, (xiz + 4)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont03

ToneGen_WriteGlobalConfig_NopCont03:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0203
	nop
	set	7, (P6:8)
	ld wa, (xiz + 6)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont04

ToneGen_WriteGlobalConfig_NopCont04:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0204
	nop
	set	7, (P6:8)
	ld wa, (xiz + 8)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont05

ToneGen_WriteGlobalConfig_NopCont05:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0205
	nop
	set	7, (P6:8)
	ld wa, (xiz + 10)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont06

ToneGen_WriteGlobalConfig_NopCont06:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0c00
	nop
	set	7, (P6:8)
	ld wa, (xiz + 12)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont07

ToneGen_WriteGlobalConfig_NopCont07:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0c01
	nop
	set	7, (P6:8)
	ld wa, (xiz + 14)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont08

ToneGen_WriteGlobalConfig_NopCont08:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0c02
	nop
	set	7, (P6:8)
	ld wa, (xiz + 16)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont09

ToneGen_WriteGlobalConfig_NopCont09:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0c03
	nop
	set	7, (P6:8)
	ld wa, (xiz + 18)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont10

ToneGen_WriteGlobalConfig_NopCont10:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0c04
	nop
	set	7, (P6:8)
	ld wa, (xiz + 20)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont11

ToneGen_WriteGlobalConfig_NopCont11:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0c05
	nop
	set	7, (P6:8)
	ld wa, (xiz + 22)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont12

ToneGen_WriteGlobalConfig_NopCont12:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw (ToneGen_RegAddrLatch:24), 0x0e00
	nop
	set	7, (P6:8)
	ld wa, (xiz + 24)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteGlobalConfig_NopCont13

ToneGen_WriteGlobalConfig_NopCont13:
	nop
	nop
	nop
	pop xiz
	ret

; ** MISIDENTIFIED AS DATA (LLVM: ToneGen_GlobalConfigTable_02D93E .byte). It is not a table;
; it is the first of five single/double register writers packed into that blob. **
; WA = channel, XBC = shadow; writes 0x0440+ch <- +0x10 and 0x0480+ch <- +0x12. Unreferenced.
; ★ Renamed 2026-09-25 from ToneGen_GlobalConfigTable_02D93E: header: writes TG 0x0440+ch <- +0x10 and 0x0480+ch <- +0x12.
ToneGen_WriteReg0440_0480:
	dec	4, xsp
	pushw	iz
	ld	(xsp+2), xbc
	ld	iz, wa
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1088
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+16)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteReg0440_0480_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteReg0440_0480_Next:
	nop
	nop
	nop
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1152
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+18)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteReg0440_0480_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteReg0440_0480_Next2:
	nop
	nop
	nop
	popw	iz
	inc	4, xsp
	ret
; Inside the same misidentified blob; no symbol in either source. WA = channel, XBC = shadow;
; writes 0x0180 + ch <- +0x0C. Unreferenced in v142.
ToneGen_Write_Reg0180:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 384
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+12)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_Write_Reg0180_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Write_Reg0180_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Same blob. Writes 0x0440 + ch <- shadow +0x10. Unreferenced in v142.
ToneGen_Write_Reg0440:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1088
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+16)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_Write_Reg0440_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Write_Reg0440_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Same blob. Writes 0x0480 + ch <- shadow +0x12. Unreferenced in v142.
ToneGen_Write_Reg0480:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1152
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+18)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_Write_Reg0480_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Write_Reg0480_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Same blob. Writes 0x04C0 + ch <- shadow +0x14. Unreferenced in v142.
ToneGen_Write_Reg04C0:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1216
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+20)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_Write_Reg04C0_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Write_Reg04C0_Next:
	nop
	nop
	nop
	pop	xiz
	ret

; Existing name kept. WA = channel, XBC = shadow. The "strobed pair" pattern used by every
; ExtParams routine:
;   if (shadow+0x3C) bit15 is set:  0x0580+ch <- +0x3C  (strobe asserted)
;   always:                         0x0600+ch <- +0x40
;   always:                         0x0580+ch <- +0x3C with bit15 CLEARED (strobe released)
; So bit15 of the 0x0540/0x0580/0x05C0 banks is a load/trigger bit that software raises and
; lowers around the companion register write.
ToneGen_WriteExtParams_56:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	ld xwa, (xsp + 2)
	ld wa, (xwa + 60)
	bit 15, wa
	jr z, ToneGen_WriteExtParams_56_BranchSkip
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x580
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 60)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_56_NopCont1

ToneGen_WriteExtParams_56_NopCont1:
	nop
	nop
	nop

ToneGen_WriteExtParams_56_BranchSkip:
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x600
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 64)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_56_NopCont2

ToneGen_WriteExtParams_56_NopCont2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x580
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 60)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_56_NopCont3

ToneGen_WriteExtParams_56_NopCont3:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; WA = channel, XBC = shadow; writes 0x0600 + ch <- +0x40 only.
ToneGen_WriteExtParam_600:
	push xiz
	ld xiz, xbc
	res	7, (P6:8)
	add wa, 0x600
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld wa, (xiz + 64)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParam_600_NopCont

ToneGen_WriteExtParam_600_NopCont:
	nop
	nop
	nop
	pop xiz
	ret

; ToneGen_WriteExtParams_56 without the 0x0600 write: raises then releases the bit15 strobe on
; 0x0580 + ch using shadow +0x3C.
ToneGen_WriteExtParams_56_Alt:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	ld xwa, (xsp + 2)
	ld wa, (xwa + 60)
	bit 15, wa
	jr z, ToneGen_WriteExtParams_56_Alt_ClearPath
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x580
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 60)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_56_Alt_NopCont1

ToneGen_WriteExtParams_56_Alt_NopCont1:
	nop
	nop
	nop

ToneGen_WriteExtParams_56_Alt_ClearPath:
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x580
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 60)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_56_Alt_NopCont2

ToneGen_WriteExtParams_56_Alt_NopCont2:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; WA = channel. Writes the literal 0x8100 to 0x0580 + ch. 0x8100 is the constant this whole
; family uses to mean "release/mute this slot"; it also appears mid-burst in
; ToneGen_WriteVoiceParams and in the EXT writers, always aimed at a strobed bank.
ToneGen_WriteExtParam_600_Mute:
	res	7, (P6:8)
	add wa, 0x580
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x8100
	jr ToneGen_WriteExtParam_600_Mute_NopCont

ToneGen_WriteExtParam_600_Mute_NopCont:
	nop
	nop
	nop
	ret

; Existing name kept. Identical to ToneGen_WriteExtParams_56 but on the second bank pair:
; strobe on 0x05C0 + ch from shadow +0x3E, companion write 0x0640 + ch <- +0x42.
ToneGen_WriteExtParams_56b:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	ld xwa, (xsp + 2)
	ld wa, (xwa + 62)
	bit 15, wa
	jr z, ToneGen_WriteExtParams_56b_ClearPath
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x5C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 62)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_56b_NopCont1

ToneGen_WriteExtParams_56b_NopCont1:
	nop
	nop
	nop

ToneGen_WriteExtParams_56b_ClearPath:
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x640
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 66)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_56b_NopCont2

ToneGen_WriteExtParams_56b_NopCont2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x5C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 62)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_56b_NopCont3

ToneGen_WriteExtParams_56b_NopCont3:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; ** MISIDENTIFIED AS DATA (LLVM: ToneGen_ExtParams56b_DataTable .byte) BUT IT IS LIVE: it is
; CALLed from 0x027D43 and that call is the only reference to it in the ROM. **
; WA = channel, XBC = shadow; writes 0x0640 + ch <- shadow +0x42.
; ★ Renamed 2026-09-25 from ToneGen_ExtParams56b_DataTable: header: writes TG 0x0640+ch <- shadow+0x42.
ToneGen_WriteReg0640:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 1600
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+66)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteReg0640_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteReg0640_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; Second routine inside the 0x02DBB3 blob; no symbol in either source. Raises then releases the
; bit15 strobe on 0x05C0 + ch using shadow +0x3E (the 0x05C0 twin of 0x02DAB8). Readers below.
; Readers (claims_lint.py unread-claims, 2026-10-02): kn5000_subprogram_v142.s:17453 (source
;   reference)
ToneGen_Write_ExtParam_05C0_Strobe:
	dec	4, xsp
	pushw	iz
	ld	(xsp+2), xbc
	ld	iz, wa
	ld	xwa, (xsp+2)
	ld	wa, (xwa+62)
	bit	15, wa
	jr	z, ToneGen_Write_ExtParam_05C0_Strobe_Skip
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1472
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+62)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_Write_ExtParam_05C0_Strobe_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Write_ExtParam_05C0_Strobe_Next:
	nop
	nop
	nop
ToneGen_Write_ExtParam_05C0_Strobe_Skip:
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1472
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+62)
	res	15, wa
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_Write_ExtParam_05C0_Strobe_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Write_ExtParam_05C0_Strobe_Next2:
	nop
	nop
	nop
	popw	iz
	inc	4, xsp
	ret
; Third routine in the same blob. Writes 0x8100 to 0x05C0 + ch. Unreferenced in v142.
ToneGen_Mute_Reg05C0:
	res	7, (P6:8)
	add	wa, 1472
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw	(ToneGen_RegDataPort:24), 33024
	jr	ToneGen_Mute_Reg05C0_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_Mute_Reg05C0_Next:
	nop
	nop
	nop
	ret

; Existing name kept. Strobe on 0x0540 + ch from shadow +0x3A, companion write
; 0x01C0 + ch <- shadow +0x38.
ToneGen_WriteExtParams_15:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	bit 15, wa
	jr z, ToneGen_WriteExtParams_15_ClearPath
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x540
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_15_NopCont1

ToneGen_WriteExtParams_15_NopCont1:
	nop
	nop
	nop

ToneGen_WriteExtParams_15_ClearPath:
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x1C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 56)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_15_NopCont2

ToneGen_WriteExtParams_15_NopCont2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x540
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_15_NopCont3

ToneGen_WriteExtParams_15_NopCont3:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; WA = channel, XBC = shadow; writes 0x01C0 + ch <- +0x38 only.
ToneGen_WriteExtParam_1C0_Single:
	push xiz
	ld xiz, xbc
	res	7, (P6:8)
	add wa, 0x1C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld wa, (xiz + 56)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParam_1C0_Single_NopCont

ToneGen_WriteExtParam_1C0_Single_NopCont:
	nop
	nop
	nop
	pop xiz
	ret

; Raises then releases the bit15 strobe on 0x0540 + ch from shadow +0x3A; no companion write.
ToneGen_WriteExtParams_15_Alt:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	bit 15, wa
	jr z, ToneGen_WriteExtParams_15_Alt_ClearPath
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x540
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_15_Alt_NopCont1

ToneGen_WriteExtParams_15_Alt_NopCont1:
	nop
	nop
	nop

ToneGen_WriteExtParams_15_Alt_ClearPath:
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x540
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_15_Alt_NopCont2

ToneGen_WriteExtParams_15_Alt_NopCont2:
	nop
	nop
	nop
	popw iz
	inc 4, xsp
	ret

; Writes 0x8100 to 0x0540 + ch.
ToneGen_WriteExtParam_540_Mute:
	res	7, (P6:8)
	add wa, 0x540
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x8100
	jr ToneGen_WriteExtParam_540_Mute_NopCont

ToneGen_WriteExtParam_540_Mute_NopCont:
	nop
	nop
	nop
	ret

; ** MISIDENTIFIED AS DATA (LLVM: ToneGen_ExtParams15_DataTable .byte) BUT IT IS LIVE: CALLed
; from 0x02F80F, the only reference to it in the ROM. **
; WA = channel, XBC = shadow. Channel-banked version of ToneGen_WriteExtParams_15:
;   ch <  0x40 -> strobe 0x0540+ch from +0x3A, companion 0x01C0+ch <- +0x38
;   ch >= 0x40 -> strobe 0x0580+ch from +0x3E, companion 0x0600+ch <- +0x42
; This is the clearest statement in the firmware that the TG has TWO channel banks split at
; channel 0x40 and that the second bank uses a different register-base set.
; ★ Renamed 2026-09-25 from ToneGen_ExtParams15_DataTable: header: channel-banked version of ToneGen_WriteExtParams_15 (bank split at ch 0x40).
ToneGen_WriteExtParams_15_Banked:
	dec	4, xsp
	pushw	iz
	ld	(xsp+2), xbc
	ld	iz, wa
	cp	iz, 64
	jr	nc, ToneGen_WriteExtParams_15_Banked_Skip2
	ld	xwa, (xsp+2)
	ld	wa, (xwa+58)
	bit	15, wa
	jr	z, ToneGen_WriteExtParams_15_Banked_Skip
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1344
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+58)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteExtParams_15_Banked_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteExtParams_15_Banked_Next:
	nop
	nop
	nop
ToneGen_WriteExtParams_15_Banked_Skip:
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 448
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+56)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteExtParams_15_Banked_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteExtParams_15_Banked_Next2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1344
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+58)
	res	15, wa
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteExtParams_15_Banked_Next3	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteExtParams_15_Banked_Next3:
	nop
	nop
	nop
	jr	ToneGen_WriteExtParams_15_Banked_Epilogue
ToneGen_WriteExtParams_15_Banked_Skip2:
	ld	xwa, (xsp+2)
	ld	wa, (xwa+62)
	bit	15, wa
	jr	z, ToneGen_WriteExtParams_15_Banked_Skip3
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1408
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+62)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteExtParams_15_Banked_Next4	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteExtParams_15_Banked_Next4:
	nop
	nop
	nop
ToneGen_WriteExtParams_15_Banked_Skip3:
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1536
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+66)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteExtParams_15_Banked_Next5	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteExtParams_15_Banked_Next5:
	nop
	nop
	nop
	res	7, (P6:8)
	ld	wa, iz
	add	wa, 1408
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	xwa, (xsp+2)
	ld	wa, (xwa+62)
	res	15, wa
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteExtParams_15_Banked_Next6	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteExtParams_15_Banked_Next6:
	nop
	nop
	nop
ToneGen_WriteExtParams_15_Banked_Epilogue:
	popw	iz
	inc	4, xsp
	ret

; WA = channel, XBC = shadow. ch < 0x40 -> 0x01C0+ch <- +0x38; ch >= 0x40 -> 0x0600+ch <- +0x42.
ToneGen_WriteExtParam_TypeDispatch_Single:
	push xiz
	ld xiz, xbc
	cp wa, 0x40
	jr nc, ToneGen_WriteExtParam_TypeDispatch_Single_HiPath
	res	7, (P6:8)
	add wa, 0x1C0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld wa, (xiz + 56)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParam_TypeDispatch_Single_NopCont1

ToneGen_WriteExtParam_TypeDispatch_Single_NopCont1:
	nop
	nop
	nop
	jr ToneGen_WriteExtParam_TypeDispatch_Single_Exit

ToneGen_WriteExtParam_TypeDispatch_Single_HiPath:
	res	7, (P6:8)
	add wa, 0x600
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld wa, (xiz + 66)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParam_TypeDispatch_Single_NopCont2

ToneGen_WriteExtParam_TypeDispatch_Single_NopCont2:
	nop
	nop
	nop

ToneGen_WriteExtParam_TypeDispatch_Single_Exit:
	pop xiz
	ret

; WA = channel, XBC = shadow. Strobe-only banked writer: ch < 0x40 strobes 0x0540 from +0x3A,
; ch >= 0x40 strobes 0x0580 from +0x3E. No companion register write in either path.
ToneGen_WriteExtParams_TypeDispatch:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xbc
	ld iz, wa
	cp iz, 0x40
	jr nc, ToneGen_WriteExtParams_TypeDispatch_HiPath
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	bit 15, wa
	jr z, ToneGen_WriteExtParams_TypeDispatch_LoClearPath
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x540
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_TypeDispatch_NopCont1

ToneGen_WriteExtParams_TypeDispatch_NopCont1:
	nop
	nop
	nop

ToneGen_WriteExtParams_TypeDispatch_LoClearPath:
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x540
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 58)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_TypeDispatch_NopCont2

ToneGen_WriteExtParams_TypeDispatch_NopCont2:
	nop
	nop
	nop
	jr ToneGen_WriteExtParams_TypeDispatch_Exit

ToneGen_WriteExtParams_TypeDispatch_HiPath:
	ld xwa, (xsp + 2)
	ld wa, (xwa + 62)
	bit 15, wa
	jr z, ToneGen_WriteExtParams_TypeDispatch_HiClearPath
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x580
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 62)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_TypeDispatch_NopCont3

ToneGen_WriteExtParams_TypeDispatch_NopCont3:
	nop
	nop
	nop

ToneGen_WriteExtParams_TypeDispatch_HiClearPath:
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x580
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 2)
	ld wa, (xwa + 62)
	res 15, wa
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_WriteExtParams_TypeDispatch_NopCont4

ToneGen_WriteExtParams_TypeDispatch_NopCont4:
	nop
	nop
	nop

ToneGen_WriteExtParams_TypeDispatch_Exit:
	popw iz
	inc 4, xsp
	ret

; WA = channel. Writes 0x8100 to 0x0540 + ch (ch < 0x40) or to 0x0580 + ch (ch >= 0x40).
ToneGen_WriteExtParam_Mute_TypeDispatch:
	cp wa, 0x40
	jr nc, ToneGen_WriteExtParam_Mute_TypeDispatch_HiPath
	res	7, (P6:8)
	add wa, 0x540
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x8100
	jr ToneGen_WriteExtParam_Mute_TypeDispatch_NopCont1

ToneGen_WriteExtParam_Mute_TypeDispatch_NopCont1:
	nop
	nop
	nop
	ret

ToneGen_WriteExtParam_Mute_TypeDispatch_HiPath:
	res	7, (P6:8)
	add wa, 0x580
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x8100
	jr ToneGen_WriteExtParam_Mute_TypeDispatch_NopCont2

ToneGen_WriteExtParam_Mute_TypeDispatch_NopCont2:
	nop
	nop
	nop
	ret

; Existing name kept, but see [UNCERTAIN] -- this routine initialises the TONE GENERATOR, not a
; DSP. Called once, from 0x034CBA.
; Sequence: ToneGen_WriteGlobalConfig(ROM 0x00F8BB) to program the 13 global registers, then
; ldirw 0x22 words from ROM 0x00F8D5 into DRAM 0x2AA4 (the default voice-parameter shadow),
; then loop channel 0..0x3F running ToneGen_Config_Init.
DSP_Config_Init:
	dec 4, xsp
	pushw iz
	lda xwa, (ToneGen_GlobalConfig_Defaults:24)
	calr ToneGen_WriteGlobalConfig
	lda xwa, (10916:16)
	ld (xsp + 2), xwa
	ld xiy, ToneGen_VoiceParamShadow_Defaults
	ld xix, xwa
	ldw bc, 0x22
	ldirw
	ld iz, 0:i3
	cp iz, 0x40
	jrl nc, ToneGen_ConfigInit_Return

; Existing name kept. The per-channel body of DSP_CONFIG_INIT (IZ = channel, (XSP+2) = the
; 0x2AA4 template). For each channel:
;   mute       0x0840+ch <- 0xFF00, 0x0800+ch <- 0xFF80
;   program    ToneGen_WriteVoiceParams(ch, 0x2AA4); ToneGen_WriteSingleReg(ch, word@0x2AA4)
;   mute again 0x0840+ch <- 0xFF00, 0x0800+ch <- 0xFF80
;   clear      0x00C0+ch <- 0x0000
;   FREE       (0x0000+ch) <- 0x7E00      <-- the documented "free a voice" command
;   then ToneGen_WriteExtParams_15, _56 and _56b on the same channel.
; After this runs, all 64 TG voices are silent, freed and holding the default parameter set.
ToneGen_Config_Init:
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr ToneGen_Config_Init_NopCont1

ToneGen_Config_Init_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr ToneGen_ConfigInit_WriteVoiceRegs

ToneGen_ConfigInit_WriteVoiceRegs:
	nop
	nop
	nop
	ld wa, iz
	ld xbc, (xsp + 2)
	calr ToneGen_WriteVoiceParams
	ld wa, iz
	ld xbc, (xsp + 2)
	ld bc, (xbc)
	calr ToneGen_WriteSingleReg
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr ToneGen_ConfigInit_WriteAddr800

ToneGen_ConfigInit_WriteAddr800:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr ToneGen_ConfigInit_WriteAddrC0

ToneGen_ConfigInit_WriteAddrC0:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	add wa, 0xC0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x0000
	jr ToneGen_ConfigInit_WriteAddr00

ToneGen_ConfigInit_WriteAddr00:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x7e00
	jr ToneGen_ConfigInit_WriteExtParams

ToneGen_ConfigInit_WriteExtParams:
	nop
	nop
	nop
	ld wa, iz
	ld xbc, (xsp + 2)
	calr ToneGen_WriteExtParams_15
	ld wa, iz
	ld xbc, (xsp + 2)
	calr ToneGen_WriteExtParams_56
	ld wa, iz
	ld xbc, (xsp + 2)
	calr ToneGen_WriteExtParams_56b
	inc 1, iz
	cp iz, 0x40
	jrl c, ToneGen_Config_Init

ToneGen_ConfigInit_Return:
	popw iz
	inc 4, xsp
	ret

; ** MISIDENTIFIED AS DATA (LLVM: ToneGen_ConfigInit_AltData .byte). It is code, and it is the
; only bounded TG-status polling loop in this region. It is UNREFERENCED in v142 -- no call
; and no pointer to it anywhere in the ROM -- so it is dormant diagnostic code. **
; Takes no argument, returns HL = an iteration count. Body:
;   1. mute voice 0: 0x0840 <- 0xFF00, 0x0800 <- 0xFF80
;   2. ToneGen_WriteVoiceParams(ch 0, ROM block 0x00F919); ToneGen_WriteSingleReg(0, 0xF000)
;   3. poll up to 0x3E8 (1000) times: call 0x021023 with WA = 0; if it returns HL != 0 (i.e.
;      the TG reports voice 0 active) re-mute voice 0 and leave the loop; otherwise increment
;      the counter and retry. IZ starts at 0xFFFF and the counter lives in QIZ.
;   4. 0x00C0 <- 0x0000, then (0x0000) <- 0x7E00 to free voice 0.
;   5. return HL = the number of polls consumed (0x3E8 == the TG never reported the voice).
; ToneGen_Read_Register (0x021023) is the ONLY place the TG active-voice bitmap re-enters
; sub-CPU software. This routine is the firmware's own "is the tone generator alive?" probe
; and is worth re-enabling in a debug build. See findings.
; ★ Renamed 2026-09-25 from ToneGen_ConfigInit_AltData: header: the dormant 'is the tone generator alive?' probe that polls voice 0.
ToneGen_SelfTest_ProbeVoice0:
	push	xiz
	ldw	iz, 65535
	res	7, (P6:8)
	ldw	(ToneGen_RegAddrLatch:24), 2112
	nop
	set	7, (P6:8)
	ldw	(ToneGen_RegDataPort:24), 65280
	jr	ToneGen_SelfTest_ProbeVoice0_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_SelfTest_ProbeVoice0_Next:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw	(ToneGen_RegAddrLatch:24), 2048
	nop
	set	7, (P6:8)
	ldw	(ToneGen_RegDataPort:24), 65408
	jr	ToneGen_SelfTest_ProbeVoice0_Next2	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_SelfTest_ProbeVoice0_Next2:
	nop
	nop
	nop
	lda	xwa, (ToneGen_ProbeVoice_ParamBlock:24)
	ld	xbc, xwa
	ld	wa, 0:i3
	calr	ToneGen_WriteVoiceParams
	ld	wa, 0:i3
	ldw	bc, 61440
	calr	ToneGen_WriteSingleReg
	cpw	qiz, 1000
	jr	nc, ToneGen_SelfTest_ProbeVoice0_Join
ToneGen_SelfTest_ProbeVoice0_Loop:
	ld	wa, 0:i3
	call	ToneGen_Read_Register
	cp	hl, 0:i3
	jr	z, ToneGen_SelfTest_ProbeVoice0_Skip
	ld	iz, 0:i3
	res	7, (P6:8)
	ldw	(ToneGen_RegAddrLatch:24), 2112
	nop
	set	7, (P6:8)
	ldw	(ToneGen_RegDataPort:24), 65280
	jr	ToneGen_SelfTest_ProbeVoice0_Next3	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_SelfTest_ProbeVoice0_Next3:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw	(ToneGen_RegAddrLatch:24), 2048
	nop
	set	7, (P6:8)
	ldw	(ToneGen_RegDataPort:24), 65408
	jr	ToneGen_SelfTest_ProbeVoice0_Next4	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_SelfTest_ProbeVoice0_Next4:
	nop
	nop
	nop
	jr	ToneGen_SelfTest_ProbeVoice0_Join
ToneGen_SelfTest_ProbeVoice0_Skip:
	inc	1, qiz
	cpw	qiz, 1000
	jr	c, ToneGen_SelfTest_ProbeVoice0_Loop
ToneGen_SelfTest_ProbeVoice0_Join:
	res	7, (P6:8)
	ldw	(ToneGen_RegAddrLatch:24), 192
	nop
	set	7, (P6:8)
	ldw	(ToneGen_RegDataPort:24), 0
	jr	ToneGen_SelfTest_ProbeVoice0_Next5	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_SelfTest_ProbeVoice0_Next5:
	nop
	nop
	nop
	res	7, (P6:8)
	ldw	(ToneGen_RegAddrLatch:24), 0
	nop
	set	7, (P6:8)
	ldw	(ToneGen_RegDataPort:24), 32256
	jr	ToneGen_SelfTest_ProbeVoice0_Next6	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_SelfTest_ProbeVoice0_Next6:
	nop
	nop
	nop
	ld	hl, iz
	pop	xiz
	ret

; WA = TG channel, XBC = shadow block. Two writes, no reads of any kind:
;   0x00C0 + ch <- shadow +0x06
;   (0x0000 + ch) <- the word at 0x0430BB + ch*0x47 (voice struct +0x2D) with bit15 CLEARED
; The second write is performed by loading the constant 0x00100002 into a register and storing
; through it, which is why an automatic pass could mistake it for a read. The channel-to-struct
; index multiply uses Math_Multiply32 (0x03D8CA) with XBC = 0x47.
; The LLVM name ToneGen_ReadPitch_AndScale is wrong on both counts; see [UNCERTAIN].
; Called from 0x028D14.
ToneGen_ReadPitch_AndScale:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xbc
	ld iz, wa
	res	7, (P6:8)
	ld wa, iz
	add wa, 0xC0
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, (xsp + 6)
	ld wa, (xwa + 6)
	ld (ToneGen_RegDataPort:24), wa
	jr ToneGen_ReadPitch_Compute

ToneGen_ReadPitch_Compute:
	nop
	nop
	nop
	res	7, (P6:8)
	ld wa, iz
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld xwa, 0x100002
	ld (xsp + 2), xwa
	ld wa, iz
	extz xwa
	ld xbc, 0x47
	call Math_Multiply32
	lda xwa, (Payload_Bss_Start+0x4245:24)
	add xwa, xhl
	ld bc, (xwa)
	res 15, bc
	ld xwa, (xsp + 2)
	ld (xwa), bc
	jr ToneGen_ReadPitch_Return

ToneGen_ReadPitch_Return:
	nop
	nop
	nop
	popw iz
	inc 8, xsp
	ret

; --- CheckStatusBits_Zero: Check if status bits [7:6] are zero ---
; Entry: WA = index
; Exit: HL = 1 if status bits are 0b00, else HL = 0
; WA = part index. Computes 0x04136E + part*0x11F via Math_Multiply32(0x11F), dereferences the
; long stored there (the tone-header pointer), reads header byte +0x10, masks 0xC0 and returns
; HL = 1 when the part mode is 0x00, else 0 (scc Z,HL). Unreferenced in v142.
CheckStatusBits_Zero:
	extz	xwa
	ld	xbc, 0x11f
	call	Math_Multiply32
	lda	xwa, (Part_PatchRecord_Ptr:24)
	add	xwa, xhl
	ld	xwa, (xwa)
	ld	a, (xwa+16)
	and	a, 0xc0
	cp	a, 0:i3
	scc16	z, hl
	ret

; Identical predicate for part mode 0x40. Called from 0x0317F2 and 0x035BC8 -- the only member
; of this family of four with live callers.
CheckStatusBits_40:
	extz xwa
	ld xbc, 0x11F
	call Math_Multiply32
	lda xwa, (Part_PatchRecord_Ptr:24)
	add xwa, xhl
	ld xwa, (xwa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0x40
	scc16 z, hl
	ret

; --- CheckStatusBits_80: Check if status bits [7:6] are 0b10 ---
; Entry: WA = index
; Exit: HL = 1 if status bits are 0x80, else HL = 0
; Identical predicate for part mode 0x80. Unreferenced in v142.
CheckStatusBits_80:
	extz	xwa
	ld	xbc, 287
	call	Math_Multiply32
	lda	xwa, (Part_PatchRecord_Ptr:24)
	add	xwa, xhl
	ld	xwa, (xwa)
	ld	a, (xwa+16)
	and	a, 192
	cp	a, 128
	scc16	z, hl
	ret
; --- CheckStatusBits_C0: Check if status bits [7:6] are 0b11 ---
; ** Has no symbol in the reference file OR the LLVM build -- it is the fourth, unnamed member
; of the part-mode predicate family. ** Identical predicate for part mode 0xC0.
; Unreferenced in v142.
Voice_Part_Mode_Is_C0:
	extz	xwa
	ld	xbc, 287
	call	Math_Multiply32
	lda	xwa, (Part_PatchRecord_Ptr:24)
	add	xwa, xhl
	ld	xwa, (xwa)
	ld	a, (xwa+16)
	and	a, 192
	cp	a, 192
	scc16	z, hl
	ret

; The region's block-copy helper. XWA = source, XBC = destination, DE = BYTE count (returns
; immediately when DE == 0). Copies with post-incrementing byte loads/stores through XHL.
; The LLVM name BlockCopy_Words_BC_to_HL is doubly wrong -- the transfers are byte-sized and
; the destination is XBC, not XHL. Used by all five VOICEPARAM_*_LOAD_* routines below.
BlockCopy_Words_BC_to_HL:
	ld xhl, xbc
	ld ix, 0:i3
	cp ix, de
	ret nc

BlockCopy_Words_BC_to_HL_Loop:
	ld C, (xwa+)
	ld (xhl+), c
	inc 1, ix
	cp ix, de
	jr c, BlockCopy_Words_BC_to_HL_Loop
	ret

; A = part index. Populates the tone staging buffer at 0x044FCE:
;   0x66 bytes from the pointer at part+0x06        -> 0x044FCE + 0x0000
;   for i = 0..3: 0x51 bytes from the pointer at part + 0x6E + i*0x25 -> 0x044FCE + 0x66 + i*0x51
; That fixes the staging layout used everywhere else in the region.
VoiceStruct_BulkInit:
	dec 2, xsp
	pushw_erp 0xFA
	ld (xsp + 2), a
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xde, (xbc+wa)
	lda xwa, (Payload_Bss_Start+0x6158:24)
	ld xbc, xwa
	ld xwa, xde
	ldw de, 0x66
	calr BlockCopy_Words_BC_to_HL
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jr nc, VoiceStruct_BulkInit_Return

VoiceStruct_BulkInit_SubSlotLoop:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	ld	xde, (xwa+de)
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x51
	add wa, 0x66
	lda xbc, (Payload_Bss_Start+0x6158:24)
	exts xwa
	add xwa, xbc
	ld xbc, xwa
	ld xwa, xde
	ldw de, 0x51
	calr BlockCopy_Words_BC_to_HL
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jr c, VoiceStruct_BulkInit_SubSlotLoop

VoiceStruct_BulkInit_Return:
	popw_erp 0xFA
	inc 2, xsp
	ret

; ** MISIDENTIFIED AS DATA in the reference file / emitted with decimal literals in the LLVM
; source under the name VoiceStruct_BulkInit_AltData; it is ordinary code. ** Called from
; 0x02EA1F.
; A = catalogue index, C = a second index, E = custom-tone slot (saved on the stack). Calls
; ToneDB_Resolve_NamedToneRecord (0x032A08) to obtain XHL = the source record, then copies
; (0x045314)[0xEE] bytes into (0x04531C) + slot*0x50 + 0x4AA7 using MEMCPY_BYTES_XWA_TO_XBC.
; ★ Renamed 2026-09-25 from VoiceStruct_BulkInit_AltData: header: copies a resolved tone record (0xEE bytes) into a custom-tone slot.
CustomTone_CopyToneRecord:
	dec	2, xsp
	ld	(xsp), e
	ld	l, a
	extz	hl
	extz	bc
	ld	a, (xsp)
	ld	e, a
	extz	de
	pushw 255
	ld	wa, hl
	call	ToneDB_Resolve_NamedToneRecord
	ld	a, (xsp)
	extz	wa
	muls	wa, 80
	ld	bc, wa
	add	bc, 19111
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xwa, (xwa+bc)
	ld	xbc, xwa
	ld	xde, (Payload_Bss_Start+0x649e:24)
	ld	xwa, xhl
	ld	de, (xde+238)
	calr	BlockCopy_Words_BC_to_HL
	inc	2, xsp
	ret

; A = part index, C = sub-slot (0..3). Calls WaveSel_StageA1_FromPatchBlock (0x0325FC) to obtain XHL = the
; source record, then copies (0x045314)[0xEA] bytes into 0x044FCE + 0x1AA + slot*0x0B.
; Named VoiceSubSlot_Init in the LLVM build.
VoiceSubSlot_Init:
	dec 2, xsp
	ld (xsp), c
	ld e, a
	extz de
	ld a, (xsp)
	ld c, a
	extz bc
	ld wa, de
	call WaveSel_StageA1_FromPatchBlock
	ld a, (xsp)
	extz wa
	muls wa, 0xB
	add wa, 0x1AA
	lda xbc, (Payload_Bss_Start+0x6158:24)
	exts xwa
	add xwa, xbc
	ld xbc, xwa
	ld xde, (Payload_Bss_Start+0x649e:24)
	ld xwa, xhl
	ld	de, (xde+234)
	calr BlockCopy_Words_BC_to_HL
	inc 2, xsp
	ret

; ** MISIDENTIFIED AS DATA (LLVM: VoiceSubSlot_Init_AltData .byte); it is code. ** Called from
; 0x02EA60 and 0x02EB53. A = sub-unit index, BC/DE = selectors, (XSP+6) = custom-tone slot;
; returns with retd 2. Calls WaveSel_StageA1_FindVelSplit (0x03248B) for XHL = the source record and
; copies (0x045314)[0xF0] bytes into
; (0x04531C) + slot*0x50 + unit*0x0B + 0x4AE1.
; ★ Renamed 2026-09-25 from VoiceSubSlot_Init_AltData: header: copies a sub-unit record (0xF0 bytes) into a custom-tone slot's sub-unit.
CustomTone_CopySubUnitRecord:
	dec	2, xsp
	ld	(xsp), a
	ld	a, (xsp)
	ld	l, a
	extz	hl
	extz	bc
	extz	de
	ld	a, (xsp+6)
	extz	wa
	pushw	wa
	pushw	255
	ld	wa, hl
	call	WaveSel_StageA1_FindVelSplit
	ld	a, (xsp)
	extz	wa
	muls	wa, 11
	ld	bc, wa
	ld	a, (xsp+6)
	extz	wa
	muls	wa, 80
	ld	de, wa
	add	de, bc
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xwa, (xwa+de)	; lda XWA,XWA+DE
	lda	xwa, (xwa+19169)
	ld	xbc, xwa
	ld	xde, (Payload_Bss_Start+0x649e:24)
	ld	xwa, xhl
	ld	de, (xde+240)
	calr	BlockCopy_Words_BC_to_HL
	inc	2, xsp
	retd	2

; A = part index. The full "prepare this part's tone for the TG" pass, and the only writer of
; several staging fields. Steps:
;   1. VOICEPARAM_LOAD_TONE_RECORD(part), then VOICEPARAM_LOAD_SUBSLOT_RECORD(part, i) for i<4.
;   2. Reads the part routing word at 0x041372 + part*0x11F; bit15 set -> set bit7 of the DRAM
;      byte at 0x04506B, clear -> clear it.
;   3. Copies the 8 default tone-option bytes from the ROM table at 0x00F95D into
;      0x044FCE + 0x1D8 + k (k = 0..7).
;   4. Counts "usable" slots: a slot i counts when (0x044FD4 + 0x66 + i*0x51) & 0xC0 == 0 AND
;      bit5 of the same byte is clear. If the count is not exactly 4 it forces the staging byte
;      at 0x0451A7 (= staging +0x1D9, tone-option[1]) to 0.
;   5. For each slot i: takes (part sub-slot +0x36) & 7 and copies four bytes from the part
;      sub-slot's +0x4D..+0x50 into 0x0451AF + i*5 + j (= staging +0x1E1 + ...).
; Called from 0x02EC7D and 0x030996.
VoiceParam_FullSetup:
	dec 2, xsp
	push xiz
	ld (xsp + 4), a
	ld a, (xsp + 4)
	extz wa
	calr VoiceStruct_BulkInit
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jr nc, VoiceParam_FullSetup_SetRoutingBit

VoiceParam_FullSetup_SubSlotInitLoop:
	ld a, (xsp + 4)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ld wa, de
	calr VoiceSubSlot_Init
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jr c, VoiceParam_FullSetup_SubSlotInitLoop

VoiceParam_FullSetup_SetRoutingBit:
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	ld	wa, (xbc+wa)
	extz xwa
	bit 15, wa
	jr z, VoiceParam_FullSetup_ClearRoutingBit
	set 7, (Payload_Bss_Start+0x61b5:24)
	jr VoiceParam_FullSetup_CopyLUT

VoiceParam_FullSetup_ClearRoutingBit:
	res 7, (Payload_Bss_Start+0x61b5:24)

VoiceParam_FullSetup_CopyLUT:
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x08
	jr nc, VoiceParam_FullSetup_CountActive

VoiceParam_FullSetup_CopyLUT_Loop:
	ldto_berp A, 0xFB
	extz wa
	ld de, wa
	add de, 0x1D8
	lda xhl, (Payload_Bss_Start+0x6158:24)
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (DSP_VOICEPARAM_DEFAULT_TABLE:24)
	ld	a, (xbc+wa)
	ld	(xhl+de), a
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x08
	jr c, VoiceParam_FullSetup_CopyLUT_Loop

VoiceParam_FullSetup_CountActive:
	ld c, 0x0:opc
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jr nc, VoiceParam_FullSetup_CheckAllActive

VoiceParam_FullSetup_CountActive_Loop:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x51
	add wa, 0x66
	lda xde, (Payload_Bss_Start+0x615e:24)
	ld	a, (xde+wa)
	and a, 0xC0
	jr nz, VoiceParam_FullSetup_CountActive_Next
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x51
	add wa, 0x66
	lda xde, (Payload_Bss_Start+0x615e:24)
	bit	5, (xde+wa)
	jr nz, VoiceParam_FullSetup_CountActive_Next
	inc 1, c

VoiceParam_FullSetup_CountActive_Next:
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jr c, VoiceParam_FullSetup_CountActive_Loop

VoiceParam_FullSetup_CheckAllActive:
	cp c, 4:i3
	jr z, VoiceParam_FullSetup_CopySlotParams
	ld (Payload_Bss_Start+0x6331:24), 0x00

VoiceParam_FullSetup_CopySlotParams:
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jrl nc, VoiceParam_FullSetup_Return

VoiceParam_FullSetup_CopySlotParams_Outer:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	ld	xwa, (xwa+de)
	ld a, (xwa + 54)
	and a, 0x7
	ld e, a
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x5
	add wa, 0x1E0
	lda xbc, (Payload_Bss_Start+0x6158:24)
	ld	(xbc+wa), e
	ld c, 0x0:opc
	cp c, 4:i3
	jr nc, VoiceParam_FullSetup_CopySlotParams_OuterNext

VoiceParam_FullSetup_CopySlotParams_Inner:
	ld l, c
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x5
	ld de, wa
	add de, hl
	lda xhl, (Payload_Bss_Start+0x6339:24)
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld iy, wa
	add iy, 0x6E
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x11F
	lda xix, (Part_Record_Base:24)
	lda	xix, (xix+wa)
	ld a, c
	extz wa
	ld iz, wa
	add iz, 0x4D
	ld	xwa, (xix+iy)
	ld	a, (xwa+iz)
	ld	(xhl+de), a
	inc 1, c
	cp c, 4:i3
	jr c, VoiceParam_FullSetup_CopySlotParams_Inner

VoiceParam_FullSetup_CopySlotParams_OuterNext:
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jrl c, VoiceParam_FullSetup_CopySlotParams_Outer

VoiceParam_FullSetup_Return:
	pop xiz
	inc 2, xsp
	ret

; ** Start of a 1672-byte run (0x02E581..0x02EC09) that BOTH symbol sources treat as data
; (LLVM: VoiceParam_FullSetup_ExtData). It is eight live routines; every one of them is CALLed
; from the dispatcher at 0x02EDC9..0x02EFF6. **
; A = part index, C = a boolean. Returns immediately if the part status word at
; 0x041368 + part*0x11F has (value & 3) == 0, i.e. the part is not loaded.
; Otherwise: C == 0 -> clear bit0 and set bit1; C != 0 -> clear bit1 and set bit0; then set
; bit2 unconditionally. Calls Voice_NoteState_Clear (0x0347B7) and Voice_SetLFO_ActiveFlag
; (0x027CBE), then WaveSel_Rebuild_PartCaches (0x032938) with the two part bytes at +0x19 and +0x1A.
; Then tone-header byte +0x5D bit7 -> set (else clear) bit14 of the part routing word +0x0A.
; Finally dispatches on the part mode (tone-header +0x10 & 0xC0):
;   0x80 -> nothing;  0x40 -> VoiceSlot_AltInit (0x034968);  0x00 and 0xC0 ->
;   VoiceSlot_FullInit (0x034890).
; ★ Renamed 2026-09-25 from VoiceParam_FullSetup_ExtData: header: sets the part status bits from C, then re-initialises the part by its mode.
Voice_Part_SetStateAndReinit:
	dec	2, xsp
	ld	(xsp), a
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xde, (Part_Record_Base:24)
	ld	wa, (xde+wa)
	and	wa, 3
	jrl	z, Voice_Part_SetStateAndReinit_Epilogue
	cp	c, 0:i3
	jr	nz, Voice_Part_SetStateAndReinit_Skip
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	andw	(xbc+wa), 0xfffe	; (unidasm; no llvm-mc spelling)
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 2, 0
	jr	Voice_Part_SetStateAndReinit_Join
Voice_Part_SetStateAndReinit_Skip:
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	andw	(xbc+wa), 0xfffd	; (unidasm; no llvm-mc spelling)
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 1, 0
Voice_Part_SetStateAndReinit_Join:
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 4, 0
	ld	a, (xsp)
	extz	wa
	call	Voice_NoteState_Clear
	ld	a, (xsp)
	extz	wa
	call	Voice_SetLFO_ActiveFlag
	ld	a, (xsp)
	ld	l, a
	extz	hl
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x250b:24)
	ld	a, (xbc+wa)
	ldfr_berp	a, 240
	extz	ix
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x250c:24)
	ld	a, (xbc+wa)
	ld	e, a
	extz	de
	ld	wa, hl
	ld	bc, ix
	call	WaveSel_Rebuild_PartCaches
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	bitm	7, (xwa+93)
	jr	z, Voice_Part_SetStateAndReinit_Skip2
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x24fc:24)
	or_rrw_im	xbc, wa, 0, 64
	jr	Voice_Part_SetStateAndReinit_Join2
Voice_Part_SetStateAndReinit_Skip2:
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x24fc:24)
	andw	(xbc+wa), 0xbfff	; (unidasm; no llvm-mc spelling)
Voice_Part_SetStateAndReinit_Join2:
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld	a, (xwa+16)
	and	a, 192
	cp	a, 128
	jr	z, Voice_Part_SetStateAndReinit_Epilogue
	cp	a, 64
	jr	z, Voice_Part_SetStateAndReinit_Skip4
	cp	a, 192
	jr	z, Voice_Part_SetStateAndReinit_Skip3
	cp	a, 0:i3
	jr	nz, Voice_Part_SetStateAndReinit_Epilogue
Voice_Part_SetStateAndReinit_Skip3:
	ld	a, (xsp)
	extz	wa
	call	VoiceSlot_FullInit
	jr	t, Voice_Part_SetStateAndReinit_Epilogue
Voice_Part_SetStateAndReinit_Skip4:
	ld	a, (xsp)
	extz	wa
	call	VoiceSlot_AltInit
Voice_Part_SetStateAndReinit_Epilogue:
	inc	2, xsp
	ret
; ** Inside the same misidentified blob; unnamed in both sources. ** Called from 0x02EE97.
; A = part index, E low nibble = sub-slot, BC = wave-catalogue index. The catalogue is
; (0x045310) + (0x045314)[0x50], entries are 0x10 bytes. Writes catalogue entry byte +0x0E into
; the sub-slot descriptor's +0x02 and byte +0x0F into +0x03 (the descriptor is the long at
; part + 0x6E + slot*0x25). Then calls VOICEPARAM_LOAD_SUBSLOT_RECORD(part, slot) and
; WaveSel_Cache_SetDescPtr (0x0328E2) for j = 0..3.
; The +0x0E/+0x0F pair recurs in all four "catalogue" routines below and is almost certainly
; the wave/sample selector; that reading is inference, not proof.
VoiceParam_SubSlot_Apply_Catalog50:
	dec	2, xsp
	push qiz
	ld	(xsp+2), a
	ld	xwa, (Payload_Bss_Start+0x649e:24)
	ld	xwa, (xwa+80)
	ld	xhl, (Payload_Bss_Start+0x649a:24)
	add	xhl, xwa
	ldfr_berp	e, 251
	and_erpb	251, 15
	ldto_berp	a, 251
	extz	wa
	muls	wa, 37
	ld	ix, wa
	add	ix, 110
	ld	a, (xsp+2)
	extz	wa
	muls	wa, 287
	lda	xde, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xde
	ld	xde, (xwa+ix)
	ld	wa, bc
	extz	xwa
	sll	xwa, 4
	add	xwa, xhl
	ld	a, (xwa+14)
	ld	(xde+2), a
	ldto_berp	a, 251
	extz	wa
	muls	wa, 37
	ld	ix, wa
	add	ix, 110
	ld	a, (xsp+2)
	extz	wa
	muls	wa, 287
	lda	xde, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xde
	ld	xde, (xwa+ix)
	ld	wa, bc
	extz	xwa
	sll	xwa, 4
	add	xwa, xhl
	ld	a, (xwa+15)
	ld	(xde+3), a
	ld	a, (xsp+2)
	ld	e, a
	extz	de
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	wa, de
	calr	VoiceSubSlot_Init
	ldib_erp	250, 0
	cpib_erp	250, 4
	jr	nc, VoiceParam_SubSlot_Apply_Catalog50_Epilogue
VoiceParam_SubSlot_Apply_Catalog50_Loop:
	ld	a, (xsp+2)
	ld	l, a
	extz	hl
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ldto_berp	a, 250
	ld	e, a
	extz	de
	ld	wa, hl
	call	WaveSel_Cache_SetDescPtr
	incb_erp	250, 1
	cpib_erp	250, 4
	jr	c, VoiceParam_SubSlot_Apply_Catalog50_Loop
VoiceParam_SubSlot_Apply_Catalog50_Epilogue:
	pop qiz
	inc	2, xsp
	ret
; ** Same blob; unnamed in both sources. ** Called from 0x02EECA. Catalogue is
; (0x045310) + (0x045314)[0x64]. E low nibble = sub-slot, E high nibble = a pair index k,
; A = part, BC = catalogue index. Writes catalogue entry +0x0E into (sub-slot record +0x04)
; indexed by 3 + 2*k, and entry +0x0F into the following byte, then tail-jumps into
; WaveSel_Cache_SetDescPtr (0x0328E2).
VoiceParam_SubSlot_Apply_Catalog64:
	ld	xhl, (Payload_Bss_Start+0x649e:24)
	ld	xhl, (xhl+100)
	ld	xix, (Payload_Bss_Start+0x649a:24)
	add	xix, xhl
	ldfr_berp	e, 226
	and_erpb	226, 15
	and	e, 240
	srl	e, 4
	ld	w, e
	ldto_berp	e, 226
	extz	de
	muls	de, 37
	ld	iy, de
	add	iy, 110
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_Record_Base:24)
	exts	xde
	add	xde, xhl
	lda	xhl, (xde+iy)
	ld	e, w
	extz	de
	add	de, de
	ld	iy, de
	inc	3, iy
	ld	xhl, (xhl+4)
	ld	de, bc
	extz	xde
	sll	xde, 4
	add	xde, xix
	ld	e, (xde+14)
	ld	(xhl+iy), e
	ldto_berp	e, 226
	extz	de
	muls	de, 37
	ld	iy, de
	add	iy, 110
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_Record_Base:24)
	exts	xde
	add	xde, xhl
	lda	xhl, (xde+iy)
	ld	e, w
	extz	de
	add	de, de
	ld	iy, de
	inc	3, iy
	ld	xde, (xhl+4)
	lda	xde, (xde+iy)
	extz	xbc
	sll	xbc, 4
	add	xbc, xix
	ld	c, (xbc+15)
	ld	(xde+1), c
	ld	l, a
	extz	hl
	ldto_berp	a, 226
	ld	c, a
	extz	bc
	ld	e, w
	extz	de
	ld	wa, hl
	jp	WaveSel_Cache_SetDescPtr
; ** Same blob; unnamed in both sources. ** Called from 0x02EF20.
; E = new value, (XSP+2) = part index, C = tone-option index (0..6). Stores E into the staging
; tone-option array at 0x044FCE + 0x1D8 + C, then dispatches through the 7-entry, 2-byte
; jump-offset table at ROM 0x00F965 relative to base 0x02E89B. C outside 0..6 falls straight to
; the exit. The seven handlers are NOT a fall-through chain; each ends with a jump to 0x02E918:
;   0 -> Voice_ActiveFlag_CheckAndLoad (0x034491)
;   1 -> 0x034503, then 0x034606 unless the new value is 0xF5, then 0x02F52A(part, 0)
;   2 -> 0x034651 then 0x02F52A(part, 0)
;   3 -> 0x03469C then 0x02F52A(part, 0)
;   4 -> 0x0346E7
;   5 -> 0x034732
;   6 -> 0x034732, then VOICE_QUERY_REQ_MODE40_MASK7F(part) and
;        Voice_AllNotes_SustainRetrigger (0x028E26) with BC = 1
; Note that the 8-byte option array these indices address is initialised from ROM 0x00F95D by
; VOICEPARAM_BUILD_TONE_STAGING, and that option[1] is the byte
; VOICEPARAM_BUILD_TONE_STAGING zeroes when fewer than 4 slots are usable.
VoiceParam_Set_Tone_Option:
	dec	4, xsp
	ld	(xsp), e
	ld	(xsp+2), a
	ld	a, c
	extz	wa
	ld	de, wa
	add	de, 472
	lda	xhl, (Payload_Bss_Start+0x6158:24)
	ld	a, (xsp)
	ld	(xhl+de), a
	ld	a, c
	extz	wa
	cp	wa, 0:i3
	jrl	mi, VoiceParam_Set_Tone_Option_Epilogue
	cp	wa, 6:i3
	jrl	gt, VoiceParam_Set_Tone_Option_Epilogue
	add	wa, wa
	lda	xix, (VOICEPARAM_TONE_OPTION_JUMPTABLE:24)
	ld	wa, (xix+wa)
	lda	xix, (VoiceParam_Set_Tone_Option_CutoffOffset:24)
	jp	t, (xix+wa)
; Base of the 7-way jump table at ROM 0x00F965; also the handler for option index 0.
VoiceParam_Set_Tone_Option_CutoffOffset:
	ld	a, (xsp+2)
	extz	wa
	call	Voice_ActiveFlag_CheckAndLoad
	jr	t, VoiceParam_Set_Tone_Option_Epilogue
; VoiceParam_Set_Tone_Option_LfoDepthOffset: 0xF5 is the 'unset' sentinel: Voice_Part_ResetSlotRouting re-derives the
;   slot flags from it and the part+0x68 refresh is skipped.
VoiceParam_Set_Tone_Option_LfoDepthOffset:
	ld	a, (xsp+2)
	extz	wa
	call	Voice_Part_ResetSlotRouting
	cp	(xsp), 245
	jr	z, VoiceParam_Set_Tone_Option_Skip
	ld	a, (xsp+2)
	extz	wa
	call	DSP_SlotParam_Write_Slot0
VoiceParam_Set_Tone_Option_Skip:
	ld	a, (xsp+2)
	extz	wa
	ld	bc, 0:i3
	calr	VoiceAlloc_Apply_Algo_Group0
	jr	VoiceParam_Set_Tone_Option_Epilogue
VoiceParam_Set_Tone_Option_Case2:
	ld	a, (xsp+2)
	extz	wa
	call	DSP_SlotParam_Write_Slot1
	ld	a, (xsp+2)
	extz	wa
	ld	bc, 0:i3
	calr	VoiceAlloc_Apply_Algo_Group0
	jr	VoiceParam_Set_Tone_Option_Epilogue
VoiceParam_Set_Tone_Option_LfoDelayOffset:
	ld	a, (xsp+2)
	extz	wa
	call	DSP_SlotParam_Write_Slot2
	ld	a, (xsp+2)
	extz	wa
	ld	bc, 0:i3
	calr	VoiceAlloc_Apply_Algo_Group0
	jr	VoiceParam_Set_Tone_Option_Epilogue
VoiceParam_Set_Tone_Option_AttackOffset:
	ld	a, (xsp+2)
	extz	wa
	call	DSP_SlotParam_Write_Slot3
	jr	t, VoiceParam_Set_Tone_Option_Epilogue
; VoiceParam_Set_Tone_Option_EnvALevelOffset: Also re-runs Voice_AllNotes_SustainRetrigger so held notes pick up the
;   new envelope-A level.
VoiceParam_Set_Tone_Option_EnvALevelOffset:
	ld	a, (xsp+2)
	extz	wa
	call	DSP_SlotParam_Write_Slot4
	ld	a, (xsp+2)
	extz	wa
	call	Voice_AllocateForSustain
	ld	xwa, xhl
	ld	bc, 1:i3
	call	Voice_AllNotes_SustainRetrigger
VoiceParam_Set_Tone_Option_Epilogue:
	inc	4, xsp
	ret
; ** Same blob; unnamed in both sources. ** Called from 0x02EF7B.
; A = custom-tone slot. Latches it into the byte at (0x04531C) + 0x72A7 -- the "currently
; selected custom tone" global that the next three routines all read back. Then for k = 0..1 it
; copies from (0x04531C) + slot*0x50 + k*0x15 + 0x4AB7 into 0x044FCE + 0x1F4 + k*5:
;   dest[0] = src[0x0F] & 7 ; dest[1..4] = src[0x11..0x14].
VoiceParam_CustomTone_Select:
	dec	2, xsp
	push xiz
	ld	(xsp+4), a
	ld	xbc, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xsp+4)
	ld	(xbc+29351), a
	ld	qiz, 0
	cp	qiz, 2
	jr	nc, VoiceParam_CustomTone_Select_Epilogue
VoiceParam_CustomTone_Select_Loop:
	ld	a, (xsp+4)
	extz	wa
	muls	wa, 80
	ld	iz, wa
	ld	wa, qiz
	extz	xwa
	ld	xbc, 21
	call	Math_Multiply32
	lda	xhl, (xhl+iz)
	add	xhl, (Payload_Bss_Start+0x64a6:24)
	lda	xhl, (xhl+19127)
	ld	wa, qiz
	extz	xwa
	ld	xbc, xwa
	sll	xbc, 2
	add	xbc, xwa
	add	xbc, 500
	lda	xde, (Payload_Bss_Start+0x6158:24)
	add	xde, xbc
	ld	a, (xhl+15)
	and	a, 7
	ld	(xde), a
	ld	bc, 0:i3
	cp	bc, 4:i3
	jr	nc, VoiceParam_CustomTone_Select_Skip
VoiceParam_CustomTone_Select_Loop2:
	ld	wa, bc
	extz	xwa
	inc	1, xwa
	ld	xix, xwa
	add	xix, xde
	ld	wa, bc
	extz	xwa
	add	xwa, 17
	add	xwa, xhl
	ld	a, (xwa)
	ld	(xix), a
	inc	1, bc
	cp	bc, 4:i3
	jr	c, VoiceParam_CustomTone_Select_Loop2
VoiceParam_CustomTone_Select_Skip:
	inc	1, qiz
	cp	qiz, 2
	jr	c, VoiceParam_CustomTone_Select_Loop
VoiceParam_CustomTone_Select_Epilogue:
	pop xiz
	inc	2, xsp
	ret
; ** Same blob; unnamed in both sources. ** Called from 0x02EF96. WA = wave-catalogue index;
; the custom-tone slot comes from the (0x04531C)+0x72A7 latch, not from an argument.
; Catalogue = (0x045310) + (0x045314)[0x80], 0x10-byte entries. Calls
; VOICEPARAM_CUSTOMTONE_LOAD_HEADER with entry +0x0E / +0x0F, then for k = 0..1 calls
; VOICEPARAM_CUSTOMTONE_LOAD_SUBUNIT for the sub-record at base + 0x10 + k*0x15 and rewrites
; that record's +0x02 as (value & 0x0F) | 0x50. Finally stores entry +0x0E and
; (entry +0x0F & 0x1F) | 0x60 into (0x04531C) + slot*2 + 0x49A7.
VoiceParam_CustomTone_Apply_Catalog80:
	lda	xsp, (xsp-14)
	push xiz
	ld	(xsp+16), wa
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	(xsp+12), a
	extz	wa
	muls	wa, 80
	ld	bc, wa
	add	bc, 19111
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xwa, (xwa+bc)
	ld	(xsp+4), xwa
	ld	xwa, (Payload_Bss_Start+0x649e:24)
	ld	xwa, (xwa+128)
	ld	xbc, (Payload_Bss_Start+0x649a:24)
	add	xbc, xwa
	ld	(xsp+8), xbc
	ld	wa, (xsp+16)
	extz	xwa
	sll	xwa, 4
	add	xwa, (xsp+8)
	ld	a, (xwa+14)
	ld	l, a
	extz	hl
	ld	wa, (xsp+16)
	extz	xwa
	sll	xwa, 4
	add	xwa, (xsp+8)
	ld	a, (xwa+15)
	ld	c, a
	extz	bc
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	wa, hl
	calr	CustomTone_CopyToneRecord
	ld	(xsp+14), 0
	cp	(xsp+14), 2
	jr	nc, VoiceParam_CustomTone_Apply_Catalog80_Skip
VoiceParam_CustomTone_Apply_Catalog80_Loop:
	ld	a, (xsp+14)
	extz	wa
	muls	wa, 21
	ld	bc, wa
	add	bc, 16
	ld	xwa, (xsp+4)
	lda	xiz, (xwa+bc)
	ld	a, (xsp+14)
	ld	l, a
	extz	hl
	ld	a, (xiz+1)
	ld	c, a
	extz	bc
	ld	a, (xiz+2)
	ld	e, a
	extz	de
	ld	a, (xsp+12)
	extz	wa
	pushw wa
	ld	wa, hl
	calr	CustomTone_CopySubUnitRecord
	andmi8	(xiz+2), 15
	ormi8	(xiz+2), 80
	incm8	1, (xsp+14)
	cp	(xsp+14), 2
	jr	c, VoiceParam_CustomTone_Apply_Catalog80_Loop
VoiceParam_CustomTone_Apply_Catalog80_Skip:
	ld	a, (xsp+12)
	extz	wa
	add	wa, wa
	ld	de, wa
	add	de, 18855
	ld	xbc, (Payload_Bss_Start+0x64a6:24)
	ld	wa, (xsp+16)
	extz	xwa
	sll	xwa, 4
	add	xwa, (xsp+8)
	ld	a, (xwa+14)
	ld	(xbc+de), a
	ld	wa, (xsp+16)
	extz	xwa
	sll	xwa, 4
	add	xwa, (xsp+8)
	ld	a, (xwa+15)
	and	a, 31
	or	a, 96
	ld	e, a
	ld	a, (xsp+12)
	extz	wa
	add	wa, wa
	ld	bc, wa
	add	bc, 18855
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xwa, (xwa+bc)
	ld	(xwa+1), e
	pop xiz
	lda	xsp, (xsp+14)
	ret
; ** Same blob; unnamed in both sources. ** Called from 0x02EFC6. WA = catalogue index,
; C low nibble = unit index; catalogue = (0x045310) + (0x045314)[0x8C]. Calls
; VOICEPARAM_CUSTOMTONE_LOAD_SUBUNIT, then writes catalogue entry +0x0E into
; (0x04531C) + slot*0x50 + unit*0x15 + 0x4AB7 + 1 and (entry +0x0F & 0x0F) | 0x50 into +2.
VoiceParam_CustomTone_Apply_Catalog8C:
	dec	6, xsp
	push xiz
	ld	(xsp+8), wa
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	e, (xwa+29351)
	ld	xwa, (Payload_Bss_Start+0x649e:24)
	ld	xwa, (xwa+140)
	ld	xhl, (Payload_Bss_Start+0x649a:24)
	add	xhl, xwa
	ld	xiz, xhl
	ld	l, c
	and	l, 15
	ld	a, l
	extz	wa
	muls	wa, 21
	ld	bc, wa
	ld	a, e
	extz	wa
	muls	wa, 80
	ld	ix, wa
	add	ix, bc
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xwa, (xwa+ix)
	ld	(xsp+4), xwa
	ld	xwa, 19127
	add	(xsp+4), xwa
	ld	c, l
	extz	bc
	ld	wa, (xsp+8)
	extz	xwa
	sll	xwa, 4
	add	xwa, xiz
	ld	a, (xwa+14)
	ldfr_berp	a, 240
	extz	ix
	ld	wa, (xsp+8)
	extz	xwa
	sll	xwa, 4
	add	xwa, xiz
	ld	a, (xwa+15)
	ld	l, a
	extz	hl
	ld	a, e
	extz	wa
	pushw wa
	ld	wa, bc
	ld	bc, ix
	ld	de, hl
	calr	CustomTone_CopySubUnitRecord
	ld	wa, (xsp+8)
	extz	xwa
	sll	xwa, 4
	ld	xbc, xwa
	add	xbc, xiz
	ld	xwa, (xsp+4)
	ld	c, (xbc+14)
	ld	(xwa+1), c
	ld	wa, (xsp+8)
	extz	xwa
	sll	xwa, 4
	add	xwa, xiz
	ld	a, (xwa+15)
	and	a, 15
	or	a, 80
	ld	c, a
	ld	xwa, (xsp+4)
	ld	(xwa+2), c
	pop xiz
	inc	6, xsp
	ret
; ** Same blob; unnamed in both sources. ** Called from 0x02EFF6. WA = catalogue index,
; C low nibble = sub-unit (stride 0x0B), C high nibble = pair index k;
; catalogue = (0x045310) + (0x045314)[0x94]. Writes entry +0x0E into
; (0x04531C) + slot*0x50 + unit*0x0B + 0x4AE1 + 3 + 2*k and entry +0x0F into the next byte.
; No copy and no further calls -- the smallest of the four catalogue appliers.
VoiceParam_CustomTone_Apply_Catalog94:
	ld	xde, (Payload_Bss_Start+0x64a6:24)
	ld	b, (xde+29351)
	ld	xde, (Payload_Bss_Start+0x649e:24)
	ld	xde, (xde+148)
	ld	xhl, (Payload_Bss_Start+0x649a:24)
	add	xhl, xde
	ld	e, c
	and	e, 15
	extz	de
	muls	de, 11
	ld	ix, de
	ld	e, b
	extz	de
	muls	de, 80
	ld	iy, de
	add	iy, ix
	ld	xde, (Payload_Bss_Start+0x64a6:24)
	lda	xde, (xde+iy)
	lda	xde, (xde+19169)
	and	c, 240
	srl	c, 4
	ldfr_berp	c, 226
	extz	bc
	add	bc, bc
	ld	ix, bc
	inc	3, ix
	ld	bc, wa
	extz	xbc
	sll	xbc, 4
	add	xbc, xhl
	ld	c, (xbc+14)
	ld	(xde+ix), c
	ldto_berp	c, 226
	extz	bc
	add	bc, bc
	inc	3, bc
	exts	xbc
	add	xbc, xde
	extz	xwa
	sll	xwa, 4
	add	xwa, xhl
	ld	a, (xwa+15)
	ld	(xbc+1), a
	ret

; A = part index. Only the first 0x2E bytes of this routine fall inside region 8 (it continues
; past 0x02EC37 to 0x02ECBD); documented here for its GUARD, which is the part everyone using
; this region needs to know about:
;     if (byte at DRAM 0x0451A4) != A            -> return immediately, doing nothing
;     if A > 2 and (part status word & 3) != 3   -> return immediately, doing nothing
; 0x0451A4 is a single global "part currently being edited/loaded" latch. Because it is a
; plain equality test with no timeout and no fallback, every one of the 13 call sites
; (0x02EDD4, 0x02EDF3, 0x02EE12, 0x02EE31, 0x02EE50, 0x02EE6F, 0x02EEA2, 0x02EF0A, 0x02F513,
; 0x031AAE, 0x031ABE, 0x031AEA and 0x02EC7D's neighbourhood) silently becomes a no-op whenever
; that latch does not match. Beyond the guard the routine calls
; VOICEPARAM_BUILD_TONE_STAGING (0x02EC7D) and continues into 0x02EC38.
VoiceAlloc_CheckAndInit:
	dec 2, xsp
	ld (xsp), a
	ld a, (Payload_Bss_Start+0x632e:24)
	cp a, (xsp)
	jrl nz, VoiceAlloc_CheckAndInit_Return
	cp (xsp), 0x2
	jr ule, VoiceAlloc_SetFlagBit0
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	ld	wa, (xbc+wa)
	and wa, 0x3
	cp wa, 3:i3
	jrl nz, VoiceAlloc_CheckAndInit_Return

; Second stage of VoiceAlloc_CheckAndInit (0x02EC0A).  Re-reads the part's flag word at
; PART+0x00; if bit 0 is already set the part is merely re-marked (OR 0x0001) and the routine
; returns; otherwise control falls to VoiceAlloc_InitNewAllocation.  Part index is on the
; stack at (XSP).
VoiceAlloc_SetFlagBit0:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	ld	wa, (xbc+wa)
	bit 0, wa
	jr z, VoiceAlloc_InitNewAllocation
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	orw	(xbc+wa), 0x0001
	jr VoiceAlloc_CheckAndInit_Return

; First-time allocation of a part: set PART+0x00 bit 0, call VoiceParam_FullSetup (0x02E3E9)
; with the part index, then call WaveSel_Rebuild_PartCaches (0x032938) with
; WA = part, BC = PART+0x19 (Part_UserToneIndex), DE = PART+0x1A.  This is the only path in
; this region that actually creates voices.
VoiceAlloc_InitNewAllocation:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	orw	(xbc+wa), 0x0001
	ld a, (xsp)
	extz wa
	calr VoiceParam_FullSetup
	ld a, (xsp)
	ld l, a
	extz hl
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x250b:24)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xF0
	extz ix
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x250c:24)
	ld	a, (xbc+wa)
	ld e, a
	extz de
	ld wa, hl
	ld bc, ix
	call WaveSel_Rebuild_PartCaches

; Pop the one-word part-index frame and return.
VoiceAlloc_CheckAndInit_Return:
	inc 2, xsp
	ret

; Register-argument twin of VoiceAlloc_CheckAndInit: entry with XWA = pointer to the 6-byte
; command record; the part index is taken from (XWA+1) into E and kept there throughout.
; Unlike VoiceAlloc_CheckAndInit it does NOT consult the current-edit-part byte 0x0451A4 --
; it goes straight to the (PART+0x00 & 3) == 3 test for parts > 2.
; After marking the part it reads PART+0x1A; if that byte is in [0x40,0x50) it calls
; DSP_FlushAllSlots_ForPart (0x0351B3) with the part index, otherwise it just returns.
; Single caller: tone-edit opcode 0x13 at 0x02EF71.  Despite the "_ExtData" suffix this is
; ordinary code, not a data table.
; ★ Renamed 2026-09-25 from VoiceAlloc_CheckAndInit_ExtData: header: register-argument twin of VoiceAlloc_CheckAndInit, part from the record.
VoiceAlloc_CheckAndInit_FromRecord:
	ld	e, (xwa+1)
	cp	e, 2:i3
	jr	ule, VoiceAlloc_Cmd_MarkPresent
	ld	a, e
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	ld	wa, (xbc+wa)
	and	wa, 3
	cp	wa, 3:i3
	ret	nz
; Common continuation for parts 0..2 and for parts that passed the (flags & 3) == 3 test:
; re-read PART+0x00 and branch on bit 0.
VoiceAlloc_Cmd_MarkPresent:
	ld	a, e
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	ld	wa, (xbc+wa)
	bit	0, wa
	jr	z, VoiceAlloc_Cmd_FirstAlloc
	ld	a, e
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 1, 0
	ret
; Part was not yet allocated: set PART+0x00 bit 0, then range-check PART+0x1A against
; [0x40,0x50) before calling DSP_FlushAllSlots_ForPart.
VoiceAlloc_Cmd_FirstAlloc:
	ld	a, e
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	or_rrw_im	xbc, wa, 1, 0
	ld	a, e
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x250c:24)
	ld	a, (xbc+wa)
	cp	a, 64
	ret	c
	cp	a, 80
	ret	nc
	ld	a, e
	extz	wa
	call	DSP_FlushAllSlots_ForPart
	ret
; Ships one whole tone-edit buffer from sub to main.  Input: A = edit-buffer index.
;   src = (ToneDB_RamBankA) + 0x4AA7 + index*0x50
;   dst = 0x001E0000  + 0x4AA7 + index*0x50      (the main CPU's window)
;   len = 0x01D6 (470 bytes), hard-coded in HL
; Tail-jumps to InterCPU_E1_DMA_Transfer (0x020DB3), so its timeout behaviour is this
; routine's timeout behaviour.  Called from tone-edit opcodes 0x14, 0x15 and 0x16
; (0x02EFA5, 0x02EFD5, 0x02F005), each of which first fetches the index from
; (ToneDB_RamBankA + 0x72A7).  NOTE the stride/length mismatch flagged in [UNCERTAIN].
; InterCPU_SendEditBufferToMain: Copies one 470-byte custom-tone edit buffer to the main CPU by an E1 transfer: source
;   (ToneDB_RamBankA) + 0x4AA7 + index*0x50, destination main-CPU address 0x1E0000 + the same offset, length 0x1D6;
;   index in A. Basis: callers + body -- tone-edit opcodes 0x14 / 0x15 / 0x16 call it after
;   VoiceParam_CustomTone_Apply_Catalog80 / 8C / 94 with the index latched at (ToneDB_RamBankA) + 0x72A7.
InterCPU_SendEditBufferToMain:
	ld	xix, 1966080
	ldw	hl, 470
	ld	c, a
	extz	bc
	muls	bc, 80
	ld	de, bc
	add	de, 19111
	ld	xbc, (Payload_Bss_Start+0x64a6:24)
	lda	xbc, (xbc+de)
	ld	xde, xbc
	extz	wa
	muls	wa, 80
	add	wa, 19111
	exts	xwa
	add	xwa, xix
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, xbc
	ld	bc, hl
	jp	InterCPU_E1_DMA_Transfer
; Primary tone-edit command dispatcher.  Entry XWA = command record; saves it in XIZ.
; Accepts opcodes 0x00..0x0D directly, and 0x13..0x18 after subtracting 5; everything else
; falls through to the return.  (The `cp WA,0 / jrl M` at 0x02ED88 is dead: WA was just
; zero-extended from a byte.)  Jumps through AUDIO_CMD_TONEEDIT_JUMPTABLE (0x00F973) with
; base 0x02EDB9.  Nine of the sixteen live cases begin by calling VoiceAlloc_CheckAndInit,
; which is why almost every one of them is a no-op unless 0x0451A4 already names this part.
; Sole caller: 0x031AA3, inside DSP_SetCoeff_MasterConfig's command tree.
Audio_Cmd_ToneEdit_Dispatch:
	push xiz
	ld	xiz, xwa
	ld	a, (xiz+2)
	extz	wa
	cp	wa, 0:i3
	jrl	mi, Audio_Cmd_ToneEdit_Return
	cp	wa, 13
	jr	le, Audio_Cmd_ToneEdit_TableJump
	dec	5, wa
	cp	wa, 14
	jrl	lt, Audio_Cmd_ToneEdit_Return
	cp	wa, 19
	jrl	gt, Audio_Cmd_ToneEdit_Return
; Common tail of the range checks: WA*2 indexes AUDIO_CMD_TONEEDIT_JUMPTABLE, the fetched
; offset is added to 0x02EDB9 and jumped to.
Audio_Cmd_ToneEdit_TableJump:
	add	wa, wa
	lda	xix, (AUDIO_CMD_TONEEDIT_JUMPTABLE:24)
	ld	wa, (xix+wa)
	lda	xix, (Audio_Cmd_ToneEdit_Op00:24)
	jp	t, (xix+wa)
; Opcode 0x00: Voice_Part_SetStateAndReinit(WA = part from rec+1, BC = value from rec+4).
Audio_Cmd_ToneEdit_Op00:
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	Voice_Part_SetStateAndReinit
	jrl	Audio_Cmd_ToneEdit_Return
; Opcode 0x04: VoiceAlloc_CheckAndInit(part) then 0x02AE22 (Voice_SetArticWord0_LowByte)
; with WA = part, BC = rec+4.
Audio_Cmd_ToneEdit_Op04:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	wa, de
	call	Voice_SetArticWord0_LowByte
	jrl	t, Audio_Cmd_ToneEdit_Return
; Opcode 0x05: VoiceAlloc_CheckAndInit(part) then 0x02AE58 with WA = part, BC = rec+4.
Audio_Cmd_ToneEdit_Op05:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	wa, de
	call	Voice_Artic_SetWord2Word1_Nibble0
	jrl	t, Audio_Cmd_ToneEdit_Return
; Opcode 0x06: VoiceAlloc_CheckAndInit(part) then 0x02AEA2 with WA = part, BC = rec+4.
Audio_Cmd_ToneEdit_Op06:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	wa, de
	call	Voice_Artic_SetWord2Word1_Nibble1
	jrl	t, Audio_Cmd_ToneEdit_Return
; Opcode 0x07: VoiceAlloc_CheckAndInit(part) then 0x02AEEC with WA = part, BC = rec+4.
Audio_Cmd_ToneEdit_Op07:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	wa, de
	call	Voice_Artic_SetWord0Word2_Nibble2
	jrl	t, Audio_Cmd_ToneEdit_Return
; Opcode 0x08: VoiceAlloc_CheckAndInit(part) then 0x02AF3A with WA = part, BC = rec+4.
Audio_Cmd_ToneEdit_Op08:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	wa, de
	call	Voice_Artic_SetWord1Nibble2_And_Word3
	jrl	t, Audio_Cmd_ToneEdit_Return
; Opcode 0x09: VoiceAlloc_CheckAndInit(part), then 0x02E6D4 with WA = part,
; BC = (rec+3)<<8 | (rec+4) -- the only opcodes that carry a 16-bit value -- and DE = rec+5.
Audio_Cmd_ToneEdit_Op09:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	a, (xiz+3)
	extz	wa
	ld	hl, wa
	sll	hl, 8
	or	hl, bc
	ld	a, (xiz+1)
	ld	c, a
	extz	bc
	ld	a, (xiz+5)
	ld	e, a
	extz	de
	ld	wa, bc
	ld	bc, hl
	calr	VoiceParam_SubSlot_Apply_Catalog50
	jrl	Audio_Cmd_ToneEdit_Return
; Opcode 0x0A: same 16-bit decode as opcode 0x09 but the callee is 0x02E7A0.
Audio_Cmd_ToneEdit_Op0A:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	a, (xiz+3)
	extz	wa
	ld	hl, wa
	sll	hl, 8
	or	hl, bc
	ld	a, (xiz+1)
	ld	c, a
	extz	bc
	ld	a, (xiz+5)
	ld	e, a
	extz	de
	ld	wa, bc
	ld	bc, hl
	calr	VoiceParam_SubSlot_Apply_Catalog64
	jrl	Audio_Cmd_ToneEdit_Return
; Opcode 0x0B: reads the patch record (PART+0x06) and tests (patch+0x10) & 0xC0 == 0x40.
; If so, calls 0x02AF82(WA = part, BC = rec+4) and returns; otherwise falls through to
; Audio_Cmd_ToneEdit_Op0B_Alt.
Audio_Cmd_ToneEdit_Op0B:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld	a, (xwa+16)
	and	a, 192
	cp	a, 64
	jr	nz, Audio_Cmd_ToneEdit_Op0B_Alt
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	wa, de
	call	Voice_Artic_SetDepthPair_A
	jrl	t, Audio_Cmd_ToneEdit_Return
; Opcode 0x0B, ordinary patch: VoiceAlloc_CheckAndInit(part) then 0x02E85A with
; WA = part, BC = rec+3, E = rec+4.
Audio_Cmd_ToneEdit_Op0B_Alt:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+1)
	ld	l, a
	extz	hl
	ld	a, (xiz+3)
	ld	c, a
	extz	bc
	ld	e, (xiz+4)
	ld	wa, hl
	calr	VoiceParam_Set_Tone_Option
	jrl	Audio_Cmd_ToneEdit_Return
; Opcode 0x0D -- SELECT THE PART TO EDIT.  Copies 0x0451A4 to 0x0451A5 and then stores
; (rec+1) into 0x0451A4.  This is the ONLY writer of 0x0451A4 apart from the 0xFF
; initialisation at 0x034C3B, and 0x0451A5 is never read anywhere in the ROM.  Everything
; gated on VoiceAlloc_CheckAndInit is inert until this opcode arrives.
Audio_Cmd_ToneEdit_Op0D_SelectPart:
	ld	a, (Payload_Bss_Start+0x632e:24)
	ld	(Payload_Bss_Start+0x632f:24), a
	ld	a, (xiz+1)
	ld	(Payload_Bss_Start+0x632e:24), a
	jrl	t, Audio_Cmd_ToneEdit_Return
; Opcode 0x0C: only acts when (patch+0x10) & 0xC0 == 0x40; then calls 0x02AFBD with
; WA = part, BC = rec+4.  No allocation, no reply.
Audio_Cmd_ToneEdit_Op0C:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld	a, (xwa+16)
	and	a, 192
	cp	a, 64
	jrl	nz, Audio_Cmd_ToneEdit_Return
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	wa, de
	call	Voice_Artic_SetDepthPair_B
	jrl	t, Audio_Cmd_ToneEdit_Return
; Opcode 0x13: VoiceAlloc_CheckAndInit_FromRecord(XWA = record) followed by 0x02E91B with
; WA = rec+4.
Audio_Cmd_ToneEdit_Op13:
	ld	xwa, xiz
	calr	VoiceAlloc_CheckAndInit_FromRecord
	ld	a, (xiz+4)
	extz	wa
	calr	VoiceParam_CustomTone_Select
	jrl	Audio_Cmd_ToneEdit_Return
; Opcode 0x14: 0x02E9B1 with the 16-bit value (rec+3)<<8|(rec+4), then reads the edit-buffer
; index from (ToneDB_RamBankA + 0x72A7) and calls InterCPU_SendEditBufferToMain.
; One of only three opcodes in this dispatcher that produce sub->main traffic.
Audio_Cmd_ToneEdit_Op14:
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	a, (xiz+3)
	extz	wa
	ld	hl, wa
	sll	hl, 8
	or	hl, bc
	ld	wa, hl
	calr	VoiceParam_CustomTone_Apply_Catalog80
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	extz	wa
	calr	InterCPU_SendEditBufferToMain
	jr	Audio_Cmd_ToneEdit_Return
; Opcode 0x15: 0x02EACE with the 16-bit value and BC = rec+5, then the same
; InterCPU_SendEditBufferToMain reply.
Audio_Cmd_ToneEdit_Op15:
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	a, (xiz+3)
	extz	wa
	ld	hl, wa
	sll	hl, 8
	or	hl, bc
	ld	a, (xiz+5)
	ld	c, a
	extz	bc
	ld	wa, hl
	calr	VoiceParam_CustomTone_Apply_Catalog8C
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	extz	wa
	calr	InterCPU_SendEditBufferToMain
	jr	Audio_Cmd_ToneEdit_Return
; Opcode 0x16: 0x02EB8A with the 16-bit value and BC = rec+5, then the same
; InterCPU_SendEditBufferToMain reply.
Audio_Cmd_ToneEdit_Op16:
	ld	a, (xiz+4)
	ld	c, a
	extz	bc
	ld	a, (xiz+3)
	extz	wa
	ld	hl, wa
	sll	hl, 8
	or	hl, bc
	ld	a, (xiz+5)
	ld	c, a
	extz	bc
	ld	wa, hl
	calr	VoiceParam_CustomTone_Apply_Catalog94
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	extz	wa
	calr	InterCPU_SendEditBufferToMain
	jr	Audio_Cmd_ToneEdit_Return
; Opcode 0x17: calls DSP_Stub_RetB (0x035575) -- a stub.  Opcode 0x18 and opcodes 0x01..0x03
; jump straight to the return.
Audio_Cmd_ToneEdit_Op17:
	call	DSP_Stub_RetB
; Restore XIZ and return.  Every case joins here.
Audio_Cmd_ToneEdit_Return:
	pop xiz
	ret
; First of eight near-identical copiers.  Input WA = part, C = descriptor index.
; XDE = the part's patch record (from PART+0x06); XBC = DSP_EFFECT_DESCRIPTOR_TABLE +
; index*0x27.  Copies descriptor fields into patch+0x5E..+0x65; this variant takes
; +0x00,+0x01,+0x1A,+0x1C,+0x1B,(skip +0x63),+0x0E,+0x12.  No hardware access.
DSP_EffParam_Copy_V0:
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+wa)
	ld	a, c
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	ld	a, (xbc)
	ld	(xde+94), a
	ld	a, (xbc+1)
	ld	(xde+95), a
	ld	a, (xbc+26)
	ld	(xde+96), a
	ld	a, (xbc+28)
	ld	(xde+97), a
	ld	a, (xbc+27)
	ld	(xde+98), a
	ld	a, (xbc+14)
	ld	(xde+100), a
	ld	a, (xbc+18)
	ld	(xde+101), a
	ret
; Same shape; fields +0x00,+0x01,+0x03,+0x04,+0x1A,+0x1C,+0x0E,+0x12 into patch+0x5E..+0x65.
DSP_EffParam_Copy_V1:
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+wa)
	ld	a, c
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	ld	a, (xbc)
	ld	(xde+94), a
	ld	a, (xbc+1)
	ld	(xde+95), a
	ld	a, (xbc+3)
	ld	(xde+96), a
	ld	a, (xbc+4)
	ld	(xde+97), a
	ld	a, (xbc+26)
	ld	(xde+98), a
	ld	a, (xbc+28)
	ld	(xde+99), a
	ld	a, (xbc+14)
	ld	(xde+100), a
	ld	a, (xbc+18)
	ld	(xde+101), a
	ret
; Fields +0x06,+0x07,+0x08,+0x1B then two zero bytes then +0x0E,+0x12.
DSP_EffParam_Copy_V2:
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+wa)
	ld	a, c
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	ld	a, (xbc+6)
	ld	(xde+94), a
	ld	a, (xbc+7)
	ld	(xde+95), a
	ld	a, (xbc+8)
	ld	(xde+96), a
	ld	a, (xbc+27)
	ld	(xde+97), a
	ld	(xde+98), 0
	ld	(xde+99), 0
	ld	a, (xbc+14)
	ld	(xde+100), a
	ld	a, (xbc+18)
	ld	(xde+101), a
	ret
; Fields +0x00,+0x01,+0x03,+0x04 then two zero bytes then +0x0E,+0x12.
DSP_EffParam_Copy_V3:
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+wa)
	ld	a, c
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	ld	a, (xbc)
	ld	(xde+94), a
	ld	a, (xbc+1)
	ld	(xde+95), a
	ld	a, (xbc+3)
	ld	(xde+96), a
	ld	a, (xbc+4)
	ld	(xde+97), a
	ld	(xde+98), 0
	ld	(xde+99), 0
	ld	a, (xbc+14)
	ld	(xde+100), a
	ld	a, (xbc+18)
	ld	(xde+101), a
	ret
; Fields +0x1C,+0x1A,+0x19,+0x1B then two zero bytes then +0x0E,+0x12.
DSP_EffParam_Copy_V4:
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+wa)
	ld	a, c
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	ld	a, (xbc+28)
	ld	(xde+94), a
	ld	a, (xbc+26)
	ld	(xde+95), a
	ld	a, (xbc+25)
	ld	(xde+96), a
	ld	a, (xbc+27)
	ld	(xde+97), a
	ld	(xde+98), 0
	ld	(xde+99), 0
	ld	a, (xbc+14)
	ld	(xde+100), a
	ld	a, (xbc+18)
	ld	(xde+101), a
	ret
; Fields +0x09,+0x0A,+0x0B,+0x0C then two zero bytes then +0x0E,+0x12.
DSP_EffParam_Copy_V5:
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+wa)
	ld	a, c
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	ld	a, (xbc+9)
	ld	(xde+94), a
	ld	a, (xbc+10)
	ld	(xde+95), a
	ld	a, (xbc+11)
	ld	(xde+96), a
	ld	a, (xbc+12)
	ld	(xde+97), a
	ld	(xde+98), 0
	ld	(xde+99), 0
	ld	a, (xbc+14)
	ld	(xde+100), a
	ld	a, (xbc+18)
	ld	(xde+101), a
	ret
; Different in kind: patch+0x5E is set to 1 or 0 from bit 7 of descriptor+0x13,
; patch+0x5F = descriptor+0x02 & 0x3F, patch+0x60 = descriptor+0x00, patch+0x61..+0x64 = 0,
; patch+0x65 = descriptor+0x12.
DSP_EffParam_Copy_V6:
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+wa)
	ld	a, c
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	bitm	7, (xbc+19)
	jr	z, DSP_EffParam_Copy_V6_FlagClear
	ld	(xde+94), 1
	jr	t, DSP_EffParam_Copy_V6_CopyRemaining
; Descriptor+0x13 bit 7 clear -> patch+0x5E = 0.
DSP_EffParam_Copy_V6_FlagClear:
	ld	(xde+94), 0
; Common tail: the +0x02/&0x3F, +0x00, four zeros, +0x12 stores.
DSP_EffParam_Copy_V6_CopyRemaining:
	ld	a, (xbc+2)
	and	a, 63
	ld	(xde+95), a
	ld	a, (xbc)
	ld	(xde+96), a
	ld	(xde+97), 0
	ld	(xde+98), 0
	ld	(xde+99), 0
	ld	(xde+100), 0
	ld	a, (xbc+18)
	ld	(xde+101), a
	ret
; As V6 but patch+0x64 takes descriptor+0x0E instead of zero.
DSP_EffParam_Copy_V7:
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+wa)
	ld	a, c
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	bitm	7, (xbc+19)
	jr	z, DSP_EffParam_Copy_V7_FlagClear
	ld	(xde+94), 1
	jr	t, DSP_EffParam_Copy_V7_CopyRemaining
; Descriptor+0x13 bit 7 clear -> patch+0x5E = 0.
DSP_EffParam_Copy_V7_FlagClear:
	ld	(xde+94), 0
; Common tail of V7.
DSP_EffParam_Copy_V7_CopyRemaining:
	ld	a, (xbc+2)
	and	a, 63
	ld	(xde+95), a
	ld	a, (xbc)
	ld	(xde+96), a
	ld	(xde+97), 0
	ld	(xde+98), 0
	ld	(xde+99), 0
	ld	a, (xbc+14)
	ld	(xde+100), a
	ld	a, (xbc+18)
	ld	(xde+101), a
	ret
; Input A = part.  Reads the part's algorithm type ((patch+0x5D) & 0x0F); if it is outside
; 0..0x0B it returns.  Otherwise jumps through DSP_EFFPARAM_APPLY_JUMPTABLE (0x00F99B, base
; 0x02F2D9); each of the twelve cases loads BC with a descriptor index and tail-jumps to one
; of the DSP_EFFPARAM_COPY_Vn routines:
;   type 0->V0/0  1->V0/1  2->V0/2  3->V0/3  4->V1/4  5->V1/5  6->V2/6  7->V3/7
;   type 8->V4/8  9->V5/9  A->V6/0x0A  B->V7/0x0B
; Called from 0x02FC2D (opcode 0x5D with rec+5 == 0x0F).
DSP_EffParam_Apply_By_AlgoType:
	ld	c, a
	extz	bc
	muls	bc, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xde+bc)
	ld	c, (xbc+93)
	and	c, 15
	extz	bc
	cp	bc, 0:i3
	ret	mi
	cp	bc, 11
	ret	gt
	add	bc, bc
	lda	xix, (DSP_EFFPARAM_APPLY_JUMPTABLE:24)
	ld	bc, (xix+bc)
	lda	xix, (DSP_EffParam_Apply_T0:24)
	jp	t, (xix+bc)
; Algorithm type 0: DSP_EffParam_Copy_V0 with descriptor 0.
DSP_EffParam_Apply_T0:
	extz	wa
	ld	bc, 0:i3
	jrl	t, DSP_EffParam_Copy_V0
; Algorithm type 1: DSP_EffParam_Copy_V0 with descriptor 1.
DSP_EffParam_Apply_T1:
	extz	wa
	ld	bc, 1:i3
	jrl	t, DSP_EffParam_Copy_V0
; Algorithm type 2: DSP_EffParam_Copy_V0 with descriptor 2.
DSP_EffParam_Apply_T2:
	extz	wa
	ld	bc, 2:i3
	jrl	t, DSP_EffParam_Copy_V0
; Algorithm type 3: DSP_EffParam_Copy_V0 with descriptor 3.
DSP_EffParam_Apply_T3:
	extz	wa
	ld	bc, 3:i3
	jrl	t, DSP_EffParam_Copy_V0
; Algorithm type 4: DSP_EffParam_Copy_V1 with descriptor 4.
DSP_EffParam_Apply_T4:
	extz	wa
	ld	bc, 4:i3
	jrl	t, DSP_EffParam_Copy_V1
; Algorithm type 5: DSP_EffParam_Copy_V1 with descriptor 5.
DSP_EffParam_Apply_T5:
	extz	wa
	ld	bc, 5:i3
	jrl	t, DSP_EffParam_Copy_V1
; Algorithm type 6: DSP_EffParam_Copy_V2 with descriptor 6.
DSP_EffParam_Apply_T6:
	extz	wa
	ld	bc, 6:i3
	jrl	t, DSP_EffParam_Copy_V2
; Algorithm type 7: DSP_EffParam_Copy_V3 with descriptor 7.
DSP_EffParam_Apply_T7:
	extz	wa
	ld	bc, 7:i3
	jrl	t, DSP_EffParam_Copy_V3
; Algorithm type 8: DSP_EffParam_Copy_V4 with descriptor 8.
DSP_EffParam_Apply_T8:
	extz	wa
	ldw	bc, 8
	jrl	t, DSP_EffParam_Copy_V4
; Algorithm type 9: DSP_EffParam_Copy_V5 with descriptor 9.
DSP_EffParam_Apply_T9:
	extz	wa
	ldw	bc, 9
	jrl	t, DSP_EffParam_Copy_V5
; Algorithm type 0x0A: DSP_EffParam_Copy_V6 with descriptor 0x0A.
DSP_EffParam_Apply_TA:
	extz	wa
	ldw	bc, 10
	jrl	t, DSP_EffParam_Copy_V6
; Algorithm type 0x0B: DSP_EffParam_Copy_V7 with descriptor 0x0B.
DSP_EffParam_Apply_TB:
	extz	wa
	ldw	bc, 11
	jrl	t, DSP_EffParam_Copy_V7
	ret
; Input A = part.  Re-runs the part's DSP output routing after a parameter change.
; Reads the algorithm type; types outside 0..7 do nothing.  Dispatches through
; VOICE_DSPOUT_A_JUMPTABLE (0x00F9B3, base 0x02F36E) onto Voice_DSP_OutputConfig (0x027CE4)
; and Voice_DSP_SimpleCopy (0x027EBE).  Called from 0x02FC6A and 0x02FCE2.
Voice_DSPOut_Apply_A:
	dec	2, xsp
	ld	(xsp), a
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld	a, (xwa+93)
	and	a, 15
	extz	wa
	cp	wa, 0:i3
	jr	mi, Voice_DSPOut_A_Return
	cp	wa, 7:i3
	jr	gt, Voice_DSPOut_A_Return
	add	wa, wa
	lda	xix, (VOICE_DSPOUT_A_JUMPTABLE:24)
	ld	wa, (xix+wa)
	lda	xix, (Voice_DSPOut_A_Type0To3:24)
	jp	t, (xix+wa)
; Algorithm types 0..3: Voice_DSP_OutputConfig(part, 0) then (part, 1).
Voice_DSPOut_A_Type0To3:
	ld	a, (xsp)
	extz	wa
	ld	bc, 0:i3
	call	Voice_DSP_OutputConfig
	ld	a, (xsp)
	extz	wa
	ld	bc, 1:i3
	call	Voice_DSP_OutputConfig
	jr	t, Voice_DSPOut_A_Return
; Algorithm types 4..5: Voice_DSP_OutputConfig(part, 0) only.
Voice_DSPOut_A_Type4To5:
	ld	a, (xsp)
	extz	wa
	ld	bc, 0:i3
	call	Voice_DSP_OutputConfig
	jr	t, Voice_DSPOut_A_Return
; Algorithm type 6: Voice_DSP_SimpleCopy(part).
Voice_DSPOut_A_Type6:
	ld	a, (xsp)
	extz	wa
	call	Voice_DSP_SimpleCopy
	jr	t, Voice_DSPOut_A_Return
; Algorithm type 7: only if PART+0x0A bit 14 is set, Voice_DSP_OutputConfig(part, 0).
Voice_DSPOut_A_Type7:
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x24fc:24)
	ld	wa, (xbc+wa)
	bit	14, wa
	jr	z, Voice_DSPOut_A_Return
	ld	a, (xsp)
	extz	wa
	ld	bc, 0:i3
	call	Voice_DSP_OutputConfig
; Pop the one-word frame and return.
Voice_DSPOut_A_Return:
	inc	2, xsp
	ret
; Twin of Voice_DSPOut_Apply_A driving the second output bank: Voice_DSP_OutputConfig2
; (0x027DD1) and Voice_DSP_SimpleCopy2 (0x027F19), table VOICE_DSPOUT_B_JUMPTABLE
; (0x00F9C3, base 0x02F3FA).  Called from 0x02FC75 and 0x02FCF0.
Voice_DSPOut_Apply_B:
	dec	2, xsp
	ld	(xsp), a
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld	a, (xwa+93)
	and	a, 15
	extz	wa
	cp	wa, 0:i3
	jr	mi, Voice_DSPOut_B_Return
	cp	wa, 7:i3
	jr	gt, Voice_DSPOut_B_Return
	add	wa, wa
; CORRECTED FRAMING: the next 5+5 bytes were `.byte 0xf2 / xor c,(xiz+13312) / reti /
; .byte 0xf0,0xe0,0x20`, a misreading of `lda xix,(table:24)` + `ld wa,(xix+wa)` (unidasm
; frames them so; they are the same two instructions as in Voice_DSPOut_Apply_A).
	lda	xix, (VOICE_DSPOUT_B_JUMPTABLE:24)
	ld	wa, (xix+wa)
	lda	xix, (Voice_DSPOut_B_Type0To3:24)
	jp	t, (xix+wa)
; Algorithm types 0..3: Voice_DSP_OutputConfig2(part, 0) then (part, 1).
Voice_DSPOut_B_Type0To3:
	ld	a, (xsp)
	extz	wa
	ld	bc, 0:i3
	call	Voice_DSP_OutputConfig2
	ld	a, (xsp)
	extz	wa
	ld	bc, 1:i3
	call	Voice_DSP_OutputConfig2
	jr	t, Voice_DSPOut_B_Return
; Algorithm types 4..5: Voice_DSP_OutputConfig2(part, 0) only.
Voice_DSPOut_B_Type4To5:
	ld	a, (xsp)
	extz	wa
	ld	bc, 0:i3
	call	Voice_DSP_OutputConfig2
	jr	t, Voice_DSPOut_B_Return
; Algorithm type 6: Voice_DSP_SimpleCopy2(part).
Voice_DSPOut_B_Type6:
	ld	a, (xsp)
	extz	wa
	call	Voice_DSP_SimpleCopy2
	jr	t, Voice_DSPOut_B_Return
; Algorithm type 7: only if PART+0x0A bit 14 is set, Voice_DSP_OutputConfig2(part, 0)
; followed by Voice_DSP_SimpleCopy2(part).
Voice_DSPOut_B_Type7:
	ld	a, (xsp)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x24fc:24)
	ld	wa, (xbc+wa)
	bit	14, wa
	jr	z, Voice_DSPOut_B_Return
	ld	a, (xsp)
	extz	wa
	ld	bc, 0:i3
	call	Voice_DSP_OutputConfig2
	ld	a, (xsp)
	extz	wa
	call	Voice_DSP_SimpleCopy2
; Pop the one-word frame and return.
Voice_DSPOut_B_Return:
	inc	2, xsp
	ret
; Input A = part.  Applies the SECOND output slot only, and only for algorithm types 4..0x0B
; ((patch+0x5D & 0x0F) - 4 must be in 0..7).  Table VOICE_DSPOUT_SECOND_A_JUMPTABLE
; (0x00F9D3, base 0x02F48C).  Called from 0x02FC80 and 0x02FD09.
Voice_DSPOut_Second_A:
	ld	c, a
	extz	bc
	muls	bc, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xde+bc)
	ld	c, (xbc+93)
	and	c, 15
	extz	bc
	dec	4, bc
	cp	bc, 0:i3
	ret	lt
	cp	bc, 7:i3
	ret	gt
	add	bc, bc
; CORRECTED FRAMING, as in Voice_DSPOut_Apply_B: `lda xix,(table:24)` + `ld bc,(xix+bc)`.
	lda	xix, (VOICE_DSPOUT_SECOND_A_JUMPTABLE:24)
	ld	bc, (xix+bc)
	lda	xix, (Voice_DSPOut_Second_A_Slot1:24)
	jp	t, (xix+bc)
; Types 4..5: tail-jump Voice_DSP_OutputConfig(part, 1).
Voice_DSPOut_Second_A_Slot1:
	extz	wa
	ld	bc, 1:i3
	jp	Voice_DSP_OutputConfig
; Type 6: tail-jump Voice_DSP_SimpleCopy(part).
Voice_DSPOut_Second_A_Simple:
	extz	wa
	jp	Voice_DSP_SimpleCopy
; Type 7: return unless PART+0x0A bit 14 is set, then Voice_DSP_OutputConfig(part, 1).
Voice_DSPOut_Second_A_Gated:
	ld	c, a
	extz	bc
	muls	bc, 287
	lda	xde, (Payload_Bss_Start+0x24fc:24)
	ld	bc, (xde+bc)
	bit	14, bc
	ret	z
	extz	wa
	ld	bc, 1:i3
	jp	Voice_DSP_OutputConfig
; Types 0x0A..0x0B: tail-jump Voice_DSP_OutputConfig(part, 0).
Voice_DSPOut_Second_A_Slot0:
	extz	wa
	ld	bc, 0:i3
	jp	Voice_DSP_OutputConfig
; Types 8..9: bare return.
Voice_DSPOut_Second_A_None:
	ret
; Second-bank twin of Voice_DSPOut_Second_A, written as an if-chain instead of a table:
; algorithm types 4 and 5 -> Voice_DSP_OutputConfig2(part, 1); type 7 -> the same but only
; when PART+0x0A bit 14 is set; every other type returns.  Called from 0x02FC8B, 0x02FD22.
Voice_DSPOut_Second_B:
	ld	c, a
	extz	bc
	muls	bc, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xde+bc)
	ld	c, (xbc+93)
	and	c, 15
	cp	c, 7:i3
	jr	z, Voice_DSPOut_Second_B_Gated
	cp	c, 5:i3
	jr	z, Voice_DSPOut_Second_B_Slot1
	cp	c, 4:i3
	ret	nz
; Tail-jump Voice_DSP_OutputConfig2(part, 1).
Voice_DSPOut_Second_B_Slot1:
	extz	wa
	ld	bc, 1:i3
	jp	Voice_DSP_OutputConfig2
; Algorithm type 7: gate on PART+0x0A bit 14 before the same call.
Voice_DSPOut_Second_B_Gated:
	ld	c, a
	extz	bc
	muls	bc, 287
	lda	xde, (Payload_Bss_Start+0x24fc:24)
	ld	bc, (xde+bc)
	bit	14, bc
	ret	z
	extz	wa
	ld	bc, 1:i3
	jp	Voice_DSP_OutputConfig2

; Input A = part, C = flag.  Calls VoiceAlloc_CheckAndInit(part) and then sets or clears
; bit 7 of the parameter-shadow byte 0x04502B (= UserTone_VelSplit_Base + 0x5D, i.e. the
; cached value of opcode 0x5D) according to C.  Single caller: 0x02A148.
VoiceAlloc_WithRoutingFlag:
	dec 2, xsp
	ld (xsp), c
	extz wa
	calr VoiceAlloc_CheckAndInit
	cp (xsp), 0x0
	jr z, VoiceAlloc_WithRoutingFlag_Clear
	set 7, (Payload_Bss_Start+0x61b5:24)
	jr VoiceAlloc_WithRoutingFlag_Return

; C == 0 -> res 7,(0x04502B).
VoiceAlloc_WithRoutingFlag_Clear:
	res 7, (Payload_Bss_Start+0x61b5:24)

; Pop the frame and return.
VoiceAlloc_WithRoutingFlag_Return:
	inc 2, xsp
	ret

; ALGORITHM GROUP 0 APPLY.  Input A = part, C = algorithm slot 0..3.  Not data: this is the
; first of three structurally identical routines (the others are 0x02F630 and 0x02F735).
; Steps:
;   1. AlgoFlag_Write(WA=part, DE=slot, BC=0) and AlgoFlag_Write_Bit3(same, BC=0)
;   2. EFF_RoutingInit(WA=part, BC=0..3, DE=0) for all four routing slots
;   3. Voice_BuildOutputList(WA=part, BC=slot, DE=0) -> XHL = word list of voice numbers
;   4. for each entry: Voice_OpSlot_WriteParams(part, PART record, slot, voice, group=0),
;      EGEnv_Compute_A (0x022E2A) -> 0x04520C, EGEnv_Compute_A_Simple (0x022EBA) -> 0x045208,
;      then ToneGen_WriteExtParams_56 (0x02DA16) with XBC = TG_Scratch_Base (0x0451CC).
;   Loop terminator: stop when (list word & 0x00FF) >= 0x80.
; This is the only place group 0 parameters reach the tone generator after an edit.
; Callers verified by disassembly: 0x02E8C4 and 0x02E8D9 (both with BC = 0), and the four
; opcode-group cases at 0x02FB65, 0x02FB75, 0x02FB85, 0x02FB95 (slots 0..3).
; ★ Renamed 2026-09-25 from VoiceAlloc_WithRoutingFlag_ExtData: header: ALGORITHM GROUP 0 APPLY; siblings are VoiceAlloc_Apply_Algo_Group1/2.
VoiceAlloc_Apply_Algo_Group0:
	lda	xsp, (xsp-10)
	push xiz
	ld	(xsp+10), c
	ld	(xsp+12), a
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	call	AlgoFlag_Write
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	call	AlgoFlag_Write_Bit3
	ldib_erp	251, 0
	cpib_erp	251, 4
	jr	nc, VoiceAlloc_Apply_Grp0_BuildList
; Body of the four-iteration EFF_RoutingInit loop, counter in QIZH.
VoiceAlloc_Apply_Grp0_RoutingLoop:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	EFF_RoutingInit
	incb_erp	251, 1
	cpib_erp	251, 4
	jr	c, VoiceAlloc_Apply_Grp0_RoutingLoop
; Routing done: call Voice_BuildOutputList and stash the list pointer at (XSP+0x04),
; cursor at (XSP+0x08).
VoiceAlloc_Apply_Grp0_BuildList:
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	a, (xsp+10)
	extz	wa
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ldw	(xsp+8), 0
	jr	t, VoiceAlloc_Apply_Grp0_VoiceLoop_Test
; Per-voice body: fetch list[cursor] into IZ, write the op-slot parameters, compute both
; envelopes and push the result to the tone generator.
VoiceAlloc_Apply_Grp0_VoiceLoop:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add	xwa, (xsp+4)
	ld	iz, (xwa)
	ldib_erp	249, 0
	ld	a, (xsp+12)
	ld	l, a
	extz	hl
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	pushw 0
	ldto_berp	a, 248
	extz	wa
	pushw wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	ldto_berp	a, 248
	extz	wa
	call	EGEnv_Compute_A
	ld	(Payload_Bss_Start+0x6396:24), hl
	ldto_berp	a, 248
	extz	wa
	call	EGEnv_Compute_A_Simple
	ld	(Payload_Bss_Start+0x6392:24), hl
	ld	wa, iz
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_WriteExtParams_56
	incw	1, (xsp+8)
; Loop condition: re-read list[cursor] and continue while (word & 0xFF) < 0x80.
VoiceAlloc_Apply_Grp0_VoiceLoop_Test:
	ld	wa, (xsp+8)
	extz	xwa
	add	xwa, xwa
	add	xwa, (xsp+4)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jr	c, VoiceAlloc_Apply_Grp0_VoiceLoop
	pop xiz
	lda	xsp, (xsp+10)
	ret
; ALGORITHM GROUP 1 APPLY.  Same five steps as 0x02F52A with group = 1 throughout:
; AlgoFlag_Write(...,BC=1), AlgoFlag_Write_Bit3(...,BC=1), EFF_RoutingInit(...,DE=1),
; Voice_BuildOutputList with the slot number OR 4 (`set 2,WA`), Voice_OpSlot_WriteParams
; with group 1, EGEnv_Compute_B (0x022F3C) -> 0x045204, EGEnv_Compute_B_Simple (0x022FCC)
; -> 0x045206, ToneGen_WriteExtParams_15 (0x02DC50).
; ★ Its voice-list loop terminates on (word & 0xFF) >= 0x40, not >= 0x80 like the other two.
; Callers: opcodes 0x2F..0x32 (0x02FBA5..0x02FBD5).
VoiceAlloc_Apply_Algo_Group1:
	dec	8, xsp
	push xiz
	ld	(xsp+8), c
	ld	(xsp+10), a
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ld	a, (xsp+8)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	call	AlgoFlag_Write
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ld	a, (xsp+8)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	call	AlgoFlag_Write_Bit3
	ldib_erp	251, 0
	cpib_erp	251, 4
	jr	nc, VoiceAlloc_Apply_Grp1_BuildList
; Four-iteration EFF_RoutingInit loop with DE = 1.
VoiceAlloc_Apply_Grp1_RoutingLoop:
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 1:i3
	call	EFF_RoutingInit
	incb_erp	251, 1
	cpib_erp	251, 4
	jr	c, VoiceAlloc_Apply_Grp1_RoutingLoop
; Voice_BuildOutputList with selector = slot | 4.
VoiceAlloc_Apply_Grp1_BuildList:
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ld	a, (xsp+8)
	extz	wa
	set	2, wa
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ld	qiz, 0
	jr	t, VoiceAlloc_Apply_Grp1_VoiceLoop_Test
; Per-voice body for group 1.
VoiceAlloc_Apply_Grp1_VoiceLoop:
	ld	wa, qiz
	extz	xwa
	add	xwa, xwa
	add	xwa, (xsp+4)
	ld	iz, (xwa)
	ldib_erp	249, 0
	ld	a, (xsp+10)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	pushw 1
	ldto_berp	a, 248
	extz	wa
	pushw wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	ldto_berp	a, 248
	extz	wa
	call	EGEnv_Compute_B
	ld	(Payload_Bss_Start+0x638e:24), hl
	ldto_berp	a, 248
	extz	wa
	call	EGEnv_Compute_B_Simple
	ld	(Payload_Bss_Start+0x6390:24), hl
	ld	wa, iz
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_WriteExtParams_15
	inc	1, qiz
; Loop condition: continue while (list word & 0xFF) < 0x40.
VoiceAlloc_Apply_Grp1_VoiceLoop_Test:
	ld	wa, qiz
	extz	xwa
	add	xwa, xwa
	add	xwa, (xsp+4)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 64
	jr	c, VoiceAlloc_Apply_Grp1_VoiceLoop
	pop xiz
	inc	8, xsp
	ret
; ALGORITHM GROUP 2 APPLY.  Group = 2 throughout; Voice_BuildOutputList selector = slot | 8
; (`set 3,WA`); per voice it calls Voice_OpSlot_WriteParams(group 2), Voice_Freq_WriteLeft
; (0x023043), Voice_Freq_WriteRight (0x02315F) and ToneGen_WriteExtParams_15_Banked (0x02DD6D).
; Loop terminator (word & 0xFF) >= 0x80.  Callers: opcodes 0x33..0x36 (0x02FBE5..0x02FC15).
VoiceAlloc_Apply_Algo_Group2:
	dec	8, xsp
	push xiz
	ld	(xsp+8), c
	ld	(xsp+10), a
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ld	a, (xsp+8)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	call	AlgoFlag_Write
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ld	a, (xsp+8)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	call	AlgoFlag_Write_Bit3
	ldib_erp	251, 0
	cpib_erp	251, 4
	jr	nc, VoiceAlloc_Apply_Grp2_BuildList
; Four-iteration EFF_RoutingInit loop with DE = 2.
VoiceAlloc_Apply_Grp2_RoutingLoop:
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 2:i3
	call	EFF_RoutingInit
	incb_erp	251, 1
	cpib_erp	251, 4
	jr	c, VoiceAlloc_Apply_Grp2_RoutingLoop
; Voice_BuildOutputList with selector = slot | 8.
VoiceAlloc_Apply_Grp2_BuildList:
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ld	a, (xsp+8)
	extz	wa
	set	3, wa
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	Voice_BuildOutputList
	ld	(xsp+4), xhl
	ld	qiz, 0
	jr	t, VoiceAlloc_Apply_Grp2_VoiceLoop_Test
; Per-voice body for group 2 (frequency writes rather than envelope writes).
VoiceAlloc_Apply_Grp2_VoiceLoop:
	ld	wa, qiz
	extz	xwa
	add	xwa, xwa
	add	xwa, (xsp+4)
	ld	iz, (xwa)
	ldib_erp	249, 0
	ld	a, (xsp+10)
	ld	l, a
	extz	hl
	ld	a, (xsp+10)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	pushw 2
	ldto_berp	a, 248
	extz	wa
	pushw wa
	ld	wa, hl
	call	Voice_OpSlot_WriteParams
	ldto_berp	a, 248
	extz	wa
	call	Voice_Freq_WriteLeft
	ldto_berp	a, 248
	extz	wa
	call	Voice_Freq_WriteRight
	ld	wa, iz
	lda	xbc, (ToneGen_StagingBlock:24)
	call	ToneGen_WriteExtParams_15_Banked
	inc	1, qiz
; Loop condition: continue while (list word & 0xFF) < 0x80.
VoiceAlloc_Apply_Grp2_VoiceLoop_Test:
	ld	wa, qiz
	extz	xwa
	add	xwa, xwa
	add	xwa, (xsp+4)
	ld	wa, (xwa)
	and	wa, 255
	cp	wa, 128
	jr	c, VoiceAlloc_Apply_Grp2_VoiceLoop
	pop xiz
	inc	8, xsp
	ret
; Second command dispatcher.  Entry XWA = command record; part goes to QIZH.
; Stage 1 accepts opcodes 0x15..0x27 through AUDIO_CMD_EFFECTPARAM_JUMPTABLE (0x00FA76,
; base 0x02F86F); only every third opcode has a handler, and each handler forwards to
; AudioChannel_Dispatch (0x029E31) with XDE pointing at one of the seven 3-byte parameter
; groups inside the patch record.  All handlers then fall into
; Audio_Cmd_EffParam_Cache_And_Dispatch2, which caches the value and runs a much larger
; second stage.  Sole caller: 0x031AB3.
Audio_Cmd_EffectParam_Dispatch:
	dec	4, xsp
	push qiz
	ld	(xsp+2), xwa
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	ldfr_berp	a, 251
	ld	xwa, (xsp+2)
	ld	a, (xwa+2)
	extz	wa
	sub	wa, 21
	cp	wa, 0:i3
	jrl	lt, Audio_Cmd_EffParam_Cache_And_Dispatch2
	cp	wa, 18
	jrl	gt, Audio_Cmd_EffParam_Cache_And_Dispatch2
	add	wa, wa
	lda	xix, (AUDIO_CMD_EFFECTPARAM_JUMPTABLE:24)
	ld	wa, (xix+wa)
	lda	xix, (Audio_Cmd_EffParam_Grp0:24)
	jp	t, (xix+wa)
; Opcode 0x15: AudioChannel_Dispatch(WA=part, XDE=&patch[0x14], BC=0).
Audio_Cmd_EffParam_Grp0:
	ldto_berp	a, 251
	ld	l, a
	extz	hl
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xde, (xwa+20)
	ld	wa, hl
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Cache_And_Dispatch2
; Opcode 0x18: AudioChannel_Dispatch(WA=part, XDE=&patch[0x17], BC=0).
Audio_Cmd_EffParam_Grp1:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+23)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Cache_And_Dispatch2
; Opcode 0x1B: AudioChannel_Dispatch(WA=part, XDE=&patch[0x1A], BC=0).
Audio_Cmd_EffParam_Grp2:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+26)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Cache_And_Dispatch2
; Opcode 0x1E: AudioChannel_Dispatch(WA=part, XDE=&patch[0x1D], BC=0).
Audio_Cmd_EffParam_Grp3:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+29)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jr	t, Audio_Cmd_EffParam_Cache_And_Dispatch2
; Opcode 0x21: AudioChannel_Dispatch(WA=part, XDE=&patch[0x20], BC=0).
Audio_Cmd_EffParam_Grp4:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+32)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jr	t, Audio_Cmd_EffParam_Cache_And_Dispatch2
; Opcode 0x24: AudioChannel_Dispatch(WA=part, XDE=&patch[0x23], BC=0).
Audio_Cmd_EffParam_Grp5:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+35)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jr	t, Audio_Cmd_EffParam_Cache_And_Dispatch2
; Opcode 0x27: AudioChannel_Dispatch(WA=part, XDE=&patch[0x26], BC=0).
Audio_Cmd_EffParam_Grp6:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+38)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
; Common tail of stage 1 and the entry to stage 2.  Stores (rec+4) into the parameter shadow
; at UserTone_VelSplit_Base + opcode (0x044FCE + opcode), then range-checks the opcode:
; 0x00..0x10 exit, 0x11..0x65 continue.
Audio_Cmd_EffParam_Cache_And_Dispatch2:
	lda	xwa, (Payload_Bss_Start+0x6158:24)
	ld	xbc, xwa
	ld	xwa, (xsp+2)
	ld	a, (xwa+2)
	extz	wa
	lda	xbc, (xbc+wa)
	ld	xwa, (xsp+2)
	ld	a, (xwa+4)
	ld	(xbc), a
	ld	xwa, (xsp+2)
	ld	a, (xwa+2)
	cp	a, 16
	jr	ugt, Audio_Cmd_EffParam_TableJump
	cp	a, 0:i3
	jrl	nc, Audio_Cmd_EffParam_Return
; Two-level lookup: AUDIO_CMD_EFFPARAM_CASEMAP (0x00F9E3) maps opcode-0x11 to a case number,
; which indexes AUDIO_CMD_EFFPARAM_JUMPTABLE (0x00FA38) with base 0x02F9FA.
Audio_Cmd_EffParam_TableJump:
	extz	wa
	sub	wa, 17
	cp	wa, 0:i3
	jrl	lt, Audio_Cmd_EffParam_Return
	cp	wa, 84
	jrl	gt, Audio_Cmd_EffParam_Return
	lda	xix, (AUDIO_CMD_EFFPARAM_CASEMAP:24)
	ld	wa, (xix+wa)
	extz	wa
	sll	wa, 1
	ld	xix, AUDIO_CMD_EFFPARAM_JUMPTABLE
	ld	wa, (xix+wa)
	lda	xix, (Audio_Cmd_EffParam_TableJump_CaseBase:24)
	jp	t, (xix+wa)
Audio_Cmd_EffParam_TableJump_CaseBase:
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x11: Partial_Build_Present_Word(part) then EnvTranspose_UpdateLoop(part).
Audio_Cmd_EffParam_Op11:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	Partial_Build_Present_Word
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	EnvTranspose_UpdateLoop
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x12: Partial_Build_Present_Word(part) only.
Audio_Cmd_EffParam_Op12:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	Partial_Build_Present_Word
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x14: AudioChannel_Dispatch(part, &patch[0x1D], 0).
Audio_Cmd_EffParam_Op14:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+29)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x17: AudioChannel_Dispatch(part, &patch[0x17], 0).
Audio_Cmd_EffParam_Op17:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+23)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x1A: AudioChannel_Dispatch(part, &patch[0x1A], 0).
Audio_Cmd_EffParam_Op1A:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+26)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x1D: AudioChannel_Dispatch(part, &patch[0x1D], 0).
Audio_Cmd_EffParam_Op1D:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+29)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x20: AudioChannel_Dispatch(part, &patch[0x20], 0).
Audio_Cmd_EffParam_Op20:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+32)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x23: AudioChannel_Dispatch(part, &patch[0x23], 0).
Audio_Cmd_EffParam_Op23:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+35)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x26: AudioChannel_Dispatch(part, &patch[0x26], 0).
Audio_Cmd_EffParam_Op26:
	ldto_berp	a, 251
	ld	e, a
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	lda	xwa, (xwa+38)
	ld	xbc, xwa
	ld	wa, de
	ld	xde, xbc
	ld	bc, 0:i3
	call	AudioChannel_Dispatch
	jrl	t, Audio_Cmd_EffParam_Return
; Opcodes 0x2B..0x2E: VoiceAlloc_Apply_Algo_Group0(part, slot 0) -- group 0 apply.
; Note all four opcodes of the run share this case and therefore share slot 0; the per-slot
; distinction is carried by the next three cases, not by the opcode's low bits.
Audio_Cmd_EffParam_Grp0_Slot0:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 0:i3
	calr	VoiceAlloc_Apply_Algo_Group0
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x2F..0x32: VoiceAlloc_Apply_Algo_Group0(part, slot 1).
Audio_Cmd_EffParam_Grp0_Slot1:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 1:i3
	calr	VoiceAlloc_Apply_Algo_Group0
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x33..0x36: VoiceAlloc_Apply_Algo_Group0(part, slot 2).
Audio_Cmd_EffParam_Grp0_Slot2:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 2:i3
	calr	VoiceAlloc_Apply_Algo_Group0
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x37..0x3A: VoiceAlloc_Apply_Algo_Group0(part, slot 3).
Audio_Cmd_EffParam_Grp0_Slot3:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 3:i3
	calr	VoiceAlloc_Apply_Algo_Group0
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x3B..0x3E: VoiceAlloc_Apply_Algo_Group1(part, slot 0).
Audio_Cmd_EffParam_Grp1_Slot0:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 0:i3
	calr	VoiceAlloc_Apply_Algo_Group1
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x3F..0x42: VoiceAlloc_Apply_Algo_Group1(part, slot 1).
Audio_Cmd_EffParam_Grp1_Slot1:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 1:i3
	calr	VoiceAlloc_Apply_Algo_Group1
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x43..0x46: VoiceAlloc_Apply_Algo_Group1(part, slot 2).
Audio_Cmd_EffParam_Grp1_Slot2:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 2:i3
	calr	VoiceAlloc_Apply_Algo_Group1
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x47..0x4A: VoiceAlloc_Apply_Algo_Group1(part, slot 3).
Audio_Cmd_EffParam_Grp1_Slot3:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 3:i3
	calr	VoiceAlloc_Apply_Algo_Group1
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x4B..0x4E: VoiceAlloc_Apply_Algo_Group2(part, slot 0).
Audio_Cmd_EffParam_Grp2_Slot0:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 0:i3
	calr	VoiceAlloc_Apply_Algo_Group2
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x4F..0x52: VoiceAlloc_Apply_Algo_Group2(part, slot 1).
Audio_Cmd_EffParam_Grp2_Slot1:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 1:i3
	calr	VoiceAlloc_Apply_Algo_Group2
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x53..0x56: VoiceAlloc_Apply_Algo_Group2(part, slot 2).
Audio_Cmd_EffParam_Grp2_Slot2:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 2:i3
	calr	VoiceAlloc_Apply_Algo_Group2
	jrl	Audio_Cmd_EffParam_Return
; Opcodes 0x57..0x5A: VoiceAlloc_Apply_Algo_Group2(part, slot 3).
Audio_Cmd_EffParam_Grp2_Slot3:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 3:i3
	calr	VoiceAlloc_Apply_Algo_Group2
	jrl	Audio_Cmd_EffParam_Return
; Opcode 0x5D with (rec+5) == 0x0F: the heaviest case in the region.  In order:
; DSP_EffParam_Apply_By_AlgoType, AlgoType_StateWrite(part, 0), Partial_Build_Present_Word,
; EnvTranspose_UpdateLoop, VoiceNoteParam_UpdateLoop, Voice_DSPOut_Apply_A,
; Voice_DSPOut_Apply_B, Voice_DSPOut_Second_A, Voice_DSPOut_Second_B,
; Voice_ActiveFlag_CheckAndLoad, Voice_SecondaryParam_Epilogue, and finally L is stored into
; PART+0x66 (0x0413CE + part*0x11F).
Audio_Cmd_EffParam_Op5D_FullRebuild:
	ld	xwa, (xsp+2)
	cp	(xwa+5), 15
	jrl	nz, Audio_Cmd_EffParam_Op5D_Light
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	DSP_EffParam_Apply_By_AlgoType
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	ld	bc, 0:i3
	call	AlgoType_StateWrite
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	Partial_Build_Present_Word
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	EnvTranspose_UpdateLoop
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	VoiceNoteParam_UpdateLoop
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	Voice_DSPOut_Apply_A
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	Voice_DSPOut_Apply_B
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	Voice_DSPOut_Second_A
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	Voice_DSPOut_Second_B
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	Voice_ActiveFlag_CheckAndLoad
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	Voice_SecondaryParam_Epilogue
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2558:24)
	ld	(xbc+wa), l
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x5D with (rec+5) != 0x0F: only Partial_Build_Present_Word + EnvTranspose_UpdateLoop.
Audio_Cmd_EffParam_Op5D_Light:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	Partial_Build_Present_Word
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	EnvTranspose_UpdateLoop
	jrl	t, Audio_Cmd_EffParam_Return
; Opcode 0x5E: Voice_DSPOut_Apply_A(part).
Audio_Cmd_EffParam_Op5E:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	Voice_DSPOut_Apply_A
	jrl	Audio_Cmd_EffParam_Return
; Opcode 0x5F: Voice_DSPOut_Apply_B(part) then VoiceNoteParam_UpdateLoop(part).
Audio_Cmd_EffParam_Op5F:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	Voice_DSPOut_Apply_B
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	VoiceNoteParam_UpdateLoop
	jr	t, Audio_Cmd_EffParam_Return
; Opcode 0x60: Voice_DSPOut_Second_A(part) then VoiceNoteParam_UpdateLoop(part).
Audio_Cmd_EffParam_Op60:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	Voice_DSPOut_Second_A
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	VoiceNoteParam_UpdateLoop
	jr	t, Audio_Cmd_EffParam_Return
; Opcode 0x61: Voice_DSPOut_Second_B(part) then VoiceNoteParam_UpdateLoop(part).
Audio_Cmd_EffParam_Op61:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	calr	Voice_DSPOut_Second_B
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	VoiceNoteParam_UpdateLoop
	jr	t, Audio_Cmd_EffParam_Return
; Opcode 0x62: VoiceNoteParam_UpdateLoop(part) only.
Audio_Cmd_EffParam_Op62:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	VoiceNoteParam_UpdateLoop
	jr	t, Audio_Cmd_EffParam_Return
; Opcode 0x63: identical to opcode 0x62 (duplicated case body).
Audio_Cmd_EffParam_Op63:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	VoiceNoteParam_UpdateLoop
	jr	t, Audio_Cmd_EffParam_Return
; Opcode 0x64: Voice_ActiveFlag_CheckAndLoad(part).
Audio_Cmd_EffParam_Op64:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	Voice_ActiveFlag_CheckAndLoad
	jr	t, Audio_Cmd_EffParam_Return
; Opcode 0x65: Voice_SecondaryParam_Epilogue(part), then L into PART+0x66.
Audio_Cmd_EffParam_Op65:
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	call	Voice_SecondaryParam_Epilogue
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2558:24)
	ld	(xbc+wa), l
; Restore QIZ, drop the 4-byte frame, return.  Every stage-1 and stage-2 case joins here.
Audio_Cmd_EffParam_Return:
	pop qiz
	inc	4, xsp
	ret
; Input WA = part, C = slot 0..3.  XDE = the slot descriptor pointed to by
; PART + 0x6E + slot*0x25; XBC = the 5-byte cache at UserTone_VelSplit_Base + 0x1E0 + slot*5.
; If (descriptor+0x36 & 7) equals cache[0] the four cached bytes are copied straight into
; descriptor+0x4D..+0x50.  Otherwise it re-maps them according to the pair
; (cache[0], descriptor shape), which is what the branch tree below does.
; Called from Audio_Cmd_DSPUnit_Param opcode 0x36 (0x030167), gated on (rec+5) == 7.
DSP_SlotParam_Write_From_Cache:
	ld	e, c
	extz	de
	muls	de, 37
	ld	hl, de
	add	hl, 110
	extz	wa
	muls	wa, 287
	lda	xde, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xde
	ld	xde, (xwa+hl)
	ld	a, c
	extz	wa
	muls	wa, 5
	add	wa, 480
	lda	xbc, (Payload_Bss_Start+0x6158:24)
	lda	xbc, (xbc+wa)
	ld	a, (xde+54)
	and	a, 7
	cp	a, (xbc)
	jr	nz, DSP_SlotParam_Write_Remap
	ld	hl, 0:i3
	cp	hl, 4:i3
	ret	nc
; Shapes agree: copy cache[1..4] to descriptor+0x4D..+0x50 in a 4-iteration loop.
DSP_SlotParam_Write_Match_Loop:
	ld	wa, hl
	extz	xwa
	add	xwa, 77
	ld	xix, xwa
	add	xix, xde
	ld	wa, hl
	extz	xwa
	inc	1, xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	(xix), a
	inc	1, hl
	cp	hl, 4:i3
	jr	c, DSP_SlotParam_Write_Match_Loop
	ret
; Shapes differ: switch on cache[0] (1/3 -> 0x02FE05, 2/4 -> 0x02FE4B, 5 -> 0x02FE91,
; anything else -> return).
DSP_SlotParam_Write_Remap:
	ld	a, (xbc)
	cp	a, 5:i3
	jrl	z, DSP_SlotParam_Write_Shape5
	cp	a, 4:i3
	jr	z, DSP_SlotParam_Write_Shape2Or4
	cp	a, 2:i3
	jr	z, DSP_SlotParam_Write_Shape2Or4
	cp	a, 3:i3
	jr	z, DSP_SlotParam_Write_Shape1Or3
	cp	a, 1:i3
	ret	nz
; cache[0] in {1,3}: if the descriptor's shape is 5, write the fixed pattern
; {0x00, 0x01, cache[1], cache[2]}; otherwise fall back to the plain 4-byte copy.
DSP_SlotParam_Write_Shape1Or3:
	ld	a, (xde+54)
	and	a, 7
	cp	a, 5:i3
	jr	nz, DSP_SlotParam_Write_Shape1Or3_Plain
	ld	(xde+77), 0
	ld	(xde+78), 1
	ld	a, (xbc+1)
	ld	(xde+79), a
	ld	a, (xbc+2)
	ld	(xde+80), a
	ret
; Plain 4-byte copy fallback for the {1,3} branch.
DSP_SlotParam_Write_Shape1Or3_Plain:
	ld	hl, 0:i3
	cp	hl, 4:i3
	ret	nc
; Loop body of that fallback.
DSP_SlotParam_Write_Shape1Or3_Loop:
	ld	wa, hl
	extz	xwa
	add	xwa, 77
	ld	xix, xwa
	add	xix, xde
	ld	wa, hl
	extz	xwa
	inc	1, xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	(xix), a
	inc	1, hl
	cp	hl, 4:i3
	jr	c, DSP_SlotParam_Write_Shape1Or3_Loop
	ret
; cache[0] in {2,4}: if the descriptor's shape is 5, write {cache[1], cache[2], 0x7F, 0x01};
; otherwise plain copy.
DSP_SlotParam_Write_Shape2Or4:
	ld	a, (xde+54)
	and	a, 7
	cp	a, 5:i3
	jr	nz, DSP_SlotParam_Write_Shape2Or4_Plain
	ld	a, (xbc+1)
	ld	(xde+77), a
	ld	a, (xbc+2)
	ld	(xde+78), a
	ld	(xde+79), 127
	ld	(xde+80), 1
	ret
; Plain 4-byte copy fallback for the {2,4} branch.
DSP_SlotParam_Write_Shape2Or4_Plain:
	ld	hl, 0:i3
	cp	hl, 4:i3
	ret	nc
; Loop body of that fallback.
DSP_SlotParam_Write_Shape2Or4_Loop:
	ld	wa, hl
	extz	xwa
	add	xwa, 77
	ld	xix, xwa
	add	xix, xde
	ld	wa, hl
	extz	xwa
	inc	1, xwa
	add	xwa, xbc
	ld	a, (xwa)
	ld	(xix), a
	inc	1, hl
	cp	hl, 4:i3
	jr	c, DSP_SlotParam_Write_Shape2Or4_Loop
	ret
; cache[0] == 5: descriptor shape 1 or 3 -> write {cache[3], cache[4], 0x40, 0x87};
; shape 2 or 4 -> write {cache[1], cache[2], 0x40, 0x07}; other shapes -> return.
DSP_SlotParam_Write_Shape5:
	ld	a, (xde+54)
	and	a, 7
	cp	a, 4:i3
	jr	z, DSP_SlotParam_Write_Shape5_To24
	cp	a, 2:i3
	jr	z, DSP_SlotParam_Write_Shape5_To24
	cp	a, 3:i3
	jr	z, DSP_SlotParam_Write_Shape5_To13
	cp	a, 1:i3
	ret	nz
; Shape-5 source, shape-1/3 destination.
DSP_SlotParam_Write_Shape5_To13:
	ld	a, (xbc+3)
	ld	(xde+77), a
	ld	a, (xbc+4)
	ld	(xde+78), a
	ld	(xde+79), 64
	ld	(xde+80), 135
	ret
; Shape-5 source, shape-2/4 destination.
DSP_SlotParam_Write_Shape5_To24:
	ld	a, (xbc+1)
	ld	(xde+77), a
	ld	a, (xbc+2)
	ld	(xde+78), a
	ld	(xde+79), 64
	ld	(xde+80), 7
	ret
; Inverse of DSP_SlotParam_Write_From_Cache.  Same addressing; returns immediately unless
; (descriptor+0x36 & 7) equals cache[0], then copies descriptor+0x4D..+0x50 into cache[1..4].
; Called from Audio_Cmd_DSPUnit_Param opcodes 0x4D..0x50 (0x0301DC).
DSP_SlotParam_Read_To_Cache:
	ld	e, c
	extz	de
	muls	de, 37
	ld	hl, de
	add	hl, 110
	extz	wa
	muls	wa, 287
	lda	xde, (Part_Record_Base:24)
	exts	xwa
	add	xwa, xde
	ld	xde, (xwa+hl)
	ld	a, c
	extz	wa
	muls	wa, 5
	add	wa, 480
	lda	xbc, (Payload_Bss_Start+0x6158:24)
	lda	xhl, (xbc+wa)
	ld	a, (xde+54)
	and	a, 7
	cp	a, (xhl)
	ret	nz
	ld	bc, 0:i3
	cp	bc, 4:i3
	ret	nc
; 4-iteration copy loop.
DSP_SlotParam_Read_Loop:
	ld	wa, bc
	extz	xwa
	inc	1, xwa
	ld	xix, xwa
	add	xix, xhl
	ld	wa, bc
	extz	xwa
	add	xwa, 77
	add	xwa, xde
	ld	a, (xwa)
	ld	(xix), a
	inc	1, bc
	cp	bc, 4:i3
	jr	c, DSP_SlotParam_Read_Loop
	ret
; Third command dispatcher, one instance per DSP unit.  Input C = unit 0..3,
; XWA = command record.  The opcode is taken from (rec+2) with bit 7 forced low; the value
; (rec+4) is stored into the parameter shadow at
; UserTone_VelSplit_Base + 0x66 + unit*0x51 + opcode.
; Opcodes 0x4D..0x50 short-circuit to DSP_SlotParam_Read_To_Cache.  Opcode 0x17 short-
; circuits to the amplitude path.  Opcodes 0x07..0x16, 0x39..0x4C and >0x4C are ignored.
; Everything else goes through AUDIO_CMD_DSPUNIT_CASEMAP (0x00FA9C) /
; AUDIO_CMD_DSPUNIT_JUMPTABLE (0x00FAB6), base 0x02FFF9.
; Four callers: 0x031AD5, 0x031ADF, 0x031B01, 0x031B0B.  Produces no sub->main traffic.
Audio_Cmd_DSPUnit_Param:
	dec	6, xsp
	pushw iz
	ld	(xsp+2), c
	ld	(xsp+4), xwa
	ld	a, (xsp+2)
	extz	wa
	muls	wa, 81
	add	wa, 102
	lda	xbc, (Payload_Bss_Start+0x6158:24)
	exts	xwa
	add	xwa, xbc
	ld	xbc, xwa
	ld	xwa, (xsp+4)
	ld	a, (xwa+2)
	res	7, a
	extz	wa
	lda	xbc, (xbc+wa)
	ld	xwa, (xsp+4)
	ld	a, (xwa+4)
	ld	(xbc), a
	ld	xwa, (xsp+4)
	ld	a, (xwa+2)
	res	7, a
	cp	a, 77
	jrl	z, Audio_Cmd_DSPUnit_Op4D_To_50
	cp	a, 78
	jrl	z, Audio_Cmd_DSPUnit_Op4D_To_50
	cp	a, 79
	jrl	z, Audio_Cmd_DSPUnit_Op4D_To_50
	cp	a, 80
	jrl	z, Audio_Cmd_DSPUnit_Op4D_To_50
	cp	a, 76
	jrl	ugt, Audio_Cmd_DSPUnit_Return
	cp	a, 57
	jrl	nc, Audio_Cmd_DSPUnit_Return
	cp	a, 37
	jr	ugt, Audio_Cmd_DSPUnit_Check_Low
	cp	a, 24
	jrl	nc, Audio_Cmd_DSPUnit_Return
; Opcode < 0x17: reject 0x07..0x16, accept 0x00..0x06.
Audio_Cmd_DSPUnit_Check_Low:
	cp	a, 23
	jrl	z, Audio_Cmd_DSPUnit_Op17
	cp	a, 22
	jr	ugt, Audio_Cmd_DSPUnit_Normalise
	cp	a, 7:i3
	jrl	nc, Audio_Cmd_DSPUnit_Return
; Fold the two accepted opcode windows into one index: 0..6 stay, 0x26..0x38 become
; 7..0x19; anything else exits.
Audio_Cmd_DSPUnit_Normalise:
	extz	wa
	cp	wa, 0:i3
	jrl	mi, Audio_Cmd_DSPUnit_Return
	cp	wa, 6:i3
	jr	le, Audio_Cmd_DSPUnit_TableJump
	sub	wa, 31
	cp	wa, 7:i3
	jrl	lt, Audio_Cmd_DSPUnit_Return
	cp	wa, 25
	jrl	gt, Audio_Cmd_DSPUnit_Return
; Two-level lookup into the case map and jump table.
Audio_Cmd_DSPUnit_TableJump:
	lda	xix, (AUDIO_CMD_DSPUNIT_CASEMAP:24)
	ld	wa, (xix+wa)
	extz	wa
	sll	wa, 1
	ld	xix, AUDIO_CMD_DSPUNIT_JUMPTABLE
	ld	wa, (xix+wa)
	lda	xix, (Audio_Cmd_DSPUnit_Op01:24)
	jp	t, (xix+wa)
; Opcode 0x01: EnvTranspose_UpdateLoop(part).
Audio_Cmd_DSPUnit_Op01:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	call	EnvTranspose_UpdateLoop
	jrl	t, Audio_Cmd_DSPUnit_Return
; Opcodes 0x02 and 0x03: WaveSel_Cache_VelSplitPtr(part, unit) then
; WaveSel_Cache_SetDescPtr(part, unit, slot) for slots 0..3.
Audio_Cmd_DSPUnit_Op02:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ld	wa, de
	call	WaveSel_Cache_VelSplitPtr
	ld	iz, 0:i3
	cp	iz, 4:i3
	jrl	nc, Audio_Cmd_DSPUnit_Return
; Four-iteration slot loop of opcode 0x02/0x03.
Audio_Cmd_DSPUnit_Op02_SlotLoop:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	l, a
	extz	hl
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ldto_berp	a, 248
	ld	e, a
	extz	de
	ld	wa, hl
	call	WaveSel_Cache_SetDescPtr
	inc	1, iz
	cp	iz, 4:i3
	jr	c, Audio_Cmd_DSPUnit_Op02_SlotLoop
	jrl	t, Audio_Cmd_DSPUnit_Return
; Opcode 0x05: Voice_Query_PartVoices(part) then Pitch_Refresh_Sounding_Voices (0x028D4C).
Audio_Cmd_DSPUnit_Op05:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	call	Voice_Query_PartVoices
	ld	xwa, xhl
	call	Pitch_Refresh_Sounding_Voices
	jrl	t, Audio_Cmd_DSPUnit_Return
; Opcode 0x06: for slots 0..3 AlgoFlag_Write_Bit3(part, slot, 0) and
; AlgoFlag_Write(part, slot, 0), then EFF_RoutingInit(part, unit, 0).
Audio_Cmd_DSPUnit_Op06:
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, Audio_Cmd_DSPUnit_Op06_Routing
; Four-iteration slot loop of opcode 0x06.
Audio_Cmd_DSPUnit_Op06_SlotLoop:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ldto_berp	a, 248
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	call	AlgoFlag_Write_Bit3
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ldto_berp	a, 248
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	call	AlgoFlag_Write
	inc	1, iz
	cp	iz, 4:i3
	jr	c, Audio_Cmd_DSPUnit_Op06_SlotLoop
; Tail of opcode 0x06: the single EFF_RoutingInit call with DE = 0.
Audio_Cmd_DSPUnit_Op06_Routing:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 0:i3
	call	EFF_RoutingInit
	jrl	t, Audio_Cmd_DSPUnit_Return
; Opcode 0x17 (special-cased before the table): Voice_Query_PartVoices(part) then
; Voice_AllVoices_WriteAmplitude (0x028DBF).
Audio_Cmd_DSPUnit_Op17:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	call	Voice_Query_PartVoices
	ld	xwa, xhl
	call	Voice_AllVoices_WriteAmplitude
	jrl	t, Audio_Cmd_DSPUnit_Return
; Opcode 0x26: the opcode-0x06 sequence with group 1 -- AlgoFlag_Write_Bit3(...,1),
; AlgoFlag_Write(...,1) for four slots, then EFF_RoutingInit(part, unit, 1).
Audio_Cmd_DSPUnit_Op26:
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, Audio_Cmd_DSPUnit_Op26_Routing
; Four-iteration slot loop of opcode 0x26.
Audio_Cmd_DSPUnit_Op26_SlotLoop:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ldto_berp	a, 248
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	call	AlgoFlag_Write_Bit3
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ldto_berp	a, 248
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	call	AlgoFlag_Write
	inc	1, iz
	cp	iz, 4:i3
	jr	c, Audio_Cmd_DSPUnit_Op26_SlotLoop
; Tail of opcode 0x26: EFF_RoutingInit with DE = 1.
Audio_Cmd_DSPUnit_Op26_Routing:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 1:i3
	call	EFF_RoutingInit
	jrl	t, Audio_Cmd_DSPUnit_Return
; Opcode 0x2D: Voice_AllocateForSustain(part) then
; Voice_AllNotes_SustainRetrigger(list, BC = 1).
Audio_Cmd_DSPUnit_Op2D:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	call	Voice_AllocateForSustain
	ld	xwa, xhl
	ld	bc, 1:i3
	call	Voice_AllNotes_SustainRetrigger
	jrl	t, Audio_Cmd_DSPUnit_Return
; Opcode 0x36: only when (rec+5) == 7, DSP_SlotParam_Write_From_Cache(part, unit).
Audio_Cmd_DSPUnit_Op36:
	ld	xwa, (xsp+4)
	cp	(xwa+5), 7
	jrl	nz, Audio_Cmd_DSPUnit_Return
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	DSP_SlotParam_Write_From_Cache
	jr	Audio_Cmd_DSPUnit_Return
; Opcode 0x38: the opcode-0x06 sequence with group 2, then EFF_RoutingInit(part, unit, 2).
Audio_Cmd_DSPUnit_Op38:
	ld	iz, 0:i3
	cp	iz, 4:i3
	jr	nc, Audio_Cmd_DSPUnit_Op38_Routing
; Four-iteration slot loop of opcode 0x38.
Audio_Cmd_DSPUnit_Op38_SlotLoop:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ldto_berp	a, 248
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	call	AlgoFlag_Write_Bit3
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ldto_berp	a, 248
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	call	AlgoFlag_Write
	inc	1, iz
	cp	iz, 4:i3
	jr	c, Audio_Cmd_DSPUnit_Op38_SlotLoop
; Tail of opcode 0x38: EFF_RoutingInit with DE = 2.
Audio_Cmd_DSPUnit_Op38_Routing:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, 2:i3
	call	EFF_RoutingInit
	jr	t, Audio_Cmd_DSPUnit_Return
; Opcodes 0x4D..0x50: DSP_SlotParam_Read_To_Cache(part, unit).  Read-back only.
Audio_Cmd_DSPUnit_Op4D_To_50:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	DSP_SlotParam_Read_To_Cache
; Restore IZ, drop the 6-byte frame, return.
Audio_Cmd_DSPUnit_Return:
	popw iz
	inc	6, xsp
	ret
; Input XWA = command record.  Pure shadow-RAM write, no side effects: stores (rec+4) into
; UserTone_VelSplit_Base + 0x1AA + (opcode >> 6)*0x0B + (opcode & 0x3F).  The trailing
; `cp A,0x0A / ret UGT` before the final `ret` computes a flag nothing consumes.
; Caller: 0x031B1B.
Audio_Cmd_DSPGlobal_Param_Store:
	ld	c, (xwa+2)
	and	c, 192
	srl	c, 6
	extz	bc
	muls	bc, 11
	add	bc, 426
	lda	xde, (Payload_Bss_Start+0x6158:24)
	exts	xbc
	add	xbc, xde
	ld	xde, xbc
	ld	c, (xwa+2)
	and	c, 63
	extz	bc
	lda	xde, (xde+bc)
	ld	c, (xwa+4)
	ld	(xde), c
	ld	a, (xwa+2)
	res	7, a
	cp	a, 10
	ret	ugt
	ret
; Input XWA = command record.  Writes (rec+4) into the part's patch record at byte offset
; (rec+2), then tail-jumps to InterCPU_E1_DMA_Transfer with
; src = &patch[opcode], dst = 0x001E0000 + 0x4980 + opcode, len = 1.
; A one-byte write-through to the main CPU's mirror of the patch record.  Caller: 0x031B23.
Audio_Cmd_PatchByte_Write_And_Echo:
	ld	c, (xwa+1)
	extz	bc
	muls	bc, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xde+bc)
	ld	c, (xwa+2)
	extz	bc
	extz	xbc
	add	xhl, xbc
	ld	c, (xwa+4)
	ld	(xhl), c
	ld	xde, 1966080
	ld	a, (xwa+2)
	extz	wa
	ld	bc, wa
	extz	xbc
	lda	xwa, (xde+18816)
	ld	xde, xwa
	add	xde, xbc
	ld	xwa, xhl
	ld	bc, 1:i3
	jp	InterCPU_E1_DMA_Transfer
; Bank-buffer flavour of DSP_SlotParam_Write_From_Cache.  Input A = record index.
; Target record = ToneDB_RamBankA + 0x4AB7 + (editIndex*0x50) + index*0x15, where editIndex
; is the byte at ToneDB_RamBankA + 0x72A7.  Cache = UserTone_VelSplit_Base + 0x1F4 + index*5.
; Shape byte is at record+0x0F and the four data bytes at record+0x11..+0x14.  The remap
; tree is byte-for-byte the same decision structure as the 0x02FD85 version.
; Called twice from Audio_Cmd_ToneEdit_Write_And_Reply (0x0304E2, 0x0304EF) with index 0/1.
DSP_SlotParam_Write_From_Cache_B:
	ld	c, a
	extz	bc
	muls	bc, 21
	ld	de, bc
	ld	xbc, (Payload_Bss_Start+0x64a6:24)
	ld	c, (xbc+29351)
	extz	bc
	muls	bc, 80
	ld	hl, bc
	add	hl, de
	ld	xbc, (Payload_Bss_Start+0x64a6:24)
	lda	xbc, (xbc+hl)
	lda	xbc, (xbc+19127)
	extz	wa
	muls	wa, 5
	add	wa, 500
	lda	xde, (Payload_Bss_Start+0x6158:24)
	lda	xde, (xde+wa)
	ld	a, (xbc+15)
	and	a, 7
	cp	a, (xde)
	jr	nz, DSP_SlotParam_Write_B_Remap
	ld	hl, 0:i3
	cp	hl, 4:i3
	ret	nc
; Shapes agree: copy cache[1..4] into record+0x11..+0x14.
DSP_SlotParam_Write_B_Match_Loop:
	ld	wa, hl
	extz	xwa
	add	xwa, 17
	ld	xix, xwa
	add	xix, xbc
	ld	wa, hl
	extz	xwa
	inc	1, xwa
	add	xwa, xde
	ld	a, (xwa)
	ld	(xix), a
	inc	1, hl
	cp	hl, 4:i3
	jr	c, DSP_SlotParam_Write_B_Match_Loop
	ret
; Shapes differ: switch on cache[0] exactly as at 0x02FDEE.
DSP_SlotParam_Write_B_Remap:
	ld	a, (xde)
	cp	a, 5:i3
	jrl	z, DSP_SlotParam_Write_B_Shape5
	cp	a, 4:i3
	jr	z, DSP_SlotParam_Write_B_Shape2Or4
	cp	a, 2:i3
	jr	z, DSP_SlotParam_Write_B_Shape2Or4
	cp	a, 3:i3
	jr	z, DSP_SlotParam_Write_B_Shape1Or3
	cp	a, 1:i3
	ret	nz
; cache[0] in {1,3}: record shape 5 -> {0x00, 0x01, cache[1], cache[2]}, else plain copy.
DSP_SlotParam_Write_B_Shape1Or3:
	ld	a, (xbc+15)
	and	a, 7
	cp	a, 5:i3
	jr	nz, DSP_SlotParam_Write_B_Shape1Or3_Plain
	ld	(xbc+17), 0
	ld	(xbc+18), 1
	ld	a, (xde+1)
	ld	(xbc+19), a
	ld	a, (xde+2)
	ld	(xbc+20), a
	ret
; Plain copy fallback.
DSP_SlotParam_Write_B_Shape1Or3_Plain:
	ld	hl, 0:i3
	cp	hl, 4:i3
	ret	nc
; Loop body of that fallback.
DSP_SlotParam_Write_B_Shape1Or3_Loop:
	ld	wa, hl
	extz	xwa
	add	xwa, 17
	ld	xix, xwa
	add	xix, xbc
	ld	wa, hl
	extz	xwa
	inc	1, xwa
	add	xwa, xde
	ld	a, (xwa)
	ld	(xix), a
	inc	1, hl
	cp	hl, 4:i3
	jr	c, DSP_SlotParam_Write_B_Shape1Or3_Loop
	ret
; cache[0] in {2,4}: record shape 5 -> {cache[1], cache[2], 0x7F, 0x01}, else plain copy.
DSP_SlotParam_Write_B_Shape2Or4:
	ld	a, (xbc+15)
	and	a, 7
	cp	a, 5:i3
	jr	nz, DSP_SlotParam_Write_B_Shape2Or4_Plain
	ld	a, (xde+1)
	ld	(xbc+17), a
	ld	a, (xde+2)
	ld	(xbc+18), a
	ld	(xbc+19), 127
	ld	(xbc+20), 1
	ret
; Plain copy fallback.
DSP_SlotParam_Write_B_Shape2Or4_Plain:
	ld	hl, 0:i3
	cp	hl, 4:i3
	ret	nc
; Loop body of that fallback.
DSP_SlotParam_Write_B_Shape2Or4_Loop:
	ld	wa, hl
	extz	xwa
	add	xwa, 17
	ld	xix, xwa
	add	xix, xbc
	ld	wa, hl
	extz	xwa
	inc	1, xwa
	add	xwa, xde
	ld	a, (xwa)
	ld	(xix), a
	inc	1, hl
	cp	hl, 4:i3
	jr	c, DSP_SlotParam_Write_B_Shape2Or4_Loop
	ret
; cache[0] == 5: shape 1/3 -> {cache[3], cache[4], 0x40, 0x87}; shape 2/4 ->
; {cache[1], cache[2], 0x40, 0x07}.
DSP_SlotParam_Write_B_Shape5:
	ld	a, (xbc+15)
	and	a, 7
	cp	a, 4:i3
	jr	z, DSP_SlotParam_Write_B_Shape5_To24
	cp	a, 2:i3
	jr	z, DSP_SlotParam_Write_B_Shape5_To24
	cp	a, 3:i3
	jr	z, DSP_SlotParam_Write_B_Shape5_To13
	cp	a, 1:i3
	ret	nz
; Shape-5 source, shape-1/3 destination.
DSP_SlotParam_Write_B_Shape5_To13:
	ld	a, (xde+3)
	ld	(xbc+17), a
	ld	a, (xde+4)
	ld	(xbc+18), a
	ld	(xbc+19), 64
	ld	(xbc+20), 135
	ret
; Shape-5 source, shape-2/4 destination.
DSP_SlotParam_Write_B_Shape5_To24:
	ld	a, (xde+1)
	ld	(xbc+17), a
	ld	a, (xde+2)
	ld	(xbc+18), a
	ld	(xbc+19), 64
	ld	(xbc+20), 7
	ret
; Inverse of DSP_SlotParam_Write_From_Cache_B; input C = record index.  Returns unless
; (record+0x0F & 7) == cache[0], then copies record+0x11..+0x14 into cache[1..4].
; Called twice from 0x0304FB and 0x030505.
DSP_SlotParam_Read_To_Cache_B:
	ld	a, c
	extz	wa
	muls	wa, 21
	ld	de, wa
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	extz	wa
	muls	wa, 80
	ld	hl, wa
	add	hl, de
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xde, (xwa+hl)
	lda	xde, (xde+19127)
	ld	a, c
	extz	wa
	muls	wa, 5
	add	wa, 500
	lda	xbc, (Payload_Bss_Start+0x6158:24)
	lda	xhl, (xbc+wa)
	ld	a, (xde+15)
	and	a, 7
	cp	a, (xhl)
	ret	nz
	ld	bc, 0:i3
	cp	bc, 4:i3
	ret	nc
; 4-iteration copy loop.
DSP_SlotParam_Read_B_Loop:
	ld	wa, bc
	extz	xwa
	inc	1, xwa
	ld	xix, xwa
	add	xix, xhl
	ld	wa, bc
	extz	xwa
	add	xwa, 17
	add	xwa, xde
	ld	a, (xwa)
	ld	(xix), a
	inc	1, bc
	cp	bc, 4:i3
	jr	c, DSP_SlotParam_Read_B_Loop
	ret
; Fourth command dispatcher, and the one that ALWAYS answers the main CPU.
; Input XWA = command record (kept in XIZ).  Obtains the part's working buffer via
; ToneDB_Find_SubToneRecord (0x032AE0) called with WA = patch pointer, BC = the edit
; index at ToneDB_RamBankA+0x72A7, DE = part; keeps the returned XHL at (XSP+0x04).
; Stores (rec+4) at buffer[opcode].  Then dispatches opcodes 0x19..0x24 and 0x2B..0x36 via
; AUDIO_CMD_TONEEDIT_REPLY_CASEMAP / _JUMPTABLE (base 0x0304B6).  ALL paths, including the
; ignored opcodes, converge on Audio_Cmd_ToneEdit_Reply_Send.  Caller: 0x031B2B.
Audio_Cmd_ToneEdit_Write_And_Reply:
	dec	4, xsp
	push xiz
	ld	xiz, xwa
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xbc+wa)
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	c, a
	extz	bc
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	xwa, xhl
	call	ToneDB_Find_SubToneRecord
	ld	(xsp+4), xhl
	ld	a, (xiz+2)
	extz	wa
	extz	xwa
	ld	xbc, xwa
	add	xbc, (xsp+4)
	ld	a, (xiz+4)
	ld	(xbc), a
	ld	a, (xiz+2)
	extz	wa
	sub	wa, 25
	cp	wa, 0:i3
	jrl	lt, Audio_Cmd_ToneEdit_Reply_Send
	cp	wa, 11
	jr	le, Audio_Cmd_ToneEdit_Reply_TableJump
	sub	wa, 9
	cp	wa, 12
	jr	lt, Audio_Cmd_ToneEdit_Reply_Send
	cp	wa, 23
	jr	gt, Audio_Cmd_ToneEdit_Reply_Send
; Fold opcodes 0x19..0x24 and 0x2B..0x36 into one 0..0x17 index and jump.
Audio_Cmd_ToneEdit_Reply_TableJump:
	lda	xix, (AUDIO_CMD_TONEEDIT_REPLY_CASEMAP:24)
	ld	wa, (xix+wa)
	extz	wa
	sll	wa, 1
	ld	xix, AUDIO_CMD_TONEEDIT_REPLY_JUMPTABLE
	ld	wa, (xix+wa)
	lda	xix, (Audio_Cmd_ToneEdit_Reply_Case_Pan:24)
	jp	t, (xix+wa)
; Voice_Query_PartVoices(part) then 0x029071 over the returned voice list.
Audio_Cmd_ToneEdit_Reply_Case_Pan:
	ld	a, (xiz+1)
	extz	wa
	call	Voice_Query_PartVoices
	ld	xwa, xhl
	call	AudioChannel_AllVoices_Update_Variant3
	jr	t, Audio_Cmd_ToneEdit_Reply_Send
; Voice_AllocateForSustain(part) then Voice_AllNotes_SustainRetrigger(list, 1).
Audio_Cmd_ToneEdit_Reply_Case_Sustain:
	ld	a, (xiz+1)
	extz	wa
	call	Voice_AllocateForSustain
	ld	xwa, xhl
	ld	bc, 1:i3
	call	Voice_AllNotes_SustainRetrigger
	jr	t, Audio_Cmd_ToneEdit_Reply_Send
; Only when (rec+5) == 7: DSP_SlotParam_Write_From_Cache_B(index 0).
Audio_Cmd_ToneEdit_Reply_Case_Slot0:
	cp	(xiz+5), 7
	jr	nz, Audio_Cmd_ToneEdit_Reply_Send
	ld	wa, 0:i3
	calr	DSP_SlotParam_Write_From_Cache_B
	jr	Audio_Cmd_ToneEdit_Reply_Send
; Only when (rec+5) == 7: DSP_SlotParam_Write_From_Cache_B(index 1).
Audio_Cmd_ToneEdit_Reply_Case_Slot1:
	cp	(xiz+5), 7
	jr	nz, Audio_Cmd_ToneEdit_Reply_Send
	ld	wa, 1:i3
	calr	DSP_SlotParam_Write_From_Cache_B
	jr	Audio_Cmd_ToneEdit_Reply_Send
; DSP_SlotParam_Read_To_Cache_B for indices 0 and 1.
Audio_Cmd_ToneEdit_Reply_Case_ReadBack:
	ld	a, (xiz+1)
	extz	wa
	ld	bc, 0:i3
	calr	DSP_SlotParam_Read_To_Cache_B
; Table entry that enters the read-back pair at its second call only (index 1).
Audio_Cmd_ToneEdit_Reply_Case_ReadBack1:
	ld	a, (xiz+1)
	extz	wa
	ld	bc, 1:i3
	calr	DSP_SlotParam_Read_To_Cache_B
; ★ The unconditional sub->main reply.  Builds
;   dst = 0x001E0000 + 0x4AA7 + editIndex*0x50   (editIndex = [ToneDB_RamBankA + 0x72A7])
;   src = the buffer pointer saved at (XSP+0x04)
;   len = 0x3A (58 bytes)
; and calls InterCPU_E1_DMA_Transfer (0x020DB3).  If that call times out the command is
; still acknowledged locally and the main CPU simply never sees the update.
Audio_Cmd_ToneEdit_Reply_Send:
	ld	xde, 1966080
	ldw	bc, 58
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	extz	wa
	muls	wa, 80
	add	wa, 19111
	exts	xwa
	add	xwa, xde
	ld	xde, xwa
	ld	xwa, (xsp+4)
	call	InterCPU_E1_DMA_Transfer
	pop xiz
	inc	4, xsp
	ret
; Sibling of 0x030428 for the sub-field form of the command.  The opcode's top two bits
; select a group 0..3 (kept in QIZH) and its low six bits select a byte within that group.
; After ToneDB_Find_SubToneRecord it advances the buffer pointer by group*0x15 + 0x10,
; calls WaveSel_StageA1_FromToneSlot (0x032682) with WA = group, XBC = buffer, DE = editIndex
; and the part pushed on the stack, stores (rec+4) at buffer[opcode & 0x3F], and then
; DMAs that single byte to
;   0x001E0000 + 0x4AE1 + editIndex*0x50 + group*0x0B + (opcode & 0x3F)
; via InterCPU_E1_DMA_Transfer.  Caller: 0x031B33.
Audio_Cmd_ToneEdit_Field_Write_And_Reply:
	dec	4, xsp
	push qiz
	ld	(xsp+2), xwa
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xbc+wa)
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	c, a
	extz	bc
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	xwa, xhl
	call	ToneDB_Find_SubToneRecord
	ld	xwa, (xsp+2)
	ld	a, (xwa+2)
	and	a, 192
	srl	a, 6
	ldfr_berp	a, 251
	extz	wa
	muls	wa, 21
	add	wa, 16
	lda	xhl, (xhl+wa)
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	e, a
	extz	de
	ld	xwa, (xsp+2)
	ld	a, (xwa+1)
	extz	wa
	pushw wa
	ld	wa, bc
	ld	xbc, xhl
	call	WaveSel_StageA1_FromToneSlot
	ld	xwa, (xsp+2)
	ld	a, (xwa+2)
	and	a, 63
	extz	wa
	extz	xwa
	add	xhl, xwa
	ld	xwa, (xsp+2)
	ld	a, (xwa+4)
	ld	(xhl), a
	ld	xde, 1966080
	ldto_berp	a, 251
	extz	wa
	muls	wa, 11
	ld	bc, wa
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	extz	wa
	muls	wa, 80
	add	wa, bc
	exts	xwa
	add	xwa, xde
	lda	xwa, (xwa+19169)
	ld	xbc, xwa
	ld	xwa, (xsp+2)
	ld	a, (xwa+2)
	and	a, 63
	extz	wa
	extz	xwa
	ld	xde, xwa
	add	xde, xbc
	ld	xwa, xhl
	ld	bc, 1:i3
	call	InterCPU_E1_DMA_Transfer
	pop qiz
	inc	4, xsp
	ret

; DSP_EffectStateQuery -- Query whether effect is active for a voice
; Reads bit 0 of voice struct at 0x041368; returns 1 (active) or 0.
; Input WA = part, XBC = one-byte result buffer.  Writes 1 if PART+0x00 bit 0 is set
; (the part is allocated), 0 otherwise, and returns HL = 1.
; Called from DSP_SetCoeff_MasterConfig at 0x0317E2 with XBC = 0x045216, and from
; AUDIO_PROCESS_DSP at 0x035BFC.
DSP_EffectStateQuery:
	extz wa
	muls wa, 0x11F
	lda xde, (Part_Record_Base:24)
	ld	wa, (xde+wa)
	bit 0, wa
	jr z, DSP_EffectStateQuery_WriteZero
	ld (xbc), 0x1
	jr DSP_EffectStateQuery_SetResult

; Part not allocated: store 0.
DSP_EffectStateQuery_WriteZero:
	ld (xbc), 0x0

; Return HL = 1 (success).
DSP_EffectStateQuery_SetResult:
	ld hl, 1:i3
	ret

; Input XWA = PART record base.  Applies the five global offset bytes at 0x0451A6..0x0451AC
; to a part's four operator slots and to the part's patch record:
;   0x0451A6 << 2  -> slot+0x4D (and slot+0x4F for shape 5), clamped by TVF_Clamp_Cutoff
;   0x0451AB << 2  -> slot+0x27, clamped 0..0xFF by Int_ClampSignedToRange
;   0x0451AC << 2  -> slot+0x2D, same clamp
;   0x0451A7 << 1  -> patch+0x2B and patch+0x3B, clamped 0..0x7F (skipped when 0x0451A7
;                     reads 0xF5, the "unset" sentinel)
;   0x0451A8 << 1  -> patch+0x2C and patch+0x3C, clamped 0..0x7F
;   0x0451A9 << 1  -> the low 6 bits of patch+0x2E and patch+0x3E, clamped 0..0x1E
; Slot addressing is Math_Multiply32(index, 0x25) + 0x6E + PART, then a long pointer fetch.
; Called only from DSP_AlgoSelect_AlreadyAllocated (0x0309BD).
DSP_AdjustVoiceParams:
	lda xsp, (xsp - 10)
	push xiz
	ld (xsp + 10), xwa
	ld a, (Payload_Bss_Start+0x6330:24)
	sla a, 2
	exts wa
	ld (xsp + 4), wa
	ld a, (Payload_Bss_Start+0x6335:24)
	sla a, 2
	exts wa
	ld (xsp + 6), wa
	ld a, (Payload_Bss_Start+0x6336:24)
	sla a, 2
	exts wa
	ld (xsp + 8), wa
	ldiw_erp 0xFA, 0
	cpiw_erp 0xFA, 4
	jrl nc, DSP_AdjustVoiceParams_Vibrato

; Four-iteration loop over the part's operator slots; QIZ is the slot counter.
DSP_AdjustVoiceParams_SlotLoop:
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ld a, (xwa + 54)
	and a, 0x7
	cp a, 5:i3
	jr z, DSP_AdjustVoiceParams_Type5
	cp a, 4:i3
	jr z, DSP_AdjustVoiceParams_Type1to4
	cp a, 3:i3
	jr z, DSP_AdjustVoiceParams_Type1to4
	cp a, 2:i3
	jr z, DSP_AdjustVoiceParams_Type1to4
	cp a, 1:i3
	jrl nz, DSP_AdjustVoiceParams_ReverbChorus

; Slot shapes 1..4: adjust slot+0x4D only.
DSP_AdjustVoiceParams_Type1to4:
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ld a, (xwa + 77)
	extz wa
	add wa, (xsp + 4)
	call TVF_Clamp_Cutoff
	ld iz, hl
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ldto_berp C, 0xF8
	ld (xwa + 77), c
	jrl DSP_AdjustVoiceParams_ReverbChorus

; Slot shape 5: adjust both slot+0x4D and slot+0x4F.
DSP_AdjustVoiceParams_Type5:
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ld a, (xwa + 77)
	extz wa
	add wa, (xsp + 4)
	call TVF_Clamp_Cutoff
	ld iz, hl
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ldto_berp C, 0xF8
	ld (xwa + 77), c
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ld a, (xwa + 79)
	extz wa
	add wa, (xsp + 4)
	call TVF_Clamp_Cutoff
	ld iz, hl
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ldto_berp C, 0xF8
	ld (xwa + 79), c

; Common per-slot tail: the 0x0451AB -> slot+0x27 and 0x0451AC -> slot+0x2D adjustments,
; then loop back to the slot loop.
DSP_AdjustVoiceParams_ReverbChorus:
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ld a, (xwa + 39)
	extz wa
	add wa, (xsp + 6)
	ldw bc, 0xFF
	ld de, 0:i3
	call Int_ClampSignedToRange
	ld iz, hl
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ldto_berp C, 0xF8
	ld (xwa + 39), c
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ld a, (xwa + 45)
	extz wa
	add wa, (xsp + 8)
	ldw bc, 0xFF
	ld de, 0:i3
	call Int_ClampSignedToRange
	ld iz, hl
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	add xhl, 0x6E
	add xhl, (xsp + 10)
	ld xwa, (xhl)
	ldto_berp C, 0xF8
	ld (xwa + 45), c
	inc1w_erp 0xFA
	cpiw_erp 0xFA, 4
	jrl c, DSP_AdjustVoiceParams_SlotLoop

; After all four slots: the 0x0451A7 pair, skipped entirely when 0x0451A7 == 0xF5.
DSP_AdjustVoiceParams_Vibrato:
	cp (Payload_Bss_Start+0x6331:24), 0xf5
	jr z, DSP_AdjustVoiceParams_Filter
	ld a, (Payload_Bss_Start+0x6331:24)
	sla a, 1
	ld c, a
	exts bc
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ld a, (xwa + 43)
	extz wa
	add wa, bc
	ldw bc, 0x7F
	ld de, 0:i3
	call ClampS16_WA_Short
	ld iz, hl
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ldto_berp C, 0xF8
	ld (xwa + 43), c
	ld a, (Payload_Bss_Start+0x6331:24)
	sla a, 1
	ld c, a
	exts bc
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ld a, (xwa + 59)
	extz wa
	add wa, bc
	ldw bc, 0x7F
	ld de, 0:i3
	call ClampS16_WA_Short
	ld iz, hl
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ldto_berp C, 0xF8
	ld (xwa + 59), c

; The 0x0451A8 and 0x0451A9 adjustments; the latter is a read-modify-write that preserves
; the top two bits of patch+0x2E / patch+0x3E.
DSP_AdjustVoiceParams_Filter:
	ld a, (Payload_Bss_Start+0x6332:24)
	sla a, 1
	ld c, a
	exts bc
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ld a, (xwa + 44)
	extz wa
	add wa, bc
	ldw bc, 0x7F
	ld de, 0:i3
	call ClampS16_WA_Short
	ld iz, hl
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ldto_berp C, 0xF8
	ld (xwa + 44), c
	ld a, (Payload_Bss_Start+0x6332:24)
	sla a, 1
	ld c, a
	exts bc
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ld a, (xwa + 60)
	extz wa
	add wa, bc
	ldw bc, 0x7F
	ld de, 0:i3
	call ClampS16_WA_Short
	ld iz, hl
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ldto_berp C, 0xF8
	ld (xwa + 60), c
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ld a, (xwa + 46)
	and a, 0x3F
	ldfr_berp A, 0xF8
	extz iz
	ld a, (Payload_Bss_Start+0x6333:24)
	sla a, 1
	exts wa
	add wa, iz
	ldw bc, 0x1E
	ld de, 0:i3
	call ClampS16_WA_Short
	ld iz, hl
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	andmi8 (xwa + 46), 0xC0
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ldto_berp C, 0xF8
	or (xwa + 46), c
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ld a, (xwa + 62)
	and a, 0x3F
	ldfr_berp A, 0xF8
	extz iz
	ld a, (Payload_Bss_Start+0x6333:24)
	sla a, 1
	exts wa
	add wa, iz
	ldw bc, 0x1E
	ld de, 0:i3
	call ClampS16_WA_Short
	ld iz, hl
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	andmi8 (xwa + 62), 0xC0
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 6)
	ldto_berp C, 0xF8
	or (xwa + 62), c
	pop xiz
	lda xsp, (xsp + 10)
	ret

