
; ==============================================================================
; 0xFA5400-0xFA5417 -- the MIDI module's entry-thunk table
; ==============================================================================
;
; ---------------------------------------------------------------------
; MIDI_EntryThunks -- six 4-byte slots, the module's public entry points
;
; Called from: not yet traced.  ⚠ notes/prom_a_xref.py finds no `call`, `jp`,
;          `lda` or bare pointer naming 0xFA5400 in either image, so whatever
;          reaches this table computes the address.
; Inputs:  none
; Outputs: none
; Evidence: the same idiom as LCD_EntryThunks at 0xF8E800 -- a fixed-stride
;          table of entry points rather than of pointers, which is how a
;          firmware keeps a module ABI stable across revisions.  The stride is
;          4 and is fixed by the ONE live slot: slot 3 holds `1b be 58 fa`, a
;          4-byte `jp`, and it starts at 0xFA540C = 0xFA5400 + 3*4.  The other
;          five slots are `ret` followed by three `nop`s -- an empty slot
;          padded to the same stride, which is what makes the stride readable
;          at all.
; Notes:   the table's LOWER edge is a 152-byte run of 0x0E at
;          0xFA5368-0xFA53FF, and its upper edge is MIDI_RX_ErrorReset at
;          0xFA5418, already converted.  So six slots is the whole table, not a
;          window on a longer one.
;          ⚠ 0x0E -- RET -- is this build's inter-module pad byte throughout;
;          prom_a alone has 35 runs of 64 or more of them.  That means the pad
;          and slot 0's own `ret` are the SAME BYTE, so a scan for the run
;          measures 153 and stops one byte inside the table.  The boundary here
;          comes from the 4-byte stride, not from where the 0x0E stops.
; Unknown:  ⚠ what the five empty slots were for.  Their presence says the
;          module's interface was designed for six entry points and only one
;          survives, exactly as four of the LCD module's six are `ret`.
; ---------------------------------------------------------------------
MIDI_EntryThunks:
	ret                                           ; FA5400  0e   slot 0 -- unused
	nop                                           ; FA5401  00
	nop                                           ; FA5402  00
	nop                                           ; FA5403  00
	ret                                           ; FA5404  0e   slot 1 -- unused
	nop                                           ; FA5405  00
	nop                                           ; FA5406  00
	nop                                           ; FA5407  00
	ret                                           ; FA5408  0e   slot 2 -- unused
	nop                                           ; FA5409  00
	nop                                           ; FA540A  00
	nop                                           ; FA540B  00
	jp MIDI_Reset                                 ; FA540C  1b be 58 fa   slot 3 -- the only live entry
	ret                                           ; FA5410  0e   slot 4 -- unused
	nop                                           ; FA5411  00
	nop                                           ; FA5412  00
	nop                                           ; FA5413  00
	ret                                           ; FA5414  0e   slot 5 -- unused
	nop                                           ; FA5415  00
	nop                                           ; FA5416  00
	nop                                           ; FA5417  00

; ==============================================================================
; 0xFA5418-0xFA5503 -- serial channel 0 = the MIDI port: the two interrupts
; ==============================================================================
;
; That SC0 is MIDI is settled by traffic rather than by a register setting: the
; transmit handler below writes 0xFC, 0xF8, 0xFE, 0xFA and 0xFB into SC0BUF and
; nothing else in any of the four images writes those bytes to a UART.  They are
; the five MIDI System Real Time messages -- STOP, TIMING CLOCK, ACTIVE SENSING,
; START, CONTINUE -- and the receive handler splits incoming bytes on exactly
; the MIDI boundaries (bit 7 = status, 0xF8 and above = real time, 0xF7 = end of
; exclusive).
;
; ★ (0xA0) IS THE REAL-TIME TRANSMIT REQUEST BITMAP, and this routine is what
;   assigns its bits their meaning:
;       bit 0 -> 0xF8 TIMING CLOCK      bit 1 -> 0xFA START
;       bit 2 -> 0xFB CONTINUE          bit 3 -> 0xFC STOP
;       bit 4 -> 0xFE ACTIVE SENSING
;   INTT1_Tick sets bit 4 (0xF82D3F) and bit 3 (0xF82D92) and bit 0 (0xF82DC0);
;   the sequencer tick at 0xF82F7D sets bit 1.  The `or (0xA0),n; call 0xF40724`
;   idiom noted there is therefore "queue this MIDI real-time byte".
;
; ★ ACTIVE SENSING, both directions, and what it says about the tick rate:
;     SEND    INTT1_Tick wraps a 0..0x86 counter, so bit 4 is requested every
;             135 timer-1 ticks.
;     TIMEOUT bit 7 of (0x9E) is set when a 0xFE arrives (0xFA5509); while it is
;             set INTT1_Tick counts (0x9C) up and gives up at 0xA5, i.e. after
;             166 ticks.  (0x9C) is zeroed at 0xFA54AE on EVERY received byte.
;   At the 488.28 Hz that notes/FINDINGS-system-clock.md derives, that is send
;   every 277 ms and give up after 340 ms -- one either side of MIDI 1.0's
;   300 ms rule, which is what a correct implementation looks like.  ⚠ This is a
;   CONSISTENCY CHECK, not a fourth lever on fc: the window is wide enough that
;   24 MHz would also put the timeout on the right side of 300 ms (though not
;   the send interval).  The levers are in that note; do not re-derive fc here.
;
; ---------------------------------------------------------------------
; MIDI_RX_ErrorReset -- the receive-error path
;
; Called from: MIDI_RX_Byte (0xFA549E), when SC0CR bits 2-4 are not all clear
; Inputs:  SC0CR error flags
; Outputs: SC0BUF read (which is how the error is cleared), running status
;          (0x9A) dropped, (0x9E) masked with 0xBD and bit 3 set, (0xA9) zeroed,
;          the 8-BIT counter at (0x0931) incremented.  Returns with RETI.
;          ⚠ CORRECTED 2026-08-25: this line said 16-bit while its own body
;          two lines below said 8-bit.  `incdi8 0x01,(0x0931)` at 0xFA5429
;          is C1 31 09 61 -- prefix 0xC1 is the BYTE operand with a 16-bit
;          address, so the increment is one byte wide.  The fix was already
;          in notes/FINDINGS-midi-port.md:219 and had not reached the source.
; Evidence: "receive error" is the caller's test, not this routine's --
;          MIDI_RX_Byte reads SC0CR and does `and A,0x1c` (0xFA549A), i.e.
;          bits 2-4, and branches here when any is set. "Reset" is the body:
;          SC0BUF is read at 0xFA5419 purely to clear the condition, running
;          status (0x9A) is zeroed, and (0xA9) is zeroed -- after which it
;          RETIs without ever entering the parser.
; Notes:   the parser is deliberately NOT run, so a byte received with a framing
;          or overrun error cannot enter the MIDI state machine.
; ---------------------------------------------------------------------
MIDI_RX_ErrorReset:
	pushw wa                                      ; FA5418  28
	ld_sd8b a, SC0BUF                               ; FA5419  c0 50 21   read SC0BUF to clear the error
	ld (MIDI_RX_RunningStatus:8), 0x00:io                               ; FA541C  08 9a 00
	and	(MIDI_RX_Flags:8), 0xbd                        ; FA541F  c0 9e 3c bd
	set	3, (MIDI_RX_Flags:8)                            ; FA5423  f0 9e bb   (0x9E) bit 3 = 'the link had an error'
	ld (MIDI_RX_SysExState:8), 0x00:io                               ; FA5426  08 a9 00
	inc 0x01, (MIDI_RX_ErrorCount:16)                         ; FA5429  c1 31 09 61   (0x0931) = an 8-BIT receive-error counter
	popw wa                                       ; FA542D  48
	reti                                          ; FA542E  07

; ---------------------------------------------------------------------
; MIDI_TX_Ready -- INTTX0: SC0BUF has room, send the next MIDI byte
;
; Called from: vector slot 0x64 (0xFFFF64 holds 0x00F40718, a prom_b thunk whose
;          body is `jp 0xFA542F`)
; Inputs:  (0xA0), the real-time request bitmap described above
; Outputs: one byte written to SC0BUF and its request bit cleared; or, if no
;          request bit is set, one byte pulled from the output queue by the
;          prom_b routine at 0xF41DF0 (which returns 0xFFFF for "empty").
; Evidence: the slot is emitted as `.long 0x00F40718` with the thunk's body
;          given above, and the five real-time bytes are LITERAL immediates
;          written to SC0BUF -- so the mapping from (0xA0) bit to MIDI byte is
;          read out of the ROM, not assumed. The priority order is likewise
;          read off the branch chain: 0xFA5433 tests bit 0, then 0xFA5438 bit
;          4, 0xFA543D bit 1, 0xFA5442 bit 2, 0xFA5447 bit 3 -- clock, active
;          sensing, start, continue, stop, which is NOT the bit order.
;          0xFA544F is `ldio SC0BUF,0xfc`, the STOP byte, on the bit-3 arm.
; Notes:   the priority order is fixed and is NOT the bit order: clock, active
;          sensing, start, continue, stop.  Timing clock first is the right
;          choice for a sequencer -- it is the one message whose jitter is
;          audible.
;
;          The tail is the "nothing left to send" hand-off: when no request bit
;          is set AND 0xF41DFC reports the queue empty, (0x77) is set to 0xFD.
;          (0x77) also takes 0xDD from the work poster at 0xFA590F, so it is a
;          one-byte mailbox to the foreground, not a UART register.
; ---------------------------------------------------------------------
MIDI_TX_Ready:
	pushw wa                                      ; FA542F  28
	ld	a, (MidiTx_RealtimePending:8)                               ; FA5430  c0 a0 21   the pending-transmit bitmap; INTT1 and INTTR4 set its bits
	bit 0x00,A                                    ; FA5433  c9 33 00
	jr nz, .LFA5454                               ; FA5436  6e 1c
	bit 0x04,A                                    ; FA5438  c9 33 04
	jr nz, .LFA545C                               ; FA543B  6e 1f
	bit 0x01,A                                    ; FA543D  c9 33 01
	jr nz, .LFA5464                               ; FA5440  6e 22
	bit 0x02,A                                    ; FA5442  c9 33 02
	jr nz, .LFA546C                               ; FA5445  6e 25
	bit 0x03,A                                    ; FA5447  c9 33 03
	jr z, .LFA5474                                ; FA544A  66 28
	res	3, (MidiTx_RealtimePending:8)                            ; FA544C  f0 a0 b3
	ld (SC0BUF:8), 0xfc:io                               ; FA544F  08 50 fc   bit 3 -> 0xFC  MIDI System Real Time STOP
	jr .LFA5481                                   ; FA5452  68 2d
.LFA5454:
	res	0, (MidiTx_RealtimePending:8)                            ; FA5454  f0 a0 b0
	ld (SC0BUF:8), 0xf8:io                               ; FA5457  08 50 f8   bit 0 -> 0xF8  MIDI System Real Time TIMING CLOCK
	jr .LFA5481                                   ; FA545A  68 25
.LFA545C:
	res	4, (MidiTx_RealtimePending:8)                            ; FA545C  f0 a0 b4
	ld (SC0BUF:8), 0xfe:io                               ; FA545F  08 50 fe   bit 4 -> 0xFE  MIDI System Real Time ACTIVE SENSING
	jr .LFA5481                                   ; FA5462  68 1d
.LFA5464:
	res	1, (MidiTx_RealtimePending:8)                            ; FA5464  f0 a0 b1
	ld (SC0BUF:8), 0xfa:io                               ; FA5467  08 50 fa   bit 1 -> 0xFA  MIDI System Real Time START
	jr .LFA5481                                   ; FA546A  68 15
.LFA546C:
	res	2, (MidiTx_RealtimePending:8)                            ; FA546C  f0 a0 b2
	ld (SC0BUF:8), 0xfb:io                               ; FA546F  08 50 fb   bit 2 -> 0xFB  MIDI System Real Time CONTINUE
	jr .LFA5481                                   ; FA5472  68 0d
.LFA5474:
	call T_Ring601432_Get                         ; FA5474  1d f0 1d f4   no real-time byte pending: pull one from the output queue
	cp WA,0xffff                                  ; FA5478  d8 cf ff ff   0xFFFF = the queue is empty
	jr z, .LFA5481                                ; FA547C  66 03
	st_dd8b a, SC0BUF                               ; FA547E  f0 50 41
.LFA5481:
	ld	a, (MidiTx_RealtimePending:8)                               ; FA5481  c0 a0 21
	and A,0x1f                                    ; FA5484  c9 cc 1f   any of the five real-time bits still set?
	jr nz, .LFA5494                               ; FA5487  6e 0b
	call T_Ring601432_IsEmpty                     ; FA5489  1d fc 1d f4
	and WA,WA                                     ; FA548D  d8 c0
	jr nz, .LFA5494                               ; FA548F  6e 03
	ld (INTES0:8), 0xfd:io                               ; FA5491  08 77 fd   queue empty and nothing pending -> (0x77) = 0xFD
.LFA5494:
	popw wa                                       ; FA5494  48
	reti                                          ; FA5495  07

; ---------------------------------------------------------------------
; MIDI_RX_Byte -- INTRX0: a byte arrived on the MIDI input
;
; Called from: vector slot 0x60 (0xFFFF60 holds 0x00F40714, a prom_b thunk whose
;          body is `jp 0xFA5496`)
; Inputs:  SC0CR (error flags), SC0BUF (the byte)
; Outputs: the byte is dispatched into one of three paths and the receive
;          inactivity counter (0x9C) is restarted.  All seven 32-bit registers
;          are saved, so the parser it calls may use any of them.
; Evidence: the slot is emitted as `.long 0x00F40714` and the thunk body is
;          given above, so this is INTRX0's handler. The three-way split is
;          read straight off the code -- the SC0CR error mask `and A,0x1c` at
;          0xFA549A, then bit 7 of the byte, then the 0xF8 boundary -- and the
;          register context that makes the parser stateful is the pair of
;          block moves at 0xFA5884 and 0xFA58A1 that load and store all seven
;          32-bit registers from RAM at 0x0900. What makes the whole block
;          MIDI rather than "a UART" is MIDI_StatusDispatch_Table below.
; Notes:   the three paths, and what picks them:
;            bit 7 clear          -> a DATA byte      -> 0xFA5763
;            0x80-0xF7            -> a STATUS byte    -> handled inline:
;                                    it becomes the running status in (0x9A),
;                                    and 0xF7 (END OF EXCLUSIVE) closes an
;                                    in-progress SysEx through 0xF41E3C
;            0xF8-0xFF            -> SYSTEM REAL TIME -> 0xFA5504
;          (0xA9) is the SysEx state: bit 0 armed, bit 1 in-message, bit 5 seen.
;          ⚠ bit 5 is still uncorroborated; bits 0 and 1 now are -- converting
;          MIDI_RX_SysExStart and MIDI_RX_SysExData (0xFA584D, 0xFA586E) shows
;          bit 0 being set the moment 0xF0 arrives and bit 1 only when the
;          identifier byte is one this machine accepts.
;
;          ★ The three `calr`s here are not ordinary calls.  The pushes above
;          save the INTERRUPTED code's registers; 0xFA5884 then loads the
;          PARSER's own seven registers out of RAM at 0x0900, and 0xFA58A1
;          writes them back before the pops.  The parser therefore keeps state
;          in registers from one incoming byte to the next -- see the block
;          header at 0xFA5763.
; ---------------------------------------------------------------------
MIDI_RX_Byte:
	pushw wa                                      ; FA5496  28
	ld_sd8b a, SC0CR                               ; FA5497  c0 51 21   SC0CR bits 2-4 are the receive error flags
	and A,0x1c                                    ; FA549A  c9 cc 1c
	popw wa                                       ; FA549D  48
	jrl nz, MIDI_RX_ErrorReset                              ; FA549E  7e 77 ff   any error -> the error path above, which does not run the parser
	push XWA                                      ; FA54A1  38
	push XBC                                      ; FA54A2  39
	push XDE                                      ; FA54A3  3a
	push XHL                                      ; FA54A4  3b
	push XIX                                      ; FA54A5  3c
	push XIY                                      ; FA54A6  3d
	push XIZ                                      ; FA54A7  3e
	calr MIDI_Parser_LoadContext                                   ; FA54A8  1e d9 03   -> MIDI_Parser_LoadContext (0xFA5884)
	ld_sd8b a, SC0BUF                               ; FA54AB  c0 50 21   the received byte
	ld (0x9c:8), 0x00:io                               ; FA54AE  08 9c 00   restart the receive-inactivity timer INTT1 counts
	bit 0x07,A                                    ; FA54B1  c9 33 07   bit 7 set = a status byte
	jr z, .LFA54F6                                ; FA54B4  66 40
	cp A,0xf7                                     ; FA54B6  c9 cf f7   0xF8-0xFF are System Real Time
	jr ule, .LFA54C0                              ; FA54B9  63 05
	calr MIDI_RT_Received                                     ; FA54BB  1e 46 00   -> MIDI_RT_Received (0xFA5504)
	jr .LFA54F9                                   ; FA54BE  68 39
