
; ==============================================================================
; 0xF8A000-0xF8BBFF -- the PANEL WIRE-to-GROUP module
; ==============================================================================
;
; ★★ THIS IS WHERE THE PANEL'S WIRE ADDRESSES BECOME GROUP IDS, and it is the
; span kn7000_mame's gap O points at.  Two 128-byte maps, one per model variant,
; selected by the (0xC4) strap, indexed by
;     (wire & 0x1F) | ((wire & 0xC0) >> 1)
; -- see PanelWireGroupMap_Variant1's header for where every term of that comes
; from.  Variant 1 answers to eleven button wires (0xC0-0xCA) plus four
; continuous ones (0xD0-0xD3) plus the dial (0xD7); variant 2 answers to nine
; button wires (0xC0-0xC5, 0xC7-0xC9) plus 0xD3 and 0xD7.  Both lists are
; printed by `python3 notes/gen_prom_a_f8a000_module.py --check`, which reads
; them out of the ROM rather than out of this comment.
;
; The rest of the module is the panel event loop that walks the receive ring at
; RAM 0x2B40 and dispatches on the group, plus 2,191 bytes of tables at
; 0xF8B325 that are framed but not decoded.
;
; ⚠ Every routine here is `sub_XXXXXX`.  This pass converted the module and
; decoded ONE object in it.
; ==============================================================================

; PanelWire_EntryThunks -- the panel wire-to-group module's six-slot phase vector
; Evidence: ModuleInitDirectory_F82641[3] = T_PanelWire_EntryThunks, whose word is .long 0xF8A000; slot 0 (phase 0) is `jp PanelWire_ModuleReset`, slots 1-5 are `ret` + 3 pad bytes.  Same layout as MidiIn_EntryThunks.  Not a routine.
PanelWire_EntryThunks:
	jp PanelWire_BootPhase0                                        ; F8A000  1b 18 a0 f8
	ret                                                  ; F8A004  0e
	nop                                                  ; F8A005  00
	nop                                                  ; F8A006  00
	nop                                                  ; F8A007  00
	ret                                                  ; F8A008  0e
	nop                                                  ; F8A009  00
	nop                                                  ; F8A00A  00
	nop                                                  ; F8A00B  00
	ret                                                  ; F8A00C  0e
	nop                                                  ; F8A00D  00
	nop                                                  ; F8A00E  00
	nop                                                  ; F8A00F  00
	ret                                                  ; F8A010  0e
	nop                                                  ; F8A011  00
	nop                                                  ; F8A012  00
	nop                                                  ; F8A013  00
	ret                                                  ; F8A014  0e
	nop                                                  ; F8A015  00
	nop                                                  ; F8A016  00
	nop                                                  ; F8A017  00
; PanelWire_BootPhase0: module 3's boot phase 0 handler, slot 0 of its vector PanelWire_EntryThunks: (0x2000) = 0xFF, (0x219A) = 0.
;   It was labelled as a branch target of the vector (notes/prom_a_module_boot_phase_names.py).
PanelWire_BootPhase0:
	ld (0x2000:16), 0xff                                 ; F8A018  f1 00 20 00 ff
	ld (0x219a:16), 0x00                                 ; F8A01D  f1 9a 21 00 00
	ret                                                  ; F8A022  0e
; PanelWire_Service -- the panel wire module's per-loop entry
; Evidence: prom_b slot T_PanelWire_Service is `jp PanelWire_Service`; MainTask_Loop calls it at 0xF8204C beside T_AnalogScan_All and T_SC1_Service; body `calr PanelWire_ThrottledPoll / ret`.
PanelWire_Service:
	calr PanelWire_ThrottledPoll                                      ; F8A023  1e 02 00
	ret                                                  ; F8A026  0e
T_F40618_Nop:
	ret                                                  ; F8A027  0e
; PanelWire_ThrottledPoll -- run PanelWire_PollProducers on every other call, or at once after 16 idle ticks
; Evidence: inc (0x219B); inc (0x2196), phase=(0x2196)&3, forced to 0 when (0x80)-(0x2197)>=0x10; Dispatch_F8A05F[phase] = PollProducers for 0/2, the `ret` at 0xF8A05E for 1/3; (0x2197) is the (0x80) stamp PollProducers stores.
PanelWire_ThrottledPoll:
	ld XIY,0x0000219b                                    ; F8A028  45 9b 21 00 00
	incm8 0x01, (xiy)                                    ; F8A02D  85 61
	ld XIY,PanelWire_Phase                                    ; F8A02F  45 96 21 00 00
	incm8 0x01, (xiy)                                    ; F8A034  85 61
	ld HL,(XIY)                                          ; F8A036  95 23
	and HL,0x0003                                        ; F8A038  db cc 03 00
	ld	wa, (Tick_Count:8)                                 ; F8A03C  d0 80 20
	ld bc, (PanelWire_LastPollTick:16)                                 ; F8A03F  d1 97 21 21
	sub WA,BC                                            ; F8A043  d9 a0
	cp WA,0x0010                                         ; F8A045  d8 cf 10 00
	jr c, .LF8A04F                                       ; F8A049  67 04
	xor HL,HL                                            ; F8A04B  db d3
	ld (XIY),HL                                          ; F8A04D  b5 53
.LF8A04F:
	sla l, 0x02                                          ; F8A04F  cf ec 02
	ld XIY,Dispatch_F8A05F                               ; F8A052  45 5f a0 f8 00
	ld	xwa, (xiy+hl)                                ; F8A057  e3 07 f4 ec 20
	call (xwa)                                           ; F8A05C  b0 e8
.LF8A05E:
	ret                                                  ; F8A05E  0e
; ---------------------------------------------------------------------
; Dispatch_F8A05F -- 4 routine pointers
; Read by: 0xF8A052 `ld XIY,0x00F8A05F` after `sla L,2`, then
;          `ld XWA,(XIY+HL) / call (XWA)` at 0xF8A057-0xF8A05C.
; ⚠ ENTRY COUNT 4 is the EXTENT -- 0xF8A06F is the `ret` that ends the
;          previous routine's fall-through and code resumes at 0xF8A070.
;          There is no compare on L at the call site, so this is weaker
;          than a bound.
; Contents: 0xF8A070, 0xF8A05E, 0xF8A070, 0xF8A05E -- two distinct arms,
;          and 0xF8A05E is the bare `ret` one instruction above the table,
;          i.e. slots 1 and 3 are DO NOTHING.
; ---------------------------------------------------------------------

Dispatch_F8A05F:
	.long PanelWire_PollProducers                                 ; F8A05F  [  0]
	.long .LF8A05E                                   ; F8A063  [  1]
	.long PanelWire_PollProducers                                 ; F8A067  [  2]
	.long .LF8A05E                                   ; F8A06B  [  3]
	ret                                                  ; F8A06F  0e
; PanelWire_PollProducers -- run the three producers of the panel group queue
; Evidence: (0x2197)=(0x80); unless (0x207A)=0xDB: PanelWireQueue_DrainToGroupQueue, AssignableSwitch_Poll, PanelGroupQueue_AppendFlaggedGroups.  Reached through Dispatch_F8A05F slots 0 and 2.
PanelWire_PollProducers:   ; entry: named by 2 `.long` operands, first at 0xF8A05F
	ld	wa, (Tick_Count:8)                                 ; F8A070  d0 80 20
	ld (PanelWire_LastPollTick:16), wa                                  ; F8A073  f1 97 21 50
	cp	(UI_ScreenLatch:16), 0xdb                            ; F8A077  c1 7a 20 3f db
	jr z, .LF8A087                                       ; F8A07C  66 09
	calr PanelWireQueue_DrainToGroupQueue                                      ; F8A07E  1e 07 00
	calr AssignableSwitch_Poll                                          ; F8A081  1e 85 01
	calr PanelGroupQueue_AppendFlaggedGroups                                          ; F8A084  1e 7c 02
.LF8A087:
	ret                                                  ; F8A087  0e
; ---------------------------------------------------------------------
; PanelWireQueue_DrainToGroupQueue -- drain the CP1 wire queue at RAM 0x2B40
; and re-post each change as a GROUP record on the queue at RAM 0x2000.
;
; Called from: 0xF8A07E (`calr`), inside the arm that Dispatch_F8A05F slot 0
;          and slot 2 reach.
; Produces: it is the FIRST of the eight producers that call
;          PanelGroupQueue_Append; the other seven are the six fixed-group
;          appenders in PanelGroupQueue_AppendFlaggedGroups and the run-time
;          one at 0xF8A2D6.
; Body:    XIZ = 0x2B40, a ring whose put/get cursors are at +0x04/+0x06 and
;          whose wrap limit is at +0x02.  Per THREE-byte record it reads
;          [wire][new value][old XOR new], computes the map index
;          (wire & 0x1F) | ((wire & 0xC0) >> 1), reads
;          PanelWireGroupMap_Variant1/2 for the GROUP, and -- only when the
;          change byte is non-zero -- calls PanelGroupQueue_Append.
; Refuses: `cp (0x219A),0x07` at 0xF8A090 stops the drain when the group
;          queue already holds seven records; the wire queue keeps its
;          unread bytes and the drain resumes next tick.
; Sibling: prom_b SC1_RxOp0_ThreeByte (0xF5B0D5) is what FILLS 0x2B40.
; ⚠ prom_b's comments at :98479 and :156427, and two notes scripts, still
;          cite this routine as `prom_a sub_F8A088`; those files belong to
;          other lanes and were not edited.
; Evidence: `ld XIZ,0x00002B40` at 0xF8A088, `cp (0x219A),0x07` at 0xF8A090,
;          the index expression `and L,0x1F` / `and A,0xC0` / `srl A,1` /
;          `or L,A` at 0xF8A0A3-0xF8A0AC, `ld XIY,0x00F8A109` at 0xF8A0AE,
;          `calr` to 0xF8A3B2 at 0xF8A0F2, `ld (XIZ+0x06),IX` at 0xF8A103.
; ---------------------------------------------------------------------

PanelWireQueue_DrainToGroupQueue:
	ld XIZ,SC1_InQueue                                    ; F8A088  46 40 2b 00 00
	ld IX,(XIZ+0x06)                                     ; F8A08D  9e 06 24
.LF8A090:
	cp	(0x219a:16), 0x07                            ; F8A090  c1 9a 21 3f 07
	jr nc, .LF8A101                                      ; F8A095  6f 6a
	cp IX,(XIZ+0x04)                                     ; F8A097  9e 04 f4
	jr z, .LF8A101                                       ; F8A09A  66 65
	ld	a, (xiz+ix)                                  ; F8A09C  c3 07 f8 f0 21
	ld L,A                                               ; F8A0A1  c9 8f
	and L,0x1f                                           ; F8A0A3  cf cc 1f
	and A,0xc0                                           ; F8A0A6  c9 cc c0
	srl a, 0x01                                          ; F8A0A9  c9 ef 01
	or L,A                                               ; F8A0AC  c9 e7
	ld XIY,PanelWireGroupMap_Variant1                    ; F8A0AE  45 09 a1 f8 00
	cp	(Variant_Flag:8), 0x01                               ; F8A0B3  c0 c4 3f 01
	jr z, .LF8A0BE                                       ; F8A0B7  66 05
	ld XIY,PanelWireGroupMap_Variant2                    ; F8A0B9  45 89 a1 f8 00
.LF8A0BE:
	ld	e, (xiy+l)                                   ; F8A0BE  c3 03 f4 ec 25
	inc 1,IX                                             ; F8A0C3  dc 61
	incw 0x01, (xiz+0x08)                                ; F8A0C5  9e 08 61
	cp IX,(XIZ+0x02)                                     ; F8A0C8  9e 02 f4
	jr ule, .LF8A0D0                                     ; F8A0CB  63 03
	ld	ix, (xiz+0:8)                                ; F8A0CD  9e 00 24
.LF8A0D0:
	ld	a, (xiz+ix)                                  ; F8A0D0  c3 07 f8 f0 21
	inc 1,IX                                             ; F8A0D5  dc 61
	incw 0x01, (xiz+0x08)                                ; F8A0D7  9e 08 61
	cp IX,(XIZ+0x02)                                     ; F8A0DA  9e 02 f4
	jr ule, .LF8A0E2                                     ; F8A0DD  63 03
	ld	ix, (xiz+0:8)                                ; F8A0DF  9e 00 24
.LF8A0E2:
	ld	w, (xiz+ix)                                  ; F8A0E2  c3 07 f8 f0 20
	inc 1,IX                                             ; F8A0E7  dc 61
	incw 0x01, (xiz+0x08)                                ; F8A0E9  9e 08 61
	cp w, 0x00:i3                                          ; F8A0EC  c8 d8
	jr z, .LF8A0F7                                       ; F8A0EE  66 07
	push XIZ                                             ; F8A0F0  3e
	pushw ix                                             ; F8A0F1  2c
	calr PanelGroupQueue_Append                                          ; F8A0F2  1e bd 02
	popw ix                                              ; F8A0F5  4c
	pop XIZ                                              ; F8A0F6  5e
.LF8A0F7:
	cp IX,(XIZ+0x02)                                     ; F8A0F7  9e 02 f4
	jr ule, .LF8A090                                     ; F8A0FA  63 94
	ld	ix, (xiz+0:8)                                ; F8A0FC  9e 00 24
	jr .LF8A090                                          ; F8A0FF  68 8f
.LF8A101:
	ei 0x06                                              ; F8A101  06 06
	ld (XIZ+0x06),IX                                     ; F8A103  be 06 54
	ei 0x00                                              ; F8A106  06 00
	ret                                                  ; F8A108  0e
; ---------------------------------------------------------------------
; PanelWireGroupMap_Variant1 -- 128 bytes, wire address -> group id
; Read by: 0xF8A0BE `ld A,(XIY+L)` with XIY = 0xF8A109, loaded at
;          0xF8A0AE.  The other arm loads 0xF8A189; `cp (0xC4),0x01` at
;          0xF8A0B3 picks between them -- (0xC4) is the MODEL STRAP
;          (prom_a 0xF82882 reads PB bit 0 into it).
; INDEX:   (wire & 0x1F) | ((wire & 0xC0) >> 1), computed at
;          0xF8A0A3-0xF8A0AC.  Bit 5 of the wire is DROPPED, so wire
;          W and W|0x20 read the same entry.
; ENTRY COUNT 128 is the index width: the expression above cannot
;          exceed 0x7F, and 0xF8A189 is where the sibling map starts.
; 0x20 means NO GROUP -- 112 of the 128 entries are 0x20.
; The wires this variant answers to:
;     wire 0xC0 -> group 0x00
;     wire 0xC1 -> group 0x01
;     wire 0xC2 -> group 0x02
;     wire 0xC3 -> group 0x03
;     wire 0xC4 -> group 0x04
;     wire 0xC5 -> group 0x05
;     wire 0xC6 -> group 0x06
;     wire 0xC7 -> group 0x07
;     wire 0xC8 -> group 0x08
;     wire 0xC9 -> group 0x09
;     wire 0xCA -> group 0x0A
;     wire 0xD0 -> group 0x0B
;     wire 0xD1 -> group 0x0C
;     wire 0xD2 -> group 0x0D
;     wire 0xD3 -> group 0x0E
;     wire 0xD7 -> group 0x0F
; ★ WHAT A GROUP ID SELECTS -- established in round 10, applied in round 11:
;   it indexes PanelGroupEventLists_Variant1 (0xF8B446) or _Variant2
;   (0xF8B4B2), whose list says which UI event class and code that wire
;   raises.  PanelGroupQueue_ExpandToEvents does the indexing at 0xF8A846.
; ⚠ AND THE TWO NUMBERINGS DISAGREE FOR THE DIAL.  The physical map in
;   notes/wave7_panel_button_codes.py puts the -1/+1 pair at matrix SEGMENT
;   3; the event table puts its code (0x0D) at GROUP 0x0A, and group ==
;   segment for wires 0xC0-0xCA.  One of the two is wrong; neither has been
;   edited to hide it.
; ---------------------------------------------------------------------

PanelWireGroupMap_Variant1:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A109
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A119
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A129
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A139
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A149
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A159
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A169
	.byte 0x0b, 0x0c, 0x0d, 0x0e, 0x20, 0x20, 0x20, 0x0f, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A179
; ---------------------------------------------------------------------
; PanelWireGroupMap_Variant2 -- 128 bytes, wire address -> group id
; Read by: 0xF8A0BE `ld A,(XIY+L)` with XIY = 0xF8A189, loaded at
;          0xF8A0B9.  The other arm loads 0xF8A109; `cp (0xC4),0x01` at
;          0xF8A0B3 picks between them -- (0xC4) is the MODEL STRAP
;          (prom_a 0xF82882 reads PB bit 0 into it).
; INDEX:   (wire & 0x1F) | ((wire & 0xC0) >> 1), computed at
;          0xF8A0A3-0xF8A0AC.  Bit 5 of the wire is DROPPED, so wire
;          W and W|0x20 read the same entry.
; ENTRY COUNT 128 is the index width: the expression above cannot
;          exceed 0x7F, and 0xF8A209 is where the sibling map starts.
; 0x20 means NO GROUP -- 117 of the 128 entries are 0x20.
; The wires this variant answers to:
;     wire 0xC0 -> group 0x00
;     wire 0xC1 -> group 0x01
;     wire 0xC2 -> group 0x02
;     wire 0xC3 -> group 0x03
;     wire 0xC4 -> group 0x04
;     wire 0xC5 -> group 0x05
;     wire 0xC7 -> group 0x06
;     wire 0xC8 -> group 0x07
;     wire 0xC9 -> group 0x08
;     wire 0xD3 -> group 0x0E
;     wire 0xD7 -> group 0x0F
; ★ WHAT A GROUP ID SELECTS -- established in round 10, applied in round 11:
;   it indexes PanelGroupEventLists_Variant1 (0xF8B446) or _Variant2
;   (0xF8B4B2), whose list says which UI event class and code that wire
;   raises.  PanelGroupQueue_ExpandToEvents does the indexing at 0xF8A846.
; ⚠ AND THE TWO NUMBERINGS DISAGREE FOR THE DIAL.  The physical map in
;   notes/wave7_panel_button_codes.py puts the -1/+1 pair at matrix SEGMENT
;   3; the event table puts its code (0x0D) at GROUP 0x0A, and group ==
;   segment for wires 0xC0-0xCA.  One of the two is wrong; neither has been
;   edited to hide it.
; ---------------------------------------------------------------------

PanelWireGroupMap_Variant2:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A189
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A199
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A1A9
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A1B9
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A1C9
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A1D9
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x20, 0x06, 0x07, 0x08, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A1E9
	.byte 0x20, 0x20, 0x20, 0x0e, 0x20, 0x20, 0x20, 0x0f, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F8A1F9
; AssignableSwitch_Poll -- read the two switch inputs on P7 bits 6 and 7 (variant 1 only)
; Evidence: returns when (0xC4)=2; `ld A,(0x13)` (P7 in include/tmp95c061_sfr.inc); (0x2190)=bit 6, (0x2191)=bit 7, each XORed with bit 0 / bit 1 of (0x7F12); calls AssignableSwitch_PostChanges when either is 1 or word (0x2194) is non-zero.
; Caller: PanelWire_PollProducers.
AssignableSwitch_Poll:
	cp	(Variant_Flag:8), 0x02                               ; F8A209  c0 c4 3f 02
	jr z, .LF8A249                                           ; F8A20D  66 3a
	ld	a, (P7:8)                                      ; F8A20F  c0 13 21
	ld W,A                                               ; F8A212  c9 88
	and A,0x40                                           ; F8A214  c9 cc 40
	srl a, 0x06                                          ; F8A217  c9 ef 06
	bit	0, (0x7f12:16)                               ; F8A21A  f1 12 7f c8
	jr z, .LF8A223                                           ; F8A21E  66 03
	xor A,0x01                                           ; F8A220  c9 cd 01
.LF8A223:
	ld (0x2190:16), a                                   ; F8A223  f1 90 21 41
	and W,0x80                                           ; F8A227  c8 cc 80
	srl w, 0x07                                          ; F8A22A  c8 ef 07
	bit	1, (0x7f12:16)                               ; F8A22D  f1 12 7f c9
	jr z, .LF8A236                                           ; F8A231  66 03
	xor W,0x01                                           ; F8A233  c8 cd 01
.LF8A236:
	ld (0x2191:16), w                                   ; F8A236  f1 91 21 40
	and WA,WA                                            ; F8A23A  d8 c0
	jr nz, .LF8A246                                          ; F8A23C  6e 08
	ld wa, (0x2194:16)                                 ; F8A23E  d1 94 21 20
	and WA,WA                                            ; F8A242  d8 c0
	jr z, .LF8A249                                           ; F8A244  66 03
.LF8A246:
	calr AssignableSwitch_PostChanges                                            ; F8A246  1e 01 00
.LF8A249:
	ret                                                  ; F8A249  0e
; AssignableSwitch_PostChanges -- post a group event for each of the two P7 switches whose state changed (groups 0x16 and 0x17)
; Evidence: (0x219C)=0x16, incremented per input; per input it combines new (0x2190+i), old (0x2192+i) and (0x2194+i), and on a change calls PanelGroupQueue_Append with E=(0x219C), or, when (0x219A)>=7, parks the pair in (0x2185+2i) and sets (0x219D+i) bit 0 for the next call.  Groups 0x16/0x17 are what PanelAction_AssignableSwitch handles (v1, mask 01).
AssignableSwitch_PostChanges:
	link XIZ,0xffec                                      ; F8A24A  ee 0c ec ff
	ld XIX,0x00002190                                    ; F8A24E  44 90 21 00 00
	ld (xiz-4), xix                                      ; F8A253  be fc 64
	ld XIX,0x00002192                                    ; F8A256  44 92 21 00 00
	ld (xiz-8), xix                                      ; F8A25B  be f8 64
	ld XIX,0x00002194                                    ; F8A25E  44 94 21 00 00
	ld (xiz-12), xix                                     ; F8A263  be f4 64
	ld XIX,0x0000219d                                    ; F8A266  44 9d 21 00 00
	ld (xiz-16), xix                                     ; F8A26B  be f0 64
	ld XIX,0x00002185                                    ; F8A26E  44 85 21 00 00
	ld (xiz-20), xix                                     ; F8A273  be ec 64
	ld b, 0x02:opc                                          ; F8A276  22 02
	ld (0x219c:16), 0x16                                 ; F8A278  f1 9c 21 00 16
.LF8A27D:
	ld xix, (xiz-16)                                     ; F8A27D  ae f0 24
	bit 0,(XIX)                                          ; F8A280  b4 c8
	jr z, .LF8A28B                                           ; F8A282  66 07
	ld xix, (xiz-20)                                     ; F8A284  ae ec 24
	ld WA,(XIX)                                          ; F8A287  94 20
	jr .LF8A2B8                                              ; F8A289  68 2d
.LF8A28B:
	ld xix, (xiz-4)                                      ; F8A28B  ae fc 24
	ld A,(XIX)                                           ; F8A28E  84 21
	ld xix, (xiz-8)                                      ; F8A290  ae f8 24
	ld W,(XIX)                                           ; F8A293  84 20
	ld xix, (xiz-12)                                     ; F8A295  ae f4 24
	ld E,(XIX)                                           ; F8A298  84 25
	ld HL,WA                                             ; F8A29A  d8 8b
	ld D,E                                               ; F8A29C  cd 8c
	xor A,W                                              ; F8A29E  c8 d1
	and A,E                                              ; F8A2A0  cd c1
	ld E,A                                               ; F8A2A2  c9 8d
	ld WA,HL                                             ; F8A2A4  db 88
	and A,W                                              ; F8A2A6  c8 c1
	or A,W                                               ; F8A2A8  c8 e1
	ld xix, (xiz-12)                                     ; F8A2AA  ae f4 24
	ld (XIX),A                                           ; F8A2AD  b4 41
	ld W,D                                               ; F8A2AF  cc 88
	ld DE,HL                                             ; F8A2B1  db 8a
	ld xix, (xiz-8)                                      ; F8A2B3  ae f8 24
	ld (XIX),E                                           ; F8A2B6  b4 45
.LF8A2B8:
	xor W,A                                              ; F8A2B8  c9 d0
	jr z, .LF8A2DB                                           ; F8A2BA  66 1f
	cp	(0x219a:16), 0x07                            ; F8A2BC  c1 9a 21 3f 07
	jr c, .LF8A2D0                                           ; F8A2C1  67 0d
	ld xix, (xiz-20)                                     ; F8A2C3  ae ec 24
	ld (XIX),WA                                          ; F8A2C6  b4 50
	ld xix, (xiz-16)                                     ; F8A2C8  ae f0 24
	or	(xix), 0x01                                  ; F8A2CB  84 3e 01
	jr .LF8A2E1                                              ; F8A2CE  68 11
.LF8A2D0:
	push XIZ                                             ; F8A2D0  3e
	pushw bc                                             ; F8A2D1  29
	ld e, (0x219c:16)                                   ; F8A2D2  c1 9c 21 25
	calr PanelGroupQueue_Append                                            ; F8A2D6  1e d9 00
	popw bc                                              ; F8A2D9  49
	pop XIZ                                              ; F8A2DA  5e
.LF8A2DB:
	ld xix, (xiz-16)                                     ; F8A2DB  ae f0 24
	and (XIX),0xfe                                       ; F8A2DE  84 3c fe
.LF8A2E1:
	ld XIX,0x00000001                                    ; F8A2E1  44 01 00 00 00
	add (xiz-4), xix                                     ; F8A2E6  ae fc 8c
	add (xiz-8), xix                                     ; F8A2E9  ae f8 8c
	add (xiz-12), xix                                    ; F8A2EC  ae f4 8c
	add (xiz-16), xix                                    ; F8A2EF  ae f0 8c
	inc 1,XIX                                            ; F8A2F2  ec 61
	add (xiz-20), xix                                    ; F8A2F4  ae ec 8c
	inc 0x01, (0x219c:16)                                ; F8A2F7  c1 9c 21 61
	dec 1,B                                              ; F8A2FB  ca 69
	jrl nz, .LF8A27D                                         ; F8A2FD  7e 7d ff
	unlk XIZ                                             ; F8A300  ee 0d
	ret                                                  ; F8A302  0e
; ---------------------------------------------------------------------
; PanelGroupQueue_AppendFlaggedGroups -- raise a group event for each of six
; RAM FLAG BYTES whose bit 7 is set, then clear that bit.
;
; ★★ THESE ARE SIX OF THE SEVEN NON-WIRE PRODUCERS round 10 located and did
; not read.  Each arm is the same five steps: test bit 7 of the flag byte,
; check the group queue has room, clear bit 7, and call
; PanelGroupQueue_Append with a FIXED group id in E, the flag byte ITSELF
; as the value (A), and 0x7F as the change mask (W).  The six pairs are
;   (0x28EE) -> group 0x10    (0x28F1) -> group 0x13
;   (0x28EF) -> group 0x11    (0x28EC) -> group 0x14
;   (0x28F0) -> group 0x12    (0x28ED) -> group 0x15
; and the variant-1 lists for groups 0x10-0x15 emit classes BA, BB, B4, BD,
; B8, B9 -- every one with CODE 0x00 and a 0x7F whole-field mask.  So the
; delivered event carries the flag byte's LOW SEVEN BITS as a value: six
; continuous-controller-shaped events, not buttons.
; ★ SO SIX OF THE SEVEN CANNOT BE THE MISSING PRODUCER OF CODE 0x0E.
;   UiEvent_RouteByCode has an 0x0E arm that nothing found raises; the last
;   remaining non-wire suspect is 0xF8A2D6, which takes its group from
;   (0x219C) at RUN TIME and therefore cannot be enumerated statically.
; ⚠ Groups 0x16, 0x17 and 0x18 have no producer this tree has found.
; Variant: `cp (0xC4),0x02` at 0xF8A303 skips the whole routine on one
;          model strap.
; Evidence: the six `ldb E,imm8` at 0xF8A31E/0xF8A33A/0xF8A356/0xF8A372/
;          0xF8A38E/0xF8A3AA, the six `and (flag),0x7F` at 0xF8A319/0xF8A335/
;          0xF8A351/0xF8A36D/0xF8A389/0xF8A3A5, the six `cp (0x219A),0x07`
;          guards, and the six `calr` to 0xF8A3B2 at 0xF8A322/0xF8A33E/
;          0xF8A35A/0xF8A376/0xF8A392/0xF8A3AE.
; ---------------------------------------------------------------------

PanelGroupQueue_AppendFlaggedGroups:
	cp	(Variant_Flag:8), 0x02                               ; F8A303  c0 c4 3f 02
	jr z, .LF8A379                                           ; F8A307  66 70
	ld a, (AnalogScan_Cooked+2:16)                                   ; F8A309  c1 ee 28 21
	bit 0x07,A                                           ; F8A30D  c9 33 07
	jr z, .LF8A325                                           ; F8A310  66 13
	cp	(0x219a:16), 0x07                            ; F8A312  c1 9a 21 3f 07
	jr nc, .LF8A325                                          ; F8A317  6f 0c
	and	(AnalogScan_Cooked+2:16), 0x7f                            ; F8A319  c1 ee 28 3c 7f
	ld e, 0x10:opc                                          ; F8A31E  25 10
	ld w, 0x7f:opc                                          ; F8A320  20 7f
	calr PanelGroupQueue_Append                                            ; F8A322  1e 8d 00
.LF8A325:
	ld a, (AnalogScan_Cooked+3:16)                                   ; F8A325  c1 ef 28 21
	bit 0x07,A                                           ; F8A329  c9 33 07
	jr z, .LF8A341                                           ; F8A32C  66 13
	cp	(0x219a:16), 0x07                            ; F8A32E  c1 9a 21 3f 07
	jr nc, .LF8A341                                          ; F8A333  6f 0c
	and	(AnalogScan_Cooked+3:16), 0x7f                            ; F8A335  c1 ef 28 3c 7f
	ld e, 0x11:opc                                          ; F8A33A  25 11
	ld w, 0x7f:opc                                          ; F8A33C  20 7f
	calr PanelGroupQueue_Append                                            ; F8A33E  1e 71 00
.LF8A341:
	ld a, (AnalogScan_Cooked+4:16)                                   ; F8A341  c1 f0 28 21
	bit 0x07,A                                           ; F8A345  c9 33 07
	jr z, .LF8A35D                                           ; F8A348  66 13
	cp	(0x219a:16), 0x07                            ; F8A34A  c1 9a 21 3f 07
	jr nc, .LF8A35D                                          ; F8A34F  6f 0c
	and	(AnalogScan_Cooked+4:16), 0x7f                            ; F8A351  c1 f0 28 3c 7f
	ld e, 0x12:opc                                          ; F8A356  25 12
	ld w, 0x7f:opc                                          ; F8A358  20 7f
	calr PanelGroupQueue_Append                                            ; F8A35A  1e 55 00
.LF8A35D:
	ld a, (AnalogScan_Cooked+5:16)                                   ; F8A35D  c1 f1 28 21
	bit 0x07,A                                           ; F8A361  c9 33 07
	jr z, .LF8A379                                           ; F8A364  66 13
	cp	(0x219a:16), 0x07                            ; F8A366  c1 9a 21 3f 07
	jr nc, .LF8A379                                          ; F8A36B  6f 0c
	and	(AnalogScan_Cooked+5:16), 0x7f                            ; F8A36D  c1 f1 28 3c 7f
	ld e, 0x13:opc                                          ; F8A372  25 13
	ld w, 0x7f:opc                                          ; F8A374  20 7f
	calr PanelGroupQueue_Append                                            ; F8A376  1e 39 00
