; ==== 0xFAD800-0xFB2000 -- emitted by notes/gen_prom_a_fad800_module.py ====
; Layout from notes/prom_a_fad800_layout.py (--selftest: 64 checks).
; This text was assembled and byte-compared with the ROM before printing.
T_F40860_Nop:
	ret
	calr Dev7F_WriteAllFourSlots
	ret
T_F4085C_Nop:
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamApply_MaskedWriteAndPublish -- apply {C,B,E,D} to the parameter
;                           record and publish the change
;
; Called from: prom_b directory slot T_ParamApply_MaskedWriteAndPublish.  ⚠ This address had NO
;          LABEL before this pass; the emitter that converted the span
;          labels only what its own descent reaches, and a `jp` in prom_b
;          is invisible to it.
; Inputs:  C, B, E, D, passed straight through in registers.
; Body:    `ld (0x60f01e),0xff`, then T_ParamRecord_WriteFieldAndStage_Copy (T_F407D8)
;          (ParamRecord_WriteFieldAndStage_Copy) and T_Queue2C00_PublishStagedIfPending (T_F407B4)
;          (Queue2C00_PublishStagedIfPending).
; Evidence: the three instructions at 0xFAD80A, 0xFAD810 and 0xFAD814.
; Unknown:  what (0x60F01E) means.  Every entry point of this module
;          except the four ParamShadow_ ones writes 0xFF to it first, and
;          0xFAA86D seeds it with 0x7F at start-up; nothing here says what
;          reads it.
; ---------------------------------------------------------------------
ParamApply_MaskedWriteAndPublish:
	ld (0x60f01e:24), 0xff
	call T_ParamRecord_WriteFieldAndStage_Copy
	call T_Queue2C00_PublishStagedIfPending
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamShadow_SetField3 -- remember a value for field 3 of parameter C,
;                           to be published later by ParamShadow_FlushAll
;
; Called from: prom_b directory slot T_ParamShadow_SetField3.
; Body:    when BC == 0x00B0 (C = 0xB0, B = 0), write E to (0x24F1) and
;          go out immediately through T_ParamB0_PublishField0IfPending; otherwise, when C <= 0x1F,
;          store E with bit 7 forced into the 32-byte array at 0x60F610,
;          indexed by C, and return.
; Evidence: `cp BC,0x00b0` at 0xFAD81D, `cp C,0x1f` at 0xFAD823,
;          `set 0x07,E` at 0xFAD828, `ld XIX,0x0060f610` at 0xFAD82B.
; ★ WHY "field 3": ParamShadow_FlushAll's arm for this array emits the
;          record with `ld C,L` at 0xFADB14 and `ld B,0x03` at 0xFADB16,
;          so the deferred write is byte 3 of the record
;          of the parameter whose number is the array index.  Bit 7 is the
;          pending flag: the flush tests it and clears it.
; Unknown:  what field 3 of a part record holds.
; ---------------------------------------------------------------------
ParamShadow_SetField3:
	cp BC,0x00b0
	jr z, .LFAD837
	cp C,0x1f
	jr ugt, .LFAD845
	set 0x07,E
	ld XIX,SeqEvt_VolumeShadow
	ld	(xix+c), e
	jr .LFAD845
.LFAD837:
	ld (0x60f01e:24), 0xff
	ld (0x24f1:16), e
	call T_ParamB0_PublishField0IfPending
.LFAD845:
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamShadow_SetExpression -- remember an EXPRESSION value (parameter
;                           number 0xB3) for index B, to be published
;                           later by ParamShadow_FlushAll
;
; Called from: prom_b directory slot T_ParamShadow_SetExpression.
; Body:    when C == 0xB0, store E with bit 7 forced into the single byte
;          at 0x60F650; otherwise, when B <= 0x1F, into the 32-byte array
;          at 0x60F590 indexed by B.  Bit 7 is the pending flag.
; Evidence: `cp C,0xb0` at 0xFAD84A, `ld (0x60f650),E` at 0xFAD852,
;          `cp B,0x1f` at 0xFAD859, `ld XIX,0x0060f590` at 0xFAD861.
; ★ WHY 0xB3: ParamShadow_FlushAll walks 0x60F590 with W = 0xB3 (`ld
;          W,0xb3` at 0xFADA2B) and emits {W, index, value, 0x7F}.
; ★ WHY "EXPRESSION", with three witnesses:
;          1. MidiOut_ParamNumberTable[0xB3] is MidiOut_CC0B_Expression;
;          2. the change record at 0xFA81A2 carries parameter number
;             0x00B3 in bytes [8:10] and the SAME routine in [4:8];
;          3. prom_a's own controller list spells controller #11 --
;             which is CC 0x0B -- `EXPRESSION (#11)` at 0xFA2C03.
;          Check R2 re-derives 1 and 2 for all eleven records; check W1
;          re-reads 3 from the ROM.
; Note:    the C == 0xB0 arm defers parameter number 0xB0 instead, whose
;          MidiOut_ParamNumberTable entry is a bare `ret` (0xFA767D), so
;          nothing echoes it and nothing here names it.
; ---------------------------------------------------------------------
ParamShadow_SetExpression:
	cp C,0xb0
	jr nz, .LFAD859
	set 0x07,E
	ld (0x60f650:24), e
	jr .LFAD86B
.LFAD859:
	cp B,0x1f
	jr ugt, .LFAD86B
	set 0x07,E
	ld XIX,SeqEvt_ExpressionShadow
	ld	(xix+b), e
.LFAD86B:
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamShadow_SetPitchBend -- remember a PITCH BEND value AND its mask
;                           (parameter number 0xB1) for index B
;
; Called from: prom_b directory slot T_ParamShadow_SetPitchBend.
; Body:    when B <= 0x1F, store the 16-bit DE -- with bit 7 of E forced --
;          at 0x60F5D0 + 2*B.  This is the ONLY 16-bit shadow of the four,
;          and on the flush the high byte becomes the record's mask.
; Evidence: `cp B,0x1f` at 0xFAD870, `set 0x07,E` at 0xFAD875,
;          `ld XIX,0x0060f5d0` at 0xFAD878, `sll 0x01,B` at 0xFAD87D,
;          `ld (XIX+B),DE` at 0xFAD880; ParamShadow_FlushAll reads the pair
;          back with `ld WA,(XIY+HL)` at 0xFADAC3 and emits
;          {0xB1, index, A, W}.
; ★ WHY "PITCH BEND".  Round 4 called this the weakest of the three
;          because its handler had no name to borrow.  It has one now,
;          and round 4's three arguments stand unchanged below:
;          1. MidiOut_ParamNumberTable[0xB1] is MidiOut_PitchBend, and the code
;             that routine reaches builds its MIDI status byte with
;             `and A,0x0f` at 0xFA7703 and `or A,0xe0` at 0xFA7706 and sets a
;             three-byte length with `ld DE,0x0300` at 0xFA76F5.  0xEn is
;             the pitch-bend status in MIDI 1.0 -- ⚠ that last step is a
;             fact about the PROTOCOL, not about this ROM;
;          2. the change record at 0xFA8196 carries parameter number
;             0x00B1 with value bytes 0x4000, and 0x4000 is the pitch-bend
;             centre;
;          3. pitch bend is the only 14-bit channel message, and this is
;             the only one of the four shadows that stores 16 bits.
;          The `or A,0xe0` has two siblings and no others: `or A,0xc0` at
;          0xFA7612 and `or A,0xd0` at 0xFA7882 -- program change and
;          channel pressure -- so the idiom is the status-byte builder and
;          not a coincidence (check V1).
; ★ CLOSED, round 12.  This Unknown line read "sub_FA767E itself is still
;          unnamed; naming it would retire MidiOut_ChangeRecord_09's
;          positional suffix as well".  Both happened: 0xFA767E is
;          MidiOut_PitchBend and the record is MidiOut_ChangeRecord_PitchBend.
;          ★ The two derivations are INDEPENDENT and they agree -- round 4
;          argued pitch bend from the parameter shadow's width and the 0x4000
;          reset value, round 12 from the status byte, the message length, the
;          inbound caller and the change record.  Neither was written from the
;          other; notes/prom_a_panel_names_round11.py --midi prints round 12's.
; ---------------------------------------------------------------------
ParamShadow_SetPitchBend:
	cp B,0x1f
	jr ugt, .LFAD86B
	set 0x07,E
	ld XIX,SeqEvt_PitchBendShadow
	sll b, 0x01
	ld	(xix+b), de
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamShadow_SetModulation1 -- remember a MODULATION 1 value (parameter
;                           number 0xB2) for index B
;
; Called from: prom_b directory slot T_ParamShadow_SetModulation1.
; Body:    when B <= 0x1F, store E with bit 7 forced into the 32-byte
;          array at 0x60F5B0 indexed by B.
; Evidence: `cp B,0x1f` at 0xFAD88A, `ld XIX,0x0060f5b0` at 0xFAD892.
;          ParamShadow_FlushAll walks the same array with W = 0xB2
;          (`ld W,0xb2` at 0xFADA38) through the same shared loop it uses
;          for 0x60F590, which is what pins the parameter number.
; ★ WHY "MODULATION 1", with three witnesses:
;          1. MidiOut_ParamNumberTable[0xB2] is MidiOut_CC01_Modulation;
;          2. the change record at 0xFA812A carries parameter number
;             0x00B2 and the same routine in [4:8];
;          3. prom_a's controller list spells controller #1 -- CC 0x01 --
;             `MODULATION1(# 1)` at 0xFA2BD3, and #2 `MODULATION2(# 2)`,
;             which is why the name carries the 1.
; ---------------------------------------------------------------------
ParamShadow_SetModulation1:
	cp B,0x1f
	jr ugt, .LFAD86B
	set 0x07,E
	ld XIX,SeqEvt_ModulationShadow
	ld	(xix+b), e
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamApply_WriteStagedAndPublish -- take {C,B,E,D} from the 0x1950
;                           staging cells, apply it and publish it
;
; Called from: prom_b directory slot T_ParamApply_WriteStagedAndPublish.
; Body:    `ld (0x60f01e),0xff`, BC = (0x1950), DE = (0x1952), then
;          T_ParamRecord_WriteFieldAndStage (T_F407D4) (ParamRecord_WriteFieldAndStage) and T_Queue2C00_PublishStagedIfPending (T_F407B4).
; Evidence: the six instructions at 0xFAD8A1-0xFAD8B3.
; ★ (0x1950..0x1953) is the four-byte staging area the MIDI-in handlers
;          fill: MidiIn_CC5B_Effect1Depth and its neighbours end in
;          `ld (0x1950),BC / ld (0x1952),DE` and then call one of this
;          module's slots -- 0xFA6D1A and 0xFA6D1E are one such pair.
; ---------------------------------------------------------------------
ParamApply_WriteStagedAndPublish:
	ld (0x60f01e:24), 0xff
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamApply_PublishStagedPair -- copy the 0x1950 staging cells into the
;                           publish record and publish, with NO record
;                           write
;
; Called from: prom_b directory slot T_ParamApply_PublishStagedPair.
; Body:    `ld (0x60f01e),0xff`; (0x60F080) = (0x1950); (0x60F082) =
;          (0x1952); T_Queue2C00_PublishStagedIfPending (T_F407B4).  Nothing reads ParamNumber_RecordPtrs on
;          this path, so a parameter number with no record can use it.
; Evidence: the six instructions at 0xFAD8BC-0xFAD8D8; the absence of any
;          `call 0xf407d4`/`0xf407d8` between them.
; ---------------------------------------------------------------------
ParamApply_PublishStagedPair:
	ld (0x60f01e:24), 0xff
	ld wa, (0x1950:16)
	ld (0x60f080:24), wa
	ld wa, (0x1952:16)
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamApply_PublishStagedPair_Copy -- a second copy, published as its own
;                           directory slot
;
; Called from: prom_b directory slot T_ParamApply_PublishStagedPair_Copy.
; ★ BORROWED NAME, WITH THE DIFF: 0xFAD8BC and 0xFAD8DD are 29 bytes with
;          ZERO differing -- byte for byte the same routine, `ret`
;          included.  Check C2 recomputes both numbers.  (At 33 bytes the
;          count is 1, and that byte is the `calr` displacement of the
;          four-byte stub that FOLLOWS each routine; 29 is where both
;          routines end.)
; ---------------------------------------------------------------------
ParamApply_PublishStagedPair_Copy:
	ld (0x60f01e:24), 0xff
	ld wa, (0x1950:16)
	ld (0x60f080:24), wa
	ld wa, (0x1952:16)
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamApply_PublishStagedAndPostSeven -- publish the staged pair, then
;                           post seven fixed records for the same index
;
; Called from: prom_b directory slot T_ParamApply_PublishStagedAndPostSeven.
; Body:    the ParamApply_PublishStagedPair sequence, then seven
;          Queue2E00_AppendRegs (T_Queue2E00_AppendRegs (T_F40F3C)) calls with E = 0xB1, 0xB4,
;          0xB2, 0xB3, 0xB5, 0xB6, 0xB7 in that order, D = (0x1951) each
;          time and WA = 0x4000, 0x7F00, 0x7F00, 0x7F7F, 0x7F00, 0x7F00,
;          0x7F00; then (0x1980 + 2*(0x1951)) = 0x7F7F.
; Evidence: the seven `ld E,0xbN` immediates at 0xFAD91A, 0xFAD927,
;          0xFAD934, 0xFAD941, 0xFAD94E, 0xFAD95B and 0xFAD968, each
;          followed by `call 0xf40f3c`; `ld XIX,0x00001980` at 0xFAD97E.
;          Check C3 reads the seven parameter numbers and the seven WA
;          immediates out of the ROM rather than trusting this list.
; ★ All seven are parameter numbers that have an Evt2030 handler and NO
;          record, so the seven posts go out as queue traffic only.
; Unknown:  what 0x1980 is.  A 16-bit array indexed by the same index.
; ---------------------------------------------------------------------
ParamApply_PublishStagedAndPostSeven:
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	ld (0x60f01e:24), 0xff
	ld (0x60f080:24), bc
	ld (0x60f082:24), de
	call T_Queue2C00_PublishStagedIfPending
	ld e, 0xb1:opc
	ld d, (0x1951:16)
	ldw wa, 0x4000
	call T_Queue2E00_AppendRegs
	ld e, 0xb4:opc
	ld d, (0x1951:16)
	ldw wa, 0x7f00
	call T_Queue2E00_AppendRegs
	ld e, 0xb2:opc
	ld d, (0x1951:16)
	ldw wa, 0x7f00
	call T_Queue2E00_AppendRegs
	ld e, 0xb3:opc
	ld d, (0x1951:16)
	ldw wa, 0x7f7f
	call T_Queue2E00_AppendRegs
	ld e, 0xb5:opc
	ld d, (0x1951:16)
	ldw wa, 0x7f00
	call T_Queue2E00_AppendRegs
	ld e, 0xb6:opc
	ld d, (0x1951:16)
	ldw wa, 0x7f00
	call T_Queue2E00_AppendRegs
	ld e, 0xb7:opc
	ld d, (0x1951:16)
	ldw wa, 0x7f00
	call T_Queue2E00_AppendRegs
	xor H,H
	ld l, (0x1951:16)
	sla hl, 0x01
	ld XIX,0x00001980
	.byte 0xf3, 0x07, 0xf0, 0xec, 0x02, 0x7f, 0x7f
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamApply_PublishStagedPairBCDE -- the same publish, staged through
;                           BC/DE instead of WA
;
; Called from: prom_b directory slot T_ParamApply_PublishStagedPairBCDE.
; Body:    BC = (0x1950); DE = (0x1952); `ld (0x60f01e),0xff`;
;          (0x60F080) = BC; (0x60F082) = DE; T_Queue2C00_PublishStagedIfPending (T_F407B4).  Same effect as
;          ParamApply_PublishStagedPair, different register file and a
;          different order, so the two are NOT a byte match -- the name
;          says which spelling this is and claims nothing more.
; Evidence: `ld BC,(0x1950)` at 0xFAD98F against `ld WA,(0x1950)` at
;          0xFAD8C2; 28 bytes here against 29 there.
; ---------------------------------------------------------------------
ParamApply_PublishStagedPairBCDE:
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	ld (0x60f01e:24), 0xff
	ld (0x60f080:24), bc
	ld (0x60f082:24), de
	call T_Queue2C00_PublishStagedIfPending
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamApply_WriteStagedAndPublish_Copy -- a second copy of 0xFAD8A1
;
; Called from: prom_b directory slot T_ParamApply_WriteStagedAndPublish_Copy.
; ★ BORROWED NAME, WITH THE DIFF: 0xFAD8A1 and 0xFAD9B0 are 23 bytes with
;          ZERO differing.  Check C2 recomputes both numbers.
; ---------------------------------------------------------------------
ParamApply_WriteStagedAndPublish_Copy:
	ld (0x60f01e:24), 0xff
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; ParamApply_OneHotOfSix -- apply a value whose low six bits are an
;                           ORDINAL, as a one-hot bit in the next field
;
; Called from: prom_b directory slot T_ParamApply_OneHotOfSix.
; Body:    A = (0x1952) & 0x3F; return when A >= 6.  Then write bit 6 of
;          the value, INVERTED, into field B under the staged mask, and
;          publish.  Then reload BC = (0x1950), advance B by 1 -- or by 2
;          when bit 7 of the value is clear -- look the ordinal up in
;          OrdinalToBitMask6, set D = 0x3F, and write and publish that.
; Evidence: `and A,0x3f` at 0xFAD9CF and `cp A,6` at 0xFAD9D2 bound the
;          ordinal; `srl 0x06,E / xor E,0xff / and E,0x01` at
;          0xFAD9E4-0xFAD9EA is the inverted bit 6; `inc 1,B` at 0xFAD9F9
;          and 0xFADA06 with `srl 0x07,A / jr C` between them is the
;          +1-or-+2; `ld XIX,0x00fada20` at 0xFADA0B is the table.
;          Two independent pins on the 6: the `cp A,6` bound and the
;          table's own six bytes.
; Unknown:  which parameter this is for -- C comes from (0x1950) and is
;          not constrained here.
; ---------------------------------------------------------------------
ParamApply_OneHotOfSix:
	ld a, (0x1952:16)
	and A,0x3f
	cp a, 0x06:i3
	jr nc, .LFADA1F
	ld (0x60f01e:24), 0xff
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	srl e, 0x06
	xor E,0xff
	and E,0x01
	call T_ParamRecord_WriteFieldAndStage_Copy
	call T_Queue2C00_PublishStagedIfPending
	ld bc, (0x1950:16)
	inc 1,B
	ld e, (0x1952:16)
	ld A,E
	srl a, 0x07
	jr c, .LFADA08
	inc 1,B
.LFADA08:
	and E,0x3f
	ld XIX,OrdinalToBitMask6
	ld	e, (xix+e)
	ld d, 0x3f:opc
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
.LFADA1F:
	ret
; ---------------------------------------------------------------------
; OrdinalToBitMask6 -- six bytes, 0x01 0x02 0x04 0x08 0x10 0x20: ordinal
;                           k (0..5) as a one-hot bit
;
; Read by: `ld E,(XIX+E)` at 0xFADA10, with XIX loaded from
;          `ld XIX,0x00fada20` at 0xFADA0B, inside ParamApply_OneHotOfSix.
; ★ It is the exact inverse of BitMaskToOrdinal6 at 0xFADD30: for every
;          k in 0..5, BitMaskToOrdinal6[OrdinalToBitMask6[k]] == k.  Check
;          C4 asserts that round trip on all six, last included -- which is
;          what makes both names something better than a reading of six
;          bytes.
; Evidence: the six bytes, re-read from the ROM by check C4.
; ⚠ THE EMITTER SPELLED THEM AS INSTRUCTIONS.  The four lines below this
;          label -- `normal`, `push SR`, `max`, `ld (0x10),0x20` (the .s
;          spells the last one `ldio 0x10, 0x20`) -- are
;          0x01 0x02 0x04 0x08 0x10 0x20, this table, decoded as code by
;          notes/gen_prom_a_fad800_module.py.  The byte gate cannot tell
;          the difference and never will; only this header can.
; ---------------------------------------------------------------------
OrdinalToBitMask6:
	normal
	push SR
	max
	ld (P5CR:8), 0x20:io
; ---------------------------------------------------------------------
; ParamShadow_FlushAll -- publish every shadow entry whose bit 7 is set,
;                           then clear the bit
;
; Called from: prom_b directory slot T_ParamShadow_FlushAll.
; Body:    five sweeps, starting immediately with `ld XIY,0x0060f590`:
;            0x60F590[0..0x1F]  as parameter 0xB3, mask 0x7F
;            0x60F650           as parameter 0xB0 index 1, mask 0x7F,
;                               also copied to (0x24F0) and sent through
;                               T_ParamB0_PublishField0IfPending
;            0x60F5B0[0..0x1F]  as parameter 0xB2, mask 0x7F
;            0x60F5D0[0..0x1F]  as parameter 0xB1, 16-bit: the stored high
;                               byte becomes the mask (T_Queue2C00_PublishStagedDrainPassB (T_F407B8))
;            0x60F610[0..0x1F]  as parameter <index>, field 3, mask 0x7F
;                               (T_ParamRecord_WriteFieldAndStage (T_F407D4) then T_Queue2C00_PublishStagedIfPending (T_F407B4))
;          Each sweep tests bit 7, clears it, writes the record and calls
;          a publish entry.
; Evidence: `ld XIY,0x0060f590` at 0xFADA26, `ld W,0xb3` at 0xFADA2B,
;          `ld XIY,0x0060f5b0` at 0xFADA33, `ld W,0xb2` at 0xFADA38,
;          `ld XIY,0x0060f650` at 0xFADA7F, `ld XIY,0x0060f5d0` at
;          0xFADABA, `ld XIY,0x0060f610` at 0xFADAF5; `bit 0x07,A` and
;          `res 0x07,A` in each loop; `cp L,0x1f`/`cp B,0x1f` bound each
;          sweep at 32 entries.
; ★ 0xB3 is EXPRESSION, 0xB2 is MODULATION 1 and 0xB1 is PITCH BEND --
;          see ParamShadow_SetExpression, ParamShadow_SetModulation1 and
;          ParamShadow_SetPitchBend for the witnesses.  0xB0 has no
;          outbound handler (MidiOut_ParamNumberTable[0xB0] is a bare
;          `ret` at 0xFA767D), so nothing here names it.
; ★ These five arrays are the deferred half of this module: the four
;          ParamShadow_Set* entries write them and only this routine reads
;          them.  Nothing else in prom_a names 0x60F590, 0x60F5B0,
;          0x60F5D0, 0x60F610 or 0x60F650.
; ---------------------------------------------------------------------
ParamShadow_FlushAll:
	ld XIY,SeqEvt_ExpressionShadow
	ld w, 0xb3:opc
	calr .LFADA44
	calr .LFADA7F
	ld XIY,SeqEvt_ModulationShadow
	ld w, 0xb2:opc
	calr .LFADA44
	calr .LFADABA
	calr .LFADAF5
	ret
.LFADA44:
	xor HL,HL
.LFADA46:
	ld	a, (xiy+hl)
	bit 0x07,A
	jr z, .LFADA77
	res 0x07,A
	ld	(xiy+hl), a
	ld (0x60f01e:24), 0xff
	ld (0x60f080:24), w
	ld (0x60f081:24), l
	ld (0x60f082:24), a
	ld (0x60f083:24), 0x7f
	call T_Queue2C00_PublishStagedIfPending
.LFADA77:
	inc 1,HL
	cp L,0x1f
	jr ule, .LFADA46
	ret
.LFADA7F:
	ld XIY,0x0060f650
	ld A,(XIY)
	bit 0x07,A
	jr z, .LFADAB9
	res 0x07,A
	ld (XIY),A
	ld (0x24f0:16), a
	call T_ParamB0_PublishField0IfPending
	ld (0x60f01e:24), 0xff
	ld (0x60f080:24), 0xb0
	ld (0x60f081:24), 0x01
	ld (0x60f082:24), a
	ld (0x60f083:24), 0x7f
	call T_Queue2C00_PublishStagedIfPending
.LFADAB9:
	ret
.LFADABA:
	ld XIY,SeqEvt_PitchBendShadow
	xor HL,HL
	xor BC,BC
.LFADAC3:
	ld	wa, (xiy+hl)
	bit 0x07,A
	jr z, .LFADAEB
	res 0x07,A
	ld	(xiy+hl), wa
	ld (0x60f01e:24), 0xff
	ld c, 0xb1:opc
	ld (0x60f080:24), bc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedDrainPassB
.LFADAEB:
	inc 1,B
	inc 2,HL
	cp B,0x1f
	jr ule, .LFADAC3
	ret
.LFADAF5:
	ld XIY,SeqEvt_VolumeShadow
	xor HL,HL
.LFADAFC:
	ld	a, (xiy+hl)
	bit 0x07,A
	jr z, .LFADB24
	res 0x07,A
	ld	(xiy+hl), a
	ld (0x60f01e:24), 0xff
	ld C,L
	ld b, 0x03:opc
	ld E,A
	ld d, 0x7f:opc
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
.LFADB24:
	inc 1,HL
	cp L,0x1f
	jr ule, .LFADAFC
	ret
; ---------------------------------------------------------------------
; Evt2030_RunList -- walk the 0x2030 event list and dispatch every record
;                           through Evt2030_ClassHandlers
;
; Called from: prom_b directory slot T_Evt2030_RunList.
; Body:    return when bit 0 of (0x0922) is set and bit 1 is clear;
;          otherwise (0x60F08C) = 0 and loop: A = byte +0 of the record at
;          0x2030 + (0x60F08C); stop at 0xFF; skip when A > 0xBF; else
;          XIY = Evt2030_ClassHandlers[A]; skip when that is 0xFFFFFFFF;
;          load BC and DE from the record, save them to (0x60F0BC) and
;          (0x60F0BE), `call XIY`, advance (0x60F08C) by 4.
; Evidence: `ld (0x60f08c),0x0000` at 0xFADB3A, `ld XIX,0x00002030` at
;          0xFADB41, `cp A,0xff` at 0xFADB50, `cp A,0xbf` at 0xFADB55,
;          `ld XIY,0x00fae3a2` at 0xFADB5F, `cp XIY,0xffffffff` at
;          0xFADB69, `call T,XIY` at 0xFADB87, `inc 4,(0x60f08c)` at
;          0xFADB89.  The 0x2030 list itself is List2030_AppendRegs'
;          (0xF86AC7) buffer, whose header already names this loop as one
;          of its three consumers.
; ★ 0xBF is the same bound MidiOut_ParamChanged uses on the SAME byte
;          (`cp C,0xbf` at 0xFA710B), and both tables have 192 entries.
; ---------------------------------------------------------------------
Evt2030_RunList:
	ld a, (0x0922:16)
	bit 0x00,A
	jr z, .LFADB3A
	bit 0x01,A
	jr nz, .LFADB90
.LFADB3A:
	ldw (0x60f08c:24), 0x00
.LFADB41:
	ld XIX,0x00002030
	ld hl, (0x60f08c:24)
	ld	a, (xix+hl)
	cp A,0xff
	jr z, .LFADB90
	cp A,0xbf
	jr ugt, .LFADB89
	extz WA
	sll wa, 0x02
	ld XIY,Evt2030_ClassHandlers
	ld	xiy, (xiy+wa)
	cp XIY,0xffffffff
	jr z, .LFADB89
	ld	bc, (xix+hl)
	inc 2,HL
	ld (0x60f0bc:24), bc
	ld	de, (xix+hl)
	ld (0x60f0be:24), de
	call (xiy)
.LFADB89:
	inc 0x04, (0x60f08c:24)
	jr .LFADB41
.LFADB90:
	ret
; ---------------------------------------------------------------------
; Evt2030_Class00to1F -- the 0xFAD800 module's handler for event classes
;                        0x00-0x1F of the RAM 0x2030 list
;
; Called from: `call XIY` at 0xFADB87, after 0xFADB64 fetched the handler
;          from Evt2030_ClassHandlers.  All 32 of that table's entries
;          0x00..0x1F hold 0x00FADB91 -- check N1.
; Inputs:  C = the record's byte +0 (the class), B = byte +1, E = byte +2,
;          D = byte +3; the same four bytes List2030_AppendRegs (prom_a
;          0xF86AC7) stores, and the same payload UiEventList_Run hands to
;          the pass-C handlers as (0x20B8)/(0x20B9)/(0x20BA).
; Body:    L = B; refuse if L > 0x0B; jump through the 12-entry table at
;          0x00FADBA9 (`cp L,0x0b` at 0xFADB95, `ld XIX,0x00fadba9` at
;          0xFADB9D).
; Evidence: two independent pins on the 12 -- the `cp L,0x0b` bound and
;          the table's 48-byte extent, which ends where the first arm
;          (0xFADBD9) begins.
; ---------------------------------------------------------------------
Evt2030_Class00to1F:   ; entry: pointer-table entry
	extz HL
	ld L,B
	cp L,0x0b
	jr ugt, Evt2030_Class00to1F_Op01
	sll hl, 0x02
	ld XIX,Evt2030_Class00to1F_JumpTable_FADBA9
	ld	xix, (xix+hl)
	jp (xix)
; --- 0xFADBA9-0xFADBD9  pointer table (48 bytes) ---
Evt2030_Class00to1F_JumpTable_FADBA9:
	.long Evt2030_Class00to1F_Op00 ; -> Evt2030_Class00to1F_Op00   ; FADBA9
	.long Evt2030_Class00to1F_Op01 ; -> Evt2030_Class00to1F_Op01   ; FADBAD
	.long Evt2030_Class00to1F_Op01 ; -> Evt2030_Class00to1F_Op01   ; FADBB1
	.long Evt2030_Class00to1F_Op03 ; -> Evt2030_Class00to1F_Op03   ; FADBB5
	.long Evt2030_Class00to1F_Op04 ; -> Evt2030_Class00to1F_Op04   ; FADBB9
	.long Evt2030_Class00to1F_Op05 ; -> Evt2030_Class00to1F_Op05   ; FADBBD
	.long Evt2030_Class00to1F_Op05 ; -> Evt2030_Class00to1F_Op05   ; FADBC1
	.long Evt2030_Class00to1F_Op05 ; -> Evt2030_Class00to1F_Op05   ; FADBC5
	.long Evt2030_Class00to1F_Op05 ; -> Evt2030_Class00to1F_Op05   ; FADBC9
	.long Evt2030_Class00to1F_Op05 ; -> Evt2030_Class00to1F_Op05   ; FADBCD
	.long Evt2030_Class00to1F_Op05 ; -> Evt2030_Class00to1F_Op05   ; FADBD1
	.long Evt2030_Class00to1F_Op05 ; -> Evt2030_Class00to1F_Op05   ; FADBD5
; ---------------------------------------------------------------------
; Evt2030_Class00to1F_Op01 -- operations 0x01 and 0x02: do nothing
;
; Called from: `jp XIX` at 0xFADBA7; indices 1 AND 2 of the table at
;          0x00FADBA9 both hold 0x00FADBD9 -- check N2.  Named after the
;          LOWER index because a label can only have one name.
; Body:    one `ret`.
; ---------------------------------------------------------------------
Evt2030_Class00to1F_Op01:   ; entry: pointer-table entry
	ret
; Evt2030_ProgChgMode3_Notify -- PROG CHANGE MODE value 3 (no caption) of Evt2030_Class00to1F_Op00, a part's program change (class 0): map the part's sound bytes through T_PartSound_ToProgramChange and notify bank select (param 0x81) and program (class 0)
; Evidence: arm 3 of the 4-entry table at 0xFAE30E -- the LE32 word at 0xFAE31A reads 0x00FADBDA; reader `ld XIX,0x00fae30e` at 0xFAE301, index (0x7F32) & 3.
; (0x7F32) & 3 is PROG CHANGE MODE: sub_F9A4B0 copies it to (0x2740) and draws it with DL_NormalTechRemap at screen offset 0x15F8, right after the 18-char "PROG CHANGE MODE: " text at 0x15E6 of DL_TotalModeMidiMidiInputMode; DLTable_NormalTechRemap holds only NORMAL/TECH/REMAP.
; Body: unless C == 0x48, (0x60F010) = word at ParamNumber_RecordPtrs[C], (0x60F012) = C, `call T_PartSound_ToProgramChange` (PartSound_ToProgramChange), then ParamChange_NotifyClearSource {0x81, part, (0x60F014..15)} and {part, 0, (0x60F016), 0xFF}.  MidiOut_ParamNumberTable[129] is MidiOut_BankSelect_Pair; class 0 is MidiOut_ProgramChange.
Evt2030_ProgChgMode3_Notify:   ; entry: pointer-table entry
	cp C,0x48
	jr z, .LFADC1F
	extz HL
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	ld WA,(XIX)
	ld (SoundConv_Arg0:24), wa
	ld (SoundConv_Arg2:24), c
	call T_PartSound_ToProgramChange
	ld B,C
	ld c, 0x81:opc
	ld de, (SoundConv_Result0:24)
	call T_ParamChange_NotifyClearSource
	ld c, (0x60f0bc:24)
	xor B,B
	ld e, (SoundConv_Result2:24)
	ld d, 0xff:opc
	call T_ParamChange_NotifyClearSource