.LFA54C0:
	ld	(MIDI_RX_RunningStatus:8), a                               ; FA54C0  f0 9a 41   (0x9A) = running status
	and	(MIDI_RX_Flags:8), 0xbd                        ; FA54C3  c0 9e 3c bd
	bit	0, (MIDI_RX_SysExState:8)                            ; FA54C7  f0 a9 c8
	jr z, .LFA54F9                                ; FA54CA  66 2d
	bit	1, (MIDI_RX_SysExState:8)                            ; FA54CC  f0 a9 c9
	jr z, .LFA54E5                                ; FA54CF  66 14
	cp A,0xf7                                     ; FA54D1  c9 cf f7
	jr nz, .LFA54EE                               ; FA54D4  6e 18
	bit	5, (MIDI_RX_SysExState:8)                            ; FA54D6  f0 a9 cd
	jr nz, .LFA54E5                               ; FA54D9  6e 0a
	pushw wa                                      ; FA54DB  28
	call T_Ring601646_Put                         ; FA54DC  1d 3c 1e f4
	inc 2,XSP                                     ; FA54E0  ef 62
	ld (MIDI_RX_SysExState:8), 0x04:io                               ; FA54E2  08 a9 04
.LFA54E5:
	ld (MIDI_RX_RunningStatus:8), 0x00:io                               ; FA54E5  08 9a 00
	and	(MIDI_RX_SysExState:8), 0xcc                        ; FA54E8  c0 a9 3c cc
	jr .LFA54F9                                   ; FA54EC  68 0b
.LFA54EE:
	ld (MIDI_RX_SysExState:8), 0x10:io                               ; FA54EE  08 a9 10
	ld (MIDI_RX_RunningStatus:8), 0x00:io                               ; FA54F1  08 9a 00
	jr .LFA54F9                                   ; FA54F4  68 03
.LFA54F6:
	calr MIDI_RX_DataByte                                   ; FA54F6  1e 6a 02   -> MIDI_RX_DataByte (0xFA5763)
.LFA54F9:
	calr MIDI_Parser_SaveContext                                   ; FA54F9  1e a5 03   -> MIDI_Parser_SaveContext (0xFA58A1)
	pop XIZ                                       ; FA54FC  5e
	pop XIY                                       ; FA54FD  5d
	pop XIX                                       ; FA54FE  5c
	pop XHL                                       ; FA54FF  5b
	pop XDE                                       ; FA5500  5a
	pop XBC                                       ; FA5501  59
	pop XWA                                       ; FA5502  58
	reti                                          ; FA5503  07

; ==============================================================================
; 0xFA5504-0xFA570B -- the MIDI System Real Time receive handler
; ==============================================================================
;
; ★ THIS ROUTINE DEFINES THE TRANSPORT STATE BYTES.  (0x94), (0x95) and (0x96)
;   are written here and in INTTR4_SequencerTick and INTT1_Tick, and putting the
;   three together gives the bit layout -- from the code, not from a guess:
;       bit 0  0x01  START pending / just started
;       bit 2  0x04  RUNNING          (every "is it going?" test is `bit 2`)
;       bit 3  0x08  STOP pending
;       bit 4  0x10  STOPPED
;   and the values actually written are 0x01 (start), 0x06 (running: bits 1+2),
;   0x0C, 0x10 (stopped), 0x08 and 0x86.  Bits 1, 5 and 7 are read in
;   INTT1_Tick but never assigned a meaning by anything traced so far.
;
; ★ FOUR TICKS PER MIDI CLOCK, again.  0xFA55A1 does `and (0x93),0xFC` then
;   `inc 4,(0x93)`: each incoming 0xF8 advances a transport by exactly 4 of the
;   96-per-beat ticks, and 96 / 24 = 4.  INTTR4_SequencerTick derives the same
;   constant from the other direction, by emitting a clock every 4th tick.
;
; ★ THE TEMPO TRACKER at MIDI_Clock_SetTempo is lever B of
;   notes/FINDINGS-system-clock.md.  Do not re-derive fc here; that note owns the
;   argument, including why the firmware's 1750 differs from the predicted 1792
;   by 2.3%.  What this conversion adds is the two clamps' meaning:
;       (0xA1) > 0x70   -> TREG5 = 0x4735.  With TREG5 = 140e6/(64*BPM) that is
;                          120.0 BPM exactly -- the "no clock has arrived for a
;                          long time" fallback tempo.
;       (0xA1) <= 4     -> TREG5 = 0x1C7B = 300.0 BPM exactly -- the fastest
;                          tempo the machine will follow.
;   Two round numbers falling out of two hex constants is a good sign the
;   TREG5-to-BPM formula in that note is right.
;
; ---------------------------------------------------------------------
; MIDI_RT_Received -- dispatch one System Real Time byte (0xF8-0xFF)
;
; Called from: MIDI_RX_Byte (0xFA54BB)
; Inputs:  A = the byte
; Outputs: depends on the byte -- see below.  D is used as a scratch copy of A.
; Evidence: every gate in the list below is a literal compare or bit test in
;          the body, in that order, and the four bytes it acts on -- 0xFE,
;          0xFD, 0xF8, 0xFA, 0xFB, 0xFC -- are immediates, not derived values:
;          0xFA5504 is `cp A,0xfe` and 0xFA5509 sets (0x9E) bit 7, the same
;          bit INTT1_Tick counts (0x9C) against. That pairing across two
;          routines is what identifies the byte as ACTIVE SENSING rather than
;          merely "the value 0xFE".
; Notes:   the gates it applies before doing anything, in order:
;            A == 0xFE            -> set (0x9E) bit 7 and return
;            (0x0925) bit 0 set   -> ignore
;            A >= 0xFD            -> ignore (0xFD is undefined; 0xFF is RESET)
;            (0x2094) bit 6 set   -> ignore
;            (0xA9) & 3 non-zero  -> ignore (a SysEx is in progress)
;            (0x7F32) bit 2 clear -> MIDI_RT_ExternalOff, the reduced handler
;          then 0xF8 drives the tempo tracker and advances the transports, 0xFA
;          rewinds and starts them, 0xFB resumes them and 0xFC stops them.
; ---------------------------------------------------------------------
MIDI_RT_Received:
	cp A,0xfe                                     ; FA5504  c9 cf fe   0xFE ACTIVE SENSING: arm the receive-inactivity timeout
	jr nz, MIDI_RT_NotSensing                               ; FA5507  6e 04
	set	7, (MIDI_RX_Flags:8)                            ; FA5509  f0 9e bf   (0x9E) bit 7 -- INTT1_Tick counts (0x9C) while this is set
MIDI_RT_Ignore:
	ret                                           ; FA550C  0e
MIDI_RT_NotSensing:
	bit	0, (0x0925:16)                        ; FA550D  f1 25 09 c8
	jr nz, MIDI_RT_Ignore                               ; FA5511  6e f9
	cp A,0xfd                                     ; FA5513  c9 cf fd   0xFD is undefined in MIDI 1.0; 0xFE/0xFF handled elsewhere
	jr nc, MIDI_RT_Ignore                               ; FA5516  6f f4
	bit	6, (0x2094:16)                        ; FA5518  f1 94 20 ce
	jr nz, MIDI_RT_Ignore                               ; FA551C  6e ee
	ld D,A                                        ; FA551E  c9 8c   D = the real-time byte
	ld	a, (MIDI_RX_SysExState:8)                               ; FA5520  c0 a9 21
	and A,0x03                                    ; FA5523  c9 cc 03
	jr nz, MIDI_RT_Ignore                               ; FA5526  6e e4
	bit	2, (MidiCfg_ModeBits:16)                        ; FA5528  f1 32 7f ca   the same mode bit INTTR4_SequencerTick branches on
	jrl z, MIDI_RT_ExternalOff                               ; FA552C  76 45 01
	cp D,0xf8                                     ; FA552F  cc cf f8   0xF8 TIMING CLOCK
	jr nz, MIDI_RT_NotClock                               ; FA5532  6e 2e
	bit	5, (0x34d0:16)                        ; FA5534  f1 d0 34 cd
	jr z, MIDI_Clock_SetTempo                                ; FA5538  66 04
	inc 0x01, (0x091e:16)                         ; FA553A  c1 1e 09 61
MIDI_Clock_SetTempo:
	ld	a, (0xa1:8)                               ; FA553E  c0 a1 21   (0xA1) = timer-1 ticks since the previous clock
	cp A,0x70                                     ; FA5541  c9 cf 70   more than 0x70 ticks -> the clock has stopped: fall back
	jr ugt, .LFA5559                              ; FA5544  6b 13
	cp a, 0x04:i3                                   ; FA5546  c9 dc   4 or fewer -> faster than the tempo range allows: clamp
	jr ugt, .LFA554F                              ; FA5548  6b 05
	ldw wa, 0x1c7b                                ; FA554A  30 7b 1c
	jr .LFA555C                                   ; FA554D  68 0d
.LFA554F:
	extz XWA                                      ; FA554F  e8 12
	xor W,W                                       ; FA5551  c8 d0
	muls WA,0x06d6                                ; FA5553  d8 09 d6 06
	jr .LFA555C                                   ; FA5557  68 03
.LFA5559:
	ldw wa, 0x4735                                ; FA5559  30 35 47
.LFA555C:
	ld	(TREG5L:8), wa                              ; FA555C  f0 32 50
	ld (0xa1:8), 0x00:io                               ; FA555F  08 a1 00
MIDI_RT_NotClock:
	ld	a, (TransportC_State:8)                               ; FA5562  c0 95 21
	pushw wa                                      ; FA5565  28
	and A,0x15                                    ; FA5566  c9 cc 15
	popw wa                                       ; FA5569  48
	jrl z, .LFA55DC                               ; FA556A  76 6f 00
	cp D,0xf8                                     ; FA556D  cc cf f8
	jr nz, .LFA55C1                               ; FA5570  6e 4f
	bit 0x00,A                                    ; FA5572  c9 33 00
	jr z, .LFA5584                                ; FA5575  66 0d
	ld (TransportC_State:8), 0x06:io                               ; FA5577  08 95 06
	bit	0, (TransportB_State:8)                            ; FA557A  f0 96 c8
	jr z, .LFA5582                                ; FA557D  66 03
	ld (TransportB_State:8), 0x06:io                               ; FA557F  08 96 06
.LFA5582:
	jr .LFA55C1                                   ; FA5582  68 3d
.LFA5584:
	bit 0x02,A                                    ; FA5584  c9 33 02
	jr z, .LFA559C                                ; FA5587  66 13
	and	(TransportC_Tick:8), 0xfc                        ; FA5589  c0 8d 3c fc
	inc	4, (TransportC_Tick:8)                           ; FA558D  c0 8d 64
	cp	(TransportC_Tick:8), 0x60                        ; FA5590  c0 8d 3f 60
	jr nz, .LFA559C                               ; FA5594  6e 06
	ld (TransportC_Tick:8), 0x00:io                               ; FA5596  08 8d 00
	incw	1, (TransportC_Beat:8)                           ; FA5599  d0 8e 61
.LFA559C:
	bit	2, (TransportB_State:8)                            ; FA559C  f0 96 ca
	jr z, .LFA55C1                                ; FA559F  66 20
	and	(Seq_BeatTick:8), 0xfc                        ; FA55A1  c0 93 3c fc
	inc	4, (Seq_BeatTick:8)                           ; FA55A5  c0 93 64   +4 ticks per MIDI clock, and 96/24 = 4
	cp	(Seq_BeatTick:8), 0x60                        ; FA55A8  c0 93 3f 60
	jr nz, .LFA55DB                               ; FA55AC  6e 2d
	ld (Seq_BeatTick:8), 0x00:io                               ; FA55AE  08 93 00
	incw	1, (TransportB_Beat:8)                           ; FA55B1  d0 91 61
	push XWA                                      ; FA55B4  38
	xor XWA,XWA                                   ; FA55B5  e8 d0
	cp (0x3004:16), xwa                          ; FA55B7  e1 04 30 f8
	pop XWA                                       ; FA55BB  58
	jr z, .LFA55C1                                ; FA55BC  66 03
	calr SeqBuf_AppendMarker_XIX                                 ; FA55BE  1e 0a 01
.LFA55C1:
	bit	2, (0x7f34:16)                        ; FA55C1  f1 34 7f ca
	jr z, .LFA55DB                                ; FA55C5  66 14
	cp D,0xfc                                     ; FA55C7  cc cf fc
	jr nz, .LFA55DB                               ; FA55CA  6e 0f
	set	7, (0x34bb:16)                        ; FA55CC  f1 bb 34 bf   (0x34BB) bit 7 -- 'stopped by an external 0xFC'
	ld (TransportC_State:8), 0x10:io                               ; FA55D0  08 95 10
.LFA55D3:
	bit	2, (TransportB_State:8)                            ; FA55D3  f0 96 ca
	jr z, .LFA55DB                                ; FA55D6  66 03
	ld (TransportB_State:8), 0x10:io                               ; FA55D8  08 96 10
.LFA55DB:
	ret                                           ; FA55DB  0e
.LFA55DC:
	bit	2, (0x7f34:16)                        ; FA55DC  f1 34 7f ca
	jr z, .LFA55D3                                ; FA55E0  66 f1
	bit	2, (0x34bb:16)                        ; FA55E2  f1 bb 34 ca
	jr nz, .LFA55F3                               ; FA55E6  6e 0b
	cp D,0xfa                                     ; FA55E8  cc cf fa
	jr z, MIDI_RT_Start                                ; FA55EB  66 1d
	cp D,0xfb                                     ; FA55ED  cc cf fb
	jrl z, MIDI_RT_Continue                               ; FA55F0  76 74 00
.LFA55F3:
	ret                                           ; FA55F3  0e
; MIDI_Clock_CatchUpIfAnySlot -- when the slot mask (0x60341E) is non-zero: MIDI_RT_Start_ResetCounters and
;          MIDI_Clock_CatchUp at interrupt level 6.  prom_b directory slot T_MIDI_Clock_CatchUpIfAnySlot; MainTask's timed-event
;          service calls it when bit 5 of (0x34D0) is set (0xF823EC).
MIDI_Clock_CatchUpIfAnySlot:
	push XWA                                      ; FA55F4  38
	xor XWA,XWA                                   ; FA55F5  e8 d0
	cp (0x60341e:24), xwa                     ; FA55F7  e2 1e 34 60 f8
	pop XWA                                       ; FA55FC  58
	jr z, .LFA5609                                ; FA55FD  66 0a
	push SR                                       ; FA55FF  02
	ei 0x06                                       ; FA5600  06 06
	calr MIDI_RT_Start_ResetCounters                                 ; FA5602  1e 19 00
	calr MIDI_Clock_CatchUp                                 ; FA5605  1e 33 00
	pop SR                                        ; FA5608  03
.LFA5609:
	ret                                           ; FA5609  0e
MIDI_RT_Start:
	set	5, (0x34d0:16)                        ; FA560A  f1 d0 34 bd
	ld (0x091e:16), 0x00                          ; FA560E  f1 1e 09 00 00
	push XWA                                      ; FA5613  38
	xor XWA,XWA                                   ; FA5614  e8 d0
	cp (0x60341e:24), xwa                     ; FA5616  e2 1e 34 60 f8
	pop XWA                                       ; FA561B  58
	jr nz, .LFA563A                               ; FA561C  6e 1c
MIDI_RT_Start_ResetCounters:
	xor WA,WA                                     ; FA561E  d8 d0
	ld	(TransportC_Tick:8), a                               ; FA5620  f0 8d 41   START rewinds transport C to bar 0 beat 0 tick 0
	ld	(TransportC_Beat:8), wa                              ; FA5623  f0 8e 50
	ld (TransportC_State:8), 0x01:io                               ; FA5626  08 95 01   and puts it in state 0x01
	bit	0, (0x34bb:16)                        ; FA5629  f1 bb 34 c8
	jr z, .LFA563A                                ; FA562D  66 0b
	xor WA,WA                                     ; FA562F  d8 d0
	ld	(Seq_BeatTick:8), a                               ; FA5631  f0 93 41
	ld	(TransportB_Beat:8), wa                              ; FA5634  f0 91 50
	ld (TransportB_State:8), 0x01:io                               ; FA5637  08 96 01