.LF8A379:
	ld a, (AnalogScan_Cooked:16)                                   ; F8A379  c1 ec 28 21
	bit 0x07,A                                           ; F8A37D  c9 33 07
	jr z, .LF8A395                                           ; F8A380  66 13
	cp	(0x219a:16), 0x07                            ; F8A382  c1 9a 21 3f 07
	jr nc, .LF8A395                                          ; F8A387  6f 0c
	and	(AnalogScan_Cooked:16), 0x7f                            ; F8A389  c1 ec 28 3c 7f
	ld e, 0x14:opc                                          ; F8A38E  25 14
	ld w, 0x7f:opc                                          ; F8A390  20 7f
	calr PanelGroupQueue_Append                                            ; F8A392  1e 1d 00
.LF8A395:
	ld a, (AnalogScan_Cooked+1:16)                                   ; F8A395  c1 ed 28 21
	bit 0x07,A                                           ; F8A399  c9 33 07
	jr z, .LF8A3B1                                           ; F8A39C  66 13
	cp	(0x219a:16), 0x07                            ; F8A39E  c1 9a 21 3f 07
	jr nc, .LF8A3B1                                          ; F8A3A3  6f 0c
	and	(AnalogScan_Cooked+1:16), 0x7f                            ; F8A3A5  c1 ed 28 3c 7f
	ld e, 0x15:opc                                          ; F8A3AA  25 15
	ld w, 0x7f:opc                                          ; F8A3AC  20 7f
	calr PanelGroupQueue_Append                                            ; F8A3AE  1e 01 00
.LF8A3B1:
	ret                                                  ; F8A3B1  0e
; ---------------------------------------------------------------------
; PanelGroupQueue_Append -- append [group][value][change mask] to the group
; queue at RAM 0x2000 and bump the count at (0x219A).
;
; Called from: eight sites, all `calr` -- 0xF8A0F2 (the wire drain), 0xF8A2D6
;          (the run-time-group producer) and the six fixed-group arms of
;          PanelGroupQueue_AppendFlaggedGroups.
; Capacity: SEVEN records.  `cp (XIY),0x07` at 0xF8A3C4 refuses when the
;          count is already 7; the record offset is count*3 (`muls HL,3` at
;          0xF8A3CE), so the queue occupies 0x2000-0x2014 and the terminator
;          one byte past the last record.
; Body:    stores E, W and A in that order through XIX+HL, writes a 0xFF
;          terminator after them, and increments (0x219A).
; Read by: PanelGroupQueue_ExpandToEvents, which is the only consumer.
; ⚠ It also has a variant gate (`cp (0x207A),0xDB` at 0xF8A3B2) and, on one
;          path, calls prom_b through the thunk 0xF434D4 before storing; what
;          that call does is not established here.
; Evidence: `ld XIY,0x0000219A` at 0xF8A3BA, `ld XIX,0x00002000` at 0xF8A3BF,
;          `cp (XIY),0x07` at 0xF8A3C4, `muls HL,0x0003` at 0xF8A3CE, the
;          three stores at 0xF8A42D/0xF8A434/0xF8A43B, the 0xFF terminator at
;          0xF8A442 and `inc (XIY)` at 0xF8A448.
; ---------------------------------------------------------------------

PanelGroupQueue_Append:
	cp	(UI_ScreenLatch:16), 0xdb                            ; F8A3B2  c1 7a 20 3f db
	jrl z, .LF8A44A                                          ; F8A3B7  76 90 00
	ld XIY,0x0000219a                                    ; F8A3BA  45 9a 21 00 00
	ld XIX,0x00002000                                    ; F8A3BF  44 00 20 00 00
	cp (XIY),0x07                                        ; F8A3C4  85 3f 07
	jrl nc, .LF8A44A                                         ; F8A3C7  7f 80 00
	xor XHL,XHL                                          ; F8A3CA  eb d3
	ld L,(XIY)                                           ; F8A3CC  85 27
	muls HL,0x0003                                       ; F8A3CE  db 09 03 00
	or	(0x225a:16), 0x40                            ; F8A3D2  c1 5a 22 3e 40
	cp	(Variant_Flag:8), 0x01                               ; F8A3D7  c0 c4 3f 01
	jr z, .LF8A406                                           ; F8A3DB  66 29
	cp e, 0x02:i3                                          ; F8A3DD  cd da
	jr nz, .LF8A3FB                                          ; F8A3DF  6e 1a
	bit 0x03,W                                           ; F8A3E1  c8 33 03
	jr z, .LF8A3FB                                           ; F8A3E4  66 15
	push XWA                                             ; F8A3E6  38
	push XBC                                             ; F8A3E7  39
	push XDE                                             ; F8A3E8  3a
	push XHL                                             ; F8A3E9  3b
	push XIX                                             ; F8A3EA  3c
	push XIY                                             ; F8A3EB  3d
	push XIZ                                             ; F8A3EC  3e
	pushw wa                                             ; F8A3ED  28
	call T_SystemTest_PlayNotesOnPanelKey                                        ; F8A3EE  1d d4 34 f4
	inc 2,XSP                                            ; F8A3F2  ef 62
	pop XIZ                                              ; F8A3F4  5e
	pop XIY                                              ; F8A3F5  5d
	pop XIX                                              ; F8A3F6  5c
	pop XHL                                              ; F8A3F7  5b
	pop XDE                                              ; F8A3F8  5a
	pop XBC                                              ; F8A3F9  59
	pop XWA                                              ; F8A3FA  58
.LF8A3FB:
	cp e, 0x06:i3                                          ; F8A3FB  cd de
	jr nz, .LF8A42D                                          ; F8A3FD  6e 2e
	cp A,0x0f                                            ; F8A3FF  c9 cf 0f
	jr nz, .LF8A42D                                          ; F8A402  6e 29
	jr .LF8A40F                                              ; F8A404  68 09
.LF8A406:
	cp e, 0x07:i3                                          ; F8A406  cd df
	jr nz, .LF8A42D                                          ; F8A408  6e 23
	cp A,0x0f                                            ; F8A40A  c9 cf 0f
	jr nz, .LF8A42D                                          ; F8A40D  6e 1e
.LF8A40F:
	push XWA                                             ; F8A40F  38
	push XBC                                             ; F8A410  39
	push XDE                                             ; F8A411  3a
	push XHL                                             ; F8A412  3b
	push XIX                                             ; F8A413  3c
	push XIY                                             ; F8A414  3d
	push XIZ                                             ; F8A415  3e
	or	(MIDI_RX_Flags:8), 0x08                               ; F8A416  c0 9e 3e 08
	call T_MIDI_SendAllNotesOff_AllChannels              ; F8A41A  1d 34 07 f4
	call T_Ram3800_InitDataImage                         ; F8A41E  1d d0 13 f4
	call T_Msg0716_PostSysEx50_A3                                        ; F8A422  1d 0c 10 f4
	pop XIZ                                              ; F8A426  5e
	pop XIY                                              ; F8A427  5d
	pop XIX                                              ; F8A428  5c
	pop XHL                                              ; F8A429  5b
	pop XDE                                              ; F8A42A  5a
	pop XBC                                              ; F8A42B  59
	pop XWA                                              ; F8A42C  58
.LF8A42D:
	ld	(xix+hl), e                                  ; F8A42D  f3 07 f0 ec 45
	inc 1,HL                                             ; F8A432  db 61
	ld	(xix+hl), a                                  ; F8A434  f3 07 f0 ec 41
	inc 1,HL                                             ; F8A439  db 61
	ld	(xix+hl), w                                  ; F8A43B  f3 07 f0 ec 40
	inc 1,HL                                             ; F8A440  db 61
	ld	(xix+hl), 0xff                               ; F8A442  f3 07 f0 ec 00 ff
	incm8 0x01, (xiy)                                    ; F8A448  85 61
.LF8A44A:
	ret                                                  ; F8A44A  0e
; ---------------------------------------------------------------------
; Two table addresses the dead copy below still holds from the older build it was copied from.  They are
; not this ROM's tables (no label here may take them): the live copy loads the same tables by name at the
; same points.
	.equ DeadCopy_OldAddr_PanelGroupActionTable_Variant1, 0x00F8AF9F	; live: PanelGroupActionTable_Variant1 (F8A8CC)
	.equ DeadCopy_OldAddr_RecordFieldPtrs_RAM76A2_Plus20, 0x00F8ACF1	; live: RecordFieldPtrs_RAM76A2_Plus20 (F8AA31)

; PanelGroupQueue_ExpandToEvents_DeadCopy -- 0xF8A44B-0xF8A4C5, 123 bytes: a
; NEVER-RELOCATED, UNREACHABLE second copy of the live list walker at
; 0xF8A84B, exactly 0x400 bytes lower.
;
; ★★ THIS IS DEAD CODE, and three independent measurements say so.
;   1. ITS TABLE POINTERS POINT AT NOTHING.  The two copies differ in exactly
;      9 of their first 123 bytes, and all 9 are inside three `imm32` operands
;      or the selector between them.  The live copy's immediates are
;      0xF8B446 / 0xF8B4B2 / 0xF8B74A, whose first four words are 4-of-4
;      in-image pointers.  This copy's are 0xF8ADDD / 0xF8AD71 / 0xF8AF9F,
;      whose first four words are 0-of-4 in-image pointers -- they land in the
;      middle of the action HANDLERS, not in a table.
;   2. ITS BACK EDGE LANDS MID-INSTRUCTION.  The `68 A6` at 0xF8A486 resolves
;      to 0xF8A42E, the SECOND byte of the 5-byte instruction at 0xF8A42D; no
;      linear decode starting anywhere in 0xF8A100-0xF8A42D puts a boundary
;      there (814 starts tried).  The live copy's identical `68 A6` at
;      0xF8A886 resolves to 0xF8A82E, which IS its loop head.
;   3. NOTHING NAMES IT.  A scan of both of CPU 1's ROMs for the 24-bit value
;      0xF8A44B returns ZERO hits; the live entry 0xF8A81D is named by
;      prom_b's routine directory at 0xF40635.
;
; ★ THE TWO RUNS EVEN CARRY LABELS AT THE SAME OFFSETS: sub_F8A49D and
;   PanelEvent_ShiftThenRunAction_DeadCopy sit at +0x52 and +0x56, exactly where the live run carries
;   sub_F8A89D and PanelEvent_ShiftThenRunAction.  They are their dead twins.
;   ⚠ The twinning stops at +0x7B: 0xF8A4C6 onward is NOT a copy of 0xF8A8C6
;   onward, so PanelEvent_ShiftThenRunAction_DeadCopy shares only its first 37 bytes with the live one and
;   is NOT renamed here.
;
; The likely history is a relocated build in which this copy's operands were
; never re-pointed; nothing here proves that, and it is offered as a guess,
; not as a finding.
; Evidence: the nine differing bytes are at 0xF8A44D, 0xF8A44E, 0xF8A451-
;          0xF8A455, 0xF8A458 and 0xF8A459; the in-image-pointer counts and
;          the reference scan are reproduced by
;          notes/prom_a_panel_names_round11.py --stale.
; ---------------------------------------------------------------------

PanelGroupQueue_ExpandToEvents_DeadCopy:
	push XIX                                             ; F8A44B  3c
	ld XIX,PanelKeypad_OrdinalToKey_V1+16                                    ; F8A44C  44 dd ad f8 00
	bit	2, (0x7f37:16)                               ; F8A451  f1 37 7f ca
	jr nz, .LF8A45C                                          ; F8A455  6e 05
	ld XIX,.LF8AD71                                      ; F8A457  44 71 ad f8 00
.LF8A45C:
	ld	xhl, (xix+hl)                                ; F8A45C  e3 07 f0 ec 23
	pop XIX                                              ; F8A461  5c
.LF8A462:
	cp (XHL),0xff                                        ; F8A462  83 3f ff
	jr z, .LF8A484                                           ; F8A465  66 1d
	ld wa, (xhl+)                                     ; F8A467  d5 ed 20
	ld (xix+), wa                                     ; F8A46A  f5 f1 50
	cp XIX,0x0000206c                                    ; F8A46D  ec cf 6c 20 00 00
	jr nc, .LF8A499                                          ; F8A473  6f 24
	inc 1,XHL                                            ; F8A475  eb 61
	ld W,(XHL)                                           ; F8A477  83 20
	ld DE,(XIY)                                          ; F8A479  95 22
	and D,W                                              ; F8A47B  c8 c4
	and E,W                                              ; F8A47D  c8 c5
	calr PanelEvent_ShiftThenRunAction_DeadCopy                                            ; F8A47F  1e 1f 00
	jr .LF8A462                                               ; F8A482  68 de
.LF8A484:
	inc 2,XIY                                            ; F8A484  ed 62
	jr -90                                               ; F8A486  68 a6
	calr sub_F8A49D                                            ; F8A488  1e 12 00
.LF8A48B:
	ld (XIX),0xff                                        ; F8A48B  b4 00 ff
	ld (0x2000:16), 0xff                                 ; F8A48E  f1 00 20 00 ff
	ld (0x219a:16), 0x00                                 ; F8A493  f1 9a 21 00 00
	ret                                                  ; F8A498  0e
.LF8A499:
	dec 2,XIX                                            ; F8A499  ec 6a
	jr .LF8A48B                                               ; F8A49B  68 ee
sub_F8A49D:
	nop                                                  ; F8A49D  00
	nop                                                  ; F8A49E  00
	nop                                                  ; F8A49F  00
	ret                                                  ; F8A4A0  0e
; PanelEvent_ShiftThenRunAction_DeadCopy -- an older, unreachable copy of PanelEvent_ShiftThenRunAction
; Evidence: inside 0xF8A44B-0xF8A7FF, which nothing outside names (PanelGroupQueue_ExpandToEvents_DeadCopy header, check C4).  Byte diff against 0xF8A8A1 over 111 bytes: the first 37 equal, 65 positions differ; the shift/drop logic is the same and the action lookup uses the single table 0xF8AF9F with no (0xC4) select, then `jp (XBC)` or falls to PanelEvent_CommitValue_DeadCopy.
PanelEvent_ShiftThenRunAction_DeadCopy:
	ld a, (xhl-1)                                        ; F8A4A1  8b ff 21
	inc 1,XHL                                            ; F8A4A4  eb 61
	cp a, 0x00:i3                                          ; F8A4A6  c9 d8
	jr z, .LF8A4BF                                           ; F8A4A8  66 15
	bit 0x04,A                                           ; F8A4AA  c9 33 04
	jr z, .LF8A4B8                                           ; F8A4AD  66 09
	and A,0x07                                           ; F8A4AF  c9 cc 07
	.byte 0xcc, 0xfc                                     ; F8A4B2  cc fc   sla A,D
	.byte 0xcd, 0xfc                                     ; F8A4B4  cd fc   sla A,E
	jr .LF8A4BF                                              ; F8A4B6  68 07
.LF8A4B8:
	and A,0x07                                           ; F8A4B8  c9 cc 07
	.byte 0xcc, 0xff                                     ; F8A4BB  cc ff   srl A,D
	.byte 0xcd, 0xff                                     ; F8A4BD  cd ff   srl A,E
.LF8A4BF:
	cp d, 0x00:i3                                          ; F8A4BF  cc d8
	jr nz, .LF8A4C7                                          ; F8A4C1  6e 04
	dec 2,XIX                                            ; F8A4C3  ec 6a
	jr .LF8A503                                              ; F8A4C5  68 3c
.LF8A4C7:
	ld a, (xiy-1)                                        ; F8A4C7  8d ff 21
	push XIY                                             ; F8A4CA  3d
	pushw hl                                             ; F8A4CB  2b
	ld XIY,DeadCopy_OldAddr_PanelGroupActionTable_Variant1 ; F8A4CC  45 9f af f8 00
	ld l, (0x2251:16)                                   ; F8A4D1  c1 51 22 27
	sla l, 0x02                                          ; F8A4D5  cf ec 02
	ld	xiy, (xiy+l)                                 ; F8A4D8  e3 03 f4 ec 25
	xor HL,HL                                            ; F8A4DD  db d3
.LF8A4DF:
	ld	bc, (xiy+hl)                                 ; F8A4DF  d3 07 f4 ec 21
	inc 2,HL                                             ; F8A4E4  db 62
	cp C,0xff                                            ; F8A4E6  cb cf ff
	jr z, .LF8A4F3                                           ; F8A4E9  66 08
	cp WA,BC                                             ; F8A4EB  d9 f0
	jr z, .LF8A4F7                                           ; F8A4ED  66 08
	inc 4,HL                                             ; F8A4EF  db 64
	jr .LF8A4DF                                               ; F8A4F1  68 ec
.LF8A4F3:
	popw hl                                              ; F8A4F3  4b
	pop XIY                                              ; F8A4F4  5d
	jr PanelEvent_CommitValue_DeadCopy                                              ; F8A4F5  68 09
.LF8A4F7:
	ld	xbc, (xiy+hl)                                ; F8A4F7  e3 07 f4 ec 21
	popw hl                                              ; F8A4FC  4b
	pop XIY                                              ; F8A4FD  5d
	jp (xbc)                                             ; F8A4FE  b1 d8
; PanelEvent_CommitValue_DeadCopy -- dead twin of PanelEvent_CommitValue
; Evidence: f5 f1 52 0e (`ld (XIX+),DE / ret`) = the 4 bytes at 0xF8A90B; every caller is inside the unreachable 0xF8A44B-0xF8A7FF region.
PanelEvent_CommitValue_DeadCopy:
	ld (xix+), de                                     ; F8A500  f5 f1 52
.LF8A503:
	ret                                                  ; F8A503  0e
; PanelEvent_Drop_DeadCopy -- dead twin of PanelEvent_Drop
; Evidence: ec 6a 68 fb (`dec 2,XIX / jr` to the `ret`) = the 4 bytes at 0xF8A90F; callers are inside the unreachable region.
PanelEvent_Drop_DeadCopy:
	dec 2,XIX                                            ; F8A504  ec 6a
	jr .LF8A503                                                ; F8A506  68 fb
; ---------------------------------------------------------------------
; LowestSetBitIndex1Based_Copy -- a second, verbatim copy of the routine at
;                           0xF8A913
;
; ★ RENAMED FROM sub_F8A508.  All 20 bytes of 0xF8A508-0xF8A51B are
;          identical to 0xF8A913-0xF8A926: 0 differ (check X13).
; ★ THE NAME IS NOT BORROWED, which is why it may be used at all.  The
;          body is read here: `cp E,0` and return, else `xor C,C`, then
;          `inc 1,C` / `srl E,1` / `jr NC,-7` and `ld E,C` -- count the
;          trailing zeros of E and add one.  That is the algorithm, and
;          it is what the twin at 0xF8A913 is called.
; Evidence: the byte diff above plus the body; check X13 re-runs both,
;          and check X14 asserts the OTHER twin this lever found is NOT
;          named, for the reason in that routine's own header.
; ---------------------------------------------------------------------

LowestSetBitIndex1Based_Copy:
	cp e, 0x00:i3                                          ; F8A508  cd d8
	jr z, .LF8A51B                                           ; F8A50A  66 0f
	push C                                               ; F8A50C  cb 04
	xor C,C                                              ; F8A50E  cb d3
.LF8A510:
	inc 1,C                                              ; F8A510  cb 61
	srl e, 0x01                                          ; F8A512  cd ef 01
	jr nc, .LF8A510                                            ; F8A515  6f f9
	ld E,C                                               ; F8A517  cb 8d
	pop C                                                ; F8A519  cb 05
.LF8A51B:
	ret                                                  ; F8A51B  0e
; ---------------------------------------------------------------------
; IndexToBitMask8_DeadCopy -- E (0..8) -> E = one-hot mask.  The dead
;          module's twin of IndexToBitMask8 (0xF8A927), 0x40B lower and
;          identical but for its table operand (check C3).
; Called by: the dead handler at 0xF8A619 (`calr` at 0xF8A620).
; ---------------------------------------------------------------------
IndexToBitMask8_DeadCopy:
	push XIX                                             ; F8A51C  3c
	cp E,0x08                                            ; F8A51D  cd cf 08
	jr ule, .LF8A524                                         ; F8A520  63 02
	xor E,E                                              ; F8A522  cd d5
.LF8A524:
	ld XIX,BitMask8ByIndex_DeadCopy                            ; F8A524  44 30 a5 f8 00
	ld	e, (xix+e)                                   ; F8A529  c3 03 f0 e8 25
	pop XIX                                              ; F8A52E  5c
	ret                                                  ; F8A52F  0e
; ---------------------------------------------------------------------
; BitMask8ByIndex_DeadCopy -- 9 x u8: 0, then 1<<0 .. 1<<7 (entry k = 1 << (k-1)).
; Read by: IndexToBitMask8_DeadCopy (0xF8A51C) -- `cp E,0x08 / jr ule / xor E,E /
;          ld XIX,<this> / ld E,(XIX+E)`: any E above 8 reads entry 0.
; COUNT 9 = that bound + 1; IndexToBitMask16_DeadCopy starts right after.
; Byte-identical to BitMask8ByIndex (0xF8A93B), 0x40B higher (check C3).
; ⚠ DEAD: 0xF8A44B-0xF8A7FF is unreachable -- nothing outside it names an
;          address in it (check C4); see PanelGroupQueue_ExpandToEvents_DeadCopy.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
BitMask8ByIndex_DeadCopy:
	.byte 0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80  ; F8A530  [0]

; ---------------------------------------------------------------------
; IndexToBitMask16_DeadCopy -- E (0..16) -> DE = one-hot mask; twin of
;          IndexToBitMask16 (0xF8A944), identical but for its table operand.
; Called by: nothing found -- no 24-bit reference in either ROM (C4) and
;          no calr/jrl in prom_a lands on it (C4b).
; ⚠ DEAD: 0xF8A44B-0xF8A7FF is unreachable -- nothing outside it names an
;          address in it (check C4); see PanelGroupQueue_ExpandToEvents_DeadCopy.
; ---------------------------------------------------------------------
IndexToBitMask16_DeadCopy:
	push XIX                                      ; F8A539  3c
	cp E,0x10                                     ; F8A53A  cd cf 10
	jr ule, .LF8A541                                         ; F8A53D  63 02
	xor E,E                                              ; F8A53F  cd d5
.LF8A541:
	sla e, 0x01                                          ; F8A541  cd ec 01
	ld XIX,BitMask16ByIndex_DeadCopy                           ; F8A544  44 50 a5 f8 00
	ld	de, (xix+e)                                  ; F8A549  d3 03 f0 e8 22
	pop XIX                                              ; F8A54E  5c
	ret                                                  ; F8A54F  0e
; ---------------------------------------------------------------------
; BitMask16ByIndex_DeadCopy -- 17 x u16: 0, then 1<<0 .. 1<<15 (entry k = 1 << (k-1)).
; Read by: IndexToBitMask16_DeadCopy (0xF8A539) -- `cp E,0x10 / jr ule / xor E,E /
;          sla 1,E / ld XIX,<this> / ld DE,(XIX+E)`: any E above 16 reads entry 0.
; COUNT 17 = that bound + 1; IndexToBitMask32_DeadCopy starts right after.
; Byte-identical to BitMask16ByIndex (0xF8A95B), 0x40B higher (check C3).
; ⚠ DEAD: 0xF8A44B-0xF8A7FF is unreachable -- nothing outside it names an
;          address in it (check C4); see PanelGroupQueue_ExpandToEvents_DeadCopy.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
BitMask16ByIndex_DeadCopy:
	.short 0x0000, 0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040  ; F8A550  [0]
	.short 0x0080, 0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000  ; F8A560  [8]
	.short 0x8000  ; F8A570  [16]

; ---------------------------------------------------------------------
; IndexToBitMask32_DeadCopy -- E (0..32) -> XDE = one-hot mask; twin of
;          IndexToBitMask32 (0xF8A97D), identical but for its table operand.
; Called by: nothing found (as IndexToBitMask16_DeadCopy).
; ⚠ DEAD: 0xF8A44B-0xF8A7FF is unreachable -- nothing outside it names an
;          address in it (check C4); see PanelGroupQueue_ExpandToEvents_DeadCopy.
; ---------------------------------------------------------------------
IndexToBitMask32_DeadCopy:
	push XIX                                      ; F8A572  3c
	cp E,0x20                                     ; F8A573  cd cf 20
	jr ule, .LF8A57A                                  ; F8A576  63 02
	xor E,E                                              ; F8A578  cd d5
.LF8A57A:
	sla e, 0x02                                          ; F8A57A  cd ec 02
	ld XIX,BitMask32ByIndex_DeadCopy                           ; F8A57D  44 89 a5 f8 00
	ld	xde, (xix+e)                                 ; F8A582  e3 03 f0 e8 22
	pop XIX                                              ; F8A587  5c
	ret                                                  ; F8A588  0e
; ---------------------------------------------------------------------
; BitMask32ByIndex_DeadCopy -- 33 x u32: 0, then 1<<0 .. 1<<31 (entry k = 1 << (k-1)).
; Read by: IndexToBitMask32_DeadCopy (0xF8A572) -- `cp E,0x20 / jr ule / xor E,E /
;          sla 2,E / ld XIX,<this> / ld XDE,(XIX+E)`: any E above 32 reads entry 0.
; COUNT 33 = that bound + 1; the dead handler at 0xF8A60D starts right after.
; Byte-identical to BitMask32ByIndex (0xF8A994), 0x40B higher (check C3).
; ⚠ DEAD: 0xF8A44B-0xF8A7FF is unreachable -- nothing outside it names an
;          address in it (check C4); see PanelGroupQueue_ExpandToEvents_DeadCopy.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
BitMask32ByIndex_DeadCopy:
	.long 0x00000000, 0x00000001, 0x00000002, 0x00000004  ; F8A589  [0]
	.long 0x00000008, 0x00000010, 0x00000020, 0x00000040  ; F8A599  [4]
	.long 0x00000080, 0x00000100, 0x00000200, 0x00000400  ; F8A5A9  [8]
	.long 0x00000800, 0x00001000, 0x00002000, 0x00004000  ; F8A5B9  [12]
	.long 0x00008000, 0x00010000, 0x00020000, 0x00040000  ; F8A5C9  [16]
	.long 0x00080000, 0x00100000, 0x00200000, 0x00400000  ; F8A5D9  [20]
	.long 0x00800000, 0x01000000, 0x02000000, 0x04000000  ; F8A5E9  [24]
	.long 0x08000000, 0x10000000, 0x20000000, 0x40000000  ; F8A5F9  [28]
	.long 0x80000000  ; F8A609  [32]
	cp e, 0x00:i3                                          ; F8A60D  cd d8
	jr z, .LF8A615                                           ; F8A60F  66 04
	jp PanelEvent_CommitValue_DeadCopy                                        ; F8A611  1b 00 a5 f8
.LF8A615:
	jp PanelEvent_Drop_DeadCopy                                        ; F8A615  1b 04 a5 f8
	cp e, 0x00:i3                                          ; F8A619  cd d8
	jr z, .LF8A648                                           ; F8A61B  66 2b
	calr LowestSetBitIndex1Based_Copy                                          ; F8A61D  1e e8 fe
	calr IndexToBitMask8_DeadCopy                                          ; F8A620  1e f9 fe
	ld d, 0x3f:opc                                          ; F8A623  24 3f
	push XIX                                             ; F8A625  3c
	ld XIX,DeadCopy_OldAddr_RecordFieldPtrs_RAM76A2_Plus20 ; F8A626  44 f1 ac f8 00
	ld a, (UI_PartIndex:16)                                   ; F8A62B  c1 50 22 21
	sla a, 0x02                                          ; F8A62F  c9 ec 02
	ld	xix, (xix+a)                                 ; F8A632  e3 03 f0 e0 24
	ld A,(XIX+0x18)                                      ; F8A637  8c 18 21
	pop XIX                                              ; F8A63A  5c
	bit 0x00,A                                           ; F8A63B  c9 33 00
	jr z, .LF8A644                                           ; F8A63E  66 04
	ld (xix-1), 0x1a                                     ; F8A640  bc ff 00 1a
.LF8A644:
	jp PanelEvent_CommitValue_DeadCopy                                        ; F8A644  1b 00 a5 f8
.LF8A648:
	jp PanelEvent_Drop_DeadCopy                                        ; F8A648  1b 04 a5 f8
	cp e, 0x00:i3                                          ; F8A64C  cd d8
	jr z, .LF8A662                                           ; F8A64E  66 12
	ldw de, 0x7f40                                       ; F8A650  32 40 7f
	calr PanelEvent_CommitValue_DeadCopy                                          ; F8A653  1e aa fe
	ldw (xix+), 0x00b9                            ; F8A656  f5 f1 02 b9 00
	ldw de, 0x7f40                                       ; F8A65B  32 40 7f
	jp PanelEvent_CommitValue_DeadCopy                                        ; F8A65E  1b 00 a5 f8
.LF8A662:
	jp PanelEvent_Drop_DeadCopy                                        ; F8A662  1b 04 a5 f8
	cp	(0x2806:16), 0x00                            ; F8A666  c1 06 28 3f 00
	jr nz, .LF8A682                                          ; F8A66B  6e 15
	calr LowestSetBitIndex1Based_Copy                                          ; F8A66D  1e 98 fe
	extz DE                                              ; F8A670  da 12
	extz XDE                                             ; F8A672  ea 12
	add XDE,PanelOrdinalToEventValue_A_DeadCopy                       ; F8A674  ea c8 86 a6 f8 00
	ld E,(XDE)                                           ; F8A67A  82 25
	ld d, 0xff:opc                                          ; F8A67C  24 ff
	jp PanelEvent_CommitValue_DeadCopy                                        ; F8A67E  1b 00 a5 f8
.LF8A682:
	jp PanelEvent_Drop_DeadCopy                                        ; F8A682  1b 04 a5 f8
; ---------------------------------------------------------------------
; PanelOrdinalToEventValue_A_DeadCopy -- 9 bytes, identical to
;          PanelOrdinalToEventValue_A (0xF8AB39) (check C5).
; Read by: the unlabelled handler at 0xF8A666 -- `add XDE,<this> / ld E,(XDE)`
;          at 0xF8A674, then `ld D,0xFF / jp PanelEvent_CommitValue_DeadCopy`, the dead module's
;          `ld (XIX+),DE`.  It is an OLDER form of the live handler 0xF8AB08:
;          it lacks the value-3 / (0x3614) bit-0 case.  No pool record names
;          0xF8A666 (check C1).
; COUNT 9 = ordinals 0..8, as its live twin.
; ⚠ DEAD: 0xF8A44B-0xF8A7FF is unreachable -- nothing outside it names an
;          address in it (check C4); see PanelGroupQueue_ExpandToEvents_DeadCopy.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
PanelOrdinalToEventValue_A_DeadCopy:
	.byte 0x00, 0x09, 0x0a, 0x12, 0x15, 0x08, 0x03, 0x00, 0x00  ; F8A686  [0]
	cp	(0x2806:16), 0x00                            ; F8A68F  c1 06 28 3f 00
	jr nz, .LF8A6AB                                          ; F8A694  6e 15
	calr LowestSetBitIndex1Based_Copy                                          ; F8A696  1e 6f fe
	extz DE                                              ; F8A699  da 12
	extz XDE                                             ; F8A69B  ea 12
	add XDE,PanelOrdinalToEventValue_B_DeadCopy                       ; F8A69D  ea c8 af a6 f8 00
	ld E,(XDE)                                           ; F8A6A3  82 25
	ld d, 0xff:opc                                          ; F8A6A5  24 ff
	jp PanelEvent_CommitValue_DeadCopy                                        ; F8A6A7  1b 00 a5 f8