.LFADC1F:
	ret
; ---------------------------------------------------------------------
; Evt2030_Class00to1F_Op03 -- operation 0x03 of event classes 0x00-0x1F
;
; Called from: `jp XIX` at 0xFADBA7; table index 3 -- check N2.
; Body:    HL = C * 4; XIX = ((0x60F018))[HL]; E = (XIX + B) & 0x7F;
;          D = 0x7F; `call T_ParamChange_NotifyClearSource (T_F407CC)`.
; Evidence: (0x60F018) is the table base prom_b's IndexedTable_GetPtr
;          (0xF55321) reads, and prom_a's byte-identical twin of that
;          routine is at 0xFB77D8 -- so the class byte C indexes a table
;          of per-class records and B is the offset inside one.
; ---------------------------------------------------------------------
Evt2030_Class00to1F_Op03:   ; entry: pointer-table entry
	extz HL
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	ld L,B
	ld	e, (xix+l)
	and E,0x7f
	ld d, 0x7f:opc
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_Class00to1F_Op04 -- operation 0x04 of event classes 0x00-0x1F
;
; Called from: `jp XIX` at 0xFADBA7; table index 4 -- check N2.
; Body:    masks DE with 0x4848, consults bit 1 of (0x60F020), and only
;          then does the same record fetch as Op03.
; ---------------------------------------------------------------------
Evt2030_Class00to1F_Op04:   ; entry: pointer-table entry
	and DE,0x4848
	and E,D
	bit 0x03,D
	jr z, .LFADC57
	bit	1, (0x60f020:24)
	jr z, .LFADC57
	or E,0x08
.LFADC57:
	ld A,E
	and E,0x48
	jr z, .LFADC7D
	extz HL
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	ld L,B
	ld	e, (xix+l)
	and D,0x48
	call T_ParamChange_NotifyClearSource
.LFADC7D:
	ret
; ---------------------------------------------------------------------
; Evt2030_Class00to1F_Op05 -- operations 0x05 through 0x0B
;
; Called from: `jp XIX` at 0xFADBA7; SEVEN indices, 5..0x0B, of the table
;          at 0x00FADBA9 hold 0x00FADC7E -- check N2.  Named after the
;          lowest.
; Body:    returns at once when D == 0; otherwise the same record fetch as
;          Op03, with no masking.
; ---------------------------------------------------------------------
Evt2030_Class00to1F_Op05:   ; entry: pointer-table entry
	cp d, 0x00:i3
	jr z, .LFADC9E
	extz HL
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	ld L,B
	ld	e, (xix+l)
	call T_ParamChange_NotifyClearSource
.LFADC9E:
	ret
; ---------------------------------------------------------------------
; Evt2030_Class20to3F -- the same, for event classes 0x20-0x3F
;
; Called from: `call XIY` at 0xFADB87; all 32 entries 0x20..0x3F of
;          Evt2030_ClassHandlers hold 0x00FADC9F -- check N1.
; Body:    L = B - 0x18; refuse if B < 0x18 or L > 2; jump through the
;          3-entry table at 0x00FADCBE.
; Evidence: `cp L,0x18` at 0xFADCA3, `sub L,0x18` at 0xFADCA8, `cp L,2` at
;          0xFADCAB -- so this class's operation byte runs 0x18..0x1A, not
;          from zero.  The table's 12-byte extent agrees: 3 entries.
; ---------------------------------------------------------------------
Evt2030_Class20to3F:   ; entry: pointer-table entry
	extz HL
	ld L,B
	cp L,0x18
	jr c, DuplicateTail_FAD3EB_Code_Return
	sub L,0x18
	cp l, 0x02:i3
	jr ugt, DuplicateTail_FAD3EB_Code_Return
	sll hl, 0x02
	ld XIX,Evt2030_Class20to3F_JumpTable_FADCBE
	ld	xix, (xix+hl)
	jp (xix)
; --- 0xFADCBE-0xFADCCA  pointer table (12 bytes) ---
Evt2030_Class20to3F_JumpTable_FADCBE:
	.long Evt2030_Class20to3F_Op18 ; -> Evt2030_Class20to3F_Op18   ; FADCBE
	.long Evt2030_Class20to3F_Op19 ; -> Evt2030_Class20to3F_Op19   ; FADCC2
	.long Evt2030_Class20to3F_Op1A ; -> Evt2030_Class20to3F_Op1A   ; FADCC6
DuplicateTail_FAD3EB_Code_Return:
	ret
; ---------------------------------------------------------------------
; Evt2030_Class20to3F_Op18 -- operation 0x18 of event classes 0x20-0x3F
;
; Called from: `jp XIX` at 0xFADCBC; index 0 of the 3-entry table at
;          0x00FADCBE, which its reader indexes with B - 0x18 -- check N3.
; ---------------------------------------------------------------------
Evt2030_Class20to3F_Op18:   ; entry: pointer-table entry
	calr .LFADCE5
	ret
; ---------------------------------------------------------------------
; Evt2030_Class20to3F_Op19 -- operation 0x19 of event classes 0x20-0x3F
;
; Called from: `jp XIX` at 0xFADCBC; index 1 of the table at 0x00FADCBE
;          -- check N3.
; ---------------------------------------------------------------------
Evt2030_Class20to3F_Op19:   ; entry: pointer-table entry
	and E,D
	and E,0x3f
	jr z, .LFADCD9
	calr .LFADCE5
.LFADCD9:
	ret
; ---------------------------------------------------------------------
; Evt2030_Class20to3F_Op1A -- operation 0x1A of event classes 0x20-0x3F
;
; Called from: `jp XIX` at 0xFADCBC; index 2 of the table at 0x00FADCBE
;          -- check N3.
; ---------------------------------------------------------------------
Evt2030_Class20to3F_Op1A:   ; entry: pointer-table entry
	and E,D
	and E,0x3f
	jr z, .LFADCE4
	calr .LFADCE5
.LFADCE4:
	ret
.LFADCE5:
	extz HL
	ld l, (0x60f0bc:24)
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	ld E,(XIX+0x18)
	ld D,E
	xor E,0xff
	and E,0x01
	sll e, 0x06
	ld A,(XIX+0x19)
	and A,0x3f
	bit 0x00,D
	jr z, .LFADD18
	ld A,(XIX+0x1a)
	and A,0x3f
.LFADD18:
	ld XIX,BitMaskToOrdinal6
	ld	a, (xix+a)
	or E,A
	ld c, (0x60f0bc:24)
	ld b, 0x18:opc
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; BitMaskToOrdinal6 -- 48 bytes indexed by a one-hot byte: 0x01 -> 0,
;                           0x02 -> 1, 0x04 -> 2, 0x08 -> 3, 0x10 -> 4,
;                           0x20 -> 5, every other index 0
;
; Read by: `ld A,(XIX+A)` at 0xFADD1D, with XIX loaded from
;          `ld XIX,0x00fadd30` at 0xFADD18, inside the shared tail at
;          0xFADCE5 that all three Evt2030_Class20to3F arms call.
; ★ The inverse of OrdinalToBitMask6 at 0xFADA20 -- check C4 asserts the
;          round trip on all six, last included.
; Extent:  48 bytes, from 0xFADD30 to the code at 0xFADD60.  The largest
;          index it can be reached with is 0x3F (`and A,0x3f` at 0xFADD0A
;          and 0xFADD15), so 0x40 bytes would be the natural size and the
;          table is 0x30; indices 0x30..0x3F would run into the code.
;          ⚠ Stated as measured, not explained.
; ---------------------------------------------------------------------
BitMaskToOrdinal6:
	nop
	nop
	normal
	nop
	push SR
	nop
	nop
	nop
	pop SR
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	max
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	halt
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	extz HL
	ld L,B
	cp l, 0x03:i3
	jr ugt, BitMaskToOrdinal6_JumpTable_FADD77_Nop1
	sll hl, 0x02
	ld XIX,BitMaskToOrdinal6_JumpTable_FADD77
	ld	xix, (xix+hl)
	jp (xix)
; --- 0xFADD77-0xFADD87  pointer table (16 bytes) ---
BitMaskToOrdinal6_JumpTable_FADD77:
	.long Evt2030_Class00to1F_Op00 ; -> Evt2030_Class00to1F_Op00   ; FADD77
	.long BitMaskToOrdinal6_JumpTable_FADD77_Nop1   ; -> BitMaskToOrdinal6_JumpTable_FADD77_Nop1   ; FADD7B
	.long BitMaskToOrdinal6_JumpTable_FADD77_Nop1   ; -> BitMaskToOrdinal6_JumpTable_FADD77_Nop1   ; FADD7F
	.long BitMaskToOrdinal6_JumpTable_FADD77_Nop3   ; -> BitMaskToOrdinal6_JumpTable_FADD77_Nop3   ; FADD83
; ---------------------------------------------------------------------
; BitMaskToOrdinal6_JumpTable_FADD77_Nop1 -- arm 1, 2 of the 4-entry jump table at 0xFADD77
;
; Called from: the reader `ld XIX,0x00fadd77` at 0xFADD6B, through XIX/XIY.
;          Index: B, bounded by `cp L,3` at 0xFADD64.
; Owner:   the handler at 0xFADD60, which NOTHING references.
; Body:    starts `ret`.
; Evidence: the LE32 words at 0xFADD7B, 0xFADD7F reads 0x00FADD87, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names B, bounded by `cp L,3` at 0xFADD64, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
BitMaskToOrdinal6_JumpTable_FADD77_Nop1:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; BitMaskToOrdinal6_JumpTable_FADD77_Nop3 -- arm 3 of the 4-entry jump table at 0xFADD77
;
; Called from: the reader `ld XIX,0x00fadd77` at 0xFADD6B, through XIX/XIY.
;          Index: B, bounded by `cp L,3` at 0xFADD64.
; Owner:   the handler at 0xFADD60, which NOTHING references.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFADD83 reads 0x00FADD88, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names B, bounded by `cp L,3` at 0xFADD64, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
BitMaskToOrdinal6_JumpTable_FADD77_Nop3:   ; entry: pointer-table entry
	ret
	extz HL
	ld L,B
	cp l, 0x01:i3
	jr ugt, sub_FADD88_JumpTable_FADDA0_Nop0
	sll hl, 0x02
	ld XIX,sub_FADD88_JumpTable_FADDA0
	ld	xix, (xix+hl)
	jp (xix)
; --- 0xFADDA0-0xFADDA8  pointer table (8 bytes) ---
sub_FADD88_JumpTable_FADDA0:
	.long sub_FADD88_JumpTable_FADDA0_Nop0   ; -> sub_FADD88_JumpTable_FADDA0_Nop0   ; FADDA0
	.long sub_FADD88_JumpTable_FADDA0_Nop1   ; -> sub_FADD88_JumpTable_FADDA0_Nop1   ; FADDA4
; ---------------------------------------------------------------------
; sub_FADD88_JumpTable_FADDA0_Nop0 -- arm 0 of the 2-entry jump table at 0xFADDA0
;
; Called from: the reader `ld XIX,0x00fadda0` at 0xFADD94, through XIX/XIY.
;          Index: B, bounded by `cp L,1` at 0xFADD8D.
; Owner:   the handler at 0xFADD89, which NOTHING references.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFADDA0 reads 0x00FADDA8, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names B, bounded by `cp L,1` at 0xFADD8D, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
sub_FADD88_JumpTable_FADDA0_Nop0:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; sub_FADD88_JumpTable_FADDA0_Nop1 -- arm 1 of the 2-entry jump table at 0xFADDA0
;
; Called from: the reader `ld XIX,0x00fadda0` at 0xFADD94, through XIX/XIY.
;          Index: B, bounded by `cp L,1` at 0xFADD8D.
; Owner:   the handler at 0xFADD89, which NOTHING references.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFADDA4 reads 0x00FADDA9, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names B, bounded by `cp L,1` at 0xFADD8D, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
sub_FADD88_JumpTable_FADDA0_Nop1:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; Evt2030_Class98 -- the 0xFAD800 module's handler for event class 0x98
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0x98] is the
;          only entry holding 0x00FADDAA -- check N1.
; Evidence: 0x98 is one of the thirteen class ids ByteTable_FAD38A lists
;          (0xFAD38A, read at 0xFAAFCE and 0xFAB031) and one of the 121
;          that own a handler list in all three of the
;          UiEventClass_ListTable_A/B/C tables at 0xF87681 / 0xF87E91 /
;          0xF88EC1.
; ---------------------------------------------------------------------
Evt2030_Class98:   ; entry: pointer-table entry
	extz HL
	ld L,B
	cp l, 0x01:i3
	jr ugt, Evt2030_Class98_Op00
	sll hl, 0x02
	ld XIX,Evt2030_Class98_JumpTable_FADDC1
	ld	xix, (xix+hl)
	jp (xix)
; --- 0xFADDC1-0xFADDC9  pointer table (8 bytes) ---
Evt2030_Class98_JumpTable_FADDC1:
	.long Evt2030_Class98_Op00 ; -> Evt2030_Class98_Op00   ; FADDC1
	.long Evt2030_Class98_Op01 ; -> Evt2030_Class98_Op01   ; FADDC5
; ---------------------------------------------------------------------
; Evt2030_Class98_Op00 -- operation 0 of parameter number 0x98: do nothing
;
; Called from: `jp T,XIX` at 0xFADDBF; index 0 of the 2-entry table at
;          0x00FADDC1, which Evt2030_Class98 indexes with B after
;          `cp L,1` at 0xFADDAE.
; Body:    one `ret`.
; Evidence: the LE32 word at 0xFADDC1 reads 0x00FADDC9 and the word at
;          0xFADDC5 reads 0x00FADDCA, so the two arms are one byte apart
;          and the first is the `ret`.
; ---------------------------------------------------------------------
Evt2030_Class98_Op00:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; Evt2030_Class98_Op01 -- operation 1 of parameter number 0x98
;
; Called from: `jp T,XIX` at 0xFADDBF; index 1 of the table at 0x00FADDC1.
; Body:    return unless bit 3 of (0x7F32) is set; bump (0x1965) and
;          return if its bit 0 is now set; otherwise dispatch on
;          (0x7F32) & 3 through the 4-entry table at 0x00FADDF1.
; Evidence: `bit 3,(0x7f32)` at 0xFADDCA, `inc 1,(0x1965)` at 0xFADDD1,
;          `ld L,(0x7f32)` at 0xFADDDB and `and L,0x03` at 0xFADDDF,
;          `ld XIX,0x00faddf1` at 0xFADDE5.
; ★ (0x7F32) is parameter number 0x80's own record -- see
;          ParamNumber_RecordPtrs -- so this handler for parameter 0x98
;          is gated by, and dispatched on, ANOTHER parameter's value.
; Unknown:  what bit 3 of (0x7F32) is, and what (0x1965) counts.
; ---------------------------------------------------------------------
Evt2030_Class98_Op01:   ; entry: pointer-table entry
	bit	3, (MidiCfg_ModeBits:16)
	jrl z, Evt2030_Class98_Op01_JumpTable_FADDF1_Nop2
	inc 0x01, (0x1965:16)
	bit	0, (0x1965:16)
	jr nz, Evt2030_Class98_Op01_JumpTable_FADDF1_Nop2
	ld l, (MidiCfg_ModeBits:16)
	and L,0x03
	sll l, 0x02
	ld XIX,Evt2030_Class98_Op01_JumpTable_FADDF1
	ld	xix, (xix+l)
	jp (xix)
; --- 0xFADDF1-0xFADE01  pointer table (16 bytes) ---
Evt2030_Class98_Op01_JumpTable_FADDF1:
	.long Evt2030_Param98Normal_Notify   ; -> Evt2030_Param98Normal_Notify   ; FADDF1
	.long Evt2030_Param98Tech_Notify   ; -> Evt2030_Param98Tech_Notify   ; FADDF5
	.long Evt2030_Class98_Op01_JumpTable_FADDF1_Nop2   ; -> Evt2030_Class98_Op01_JumpTable_FADDF1_Nop2   ; FADDF9
	.long Evt2030_Class98_Op01_JumpTable_FADDF1_Nop2   ; -> Evt2030_Class98_Op01_JumpTable_FADDF1_Nop2   ; FADDFD
; Evt2030_Param98Normal_Notify -- PROG CHANGE MODE NORMAL arm of Evt2030_Class98_Op01: notify parameter 0x98's class 2 and class 1 values from record bytes 0x7F08..0x7F0A
; Evidence: arm 0 of the 4-entry table at 0xFADDF1 -- the LE32 word at 0xFADDF1 reads 0x00FADE01; reader `ld XIX,0x00faddf1` at 0xFADDE5, index (0x7F32) & 3 = PROG CHANGE MODE (DLTable_NormalTechRemap[0] = "NORMAL").
; Body: ParamChange_NotifyClearSource {0x98, 2, (0x7F0A) split into two 7-bit halves} then {0x98, 1, ((0x7F08)<<3)|((0x7F09)&7), 0xFF}; ends in the shared `ret` 0xFADE55.  The owner runs only when bit 3 of (0x7F32), SINGLE CH PROG CHANGE = COMBI, is set.
Evt2030_Param98Normal_Notify:   ; entry: pointer-table entry
	ldw bc, 0x0298
	extz DE
	ld e, (0x7f0a:16)
	sll de, 0x05
	srl e, 0x01
	call T_ParamChange_NotifyClearSource
	ldw bc, 0x0198
	ld e, (0x7f09:16)
	and E,0x07
	ld d, (0x7f08:16)
	sll d, 0x03
	or E,D
	ld d, 0xff:opc
	call T_ParamChange_NotifyClearSource
	jr .LFADE55
; Evt2030_Param98Tech_Notify -- PROG CHANGE MODE TECH arm of Evt2030_Class98_Op01: notify parameter 0x98's class 2 and class 1 values from record bytes 0x7F04 and 0x7F03
; Evidence: arm 1 of the 4-entry table at 0xFADDF1 -- the LE32 word at 0xFADDF5 reads 0x00FADE2F; reader `ld XIX,0x00faddf1` at 0xFADDE5, index (0x7F32) & 3 (DLTable_NormalTechRemap[1] = "TECH").
; Body: ParamChange_NotifyClearSource {0x98, 2, (0x7F04)&0x3F split} then {0x98, 1, (0x7F03)&0x7F, 0xFF}; the same two bytes and masks Queue2E00_PostParam98Fields posts.
Evt2030_Param98Tech_Notify:   ; entry: pointer-table entry
	extz DE
	ld e, (0x7f04:16)
	and E,0x3f
	sll de, 0x05
	srl e, 0x01
	ldw bc, 0x0298
	call T_ParamChange_NotifyClearSource
	ldw bc, 0x0198
	ld e, (0x7f03:16)
	res 0x07,E
	ld d, 0xff:opc
	call T_ParamChange_NotifyClearSource
.LFADE55:
; ---------------------------------------------------------------------
; Evt2030_Class98_Op01_JumpTable_FADDF1_Nop2 -- arm 2, 3 of the 4-entry jump table at 0xFADDF1
;
; Called from: the reader `ld XIX,0x00faddf1` at 0xFADDE5, through XIX/XIY.
;          Index: (0x7F32) & 3.
; Owner:   Evt2030_Class98_Op01.
; Body:    starts `ret`.
; Evidence: the LE32 words at 0xFADDF9, 0xFADDFD reads 0x00FADE55, and no other
;          entry of that table does.
; Unknown:  ⚠ WHAT THE FOUR VALUES OF (0x7F32) & 3 SELECT.
;          SIX tables in this span are indexed by that same
;          2-bit field; prom_b 0xF6F858 copies it from
;          (0x1380) & 3 and posts it as {0x80, 0, v, 0x03}.
;          That names the producer, not the meaning, so this
;          label stays sub_XXXXXX.  A stated gap beats a
;          plausible guess.
; ---------------------------------------------------------------------
Evt2030_Class98_Op01_JumpTable_FADDF1_Nop2:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassB1_Fwd -- event class 0xB1: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xB1]
;          is the only entry holding 0x00FADE56 -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassB1_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassB2_Fwd -- event class 0xB2: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xB2]
;          is the only entry holding 0x00FADE5B -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassB2_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassB3_Fwd -- event class 0xB3: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xB3]
;          is the only entry holding 0x00FADE60 -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassB3_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassB4_Fwd -- event class 0xB4: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xB4]
;          is the only entry holding 0x00FADE65 -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassB4_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassB5_Fwd -- event class 0xB5: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xB5]
;          is the only entry holding 0x00FADE6A -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassB5_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassB8_Fwd -- event class 0xB8: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xB8]
;          is the only entry holding 0x00FADE6F -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassB8_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassB9_Fwd -- event class 0xB9: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xB9]
;          is the only entry holding 0x00FADE74 -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassB9_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassBA_Fwd -- event class 0xBA: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xBA]
;          is the only entry holding 0x00FADE79 -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassBA_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassBB_Fwd -- event class 0xBB: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xBB]
;          is the only entry holding 0x00FADE7E -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassBB_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassBC_Fwd -- event class 0xBC: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xBC]
;          is the only entry holding 0x00FADE83 -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassBC_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassBD_Fwd -- event class 0xBD: hand the record straight
;                         to T_ParamChange_NotifyClearSource (T_F407CC) (prom_a 0xFAA5FE)
;
; Called from: `call XIY` at 0xFADB87; Evt2030_ClassHandlers[0xBD]
;          is the only entry holding 0x00FADE88 -- check N5.
; Body:    `call 0xf407cc / ret`, five bytes.  ELEVEN of these sit in a
;          row at 0xFADE56-0xFADE8C, one per class in {0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD},
;          all byte-identical to each other -- check N5.  They are
;          eleven labels and not one because the ROM publishes eleven
;          distinct addresses.
; Evidence: registers are untouched, so C/B/E/D reach 0xFAA5FE exactly
;          as UiEventList-style payload.
; ---------------------------------------------------------------------
Evt2030_ClassBD_Fwd:   ; entry: pointer-table entry
	call T_ParamChange_NotifyClearSource
	ret
; ---------------------------------------------------------------------
; ParamReset_SixParamsForIndex -- post six fixed parameter records for one
;                           index, through ParamChange_Notify
;
; Called from: prom_b directory slot T_ParamReset_SixParamsForIndex.  No call/jump line in any
;          of the four transcriptions names that slot, so nothing recorded
;          calls it; stated as a searched negative.
; Inputs:  A = the index, W = a source byte.
; Body:    return when A == 0x48.  W = (W & 0x0F) | 0x80, saved on the
;          stack; then six times: (0x60F007) = W, C = the parameter number,
;          B = A, DE = the fixed pair, `call 0xf407d0`.  The six parameter
;          numbers are 0xB5, 0xB7, 0xB6, 0xB1, 0xB2, 0xB4 in that order
;          and the pairs are 0x7F00 except 0xB1's 0x4000.
; Evidence: `cp A,0x48` at 0xFADE8D; `and W,0x0f` at 0xFADE92 and
;          `or W,0x80` at 0xFADE95; the six `ld C,0xbN` immediates at
;          0xFADEA0, 0xFADEB2, 0xFADEC4, 0xFADED6, 0xFADEE8 and 0xFADEFA, each
;          followed by `call 0xf407d0`.  Check C3 reads all six numbers
;          and all six pairs out of the ROM.
; Unknown:  why 0x48 is the excluded index.
; ---------------------------------------------------------------------
ParamReset_SixParamsForIndex:
	cp A,0x48
	jr z, .LFADF07
	and W,0x0f
	or W,0x80
	pushw wa
	ld WA,(XSP)
	ld (0x60f007:24), w
	ld c, 0xb5:opc
	ld B,A
	ldw de, 0x7f00
	call T_ParamChange_Notify
	ld WA,(XSP)
	ld (0x60f007:24), w
	ld c, 0xb7:opc
	ld B,A
	ldw de, 0x7f00
	call T_ParamChange_Notify
	ld WA,(XSP)
	ld (0x60f007:24), w
	ld c, 0xb6:opc
	ld B,A
	ldw de, 0x7f00
	call T_ParamChange_Notify
	ld WA,(XSP)
	ld (0x60f007:24), w
	ld c, 0xb1:opc
	ld B,A
	ldw de, 0x4000
	call T_ParamChange_Notify
	ld WA,(XSP)
	ld (0x60f007:24), w
	ld c, 0xb2:opc
	ld B,A
	ldw de, 0x7f00
	call T_ParamChange_Notify
	ld WA,(XSP)
	ld (0x60f007:24), w
	ld c, 0xb4:opc
	ld B,A
	ldw de, 0x7f00
	call T_ParamChange_Notify
	inc 2,XSP
.LFADF07:
	ret
; ---------------------------------------------------------------------
; Msg0716_AllPartsResetBendAndModulation_Call -- a five-byte veneer: `call 0xf40fd0 / ret`
;
; Called from: prom_b directory slot T_F40894.
; ★ IT KEEPS A sub_XXXXXX NAME ON PURPOSE.  It is a published entry point
;          and so it needs a label -- before this pass the twenty slots of
;          T_Evt2030_RunList-T_ParamApply_OneHotOfSix pointed at twenty addresses with no label at
;          all -- but its whole body is one call to T_Msg0716_AllPartsResetBendAndModulation, which is
;          prom_a 0xFC10DD, and that routine is `Msg0716_AllPartsResetBendAndModulation`.  A veneer
;          can be named no better than its target, so this one is not
;          named.  A stated gap beats a plausible guess.
; Evidence: `call 0xf40fd0` at 0xFADF08 and `ret` at 0xFADF0C; prom_b's
;          directory line `T_Msg0716_AllPartsResetBendAndModulation: jp 0xFC10DD`.
; Unknown:  everything 0xFC10DD does.
; ---------------------------------------------------------------------
; Msg0716_AllPartsResetBendAndModulation_Call: calls Msg0716_AllPartsResetBendAndModulation and returns -- `call T_Msg0716_AllPartsResetBendAndModulation / ret`.
Msg0716_AllPartsResetBendAndModulation_Call:
	call T_Msg0716_AllPartsResetBendAndModulation
	ret
; ---------------------------------------------------------------------
; Dev7F_WriteAllFourSlots -- call all four Dev7F_WriteSlot8 slot entries
;                           in order
;
; Called from: thirteen four-byte `calr <here> / ret` stubs inside this
;          module, at 0xFAD801, 0xFAD806, 0xFAD819, 0xFAD846, 0xFAD86C,
;          0xFAD886, 0xFAD89D, 0xFAD8B8, 0xFAD8D9, 0xFAD8FA, 0xFAD98B,
;          0xFAD9AC and 0xFAD9C7 -- one immediately after each of the
;          module's first thirteen entry points.  Check C5 re-derives that
;          list from the ROM and reports that NOTHING references any of the
;          thirteen stubs.
; Body:    `call 0xf40004 / call 0xf40008 / call 0xf4000c / call 0xf40010`
;          and `ret`, four directory slots that are
;          Dev7F_WriteSlot8_Slot0..Slot3 (prom_a 0xF83171, 0xF83179,
;          0xF83181, 0xF83189), all four already named.
; Evidence: the five instructions at 0xFADF0D-0xFADF1D.
; Unknown:  what device 0x7F is -- FINDINGS-memory-map.md already records
;          that as open, and this routine does not settle it.
; ---------------------------------------------------------------------
Dev7F_WriteAllFourSlots:
	call T_Dev7F_WriteSlot8_Slot0
	call T_Dev7F_WriteSlot8_Slot1
	call T_Dev7F_WriteSlot8_Slot2
	call T_Dev7F_WriteSlot8_Slot3
	ret
; ---------------------------------------------------------------------
; ParamApply_ByModeOfParam80 -- apply the staged record through one of
;                           four arms chosen by (0x7F32) & 3
;
; Called from: prom_b directory slot T_ParamApply_ByModeOfParam80.
; Body:    `ld (0x60f01e),0xff`.  When C != 0x98 the routine jumps to
;          0xFAE032, which dispatches on (0x7F32) & 3 through the table at
;          0xFAE04D.  When C == 0x98 it first requires (0x7F02) & 0xF0 to
;          be 0x10, then builds a byte out of (0x60F652) and dispatches on
;          (0x7F32) & 3 through the table at 0xFADF77.
; Evidence: `cp C,0x98` at 0xFADF24, `ld A,(0x7f02)` at 0xFADF2A,
;          `cp A,0x10` at 0xFADF31, `ld WA,(0x60f652)` at 0xFADF37,
;          `ld L,(0x7f32)` at 0xFADF61 and `and L,0x03` at 0xFADF65,
;          `ld XIX,0x00fadf77` at 0xFADF6B; and the same three-instruction
;          selector again at 0xFAE032-0xFAE03C with 0xFAE04D.
; ★ (0x7F32) is parameter number 0x80's record -- ParamNumber_RecordPtrs
;          entry 0x80 IS 0x7F32 -- and 0x7F02 is parameter 0x98's.
; Unknown:  ⚠ WHAT THE FOUR VALUES OF (0x7F32) & 3 MEAN IS NOT
;          ESTABLISHED.  Six separate tables in this span are indexed by
;          it (--tables lists them); bit 2 of the same byte is the
;          already-named follow-external-clock bit and prom_b 0xF6F858
;          writes the low two bits from (0x1380) before posting them as
;          {0x80, 0, value, 0x03}.  That names the PRODUCER, not the
;          meaning, and the arms keep their sub_XXXXXX names because of
;          it.
; ---------------------------------------------------------------------
ParamApply_ByModeOfParam80:
	ld (0x60f01e:24), 0xff
	cp C,0x98
	jrl nz, Dev7F_WriteAllFourSlots_Skip
	ld a, (0x7f02:16)
	and A,0xf0
	cp A,0x10
	jrl nz, ParamApply_ByModeOfParam80_JumpTable_FADF77_Nop2
	ld wa, (0x60f652:24)
	and WA,0x7f7f
	srl a, 0x04
	and A,0x07
	and W,0x03
	sll w, 0x03
	or A,W
	push_a
	and A,0x18
	cp A,0x10
	pop_a
	jr nz, .LFADF61
	bit	1, (0x08ec:16)
	jr nz, .LFADF61
	and A,0xe7
.LFADF61:
	ld l, (MidiCfg_ModeBits:16)
	and L,0x03
	sll l, 0x02
	ld XIX,ParamApply_ByModeOfParam80_JumpTable_FADF77
	ld	xix, (xix+l)
	jp (xix)
; --- 0xFADF77-0xFADF87  pointer table (16 bytes) ---
ParamApply_ByModeOfParam80_JumpTable_FADF77:
	.long ParamApply_Param98Normal   ; -> ParamApply_Param98Normal   ; FADF77
	.long ParamApply_Param98Tech   ; -> ParamApply_Param98Tech   ; FADF7B
	.long ParamApply_ByModeOfParam80_JumpTable_FADF77_Nop2   ; -> ParamApply_ByModeOfParam80_JumpTable_FADF77_Nop2   ; FADF7F
	.long ParamApply_ByModeOfParam80_JumpTable_FADF77_Nop2   ; -> ParamApply_ByModeOfParam80_JumpTable_FADF77_Nop2   ; FADF83
; ParamApply_Param98Normal -- PROG CHANGE MODE NORMAL arm of ParamApply_ByModeOfParam80 for C == 0x98: store the packed value into record 0x7F02's bytes +6..+8, map it through T_CombiSel_ToNumberAndBank, and write+publish {0x98,2,..,0x3F} and {0x98,1,..,0x7F}
; Evidence: arm 0 of the 4-entry table at 0xFADF77 -- the LE32 word at 0xFADF77 reads 0x00FADF87; reader `ld XIX,0x00fadf77` at 0xFADF6B, index (0x7F32) & 3 = PROG CHANGE MODE (DLTable_NormalTechRemap[0] = "NORMAL").
; Body: (0x7F0A)=(0x60F013)=A, (0x7F09)=(0x60F011)=E&7, (0x7F08)=(0x60F010)=E>>3, (0x60F012)=0x98; call T_CombiSel_ToNumberAndBank (CombiSel_ToNumberAndBank); T_ParamRecord_WriteFieldAndStage + T_Queue2C00_PublishStagedIfPending with (0x60F015)/0x3F and (0x60F014)/0x7F; falls into the shared `ret` 0xFAE02D.
ParamApply_Param98Normal:   ; entry: pointer-table entry
	ld XIX,0x00007f02
	ld XIY,SoundConv_Arg0
	ld (XIX+0x08),A
	ld (XIY+0x03),A
	ld A,E
	and A,0x07
	ld (XIX+0x07),A
	ld (XIY+0x01),A
	srl e, 0x03
	ld (XIX+0x06),E
	ld	(xiy+0:8), e
	ld (XIY+0x02),0x98
	call T_CombiSel_ToNumberAndBank
	ldw bc, 0x0298
	ld e, (SoundConv_Result1:24)
	ld d, 0x3f:opc
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
	ldw bc, 0x0198
	ld e, (SoundConv_Result0:24)
	ld d, 0x7f:opc
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
	jr .LFAE02D
