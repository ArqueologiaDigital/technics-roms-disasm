; ==============================================================================
; 0xF89800-0xF89FFF -- the CONTINUOUS-CONTROL NORMALISER
; ==============================================================================
;
; ★★ THIS IS THE ROUTINE emulation gap E asks about.
; kn7000_mame/notes/WSA1-EMULATION-DISASM-GAPS.md, gap E.3: "What does prom_a
; 0xF89800 (reached through thunk 0xF405F0) do with a received byte?  Its carry
; result decides whether the byte is kept, and it is the module's only call out
; of itself."  And notes/FINDINGS-prom_b-sc1-link.md ends its own open-questions
; list with "What would settle it: ... 0xF89800."
;
; WHAT IT IS.  One routine that turns a RAW 8-bit reading of a continuous
; control into a COOKED value through a per-channel response curve, remembers
; the cooked value, and returns CARRY SET only when it changed.  That is why
; every caller is `call T_Ctrl_Normalise (T_F405F0) / jr nc,skip`: the carry means "this control
; actually moved".
;
; THE CHANNEL SELECTOR is in W, the raw reading in A.  The dispatcher builds
;     index = ((W & 0xC0) >> 1) | ((W & 0x07) << 2)
; -- so bits 7-6 are a GROUP and bits 2-0 a CHANNEL, bits 5-3 are ignored, and
; the result is a byte offset into a 32-entry LE32 table.  Ten of the 32 slots
; are live; twenty-one go to Ctrl_ReportUnchanged and one to Ctrl_ReportChanged.
;
; ★ GROUP 0 IS THE ON-BOARD ANALOGUE SCAN, and that is proved by its call sites,
; not inferred: the EIGHT converted calls in AnalogScan (0xF8DC00-0xF8DDE5) pass
; W = 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x04, 0x05 -- four from ADREG0-ADREG3
; and two from (0x600000)/(0x600001) -- which is exactly slots 0.0 to 0.5.
; ⚠ EIGHT sites for SIX channels: 0xF8DDBC-0xF8DDE5 is BYTE-IDENTICAL to
; 0xF8DD4D-0xF8DD76, so AnalogScan carries two copies of the scan routine for
; channel 4 and two for channel 5.  Stated as measured (the two 21-byte runs
; compare equal); nothing here says why.  notes/FINDINGS-prom_a-ring-buffers.md
; already said "all six report through directory slot T_Ctrl_Normalise (T_F405F0)"; this is the
; other end of that sentence.
;
; ★ GROUP 3 IS FOUR MORE CONTROLS OF THE SAME KIND, with their own raw slots
; (0x24E8-0x24EB), their own cooked slots and their own curves.  ⚠ WHO SENDS
; THEM IS NOT ESTABLISHED HERE.  What is established is that prom_b's SC1
; receive decoder calls this same routine twice (prom_b 0xF5B14C and 0xF5B1D6)
; with W taken from a RECEIVED BYTE -- so a control arriving over SC1 and a
; control read from the CPU's own A/D are normalised by one routine, with one
; table of curves, into one bank of cooked values.  Which group SC1's bytes land
; in depends on those bytes and is not read off the ROM.  So the cross-note lead
; gap E flags ("if it is one slot, the analogue controls and the SC1 peer are
; the same board") resolves to: IT IS ONE SLOT, and the two sources share the
; whole normalising path -- but the ROM distinguishes them by group, and that is
; as far as the evidence goes.
;
; THE RAM BANK
;   0x24D0-0x24D5   raw readings, group 0 channels 0-5
;   0x24E8-0x24EB   raw readings, group 3 channels 0-3
;   0x24F2 0x24F3 0x24F4 0x24F5 0x24F6 0x24FF 0x2503 0x2504 0x2505 0x2506
;                   the ten cooked values, one per live slot
;   (0xC4)          a mode byte.  When it is 2, six of the ten handlers skip the
;                   curve entirely and force an IDLE value -- 0x40 for slots 0.0,
;                   0.1 and 3.2, 0x00 for 0.2, 0.3 and 3.0, 0x80 for 3.1 -- and
;                   return carry CLEAR.  Slots 0.4, 0.5 and 3.3 have no such arm.
;                   ⚠ What mode 2 is is not established.
;
; THE CURVES.  Eight tables tile 0xF89AB4-0xF89FBE with no gap:
;
;   0xF89AB4  128  identity 0..127                     slot 3.3
;   0xF89B34  128  a compressed curve, 0..127          slots 0.4, 0.5, 3.2
;   0xF89BB4  128  the same curve, 40 bytes off by ±1  slots 0.0, 0.1
;   0xF89C34  128  BYTE-IDENTICAL to 0xF89AB4          slot 3.0
;   0xF89CB4  256  0..255, indexed by the raw byte     slot 3.1
;   0xF89DB4  128  0..127                              slot 0.3
;   0xF89E34  128  0..127, and NOTHING REFERENCES IT   (see below)
;   0xF89EB4  256  0..255, indexed by the raw byte     slot 0.2
;   0xF89FB4   11  a span table, indexed by (0x7F5F)   slot 0.2's calibration
;
;   Seven of the eight are indexed by `raw >> 1`, so they are 128-entry maps
;   over a 7-bit position; the two 256-entry ones are indexed by the raw byte
;   whole.  ⚠ 0xF89E34 has NO reference: censusing the 4-byte little-endian
;   immediate 0x00F89E34 over prom_a AND prom_b finds zero sites, while the same
;   census finds every other table at exactly the `ld XIX,imm32` that uses it.
;   ⚠ 0xF89BB4 is 0xF89B34 with 40 of its 128 bytes changed by exactly ±1 --
;   21 higher and 19 lower, all of them between indices 37 and 89, the other 88
;   equal.  Two roundings of one curve, not two curves.
;   ⚠ 0xF89B34 and 0xF89BB4 share a single NON-MONOTONE entry at index 20 --
;   0x2C where its neighbours are 0x21 and 0x24.  Recorded as read; nothing here
;   claims it is a defect.
;
; SLOT 0.2 IS THE ONE CALIBRATED CHANNEL.  It reads a two-byte record at
; 0x007F5A: (+6) is subtracted from the curve output with a floor, and (+5)
; indexes the 11-entry span table at 0xF89FB4; the result is
; `((raw_curved - floor) * 0x100 / 0xEC) * span / 0x14`, clamped to 0x7F.
; ⚠ The 11-entry count is the number of non-0x0E bytes before the module's pad;
; the use site does NOT range-check (0x7F5F), so the ROM does not bound it.
;
; Every number above is re-derived by notes/prom_a_ctrl_checks.py.
; ==============================================================================

; ---------------------------------------------------------------------
; Ctrl_Normalise -- the published entry: normalise one control reading
;
; Called from: prom_b thunk slots T_Ctrl_Normalise (T_F405F0) (`jp 0xF89800`) and T_Ctrl_Nop_Ret (T_F405F4)
;          (`jp 0xF89804`).  The eight converted call sites of T_Ctrl_Normalise (T_F405F0) are all
;          in AnalogScan and there are EIGHT of them, not six: 0xF8DC63 (W=0),
;          0xF8DC96 (1), 0xF8DCC9 (2), 0xF8DCFC (3), 0xF8DD54 (4), 0xF8DD69 (5),
;          0xF8DDC3 (4) and 0xF8DDD8 (5) -- the last two inside a byte-identical
;          duplicate of the two routines before them.  prom_b calls it at
;          0xF5B14C and 0xF5B1D6, from the SC1 receive decoder.
; Inputs:  W = the channel selector, A = the raw 8-bit reading.
; Outputs: CARRY SET if the cooked value changed, CLEAR if not; A = the cooked
;          value on the "changed" path.  XHL and XIX are saved by the dispatcher.
; Evidence: the callers are the proof of the convention -- AnalogScan loads
;          `ldb w,0x00` .. `ldb w,0x05` immediately before each call and tests
;          `jr nc` immediately after.
; Unknown:  which W values prom_b's two SC1 sites pass.  They take W from a
;          RECEIVED byte, so the group is whatever the panel sent; no constant
;          is compared against it in either image.
; ---------------------------------------------------------------------
Ctrl_Normalise:
	calr .LF89805                                 ; F89800  1e 02 00
	ret                                           ; F89803  0e

; Ctrl_Nop_Ret -- T_Ctrl_Nop_Ret (T_F405F4)'s target: a bare RET.  Kept as a label because the
; thunk table publishes it separately.
Ctrl_Nop_Ret:
	ret                                           ; F89804  0e

; ---------------------------------------------------------------------
; Ctrl_Normalise_Dispatch -- index = ((W & 0xC0) >> 1) | ((W & 7) << 2)
;
; Called from: Ctrl_Normalise (0xF89800), which is the only site: this label is
;          the target of one `calr` and of nothing else.
; Inputs:  W = the channel selector, A = the raw reading; both are passed
;          through untouched to the handler.
; Outputs: jumps to the handler; XHL and XIX are pushed here and popped by the
;          shared exit at Ctrl__return, so every handler inherits that frame.
; Unknown:  what bits 5-3 of W are for.  The arithmetic drops them and nothing
;          else in either image reads them.
; Evidence: the index is built in four instructions and used as a BYTE offset
;          into an LE32 table, so its maximum, 0x60 | 0x1C = 0x7C, is entry 31 --
;          that is what makes the table 32 entries and not more.  ⚠ There is NO
;          bounds check, and none is needed: the arithmetic cannot exceed 0x7C.
; ---------------------------------------------------------------------
Ctrl_Normalise_Dispatch:
.LF89805:
	push XHL                                      ; F89805  3b
	push XIX                                      ; F89806  3c
	xor HL,HL                                     ; F89807  db d3
	ld L,W                                        ; F89809  c8 8f
	and L,0xc0                                    ; F8980B  cf cc c0
	srl l, 0x01                                   ; F8980E  cf ef 01
	and W,0x07                                    ; F89811  c8 cc 07
	sla w, 0x02                                   ; F89814  c8 ec 02
	or L,W                                        ; F89817  c8 e7
	ld XIX,Ctrl_HandlerTable                      ; F89819  44 25 98 f8 00
	ld	xhl, (xix+hl)                         ; F8981E  e3 07 f0 ec 23
	jp (xhl)                                      ; F89823  b3 d8

; ---------------------------------------------------------------------
; Ctrl_HandlerTable -- 34 LE32 entries.
; The dispatcher can form byte offsets 0x00..0x7C, so entries 0..31 are the
; reachable ones; entries 32 and 33 lie beyond the largest index the
; arithmetic at 0xF89805 can produce and are both the ignore handler.
; Emitted SYMBOLICALLY: if a label below is at the wrong address the byte
; gate fails, so this table checks the names rather than describing them.
;
; Called from: one site -- `ld XIX,0x00F89825` at 0xF89819 followed by the
;          `ld xhl, (xix+hl)` at 0xF8981E, inside Ctrl_Normalise_Dispatch.  A census
;          of the immediate 0x00F89825 over prom_a and prom_b finds no other
;          (notes/prom_a_ctrl_checks.py).
; Inputs:  a BYTE offset 0x00..0x7C, four per slot.
; Outputs: an LE32 code address, loaded into XHL and jumped to.
; Evidence: the 34-entry count is the distance from 0xF89825 to the first
;          handler at 0xF898AD, 0x88 bytes = 34 entries; the reachable 32 come
;          from the dispatcher's maximum index, not from a bound in the ROM.
; Unknown:  why 34 entries were emitted when 32 are reachable.  Both extra
;          entries hold Ctrl_ReportUnchanged, so the overrun would be harmless
;          if it happened; that is an observation, not an explanation.
; ---------------------------------------------------------------------
Ctrl_HandlerTable:
	.long Ctrl_Ch0_Normalise       ; F89825  grp 0 ch 0
	.long Ctrl_Ch1_Normalise       ; F89829  grp 0 ch 1
	.long Ctrl_Ch2_Normalise       ; F8982D  grp 0 ch 2
	.long Ctrl_Ch3_Normalise       ; F89831  grp 0 ch 3
	.long Ctrl_Ch4_Normalise       ; F89835  grp 0 ch 4
	.long Ctrl_Ch5_Normalise       ; F89839  grp 0 ch 5
	.long Ctrl_ReportUnchanged     ; F8983D  grp 0 ch 6
	.long Ctrl_ReportUnchanged     ; F89841  grp 0 ch 7
	.long Ctrl_ReportUnchanged     ; F89845  grp 1 ch 0
	.long Ctrl_ReportUnchanged     ; F89849  grp 1 ch 1
	.long Ctrl_ReportUnchanged     ; F8984D  grp 1 ch 2
	.long Ctrl_ReportUnchanged     ; F89851  grp 1 ch 3
	.long Ctrl_ReportUnchanged     ; F89855  grp 1 ch 4
	.long Ctrl_ReportUnchanged     ; F89859  grp 1 ch 5
	.long Ctrl_ReportUnchanged     ; F8985D  grp 1 ch 6
	.long Ctrl_ReportUnchanged     ; F89861  grp 1 ch 7
	.long Ctrl_ReportUnchanged     ; F89865  grp 2 ch 0
	.long Ctrl_ReportUnchanged     ; F89869  grp 2 ch 1
	.long Ctrl_ReportUnchanged     ; F8986D  grp 2 ch 2
	.long Ctrl_ReportUnchanged     ; F89871  grp 2 ch 3
	.long Ctrl_ReportUnchanged     ; F89875  grp 2 ch 4
	.long Ctrl_ReportUnchanged     ; F89879  grp 2 ch 5
	.long Ctrl_ReportUnchanged     ; F8987D  grp 2 ch 6
	.long Ctrl_ReportUnchanged     ; F89881  grp 2 ch 7
	.long Ctrl_G3Ch0_Normalise     ; F89885  grp 3 ch 0
	.long Ctrl_G3Ch1_Normalise     ; F89889  grp 3 ch 1
	.long Ctrl_G3Ch2_Normalise     ; F8988D  grp 3 ch 2
	.long Ctrl_G3Ch3_Normalise     ; F89891  grp 3 ch 3
	.long Ctrl_ReportUnchanged     ; F89895  grp 3 ch 4
	.long Ctrl_ReportUnchanged     ; F89899  grp 3 ch 5
	.long Ctrl_ReportUnchanged     ; F8989D  grp 3 ch 6
	.long Ctrl_ReportChanged       ; F898A1  grp 3 ch 7
	.long Ctrl_ReportUnchanged     ; F898A5  grp 4 ch 0   ⚠ beyond index 0x7C
	.long Ctrl_ReportUnchanged     ; F898A9  grp 4 ch 1   ⚠ beyond index 0x7C

; ---------------------------------------------------------------------
; The TEN live handlers.  Every one has the same shape, and the differences
; between them are the whole content of this module:
;
;   slot  raw slot  curve      cooked   idle value when (0xC4) == 2
;   0.0   0x24D0    0xF89BB4   0x2505   0x40
;   0.1   0x24D1    0xF89BB4   0x2506   0x40
;   0.2   0x24D2    0xF89EB4   0x24FF   0x00     + the 0x007F5A calibration
;   0.3   0x24D3    0xF89DB4   0x24F2   0x00     + the raw byte is INVERTED first
;   0.4   0x24D4    0xF89B34   0x2503   (no idle arm)
;   0.5   0x24D5    0xF89B34   0x2504   (no idle arm)
;   3.0   0x24E8    0xF89C34   0x24F5   0x00
;   3.1   0x24E9    0xF89CB4   0x24F4   0x80     + indexed by the RAW byte
;   3.2   0x24EA    0xF89B34   0x24F6   0x40
;   3.3   0x24EB    0xF89AB4   0x24F3   (no idle arm)
;
; and the tail is shared: `scf` then return means "changed", `rcf` then return
; means "no change, ignore this reading".
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; Ctrl_Ch0_Normalise -- slot 0.0 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 0 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x2505) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  When (0xC4) == 2
;          it writes the idle value 0x40 to (0x2505) instead and returns
;          CARRY CLEAR without touching the curve.  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24D0), the curve base is the literal
;          0x00F89BB4 (Ctrl_Curve_Compressed_PlusMinus1) in its own `ld XIX,imm32`, the index is raw >> 1,
;          and the cooked slot is (0x2505) in both the compare and the store.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_Ch0_Normalise:
	cp	(Variant_Flag:8), 0x02                        ; F898AD  c0 c4 3f 02
	jr nz, .LF898BC                               ; F898B1  6e 09
	ld a, 0x40:opc                                   ; F898B3  21 40
	ld (0x2505:16), a                            ; F898B5  f1 05 25 41
	jrl .LF89AB0                                  ; F898B9  78 f4 01