.LFA563A:
	ret                                           ; FA563A  0e
MIDI_Clock_CatchUp:
	cp	(0x091e:16), 0x00                     ; FA563B  c1 1e 09 3f 00
	jr z, MIDI_Clock_CatchUp_Done                                ; FA5640  66 1f
	bit	0, (TransportC_State:8)                            ; FA5642  f0 95 c8
	jr z, MIDI_Clock_CatchUp_Done                                ; FA5645  66 1a
	ld (TransportC_State:8), 0x06:io                               ; FA5647  08 95 06
	ld a, (0x091e:16)                            ; FA564A  c1 1e 09 21
	dec 1,A                                       ; FA564E  c9 69
	sll a, 0x02                                   ; FA5650  c9 ee 02
	add	(TransportC_Tick:8), a                           ; FA5653  c0 8d 89
	bit	0, (TransportB_State:8)                            ; FA5656  f0 96 c8
	jr z, MIDI_Clock_CatchUp_Done                                ; FA5659  66 06
	ld (TransportB_State:8), 0x06:io                               ; FA565B  08 96 06
	add	(Seq_BeatTick:8), a                           ; FA565E  c0 93 89
MIDI_Clock_CatchUp_Done:
	ld (0x091e:16), 0x00                          ; FA5661  f1 1e 09 00 00
	ret                                           ; FA5666  0e
MIDI_RT_Continue:
	ld (TransportC_State:8), 0x06:io                               ; FA5667  08 95 06
	bit	0, (0x34bb:16)                        ; FA566A  f1 bb 34 c8
	jr z, .LFA5673                                ; FA566E  66 03
	ld (TransportB_State:8), 0x06:io                               ; FA5670  08 96 06
.LFA5673:
	ret                                           ; FA5673  0e

; ---------------------------------------------------------------------
; MIDI_RT_ExternalOff -- the same dispatch when (0x7F32) bit 2 is clear
;
; Called from: MIDI_RT_Received (0xFA552C)
; Inputs:  D = the real-time byte
; Outputs: (0xA1) is zeroed -- so the tempo tracker's counter is kept reset even
;          when the tempo is not being followed -- and 0xFC still stops the
;          transports, but into state 0x0C rather than 0x10.
; Evidence: it is the `jr` target taken when (0x7F32) bit 2 is clear at
;          0xFA552C, and its first instruction is `ldio 0xa1,0x00` (0xFA5674)
;          -- the tempo counter INTT1_Tick increments and 0xFA553E turns into
;          TREG5. So the two arms differ in exactly the way the name says: one
;          follows the incoming clock, this one holds its counter at zero.
;          ⚠ "External" is the READING of that difference; the bit's producer
;          is not traced, which is why the header says so in Notes.
; Notes:   the pair of handlers is what makes (0x7F32) bit 2 a "follow external
;          MIDI clock" switch rather than a mode bit of unknown purpose.  That
;          is inference from the two arms' contents; the bit's producer has not
;          been traced.
; ---------------------------------------------------------------------
MIDI_RT_ExternalOff:
	ld (0xa1:8), 0x00:io                               ; FA5674  08 a1 00
	pushw wa                                      ; FA5677  28
	ld	a, (TransportC_State:8)                               ; FA5678  c0 95 21
	and A,0x05                                    ; FA567B  c9 cc 05
	popw wa                                       ; FA567E  48
	jr z, .LFA569C                                ; FA567F  66 1b
	bit	2, (0x7f34:16)                        ; FA5681  f1 34 7f ca
	jr z, .LFA569B                                ; FA5685  66 14
	cp D,0xfc                                     ; FA5687  cc cf fc
	jr nz, .LFA569B                               ; FA568A  6e 0f
	set	7, (0x34bb:16)                        ; FA568C  f1 bb 34 bf
	ld (TransportC_State:8), 0x0c:io                               ; FA5690  08 95 0c
	bit	2, (TransportB_State:8)                            ; FA5693  f0 96 ca
	jr z, .LFA569B                                ; FA5696  66 03
	ld (TransportB_State:8), 0x0c:io                               ; FA5698  08 96 0c
.LFA569B:
	ret                                           ; FA569B  0e
.LFA569C:
	bit	2, (0x7f34:16)                        ; FA569C  f1 34 7f ca
	jr z, .LFA56B2                                ; FA56A0  66 10
	bit	2, (0x34bb:16)                        ; FA56A2  f1 bb 34 ca
	jr nz, .LFA56B2                               ; FA56A6  6e 0a
	cp D,0xfa                                     ; FA56A8  cc cf fa
	jr z, .LFA56B3                                ; FA56AB  66 06
	cp D,0xfb                                     ; FA56AD  cc cf fb
	jr z, .LFA56BC                                ; FA56B0  66 0a
.LFA56B2:
	ret                                           ; FA56B2  0e
.LFA56B3:
	set	1, (MidiTx_RealtimePending:8)                            ; FA56B3  f0 a0 b9
	ld (INTES0:8), 0xdd:io                               ; FA56B6  08 77 dd
	jrl MIDI_RT_Start                                  ; FA56B9  78 4e ff
.LFA56BC:
	bit	0, (0x34bb:16)                        ; FA56BC  f1 bb 34 c8
	jr z, .LFA56CA                                ; FA56C0  66 08
	set	2, (MidiTx_RealtimePending:8)                            ; FA56C2  f0 a0 ba
	ld (INTES0:8), 0xdd:io                               ; FA56C5  08 77 dd
	jr MIDI_RT_Continue                                   ; FA56C8  68 9d
.LFA56CA:
	ret                                           ; FA56CA  0e

; ---------------------------------------------------------------------
; SeqBuf_AppendMarker_XIX -- a second copy of SeqBuf_AppendMarker
;
; Called from: 0xFA55BE
; Inputs:  as SeqBuf_AppendMarker, but the buffer pointer is built here rather
;          than inherited: XIX = 0x600A14
; Outputs: as SeqBuf_AppendMarker
; Evidence: "a second copy" is a byte-level statement and it can be checked by
;          eye against the first: the two bodies below are the same
;          instructions in the same order with XIX substituted for XIY, and
;          both write the same immediate 0x81 into the same buffer at 0x600A14
;          with the same `minc1_16 ...,0x01ff` wrap. Both listings are in this
;          file, side by side, and the byte gate holds both.
; Notes:   instruction for instruction the same routine as the one at 0xF83034,
;          with XIX substituted for XIY throughout -- two compilations of one
;          source, reached from the sequencer tick and from the MIDI clock.
; ---------------------------------------------------------------------
SeqBuf_AppendMarker_XIX:
	bit	0, (SeqBuf_Flags:8)                            ; FA56CB  f0 aa c8
	jr nz, .LFA56F8                               ; FA56CE  6e 28
	pushw wa                                      ; FA56D0  28
	ld XIX,SeqBuf_Ring                             ; FA56D1  44 14 0a 60 00
	ld wa, (xix-2)                                ; FA56D6  9c fe 20
	and WA,WA                                     ; FA56D9  d8 c0
	jr z, .LFA56F2                                ; FA56DB  66 15
	ld hl, (xix-4)                                ; FA56DD  9c fc 23
	ld	(xix+hl), 0x81                        ; FA56E0  f3 07 f0 ec 00 81
	minc1_16 hl, 0x01ff                           ; FA56E6  db 38 ff 01
	dec 1,WA                                      ; FA56EA  d8 69
	ld (xix-4), hl                                ; FA56EC  bc fc 53
	ld (xix-2), wa                                ; FA56EF  bc fe 50
.LFA56F2:
	popw wa                                       ; FA56F2  48
	ldw (SeqBuf_StagedCount:8), 0x00:io                              ; FA56F3  0a ac 00 00
	ret                                           ; FA56F7  0e
.LFA56F8:
	ld XIX,0x000000ae                             ; FA56F8  44 ae 00 00 00
	ld	hl, (SeqBuf_StagedCount:8)                          ; FA56FD  d0 ac 23
	ld	(xix+hl), 0x81                        ; FA5700  f3 07 f0 ec 00 81
	inc 1,HL                                      ; FA5706  db 61
	ld	(SeqBuf_StagedCount:8), hl                              ; FA5708  f0 ac 53
	ret                                           ; FA570B  0e
; ---------------------------------------------------------------------
; SeqBuf_AppendEvent_XIX -- a second copy of SeqBuf_AppendEvent
;
; Called from: NOTHING NAMES IT (as SeqBuf_AppendEvent itself; searched by
;          notes/prom_a_ringbuf_map.py, same negative).
; Inputs/Outputs: as SeqBuf_AppendEvent -- two bytes appended to ring
;          0x600A14.
; Evidence: notes/FINDINGS-prom_a-ring-buffers.md section 3 and
;          notes/prom_a_byte_checks.py ("SeqBuf twins:") establish this is
;          an INDEPENDENTLY WRITTEN twin of SeqBuf_AppendEvent (0xF830C6),
;          not a near-duplicate differing by one byte -- that earlier claim
;          was retracted 2026-08-25 (round-2 audit, F1).  75 of the 90
;          positional bytes differ.  What is identical below is transcribed
;          from SeqBuf_AppendEvent verbatim; what differs is transcribed
;          from SeqBuf_AppendMarker_XIX immediately above -- the proven
;          XIX idiom for this same 0x600A14 ring -- and from this file's
;          own established `push SR`/`ei 0x06`/`pop SR` and
;          `decm N,(reg+disp)` spellings.  Differences from
;          SeqBuf_AppendEvent (full table in the header there):
;            base register     XIX, not XIY
;            critical section  push SR / ei 0x06 .. pop SR, not push/pop XIY
;            free count        ONE decm 0x02,(xix-2), not TWO decm 0x01,(xiy-2)
;            write cursor      ld (xix-4),hl (indexed), not ld (0x600a10),hl
;            guard cell        (0x600a0c), the READ cursor, not (0x600a12)
;            trace path        ld XIX,0x000000ae + XIX-relative store, once;
;                              not extz XHL + XHL-relative, twice (2nd dead)
; ---------------------------------------------------------------------
SeqBuf_AppendEvent_XIX:
	bit	0, (SeqBuf_Flags:8)                                   ; FA570C  f0 aa c8
	jr nz, SeqBuf_AppendEvent_XIX__trace                 ; FA570F  6e 35
	cpw	(0x600a0c:24), 0x0002                        ; FA5711  d2 0c 0a 60 3f 02 00
	jr c, SeqBuf_AppendEvent_XIX__drop                   ; FA5718  67 27
	push SR                                              ; FA571A  02
	ei 0x06                                              ; FA571B  06 06
	ld XIX,SeqBuf_Ring                                    ; FA571D  44 14 0a 60 00
	ld hl, (xix-4)                                       ; FA5722  9c fc 23
	ld	(xix+hl), a                                  ; FA5725  f3 07 f0 ec 41
	minc1_16 hl, 0x01ff                                  ; FA572A  db 38 ff 01
	ld	a, (Seq_BeatTick:8)                                      ; FA572E  c0 93 21
	ld	(xix+hl), a                                  ; FA5731  f3 07 f0 ec 41
	minc1_16 hl, 0x01ff                                  ; FA5736  db 38 ff 01
	ld (xix-4), hl                                       ; FA573A  bc fc 53
	decm 0x02, (xix-2)                                   ; FA573D  9c fe 6a
	pop SR                                               ; FA5740  03
SeqBuf_AppendEvent_XIX__drop:
	ldw (SeqBuf_StagedCount:8), 0x00:io                                     ; FA5741  0a ac 00 00
	ret                                                  ; FA5745  0e
SeqBuf_AppendEvent_XIX__trace:
	ld XIX,0x000000ae                                    ; FA5746  44 ae 00 00 00
	ld	hl, (SeqBuf_StagedCount:8)                                 ; FA574B  d0 ac 23
	ld	(xix+hl), a                                  ; FA574E  f3 07 f0 ec 41
	inc 1,HL                                             ; FA5753  db 61
	ld	a, (Seq_BeatTick:8)                                      ; FA5755  c0 93 21
	ld	(xix+hl), a                                  ; FA5758  f3 07 f0 ec 41
	inc 1,HL                                             ; FA575D  db 61
	ld	(SeqBuf_StagedCount:8), hl                                     ; FA575F  f0 ac 53
	ret                                                  ; FA5762  0e

; ==============================================================================
; 0xFA5763-0xFA5941 -- the MIDI input parser, its register context, and the
;                      UART setup
; ==============================================================================
;
; ★ THE PARSER IS A RESUMED ROUTINE, NOT A CALLED ONE.  MIDI_RX_Byte pushes all
;   seven 32-bit registers on the STACK (they belong to whatever was
;   interrupted), then calls MIDI_Parser_LoadContext, which loads all seven from
;   a fixed RAM block at 0x0900; at the end it calls MIDI_Parser_SaveContext,
;   which writes them back, and only then pops the interrupted code's registers.
;
;   So the parser has its OWN persistent register set that survives between
;   incoming bytes, and code below may leave state in any register across a
;   whole MIDI message.  It does: C holds the first data byte of a two-data-byte
;   message from one interrupt to the next (0xFA57DB), and D/E are reloaded from
;   RAM each time.  Reading any of this as ordinary subroutine code -- where
;   registers die at the `ret` -- gets it wrong.
;
; The RAM the parser owns:
;   (0x0900)-(0x091B)  the seven saved 32-bit registers, in the order
;                      XWA XBC XDE XHL XIX XIY XIZ.  Cleared by
;                      MIDI_Parser_ClearContext.
;   (0x9A)   running status, 0 = none.  Written by MIDI_RX_Byte on every status
;            byte, cleared here on System Common, cleared by MIDI_RX_ErrorReset
;   (0x9E)   receive state flags -- see the table below
;   (0xA9)   SysEx state: bit 0 armed, bit 1 accepted/in-message, bit 5 seen
;   (0x0932) an 8-bit counter, bumped on every input-queue overflow
;   (0x216F) bit 0  set on every byte actually delivered -- a MIDI-activity flag
;
; (0x9E), as far as this block and the two already-converted handlers show:
;   bit 1  the pending two-data-byte message is a SONG POSITION POINTER
;   bit 2  the input queue overflowed
;   bit 3  the UART reported a receive error       (MIDI_RX_ErrorReset)
;   bit 5  active sensing timed out                (INTT1_Tick)
;   bit 6  a first data byte is pending in C
;   bit 7  active sensing has been seen            (MIDI_RT_Received)
;   MIDI_RX_Byte clears bits 6 and 1 (`and (0x9e),0xbd`) on every status byte,
;   which is what makes a new status cancel a half-received message.
;
; The queue this parser feeds is in prom_b: 0xF41DAC appends one byte and
; 0xF41E3C appends one SysEx byte.  ⚠ Their bodies are another lane's territory.
; The free-space count it tests is the 16-bit field at 0x00600C1E + 0xFE =
; (0x600D1C); "free" rather than "used" is not a guess -- every test is
; `cp (XIX+0xfe),n` / `jr c` -> OVERFLOW with n one greater than the number of
; bytes about to be written (3 before writing 2, 4 before writing 3).
;
; ---------------------------------------------------------------------
; MIDI_RX_DataByte -- the data-byte path of the MIDI receive interrupt
;
; Called from: MIDI_RX_Byte 0xFA54F6 (`calr`), when bit 7 of the received byte
;          is clear
; Inputs:  A = the data byte; (0x9A) = running status; (0x9E) and (0xA9) as above
; Outputs: zero, one or three bytes appended to the prom_b input queue; the
;          parser's flags updated.  D, E, C and XIX are used and their values
;          persist into the next interrupt through the saved context.
; Evidence: the three-way head is read straight off the branches -- SysEx armed
;          ((0xA9) bit 0) wins, then "a first data byte is pending" ((0x9E)
;          bit 6), then "no running status" (A == 0) drops the byte.  What is
;          left is dispatched through MIDI_StatusDispatch_Table, and that table
;          IS the identification: see its header.
; Unknown:  what reads (0x0932), and the exact meaning of (0xA9) bit 5.
; ---------------------------------------------------------------------
MIDI_RX_DataByte:
	ld E,A                                        ; FA5763  c9 8d   E = the data byte
	ld	a, (MIDI_RX_RunningStatus:8)                               ; FA5765  c0 9a 21   A = running status
	ld D,A                                        ; FA5768  c9 8c   D = running status
	bit	0, (MIDI_RX_SysExState:8)                            ; FA576A  f0 a9 c8   a SysEx is armed?
	jrl nz, MIDI_RX_SysExData                     ; FA576D  7e fe 00
	bit	6, (MIDI_RX_Flags:8)                            ; FA5770  f0 9e ce   a first data byte is already pending?
	jr nz, MIDI_RX_SecondDataByte                 ; FA5773  6e 69
	cp a, 0x00:i3                                   ; FA5775  c9 d8   no running status at all?
	jr z, MIDI_RX_Drop                            ; FA5777  66 35   then the byte has nowhere to go
	and A,0x70                                    ; FA5779  c9 cc 70   the status nibble, minus its top bit
	srl a, 0x02                                   ; FA577C  c9 ef 02   * 4: eight 32-bit table slots
	xor W,W                                       ; FA577F  c8 d0
	ld XIX,MIDI_StatusDispatch_Table              ; FA5781  44 8e 57 fa 00
	ld	xix, (xix+wa)                         ; FA5786  e3 07 f0 e0 24
	jp (xix)                                      ; FA578B  b4 d8
	nop                                           ; FA578D  00