.LF8A6AB:
	jp PanelEvent_Drop_DeadCopy                                        ; F8A6AB  1b 04 a5 f8
; ---------------------------------------------------------------------
; PanelOrdinalToEventValue_B_DeadCopy -- 9 bytes, identical to
;          PanelOrdinalToEventValue_B (0xF8AB67) (check C5).
; Read by: the unlabelled handler at 0xF8A68F -- `add XDE,<this> / ld E,(XDE)`
;          at 0xF8A69D, then `ld D,0xFF / jp PanelEvent_CommitValue_DeadCopy`.  An OLDER form of
;          the live handler 0xF8AB42, which also clears bit 0 of (0x3614).
;          No pool record names 0xF8A68F (check C1).
; COUNT 9 = ordinals 0..8, as its live twin.
; ⚠ DEAD: 0xF8A44B-0xF8A7FF is unreachable -- nothing outside it names an
;          address in it (check C4); see PanelGroupQueue_ExpandToEvents_DeadCopy.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
PanelOrdinalToEventValue_B_DeadCopy:
	.byte 0x00, 0x01, 0x02, 0x17, 0x16, 0x00, 0x00, 0x00, 0x00  ; F8A6AF  [0]
	cp e, 0x00:i3                                          ; F8A6B8  cd d8
	jr z, .LF8A722                                           ; F8A6BA  66 66
	ld d, 0x3f:opc                                          ; F8A6BC  24 3f
	ld a, (0x7f02:16)                                   ; F8A6BE  c1 02 7f 21
	and A,0xf0                                           ; F8A6C2  c9 cc f0
	cp a, 0x00:i3                                          ; F8A6C5  c9 d8
	jr z, .LF8A702                                           ; F8A6C7  66 39
	ld a, (0x7f04:16)                                   ; F8A6C9  c1 04 7f 21
	and A,0x3f                                           ; F8A6CD  c9 cc 3f
	ld w, (SoundSel_Bank:16)                                   ; F8A6D0  c1 6a 21 20
.LF8A6D4:
	cp A,0x18                                            ; F8A6D4  c9 cf 18
	jr c, .LF8A6F0                                           ; F8A6D7  67 17
	cp A,0x1a                                            ; F8A6D9  c9 cf 1a
	jr ugt, .LF8A6F0                                         ; F8A6DC  6b 12
	cp W,0x18                                            ; F8A6DE  c8 cf 18
	jr c, .LF8A6EC                                           ; F8A6E1  67 09
	cp W,0x1a                                            ; F8A6E3  c8 cf 1a
	jr ugt, .LF8A6EC                                         ; F8A6E6  6b 04
	ld e, 0x00:opc                                          ; F8A6E8  25 00
	jr .LF8A71E                                              ; F8A6EA  68 32
.LF8A6EC:
	ld E,A                                               ; F8A6EC  c9 8d
	jr .LF8A71E                                              ; F8A6EE  68 2e
.LF8A6F0:
	cp W,0x18                                            ; F8A6F0  c8 cf 18
; (sub_F8A6F3 removed 2026-10-04: no code names it and the line above falls through into it -- part of PanelOrdinalToEventValue_B_DeadCopy;
;  notes/prom_a_stray_label_removal.py)
	jr c, .LF8A6FE                                           ; F8A6F3  67 09
	cp W,0x1a                                            ; F8A6F5  c8 cf 1a
	jr ugt, .LF8A6FE                                         ; F8A6F8  6b 04
	ld E,A                                               ; F8A6FA  c9 8d
	jr .LF8A71E                                              ; F8A6FC  68 20
.LF8A6FE:
	ld e, 0x18:opc                                          ; F8A6FE  25 18
	jr .LF8A71E                                              ; F8A700  68 1c
.LF8A702:
	ld a, 0x04:opc                                          ; F8A702  21 04
	mul	wa, (UI_PartIndex:16)                              ; F8A704  c1 50 22 41
	add WA,0x0080                                        ; F8A708  d8 c8 80 00
	extz XWA                                             ; F8A70C  e8 12
	add xwa, (IndexedTable_Base:24)                           ; F8A70E  e2 18 f0 60 80
	ld XWA,(XWA)                                         ; F8A713  a0 20
	ld A,(XWA+0x1d)                                      ; F8A715  88 1d 21
	ld w, (SoundSel_Bank:16)                                   ; F8A718  c1 6a 21 20
	jr .LF8A6D4                                               ; F8A71C  68 b6
.LF8A71E:
	jp PanelEvent_CommitValue_DeadCopy                                        ; F8A71E  1b 00 a5 f8
.LF8A722:
	jp PanelEvent_Drop_DeadCopy                                        ; F8A722  1b 04 a5 f8
	cp e, 0x00:i3                                          ; F8A726  cd d8
	jrl z, .LF8A7D7                                          ; F8A728  76 ac 00
	calr LowestSetBitIndex1Based_Copy                                          ; F8A72B  1e da fd
	ld d, 0x3f:opc                                          ; F8A72E  24 3f
	ld a, (SoundSel_Bank:16)                                   ; F8A730  c1 6a 21 21
	cp A,0x18                                            ; F8A734  c9 cf 18
	jr c, .LF8A744                                           ; F8A737  67 0b
	cp A,0x1a                                            ; F8A739  c9 cf 1a
	jr ugt, .LF8A744                                         ; F8A73C  6b 06
	add E,0x17                                           ; F8A73E  cd c8 17
	jrl .LF8A7D3                                             ; F8A741  78 8f 00
.LF8A744:
	ld a, (0x7f02:16)                                   ; F8A744  c1 02 7f 21
	and A,0xf0                                           ; F8A748  c9 cc f0
	cp a, 0x00:i3                                          ; F8A74B  c9 d8
	jr z, .LF8A777                                           ; F8A74D  66 28
	ld a, (0x7f04:16)                                   ; F8A74F  c1 04 7f 21
	and A,0x3f                                           ; F8A753  c9 cc 3f
	cp e, 0x01:i3                                          ; F8A756  cd d9
	jr nz, .LF8A75E                                          ; F8A758  6e 04
	ld e, 0x08:opc                                          ; F8A75A  25 08
	jr .LF8A7D3                                              ; F8A75C  68 75
.LF8A75E:
	cp e, 0x02:i3                                          ; F8A75E  cd da
	jr z, .LF8A7D7                                           ; F8A760  66 75
	cp e, 0x03:i3                                          ; F8A762  cd db
	jr nz, .LF8A7D7                                          ; F8A764  6e 71
	cp a, 0x00:i3                                          ; F8A766  c9 d8
	jr z, .LF8A773                                           ; F8A768  66 09
	cp A,0x10                                            ; F8A76A  c9 cf 10
	jr z, .LF8A773                                           ; F8A76D  66 04
	ld e, 0x00:opc                                          ; F8A76F  25 00
	jr .LF8A7D3                                              ; F8A771  68 60
.LF8A773:
	ld E,A                                               ; F8A773  c9 8d
	jr .LF8A7D3                                              ; F8A775  68 5c
.LF8A777:
	ld a, 0x04:opc                                          ; F8A777  21 04
	mul	wa, (UI_PartIndex:16)                              ; F8A779  c1 50 22 41
	add WA,0x0080                                        ; F8A77D  d8 c8 80 00
	extz XWA                                             ; F8A781  e8 12
	add xwa, (IndexedTable_Base:24)                           ; F8A783  e2 18 f0 60 80
	ld XWA,(XWA)                                         ; F8A788  a0 20
	ld A,(XWA+0x1d)                                      ; F8A78A  88 1d 21
	cp e, 0x01:i3                                          ; F8A78D  cd d9
	jr nz, .LF8A79F                                          ; F8A78F  6e 0e
	cp A,0x08                                            ; F8A791  c9 cf 08
	jr z, .LF8A7D1                                           ; F8A794  66 3b
	cp A,0x28                                            ; F8A796  c9 cf 28
	jr z, .LF8A7D1                                           ; F8A799  66 36
	ld e, 0x08:opc                                          ; F8A79B  25 08
	jr .LF8A7D3                                              ; F8A79D  68 34
.LF8A79F:
	cp e, 0x02:i3                                          ; F8A79F  cd da
	jr nz, .LF8A7B1                                          ; F8A7A1  6e 0e
	cp A,0x09                                            ; F8A7A3  c9 cf 09
	jr z, .LF8A7D1                                           ; F8A7A6  66 29
	cp A,0x29                                            ; F8A7A8  c9 cf 29
	jr z, .LF8A7D1                                           ; F8A7AB  66 24
	ld e, 0x09:opc                                          ; F8A7AD  25 09
	jr .LF8A7D3                                              ; F8A7AF  68 22
.LF8A7B1:
	cp e, 0x03:i3                                          ; F8A7B1  cd db
	jr nz, .LF8A7D7                                          ; F8A7B3  6e 22
	cp a, 0x01:i3                                          ; F8A7B5  c9 d9
	jr ule, .LF8A7D1                                         ; F8A7B7  63 18
	cp A,0x10                                            ; F8A7B9  c9 cf 10
	jr z, .LF8A7D1                                           ; F8A7BC  66 13
	cp A,0x20                                            ; F8A7BE  c9 cf 20
	jr z, .LF8A7D1                                           ; F8A7C1  66 0e
	cp A,0x21                                            ; F8A7C3  c9 cf 21
	jr z, .LF8A7D1                                           ; F8A7C6  66 09
	cp A,0x30                                            ; F8A7C8  c9 cf 30
	jr z, .LF8A7D1                                           ; F8A7CB  66 04
	ld e, 0x00:opc                                          ; F8A7CD  25 00
	jr .LF8A7D3                                              ; F8A7CF  68 02
.LF8A7D1:
	ld E,A                                               ; F8A7D1  c9 8d
.LF8A7D3:
	jp PanelEvent_CommitValue_DeadCopy                                        ; F8A7D3  1b 00 a5 f8
.LF8A7D7:
	jp PanelEvent_Drop_DeadCopy                                        ; F8A7D7  1b 04 a5 f8
	bit	1, (UI_RequestBits:16)                               ; F8A7DB  f1 75 20 c9
	jr nz, PanelEvent_Service                                          ; F8A7DF  6e 3c
	cp e, 0x00:i3                                          ; F8A7E1  cd d8
	jr z, 0x34                                           ; F8A7E3  66 34
	calr LowestSetBitIndex1Based_Copy                                          ; F8A7E5  1e 20 fd
	dec 1,E                                              ; F8A7E8  cd 69
	cp a, 0x01:i3                                          ; F8A7EA  c9 d9
	jr z, .LF8A7F1                                           ; F8A7EC  66 03
	add E,0x08                                           ; F8A7EE  cd c8 08
.LF8A7F1:
	ld d, 0x0f:opc                                          ; F8A7F1  24 0f
	ld a, (0x7f02:16)                                   ; F8A7F3  c1 02 7f 21
	and A,0xf0                                           ; F8A7F7  c9 cc f0
	cp a, 0x00:i3                                          ; F8A7FA  c9 d8
	jr nz, .LF8A811                                          ; F8A7FC  6e 13
	ld A,E                                               ; F8A7FE  cd 89
; PanelEvent_PhaseVector: the boot phase vector of module 4 -- ModuleInitDirectory_F82641 reaches it; the walker calls slot k (4 bytes)
;   for boot phase k (notes/prom_a_module_boot_phase_names.py).  2026-10-04.
PanelEvent_PhaseVector:
	jp PanelEvent_BootPhase0                                        ; F8A800  1b 18 a8 f8
	ret                                                  ; F8A804  0e
	nop                                                  ; F8A805  00
	nop                                                  ; F8A806  00
	nop                                                  ; F8A807  00
	ret                                                  ; F8A808  0e
	nop                                                  ; F8A809  00
	nop                                                  ; F8A80A  00
	nop                                                  ; F8A80B  00
	ret                                                  ; F8A80C  0e
	nop                                                  ; F8A80D  00
	nop                                                  ; F8A80E  00
	nop                                                  ; F8A80F  00
	ret                                                  ; F8A810  0e
.LF8A811:
	nop                                                  ; F8A811  00
	nop                                                  ; F8A812  00
	nop                                                  ; F8A813  00
	ret                                                  ; F8A814  0e
	nop                                                  ; F8A815  00
	nop                                                  ; F8A816  00
	nop                                                  ; F8A817  00
; PanelEvent_BootPhase0: module 4's boot phase 0 handler (vector 0xF8A800, the PanelEvent_* block): T_AsciiField_Clear.
PanelEvent_BootPhase0:
	call T_AsciiField_Clear                              ; F8A818  1d f8 32 f4
	ret                                                  ; F8A81C  0e
; PanelEvent_Service -- expand the panel group queue into UI events, then post-process the event list
; Evidence: prom_b slot T_PanelEvent_Service is `jp PanelEvent_Service`, called from MainTask_Loop 0xF820F1; body `calr PanelGroupQueue_ExpandToEvents / calr PanelEvents_StampCurrentPart / ret` (PanelEvents_StampCurrentPart walks the 0x2030 list, class 0x20 -> Var2250_AcceptList check, class 0 -> PanelEvent_StampPartIntoClass00).
PanelEvent_Service:
	calr PanelGroupQueue_ExpandToEvents                                            ; F8A81D  1e 04 00
	calr PanelEvents_StampCurrentPart                                          ; F8A820  1e a1 0a
	ret                                                  ; F8A823  0e
; ---------------------------------------------------------------------
; PanelGroupQueue_ExpandToEvents -- turn the group queue at RAM 0x2000 into
; UI events in the fixed list at RAM 0x2030.  ★★ THIS IS THE ROUTINE THAT
; READS THE LAYER-2 TABLES.
;
; Called from: PanelEvent_Service (`calr` at 0xF8A81D), which prom_b's routine
;          directory publishes as slot 0xF40634.  No 24-bit reference to
;          0xF8A824 itself exists in either of CPU 1's ROMs.
; Body:    XIY = 0x2000, XIX = 0x2030.  Per queue record it reads the GROUP
;          byte, stops on 0xFF or 0xFE, REJECTS a group above 0x18, stores
;          the group to (0x2251) for the action-table lookup, and indexes
;          PanelGroupEventLists_Variant1/2 with group*4.  It then walks that
;          list: [class] and [code] are copied straight into the event,
;          [mask] selects which bits of the wire byte the record owns, and
;          [shift] normalises those bits down to positions 0-1.  A record
;          whose masked CHANGE is zero is discarded (`dec 2,XIX`).
; Bounds:  `cp XIX,0x0000206C` at 0xF8A86D is the 15-record capacity of the
;          0x2030 list -- the same ceiling List2030_AppendRegs enforces.  On
;          exit it writes 0xFF to (XIX), 0xFF to (0x2000) and 0 to (0x219A),
;          emptying the group queue.
; Variant: `cp (0xC4),0x01` at 0xF8A851 picks variant 1 or 2; (0xC4) is the
;          MODEL STRAP that prom_a 0xF82882 loads from PB bit 0.
; ⚠ A NEVER-RELOCATED COPY of this routine's list walker sits 0x400 lower at
;          PanelGroupQueue_ExpandToEvents_DeadCopy (0xF8A44B).
; Evidence: `ld XIY,0x00002000` at 0xF8A824, `ld XIX,0x00002030` at 0xF8A829,
;          `cp A,0x18` at 0xF8A83B, `ld (0x2251),A` at 0xF8A840,
;          `ld XIX,0x00F8B446` at 0xF8A84C, `ld XIX,0x00F8B4B2` at 0xF8A857,
;          `cp (XHL),0xff` at 0xF8A862, `cp XIX,0x0000206C` at 0xF8A86D,
;          `ld (XIX+),DE` at 0xF8A90B.
; ---------------------------------------------------------------------

PanelGroupQueue_ExpandToEvents:
	ld XIY,0x00002000                                    ; F8A824  45 00 20 00 00
	ld XIX,0x00002030                                    ; F8A829  44 30 20 00 00
.LF8A82E:
	ld a, (xiy+)                                      ; F8A82E  c5 f4 21
	cp A,0xff                                            ; F8A831  c9 cf ff
	jr z, .LF8A88B                                           ; F8A834  66 55
	cp A,0xfe                                            ; F8A836  c9 cf fe
	jr z, .LF8A888                                           ; F8A839  66 4d
	cp A,0x18                                            ; F8A83B  c9 cf 18
	jr ugt, .LF8A884                                         ; F8A83E  6b 44
	ld (0x2251:16), a                                   ; F8A840  f1 51 22 41
	xor W,W                                              ; F8A844  c8 d0
	sla wa, 0x02                                         ; F8A846  d8 ec 02
	ld HL,WA                                             ; F8A849  d8 8b
	push XIX                                             ; F8A84B  3c
	ld XIX,PanelGroupEventLists_Variant1                 ; F8A84C  44 46 b4 f8 00
	cp	(Variant_Flag:8), 0x01                               ; F8A851  c0 c4 3f 01
	jr z, .LF8A85C                                           ; F8A855  66 05
	ld XIX,PanelGroupEventLists_Variant2                 ; F8A857  44 b2 b4 f8 00
.LF8A85C:
	ld	xhl, (xix+hl)                                ; F8A85C  e3 07 f0 ec 23
	pop XIX                                              ; F8A861  5c
.LF8A862:
	cp (XHL),0xff                                        ; F8A862  83 3f ff
	jr z, .LF8A884                                           ; F8A865  66 1d
	ld wa, (xhl+)                                     ; F8A867  d5 ed 20
	ld (xix+), wa                                     ; F8A86A  f5 f1 50
	cp XIX,0x0000206c                                    ; F8A86D  ec cf 6c 20 00 00
	jr nc, .LF8A899                                          ; F8A873  6f 24
	inc 1,XHL                                            ; F8A875  eb 61
	ld W,(XHL)                                           ; F8A877  83 20
	ld DE,(XIY)                                          ; F8A879  95 22
	and D,W                                              ; F8A87B  c8 c4
	and E,W                                              ; F8A87D  c8 c5
	calr PanelEvent_ShiftThenRunAction                                            ; F8A87F  1e 1f 00
	jr .LF8A862                                               ; F8A882  68 de
.LF8A884:
	inc 2,XIY                                            ; F8A884  ed 62
	jr .LF8A82E                                               ; F8A886  68 a6
.LF8A888:
	calr sub_F8A89D                                            ; F8A888  1e 12 00
.LF8A88B:
	ld (XIX),0xff                                        ; F8A88B  b4 00 ff
	ld (0x2000:16), 0xff                                 ; F8A88E  f1 00 20 00 ff
	ld (0x219a:16), 0x00                                 ; F8A893  f1 9a 21 00 00
	ret                                                  ; F8A898  0e
.LF8A899:
	dec 2,XIX                                            ; F8A899  ec 6a
	jr .LF8A88B                                               ; F8A89B  68 ee
sub_F8A89D:
	nop                                                  ; F8A89D  00
	nop                                                  ; F8A89E  00
	nop                                                  ; F8A89F  00
	ret                                                  ; F8A8A0  0e
; ---------------------------------------------------------------------
; PanelEvent_ShiftThenRunAction -- normalise one event-list record's two bits,
; then give the per-group ACTION list a chance to intercept before the value
; pair is committed.
;
; Called from: PanelGroupQueue_ExpandToEvents, `calr` at 0xF8A87F, once per
;          surviving list record.
; Body, in order:
;   1. read the record's SHIFT byte; a zero shift skips to the action lookup;
;   2. `bit 4` picks direction and `and A,0x07` the count, then D (the masked
;      change) and E (the masked value) are shifted together;
;   3. if D is now zero the event is DROPPED -- `dec 2,XIX` at 0xF8A8C3 backs
;      the event pointer up over the class/code pair already written;
;   4. otherwise index PanelGroupActionTable_Variant1/2 by (0x2251), walk its
;      6-byte records for a matching (mask, group) pair, and `jp (XBC)` to the
;      handler if one matches;
;   5. with no match, fall through to 0xF8A90B, which commits `ld (XIX+),DE`.
; ★ A HANDLER MAY REWRITE THE CODE the walker already stored -- `add
;   (XIX-1),0x11` at 0xF8AE7E/0xF8AEF1 and `ld (XIX-1),0x19` at
;   0xF8AE8A/0xF8AEFD -- or drop the event by ending at 0xF8A90F.
; ⚠ WHICH BRANCH RUNS is a run-time property; nothing here establishes it.
; Evidence: `ld A,(XHL-1)` at 0xF8A8A1, `bit 0x04,A` at 0xF8A8AA, `and A,0x07`
;          at 0xF8A8AF and 0xF8A8B8, `dec 2,XIX` at 0xF8A8C3,
;          `ld L,(0x2251)` at 0xF8A8DC, `ld XIY,0x00F8B74A` at 0xF8A8CC,
;          `cp C,0xff` at 0xF8A8F1, `cp WA,BC` at 0xF8A8F6, `jp (XBC)` at
;          0xF8A909.
; ---------------------------------------------------------------------

PanelEvent_ShiftThenRunAction:
	ld a, (xhl-1)                                        ; F8A8A1  8b ff 21
	inc 1,XHL                                            ; F8A8A4  eb 61
	cp a, 0x00:i3                                          ; F8A8A6  c9 d8
	jr z, .LF8A8BF                                           ; F8A8A8  66 15
	bit 0x04,A                                           ; F8A8AA  c9 33 04
	jr z, .LF8A8B8                                           ; F8A8AD  66 09
	and A,0x07                                           ; F8A8AF  c9 cc 07
	.byte 0xcc, 0xfc                                     ; F8A8B2  cc fc   sla A,D
	.byte 0xcd, 0xfc                                     ; F8A8B4  cd fc   sla A,E
	jr .LF8A8BF                                              ; F8A8B6  68 07
.LF8A8B8:
	and A,0x07                                           ; F8A8B8  c9 cc 07
	.byte 0xcc, 0xff                                     ; F8A8BB  cc ff   srl A,D
	.byte 0xcd, 0xff                                     ; F8A8BD  cd ff   srl A,E
.LF8A8BF:
	cp d, 0x00:i3                                          ; F8A8BF  cc d8
	jr nz, .LF8A8C7                                          ; F8A8C1  6e 04
	dec 2,XIX                                            ; F8A8C3  ec 6a
	jr .LF8A90E                                              ; F8A8C5  68 47
.LF8A8C7:
	ld a, (xiy-1)                                        ; F8A8C7  8d ff 21
	push XIY                                             ; F8A8CA  3d
	pushw hl                                             ; F8A8CB  2b
	ld XIY,PanelGroupActionTable_Variant1                ; F8A8CC  45 4a b7 f8 00
	cp	(Variant_Flag:8), 0x01                               ; F8A8D1  c0 c4 3f 01
	jr z, .LF8A8DC                                           ; F8A8D5  66 05
	ld XIY,PanelGroupActionTable_Variant2                ; F8A8D7  45 ae b7 f8 00
.LF8A8DC:
	ld l, (0x2251:16)                                   ; F8A8DC  c1 51 22 27
	sla l, 0x02                                          ; F8A8E0  cf ec 02
	ld	xiy, (xiy+l)                                 ; F8A8E3  e3 03 f4 ec 25
	xor HL,HL                                            ; F8A8E8  db d3
.LF8A8EA:
	ld	bc, (xiy+hl)                                 ; F8A8EA  d3 07 f4 ec 21
	inc 2,HL                                             ; F8A8EF  db 62
	cp C,0xff                                            ; F8A8F1  cb cf ff
	jr z, .LF8A8FE                                           ; F8A8F4  66 08
	cp WA,BC                                             ; F8A8F6  d9 f0
	jr z, .LF8A902                                           ; F8A8F8  66 08
	inc 4,HL                                             ; F8A8FA  db 64
	jr .LF8A8EA                                               ; F8A8FC  68 ec
.LF8A8FE:
	popw hl                                              ; F8A8FE  4b
	pop XIY                                              ; F8A8FF  5d
	jr PanelEvent_CommitValue                                              ; F8A900  68 09
.LF8A902:
	ld	xbc, (xiy+hl)                                ; F8A902  e3 07 f4 ec 21
	popw hl                                              ; F8A907  4b
	pop XIY                                              ; F8A908  5d
	jp (xbc)                                             ; F8A909  b1 d8
; PanelEvent_CommitValue -- commit the (D,E) value pair of the current event: `ld (XIX+),DE / ret`
; Evidence: PanelEvent_ShiftThenRunAction falls into it when no action record matches (0xF8A900), and the action handlers end with `jp PanelEvent_CommitValue` (20 jump/call sites, e.g. PanelAction_AssignableController, PanelAction_Keypad_V2); PanelEvent_ShiftThenRunAction's header calls this the commit.
PanelEvent_CommitValue:
	ld (xix+), de                                     ; F8A90B  f5 f1 52
.LF8A90E:
	ret                                                  ; F8A90E  0e
; PanelEvent_Drop -- drop the current event: `dec 2,XIX`, then return
; Evidence: backs XIX over the class/code pair PanelGroupQueue_ExpandToEvents already stored, as the shift-to-zero path at 0xF8A8C3 does; action handlers end with `jp PanelEvent_Drop` to discard (15 sites).
PanelEvent_Drop:
	dec 2,XIX                                            ; F8A90F  ec 6a
	jr .LF8A90E                                                ; F8A911  68 fb
; ---------------------------------------------------------------------
; LowestSetBitIndex1Based -- E := 1-based position of E's lowest set bit.
;
; E = 0 returns 0 unchanged (`cps E,0x00` / `jr z` at 0xF8A913).  Otherwise C is
; counted up from 0 while E is shifted right until the carry comes out set,
; so bit 0 gives 1 and bit 7 gives 8; C is copied back into E.  C is saved
; and restored, so the only register the caller sees changed is E.
; ★ IT IS THE INVERSE OF IndexToBitMask8, 20 bytes above it.
; Evidence: `cps E,0x00` at 0xF8A913, `inc 1,C` at 0xF8A91B, `srl E,1` at
;          0xF8A91D, `jr nc,-7` at 0xF8A920, `ld E,C` at 0xF8A922.
; ---------------------------------------------------------------------

LowestSetBitIndex1Based:
	cp e, 0x00:i3                                          ; F8A913  cd d8
	jr z, .LF8A926                                           ; F8A915  66 0f
	push C                                               ; F8A917  cb 04
	xor C,C                                              ; F8A919  cb d3
.LF8A91B:
	inc 1,C                                              ; F8A91B  cb 61
	srl e, 0x01                                          ; F8A91D  cd ef 01
	jr nc, .LF8A91B                                            ; F8A920  6f f9
	ld E,C                                               ; F8A922  cb 8d
	pop C                                                ; F8A924  cb 05
.LF8A926:
	ret                                                  ; F8A926  0e
; ---------------------------------------------------------------------
; IndexToBitMask8 -- E (0..8) -> E = one-hot 8-bit mask, by table lookup.
;
; `cp E,0x08` / `jr ule` at 0xF8A928 lets 0..8 through and forces anything
; larger to 0, which selects entry 0 -- the ZERO mask, not the top entry.
; The table is BitMask8ByIndex immediately below.
; ★ It is the inverse of LowestSetBitIndex1Based, and the two sit 20 bytes
;   apart, which is what makes the pairing more than a coincidence of shape.
; Evidence: `cp E,0x08` at 0xF8A928, `xor E,E` at 0xF8A92D,
;          `ld XIX,0x00F8A93B` at 0xF8A92F, `ld E,(XIX+E)` at 0xF8A934 --
;          the result lands in E, the same register the index arrived in.
; ---------------------------------------------------------------------

IndexToBitMask8:
	push XIX                                             ; F8A927  3c
	cp E,0x08                                            ; F8A928  cd cf 08
	jr ule, .LF8A92F                                         ; F8A92B  63 02
	xor E,E                                              ; F8A92D  cd d5
.LF8A92F:
	ld XIX,BitMask8ByIndex                               ; F8A92F  44 3b a9 f8 00
	ld	e, (xix+e)                                   ; F8A934  c3 03 f0 e8 25
	pop XIX                                              ; F8A939  5c
	ret                                                  ; F8A93A  0e
; ---------------------------------------------------------------------
; THE THREE BIT-MASK LOOKUP SIBLINGS -- 0xF8A93B-0xF8AA17.
;
; ⚠ THIS RANGE WAS MIS-DECODED UNTIL ROUND 11.  Three DATA tables were
; emitted as instructions, and because a table byte pair like `40 80`
; starts a 5-byte `ld XWA,imm32`, the decode ran PAST the end of each
; table and swallowed the entry of the routine that follows it.  Two
; routine entry points -- 0xF8A944 and 0xF8A97D -- were inside a bogus
; operand and had no label.  The bytes were always right; the gate
; cannot see a wrong decode, which is exactly why this was invisible.
;
; Each routine converts an INDEX to a ONE-HOT MASK by table lookup:
;   IndexToBitMask8   `cp E,0x08` clamps,  9 x u8  -> E
;   IndexToBitMask16  `cp E,0x10` clamps, 17 x u16 -> DE
;   IndexToBitMask32  `cp E,0x20` clamps, 33 x u32 -> XDE
; and the result always lands in the E/DE/XDE register the index
; arrived in (`r5`, `r2`, `r2` at 0xF8A934, 0xF8A954 and 0xF8A98D).
; and index 0 maps to 0 in all three, so entry i is 1 << (i-1).  An
; out-of-range index is forced to 0 (`xor E,E`), i.e. to the zero mask,
; not clamped to the top entry.
; ★ LowestSetBitIndex1Based (0xF8A913) is the INVERSE of the 8-bit one:
;   it returns the 1-based position of the lowest set bit, which is the
;   index this table turns back into a mask.
; Evidence: the clamp `cp E,0x08` at 0xF8A928, 0xF8A945 and 0xF8A97E; the
;          table loads `ld XIX,imm32` at 0xF8A92F, 0xF8A94F and 0xF8A988;
;          the last entry of each table is 0x80, 0x8000 and 0x80000000.
; ---------------------------------------------------------------------

BitMask8ByIndex:
	.byte 0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 ; F8A93B  [ 0.. 8]  index -> 1 << (index-1), 0 for 0

; ---------------------------------------------------------------------
; IndexToBitMask16 -- E (0..16) -> DE = one-hot 16-bit mask.
; Entry was HIDDEN inside a mis-decoded table until round 11.
; Evidence: `push XIX` at 0xF8A944, `cp E,0x10` at 0xF8A945, `xor E,E` at
;          0xF8A94A, `sla E,1` at 0xF8A94C, `ld XIX,0x00F8A95B` at 0xF8A94F.
; ---------------------------------------------------------------------