; ParamApply_Param98Tech -- PROG CHANGE MODE TECH arm of ParamApply_ByModeOfParam80 for C == 0x98: write+publish {0x98,2,A,0x3F} and the MIDI-in record (0x1950), map through T_CombiSel_FromNumberAndBank and copy the result to 0x7F08..0x7F0A
; Evidence: arm 1 of the 4-entry table at 0xFADF77 -- the LE32 word at 0xFADF7B reads 0x00FADFD9; reader `ld XIX,0x00fadf77` at 0xFADF6B, index (0x7F32) & 3 (DLTable_NormalTechRemap[1] = "TECH").
; Body: `ldw BC,0x0298` + T_ParamRecord_WriteFieldAndStage/T_Queue2C00_PublishStagedIfPending; again with BC/DE = (0x1950)/(0x1952); (0x60F010)=(0x1952), (0x60F011)=E, (0x60F012)=0x98, `call T_CombiSel_FromNumberAndBank` (CombiSel_FromNumberAndBank); (0x60F014..16) -> (0x7F08..0x7F0A).
ParamApply_Param98Tech:   ; entry: pointer-table entry
	ldw bc, 0x0298
	ld E,A
	ld d, 0x3f:opc
	pushw de
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
	popw de
	ld a, (0x1952:16)
	ld (SoundConv_Arg0:24), a
	ld (SoundConv_Arg1:24), e
	ld (SoundConv_Arg2:24), 0x98
	call T_CombiSel_FromNumberAndBank
	ld a, (SoundConv_Result0:24)
	ld (0x7f08:16), a
	ld a, (SoundConv_Result1:24)
	ld (0x7f09:16), a
	ld a, (SoundConv_Result2:24)
	ld (0x7f0a:16), a
.LFAE02D:
; ---------------------------------------------------------------------
; ParamApply_ByModeOfParam80_JumpTable_FADF77_Nop2 -- arm 2, 3 of the 4-entry jump table at 0xFADF77
;
; Called from: the reader `ld XIX,0x00fadf77` at 0xFADF6B, through XIX/XIY.
;          Index: (0x7F32) & 3.
; Owner:   ParamApply_ByModeOfParam80.
; Body:    starts `ret`.
; Evidence: the LE32 words at 0xFADF7F, 0xFADF83 reads 0x00FAE02D, and no other
;          entry of that table does.
; Unknown:  ⚠ WHAT THE FOUR VALUES OF (0x7F32) & 3 SELECT.
;          SIX tables in this span are indexed by that same
;          2-bit field; prom_b 0xF6F858 copies it from
;          (0x1380) & 3 and posts it as {0x80, 0, v, 0x03}.
;          That names the producer, not the meaning, so this
;          label stays sub_XXXXXX.  A stated gap beats a
;          plausible guess.
; ---------------------------------------------------------------------
ParamApply_ByModeOfParam80_JumpTable_FADF77_Nop2:   ; entry: pointer-table entry
	ret
	calr Dev7F_WriteAllFourSlots
	ret
Dev7F_WriteAllFourSlots_Skip:
	ld l, (MidiCfg_ModeBits:16)
	and L,0x03
	sla l, 0x02
	ld XIX,Dev7F_WriteAllFourSlots_Skip_JumpTable_FAE04D
	ld	xix, (xix+l)
	call (xix)
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; --- 0xFAE04D-0xFAE05D  pointer table (16 bytes) ---
Dev7F_WriteAllFourSlots_Skip_JumpTable_FAE04D:
	.long ParamApply_PartProgNormal   ; -> ParamApply_PartProgNormal   ; FAE04D
	.long ParamApply_PartProgTech   ; -> ParamApply_PartProgTech   ; FAE051
	.long Dev7F_WriteAllFourSlots_Skip_JumpTable_FAE04D_Nop2   ; -> Dev7F_WriteAllFourSlots_Skip_JumpTable_FAE04D_Nop2   ; FAE055
	.long ParamApply_PartProgMode3   ; -> ParamApply_PartProgMode3   ; FAE059
; ParamApply_PartProgNormal -- PROG CHANGE MODE NORMAL arm of ParamApply_ByModeOfParam80 for a part: apply the program in the MIDI-in record (0x1950) to part C's record and publish class 1 and class 0
; Evidence: arm 0 of the 4-entry table at 0xFAE04D -- the LE32 word at 0xFAE04D reads 0x00FAE05D; reader `ld XIX,0x00fae04d` at 0xFAE03C, index (0x7F32) & 3 = PROG CHANGE MODE (DLTable_NormalTechRemap[0] = "NORMAL").
; Body: with GM mode on (bit 2 of (0x7F4D)) parts 9 and 0x19 take the TECH arm; else W = (0x60F570)[C], L = (E&0x7F)>>3, H = E&7 stored at second-half +0x1B/+0x1C/+0x1D, T_SoundSel_ClampToProgramAndBankRegs, rec[0] = L, rec[1] = H, publish {C,1,H,0x7F} and {C,0,L,0xFF}.
ParamApply_PartProgNormal:   ; entry: pointer-table entry
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	bit	2, (0x7f4d:16)
	jr z, .LFAE077
	cp C,0x09
	jrl z, .LFAE0FC
	cp C,0x19
	jrl z, .LFAE0FC
.LFAE077:
	xor H,H
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	cp XIX,0xffffffff
	jr z, .LFAE0FB
	xor H,H
	ld L,C
	ld (0x60f01c:24), c
	ld XIY,0x0060f570
	ld	w, (xiy+hl)
	ld L,E
	ld H,L
	res 0x07,L
	srl l, 0x03
	and H,0x07
	ld XIY,XIX
	add XIY,0x00000020
	ld (XIY+0x1b),L
	ld (XIY+0x1c),H
	ld (XIY+0x1d),W
	call T_SoundSel_ClampToProgramAndBankRegs
	ld	(xix+0:8), l
	ld (XIX+0x01),H
	ld a, (0x1950:16)
	ld w, 0x01:opc
	ld (0x60f080:24), wa
	ld A,H
	ld w, 0x7f:opc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
	ld a, (0x1950:16)
	ld w, 0x00:opc
	ld (0x60f080:24), wa
	ld A,L
	ld w, 0xff:opc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
.LFAE0FB:
	ret
.LFAE0FC:
; ParamApply_PartProgTech -- PROG CHANGE MODE TECH arm of ParamApply_ByModeOfParam80 for a part: write the received program byte and bank byte straight into part C's record and publish class 1 and class 0
; Evidence: arm 1 of the 4-entry table at 0xFAE04D -- the LE32 word at 0xFAE051 reads 0x00FAE0FC; reader `ld XIX,0x00fae04d` at 0xFAE03C, index (0x7F32) & 3 (DLTable_NormalTechRemap[1] = "TECH").
; Body: BC/DE = (0x1950)/(0x1952); bit 7 of D moves to E; rec[0] = E, rec[1] = (rec[1]&0x80)|D; T_SoundSel_FromProgramAndBankRegs then second-half +0x1B..+0x1D; publish {C,1,D,0x7F} and {C,0,E,0xFF}.  Also the GM drum-part branch target of ParamApply_PartProgNormal.
ParamApply_PartProgTech:   ; entry: pointer-table entry
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	ld (0x60f01d:24), c
	extz HL
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	cp XIX,0xffffffff
	jr z, .LFAE187
	extz HL
	ld L,C
	ld XIY,0x0060f570
	ld	d, (xiy+hl)
	bit 0x07,D
	jr z, .LFAE13B
	res 0x07,D
	set 0x07,E
.LFAE13B:
	ld (XIX),E
	and (XIX+0x01),0x80
	or (XIX+0x01),D
	ld L,E
	ld H,D
	call T_SoundSel_FromProgramAndBankRegs
	add XIX,0x00000020
	ld (XIX+0x1b),L
	ld (XIX+0x1c),H
	ld (XIX+0x1d),W
	ld A,C
	ld w, 0x01:opc
	ld (0x60f080:24), wa
	ld A,D
	ld w, 0x7f:opc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
	ld A,C
	ld w, 0x00:opc
	ld (0x60f080:24), wa
	ld A,E
	ld w, 0xff:opc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
.LFAE187:
	ret
; ---------------------------------------------------------------------
; Dev7F_WriteAllFourSlots_Skip_JumpTable_FAE04D_Nop2 -- arm 2 of the 4-entry jump table at 0xFAE04D
;
; Called from: the reader `ld XIX,0x00fae04d` at 0xFAE03C, through XIX/XIY.
;          Index: (0x7F32) & 3.
; Owner:   the tail of ParamApply_ByModeOfParam80.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAE055 reads 0x00FAE188, and no other
;          entry of that table does.
; Unknown:  ⚠ WHAT THE FOUR VALUES OF (0x7F32) & 3 SELECT.
;          SIX tables in this span are indexed by that same
;          2-bit field; prom_b 0xF6F858 copies it from
;          (0x1380) & 3 and posts it as {0x80, 0, v, 0x03}.
;          That names the producer, not the meaning, so this
;          label stays sub_XXXXXX.  A stated gap beats a
;          plausible guess.
; ---------------------------------------------------------------------
Dev7F_WriteAllFourSlots_Skip_JumpTable_FAE04D_Nop2:   ; entry: pointer-table entry
	ret
; ParamApply_PartProgMode3 -- PROG CHANGE MODE value 3 (no caption) of ParamApply_ByModeOfParam80 for a part: map the stored bank pair through T_PartSound_FromProgramChange and apply the result as part C's program
; Evidence: arm 3 of the 4-entry table at 0xFAE04D -- the LE32 word at 0xFAE059 reads 0x00FAE189; reader `ld XIX,0x00fae04d` at 0xFAE03C, index (0x7F32) & 3; DLTable_NormalTechRemap has no entry 3.
; Body: (0x60F010) = (0x60F530)[2*C], (0x60F012) = DE, `call T_PartSound_FromProgramChange` (PartSound_FromProgramChange), (0x60F014..15) -> rec[0]/rec[1], T_SoundSel_FromProgramAndBankRegs then second-half +0x1B..+0x1D, publish {C,1,D,0x7F} and {C,0,E,0xFF}.
ParamApply_PartProgMode3:   ; entry: pointer-table entry
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	xor H,H
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	cp XIX,0xffffffff
	jr z, .LFAE222
	xor H,H
	ld L,C
	ld D,C
	sll l, 0x01
	ld XIY,0x0060f530
	ld	wa, (xiy+hl)
	ld (SoundConv_Arg0:24), wa
	ld (SoundConv_Arg2:24), de
	call T_PartSound_FromProgramChange
	ld de, (SoundConv_Result0:24)
	ld	(xix+0:8), e
	ld (XIX+0x01),D
	ld (0x60f01d:24), c
	ld L,E
	ld H,D
	call T_SoundSel_FromProgramAndBankRegs
	add XIX,0x00000020
	ld (XIX+0x1b),L
	ld (XIX+0x1c),H
	ld (XIX+0x1d),W
	ld a, (0x1950:16)
	ld w, 0x01:opc
	ld (0x60f080:24), wa
	ld A,D
	ld w, 0x7f:opc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
	ld a, (0x1950:16)
	ld w, 0x00:opc
	ld (0x60f080:24), wa
	ld A,E
	ld w, 0xff:opc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
.LFAE222:
	ret
; ---------------------------------------------------------------------
; ParamApply_StorePairAndDerive -- store the staged value in a 16-bit
;                           table, then derive a byte from it by mode
;
; Called from: prom_b directory slot T_ParamApply_StorePairAndDerive.
; Body:    BC = (0x1950), DE = (0x1952); XIX = 0x60F530, XIZ = 0x60F570,
;          HL = 2*C -- or, when C == 0x98, XIX = 0x60F652, XIZ = 0x60F654,
;          HL = 0.  Store E at (XIX+HL) when E != 0xFF, otherwise D at
;          (XIX+HL+1), each with bit 7 cleared; mask the 16-bit pair with
;          0x7F7F; then dispatch on (0x7F32) & 3 through the table at
;          0xFAE28F and store the resulting A at (XIZ + C).
; Evidence: `ld XIX,0x0060f530` at 0xFAE22B, `ld XIZ,0x0060f570` at
;          0xFAE230, `cp C,0x98` at 0xFAE23C, `ld XIX,0x0060f652` at
;          0xFAE241, `cp E,0xff` at 0xFAE24D, `and WA,0x7f7f` at 0xFAE26D,
;          `ld B,(0x7f32)` at 0xFAE279 and `and B,0x03` at 0xFAE27D,
;          `ld XIY,0x00fae28f` at 0xFAE283, `ld (XIZ+HL),A` at 0xFAE2D8.
; Unknown:  what 0x60F530 and 0x60F570 hold, and what the four arms
;          compute.  The arms keep their sub_XXXXXX names.
; ---------------------------------------------------------------------
ParamApply_StorePairAndDerive:
	ld bc, (0x1950:16)
	ld de, (0x1952:16)
	ld XIX,0x0060f530
	ld XIZ,0x0060f570
	xor H,H
	ld L,C
	sll l, 0x01
	cp C,0x98
	jr nz, .LFAE24D
	ld XIX,0x0060f652
	ld XIZ,0x0060f654
	xor HL,HL
.LFAE24D:
	cp E,0xff
	jr z, .LFAE25C
	res 0x07,E
	ld	(xix+hl), e
	jr .LFAE268
.LFAE25C:
	res 0x07,D
	inc 1,XIX
	ld	(xix+hl), d
	dec 1,XIX
.LFAE268:
	ld	wa, (xix+hl)
	and WA,0x7f7f
	ld	(xix+hl), wa
	srl l, 0x01
	ld b, (MidiCfg_ModeBits:16)
	and B,0x03
	sll b, 0x02
	ld XIY,ParamApply_StorePairAndDerive_JumpTable_FAE28F
	ld	xiy, (xiy+b)
	jp (xiy)
; --- 0xFAE28F-0xFAE29F  pointer table (16 bytes) ---
ParamApply_StorePairAndDerive_JumpTable_FAE28F:
	.long ParamApply_DeriveNormal   ; -> ParamApply_DeriveNormal   ; FAE28F
	.long ParamApply_DeriveTech   ; -> ParamApply_DeriveTech   ; FAE293
	.long ParamApply_DeriveRemap   ; -> ParamApply_DeriveRemap   ; FAE297
	.long ParamApply_DeriveMode3   ; -> ParamApply_DeriveMode3   ; FAE29B
; ParamApply_DeriveNormal -- PROG CHANGE MODE NORMAL arm of ParamApply_StorePairAndDerive: derive the stored byte from the 7F7F pair as ((A>>4)&7)|(W<<3), W&7 with 7 -> 4
; Evidence: arm 0 of the 4-entry table at 0xFAE28F -- the LE32 word at 0xFAE28F reads 0x00FAE29F; reader `ld XIY,0x00fae28f` at 0xFAE283, index (0x7F32) & 3 = PROG CHANGE MODE (DLTable_NormalTechRemap[0]).
; Body: `jr 0xFAE2AA`, i.e. into ParamApply_DeriveTech past its W 3 -> 0 step; result stored at (XIZ+C) (0x60F570, or 0x60F654 for C == 0x98).
ParamApply_DeriveNormal:   ; entry: pointer-table entry
	jr .LFAE2AA
; ParamApply_DeriveTech -- PROG CHANGE MODE TECH arm of ParamApply_StorePairAndDerive: derive the stored byte from the pair as ((A>>4)&7)|(W<<3), with W&7 mapped 3 -> 0 and 7 -> 4
; Evidence: arm 1 of the 4-entry table at 0xFAE28F -- the LE32 word at 0xFAE293 reads 0x00FAE2A1; reader `ld XIY,0x00fae28f` at 0xFAE283, index (0x7F32) & 3 (DLTable_NormalTechRemap[1]).
; Body: `cp W,3 / xor W,W`, `cp W,7 / ld W,4`, pack, clear bits 3-4 when they read 0x10 and bit 0 of (0x08EC) is clear; stored at (XIZ+C) by the shared tail 0xFAE2D8.
ParamApply_DeriveTech:   ; entry: pointer-table entry
	and W,0x07
	cp w, 0x03:i3
	jr nz, .LFAE2AA
	xor W,W
.LFAE2AA:
	and W,0x07
	cp w, 0x07:i3
	jr nz, .LFAE2B3
	ld w, 0x04:opc
.LFAE2B3:
	srl a, 0x04
	and A,0x07
	sll w, 0x03
	or A,W
	push_a
	and A,0x18
	cp A,0x10
	pop_a
	jr nz, .LFAE2D1
	bit	0, (0x08ec:16)
	jr nz, .LFAE2D1
	and A,0xe7
.LFAE2D1:
	jr .LFAE2D8
; ParamApply_DeriveRemap -- PROG CHANGE MODE REMAP arm of ParamApply_StorePairAndDerive: store the pair's low byte A unchanged
; Evidence: arm 2 of the 4-entry table at 0xFAE28F -- the LE32 word at 0xFAE297 reads 0x00FAE2D3; reader `ld XIY,0x00fae28f` at 0xFAE283, index (0x7F32) & 3, DLTable_NormalTechRemap[2] = "REMAP".  Body: `jr 0xFAE2D8`, the shared `ld (XIZ+HL),A`.
ParamApply_DeriveRemap:   ; entry: pointer-table entry
	jr .LFAE2D8
; ParamApply_DeriveMode3 -- PROG CHANGE MODE value 3 (no caption) of ParamApply_StorePairAndDerive: store the pair's high byte W
; Evidence: arm 3 of the 4-entry table at 0xFAE28F -- the LE32 word at 0xFAE29B reads 0x00FAE2D5; reader `ld XIY,0x00fae28f` at 0xFAE283, index (0x7F32) & 3.  Body: `srl 0x08,WA` then the shared `ld (XIZ+HL),A` at 0xFAE2D8.
ParamApply_DeriveMode3:   ; entry: pointer-table entry
	srl wa, 0x08
.LFAE2D8:
	ld	(xiz+hl), a
	ret
	calr Dev7F_WriteAllFourSlots
	ret
; ---------------------------------------------------------------------
; Evt2030_Class00to1F_Op00 -- operation 0x00 of event classes 0x00-0x1F
;
; Called from: `jp XIX` at 0xFADBA7; the table at 0x00FADBA9 holds
;          0x00FAE2E2 at index 0 and nowhere else -- check N2.
; ---------------------------------------------------------------------
Evt2030_Class00to1F_Op00:   ; entry: pointer-table entry
	inc 0x01, (0x1965:16)
	bit	0, (0x1965:16)
	jr z, .LFAE2F7
	ld wa, (0x60f0be:24)
	ld (0x1966:16), wa
	jr .LFAE30D
.LFAE2F7:
	ld l, (MidiCfg_ModeBits:16)
	and L,0x03
	sll l, 0x02
	ld XIX,sub_FAE30D_JumpTable_FAE30E
	ld	xix, (xix+l)
	jp (xix)
.LFAE30D:
; ---------------------------------------------------------------------
; sub_FAE30D_JumpTable_FAE30E_Nop2 -- arm 2 of the 4-entry jump table at 0xFAE30E
;
; Called from: the reader `ld XIX,0x00fae30e` at 0xFAE301, through XIX/XIY.
;          Index: (0x7F32) & 3.
; Owner:   Evt2030_Class00to1F_Op00.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAE316 reads 0x00FAE30D, and no other
;          entry of that table does.
; Unknown:  ⚠ WHAT THE FOUR VALUES OF (0x7F32) & 3 SELECT.
;          SIX tables in this span are indexed by that same
;          2-bit field; prom_b 0xF6F858 copies it from
;          (0x1380) & 3 and posts it as {0x80, 0, v, 0x03}.
;          That names the producer, not the meaning, so this
;          label stays sub_XXXXXX.  A stated gap beats a
;          plausible guess.
; ---------------------------------------------------------------------
sub_FAE30D_JumpTable_FAE30E_Nop2:   ; entry: pointer-table entry
	ret
; --- 0xFAE30E-0xFAE31E  pointer table (16 bytes) ---
sub_FAE30D_JumpTable_FAE30E:
	.long Evt2030_ProgChgNormal_Notify   ; -> Evt2030_ProgChgNormal_Notify   ; FAE30E
	.long Evt2030_ProgChgTech_Notify   ; -> Evt2030_ProgChgTech_Notify   ; FAE312
	.long sub_FAE30D_JumpTable_FAE30E_Nop2   ; -> sub_FAE30D_JumpTable_FAE30E_Nop2   ; FAE316
	.long Evt2030_ProgChgMode3_Notify   ; -> Evt2030_ProgChgMode3_Notify   ; FAE31A
; Evt2030_ProgChgNormal_Notify -- PROG CHANGE MODE NORMAL arm of Evt2030_Class00to1F_Op00: notify bank select (param 0x81) and program (class 0) from the part's second-half bytes +0x1B..+0x1D
; Evidence: arm 0 of the 4-entry table at 0xFAE30E -- the LE32 word at 0xFAE30E reads 0x00FAE31E; reader `ld XIX,0x00fae30e` at 0xFAE301, index (0x7F32) & 3, and DLTable_NormalTechRemap[0] is "NORMAL" (see Evt2030_ProgChgMode3_Notify).
; Body: with GM mode on (bit 2 of (0x7F4D), notes/sysex-probes/sysex_general_midi.py) parts 9 and 0x19 take the TECH arm; else XIX = ParamNumber_RecordPtrs[C|0x20], notify {0x81, part, (XIX+0x1D) split into two 7-bit halves} and {part, 0, ((XIX+0x1B)<<3)|((XIX+0x1C)&7), 0xFF} -- the bytes ParamApply_PartProgNormal stores.
Evt2030_ProgChgNormal_Notify:   ; entry: pointer-table entry
	bit	2, (0x7f4d:16)
	jr z, .LFAE32E
	cp C,0x09
	jr z, .LFAE36C
	cp C,0x19
	jr z, .LFAE36C
.LFAE32E:
	extz HL
	ld L,C
	or L,0x20
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	pushw bc
	xor D,D
	ld E,(XIX+0x1d)
	sll de, 0x05
	srl e, 0x01
	ld B,C
	ld c, 0x81:opc
	call T_ParamChange_NotifyClearSource
	popw bc
	ld E,(XIX+0x1c)
	and E,0x07
	ld D,(XIX+0x1b)
	sll d, 0x03
	or E,D
	ld d, 0xff:opc
	call T_ParamChange_NotifyClearSource
	ret
.LFAE36C:
; Evt2030_ProgChgTech_Notify -- PROG CHANGE MODE TECH arm of Evt2030_Class00to1F_Op00: notify bank select (param 0x81) from record byte 1 and program (class 0) from record byte 0
; Evidence: arm 1 of the 4-entry table at 0xFAE30E -- the LE32 word at 0xFAE312 reads 0x00FAE36C; reader `ld XIX,0x00fae30e` at 0xFAE301, index (0x7F32) & 3; DLTable_NormalTechRemap[1] is "TECH".
; Body: XIX = ParamNumber_RecordPtrs[C]; notify {0x81, part, (XIX+1)&0x3F split} and {part, 0, (XIX)&0x7F, 0xFF}.  Also the target of Evt2030_ProgChgNormal_Notify's GM drum-part branch.
Evt2030_ProgChgTech_Notify:   ; entry: pointer-table entry
	extz HL
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	pushw bc
	extz DE
	ld E,(XIX+0x01)
	and E,0x3f
	sll de, 0x05
	srl e, 0x01
	ld B,C
	ld c, 0x81:opc
	call T_ParamChange_NotifyClearSource
	popw bc
	ld E,(XIX)
	res 0x07,E
	ld d, 0xff:opc
	call T_ParamChange_NotifyClearSource
	ret
; --- 0xFAE3A1-0xFAE3A2  align (1 bytes) ---
	.byte 0x00   ; FAE3A1
;
; Evt2030_ClassHandlers -- 192 LE32 words: the handler for each parameter
;                           number 0x00-0xBF, or 0xFFFFFFFF for none
;
; ★ THIS NAME WAS ALREADY IN THE TREE -- thirteen routine headers in this
;          module cite `Evt2030_ClassHandlers` -- but the table itself had
;          no label, so every citation pointed at a name that did not
;          exist.  This adds the label the prose already assumed.
; Read by: Evt2030_RunList, `ld XIY,0x00fae3a2` at 0xFADB5F, its only
;          reader (the table's address appears as a 32-bit little-endian
;          word at exactly one place in prom_a).
; Layout:  15 distinct values.  All 32 entries 0x00-0x1F hold
;          Evt2030_Class00to1F; all 32 entries 0x20-0x3F hold
;          Evt2030_Class20to3F; 0x98 holds Evt2030_Class98; eleven single
;          entries hold the eleven five-byte forwarders at
;          0xFADE56-0xFADE8C; the other 116 are 0xFFFFFFFF.
; ★ Evidence, against ParamNumber_RecordPtrs and re-derived by check C6:
;          76 parameter numbers have a handler and 77 have a record; 65
;          have both; the eleven with a handler and NO record are exactly
;          0xB1-0xB5, 0xB8-0xBD, i.e. exactly the eleven forwarders.  Two
;          tables derived from different parts of the ROM agreeing on an
;          eleven-element set is what makes both of them readable.
; --- 0xFAE3A2-0xFAE6A2  pointer table (768 bytes) ---
Evt2030_ClassHandlers:
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3A2
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3A6
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3AA
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3AE
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3B2
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3B6
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3BA
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3BE
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3C2
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3C6
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3CA
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3CE
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3D2
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3D6
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3DA
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3DE
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3E2
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3E6
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3EA
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3EE
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3F2
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3F6
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3FA
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE3FE
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE402
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE406
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE40A
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE40E
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE412
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE416
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE41A
	.long Evt2030_Class00to1F ; -> Evt2030_Class00to1F   ; FAE41E
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE422
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE426
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE42A
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE42E
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE432
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE436
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE43A
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE43E
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE442
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE446
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE44A
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE44E
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE452
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE456
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE45A
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE45E
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE462
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE466
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE46A
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE46E
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE472
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE476
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE47A
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE47E
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE482
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE486
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE48A
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE48E
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE492
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE496
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE49A
	.long Evt2030_Class20to3F ; -> Evt2030_Class20to3F   ; FAE49E
	.long 0xFFFFFFFF   ; empty slot   ; FAE4A2
	.long 0xFFFFFFFF   ; empty slot   ; FAE4A6
	.long 0xFFFFFFFF   ; empty slot   ; FAE4AA
	.long 0xFFFFFFFF   ; empty slot   ; FAE4AE
	.long 0xFFFFFFFF   ; empty slot   ; FAE4B2
	.long 0xFFFFFFFF   ; empty slot   ; FAE4B6
	.long 0xFFFFFFFF   ; empty slot   ; FAE4BA
	.long 0xFFFFFFFF   ; empty slot   ; FAE4BE
	.long 0xFFFFFFFF   ; empty slot   ; FAE4C2
	.long 0xFFFFFFFF   ; empty slot   ; FAE4C6
	.long 0xFFFFFFFF   ; empty slot   ; FAE4CA
	.long 0xFFFFFFFF   ; empty slot   ; FAE4CE
	.long 0xFFFFFFFF   ; empty slot   ; FAE4D2
	.long 0xFFFFFFFF   ; empty slot   ; FAE4D6
	.long 0xFFFFFFFF   ; empty slot   ; FAE4DA
	.long 0xFFFFFFFF   ; empty slot   ; FAE4DE
	.long 0xFFFFFFFF   ; empty slot   ; FAE4E2
	.long 0xFFFFFFFF   ; empty slot   ; FAE4E6
	.long 0xFFFFFFFF   ; empty slot   ; FAE4EA
	.long 0xFFFFFFFF   ; empty slot   ; FAE4EE
	.long 0xFFFFFFFF   ; empty slot   ; FAE4F2
	.long 0xFFFFFFFF   ; empty slot   ; FAE4F6
	.long 0xFFFFFFFF   ; empty slot   ; FAE4FA
	.long 0xFFFFFFFF   ; empty slot   ; FAE4FE
	.long 0xFFFFFFFF   ; empty slot   ; FAE502
	.long 0xFFFFFFFF   ; empty slot   ; FAE506
	.long 0xFFFFFFFF   ; empty slot   ; FAE50A
	.long 0xFFFFFFFF   ; empty slot   ; FAE50E
	.long 0xFFFFFFFF   ; empty slot   ; FAE512
	.long 0xFFFFFFFF   ; empty slot   ; FAE516
	.long 0xFFFFFFFF   ; empty slot   ; FAE51A
	.long 0xFFFFFFFF   ; empty slot   ; FAE51E
	.long 0xFFFFFFFF   ; empty slot   ; FAE522
	.long 0xFFFFFFFF   ; empty slot   ; FAE526
	.long 0xFFFFFFFF   ; empty slot   ; FAE52A
	.long 0xFFFFFFFF   ; empty slot   ; FAE52E
	.long 0xFFFFFFFF   ; empty slot   ; FAE532
	.long 0xFFFFFFFF   ; empty slot   ; FAE536
	.long 0xFFFFFFFF   ; empty slot   ; FAE53A
	.long 0xFFFFFFFF   ; empty slot   ; FAE53E
	.long 0xFFFFFFFF   ; empty slot   ; FAE542
	.long 0xFFFFFFFF   ; empty slot   ; FAE546
	.long 0xFFFFFFFF   ; empty slot   ; FAE54A
	.long 0xFFFFFFFF   ; empty slot   ; FAE54E
	.long 0xFFFFFFFF   ; empty slot   ; FAE552
	.long 0xFFFFFFFF   ; empty slot   ; FAE556
	.long 0xFFFFFFFF   ; empty slot   ; FAE55A
	.long 0xFFFFFFFF   ; empty slot   ; FAE55E
	.long 0xFFFFFFFF   ; empty slot   ; FAE562
	.long 0xFFFFFFFF   ; empty slot   ; FAE566
	.long 0xFFFFFFFF   ; empty slot   ; FAE56A
	.long 0xFFFFFFFF   ; empty slot   ; FAE56E
	.long 0xFFFFFFFF   ; empty slot   ; FAE572
	.long 0xFFFFFFFF   ; empty slot   ; FAE576
	.long 0xFFFFFFFF   ; empty slot   ; FAE57A
	.long 0xFFFFFFFF   ; empty slot   ; FAE57E
	.long 0xFFFFFFFF   ; empty slot   ; FAE582
	.long 0xFFFFFFFF   ; empty slot   ; FAE586
	.long 0xFFFFFFFF   ; empty slot   ; FAE58A
	.long 0xFFFFFFFF   ; empty slot   ; FAE58E
	.long 0xFFFFFFFF   ; empty slot   ; FAE592
	.long 0xFFFFFFFF   ; empty slot   ; FAE596
	.long 0xFFFFFFFF   ; empty slot   ; FAE59A
	.long 0xFFFFFFFF   ; empty slot   ; FAE59E
	.long 0xFFFFFFFF   ; empty slot   ; FAE5A2
	.long 0xFFFFFFFF   ; empty slot   ; FAE5A6
	.long 0xFFFFFFFF   ; empty slot   ; FAE5AA
	.long 0xFFFFFFFF   ; empty slot   ; FAE5AE
	.long 0xFFFFFFFF   ; empty slot   ; FAE5B2
	.long 0xFFFFFFFF   ; empty slot   ; FAE5B6
	.long 0xFFFFFFFF   ; empty slot   ; FAE5BA
	.long 0xFFFFFFFF   ; empty slot   ; FAE5BE
	.long 0xFFFFFFFF   ; empty slot   ; FAE5C2
	.long 0xFFFFFFFF   ; empty slot   ; FAE5C6
	.long 0xFFFFFFFF   ; empty slot   ; FAE5CA
	.long 0xFFFFFFFF   ; empty slot   ; FAE5CE
	.long 0xFFFFFFFF   ; empty slot   ; FAE5D2
	.long 0xFFFFFFFF   ; empty slot   ; FAE5D6
	.long 0xFFFFFFFF   ; empty slot   ; FAE5DA
	.long 0xFFFFFFFF   ; empty slot   ; FAE5DE
	.long 0xFFFFFFFF   ; empty slot   ; FAE5E2
	.long 0xFFFFFFFF   ; empty slot   ; FAE5E6
	.long 0xFFFFFFFF   ; empty slot   ; FAE5EA
	.long 0xFFFFFFFF   ; empty slot   ; FAE5EE
	.long 0xFFFFFFFF   ; empty slot   ; FAE5F2
	.long 0xFFFFFFFF   ; empty slot   ; FAE5F6
	.long 0xFFFFFFFF   ; empty slot   ; FAE5FA
	.long 0xFFFFFFFF   ; empty slot   ; FAE5FE
	.long Evt2030_Class98 ; -> Evt2030_Class98   ; FAE602
	.long 0xFFFFFFFF   ; empty slot   ; FAE606
	.long 0xFFFFFFFF   ; empty slot   ; FAE60A
	.long 0xFFFFFFFF   ; empty slot   ; FAE60E
	.long 0xFFFFFFFF   ; empty slot   ; FAE612
	.long 0xFFFFFFFF   ; empty slot   ; FAE616
	.long 0xFFFFFFFF   ; empty slot   ; FAE61A
	.long 0xFFFFFFFF   ; empty slot   ; FAE61E
	.long 0xFFFFFFFF   ; empty slot   ; FAE622
	.long 0xFFFFFFFF   ; empty slot   ; FAE626
	.long 0xFFFFFFFF   ; empty slot   ; FAE62A
	.long 0xFFFFFFFF   ; empty slot   ; FAE62E
	.long 0xFFFFFFFF   ; empty slot   ; FAE632
	.long 0xFFFFFFFF   ; empty slot   ; FAE636
	.long 0xFFFFFFFF   ; empty slot   ; FAE63A
	.long 0xFFFFFFFF   ; empty slot   ; FAE63E
	.long 0xFFFFFFFF   ; empty slot   ; FAE642
	.long 0xFFFFFFFF   ; empty slot   ; FAE646
	.long 0xFFFFFFFF   ; empty slot   ; FAE64A
	.long 0xFFFFFFFF   ; empty slot   ; FAE64E
	.long 0xFFFFFFFF   ; empty slot   ; FAE652
	.long 0xFFFFFFFF   ; empty slot   ; FAE656
	.long 0xFFFFFFFF   ; empty slot   ; FAE65A
	.long 0xFFFFFFFF   ; empty slot   ; FAE65E
	.long 0xFFFFFFFF   ; empty slot   ; FAE662
	.long Evt2030_ClassB1_Fwd ; -> Evt2030_ClassB1_Fwd   ; FAE666
	.long Evt2030_ClassB2_Fwd ; -> Evt2030_ClassB2_Fwd   ; FAE66A
	.long Evt2030_ClassB3_Fwd ; -> Evt2030_ClassB3_Fwd   ; FAE66E
	.long Evt2030_ClassB4_Fwd ; -> Evt2030_ClassB4_Fwd   ; FAE672
	.long Evt2030_ClassB5_Fwd ; -> Evt2030_ClassB5_Fwd   ; FAE676
	.long 0xFFFFFFFF   ; empty slot   ; FAE67A
	.long 0xFFFFFFFF   ; empty slot   ; FAE67E
	.long Evt2030_ClassB8_Fwd ; -> Evt2030_ClassB8_Fwd   ; FAE682
	.long Evt2030_ClassB9_Fwd ; -> Evt2030_ClassB9_Fwd   ; FAE686
	.long Evt2030_ClassBA_Fwd ; -> Evt2030_ClassBA_Fwd   ; FAE68A
	.long Evt2030_ClassBB_Fwd ; -> Evt2030_ClassBB_Fwd   ; FAE68E
	.long Evt2030_ClassBC_Fwd ; -> Evt2030_ClassBC_Fwd   ; FAE692
	.long Evt2030_ClassBD_Fwd ; -> Evt2030_ClassBD_Fwd   ; FAE696
	.long 0xFFFFFFFF   ; empty slot   ; FAE69A
	.long 0xFFFFFFFF   ; empty slot   ; FAE69E