; ---------------------------------------------------------------------
; MIDI_StatusDispatch_Table -- eight LE32 handlers, indexed by the status nibble
;
; Called from: MIDI_RX_DataByte 0xFA578B, as `jp (XIX)` after
;          XIX = (0xFA578E + ((status & 0x70) >> 2))
; Layout:  8 entries x 4 bytes = 32 bytes, 0xFA578E-0xFA57AD.  The COUNT is
;          fixed by the addressing, not by inspection: `and A,0x70` leaves three
;          significant bits and `srl 2` turns them into a 0..28 byte offset, so
;          index 7 is the last slot the code can form -- and slot 7 ends at
;          0xFA57AE, which is the RET slot 2 points at.  A ninth entry would
;          overlap it.
; Evidence: ★ this table is what identifies the whole block as a MIDI parser.
;          The index is (status & 0x70) >> 4, and bit 7 is always set on a
;          status byte, so index n means status 0x80 + 16n:
;
;            index  status  MIDI message           target
;              0     0x8n   Note Off               MIDI_RX_AwaitSecondByte
;              1     0x9n   Note On                MIDI_RX_AwaitSecondByte
;              2     0xAn   Poly Key Pressure      MIDI_RX_Drop  <-- a bare RET
;              3     0xBn   Control Change         MIDI_RX_AwaitSecondByte
;              4     0xCn   Program Change         MIDI_RX_DeliverTwo
;              5     0xDn   Channel Pressure       MIDI_RX_DeliverTwo
;              6     0xEn   Pitch Bend             MIDI_RX_AwaitSecondByte
;              7     0xFn   System                 MIDI_RX_SystemCommon
;
;          That is EXACTLY the MIDI 1.0 data-byte count for each status: two
;          data bytes for 0x8n 0x9n 0xBn 0xEn, one for 0xCn and 0xDn.  Nothing
;          was assumed to produce it -- the four addresses are read out of the
;          ROM and the grouping falls out.
; Naming:  called MIDI_MessageLength_Table until 2026-08-25.  Renamed after the
;          round-1 audit: every entry is a 32-bit CODE POINTER, not a length,
;          so a reader who greps the old name expects `.long 2,2,2,...` and
;          finds handlers.  The data-byte count is only IMPLIED, by which
;          handler each status is grouped onto; the object itself is a dispatch
;          table.  The grouping argument below is unchanged and still stands.
; Notes:   ★ index 2 is the finding.  Polyphonic Key Pressure is the one
;          channel-voice message this instrument DISCARDS: its slot points at
;          0xFA57AE, a bare `ret`, and the two data bytes that follow are then
;          dropped as well because bit 6 of (0x9E) was never set.  Every other
;          channel-voice message is delivered.
; Unknown:  nothing outstanding.
; ---------------------------------------------------------------------
MIDI_StatusDispatch_Table:
	.long MIDI_RX_AwaitSecondByte	; FA578E  d8 57 fa 00   0x8n Note Off
	.long MIDI_RX_AwaitSecondByte	; FA5792  d8 57 fa 00   0x9n Note On
	.long MIDI_RX_Drop	; FA5796  ae 57 fa 00   0xAn Poly Key Pressure -- DISCARDED
	.long MIDI_RX_AwaitSecondByte	; FA579A  d8 57 fa 00   0xBn Control Change
	.long MIDI_RX_DeliverTwo	; FA579E  af 57 fa 00   0xCn Program Change
	.long MIDI_RX_DeliverTwo	; FA57A2  af 57 fa 00   0xDn Channel Pressure
	.long MIDI_RX_AwaitSecondByte	; FA57A6  d8 57 fa 00   0xEn Pitch Bend
	.long MIDI_RX_SystemCommon	; FA57AA  30 58 fa 00   0xFn System Common

; ---------------------------------------------------------------------
; MIDI_RX_Drop -- the "this message is not wanted" target: one RET
;
; Called from: MIDI_StatusDispatch_Table slot 2 (Poly Key Pressure), and
;          MIDI_RX_DataByte 0xFA5777 (no running status)
; Evidence: the body is one byte, 0x0E = RET at 0xFA57AE. Both routes in are
;          re-derived from the ROM by notes/prom_a_byte_checks.py -- the
;          branch at 0xFA5777 and the single data reference at 0xFA5796, which
;          is MIDI_StatusDispatch_Table + 2*4, i.e. slot 2. There is no third
;          route.
; ---------------------------------------------------------------------
MIDI_RX_Drop:
	ret                                           ; FA57AE  0e

; ---------------------------------------------------------------------
; MIDI_RX_DeliverTwo -- append <status, data> to the input queue
;
; Called from: MIDI_StatusDispatch_Table slots 4 and 5 (Program Change, Channel
;          Pressure); MIDI_RX_SongSelect 0xFA584A (`jrl`)
; Inputs:  D = status, E = the single data byte
; Outputs: two bytes appended through prom_b 0xF41DAC, or the overflow flag set
; Evidence: the free-space test is `cp (XIX+0xfe),0x0003` before appending TWO
;          bytes -- one more than it is about to write, which is what makes
;          (0x600D1C) a FREE count and not a used one.
; ---------------------------------------------------------------------
MIDI_RX_DeliverTwo:
	set	0, (MIDI_ActivityFlags:16)                        ; FA57AF  f1 6f 21 b8   MIDI activity
	ld XIX,MidiIn_PortARing                             ; FA57B3  44 1e 0c 60 00
	cpw	(xix-2), 0x0003                       ; FA57B8  9c fe 3f 03 00   free space >= 3?
	jr c, MIDI_RX_QueueFull2                      ; FA57BD  67 11
	ld A,D                                        ; FA57BF  cc 89
	pushw wa                                      ; FA57C1  28
	call T_MidiInARing_Put                         ; FA57C2  1d ac 1d f4   append the status byte
	inc 2,XSP                                     ; FA57C6  ef 62
	pushw de                                      ; FA57C8  2a
	call T_MidiInARing_Put                         ; FA57C9  1d ac 1d f4   append the data byte
	inc 2,XSP                                     ; FA57CD  ef 62
	ret                                           ; FA57CF  0e
MIDI_RX_QueueFull2:
	set	2, (MIDI_RX_Flags:8)                            ; FA57D0  f0 9e ba   (0x9E) bit 2 = the input queue overflowed
	inc 0x01, (MIDI_RX_OverflowCount:16)                         ; FA57D3  c1 32 09 61   8-bit overflow counter
	ret                                           ; FA57D7  0e

; ---------------------------------------------------------------------
; MIDI_RX_AwaitSecondByte -- stash the first of two data bytes and return
;
; Called from: MIDI_StatusDispatch_Table slots 0, 1, 3, 6
; Inputs:  E = the first data byte
; Outputs: C = E, and (0x9E) bit 6 set so the NEXT byte takes
;          MIDI_RX_SecondDataByte.  C survives to that interrupt through the
;          saved register context -- see this block's header.
; Evidence: the body is three instructions -- `set 6,(0x9E)` at 0xFA57D8, `ld
;          C,E` at 0xFA57DB, `ret` -- and bit 6 of (0x9E) is exactly the bit
;          MIDI_RX_DataByte tests at 0xFA5770 to send the NEXT byte to
;          MIDI_RX_SecondDataByte. The two halves of the name are those two
;          facts.
; ---------------------------------------------------------------------
MIDI_RX_AwaitSecondByte:
	set	6, (MIDI_RX_Flags:8)                            ; FA57D8  f0 9e be
	ld C,E                                        ; FA57DB  cd 8b
	ret                                           ; FA57DD  0e

; ---------------------------------------------------------------------
; MIDI_RX_SecondDataByte -- the second data byte of a three-byte message
;
; Called from: MIDI_RX_DataByte 0xFA5773, when (0x9E) bit 6 is set
; Inputs:  C = the first data byte, E = the second, D = running status
; Outputs: three bytes appended, and (0x9E) bits 6 and 1 cleared
; Evidence: ★ THE CONGESTION RULE.  Before the ordinary "is there room for 3"
;          test there is a SECOND, much larger one: if free space is 0x40 or
;          less, and the message is a Note On (`and D,0xf0` / `cp D,0x90`) whose
;          velocity is NOT zero (`cp E,0` / `jr nz`), the message is thrown
;          away.  A Note On with velocity zero -- which is how MIDI spells a
;          release under running status -- falls through and IS delivered.
;          So under overload the parser sheds NOTE STARTS and always keeps NOTE
;          ENDS, which is exactly the behaviour that stops an overloaded input
;          leaving notes stuck on.  The sense of the velocity test is worth
;          reading twice: `jr nz` after `cp E,0` jumps to the RET, so it is the
;          non-zero velocity that is dropped.
; Notes:   the `ld D,0xf2` at 0xFA57E7 restores the status for a Song Position
;          Pointer.  It is needed because MIDI_RX_SystemCommon zeroed the
;          running status when the 0xF2 arrived, so D would otherwise be 0 by
;          the time the second data byte turns up; (0x9E) bit 1 is the marker
;          that says which message this is.
; ---------------------------------------------------------------------
MIDI_RX_SecondDataByte:
	set	0, (MIDI_ActivityFlags:16)                        ; FA57DE  f1 6f 21 b8   MIDI activity
	bit	1, (MIDI_RX_Flags:8)                            ; FA57E2  f0 9e c9   a Song Position Pointer?
	jr z, .LFA57E9                                ; FA57E5  66 02
	ld d, 0xf2:opc                                   ; FA57E7  24 f2   restore the status the F2 handler cleared
.LFA57E9:
	ld XIX,MidiIn_PortARing                             ; FA57E9  44 1e 0c 60 00
	cpw	(xix-2), 0x0040                       ; FA57EE  9c fe 3f 40 00   plenty of room?
	jr ugt, MIDI_RX_DeliverThree                  ; FA57F3  6b 0e
	pushw de                                      ; FA57F5  2a
	and D,0xf0                                    ; FA57F6  cc cc f0
	cp D,0x90                                     ; FA57F9  cc cf 90   a Note On?
	popw de                                       ; FA57FC  4a
	jr nz, MIDI_RX_DeliverThree                   ; FA57FD  6e 04
	cp e, 0x00:i3                                   ; FA57FF  cd d8   velocity zero = a note END, keep it
	jr nz, MIDI_RX_Return                         ; FA5801  6e 24   a real note START, drop it
MIDI_RX_DeliverThree:
	cpw	(xix-2), 0x0004                       ; FA5803  9c fe 3f 04 00   free space >= 4?
	jr c, MIDI_RX_QueueFull3                      ; FA5808  67 1e
	ld A,D                                        ; FA580A  cc 89
	pushw wa                                      ; FA580C  28
	call T_MidiInARing_Put                         ; FA580D  1d ac 1d f4   status
	inc 2,XSP                                     ; FA5811  ef 62
	ld A,C                                        ; FA5813  cb 89
	pushw wa                                      ; FA5815  28
	call T_MidiInARing_Put                         ; FA5816  1d ac 1d f4   first data byte
	inc 2,XSP                                     ; FA581A  ef 62
	pushw de                                      ; FA581C  2a
	call T_MidiInARing_Put                         ; FA581D  1d ac 1d f4   second data byte
	inc 2,XSP                                     ; FA5821  ef 62
	and	(MIDI_RX_Flags:8), 0xbd                        ; FA5823  c0 9e 3c bd   clear bits 6 and 1
MIDI_RX_Return:
	ret                                           ; FA5827  0e
MIDI_RX_QueueFull3:
	set	2, (MIDI_RX_Flags:8)                            ; FA5828  f0 9e ba
	inc 0x01, (MIDI_RX_OverflowCount:16)                         ; FA582B  c1 32 09 61
	ret                                           ; FA582F  0e

; ---------------------------------------------------------------------
; MIDI_RX_SystemCommon -- the 0xFn arm of MIDI_StatusDispatch_Table
;
; Called from: MIDI_StatusDispatch_Table slot 7
; Inputs:  D = the status byte (0xF0-0xF7), E = the first data byte
; Outputs: running status cleared; then per message
; Evidence: three explicit compares and a fall-through:
;            0xF0 SYSTEM EXCLUSIVE   -> MIDI_RX_SysExStart
;            0xF2 SONG POSITION      -> MIDI_RX_SongPosition, two data bytes
;            0xF3 SONG SELECT        -> MIDI_RX_DeliverTwo, one data byte
;            anything else           -> RET, i.e. 0xF1 MIDI Time Code Quarter
;                                       Frame and 0xF6 Tune Request are IGNORED
;          Clearing (0x9A) first is the MIDI 1.0 rule that a System Common
;          message cancels running status, and it is done unconditionally --
;          before the dispatch, so it applies to the ignored ones too.
; ---------------------------------------------------------------------
MIDI_RX_SystemCommon:
	ld (MIDI_RX_RunningStatus:8), 0x00:io                               ; FA5830  08 9a 00   System Common cancels running status
	cp D,0xf0                                     ; FA5833  cc cf f0
	jr z, MIDI_RX_SysExStart                      ; FA5836  66 15
	cp D,0xf2                                     ; FA5838  cc cf f2
	jr z, MIDI_RX_SongPosition                    ; FA583B  66 06
	cp D,0xf3                                     ; FA583D  cc cf f3
	jr z, MIDI_RX_SongSelect                      ; FA5840  66 08
	ret                                           ; FA5842  0e
MIDI_RX_SongPosition:
	or	(MIDI_RX_Flags:8), 0x42                        ; FA5843  c0 9e 3e 42   bit 6 = a byte is pending, bit 1 = it is an SPP
	ld C,E                                        ; FA5847  cd 8b
	ret                                           ; FA5849  0e
MIDI_RX_SongSelect:
	jrl MIDI_RX_DeliverTwo                        ; FA584A  78 62 ff

; ---------------------------------------------------------------------
; MIDI_RX_SysExStart -- 0xF0 arrived and this is its first data byte, the ID
;
; Called from: MIDI_RX_SystemCommon 0xFA5836
; Inputs:  D = 0xF0, E = the identifier byte
; Outputs: (0xA9) = 1 (armed).  If the identifier is accepted, bit 1 is set as
;          well and BOTH bytes are forwarded through prom_b 0xF41E3C.
; Evidence: exactly two identifiers are accepted, 0x50 and 0x7E, and every
;          other value leaves (0xA9) armed but NOT in-message -- so the rest of
;          that message reaches MIDI_RX_SysExData and is discarded there,
;          which is how a device ignores another maker's SysEx without losing
;          track of where it ends.
;          0x7E is MIDI's Universal Non-Real Time identifier.  0x50 is a
;          manufacturer identifier, and by the shape of the test it must be
;          this machine's own.  ⚠ Which company holds 0x50 is NOT established
;          here -- it needs the MMA's assignment list, which is not in this
;          tree.  Do not write a company name into this file on the strength
;          of the byte alone.
; Unknown:  (0xA9) bit 5, tested by MIDI_RX_SysExData and set nowhere in the
;          converted code.
; ---------------------------------------------------------------------
MIDI_RX_SysExStart:
	ld (MIDI_RX_SysExState:8), 0x01:io                               ; FA584D  08 a9 01   armed
	cp E,0x50                                     ; FA5850  cd cf 50
	jr z, MIDI_SysEx_Accept                       ; FA5853  66 05
	cp E,0x7e                                     ; FA5855  cd cf 7e   Universal Non-Real Time
	jr nz, MIDI_SysEx_Ignore                      ; FA5858  6e 13