IndexToBitMask16:
	push XIX                                      ; F8A944  3c
	cp E,0x10                                     ; F8A945  cd cf 10
	jr ule, .LF8A94C                              ; F8A948  63 02
	xor E,E                                       ; F8A94A  cd d5
.LF8A94C:
	sla e, 0x01                                   ; F8A94C  cd ec 01
	ld XIX,BitMask16ByIndex                       ; F8A94F  44 5b a9 f8 00
IndexToBitMask16__F8A954:
	ld	de, (xix+e)                           ; F8A954  d3 03 f0 e8 22
	pop XIX                                       ; F8A959  5c
	ret                                           ; F8A95A  0e

; ---------------------------------------------------------------------
; BitMask16ByIndex -- 17 x u16: 0, then 1<<0 .. 1<<15 (entry k = 1 << (k-1)).
; Read by: IndexToBitMask16 (0xF8A944): `cp E,0x10 / jr ule / xor E,E /
;          sla 1,E / ld XIX,<this> / ld DE,(XIX+E)`.  COUNT 17 = that
;          bound + 1.  (notes/proma-2026-09-25/gen_small_headers.py, H1)
; ---------------------------------------------------------------------
BitMask16ByIndex:
	.short 0x0000, 0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040 ; F8A95B  [ 0.. 7]  index -> 1 << (index-1), 0 for 0
	.short 0x0080, 0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000 ; F8A96B  [ 8..15]
	.short 0x8000                                              ; F8A97B  [16..16]

; ---------------------------------------------------------------------
; IndexToBitMask32 -- E (0..32) -> XDE = one-hot 32-bit mask.
; Entry was HIDDEN inside a mis-decoded table until round 11.
; Evidence: `push XIX` at 0xF8A97D, `cp E,0x20` at 0xF8A97E, `xor E,E` at
;          0xF8A983, `sla E,2` at 0xF8A985, `ld XIX,0x00F8A994` at 0xF8A988.
; ---------------------------------------------------------------------

IndexToBitMask32:
	push XIX                                      ; F8A97D  3c
	cp E,0x20                                     ; F8A97E  cd cf 20
	jr ule, .LF8A985                              ; F8A981  63 02
	xor E,E                                       ; F8A983  cd d5
.LF8A985:
	sla e, 0x02                                   ; F8A985  cd ec 02
	ld XIX,BitMask32ByIndex                       ; F8A988  44 94 a9 f8 00
	ld	xde, (xix+e)                          ; F8A98D  e3 03 f0 e8 22
	pop XIX                                       ; F8A992  5c
	ret                                           ; F8A993  0e

; ---------------------------------------------------------------------
; BitMask32ByIndex -- 33 x u32: 0, then 1<<0 .. 1<<31 (entry k = 1 << (k-1)).
; Read by: IndexToBitMask32 (0xF8A97D): `cp E,0x20 / jr ule / xor E,E /
;          sla 2,E / ld XIX,<this> / ld XDE,(XIX+E)`.  COUNT 33 = that
;          bound + 1.  Also copied at BitMask32ByIndex_Copy and
;          BitMask32ByIndex_DeadCopy.  (gen_small_headers.py, H1)
; ---------------------------------------------------------------------
BitMask32ByIndex:
	.long 0x00000000, 0x00000001, 0x00000002, 0x00000004       ; F8A994  [ 0.. 3]  index -> 1 << (index-1), 0 for 0
	.long 0x00000008, 0x00000010, 0x00000020, 0x00000040       ; F8A9A4  [ 4.. 7]
	.long 0x00000080, 0x00000100, 0x00000200, 0x00000400       ; F8A9B4  [ 8..11]
	.long 0x00000800, 0x00001000, 0x00002000, 0x00004000       ; F8A9C4  [12..15]
	.long 0x00008000, 0x00010000, 0x00020000, 0x00040000       ; F8A9D4  [16..19]
	.long 0x00080000, 0x00100000, 0x00200000, 0x00400000       ; F8A9E4  [20..23]
	.long 0x00800000, 0x01000000, 0x02000000, 0x04000000       ; F8A9F4  [24..27]
	.long 0x08000000, 0x10000000, 0x20000000, 0x40000000       ; F8AA04  [28..31]
	.long 0x80000000                                           ; F8AA14  [32..32]
	cp e, 0x00:i3                                          ; F8AA18  cd d8
	jr z, .LF8AA20                                           ; F8AA1A  66 04
	jp PanelEvent_CommitValue                                        ; F8AA1C  1b 0b a9 f8
.LF8AA20:
	jp PanelEvent_Drop                                        ; F8AA20  1b 0f a9 f8
; PanelAction_LowestBitOneHot -- action handler of v1 group 0x08, mask 0x3F: keep only the lowest set bit of the value
; Evidence: PanelGroupActionListPool record 0xF8B95C ({0x08,0x3F} -> 0xF8AA24).  E=0 -> PanelEvent_Drop; else E=IndexToBitMask8(LowestSetBitIndex1Based(E)), D=0x3F; when bit 0 of byte +0x18 of RecordFieldPtrs_RAM76A2_Plus20[(0x2250)] is set, the stored code becomes 0x1A (`ld (XIX-1),0x1A`); then PanelEvent_CommitValue.
; Which panel control group 0x08 is, and what code 0x1A means, are not established.
PanelAction_LowestBitOneHot:   ; entry: PanelGroupActionListPool
	cp e, 0x00:i3                                          ; F8AA24  cd d8
	jr z, .LF8AA53                                           ; F8AA26  66 2b
	calr LowestSetBitIndex1Based                                          ; F8AA28  1e e8 fe
	calr IndexToBitMask8                                          ; F8AA2B  1e f9 fe
	ld d, 0x3f:opc                                          ; F8AA2E  24 3f
	push XIX                                             ; F8AA30  3c
	ld XIX,RecordFieldPtrs_RAM76A2_Plus20                ; F8AA31  44 c6 b3 f8 00
	ld a, (UI_PartIndex:16)                                   ; F8AA36  c1 50 22 21
	sla a, 0x02                                          ; F8AA3A  c9 ec 02
	ld	xix, (xix+a)                                 ; F8AA3D  e3 03 f0 e0 24
	ld A,(XIX+0x18)                                      ; F8AA42  8c 18 21
	pop XIX                                              ; F8AA45  5c
	bit 0x00,A                                           ; F8AA46  c9 33 00
	jr z, .LF8AA4F                                           ; F8AA49  66 04
	ld (xix-1), 0x1a                                     ; F8AA4B  bc ff 00 1a
.LF8AA4F:
	jp PanelEvent_CommitValue                                        ; F8AA4F  1b 0b a9 f8
.LF8AA53:
	jp PanelEvent_Drop                                        ; F8AA53  1b 0f a9 f8
; PanelAction_ResetAssignableCtrls -- RESET-button action: re-centre the two assignable controllers
; Evidence: PanelGroupActionListPool sends v2 group 0x07 mask 0x02 (event B8/00; wire 0xC8 = segment 8 bit 1 = RESET,
;   notes/wave7_panel_button_codes.py, grade RULE) and v1 group 0x08 mask 0x40 here.  Pressed (E != 0): for each of
;   (0x600000)/(0x600001) -- the RAM channels AnalogScan_RamChannel4/5 normalise -- not already 0x80, store 0x80; if
;   already 0x80, rewrite the event number from PanelCtrl_AssignToParamNumber((0x7F27)/(0x7F28)) with DE = 0x7F40
;   (value 0x40).  Release drops the event (sub_F8A90F).  0xF8AA5D-0xF8AAA4.
PanelAction_ResetAssignableCtrls:   ; entry: PanelGroupActionListPool
	cp e, 0x00:i3                                          ; F8AA57  cd d8
	jr z, .LF8AAA8                                           ; F8AA59  66 4d
	ld a, 0x80:opc                                          ; F8AA5B  21 80
	cp (0x600000:24), a                               ; F8AA5D  c2 00 00 60 f9
	jr z, .LF8AA6B                                           ; F8AA62  66 07
	ld (0x600000:24), a                                 ; F8AA64  f2 00 00 60 41
	jr .LF8AA7E                                              ; F8AA69  68 13
.LF8AA6B:
	push XIX                                             ; F8AA6B  3c
	ld XIX,0x00007f27                                    ; F8AA6C  44 27 7f 00 00
	calr PanelCtrl_AssignToParamNumber                                            ; F8AA71  1e 38 00
	pop XIX                                              ; F8AA74  5c
	ld (xix-2), a                                        ; F8AA75  bc fe 41
	ldw de, 0x7f40                                       ; F8AA78  32 40 7f
	calr PanelEvent_CommitValue                                          ; F8AA7B  1e 8d fe
.LF8AA7E:
	ld a, 0x80:opc                                          ; F8AA7E  21 80
	cp (0x600001:24), a                               ; F8AA80  c2 01 00 60 f9
	jr z, .LF8AA90                                           ; F8AA85  66 09
	ld (0x600001:24), a                                 ; F8AA87  f2 01 00 60 41
	jp PanelEvent_Drop                                        ; F8AA8C  1b 0f a9 f8
.LF8AA90:
	push XIX                                             ; F8AA90  3c
	ld XIX,0x00007f28                                    ; F8AA91  44 28 7f 00 00
	calr PanelCtrl_AssignToParamNumber                                            ; F8AA96  1e 13 00
	pop XIX                                              ; F8AA99  5c
	ld (xix+), a                                    ; F8AA9A  f5 f0 41
	ld (xix+), 0x00                                  ; F8AA9D  f5 f0 00 00
	ldw de, 0x7f40                                       ; F8AAA1  32 40 7f
	jp PanelEvent_CommitValue                                        ; F8AAA4  1b 0b a9 f8
.LF8AAA8:
	jp PanelEvent_Drop                                        ; F8AAA8  1b 0f a9 f8
; ---------------------------------------------------------------------
; PanelCtrl_AssignToParamNumber -- A = the parameter number for the controller
;          assignment byte at (XIX); 0xFE when the byte is none of the ten.
; Called from: PanelAction_ResetAssignableCtrls with XIX = 0x7F27 and 0x7F28, i.e. 0x7F12 + 0x15
;          and + 0x16, two of the slots PanelGroupToRam7F12Slot maps groups to.
; Body:    a `cp A,v / jr nz / ld A,n` chain:
;          0x01->B2, 0x02->BC, 0x04->BD, 0x0B->B3, 0x10->B8,
;          0x11->B9, 0x12->BA, 0x13->BB, 0x40->B5, 0x81->B4.
;          PanelAction_AssignableController (0xF8AFD0) carries the same ten
;          pairs inline (check A1).
; ★ The assignment byte IS A MIDI CONTROLLER NUMBER: for every v < 0x80 the
;          MIDI-in table of controller v (MidiIn_CC01_ParamTable, ..._CC40_)
;          holds exactly n as its parameter number, and 0x81 -> 0xB4 is
;          MidiIn_ChannelPressure_ParamTable's number -- so 0x81 is how an
;          assignment spells channel pressure (aftertouch).
; (check A1: notes/proma-2026-09-25/gen_panel_actions.py)
; ---------------------------------------------------------------------
PanelCtrl_AssignToParamNumber:
	ld A,(XIX)                                           ; F8AAAC  84 21
	cp A,0x10                                            ; F8AAAE  c9 cf 10
	jr nz, .LF8AAB7                                          ; F8AAB1  6e 04
	ld a, 0xb8:opc                                          ; F8AAB3  21 b8
	jr .LF8AB07                                              ; F8AAB5  68 50
.LF8AAB7:
	cp a, 0x01:i3                                          ; F8AAB7  c9 d9
	jr nz, .LF8AABF                                          ; F8AAB9  6e 04
	ld a, 0xb2:opc                                          ; F8AABB  21 b2
	jr .LF8AB07                                              ; F8AABD  68 48
.LF8AABF:
	cp a, 0x02:i3                                          ; F8AABF  c9 da
	jr nz, .LF8AAC7                                          ; F8AAC1  6e 04
	ld a, 0xbc:opc                                          ; F8AAC3  21 bc
	jr .LF8AB07                                              ; F8AAC5  68 40
.LF8AAC7:
	cp a, 0x04:i3                                          ; F8AAC7  c9 dc
	jr nz, .LF8AACF                                          ; F8AAC9  6e 04
	ld a, 0xbd:opc                                          ; F8AACB  21 bd
	jr .LF8AB07                                              ; F8AACD  68 38
.LF8AACF:
	cp A,0x0b                                            ; F8AACF  c9 cf 0b
	jr nz, .LF8AAD8                                          ; F8AAD2  6e 04
	ld a, 0xb3:opc                                          ; F8AAD4  21 b3
	jr .LF8AB07                                              ; F8AAD6  68 2f
.LF8AAD8:
	cp A,0x11                                            ; F8AAD8  c9 cf 11
	jr nz, .LF8AAE1                                          ; F8AADB  6e 04
	ld a, 0xb9:opc                                          ; F8AADD  21 b9
	jr .LF8AB07                                              ; F8AADF  68 26
.LF8AAE1:
	cp A,0x12                                            ; F8AAE1  c9 cf 12
	jr nz, .LF8AAEA                                          ; F8AAE4  6e 04
	ld a, 0xba:opc                                          ; F8AAE6  21 ba
	jr .LF8AB07                                              ; F8AAE8  68 1d
.LF8AAEA:
	cp A,0x13                                            ; F8AAEA  c9 cf 13
	jr nz, .LF8AAF3                                          ; F8AAED  6e 04
	ld a, 0xbb:opc                                          ; F8AAEF  21 bb
	jr .LF8AB07                                              ; F8AAF1  68 14
.LF8AAF3:
	cp A,0x40                                            ; F8AAF3  c9 cf 40
	jr nz, .LF8AAFC                                          ; F8AAF6  6e 04
	ld a, 0xb5:opc                                          ; F8AAF8  21 b5
	jr .LF8AB07                                              ; F8AAFA  68 0b
.LF8AAFC:
	cp A,0x81                                            ; F8AAFC  c9 cf 81
	jr nz, .LF8AB05                                          ; F8AAFF  6e 04
	ld a, 0xb4:opc                                          ; F8AB01  21 b4
	jr .LF8AB07                                              ; F8AB03  68 02
.LF8AB05:
	ld a, 0xfe:opc                                          ; F8AB05  21 fe
.LF8AB07:
	ret                                                  ; F8AB07  0e
; ---------------------------------------------------------------------
; PanelAction_OrdinalToEventValue_A -- action handler of 10 pool records (v1
;          group 0x07 masks 01..20, v2 group 0x06 masks 01..08): turn the one
;          set bit into the event value PanelOrdinalToEventValue_A gives it.
;          The body is described in that table's header.
; (notes/proma-2026-09-25/gen_panel_actions.py)
; ---------------------------------------------------------------------
PanelAction_OrdinalToEventValue_A:   ; entry: PanelGroupActionListPool
	cp	(0x2806:16), 0x00                            ; F8AB08  c1 06 28 3f 00
	jr nz, .LF8AB35                                          ; F8AB0D  6e 26
	calr LowestSetBitIndex1Based                                          ; F8AB0F  1e 01 fe
	extz DE                                              ; F8AB12  da 12
	extz XDE                                             ; F8AB14  ea 12
	add XDE,PanelOrdinalToEventValue_A                       ; F8AB16  ea c8 39 ab f8 00
	ld E,(XDE)                                           ; F8AB1C  82 25
	ld d, 0xff:opc                                          ; F8AB1E  24 ff
	cp e, 0x03:i3                                          ; F8AB20  cd db
	jr nz, .LF8AB2C                                          ; F8AB22  6e 08
	bit	0, (0x3614:16)                               ; F8AB24  f1 14 36 c8
	jr z, .LF8AB31                                           ; F8AB28  66 07
	ld e, 0x08:opc                                          ; F8AB2A  25 08
.LF8AB2C:
	and	(0x3614:16), 0xfe                            ; F8AB2C  c1 14 36 3c fe
.LF8AB31:
	jp PanelEvent_CommitValue                                        ; F8AB31  1b 0b a9 f8
.LF8AB35:
	jp PanelEvent_Drop                                        ; F8AB35  1b 0f a9 f8
; ---------------------------------------------------------------------
; PanelOrdinalToEventValue_A -- 9 bytes: switch ordinal -> event VALUE byte.
; Read by: the action handler at 0xF8AB08 -- `add XDE,<this> / ld E,(XDE)` at
;          0xF8AB16 -- which 10 PanelGroupActionListPool records dispatch:
;          v1 group 0x07 masks 01..20 and v2 group 0x06 masks 01..08 (check C1).
;          Those groups' event-list records are all class 0xA9 code 0x20,
;          shift 0, one bit each (check C2), so E arrives as that single
;          bit and LowestSetBitIndex1Based makes it the ordinal 1..8.
;          The handler runs only while (0x2806) is 0, sets D = 0xFF, turns
;          a value of 3 into 8 when bit 0 of (0x3614) is set, clears that
;          bit, and commits DE through PanelEvent_CommitValue (`ld (XIX+),DE`).
; So every switch in those groups raises the SAME event (A9,20) and this
;          table's byte is what tells them apart.
; COUNT 9 = ordinals 0..8; the records reach 1..6 (v1) and 1..4 (v2).
; ⚠ What the values 0x09 0x0A 0x12 0x15 0x08 0x03 denote is not established.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
PanelOrdinalToEventValue_A:
	.byte 0x00, 0x09, 0x0a, 0x12, 0x15, 0x08, 0x03, 0x00, 0x00  ; F8AB39  [0]
; ---------------------------------------------------------------------
; PanelAction_OrdinalToEventValue_B -- action handler of 8 pool records (v1
;          and v2 group 0x00 masks 01..08); the body is described in
;          PanelOrdinalToEventValue_B's header.
; (notes/proma-2026-09-25/gen_panel_actions.py)
; ---------------------------------------------------------------------
PanelAction_OrdinalToEventValue_B:   ; entry: PanelGroupActionListPool
	cp	(0x2806:16), 0x00                            ; F8AB42  c1 06 28 3f 00
	jr nz, .LF8AB63                                          ; F8AB47  6e 1a
	calr LowestSetBitIndex1Based                                          ; F8AB49  1e c7 fd
	extz DE                                              ; F8AB4C  da 12
	extz XDE                                             ; F8AB4E  ea 12
	add XDE,PanelOrdinalToEventValue_B                       ; F8AB50  ea c8 67 ab f8 00
	ld E,(XDE)                                           ; F8AB56  82 25
	ld d, 0xff:opc                                          ; F8AB58  24 ff
	and	(0x3614:16), 0xfe                            ; F8AB5A  c1 14 36 3c fe
	jp PanelEvent_CommitValue                                        ; F8AB5F  1b 0b a9 f8
.LF8AB63:
	jp PanelEvent_Drop                                        ; F8AB63  1b 0f a9 f8
; ---------------------------------------------------------------------
; PanelOrdinalToEventValue_B -- 9 bytes: switch ordinal -> event VALUE byte.
; Read by: the action handler at 0xF8AB42 -- `add XDE,<this> / ld E,(XDE)` at
;          0xF8AB50 -- which 8 PanelGroupActionListPool records dispatch: v1
;          and v2 group 0x00 masks 01..08 (check C1).  Those event-list
;          records are class 0xA9 code 0x20, shift 0, one bit each (check C2),
;          the same event PanelOrdinalToEventValue_A feeds.  The handler
;          runs only while (0x2806) is 0, sets D = 0xFF, clears bit 0 of
;          (0x3614) and commits DE through PanelEvent_CommitValue.
; COUNT 9 = ordinals 0..8; the records reach 1..4.
; ⚠ What the values 0x01 0x02 0x17 0x16 denote is not established.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
PanelOrdinalToEventValue_B:
	.byte 0x00, 0x01, 0x02, 0x17, 0x16, 0x00, 0x00, 0x00, 0x00  ; F8AB67  [0]
; PanelAction_BankRemap -- BANK RE-MAP action: pick the bank value the A8/07 event carries
; Evidence: PanelGroupActionListPool v1/v2 group 0x00 mask 0x80; event list A8/07 shift 0 mask 0x80; wire 0xC0 bit 7 =
;   "BANK RE-MAP" (wave7_panel_button_codes.py, LEGEND).  D = 0x3F; the current bank is the part record's +0x1D
;   (record from (0x60F018)+0x80+4*(0x2250)) or (0x7F04)&0x3F in combination mode ((0x7F02)&0xF0 != 0); E toggles
;   between the remap banks 0x18-0x1A (vs (0x216A)) and the current bank.  PanelLed_ShowBank lights RE-MAP for
;   0x18-0x1A. Release drops the event.  0xF8AB70-0xF8ABF9.
PanelAction_BankRemap:   ; entry: PanelGroupActionListPool
	cp e, 0x00:i3                                          ; F8AB70  cd d8
	jrl z, .LF8ABF9                                          ; F8AB72  76 84 00
	ld d, 0x3f:opc                                          ; F8AB75  24 3f
	ld a, (PanelModeGroup:16)                                   ; F8AB77  c1 76 20 21
	cp A,0x09                                            ; F8AB7B  c9 cf 09
	jr z, .LF8ABD9                                           ; F8AB7E  66 59
	cp A,0x08                                            ; F8AB80  c9 cf 08
	jr z, .LF8ABD9                                           ; F8AB83  66 54
	cp a, 0x03:i3                                          ; F8AB85  c9 db
	jr z, .LF8ABD9                                           ; F8AB87  66 50
	cp A,0x16                                            ; F8AB89  c9 cf 16
	jr z, .LF8ABD9                                           ; F8AB8C  66 4b
	cp	(UI_ScreenLatch:16), 0xb7                            ; F8AB8E  c1 7a 20 3f b7
	jr z, .LF8ABD9                                           ; F8AB93  66 44
	ld a, (0x7f02:16)                                   ; F8AB95  c1 02 7f 21
	and A,0xf0                                           ; F8AB99  c9 cc f0
	cp a, 0x00:i3                                          ; F8AB9C  c9 d8
	jr z, .LF8ABD9                                           ; F8AB9E  66 39
	ld a, (0x7f04:16)                                   ; F8ABA0  c1 04 7f 21
	and A,0x3f                                           ; F8ABA4  c9 cc 3f
	ld w, (SoundSel_Bank:16)                                   ; F8ABA7  c1 6a 21 20
.LF8ABAB:
	cp A,0x18                                            ; F8ABAB  c9 cf 18
	jr c, .LF8ABC7                                           ; F8ABAE  67 17
	cp A,0x1a                                            ; F8ABB0  c9 cf 1a
	jr ugt, .LF8ABC7                                         ; F8ABB3  6b 12
	cp W,0x18                                            ; F8ABB5  c8 cf 18
	jr c, .LF8ABC3                                           ; F8ABB8  67 09
	cp W,0x1a                                            ; F8ABBA  c8 cf 1a
	jr ugt, .LF8ABC3                                         ; F8ABBD  6b 04
	ld e, 0x00:opc                                          ; F8ABBF  25 00
	jr .LF8ABF5                                              ; F8ABC1  68 32
.LF8ABC3:
	ld E,A                                               ; F8ABC3  c9 8d
	jr .LF8ABF5                                              ; F8ABC5  68 2e
.LF8ABC7:
	cp W,0x18                                            ; F8ABC7  c8 cf 18
	jr c, .LF8ABD5                                           ; F8ABCA  67 09
	cp W,0x1a                                            ; F8ABCC  c8 cf 1a
	jr ugt, .LF8ABD5                                         ; F8ABCF  6b 04
	ld E,A                                               ; F8ABD1  c9 8d
	jr .LF8ABF5                                              ; F8ABD3  68 20
.LF8ABD5:
	ld e, 0x18:opc                                          ; F8ABD5  25 18
	jr .LF8ABF5                                              ; F8ABD7  68 1c
.LF8ABD9:
	ld a, 0x04:opc                                          ; F8ABD9  21 04
	mul	wa, (UI_PartIndex:16)                              ; F8ABDB  c1 50 22 41
	add WA,0x0080                                        ; F8ABDF  d8 c8 80 00
	extz XWA                                             ; F8ABE3  e8 12
	add xwa, (IndexedTable_Base:24)                           ; F8ABE5  e2 18 f0 60 80
	ld XWA,(XWA)                                         ; F8ABEA  a0 20
	ld A,(XWA+0x1d)                                      ; F8ABEC  88 1d 21
	ld w, (SoundSel_Bank:16)                                   ; F8ABEF  c1 6a 21 20
	jr .LF8ABAB                                               ; F8ABF3  68 b6
.LF8ABF5:
	jp PanelEvent_CommitValue                                        ; F8ABF5  1b 0b a9 f8
.LF8ABF9:
	jp PanelEvent_Drop                                        ; F8ABF9  1b 0f a9 f8
; PanelAction_BankButton -- BANK USER 1 / USER 2 / ROM-EXT action: turn the pressed button into a bank value
; Evidence: PanelGroupActionListPool v1/v2 group 0x00 mask 0x70; event list A8/07 shift 4 mask 0x70; wire 0xC0 bits
;   4-6 = BANK USER 1/USER 2/ROM-EXT (LEGEND).  E = LowestSetBitIndex1Based (1..3), D = 0x3F.  With (0x216A) in
;   0x18-0x1A: E += 0x17 (remap banks).  Otherwise 1 -> 0x08/0x28, 2 -> 0x09/0x29, 3 -> keep a ROM bank or 0x00/0x20
;   (bit 5 of the current bank picks the 0x2x form) -- the same buckets PanelLed_ShowBank maps back to the three BANK
;   LEDs.
PanelAction_BankButton:   ; entry: PanelGroupActionListPool
	cp e, 0x00:i3                                          ; F8ABFD  cd d8
	jrl z, .LF8ACE4                                          ; F8ABFF  76 e2 00
	calr LowestSetBitIndex1Based                                          ; F8AC02  1e 0e fd
	ld d, 0x3f:opc                                          ; F8AC05  24 3f
	ld a, (SoundSel_Bank:16)                                   ; F8AC07  c1 6a 21 21
	cp A,0x18                                            ; F8AC0B  c9 cf 18
	jr c, .LF8AC1B                                           ; F8AC0E  67 0b
	cp A,0x1a                                            ; F8AC10  c9 cf 1a
	jr ugt, .LF8AC1B                                         ; F8AC13  6b 06
	add E,0x17                                           ; F8AC15  cd c8 17
	jrl .LF8ACE0                                             ; F8AC18  78 c5 00
.LF8AC1B:
	ld a, (PanelModeGroup:16)                                   ; F8AC1B  c1 76 20 21
	cp A,0x09                                            ; F8AC1F  c9 cf 09
	jr z, .LF8AC6F                                           ; F8AC22  66 4b
	cp A,0x08                                            ; F8AC24  c9 cf 08
	jr z, .LF8AC6F                                           ; F8AC27  66 46
	cp a, 0x03:i3                                          ; F8AC29  c9 db
	jr z, .LF8AC6F                                           ; F8AC2B  66 42
	cp A,0x16                                            ; F8AC2D  c9 cf 16
	jr z, .LF8AC6F                                           ; F8AC30  66 3d
	cp	(UI_ScreenLatch:16), 0xb7                            ; F8AC32  c1 7a 20 3f b7
	jr z, .LF8AC6F                                           ; F8AC37  66 36
	ld a, (0x7f02:16)                                   ; F8AC39  c1 02 7f 21
	and A,0xf0                                           ; F8AC3D  c9 cc f0
	cp a, 0x00:i3                                          ; F8AC40  c9 d8
	jr z, .LF8AC6F                                           ; F8AC42  66 2b
	ld a, (0x7f04:16)                                   ; F8AC44  c1 04 7f 21
	and A,0x3f                                           ; F8AC48  c9 cc 3f
	cp e, 0x01:i3                                          ; F8AC4B  cd d9
	jr nz, .LF8AC54                                          ; F8AC4D  6e 05
	ld e, 0x08:opc                                          ; F8AC4F  25 08
	jrl .LF8ACE0                                             ; F8AC51  78 8c 00
.LF8AC54:
	cp e, 0x02:i3                                          ; F8AC54  cd da
	jrl z, .LF8ACE4                                          ; F8AC56  76 8b 00
	cp e, 0x03:i3                                          ; F8AC59  cd db
	jrl nz, .LF8ACE4                                         ; F8AC5B  7e 86 00
	cp a, 0x00:i3                                          ; F8AC5E  c9 d8
	jr z, .LF8AC6B                                           ; F8AC60  66 09
	cp A,0x10                                            ; F8AC62  c9 cf 10
	jr z, .LF8AC6B                                           ; F8AC65  66 04
	ld e, 0x00:opc                                          ; F8AC67  25 00
	jr .LF8ACE0                                              ; F8AC69  68 75
.LF8AC6B:
	ld E,A                                               ; F8AC6B  c9 8d
	jr .LF8ACE0                                              ; F8AC6D  68 71
.LF8AC6F:
	ld a, 0x04:opc                                          ; F8AC6F  21 04
	mul	wa, (UI_PartIndex:16)                              ; F8AC71  c1 50 22 41
	add WA,0x0080                                        ; F8AC75  d8 c8 80 00
	extz XWA                                             ; F8AC79  e8 12
	add xwa, (IndexedTable_Base:24)                           ; F8AC7B  e2 18 f0 60 80
	ld XWA,(XWA)                                         ; F8AC80  a0 20
	ld A,(XWA+0x1d)                                      ; F8AC82  88 1d 21
	cp e, 0x01:i3                                          ; F8AC85  cd d9
	jr nz, .LF8AC9E                                          ; F8AC87  6e 15
	cp A,0x08                                            ; F8AC89  c9 cf 08
	jr z, .LF8ACDE                                           ; F8AC8C  66 50
	cp A,0x28                                            ; F8AC8E  c9 cf 28
	jr z, .LF8ACDE                                           ; F8AC91  66 4b
	ld e, 0x08:opc                                          ; F8AC93  25 08
	bit 0x05,A                                           ; F8AC95  c9 33 05
	jr z, .LF8ACE0                                           ; F8AC98  66 46
	ld e, 0x28:opc                                          ; F8AC9A  25 28
	jr .LF8ACE0                                              ; F8AC9C  68 42
.LF8AC9E:
	cp e, 0x02:i3                                          ; F8AC9E  cd da
	jr nz, .LF8ACB7                                          ; F8ACA0  6e 15
	cp A,0x09                                            ; F8ACA2  c9 cf 09
	jr z, .LF8ACDE                                           ; F8ACA5  66 37
	cp A,0x29                                            ; F8ACA7  c9 cf 29
	jr z, .LF8ACDE                                           ; F8ACAA  66 32
	ld e, 0x09:opc                                          ; F8ACAC  25 09
	bit 0x05,A                                           ; F8ACAE  c9 33 05
	jr z, .LF8ACE0                                           ; F8ACB1  66 2d
	ld e, 0x29:opc                                          ; F8ACB3  25 29
	jr .LF8ACE0                                              ; F8ACB5  68 29