.LF898BC:
	ld (0x24d0:16), a                            ; F898BC  f1 d0 24 41
	srl a, 0x01                                   ; F898C0  c9 ef 01
	xor HL,HL                                     ; F898C3  db d3
	ld L,A                                        ; F898C5  c9 8f
	ld XIX,Ctrl_Curve_Compressed_PlusMinus1       ; F898C7  44 b4 9b f8 00
	ld	a, (xix+hl)                           ; F898CC  c3 07 f0 ec 21
	cp	a, (0x2505:16)                        ; F898D1  c1 05 25 f1
	jrl z, .LF89AB0                               ; F898D5  76 d8 01
	ld (0x2505:16), a                            ; F898D8  f1 05 25 41
	scf                                           ; F898DC  11
	jrl .LF89AB1                                  ; F898DD  78 d1 01
; ---------------------------------------------------------------------
; Ctrl_Ch1_Normalise -- slot 0.1 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 1 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x2506) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  When (0xC4) == 2
;          it writes the idle value 0x40 to (0x2506) instead and returns
;          CARRY CLEAR without touching the curve.  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24D1), the curve base is the literal
;          0x00F89BB4 (Ctrl_Curve_Compressed_PlusMinus1) in its own `ld XIX,imm32`, the index is raw >> 1,
;          and the cooked slot is (0x2506) in both the compare and the store.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_Ch1_Normalise:
	cp	(Variant_Flag:8), 0x02                        ; F898E0  c0 c4 3f 02
	jr nz, .LF898EF                               ; F898E4  6e 09
	ld a, 0x40:opc                                   ; F898E6  21 40
	ld (0x2506:16), a                            ; F898E8  f1 06 25 41
	jrl .LF89AB0                                  ; F898EC  78 c1 01