MIDI_SysEx_Accept:
	set	1, (MIDI_RX_SysExState:8)                            ; FA585A  f0 a9 b9   in-message
	ld A,D                                        ; FA585D  cc 89
	pushw wa                                      ; FA585F  28
	call T_Ring601646_Put                         ; FA5860  1d 3c 1e f4   forward the 0xF0
	inc 2,XSP                                     ; FA5864  ef 62
	pushw de                                      ; FA5866  2a
	call T_Ring601646_Put                         ; FA5867  1d 3c 1e f4   forward the identifier
	inc 2,XSP                                     ; FA586B  ef 62
MIDI_SysEx_Ignore:
	ret                                           ; FA586D  0e

; ---------------------------------------------------------------------
; MIDI_RX_SysExData -- a data byte inside a System Exclusive message
;
; Called from: MIDI_RX_DataByte 0xFA576D, whenever (0xA9) bit 0 is set
; Inputs:  E = the byte, (0xA9) the SysEx state
; Outputs: the byte forwarded through prom_b 0xF41E3C, or dropped
; Evidence: it forwards only when bit 1 is set AND bit 5 is clear.  Bit 1 is
;          MIDI_RX_SysExStart's "the identifier was accepted", so a message
;          from an unrecognised maker is armed but never forwarded.
; ---------------------------------------------------------------------
MIDI_RX_SysExData:
	bit	1, (MIDI_RX_SysExState:8)                            ; FA586E  f0 a9 c9   was the identifier accepted?
	jr z, MIDI_SysEx_DataDone                     ; FA5871  66 10
	bit	5, (MIDI_RX_SysExState:8)                            ; FA5873  f0 a9 cd
	jr nz, MIDI_SysEx_DataDone                    ; FA5876  6e 0b
	set	0, (MIDI_ActivityFlags:16)                        ; FA5878  f1 6f 21 b8   MIDI activity
	pushw de                                      ; FA587C  2a
	call T_Ring601646_Put                         ; FA587D  1d 3c 1e f4
	inc 2,XSP                                     ; FA5881  ef 62
MIDI_SysEx_DataDone:
	ret                                           ; FA5883  0e

; ---------------------------------------------------------------------
; MIDI_Parser_LoadContext / MIDI_Parser_SaveContext -- the parser's own
; register set, in RAM at 0x0900
;
; Called from: MIDI_RX_Byte 0xFA54A8 (load) and 0xFA54F9 (save)
; Inputs/Outputs: all seven 32-bit registers, moved between the CPU and
;          0x0900-0x091B in the order XWA XBC XDE XHL XIX XIY XIZ
; Evidence: seven `ld XRR,(nn)` against seven `ld (nn),XRR` over the same seven
;          addresses four bytes apart, and MIDI_RX_Byte brackets its whole body
;          with one call to each -- INSIDE the push/pop of the interrupted
;          code's registers.  That nesting is the whole point: see this block's
;          header.
; Notes:   the block is 28 bytes, 0x0900-0x091B.  MIDI_Parser_ClearContext
;          zeroes exactly those seven longs, which is the independent check
;          that the block is seven entries and not eight.
; ---------------------------------------------------------------------
MIDI_Parser_LoadContext:
	ld xwa, (MIDI_Parser_SavedXWA:16)                          ; FA5884  e1 00 09 20
	ld xbc, (MIDI_Parser_SavedXBC:16)                          ; FA5888  e1 04 09 21
	ld xde, (MIDI_Parser_SavedXDE:16)                          ; FA588C  e1 08 09 22
	ld xhl, (MIDI_Parser_SavedXHL:16)                          ; FA5890  e1 0c 09 23
	ld xix, (MIDI_Parser_SavedXIX:16)                          ; FA5894  e1 10 09 24
	ld xiy, (MIDI_Parser_SavedXIY:16)                          ; FA5898  e1 14 09 25
	ld xiz, (MIDI_Parser_SavedXIZ:16)                          ; FA589C  e1 18 09 26
	ret                                           ; FA58A0  0e
MIDI_Parser_SaveContext:
	ld (MIDI_Parser_SavedXWA:16), xwa                          ; FA58A1  f1 00 09 60
	ld (MIDI_Parser_SavedXBC:16), xbc                          ; FA58A5  f1 04 09 61
	ld (MIDI_Parser_SavedXDE:16), xde                          ; FA58A9  f1 08 09 62
	ld (MIDI_Parser_SavedXHL:16), xhl                          ; FA58AD  f1 0c 09 63
	ld (MIDI_Parser_SavedXIX:16), xix                          ; FA58B1  f1 10 09 64
	ld (MIDI_Parser_SavedXIY:16), xiy                          ; FA58B5  f1 14 09 65
	ld (MIDI_Parser_SavedXIZ:16), xiz                          ; FA58B9  f1 18 09 66
	ret                                           ; FA58BD  0e

; ---------------------------------------------------------------------
; MIDI_Reset -- bring the MIDI subsystem up
;
; Called from: MIDI_EntryThunks slot 3 (0xFA540C), converted above -- the
;          module's only live public entry point, built exactly like
;          LCD_EntryThunks at 0xF8E800.  ⚠ Nothing that reaches that table has
;          been found, so nothing here says WHEN the MIDI subsystem is reset.
; Inputs:  none
; Outputs: the parser context zeroed, the UART programmed, and two further
;          routines run
; Evidence: four calls and a return, nothing else.
; Notes:   the third call is MIDI_SendStart_PortB (0xFA5BF7), converted in
;          wave 7 round 2: it puts the single byte 0xFA on port B.
; ---------------------------------------------------------------------
MIDI_Reset:
	calr MIDI_Parser_ClearContext                 ; FA58BE  1e 0b 00
	calr MIDI_UART_Configure                      ; FA58C1  1e 2c 00
	call MIDI_SendStart_PortB                                 ; FA58C4  1d f7 5b fa
	calr MIDI_SetRealtimeIgnoreFromVariant                               ; FA58C8  1e 5b 00
	ret                                           ; FA58CB  0e

; ---------------------------------------------------------------------
; MIDI_Parser_ClearContext -- zero the parser's seven saved registers
;
; Called from: MIDI_Reset 0xFA58BE
; Evidence: seven 32-bit stores of 0 to 0x0900, 0x0904 ... 0x0918 -- the same
;          seven addresses MIDI_Parser_LoadContext reads.
; ---------------------------------------------------------------------
MIDI_Parser_ClearContext:
	ld (MIDI_Parser_SavedXWA:16), 0x00                          ; FA58CC  f1 00 09 00 00
	ld (MIDI_Parser_SavedXBC:16), 0x00                          ; FA58D1  f1 04 09 00 00
	ld (MIDI_Parser_SavedXDE:16), 0x00                          ; FA58D6  f1 08 09 00 00
	ld (MIDI_Parser_SavedXHL:16), 0x00                          ; FA58DB  f1 0c 09 00 00
	ld (MIDI_Parser_SavedXIX:16), 0x00                          ; FA58E0  f1 10 09 00 00
	ld (MIDI_Parser_SavedXIY:16), 0x00                          ; FA58E5  f1 14 09 00 00
	ld (MIDI_Parser_SavedXIZ:16), 0x00                          ; FA58EA  f1 18 09 00 00
	ret                                           ; FA58EF  0e

; ---------------------------------------------------------------------
; MIDI_UART_Configure -- program serial channel 0 for the MIDI current loop
;
; Called from: MIDI_Reset 0xFA58C1
; Inputs:  the byte at 0xFFFFF8
; Outputs: SC0MOD, SC0CR, BR0CR and SC0BUF written; (0x77) = 0x5D; the
;          interrupt mask raised to 6 for the duration and released to 0
; Evidence: the SFR numbers are the TMP95C061's -- 0x50 SC0BUF, 0x51 SC0CR,
;          0x52 SC0MOD, 0x53 BR0CR.  SC0MOD = 0x29 is 8-bit UART clocked from
;          the baud-rate generator, and BR0CR = 0x0E divides by 896:
;          31250 x 896 = 28,000,000, which is where
;          notes/FINDINGS-system-clock.md gets fc = 28 MHz.
; Notes:   ★ THE 0x0C BRANCH IS DEAD, and that is checkable rather than
;          assumed.  0xFFFFF8 is inside this ROM's BUILD_TAG and holds 0x02,
;          not 0x24, so the compare at 0xFA58FB always fails and BR0CR stays
;          0x0E.  See the BUILD_TAG block at the end of this file, and
;          notes/FINDINGS-system-clock.md, which enumerates every BR0CR writer
;          in both images.
;          `ei 0x06` RAISES the interrupt mask and `ei 0x00` releases it, so
;          the pair brackets a critical section -- the reverse of what the
;          mnemonic suggests.  See notes/llvm-mc-tlcs900-spellings.md.
; Unknown:  why SC0BUF is written 0xFE at the end.  (0x77) is the one-byte
;          mailbox MIDI_TX_Ready also writes.
; ---------------------------------------------------------------------
MIDI_UART_Configure:
	ei 0x06                                       ; FA58F0  06 06   RAISE the mask: critical section
	ld (SC0MOD:8), 0x29:io                               ; FA58F2  08 52 29   SC0MOD = 8-bit UART, baud-rate generator
	ld (SC0CR:8), 0x00:io                               ; FA58F5  08 51 00   SC0CR cleared
	ld (BR0CR:8), 0x0e:io                               ; FA58F8  08 53 0e   BR0CR: divide by 896 -> 31250 baud at fc = 28 MHz
	cp (BUILD_TAG+8:24), 0x24                     ; FA58FB  c2 f8 ff ff 3f 24   the byte here is 0x02 -- never equal
	jr nz, .LFA5906                               ; FA5901  6e 03
	ld (BR0CR:8), 0x0c:io                               ; FA5903  08 53 0c   divide by 768 -- NOT REACHED
.LFA5906:
	ld (INTES0:8), 0x5d:io                               ; FA5906  08 77 5d
	ld (SC0BUF:8), 0xfe:io                               ; FA5909  08 50 fe   SC0BUF
	ei 0x00                                       ; FA590C  06 00   release the mask
	ret                                           ; FA590E  0e

; ---------------------------------------------------------------------
; MIDI_PostSendWork -- wake the transmitter
;
; Called from: prom_b thunk 0xF40724 (`jp 0xFA590F`), and 0xFA5BD1, 0xFA5C81
; Inputs:  (0x89)
; Outputs: either (0x77) = 0xDD, or prom_b 0xF41E00 is called and (0xA0)
;          cleared
; Evidence: this is the routine FINDINGS-midi-port.md already names as the
;          other writer of the (0x77) mailbox; MIDI_TX_Ready writes 0xFD there
;          when it runs dry.  (0xA0) is the System Real Time request bitmap
;          that same note decodes, and clearing it abandons every pending
;          real-time byte.
; Notes:   `push SR` / `ei 0x06` / ... / `pop SR` is the save-and-raise form of
;          the critical section: the old mask is restored rather than forced
;          to 0.
; Unknown:  ⚠ what (0x89) == 0xFF means.  It selects the whole second arm, so
;          it is not a detail.
; ---------------------------------------------------------------------
MIDI_PostSendWork:
	push SR                                       ; FA590F  02
	ei 0x06                                       ; FA5910  06 06
	cp	(0x89:8), 0xff                        ; FA5912  c0 89 3f ff
	jr z, .LFA591D                                ; FA5916  66 05
	ld (INTES0:8), 0xdd:io                               ; FA5918  08 77 dd   the mailbox MIDI_TX_Ready also writes
	pop SR                                        ; FA591B  03
	ret                                           ; FA591C  0e
.LFA591D:
	call T_Ring601432_Init                        ; FA591D  1d 00 1e f4
	ld (MidiTx_RealtimePending:8), 0x00:io                               ; FA5921  08 a0 00   drop every pending real-time request
	pop SR                                        ; FA5924  03
	ret                                           ; FA5925  0e

; ---------------------------------------------------------------------
; MIDI_SetRealtimeIgnoreFromVariant -- mirror "(0xC4) == 2" into bit 0 of (0x0925)
;
; Called from: MIDI_Reset 0xFA58C8
; Inputs:  (0xC4)
; Outputs: bit 0 of (0x0925) set if (0xC4) == 2, cleared otherwise
; Evidence: that is the whole routine -- clear the bit, compare, set it back.
; Unknown:  ⚠ deliberately NOT named.  Neither (0xC4) nor (0x0925) is
;          identified anywhere in this tree, so any name would be a guess about
;          what the two mean.  It is called only from MIDI_Reset, which is a
;          hint that (0xC4) is a MIDI-related mode byte and nothing more.
; ---------------------------------------------------------------------
; MIDI_SetRealtimeIgnoreFromVariant: (0x0925) bit 0 := (Variant_Flag == 2), the bit MIDI_RT_Received tests to drop
;   every System Real Time byte except Active Sensing -- so variant 2 (the SX-WSA1R, FINDINGS-prom_a-panel-control-
;   map.md 2) ignores incoming clock / start / continue / stop. Last step of MIDI_Reset. Basis: caller + body + the
;   bit's only reader. (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
MIDI_SetRealtimeIgnoreFromVariant:
	res	0, (0x0925:16)                        ; FA5926  f1 25 09 b0
	cp	(Variant_Flag:8), 0x02                        ; FA592A  c0 c4 3f 02
	jr nz, .LFA5934                               ; FA592E  6e 04
	set	0, (0x0925:16)                        ; FA5930  f1 25 09 b8
.LFA5934:
	ret                                           ; FA5934  0e

; ---------------------------------------------------------------------
; PanelLed_ToggleActivityLed_SaveRegs -- call prom_b 0xF406A0 with four registers preserved
;
; Called from: MIDI_Fg_Deliver2 (0xFA5A93) and MIDI_Fg_Deliver3 (0xFA5AC6),
;          both `calr`.  ⚠ An earlier version of this header said no caller had
;          been found, citing notes/prom_a_xref.py -- which is an ABSOLUTE
;          reference search and cannot see a `calr`.  The two callers turned up
;          as soon as their neighbourhood was converted.  Recorded because it is
;          the same trap that produced "Dev7A_StartDma has no callers" earlier
;          in this tree: "prom_a_xref found nothing" is not "nothing calls it".
; Inputs:  XIX = a buffer on the caller's frame (2 bytes at 0xFA5A93, 4 at
;          0xFA5AC6); whatever else 0xF406A0 takes
; Outputs: whatever it returns; XDE, XHL, XIX and XIZ are preserved
; Notes:   both callers do the same thing straight afterwards -- fill that
;          buffer with a MIDI message and hand it to prom_b 0xF41DD4 -- so this
;          is very likely the buffer's initialiser.
; Unknown:  ⚠ still NOT named.  "Very likely the initialiser" is a reading of
;          two call sites, not a fact about 0xF406A0, which is a prom_b thunk
;          this tree has not resolved.
; ---------------------------------------------------------------------
PanelLed_ToggleActivityLed_SaveRegs:
	push XDE                                      ; FA5935  3a
	push XHL                                      ; FA5936  3b
	push XIX                                      ; FA5937  3c
	push XIZ                                      ; FA5938  3e
	call T_PanelLed_ToggleActivityLed                                 ; FA5939  1d a0 06 f4
	pop XIZ                                       ; FA593D  5e
	pop XIX                                       ; FA593E  5c
	pop XHL                                       ; FA593F  5b
	pop XDE                                       ; FA5940  5a
	ret                                           ; FA5941  0e