.LF8ACB7:
	cp e, 0x03:i3                                          ; F8ACB7  cd db
	jr nz, .LF8ACE4                                          ; F8ACB9  6e 29
	cp a, 0x01:i3                                          ; F8ACBB  c9 d9
	jr ule, .LF8ACDE                                         ; F8ACBD  63 1f
	cp A,0x10                                            ; F8ACBF  c9 cf 10
	jr z, .LF8ACDE                                           ; F8ACC2  66 1a
	cp A,0x20                                            ; F8ACC4  c9 cf 20
	jr z, .LF8ACDE                                           ; F8ACC7  66 15
	cp A,0x21                                            ; F8ACC9  c9 cf 21
	jr z, .LF8ACDE                                           ; F8ACCC  66 10
	cp A,0x30                                            ; F8ACCE  c9 cf 30
	jr z, .LF8ACDE                                           ; F8ACD1  66 0b
	ld e, 0x00:opc                                          ; F8ACD3  25 00
	bit 0x05,A                                           ; F8ACD5  c9 33 05
	jr z, .LF8ACE0                                           ; F8ACD8  66 06
	ld e, 0x20:opc                                          ; F8ACDA  25 20
	jr .LF8ACE0                                              ; F8ACDC  68 02
.LF8ACDE:
	ld E,A                                               ; F8ACDE  c9 8d
.LF8ACE0:
	jp PanelEvent_CommitValue                                        ; F8ACE0  1b 0b a9 f8
.LF8ACE4:
	jp PanelEvent_Drop                                        ; F8ACE4  1b 0f a9 f8
; ---------------------------------------------------------------------
; PanelAction_SoundSelectOrKeypad_V1 -- action handler of v1 groups 0x01 and
;          0x02, mask FF: sixteen switches with two uses.
;   bit 1 of (0x2075) set: the numeric-keypad path at 0xF8AD54, see
;          PanelKeypad_OrdinalToKey_V1.
;   otherwise: E = the set bit's index (+8 for group 2), D = 0x0F; the index
;          is checked with T_SoundGroup_MaxMemberIndex_Get (or its ToneCopy
;          twin, chosen by (0x2076) and (0x7F02)) and, if accepted, stored
;          at (0x2169) and committed; 0xFF from the check drops the event.
; (notes/proma-2026-09-25/gen_panel_actions.py)
; ---------------------------------------------------------------------
PanelAction_SoundSelectOrKeypad_V1:   ; entry: PanelGroupActionListPool
	bit	1, (UI_RequestBits:16)                               ; F8ACE8  f1 75 20 c9
	jr nz, .LF8AD54                                          ; F8ACEC  6e 66
	cp e, 0x00:i3                                          ; F8ACEE  cd d8
	jr z, .LF8AD50                                           ; F8ACF0  66 5e
	calr LowestSetBitIndex1Based                                          ; F8ACF2  1e 1e fc
	dec 1,E                                              ; F8ACF5  cd 69
	cp a, 0x01:i3                                          ; F8ACF7  c9 d9
	jr z, PanelAction_SoundSelectOrKeypad_V1_Skip                                           ; F8ACF9  66 03
	add E,0x08                                           ; F8ACFB  cd c8 08
PanelAction_SoundSelectOrKeypad_V1_Skip:
	ld d, 0x0f:opc                                          ; F8ACFE  24 0f
	ld a, (PanelModeGroup:16)                                   ; F8AD00  c1 76 20 21
	cp A,0x09                                            ; F8AD04  c9 cf 09
	jr z, .LF8AD35                                           ; F8AD07  66 2c
	cp A,0x08                                            ; F8AD09  c9 cf 08
	jr z, .LF8AD35                                           ; F8AD0C  66 27
	cp a, 0x03:i3                                          ; F8AD0E  c9 db
	jr z, .LF8AD35                                           ; F8AD10  66 23
	cp A,0x16                                            ; F8AD12  c9 cf 16
	jr z, .LF8AD35                                           ; F8AD15  66 1e
	ld a, (0x7f02:16)                                   ; F8AD17  c1 02 7f 21
	and A,0xf0                                           ; F8AD1B  c9 cc f0
	cp a, 0x00:i3                                          ; F8AD1E  c9 d8
	jr z, .LF8AD35                                           ; F8AD20  66 13
	ld A,E                                               ; F8AD22  cd 89
	ld w, (SoundSel_Bank:16)                                   ; F8AD24  c1 6a 21 20
	ld b, 0x98:opc                                          ; F8AD28  22 98
	call T_SoundGroup_MaxMemberIndex_GetToneCopy         ; F8AD2A  1d 34 10 f4
	cp A,0xff                                            ; F8AD2E  c9 cf ff
	jr z, .LF8AD50                                           ; F8AD31  66 1d
	jr .LF8AD48                                              ; F8AD33  68 13
.LF8AD35:
	ld A,E                                               ; F8AD35  cd 89
	ld w, (SoundSel_Bank:16)                                   ; F8AD37  c1 6a 21 20
	ld b, (UI_PartIndex:16)                                   ; F8AD3B  c1 50 22 22
	call T_SoundGroup_MaxMemberIndex_Get                 ; F8AD3F  1d 1c 10 f4
	cp A,0xff                                            ; F8AD43  c9 cf ff
	jr z, .LF8AD50                                           ; F8AD46  66 08
.LF8AD48:
	ld (SoundSel_Group:16), e                                   ; F8AD48  f1 69 21 45
	jp PanelEvent_CommitValue                                        ; F8AD4C  1b 0b a9 f8
.LF8AD50:
	jp PanelEvent_Drop                                        ; F8AD50  1b 0f a9 f8
.LF8AD54:
	ldw	(xix-2), 0x1ba9                              ; F8AD54  bc fe 02 a9 1b
	cp e, 0x00:i3                                          ; F8AD59  cd d8
	jr nz, .LF8AD62                                          ; F8AD5B  6e 05
	ldw de, 0x0200                                       ; F8AD5D  32 00 02
	jr .LF8ADC5                                              ; F8AD60  68 63
.LF8AD62:
	ld XBC,0x00002267                                    ; F8AD62  41 67 22 00 00
	calr LowestSetBitIndex1Based                                          ; F8AD67  1e a9 fb
	cp a, 0x01:i3                                          ; F8AD6A  c9 d9
	jr z, .LF8AD71                                           ; F8AD6C  66 03
	add E,0x08                                           ; F8AD6E  cd c8 08
.LF8AD71:
	extz DE                                              ; F8AD71  da 12
	extz XDE                                             ; F8AD73  ea 12
	add XDE,PanelKeypad_OrdinalToKey_V1                       ; F8AD75  ea c8 cd ad f8 00
	ld E,(XDE)                                           ; F8AD7B  82 25
	cp E,0x0f                                            ; F8AD7D  cd cf 0f
	jr nz, .LF8AD8D                                          ; F8AD80  6e 0b
	cp	(0x2823:16), 0x20                            ; F8AD82  c1 23 28 3f 20
	jr z, .LF8ADC9                                           ; F8AD87  66 40
	ld (XBC),E                                           ; F8AD89  b1 45
	jr .LF8ADC2                                              ; F8AD8B  68 35
.LF8AD8D:
	cp E,0x80                                            ; F8AD8D  cd cf 80
	jr nz, .LF8ADA8                                          ; F8AD90  6e 16
	ld (XBC),E                                           ; F8AD92  b1 45
	ld XWA,0x00002820                                    ; F8AD94  40 20 28 00 00
	cp (XWA),0x2b                                        ; F8AD99  80 3f 2b
	jr z, .LF8ADA3                                           ; F8AD9C  66 05
	ld (XWA),0x2b                                        ; F8AD9E  b0 00 2b
	jr .LF8ADC5                                              ; F8ADA1  68 22
.LF8ADA3:
	ld (XWA),0x2d                                        ; F8ADA3  b0 00 2d
	jr .LF8ADC2                                              ; F8ADA6  68 1a
.LF8ADA8:
	cp E,0x09                                            ; F8ADA8  cd cf 09
	jr ugt, .LF8ADC9                                         ; F8ADAB  6b 1c
	ld (XBC),E                                           ; F8ADAD  b1 45
	ld XBC,0x00002821                                    ; F8ADAF  41 21 28 00 00
	ld WA,(XBC+0x01)                                     ; F8ADB4  99 01 20
	ld	(xbc+0:8), wa                                ; F8ADB7  b9 00 50
	ld A,E                                               ; F8ADBA  cd 89
	add A,0x30                                           ; F8ADBC  c9 c8 30
	ld (XBC+0x02),A                                      ; F8ADBF  b9 02 41
.LF8ADC2:
	ldw de, 0x0202                                       ; F8ADC2  32 02 02
.LF8ADC5:
	jp PanelEvent_CommitValue                                        ; F8ADC5  1b 0b a9 f8
.LF8ADC9:
	jp PanelEvent_Drop                                        ; F8ADC9  1b 0f a9 f8
; ---------------------------------------------------------------------
; PanelKeypad_OrdinalToKey_V1 -- 17 bytes: keypad switch ordinal -> key.
; Read by: `add XDE,<this> / ld E,(XDE)` at 0xF8AD75, in the keypad path
;          (0xF8AD54, taken when bit 1 of (0x2075) is set) of the action
;          handler at 0xF8ACE8, which the pool dispatches for v1 groups
;          0x01 and 0x02, mask FF (check C1).  The path first rewrites the
;          event's class/code word to 0x1BA9 -- the (A9,1B) that v2's
;          keypad groups carry natively (check C2); E = 0 commits
;          DE = 0x0200; otherwise E = LowestSetBitIndex1Based(E), plus 8
;          unless the group (A) is 1, so group 1 gives ordinals 1-8 and
;          group 2 ordinals 9-16.
; What the handler does with the byte read (0xF8AD7D-0xF8ADC9):
;   0..9  a DIGIT: stored to (0x2267); the bytes at 0x2822-0x2823 move
;         down to 0x2821-0x2822 and `E + 0x30` (its ASCII) goes to 0x2823;
;   0x80  stored to (0x2267); (0x2820) toggles between '+' (0x2B) and
;         '-' (0x2D);
;   0x0F  stored to (0x2267) -- unless (0x2823) holds 0x20 (a space),
;         in which case the event is dropped;
;   0xFF  above 9 and not special: dropped (`jp PanelEvent_Drop`).
;         So 0x2820-0x2823 is a sign and three ASCII digits.
; Here: ordinals 1-9 -> digits 1-9, 10 -> 0, 11 -> 0x80, 12 -> 0x0F,
;          0 and 13-16 -> 0xFF.  COUNT 17 = ordinals 0..16.
; ⚠ What 0x0F commits (an ENTER?) is not established from this code.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
PanelKeypad_OrdinalToKey_V1:
	.byte 0xff, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x00, 0x80, 0x0f, 0xff, 0xff, 0xff  ; F8ADCD  [0]
	.byte 0xff  ; F8ADDD  [16]