; --- 0xFAE6A2-0xFAE7C0  zero pad (286 bytes) ---
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE6A2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE6B2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE6C2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE6D2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE6E2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE6F2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE702
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE712
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE722
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE732
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE742
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE752
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE762
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE772
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE782
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE792
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE7A2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; FAE7B2
; --- 0xFAE7C0-0xFAE800  0xFF pad (64 bytes) ---
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FAE7C0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FAE7D0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FAE7E0
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; FAE7F0
T_F41F2C_Nop:
	ret
; --- 0xFAE801-0xFAE802  align (1 bytes) ---
	.byte 0x00   ; FAE801
; --- 0xFAE802-0xFAE822  pointer table (32 bytes) ---
	.long Evt2030_ClassHandlers_Nop0   ; -> Evt2030_ClassHandlers_Nop0   ; FAE802
	.long Evt2030_ClassHandlers_Nop1   ; -> Evt2030_ClassHandlers_Nop1   ; FAE806
	.long Evt2030_ClassHandlers_Nop2   ; -> Evt2030_ClassHandlers_Nop2   ; FAE80A
	.long Evt2030_ClassHandlers_Nop3   ; -> Evt2030_ClassHandlers_Nop3   ; FAE80E
	.long Evt2030_ClassHandlers_Nop4   ; -> Evt2030_ClassHandlers_Nop4   ; FAE812
	.long Evt2030_ClassHandlers_Nop5   ; -> Evt2030_ClassHandlers_Nop5   ; FAE816
	.long Evt2030_ClassHandlers_Nop5   ; -> Evt2030_ClassHandlers_Nop5   ; FAE81A
	.long Evt2030_ClassHandlers_Nop5   ; -> Evt2030_ClassHandlers_Nop5   ; FAE81E
; ---------------------------------------------------------------------
; Evt2030_ClassHandlers_Nop5 -- arm 5, 6, 7 of the 8-entry jump table at 0xFAE802
;
; Called from: NOTHING -- no instruction in prom_a loads this table, through XIX/XIY.
;          Index: -- no reader found --.
; Owner:   nothing.
; Body:    starts `ret`.
; Evidence: the LE32 words at 0xFAE816, 0xFAE81A, 0xFAE81E reads 0x00FAE822, and no other
;          entry of that table does.
; Unknown:  everything.  Nothing loads the table, so nothing
;          is known to reach this arm at all.
; ---------------------------------------------------------------------
Evt2030_ClassHandlers_Nop5:   ; entry: pointer-table entry
	ret
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassHandlers_Nop0 -- arm 0 of the 8-entry jump table at 0xFAE802
;
; Called from: NOTHING -- no instruction in prom_a loads this table, through XIX/XIY.
;          Index: -- no reader found --.
; Owner:   nothing.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAE802 reads 0x00FAE824, and no other
;          entry of that table does.
; Unknown:  everything.  Nothing loads the table, so nothing
;          is known to reach this arm at all.
; ---------------------------------------------------------------------
Evt2030_ClassHandlers_Nop0:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassHandlers_Nop1 -- arm 1 of the 8-entry jump table at 0xFAE802
;
; Called from: NOTHING -- no instruction in prom_a loads this table, through XIX/XIY.
;          Index: -- no reader found --.
; Owner:   nothing.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAE806 reads 0x00FAE825, and no other
;          entry of that table does.
; Unknown:  everything.  Nothing loads the table, so nothing
;          is known to reach this arm at all.
; ---------------------------------------------------------------------
Evt2030_ClassHandlers_Nop1:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassHandlers_Nop2 -- arm 2 of the 8-entry jump table at 0xFAE802
;
; Called from: NOTHING -- no instruction in prom_a loads this table, through XIX/XIY.
;          Index: -- no reader found --.
; Owner:   nothing.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAE80A reads 0x00FAE826, and no other
;          entry of that table does.
; Unknown:  everything.  Nothing loads the table, so nothing
;          is known to reach this arm at all.
; ---------------------------------------------------------------------
Evt2030_ClassHandlers_Nop2:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassHandlers_Nop3 -- arm 3 of the 8-entry jump table at 0xFAE802
;
; Called from: NOTHING -- no instruction in prom_a loads this table, through XIX/XIY.
;          Index: -- no reader found --.
; Owner:   nothing.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAE80E reads 0x00FAE827, and no other
;          entry of that table does.
; Unknown:  everything.  Nothing loads the table, so nothing
;          is known to reach this arm at all.
; ---------------------------------------------------------------------
Evt2030_ClassHandlers_Nop3:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; Evt2030_ClassHandlers_Nop4 -- arm 4 of the 8-entry jump table at 0xFAE802
;
; Called from: NOTHING -- no instruction in prom_a loads this table, through XIX/XIY.
;          Index: -- no reader found --.
; Owner:   nothing.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAE812 reads 0x00FAE828, and no other
;          entry of that table does.
; Unknown:  everything.  Nothing loads the table, so nothing
;          is known to reach this arm at all.
; ---------------------------------------------------------------------
Evt2030_ClassHandlers_Nop4:   ; entry: pointer-table entry
	ret
T_F41F3C_Nop:
	ret
; --- 0xFAE82A-0xFAE84A  pointer table (32 bytes) ---
	.long SeqBuf_PutProgramEvent   ; -> SeqBuf_PutProgramEvent   ; FAE82A
	.long SeqBuf_PutParamEvent   ; -> SeqBuf_PutParamEvent   ; FAE82E
	.long SeqBuf_PutPitchBendEvent   ; -> SeqBuf_PutPitchBendEvent   ; FAE832
	.long SeqBuf_PutModulationEvent   ; -> SeqBuf_PutModulationEvent   ; FAE836
	.long SeqBuf_PutExpressionEvent   ; -> SeqBuf_PutExpressionEvent   ; FAE83A
	.long Evt2030_ClassHandlers_Nop6   ; -> Evt2030_ClassHandlers_Nop6   ; FAE83E
	.long Evt2030_ClassHandlers_Nop6   ; -> Evt2030_ClassHandlers_Nop6   ; FAE842
	.long Evt2030_ClassHandlers_Nop6   ; -> Evt2030_ClassHandlers_Nop6   ; FAE846
; ---------------------------------------------------------------------
; Evt2030_ClassHandlers_Nop6 -- arm 0, 1, 2 of the 3-entry jump table at 0xFAE83E
;
; Called from: NOTHING -- no instruction in prom_a loads this table, through XIX/XIY.
;          Index: -- no reader found --.
; Owner:   nothing.
; Body:    starts `ret`.
; Evidence: the LE32 words at 0xFAE83E, 0xFAE842, 0xFAE846 reads 0x00FAE84A, and no other
;          entry of that table does.
; Unknown:  everything.  Nothing loads the table, so nothing
;          is known to reach this arm at all.
; ---------------------------------------------------------------------
Evt2030_ClassHandlers_Nop6:   ; entry: pointer-table entry
	ret
	ret
T_F41F38_Nop:
	ret
; SeqBuf_RecordQueuedEvents: T_F41F14 entry: from queue index 0, picks the recording part mask (0x60F318) by PanelMode
;   / screen, and SeqBuf_EncodeQueue2C00 appends the queued events to the sequencer ring. The MIDI-in routers call it
;   after pumping a port into the queue; also SysExCmd_ParamWrite and step record. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_a.json)
SeqBuf_RecordQueuedEvents:
	ldw (0x60f002:24), 0x00
	calr T_F41F2C_Nop
	calr T_F41F3C_Nop
	calr .LFAE8CB
	calr SeqBuf_EncodeQueue2C00
	ret
	call T_Dev7F_WriteSlot8_Slot0
	call T_Dev7F_WriteSlot8_Slot1
	call T_Dev7F_WriteSlot8_Slot2
	call T_Dev7F_WriteSlot8_Slot3
	ret
; SeqBuf_PickRecordPartMask: Sets the recording part mask (0x60F318), masked to 17 bits: (0x3000) in PanelMode 5 while
;   transport B runs ((0x60F020) bit 2), (0x1336) -- the EDIT PART SELECT mask -- in PanelMode 6 or 3 (bit 3),
;   (0x3004) on screens 9 / 0x0A when (0x34E2) bit 0, else 0 (bits 2-3 cleared). List2030_ProcessEvents runs it
;   (T_F41F30) before SeqBuf_EncodeQueue2C00; SeqBuf_RecordQueuedEvents inlines the same pick. Basis: caller + body +
;   consumer. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
SeqBuf_PickRecordPartMask:
	xor XWA,XWA
	ld e, (PanelMode:16)
	cp e, 0x05:i3
	jr z, .LFAE89A
	cp e, 0x06:i3
	jr z, .LFAE8B6
	cp e, 0x03:i3
	jr z, .LFAE8B6
	ld d, (UI_ScreenLatch:16)
	cp D,0x09
	jr z, .LFAE8AA
	cp D,0x0a
	jr z, .LFAE8AA
	and	(0x60f020:24), 0xf3
	jr .LFAE8BF
.LFAE89A:
	bit	2, (TransportB_State:8)
	jr z, .LFAE8BF
	ld xwa, (0x3000:16)
	set	2, (0x60f020:24)
	jr .LFAE8BF
.LFAE8AA:
	bit	0, (0x34e2:16)
	jr z, .LFAE8BF
	ld xwa, (0x3004:16)
	jr .LFAE8BF
.LFAE8B6:
	ld xwa, (0x1336:16)
	set	3, (0x60f020:24)
.LFAE8BF:
	and XWA,0x0001ffff
	ld (0x60f318:24), xwa
	ret
.LFAE8CB:
	xor XWA,XWA
	ld e, (PanelMode:16)
	cp e, 0x05:i3
	jr z, .LFAE8EF
	cp e, 0x06:i3
	jr z, .LFAE90C
	ld d, (UI_ScreenLatch:16)
	cp D,0x09
	jr z, .LFAE900
	cp D,0x0a
	jr z, .LFAE900
	and	(0x60f020:24), 0xf3
	jr .LFAE915
.LFAE8EF:
	cp (0x3000:16), xwa
	jr z, .LFAE915
	ld xwa, (0x3000:16)
	set	2, (0x60f020:24)
	jr T,.LFAE915
.LFAE900:
	bit	0, (0x34e2:16)
	jr z, .LFAE915
	ld xwa, (0x3004:16)
	jr .LFAE915
.LFAE90C:
	ld xwa, (0x1336:16)
	set	3, (0x60f020:24)
.LFAE915:
	and XWA,0x0001ffff
	ld (0x60f318:24), xwa
	ret
; SeqBuf_EncodeQueue2C00 -- the 0x2C00-queue encoder its event-type arms (SeqBuf_Put*Event) name: walk the queue's
;          records from 0x2C00 + (0x60F002) up to the 0xFF end mark and append each as a sequencer event to ring
;          0x600A14.  prom_b directory slot T_F41F34; also reached from SeqBuf_RecordQueuedEvents.
SeqBuf_EncodeQueue2C00:
	xor XWA,XWA
	cp (0x60f318:24), xwa
	jrl z, .LFAE9CE
	ei 0x06
	set	0, (SeqBuf_Flags:8)
	ld	a, (Seq_BeatTick:8)
	ld (0x60f31e:24), a
	ei 0x00
	ld XIX,0x00002c00
	extz XWA
	ld wa, (0x60f002:24)
	add XIX,XWA
	ld (0x60f314:24), xix
.LFAE94D:
	ld xix, (0x60f314:24)
	ld wa, (xix+)
	cp A,0xff
	jr z, .LFAE9C7
	ld (0x60f310:24), wa
	ld wa, (xix+)
	ld (0x60f314:24), xix
	ld (0x60f312:24), wa
	ld (0x60f31c:24), 0x00
.LFAE972:
	calr SeqBuf_LoadSlotKeyList
	ld bc, (0x60f310:24)
	ld d, (0x60f313:24)
	ld XIX,0x0060f330
.LFAE984:
	ld wa, (xix+)
	cp A,0xff
	jr z, .LFAE9B2
	cp WA,BC
	jr z, .LFAE994
	inc 2,XIX
	jr .LFAE984
.LFAE994:
	ld wa, (xix+)
	cp C,0xb1
	jr z, .LFAE9A0
	and D,A
	jr z, .LFAE984
.LFAE9A0:
	and W,0x0f
	sll w, 0x02
	ld XIX,sub_FAE84A_JumpTable_FAE9D0
	ld	xix, (xix+w)
	call (xix)
.LFAE9B2:
	ld (0x60f330:24), 0xff
	inc 0x01, (0x60f31c:24)
	cp	(0x60f31c:24), 0x10
	jr ule, .LFAE972
	jr .LFAE94D
.LFAE9C7:
	call T_SeqBuf_FlushStaged
	res	0, (SeqBuf_Flags:8)
.LFAE9CE:
	ret
; --- 0xFAE9CF-0xFAE9D0  align (1 bytes) ---
	.byte 0x00   ; FAE9CF
; --- 0xFAE9D0-0xFAEA10  pointer table (64 bytes) ---
sub_FAE84A_JumpTable_FAE9D0:
	.long SeqBuf_PutProgramEvent   ; -> SeqBuf_PutProgramEvent   ; FAE9D0
	.long SeqBuf_PutParamEvent   ; -> SeqBuf_PutParamEvent   ; FAE9D4
	.long SeqBuf_PutTempoEvent   ; -> SeqBuf_PutTempoEvent   ; FAE9D8
	.long SeqBuf_PutPitchBendEvent   ; -> SeqBuf_PutPitchBendEvent   ; FAE9DC
	.long SeqBuf_PutModulationEvent   ; -> SeqBuf_PutModulationEvent   ; FAE9E0
	.long SeqBuf_PutExpressionEvent   ; -> SeqBuf_PutExpressionEvent   ; FAE9E4
	.long SeqBuf_PutChanPressureEvent   ; -> SeqBuf_PutChanPressureEvent   ; FAE9E8
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAE9EC
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAE9F0
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAE9F4
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAE9F8
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAE9FC
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAEA00
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAEA04
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAEA08
	.long sub_FAE84A_JumpTable_FAE9D0_Nop7   ; -> sub_FAE84A_JumpTable_FAE9D0_Nop7   ; FAEA0C
; ---------------------------------------------------------------------
; sub_FAE84A_JumpTable_FAE9D0_Nop7 -- arm 7, 8, 9, 10, 11, 12, 13, 14, 15 of the 16-entry jump table at 0xFAE9D0
;
; Called from: the reader `ld XIX,0x00fae9d0` at 0xFAE9A6, through XIX/XIY.
;          Index: W & 0x0F.
; Owner:   the routine at 0xFAE921.
; Body:    starts `ret`.
; Evidence: the LE32 words at 0xFAE9EC, 0xFAE9F0, 0xFAE9F4, 0xFAE9F8, 0xFAE9FC, 0xFAEA00, 0xFAEA04, 0xFAEA08, 0xFAEA0C reads 0x00FAEA10, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names W & 0x0F, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
sub_FAE84A_JumpTable_FAE9D0_Nop7:   ; entry: pointer-table entry
	ret
	ret
; SeqBuf_PutProgramEvent -- event type 0 of the 0x2C00-queue encoder at 0xFAE921: encode a part program change as a 7-byte 0xC0-tagged event and append it to the sequencer event ring 0x600A14
; Evidence: the LE32 word at 0xFAE9D0 reads 0x00FAEA12 (index 0); reader `ld XIX,0x00fae9d0` at 0xFAE9A6, index W & 0x0F where W is the high byte of the value word SeqBuf_LoadSlotKeyList copied from KeyValueList_A; in every A list type 0 belongs to exactly one key, {part, class 0} (program; MidiOut_ParamClassTable[0] = MidiOut_ProgramChange).
; Body: builds {0xC0, tick (0x60F31E) = (0x93), number, class, rec[0], rec[1], slot (0x60F31C)} at 0x60F300, bit 7 of rec[0]/rec[1] folded into status bits 0/1; length (0x60F31F) = 7; the tail 0xFAEC0F appends it with T_Ring600A14_PutBlock.  0x600A14 is the sequencer event ring of SeqBuf_AppendEvent (tag byte, then tick (0x93)).
SeqBuf_PutProgramEvent:   ; entry: pointer-table entry
	ld XIX,0x0060f300
	ld a, 0xc0:opc
	ld w, (0x60f31e:24)
	ld (xix+), wa
	ld wa, (0x60f310:24)
	ld (xix+), wa
	ld xiy, (IndexedTable_Base:24)
	extz WA
	sll wa, 0x02
	ld	xiy, (xiy+wa)
	ld WA,(XIY)
	bit 0x07,A
	jr z, .LFAEA47
	res 0x07,A
	set	0, (0x60f300:24)
.LFAEA47:
	bit 0x07,W
	jr z, .LFAEA54
	res 0x07,W
	set	1, (0x60f300:24)
.LFAEA54:
	ld (xix+), wa
	ld a, (0x60f31c:24)
	ld w, 0xff:opc
	ld (xix+), wa
	ld (0x60f31f:24), 0x07
	calr .LFAEC0F
	ret
; SeqBuf_PutParamEvent -- event type 1 of the encoder at 0xFAE921: encode a parameter change as a 7-byte 0xB0-tagged event {0xB0, tick, number, class, value, mask, slot} and append it to ring 0x600A14
; Evidence: the LE32 word at 0xFAE9D4 reads 0x00FAEA6B (index 1); reader `ld XIX,0x00fae9d0` at 0xFAE9A6.  KeyValueList_A type 1 covers part classes 3-0x0B, second-half classes 0x18-0x1A and numbers 0xAD, 0xAE, 0xB5-0xBD.
; Body: bit 7 of number / value / mask folded into status bits 2 / 0 / 1 (0xFAEA7A-0xFAEAA9), length 7, tail 0xFAEC0F.  SeqEvt_LookupParamType undoes the folding.
SeqBuf_PutParamEvent:   ; entry: pointer-table entry
	ld XIX,0x0060f300
	ld a, 0xb0:opc
	ld w, (0x60f31e:24)
	ld (xix+), wa
	ld wa, (0x60f310:24)
	bit 0x07,A
	jr z, .LFAEA8C
	res 0x07,A
	set	2, (0x60f300:24)
.LFAEA8C:
	ld (xix+), wa
	ld wa, (0x60f312:24)
	bit 0x07,A
	jr z, .LFAEAA1
	res 0x07,A
	set	0, (0x60f300:24)
.LFAEAA1:
	bit 0x07,W
	jr z, .LFAEAAE
	res 0x07,W
	set	1, (0x60f300:24)
.LFAEAAE:
	ld (xix+), wa
	ld a, (0x60f31c:24)
	ld w, 0xff:opc
	ld (xix+), wa
	ld (0x60f31f:24), 0x07
	calr .LFAEC0F
	ret
; SeqBuf_PutPitchBendEvent -- event type 3 of the encoder at 0xFAE921: encode a pitch-bend change as {0xD2, tick, LSB, MSB, slot} and append it to ring 0x600A14
; Evidence: the LE32 word at 0xFAE9DC reads 0x00FAEAC5 (index 3); reader `ld XIX,0x00fae9d0` at 0xFAE9A6; KeyValueList_A type 3 belongs only to key 0xB1 (ParamMsg_B1_PitchBend).  Body: `ld A,0xd2`, (0x60F312) & 0x7F7F, (0x60F31F) = 0x25 (length 5; 0x20 is the overflow flag the tail ORs into (0x34B8) when the ring is full).
; SeqEvt_ShadowPitchBend handles the same 0xD2 code on the playback side.
SeqBuf_PutPitchBendEvent:   ; entry: pointer-table entry
	ld XIX,0x0060f300
	ld a, 0xd2:opc
	ld w, (0x60f31e:24)
	ld (xix+), wa
	ld wa, (0x60f312:24)
	and WA,0x7f7f
	ld (xix+), wa
	ld a, (0x60f31c:24)
	ld w, 0xff:opc
	ld (xix+), wa
	ld (0x60f31f:24), 0x25
	calr .LFAEC0F
	ret
; SeqBuf_PutModulationEvent -- event type 4 of the encoder at 0xFAE921: encode a modulation change as {0xD1, tick, value, slot} and append it to ring 0x600A14
; Evidence: the LE32 word at 0xFAE9E0 reads 0x00FAEAF4 (index 4); reader `ld XIX,0x00fae9d0` at 0xFAE9A6; KeyValueList_A type 4 belongs only to key 0xB2 (ParamMsg_B2_CC01_Modulation).  Body: `ld A,0xd1`, (0x60F31F) = 0x14 (length 4, overflow flag 0x10).  SeqEvt_ShadowModulation handles 0xD1 on playback.
SeqBuf_PutModulationEvent:   ; entry: pointer-table entry
	ld XIX,0x0060f300
	ld a, 0xd1:opc
	ld w, (0x60f31e:24)
	ld (xix+), wa
	ld a, (0x60f312:24)
	ld w, (0x60f31c:24)
	ld (xix+), wa
	ld (XIX),0xff
	ld (0x60f31f:24), 0x14
	calr .LFAEC0F
	ret
; SeqBuf_PutExpressionEvent -- event type 5 of the encoder at 0xFAE921: encode an expression change as {0xD3, tick, value, slot} and append it to ring 0x600A14
; Evidence: the LE32 word at 0xFAE9E4 reads 0x00FAEB1D (index 5); reader `ld XIX,0x00fae9d0` at 0xFAE9A6; KeyValueList_A type 5 belongs only to key 0xB3 (ParamMsg_B3_CC0B_Expression).  Body: `ld A,0xd3`, (0x60F31F) = 4.  SeqEvt_ShadowExpression handles 0xD3 on playback.
SeqBuf_PutExpressionEvent:   ; entry: pointer-table entry
	ld XIX,0x0060f300
	ld a, 0xd3:opc
	ld w, (0x60f31e:24)
	ld (xix+), wa
	ld a, (0x60f312:24)
	ld w, (0x60f31c:24)
	ld (xix+), wa
	ld (XIX),0xff
	ld (0x60f31f:24), 0x04
	calr .LFAEC0F
	ret
; SeqBuf_PutChanPressureEvent -- event type 6 of the encoder at 0xFAE921: when bit 0 of (0x7FC2) is set, encode a channel-pressure change as {0xD0, tick, value, slot} and append it to ring 0x600A14
; Evidence: the LE32 word at 0xFAE9E8 reads 0x00FAEB46 (index 6); reader `ld XIX,0x00fae9d0` at 0xFAE9A6; KeyValueList_A type 6 belongs only to key 0xB4 (ParamMsg_B4_ChannelPressure).  Body: `bit 0,(0x7fc2) / jr z` gate, `ld A,0xd0`, (0x60F31F) = 4.  What bit 0 of (0x7FC2) is, is not established.
SeqBuf_PutChanPressureEvent:   ; entry: pointer-table entry
	bit	0, (0x7fc2:16)
	jr z, .LFAEB74
	ld XIX,0x0060f300
	ld a, 0xd0:opc
	ld w, (0x60f31e:24)
	ld (xix+), wa
	ld a, (0x60f312:24)
	ld w, (0x60f31c:24)
	ld (xix+), wa
	ld (XIX),0xff
	ld (0x60f31f:24), 0x04
	calr .LFAEC0F
.LFAEB74:
	ret
; SeqBuf_PutTempoEvent -- event type 2 of the encoder at 0xFAE921: encode the current tempo (parameter 0x7A, RAM 0x7EE2) as {0x80, tick, tempo&0x7F, tempo>>7} and append it to ring 0x600A14
; Evidence: the LE32 word at 0xFAE9D8 reads 0x00FAEB75 (index 2); reader `ld XIX,0x00fae9d0` at 0xFAE9A6; KeyValueList_A type 2 belongs only to key 0x7A (KeyValueList_A32).  Body: `ld A,0x80`, `ld WA,(0x7ee2) / and WA,0x01ff`, 7-bit split, (0x60F31F) = 4.  SeqEvt_ApplyTempo decodes the same 0x80 code.
SeqBuf_PutTempoEvent:   ; entry: pointer-table entry
	ld XIX,0x0060f300
	ld a, 0x80:opc
	ld w, (0x60f31e:24)
	ld (xix+), wa
	ld wa, (0x7ee2:16)
	and WA,0x01ff
	sll w, 0x01
	bit 0x07,A
	jr z, .LFAEB97
	set 0x00,W
.LFAEB97:
	res 0x07,A
	ld (xix+), wa
	ld (XIX),0xff
	ld (0x60f31f:24), 0x04
	calr .LFAEC0F
	ret
T_F41F24_Nop:
	ret
	call T_Dev7F_WriteSlot8_Slot0
	call T_Dev7F_WriteSlot8_Slot1
	call T_Dev7F_WriteSlot8_Slot2
	call T_Dev7F_WriteSlot8_Slot3
	ret
; SeqBuf_LoadSlotKeyList -- if slot (0x60F31C) is enabled in the slot mask (0x60F318), copy KeyValueList_A for the slot's part (0x603422)[slot] to RAM 0x60F330; otherwise leave 0x60F330 empty (0xFF)
; Evidence: `ld (0x60f330),0xff`, shift loop on (0x60F318) at 0xFAEBC9-0xFAEBD6, `ld XIX,KeyValueListPtrs_A` read (the reader KeyValueListPtrs_A's header cites) and the word-copy loop 0xFAEBFB-0xFAEC0E.
; (0x60F318) is set by SeqBuf_PickRecordPartMask (directory T_F41F30) from (0x3000), (0x3004) or (0x1336) by the mode bytes (0x2078)/(0x207A).  Called per slot 0..16 by the 0x2C00 encoder at 0xFAE921.
SeqBuf_LoadSlotKeyList:
	ld (0x60f330:24), 0xff
	xor XWA,XWA
	ld c, (0x60f31c:24)
	inc 1,C
	ld xwa, (0x60f318:24)
.LFAEBD0:
	srl xwa, 0x01
	djnz8 c, .LFAEBD0
	jr nc, .LFAEC0E
	extz HL
	ld l, (0x60f31c:24)
	ld XIX,BStore_TrackToPart
	ld	l, (xix+hl)
	sll hl, 0x02
	ld XIX,KeyValueListPtrs_A
	ld	xiy, (xix+hl)
	ld XIX,0x0060f330
.LFAEBFB:
	ld wa, (xiy+)
	ld (xix+), wa
	cp A,0xff
	jr z, .LFAEC0E
	ld wa, (xiy+)
	ld (xix+), wa
	jr .LFAEBFB
.LFAEC0E:
	ret
.LFAEC0F:
	cp	(0x60f300:24), 0xff
	jr z, .LFAEC77
	ld XIX,SeqBuf_Ring
	extz WA
	ld a, (0x60f31f:24)
	pushw wa
	and A,0x07
	cp (xix-2), wa
	popw wa
	jr c, .LFAEC5E
	ld XIX,0x0060f300
	push XIX
	extz WA
	ld a, (0x60f31f:24)
	and A,0x07
	pushw wa
	ei 0x06
	call T_SeqBufRing_PutBlock
	inc 6,XSP
	ei 0x00
	cp	(0x60f01e:24), 0xff
	jr nz, .LFAEC71
	call Regs_SaveAllScratch
	call T_SeqRecord_StartOnFirstEvent
	call Regs_RestoreAllScratch
	jr .LFAEC71
.LFAEC5E:
	ld a, (0x60f31f:24)
	pushw wa
	and A,0xb0
	popw wa
	jr z, .LFAEC71
	srl a, 0x04
	or (0x34b8:16), a
.LFAEC71:
	ld (0x60f31f:24), 0x00
.LFAEC77:
	ret
T_F41F1C_Nop:
	ret
	call T_Dev7F_WriteSlot8_Slot0
	call T_Dev7F_WriteSlot8_Slot1
	call T_Dev7F_WriteSlot8_Slot2
	call T_Dev7F_WriteSlot8_Slot3
	ret
; SeqEvt_ResetPlayingSlotControllers: T_F41F18: for each of the 17 sequencer slots whose bit is set in the playing mask (0x60341E), with its part from
;   BStore_TrackToPart: channel pressure 0 (D0), modulation 0 (D1), pitch bend centre (D2 0x00 0x40) through
;   SeqEvt_ApplyCtrlEvent, and a B0 / 0xB5 0x7F event through SeqEvt_ApplyParamEvent; then SeqEvt_FlushShadows,
;   DspEffect_RepostRotarySpeakerAlgorithm, T_Queue2C00_DrainPassB.  SeqEvt_FlushShadows' header calls it the slot-reset routine.  Basis: body.
SeqEvt_ResetPlayingSlotControllers:
	ld (0x60f31d:24), 0x00
.LFAEC90:
	xor XWA,XWA
	ld c, (0x60f31d:24)
	inc 1,C
	ld xwa, (0x60341e:24)
.LFAEC9E:
	srl xwa, 0x01
	djnz8 c, .LFAEC9E
	jr nc, .LFAECC8
	extz HL
	ld L,C
	ld XIX,BStore_TrackToPart
	ld	a, (xix+hl)
	ld (0x60f322:24), a
	calr .LFAED1B
	calr .LFAED37
	calr .LFAECE0
	calr .LFAECFF
	calr .LFAED75
.LFAECC8:
	inc 0x01, (0x60f31d:24)
	cp	(0x60f31d:24), 0x11
	jr c, .LFAEC90
	calr SeqEvt_FlushShadows
	calr DspEffect_RepostRotarySpeakerAlgorithm
	call T_Queue2C00_DrainPassB
	ret
.LFAECE0:
	ld XIX,0x0060f308
	ldw wa, 0xd2
	ld (xix+), wa
	xor A,A
	ld w, 0x40:opc
	ld (xix+), wa
	ld a, (0x60f31d:24)
	ld w, 0xff:opc
	ld (XIX),WA
	calr SeqEvt_ApplyCtrlEvent
	ret
.LFAECFF:
	ld XIX,0x0060f308
	ldw wa, 0xd1
	ld (xix+), wa
	ld a, 0x00:opc
	ld w, (0x60f31d:24)
	ld (xix+), wa
	ld (XIX),0xff
	calr SeqEvt_ApplyCtrlEvent
	ret
.LFAED1B:
	ld XIX,0x0060f308
	ldw wa, 0xd0
	ld (xix+), wa
	ld a, 0x00:opc
	ld w, (0x60f31d:24)
	ld (xix+), wa
	ld (XIX),0xff
	calr SeqEvt_ApplyCtrlEvent
	ret
.LFAED37:
	ld XIX,0x0060f308
	ldw wa, 0xb0
	ld (xix+), wa
	extz HL
	ld l, (0x60f31d:24)
	ld XIY,BStore_TrackToPart
	ld	l, (xiy+hl)
	ld XIY,IdentityMap32_FAF7A6
	ld	w, (xiy+hl)
	ld a, 0xb5:opc
	ld (xix+), wa
	ldw wa, 0x7f00
	ld (xix+), wa
	ld a, (0x60f31d:24)
	ld w, 0xff:opc
	ld (XIX),WA
	calr SeqEvt_ApplyParamEvent
	ret
.LFAED75:
	ret
; SeqEvt_PlayRun: Plays a due class-0 run of the timed-event ring: (0x60F002) = queue cursor,
;   TimedEventRing_ScanRewind, then each event's bytes up to the next status byte into 0x60F308, dispatched on (status
;   & 0x70) >> 4 through SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0 (SeqEvt_ApplyTempo / ApplyParamEvent /
;   ApplyProgramEvent / ApplyCtrlEvent); ends the 0x2C00 queue with 0xFF and runs SeqEvt_FlushShadows. Called via
;   T_F41F10 by TimedEvents_DispatchDueRun. Basis: caller + body + table. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
SeqEvt_PlayRun:
	calr .LFAED8E
	calr SeqEvt_FlushShadows
	ret
	call T_Dev7F_WriteSlot8_Slot0
	call T_Dev7F_WriteSlot8_Slot1
	call T_Dev7F_WriteSlot8_Slot2
	call T_Dev7F_WriteSlot8_Slot3
	ret