.LF898EF:
	ld (0x24d1:16), a                            ; F898EF  f1 d1 24 41
	srl a, 0x01                                   ; F898F3  c9 ef 01
	xor HL,HL                                     ; F898F6  db d3
	ld L,A                                        ; F898F8  c9 8f
	ld XIX,Ctrl_Curve_Compressed_PlusMinus1       ; F898FA  44 b4 9b f8 00
	ld	a, (xix+hl)                           ; F898FF  c3 07 f0 ec 21
	cp	a, (0x2506:16)                        ; F89904  c1 06 25 f1
	jrl z, .LF89AB0                               ; F89908  76 a5 01
	ld (0x2506:16), a                            ; F8990B  f1 06 25 41
	scf                                           ; F8990F  11
	jrl .LF89AB1                                  ; F89910  78 9e 01
; ---------------------------------------------------------------------
; Ctrl_Ch2_Normalise -- slot 0.2 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 2 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x24FF) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  When (0xC4) == 2
;          it writes the idle value 0x00 to (0x24FF) instead and returns
;          CARRY CLEAR without touching the curve.  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24D2), the curve base is the literal
;          0x00F89EB4 (Ctrl_Curve_Wide256_B) in its own `ld XIX,imm32`, the index is the raw byte whole,
;          and the cooked slot is (0x24FF) in both the compare and the store.
; Evidence: ★ THE ONE CALIBRATED SLOT.  After the curve it subtracts the floor byte at
;          (0x7F60), scales by 0x100/0xEC, multiplies by Ctrl_SpanTable[(0x7F5F)]
;          and divides by 20, then clamps to 0x7F.  (0x7F5A) is the base of the
;          record: +5 is the span index and +6 the floor.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_Ch2_Normalise:
	cp	(Variant_Flag:8), 0x02                        ; F89913  c0 c4 3f 02
	jr nz, .LF89922                               ; F89917  6e 09
	ld a, 0x00:opc                                   ; F89919  21 00
	ld (0x24ff:16), a                            ; F8991B  f1 ff 24 41
	jrl .LF89AB0                                  ; F8991F  78 8e 01