; ---------------------------------------------------------------------
; PanelAction_Keypad_V2 -- action handler of v2 group 0x01 mask FF and group
;          0x02 mask 0F: the V1 keypad path instruction for instruction, with
;          PanelKeypad_OrdinalToKey_V2 (see that table's header).
; (notes/proma-2026-09-25/gen_panel_actions.py)
; ---------------------------------------------------------------------
PanelAction_Keypad_V2:   ; entry: PanelGroupActionListPool
	ldw	(xix-2), 0x1ba9                              ; F8ADDE  bc fe 02 a9 1b
	cp e, 0x00:i3                                          ; F8ADE3  cd d8
	jr nz, .LF8ADEC                                          ; F8ADE5  6e 05
	ldw de, 0x0200                                       ; F8ADE7  32 00 02
	jr .LF8AE4F                                              ; F8ADEA  68 63
.LF8ADEC:
	ld XBC,0x00002267                                    ; F8ADEC  41 67 22 00 00
	calr LowestSetBitIndex1Based                                          ; F8ADF1  1e 1f fb
	cp a, 0x01:i3                                          ; F8ADF4  c9 d9
	jr z, .LF8ADFB                                           ; F8ADF6  66 03
	add E,0x08                                           ; F8ADF8  cd c8 08
.LF8ADFB:
	extz DE                                              ; F8ADFB  da 12
	extz XDE                                             ; F8ADFD  ea 12
	add XDE,PanelKeypad_OrdinalToKey_V2                       ; F8ADFF  ea c8 57 ae f8 00
	ld E,(XDE)                                           ; F8AE05  82 25
	cp E,0x0f                                            ; F8AE07  cd cf 0f
	jr nz, .LF8AE17                                          ; F8AE0A  6e 0b
	cp	(0x2823:16), 0x20                            ; F8AE0C  c1 23 28 3f 20
	jr z, .LF8AE53                                           ; F8AE11  66 40
	ld (XBC),E                                           ; F8AE13  b1 45
	jr .LF8AE4C                                              ; F8AE15  68 35
.LF8AE17:
	cp E,0x80                                            ; F8AE17  cd cf 80
	jr nz, .LF8AE32                                          ; F8AE1A  6e 16
	ld (XBC),E                                           ; F8AE1C  b1 45
	ld XWA,0x00002820                                    ; F8AE1E  40 20 28 00 00
	cp (XWA),0x2b                                        ; F8AE23  80 3f 2b
	jr z, .LF8AE2D                                           ; F8AE26  66 05
	ld (XWA),0x2b                                        ; F8AE28  b0 00 2b
	jr .LF8AE4F                                              ; F8AE2B  68 22
.LF8AE2D:
	ld (XWA),0x2d                                        ; F8AE2D  b0 00 2d
	jr .LF8AE4C                                              ; F8AE30  68 1a
.LF8AE32:
	cp E,0x09                                            ; F8AE32  cd cf 09
	jr ugt, .LF8AE53                                         ; F8AE35  6b 1c
	ld (XBC),E                                           ; F8AE37  b1 45
	ld XBC,0x00002821                                    ; F8AE39  41 21 28 00 00
	ld WA,(XBC+0x01)                                     ; F8AE3E  99 01 20
	ld	(xbc+0:8), wa                                ; F8AE41  b9 00 50
	ld A,E                                               ; F8AE44  cd 89
	add A,0x30                                           ; F8AE46  c9 c8 30
	ld (XBC+0x02),A                                      ; F8AE49  b9 02 41
.LF8AE4C:
	ldw de, 0x0202                                       ; F8AE4C  32 02 02
.LF8AE4F:
	jp PanelEvent_CommitValue                                        ; F8AE4F  1b 0b a9 f8
.LF8AE53:
	jp PanelEvent_Drop                                        ; F8AE53  1b 0f a9 f8
; ---------------------------------------------------------------------
; PanelKeypad_OrdinalToKey_V2 -- 17 bytes: keypad switch ordinal -> key.
; Read by: `add XDE,<this> / ld E,(XDE)` at 0xF8ADFF in the action handler
;          at 0xF8ADDE, which the pool dispatches for v2 group 0x01 mask FF
;          and v2 group 0x02 mask 0F (check C1): 8 + 4 = 12 switches, event
;          (A9,1B) (check C2).  The handler is the V1 keypad path
;          (PanelKeypad_OrdinalToKey_V1) instruction for instruction but
;          for this table (check C6): the same digit / 0x80 / 0x0F / 0xFF
;          actions on the same RAM.
; Here: ordinals 1-10 -> digits 0-9, 11 -> 0x80, 12 -> 0x0F, 0 and 13-16 -> 0xFF.
;          COUNT 17 = ordinals 0..16 (v2's masks reach only 1..12).
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
PanelKeypad_OrdinalToKey_V2:
	.byte 0xff, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x80, 0x0f, 0xff, 0xff, 0xff  ; F8AE57  [0]
	.byte 0xff  ; F8AE67  [16]
; PanelAction_PairPos0_HeldMaskAltCode -- pair-position-0 key of v1 groups 3-6: held-set bookkeeping, code rewrite
; Evidence: pool v1 groups 0x03-0x06 masks 0x01/0x04/0x10/0x40 (shift normalises them onto bit 0).  XDE = 1<<code
;   (IndexToBitMask32 of (XIX-1)+1).  Press: if that code is already held in (0x2252) the event code becomes code+0x11
;   (`add (XIX-1),0x11` 0xF8AE7E; 0x19 when past bit 31); set the bit; DE = 0x0303 if the code is also held in
;   (0x2256) else 0x0101.  Release: clear the bit (alt bit if set) and DE = 0x0100.  prom_b PanelCode_ToSlotAndFlags
;   bit 2 undoes the +0x11.
PanelAction_PairPos0_HeldMaskAltCode:   ; entry: PanelGroupActionListPool
	ld BC,DE                                             ; F8AE68  da 89
	ld e, (xix-1)                                        ; F8AE6A  8c ff 25
	inc 1,E                                              ; F8AE6D  cd 61
	calr IndexToBitMask32                                          ; F8AE6F  1e 0b fb
	ld xwa, (PanelHeld_Pos0:16)                                 ; F8AE72  e1 52 22 20
	cp c, 0x00:i3                                          ; F8AE76  cb d8
	jr z, .LF8AEA7                                           ; F8AE78  66 2d
	and XWA,XDE                                          ; F8AE7A  ea c0
	jr z, .LF8AE93                                           ; F8AE7C  66 15
	add	(xix-1), 0x11                                ; F8AE7E  8c ff 38 11
	sla xde, 16                                        ; F8AE82  ea ec 00
	sla xde, 0x01                                        ; F8AE85  ea ec 01
	jr nz, .LF8AE93                                          ; F8AE88  6e 09
	ld (xix-1), 0x19                                     ; F8AE8A  bc ff 00 19
	ld XDE,0x02000000                                    ; F8AE8E  42 00 00 00 02
.LF8AE93:
	or	(PanelHeld_Pos0:16), xde                     ; F8AE93  e1 52 22 ea
	and	xde, (PanelHeld_Pos1:16)                             ; F8AE97  e1 56 22 c2
	jr z, .LF8AEA2                                           ; F8AE9B  66 05
	ldw de, 0x0303                                       ; F8AE9D  32 03 03
	jr .LF8AED7                                              ; F8AEA0  68 35
.LF8AEA2:
	ldw de, 0x0101                                       ; F8AEA2  32 01 01
	jr .LF8AED7                                              ; F8AEA5  68 30
.LF8AEA7:
	ld XBC,XDE                                           ; F8AEA7  ea 89
	sla xbc, 16                                        ; F8AEA9  e9 ec 00
	sla xbc, 0x01                                        ; F8AEAC  e9 ec 01
	jr nz, .LF8AEB6                                          ; F8AEAF  6e 05
	ld XBC,0x02000000                                    ; F8AEB1  41 00 00 00 02
.LF8AEB6:
	and XWA,XBC                                          ; F8AEB6  e9 c0
	jr z, .LF8AECA                                           ; F8AEB8  66 10
	ld XDE,XBC                                           ; F8AEBA  e9 8a
	add	(xix-1), 0x11                                ; F8AEBC  8c ff 38 11
	cp	(xix-1), 0x1f                                ; F8AEC0  8c ff 3f 1f
	jr ule, .LF8AECA                                         ; F8AEC4  63 04
	ld (xix-1), 0x19                                     ; F8AEC6  bc ff 00 19
.LF8AECA:
	xor XDE,0xffffffff                                   ; F8AECA  ea cd ff ff ff ff
	and	(PanelHeld_Pos0:16), xde                     ; F8AED0  e1 52 22 ca
	ldw de, 0x0100                                       ; F8AED4  32 00 01
.LF8AED7:
	jp PanelEvent_CommitValue                                        ; F8AED7  1b 0b a9 f8
; PanelAction_PairPos1_HeldMaskAltCode -- pair-position-1 twin of PanelAction_PairPos0_HeldMaskAltCode
; Evidence: pool v1 groups 0x03-0x06 masks 0x02/0x08/0x20/0x80 (bit 1 after the shift).  Same body with the two sets
;   swapped: own held set (0x2256), partner (0x2252); press DE = 0x0202 or 0x0303 (both held), release DE = 0x0200;
;   `add (XIX-1),0x11` at 0xF8AEF1 and `ld (XIX-1),0x19` at 0xF8AEFD rewrite a repeated code.
PanelAction_PairPos1_HeldMaskAltCode:   ; entry: PanelGroupActionListPool
	ld BC,DE                                             ; F8AEDB  da 89
	ld e, (xix-1)                                        ; F8AEDD  8c ff 25
	inc 1,E                                              ; F8AEE0  cd 61
	calr IndexToBitMask32                                          ; F8AEE2  1e 98 fa
	ld xwa, (PanelHeld_Pos1:16)                                 ; F8AEE5  e1 56 22 20
	cp c, 0x00:i3                                          ; F8AEE9  cb d8
	jr z, .LF8AF1A                                           ; F8AEEB  66 2d
	and XWA,XDE                                          ; F8AEED  ea c0
	jr z, .LF8AF06                                           ; F8AEEF  66 15
	add	(xix-1), 0x11                                ; F8AEF1  8c ff 38 11
	sla xde, 16                                        ; F8AEF5  ea ec 00
	sla xde, 0x01                                        ; F8AEF8  ea ec 01
	jr nz, .LF8AF06                                          ; F8AEFB  6e 09
	ld (xix-1), 0x19                                     ; F8AEFD  bc ff 00 19
	ld XDE,0x02000000                                    ; F8AF01  42 00 00 00 02
.LF8AF06:
	or	(PanelHeld_Pos1:16), xde                     ; F8AF06  e1 56 22 ea
	and	xde, (PanelHeld_Pos0:16)                             ; F8AF0A  e1 52 22 c2
	jr z, .LF8AF15                                           ; F8AF0E  66 05
	ldw de, 0x0303                                       ; F8AF10  32 03 03
	jr .LF8AF4A                                              ; F8AF13  68 35
.LF8AF15:
	ldw de, 0x0202                                       ; F8AF15  32 02 02
	jr .LF8AF4A                                              ; F8AF18  68 30
.LF8AF1A:
	ld XBC,XDE                                           ; F8AF1A  ea 89
	sla xbc, 16                                        ; F8AF1C  e9 ec 00
	sla xbc, 0x01                                        ; F8AF1F  e9 ec 01
	jr nz, .LF8AF29                                          ; F8AF22  6e 05
	ld XBC,0x02000000                                    ; F8AF24  41 00 00 00 02
.LF8AF29:
	and XWA,XBC                                          ; F8AF29  e9 c0
	jr z, .LF8AF3D                                           ; F8AF2B  66 10
	ld XDE,XBC                                           ; F8AF2D  e9 8a
	add	(xix-1), 0x11                                ; F8AF2F  8c ff 38 11
	cp	(xix-1), 0x1f                                ; F8AF33  8c ff 3f 1f
	jr ule, .LF8AF3D                                         ; F8AF37  63 04
	ld (xix-1), 0x19                                     ; F8AF39  bc ff 00 19
.LF8AF3D:
	xor XDE,0xffffffff                                   ; F8AF3D  ea cd ff ff ff ff
	and	(PanelHeld_Pos1:16), xde                     ; F8AF43  e1 56 22 ca
	ldw de, 0x0200                                       ; F8AF47  32 00 02
.LF8AF4A:
	jp PanelEvent_CommitValue                                        ; F8AF4A  1b 0b a9 f8
; PanelAction_PairPos0_HeldMask -- pair-position-0 key action: record it held and report which pair members are down
; Evidence: pool v2 groups 0x03-0x05 and 0x08 masks whose shifted bit is bit 0 (LCD LEFT 1-5, -1, soft-key lower row,
;   PAGE v = group 0x02 mask 0x10), v1 groups 0x09/0x0A likewise.  XDE = 1<<code (IndexToBitMask32 at 0xF8AF55).
;   Press: or (0x2252),XDE; DE = 0x0303 if the same code is held in (0x2256) else 0x0101.  Release: clear the bit, DE
;   = 0x0100.  Commits through sub_F8A90B.
PanelAction_PairPos0_HeldMask:   ; entry: PanelGroupActionListPool
	ld BC,DE                                             ; F8AF4E  da 89
	ld e, (xix-1)                                        ; F8AF50  8c ff 25
	inc 1,E                                              ; F8AF53  cd 61
	calr IndexToBitMask32                                          ; F8AF55  1e 25 fa
	cp c, 0x00:i3                                          ; F8AF58  cb d8
	jr z, .LF8AF70                                           ; F8AF5A  66 14
	or	(PanelHeld_Pos0:16), xde                     ; F8AF5C  e1 52 22 ea
	and	xde, (PanelHeld_Pos1:16)                             ; F8AF60  e1 56 22 c2
	jr z, .LF8AF6B                                           ; F8AF64  66 05
	ldw de, 0x0303                                       ; F8AF66  32 03 03
	jr .LF8AF7D                                              ; F8AF69  68 12
.LF8AF6B:
	ldw de, 0x0101                                       ; F8AF6B  32 01 01
	jr .LF8AF7D                                              ; F8AF6E  68 0d
.LF8AF70:
	xor XDE,0xffffffff                                   ; F8AF70  ea cd ff ff ff ff
	and	(PanelHeld_Pos0:16), xde                     ; F8AF76  e1 52 22 ca
	ldw de, 0x0100                                       ; F8AF7A  32 00 01
.LF8AF7D:
	jp PanelEvent_CommitValue                                        ; F8AF7D  1b 0b a9 f8
; PanelAction_PairPos1_HeldMask -- pair-position-1 twin of PanelAction_PairPos0_HeldMask
; Evidence: pool masks whose shifted bit is bit 1 (LCD RIGHT 1-5, +1 and EXIT = v2 group 0x03, soft-key upper row,
;   PAGE ^ = v2 group 0x02 mask 0x20).  or (0x2256),XDE at 0xF8AF8F; DE = 0x0303 if (0x2252) also holds the code else
;   0x0202; release clears the bit and DE = 0x0200.
PanelAction_PairPos1_HeldMask:   ; entry: PanelGroupActionListPool
	ld BC,DE                                             ; F8AF81  da 89
	ld e, (xix-1)                                        ; F8AF83  8c ff 25
	inc 1,E                                              ; F8AF86  cd 61
	calr IndexToBitMask32                                          ; F8AF88  1e f2 f9
	cp c, 0x00:i3                                          ; F8AF8B  cb d8
	jr z, .LF8AFA3                                           ; F8AF8D  66 14
	or	(PanelHeld_Pos1:16), xde                     ; F8AF8F  e1 56 22 ea
	and	xde, (PanelHeld_Pos0:16)                             ; F8AF93  e1 52 22 c2
	jr z, .LF8AF9E                                           ; F8AF97  66 05
	ldw de, 0x0303                                       ; F8AF99  32 03 03
	jr .LF8AFB0                                              ; F8AF9C  68 12
.LF8AF9E:
	ldw de, 0x0202                                       ; F8AF9E  32 02 02
	jr .LF8AFB0                                              ; F8AFA1  68 0d
.LF8AFA3:
	xor XDE,0xffffffff                                   ; F8AFA3  ea cd ff ff ff ff
	and	(PanelHeld_Pos1:16), xde                     ; F8AFA9  e1 56 22 ca
	ldw de, 0x0200                                       ; F8AFAD  32 00 02
.LF8AFB0:
	jp PanelEvent_CommitValue                                        ; F8AFB0  1b 0b a9 f8
; PanelAction_PitchBendToMsbLsb -- turn an 8-bit bend reading into the pitch-bend MSB/LSB pair
; Evidence: pool v1 group 0x0C mask 0xFF; that group's event class is 0xB1, the number MidiIn_PitchBend_ParamTable
;   gives every part (MidiIn_PitchBend stores LSB in E, MSB in D).  `sla 7,DE / srl 1,E` (0xF8AFBD) makes D = r>>1, E
;   = (r&1)<<6; DE >= 0x7F40 becomes 0x7F7F.  `cp (0xC4),0x02 / jrl z,sub_F8A90F` drops it on the SX-WSA1R strap.
PanelAction_PitchBendToMsbLsb:   ; entry: PanelGroupActionListPool
	cp	(Variant_Flag:8), 0x02                               ; F8AFB4  c0 c4 3f 02
	jrl z, PanelEvent_Drop                                         ; F8AFB8  76 54 f9
	xor D,D                                              ; F8AFBB  cc d4
	sla de, 0x07                                         ; F8AFBD  da ec 07
	srl e, 0x01                                          ; F8AFC0  cd ef 01
	cp DE,0x7f40                                         ; F8AFC3  da cf 40 7f
	jr c, .LF8AFCC                                           ; F8AFC7  67 03
	ldw de, 0x7f7f                                       ; F8AFC9  32 7f 7f
.LF8AFCC:
	jp PanelEvent_CommitValue                                        ; F8AFCC  1b 0b a9 f8
; ---------------------------------------------------------------------
; PanelAction_AssignableController -- action handler of the 7-bit (mask 7F)
;          groups v1 0x0B 0x0D 0x10 0x11 0x13 0x14 0x15 and v2 0x14 0x15:
;          slot = PanelGroupToRam7F12Slot[group - 0x0B]; the assignment byte
;          at 0x7F12 + slot is a MIDI controller number, and the chain
;          0xF8AFF2-0xF8B07D rewrites the event's parameter number at
;          (XIX-2) from it -- the ten pairs of PanelCtrl_AssignToParamNumber
;          (check A1) -- or drops the event for any other value.  With
;          (0xC4) = 2 only slots 0x15 / 0x16 get through.
; (notes/proma-2026-09-25/gen_panel_actions.py)
; ---------------------------------------------------------------------
PanelAction_AssignableController:   ; entry: PanelGroupActionListPool
	sub A,0x0b                                           ; F8AFD0  c9 ca 0b
	extz WA                                              ; F8AFD3  d8 12
	extz XWA                                             ; F8AFD5  e8 12
	add XWA,PanelGroupToRam7F12Slot                       ; F8AFD7  e8 c8 7e b0 f8 00
	ld A,(XWA)                                           ; F8AFDD  80 21
	cp	(Variant_Flag:8), 0x02                               ; F8AFDF  c0 c4 3f 02
	jr nz, .LF8AFF2                                          ; F8AFE3  6e 0d
	cp A,0x15                                            ; F8AFE5  c9 cf 15
	jr z, .LF8AFF2                                           ; F8AFE8  66 08
	cp A,0x16                                            ; F8AFEA  c9 cf 16
	jr z, .LF8AFF2                                           ; F8AFED  66 03
	jrl PanelEvent_Drop                                            ; F8AFEF  78 1d f9
.LF8AFF2:
	extz WA                                              ; F8AFF2  d8 12
	extz XWA                                             ; F8AFF4  e8 12
	add XWA,0x00007f12                                   ; F8AFF6  e8 c8 12 7f 00 00
	ld A,(XWA)                                           ; F8AFFC  80 21
	cp a, 0x01:i3                                          ; F8AFFE  c9 d9
	jr nz, .LF8B00A                                          ; F8B000  6e 08
	ld (xix-2), 0xb2                                     ; F8B002  bc fe 00 b2
	jp PanelEvent_CommitValue                                        ; F8B006  1b 0b a9 f8
.LF8B00A:
	cp a, 0x02:i3                                          ; F8B00A  c9 da
	jr nz, .LF8B016                                          ; F8B00C  6e 08
	ld (xix-2), 0xbc                                     ; F8B00E  bc fe 00 bc
	jp PanelEvent_CommitValue                                        ; F8B012  1b 0b a9 f8
.LF8B016:
	cp a, 0x04:i3                                          ; F8B016  c9 dc
	jr nz, .LF8B022                                          ; F8B018  6e 08
	ld (xix-2), 0xbd                                     ; F8B01A  bc fe 00 bd
	jp PanelEvent_CommitValue                                        ; F8B01E  1b 0b a9 f8
.LF8B022:
	cp A,0x0b                                            ; F8B022  c9 cf 0b
	jr nz, .LF8B02F                                          ; F8B025  6e 08
	ld (xix-2), 0xb3                                     ; F8B027  bc fe 00 b3
	jp PanelEvent_CommitValue                                        ; F8B02B  1b 0b a9 f8
.LF8B02F:
	cp A,0x10                                            ; F8B02F  c9 cf 10
	jr nz, .LF8B03C                                          ; F8B032  6e 08
	ld (xix-2), 0xb8                                     ; F8B034  bc fe 00 b8
	jp PanelEvent_CommitValue                                        ; F8B038  1b 0b a9 f8
.LF8B03C:
	cp A,0x11                                            ; F8B03C  c9 cf 11
	jr nz, .LF8B049                                          ; F8B03F  6e 08
	ld (xix-2), 0xb9                                     ; F8B041  bc fe 00 b9
	jp PanelEvent_CommitValue                                        ; F8B045  1b 0b a9 f8
.LF8B049:
	cp A,0x12                                            ; F8B049  c9 cf 12
	jr nz, .LF8B056                                          ; F8B04C  6e 08
	ld (xix-2), 0xba                                     ; F8B04E  bc fe 00 ba
	jp PanelEvent_CommitValue                                        ; F8B052  1b 0b a9 f8
.LF8B056:
	cp A,0x13                                            ; F8B056  c9 cf 13
	jr nz, .LF8B063                                          ; F8B059  6e 08
	ld (xix-2), 0xbb                                     ; F8B05B  bc fe 00 bb
	jp PanelEvent_CommitValue                                        ; F8B05F  1b 0b a9 f8
.LF8B063:
	cp A,0x40                                            ; F8B063  c9 cf 40
	jr nz, .LF8B070                                          ; F8B066  6e 08
	ld (xix-2), 0xb5                                     ; F8B068  bc fe 00 b5
	jp PanelEvent_CommitValue                                        ; F8B06C  1b 0b a9 f8
.LF8B070:
	cp A,0x81                                            ; F8B070  c9 cf 81
	jrl nz, PanelEvent_Drop                                        ; F8B073  7e 99 f8
	ld (xix-2), 0xb4                                     ; F8B076  bc fe 00 b4
	jp PanelEvent_CommitValue                                        ; F8B07A  1b 0b a9 f8
; ---------------------------------------------------------------------
; PanelGroupToRam7F12Slot -- 13 bytes: panel group 0x0B..0x17 -> slot in the
;          RAM byte array at 0x7F12 (index = group - 0x0B).
; Read by: the action handler at 0xF8AFD0 (pool: v1 groups 0x0B 0x0D 0x10
;          0x11 0x13 0x14 0x15, v2 groups 0x14 0x15, all mask 7F -- 7-bit
;          controller values, event classes B2 BC BA BB BD B8 B9) and the
;          one at 0xF8B08B (v1 groups 0x16 0x17, mask 01) (check C1):
;          `sub A,0x0B / add XWA,<this> / ld A,(XWA)` at 0xF8AFD7 and
;          0xF8B099, then both read the byte at 0x7F12 + that slot.
;          0xF8AFD0 turns that byte into the event's CLASS (1->B2, 2->BC,
;          4->BD, 0x0B->B3, 0x10->B8, 0x11->B9, 0x12->BA, 0x13->BB,
;          0x40->B5, 0x81->B4, anything else drops the event); with
;          (0xC4) = 2 it lets only slots 0x15/0x16 through.  0xF8B08B
;          branches on it (0x40, 0x88, 0x89, ...).
; So the RAM bytes at 0x7F12 + slot hold an ASSIGNMENT per controller, and
;          the assignment is a MIDI controller number (0x81 = channel
;          pressure): the byte -> CLASS map above is the MIDI-in
;          controller -> parameter-number map (the CLASS of the panel event
;          lists is byte 0, the parameter number) -- see
;          PanelCtrl_AssignToParamNumber, check A1 of gen_panel_actions.py.
; COUNT 13 = groups 0x0B..0x17; the unused slots (groups 0x0C 0x0E 0x0F
;          0x12, which the pool never sends here) are 0.
; ⚠ Which physical controllers the groups are is not established here.
; (was framed as code; notes/proma-2026-09-25/reframe_panel_tables.py,
;  headers from notes/proma-2026-09-25/retitle_panel_tables.py)
; ---------------------------------------------------------------------
PanelGroupToRam7F12Slot:
	.byte 0x11, 0x00, 0x12, 0x00, 0x00, 0x17, 0x18, 0x00, 0x02, 0x15, 0x16, 0x04, 0x05  ; F8B07E  [0]
; ---------------------------------------------------------------------
; PanelAction_AssignableSwitch -- action handler of v1 groups 0x16 and 0x17,
;          mask 01 (switches): dropped when (0xC4) = 2; otherwise the slot
;          byte (PanelGroupToRam7F12Slot, slots 0x04 / 0x05) selects:
;   0x40 -> PanelAction_SwitchSendsHold: event word 0x00B5, value 0x7F on / 0x00 off -- a
;          Hold (controller 0x40, parameter number 0xB5) switch (check A4);
;   0x88 -> PanelAction_SelectNextSound, 0x89 -> PanelAction_SelectPrevSound, 0x90 -> PanelAction_SwitchRaisesClassA8Code11 (which writes
;          event word 0x11A8); anything else drops the event.
; ⚠ 0x88, 0x89 and 0x90 are not controller numbers; what they assign is
;          not established here.
; (notes/proma-2026-09-25/gen_panel_actions.py)
; ---------------------------------------------------------------------
PanelAction_AssignableSwitch:   ; entry: PanelGroupActionListPool
	cp	(Variant_Flag:8), 0x02                               ; F8B08B  c0 c4 3f 02
	jrl z, PanelEvent_Drop                                         ; F8B08F  76 7d f8
	sub A,0x0b                                           ; F8B092  c9 ca 0b
	extz WA                                              ; F8B095  d8 12
	extz XWA                                             ; F8B097  e8 12
	add XWA,PanelGroupToRam7F12Slot                       ; F8B099  e8 c8 7e b0 f8 00
	ld A,(XWA)                                           ; F8B09F  80 21
	extz WA                                              ; F8B0A1  d8 12
	extz XWA                                             ; F8B0A3  e8 12
	add XWA,0x00007f12                                   ; F8B0A5  e8 c8 12 7f 00 00
	ld A,(XWA)                                           ; F8B0AB  80 21
	cp A,0x40                                            ; F8B0AD  c9 cf 40
	jr nz, .LF8B0B6                                          ; F8B0B0  6e 04
	jp PanelAction_SwitchSendsHold                                        ; F8B0B2  1b 98 b2 f8
.LF8B0B6:
	cp A,0x88                                            ; F8B0B6  c9 cf 88
	jr nz, .LF8B0BF                                          ; F8B0B9  6e 04
	jp PanelAction_SelectNextSound                                        ; F8B0BB  1b d2 b0 f8
.LF8B0BF:
	cp A,0x89                                            ; F8B0BF  c9 cf 89
	jr nz, .LF8B0C8                                          ; F8B0C2  6e 04
	jp PanelAction_SelectPrevSound                                        ; F8B0C4  1b c1 b1 f8
.LF8B0C8:
	cp A,0x90                                            ; F8B0C8  c9 cf 90
	jrl nz, PanelEvent_Drop                                        ; F8B0CB  7e 41 f8
	jp PanelAction_SwitchRaisesClassA8Code11                                        ; F8B0CE  1b b5 b2 f8
; PanelAction_SelectNextSound -- assignable-switch function 0x88: step the part's sound forward
; Evidence: PanelAction_AssignableSwitch jumps here for slot byte 0x88.  Record = part record (+0x1D bank, +0x1B
;   group, +0x1C member) or, in combination mode, (0x7F0A)/(0x7F08)/(0x7F09) with event 0x98/01.  member < max
;   (T_SoundGroup_MaxMemberIndex_Get[_ToneCopy]) -> member+1; else group+1 (limit 1/0/0x0F by bank) with member 0, or
;   drop. Emits two events: [part,0] value = bank, then value = (group,member); sets bit 1 of (0x60F020).
PanelAction_SelectNextSound:
	ld a, (PanelModeGroup:16)                                   ; F8B0D2  c1 76 20 21
	cp A,0x09                                            ; F8B0D6  c9 cf 09
	jr z, .LF8B0F5                                           ; F8B0D9  66 1a
	cp A,0x08                                            ; F8B0DB  c9 cf 08
	jr z, .LF8B0F5                                           ; F8B0DE  66 15
	cp a, 0x03:i3                                          ; F8B0E0  c9 db
	jr z, .LF8B0F5                                           ; F8B0E2  66 11
	cp A,0x16                                            ; F8B0E4  c9 cf 16
	jr z, .LF8B0F5                                           ; F8B0E7  66 0c
	ld a, (0x7f02:16)                                   ; F8B0E9  c1 02 7f 21
	and A,0xf0                                           ; F8B0ED  c9 cc f0
	cp a, 0x00:i3                                          ; F8B0F0  c9 d8
	jrl nz, .LF8B16C                                         ; F8B0F2  7e 77 00
.LF8B0F5:
	push XIY                                             ; F8B0F5  3d
	pushw hl                                             ; F8B0F6  2b
	and E,D                                              ; F8B0F7  cc c5
	jr z, .LF8B166                                           ; F8B0F9  66 6b
	ld a, (UI_PartIndex:16)                                   ; F8B0FB  c1 50 22 21
	ld w, 0x00:opc                                          ; F8B0FF  20 00
	ld (xix-2), wa                                       ; F8B101  bc fe 50
	ld (XIX+0x02),WA                                     ; F8B104  bc 02 50
	mul A,0x04                                           ; F8B107  c9 08 04
	add WA,0x0080                                        ; F8B10A  d8 c8 80 00
	extz XWA                                             ; F8B10E  e8 12
	add xwa, (IndexedTable_Base:24)                           ; F8B110  e2 18 f0 60 80
	ld XWA,(XWA)                                         ; F8B115  a0 20
	ld b, (UI_PartIndex:16)                                   ; F8B117  c1 50 22 22
	ld C,(XWA+0x1d)                                      ; F8B11B  88 1d 23
	ld L,(XWA+0x1b)                                      ; F8B11E  88 1b 27
	ld H,(XWA+0x1c)                                      ; F8B121  88 1c 26
	ld A,L                                               ; F8B124  cf 89
	ld W,C                                               ; F8B126  cb 88
	call T_SoundGroup_MaxMemberIndex_Get                 ; F8B128  1d 1c 10 f4
	cp H,A                                               ; F8B12C  c9 f6
	jr nc, .LF8B134                                          ; F8B12E  6f 04
	inc 1,H                                              ; F8B130  ce 61
	jr .LF8B151                                              ; F8B132  68 1d
.LF8B134:
	ld a, 0x01:opc                                          ; F8B134  21 01
	cp C,0x20                                            ; F8B136  cb cf 20
	jr z, .LF8B149                                           ; F8B139  66 0e
	ld a, 0x00:opc                                          ; F8B13B  21 00
	cp C,0x28                                            ; F8B13D  cb cf 28
	jr z, .LF8B149                                           ; F8B140  66 07
	cp C,0x29                                            ; F8B142  cb cf 29
	jr z, .LF8B149                                           ; F8B145  66 02
	ld a, 0x0f:opc                                          ; F8B147  21 0f
.LF8B149:
	cp L,A                                               ; F8B149  c9 f7
	jr nc, .LF8B166                                          ; F8B14B  6f 19
	inc 1,L                                              ; F8B14D  cf 61
	xor H,H                                              ; F8B14F  ce d6
.LF8B151:
	ld E,C                                               ; F8B151  cb 8d
	calr PanelEvent_CommitValue                                          ; F8B153  1e b5 f7
	inc 2,XIX                                            ; F8B156  ec 62
	ld DE,HL                                             ; F8B158  db 8a
	or	(0x60f020:24), 0x02                          ; F8B15A  c2 20 f0 60 3e 02
	popw hl                                              ; F8B160  4b
	pop XIY                                              ; F8B161  5d
	jp PanelEvent_CommitValue                                        ; F8B162  1b 0b a9 f8
.LF8B166:
	popw hl                                              ; F8B166  4b
	pop XIY                                              ; F8B167  5d
	jp PanelEvent_Drop                                        ; F8B168  1b 0f a9 f8
.LF8B16C:
	push XIY                                             ; F8B16C  3d
	pushw hl                                             ; F8B16D  2b
	and E,D                                              ; F8B16E  cc c5
	jr z, .LF8B1BB                                           ; F8B170  66 49
	ld a, 0x98:opc                                          ; F8B172  21 98
	ld w, 0x01:opc                                          ; F8B174  20 01
	ld (xix-2), wa                                       ; F8B176  bc fe 50
	ld (XIX+0x02),WA                                     ; F8B179  bc 02 50
	ld XWA,0x00007f02                                    ; F8B17C  40 02 7f 00 00
	ld b, 0x98:opc                                          ; F8B181  22 98
	ld C,(XWA+0x08)                                      ; F8B183  88 08 23
	ld L,(XWA+0x06)                                      ; F8B186  88 06 27
	ld H,(XWA+0x07)                                      ; F8B189  88 07 26
	ld A,L                                               ; F8B18C  cf 89
	ld W,C                                               ; F8B18E  cb 88
	call T_SoundGroup_MaxMemberIndex_GetToneCopy         ; F8B190  1d 34 10 f4
	cp H,A                                               ; F8B194  c9 f6
	jr nc, .LF8B19C                                          ; F8B196  6f 04
	inc 1,H                                              ; F8B198  ce 61
	jr .LF8B1A6                                              ; F8B19A  68 0a
.LF8B19C:
	ld a, 0x0f:opc                                          ; F8B19C  21 0f
	cp L,A                                               ; F8B19E  c9 f7
	jr nc, .LF8B1BB                                          ; F8B1A0  6f 19
	inc 1,L                                              ; F8B1A2  cf 61
	xor H,H                                              ; F8B1A4  ce d6
.LF8B1A6:
	ld E,C                                               ; F8B1A6  cb 8d
	calr PanelEvent_CommitValue                                          ; F8B1A8  1e 60 f7
	inc 2,XIX                                            ; F8B1AB  ec 62
	ld DE,HL                                             ; F8B1AD  db 8a
	or	(0x60f020:24), 0x02                          ; F8B1AF  c2 20 f0 60 3e 02
	popw hl                                              ; F8B1B5  4b
	pop XIY                                              ; F8B1B6  5d
	jp PanelEvent_CommitValue                                        ; F8B1B7  1b 0b a9 f8
.LF8B1BB:
	popw hl                                              ; F8B1BB  4b
	pop XIY                                              ; F8B1BC  5d
	jp PanelEvent_Drop                                        ; F8B1BD  1b 0f a9 f8
; PanelAction_SelectPrevSound -- assignable-switch function 0x89: step the part's sound backward
; Evidence: PanelAction_AssignableSwitch jumps here for slot byte 0x89.  Same records as PanelAction_SelectNextSound;
;   member > 0 -> member-1 (0xF8B212); else group > 0 -> group-1 and member = T_SoundGroup_MaxMemberIndex_Get of the
;   new group (0xF8B224 / _GetToneCopy 0xF8B277); group 0 member 0 drops the event.  Emits bank then (group,member)
;   and sets bit 1 of (0x60F020).
PanelAction_SelectPrevSound:
	ld a, (PanelModeGroup:16)                                   ; F8B1C1  c1 76 20 21
	cp A,0x09                                            ; F8B1C5  c9 cf 09
	jr z, .LF8B1E3                                           ; F8B1C8  66 19
	cp A,0x08                                            ; F8B1CA  c9 cf 08
	jr z, .LF8B1E3                                           ; F8B1CD  66 14
	cp a, 0x03:i3                                          ; F8B1CF  c9 db
	jr z, .LF8B1E3                                           ; F8B1D1  66 10
	cp A,0x16                                            ; F8B1D3  c9 cf 16
	jr z, .LF8B1E3                                           ; F8B1D6  66 0b
	ld a, (0x7f02:16)                                   ; F8B1D8  c1 02 7f 21
	and A,0xf0                                           ; F8B1DC  c9 cc f0
	cp a, 0x00:i3                                          ; F8B1DF  c9 d8
	jr nz, .LF8B245                                          ; F8B1E1  6e 62
.LF8B1E3:
	push XIY                                             ; F8B1E3  3d
	pushw hl                                             ; F8B1E4  2b
	and E,D                                              ; F8B1E5  cc c5
	jr z, .LF8B23F                                           ; F8B1E7  66 56
	ld a, (UI_PartIndex:16)                                   ; F8B1E9  c1 50 22 21
	ld w, 0x00:opc                                          ; F8B1ED  20 00
	ld (xix-2), wa                                       ; F8B1EF  bc fe 50
	ld (XIX+0x02),WA                                     ; F8B1F2  bc 02 50
	mul A,0x04                                           ; F8B1F5  c9 08 04
	add WA,0x0080                                        ; F8B1F8  d8 c8 80 00
	extz XWA                                             ; F8B1FC  e8 12
	add xwa, (IndexedTable_Base:24)                           ; F8B1FE  e2 18 f0 60 80
	ld XWA,(XWA)                                         ; F8B203  a0 20
	ld C,(XWA+0x1d)                                      ; F8B205  88 1d 23
	ld L,(XWA+0x1b)                                      ; F8B208  88 1b 27
	ld H,(XWA+0x1c)                                      ; F8B20B  88 1c 26
	cp h, 0x00:i3                                          ; F8B20E  ce d8
	jr ule, .LF8B216                                         ; F8B210  63 04
	dec 1,H                                              ; F8B212  ce 69
	jr .LF8B22A                                              ; F8B214  68 14
.LF8B216:
	cp l, 0x00:i3                                          ; F8B216  cf d8
	jr ule, .LF8B23F                                         ; F8B218  63 25
	dec 1,L                                              ; F8B21A  cf 69
	ld b, (UI_PartIndex:16)                                   ; F8B21C  c1 50 22 22
	ld A,L                                               ; F8B220  cf 89
	ld W,C                                               ; F8B222  cb 88
	call T_SoundGroup_MaxMemberIndex_Get                 ; F8B224  1d 1c 10 f4
	ld H,A                                               ; F8B228  c9 8e
.LF8B22A:
	ld E,C                                               ; F8B22A  cb 8d
	calr PanelEvent_CommitValue                                          ; F8B22C  1e dc f6
	inc 2,XIX                                            ; F8B22F  ec 62
	ld DE,HL                                             ; F8B231  db 8a
	or	(0x60f020:24), 0x02                          ; F8B233  c2 20 f0 60 3e 02
	popw hl                                              ; F8B239  4b
	pop XIY                                              ; F8B23A  5d
	jp PanelEvent_CommitValue                                        ; F8B23B  1b 0b a9 f8
.LF8B23F:
	popw hl                                              ; F8B23F  4b
	pop XIY                                              ; F8B240  5d
	jp PanelEvent_Drop                                        ; F8B241  1b 0f a9 f8
.LF8B245:
	push XIY                                             ; F8B245  3d
	pushw hl                                             ; F8B246  2b
	and E,D                                              ; F8B247  cc c5
	jr z, .LF8B292                                           ; F8B249  66 47
	ld a, 0x98:opc                                          ; F8B24B  21 98
	ld w, 0x01:opc                                          ; F8B24D  20 01
	ld (xix-2), wa                                       ; F8B24F  bc fe 50
	ld (XIX+0x02),WA                                     ; F8B252  bc 02 50
	ld XWA,0x00007f02                                    ; F8B255  40 02 7f 00 00
	ld C,(XWA+0x08)                                      ; F8B25A  88 08 23
	ld L,(XWA+0x06)                                      ; F8B25D  88 06 27
	ld H,(XWA+0x07)                                      ; F8B260  88 07 26
	cp h, 0x00:i3                                          ; F8B263  ce d8
; (sub_F8B265 removed 2026-10-04: no code names it and the line above falls through into it -- part of PanelAction_SelectPrevSound;
;  notes/prom_a_stray_label_removal.py)
	jr ule, .LF8B26B                                         ; F8B265  63 04
	dec 1,H                                              ; F8B267  ce 69
	jr .LF8B27D                                              ; F8B269  68 12
.LF8B26B:
	cp l, 0x00:i3                                          ; F8B26B  cf d8
	jr ule, .LF8B292                                         ; F8B26D  63 23
	dec 1,L                                              ; F8B26F  cf 69
	ld b, 0x98:opc                                          ; F8B271  22 98
	ld A,L                                               ; F8B273  cf 89
	ld W,C                                               ; F8B275  cb 88
	call T_SoundGroup_MaxMemberIndex_GetToneCopy         ; F8B277  1d 34 10 f4
	ld H,A                                               ; F8B27B  c9 8e
.LF8B27D:
	ld E,C                                               ; F8B27D  cb 8d
	calr PanelEvent_CommitValue                                          ; F8B27F  1e 89 f6
	inc 2,XIX                                            ; F8B282  ec 62
	ld DE,HL                                             ; F8B284  db 8a
	or	(0x60f020:24), 0x02                          ; F8B286  c2 20 f0 60 3e 02
	popw hl                                              ; F8B28C  4b
	pop XIY                                              ; F8B28D  5d
	jp PanelEvent_CommitValue                                        ; F8B28E  1b 0b a9 f8
.LF8B292:
	popw hl                                              ; F8B292  4b
	pop XIY                                              ; F8B293  5d
	jp PanelEvent_Drop                                        ; F8B294  1b 0f a9 f8
; PanelAction_SwitchSendsHold -- assignable-switch function 0x40: the switch acts as a Hold pedal
; Evidence: PanelAction_AssignableSwitch jumps here for slot byte 0x40 (controller 0x40); `ld (XIX-2),0x00B5` at
;   0xF8B29E writes parameter number 0xB5 (PanelCtrl_AssignToParamNumber maps 0x40 -> 0xB5); pressed DE = 0x7F7F,
;   released 0x7F00; or (0x60F020),0x02.
PanelAction_SwitchSendsHold:
	or	(0x60f020:24), 0x02                          ; F8B298  c2 20 f0 60 3e 02
	ldw	(xix-2), 0x00b5                              ; F8B29E  bc fe 02 b5 00
	and E,D                                              ; F8B2A3  cc c5
	jr z, .LF8B2AE                                           ; F8B2A5  66 07
	ldw de, 0x7f7f                                       ; F8B2A7  32 7f 7f
	jp PanelEvent_CommitValue                                        ; F8B2AA  1b 0b a9 f8
.LF8B2AE:
	ldw de, 0x7f00                                       ; F8B2AE  32 00 7f
	jp PanelEvent_CommitValue                                        ; F8B2B1  1b 0b a9 f8
; PanelAction_SwitchRaisesClassA8Code11 -- assignable-switch function 0x90: re-label the event as class A8 code 0x11
; Evidence: PanelAction_AssignableSwitch jumps here for slot byte 0x90; `ld (XIX-2),0x11A8` at 0xF8B2BB, or
;   (0x60F020),0x02, then sub_F8A90B commits the incoming DE.  v1 group 0x07 bits 6-7 raise the same A8/11 natively.
; Unknown: what event A8/11 does.
PanelAction_SwitchRaisesClassA8Code11:
	or	(0x60f020:24), 0x02                          ; F8B2B5  c2 20 f0 60 3e 02
	ldw	(xix-2), 0x11a8                              ; F8B2BB  bc fe 02 a8 11
	jp PanelEvent_CommitValue                                        ; F8B2C0  1b 0b a9 f8
; PanelEvents_StampCurrentPart -- stamp the current part (0x2250) into the panel events just expanded
; Evidence: called only from sub_F8A81D right after PanelGroupQueue_ExpandToEvents; walks 4-byte records from 0x2030
;   to the 0xFF terminator; class byte 0x20 -> PanelEvent_StampPartIntoClass20, class 0x00 ->
;   PanelEvent_StampPartIntoClass00. (0x2250) is the part index (FINDINGS-l7a1429-parameter-names.md 2c, GRADE
;   PROVEN).
PanelEvents_StampCurrentPart:
	ld XIX,0x00002030                                    ; F8B2C4  44 30 20 00 00
.LF8B2C9:
	ld WA,(XIX)                                          ; F8B2C9  94 20
	cp A,0xff                                            ; F8B2CB  c9 cf ff
	jr z, .LF8B2E9                                           ; F8B2CE  66 19
	cp A,0x20                                            ; F8B2D0  c9 cf 20
	jr nz, .LF8B2DA                                          ; F8B2D3  6e 05
	calr PanelEvent_StampPartIntoClass20                                            ; F8B2D5  1e 12 00
	jr .LF8B2E1                                              ; F8B2D8  68 07
.LF8B2DA:
	cp a, 0x00:i3                                          ; F8B2DA  c9 d8
	jr nz, .LF8B2E1                                          ; F8B2DC  6e 03
	calr PanelEvent_StampPartIntoClass00                                            ; F8B2DE  1e 26 00
.LF8B2E1:
	add XIX,0x00000004                                   ; F8B2E1  ec c8 04 00 00 00
	jr .LF8B2C9                                               ; F8B2E7  68 e0
.LF8B2E9:
	ret                                                  ; F8B2E9  0e
; PanelEvent_StampPartIntoClass20 -- class 0x20 event -> class 0x20 | current part
; Evidence: scans Var2250_AcceptList for (0x2250) (0xF8B2EE); hit -> C = part, miss -> C = 0x20; `or C,0x20` / `ld
;   (XIX),C`. The UI pass-B lists for classes 0x20-0x3F (PanelLed_OnClass20Event) consume the result.
PanelEvent_StampPartIntoClass20:
	ld c, (UI_PartIndex:16)                                   ; F8B2EA  c1 50 22 23
	ld XIY,Var2250_AcceptList                            ; F8B2EE  45 25 b3 f8 00
.LF8B2F3:
	ld a, (xiy+)                                      ; F8B2F3  c5 f4 21
	cp A,C                                               ; F8B2F6  cb f1
	jr z, .LF8B301                                           ; F8B2F8  66 07
	cp A,0xff                                            ; F8B2FA  c9 cf ff
	jr nz, .LF8B2F3                                           ; F8B2FD  6e f4
	ld c, 0x20:opc                                          ; F8B2FF  23 20
.LF8B301:
	or C,0x20                                            ; F8B301  cb ce 20
	ld (XIX),C                                           ; F8B304  b4 43
	ret                                                  ; F8B306  0e
; PanelEvent_StampPartIntoClass00 -- class 0x00 event -> class = current part (code 3 left alone)
; Evidence: `cp W,3 / jr z` at 0xF8B307 skips code 3; otherwise scans Var2250_AcceptList for (0x2250) and stores the
;   part (or 0 on a miss) as the class byte.  Classes 0x00-0x1F are per-part, the [part][0] form
;   MidiIn_ProgramChange_ParamTable also posts.
PanelEvent_StampPartIntoClass00:
	cp w, 0x03:i3                                          ; F8B307  c8 db
	jr z, .LF8B324                                           ; F8B309  66 19
	ld c, (UI_PartIndex:16)                                   ; F8B30B  c1 50 22 23
	ld XIY,Var2250_AcceptList                            ; F8B30F  45 25 b3 f8 00
.LF8B314:
	ld a, (xiy+)                                      ; F8B314  c5 f4 21
	cp A,C                                               ; F8B317  cb f1
	jr z, .LF8B322                                           ; F8B319  66 07
	cp A,0xff                                            ; F8B31B  c9 cf ff
	jr nz, .LF8B314                                           ; F8B31E  6e f4
	ld c, 0x00:opc                                          ; F8B320  23 00
.LF8B322:
	ld (XIX),C                                           ; F8B322  b4 43
.LF8B324:
	ret                                                  ; F8B324  0e
; ---------------------------------------------------------------------
; THE PANEL LAYER-2 TABLES -- 0xF8B325-0xF8BBB3, 2,191 bytes, NINE objects.
;
; This block was one undifferentiated `.byte` region called
; PanelTables_F8B325 until round 11.  It is the table half of the panel
; event pipeline, and the pipeline is now readable end to end:
;
;   CP1 panel MCU  --3 bytes-->  prom_b SC1_RxOp0_ThreeByte (0xF5B0D5)
;      queues [wire][new value][old XOR new] at RAM 0x2B40
;   PanelWireQueue_DrainToGroupQueue (0xF8A088) drains it, maps the wire
;      through PanelWireGroupMap_Variant1/2 to a GROUP id, and calls
;   PanelGroupQueue_Append (0xF8A3B2), which appends
;      [group][value][change mask] to a second queue at RAM 0x2000
;      (count in (0x219A), hard limit 7 records)
;   PanelGroupQueue_ExpandToEvents (0xF8A824) walks that queue and, PER
;      GROUP, fetches ONE LIST from the tables below and writes UI events
;      to the fixed list at RAM 0x2030
;   UiEvent_RouteByCode (0xF8659B) then dispatches on the event's code.
;
; ★ WHY THE BOUNDARIES ARE NOT GUESSES.  Six of the nine objects are the
;   operand of an `ld XIX/XIY,imm32` in the code above -- 0xF8B2EE and
;   0xF8B30F (accept list), 0xF8AA31, 0xF8A84C, 0xF8A857, 0xF8A8CC,
;   0xF8A8D7.  The other three are pinned by ABUTMENT: each pointer
;   table's length is exactly (next load - this load), and each pool runs
;   from its lowest list to the byte before the next loaded table.  The
;   nine tile the block with no byte left over, and
;   notes/prom_a_panel_names_round11.py asserts that tiling on every run.
;
; ★ RECORD SHAPES, both pinned by GEOMETRY, not by a stride that looked
;   plausible: an event-list record is 4 bytes and all 39 gaps between
;   consecutive lists in the event pool are 1 mod 4; an action-list record
;   is 6 bytes; both pools end on the byte before the next object.
;
; ⚠ WHAT IS STILL NOT KNOWN, stated rather than smoothed over:
;   * NOBODY FOUND PRODUCES EVENT CODE 0x0E, though UiEvent_RouteByCode
;     has an 0x0E arm.  The six fixed-group producers in
;     PanelGroupQueue_AppendFlaggedGroups emit code 0x00 only, and the
;     seventh producer (0xF8A2D6) takes its group from RAM (0x219C) at
;     run time, so no static read can enumerate it.
;   * THREE PAIRS OF VARIANT-1 LISTS ARE BYTE-IDENTICAL -- groups
;     0x01/0x02, 0x03/0x04 and 0x05/0x06 -- so identical (class, code,
;     position) triples arrive from two different wires.  NO ROUTINE IN
;     THIS MODULE IS NAMED FROM A COLLIDING CODE.
;   * THE GROUP NUMBERING AND THE PHYSICAL SEGMENT NUMBERING DISAGREE FOR
;     THE DIAL.  notes/wave7_panel_button_codes.py puts the -1/+1 pair at
;     matrix segment 3; the table below puts code 0x0D (proven to be that
;     pair by the sign argument in notes/wave7_panel_event_index.py) at
;     GROUP 0x0A, and group == segment for wires 0xC0-0xCA.  One of the
;     two maps is wrong.  Neither has been edited to hide it.
;   * WHAT (0x2250) HOLDS.  Two objects here are named for that cell
;     because it is the only thing established about them.
;
; Evidence: the seven framing loads listed above, `cp A,0x18` at 0xF8A83B,
;          `cp (XHL),0xff` at 0xF8A862, `ld WA,(XHL+)`/`ld (XIX+),WA` at
;          0xF8A867/0xF8A86A, `ld W,(XHL)` + `and D,W`/`and E,W` at
;          0xF8A877-0xF8A87D, `ld (XIX+),DE` at 0xF8A90B.
; ---------------------------------------------------------------------

; ---------------------------------------------------------------------
; Var2250_AcceptList -- 33 bytes: 0x00..0x1F then a 0xFF terminator.
;
; It is a MEMBERSHIP LIST, not an identity map.  Two routines scan it
; for the byte in (0x2250) and CLAMP on a miss:
;   PanelEvent_StampPartIntoClass20  miss -> C = 0x20, then `or C,0x20`, then store to (XIX)
;   PanelEvent_StampPartIntoClass00  miss -> C = 0x00, then store to (XIX)
; ★ AND THE RANGE IS NOT ARBITRARY.  0xF8AA31 uses the SAME cell as an
;   index into RecordFieldPtrs_RAM76A2_Plus20, which has exactly 32
;   entries -- so this list is the valid-index test for that table.
; ⚠ What (0x2250) MEANS is not established; the name states the cell.
; Evidence: `ld XIY,0x00F8B325` at 0xF8B2EE and 0xF8B30F, the scan
;          `ld A,(XIY+)` / `cp A,C` / `cp A,0xFF` at 0xF8B2F3-0xF8B2FD,
;          `ld C,(0x2250)` at 0xF8B2EA and 0xF8B30B, and
;          `ld A,(0x2250)` / `sla A,2` at 0xF8AA36-0xF8AA3A.
; ---------------------------------------------------------------------

Var2250_AcceptList:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f ; F8B325
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f ; F8B335
	.byte 0xff                                                 ; F8B345
; ---------------------------------------------------------------------
; RecordPtrs_RAM76A2_Panel -- 32 x LE32 into the 64-byte RAM records
; at 0x76A2.  A THIRD COPY of a pointer array this tree already knows,
; and the agreement is EXACT, not approximate: the first 32 of
; RecordPtrs_RAM76A2's 35 entries (0xFEB330) are byte-identical to these
; 32, and 0xFF4251's 16 entries are these same bases plus 13.
; ★ THE STEP IS NOT UNIFORM, and the header this replaced said it was.
;   Thirty of the thirty-one steps are 0x40; step 7 is 0x80, so the
;   record at 0x78A2 is SKIPPED (entry 7 is 0x7862, entry 8 is 0x78E2).
;   The 0xFEB330 header records the same single 0x80 step in the same
;   place, from a different module -- three witnesses, one layout.
; ⚠ NO READER FOUND.  A scan of both of CPU 1's ROMs for `ld XRR,imm32`,
;   `call`, `jp` and a bare LE32 pointer naming 0xF8B346 returns NOTHING,
;   while the sibling below is loaded at 0xF8AA31.  The bound of the
;   reader that would use it is therefore unknown; 32 is the ABUTMENT
;   against 0xF8B3C6, not a count read off a reader.
; Evidence: the abutment 0xF8B3C6 - 0xF8B346 = 0x80 = 32 x 4; the 
;          entry-by-entry difference to the sibling is 0x20 for all 32.
; ---------------------------------------------------------------------

RecordPtrs_RAM76A2_Panel:
	.long 0x000076a2                                    ; F8B346  [ 0] RAM record 0
	.long 0x000076e2                                    ; F8B34A  [ 1] RAM record 1
	.long 0x00007722                                    ; F8B34E  [ 2] RAM record 2
	.long 0x00007762                                    ; F8B352  [ 3] RAM record 3
	.long 0x000077a2                                    ; F8B356  [ 4] RAM record 4
	.long 0x000077e2                                    ; F8B35A  [ 5] RAM record 5
	.long 0x00007822                                    ; F8B35E  [ 6] RAM record 6
	.long 0x00007862                                    ; F8B362  [ 7] RAM record 7
	.long 0x000078e2                                    ; F8B366  [ 8] RAM record 8
	.long 0x00007922                                    ; F8B36A  [ 9] RAM record 9
	.long 0x00007962                                    ; F8B36E  [10] RAM record 10
	.long 0x000079a2                                    ; F8B372  [11] RAM record 11
	.long 0x000079e2                                    ; F8B376  [12] RAM record 12
	.long 0x00007a22                                    ; F8B37A  [13] RAM record 13
	.long 0x00007a62                                    ; F8B37E  [14] RAM record 14
	.long 0x00007aa2                                    ; F8B382  [15] RAM record 15
	.long 0x00007ae2                                    ; F8B386  [16] RAM record 16
	.long 0x00007b22                                    ; F8B38A  [17] RAM record 17
	.long 0x00007b62                                    ; F8B38E  [18] RAM record 18
	.long 0x00007ba2                                    ; F8B392  [19] RAM record 19
	.long 0x00007be2                                    ; F8B396  [20] RAM record 20
	.long 0x00007c22                                    ; F8B39A  [21] RAM record 21
	.long 0x00007c62                                    ; F8B39E  [22] RAM record 22
	.long 0x00007ca2                                    ; F8B3A2  [23] RAM record 23
	.long 0x00007ce2                                    ; F8B3A6  [24] RAM record 24
	.long 0x00007d22                                    ; F8B3AA  [25] RAM record 25
	.long 0x00007d62                                    ; F8B3AE  [26] RAM record 26
	.long 0x00007da2                                    ; F8B3B2  [27] RAM record 27
	.long 0x00007de2                                    ; F8B3B6  [28] RAM record 28
	.long 0x00007e22                                    ; F8B3BA  [29] RAM record 29
	.long 0x00007e62                                    ; F8B3BE  [30] RAM record 30
	.long 0x00007ea2                                    ; F8B3C2  [31] RAM record 31
; ---------------------------------------------------------------------
; RecordFieldPtrs_RAM76A2_Plus20 -- 32 x LE32, each pointing 0x20 bytes
; into the same record the table above points at the base of.  The
; difference is 0x20 for every one of the 32 entries.
; Read by: 0xF8AA31 `ld XIX,0x00F8B3C6`, then `ld A,(0x2250)` /
;          `sla A,2` / `ld XIX,(XIX+A)` at 0xF8AA36-0xF8AA3D, then
;          `ld A,(XIX+0x18)` and `bit 0,A` at 0xF8AA42-0xF8AA46.
;          So the caller reads bit 0 of the record byte at +0x38.
; Evidence: the load at 0xF8AA31; the index cell (0x2250) is the same
;          cell Var2250_AcceptList validates.
; ---------------------------------------------------------------------

RecordFieldPtrs_RAM76A2_Plus20:
	.long 0x000076c2                                    ; F8B3C6  [ 0] RAM record 0 + 0x20
	.long 0x00007702                                    ; F8B3CA  [ 1] RAM record 1 + 0x20
	.long 0x00007742                                    ; F8B3CE  [ 2] RAM record 2 + 0x20
	.long 0x00007782                                    ; F8B3D2  [ 3] RAM record 3 + 0x20
	.long 0x000077c2                                    ; F8B3D6  [ 4] RAM record 4 + 0x20
	.long 0x00007802                                    ; F8B3DA  [ 5] RAM record 5 + 0x20
	.long 0x00007842                                    ; F8B3DE  [ 6] RAM record 6 + 0x20
	.long 0x00007882                                    ; F8B3E2  [ 7] RAM record 7 + 0x20
	.long 0x00007902                                    ; F8B3E6  [ 8] RAM record 8 + 0x20
	.long 0x00007942                                    ; F8B3EA  [ 9] RAM record 9 + 0x20
	.long 0x00007982                                    ; F8B3EE  [10] RAM record 10 + 0x20
	.long 0x000079c2                                    ; F8B3F2  [11] RAM record 11 + 0x20
	.long 0x00007a02                                    ; F8B3F6  [12] RAM record 12 + 0x20
	.long 0x00007a42                                    ; F8B3FA  [13] RAM record 13 + 0x20
	.long 0x00007a82                                    ; F8B3FE  [14] RAM record 14 + 0x20
	.long 0x00007ac2                                    ; F8B402  [15] RAM record 15 + 0x20
	.long 0x00007b02                                    ; F8B406  [16] RAM record 16 + 0x20
	.long 0x00007b42                                    ; F8B40A  [17] RAM record 17 + 0x20
	.long 0x00007b82                                    ; F8B40E  [18] RAM record 18 + 0x20
	.long 0x00007bc2                                    ; F8B412  [19] RAM record 19 + 0x20
	.long 0x00007c02                                    ; F8B416  [20] RAM record 20 + 0x20
	.long 0x00007c42                                    ; F8B41A  [21] RAM record 21 + 0x20
	.long 0x00007c82                                    ; F8B41E  [22] RAM record 22 + 0x20
	.long 0x00007cc2                                    ; F8B422  [23] RAM record 23 + 0x20
	.long 0x00007d02                                    ; F8B426  [24] RAM record 24 + 0x20
	.long 0x00007d42                                    ; F8B42A  [25] RAM record 25 + 0x20
	.long 0x00007d82                                    ; F8B42E  [26] RAM record 26 + 0x20
	.long 0x00007dc2                                    ; F8B432  [27] RAM record 27 + 0x20
	.long 0x00007e02                                    ; F8B436  [28] RAM record 28 + 0x20
	.long 0x00007e42                                    ; F8B43A  [29] RAM record 29 + 0x20
	.long 0x00007e82                                    ; F8B43E  [30] RAM record 30 + 0x20
	.long 0x00007ec2                                    ; F8B442  [31] RAM record 31 + 0x20
; ---------------------------------------------------------------------
; PanelGroupEventLists_Variant1 -- 27 x LE32 list heads.
;
; ★★ THIS IS THE LAYER-2 TABLE: the map from a panel GROUP id to the
; UI EVENTS that group's wire raises.  It is a TABLE, not a
; computation, which is why a search for an `ld DE,0x00A9`-shaped
; event post found nothing anywhere in the four images -- the class
; byte 0xA9 is a DATA BYTE in the lists below, copied to the event.
;
; Read by: PanelGroupQueue_ExpandToEvents.  `ld XIX,0x00F8B446` at
;          0xF8A84C and `ld XIX,0x00F8B4B2` at 0xF8A857; `cp (0xC4),
;          0x01` at 0xF8A851 picks between them -- (0xC4) is the
;          MODEL STRAP, the same byte PanelWireGroupMap picks on.
;          The index is the group id, `sla WA,2` at 0xF8A846.
; ENTRY COUNT 27 is the ABUTMENT (0xF8B4B2 - 0xF8B446) / 4, NOT a bound
;          in the reader.  The reader's bound is LOWER: `cp A,0x18` /
;          `jr ugt` at 0xF8A83B rejects any group above 0x18, so
;          slots 0x19 and 0x1A CANNOT BE REACHED.  24 of the 27
;          reachable slots have a non-empty list.
; Evidence: the load at 0xF8A84C; the terminator test `cp (XHL),0xff`
;          at 0xF8A862; `ld WA,(XHL+)` / `ld (XIX+),WA` at
;          0xF8A867/0xF8A86A copy [class][code] into the event.
; ---------------------------------------------------------------------

PanelGroupEventLists_Variant1:
	.long PanelGroupEventListPool                       ; F8B446  [0x00] 6 records
	.long PanelGroupEventListPool+0x19                  ; F8B44A  [0x01] 1 record
	.long PanelGroupEventListPool+0x1E                  ; F8B44E  [0x02] 1 record
	.long PanelGroupEventListPool+0x23                  ; F8B452  [0x03] 8 records
	.long PanelGroupEventListPool+0x44                  ; F8B456  [0x04] 8 records
	.long PanelGroupEventListPool+0x65                  ; F8B45A  [0x05] 8 records
	.long PanelGroupEventListPool+0x86                  ; F8B45E  [0x06] 8 records
	.long PanelGroupEventListPool+0xA7                  ; F8B462  [0x07] 8 records
	.long PanelGroupEventListPool+0xC8                  ; F8B466  [0x08] 2 records
	.long PanelGroupEventListPool+0xD1                  ; F8B46A  [0x09] 8 records
	.long PanelGroupEventListPool+0xF2                  ; F8B46E  [0x0A] 8 records
	.long PanelGroupEventListPool+0x113                 ; F8B472  [0x0B] 1 record
	.long PanelGroupEventListPool+0x118                 ; F8B476  [0x0C] 1 record
	.long PanelGroupEventListPool+0x11D                 ; F8B47A  [0x0D] 1 record
	.long PanelGroupEventListPool+0x122                 ; F8B47E  [0x0E] 1 record
	.long PanelGroupEventListPool+0x127                 ; F8B482  [0x0F] 1 record
	.long PanelGroupEventListPool+0x12C                 ; F8B486  [0x10] 1 record
	.long PanelGroupEventListPool+0x131                 ; F8B48A  [0x11] 1 record
	.long PanelGroupEventListPool+0x136                 ; F8B48E  [0x12] 1 record
	.long PanelGroupEventListPool+0x13B                 ; F8B492  [0x13] 1 record
	.long PanelGroupEventListPool+0x140                 ; F8B496  [0x14] 1 record
	.long PanelGroupEventListPool+0x145                 ; F8B49A  [0x15] 1 record
	.long PanelGroupEventListPool+0x14A                 ; F8B49E  [0x16] 1 record
	.long PanelGroupEventListPool+0x14F                 ; F8B4A2  [0x17] 1 record
	.long PanelGroupEventListPool+0x154                 ; F8B4A6  [0x18] 0 records  (empty)
	.long PanelGroupEventListPool+0x22B                 ; F8B4AA  [0x19] 0 records  UNREACHABLE (group > 0x18)
	.long PanelGroupEventListPool+0x22B                 ; F8B4AE  [0x1A] 0 records  UNREACHABLE (group > 0x18)
; ---------------------------------------------------------------------
; PanelGroupEventLists_Variant2 -- 27 x LE32 list heads.
;
; ★★ THIS IS THE LAYER-2 TABLE: the map from a panel GROUP id to the
; UI EVENTS that group's wire raises.  It is a TABLE, not a
; computation, which is why a search for an `ld DE,0x00A9`-shaped
; event post found nothing anywhere in the four images -- the class
; byte 0xA9 is a DATA BYTE in the lists below, copied to the event.
;
; Read by: PanelGroupQueue_ExpandToEvents.  `ld XIX,0x00F8B446` at
;          0xF8A84C and `ld XIX,0x00F8B4B2` at 0xF8A857; `cp (0xC4),
;          0x01` at 0xF8A851 picks between them -- (0xC4) is the
;          MODEL STRAP, the same byte PanelWireGroupMap picks on.
;          The index is the group id, `sla WA,2` at 0xF8A846.
; ENTRY COUNT 27 is the ABUTMENT (0xF8B51E - 0xF8B4B2) / 4, NOT a bound
;          in the reader.  The reader's bound is LOWER: `cp A,0x18` /
;          `jr ugt` at 0xF8A83B rejects any group above 0x18, so
;          slots 0x19 and 0x1A CANNOT BE REACHED.  13 of the 27
;          reachable slots have a non-empty list.
; Evidence: the load at 0xF8A857; the terminator test `cp (XHL),0xff`
;          at 0xF8A862; `ld WA,(XHL+)` / `ld (XIX+),WA` at
;          0xF8A867/0xF8A86A copy [class][code] into the event.
; ---------------------------------------------------------------------

PanelGroupEventLists_Variant2:
	.long PanelGroupEventListPool+0x155                 ; F8B4B2  [0x00] 6 records
	.long PanelGroupEventListPool+0x16E                 ; F8B4B6  [0x01] 1 record
	.long PanelGroupEventListPool+0x173                 ; F8B4BA  [0x02] 4 records
	.long PanelGroupEventListPool+0x184                 ; F8B4BE  [0x03] 8 records
	.long PanelGroupEventListPool+0x1A5                 ; F8B4C2  [0x04] 8 records
	.long PanelGroupEventListPool+0x1C6                 ; F8B4C6  [0x05] 8 records
	.long PanelGroupEventListPool+0x1E7                 ; F8B4CA  [0x06] 4 records
	.long PanelGroupEventListPool+0x1F8                 ; F8B4CE  [0x07] 2 records
	.long PanelGroupEventListPool+0x201                 ; F8B4D2  [0x08] 5 records
	.long PanelGroupEventListPool+0x22A                 ; F8B4D6  [0x09] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B4DA  [0x0A] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B4DE  [0x0B] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B4E2  [0x0C] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B4E6  [0x0D] 0 records  (empty)
	.long PanelGroupEventListPool+0x216                 ; F8B4EA  [0x0E] 1 record
	.long PanelGroupEventListPool+0x21B                 ; F8B4EE  [0x0F] 1 record
	.long PanelGroupEventListPool+0x22A                 ; F8B4F2  [0x10] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B4F6  [0x11] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B4FA  [0x12] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B4FE  [0x13] 0 records  (empty)
	.long PanelGroupEventListPool+0x220                 ; F8B502  [0x14] 1 record
	.long PanelGroupEventListPool+0x225                 ; F8B506  [0x15] 1 record
	.long PanelGroupEventListPool+0x22A                 ; F8B50A  [0x16] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B50E  [0x17] 0 records  (empty)
	.long PanelGroupEventListPool+0x22A                 ; F8B512  [0x18] 0 records  (empty)
	.long PanelGroupEventListPool+0x22B                 ; F8B516  [0x19] 0 records  UNREACHABLE (group > 0x18)
	.long PanelGroupEventListPool+0x22B                 ; F8B51A  [0x1A] 0 records  UNREACHABLE (group > 0x18)
; ---------------------------------------------------------------------
; PanelGroupEventListPool -- 556 bytes, the lists both tables point into.
;
; A RECORD IS FOUR BYTES:
;   [0] event CLASS   copied to the event's +0
;   [1] event CODE    copied to the event's +1  (a BASE -- an action
;                     handler may rewrite it, see the action tables)
;   [2] SHIFT byte    bit 4 = direction, bits 0-2 = count (0xF8A8AA,
;                     `and A,0x07` at 0xF8A8AF and 0xF8A8B8)
;   [3] BIT MASK      which bits of this wire byte the record owns
; and a list ends on 0xFF in byte 0 -- a ONE-byte terminator, because
; `cp (XHL),0xff` at 0xF8A862 tests byte 0 only.
;
; ★ ONE CODE COVERS A PAIR OF MATRIX BITS.  Most button records carry a
; single-bit mask and a shift that lands that bit on position 0 or 1 of a
; two-bit field, so two records share a code and differ only in position;
; `bit 0,(0x20B9)` at 0xF866C7 and 0xF86708 sets bit 7 of the delivered
; code for position 0.  That is how 32 codes reach 58 switches.
;
; Evidence: the pool runs from the lowest list head (0xF8B51E) to the byte
;          before PanelGroupActionTable_Variant1 (0xF8B74A), and the 54
;          list walks tile it with no byte left over.
; ---------------------------------------------------------------------