.LFAED8E:
	ld wa, (0x60f000:24)
	ld (0x60f002:24), wa
	call T_TimedEventRing_ScanRewind
.LFAED9C:
	ld XIX,TimedEvents_Ring
	ld hl, (xix-10)
	cp	hl, (xix-6)
	jr z, Evt2030_ClassHandlers_Code_Skip
	ld XIY,0x0060f308
.LFAEDAE:
	call T_TimedEventRing_Scan
	ld (xiy+), a
	ld hl, (xix-10)
	cp	hl, (xix-6)
	jr z, .LFAEDC7
	ld	a, (xix+hl)
	bit 0x07,A
	jr z, .LFAEDAE
.LFAEDC7:
	ld (XIY),0xff
	ld a, (0x60f309:24)
	ld (0x60f01e:24), a
	extz HL
	ld l, (0x60f308:24)
	and L,0x70
	srl hl, 0x02
	ld XIY,SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0
	ld	xiy, (xiy+hl)
	call (xiy)
	jr .LFAED9C
; --- 0xFAEDEF-0xFAEDF0  align (1 bytes) ---
	.byte 0x00   ; FAEDEF
; --- 0xFAEDF0-0xFAEE10  pointer table (32 bytes) ---
SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0:
	.long SeqEvt_ApplyTempo   ; -> SeqEvt_ApplyTempo   ; FAEDF0
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEDF4
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEDF8
	.long SeqEvt_ApplyParamEvent   ; -> SeqEvt_ApplyParamEvent   ; FAEDFC
	.long SeqEvt_ApplyProgramEvent   ; -> SeqEvt_ApplyProgramEvent   ; FAEE00
	.long SeqEvt_ApplyCtrlEvent   ; -> SeqEvt_ApplyCtrlEvent   ; FAEE04
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE08
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE0C
; ---------------------------------------------------------------------
; SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1 -- arm 1, 2, 6, 7 of the 8-entry jump table at 0xFAEDF0
;
; Called from: the reader `ld XIY,0x00faedf0` at 0xFAEDE1, through XIX/XIY.
;          Index: ((0x60F308) & 0x70) >> 2.
; Owner:   the routine at 0xFAED76.
; Body:    starts `ret`.
; Evidence: the LE32 words at 0xFAEDF4, 0xFAEDF8, 0xFAEE08, 0xFAEE0C reads 0x00FAEE10, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names ((0x60F308) & 0x70) >> 2, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1:   ; entry: pointer-table entry
	ret
Evt2030_ClassHandlers_Code_Skip:
	ld XIX,0x00002c00
	ld hl, (0x60f000:24)
	ld	(xix+hl), 0xff
	ret
; SeqEvt_UnpackProgramBit7 -- restore bit 7 of the two sound bytes of a 0xC0 event in the buffer 0x60F308: status bit 0 -> bit 7 of byte +4, status bit 1 -> bit 7 of byte +5
; Evidence: `bit 0,(XIX) / set 7,(XIX+0x04)` and `bit 1,(XIX) / set 7,(XIX+0x05)` at 0xFAEE22-0xFAEE33 with XIX = 0x60F308 -- the inverse of SeqBuf_PutProgramEvent's `res 7` + `set 0/1,(0x60f300)`.  Called only by SeqEvt_ApplyProgramEvent.
SeqEvt_UnpackProgramBit7:
	ld XIX,0x0060f308
	bit 0,(XIX)
	jr z, .LFAEE2E
	set 7,(XIX+0x04)
.LFAEE2E:
	bit 1,(XIX)
	jr z, .LFAEE35
	set 7,(XIX+0x05)
.LFAEE35:
	ret
; SeqEvt_ApplyParamEvent -- playback of a 0xBn sequencer event: look its {number, class} up in the slot's KeyValueList_B and dispatch on the event type found
; Evidence: the LE32 word at 0xFAEDFC reads 0x00FAEE36 (entry 3 of the table at 0xFAEDF0, read by `ld XIY,0x00faedf0` at 0xFAEDE1, index (status & 0x70) >> 4); body calr SeqEvt_LookupParamType, then `ld L,(0x60f327) / and L,0x0f` and the 16-entry table at 0xFAEE5C (reader at 0xFAEE4E).
; KeyValueList_B uses only types 3 (key 0xAD), 4 (0xAE, 0xB5-0xBD), 5 ({part,3}) and 6 (part classes 5-0x0B, 0x18-0x1A), read straight from KeyValueList_B00..B32.
SeqEvt_ApplyParamEvent:   ; entry: pointer-table entry
	calr SeqEvt_LookupParamType
	cp	(0x60f308:24), 0xff
	jr z, .LFAEE5A
	extz HL
	ld l, (0x60f327:24)
	and L,0x0f
	sll hl, 0x02
	ld XIX,SeqEvt_ApplyParamEvent_JumpTable_FAEE5C
	ld	xix, (xix+hl)
	call (xix)
.LFAEE5A:
	ret
; --- 0xFAEE5B-0xFAEE5C  align (1 bytes) ---
	.byte 0x00   ; FAEE5B
; --- 0xFAEE5C-0xFAEE9C  pointer table (64 bytes) ---
SeqEvt_ApplyParamEvent_JumpTable_FAEE5C:
	.long SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop0   ; -> SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop0   ; FAEE5C
	.long SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop1   ; -> SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop1   ; FAEE60
	.long SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop2   ; -> SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop2   ; FAEE64
	.long SeqEvt_ApplyParamAD   ; -> SeqEvt_ApplyParamAD   ; FAEE68
	.long SeqEvt_PublishParam   ; -> SeqEvt_PublishParam   ; FAEE6C
	.long SeqEvt_ShadowPartVolume   ; -> SeqEvt_ShadowPartVolume   ; FAEE70
	.long SeqEvt_WriteRecordField   ; -> SeqEvt_WriteRecordField   ; FAEE74
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE78
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE7C
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE80
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE84
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE88
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE8C
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE90
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE94
	.long SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; -> SeqBuf_LoadSlotKeyList_JumpTable_FAEDF0_Nop1   ; FAEE98
; ---------------------------------------------------------------------
; SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop0 -- arm 0 of the 16-entry jump table at 0xFAEE5C
;
; Called from: the reader `ld XIX,0x00faee5c` at 0xFAEE4E, through XIX/XIY.
;          Index: (0x60F327) & 0x0F.
; Owner:   the routine at 0xFAEE10.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAEE5C reads 0x00FAEE9C, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names (0x60F327) & 0x0F, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop0:   ; entry: pointer-table entry
	ret
; SeqEvt_WriteRecordField -- type 6 of a played-back 0xBn event: masked write of {number, class, value, mask} into ParamNumber_RecordPtrs[number] + class and publish it when the slot's apply bit is set, then notify MIDI out unless the slot's output byte is 0x20
; Evidence: the LE32 word at 0xFAEE74 reads 0x00FAEE9D (index 6 of 0xFAEE5C, reader at 0xFAEE4E, index (0x60F327) & 0x0F); KeyValueList_B type 6 = part classes 5-0x0B and 0x18-0x1A.
; Body: SeqEvt_SlotApplyBit gate, `ld W,D / xor W,0xff / and A,W / and E,D / or E,A` store, T_Queue2C00_PublishStagedIfPending; then (0x60F007) = (0x603433)[slot] | 0x80 and T_ParamChange_Notify.
SeqEvt_WriteRecordField:   ; entry: pointer-table entry
	call SeqEvt_SlotApplyBit
	jr nc, .LFAEEED
	ld bc, (0x60f30a:24)
	ld de, (0x60f30c:24)
	extz HL
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	cp XIX,0xffffffff
	jr z, .LFAEF23
	extz HL
	ld L,B
	ld	a, (xix+hl)
	ld W,D
	xor W,0xff
	and A,W
	and E,D
	or E,A
	ld	(xix+hl), e
	ld (0x60f080:24), bc
	ld (0x60f082:24), de
	call T_Queue2C00_PublishStagedIfPending
.LFAEEED:
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld	a, (xix+hl)
	ld XIX,0x00603433
	ld	a, (xix+hl)
	cp A,0x20
	jr z, .LFAEF23
	set 0x07,A
	ld (0x60f007:24), a
	ld bc, (0x60f30a:24)
	ld de, (0x60f30c:24)
	call T_ParamChange_Notify
.LFAEF23:
	ret
; SeqEvt_ShadowPartVolume -- type 5 of a played-back 0xBn event: defer a part-volume value, (0x60F610)[slot] = value | 0x80, for SeqEvt_FlushShadows
; Evidence: the LE32 word at 0xFAEE70 reads 0x00FAEF24 (index 5 of 0xFAEE5C, reader at 0xFAEE4E); KeyValueList_B type 5 belongs only to key {part, class 3}, and class 3 is volume (MidiOut_ParamClassTable[3] = MidiOut_CC07_Volume).  Body: `set 7,E / ld XIX,0x0060f610 / ld (XIX+HL),E`; SeqEvt_FlushShadows posts the array through SeqEvt_PostPartVolume with B = 3.
SeqEvt_ShadowPartVolume:   ; entry: pointer-table entry
	ld e, (0x60f30c:24)
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	set 0x07,E
	ld XIX,SeqEvt_VolumeShadow
	ld	(xix+hl), e
	ret
; SeqEvt_PostPartVolume -- post a deferred part volume for sequencer slot (0x60F31D): {part, 3, E, 0x7F} written into the part record and published when the slot's apply bit is set, then notified to MIDI out unless the slot's output byte is 0x20
; Evidence: part = IdentityMap32_FAF7A6[(0x603422)[slot]], `ld B,0x03 / ld D,0x7f`, SeqEvt_SlotApplyBit, T_ParamRecord_WriteFieldAndStage + T_Queue2C00_PublishStagedIfPending, then T_ParamChange_Notify (0xFAEF43-0xFAEFB0).  Class 3 is volume (MidiOut_ParamClassTable[3] = MidiOut_CC07_Volume).  Called from SeqEvt_FlushShadows' 0x60F610 sweep.
SeqEvt_PostPartVolume:
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld	l, (xix+hl)
	ld XIX,IdentityMap32_FAF7A6
	ld	c, (xix+hl)
	ld b, 0x03:opc
	ld (0x60f0bc:24), bc
	ld d, 0x7f:opc
	ld (0x60f0be:24), de
	call SeqEvt_SlotApplyBit
	jr nc, .LFAEF7A
	call T_ParamRecord_WriteFieldAndStage
	call T_Queue2C00_PublishStagedIfPending
.LFAEF7A:
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld	a, (xix+hl)
	ld XIX,0x00603433
	ld	a, (xix+hl)
	cp A,0x20
	jr z, .LFAEFB0
	ld bc, (0x60f0bc:24)
	ld de, (0x60f0be:24)
	set 0x07,A
	ld (0x60f007:24), a
	call T_ParamChange_Notify
.LFAEFB0:
	ret
; ---------------------------------------------------------------------
; SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop1 -- arm 1 of the 16-entry jump table at 0xFAEE5C
;
; Called from: the reader `ld XIX,0x00faee5c` at 0xFAEE4E, through XIX/XIY.
;          Index: (0x60F327) & 0x0F.
; Owner:   the routine at 0xFAEE10.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAEE60 reads 0x00FAEFB1, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names (0x60F327) & 0x0F, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop1:   ; entry: pointer-table entry
	ret
; ---------------------------------------------------------------------
; SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop2 -- arm 2 of the 16-entry jump table at 0xFAEE5C
;
; Called from: the reader `ld XIX,0x00faee5c` at 0xFAEE4E, through XIX/XIY.
;          Index: (0x60F327) & 0x0F.
; Owner:   the routine at 0xFAEE10.
; Body:    starts `ret`.
; Evidence: the LE32 word at 0xFAEE64 reads 0x00FAEFB2, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names (0x60F327) & 0x0F, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
SeqEvt_ApplyParamEvent_JumpTable_FAEE5C_Nop2:   ; entry: pointer-table entry
	ret
; SeqEvt_ApplyParamAD -- type 3 of a played-back 0xBn event (used only by key 0xAD): load the event into the MIDI-in record (0x1950) with value/mask 0x7F00 and run ParamApply_PublishStagedAndPostSeven, then notify MIDI out
; Evidence: the LE32 word at 0xFAEE68 reads 0x00FAEFB3 (index 3 of 0xFAEE5C, reader at 0xFAEE4E); KeyValueList_B type 3 holds only key 0xAD.  Body: SeqEvt_SlotApplyBit gate, `ld (0x1950),WA` from (0x60F30A), `ldw WA,0x7f00 / ld (0x1952),WA`, `call T_F4087C` (ParamApply_PublishStagedAndPostSeven, which also posts the B1/B4/B2/B3/B5/B6/B7 reset values), (0x60F01E) := (0x60F309); then T_ParamChange_Notify.
SeqEvt_ApplyParamAD:   ; entry: pointer-table entry
	call SeqEvt_SlotApplyBit
	jr nc, .LFAEFDD
	ld a, 0x00:opc
	ld (0x1950:16), a
	ld wa, (0x60f30a:24)
	ld (0x1950:16), wa
	ldw wa, 0x7f00
	ld (0x1952:16), wa
	call T_ParamApply_PublishStagedAndPostSeven
	ld a, (0x60f309:24)
	ld (0x60f01e:24), a
.LFAEFDD:
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,0x00603433
	ld	a, (xix+hl)
	cp A,0x20
	jr z, .LFAF009
	set 0x07,A
	ld (0x60f007:24), a
	ld bc, (0x60f30a:24)
	ld de, (0x60f30c:24)
	call T_ParamChange_Notify
.LFAF009:
	ret
; SeqEvt_PublishParam -- type 4 of a played-back 0xBn event: publish the event's four bytes unchanged to 0x2C00 (no record write) when the slot's apply bit is set, then notify MIDI out
; Evidence: the LE32 word at 0xFAEE6C reads 0x00FAF00A (index 4 of 0xFAEE5C, reader at 0xFAEE4E); KeyValueList_B type 4 = keys 0xAE and 0xB5-0xBD, numbers with no record.  Body: SeqEvt_SlotApplyBit gate, (0x60F080..83) := (0x60F30A..0D), T_Queue2C00_PublishStagedIfPending; T_ParamChange_Notify unless (0x603433)[slot] == 0x20.
SeqEvt_PublishParam:   ; entry: pointer-table entry
	call SeqEvt_SlotApplyBit
	jr nc, .LFAF028
	ld wa, (0x60f30a:24)
	ld (0x60f080:24), wa
	ld wa, (0x60f30c:24)
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
.LFAF028:
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,0x00603433
	ld	a, (xix+hl)
	cp A,0x20
	jr z, .LFAF054
	set 0x07,A
	ld (0x60f007:24), a
	ld bc, (0x60f30a:24)
	ld de, (0x60f30c:24)
	call T_ParamChange_Notify
.LFAF054:
	ret
; SeqEvt_LookupParamType -- for the 0xBn event in 0x60F308: take the slot from byte +6, load the slot's KeyValueList_B into 0x60F330, restore bit 7 of number/value/mask from status bits 2/0/1, find the {number, class} key and leave its type in (0x60F327), or invalidate the event ((0x60F308) = 0xFF) when there is no key or its mask misses the event's mask
; Evidence: `ld A,(0x60f30e) / ld (0x60f31d),A` at 0xFAF055; .LFAF0C1 copies KeyValueListPtrs_B[(0x603422)[slot]] (reader at 0xFAF0DB, cited by that table's header); flag restore 0xFAF075-0xFAF08F; key search 0xFAF099-0xFAF0BB.
; The inverse of SeqBuf_PutParamEvent's flag folding.  Called only by SeqEvt_ApplyParamEvent.
SeqEvt_LookupParamType:
	ld a, (0x60f30e:24)
	ld (0x60f31d:24), a
	calr .LFAF0C1
	cp	(0x60f330:24), 0xff
	jr z, .LFAF0B3
	ld XIX,0x0060f30a
	ld BC,(XIX)
	ld DE,(XIX+0x02)
	ld a, (xix-2)
	bit 0x02,A
	jr z, .LFAF07F
	set 0x07,C
.LFAF07F:
	bit 0x00,A
	jr z, .LFAF087
	set 0x07,E
.LFAF087:
	bit 0x01,A
	jr z, .LFAF08F
	set 0x07,D
.LFAF08F:
	ld (XIX),BC
	ld (XIX+0x02),DE
	ld XIY,0x0060f330
.LFAF099:
	ld wa, (xiy+)
	cp A,0xff
	jr z, .LFAF0B3
	cp WA,BC
	jr z, .LFAF0A9
	inc 2,XIY
	jr .LFAF099
.LFAF0A9:
	ld wa, (xiy+)
	and D,A
	ld (XIX+0x02),DE
	jr nz, .LFAF0BB
.LFAF0B3:
	ld (0x60f308:24), 0xff
	jr .LFAF0C0
.LFAF0BB:
	ld (0x60f327:24), w
.LFAF0C0:
	ret
.LFAF0C1:
	ld (0x60f330:24), 0xff
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld	l, (xix+hl)
	sll hl, 0x02
	ld XIX,KeyValueListPtrs_B
	ld	xiy, (xix+hl)
	ld XIX,0x0060f330
.LFAF0EA:
	ld wa, (xiy+)
	ld (xix+), wa
	cp A,0xff
	jr z, .LFAF0FD
	ld wa, (xiy+)
	ld (xix+), wa
	jr .LFAF0EA
.LFAF0FD:
	ret
; SeqEvt_ApplyTempo -- playback of a 0x80 sequencer event: write its 9-bit tempo into parameter 0x7A's record (RAM 0x7EE2), reprogram the tempo timer and publish {0x7A, 0, tempo, 0xFF} when the slot's apply bit is set
; Evidence: the LE32 word at 0xFAEDF0 reads 0x00FAF0FE (entry 0 of the table at 0xFAEDF0, reader `ld XIY,0x00faedf0` at 0xFAEDE1); `cp (0x60f308),0x80`; `ld XIX,0x00007ee2 / and (XIX),0xfe00 / or (XIX),WA`; `call T_Tempo_ApplyBpm` (Tempo_ApplyBpm, the 40..300 BPM clamp that loads TREG5); `ldw (0x60f080),0x7a` + T_Queue2C00_PublishStagedIfPending.
; The decode side of SeqBuf_PutTempoEvent.
SeqEvt_ApplyTempo:   ; entry: pointer-table entry
	cp	(0x60f308:24), 0x80
	jr nz, .LFAF147
	ld a, (0x60f30c:24)
	ld (0x60f31d:24), a
	call SeqEvt_SlotApplyBit
	jr nc, .LFAF147
	ld wa, (0x60f30a:24)
	srl w, 0x01
	jr nc, .LFAF123
	set 0x07,A
.LFAF123:
	ld XIX,0x00007ee2
	and W,0x01
	.byte 0x94, 0x3c, 0x00, 0xfe
	or (XIX),WA
	ld w, 0xff:opc
	call T_Tempo_ApplyBpm
	ld (0x60f082:24), wa
	ldw (0x60f080:24), 0x7a
	call T_Queue2C00_PublishStagedIfPending
.LFAF147:
	ret
; SeqEvt_ApplyCtrlEvent -- playback of a 0xDn sequencer event: validate its slot, then dispatch on status & 3 -- D0 channel pressure, D1 modulation, D2 pitch bend, D3 expression
; Evidence: the LE32 word at 0xFAEE04 reads 0x00FAF148 (entry 5 of the table at 0xFAEDF0, reader `ld XIY,0x00faedf0` at 0xFAEDE1); body calr SeqEvt_SelectCtrlEventSlot, `and A,0x03` and the 4-entry table at 0xFAF16C.
; The four codes are the ones SeqBuf_PutChanPressureEvent / PutModulationEvent / PutPitchBendEvent / PutExpressionEvent emit for keys 0xB4 / 0xB2 / 0xB1 / 0xB3.  Also called by the slot-reset routine at 0xFAEC8A (directory T_F41F18) with synthesised D0/D1/D2 events.
SeqEvt_ApplyCtrlEvent:   ; entry: pointer-table entry
	calr SeqEvt_SelectCtrlEventSlot
	cp	(0x60f308:24), 0xff
	jr z, .LFAF16A
	ld a, (0x60f308:24)
	and A,0x03
	sll a, 0x02
	ld XIX,SeqEvt_ApplyCtrlEvent_StatusHandlers
	ld	xix, (xix+a)
	call (xix)
.LFAF16A:
	ret
; --- 0xFAF16B-0xFAF16C  align (1 bytes) ---
	.byte 0x00   ; FAF16B
; --- 0xFAF16C-0xFAF17C  pointer table (16 bytes) ---
; SeqEvt_ApplyCtrlEvent_StatusHandlers: SeqEvt_ApplyCtrlEvent's switch on the 0xDn event status & 3:
;   SeqEvt_ShadowChanPressure / ShadowModulation / ShadowPitchBend / ShadowExpression. Basis: table index (status) +
;   its four already-named arms. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
SeqEvt_ApplyCtrlEvent_StatusHandlers:
	.long SeqEvt_ShadowChanPressure   ; -> SeqEvt_ShadowChanPressure   ; FAF16C
	.long SeqEvt_ShadowModulation   ; -> SeqEvt_ShadowModulation   ; FAF170
	.long SeqEvt_ShadowPitchBend   ; -> SeqEvt_ShadowPitchBend   ; FAF174
	.long SeqEvt_ShadowExpression   ; -> SeqEvt_ShadowExpression   ; FAF178
; SeqEvt_ShadowChanPressure -- 0xD0 arm of SeqEvt_ApplyCtrlEvent: defer a channel-pressure value, (0x60F630)[slot] = value | 0x80
; Evidence: arm 0 of the 4-entry table at 0xFAF16C -- the LE32 word at 0xFAF16C reads 0x00FAF17C; reader `ld XIX,0x00faf16c` at 0xFAF15E, index (0x60F308) & 3.  SeqEvt_FlushShadows posts 0x60F630 through SeqEvt_PostChanPressure (`ld C,0xb4`).
SeqEvt_ShadowChanPressure:   ; entry: pointer-table entry
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,SeqEvt_PressureShadow
	ld a, (0x60f30a:24)
	set 0x07,A
	ld	(xix+hl), a
	ret
; SeqEvt_PostChanPressure -- post a deferred channel pressure for sequencer slot (0x60F31D): {0xB4, part, E, 0x7F} published to 0x2C00 when the slot's apply bit is set, then notified to MIDI out unless the slot's output byte is 0x20
; Evidence: `ld C,0xb4`; part = IdentityMap32_FAF7A6[(0x603422)[slot]]; SeqEvt_SlotApplyBit, T_Queue2C00_PublishStagedIfPending, T_ParamChange_Notify (0xFAF196-0xFAF20A).  0xB4 is ParamMsg_B4_ChannelPressure.  Called from SeqEvt_FlushShadows' 0x60F630 sweep.
SeqEvt_PostChanPressure:
	ld c, 0xb4:opc
	ld XIX,BStore_TrackToPart
	ld l, (0x60f31d:24)
	ld	l, (xix+l)
	ld XIX,IdentityMap32_FAF7A6
	ld	b, (xix+l)
	ld (0x60f0bc:24), bc
	ld d, 0x7f:opc
	ld (0x60f0be:24), de
	call SeqEvt_SlotApplyBit
	jr nc, .LFAF1DB
	ld wa, (0x60f0bc:24)
	ld (0x60f080:24), wa
	ld wa, (0x60f0be:24)
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
.LFAF1DB:
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld XIX,0x00603433
	ld	a, (xix+l)
	cp A,0x20
	jr z, .LFAF20A
	set 0x07,A
	ld (0x60f007:24), a
	ld bc, (0x60f0bc:24)
	ld de, (0x60f0be:24)
	call T_ParamChange_Notify
.LFAF20A:
	ret
; SeqEvt_ShadowModulation -- 0xD1 arm of SeqEvt_ApplyCtrlEvent: defer a modulation value, (0x60F5B0)[slot] = value | 0x80
; Evidence: arm 1 of the 4-entry table at 0xFAF16C -- the LE32 word at 0xFAF170 reads 0x00FAF20B; reader `ld XIX,0x00faf16c` at 0xFAF15E, index (0x60F308) & 3.  SeqEvt_FlushShadows posts 0x60F5B0 through SeqEvt_PostModulation (`ld C,0xb2`); ParamShadow_FlushAll walks the same array with W = 0xB2.
SeqEvt_ShadowModulation:   ; entry: pointer-table entry
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,SeqEvt_ModulationShadow
	ld a, (0x60f30a:24)
	set 0x07,A
	ld	(xix+hl), a
	ret
; SeqEvt_PostModulation -- post a deferred modulation value for sequencer slot (0x60F31D): {0xB2, part, E, 0x7F} published when the slot's apply bit is set, then notified to MIDI out unless the slot's output byte is 0x20
; Evidence: `ld C,0xb2`; part = IdentityMap32_FAF7A6[(0x603422)[slot]]; SeqEvt_SlotApplyBit, T_Queue2C00_PublishStagedIfPending, T_ParamChange_Notify (0xFAF225-0xFAF299).  0xB2 is ParamMsg_B2_CC01_Modulation.  Called from SeqEvt_FlushShadows' 0x60F5B0 sweep.
SeqEvt_PostModulation:
	ld c, 0xb2:opc
	ld XIX,BStore_TrackToPart
	ld l, (0x60f31d:24)
	ld	l, (xix+l)
	ld XIX,IdentityMap32_FAF7A6
	ld	b, (xix+l)
	ld (0x60f0bc:24), bc
	ld d, 0x7f:opc
	ld (0x60f0be:24), de
	call SeqEvt_SlotApplyBit
	jr nc, .LFAF26A
	ld wa, (0x60f0bc:24)
	ld (0x60f080:24), wa
	ld wa, (0x60f0be:24)
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
.LFAF26A:
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld XIX,0x00603433
	ld	a, (xix+l)
	cp A,0x20
	jr z, .LFAF299
	set 0x07,A
	ld (0x60f007:24), a
	ld bc, (0x60f0bc:24)
	ld de, (0x60f0be:24)
	call T_ParamChange_Notify
.LFAF299:
	ret
; SeqEvt_ShadowPitchBend -- 0xD2 arm of SeqEvt_ApplyCtrlEvent: defer a pitch-bend pair, 16-bit (0x60F5D0)[2*slot] = (word & 0x7F7F) with bit 7 of the low byte as pending flag
; Evidence: arm 2 of the 4-entry table at 0xFAF16C -- the LE32 word at 0xFAF174 reads 0x00FAF29A; reader `ld XIX,0x00faf16c` at 0xFAF15E, index (0x60F308) & 3.  SeqEvt_FlushShadows posts 0x60F5D0 through SeqEvt_PostPitchBend (`ld C,0xb1`); 0x60F5D0 is ParamShadow_SetPitchBend's 16-bit array.
SeqEvt_ShadowPitchBend:   ; entry: pointer-table entry
	extz HL
	ld l, (0x60f31d:24)
	sll l, 0x01
	ld XIX,SeqEvt_PitchBendShadow
	ld wa, (0x60f30a:24)
	and WA,0x7f7f
	set 0x07,A
	ld	(xix+hl), wa
	ret
; SeqEvt_PostPitchBend -- post a deferred pitch bend for sequencer slot (0x60F31D): {0xB1, part, LSB, MSB} published through T_Queue2C00_PublishStagedDrainPassB when the slot's apply bit is set, then notified to MIDI out unless the slot's output byte is 0x20
; Evidence: `ld C,0xb1`, `and DE,0x7f7f`; part = IdentityMap32_FAF7A6[(0x603422)[slot]]; SeqEvt_SlotApplyBit, T_Queue2C00_PublishStagedDrainPassB, T_ParamChange_Notify (0xFAF2BB-0xFAF331).  0xB1 is ParamMsg_B1_PitchBend.  Called from SeqEvt_FlushShadows' 0x60F5D0 sweep.
SeqEvt_PostPitchBend:
	ld c, 0xb1:opc
	ld XIX,BStore_TrackToPart
	ld l, (0x60f31d:24)
	ld	l, (xix+l)
	ld XIX,IdentityMap32_FAF7A6
	ld	b, (xix+l)
	ld (0x60f0bc:24), bc
	and DE,0x7f7f
	ld (0x60f0be:24), de
	call SeqEvt_SlotApplyBit
	jr nc, .LFAF302
	ld wa, (0x60f0bc:24)
	ld (0x60f080:24), wa
	ld wa, (0x60f0be:24)
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedDrainPassB
.LFAF302:
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld XIX,0x00603433
	ld	a, (xix+l)
	cp A,0x20
	jr z, .LFAF331
	set 0x07,A
	ld (0x60f007:24), a
	ld bc, (0x60f0bc:24)
	ld de, (0x60f0be:24)
	call T_ParamChange_Notify
.LFAF331:
	ret
; SeqEvt_ShadowExpression -- 0xD3 arm of SeqEvt_ApplyCtrlEvent: defer an expression value, (0x60F590)[slot] = value | 0x80, unless bit 7 of (0x34D1) is set, in which case post {0xB3, part, value, 0x7F} at once
; Evidence: arm 3 of the 4-entry table at 0xFAF16C -- the LE32 word at 0xFAF178 reads 0x00FAF332; reader `ld XIX,0x00faf16c` at 0xFAF15E, index (0x60F308) & 3.  `bit 7,(0x34d1)` gate; the immediate path at 0xFAF352 loads `ld C,0xb3` and publishes/notifies like SeqEvt_PostModulation; 0x60F590 is ParamShadow_SetExpression's array.  SeqEvt_FlushShadows calls 0xFAF352 for this array.
SeqEvt_ShadowExpression:   ; entry: pointer-table entry
	ld e, (0x60f30a:24)
	extz HL
	ld l, (0x60f31d:24)
	bit	7, (0x34d1:16)
	jr nz, .LFAF352
	set 0x07,E
	ld XIX,SeqEvt_ExpressionShadow
	ld	(xix+hl), e
	ret
.LFAF352:
	ldw bc, 0x01b0
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld	a, (xix+hl)
	ld c, 0xb3:opc
	ld XIX,IdentityMap32_FAF7A6
	ld	b, (xix+a)
	ld (0x60f0bc:24), bc
	ld d, 0x7f:opc
	ld (0x60f0be:24), de
	call SeqEvt_SlotApplyBit
	jr nc, .LFAF3CC
	cp	(0x60f0bc:24), 0xb0
	jr z, .LFAF3A6
	ld wa, (0x60f0bc:24)
	ld (0x60f080:24), wa
	ld wa, (0x60f0be:24)
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
	jr .LFAF3CC
.LFAF3A6:
	bit	7, (0x34d1:16)
	jr nz, .LFAF3B2
	bit	7, (0x34d8:16)
	jr z, .LFAF3F8
.LFAF3B2:
	ld a, (0x60f0be:24)
	set 0x07,A
	ld (0x24f0:16), a
	call T_ParamB0_PublishField0IfPending
	bit	7, (0x34d1:16)
	jr z, .LFAF3CC
	res	7, (0x34d1:16)
.LFAF3CC:
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,0x00603433
	ld	a, (xix+hl)
	cp A,0x20
	jr z, .LFAF3F8
	set 0x07,A
	ld (0x60f007:24), a
	ld bc, (0x60f0bc:24)
	ld de, (0x60f0be:24)
	call T_ParamChange_Notify
.LFAF3F8:
	ret
; SeqEvt_SelectCtrlEventSlot -- for a 0xDn playback event, take the slot from byte +3 (byte +4 for D2, which has two data bytes) into (0x60F31D) and accept it only if the slot's part (0x603422)[slot] is in IdentityMap32_FAF7C7 (0..0x1F); otherwise invalidate the event ((0x60F308) = 0xFF)
; Evidence: `and L,0x03` dispatch through the 4-entry table at 0xFAF410 (reader at 0xFAF404); the arms 0xFAF420/0xFAF431/0xFAF453 load L = (0x60F30B), 0xFAF442 loads L = (0x60F30C); shared search loop 0xFAF462-0xFAF48E (`djnz16` over 0x20 entries).  Called only by SeqEvt_ApplyCtrlEvent.
SeqEvt_SelectCtrlEventSlot:
	ld l, (0x60f308:24)
	and L,0x03
	sll l, 0x02
	ld XIX,SeqEvt_SelectCtrlEventSlot_StatusHandlers
	ld	xix, (xix+l)
	jp (xix)
; --- 0xFAF410-0xFAF420  pointer table (16 bytes) ---
; SeqEvt_SelectCtrlEventSlot_StatusHandlers: SeqEvt_SelectCtrlEventSlot's switch on the 0xDn event status & 3 (D0
;   channel pressure, D1 modulation, D2 pitch bend, D3 expression): each arm loads the event's slot byte and joins the
;   part-validity search. Basis: table index (status, the SeqBuf_Put*Event codes) + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
SeqEvt_SelectCtrlEventSlot_StatusHandlers:
	.long SeqEvt_SelectChanPressureSlot   ; -> SeqEvt_SelectChanPressureSlot   ; FAF410
	.long SeqEvt_SelectModulationSlot   ; -> SeqEvt_SelectModulationSlot   ; FAF414
	.long SeqEvt_SelectPitchBendSlot   ; -> SeqEvt_SelectPitchBendSlot   ; FAF418
	.long SeqEvt_SelectExpressionSlot   ; -> SeqEvt_SelectExpressionSlot   ; FAF41C