.LF89922:
	ld (0x24d2:16), a                            ; F89922  f1 d2 24 41
	ld XIX,Ctrl_Curve_Wide256_B                   ; F89926  44 b4 9e f8 00
	xor W,W                                       ; F8992B  c8 d0
	ld	a, (xix+wa)                           ; F8992D  c3 07 f0 e0 21
	ld XIX,0x00007f5a                             ; F89932  44 5a 7f 00 00
	ld L,(XIX+0x06)                               ; F89937  8c 06 27
	cp A,L                                        ; F8993A  cf f1
	jr ugt, .LF89940                              ; F8993C  6b 02
	ld A,L                                        ; F8993E  cf 89
.LF89940:
	sub A,L                                       ; F89940  cf a1
	extz WA                                       ; F89942  d8 12
	mul WA,0x0100                                 ; F89944  d8 08 00 01
	div WA,0x00ec                                 ; F89948  d8 0a ec 00
	ld L,(XIX+0x05)                               ; F8994C  8c 05 27
	extz HL                                       ; F8994F  db 12
	extz XHL                                      ; F89951  eb 12
	add XHL,Ctrl_SpanTable                        ; F89953  eb c8 b4 9f f8 00
	ld L,(XHL)                                    ; F89959  83 27
	extz HL                                       ; F8995B  db 12
	mul xhl, wa                                  ; F8995D  d8 43
	div HL,0x0014                                 ; F8995F  db 0a 14 00
	ld WA,HL                                      ; F89963  db 88
	cp WA,0x007f                                  ; F89965  d8 cf 7f 00
	jr ule, .LF8996D                              ; F89969  63 02
	ld a, 0x7f:opc                                   ; F8996B  21 7f
.LF8996D:
	cp	a, (0x24ff:16)                        ; F8996D  c1 ff 24 f1
	jrl z, .LF89AB0                               ; F89971  76 3c 01
	ld (0x24ff:16), a                            ; F89974  f1 ff 24 41
	scf                                           ; F89978  11
	jrl .LF89AB1                                  ; F89979  78 35 01
; ---------------------------------------------------------------------
; Ctrl_Ch3_Normalise -- slot 0.3 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 3 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x24F2) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  When (0xC4) == 2
;          it writes the idle value 0x00 to (0x24F2) instead and returns
;          CARRY CLEAR without touching the curve.  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24D3), the curve base is the literal
;          0x00F89DB4 (Ctrl_Curve_Concave128) in its own `ld XIX,imm32`, the index is raw >> 1,
;          and the cooked slot is (0x24F2) in both the compare and the store.
; Evidence: the raw byte is INVERTED (`xor A,0xFF`) before it is stored and indexed, so
;          this control reads backwards from the other five.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_Ch3_Normalise:
	cp	(Variant_Flag:8), 0x02                        ; F8997C  c0 c4 3f 02
	jr nz, .LF8998B                               ; F89980  6e 09
	ld a, 0x00:opc                                   ; F89982  21 00
	ld (0x24f2:16), a                            ; F89984  f1 f2 24 41
	jrl .LF89AB0                                  ; F89988  78 25 01
.LF8998B:
	xor A,0xff                                    ; F8998B  c9 cd ff
	ld (0x24d3:16), a                            ; F8998E  f1 d3 24 41
	srl a, 0x01                                   ; F89992  c9 ef 01
	xor HL,HL                                     ; F89995  db d3
	ld L,A                                        ; F89997  c9 8f
	ld XIX,Ctrl_Curve_Concave128                  ; F89999  44 b4 9d f8 00
	ld	a, (xix+hl)                           ; F8999E  c3 07 f0 ec 21
	cp	a, (0x24f2:16)                        ; F899A3  c1 f2 24 f1
	jrl z, .LF89AB0                               ; F899A7  76 06 01
	ld (0x24f2:16), a                            ; F899AA  f1 f2 24 41
	scf                                           ; F899AE  11
	jrl .LF89AB1                                  ; F899AF  78 ff 00
; ---------------------------------------------------------------------
; Ctrl_Ch4_Normalise -- slot 0.4 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 4 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x2503) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  This slot has NO
;          idle arm: it does not test (0xC4).  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24D4), the curve base is the literal
;          0x00F89B34 (Ctrl_Curve_Compressed) in its own `ld XIX,imm32`, the index is raw >> 1,
;          and the cooked slot is (0x2503) in both the compare and the store.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_Ch4_Normalise:
	ld (0x24d4:16), a                            ; F899B2  f1 d4 24 41
	srl a, 0x01                                   ; F899B6  c9 ef 01
	xor HL,HL                                     ; F899B9  db d3
	ld L,A                                        ; F899BB  c9 8f
	ld XIX,Ctrl_Curve_Compressed                  ; F899BD  44 34 9b f8 00
	ld	a, (xix+hl)                           ; F899C2  c3 07 f0 ec 21
	cp	a, (0x2503:16)                        ; F899C7  c1 03 25 f1
	jrl z, .LF89AB0                               ; F899CB  76 e2 00
	ld (0x2503:16), a                            ; F899CE  f1 03 25 41
	scf                                           ; F899D2  11
	jrl .LF89AB1                                  ; F899D3  78 db 00