PanelGroupEventListPool:
	; -- v1 g00
	.byte 0xa9, 0x20, 0x00, 0x01                               ; F8B51E  class A9 code 20 shift 00 mask 01
	.byte 0xa9, 0x20, 0x00, 0x02                               ; F8B522  class A9 code 20 shift 00 mask 02
	.byte 0xa9, 0x20, 0x00, 0x04                               ; F8B526  class A9 code 20 shift 00 mask 04
	.byte 0xa9, 0x20, 0x00, 0x08                               ; F8B52A  class A9 code 20 shift 00 mask 08
	.byte 0xa8, 0x07, 0x04, 0x70                               ; F8B52E  class A8 code 07 shift 04 mask 70
	.byte 0xa8, 0x07, 0x00, 0x80                               ; F8B532  class A8 code 07 shift 00 mask 80
	.byte 0xff                                                 ; F8B536  end of list
	; -- v1 g01
	.byte 0xa8, 0x08, 0x00, 0xff                               ; F8B537  class A8 code 08 shift 00 mask FF
	.byte 0xff                                                 ; F8B53B  end of list
	; -- v1 g02
	.byte 0xa8, 0x08, 0x00, 0xff                               ; F8B53C  class A8 code 08 shift 00 mask FF
	.byte 0xff                                                 ; F8B540  end of list
	; -- v1 g03
	.byte 0xa9, 0x04, 0x00, 0x01                               ; F8B541  class A9 code 04 shift 00 mask 01
	.byte 0xa9, 0x04, 0x00, 0x02                               ; F8B545  class A9 code 04 shift 00 mask 02
	.byte 0xa9, 0x05, 0x02, 0x04                               ; F8B549  class A9 code 05 shift 02 mask 04
	.byte 0xa9, 0x05, 0x02, 0x08                               ; F8B54D  class A9 code 05 shift 02 mask 08
	.byte 0xa9, 0x06, 0x04, 0x10                               ; F8B551  class A9 code 06 shift 04 mask 10
	.byte 0xa9, 0x06, 0x04, 0x20                               ; F8B555  class A9 code 06 shift 04 mask 20
	.byte 0xa9, 0x07, 0x06, 0x40                               ; F8B559  class A9 code 07 shift 06 mask 40
	.byte 0xa9, 0x07, 0x06, 0x80                               ; F8B55D  class A9 code 07 shift 06 mask 80
	.byte 0xff                                                 ; F8B561  end of list
	; -- v1 g04
	.byte 0xa9, 0x04, 0x00, 0x01                               ; F8B562  class A9 code 04 shift 00 mask 01
	.byte 0xa9, 0x04, 0x00, 0x02                               ; F8B566  class A9 code 04 shift 00 mask 02
	.byte 0xa9, 0x05, 0x02, 0x04                               ; F8B56A  class A9 code 05 shift 02 mask 04
	.byte 0xa9, 0x05, 0x02, 0x08                               ; F8B56E  class A9 code 05 shift 02 mask 08
	.byte 0xa9, 0x06, 0x04, 0x10                               ; F8B572  class A9 code 06 shift 04 mask 10
	.byte 0xa9, 0x06, 0x04, 0x20                               ; F8B576  class A9 code 06 shift 04 mask 20
	.byte 0xa9, 0x07, 0x06, 0x40                               ; F8B57A  class A9 code 07 shift 06 mask 40
	.byte 0xa9, 0x07, 0x06, 0x80                               ; F8B57E  class A9 code 07 shift 06 mask 80
	.byte 0xff                                                 ; F8B582  end of list
	; -- v1 g05
	.byte 0xa9, 0x00, 0x00, 0x01                               ; F8B583  class A9 code 00 shift 00 mask 01
	.byte 0xa9, 0x00, 0x00, 0x02                               ; F8B587  class A9 code 00 shift 00 mask 02
	.byte 0xa9, 0x01, 0x02, 0x04                               ; F8B58B  class A9 code 01 shift 02 mask 04
	.byte 0xa9, 0x01, 0x02, 0x08                               ; F8B58F  class A9 code 01 shift 02 mask 08
	.byte 0xa9, 0x02, 0x04, 0x10                               ; F8B593  class A9 code 02 shift 04 mask 10
	.byte 0xa9, 0x02, 0x04, 0x20                               ; F8B597  class A9 code 02 shift 04 mask 20
	.byte 0xa9, 0x03, 0x06, 0x40                               ; F8B59B  class A9 code 03 shift 06 mask 40
	.byte 0xa9, 0x03, 0x06, 0x80                               ; F8B59F  class A9 code 03 shift 06 mask 80
	.byte 0xff                                                 ; F8B5A3  end of list
	; -- v1 g06
	.byte 0xa9, 0x00, 0x00, 0x01                               ; F8B5A4  class A9 code 00 shift 00 mask 01
	.byte 0xa9, 0x00, 0x00, 0x02                               ; F8B5A8  class A9 code 00 shift 00 mask 02
	.byte 0xa9, 0x01, 0x02, 0x04                               ; F8B5AC  class A9 code 01 shift 02 mask 04
	.byte 0xa9, 0x01, 0x02, 0x08                               ; F8B5B0  class A9 code 01 shift 02 mask 08
	.byte 0xa9, 0x02, 0x04, 0x10                               ; F8B5B4  class A9 code 02 shift 04 mask 10
	.byte 0xa9, 0x02, 0x04, 0x20                               ; F8B5B8  class A9 code 02 shift 04 mask 20
	.byte 0xa9, 0x03, 0x06, 0x40                               ; F8B5BC  class A9 code 03 shift 06 mask 40
	.byte 0xa9, 0x03, 0x06, 0x80                               ; F8B5C0  class A9 code 03 shift 06 mask 80
	.byte 0xff                                                 ; F8B5C4  end of list
	; -- v1 g07
	.byte 0xa9, 0x20, 0x00, 0x01                               ; F8B5C5  class A9 code 20 shift 00 mask 01
	.byte 0xa9, 0x20, 0x00, 0x02                               ; F8B5C9  class A9 code 20 shift 00 mask 02
	.byte 0xa9, 0x20, 0x00, 0x04                               ; F8B5CD  class A9 code 20 shift 00 mask 04
	.byte 0xa9, 0x20, 0x00, 0x08                               ; F8B5D1  class A9 code 20 shift 00 mask 08
	.byte 0xa9, 0x20, 0x00, 0x10                               ; F8B5D5  class A9 code 20 shift 00 mask 10
	.byte 0xa9, 0x20, 0x00, 0x20                               ; F8B5D9  class A9 code 20 shift 00 mask 20
	.byte 0xa8, 0x11, 0x05, 0x40                               ; F8B5DD  class A8 code 11 shift 05 mask 40
	.byte 0xa8, 0x11, 0x07, 0x80                               ; F8B5E1  class A8 code 11 shift 07 mask 80
	.byte 0xff                                                 ; F8B5E5  end of list
	; -- v1 g08
	.byte 0xb8, 0x00, 0x00, 0x40                               ; F8B5E6  class B8 code 00 shift 00 mask 40
	.byte 0x20, 0x19, 0x00, 0x3f                               ; F8B5EA  class 20 code 19 shift 00 mask 3F
	.byte 0xff                                                 ; F8B5EE  end of list
	; -- v1 g09
	.byte 0xa9, 0x08, 0x00, 0x01                               ; F8B5EF  class A9 code 08 shift 00 mask 01
	.byte 0xa9, 0x09, 0x01, 0x02                               ; F8B5F3  class A9 code 09 shift 01 mask 02
	.byte 0xa9, 0x0a, 0x02, 0x04                               ; F8B5F7  class A9 code 0A shift 02 mask 04
	.byte 0xa9, 0x0b, 0x03, 0x08                               ; F8B5FB  class A9 code 0B shift 03 mask 08
	.byte 0xa9, 0x0c, 0x04, 0x10                               ; F8B5FF  class A9 code 0C shift 04 mask 10
	.byte 0xa9, 0x1e, 0x04, 0x20                               ; F8B603  class A9 code 1E shift 04 mask 20
	.byte 0xa9, 0x10, 0x06, 0x40                               ; F8B607  class A9 code 10 shift 06 mask 40
	.byte 0xa9, 0x10, 0x06, 0x80                               ; F8B60B  class A9 code 10 shift 06 mask 80
	.byte 0xff                                                 ; F8B60F  end of list
	; -- v1 g0A
	.byte 0xa9, 0x08, 0x11, 0x01                               ; F8B610  class A9 code 08 shift 11 mask 01
	.byte 0xa9, 0x09, 0x00, 0x02                               ; F8B614  class A9 code 09 shift 00 mask 02
	.byte 0xa9, 0x0a, 0x01, 0x04                               ; F8B618  class A9 code 0A shift 01 mask 04
	.byte 0xa9, 0x0b, 0x02, 0x08                               ; F8B61C  class A9 code 0B shift 02 mask 08
	.byte 0xa9, 0x0c, 0x03, 0x10                               ; F8B620  class A9 code 0C shift 03 mask 10
	.byte 0xa9, 0x0d, 0x05, 0x20                               ; F8B624  class A9 code 0D shift 05 mask 20
	.byte 0xa9, 0x0d, 0x05, 0x40                               ; F8B628  class A9 code 0D shift 05 mask 40
	.byte 0xa9, 0x0f, 0x06, 0x80                               ; F8B62C  class A9 code 0F shift 06 mask 80
	.byte 0xff                                                 ; F8B630  end of list
	; -- v1 g0B
	.byte 0xb2, 0x00, 0x00, 0x7f                               ; F8B631  class B2 code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B635  end of list
	; -- v1 g0C
	.byte 0xb1, 0x00, 0x00, 0xff                               ; F8B636  class B1 code 00 shift 00 mask FF
	.byte 0xff                                                 ; F8B63A  end of list
	; -- v1 g0D
	.byte 0xbc, 0x00, 0x00, 0x7f                               ; F8B63B  class BC code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B63F  end of list
	; -- v1 g0E
	.byte 0xb0, 0x00, 0x00, 0x7f                               ; F8B640  class B0 code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B644  end of list
	; -- v1 g0F
	.byte 0xa9, 0x21, 0x00, 0xff                               ; F8B645  class A9 code 21 shift 00 mask FF
	.byte 0xff                                                 ; F8B649  end of list
	; -- v1 g10
	.byte 0xba, 0x00, 0x00, 0x7f                               ; F8B64A  class BA code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B64E  end of list
	; -- v1 g11
	.byte 0xbb, 0x00, 0x00, 0x7f                               ; F8B64F  class BB code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B653  end of list
	; -- v1 g12
	.byte 0xb4, 0x00, 0x00, 0x7f                               ; F8B654  class B4 code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B658  end of list
	; -- v1 g13
	.byte 0xbd, 0x00, 0x00, 0x7f                               ; F8B659  class BD code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B65D  end of list
	; -- v1 g14
	.byte 0xb8, 0x00, 0x00, 0x7f                               ; F8B65E  class B8 code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B662  end of list
	; -- v1 g15
	.byte 0xb9, 0x00, 0x00, 0x7f                               ; F8B663  class B9 code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B667  end of list
	; -- v1 g16
	.byte 0xa9, 0x32, 0x00, 0x01                               ; F8B668  class A9 code 32 shift 00 mask 01
	.byte 0xff                                                 ; F8B66C  end of list
	; -- v1 g17
	.byte 0xa9, 0x33, 0x00, 0x01                               ; F8B66D  class A9 code 33 shift 00 mask 01
	.byte 0xff                                                 ; F8B671  end of list
	; -- v1 g18
	.byte 0xff                                                 ; F8B672  end of list
	; -- v2 g00
	.byte 0xa9, 0x20, 0x00, 0x01                               ; F8B673  class A9 code 20 shift 00 mask 01
	.byte 0xa9, 0x20, 0x00, 0x02                               ; F8B677  class A9 code 20 shift 00 mask 02
	.byte 0xa9, 0x20, 0x00, 0x04                               ; F8B67B  class A9 code 20 shift 00 mask 04
	.byte 0xa9, 0x20, 0x00, 0x08                               ; F8B67F  class A9 code 20 shift 00 mask 08
	.byte 0xa8, 0x07, 0x04, 0x70                               ; F8B683  class A8 code 07 shift 04 mask 70
	.byte 0xa8, 0x07, 0x00, 0x80                               ; F8B687  class A8 code 07 shift 00 mask 80
	.byte 0xff                                                 ; F8B68B  end of list
	; -- v2 g01
	.byte 0xa9, 0x1b, 0x00, 0xff                               ; F8B68C  class A9 code 1B shift 00 mask FF
	.byte 0xff                                                 ; F8B690  end of list
	; -- v2 g02
	.byte 0xa9, 0x1b, 0x00, 0x0f                               ; F8B691  class A9 code 1B shift 00 mask 0F
	.byte 0xa9, 0x10, 0x04, 0x10                               ; F8B695  class A9 code 10 shift 04 mask 10
	.byte 0xa9, 0x10, 0x04, 0x20                               ; F8B699  class A9 code 10 shift 04 mask 20
	.byte 0xa9, 0x1e, 0x05, 0x40                               ; F8B69D  class A9 code 1E shift 05 mask 40
	.byte 0xff                                                 ; F8B6A1  end of list
	; -- v2 g03
	.byte 0xa9, 0x08, 0x11, 0x01                               ; F8B6A2  class A9 code 08 shift 11 mask 01
	.byte 0xa9, 0x09, 0x00, 0x02                               ; F8B6A6  class A9 code 09 shift 00 mask 02
	.byte 0xa9, 0x0a, 0x01, 0x04                               ; F8B6AA  class A9 code 0A shift 01 mask 04
	.byte 0xa9, 0x0b, 0x02, 0x08                               ; F8B6AE  class A9 code 0B shift 02 mask 08
	.byte 0xa9, 0x0c, 0x03, 0x10                               ; F8B6B2  class A9 code 0C shift 03 mask 10
	.byte 0xa9, 0x0d, 0x05, 0x20                               ; F8B6B6  class A9 code 0D shift 05 mask 20
	.byte 0xa9, 0x0d, 0x05, 0x40                               ; F8B6BA  class A9 code 0D shift 05 mask 40
	.byte 0xa9, 0x0f, 0x06, 0x80                               ; F8B6BE  class A9 code 0F shift 06 mask 80
	.byte 0xff                                                 ; F8B6C2  end of list
	; -- v2 g04
	.byte 0xa9, 0x00, 0x00, 0x01                               ; F8B6C3  class A9 code 00 shift 00 mask 01
	.byte 0xa9, 0x00, 0x00, 0x02                               ; F8B6C7  class A9 code 00 shift 00 mask 02
	.byte 0xa9, 0x01, 0x02, 0x04                               ; F8B6CB  class A9 code 01 shift 02 mask 04
	.byte 0xa9, 0x01, 0x02, 0x08                               ; F8B6CF  class A9 code 01 shift 02 mask 08
	.byte 0xa9, 0x02, 0x04, 0x10                               ; F8B6D3  class A9 code 02 shift 04 mask 10
	.byte 0xa9, 0x02, 0x04, 0x20                               ; F8B6D7  class A9 code 02 shift 04 mask 20
	.byte 0xa9, 0x03, 0x06, 0x40                               ; F8B6DB  class A9 code 03 shift 06 mask 40
	.byte 0xa9, 0x03, 0x06, 0x80                               ; F8B6DF  class A9 code 03 shift 06 mask 80
	.byte 0xff                                                 ; F8B6E3  end of list
	; -- v2 g05
	.byte 0xa9, 0x04, 0x00, 0x01                               ; F8B6E4  class A9 code 04 shift 00 mask 01
	.byte 0xa9, 0x04, 0x00, 0x02                               ; F8B6E8  class A9 code 04 shift 00 mask 02
	.byte 0xa9, 0x05, 0x02, 0x04                               ; F8B6EC  class A9 code 05 shift 02 mask 04
	.byte 0xa9, 0x05, 0x02, 0x08                               ; F8B6F0  class A9 code 05 shift 02 mask 08
	.byte 0xa9, 0x06, 0x04, 0x10                               ; F8B6F4  class A9 code 06 shift 04 mask 10
	.byte 0xa9, 0x06, 0x04, 0x20                               ; F8B6F8  class A9 code 06 shift 04 mask 20
	.byte 0xa9, 0x07, 0x06, 0x40                               ; F8B6FC  class A9 code 07 shift 06 mask 40
	.byte 0xa9, 0x07, 0x06, 0x80                               ; F8B700  class A9 code 07 shift 06 mask 80
	.byte 0xff                                                 ; F8B704  end of list
	; -- v2 g06
	.byte 0xa9, 0x20, 0x00, 0x01                               ; F8B705  class A9 code 20 shift 00 mask 01
	.byte 0xa9, 0x20, 0x00, 0x02                               ; F8B709  class A9 code 20 shift 00 mask 02
	.byte 0xa9, 0x20, 0x00, 0x04                               ; F8B70D  class A9 code 20 shift 00 mask 04
	.byte 0xa9, 0x20, 0x00, 0x08                               ; F8B711  class A9 code 20 shift 00 mask 08
	.byte 0xff                                                 ; F8B715  end of list
	; -- v2 g07
	.byte 0xa8, 0x05, 0x12, 0x01                               ; F8B716  class A8 code 05 shift 12 mask 01
	.byte 0xb8, 0x00, 0x00, 0x02                               ; F8B71A  class B8 code 00 shift 00 mask 02
	.byte 0xff                                                 ; F8B71E  end of list
	; -- v2 g08
	.byte 0xa9, 0x08, 0x00, 0x01                               ; F8B71F  class A9 code 08 shift 00 mask 01
	.byte 0xa9, 0x09, 0x01, 0x02                               ; F8B723  class A9 code 09 shift 01 mask 02
	.byte 0xa9, 0x0a, 0x02, 0x04                               ; F8B727  class A9 code 0A shift 02 mask 04
	.byte 0xa9, 0x0b, 0x03, 0x08                               ; F8B72B  class A9 code 0B shift 03 mask 08
	.byte 0xa9, 0x0c, 0x04, 0x10                               ; F8B72F  class A9 code 0C shift 04 mask 10
	.byte 0xff                                                 ; F8B733  end of list
	; -- v2 g0E
	.byte 0xb0, 0x00, 0x00, 0x7f                               ; F8B734  class B0 code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B738  end of list
	; -- v2 g0F
	.byte 0xa9, 0x21, 0x00, 0xff                               ; F8B739  class A9 code 21 shift 00 mask FF
	.byte 0xff                                                 ; F8B73D  end of list
	; -- v2 g14
	.byte 0xb8, 0x00, 0x00, 0x7f                               ; F8B73E  class B8 code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B742  end of list
	; -- v2 g15
	.byte 0xb9, 0x00, 0x00, 0x7f                               ; F8B743  class B9 code 00 shift 00 mask 7F
	.byte 0xff                                                 ; F8B747  end of list
	; -- v2 g09, v2 g0A, v2 g0B, v2 g0C, v2 g0D, v2 g10, v2 g11, v2 g12, v2 g13, v2 g16, v2 g17, v2 g18
	.byte 0xff                                                 ; F8B748  end of list
	; -- v1 g19, v1 g1A, v2 g19, v2 g1A
	.byte 0xff                                                 ; F8B749  end of list