; ==============================================================================
; 0xFA5942-0xFA5AEA -- the FOREGROUND MIDI consumer
; ==============================================================================
;
; ★ THERE ARE TWO MIDI STATE MACHINES IN THIS FIRMWARE, NOT ONE, AND THEY HAVE
;   THE SAME SHAPE.  The interrupt-time parser at 0xFA5763 keeps
;
;       (0x9A)   running status      (0x9E)   receive flags      (0xA9)  SysEx
;
;   and this block, which runs in the foreground, keeps its own private trio
;
;       (0x0960) running status      (0x0963) flags              (0x0964) SysEx
;
;   used the same way, bit for bit: bit 6 of the flag byte is "a first data
;   byte is pending", bit 1 goes with it, and both are cleared with the same
;   `and ...,0xbd` mask that MIDI_RX_Byte uses on (0x9E).  Each machine even has
;   its own eight-entry status-nibble jump table.  The division of labour is
;   that the interrupt side takes bytes off the UART and packs them into a
;   queue; this side takes them out again and turns each complete message into
;   an application event.
;
;   ⚠ ONE DELIBERATE DIFFERENCE, and it is worth knowing before trusting either
;   table: the interrupt side's table sends Polyphonic Key Pressure to a bare
;   RET (see MIDI_StatusDispatch_Table), while THIS table treats it like every
;   other two-data-byte message.  The foreground code is willing to handle it;
;   the interrupt code never lets it through.  So "the WSA1 ignores Poly Key
;   Pressure" is a statement about the interrupt parser, which is where it is
;   decided, and this table is not evidence against it.
;
; ⚠ WHICH QUEUE.  This block drains through prom_b 0xF41D18 and posts through
; prom_b 0xF41DD4 and 0xF41B18.  MIDI_TX_Ready drains the OUTPUT queue through
; a different routine, 0xF41DF0, and the interrupt parser fills through
; 0xF41DAC.  Nothing converted here proves 0xF41D18 and 0xF41DAC are the two
; ends of one queue -- they are in prom_b, another lane -- so this block is
; named for what it demonstrably does (drain a queue and dispatch) and not for
; the direction.
;
; ---------------------------------------------------------------------
; MIDI_DrainQueue -- take messages out of the queue until it is empty
;
; Called from: not traced.  ⚠ notes/prom_a_xref.py finds no absolute reference
;          to 0xFA5942 in either image; a `calr` would be invisible to it.
; Inputs:  the queue behind prom_b 0xF41D18, which returns 0xFFFF when empty
; Outputs: every byte dispatched; HL and DE preserved
; Evidence: the same three-way split on the byte as MIDI_RX_Byte --
;            bit 7 clear   -> MIDI_Fg_DataByte
;            0x80-0xF7     -> handled inline: it becomes (0x0960), the
;                             foreground running status
;            0xF8-0xFF     -> MIDI_Fg_RealTime
;          and the loop only ends on 0xFFFF.
; Notes:   the 0x80-0xF7 arm is guarded by BOTH bits 0 and 1 of (0x0964): a
;          status byte is only acted on further while a SysEx is open.  0xF7
;          (END OF EXCLUSIVE) then closes it through prom_b 0xF41EA8 and leaves
;          (0x0964) = 4; any other status abandons it with (0x0964) = 0.  Either
;          way (0x0960) is cleared, so a status byte never becomes running
;          status for the SysEx path.
; Unknown:  ⚠ what (0x0964) = 4 means to whoever reads it.
; ---------------------------------------------------------------------
MIDI_DrainQueue:
	pushw hl                                      ; FA5942  2b
	pushw de                                      ; FA5943  2a
MIDI_DrainQueue__next:
	call T_Ring60195A_Get                         ; FA5944  1d 18 1d f4   take one byte; 0xFFFF = empty
	ld DE,WA                                      ; FA5948  d8 8a
	cp WA,0xffff                                  ; FA594A  d8 cf ff ff
	jr z, MIDI_DrainQueue__done                   ; FA594E  66 58
	ld H,A                                        ; FA5950  c9 8e
	and A,0x80                                    ; FA5952  c9 cc 80
	jr z, MIDI_DrainQueue__data                   ; FA5955  66 46   bit 7 clear = a data byte
	cp H,0xf7                                     ; FA5957  ce cf f7
	jr ule, MIDI_DrainQueue__status               ; FA595A  63 0a   0x80-0xF7
	ld C,H                                        ; FA595C  ce 8b   0xF8-0xFF = System Real Time
	extz BC                                       ; FA595E  d9 12
	pushw bc                                      ; FA5960  29
	calr MIDI_Fg_RealTime                         ; FA5961  1e 47 00
	jr MIDI_DrainQueue__pop                       ; FA5964  68 3f
MIDI_DrainQueue__status:
	ld (MIDI_Fg_RunningStatus:16), h                            ; FA5966  f1 60 09 46   the foreground running status
	and	(MIDI_Fg_Flags:16), 0xbd                     ; FA596A  c1 63 09 3c bd   clear bits 6 and 1
	bit	0, (MIDI_Fg_SysExState:16)                        ; FA596F  f1 64 09 c8   a SysEx armed?
	jr z, MIDI_DrainQueue__next                   ; FA5973  66 cf
	bit	1, (MIDI_Fg_SysExState:16)                        ; FA5975  f1 64 09 c9   and accepted?
	jr z, MIDI_DrainQueue__next                   ; FA5979  66 c9
	cp H,0xf7                                     ; FA597B  ce cf f7   END OF EXCLUSIVE?
	jr nz, MIDI_DrainQueue__abandon               ; FA597E  6e 11
	ld C,H                                        ; FA5980  ce 8b
	extz BC                                       ; FA5982  d9 12
	pushw bc                                      ; FA5984  29
	call T_Ring601C6E_Put                         ; FA5985  1d a8 1e f4   close the SysEx
	ld (MIDI_Fg_SysExState:16), 0x04                          ; FA5989  f1 64 09 00 04
	popw bc                                       ; FA598E  49
	jr MIDI_DrainQueue__clearstatus               ; FA598F  68 05
MIDI_DrainQueue__abandon:
	ld (MIDI_Fg_SysExState:16), 0x00                          ; FA5991  f1 64 09 00 00   any other status abandons it
MIDI_DrainQueue__clearstatus:
	ld (MIDI_Fg_RunningStatus:16), 0x00                          ; FA5996  f1 60 09 00 00
	jr MIDI_DrainQueue__next                      ; FA599B  68 a7
MIDI_DrainQueue__data:
	ld C,H                                        ; FA599D  ce 8b
	extz BC                                       ; FA599F  d9 12
	pushw bc                                      ; FA59A1  29
	calr MIDI_Fg_DataByte                         ; FA59A2  1e 55 00
MIDI_DrainQueue__pop:
	popw bc                                       ; FA59A5  49
	jr MIDI_DrainQueue__next                      ; FA59A6  68 9c
MIDI_DrainQueue__done:
	popw de                                       ; FA59A8  4a
	popw hl                                       ; FA59A9  4b
	ret                                           ; FA59AA  0e

; ---------------------------------------------------------------------
; MIDI_Fg_RealTime -- a System Real Time byte reached the foreground
;
; Called from: MIDI_DrainQueue 0xFA5961, with the byte as a 16-bit stack argument
; Inputs:  the byte at (XIZ+0x08); (0x0922), a transport flag byte
; Outputs: for 0xFA / 0xFB, bit 1 of (0x0922) is updated and a four-argument
;          message is posted through prom_b 0xF41B18; for 0xFF, bit 5 of (0x9E)
;          is set; every other real-time byte is ignored here.
; Evidence: three explicit compares -- 0xFA, 0xFB, 0xFF -- and a fall-through
;          that does nothing.  0xFA is MIDI START and 0xFB is CONTINUE, and the
;          two arms differ ONLY in `res 1,H` versus `set 1,H`, so bit 1 of
;          (0x0922) is "this transport run was resumed rather than started".
;          0xFC STOP, 0xF8 TIMING CLOCK and 0xFE ACTIVE SENSING are NOT handled
;          here -- the interrupt-side handler at 0xFA5504 already deals with
;          them.
; Notes:   ★ AND A CORRECTION THAT CROSSES ROUTINES.  0xFF is SYSTEM RESET, and
;          this arm sets bit 5 of (0x9E).  That is the SAME bit INTT1_Tick sets
;          when the active-sensing timeout expires -- at 0xF82D30 it does
;          `and A,0x7f` then `or A,0x20` and writes A back to (0x9E) at
;          0xF82D4A, a read-modify-write rather than a `set` instruction, which
;          is why a census of `set 5,(0x9e)` finds only THIS site.
;          Two independent events set it, so bit 5 is not "active sensing timed
;          out": it is the condition both of them mean, i.e. "the link has gone
;          away, treat everything as reset".  Neither writer alone shows that.
;          The posted message is `(0xA8, 0x10, flags, 2)` pushed in that order
;          --  ⚠ two of those four are bare constants whose meaning is not
;          established, and 0xF41B18 is in prom_b.
; Unknown:  (0x0922) beyond bit 1; the two constants; who reads the message.
; ---------------------------------------------------------------------
MIDI_Fg_RealTime:
	link XIZ,0x0000                               ; FA59AB  ee 0c 00 00
	pushw hl                                      ; FA59AF  2b
	push XIX                                      ; FA59B0  3c
	lda xix, (0x0922:16)                         ; FA59B1  f1 22 09 34   XIX = &(0x0922)
	ld BC,(XIZ+0x08)                              ; FA59B5  9e 08 21   the byte
	extz BC                                       ; FA59B8  d9 12
	cp BC,0x00fa                                  ; FA59BA  d9 cf fa 00   START
	jr z, MIDI_Fg_RealTime__start                 ; FA59BE  66 0e
	cp BC,0x00fb                                  ; FA59C0  d9 cf fb 00   CONTINUE
	jr z, MIDI_Fg_RealTime__continue              ; FA59C4  66 0f
	cp BC,0x00ff                                  ; FA59C6  d9 cf ff 00   SYSTEM RESET
	jr z, MIDI_Fg_RealTime__reset                 ; FA59CA  66 26
	jr MIDI_Fg_RealTime__ret                      ; FA59CC  68 27   anything else: ignored here
MIDI_Fg_RealTime__start:
	ld H,(XIX)                                    ; FA59CE  84 26
	res 0x01,H                                    ; FA59D0  ce 30 01   started, not resumed
	jr MIDI_Fg_RealTime__post                     ; FA59D3  68 05
MIDI_Fg_RealTime__continue:
	ld H,(XIX)                                    ; FA59D5  84 26
	set 0x01,H                                    ; FA59D7  ce 31 01   resumed
MIDI_Fg_RealTime__post:
	ld (XIX),H                                    ; FA59DA  b4 46
	pushw 0x02                                    ; FA59DC  0b 02 00
	ld C,H                                        ; FA59DF  ce 8b
	extz BC                                       ; FA59E1  d9 12
	pushw bc                                      ; FA59E3  29
	pushw 0x10                                    ; FA59E4  0b 10 00
	pushw 0xa8                                    ; FA59E7  0b a8 00
	call T_PendingEventQueue_AppendStackArgs                                 ; FA59EA  1d 18 1b f4
	inc 8,XSP                                     ; FA59EE  ef 60
	jr MIDI_Fg_RealTime__ret                      ; FA59F0  68 03
MIDI_Fg_RealTime__reset:
	set	5, (MIDI_RX_Flags:8)                            ; FA59F2  f0 9e bd   see the ★ note above
MIDI_Fg_RealTime__ret:
	pop XIX                                       ; FA59F5  5c
	popw hl                                       ; FA59F6  4b
	unlk XIZ                                      ; FA59F7  ee 0d
	ret                                           ; FA59F9  0e

; ---------------------------------------------------------------------
; MIDI_Fg_DataByte -- a data byte reached the foreground
;
; Called from: MIDI_DrainQueue 0xFA59A2, with the byte as a stack argument
; Inputs:  (0x0964) SysEx state, (0x0963) flags, (0x0960) running status
; Outputs: the byte routed to one of four places
; Evidence: the priority order is the interrupt parser's, one for one:
;            (0x0964) bit 0 -- a SysEx is open   -> 0xFA5B3D
;            (0x0963) bit 6 -- a byte is pending -> MIDI_Fg_Deliver3
;            (0x0960) == 0  -- no running status -> return
;            otherwise indexed through MIDI_Fg_LengthTable
; Notes:   the index is built differently from the interrupt side's and is
;          bounds-checked rather than masked: `and C,0x70` then `srl 4` gives
;          0..7 directly, `cp BC,7` / `jr ugt` rejects anything above 7, and
;          only then is it scaled by 4.  Same eight slots, belt and braces.
; ---------------------------------------------------------------------
MIDI_Fg_DataByte:
	link XIZ,0x0000                               ; FA59FA  ee 0c 00 00
	pushw hl                                      ; FA59FE  2b
	ld H,(XIZ+0x08)                               ; FA59FF  8e 08 26
	bit	0, (MIDI_Fg_SysExState:16)                        ; FA5A02  f1 64 09 c8   inside a SysEx?
	jr z, .LFA5A12                                ; FA5A06  66 0a
	ld C,H                                        ; FA5A08  ce 8b
	extz BC                                       ; FA5A0A  d9 12
	pushw bc                                      ; FA5A0C  29
	calr MIDI_Fg_SysExData                    ; FA5A0D  1e 2d 01   MIDI_Fg_SysExData
	jr MIDI_Fg_DataByte__pop                      ; FA5A10  68 5e
.LFA5A12:
	bit	6, (MIDI_Fg_Flags:16)                        ; FA5A12  f1 63 09 ce   a first data byte pending?
	jr z, .LFA5A22                                ; FA5A16  66 0a
	ld C,H                                        ; FA5A18  ce 8b
	extz BC                                       ; FA5A1A  d9 12
	pushw bc                                      ; FA5A1C  29
	calr MIDI_Fg_Deliver3                         ; FA5A1D  1e 9e 00
	jr MIDI_Fg_DataByte__pop                      ; FA5A20  68 4e
.LFA5A22:
	cp	(MIDI_Fg_RunningStatus:16), 0x00                     ; FA5A22  c1 60 09 3f 00   no running status?
	jr z, MIDI_Fg_DataByte__ret                   ; FA5A27  66 5e
	ld c, (MIDI_Fg_RunningStatus:16)                            ; FA5A29  c1 60 09 23
	and C,0x70                                    ; FA5A2D  cb cc 70
	srl c, 0x04                                   ; FA5A30  cb ef 04   the status nibble, 0..7
	extz BC                                       ; FA5A33  d9 12
	extz XBC                                      ; FA5A35  e9 12
	cp bc, 0x07:i3                                  ; FA5A37  d9 df
	jr ugt, MIDI_Fg_DataByte__ret                 ; FA5A39  6b 4c   an explicit bound on the table
	sll bc, 0x02                                  ; FA5A3B  d9 ee 02   * 4
	add XBC,MIDI_Fg_LengthTable                   ; FA5A3E  e9 c8 48 5a fa 00
	ld XBC,(XBC)                                  ; FA5A44  a1 21
	jp (xbc)                                      ; FA5A46  b1 d8

; ---------------------------------------------------------------------
; MIDI_Fg_LengthTable -- eight LE32 handlers, the foreground's copy
;
; Called from: MIDI_Fg_DataByte 0xFA5A46
; Layout:  8 entries x 4 bytes = 32 bytes, 0xFA5A48-0xFA5A67.  The count is not
;          inferred: 0xFA5A37 compares the index against 7 and rejects anything
;          greater BEFORE the scale by 4, so eight is the table's declared size.
; Evidence: the grouping is the MIDI data-byte count again --
;            0 0x8n Note Off          -> MIDI_Fg_Await   (two data bytes)
;            1 0x9n Note On           -> MIDI_Fg_Await
;            2 0xAn Poly Key Pressure -> MIDI_Fg_Await   <-- handled here!
;            3 0xBn Control Change    -> MIDI_Fg_Await
;            4 0xCn Program Change    -> MIDI_Fg_Emit2   (one data byte)
;            5 0xDn Channel Pressure  -> MIDI_Fg_Emit2
;            6 0xEn Pitch Bend        -> MIDI_Fg_Await
;            7 0xFn System            -> MIDI_Fg_SystemCommon
;          ⚠ slot 2 differs from the interrupt side's table, which sends Poly
;          Key Pressure to a bare RET.  See this block's header: the discard
;          happens in the interrupt parser, so nothing ever reaches slot 2.
; ---------------------------------------------------------------------
MIDI_Fg_LengthTable:
	.long MIDI_Fg_Await	; FA5A48  73 5a fa 00   0x8n Note Off
	.long MIDI_Fg_Await	; FA5A4C  73 5a fa 00   0x9n Note On
	.long MIDI_Fg_Await	; FA5A50  73 5a fa 00   0xAn Poly Key Pressure
	.long MIDI_Fg_Await	; FA5A54  73 5a fa 00   0xBn Control Change
	.long MIDI_Fg_Emit2	; FA5A58  68 5a fa 00   0xCn Program Change
	.long MIDI_Fg_Emit2	; FA5A5C  68 5a fa 00   0xDn Channel Pressure
	.long MIDI_Fg_Await	; FA5A60  73 5a fa 00   0xEn Pitch Bend
	.long MIDI_Fg_System	; FA5A64  7d 5a fa 00   0xFn System