; ---------------------------------------------------------------------
; Ctrl_Ch5_Normalise -- slot 0.5 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 5 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x2504) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  This slot has NO
;          idle arm: it does not test (0xC4).  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24D5), the curve base is the literal
;          0x00F89B34 (Ctrl_Curve_Compressed) in its own `ld XIX,imm32`, the index is raw >> 1,
;          and the cooked slot is (0x2504) in both the compare and the store.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_Ch5_Normalise:
	ld (0x24d5:16), a                            ; F899D6  f1 d5 24 41
	srl a, 0x01                                   ; F899DA  c9 ef 01
	xor HL,HL                                     ; F899DD  db d3
	ld L,A                                        ; F899DF  c9 8f
	ld XIX,Ctrl_Curve_Compressed                  ; F899E1  44 34 9b f8 00
	ld	a, (xix+hl)                           ; F899E6  c3 07 f0 ec 21
	cp	a, (0x2504:16)                        ; F899EB  c1 04 25 f1
	jrl z, .LF89AB0                               ; F899EF  76 be 00
	ld (0x2504:16), a                            ; F899F2  f1 04 25 41
	scf                                           ; F899F6  11
	jrl .LF89AB1                                  ; F899F7  78 b7 00
; ---------------------------------------------------------------------
; Ctrl_G3Ch1_Normalise -- slot 3.1 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 25 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x24F4) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  When (0xC4) == 2
;          it writes the idle value 0x80 to (0x24F4) instead and returns
;          CARRY CLEAR without touching the curve.  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24E9), the curve base is the literal
;          0x00F89CB4 (Ctrl_Curve_Wide256_A) in its own `ld XIX,imm32`, the index is the raw byte whole,
;          and the cooked slot is (0x24F4) in both the compare and the store.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_G3Ch1_Normalise:
	cp	(Variant_Flag:8), 0x02                        ; F899FA  c0 c4 3f 02
	jr NZ,.LF89A09                                ; F899FE  6e 09
	ld a, 0x80:opc                                   ; F89A00  21 80
	ld (0x24f4:16), a                            ; F89A02  f1 f4 24 41
	jrl .LF89AB0                                  ; F89A06  78 a7 00
.LF89A09:
	ld (0x24e9:16), a                            ; F89A09  f1 e9 24 41
	xor HL,HL                                     ; F89A0D  db d3
	ld L,A                                        ; F89A0F  c9 8f
	ld XIX,Ctrl_Curve_Wide256_A                   ; F89A11  44 b4 9c f8 00
	ld	a, (xix+hl)                           ; F89A16  c3 07 f0 ec 21
	cp	a, (0x24f4:16)                        ; F89A1B  c1 f4 24 f1
	jrl z, .LF89AB0                               ; F89A1F  76 8e 00
	ld (0x24f4:16), a                            ; F89A22  f1 f4 24 41
	scf                                           ; F89A26  11
	jrl .LF89AB1                                  ; F89A27  78 87 00
; ---------------------------------------------------------------------
; Ctrl_G3Ch0_Normalise -- slot 3.0 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 24 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x24F5) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  When (0xC4) == 2
;          it writes the idle value 0x00 to (0x24F5) instead and returns
;          CARRY CLEAR without touching the curve.  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24E8), the curve base is the literal
;          0x00F89C34 (Ctrl_Curve_Identity128_Copy) in its own `ld XIX,imm32`, the index is raw >> 1,
;          and the cooked slot is (0x24F5) in both the compare and the store.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_G3Ch0_Normalise:
	cp	(Variant_Flag:8), 0x02                        ; F89A2A  c0 c4 3f 02
	jr nz, .LF89A39                               ; F89A2E  6e 09
	ld a, 0x00:opc                                   ; F89A30  21 00
	ld (0x24f5:16), a                            ; F89A32  f1 f5 24 41
	jrl .LF89AB0                                  ; F89A36  78 77 00
.LF89A39:
	ld (0x24e8:16), a                            ; F89A39  f1 e8 24 41
	srl a, 0x01                                   ; F89A3D  c9 ef 01
	xor HL,HL                                     ; F89A40  db d3
	ld L,A                                        ; F89A42  c9 8f
	ld XIX,Ctrl_Curve_Identity128_Copy            ; F89A44  44 34 9c f8 00
	ld	a, (xix+hl)                           ; F89A49  c3 07 f0 ec 21
	cp	a, (0x24f5:16)                        ; F89A4E  c1 f5 24 f1
	jr z, .LF89AB0                                ; F89A52  66 5c
	ld (0x24f5:16), a                            ; F89A54  f1 f5 24 41
	scf                                           ; F89A58  11
	jr .LF89AB1                                   ; F89A59  68 56
; ---------------------------------------------------------------------
; Ctrl_G3Ch2_Normalise -- slot 3.2 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 26 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x24F6) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  When (0xC4) == 2
;          it writes the idle value 0x40 to (0x24F6) instead and returns
;          CARRY CLEAR without touching the curve.  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24EA), the curve base is the literal
;          0x00F89B34 (Ctrl_Curve_Compressed) in its own `ld XIX,imm32`, the index is raw >> 1,
;          and the cooked slot is (0x24F6) in both the compare and the store.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_G3Ch2_Normalise:
	cp	(Variant_Flag:8), 0x02                        ; F89A5B  c0 c4 3f 02
	jr nz, .LF89A69                               ; F89A5F  6e 08
	ld a, 0x40:opc                                   ; F89A61  21 40
	ld (0x24f6:16), a                            ; F89A63  f1 f6 24 41
	jr .LF89AB0                                   ; F89A67  68 47
.LF89A69:
	ld (0x24ea:16), a                            ; F89A69  f1 ea 24 41
	srl a, 0x01                                   ; F89A6D  c9 ef 01
	xor HL,HL                                     ; F89A70  db d3
	ld L,A                                        ; F89A72  c9 8f
	ld XIX,Ctrl_Curve_Compressed                  ; F89A74  44 34 9b f8 00
	ld	a, (xix+hl)                           ; F89A79  c3 07 f0 ec 21
	cp	a, (0x24f6:16)                        ; F89A7E  c1 f6 24 f1
	jr z, .LF89AB0                                ; F89A82  66 2c
	ld (0x24f6:16), a                            ; F89A84  f1 f6 24 41
	scf                                           ; F89A88  11
	jr .LF89AB1                                   ; F89A89  68 26