; ---------------------------------------------------------------------
; SeqEvt_SelectChanPressureSlot -- arm 0 of the 4-entry jump table at 0xFAF410
;
; Called from: the reader `ld XIX,0x00faf410` at 0xFAF404, through XIX/XIY.
;          Index: (0x60F308) & 3.
; Owner:   the routine at 0xFAF332.
; Body:    starts `ld XIY,0x00faf7c7`.
; Evidence: the LE32 word at 0xFAF410 reads 0x00FAF420, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names (0x60F308) & 3, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
; SeqEvt_SelectChanPressureSlot: SeqEvt_SelectCtrlEventSlot_StatusHandlers[D0 & 3] (channel pressure event): L = the
;   slot, (0x60F30B), byte +3; then the shared search accepts it only if the slot's part is 0..0x1F. Basis: table
;   index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
SeqEvt_SelectChanPressureSlot:   ; entry: pointer-table entry
	ld XIY,IdentityMap32_FAF7C7
	ld XBC,0x00000020
	ld l, (0x60f30b:24)
	jr .LFAF462
; ---------------------------------------------------------------------
; SeqEvt_SelectModulationSlot -- arm 1 of the 4-entry jump table at 0xFAF410
;
; Called from: the reader `ld XIX,0x00faf410` at 0xFAF404, through XIX/XIY.
;          Index: (0x60F308) & 3.
; Owner:   the routine at 0xFAF332.
; Body:    starts `ld XIY,0x00faf7c7`.
; Evidence: the LE32 word at 0xFAF414 reads 0x00FAF431, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names (0x60F308) & 3, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
; SeqEvt_SelectModulationSlot: SeqEvt_SelectCtrlEventSlot_StatusHandlers[D1 & 3] (modulation event): L = the slot,
;   (0x60F30B), byte +3; then the shared search accepts it only if the slot's part is 0..0x1F. Basis: table index +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
SeqEvt_SelectModulationSlot:   ; entry: pointer-table entry
	ld XIY,IdentityMap32_FAF7C7
	ld XBC,0x00000020
	ld l, (0x60f30b:24)
	jr .LFAF462
; ---------------------------------------------------------------------
; SeqEvt_SelectPitchBendSlot -- arm 2 of the 4-entry jump table at 0xFAF410
;
; Called from: the reader `ld XIX,0x00faf410` at 0xFAF404, through XIX/XIY.
;          Index: (0x60F308) & 3.
; Owner:   the routine at 0xFAF332.
; Body:    starts `ld XIY,0x00faf7c7`.
; Evidence: the LE32 word at 0xFAF418 reads 0x00FAF442, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names (0x60F308) & 3, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
; SeqEvt_SelectPitchBendSlot: SeqEvt_SelectCtrlEventSlot_StatusHandlers[D2 & 3] (pitch bend event): L = the slot,
;   (0x60F30C), byte +4 (two data bytes); then the shared search accepts it only if the slot's part is 0..0x1F. Basis:
;   table index + body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
SeqEvt_SelectPitchBendSlot:   ; entry: pointer-table entry
	ld XIY,IdentityMap32_FAF7C7
	ld XBC,0x00000020
	ld l, (0x60f30c:24)
	jr .LFAF462
; ---------------------------------------------------------------------
; SeqEvt_SelectExpressionSlot -- arm 3 of the 4-entry jump table at 0xFAF410
;
; Called from: the reader `ld XIX,0x00faf410` at 0xFAF404, through XIX/XIY.
;          Index: (0x60F308) & 3.
; Owner:   the routine at 0xFAF332.
; Body:    starts `ld XIY,0x00faf7c7`.
; Evidence: the LE32 word at 0xFAF41C reads 0x00FAF453, and no other
;          entry of that table does.
; Unknown:  what the selector means.  Nothing in the tree
;          names (0x60F308) & 3, so this label stays sub_XXXXXX.
; ---------------------------------------------------------------------
; SeqEvt_SelectExpressionSlot: SeqEvt_SelectCtrlEventSlot_StatusHandlers[D3 & 3] (expression event): L = the slot,
;   (0x60F30B), byte +3; then the shared search accepts it only if the slot's part is 0..0x1F. Basis: table index +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
SeqEvt_SelectExpressionSlot:   ; entry: pointer-table entry
	ld XIY,IdentityMap32_FAF7C7
	ld XBC,0x00000020
	ld l, (0x60f30b:24)
.LFAF462:
	cp XBC,0x00000000
	jr z, .LFAF488
	ld (0x60f31d:24), l
	ld XIX,BStore_TrackToPart
	ld	w, (xix+hl)
	ld (0x60f322:24), w
.LFAF47E:
	ld a, (xiy+)
	cp A,W
	jr z, .LFAF48E
	djnz16 bc, .LFAF47E
.LFAF488:
	ld (0x60f308:24), 0xff
.LFAF48E:
	ret
T_F41F20_Nop:
	ret
T_F41F28_Nop:
	ret
; SeqEvt_FlushShadows -- for each of the 17 sequencer slots, post every deferred value (bit 7 set) and clear its flag: 0x60F630 -> SeqEvt_PostChanPressure, 0x60F5B0 -> SeqEvt_PostModulation, 0x60F5D0 (16-bit) -> SeqEvt_PostPitchBend, 0x60F590 -> the expression post at 0xFAF352, 0x60F610 -> SeqEvt_PostPartVolume
; Evidence: five `ldw BC,0x11` sweeps with `bit 7,(XIY) / res 7,(XIY)` at 0xFAF491-0xFAF55C, each setting (0x60F31D) to the slot index before the call.
; Called from: the playback entry SeqEvt_PlayRun (directory T_F41F10) and the slot-reset routine SeqEvt_ResetPlayingSlotControllers (T_F41F18).
SeqEvt_FlushShadows:
	ld XIY,SeqEvt_PressureShadow
	ldw bc, 0x11
.LFAF499:
	bit 7,(XIY)
	jr z, .LFAF4B5
	res 7,(XIY)
	ld E,(XIY)
	ld XHL,XIY
	sub XHL,SeqEvt_PressureShadow
	ld (0x60f31d:24), l
	pushw bc
	push XIY
	calr SeqEvt_PostChanPressure
	pop XIY
	popw bc
.LFAF4B5:
	inc 1,XIY
	djnz16 bc, .LFAF499
	ld XIY,SeqEvt_ModulationShadow
	ldw bc, 0x11
.LFAF4C2:
	bit 7,(XIY)
	jr z, .LFAF4DE
	res 7,(XIY)
	ld E,(XIY)
	ld XHL,XIY
	sub XHL,SeqEvt_ModulationShadow
	ld (0x60f31d:24), l
	pushw bc
	push XIY
	calr SeqEvt_PostModulation
	pop XIY
	popw bc
.LFAF4DE:
	inc 1,XIY
	djnz16 bc, .LFAF4C2
	ld XIY,SeqEvt_PitchBendShadow
	ldw bc, 0x11
.LFAF4EB:
	bit 7,(XIY)
	jr z, .LFAF50A
	res 7,(XIY)
	ld DE,(XIY)
	ld XHL,XIY
	sub XHL,SeqEvt_PitchBendShadow
	srl l, 0x01
	ld (0x60f31d:24), l
	pushw bc
	push XIY
	calr SeqEvt_PostPitchBend
	pop XIY
	popw bc
.LFAF50A:
	inc 2,XIY
	djnz16 bc, .LFAF4EB
	ld XIY,SeqEvt_ExpressionShadow
	ldw bc, 0x11
.LFAF517:
	bit 7,(XIY)
	jr z, .LFAF533
	res 7,(XIY)
	ld E,(XIY)
	ld XHL,XIY
	sub XHL,SeqEvt_ExpressionShadow
	ld (0x60f31d:24), l
	pushw bc
	push XIY
	calr .LFAF352
	pop XIY
	popw bc
.LFAF533:
	inc 1,XIY
	djnz16 bc, .LFAF517
	ld XIY,SeqEvt_VolumeShadow
	ldw bc, 0x11
.LFAF540:
	bit 7,(XIY)
	jr z, .LFAF55C
	res 7,(XIY)
	ld E,(XIY)
	ld HL,IY
	sub XHL,SeqEvt_VolumeShadow
	ld (0x60f31d:24), l
	pushw bc
	push XIY
	calr SeqEvt_PostPartVolume
	pop XIY
	popw bc
.LFAF55C:
	inc 1,XIY
	djnz16 bc, .LFAF540
	ret
; SeqEvt_SlotApplyBit -- carry = bit (0x60F31D) of the 32-bit slot mask (0x603454)
; Evidence: `ld XWA,(0x603454) / ld C,(0x60f31d) / inc 1,C / srl 0x01,XWA / djnz8` at 0xFAF562-0xFAF574, registers saved around it.  All ten callers (the SeqEvt_* handlers) `jr nc` past the record write / publish and still send the MIDI-out notify, so the bit gates the internal application only.
SeqEvt_SlotApplyBit:
	push XWA
	pushw bc
	ld xwa, (0x603454:24)
	ld c, (0x60f31d:24)
	inc 1,C
.LFAF570:
	srl xwa, 0x01
	djnz8 c, .LFAF570
	popw bc
	pop XWA
	ret
; Regs_SaveAllScratch -- store XWA, XBC, XDE, XHL, XIX, XIY and XIZ to RAM 0x60F090..0x60F0AB
; Evidence: seven `ld (0x60f090/94/98/9c/a0/a4/a8),Xrr` at 0xFAF579-0xFAF59C.  Called only from the SeqBuf append tail at 0xFAEC0F, before `call T_SeqRecord_StartOnFirstEvent` when (0x60F01E) == 0xFF; Regs_RestoreAllScratch undoes it.
Regs_SaveAllScratch:
	ld (0x60f090:24), xwa
	ld (0x60f094:24), xbc
	ld (0x60f098:24), xde
	ld (0x60f09c:24), xhl
	ld (0x60f0a0:24), xix
	ld (0x60f0a4:24), xiy
	ld (0x60f0a8:24), xiz
	ret
; Regs_RestoreAllScratch -- reload XWA, XBC, XDE, XHL, XIX, XIY and XIZ from RAM 0x60F090..0x60F0AB
; Evidence: seven `ld Xrr,(0x60f090..0x60f0a8)` at 0xFAF59D-0xFAF5C0, the inverse of Regs_SaveAllScratch; called only after `call T_SeqRecord_StartOnFirstEvent` in the SeqBuf append tail.
Regs_RestoreAllScratch:
	ld xwa, (0x60f090:24)
	ld xbc, (0x60f094:24)
	ld xde, (0x60f098:24)
	ld xhl, (0x60f09c:24)
	ld xix, (0x60f0a0:24)
	ld xiy, (0x60f0a4:24)
	ld xiz, (0x60f0a8:24)
	ret
; SeqEvt_ApplyProgramEvent -- playback of a 0xCn sequencer event: apply the recorded sound bytes to the event's part (record bytes 0/1 and second-half +0x1B..+0x1D), publish class 1 and class 0 when the slot's apply bit is set, then notify bank select / program by PROG CHANGE MODE
; Evidence: the LE32 word at 0xFAEE00 reads 0x00FAF5C1 (entry 4 of the table at 0xFAEDF0, reader `ld XIY,0x00faedf0` at 0xFAEDE1); SeqEvt_UnpackProgramBit7; `ld (XIX+0x3b),L / (XIX+0x3c),H / (XIX+0x3d),W` after T_SoundSel_FromProgramAndBankRegs; stages {num,1,..,0x7F} and {num,0,..,0xFF}.
; Then `ld L,(0x7f32) / and L,0x03` through the 4-entry table at 0xFAF6B8: SeqEvt_ProgChgNormal_Notify, SeqEvt_ProgChgTech_Notify, nothing (REMAP and value 3).  The decode side of SeqBuf_PutProgramEvent.
SeqEvt_ApplyProgramEvent:   ; entry: pointer-table entry
	calr SeqEvt_UnpackProgramBit7
	cp	(0x60f308:24), 0xff
	jrl z, SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2
	ld XIX,0x0060f30a
	ld bc, (xix+)
	ld de, (xix+)
	ld A,(XIX)
	ld (0x60f31d:24), a
	extz HL
	ld L,C
	sll hl, 0x02
	ld xix, (IndexedTable_Base:24)
	ld	xix, (xix+hl)
	cp XIX,0xffffffff
	jrl z, SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2
	ld (0x60f0bc:24), bc
	ld (0x60f0be:24), de
	ld (0x60f01d:24), c
	ld HL,DE
	call T_SoundSel_FromProgramAndBankRegs
	ld (0x60f324:24), hl
	ld (0x60f326:24), w
	call SeqEvt_SlotApplyBit
	jr nc, .LFAF676
	ld (XIX+0x3b),L
	ld (XIX+0x3c),H
	ld (XIX+0x3d),W
	call T_F407E8
	and (XIX+0x01),0x80
	ld a, (0x60f0bf:24)
	or (XIX+0x01),A
	ld a, (0x60f0be:24)
	ld (XIX),A
	ld a, (0x60f0bc:24)
	ld w, 0x01:opc
	ld (0x60f080:24), wa
	ld a, (0x60f0bf:24)
	ld w, 0x7f:opc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
	ld a, (0x60f0bc:24)
	ld w, 0x00:opc
	ld (0x60f080:24), wa
	ld a, (0x60f0be:24)
	ld w, 0xff:opc
	ld (0x60f082:24), wa
	call T_Queue2C00_PublishStagedIfPending
.LFAF676:
	xor H,H
	ld l, (0x60f31d:24)
	ld XIX,BStore_TrackToPart
	ld	a, (xix+hl)
	ld XIX,0x00603433
	ld	a, (xix+hl)
	cp A,0x20
	jrl z, SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2
	set 0x07,A
	ld (0x60f007:24), a
	extz HL
	ld l, (MidiCfg_ModeBits:16)
	and L,0x03
	sll hl, 0x02
	ld XIX,SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8
	ld	xix, (xix+hl)
	jp (xix)
; --- 0xFAF6B7-0xFAF6B8  align (1 bytes) ---
	.byte 0x00   ; FAF6B7
; --- 0xFAF6B8-0xFAF6C8  pointer table (16 bytes) ---
SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8:
	.long SeqEvt_ProgChgNormal_Notify   ; -> SeqEvt_ProgChgNormal_Notify   ; FAF6B8
	.long SeqEvt_ProgChgTech_Notify   ; -> SeqEvt_ProgChgTech_Notify   ; FAF6BC
	.long SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2   ; -> SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2   ; FAF6C0
	.long SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2   ; -> SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2   ; FAF6C4
; SeqEvt_ProgChgNormal_Notify -- PROG CHANGE MODE NORMAL arm of SeqEvt_ApplyProgramEvent: notify bank select (param 0x81) and program (class 0) to MIDI out from the bytes just written to +0x3B..+0x3D
; Evidence: arm 0 of the 4-entry table at 0xFAF6B8 -- the LE32 word at 0xFAF6B8 reads 0x00FAF6C8; reader `ld XIX,0x00faf6b8` at 0xFAF6AB, index (0x7F32) & 3 = PROG CHANGE MODE (DLTable_NormalTechRemap[0] = "NORMAL").
; Body: GM drum parts 9/0x19 take the TECH arm; else T_ParamChange_Notify {0x81, part, (0x60F326) split} and {part, 0, ((0x60F324)<<3)|((0x60F325)&7), 0xFF}, with (0x60F007) = (0x603433)[slot] | 0x80.
SeqEvt_ProgChgNormal_Notify:   ; entry: pointer-table entry
	bit	2, (0x7f4d:16)
	jr z, .LFAF6D8
	cp C,0x09
	jr z, .LFAF728
	cp C,0x19
	jr z, .LFAF728
.LFAF6D8:
	ld c, 0x81:opc
	ld b, (0x60f0bc:24)
	extz DE
	ld e, (0x60f326:24)
	sll de, 0x05
	srl e, 0x01
	call T_ParamChange_Notify
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,0x00603433
	ld	a, (xix+hl)
	set 0x07,A
	ld (0x60f007:24), a
	ld bc, (0x60f0bc:24)
	ld e, (0x60f325:24)
	and E,0x07
	ld d, (0x60f324:24)
	sll d, 0x03
	or E,D
	ld d, 0xff:opc
	call T_ParamChange_Notify
	jr .LFAF771
.LFAF728:
; SeqEvt_ProgChgTech_Notify -- PROG CHANGE MODE TECH arm of SeqEvt_ApplyProgramEvent: notify bank select (param 0x81) from the event's byte +1 and program (class 0) from byte +0
; Evidence: arm 1 of the 4-entry table at 0xFAF6B8 -- the LE32 word at 0xFAF6BC reads 0x00FAF728; reader `ld XIX,0x00faf6b8` at 0xFAF6AB, index (0x7F32) & 3 (DLTable_NormalTechRemap[1] = "TECH").
; Body: T_ParamChange_Notify {0x81, part, (0x60F0BF)&0x3F split} and {part, 0, (0x60F0BE)&0x7F, 0xFF}; falls into the shared `ret` 0xFAF771.
SeqEvt_ProgChgTech_Notify:   ; entry: pointer-table entry
	ld b, (0x60f0bc:24)
	ld c, 0x81:opc
	extz DE
	ld e, (0x60f0bf:24)
	and E,0x3f
	sll de, 0x05
	srl e, 0x01
	call T_ParamChange_Notify
	extz HL
	ld l, (0x60f31d:24)
	ld XIX,0x00603433
	ld	a, (xix+hl)
	set 0x07,A
	ld (0x60f007:24), a
	ld c, (0x60f0bc:24)
	ld b, 0x00:opc
	ld e, (0x60f0be:24)
	res 0x07,E
	ld d, 0xff:opc
	call T_ParamChange_Notify
.LFAF771:
; ---------------------------------------------------------------------
; SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2 -- arm 2, 3 of the 4-entry jump table at 0xFAF6B8
;
; Called from: the reader `ld XIX,0x00faf6b8` at 0xFAF6AB, through XIX/XIY.
;          Index: (0x7F32) & 3.
; Owner:   the routine at 0xFAF5C1.
; Body:    starts `ret`.
; Evidence: the LE32 words at 0xFAF6C0, 0xFAF6C4 reads 0x00FAF771, and no other
;          entry of that table does.
; Unknown:  ⚠ WHAT THE FOUR VALUES OF (0x7F32) & 3 SELECT.
;          SIX tables in this span are indexed by that same
;          2-bit field; prom_b 0xF6F858 copies it from
;          (0x1380) & 3 and posts it as {0x80, 0, v, 0x03}.
;          That names the producer, not the meaning, so this
;          label stays sub_XXXXXX.  A stated gap beats a
;          plausible guess.
; ---------------------------------------------------------------------
SeqEvt_ApplyProgramEvent_JumpTable_FAF6B8_Nop2:   ; entry: pointer-table entry
	ret
; DspEffect_RepostRotarySpeakerAlgorithm: For each DSP effect block 0x61/0x62/0x63 whose algorithm byte
;   ((0x7642)/(0x7662)/(0x7682)) is 0x35 = ROTARY SPEAKER (EffectNames entry 53), queues {0x61+n, 0, 0x35, 0xFF}
;   through Queue2E00_AppendRegs, re-posting that algorithm. Called by SeqEvt_ResetPlayingSlotControllers after it
;   reset the playing slots' controllers. Basis: caller + body + effect table. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
DspEffect_RepostRotarySpeakerAlgorithm:
	cp	(0x7642:16), 0x35
	jr nz, .LFAF783
	ldw de, 0x61
	ldw wa, 0xff35
	call T_Queue2E00_AppendRegs
.LFAF783:
	cp	(0x7662:16), 0x35
	jr nz, .LFAF794
	ldw de, 0x62
	ldw wa, 0xff35
	call T_Queue2E00_AppendRegs
.LFAF794:
	cp	(0x7682:16), 0x35
	jr nz, .LFAF7A5
	ldw de, 0x63
	ldw wa, 0xff35
	call T_Queue2E00_AppendRegs
.LFAF7A5:
	ret
; ---------------------------------------------------------------------
; 0xFAF7A6-0xFB178F -- two identity maps and two tables of 33 KEY/VALUE record
; lists, framed by their readers (notes/proma-2026-09-25/gen_kvlists.py)
;
; This stretch sat under the local label `.LFAF7A5`, the `ret` before it, and its
; pointer entries were annotated `-> sub_FAF86C` as if they named routines.  They
; name record LISTS that code copies and searches:
;   SeqBuf_LoadSlotKeyList (0xFAEBEC): L = RAM(0x603422 + (0x60F31C)); XIY =
;     KeyValueListPtrs_A[L]; copies LE16 words to RAM 0x60F330 until a word
;     whose low byte is 0xFF.  .LFAF0C1 does the same with (0x60F31D) and
;     KeyValueListPtrs_B (0xFAF0DB).
;   SeqEvt_LookupParamType (0xFAF094-0xFAF0A9) walks the copy two words at a time,
;     compares the FIRST word with BC (from (0x60F30A), bit 7 of C/E/D set from
;     bits 2/0/1 of (0x60F308)) and on a match takes the SECOND.
; So a record is (key LE16, value LE16), and a list ends with a record whose
; key's low byte is 0xFF -- 8 bytes of 0xFF (16 after the 33rd).  33 lists:
; 32 of equal length (27 records in A, 22 in B) and a short 33rd (1 and 0).
; ⚠ What a key or a value denotes is not claimed: the keys pair a byte from
; 0xA0-0xBF or 0x00-0x23 with the list's own index 0..31, and the values
; look like (mask 0x01/0x3F/0x7F/0xFF, count) pairs -- a description of the
; bytes, not a decode.
; ---------------------------------------------------------------------

; IdentityMap32_FAF7A6 -- 32 bytes, 0x00..0x1F.
; Read by: 0xFAED53 `ld XIY,0x00FAF7A6 / ld W,(XIY+HL)`, indexed by a slot
;          number read from RAM 0x603422, and `ld XIX,0x00FAF7A6` at 0xFAEF54,
;          0xFAF1A7, 0xFAF236, 0xFAF2CC and 0xFAF368.  Every entry is its own
;          index (an identity translation in this build).
IdentityMap32_FAF7A6:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FAF7A6
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  ; FAF7B6
	.byte 0x00                                    ; FAF7C6  one byte between the two maps

; IdentityMap32_FAF7C7 -- 32 bytes, 0x00..0x1F, the same content.
; Read by: `ld XIY,0x00FAF7C7` at 0xFAF420 (SeqEvt_SelectChanPressureSlot, with XBC = 0x20),
;          0xFAF431, 0xFAF442 and 0xFAF453 -- the four arms of the jump table
;          at 0xFAF410.
IdentityMap32_FAF7C7:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FAF7C7
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f  ; FAF7D7
	.byte 0x00                                    ; FAF7E7  one byte of alignment slack

; KeyValueListPtrs_A -- 33 pointers to the key/value record lists below.
; Read by: SeqBuf_LoadSlotKeyList at 0xFAEBEC `ld XIX,0x00FAF7E8`; index L = RAM(0x603422 + the slot byte).
; COUNT 33 is the extent to the first list, and every target is a list start.
KeyValueListPtrs_A:
	.long KeyValueList_A00                      ; FAF7E8  [ 0]
	.long KeyValueList_A01                      ; FAF7EC  [ 1]
	.long KeyValueList_A02                      ; FAF7F0  [ 2]
	.long KeyValueList_A03                      ; FAF7F4  [ 3]
	.long KeyValueList_A04                      ; FAF7F8  [ 4]
	.long KeyValueList_A05                      ; FAF7FC  [ 5]
	.long KeyValueList_A06                      ; FAF800  [ 6]
	.long KeyValueList_A07                      ; FAF804  [ 7]
	.long KeyValueList_A08                      ; FAF808  [ 8]
	.long KeyValueList_A09                      ; FAF80C  [ 9]
	.long KeyValueList_A10                      ; FAF810  [10]
	.long KeyValueList_A11                      ; FAF814  [11]
	.long KeyValueList_A12                      ; FAF818  [12]
	.long KeyValueList_A13                      ; FAF81C  [13]
	.long KeyValueList_A14                      ; FAF820  [14]
	.long KeyValueList_A15                      ; FAF824  [15]
	.long KeyValueList_A16                      ; FAF828  [16]
	.long KeyValueList_A17                      ; FAF82C  [17]
	.long KeyValueList_A18                      ; FAF830  [18]
	.long KeyValueList_A19                      ; FAF834  [19]
	.long KeyValueList_A20                      ; FAF838  [20]
	.long KeyValueList_A21                      ; FAF83C  [21]
	.long KeyValueList_A22                      ; FAF840  [22]
	.long KeyValueList_A23                      ; FAF844  [23]
	.long KeyValueList_A24                      ; FAF848  [24]
	.long KeyValueList_A25                      ; FAF84C  [25]
	.long KeyValueList_A26                      ; FAF850  [26]
	.long KeyValueList_A27                      ; FAF854  [27]
	.long KeyValueList_A28                      ; FAF858  [28]
	.long KeyValueList_A29                      ; FAF85C  [29]
	.long KeyValueList_A30                      ; FAF860  [30]
	.long KeyValueList_A31                      ; FAF864  [31]
	.long KeyValueList_A32                      ; FAF868  [32]

; KeyValueList_A00 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[0].
KeyValueList_A00:
	.short 0x00b4, 0x067f, 0x00b1, 0x037f, 0x00b2, 0x047f, 0x00b5, 0x017f  ; FAF86C
	.short 0x00b3, 0x057f, 0x00b7, 0x017f, 0x00b6, 0x017f, 0x00bc, 0x017f  ; FAF87C
	.short 0x00bd, 0x017f, 0x00b8, 0x017f, 0x00b9, 0x017f, 0x00ba, 0x017f  ; FAF88C
	.short 0x00bb, 0x017f, 0x0000, 0x00ff, 0x0300, 0x017f, 0x0500, 0x017f  ; FAF89C
	.short 0x0600, 0x017f, 0x0700, 0x017f, 0x0800, 0x017f, 0x0b00, 0x017f  ; FAF8AC
	.short 0x0a00, 0x01ff, 0x0900, 0x017f, 0x1820, 0x0101, 0x1a20, 0x013f  ; FAF8BC
	.short 0x1920, 0x013f, 0x00ad, 0x017f, 0x00ae, 0x017f  ; FAF8CC
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAF8D8  terminator

; KeyValueList_A01 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[1].
KeyValueList_A01:
	.short 0x01b4, 0x067f, 0x01b1, 0x037f, 0x01b2, 0x047f, 0x01b5, 0x017f  ; FAF8E0
	.short 0x01b3, 0x057f, 0x01b7, 0x017f, 0x01b6, 0x017f, 0x01bc, 0x017f  ; FAF8F0
	.short 0x01bd, 0x017f, 0x01b8, 0x017f, 0x01b9, 0x017f, 0x01ba, 0x017f  ; FAF900
	.short 0x01bb, 0x017f, 0x0001, 0x00ff, 0x0301, 0x017f, 0x0501, 0x017f  ; FAF910
	.short 0x0601, 0x017f, 0x0701, 0x017f, 0x0801, 0x017f, 0x0b01, 0x017f  ; FAF920
	.short 0x0a01, 0x01ff, 0x0901, 0x017f, 0x1821, 0x0101, 0x1a21, 0x013f  ; FAF930
	.short 0x1921, 0x013f, 0x01ad, 0x017f, 0x01ae, 0x017f  ; FAF940
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAF94C  terminator

; KeyValueList_A02 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[2].
KeyValueList_A02:
	.short 0x02b4, 0x067f, 0x02b1, 0x037f, 0x02b2, 0x047f, 0x02b5, 0x017f  ; FAF954
	.short 0x02b3, 0x057f, 0x02b7, 0x017f, 0x02b6, 0x017f, 0x02bc, 0x017f  ; FAF964
	.short 0x02bd, 0x017f, 0x02b8, 0x017f, 0x02b9, 0x017f, 0x02ba, 0x017f  ; FAF974
	.short 0x02bb, 0x017f, 0x0002, 0x00ff, 0x0302, 0x017f, 0x0502, 0x017f  ; FAF984
	.short 0x0602, 0x017f, 0x0702, 0x017f, 0x0802, 0x017f, 0x0b02, 0x017f  ; FAF994
	.short 0x0a02, 0x01ff, 0x0902, 0x017f, 0x1822, 0x0101, 0x1a22, 0x013f  ; FAF9A4
	.short 0x1922, 0x013f, 0x02ad, 0x017f, 0x02ae, 0x017f  ; FAF9B4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAF9C0  terminator