MIDI_Fg_Emit2:
	ld C,H                                        ; FA5A68  ce 8b
	extz BC                                       ; FA5A6A  d9 12
	pushw bc                                      ; FA5A6C  29
	calr MIDI_Fg_Deliver2                         ; FA5A6D  1e 1b 00
MIDI_Fg_DataByte__pop:
	popw bc                                       ; FA5A70  49
	jr MIDI_Fg_DataByte__ret                      ; FA5A71  68 14
MIDI_Fg_Await:
	ld C,H                                        ; FA5A73  ce 8b
	extz BC                                       ; FA5A75  d9 12
	pushw bc                                      ; FA5A77  29
	calr MIDI_Fg_StashFirstData                   ; FA5A78  1e 33 00
	jr MIDI_Fg_DataByte__pop                      ; FA5A7B  68 f3
MIDI_Fg_System:
	ld C,H                                        ; FA5A7D  ce 8b
	extz BC                                       ; FA5A7F  d9 12
	pushw bc                                      ; FA5A81  29
	calr MIDI_Fg_SystemCommon                    ; FA5A82  1e 66 00   MIDI_Fg_SystemCommon
	jr MIDI_Fg_DataByte__pop                      ; FA5A85  68 e9
MIDI_Fg_DataByte__ret:
	popw hl                                       ; FA5A87  4b
	unlk XIZ                                      ; FA5A88  ee 0d
	ret                                           ; FA5A8A  0e

; ---------------------------------------------------------------------
; MIDI_Fg_Deliver2 -- post a two-byte message: {running status, data}
;
; Called from: MIDI_Fg_Emit2 0xFA5A6D
; Inputs:  the data byte as a stack argument; (0x0960) the running status
; Outputs: a 2-byte buffer on this frame is filled and handed to prom_b
;          0xF41DD4 with a length of 2
; Evidence: `link XIZ,0xfffe` reserves exactly TWO bytes and `push 0x0002` is
;          the length passed -- the frame size and the length argument agree,
;          which is what makes this a message builder rather than a copy.
; Notes:   ★ it calls PanelLed_ToggleActivityLed_SaveRegs (0xFA5935) on the buffer address before filling
;          it.  That routine's header used to say no caller had been found; this
;          site and 0xFA5AC6 are its two callers, both `calr`, which is why
;          notes/prom_a_xref.py could not see them.
; ---------------------------------------------------------------------
MIDI_Fg_Deliver2:
	link XIZ,0xfffe                               ; FA5A8B  ee 0c fe ff   two bytes of frame
	push XIX                                      ; FA5A8F  3c
	lda xix, (xiz-2)                              ; FA5A90  be fe 34
	calr PanelLed_ToggleActivityLed_SaveRegs                    ; FA5A93  1e 9f fe   PanelLed_ToggleActivityLed_SaveRegs
	ld	(xix), (MIDI_Fg_RunningStatus)                       ; FA5A96  b4 14 60 09   buffer[0] = running status
	ld C,(XIZ+0x08)                               ; FA5A9A  8e 08 23
	ld (XIX+0x01),C                               ; FA5A9D  bc 01 43   buffer[1] = the data byte
	push XIX                                      ; FA5AA0  3c
	pushw 0x02                                    ; FA5AA1  0b 02 00   length 2
	call T_MidiInBRing_PutBlock                    ; FA5AA4  1d d4 1d f4
	inc 6,XSP                                     ; FA5AA8  ef 66
	pop XIX                                       ; FA5AAA  5c
	unlk XIZ                                      ; FA5AAB  ee 0d
	ret                                           ; FA5AAD  0e

; ---------------------------------------------------------------------
; MIDI_Fg_StashFirstData -- remember the first of two data bytes
;
; Called from: MIDI_Fg_Await 0xFA5A78
; Outputs: (0x0961) = the byte, and bit 6 of (0x0963) set so the NEXT data byte
;          takes MIDI_Fg_Deliver3
; Evidence: the two stores ARE the name -- `set 6,(0x0963)` at 0xFA5AB2 and the
;          mem-to-mem `ld (0x0961),(XIZ+0x08)` at 0xFA5AB6 -- and bit 6 of
;          (0x0963) is the flag the foreground parser tests to route the next
;          data byte, exactly as bit 6 of (0x9E) does in the interrupt parser.
;          The parallel with MIDI_RX_AwaitSecondByte is the reading in Notes,
;          not part of the evidence.
; Notes:   the foreground counterpart of MIDI_RX_AwaitSecondByte, which stashes
;          in C and sets bit 6 of (0x9E).  This one has to use RAM instead of a
;          register because, unlike the interrupt parser, it has no persistent
;          register context.
; ---------------------------------------------------------------------
MIDI_Fg_StashFirstData:
	link XIZ,0x0000                               ; FA5AAE  ee 0c 00 00
	set	6, (MIDI_Fg_Flags:16)                        ; FA5AB2  f1 63 09 be
	ld (MIDI_Fg_FirstData),(xiz+0x08)                        ; FA5AB6  8e 08 19 61 09   ld (0x0961),(XIZ+0x08)
	unlk XIZ                                      ; FA5ABB  ee 0d
	ret                                           ; FA5ABD  0e

; ---------------------------------------------------------------------
; MIDI_Fg_Deliver3 -- post a three-byte message: {status, data1, data2}
;
; Called from: MIDI_Fg_DataByte 0xFA5A1D
; Inputs:  the second data byte as a stack argument; (0x0960) status,
;          (0x0961) the first data byte
; Outputs: a 3-byte buffer handed to prom_b 0xF41DD4 with a length of 3, and
;          bits 6 and 1 of (0x0963) cleared
; Evidence: `link XIZ,0xfffc` reserves four bytes for a three-byte message and
;          `push 0x0003` is the length -- the same builder as MIDI_Fg_Deliver2
;          with one more field.  The trailing `and (0x0963),0xbd` is the same
;          mask MIDI_DrainQueue and MIDI_RX_Byte use.
; ---------------------------------------------------------------------
MIDI_Fg_Deliver3:
	link XIZ,0xfffc                               ; FA5ABE  ee 0c fc ff
	push XIX                                      ; FA5AC2  3c
	lda xix, (xiz-4)                              ; FA5AC3  be fc 34
	calr PanelLed_ToggleActivityLed_SaveRegs                    ; FA5AC6  1e 6c fe   PanelLed_ToggleActivityLed_SaveRegs
	ld	(xix), (MIDI_Fg_RunningStatus)                       ; FA5AC9  b4 14 60 09   buffer[0] = status
	ld	(xix+1), (MIDI_Fg_FirstData)                     ; FA5ACD  bc 01 14 61 09   buffer[1] = first data byte
	ld C,(XIZ+0x08)                               ; FA5AD2  8e 08 23
	ld (XIX+0x02),C                               ; FA5AD5  bc 02 43   buffer[2] = second data byte
	push XIX                                      ; FA5AD8  3c
	pushw 0x03                                    ; FA5AD9  0b 03 00   length 3
	call T_MidiInBRing_PutBlock                    ; FA5ADC  1d d4 1d f4
	and	(MIDI_Fg_Flags:16), 0xbd                     ; FA5AE0  c1 63 09 3c bd
	inc 6,XSP                                     ; FA5AE5  ef 66
	pop XIX                                       ; FA5AE7  5c
	unlk XIZ                                      ; FA5AE8  ee 0d
	ret                                           ; FA5AEA  0e
; ==== 0xFA5AEB-0xFAA000 -- emitted by notes/gen_prom_a_fa5aeb_module.py ====
; Layout from notes/prom_a_fa5aeb_layout.py; names and counts from this
; emitter's --selftest (67 checks).  Run it before trusting any number in a
; header below.  This text was assembled and byte-compared with the ROM
; before printing.
;
; ⚠ SPLICING THIS REGION BREAKS THREE OF prom_a_fa5aeb_layout.py's OWN 123
; CHECKS, and none of them is a defect in the layout: `branches whose
; destination the .s states` pins 10037 and now reads 10588 because this
; region added its own relative branches to the corpus, and `residue runs`
; / `residue bytes` pin 1 and 14 and now read 3 and 108 because that file's
; build() seeds its descent from the .s and therefore now reads this text.
; This emitter neutralises that by dropping the relative targets whose citing
; instruction is inside the span (see _rel_targets_outside_span), which is
; why its own layout is still 42 segments and its residue still 1 run of 14
; bytes.  The three constants in that file need re-pinning by whoever owns it.

; ---------------------------------------------------------------------
; MIDI_Fg_SystemCommon -- the foreground parser's 0xFn System handler
;
; Called from: MIDI_Fg_System 0xFA5A82 (`calr`), and nothing else -- no
;          absolute call or jp in either image names this address, which is
;          why an absolute-site scanner sees this whole span as unreachable.
; Inputs:  (XIZ+0x08) the byte just received; (0x0960) the running status.
; Outputs: for a SysEx opening whose second byte is 0x50 or 0x7E, (0x0964)
;          = 3 and the two bytes {0xF0, that byte} are posted to ring
;          0x601C6E through 0xF41EAC (Ring601C6E_PutBlock).  Every other
;          System Common message falls through to `ld (0x0960),0x00`.
; Evidence: the three literals it tests are 0xF0, 0xF2 and 0xF3 (0xFA5B01,
;          0xFA5B07, 0xFA5B0D) -- SysEx, Song Position and Song Select, the
;          three System Common statuses this machine's interrupt-side
;          MIDI_RX_SystemCommon also singles out.  0x50 is Matsushita's MIDI
;          manufacturer ID and 0x7E the Universal Non-Real-Time ID.
; Note:    the word it loads from MIDI_SysExHeader is 0xF0,0x50; byte 1 is
;          then OVERWRITTEN at 0xFA5B24 with the received byte, so the 0x50
;          in the template is only the expected value, never the sent one.
; ---------------------------------------------------------------------
MIDI_Fg_SystemCommon:
	link XIZ,0xfffe                               ; FA5AEB  ee 0c fe ff
	pushw hl                                      ; FA5AEF  2b   push HL
	ld H,(XIZ+0x08)                               ; FA5AF0  8e 08 26
	ld bc, (MIDI_SysExHeader:24)                         ; FA5AF3  d2 b8 5c fa 21   ld BC,(0xfa5cb8)
	ld (xiz-2), bc                                ; FA5AF8  be fe 51   ld (XIZ+0xfe),BC
	ld wa, (MIDI_Fg_RunningStatus:16)                          ; FA5AFB  d1 60 09 20   ld WA,(0x0960)
	extz WA                                       ; FA5AFF  d8 12
	cp WA,0x00f0                                  ; FA5B01  d8 cf f0 00
	jr z, .LFA5B15                                ; FA5B05  66 0e
	cp WA,0x00f2                                  ; FA5B07  d8 cf f2 00
	jr z, .LFA5B34                                ; FA5B0B  66 27
	cp WA,0x00f3                                  ; FA5B0D  d8 cf f3 00
	jr z, .LFA5B34                                ; FA5B11  66 21
	jr .LFA5B34                                   ; FA5B13  68 1f
.LFA5B15:
	cp H,0x50                                     ; FA5B15  ce cf 50
	jr z, .LFA5B1F                                ; FA5B18  66 05
	cp H,0x7e                                     ; FA5B1A  ce cf 7e
	jr nz, .LFA5B34                               ; FA5B1D  6e 15
.LFA5B1F:
	ld (MIDI_Fg_SysExState:16), 0x03                          ; FA5B1F  f1 64 09 00 03   ld (0x0964),0x03
	ld (xiz-1), h                                 ; FA5B24  be ff 46   ld (XIZ+0xff),H
	lda xbc, (xiz-2)                              ; FA5B27  be fe 31   lda XBC,XIZ+0xfe
	push XBC                                      ; FA5B2A  39
	pushw 0x02                                    ; FA5B2B  0b 02 00   push 0x0002
	call T_Ring601C6E_PutBlock                    ; FA5B2E  1d ac 1e f4
	inc 6,XSP                                     ; FA5B32  ef 66
.LFA5B34:
	ld (MIDI_Fg_RunningStatus:16), 0x00                          ; FA5B34  f1 60 09 00 00   ld (0x0960),0x00
	popw hl                                       ; FA5B39  4b   pop HL
	unlk XIZ                                      ; FA5B3A  ee 0d
	ret                                           ; FA5B3C  0e

; ---------------------------------------------------------------------
; MIDI_Fg_SysExData -- push one SysEx body byte into the receive queue
;
; Called from: MIDI_Fg_DataByte 0xFA5A0D (`calr`), and nothing else.
; Inputs:  (XIZ+0x08) the data byte; (0x0964) bits 1 and 5.
; Outputs: bit 0 of (0x216F) set and the byte posted to ring 0x601C6E via
;          0xF41EA8 (Ring601C6E_Put) -- but only when bit 1 of (0x0964) is
;          set and bit 5 clear.
; Evidence: bit 1 of (0x0964) is the flag MIDI_Fg_SystemCommon sets (it
;          writes the value 3 there) when it accepts a SysEx header, so the
;          gate here is literally `did we accept this SysEx`.  The queue it
;          writes is the same 0x601C6E the header went to.
; ---------------------------------------------------------------------
MIDI_Fg_SysExData:
	link XIZ,0x0000                               ; FA5B3D  ee 0c 00 00
	bit	1, (MIDI_Fg_SysExState:16)                        ; FA5B41  f1 64 09 c9   bit 1,(0x0964)
	jr z, .LFA5B5C                                ; FA5B45  66 15
	bit	5, (MIDI_Fg_SysExState:16)                        ; FA5B47  f1 64 09 cd   bit 5,(0x0964)
	jr nz, .LFA5B5C                               ; FA5B4B  6e 0f
	set	0, (MIDI_ActivityFlags:16)                        ; FA5B4D  f1 6f 21 b8   set 0,(0x216f)
	ld BC,(XIZ+0x08)                              ; FA5B51  9e 08 21
	extz BC                                       ; FA5B54  d9 12
	pushw bc                                      ; FA5B56  29   push BC
	call T_Ring601C6E_Put                         ; FA5B57  1d a8 1e f4
	popw bc                                       ; FA5B5B  49   pop BC
.LFA5B5C:
	unlk XIZ                                      ; FA5B5C  ee 0d
	ret                                           ; FA5B5E  0e