; ---------------------------------------------------------------------
; Ctrl_G3Ch3_Normalise -- slot 3.3 of Ctrl_HandlerTable
;
; Called from: Ctrl_Normalise_Dispatch only, through entry 27 of
;          Ctrl_HandlerTable; nothing calls it by address.
; Inputs:  A = the raw reading; (0xC4) = the mode byte.
; Outputs: CARRY SET and (0x24F3) := the cooked value when it differs from
;          the value already there; CARRY CLEAR otherwise.  This slot has NO
;          idle arm: it does not test (0xC4).  A, HL and XIX clobbered.
; Evidence: the raw byte is stored at (0x24EB), the curve base is the literal
;          0x00F89AB4 (Ctrl_Curve_Identity128) in its own `ld XIX,imm32`, the index is raw >> 1,
;          and the cooked slot is (0x24F3) in both the compare and the store.
; Unknown:  what this control IS.  The module establishes the group and the
;          channel, not the legend on the panel (emulation gap O).
; ---------------------------------------------------------------------
Ctrl_G3Ch3_Normalise:
	ld (0x24eb:16), a                            ; F89A8B  f1 eb 24 41
	srl a, 0x01                                   ; F89A8F  c9 ef 01
	xor HL,HL                                     ; F89A92  db d3
	ld L,A                                        ; F89A94  c9 8f
	ld XIX,Ctrl_Curve_Identity128                 ; F89A96  44 b4 9a f8 00
	ld	a, (xix+hl)                           ; F89A9B  c3 07 f0 ec 21
	cp	a, (0x24f3:16)                        ; F89AA0  c1 f3 24 f1
	jr z, .LF89AB0                                ; F89AA4  66 0a
	ld (0x24f3:16), a                            ; F89AA6  f1 f3 24 41
	scf                                           ; F89AAA  11
	jr .LF89AB1                                   ; F89AAB  68 04
; ---------------------------------------------------------------------
; Ctrl_ReportChanged -- `scf` and return: accept this reading unconditionally
;
; Called from: Ctrl_Normalise_Dispatch, through entry 31 of Ctrl_HandlerTable
;          (slot 3.7) -- the only entry that names it.
; Inputs:  none; A is passed through untouched.
; Outputs: CARRY SET, so the caller keeps the byte.  Nothing is stored.
; Evidence: the routine is `scf / jr Ctrl__return`, three bytes at 0xF89AAD.
; Unknown:  what the byte means.  ⚠ This slot keeps NO previous value, so it
;          cannot report "unchanged" and no reading is ever dropped -- which is
;          what emulation gap Q asks about for panel wire 0xD7.  That the byte
;          is therefore a RELATIVE step is the gap list's reading, not a claim
;          this file makes: nothing here reads the byte's value at all.
; ---------------------------------------------------------------------
Ctrl_ReportChanged:
	scf                                           ; F89AAD  11
	jr .LF89AB1                                   ; F89AAE  68 01
; ---------------------------------------------------------------------
; Ctrl_ReportUnchanged -- `rcf` and fall through: drop this reading
;
; Called from: 21 entries of Ctrl_HandlerTable, and by the "no change" and
;          "idle" arms of every live handler.
; Inputs:  none.
; Outputs: CARRY CLEAR, then Ctrl__return.  Nothing is stored.
; Evidence: one byte, `rcf` at 0xF89AB0, immediately above the shared epilogue.
; Unknown:  nothing here.
; ---------------------------------------------------------------------
Ctrl_ReportUnchanged:
.LF89AB0:
	rcf                                           ; F89AB0  10
; ---------------------------------------------------------------------
; Ctrl__return -- the shared epilogue: undo Ctrl_Normalise_Dispatch's frame
;
; Called from: reached by fall-through from Ctrl_ReportUnchanged and by a jump
;          from every handler's "changed" tail; it is not called.
; Inputs:  the carry flag, already set or cleared by the arm that jumped here.
; Outputs: XIX and XHL restored, then RET with the carry intact.
; Evidence: `pop XIX / pop XHL / ret` mirrors the `push XHL / push XIX` at
;          0xF89805-0xF89806, and RET does not touch the flags.
; Unknown:  nothing here.
; ---------------------------------------------------------------------
Ctrl__return:
.LF89AB1:
	pop XIX                                       ; F89AB1  5c
	pop XHL                                       ; F89AB2  5b
	ret                                           ; F89AB3  0e

; ====================================================================
; The eight response curves and the span table, 0xF89AB4-0xF89FBE.
; They tile with no gap.  Each table's extent is the distance to the
; next one's own base address, and the last runs to the module pad.
; ====================================================================

; identity 0..127; used by slot 3.3 (0xF89A96 `ld XIX,0x00F89AB4`)
Ctrl_Curve_Identity128:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F   ; F89AB4
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F   ; F89AC4
	.byte 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F   ; F89AD4
	.byte 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F   ; F89AE4
	.byte 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F   ; F89AF4
	.byte 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F   ; F89B04
	.byte 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F   ; F89B14
	.byte 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F   ; F89B24

; slots 0.4, 0.5 and 3.2 (0xF899BD, 0xF899E1, 0xF89A74)
Ctrl_Curve_Compressed:
	.byte 0x00, 0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12, 0x14, 0x15, 0x17, 0x19, 0x1A   ; F89B34
	.byte 0x1C, 0x1E, 0x1F, 0x21, 0x2C, 0x24, 0x25, 0x26, 0x28, 0x29, 0x2A, 0x2B, 0x2D, 0x2E, 0x2F, 0x30   ; F89B44
	.byte 0x31, 0x32, 0x33, 0x34, 0x35, 0x35, 0x36, 0x36, 0x37, 0x37, 0x38, 0x38, 0x39, 0x39, 0x3A, 0x3A   ; F89B54
	.byte 0x3B, 0x3B, 0x3C, 0x3C, 0x3D, 0x3D, 0x3E, 0x3E, 0x3F, 0x3F, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40   ; F89B64
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x41, 0x41, 0x42, 0x42, 0x43, 0x43, 0x44, 0x44, 0x45   ; F89B74
	.byte 0x45, 0x46, 0x46, 0x47, 0x47, 0x48, 0x48, 0x49, 0x49, 0x4A, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F   ; F89B84
	.byte 0x50, 0x51, 0x52, 0x53, 0x55, 0x56, 0x57, 0x58, 0x5A, 0x5B, 0x5C, 0x5E, 0x5F, 0x61, 0x62, 0x64   ; F89B94
	.byte 0x66, 0x67, 0x69, 0x6B, 0x6C, 0x6E, 0x70, 0x72, 0x74, 0x76, 0x78, 0x7A, 0x7C, 0x7E, 0x7F, 0x7F   ; F89BA4