; ---------------------------------------------------------------------
; PanelGroupActionTable_Variant1 -- 25 x LE32 list heads.
;
; An ACTION list lets a handler intercept a (group, mask) pair AFTER
; the class/code pair has been written to the event but BEFORE the
; value pair is.  Two of the handlers REWRITE the code byte in place
; -- `add (XIX-1),0x11` at 0xF8AE7E/0xF8AEF1 and `ld (XIX-1),0x19` at
; 0xF8AE8A/0xF8AEFD -- and any handler may end at 0xF8A90F
; (`dec 2,XIX`), which DROPS the event.  So a code in the event pool
; is a BASE, and the delivered code can be base, base+0x11 or 0x19.
; ⚠ WHICH BRANCH IS TAKEN AT RUN TIME IS NOT ESTABLISHED.
;
; Read by: PanelEvent_ShiftThenRunAction.  `ld XIY,0x00F8B74A` at
;          0xF8A8CC and `ld XIY,0x00F8B7AE` at 0xF8A8D7, the same
;          (0xC4) strap test at 0xF8A8D1; the index is (0x2251), the
;          group the walker stored at 0xF8A840, `sla L,2` at 0xF8A8E0.
; ENTRY COUNT 25 is the abutment (0xF8B7AE - 0xF8B74A) / 4, and here it
;          AGREES with the reader: groups 0x00-0x18 inclusive is
;          exactly 25 slots.
; Evidence: the load at 0xF8A8CC; the record walk `ld BC,(XIY+HL)` /
;          `cp C,0xff` / `cp WA,BC` at 0xF8A8EA-0xF8A8F8 and the
;          handler fetch `ld XBC,(XIY+HL)` / `jp (XBC)` at
;          0xF8A902-0xF8A909.
; ---------------------------------------------------------------------

PanelGroupActionTable_Variant1:
	.long PanelGroupActionListPool                      ; F8B74A  [0x00] 6 records
	.long PanelGroupActionListPool+0x2A                 ; F8B74E  [0x01] 1 record
	.long PanelGroupActionListPool+0x36                 ; F8B752  [0x02] 1 record
	.long PanelGroupActionListPool+0x42                 ; F8B756  [0x03] 8 records
	.long PanelGroupActionListPool+0x78                 ; F8B75A  [0x04] 8 records
	.long PanelGroupActionListPool+0xAE                 ; F8B75E  [0x05] 8 records
	.long PanelGroupActionListPool+0xE4                 ; F8B762  [0x06] 8 records
	.long PanelGroupActionListPool+0x11A                ; F8B766  [0x07] 6 records
	.long PanelGroupActionListPool+0x144                ; F8B76A  [0x08] 2 records
	.long PanelGroupActionListPool+0x156                ; F8B76E  [0x09] 7 records
	.long PanelGroupActionListPool+0x186                ; F8B772  [0x0A] 8 records
	.long PanelGroupActionListPool+0x1BC                ; F8B776  [0x0B] 1 record
	.long PanelGroupActionListPool+0x1C8                ; F8B77A  [0x0C] 1 record
	.long PanelGroupActionListPool+0x1D4                ; F8B77E  [0x0D] 1 record
	.long PanelGroupActionListPool+0x1E0                ; F8B782  [0x0E] 0 records  (empty)
	.long PanelGroupActionListPool+0x1E6                ; F8B786  [0x0F] 0 records  (empty)
	.long PanelGroupActionListPool+0x1EC                ; F8B78A  [0x10] 1 record
	.long PanelGroupActionListPool+0x1F8                ; F8B78E  [0x11] 1 record
	.long PanelGroupActionListPool+0x204                ; F8B792  [0x12] 0 records  (empty)
	.long PanelGroupActionListPool+0x20A                ; F8B796  [0x13] 1 record
	.long PanelGroupActionListPool+0x216                ; F8B79A  [0x14] 1 record
	.long PanelGroupActionListPool+0x222                ; F8B79E  [0x15] 1 record
	.long PanelGroupActionListPool+0x22E                ; F8B7A2  [0x16] 1 record
	.long PanelGroupActionListPool+0x23A                ; F8B7A6  [0x17] 1 record
	.long PanelGroupActionListPool+0x246                ; F8B7AA  [0x18] 0 records  (empty)
; ---------------------------------------------------------------------
; PanelGroupActionTable_Variant2 -- 25 x LE32 list heads.
;
; An ACTION list lets a handler intercept a (group, mask) pair AFTER
; the class/code pair has been written to the event but BEFORE the
; value pair is.  Two of the handlers REWRITE the code byte in place
; -- `add (XIX-1),0x11` at 0xF8AE7E/0xF8AEF1 and `ld (XIX-1),0x19` at
; 0xF8AE8A/0xF8AEFD -- and any handler may end at 0xF8A90F
; (`dec 2,XIX`), which DROPS the event.  So a code in the event pool
; is a BASE, and the delivered code can be base, base+0x11 or 0x19.
; ⚠ WHICH BRANCH IS TAKEN AT RUN TIME IS NOT ESTABLISHED.
;
; Read by: PanelEvent_ShiftThenRunAction.  `ld XIY,0x00F8B74A` at
;          0xF8A8CC and `ld XIY,0x00F8B7AE` at 0xF8A8D7, the same
;          (0xC4) strap test at 0xF8A8D1; the index is (0x2251), the
;          group the walker stored at 0xF8A840, `sla L,2` at 0xF8A8E0.
; ENTRY COUNT 25 is the abutment (0xF8B812 - 0xF8B7AE) / 4, and here it
;          AGREES with the reader: groups 0x00-0x18 inclusive is
;          exactly 25 slots.
; Evidence: the load at 0xF8A8D7; the record walk `ld BC,(XIY+HL)` /
;          `cp C,0xff` / `cp WA,BC` at 0xF8A8EA-0xF8A8F8 and the
;          handler fetch `ld XBC,(XIY+HL)` / `jp (XBC)` at
;          0xF8A902-0xF8A909.
; ---------------------------------------------------------------------

PanelGroupActionTable_Variant2:
	.long PanelGroupActionListPool+0x24C                ; F8B7AE  [0x00] 6 records
	.long PanelGroupActionListPool+0x276                ; F8B7B2  [0x01] 1 record
	.long PanelGroupActionListPool+0x282                ; F8B7B6  [0x02] 3 records
	.long PanelGroupActionListPool+0x29A                ; F8B7BA  [0x03] 7 records
	.long PanelGroupActionListPool+0x2CA                ; F8B7BE  [0x04] 8 records
	.long PanelGroupActionListPool+0x300                ; F8B7C2  [0x05] 8 records
	.long PanelGroupActionListPool+0x336                ; F8B7C6  [0x06] 4 records
	.long PanelGroupActionListPool+0x354                ; F8B7CA  [0x07] 1 record
	.long PanelGroupActionListPool+0x360                ; F8B7CE  [0x08] 5 records
	.long PanelGroupActionListPool+0x39C                ; F8B7D2  [0x09] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7D6  [0x0A] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7DA  [0x0B] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7DE  [0x0C] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7E2  [0x0D] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7E6  [0x0E] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7EA  [0x0F] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7EE  [0x10] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7F2  [0x11] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7F6  [0x12] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B7FA  [0x13] 0 records  (empty)
	.long PanelGroupActionListPool+0x384                ; F8B7FE  [0x14] 1 record
	.long PanelGroupActionListPool+0x390                ; F8B802  [0x15] 1 record
	.long PanelGroupActionListPool+0x39C                ; F8B806  [0x16] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B80A  [0x17] 0 records  (empty)
	.long PanelGroupActionListPool+0x39C                ; F8B80E  [0x18] 0 records  (empty)
; ---------------------------------------------------------------------
; PanelGroupActionListPool -- 930 bytes, the lists both action tables
; point into.
;
; A RECORD IS SIX BYTES: [group][mask][LE32 handler], and a list ends on
; a record whose group byte is 0xFF.  The terminator is a WHOLE SIX-BYTE
; record, not one byte, because the walk steps by 6 (`inc 4,HL` after an
; `inc 2,HL` at 0xF8A8EF/0xF8A8FA) -- which is also why several empty
; lists share the single terminator at the end of the pool.
; The key compared is the 16-bit (mask:group) pair: `cp WA,BC` at
; 0xF8A8F6 with BC loaded from the record and WA holding (mask, group).
;
; ★ 2026-09-25 (lane proma): the LE32 handler of every record is written
;          `.long <label>` (a `.byte group, mask` line, then the pointer), so
;          the byte gate checks each target; the 15 distinct handlers carry
;          labels (notes/proma-2026-09-25/gen_panel_actions.py, check A3).
; Evidence: the pool runs from the lowest list head (0xF8B812) to the last
;          byte of the block (0xF8BBB3), and the 50 list walks tile it
;          with no byte left over.
; ---------------------------------------------------------------------

PanelGroupActionListPool:
	; -- v1 g00
	.byte 0x00, 0x01                                           ; F8B812  group 00 mask 01 -> 0xF8AB42
	.long PanelAction_OrdinalToEventValue_B                  ; F8B814
	.byte 0x00, 0x02                                           ; F8B818  group 00 mask 02 -> 0xF8AB42
	.long PanelAction_OrdinalToEventValue_B                  ; F8B81A
	.byte 0x00, 0x04                                           ; F8B81E  group 00 mask 04 -> 0xF8AB42
	.long PanelAction_OrdinalToEventValue_B                  ; F8B820
	.byte 0x00, 0x08                                           ; F8B824  group 00 mask 08 -> 0xF8AB42
	.long PanelAction_OrdinalToEventValue_B                  ; F8B826
	.byte 0x00, 0x70                                           ; F8B82A  group 00 mask 70 -> 0xF8ABFD
	.long PanelAction_BankButton                                         ; F8B82C
	.byte 0x00, 0x80                                           ; F8B830  group 00 mask 80 -> 0xF8AB70
	.long PanelAction_BankRemap                                         ; F8B832
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B836  end of list
	; -- v1 g01
	.byte 0x01, 0xff                                           ; F8B83C  group 01 mask FF -> 0xF8ACE8
	.long PanelAction_SoundSelectOrKeypad_V1                 ; F8B83E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B842  end of list
	; -- v1 g02
	.byte 0x02, 0xff                                           ; F8B848  group 02 mask FF -> 0xF8ACE8
	.long PanelAction_SoundSelectOrKeypad_V1                 ; F8B84A
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B84E  end of list
	; -- v1 g03
	.byte 0x03, 0x01                                           ; F8B854  group 03 mask 01 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B856
	.byte 0x03, 0x02                                           ; F8B85A  group 03 mask 02 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B85C
	.byte 0x03, 0x04                                           ; F8B860  group 03 mask 04 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B862
	.byte 0x03, 0x08                                           ; F8B866  group 03 mask 08 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B868
	.byte 0x03, 0x10                                           ; F8B86C  group 03 mask 10 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B86E
	.byte 0x03, 0x20                                           ; F8B872  group 03 mask 20 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B874
	.byte 0x03, 0x40                                           ; F8B878  group 03 mask 40 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B87A
	.byte 0x03, 0x80                                           ; F8B87E  group 03 mask 80 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B880
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B884  end of list
	; -- v1 g04
	.byte 0x04, 0x01                                           ; F8B88A  group 04 mask 01 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B88C
	.byte 0x04, 0x02                                           ; F8B890  group 04 mask 02 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B892
	.byte 0x04, 0x04                                           ; F8B896  group 04 mask 04 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B898
	.byte 0x04, 0x08                                           ; F8B89C  group 04 mask 08 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B89E
	.byte 0x04, 0x10                                           ; F8B8A2  group 04 mask 10 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B8A4
	.byte 0x04, 0x20                                           ; F8B8A8  group 04 mask 20 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B8AA
	.byte 0x04, 0x40                                           ; F8B8AE  group 04 mask 40 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B8B0
	.byte 0x04, 0x80                                           ; F8B8B4  group 04 mask 80 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B8B6
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B8BA  end of list
	; -- v1 g05
	.byte 0x05, 0x01                                           ; F8B8C0  group 05 mask 01 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B8C2
	.byte 0x05, 0x02                                           ; F8B8C6  group 05 mask 02 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B8C8
	.byte 0x05, 0x04                                           ; F8B8CC  group 05 mask 04 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B8CE
	.byte 0x05, 0x08                                           ; F8B8D2  group 05 mask 08 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B8D4
	.byte 0x05, 0x10                                           ; F8B8D8  group 05 mask 10 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B8DA
	.byte 0x05, 0x20                                           ; F8B8DE  group 05 mask 20 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B8E0
	.byte 0x05, 0x40                                           ; F8B8E4  group 05 mask 40 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B8E6
	.byte 0x05, 0x80                                           ; F8B8EA  group 05 mask 80 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B8EC
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B8F0  end of list
	; -- v1 g06
	.byte 0x06, 0x01                                           ; F8B8F6  group 06 mask 01 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B8F8
	.byte 0x06, 0x02                                           ; F8B8FC  group 06 mask 02 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B8FE
	.byte 0x06, 0x04                                           ; F8B902  group 06 mask 04 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B904
	.byte 0x06, 0x08                                           ; F8B908  group 06 mask 08 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B90A
	.byte 0x06, 0x10                                           ; F8B90E  group 06 mask 10 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B910
	.byte 0x06, 0x20                                           ; F8B914  group 06 mask 20 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B916
	.byte 0x06, 0x40                                           ; F8B91A  group 06 mask 40 -> 0xF8AE68
	.long PanelAction_PairPos0_HeldMaskAltCode                                         ; F8B91C
	.byte 0x06, 0x80                                           ; F8B920  group 06 mask 80 -> 0xF8AEDB
	.long PanelAction_PairPos1_HeldMaskAltCode                                         ; F8B922
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B926  end of list
	; -- v1 g07
	.byte 0x07, 0x01                                           ; F8B92C  group 07 mask 01 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8B92E
	.byte 0x07, 0x02                                           ; F8B932  group 07 mask 02 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8B934
	.byte 0x07, 0x04                                           ; F8B938  group 07 mask 04 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8B93A
	.byte 0x07, 0x08                                           ; F8B93E  group 07 mask 08 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8B940
	.byte 0x07, 0x10                                           ; F8B944  group 07 mask 10 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8B946
	.byte 0x07, 0x20                                           ; F8B94A  group 07 mask 20 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8B94C
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B950  end of list
	; -- v1 g08
	.byte 0x08, 0x40                                           ; F8B956  group 08 mask 40 -> 0xF8AA57
	.long PanelAction_ResetAssignableCtrls                                         ; F8B958
	.byte 0x08, 0x3f                                           ; F8B95C  group 08 mask 3F -> 0xF8AA24
	.long PanelAction_LowestBitOneHot                                         ; F8B95E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B962  end of list
	; -- v1 g09
	.byte 0x09, 0x01                                           ; F8B968  group 09 mask 01 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8B96A
	.byte 0x09, 0x02                                           ; F8B96E  group 09 mask 02 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8B970
	.byte 0x09, 0x04                                           ; F8B974  group 09 mask 04 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8B976
	.byte 0x09, 0x08                                           ; F8B97A  group 09 mask 08 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8B97C
	.byte 0x09, 0x10                                           ; F8B980  group 09 mask 10 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8B982
	.byte 0x09, 0x40                                           ; F8B986  group 09 mask 40 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8B988
	.byte 0x09, 0x80                                           ; F8B98C  group 09 mask 80 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8B98E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B992  end of list
	; -- v1 g0A
	.byte 0x0a, 0x01                                           ; F8B998  group 0A mask 01 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8B99A
	.byte 0x0a, 0x02                                           ; F8B99E  group 0A mask 02 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8B9A0
	.byte 0x0a, 0x04                                           ; F8B9A4  group 0A mask 04 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8B9A6
	.byte 0x0a, 0x08                                           ; F8B9AA  group 0A mask 08 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8B9AC
	.byte 0x0a, 0x10                                           ; F8B9B0  group 0A mask 10 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8B9B2
	.byte 0x0a, 0x20                                           ; F8B9B6  group 0A mask 20 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8B9B8
	.byte 0x0a, 0x40                                           ; F8B9BC  group 0A mask 40 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8B9BE
	.byte 0x0a, 0x80                                           ; F8B9C2  group 0A mask 80 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8B9C4
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B9C8  end of list
	; -- v1 g0B
	.byte 0x0b, 0x7f                                           ; F8B9CE  group 0B mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8B9D0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B9D4  end of list
	; -- v1 g0C
	.byte 0x0c, 0xff                                           ; F8B9DA  group 0C mask FF -> 0xF8AFB4
	.long PanelAction_PitchBendToMsbLsb                                         ; F8B9DC
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B9E0  end of list
	; -- v1 g0D
	.byte 0x0d, 0x7f                                           ; F8B9E6  group 0D mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8B9E8
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B9EC  end of list
	; -- v1 g0E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B9F2  end of list
	; -- v1 g0F
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8B9F8  end of list
	; -- v1 g10
	.byte 0x10, 0x7f                                           ; F8B9FE  group 10 mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8BA00
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA04  end of list
	; -- v1 g11
	.byte 0x11, 0x7f                                           ; F8BA0A  group 11 mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8BA0C
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA10  end of list
	; -- v1 g12
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA16  end of list
	; -- v1 g13
	.byte 0x13, 0x7f                                           ; F8BA1C  group 13 mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8BA1E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA22  end of list
	; -- v1 g14
	.byte 0x14, 0x7f                                           ; F8BA28  group 14 mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8BA2A
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA2E  end of list
	; -- v1 g15
	.byte 0x15, 0x7f                                           ; F8BA34  group 15 mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8BA36
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA3A  end of list
	; -- v1 g16
	.byte 0x16, 0x01                                           ; F8BA40  group 16 mask 01 -> 0xF8B08B
	.long PanelAction_AssignableSwitch                       ; F8BA42
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA46  end of list
	; -- v1 g17
	.byte 0x17, 0x01                                           ; F8BA4C  group 17 mask 01 -> 0xF8B08B
	.long PanelAction_AssignableSwitch                       ; F8BA4E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA52  end of list
	; -- v1 g18
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA58  end of list
	; -- v2 g00
	.byte 0x00, 0x01                                           ; F8BA5E  group 00 mask 01 -> 0xF8AB42
	.long PanelAction_OrdinalToEventValue_B                  ; F8BA60
	.byte 0x00, 0x02                                           ; F8BA64  group 00 mask 02 -> 0xF8AB42
	.long PanelAction_OrdinalToEventValue_B                  ; F8BA66
	.byte 0x00, 0x04                                           ; F8BA6A  group 00 mask 04 -> 0xF8AB42
	.long PanelAction_OrdinalToEventValue_B                  ; F8BA6C
	.byte 0x00, 0x08                                           ; F8BA70  group 00 mask 08 -> 0xF8AB42
	.long PanelAction_OrdinalToEventValue_B                  ; F8BA72
	.byte 0x00, 0x70                                           ; F8BA76  group 00 mask 70 -> 0xF8ABFD
	.long PanelAction_BankButton                                         ; F8BA78
	.byte 0x00, 0x80                                           ; F8BA7C  group 00 mask 80 -> 0xF8AB70
	.long PanelAction_BankRemap                                         ; F8BA7E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA82  end of list
	; -- v2 g01
	.byte 0x01, 0xff                                           ; F8BA88  group 01 mask FF -> 0xF8ADDE
	.long PanelAction_Keypad_V2                              ; F8BA8A
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BA8E  end of list
	; -- v2 g02
	.byte 0x02, 0x0f                                           ; F8BA94  group 02 mask 0F -> 0xF8ADDE
	.long PanelAction_Keypad_V2                              ; F8BA96
	.byte 0x02, 0x10                                           ; F8BA9A  group 02 mask 10 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BA9C
	.byte 0x02, 0x20                                           ; F8BAA0  group 02 mask 20 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAA2
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BAA6  end of list
	; -- v2 g03
	.byte 0x03, 0x01                                           ; F8BAAC  group 03 mask 01 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAAE
	.byte 0x03, 0x02                                           ; F8BAB2  group 03 mask 02 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAB4
	.byte 0x03, 0x04                                           ; F8BAB8  group 03 mask 04 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BABA
	.byte 0x03, 0x08                                           ; F8BABE  group 03 mask 08 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAC0
	.byte 0x03, 0x10                                           ; F8BAC4  group 03 mask 10 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAC6
	.byte 0x03, 0x20                                           ; F8BACA  group 03 mask 20 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BACC
	.byte 0x03, 0x40                                           ; F8BAD0  group 03 mask 40 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAD2
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BAD6  end of list
	; -- v2 g04
	.byte 0x04, 0x01                                           ; F8BADC  group 04 mask 01 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BADE
	.byte 0x04, 0x02                                           ; F8BAE2  group 04 mask 02 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAE4
	.byte 0x04, 0x04                                           ; F8BAE8  group 04 mask 04 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BAEA
	.byte 0x04, 0x08                                           ; F8BAEE  group 04 mask 08 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAF0
	.byte 0x04, 0x10                                           ; F8BAF4  group 04 mask 10 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BAF6
	.byte 0x04, 0x20                                           ; F8BAFA  group 04 mask 20 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BAFC
	.byte 0x04, 0x40                                           ; F8BB00  group 04 mask 40 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB02
	.byte 0x04, 0x80                                           ; F8BB06  group 04 mask 80 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BB08
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BB0C  end of list
	; -- v2 g05
	.byte 0x05, 0x01                                           ; F8BB12  group 05 mask 01 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB14
	.byte 0x05, 0x02                                           ; F8BB18  group 05 mask 02 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BB1A
	.byte 0x05, 0x04                                           ; F8BB1E  group 05 mask 04 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB20
	.byte 0x05, 0x08                                           ; F8BB24  group 05 mask 08 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BB26
	.byte 0x05, 0x10                                           ; F8BB2A  group 05 mask 10 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB2C
	.byte 0x05, 0x20                                           ; F8BB30  group 05 mask 20 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BB32
	.byte 0x05, 0x40                                           ; F8BB36  group 05 mask 40 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB38
	.byte 0x05, 0x80                                           ; F8BB3C  group 05 mask 80 -> 0xF8AF81
	.long PanelAction_PairPos1_HeldMask                                         ; F8BB3E
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BB42  end of list
	; -- v2 g06
	.byte 0x06, 0x01                                           ; F8BB48  group 06 mask 01 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8BB4A
	.byte 0x06, 0x02                                           ; F8BB4E  group 06 mask 02 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8BB50
	.byte 0x06, 0x04                                           ; F8BB54  group 06 mask 04 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8BB56
	.byte 0x06, 0x08                                           ; F8BB5A  group 06 mask 08 -> 0xF8AB08
	.long PanelAction_OrdinalToEventValue_A                  ; F8BB5C
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BB60  end of list
	; -- v2 g07
	.byte 0x07, 0x02                                           ; F8BB66  group 07 mask 02 -> 0xF8AA57
	.long PanelAction_ResetAssignableCtrls                                         ; F8BB68
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BB6C  end of list
	; -- v2 g08
	.byte 0x08, 0x01                                           ; F8BB72  group 08 mask 01 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB74
	.byte 0x08, 0x02                                           ; F8BB78  group 08 mask 02 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB7A
	.byte 0x08, 0x04                                           ; F8BB7E  group 08 mask 04 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB80
	.byte 0x08, 0x08                                           ; F8BB84  group 08 mask 08 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB86
	.byte 0x08, 0x10                                           ; F8BB8A  group 08 mask 10 -> 0xF8AF4E
	.long PanelAction_PairPos0_HeldMask                                         ; F8BB8C
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BB90  end of list
	; -- v2 g14
	.byte 0x14, 0x7f                                           ; F8BB96  group 14 mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8BB98
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BB9C  end of list
	; -- v2 g15
	.byte 0x15, 0x7f                                           ; F8BBA2  group 15 mask 7F -> 0xF8AFD0
	.long PanelAction_AssignableController                   ; F8BBA4
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BBA8  end of list
	; -- v2 g09, v2 g0A, v2 g0B, v2 g0C, v2 g0D, v2 g0E, v2 g0F, v2 g10, v2 g11, v2 g12, v2 g13, v2 g16, v2 g17, v2 g18
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff                   ; F8BBAE  end of list

; 0xF8BBB4-0xF8BBFF -- 76 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 76, 1, 0x0E