; ---------------------------------------------------------------------
; MIDI_SendBankAndProgram -- transmit Bank Select + Program Change
;
; Called from: prom_b directory slot T_MIDI_SendBankAndProgram (T_F4072C) (`jp 0xFA5B5F`).
; Inputs:  (XIZ+0x08) channel in bits 0-3 and the port select in bit 4;
;          (XIZ+0x0A) the program number; (XIZ+0x0C) a 16-bit bank number,
;          or 0xFFFF for `program change only`.
; Outputs: 7 bytes `Bn 00 <bank>>7> 20 <bank&0x7F> Cn <program>` on the
;          selected port, or just the last 2 when the bank is 0xFFFF.
; Evidence: it `ldir`s the seven bytes of MIDI_BankProgramTemplate
;          (0xFA5CBA = B0 00 00 20 00 C0 00) into the frame, then writes
;          bank>>7 to template byte 2 and bank&0x7F to byte 4 -- exactly the
;          two data slots of CC 0 and CC 32 -- and ORs the channel into
;          bytes 0 and 5, the two status bytes.  `ld DE,0x0002` before the
;          0xFFFF test and `ld DE,0x0007` after it are the two lengths.
; Note:    bit 4 of the first argument picks the destination: clear sends
;          through 0xF41DF8 (Ring601432_PutBlock) and wakes the transmitter
;          with MIDI_PostSendWork; set sends through 0xF40ED4, the block
;          sender that carries port B's stream to the other CPU.
; ---------------------------------------------------------------------
MIDI_SendBankAndProgram:   ; entry: prom_b directory slot T_MIDI_SendBankAndProgram (T_F4072C)
	link XIZ,0xfff4                               ; FA5B5F  ee 0c f4 ff
	pushw hl                                      ; FA5B63  2b   push HL
	pushw de                                      ; FA5B64  2a   push DE
	push XIX                                      ; FA5B65  3c
	ld IX,(XIZ+0x0c)                              ; FA5B66  9e 0c 24
	ld H,(XIZ+0x08)                               ; FA5B69  8e 08 26
	ldw de, 0x02                                  ; FA5B6C  32 02 00   ld DE,0x0002
	push XIX                                      ; FA5B6F  3c
	ldw bc, 0x07                                  ; FA5B70  31 07 00   ld BC,0x0007
	lda xiy, (MIDI_BankProgramTemplate:24)        ; FA5B73  f2 ba 5c fa 35   lda XIY,0xfa5cba
	lda xix, (xiz-7)                              ; FA5B78  be f9 34   lda XIX,XIZ+0xf9
	ldir85                                        ; FA5B7B  85 11   ldir
	pop XIX                                       ; FA5B7D  5c
	lda xbc, (xiz-7)                              ; FA5B7E  be f9 31   lda XBC,XIZ+0xf9
	inc 5,XBC                                     ; FA5B81  e9 65
	ld (xiz-12), xbc                              ; FA5B83  be f4 61   ld (XIZ+0xf4),XBC
	cp IX,0xffff                                  ; FA5B86  dc cf ff ff
	jr z, .LFA5BAE                                ; FA5B8A  66 22
	ld A,H                                        ; FA5B8C  ce 89
	and A,0x0f                                    ; FA5B8E  c9 cc 0f
	or (xiz-7), a                                 ; FA5B91  8e f9 e9   or (XIZ+0xf9),A
	ld BC,IX                                      ; FA5B94  dc 89
	sra bc, 0x07                                  ; FA5B96  d9 ed 07   sra 0x07,BC
	ld (xiz-5), c                                 ; FA5B99  be fb 43   ld (XIZ+0xfb),C
	ld_erpb_rr c, 0xf0                            ; FA5B9C  c7 f0 8b   ld C,IXL
	res 0x07,C                                    ; FA5B9F  cb 30 07
	ld (xiz-3), c                                 ; FA5BA2  be fd 43   ld (XIZ+0xfd),C
	ldw de, 0x07                                  ; FA5BA5  32 07 00   ld DE,0x0007
	lda xbc, (xiz-7)                              ; FA5BA8  be f9 31   lda XBC,XIZ+0xf9
	ld (xiz-12), xbc                              ; FA5BAB  be f4 61   ld (XIZ+0xf4),XBC
.LFA5BAE:
	ld C,H                                        ; FA5BAE  ce 8b
	and C,0x0f                                    ; FA5BB0  cb cc 0f
	or (xiz-2), c                                 ; FA5BB3  8e fe eb   or (XIZ+0xfe),C
	ld C,(XIZ+0x0a)                               ; FA5BB6  8e 0a 23
	res 0x07,C                                    ; FA5BB9  cb 30 07
	ld (xiz-1), c                                 ; FA5BBC  be ff 43   ld (XIZ+0xff),C
	ld C,H                                        ; FA5BBF  ce 8b
	and C,0x10                                    ; FA5BC1  cb cc 10
	jr nz, .LFA5BDE                               ; FA5BC4  6e 18
	ei 0x06                                       ; FA5BC6  06 06
	ld xbc, (xiz-12)                              ; FA5BC8  ae f4 21   ld XBC,(XIZ+0xf4)
	push XBC                                      ; FA5BCB  39
	pushw de                                      ; FA5BCC  2a   push DE
	call T_Ring601432_PutBlock                    ; FA5BCD  1d f8 1d f4
	call MIDI_PostSendWork                                 ; FA5BD1  1d 0f 59 fa
	inc 6,XSP                                     ; FA5BD5  ef 66
	ei 0x00                                       ; FA5BD7  06 00
	ld (0x9b:8), 0x00:io                               ; FA5BD9  08 9b 00   ld (0x9b),0x00
	jr .LFA5BF1                                   ; FA5BDC  68 13
.LFA5BDE:
	ld xbc, (xiz-12)                              ; FA5BDE  ae f4 21   ld XBC,(XIZ+0xf4)
	push XBC                                      ; FA5BE1  39
	pushw de                                      ; FA5BE2  2a   push DE
	pushw 0x02                                    ; FA5BE3  0b 02 00   push 0x0002
	call T_Link_SendBlockIn32ByteChunks                                 ; FA5BE6  1d d4 0e f4
	ld (0x091f:16), 0x00                          ; FA5BEA  f1 1f 09 00 00   ld (0x091f),0x00
	inc 8,XSP                                     ; FA5BEF  ef 60
.LFA5BF1:
	pop XIX                                       ; FA5BF1  5c
	popw de                                       ; FA5BF2  4a   pop DE
	popw hl                                       ; FA5BF3  4b   pop HL
	unlk XIZ                                      ; FA5BF4  ee 0d
	ret                                           ; FA5BF6  0e

; ---------------------------------------------------------------------
; MIDI_SendStart_PortB -- put the single byte 0xFA on port B
;
; Called from: MIDI_Reset 0xFA58C4, its only call site in either image.
; Outputs: one byte, 0xFA, handed to 0xF40ED4 with length 1 and stream 2.
; Evidence: the only byte it builds is the immediate 0xFA at 0xFA5BFB and
;          `push 0x0001` at 0xFA5C03 is the length.  0xFA is MIDI System
;          Real Time START, and the stream it goes to is the same one
;          MIDI_SendAllNotesOff_AllChannels uses for `Bn 7B 00 79 00`, so
;          the stream carries MIDI bytes rather than commands.
; Unknown: ⚠ that the far end acts on it AS a MIDI Start is inference. What
;          is proven is the byte, the length and the stream.
; ---------------------------------------------------------------------
MIDI_SendStart_PortB:
	link XIZ,0xffff                               ; FA5BF7  ee 0c ff ff
	ld (xiz-1), 0xfa                              ; FA5BFB  be ff 00 fa   ld (XIZ+0xff),0xfa
	lda xbc, (xiz-1)                              ; FA5BFF  be ff 31   lda XBC,XIZ+0xff
	push XBC                                      ; FA5C02  39
	pushw 0x01                                    ; FA5C03  0b 01 00   push 0x0001
	pushw 0x02                                    ; FA5C06  0b 02 00   push 0x0002
	call T_Link_SendBlockIn32ByteChunks                                 ; FA5C09  1d d4 0e f4
	inc 8,XSP                                     ; FA5C0D  ef 60
	unlk XIZ                                      ; FA5C0F  ee 0d
	ret                                           ; FA5C11  0e

; ---------------------------------------------------------------------
; MIDI_PostSendWork_PortB -- drain port B's queue and forward it
;
; Called from: prom_b directory slot T_MIDI_PostSendWork_PortB (T_F40730) (`jp 0xFA5C12`).
; Outputs: every byte ring 0x60153C will give up, copied into a 256-byte
;          stack buffer and handed to 0xF40ED4 as one block, stream 2.
; Evidence: it loops on 0xF41E14 (Ring60153C_Get) until that returns
;          0xFFFF, and 0x60153C is the ring 0xF41E1C (Ring60153C_PutBlock)
;          fills.  It is the port-B twin of MIDI_PostSendWork: the pair
;          appears at 0xFA7D26/0xFA7D32 as `ld XIX,0x00F40724` (that
;          routine) versus `ld XIX,0x00F40730` (this one), selected by
;          `cp (0x194B),0x00` -- the same byte that selects between
;          Ring601432_PutBlock and Ring60153C_PutBlock ten instructions
;          earlier.
; ---------------------------------------------------------------------
MIDI_PostSendWork_PortB:   ; entry: prom_b directory slot T_MIDI_PostSendWork_PortB (T_F40730)
	link XIZ,0xfefe                               ; FA5C12  ee 0c fe fe
	pushw hl                                      ; FA5C16  2b   push HL
	pushw de                                      ; FA5C17  2a   push DE
	ldw de, 0x00                                  ; FA5C18  32 00 00   ld DE,0x0000
.LFA5C1B:
	call T_Ring60153C_Get                         ; FA5C1B  1d 14 1e f4
	ld HL,WA                                      ; FA5C1F  d8 8b
	cp WA,0xffff                                  ; FA5C21  d8 cf ff ff
	jr z, .LFA5C3B                                ; FA5C25  66 14
	ld (xiz-258), a                               ; FA5C27  f3 f9 fe fe 41   ld (XIZ+0xfefe),A
	ld BC,DE                                      ; FA5C2C  da 89
	extz XBC                                      ; FA5C2E  e9 12
	add XBC,XIZ                                   ; FA5C30  ee 81
	ld (xbc-256), a                               ; FA5C32  f3 e5 00 ff 41   ld (XBC+0xff00),A
	inc 1,DE                                      ; FA5C37  da 61
	jr .LFA5C1B                                   ; FA5C39  68 e0
.LFA5C3B:
	push SR                                       ; FA5C3B  02
	ei 0x00                                       ; FA5C3C  06 00
	lda xbc, (xiz-256)                            ; FA5C3E  f3 f9 00 ff 31   lda XBC,XIZ+0xff00
	push XBC                                      ; FA5C43  39
	pushw de                                      ; FA5C44  2a   push DE
	pushw 0x02                                    ; FA5C45  0b 02 00   push 0x0002
	call T_Link_SendBlockIn32ByteChunks                                 ; FA5C48  1d d4 0e f4
	inc 8,XSP                                     ; FA5C4C  ef 60
	pop SR                                        ; FA5C4E  03
	popw de                                       ; FA5C4F  4a   pop DE
	popw hl                                       ; FA5C50  4b   pop HL
	unlk XIZ                                      ; FA5C51  ee 0d
	ret                                           ; FA5C53  0e

; ---------------------------------------------------------------------
; MIDI_SendAllNotesOff_AllChannels -- CC 123 + CC 121 on all 16 channels,
; both ports
;
; Called from: prom_b directory slot T_MIDI_SendAllNotesOff_AllChannels (T_F40734) (`jp 0xFA5C54`).
; Outputs: `Bn 7B 00 79 00` for n = 0..0x0F, first through 0xF41DF8
;          (Ring601432_PutBlock, port A) with MIDI_PostSendWork after each,
;          then again through 0xF40ED4 (port B).  Finally (0x9B) and
;          (0x091F), the two transmitter mailboxes, are cleared.
; Evidence: MIDI_AllNotesOffTemplate at 0xFA5CC1 is B0 7B 00 79 00 -- CC
;          123 All Notes Off followed, under running status, by CC 121 Reset
;          All Controllers.  The two loops both run `ld H,0x00` .. `cp
;          H,0x0F / jr ULE`, and `or C,0xB0` builds the status byte.
; ---------------------------------------------------------------------
MIDI_SendAllNotesOff_AllChannels:   ; entry: prom_b directory slot T_MIDI_SendAllNotesOff_AllChannels (T_F40734)
	link XIZ,0xfffb                               ; FA5C54  ee 0c fb ff
	pushw hl                                      ; FA5C58  2b   push HL
	push XIX                                      ; FA5C59  3c
	lda xix, (xiz-5)                              ; FA5C5A  be fb 34   lda XIX,XIZ+0xfb
	push XIX                                      ; FA5C5D  3c
	ldw bc, 0x05                                  ; FA5C5E  31 05 00   ld BC,0x0005
	lda xiy, (MIDI_AllNotesOffTemplate:24)        ; FA5C61  f2 c1 5c fa 35   lda XIY,0xfa5cc1
	lda xix, (xiz-5)                              ; FA5C66  be fb 34   lda XIX,XIZ+0xfb
	ldir85                                        ; FA5C69  85 11   ldir
	pop XIX                                       ; FA5C6B  5c
	ld h, 0x00:opc                                   ; FA5C6C  26 00   ld H,0x00
.LFA5C6E:
	ld C,H                                        ; FA5C6E  ce 8b
	or C,0xb0                                     ; FA5C70  cb ce b0
	ld (XIX),C                                    ; FA5C73  b4 43
	ei 0x06                                       ; FA5C75  06 06
	push XIX                                      ; FA5C77  3c
	pushw 0x05                                    ; FA5C78  0b 05 00   push 0x0005
	call T_Ring601432_PutBlock                    ; FA5C7B  1d f8 1d f4
	ei 0x00                                       ; FA5C7F  06 00
	call MIDI_PostSendWork                                 ; FA5C81  1d 0f 59 fa
	inc 1,H                                       ; FA5C85  ce 61
	inc 6,XSP                                     ; FA5C87  ef 66
	cp H,0x0f                                     ; FA5C89  ce cf 0f
	jr ule, .LFA5C6E                              ; FA5C8C  63 e0
	ld h, 0x00:opc                                   ; FA5C8E  26 00   ld H,0x00
.LFA5C90:
	ld C,H                                        ; FA5C90  ce 8b
	or C,0xb0                                     ; FA5C92  cb ce b0
	ld (XIX),C                                    ; FA5C95  b4 43
	push XIX                                      ; FA5C97  3c
	pushw 0x05                                    ; FA5C98  0b 05 00   push 0x0005
	pushw 0x02                                    ; FA5C9B  0b 02 00   push 0x0002
	call T_Link_SendBlockIn32ByteChunks                                 ; FA5C9E  1d d4 0e f4
	inc 1,H                                       ; FA5CA2  ce 61
	inc 8,XSP                                     ; FA5CA4  ef 60
	cp H,0x0f                                     ; FA5CA6  ce cf 0f
	jr ule, .LFA5C90                              ; FA5CA9  63 e5
	ld (0x9b:8), 0x00:io                               ; FA5CAB  08 9b 00   ld (0x9b),0x00
	ld (0x091f:16), 0x00                          ; FA5CAE  f1 1f 09 00 00   ld (0x091f),0x00
	pop XIX                                       ; FA5CB3  5c
	popw hl                                       ; FA5CB4  4b   pop HL
	unlk XIZ                                      ; FA5CB5  ee 0d
	ret                                           ; FA5CB7  0e

; --- 0xFA5CB8-0xFA5CC5  message templates (14 bytes) ---

; ---------------------------------------------------------------------
; MIDI_SysExHeader -- the two bytes F0 50
;
; Read by: MIDI_Fg_SystemCommon 0xFA5AF3 (`ld BC,(0xfa5cb8)`), its only
;          reader.
; Layout:  0xF0 = SysEx status, 0x50 = the Matsushita manufacturer ID.
; Evidence: the two bytes are read as ONE 16-bit word into the outgoing
;          2-byte frame and byte 1 is then overwritten with the received ID,
;          which is why only 0xF0 survives to the wire.
; ---------------------------------------------------------------------
MIDI_SysExHeader:
	.byte 0xf0, 0x50   ; FA5CB8

; ---------------------------------------------------------------------
; MIDI_BankProgramTemplate -- B0 00 00 20 00 C0 00
;
; Read by: MIDI_SendBankAndProgram 0xFA5B73 (`lda XIY,0xfa5cba`), its only
;          reader, with `ld BC,0x0007` + `ldir`.
; Layout:  CC 0 (Bank Select MSB), CC 32 (Bank Select LSB) under running
;          status, then Program Change.  Slots 2 and 4 take the bank halves,
;          slots 0 and 5 take the channel.
; Evidence: the seven bytes and the `ld BC,0x0007` agree; the writes at
;          0xFA5B99 and 0xFA5BA2 land on offsets 2 and 4.
; ---------------------------------------------------------------------
MIDI_BankProgramTemplate:
	.byte 0xb0, 0x00, 0x00, 0x20, 0x00, 0xc0, 0x00   ; FA5CBA

; ---------------------------------------------------------------------
; MIDI_AllNotesOffTemplate -- B0 7B 00 79 00
;
; Read by: MIDI_SendAllNotesOff_AllChannels 0xFA5C61 (`lda XIY,0xfa5cc1`),
;          its only reader, with `ld BC,0x0005` + `ldir`.
; Layout:  CC 123 All Notes Off then, under running status, CC 121 Reset
;          All Controllers.  Byte 0 takes 0xB0 | channel.
; Evidence: five bytes, `ld BC,0x0005`, and `push 0x0005` as the length.
; ★ Together with the two objects above these fourteen bytes are the whole
;   of what notes/prom_a_fa5aeb_layout.py calls THE ONE HOLE (`Decodes, but
;   ... nothing reaches it`).  2 + 7 + 5 = 14 and each has exactly one
;   reader, so the hole is closed.
; ---------------------------------------------------------------------
MIDI_AllNotesOffTemplate:
	.byte 0xb0, 0x7b, 0x00, 0x79, 0x00   ; FA5CC1

; --- 0xFA5CC6-0xFA5FFF  0x0E pad (826 bytes) ---
	.fill 826, 1, 0x0E