; KeyValueList_A03 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[3].
KeyValueList_A03:
	.short 0x03b4, 0x067f, 0x03b1, 0x037f, 0x03b2, 0x047f, 0x03b5, 0x017f  ; FAF9C8
	.short 0x03b3, 0x057f, 0x03b7, 0x017f, 0x03b6, 0x017f, 0x03bc, 0x017f  ; FAF9D8
	.short 0x03bd, 0x017f, 0x03b8, 0x017f, 0x03b9, 0x017f, 0x03ba, 0x017f  ; FAF9E8
	.short 0x03bb, 0x017f, 0x0003, 0x00ff, 0x0303, 0x017f, 0x0503, 0x017f  ; FAF9F8
	.short 0x0603, 0x017f, 0x0703, 0x017f, 0x0803, 0x017f, 0x0b03, 0x017f  ; FAFA08
	.short 0x0a03, 0x01ff, 0x0903, 0x017f, 0x1823, 0x0101, 0x1a23, 0x013f  ; FAFA18
	.short 0x1923, 0x013f, 0x03ad, 0x017f, 0x03ae, 0x017f  ; FAFA28
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFA34  terminator

; KeyValueList_A04 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[4].
KeyValueList_A04:
	.short 0x04b4, 0x067f, 0x04b1, 0x037f, 0x04b2, 0x047f, 0x04b5, 0x017f  ; FAFA3C
	.short 0x04b3, 0x057f, 0x04b7, 0x017f, 0x04b6, 0x017f, 0x04bc, 0x017f  ; FAFA4C
	.short 0x04bd, 0x017f, 0x04b8, 0x017f, 0x04b9, 0x017f, 0x04ba, 0x017f  ; FAFA5C
	.short 0x04bb, 0x017f, 0x0004, 0x00ff, 0x0304, 0x017f, 0x0504, 0x017f  ; FAFA6C
	.short 0x0604, 0x017f, 0x0704, 0x017f, 0x0804, 0x017f, 0x0b04, 0x017f  ; FAFA7C
	.short 0x0a04, 0x01ff, 0x0904, 0x017f, 0x1824, 0x0101, 0x1a24, 0x013f  ; FAFA8C
	.short 0x1924, 0x013f, 0x04ad, 0x017f, 0x04ae, 0x017f  ; FAFA9C
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFAA8  terminator

; KeyValueList_A05 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[5].
KeyValueList_A05:
	.short 0x05b4, 0x067f, 0x05b1, 0x037f, 0x05b2, 0x047f, 0x05b5, 0x017f  ; FAFAB0
	.short 0x05b3, 0x057f, 0x05b7, 0x017f, 0x05b6, 0x017f, 0x05bc, 0x017f  ; FAFAC0
	.short 0x05bd, 0x017f, 0x05b8, 0x017f, 0x05b9, 0x017f, 0x05ba, 0x017f  ; FAFAD0
	.short 0x05bb, 0x017f, 0x0005, 0x00ff, 0x0305, 0x017f, 0x0505, 0x017f  ; FAFAE0
	.short 0x0605, 0x017f, 0x0705, 0x017f, 0x0805, 0x017f, 0x0b05, 0x017f  ; FAFAF0
	.short 0x0a05, 0x01ff, 0x0905, 0x017f, 0x1825, 0x0101, 0x1a25, 0x013f  ; FAFB00
	.short 0x1925, 0x013f, 0x05ad, 0x017f, 0x05ae, 0x017f  ; FAFB10
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFB1C  terminator

; KeyValueList_A06 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[6].
KeyValueList_A06:
	.short 0x06b4, 0x067f, 0x06b1, 0x037f, 0x06b2, 0x047f, 0x06b5, 0x017f  ; FAFB24
	.short 0x06b3, 0x057f, 0x06b7, 0x017f, 0x06b6, 0x017f, 0x06bc, 0x017f  ; FAFB34
	.short 0x06bd, 0x017f, 0x06b8, 0x017f, 0x06b9, 0x017f, 0x06ba, 0x017f  ; FAFB44
	.short 0x06bb, 0x017f, 0x0006, 0x00ff, 0x0306, 0x017f, 0x0506, 0x017f  ; FAFB54
	.short 0x0606, 0x017f, 0x0706, 0x017f, 0x0806, 0x017f, 0x0b06, 0x017f  ; FAFB64
	.short 0x0a06, 0x01ff, 0x0906, 0x017f, 0x1826, 0x0101, 0x1a26, 0x013f  ; FAFB74
	.short 0x1926, 0x013f, 0x06ad, 0x017f, 0x06ae, 0x017f  ; FAFB84
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFB90  terminator

; KeyValueList_A07 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[7].
KeyValueList_A07:
	.short 0x07b4, 0x067f, 0x07b1, 0x037f, 0x07b2, 0x047f, 0x07b5, 0x017f  ; FAFB98
	.short 0x07b3, 0x057f, 0x07b7, 0x017f, 0x07b6, 0x017f, 0x07bc, 0x017f  ; FAFBA8
	.short 0x07bd, 0x017f, 0x07b8, 0x017f, 0x07b9, 0x017f, 0x07ba, 0x017f  ; FAFBB8
	.short 0x07bb, 0x017f, 0x0007, 0x00ff, 0x0307, 0x017f, 0x0507, 0x017f  ; FAFBC8
	.short 0x0607, 0x017f, 0x0707, 0x017f, 0x0807, 0x017f, 0x0b07, 0x017f  ; FAFBD8
	.short 0x0a07, 0x01ff, 0x0907, 0x017f, 0x1827, 0x0101, 0x1a27, 0x013f  ; FAFBE8
	.short 0x1927, 0x013f, 0x07ad, 0x017f, 0x07ae, 0x017f  ; FAFBF8
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFC04  terminator

; KeyValueList_A08 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[8].
KeyValueList_A08:
	.short 0x08b4, 0x067f, 0x08b1, 0x037f, 0x08b2, 0x047f, 0x08b5, 0x017f  ; FAFC0C
	.short 0x08b3, 0x057f, 0x08b7, 0x017f, 0x08b6, 0x017f, 0x08bc, 0x017f  ; FAFC1C
	.short 0x08bd, 0x017f, 0x08b8, 0x017f, 0x08b9, 0x017f, 0x08ba, 0x017f  ; FAFC2C
	.short 0x08bb, 0x017f, 0x0008, 0x00ff, 0x0308, 0x017f, 0x0508, 0x017f  ; FAFC3C
	.short 0x0608, 0x017f, 0x0708, 0x017f, 0x0808, 0x017f, 0x0b08, 0x017f  ; FAFC4C
	.short 0x0a08, 0x01ff, 0x0908, 0x017f, 0x1828, 0x0101, 0x1a28, 0x013f  ; FAFC5C
	.short 0x1928, 0x013f, 0x08ad, 0x017f, 0x08ae, 0x017f  ; FAFC6C
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFC78  terminator

; KeyValueList_A09 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[9].
KeyValueList_A09:
	.short 0x09b4, 0x067f, 0x09b1, 0x037f, 0x09b2, 0x047f, 0x09b5, 0x017f  ; FAFC80
	.short 0x09b3, 0x057f, 0x09b7, 0x017f, 0x09b6, 0x017f, 0x09bc, 0x017f  ; FAFC90
	.short 0x09bd, 0x017f, 0x09b8, 0x017f, 0x09b9, 0x017f, 0x09ba, 0x017f  ; FAFCA0
	.short 0x09bb, 0x017f, 0x0009, 0x00ff, 0x0309, 0x017f, 0x0509, 0x017f  ; FAFCB0
	.short 0x0609, 0x017f, 0x0709, 0x017f, 0x0809, 0x017f, 0x0b09, 0x017f  ; FAFCC0
	.short 0x0a09, 0x01ff, 0x0909, 0x017f, 0x1829, 0x0101, 0x1a29, 0x013f  ; FAFCD0
	.short 0x1929, 0x013f, 0x09ad, 0x017f, 0x09ae, 0x017f  ; FAFCE0
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFCEC  terminator

; KeyValueList_A10 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[10].
KeyValueList_A10:
	.short 0x0ab4, 0x067f, 0x0ab1, 0x037f, 0x0ab2, 0x047f, 0x0ab5, 0x017f  ; FAFCF4
	.short 0x0ab3, 0x057f, 0x0ab7, 0x017f, 0x0ab6, 0x017f, 0x0abc, 0x017f  ; FAFD04
	.short 0x0abd, 0x017f, 0x0ab8, 0x017f, 0x0ab9, 0x017f, 0x0aba, 0x017f  ; FAFD14
	.short 0x0abb, 0x017f, 0x000a, 0x00ff, 0x030a, 0x017f, 0x050a, 0x017f  ; FAFD24
	.short 0x060a, 0x017f, 0x070a, 0x017f, 0x080a, 0x017f, 0x0b0a, 0x017f  ; FAFD34
	.short 0x0a0a, 0x01ff, 0x090a, 0x017f, 0x182a, 0x0101, 0x1a2a, 0x013f  ; FAFD44
	.short 0x192a, 0x013f, 0x0aad, 0x017f, 0x0aae, 0x017f  ; FAFD54
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFD60  terminator

; KeyValueList_A11 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[11].
KeyValueList_A11:
	.short 0x0bb4, 0x067f, 0x0bb1, 0x037f, 0x0bb2, 0x047f, 0x0bb5, 0x017f  ; FAFD68
	.short 0x0bb3, 0x057f, 0x0bb7, 0x017f, 0x0bb6, 0x017f, 0x0bbc, 0x017f  ; FAFD78
	.short 0x0bbd, 0x017f, 0x0bb8, 0x017f, 0x0bb9, 0x017f, 0x0bba, 0x017f  ; FAFD88
	.short 0x0bbb, 0x017f, 0x000b, 0x00ff, 0x030b, 0x017f, 0x050b, 0x017f  ; FAFD98
	.short 0x060b, 0x017f, 0x070b, 0x017f, 0x080b, 0x017f, 0x0b0b, 0x017f  ; FAFDA8
	.short 0x0a0b, 0x01ff, 0x090b, 0x017f, 0x182b, 0x0101, 0x1a2b, 0x013f  ; FAFDB8
	.short 0x192b, 0x013f, 0x0bad, 0x017f, 0x0bae, 0x017f  ; FAFDC8
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFDD4  terminator

; KeyValueList_A12 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[12].
KeyValueList_A12:
	.short 0x0cb4, 0x067f, 0x0cb1, 0x037f, 0x0cb2, 0x047f, 0x0cb5, 0x017f  ; FAFDDC
	.short 0x0cb3, 0x057f, 0x0cb7, 0x017f, 0x0cb6, 0x017f, 0x0cbc, 0x017f  ; FAFDEC
	.short 0x0cbd, 0x017f, 0x0cb8, 0x017f, 0x0cb9, 0x017f, 0x0cba, 0x017f  ; FAFDFC
	.short 0x0cbb, 0x017f, 0x000c, 0x00ff, 0x030c, 0x017f, 0x050c, 0x017f  ; FAFE0C
	.short 0x060c, 0x017f, 0x070c, 0x017f, 0x080c, 0x017f, 0x0b0c, 0x017f  ; FAFE1C
	.short 0x0a0c, 0x01ff, 0x090c, 0x017f, 0x182c, 0x0101, 0x1a2c, 0x013f  ; FAFE2C
	.short 0x192d, 0x013f, 0x0cad, 0x017f, 0x0cae, 0x017f  ; FAFE3C
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFE48  terminator

; KeyValueList_A13 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[13].
KeyValueList_A13:
	.short 0x0db4, 0x067f, 0x0db1, 0x037f, 0x0db2, 0x047f, 0x0db5, 0x017f  ; FAFE50
	.short 0x0db3, 0x057f, 0x0db7, 0x017f, 0x0db6, 0x017f, 0x0dbc, 0x017f  ; FAFE60
	.short 0x0dbd, 0x017f, 0x0db8, 0x017f, 0x0db9, 0x017f, 0x0dba, 0x017f  ; FAFE70
	.short 0x0dbb, 0x017f, 0x000d, 0x00ff, 0x030d, 0x017f, 0x050d, 0x017f  ; FAFE80
	.short 0x060d, 0x017f, 0x070d, 0x017f, 0x080d, 0x017f, 0x0b0d, 0x017f  ; FAFE90
	.short 0x0a0d, 0x01ff, 0x090d, 0x017f, 0x182d, 0x0101, 0x1a2d, 0x013f  ; FAFEA0
	.short 0x192d, 0x013f, 0x0dad, 0x017f, 0x0dae, 0x017f  ; FAFEB0
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFEBC  terminator

; KeyValueList_A14 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[14].
KeyValueList_A14:
	.short 0x0eb4, 0x067f, 0x0eb1, 0x037f, 0x0eb2, 0x047f, 0x0eb5, 0x017f  ; FAFEC4
	.short 0x0eb3, 0x057f, 0x0eb7, 0x017f, 0x0eb6, 0x017f, 0x0ebc, 0x017f  ; FAFED4
	.short 0x0ebd, 0x017f, 0x0eb8, 0x017f, 0x0eb9, 0x017f, 0x0eba, 0x017f  ; FAFEE4
	.short 0x0ebb, 0x017f, 0x000e, 0x00ff, 0x030e, 0x017f, 0x050e, 0x017f  ; FAFEF4
	.short 0x060e, 0x017f, 0x070e, 0x017f, 0x080e, 0x017f, 0x0b0e, 0x017f  ; FAFF04
	.short 0x0a0e, 0x01ff, 0x090e, 0x017f, 0x182e, 0x0101, 0x1a2e, 0x013f  ; FAFF14
	.short 0x192e, 0x013f, 0x0ead, 0x017f, 0x0eae, 0x017f  ; FAFF24
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFF30  terminator

; KeyValueList_A15 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[15].
KeyValueList_A15:
	.short 0x0fb4, 0x067f, 0x0fb1, 0x037f, 0x0fb2, 0x047f, 0x0fb5, 0x017f  ; FAFF38
	.short 0x0fb3, 0x057f, 0x0fb7, 0x017f, 0x0fb6, 0x017f, 0x0fbc, 0x017f  ; FAFF48
	.short 0x0fbd, 0x017f, 0x0fb8, 0x017f, 0x0fb9, 0x017f, 0x0fba, 0x017f  ; FAFF58
	.short 0x0fbb, 0x017f, 0x000f, 0x00ff, 0x030f, 0x017f, 0x050f, 0x017f  ; FAFF68
	.short 0x060f, 0x017f, 0x070f, 0x017f, 0x080f, 0x017f, 0x0b0f, 0x017f  ; FAFF78
	.short 0x0a0f, 0x01ff, 0x090f, 0x017f, 0x182f, 0x0101, 0x1a2f, 0x013f  ; FAFF88
	.short 0x192f, 0x013f, 0x0fad, 0x017f, 0x0fae, 0x017f  ; FAFF98
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FAFFA4  terminator

; KeyValueList_A16 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[16].
KeyValueList_A16:
	.short 0x10b4, 0x067f, 0x10b1, 0x037f, 0x10b2, 0x047f, 0x10b5, 0x017f  ; FAFFAC
	.short 0x10b3, 0x057f, 0x10b7, 0x017f, 0x10b6, 0x017f, 0x10bc, 0x017f  ; FAFFBC
	.short 0x10bd, 0x017f, 0x10b8, 0x017f, 0x10b9, 0x017f, 0x10ba, 0x017f  ; FAFFCC
	.short 0x10bb, 0x017f, 0x0010, 0x00ff, 0x0310, 0x017f, 0x0510, 0x017f  ; FAFFDC
	.short 0x0610, 0x017f, 0x0710, 0x017f, 0x0810, 0x017f, 0x0b10, 0x017f  ; FAFFEC
	.short	0x0a10, 0x01ff  ; FAFFFC
	.short	0x0910
	.short	0x017f, 0x1830, 0x0101, 0x1a30, 0x013f
	.short 0x1930, 0x013f, 0x10ad, 0x017f, 0x10ae, 0x017f  ; FB000C
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0018  terminator

; KeyValueList_A17 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[17].
KeyValueList_A17:
	.short 0x11b4, 0x067f, 0x11b1, 0x037f, 0x11b2, 0x047f, 0x11b5, 0x017f  ; FB0020
	.short 0x11b3, 0x057f, 0x11b7, 0x017f, 0x11b6, 0x017f, 0x11bc, 0x017f  ; FB0030
	.short 0x11bd, 0x017f, 0x11b8, 0x017f, 0x11b9, 0x017f, 0x11ba, 0x017f  ; FB0040
	.short 0x11bb, 0x017f, 0x0011, 0x00ff, 0x0311, 0x017f, 0x0511, 0x017f  ; FB0050
	.short 0x0611, 0x017f, 0x0711, 0x017f, 0x0811, 0x017f, 0x0b11, 0x017f  ; FB0060
	.short 0x0a11, 0x01ff, 0x0911, 0x017f, 0x1831, 0x0101, 0x1a31, 0x013f  ; FB0070
	.short 0x1931, 0x013f, 0x11ad, 0x017f, 0x11ae, 0x017f  ; FB0080
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB008C  terminator

; KeyValueList_A18 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[18].
KeyValueList_A18:
	.short 0x12b4, 0x067f, 0x12b1, 0x037f, 0x12b2, 0x047f, 0x12b5, 0x017f  ; FB0094
	.short 0x12b3, 0x057f, 0x12b7, 0x017f, 0x12b6, 0x017f, 0x12bc, 0x017f  ; FB00A4
	.short 0x12bd, 0x017f, 0x12b8, 0x017f, 0x12b9, 0x017f, 0x12ba, 0x017f  ; FB00B4
	.short 0x12bb, 0x017f, 0x0012, 0x00ff, 0x0312, 0x017f, 0x0512, 0x017f  ; FB00C4
	.short 0x0612, 0x017f, 0x0712, 0x017f, 0x0812, 0x017f, 0x0b12, 0x017f  ; FB00D4
	.short 0x0a12, 0x01ff, 0x0912, 0x017f, 0x1832, 0x0101, 0x1a32, 0x013f  ; FB00E4
	.short 0x1932, 0x013f, 0x12ad, 0x017f, 0x12ae, 0x017f  ; FB00F4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0100  terminator

; KeyValueList_A19 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[19].
KeyValueList_A19:
	.short 0x13b4, 0x067f, 0x13b1, 0x037f, 0x13b2, 0x047f, 0x13b5, 0x017f  ; FB0108
	.short 0x13b3, 0x057f, 0x13b7, 0x017f, 0x13b6, 0x017f, 0x13bc, 0x017f  ; FB0118
	.short 0x13bd, 0x017f, 0x13b8, 0x017f, 0x13b9, 0x017f, 0x13ba, 0x017f  ; FB0128
	.short 0x13bb, 0x017f, 0x0013, 0x00ff, 0x0313, 0x017f, 0x0513, 0x017f  ; FB0138
	.short 0x0613, 0x017f, 0x0713, 0x017f, 0x0813, 0x017f, 0x0b13, 0x017f  ; FB0148
	.short 0x0a13, 0x01ff, 0x0913, 0x017f, 0x1833, 0x0101, 0x1a33, 0x013f  ; FB0158
	.short 0x1933, 0x013f, 0x13ad, 0x017f, 0x13ae, 0x017f  ; FB0168
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0174  terminator

; KeyValueList_A20 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[20].
KeyValueList_A20:
	.short 0x14b4, 0x067f, 0x14b1, 0x037f, 0x14b2, 0x047f, 0x14b5, 0x017f  ; FB017C
	.short 0x14b3, 0x057f, 0x14b7, 0x017f, 0x14b6, 0x017f, 0x14bc, 0x017f  ; FB018C
	.short 0x14bd, 0x017f, 0x14b8, 0x017f, 0x14b9, 0x017f, 0x14ba, 0x017f  ; FB019C
	.short 0x14bb, 0x017f, 0x0014, 0x00ff, 0x0314, 0x017f, 0x0514, 0x017f  ; FB01AC
	.short 0x0614, 0x017f, 0x0714, 0x017f, 0x0814, 0x017f, 0x0b14, 0x017f  ; FB01BC
	.short 0x0a14, 0x01ff, 0x0914, 0x017f, 0x1834, 0x0101, 0x1a34, 0x013f  ; FB01CC
	.short 0x1934, 0x013f, 0x14ad, 0x017f, 0x14ae, 0x017f  ; FB01DC
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB01E8  terminator

; KeyValueList_A21 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[21].
KeyValueList_A21:
	.short 0x15b4, 0x067f, 0x15b1, 0x037f, 0x15b2, 0x047f, 0x15b5, 0x017f  ; FB01F0
	.short 0x15b3, 0x057f, 0x15b7, 0x017f, 0x15b6, 0x017f, 0x15bc, 0x017f  ; FB0200
	.short 0x15bd, 0x017f, 0x15b8, 0x017f, 0x15b9, 0x017f, 0x15ba, 0x017f  ; FB0210
	.short 0x15bb, 0x017f, 0x0015, 0x00ff, 0x0315, 0x017f, 0x0515, 0x017f  ; FB0220
	.short 0x0615, 0x017f, 0x0715, 0x017f, 0x0815, 0x017f, 0x0b15, 0x017f  ; FB0230
	.short 0x0a15, 0x01ff, 0x0915, 0x017f, 0x1835, 0x0101, 0x1a35, 0x013f  ; FB0240
	.short 0x1935, 0x013f, 0x15ad, 0x017f, 0x15ae, 0x017f  ; FB0250
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB025C  terminator

; KeyValueList_A22 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[22].
KeyValueList_A22:
	.short 0x16b4, 0x067f, 0x16b1, 0x037f, 0x16b2, 0x047f, 0x16b5, 0x017f  ; FB0264
	.short 0x16b3, 0x057f, 0x16b7, 0x017f, 0x16b6, 0x017f, 0x16bc, 0x017f  ; FB0274
	.short 0x16bd, 0x017f, 0x16b8, 0x017f, 0x16b9, 0x017f, 0x16ba, 0x017f  ; FB0284
	.short 0x16bb, 0x017f, 0x0016, 0x00ff, 0x0316, 0x017f, 0x0516, 0x017f  ; FB0294
	.short 0x0616, 0x017f, 0x0716, 0x017f, 0x0816, 0x017f, 0x0b16, 0x017f  ; FB02A4
	.short 0x0a16, 0x01ff, 0x0916, 0x017f, 0x1836, 0x0101, 0x1a36, 0x013f  ; FB02B4
	.short 0x1936, 0x013f, 0x16ad, 0x017f, 0x16ae, 0x017f  ; FB02C4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB02D0  terminator

; KeyValueList_A23 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[23].
KeyValueList_A23:
	.short 0x17b4, 0x067f, 0x17b1, 0x037f, 0x17b2, 0x047f, 0x17b5, 0x017f  ; FB02D8
	.short 0x17b3, 0x057f, 0x17b7, 0x017f, 0x17b6, 0x017f, 0x17bc, 0x017f  ; FB02E8
	.short 0x17bd, 0x017f, 0x17b8, 0x017f, 0x17b9, 0x017f, 0x17ba, 0x017f  ; FB02F8
	.short 0x17bb, 0x017f, 0x0017, 0x00ff, 0x0317, 0x017f, 0x0517, 0x017f  ; FB0308
	.short 0x0617, 0x017f, 0x0717, 0x017f, 0x0817, 0x017f, 0x0b17, 0x017f  ; FB0318
	.short 0x0a17, 0x01ff, 0x0917, 0x017f, 0x1837, 0x0101, 0x1a37, 0x013f  ; FB0328
	.short 0x1937, 0x013f, 0x17ad, 0x017f, 0x17ae, 0x017f  ; FB0338
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0344  terminator

; KeyValueList_A24 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[24].
KeyValueList_A24:
	.short 0x18b4, 0x067f, 0x18b1, 0x037f, 0x18b2, 0x047f, 0x18b5, 0x017f  ; FB034C
	.short 0x18b3, 0x057f, 0x18b7, 0x017f, 0x18b6, 0x017f, 0x18bc, 0x017f  ; FB035C
	.short 0x18bd, 0x017f, 0x18b8, 0x017f, 0x18b9, 0x017f, 0x18ba, 0x017f  ; FB036C
	.short 0x18bb, 0x017f, 0x0018, 0x00ff, 0x0318, 0x017f, 0x0518, 0x017f  ; FB037C
	.short 0x0618, 0x017f, 0x0718, 0x017f, 0x0818, 0x017f, 0x0b18, 0x017f  ; FB038C
	.short 0x0a18, 0x01ff, 0x0918, 0x017f, 0x1838, 0x0101, 0x1a38, 0x013f  ; FB039C
	.short 0x1938, 0x013f, 0x18ad, 0x017f, 0x18ae, 0x017f  ; FB03AC
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB03B8  terminator

; KeyValueList_A25 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[25].
KeyValueList_A25:
	.short 0x19b4, 0x067f, 0x19b1, 0x037f, 0x19b2, 0x047f, 0x19b5, 0x017f  ; FB03C0
	.short 0x19b3, 0x057f, 0x19b7, 0x017f, 0x19b6, 0x017f, 0x19bc, 0x017f  ; FB03D0
	.short 0x19bd, 0x017f, 0x19b8, 0x017f, 0x19b9, 0x017f, 0x19ba, 0x017f  ; FB03E0
	.short 0x19bb, 0x017f, 0x0019, 0x00ff, 0x0319, 0x017f, 0x0519, 0x017f  ; FB03F0
	.short 0x0619, 0x017f, 0x0719, 0x017f, 0x0819, 0x017f, 0x0b19, 0x017f  ; FB0400
	.short 0x0a19, 0x01ff, 0x0919, 0x017f, 0x1839, 0x0101, 0x1a39, 0x013f  ; FB0410
	.short 0x1939, 0x013f, 0x19ad, 0x017f, 0x19ae, 0x017f  ; FB0420
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB042C  terminator

; KeyValueList_A26 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[26].
KeyValueList_A26:
	.short 0x1ab4, 0x067f, 0x1ab1, 0x037f, 0x1ab2, 0x047f, 0x1ab5, 0x017f  ; FB0434
	.short 0x1ab3, 0x057f, 0x1ab7, 0x017f, 0x1ab6, 0x017f, 0x1abc, 0x017f  ; FB0444
	.short 0x1abd, 0x017f, 0x1ab8, 0x017f, 0x1ab9, 0x017f, 0x1aba, 0x017f  ; FB0454
	.short 0x1abb, 0x017f, 0x001a, 0x00ff, 0x031a, 0x017f, 0x051a, 0x017f  ; FB0464
	.short 0x061a, 0x017f, 0x071a, 0x017f, 0x081a, 0x017f, 0x0b1a, 0x017f  ; FB0474
	.short 0x0a1a, 0x01ff, 0x091a, 0x017f, 0x183a, 0x0101, 0x1a3a, 0x013f  ; FB0484
	.short 0x193a, 0x013f, 0x1aad, 0x017f, 0x1aae, 0x017f  ; FB0494
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB04A0  terminator

; KeyValueList_A27 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[27].
KeyValueList_A27:
	.short 0x1bb4, 0x067f, 0x1bb1, 0x037f, 0x1bb2, 0x047f, 0x1bb5, 0x017f  ; FB04A8
	.short 0x1bb3, 0x057f, 0x1bb7, 0x017f, 0x1bb6, 0x017f, 0x1bbc, 0x017f  ; FB04B8
	.short 0x1bbd, 0x017f, 0x1bb8, 0x017f, 0x1bb9, 0x017f, 0x1bba, 0x017f  ; FB04C8
	.short 0x1bbb, 0x017f, 0x001b, 0x00ff, 0x031b, 0x017f, 0x051b, 0x017f  ; FB04D8
	.short 0x061b, 0x017f, 0x071b, 0x017f, 0x081b, 0x017f, 0x0b1b, 0x017f  ; FB04E8
	.short 0x0a1b, 0x01ff, 0x091b, 0x017f, 0x183b, 0x0101, 0x1a3b, 0x013f  ; FB04F8
	.short 0x193b, 0x013f, 0x1bad, 0x017f, 0x1bae, 0x017f  ; FB0508
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0514  terminator

; KeyValueList_A28 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[28].
KeyValueList_A28:
	.short 0x1cb4, 0x067f, 0x1cb1, 0x037f, 0x1cb2, 0x047f, 0x1cb5, 0x017f  ; FB051C
	.short 0x1cb3, 0x057f, 0x1cb7, 0x017f, 0x1cb6, 0x017f, 0x1cbc, 0x017f  ; FB052C
	.short 0x1cbd, 0x017f, 0x1cb8, 0x017f, 0x1cb9, 0x017f, 0x1cba, 0x017f  ; FB053C
	.short 0x1cbb, 0x017f, 0x001c, 0x00ff, 0x031c, 0x017f, 0x051c, 0x017f  ; FB054C
	.short 0x061c, 0x017f, 0x071c, 0x017f, 0x081c, 0x017f, 0x0b1c, 0x017f  ; FB055C
	.short 0x0a1c, 0x01ff, 0x091c, 0x017f, 0x183c, 0x0101, 0x1a3c, 0x013f  ; FB056C
	.short 0x193c, 0x013f, 0x1cad, 0x017f, 0x1cae, 0x017f  ; FB057C
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0588  terminator

; KeyValueList_A29 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[29].
KeyValueList_A29:
	.short 0x1db4, 0x067f, 0x1db1, 0x037f, 0x1db2, 0x047f, 0x1db5, 0x017f  ; FB0590
	.short 0x1db3, 0x057f, 0x1db7, 0x017f, 0x1db6, 0x017f, 0x1dbc, 0x017f  ; FB05A0
	.short 0x1dbd, 0x017f, 0x1db8, 0x017f, 0x1db9, 0x017f, 0x1dba, 0x017f  ; FB05B0
	.short 0x1dbb, 0x017f, 0x001d, 0x00ff, 0x031d, 0x017f, 0x051d, 0x017f  ; FB05C0
	.short 0x061d, 0x017f, 0x071d, 0x017f, 0x081d, 0x017f, 0x0b1d, 0x017f  ; FB05D0
	.short 0x0a1d, 0x01ff, 0x091d, 0x017f, 0x183d, 0x0101, 0x1a3d, 0x013f  ; FB05E0
	.short 0x193d, 0x013f, 0x1dad, 0x017f, 0x1dae, 0x017f  ; FB05F0
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB05FC  terminator

; KeyValueList_A30 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[30].
KeyValueList_A30:
	.short 0x1eb4, 0x067f, 0x1eb1, 0x037f, 0x1eb2, 0x047f, 0x1eb5, 0x017f  ; FB0604
	.short 0x1eb3, 0x057f, 0x1eb7, 0x017f, 0x1eb6, 0x017f, 0x1ebc, 0x017f  ; FB0614
	.short 0x1ebd, 0x017f, 0x1eb8, 0x017f, 0x1eb9, 0x017f, 0x1eba, 0x017f  ; FB0624
	.short 0x1ebb, 0x017f, 0x001e, 0x00ff, 0x031e, 0x017f, 0x051e, 0x017f  ; FB0634
	.short 0x061e, 0x017f, 0x071e, 0x017f, 0x081e, 0x017f, 0x0b1e, 0x017f  ; FB0644
	.short 0x0a1e, 0x01ff, 0x091e, 0x017f, 0x183e, 0x0101, 0x1a3e, 0x013f  ; FB0654
	.short 0x193e, 0x013f, 0x1ead, 0x017f, 0x1eae, 0x017f  ; FB0664
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0670  terminator

; KeyValueList_A31 -- 27 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[31].
KeyValueList_A31:
	.short 0x1fb4, 0x067f, 0x1fb1, 0x037f, 0x1fb2, 0x047f, 0x1fb5, 0x017f  ; FB0678
	.short 0x1fb3, 0x057f, 0x1fb7, 0x017f, 0x1fb6, 0x017f, 0x1fbc, 0x017f  ; FB0688
	.short 0x1fbd, 0x017f, 0x1fb8, 0x017f, 0x1fb9, 0x017f, 0x1fba, 0x017f  ; FB0698
	.short 0x1fbb, 0x017f, 0x001f, 0x00ff, 0x031f, 0x017f, 0x051f, 0x017f  ; FB06A8
	.short 0x061f, 0x017f, 0x071f, 0x017f, 0x081f, 0x017f, 0x0b1f, 0x017f  ; FB06B8
	.short 0x0a1f, 0x01ff, 0x091f, 0x017f, 0x183f, 0x0101, 0x1a3f, 0x013f  ; FB06C8
	.short 0x193f, 0x013f, 0x1fad, 0x017f, 0x1fae, 0x017f  ; FB06D8
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB06E4  terminator

; KeyValueList_A32 -- 1 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_A[32].
KeyValueList_A32:
	.short 0x007a, 0x02ff  ; FB06EC
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB06F0  terminator
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB06F8  0xFF fill to the next object