; slots 0.0 and 0.1 (0xF898C7, 0xF898FA).  40 of its 128 bytes DIFFER from Ctrl_Curve_Compressed -- 21 are one HIGHER and 19 one LOWER, all
; between indices 37 and 89 -- and the other 88 are equal.  CORRECTED 2026-08-25 (audit F2): this comment and the label both said "one higher",
; which is half of it; the module banner above and notes/prom_a_ctrl_checks.py ("21 of them are +1 and 19 are -1") always said ±1
Ctrl_Curve_Compressed_PlusMinus1:
	.byte 0x00, 0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12, 0x14, 0x15, 0x17, 0x19, 0x1A   ; F89BB4
	.byte 0x1C, 0x1E, 0x1F, 0x21, 0x2C, 0x24, 0x25, 0x26, 0x28, 0x29, 0x2A, 0x2B, 0x2D, 0x2E, 0x2F, 0x30   ; F89BC4
	.byte 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x37, 0x38, 0x38, 0x39, 0x39, 0x3A, 0x3A, 0x3B, 0x3B   ; F89BD4
	.byte 0x3C, 0x3C, 0x3D, 0x3D, 0x3E, 0x3E, 0x3F, 0x3F, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40   ; F89BE4
	.byte 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x41, 0x41, 0x42, 0x42, 0x43, 0x43, 0x44   ; F89BF4
	.byte 0x44, 0x45, 0x45, 0x46, 0x46, 0x47, 0x47, 0x48, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F   ; F89C04
	.byte 0x50, 0x51, 0x52, 0x53, 0x55, 0x56, 0x57, 0x58, 0x5A, 0x5B, 0x5C, 0x5E, 0x5F, 0x61, 0x62, 0x64   ; F89C14
	.byte 0x66, 0x67, 0x69, 0x6B, 0x6C, 0x6E, 0x70, 0x72, 0x74, 0x76, 0x78, 0x7A, 0x7C, 0x7E, 0x7F, 0x7F   ; F89C24

; slot 3.0 (0xF89A44).  BYTE-IDENTICAL to Ctrl_Curve_Identity128 -- two copies of the same 128 bytes, 0x180 apart
Ctrl_Curve_Identity128_Copy:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F   ; F89C34
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F   ; F89C44
	.byte 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F   ; F89C54
	.byte 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F   ; F89C64
	.byte 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F   ; F89C74
	.byte 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F   ; F89C84
	.byte 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F   ; F89C94
	.byte 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F   ; F89CA4

; slot 3.1 (0xF89A11).  Indexed by the RAW byte, so all 256 entries are reachable; range 0..255
Ctrl_Curve_Wide256_A:
	.byte 0x00, 0x00, 0x00, 0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12, 0x14, 0x16, 0x18   ; F89CB4
	.byte 0x1A, 0x1C, 0x1E, 0x20, 0x22, 0x24, 0x26, 0x28, 0x2A, 0x2C, 0x2E, 0x30, 0x32, 0x33, 0x34, 0x35   ; F89CC4
	.byte 0x36, 0x38, 0x3A, 0x3C, 0x3E, 0x3F, 0x40, 0x42, 0x44, 0x45, 0x46, 0x48, 0x4A, 0x4B, 0x4C, 0x4D   ; F89CD4
	.byte 0x4E, 0x50, 0x51, 0x52, 0x54, 0x55, 0x56, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F, 0x60   ; F89CE4
	.byte 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6A, 0x6B, 0x6B, 0x6C, 0x6C, 0x6D   ; F89CF4
	.byte 0x6D, 0x6E, 0x6E, 0x6F, 0x6F, 0x70, 0x70, 0x71, 0x71, 0x72, 0x72, 0x73, 0x73, 0x74, 0x74, 0x75   ; F89D04
	.byte 0x75, 0x76, 0x76, 0x77, 0x77, 0x78, 0x78, 0x79, 0x79, 0x7A, 0x7A, 0x7B, 0x7B, 0x7C, 0x7C, 0x7D   ; F89D14
	.byte 0x7D, 0x7D, 0x7E, 0x7E, 0x7E, 0x7F, 0x7F, 0x7F, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80   ; F89D24
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x81, 0x81, 0x81, 0x81, 0x82, 0x82   ; F89D34
	.byte 0x82, 0x82, 0x83, 0x83, 0x83, 0x84, 0x84, 0x85, 0x85, 0x86, 0x86, 0x87, 0x87, 0x88, 0x88, 0x89   ; F89D44
	.byte 0x89, 0x8A, 0x8A, 0x8B, 0x8B, 0x8C, 0x8C, 0x8D, 0x8D, 0x8E, 0x8E, 0x8F, 0x8F, 0x90, 0x90, 0x91   ; F89D54
	.byte 0x91, 0x92, 0x92, 0x93, 0x94, 0x95, 0x96, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E   ; F89D64
	.byte 0x9F, 0xA0, 0xA1, 0xA2, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xB0, 0xB1   ; F89D74
	.byte 0xB2, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xBA, 0xBC, 0xBE, 0xBF, 0xC0, 0xC2, 0xC3, 0xC4, 0xC6, 0xC8   ; F89D84
	.byte 0xCA, 0xCC, 0xCD, 0xCE, 0xD0, 0xD2, 0xD4, 0xD6, 0xD8, 0xDA, 0xDC, 0xDD, 0xDE, 0xE0, 0xE2, 0xE4   ; F89D94
	.byte 0xE6, 0xE8, 0xEA, 0xEC, 0xEE, 0xF0, 0xF2, 0xF5, 0xF7, 0xF9, 0xFB, 0xFD, 0xFF, 0xFF, 0xFF, 0xFF   ; F89DA4

; slot 0.3 (0xF89999).  CORRECTED 2026-08-25 (audit F3): this was `Ctrl_Curve_Expo128`, a shape claim the bytes contradict.
; Evidence for the new name, all re-derived from the ROM by notes/prom_a_ctrl_checks.py: the table is monotone non-decreasing,
; spans 0..127, and lies ABOVE the diagonal -- 32->0x36 (54), 64->0x50 (80), 96->0x68 (104), deviation from `out == in` in the
; range -1..+22 with mean +11.9.  That is CONCAVE (log-like, small inputs boosted).  An exponential curve is the CONVEX one, and
; the two convex tables in this tiling are 0xF89E34 (mean -5.8) and 0xF89EB4 (mean -46.7), neither of which is named for a shape
Ctrl_Curve_Concave128:
	.byte 0x00, 0x00, 0x01, 0x03, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12, 0x14, 0x16, 0x18, 0x19, 0x1B   ; F89DB4
	.byte 0x1D, 0x1F, 0x20, 0x22, 0x24, 0x26, 0x28, 0x2A, 0x2B, 0x2D, 0x2E, 0x30, 0x31, 0x32, 0x34, 0x35   ; F89DC4
	.byte 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x3F, 0x40, 0x41, 0x42, 0x42, 0x43   ; F89DD4
	.byte 0x44, 0x45, 0x46, 0x46, 0x47, 0x48, 0x48, 0x49, 0x4A, 0x4B, 0x4B, 0x4C, 0x4D, 0x4E, 0x4E, 0x4F   ; F89DE4
	.byte 0x50, 0x51, 0x52, 0x52, 0x53, 0x54, 0x54, 0x55, 0x56, 0x57, 0x58, 0x58, 0x59, 0x5A, 0x5A, 0x5B   ; F89DF4
	.byte 0x5C, 0x5D, 0x5D, 0x5E, 0x5F, 0x60, 0x61, 0x61, 0x62, 0x63, 0x63, 0x64, 0x65, 0x66, 0x66, 0x67   ; F89E04
	.byte 0x68, 0x69, 0x69, 0x6A, 0x6B, 0x6C, 0x6C, 0x6D, 0x6E, 0x6F, 0x6F, 0x70, 0x71, 0x72, 0x72, 0x73   ; F89E14
	.byte 0x74, 0x74, 0x75, 0x76, 0x77, 0x77, 0x78, 0x79, 0x7A, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F, 0x7F   ; F89E24