; KeyValueListPtrs_B -- 33 pointers to the key/value record lists below.
; Read by: .LFAF0C1 at 0xFAF0DB `ld XIX,0x00FB0700`; index L = RAM(0x603422 + the slot byte).
; COUNT 33 is the extent to the first list, and every target is a list start.
KeyValueListPtrs_B:
	.long KeyValueList_B00                      ; FB0700  [ 0]
	.long KeyValueList_B01                      ; FB0704  [ 1]
	.long KeyValueList_B02                      ; FB0708  [ 2]
	.long KeyValueList_B03                      ; FB070C  [ 3]
	.long KeyValueList_B04                      ; FB0710  [ 4]
	.long KeyValueList_B05                      ; FB0714  [ 5]
	.long KeyValueList_B06                      ; FB0718  [ 6]
	.long KeyValueList_B07                      ; FB071C  [ 7]
	.long KeyValueList_B08                      ; FB0720  [ 8]
	.long KeyValueList_B09                      ; FB0724  [ 9]
	.long KeyValueList_B10                      ; FB0728  [10]
	.long KeyValueList_B11                      ; FB072C  [11]
	.long KeyValueList_B12                      ; FB0730  [12]
	.long KeyValueList_B13                      ; FB0734  [13]
	.long KeyValueList_B14                      ; FB0738  [14]
	.long KeyValueList_B15                      ; FB073C  [15]
	.long KeyValueList_B16                      ; FB0740  [16]
	.long KeyValueList_B17                      ; FB0744  [17]
	.long KeyValueList_B18                      ; FB0748  [18]
	.long KeyValueList_B19                      ; FB074C  [19]
	.long KeyValueList_B20                      ; FB0750  [20]
	.long KeyValueList_B21                      ; FB0754  [21]
	.long KeyValueList_B22                      ; FB0758  [22]
	.long KeyValueList_B23                      ; FB075C  [23]
	.long KeyValueList_B24                      ; FB0760  [24]
	.long KeyValueList_B25                      ; FB0764  [25]
	.long KeyValueList_B26                      ; FB0768  [26]
	.long KeyValueList_B27                      ; FB076C  [27]
	.long KeyValueList_B28                      ; FB0770  [28]
	.long KeyValueList_B29                      ; FB0774  [29]
	.long KeyValueList_B30                      ; FB0778  [30]
	.long KeyValueList_B31                      ; FB077C  [31]
	.long KeyValueList_B32                      ; FB0780  [32]

; KeyValueList_B00 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[0].
KeyValueList_B00:
	.short 0x00b5, 0x047f, 0x00b7, 0x047f, 0x00b6, 0x047f, 0x00bc, 0x047f  ; FB0784
	.short 0x00bd, 0x047f, 0x00b8, 0x047f, 0x00b9, 0x047f, 0x00ba, 0x047f  ; FB0794
	.short 0x00bb, 0x047f, 0x0300, 0x057f, 0x0500, 0x067f, 0x0600, 0x067f  ; FB07A4
	.short 0x0700, 0x067f, 0x0800, 0x067f, 0x0b00, 0x067f, 0x0a00, 0x06ff  ; FB07B4
	.short 0x0900, 0x067f, 0x1820, 0x0601, 0x1a20, 0x063f, 0x1920, 0x063f  ; FB07C4
	.short 0x00ad, 0x037f, 0x00ae, 0x047f  ; FB07D4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB07DC  terminator

; KeyValueList_B01 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[1].
KeyValueList_B01:
	.short 0x01b5, 0x047f, 0x01b7, 0x047f, 0x01b6, 0x047f, 0x01bc, 0x047f  ; FB07E4
	.short 0x01bd, 0x047f, 0x01b8, 0x047f, 0x01b9, 0x047f, 0x01ba, 0x047f  ; FB07F4
	.short 0x01bb, 0x047f, 0x0301, 0x057f, 0x0501, 0x067f, 0x0601, 0x067f  ; FB0804
	.short 0x0701, 0x067f, 0x0801, 0x067f, 0x0b01, 0x067f, 0x0a01, 0x06ff  ; FB0814
	.short 0x0901, 0x067f, 0x1821, 0x0601, 0x1a21, 0x063f, 0x1921, 0x063f  ; FB0824
	.short 0x01ad, 0x037f, 0x01ae, 0x047f  ; FB0834
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB083C  terminator

; KeyValueList_B02 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[2].
KeyValueList_B02:
	.short 0x02b5, 0x047f, 0x02b7, 0x047f, 0x02b6, 0x047f, 0x02bc, 0x047f  ; FB0844
	.short 0x02bd, 0x047f, 0x02b8, 0x047f, 0x02b9, 0x047f, 0x02ba, 0x047f  ; FB0854
	.short 0x02bb, 0x047f, 0x0302, 0x057f, 0x0502, 0x067f, 0x0602, 0x067f  ; FB0864
	.short 0x0702, 0x067f, 0x0802, 0x067f, 0x0b02, 0x067f, 0x0a02, 0x06ff  ; FB0874
	.short 0x0902, 0x067f, 0x1822, 0x0601, 0x1a22, 0x063f, 0x1922, 0x063f  ; FB0884
	.short 0x02ad, 0x037f, 0x02ae, 0x047f  ; FB0894
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB089C  terminator

; KeyValueList_B03 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[3].
KeyValueList_B03:
	.short 0x03b5, 0x047f, 0x03b7, 0x047f, 0x03b6, 0x047f, 0x03bc, 0x047f  ; FB08A4
	.short 0x03bd, 0x047f, 0x03b8, 0x047f, 0x03b9, 0x047f, 0x03ba, 0x047f  ; FB08B4
	.short 0x03bb, 0x047f, 0x0303, 0x057f, 0x0503, 0x067f, 0x0603, 0x067f  ; FB08C4
	.short 0x0703, 0x067f, 0x0803, 0x067f, 0x0b03, 0x067f, 0x0a03, 0x06ff  ; FB08D4
	.short 0x0903, 0x067f, 0x1823, 0x0601, 0x1a23, 0x063f, 0x1923, 0x063f  ; FB08E4
	.short 0x03ad, 0x037f, 0x03ae, 0x047f  ; FB08F4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB08FC  terminator

; KeyValueList_B04 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[4].
KeyValueList_B04:
	.short 0x04b5, 0x047f, 0x04b7, 0x047f, 0x04b6, 0x047f, 0x04bc, 0x047f  ; FB0904
	.short 0x04bd, 0x047f, 0x04b8, 0x047f, 0x04b9, 0x047f, 0x04ba, 0x047f  ; FB0914
	.short 0x04bb, 0x047f, 0x0304, 0x057f, 0x0504, 0x067f, 0x0604, 0x067f  ; FB0924
	.short 0x0704, 0x067f, 0x0804, 0x067f, 0x0b04, 0x067f, 0x0a04, 0x06ff  ; FB0934
	.short 0x0904, 0x067f, 0x1824, 0x0601, 0x1a24, 0x063f, 0x1924, 0x063f  ; FB0944
	.short 0x04ad, 0x037f, 0x04ae, 0x047f  ; FB0954
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB095C  terminator

; KeyValueList_B05 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[5].
KeyValueList_B05:
	.short 0x05b5, 0x047f, 0x05b7, 0x047f, 0x05b6, 0x047f, 0x05bc, 0x047f  ; FB0964
	.short 0x05bd, 0x047f, 0x05b8, 0x047f, 0x05b9, 0x047f, 0x05ba, 0x047f  ; FB0974
	.short 0x05bb, 0x047f, 0x0305, 0x057f, 0x0505, 0x067f, 0x0605, 0x067f  ; FB0984
	.short 0x0705, 0x067f, 0x0805, 0x067f, 0x0b05, 0x067f, 0x0a05, 0x06ff  ; FB0994
	.short 0x0905, 0x067f, 0x1825, 0x0601, 0x1a25, 0x063f, 0x1925, 0x063f  ; FB09A4
	.short 0x05ad, 0x037f, 0x05ae, 0x047f  ; FB09B4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB09BC  terminator

; KeyValueList_B06 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[6].
KeyValueList_B06:
	.short 0x06b5, 0x047f, 0x06b7, 0x047f, 0x06b6, 0x047f, 0x06bc, 0x047f  ; FB09C4
	.short 0x06bd, 0x047f, 0x06b8, 0x047f, 0x06b9, 0x047f, 0x06ba, 0x047f  ; FB09D4
	.short 0x06bb, 0x047f, 0x0306, 0x057f, 0x0506, 0x067f, 0x0606, 0x067f  ; FB09E4
	.short 0x0706, 0x067f, 0x0806, 0x067f, 0x0b06, 0x067f, 0x0a06, 0x06ff  ; FB09F4
	.short 0x0906, 0x067f, 0x1826, 0x0601, 0x1a26, 0x063f, 0x1926, 0x063f  ; FB0A04
	.short 0x06ad, 0x037f, 0x06ae, 0x047f  ; FB0A14
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0A1C  terminator

; KeyValueList_B07 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[7].
KeyValueList_B07:
	.short 0x07b5, 0x047f, 0x07b7, 0x047f, 0x07b6, 0x047f, 0x07bc, 0x047f  ; FB0A24
	.short 0x07bd, 0x047f, 0x07b8, 0x047f, 0x07b9, 0x047f, 0x07ba, 0x047f  ; FB0A34
	.short 0x07bb, 0x047f, 0x0307, 0x057f, 0x0507, 0x067f, 0x0607, 0x067f  ; FB0A44
	.short 0x0707, 0x067f, 0x0807, 0x067f, 0x0b07, 0x067f, 0x0a07, 0x06ff  ; FB0A54
	.short 0x0907, 0x067f, 0x1827, 0x0601, 0x1a27, 0x063f, 0x1927, 0x063f  ; FB0A64
	.short 0x07ad, 0x037f, 0x07ae, 0x047f  ; FB0A74
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0A7C  terminator

; KeyValueList_B08 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[8].
KeyValueList_B08:
	.short 0x08b5, 0x047f, 0x08b7, 0x047f, 0x08b6, 0x047f, 0x08bc, 0x047f  ; FB0A84
	.short 0x08bd, 0x047f, 0x08b8, 0x047f, 0x08b9, 0x047f, 0x08ba, 0x047f  ; FB0A94
	.short 0x08bb, 0x047f, 0x0308, 0x057f, 0x0508, 0x067f, 0x0608, 0x067f  ; FB0AA4
	.short 0x0708, 0x067f, 0x0808, 0x067f, 0x0b08, 0x067f, 0x0a08, 0x06ff  ; FB0AB4
	.short 0x0908, 0x067f, 0x1828, 0x0601, 0x1a28, 0x063f, 0x1928, 0x063f  ; FB0AC4
	.short 0x08ad, 0x037f, 0x08ae, 0x047f  ; FB0AD4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0ADC  terminator

; KeyValueList_B09 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[9].
KeyValueList_B09:
	.short 0x09b5, 0x047f, 0x09b7, 0x047f, 0x09b6, 0x047f, 0x09bc, 0x047f  ; FB0AE4
	.short 0x09bd, 0x047f, 0x09b8, 0x047f, 0x09b9, 0x047f, 0x09ba, 0x047f  ; FB0AF4
	.short 0x09bb, 0x047f, 0x0309, 0x057f, 0x0509, 0x067f, 0x0609, 0x067f  ; FB0B04
	.short 0x0709, 0x067f, 0x0809, 0x067f, 0x0b09, 0x067f, 0x0a09, 0x06ff  ; FB0B14
	.short 0x0909, 0x067f, 0x1829, 0x0601, 0x1a29, 0x063f, 0x1929, 0x063f  ; FB0B24
	.short 0x09ad, 0x037f, 0x09ae, 0x047f  ; FB0B34
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0B3C  terminator

; KeyValueList_B10 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[10].
KeyValueList_B10:
	.short 0x0ab5, 0x047f, 0x0ab7, 0x047f, 0x0ab6, 0x047f, 0x0abc, 0x047f  ; FB0B44
	.short 0x0abd, 0x047f, 0x0ab8, 0x047f, 0x0ab9, 0x047f, 0x0aba, 0x047f  ; FB0B54
	.short 0x0abb, 0x047f, 0x030a, 0x057f, 0x050a, 0x067f, 0x060a, 0x067f  ; FB0B64
	.short 0x070a, 0x067f, 0x080a, 0x067f, 0x0b0a, 0x067f, 0x0a0a, 0x06ff  ; FB0B74
	.short 0x090a, 0x067f, 0x182a, 0x0601, 0x1a2a, 0x063f, 0x192a, 0x063f  ; FB0B84
	.short 0x0aad, 0x037f, 0x0aae, 0x047f  ; FB0B94
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0B9C  terminator

; KeyValueList_B11 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[11].
KeyValueList_B11:
	.short 0x0bb5, 0x047f, 0x0bb7, 0x047f, 0x0bb6, 0x047f, 0x0bbc, 0x047f  ; FB0BA4
	.short 0x0bbd, 0x047f, 0x0bb8, 0x047f, 0x0bb9, 0x047f, 0x0bba, 0x047f  ; FB0BB4
	.short 0x0bbb, 0x047f, 0x030b, 0x057f, 0x050b, 0x067f, 0x060b, 0x067f  ; FB0BC4
	.short 0x070b, 0x067f, 0x080b, 0x067f, 0x0b0b, 0x067f, 0x0a0b, 0x06ff  ; FB0BD4
	.short 0x090b, 0x067f, 0x182b, 0x0601, 0x1a2b, 0x063f, 0x192b, 0x063f  ; FB0BE4
	.short 0x0bad, 0x037f, 0x0bae, 0x047f  ; FB0BF4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0BFC  terminator

; KeyValueList_B12 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[12].
KeyValueList_B12:
	.short 0x0cb5, 0x047f, 0x0cb7, 0x047f, 0x0cb6, 0x047f, 0x0cbc, 0x047f  ; FB0C04
	.short 0x0cbd, 0x047f, 0x0cb8, 0x047f, 0x0cb9, 0x047f, 0x0cba, 0x047f  ; FB0C14
	.short 0x0cbb, 0x047f, 0x030c, 0x057f, 0x050c, 0x067f, 0x060c, 0x067f  ; FB0C24
	.short 0x070c, 0x067f, 0x080c, 0x067f, 0x0b0c, 0x067f, 0x0a0c, 0x06ff  ; FB0C34
	.short 0x090c, 0x067f, 0x182c, 0x0601, 0x1a2c, 0x063f, 0x192c, 0x063f  ; FB0C44
	.short 0x0cad, 0x037f, 0x0cae, 0x047f  ; FB0C54
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0C5C  terminator

; KeyValueList_B13 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[13].
KeyValueList_B13:
	.short 0x0db5, 0x047f, 0x0db7, 0x047f, 0x0db6, 0x047f, 0x0dbc, 0x047f  ; FB0C64
	.short 0x0dbd, 0x047f, 0x0db8, 0x047f, 0x0db9, 0x047f, 0x0dba, 0x047f  ; FB0C74
	.short 0x0dbb, 0x047f, 0x030d, 0x057f, 0x050d, 0x067f, 0x060d, 0x067f  ; FB0C84
	.short 0x070d, 0x067f, 0x080d, 0x067f, 0x0b0d, 0x067f, 0x0a0d, 0x06ff  ; FB0C94
	.short 0x090d, 0x067f, 0x182d, 0x0601, 0x1a2d, 0x063f, 0x192d, 0x063f  ; FB0CA4
	.short 0x0dad, 0x037f, 0x0dae, 0x047f  ; FB0CB4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0CBC  terminator

; KeyValueList_B14 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[14].
KeyValueList_B14:
	.short 0x0eb5, 0x047f, 0x0eb7, 0x047f, 0x0eb6, 0x047f, 0x0ebc, 0x047f  ; FB0CC4
	.short 0x0ebd, 0x047f, 0x0eb8, 0x047f, 0x0eb9, 0x047f, 0x0eba, 0x047f  ; FB0CD4
	.short 0x0ebb, 0x047f, 0x030e, 0x057f, 0x050e, 0x067f, 0x060e, 0x067f  ; FB0CE4
	.short 0x070e, 0x067f, 0x080e, 0x067f, 0x0b0e, 0x067f, 0x0a0e, 0x06ff  ; FB0CF4
	.short 0x090e, 0x067f, 0x182e, 0x0601, 0x1a2e, 0x063f, 0x192e, 0x063f  ; FB0D04
	.short 0x0ead, 0x037f, 0x0eae, 0x047f  ; FB0D14
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0D1C  terminator

; KeyValueList_B15 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[15].
KeyValueList_B15:
	.short 0x0fb5, 0x047f, 0x0fb7, 0x047f, 0x0fb6, 0x047f, 0x0fbc, 0x047f  ; FB0D24
	.short 0x0fbd, 0x047f, 0x0fb8, 0x047f, 0x0fb9, 0x047f, 0x0fba, 0x047f  ; FB0D34
	.short 0x0fbb, 0x047f, 0x030f, 0x057f, 0x050f, 0x067f, 0x060f, 0x067f  ; FB0D44
	.short 0x070f, 0x067f, 0x080f, 0x067f, 0x0b0f, 0x067f, 0x0a0f, 0x06ff  ; FB0D54
	.short 0x090f, 0x067f, 0x182f, 0x0601, 0x1a2f, 0x063f, 0x192f, 0x063f  ; FB0D64
	.short 0x0fad, 0x037f, 0x0fae, 0x047f  ; FB0D74
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0D7C  terminator

; KeyValueList_B16 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[16].
KeyValueList_B16:
	.short 0x10b5, 0x047f, 0x10b7, 0x047f, 0x10b6, 0x047f, 0x10bc, 0x047f  ; FB0D84
	.short 0x10bd, 0x047f, 0x10b8, 0x047f, 0x10b9, 0x047f, 0x10ba, 0x047f  ; FB0D94
	.short 0x10bb, 0x047f, 0x0310, 0x057f, 0x0510, 0x067f, 0x0610, 0x067f  ; FB0DA4
	.short 0x0710, 0x067f, 0x0810, 0x067f, 0x0b10, 0x067f, 0x0a10, 0x06ff  ; FB0DB4
	.short 0x0910, 0x067f, 0x1830, 0x0601, 0x1a30, 0x063f, 0x1930, 0x063f  ; FB0DC4
	.short 0x10ad, 0x037f, 0x10ae, 0x047f  ; FB0DD4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0DDC  terminator

; KeyValueList_B17 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[17].
KeyValueList_B17:
	.short 0x11b5, 0x047f, 0x11b7, 0x047f, 0x11b6, 0x047f, 0x11bc, 0x047f  ; FB0DE4
	.short 0x11bd, 0x047f, 0x11b8, 0x047f, 0x11b9, 0x047f, 0x11ba, 0x047f  ; FB0DF4
	.short 0x11bb, 0x047f, 0x0311, 0x057f, 0x0511, 0x067f, 0x0611, 0x067f  ; FB0E04
	.short 0x0711, 0x067f, 0x0811, 0x067f, 0x0b11, 0x067f, 0x0a11, 0x06ff  ; FB0E14
	.short 0x0911, 0x067f, 0x1831, 0x0601, 0x1a31, 0x063f, 0x1931, 0x063f  ; FB0E24
	.short 0x11ad, 0x037f, 0x11ae, 0x047f  ; FB0E34
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0E3C  terminator

; KeyValueList_B18 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[18].
KeyValueList_B18:
	.short 0x12b5, 0x047f, 0x12b7, 0x047f, 0x12b6, 0x047f, 0x12bc, 0x047f  ; FB0E44
	.short 0x12bd, 0x047f, 0x12b8, 0x047f, 0x12b9, 0x047f, 0x12ba, 0x047f  ; FB0E54
	.short 0x12bb, 0x047f, 0x0312, 0x057f, 0x0512, 0x067f, 0x0612, 0x067f  ; FB0E64
	.short 0x0712, 0x067f, 0x0812, 0x067f, 0x0b12, 0x067f, 0x0a12, 0x06ff  ; FB0E74
	.short 0x0912, 0x067f, 0x1832, 0x0601, 0x1a32, 0x063f, 0x1932, 0x063f  ; FB0E84
	.short 0x12ad, 0x037f, 0x12ae, 0x047f  ; FB0E94
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0E9C  terminator

; KeyValueList_B19 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[19].
KeyValueList_B19:
	.short 0x13b5, 0x047f, 0x13b7, 0x047f, 0x13b6, 0x047f, 0x13bc, 0x047f  ; FB0EA4
	.short 0x13bd, 0x047f, 0x13b8, 0x047f, 0x13b9, 0x047f, 0x13ba, 0x047f  ; FB0EB4
	.short 0x13bb, 0x047f, 0x0313, 0x057f, 0x0513, 0x067f, 0x0613, 0x067f  ; FB0EC4
	.short 0x0713, 0x067f, 0x0813, 0x067f, 0x0b13, 0x067f, 0x0a13, 0x06ff  ; FB0ED4
	.short 0x0913, 0x067f, 0x1833, 0x0601, 0x1a33, 0x063f, 0x1933, 0x063f  ; FB0EE4
	.short 0x13ad, 0x037f, 0x13ae, 0x047f  ; FB0EF4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0EFC  terminator

; KeyValueList_B20 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[20].
KeyValueList_B20:
	.short 0x14b5, 0x047f, 0x14b7, 0x047f, 0x14b6, 0x047f, 0x14bc, 0x047f  ; FB0F04
	.short 0x14bd, 0x047f, 0x14b8, 0x047f, 0x14b9, 0x047f, 0x14ba, 0x047f  ; FB0F14
	.short 0x14bb, 0x047f, 0x0314, 0x057f, 0x0514, 0x067f, 0x0614, 0x067f  ; FB0F24
	.short 0x0714, 0x067f, 0x0814, 0x067f, 0x0b14, 0x067f, 0x0a14, 0x06ff  ; FB0F34
	.short 0x0914, 0x067f, 0x1834, 0x0601, 0x1a34, 0x063f, 0x1934, 0x063f  ; FB0F44
	.short 0x14ad, 0x037f, 0x14ae, 0x047f  ; FB0F54
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0F5C  terminator

; KeyValueList_B21 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[21].
KeyValueList_B21:
	.short 0x15b5, 0x047f, 0x15b7, 0x047f, 0x15b6, 0x047f, 0x15bc, 0x047f  ; FB0F64
	.short 0x15bd, 0x047f, 0x15b8, 0x047f, 0x15b9, 0x047f, 0x15ba, 0x047f  ; FB0F74
	.short 0x15bb, 0x047f, 0x0315, 0x057f, 0x0515, 0x067f, 0x0615, 0x067f  ; FB0F84
	.short 0x0715, 0x067f, 0x0815, 0x067f, 0x0b15, 0x067f, 0x0a15, 0x06ff  ; FB0F94
	.short 0x0915, 0x067f, 0x1835, 0x0601, 0x1a35, 0x063f, 0x1935, 0x063f  ; FB0FA4
	.short 0x15ad, 0x037f, 0x15ae, 0x047f  ; FB0FB4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB0FBC  terminator

; KeyValueList_B22 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[22].
KeyValueList_B22:
	.short 0x16b5, 0x047f, 0x16b7, 0x047f, 0x16b6, 0x047f, 0x16bc, 0x047f  ; FB0FC4
	.short 0x16bd, 0x047f, 0x16b8, 0x047f, 0x16b9, 0x047f, 0x16ba, 0x047f  ; FB0FD4
	.short 0x16bb, 0x047f, 0x0316, 0x057f, 0x0516, 0x067f, 0x0616, 0x067f  ; FB0FE4
	.short 0x0716, 0x067f, 0x0816, 0x067f, 0x0b16, 0x067f, 0x0a16, 0x06ff  ; FB0FF4
	.short 0x0916, 0x067f, 0x1836, 0x0601, 0x1a36, 0x063f, 0x1936, 0x063f  ; FB1004
	.short 0x16ad, 0x037f, 0x16ae, 0x047f  ; FB1014
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB101C  terminator

; KeyValueList_B23 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[23].
KeyValueList_B23:
	.short 0x17b5, 0x047f, 0x17b7, 0x047f, 0x17b6, 0x047f, 0x17bc, 0x047f  ; FB1024
	.short 0x17bd, 0x047f, 0x17b8, 0x047f, 0x17b9, 0x047f, 0x17ba, 0x047f  ; FB1034
	.short 0x17bb, 0x047f, 0x0317, 0x057f, 0x0517, 0x067f, 0x0617, 0x067f  ; FB1044
	.short 0x0717, 0x067f, 0x0817, 0x067f, 0x0b17, 0x067f, 0x0a17, 0x06ff  ; FB1054
	.short 0x0917, 0x067f, 0x1837, 0x0601, 0x1a37, 0x063f, 0x1937, 0x063f  ; FB1064
	.short 0x17ad, 0x037f, 0x17ae, 0x047f  ; FB1074
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB107C  terminator

; KeyValueList_B24 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[24].
KeyValueList_B24:
	.short 0x18b5, 0x047f, 0x18b7, 0x047f, 0x18b6, 0x047f, 0x18bc, 0x047f  ; FB1084
	.short 0x18bd, 0x047f, 0x18b8, 0x047f, 0x18b9, 0x047f, 0x18ba, 0x047f  ; FB1094
	.short 0x18bb, 0x047f, 0x0318, 0x057f, 0x0518, 0x067f, 0x0618, 0x067f  ; FB10A4
	.short 0x0718, 0x067f, 0x0818, 0x067f, 0x0b18, 0x067f, 0x0a18, 0x06ff  ; FB10B4
	.short 0x0918, 0x067f, 0x1838, 0x0601, 0x1a38, 0x063f, 0x1938, 0x063f  ; FB10C4
	.short 0x18ad, 0x037f, 0x18ae, 0x047f  ; FB10D4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB10DC  terminator

; KeyValueList_B25 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[25].
KeyValueList_B25:
	.short 0x19b5, 0x047f, 0x19b7, 0x047f, 0x19b6, 0x047f, 0x19bc, 0x047f  ; FB10E4
	.short 0x19bd, 0x047f, 0x19b8, 0x047f, 0x19b9, 0x047f, 0x19ba, 0x047f  ; FB10F4
	.short 0x19bb, 0x047f, 0x0319, 0x057f, 0x0519, 0x067f, 0x0619, 0x067f  ; FB1104
	.short 0x0719, 0x067f, 0x0819, 0x067f, 0x0b19, 0x067f, 0x0a19, 0x06ff  ; FB1114
	.short 0x0919, 0x067f, 0x1839, 0x0601, 0x1a39, 0x063f, 0x1939, 0x063f  ; FB1124
	.short 0x19ad, 0x037f, 0x19ae, 0x047f  ; FB1134
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB113C  terminator

; KeyValueList_B26 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[26].
KeyValueList_B26:
	.short 0x1ab5, 0x047f, 0x1ab7, 0x047f, 0x1ab6, 0x047f, 0x1abc, 0x047f  ; FB1144
	.short 0x1abd, 0x047f, 0x1ab8, 0x047f, 0x1ab9, 0x047f, 0x1aba, 0x047f  ; FB1154
	.short 0x1abb, 0x047f, 0x031a, 0x057f, 0x051a, 0x067f, 0x061a, 0x067f  ; FB1164
	.short 0x071a, 0x067f, 0x081a, 0x067f, 0x0b1a, 0x067f, 0x0a1a, 0x06ff  ; FB1174
	.short 0x091a, 0x067f, 0x183a, 0x0601, 0x1a3a, 0x063f, 0x193a, 0x063f  ; FB1184
	.short 0x1aad, 0x037f, 0x1aae, 0x047f  ; FB1194
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB119C  terminator

; KeyValueList_B27 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[27].
KeyValueList_B27:
	.short 0x1bb5, 0x047f, 0x1bb7, 0x047f, 0x1bb6, 0x047f, 0x1bbc, 0x047f  ; FB11A4
	.short 0x1bbd, 0x047f, 0x1bb8, 0x047f, 0x1bb9, 0x047f, 0x1bba, 0x047f  ; FB11B4
	.short 0x1bbb, 0x047f, 0x031b, 0x057f, 0x051b, 0x067f, 0x061b, 0x067f  ; FB11C4
	.short 0x071b, 0x067f, 0x081b, 0x067f, 0x0b1b, 0x067f, 0x0a1b, 0x06ff  ; FB11D4
	.short 0x091b, 0x067f, 0x183b, 0x0601, 0x1a3b, 0x063f, 0x193b, 0x063f  ; FB11E4
	.short 0x1bad, 0x037f, 0x1bae, 0x047f  ; FB11F4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB11FC  terminator

; KeyValueList_B28 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[28].
KeyValueList_B28:
	.short 0x1cb5, 0x047f, 0x1cb7, 0x047f, 0x1cb6, 0x047f, 0x1cbc, 0x047f  ; FB1204
	.short 0x1cbd, 0x047f, 0x1cb8, 0x047f, 0x1cb9, 0x047f, 0x1cba, 0x047f  ; FB1214
	.short 0x1cbb, 0x047f, 0x031c, 0x057f, 0x051c, 0x067f, 0x061c, 0x067f  ; FB1224
	.short 0x071c, 0x067f, 0x081c, 0x067f, 0x0b1c, 0x067f, 0x0a1c, 0x06ff  ; FB1234
	.short 0x091c, 0x067f, 0x183c, 0x0601, 0x1a3c, 0x063f, 0x193c, 0x063f  ; FB1244
	.short 0x1cad, 0x037f, 0x1cae, 0x047f  ; FB1254
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB125C  terminator

; KeyValueList_B29 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[29].
KeyValueList_B29:
	.short 0x1db5, 0x047f, 0x1db7, 0x047f, 0x1db6, 0x047f, 0x1dbc, 0x047f  ; FB1264
	.short 0x1dbd, 0x047f, 0x1db8, 0x047f, 0x1db9, 0x047f, 0x1dba, 0x047f  ; FB1274
	.short 0x1dbb, 0x047f, 0x031d, 0x057f, 0x051d, 0x067f, 0x061d, 0x067f  ; FB1284
	.short 0x071d, 0x067f, 0x081d, 0x067f, 0x0b1d, 0x067f, 0x0a1d, 0x06ff  ; FB1294
	.short 0x091d, 0x067f, 0x183d, 0x0601, 0x1a3d, 0x063f, 0x193d, 0x063f  ; FB12A4
	.short 0x1dad, 0x037f, 0x1dae, 0x047f  ; FB12B4
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB12BC  terminator

; KeyValueList_B30 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[30].
KeyValueList_B30:
	.short 0x1eb5, 0x047f, 0x1eb7, 0x047f, 0x1eb6, 0x047f, 0x1ebc, 0x047f  ; FB12C4
	.short 0x1ebd, 0x047f, 0x1eb8, 0x047f, 0x1eb9, 0x047f, 0x1eba, 0x047f  ; FB12D4
	.short 0x1ebb, 0x047f, 0x031e, 0x057f, 0x051e, 0x067f, 0x061e, 0x067f  ; FB12E4
	.short 0x071e, 0x067f, 0x081e, 0x067f, 0x0b1e, 0x067f, 0x0a1e, 0x06ff  ; FB12F4
	.short 0x091e, 0x067f, 0x183e, 0x0601, 0x1a3e, 0x063f, 0x193e, 0x063f  ; FB1304
	.short 0x1ead, 0x037f, 0x1eae, 0x047f  ; FB1314
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB131C  terminator

; KeyValueList_B31 -- 22 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[31].
KeyValueList_B31:
	.short 0x1fb5, 0x047f, 0x1fb7, 0x047f, 0x1fb6, 0x047f, 0x1fbc, 0x047f  ; FB1324
	.short 0x1fbd, 0x047f, 0x1fb8, 0x047f, 0x1fb9, 0x047f, 0x1fba, 0x047f  ; FB1334
	.short 0x1fbb, 0x047f, 0x031f, 0x057f, 0x051f, 0x067f, 0x061f, 0x067f  ; FB1344
	.short 0x071f, 0x067f, 0x081f, 0x067f, 0x0b1f, 0x067f, 0x0a1f, 0x06ff  ; FB1354
	.short 0x091f, 0x067f, 0x183f, 0x0601, 0x1a3f, 0x063f, 0x193f, 0x063f  ; FB1364
	.short 0x1fad, 0x037f, 0x1fae, 0x047f  ; FB1374
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB137C  terminator

; KeyValueList_B32 -- 0 (key, value) records + the 0xFF terminator;
;          KeyValueListPtrs_B[32].
KeyValueList_B32:
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB1384  terminator
	.short 0xffff, 0xffff, 0xffff, 0xffff            ; FB138C  0xFF fill to the next object

; 0xFB1394-0xFB178F -- 1,020 bytes of 0x00 after the last list, up to the
; module's 0x0E pad; checked all-zero by gen_kvlists.py.  No reader is known.
	.fill 1020, 1, 0x00                                ; FB1394

; 0xFB1790-0xFB17FF -- 112 bytes of 0x0E (RET), module padding.
; Checked byte by byte: notes/proma-2026-09-25/gen_kvlists.py asserts the run.
	.fill 112, 1, 0x0E                                ; FB1790