; ⚠ NOTHING REFERENCES THIS.  A census of the little-endian immediate 0x00F89E34 over prom_a AND prom_b finds zero sites, and the same census finds every other table here at the `ld XIX,imm32` that uses it (notes/prom_a_ctrl_checks.py)
Ctrl_Curve_Unreferenced128:
	.byte 0x00, 0x00, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0E   ; F89E34
	.byte 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D   ; F89E44
	.byte 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B   ; F89E54
	.byte 0x2C, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39   ; F89E64
	.byte 0x3A, 0x3B, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x43, 0x44, 0x45, 0x46, 0x47   ; F89E74
	.byte 0x48, 0x49, 0x4A, 0x4B, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, 0x51, 0x52, 0x52, 0x53, 0x54, 0x55   ; F89E84
	.byte 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F, 0x60, 0x61, 0x62, 0x62, 0x63   ; F89E94
	.byte 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x71, 0x74, 0x78, 0x7B, 0x7F, 0x7F   ; F89EA4

; slot 0.2 (0xF89926).  Indexed by the RAW byte; range 0..255
Ctrl_Curve_Wide256_B:
	.byte 0x00, 0x01, 0x01, 0x02, 0x02, 0x03, 0x03, 0x04, 0x04, 0x05, 0x05, 0x06, 0x07, 0x07, 0x08, 0x08   ; F89EB4
	.byte 0x09, 0x09, 0x0A, 0x0A, 0x0B, 0x0B, 0x0C, 0x0C, 0x0D, 0x0E, 0x0E, 0x0F, 0x0F, 0x10, 0x10, 0x11   ; F89EC4
	.byte 0x11, 0x12, 0x12, 0x13, 0x14, 0x14, 0x15, 0x15, 0x16, 0x16, 0x17, 0x17, 0x18, 0x18, 0x19, 0x19   ; F89ED4
	.byte 0x1A, 0x1B, 0x1B, 0x1C, 0x1C, 0x1D, 0x1D, 0x1E, 0x1E, 0x1F, 0x1F, 0x20, 0x21, 0x21, 0x22, 0x22   ; F89EE4
	.byte 0x23, 0x23, 0x24, 0x24, 0x25, 0x25, 0x26, 0x27, 0x27, 0x28, 0x28, 0x29, 0x29, 0x2A, 0x2A, 0x2B   ; F89EF4
	.byte 0x2B, 0x2C, 0x2C, 0x2D, 0x2E, 0x2E, 0x2F, 0x2F, 0x30, 0x30, 0x31, 0x31, 0x32, 0x32, 0x33, 0x34   ; F89F04
	.byte 0x34, 0x35, 0x35, 0x36, 0x36, 0x37, 0x37, 0x38, 0x38, 0x39, 0x39, 0x3A, 0x3A, 0x3B, 0x3B, 0x3C   ; F89F14
	.byte 0x3C, 0x3D, 0x3D, 0x3E, 0x3E, 0x3F, 0x3F, 0x40, 0x40, 0x41, 0x41, 0x42, 0x42, 0x43, 0x43, 0x44   ; F89F24
	.byte 0x44, 0x45, 0x45, 0x46, 0x46, 0x47, 0x47, 0x48, 0x48, 0x49, 0x49, 0x4A, 0x4A, 0x4B, 0x4B, 0x4C   ; F89F34
	.byte 0x4C, 0x4D, 0x4E, 0x4E, 0x4F, 0x50, 0x51, 0x51, 0x52, 0x53, 0x54, 0x54, 0x55, 0x56, 0x57, 0x57   ; F89F44
	.byte 0x58, 0x59, 0x5A, 0x5A, 0x5B, 0x5C, 0x5C, 0x5D, 0x5E, 0x5F, 0x5F, 0x60, 0x61, 0x62, 0x62, 0x63   ; F89F54
	.byte 0x64, 0x65, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6D, 0x6E, 0x6F, 0x70, 0x71   ; F89F64
	.byte 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F, 0x80   ; F89F74
	.byte 0x82, 0x83, 0x85, 0x87, 0x88, 0x8A, 0x8C, 0x8D, 0x8F, 0x91, 0x92, 0x94, 0x96, 0x97, 0x99, 0x9B   ; F89F84
	.byte 0x9D, 0x9F, 0xA1, 0xA3, 0xA5, 0xA7, 0xA9, 0xAB, 0xAD, 0xAF, 0xB1, 0xB3, 0xB7, 0xBA, 0xBE, 0xC1   ; F89F94
	.byte 0xC5, 0xC8, 0xCC, 0xD1, 0xD6, 0xDC, 0xE1, 0xE6, 0xE9, 0xEC, 0xEF, 0xF3, 0xF6, 0xF9, 0xFC, 0xFF   ; F89FA4

; slot 0.2's calibration span, indexed by (0x7F5F); the base is formed by `add XHL,0x00F89FB4` at 0xF89953, not by an `ld XIX`.  ⚠ ELEVEN is the number of bytes before the module's 0x0E pad, NOT a bound the ROM checks: the use site does not range-check the index
Ctrl_SpanTable:
	.byte 0x00, 0x06, 0x08, 0x0A, 0x0D, 0x10, 0x13, 0x16, 0x19, 0x1E, 0x28   ; F89FB4

; 0xF89FBF-0xF89FFF -- 65 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_ctrl_module.py
; refuses to emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 65, 1, 0x0E
