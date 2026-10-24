
; ==============================================================================
; 0xFB2000-0xFBFFFF -- FOUR MODULES: the remote-flash reader, the SMF layer,
;                      and two more the directory publishes but does not name
; ==============================================================================
;
; ⚠ READ THIS BEFORE QUOTING A COVERAGE FIGURE.  Like 0xFE0000-0xFE54B5, most of
; this span is real assembly whose instruction boundaries are certified and whose
; MEANING is mostly not established: most labels are `sub_XXXXXX`, which is an
; ADDRESS, not a claim.  What IS established is written out below, routine by
; routine, and everything else is deliberately unnamed.
;
; WHY THIS SPAN.  `python3 notes/prom_a_module_frontier.py` ranks the thunk RUN
; T_SysExDump_RunSendJob-T_SysExTx_SendBytes third in prom_a by contiguous unconverted extent (12 slots,
; 23,200 bytes, reference upper bound 10), and that run's targets are all in
; 0xFB2022-0xFB7AC2.  ★ And it is where emulation gap D lives: the caller the
; gaps file names, `0xFB24D3`, is inside it.
;
; MODULE BOUNDARIES, from the ROM's own 0x0E padding.  Each module ends in a run
; of 0x0E (RET) that reaches the next 0x400/0x800 boundary:
;
;   0xFB2000-0xFB8CA5   code + tables, pad 0xFB8CA6-0xFB8FFF   (858)
;   0xFB9000-0xFBA235   code + tables, pad 0xFBA236-0xFBABFF  (2506)
;   0xFBAC00-0xFBB42D   code,          pad 0xFBB42E-0xFBB7FF   (978)
;   0xFBB800-0xFBFFD3   code,          pad 0xFBFFD4-0xFBFFFF    (44)
;
; ⚠ WHAT PINS EACH START, one by one -- this paragraph said "0xFB2000, 0xFB9000
; and 0xFBB800 each open with `jp` veneers", and only the first of the three
; does:
;   0xFB2000  opens with a block of `jp`/`ret` veneers (`jp 0xFB2018` at
;             0xFB2000, `jp 0xFB201D` at 0xFB200C), the shape the linker gives a
;             module's published entries, and 0xFB2022 is a directory target;
;   0xFBAC00  and 0xFBB800 are themselves DIRECTORY TARGETS, so the linker names
;             them; both open directly on a routine prologue;
;   0xFB9000  is neither: it opens on a `push XIZ / ld XIZ,XSP` prologue and
;             nothing names it.  What pins it is only the pad that ends the
;             previous module at 0xFB8FFF.  Recorded as the weakest of the four.
;
; ★ WHAT THE LINEAR DECODE IS CERTIFIED BY.  `python3
; notes/prom_a_linear_decode_check.py 0xFB2000 0xFB82A0 --offenders` and the same
; on the other code spans:
;   * 0 undecodable `db` bytes once the tables below are excluded;
;   * the end of every span is an instruction boundary of a decode that runs PAST
;     it;
;   * ALL 106 prom_b directory slots that point into 0xFB2000-0xFBFFFF land
;     exactly on an instruction boundary of that decode, 0 off-boundary;
;   * 0 call/calr from an instruction inside the span to an address that is not a
;     boundary.
;   ⚠ That last row is what FOUND the record tables at 0xFB82A0: before they were
;   declared as data it read 2, and both offending "sites" (0xFB846A, 0xFB8770)
;   were bytes inside the table that happen to spell `calr`.  The check is
;   therefore one that can fail, and did.
;   ⚠ THE WHOLE-SPAN VERDICT IS "NOT self-consistent", AND THAT IS NOT A
;   FOOTNOTE (round-2 audit F12).  Run on the full span rather than the
;   code-only sub-span --
;       python3 notes/prom_a_linear_decode_check.py 0xFB2000 0xFC0000 --offenders
;   -- the tool prints `VERDICT: NOT self-consistent`: 72 undecodable `db`
;   bytes and 2 calls into non-boundaries.  Every one of the 74 is inside data
;   this source already declares (checks L1-L5 in notes/prom_a_fb2000_checks.py
;   prove it, by intersecting the tool's residue with the directive extents of
;   this very file).  The tool has no notion of a `.byte` directive, so a span
;   containing ANY declared table can never earn its PASS.  Quote the verdict
;   with that account attached, never the account alone.
;   ⚠ None of this establishes where a span STARTS -- see the same caveat on the
;   0xFE0000 block.  The starts here are pinned by the pads and the veneers.
;
; ★★ EMULATION GAP D, ANSWERED AS FAR AS THE ROM CAN ANSWER IT.  The gaps file
; asks: "Does any instruction in prom_a/prom_b index prom_d's 44-entry offset
; header at file 0x000000, or its 274-entry pointer directory at file 0x000B80,
; with an address that comes back over the link from CPU 2's flash?"
;
; The answer this module gives is NO, and it says why: the firmware never indexes
; the remote image at all.  It STREAMS it, in fixed 8 KiB blocks, through one
; staging buffer:
;
;     Remote_E80000_Read32Blocks (0xFB24EC)
;         XIX  = 0x00E80000, H = 0x1F
;      loop:   Link_RemoteRead(src = XIX, count = 0x2000, dst = 0x60A000)
;              consume the block, XIX += 0x2000, until H reaches 0
;      then    one more Link_RemoteRead of the same shape
;
;   31 blocks in the loop plus one after it is 32 x 0x2000 = 0x40000 bytes, so
;   the range read is remote 0xE80000-0xEBFFFF -- 256 KiB, HALF the size of the
;   prom_d image.  Recorded as measured; what the other half of prom_d is, or
;   whether it is reached by some other path, is NOT established here.
;
;   ⚠ WHICH STACK SLOT IS WHICH is not established by this module.  What is
;   established here is the three literals and the ORDER they are pushed in:
;   (0x60A000) then 0x2000 then XIX.  Naming them dst/count/src comes from
;   INTTC3_LinkDmaDone's decode of the 0xE1/0xE2 pair (see the 0xF8E54F block)
;   and from the gaps file's own reading of 0xFB24D3; 0xF8E0FE itself is still
;   `.incbin`.
;
;   The two link entries it uses are prom_b directory slots and both resolve
;   into prom_a's already-converted link block:
;       T_F40EF0 -> 0xF8E0FE  the remote-read packet builder (gap D names it)
;       T_Link_WaitBlockDone (T_F4123C) -> 0xF8E66D  Link_WaitBlockDone, which is what releases P7 bit 1
;   ⚠ CORRECTED 2026-08-25 (round-2 audit F1).  This header used to say the
;   ~1 s deadline loop at 0xF8E671 is entered "from HERE, and from the sibling
;   at 0xFB248A, and from nowhere else that is converted", and concluded that
;   "a machine that never runs a remote-flash read never reaches that release
;   path at all".  BOTH ARE FALSE.  notes/prom_a_converted_callers.py 0xF4123C
;   (16/16 checks) lists FIFTEEN converted call sites in five separate regions:
;       0xFAABFB  0xFB24D7 0xFB256E 0xFB26D2 0xFB2769  0xFB6FD1
;       0xFC00BE 0xFC0188 0xFC1C62 0xFC20DF 0xFC219D
;       0xFE29EB 0xFE2A73 0xFE2B86 0xFE2BC6
;   Fourteen of them do queue a link packet first -- nine with `call 0xf40ef0`
;   as the immediately preceding call, two with it two calls back in the same
;   block (0xFB2560, 0xFB275B), three one call deeper inside CombiName_RequestRead /
;   SoundGroupName_RequestRead / CombiGroupName_RequestRead.  The fifteenth, 0xFB6FD1, reaches the wait after
;   `call SysExSession_RepaintProgressIfChanged_Nop` (which is a bare `ret` at 0xFB7E9A) and `calr SysExTx_AppendContHeaderIfCont`,
;   and neither of those touches 0xF40EF0 -- so what it is waiting on is NOT
;   established.
;   And the SOURCE handed to the builder is not always remote flash: the eight
;   literal bases the checks pin are 0x00F80300 (prom_a's OWN ROM, at 0xFAABF1
;   and inside CombiName_RequestRead), 0x00C00000 (at 0xFC00AE), 0x00E80000, 0x00EC0000
;   and 0x00EC0300.  The release path is on the LINK BLOCK TRANSFER in general,
;   not on remote flash specifically.
;   CORRECTED 2026-10-04: 0x00F80300 is not prom_a's own ROM.  It is CPU 2's (prom_c's) preset combination records,
;   PromC_PresetBank_Records -- the address goes to CPU 2 in a link packet.  The sites were spelled .LF80300, a
;   label of this image at the same number (prom_c/data_tables/preset_bank.s READERS lists them).
;
; ⚠ WHAT IS NOT ESTABLISHED: what the blocks CONTAIN (the routines that consume
; them, 0xFB7649 and 0xFB6FB2, are converted here but unnamed), and why the
; single-block sibling passes count = 0x0000.
;
; ★ AND THE SMF LAYER.  0xFBA169 carries the ASCII "MThd" and "MTrk" -- the two
; chunk magics of a Standard MIDI File -- so the 0xFB9000 module is a MIDI-file
; reader or writer.  Nothing here says which; see that table's own header.
;
; Routines whose meaning is not established are `sub_XXXXXX` on purpose.
; ==============================================================================
; SysExModule_EntryThunks -- module 10 of ModuleInitDirectory_F82641: the 4-byte phase slots the boot walker calls; slot 0 is `jp SysExModule_Phase0_ResetState`, slot 3 (0xFB200C) is `jp SysExModule_Phase3_GmNormalReset`, the others are `ret` + three `nop`
; Evidence: ModuleInitDirectory_F82641[10] = T_SysExModule_EntryThunks, which in prom_b is `.long 0xFB2000`; the walker at 0xF82846 adds the phase 0x00/04/08/0C/10 to that base and calls it -- the same slot idiom as MIDI_EntryThunks.
; The module 0xFB2000-0xFB8CA5 holds SysExDump_RunSendJob (0xFB2049), the SysEx decode-tree walker at 0xFB63FC and the status reporter 0xFB7DFE (notes/sysex-probes/README.md), as well as the remote-flash reader.
SysExModule_EntryThunks:
	jp SysExModule_BootPhase0                                        ; FB2000  1b 18 20 fb
	ret                                                  ; FB2004  0e
	nop                                                  ; FB2005  00
	nop                                                  ; FB2006  00
	nop                                                  ; FB2007  00
	ret                                                  ; FB2008  0e
	nop                                                  ; FB2009  00
	nop                                                  ; FB200A  00
	nop                                                  ; FB200B  00
	jp SysExModule_Phase3_GmNormalReset                                        ; FB200C  1b 1d 20 fb
	ret                                                  ; FB2010  0e
	nop                                                  ; FB2011  00
	nop                                                  ; FB2012  00
	nop                                                  ; FB2013  00
	ret                                                  ; FB2014  0e
	nop                                                  ; FB2015  00
	nop                                                  ; FB2016  00
	nop                                                  ; FB2017  00
; SysExModule_BootPhase0: module 10's boot phase 0 handler, slot 0 of SysExModule_EntryThunks: call SysEx_ResetSession_Call.
SysExModule_BootPhase0:
	call SysEx_ResetSession_Call                                      ; FB2018  1d 8a 81 fb
	ret                                                  ; FB201C  0e
; SysExModule_Phase3_GmNormalReset -- phase-3 boot slot of the SysEx module: `call ParamApply_ResetPairTablesIfGmNormal / ret`
; Evidence: 0xFB201D, reached only by `jp 0xFB201D` at 0xFB200C, slot 3 of SysExModule_EntryThunks -- the walker pass with WA = 0x0C that boot runs through sub_F8283E (0xF827FC).
SysExModule_Phase3_GmNormalReset:
	call ParamApply_ResetPairTablesIfGmNormal                                      ; FB201D  1d 26 20 fb
	ret                                                  ; FB2021  0e
T_F408F8_Nop:
	ret                                                  ; FB2022  0e
sub_FB3C34_Nop:
	ret                                                  ; FB2023  0e
sub_FB3C34_Nop2:
	ret                                                  ; FB2024  0e
	ret                                                  ; FB2025  0e
; ParamApply_ResetPairTablesIfGmNormal -- when GM mode is on and PROG CHANGE MODE is NORMAL, refill ParamApply_StorePairAndDerive's per-part tables through ParamApply_ResetPairTablesForGm
; Evidence: `bit 2,(0x7f4d)` at 0xFB2026 (GM mode, notes/sysex-probes/sysex_general_midi.py), `ld A,(0x7f32) / and A,0x03 / cp A,0` at 0xFB202C-0xFB2033 (0 = NORMAL, DLTable_NormalTechRemap[0]), `call ParamApply_ResetPairTablesForGm` at 0xFB2037.
; ParamApply_ResetPairTablesForGm fills the pair table 0x60F530 with {0x00,0x1A} and the byte table 0x60F570 with 0x1A, then parts 9 and 0x19 with {0x00,0x20} / 0x20 (0xFB56DA-0xFB5769) -- the two tables ParamApply_StorePairAndDerive writes.
ParamApply_ResetPairTablesIfGmNormal:
	bit	2, (0x7f4d:16)                               ; FB2026  f1 4d 7f ca
	jr z, .LFB203B                                       ; FB202A  66 0f
	ld a, (MidiCfg_ModeBits:16)                                   ; FB202C  c1 32 7f 21
	and A,0x03                                           ; FB2030  c9 cc 03
	cp a, 0x00:i3                                          ; FB2033  c9 d8
	jr nz, .LFB203B                                      ; FB2035  6e 04
	call ParamApply_ResetPairTablesForGm                                      ; FB2037  1d d3 56 fb
.LFB203B:
	ret                                                  ; FB203B  0e
SoundGroup_ReloadSelection_SaveRegs:
	push XDE                                             ; FB203C  3a
	push XHL                                             ; FB203D  3b
	push XIX                                             ; FB203E  3c
	push XIZ                                             ; FB203F  3e
	call T_SoundGroup_ReloadSelection                                        ; FB2040  1d c8 15 f4
	pop XIZ                                              ; FB2044  5e
	pop XIX                                              ; FB2045  5c
	pop XHL                                              ; FB2046  5b
	pop XDE                                              ; FB2047  5a
	ret                                                  ; FB2048  0e
; SysExDump_RunSendJob -- run the pending SysEx bulk-dump transmit job: when bit 7 of (0x60F802) is set, prepare, send the category selected by (0x60F802) & 7, close the dump and report the status
; Evidence: `and C,0x80` on (0x60F802) at 0xFB204E; `set 6,(0x60fd40)`, MidiInARing_InitIfPanelMode79, SysExSession_StartProgressScreen, SysExDump_Handshake (the enquiry / start-transfer templates); `cp bc,5 / jr ugt` and SysExDump_JobTable at 0xFB2070-0xFB207F; then SysExDump_SendJobDone (end-of-dump template) and SysExDump_ShowResult (status -> COMPLETED!/ERROR message); always `ld (0x60fd40),0` and SysEx_ResetSession.
; Run by: prom_b T_SysExDump_RunSendJob after the SEND row->job table 0xF99AE3 writes (0x60F802)|0x80, and by SysExDump_StopTransportsAndSend (`call 0xFB2049` at 0xFB5165) for a received dump request -- notes/sysex-probes/README.md, sysex_bulkdump_tx.py, sysex_command_map.py.
SysExDump_RunSendJob:
	ld c, (0x60f802:24)                                 ; FB2049  c2 02 f8 60 23
	and C,0x80                                           ; FB204E  cb cc 80
	jr z, JumpTable_FB2081_Code_Skip                                           ; FB2051  66 70
	set	6, (0x60fd40:24)                             ; FB2053  f2 40 fd 60 be
	call MidiInARing_InitIfPanelMode79                                      ; FB2058  1d fd 7e fb
	call SysExSession_StartProgressScreen                                      ; FB205C  1d 0b 7b fb
	call SysExDump_Handshake                                      ; FB2060  1d 23 23 fb
	ld c, (0x60f802:24)                                 ; FB2064  c2 02 f8 60 23
	and C,0x07                                           ; FB2069  cb cc 07
	extz BC                                              ; FB206C  d9 12
	extz XBC                                             ; FB206E  e9 12
	cp bc, 0x05:i3                                         ; FB2070  d9 dd
	jr ugt, JumpTable_FB2081_Code_Return                                         ; FB2072  6b 59
	sll bc, 0x02                                         ; FB2074  d9 ee 02
	add XBC,SysExDump_JobTable                             ; FB2077  e9 c8 81 20 fb 00
	ld XBC,(XBC)                                         ; FB207D  a1 21
	jp (xbc)                                             ; FB207F  b1 d8

; ---------------------------------------------------------------------
; SysExDump_JobTable -- 6 LE32 code addresses, an INLINE jump table
;
; Read by: ONE site, `sll bc,0x02 / add XBC,0x00FB2081 / ld XBC,(XBC) / jp (XBC)`
;          at 0xFB2074-0xFB207F.
; ENTRY COUNT 6, from the ROM's own bound: `cps bc,0x05 / jr ugt` at
;          0xFB2070 admits indices 0..5.  ★ LAST-ENTRY TEST: entry 5 is
;          0x00FB20B7 and 0xFB2081 + 6*4 = 0xFB2099, which is entry 0's own
;          target -- the table tiles exactly up to the code it dispatches to.
; Evidence: the base is named by exactly one instruction, the `add Xrr,imm32`
;          quoted above, and the ENTRY COUNT is the ROM's own bound on the
;          index, not a guess at where the values stop looking like
;          addresses; the LAST-ENTRY TEST above is what makes the two agree.
; Unknown:  what the arms DO.  A jump table names its targets, not its
;          operations.
; ---------------------------------------------------------------------
; SysExDump_JobTable: the SEND job number (0x60F802) & 7 -> job routine; row->job is prom_a 0xF99AE3 (sysex-probes/sysex_dump_categories.py).
SysExDump_JobTable:
	.long SysExDump_Job0_TotalKeyboard                                 ; FB2081  [  0]
	.long SysExDump_Job1_None                                 ; FB2085  [  1]
	.long SysExDump_Job2_Sequencer                                 ; FB2089  [  2]
	.long SysExDump_Job3_Sound                                 ; FB208D  [  3]
	.long SysExDump_Job4_SystemPartMidi                                 ; FB2091  [  4]
	.long SysExDump_Job5_Combination                                 ; FB2095  [  5]
SysExDump_Job0_TotalKeyboard:   ; entry: named by 1 `.long` operand, first at 0xFB2081
	call SysExJob_TotalKeyboard                                      ; FB2099  1d cd 22 fb
	jr .LFB20BB                                          ; FB209D  68 1c
SysExDump_Job1_None:   ; entry: named by 1 `.long` operand, first at 0xFB2085
	call SysExJob_TotalKeyboard_Nop                                      ; FB209F  1d e6 22 fb
	jr .LFB20BB                                          ; FB20A3  68 16
SysExDump_Job2_Sequencer:   ; entry: named by 1 `.long` operand, first at 0xFB2089
	call SysExJob_Sequencer                                      ; FB20A5  1d e7 22 fb
	jr .LFB20BB                                          ; FB20A9  68 10
SysExDump_Job3_Sound:   ; entry: named by 1 `.long` operand, first at 0xFB208D
	call SysExJob_Sound                                      ; FB20AB  1d f6 22 fb
	jr .LFB20BB                                          ; FB20AF  68 0a
SysExDump_Job4_SystemPartMidi:   ; entry: named by 1 `.long` operand, first at 0xFB2091
	call SysExJob_SystemPartMidi                                      ; FB20B1  1d 05 23 fb
	jr .LFB20BB                                          ; FB20B5  68 04
SysExDump_Job5_Combination:   ; entry: named by 1 `.long` operand, first at 0xFB2095
	call SysExJob_Combination                                      ; FB20B7  1d 14 23 fb
.LFB20BB:
	call SysExDump_SendJobDone                                      ; FB20BB  1d ad 27 fb
	call SysExDump_ShowResult                                      ; FB20BF  1d fe 7d fb
JumpTable_FB2081_Code_Skip:
	ld (0x60fd40:24), 0x00                             ; FB20C3  f2 40 fd 60 00 00
	call SysEx_ResetSession                                      ; FB20C9  1d 56 81 fb
JumpTable_FB2081_Code_Return:
	ret                                                  ; FB20CD  0e
; SysExRx_PollRing601646: drain ring 0x601646 through a 3-state SysEx assembler (F0, then 0x50 or 0x7E, then body up to F7) into
;   SysExRx_AppendByte; on F7 run SysExRx_ParseDispatch_Ring601646.
SysExRx_PollRing601646:
	pushw hl                                             ; FB20CE  2b
	pushw de                                             ; FB20CF  2a
	push XIX                                             ; FB20D0  3c
	cp	(0x89:8), 0xff                               ; FB20D1  c0 89 3f ff
	jrl z, .LFB215C                                      ; FB20D5  76 84 00
	lda xix, (0x60fd43:24)                               ; FB20D8  f2 43 fd 60 34
	ld (0x60fd40:24), 0x00                             ; FB20DD  f2 40 fd 60 00 00
.LFB20E3:
	call T_Ring601646_Get                                ; FB20E3  1d 38 1e f4
	ld DE,WA                                             ; FB20E7  d8 8a
	cp WA,0xffff                                         ; FB20E9  d8 cf ff ff
	jrl z, .LFB215C                                      ; FB20ED  76 6c 00
	ld H,A                                               ; FB20F0  c9 8e
	call MidiInARing_InitIfPanelMode79                                      ; FB20F2  1d fd 7e fb
	ld C,(XIX)                                           ; FB20F6  84 23
	extz BC                                              ; FB20F8  d9 12
	cp bc, 0x00:i3                                         ; FB20FA  d9 d8
	jr z, .LFB2104                                       ; FB20FC  66 06
	cp bc, 0x01:i3                                         ; FB20FE  d9 d9
	jr z, .LFB210E                                       ; FB2100  66 0c
	jr .LFB211D                                          ; FB2102  68 19
.LFB2104:
	cp H,0xf0                                            ; FB2104  ce cf f0
	jr nz, .LFB20E3                                      ; FB2107  6e da
	ld (XIX),0x01                                        ; FB2109  b4 00 01
	jr .LFB2131                                          ; FB210C  68 23
.LFB210E:
	cp H,0x50                                            ; FB210E  ce cf 50
	jr z, .LFB2118                                       ; FB2111  66 05
	cp H,0x7e                                            ; FB2113  ce cf 7e
	jr nz, .LFB2153                                      ; FB2116  6e 3b
.LFB2118:
	ld (XIX),0x02                                        ; FB2118  b4 00 02
	jr .LFB2131                                          ; FB211B  68 14
.LFB211D:
	ld C,H                                               ; FB211D  ce 8b
	and C,0x80                                           ; FB211F  cb cc 80
	jr nz, .LFB213D                                      ; FB2122  6e 19
	ld xbc, (0x60fc80:24)                               ; FB2124  e2 80 fc 60 21
	ld WA,(XBC)                                          ; FB2129  91 20
	cp WA,0x00ff                                         ; FB212B  d8 cf ff 00
	jr nc, .LFB2153                                      ; FB212F  6f 22
.LFB2131:
	ld C,H                                               ; FB2131  ce 8b
	extz BC                                              ; FB2133  d9 12
	pushw bc                                             ; FB2135  29
	call SysExRx_AppendByte                                      ; FB2136  1d 65 61 fb
.LFB213A:
	popw bc                                              ; FB213A  49
	jr .LFB20E3                                          ; FB213B  68 a6
.LFB213D:
	cp H,0xf7                                            ; FB213D  ce cf f7
	jr nz, .LFB2153                                      ; FB2140  6e 11
	ld (XIX),0x00                                        ; FB2142  b4 00 00
	ld C,H                                               ; FB2145  ce 8b
	extz BC                                              ; FB2147  d9 12
	pushw bc                                             ; FB2149  29
	call SysExRx_AppendByte                                      ; FB214A  1d 65 61 fb
	calr SysExRx_ParseDispatch_Ring601646                                      ; FB214E  1e 0f 00
	jr .LFB213A                                          ; FB2151  68 e7
.LFB2153:
	ld (XIX),0x00                                        ; FB2153  b4 00 00
	call SysExRx_ResetBuffer                                      ; FB2156  1d f3 80 fb
	jr .LFB20E3                                          ; FB215A  68 87
.LFB215C:
	pop XIX                                              ; FB215C  5c
	popw de                                              ; FB215D  4a
	popw hl                                              ; FB215E  4b
	ret                                                  ; FB215F  0e
; SysExRx_ParseDispatch_Ring601646: SysExRx_ParseMessage; when status (field 4) is 0 and the command (field 0) is below 0x22, call
;   PtrTable_F4F800[command].
SysExRx_ParseDispatch_Ring601646:
	push XIX                                             ; FB2160  3c
	lda xix, (U8Rec16_GetField:24)                             ; FB2161  f2 d3 62 fb 34
	call SysExRx_ParseMessage                                      ; FB2166  1d af 63 fb
	pushw 0x04                                           ; FB216A  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB216D  e2 d8 fc 60 21
	push XBC                                             ; FB2172  39
	lda xiy, (.LFB217B:24)                               ; FB2173  f2 7b 21 fb 35
	push XIY                                             ; FB2178  3d
	jp (xix)                                             ; FB2179  b4 d8
.LFB217B:
	inc 6,XSP                                            ; FB217B  ef 66
	cp a, 0x00:i3                                          ; FB217D  c9 d8
	jr nz, .LFB21C1                                      ; FB217F  6e 40
	pushw 0x00                                           ; FB2181  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB2184  e2 d8 fc 60 21
	push XBC                                             ; FB2189  39
	lda xiy, (.LFB2192:24)                               ; FB218A  f2 92 21 fb 35
	push XIY                                             ; FB218F  3d
	jp (xix)                                             ; FB2190  b4 d8
.LFB2192:
	inc 6,XSP                                            ; FB2192  ef 66
	cp A,0x22                                            ; FB2194  c9 cf 22
	jr nc, .LFB21C1                                      ; FB2197  6f 28
	pushw 0x00                                           ; FB2199  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB219C  e2 d8 fc 60 21
	push XBC                                             ; FB21A1  39
	lda xiy, (.LFB21AA:24)                               ; FB21A2  f2 aa 21 fb 35
	push XIY                                             ; FB21A7  3d
	jp (xix)                                             ; FB21A8  b4 d8
.LFB21AA:
	mul A,0x04                                           ; FB21AA  c9 08 04
	extz XWA                                             ; FB21AD  e8 12
	add XWA,PtrTable_F4F800                              ; FB21AF  e8 c8 00 f8 f4 00
	ld XBC,(XWA)                                         ; FB21B5  a0 21
	lda xiy, (.LFB21BF:24)                               ; FB21B7  f2 bf 21 fb 35
	push XIY                                             ; FB21BC  3d
	jp (xbc)                                             ; FB21BD  b1 d8
.LFB21BF:
	inc 6,XSP                                            ; FB21BF  ef 66
.LFB21C1:
	call SysExRx_AnswerRefused2B2C                                      ; FB21C1  1d 97 51 fb
	call SysEx_ResetSession                                      ; FB21C5  1d 56 81 fb
	pop XIX                                              ; FB21C9  5c
	ret                                                  ; FB21CA  0e
; SysExRx_PollRing601C6E: the same assembler on ring 0x601C6E; on F7 run SysExRx_ParseDispatch_Ring601C6E.
SysExRx_PollRing601C6E:
	pushw hl                                             ; FB21CB  2b
	pushw de                                             ; FB21CC  2a
	push XIX                                             ; FB21CD  3c
	cp	(0x89:8), 0xff                               ; FB21CE  c0 89 3f ff
	jrl z, .LFB2259                                      ; FB21D2  76 84 00
	lda xix, (0x60fd43:24)                               ; FB21D5  f2 43 fd 60 34
	ld (0x60fd40:24), 0x00                             ; FB21DA  f2 40 fd 60 00 00
.LFB21E0:
	call T_Ring601C6E_Get                                ; FB21E0  1d a4 1e f4
	ld DE,WA                                             ; FB21E4  d8 8a
	cp WA,0xffff                                         ; FB21E6  d8 cf ff ff
	jrl z, .LFB2259                                      ; FB21EA  76 6c 00
	ld H,A                                               ; FB21ED  c9 8e
	call MidiInARing_InitIfPanelMode79                                      ; FB21EF  1d fd 7e fb
	ld C,(XIX)                                           ; FB21F3  84 23
	extz BC                                              ; FB21F5  d9 12
	cp bc, 0x00:i3                                         ; FB21F7  d9 d8
	jr z, .LFB2201                                       ; FB21F9  66 06
	cp bc, 0x01:i3                                         ; FB21FB  d9 d9
	jr z, .LFB220B                                       ; FB21FD  66 0c
	jr .LFB221A                                          ; FB21FF  68 19
.LFB2201:
	cp H,0xf0                                            ; FB2201  ce cf f0
	jr nz, .LFB21E0                                      ; FB2204  6e da
	ld (XIX),0x01                                        ; FB2206  b4 00 01
	jr .LFB222E                                          ; FB2209  68 23
.LFB220B:
	cp H,0x50                                            ; FB220B  ce cf 50
	jr z, .LFB2215                                       ; FB220E  66 05
	cp H,0x7e                                            ; FB2210  ce cf 7e
	jr nz, .LFB2250                                      ; FB2213  6e 3b
.LFB2215:
	ld (XIX),0x02                                        ; FB2215  b4 00 02
	jr .LFB222E                                          ; FB2218  68 14
.LFB221A:
	ld C,H                                               ; FB221A  ce 8b
	and C,0x80                                           ; FB221C  cb cc 80
	jr nz, .LFB223A                                      ; FB221F  6e 19
	ld xbc, (0x60fc80:24)                               ; FB2221  e2 80 fc 60 21
	ld WA,(XBC)                                          ; FB2226  91 20
	cp WA,0x00ff                                         ; FB2228  d8 cf ff 00
	jr nc, .LFB2250                                      ; FB222C  6f 22
.LFB222E:
	ld C,H                                               ; FB222E  ce 8b
	extz BC                                              ; FB2230  d9 12
	pushw bc                                             ; FB2232  29
	call SysExRx_AppendByte                                      ; FB2233  1d 65 61 fb
.LFB2237:
	popw bc                                              ; FB2237  49
	jr .LFB21E0                                          ; FB2238  68 a6
.LFB223A:
	cp H,0xf7                                            ; FB223A  ce cf f7
	jr nz, .LFB2250                                      ; FB223D  6e 11
	ld (XIX),0x00                                        ; FB223F  b4 00 00
	ld C,H                                               ; FB2242  ce 8b
	extz BC                                              ; FB2244  d9 12
	pushw bc                                             ; FB2246  29
	call SysExRx_AppendByte                                      ; FB2247  1d 65 61 fb
	calr SysExRx_ParseDispatch_Ring601C6E                                      ; FB224B  1e 0f 00
	jr .LFB2237                                          ; FB224E  68 e7
.LFB2250:
	ld (XIX),0x00                                        ; FB2250  b4 00 00
	call SysExRx_ResetBuffer                                      ; FB2253  1d f3 80 fb
	jr .LFB21E0                                          ; FB2257  68 87
.LFB2259:
	pop XIX                                              ; FB2259  5c
	popw de                                              ; FB225A  4a
	popw hl                                              ; FB225B  4b
	ret                                                  ; FB225C  0e
; SysExRx_ParseDispatch_Ring601C6E: as SysExRx_ParseDispatch_Ring601646, through PtrTable_F4F888.
SysExRx_ParseDispatch_Ring601C6E:
	push XIX                                             ; FB225D  3c
	lda xix, (U8Rec16_GetField:24)                             ; FB225E  f2 d3 62 fb 34
	call SysExRx_ParseMessage                                      ; FB2263  1d af 63 fb
	pushw 0x04                                           ; FB2267  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB226A  e2 d8 fc 60 21
	push XBC                                             ; FB226F  39
	lda xiy, (.LFB2278:24)                               ; FB2270  f2 78 22 fb 35
	push XIY                                             ; FB2275  3d
	jp (xix)                                             ; FB2276  b4 d8
.LFB2278:
	inc 6,XSP                                            ; FB2278  ef 66
	cp a, 0x00:i3                                          ; FB227A  c9 d8
	jr nz, .LFB22BE                                      ; FB227C  6e 40
	pushw 0x00                                           ; FB227E  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB2281  e2 d8 fc 60 21
	push XBC                                             ; FB2286  39
	lda xiy, (.LFB228F:24)                               ; FB2287  f2 8f 22 fb 35
	push XIY                                             ; FB228C  3d
	jp (xix)                                             ; FB228D  b4 d8
.LFB228F:
	inc 6,XSP                                            ; FB228F  ef 66
	cp A,0x22                                            ; FB2291  c9 cf 22
	jr nc, .LFB22BE                                      ; FB2294  6f 28
	pushw 0x00                                           ; FB2296  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB2299  e2 d8 fc 60 21
	push XBC                                             ; FB229E  39
	lda xiy, (.LFB22A7:24)                               ; FB229F  f2 a7 22 fb 35
	push XIY                                             ; FB22A4  3d
	jp (xix)                                             ; FB22A5  b4 d8
.LFB22A7:
	mul A,0x04                                           ; FB22A7  c9 08 04
	extz XWA                                             ; FB22AA  e8 12
	add XWA,PtrTable_F4F888                              ; FB22AC  e8 c8 88 f8 f4 00
	ld XBC,(XWA)                                         ; FB22B2  a0 21
	lda xiy, (.LFB22BC:24)                               ; FB22B4  f2 bc 22 fb 35
	push XIY                                             ; FB22B9  3d
	jp (xbc)                                             ; FB22BA  b1 d8
.LFB22BC:
	inc 6,XSP                                            ; FB22BC  ef 66
.LFB22BE:
	call SysExRx_AnswerRefused2B2C                                      ; FB22BE  1d 97 51 fb
	call SysEx_ResetSession                                      ; FB22C2  1d 56 81 fb
	pop XIX                                              ; FB22C6  5c
	ret                                                  ; FB22C7  0e
; SysExCmd_ResetSession: the foreground table's (PtrTable_F4F888) default -- SysEx_ResetSession and nothing else
;   (sysex-probes/sysex_handshake_gate.py --tables).
SysExCmd_ResetSession:
	call SysEx_ResetSession                                      ; FB22C8  1d 56 81 fb
	ret                                                  ; FB22CC  0e
; SysExJob_TotalKeyboard: bit 3 of (0x60FD40) around SysExXfer_SetJobTotal_TotalKeyboard and SysExDump_SendAllCategories.
SysExJob_TotalKeyboard:
	set	3, (0x60fd40:24)                             ; FB22CD  f2 40 fd 60 bb
	lda xbc, (0x60fce8:24)                               ; FB22D2  f2 e8 fc 60 31
	push XBC                                             ; FB22D7  39
	call SysExXfer_SetJobTotal_TotalKeyboard                                      ; FB22D8  1d 9b 74 fb
	calr SysExDump_SendAllCategories                                      ; FB22DC  1e 03 01
	res	3, (0x60fd40:24)                             ; FB22DF  f2 40 fd 60 b3
	pop XBC                                              ; FB22E4  59
	ret                                                  ; FB22E5  0e
SysExJob_TotalKeyboard_Nop:
	ret                                                  ; FB22E6  0e
; SysExJob_Sequencer: SysExXfer_SetJobTotal_Sequencer((0x60FCE8)), SysExDump_SendSequencer.
SysExJob_Sequencer:
	lda xbc, (0x60fce8:24)                               ; FB22E7  f2 e8 fc 60 31
	push XBC                                             ; FB22EC  39
	call SysExXfer_SetJobTotal_Sequencer                                      ; FB22ED  1d 3e 75 fb
	calr SysExDump_SendSequencer                                      ; FB22F1  1e 93 02
	pop XBC                                              ; FB22F4  59
	ret                                                  ; FB22F5  0e
; SysExJob_Sound: SysExXfer_SetJobTotal_Sound((0x60FCE8)), SysExDump_SendSound.
SysExJob_Sound:
	lda xbc, (0x60fce8:24)                               ; FB22F6  f2 e8 fc 60 31
	push XBC                                             ; FB22FB  39
	call SysExXfer_SetJobTotal_Sound                                      ; FB22FC  1d 1a 75 fb
	calr SysExDump_SendSound                                      ; FB2300  1e 80 01
	pop XBC                                              ; FB2303  59
	ret                                                  ; FB2304  0e
; SysExJob_SystemPartMidi: SysExXfer_SetJobTotal_SystemPartMidi((0x60FCE8)), SysExDump_SendSystemPartMidi.
SysExJob_SystemPartMidi:
	lda xbc, (0x60fce8:24)                               ; FB2305  f2 e8 fc 60 31
	push XBC                                             ; FB230A  39
	call SysExXfer_SetJobTotal_SystemPartMidi                                      ; FB230B  1d d7 74 fb
	calr SysExDump_SendSystemPartMidi                                      ; FB230F  1e dd 00
	pop XBC                                              ; FB2312  59
	ret                                                  ; FB2313  0e
; SysExJob_Combination: SysExXfer_SetJobTotal_Combination((0x60FCE8)), SysExDump_SendCombination.
SysExJob_Combination:
	lda xbc, (0x60fce8:24)                               ; FB2314  f2 e8 fc 60 31
	push XBC                                             ; FB2319  39
	call SysExXfer_SetJobTotal_Combination                                      ; FB231A  1d 8a 75 fb
	calr SysExDump_SendCombination                                      ; FB231E  1e 54 03
	pop XBC                                              ; FB2321  59
	ret                                                  ; FB2322  0e
; SysExDump_Handshake: send F0 50 21 04 00 11 F7 and await class 8, then F0 50 22 04 00 11 F7 and await class 1, 3 tries each; success sets bit 7
;   of (0x60FD40) (per-frame ACK on).
SysExDump_Handshake:
	pushw hl                                             ; FB2323  2b
	push XIX                                             ; FB2324  3c
	lda xix, (0x60fcd8:24)                               ; FB2325  f2 d8 fc 60 34
	res	7, (0x60fd40:24)                             ; FB232A  f2 40 fd 60 b7
	ld h, 0x00:opc                                          ; FB232F  26 00
.LFB2331:
	pushw 0x07                                           ; FB2331  0b 07 00
	lda xbc, (0xf4fed5:24)                               ; FB2334  f2 d5 fe f4 31
	push XBC                                             ; FB2339  39
	call SysExTx_AppendAndSendOnF7                                      ; FB233A  1d 7f 6e fb
	set	2, (0x60fd40:24)                             ; FB233E  f2 40 fd 60 ba
	call SysExRx_AwaitReply                                      ; FB2343  1d 72 60 fb
	pushw 0x00                                           ; FB2347  0b 00 00
	ld XBC,(XIX)                                         ; FB234A  a4 21
	push XBC                                             ; FB234C  39
	call U8Rec16_GetField                                      ; FB234D  1d d3 62 fb
	inc 8,XSP                                            ; FB2351  ef 60
	inc 4,XSP                                            ; FB2353  ef 64
	cp A,0x08                                            ; FB2355  c9 cf 08
	jr z, .LFB2360                                       ; FB2358  66 06
	inc 1,H                                              ; FB235A  ce 61
	cp h, 0x03:i3                                          ; FB235C  ce db
	jr c, .LFB2331                                       ; FB235E  67 d1
.LFB2360:
	cp h, 0x03:i3                                          ; FB2360  ce db
	jr nz, .LFB2375                                      ; FB2362  6e 11
	pushw 0x00                                           ; FB2364  0b 00 00
	pushw 0x04                                           ; FB2367  0b 04 00
	ld XBC,(XIX)                                         ; FB236A  a4 21
	push XBC                                             ; FB236C  39
	call U8Rec16_SetField                                      ; FB236D  1d 19 62 fb
	inc 8,XSP                                            ; FB2371  ef 60
	jr .LFB23DF                                          ; FB2373  68 6a
.LFB2375:
	pushw 0x06                                           ; FB2375  0b 06 00
	ld XBC,(XIX)                                         ; FB2378  a4 21
	push XBC                                             ; FB237A  39
	call U8Rec16_GetField                                      ; FB237B  1d d3 62 fb
	ld (0x60fc90:24), a                                 ; FB237F  f2 90 fc 60 41
	pushw 0x07                                           ; FB2384  0b 07 00
	ld XBC,(XIX)                                         ; FB2387  a4 21
	push XBC                                             ; FB2389  39
	call U8Rec16_GetField                                      ; FB238A  1d d3 62 fb
	ld (0x60fc91:24), a                                 ; FB238E  f2 91 fc 60 41
	pushw 0x08                                           ; FB2393  0b 08 00
	ld XBC,(XIX)                                         ; FB2396  a4 21
	push XBC                                             ; FB2398  39
	call U8Rec16_GetField                                      ; FB2399  1d d3 62 fb
	ld (0x60fc92:24), a                                 ; FB239D  f2 92 fc 60 41
	ld h, 0x03:opc                                          ; FB23A2  26 03
	add XSP,0x00000012                                   ; FB23A4  ef c8 12 00 00 00
.LFB23AA:
	pushw 0x07                                           ; FB23AA  0b 07 00
	lda xbc, (0xf4fedc:24)                               ; FB23AD  f2 dc fe f4 31
	push XBC                                             ; FB23B2  39
	call SysExTx_AppendAndSendOnF7                                      ; FB23B3  1d 7f 6e fb
	set	2, (0x60fd40:24)                             ; FB23B7  f2 40 fd 60 ba
	call SysExRx_AwaitReply                                      ; FB23BC  1d 72 60 fb
	pushw 0x00                                           ; FB23C0  0b 00 00
	ld XBC,(XIX)                                         ; FB23C3  a4 21
	push XBC                                             ; FB23C5  39
	call U8Rec16_GetField                                      ; FB23C6  1d d3 62 fb
	inc 8,XSP                                            ; FB23CA  ef 60
	inc 4,XSP                                            ; FB23CC  ef 64
	cp a, 0x01:i3                                          ; FB23CE  c9 d9
	jr nz, .LFB23D9                                      ; FB23D0  6e 07
	set	7, (0x60fd40:24)                             ; FB23D2  f2 40 fd 60 bf
	jr .LFB23DF                                          ; FB23D7  68 06
.LFB23D9:
	dec 1,H                                              ; FB23D9  ce 69
	cp h, 0x00:i3                                          ; FB23DB  ce d8
	jr nz, .LFB23AA                                      ; FB23DD  6e cb
.LFB23DF:
	pop XIX                                              ; FB23DF  5c
	popw hl                                              ; FB23E0  4b
	ret                                                  ; FB23E1  0e
; SysExDump_SendAllCategories: the TOTAL KEYBOARD order -- SYSTEM,PART & MIDI, SOUND, COMBINATION, SEQUENCER.
SysExDump_SendAllCategories:
	calr SysExDump_SendSystemPartMidi                                      ; FB23E2  1e 0a 00
	calr SysExDump_SendSound                                      ; FB23E5  1e 9b 00
	calr SysExDump_SendCombination                                      ; FB23E8  1e 8a 02
	calr SysExDump_SendSequencer                                      ; FB23EB  1e 99 01
	ret                                                  ; FB23EE  0e
; SysExDump_SendSystemPartMidi: parts 1 and 2, then SysExDump_SendCategoryDone.
SysExDump_SendSystemPartMidi:
	calr SysExDump_SendSystemPart1                                      ; FB23EF  1e 07 00
	calr SysExDump_SendSystemPart2                                      ; FB23F2  1e 49 00
	calr SysExDump_SendCategoryDone                                      ; FB23F5  1e 86 03
	ret                                                  ; FB23F8  0e
; SysExDump_SendSystemPart1: step 1, CPU1 0x7600..0x7620, header prom_b 0xF4FEF8 (dump address 0x100000).
SysExDump_SendSystemPart1:
	pushw 0x04                                           ; FB23F9  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB23FC  e2 d8 fc 60 21
	push XBC                                             ; FB2401  39
	call U8Rec16_GetField                                      ; FB2402  1d d3 62 fb
	inc 6,XSP                                            ; FB2406  ef 66
	cp a, 0x00:i3                                          ; FB2408  c9 d8
	jr nz, .LFB243D                                      ; FB240A  6e 31
	pushw 0x01                                           ; FB240C  0b 01 00
	pushw 0x03                                           ; FB240F  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB2412  e2 e0 fc 60 21
	push XBC                                             ; FB2417  39
	call U8Rec16_SetField                                      ; FB2418  1d 19 62 fb
	lda xbc, (0x60fcf8:24)                               ; FB241C  f2 f8 fc 60 31
	push XBC                                             ; FB2421  39
	call SysExXfer_SetPart_SystemPart1                                      ; FB2422  1d ba 75 fb
	pushw 0x0c                                           ; FB2426  0b 0c 00
	lda xbc, (0xf4fef8:24)                               ; FB2429  f2 f8 fe f4 31
	push XBC                                             ; FB242E  39
	call SysExTx_AppendAndSendOnF7                                      ; FB242F  1d 7f 6e fb
	call SysExDump_SendFrames                                      ; FB2433  1d 6b 6f fb
	add XSP,0x00000012                                   ; FB2437  ef c8 12 00 00 00
.LFB243D:
	ret                                                  ; FB243D  0e
; SysExDump_SendSystemPart2: step 2, CPU1 0x7620..0x7F80, header prom_b 0xF4FF04 (dump address 0x100020).
SysExDump_SendSystemPart2:
	pushw 0x04                                           ; FB243E  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2441  e2 d8 fc 60 21
	push XBC                                             ; FB2446  39
	call U8Rec16_GetField                                      ; FB2447  1d d3 62 fb
	inc 6,XSP                                            ; FB244B  ef 66
	cp a, 0x00:i3                                          ; FB244D  c9 d8
	jr nz, .LFB2482                                      ; FB244F  6e 31
	pushw 0x02                                           ; FB2451  0b 02 00
	pushw 0x03                                           ; FB2454  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB2457  e2 e0 fc 60 21
	push XBC                                             ; FB245C  39
	call U8Rec16_SetField                                      ; FB245D  1d 19 62 fb
	lda xbc, (0x60fcf8:24)                               ; FB2461  f2 f8 fc 60 31
	push XBC                                             ; FB2466  39
	call SysExXfer_SetPart_SystemPart2                                      ; FB2467  1d e4 75 fb
	pushw 0x0c                                           ; FB246B  0b 0c 00
	lda xbc, (0xf4ff04:24)                               ; FB246E  f2 04 ff f4 31
	push XBC                                             ; FB2473  39
	call SysExTx_AppendAndSendOnF7                                      ; FB2474  1d 7f 6e fb
	call SysExDump_SendFrames                                      ; FB2478  1d 6b 6f fb
	add XSP,0x00000012                                   ; FB247C  ef c8 12 00 00 00
.LFB2482:
	ret                                                  ; FB2482  0e
; SysExDump_SendSound: Remote_E80000_Read32Blocks (CPU2 flash 0xE80000..0xEC0000), then SysExDump_SendCategoryDone.
SysExDump_SendSound:
	calr Remote_E80000_Read32Blocks                      ; FB2483  1e 66 00
	calr SysExDump_SendCategoryDone                                      ; FB2486  1e f5 02
	ret                                                  ; FB2489  0e
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; 0xFB248A -- the single-block sibling of Remote_E80000_Read32Blocks: one
;            remote-flash read of 0xE80000 with count 0x0000
;
; ⚠ NO LABEL, DELIBERATELY.  notes/gen_prom_a_block.py places a label only
;          where some site NAMES the address, and nothing names this one --
;          see Called from.  A label here would assert an entry point that the
;          reference scan does not support.
;
; Called from: no absolute reference anywhere (`python3 notes/prom_a_xref.py
;          0xFB248A` finds none), so it is reached by a `calr` from inside this
;          module or from code that is still `.incbin`.  Recorded as a searched
;          negative with the search named.
; Inputs:  (0x60FCD8) and (0x60FCE0), two pointers this module keeps; the guard
;          `0xFB62D3(4, (0x60FCD8))` must return 0 or the routine does nothing.
; Outputs: whatever a count of 0x0000 transfers into RAM 0x60A000 (the same
;          staging buffer Remote_E80000_Read32Blocks below fills 0x2000 bytes at
;          a time), and one 12-byte display list drawn from prom_b 0xF4FF10.
;          On a link timeout -- Link_WaitBlockDone returns WA = 0xFFFF -- it
;          calls 0xFB6F6B and returns.
; Evidence: the three arguments are literals in the instruction stream:
;          `lda XBC,(0x60A000) / push` then `pushw 0x0000` then
;          `ld XWA,0x00E80000 / push`, and the call at 0xFB24D3 is
;          `call 0xF40EF0`, the prom_b slot whose `jp` names 0xF8E0FE.  0xE80000
;          is the flash window of notes/FINDINGS-memory-map.md sec.5.
; Unknown:  ⚠ WHY THE COUNT IS ZERO.  Every other caller of this entry passes
;          0x2000.  A zero-length block read, a 0x10000 wrap and a "position
;          only" probe all fit the byte; nothing here chooses between them.
; ---------------------------------------------------------------------
	pushw 0x04                                           ; FB248A  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB248D  e2 d8 fc 60 21
	push XBC                                             ; FB2492  39
	call U8Rec16_GetField                                      ; FB2493  1d d3 62 fb
	inc 6,XSP                                            ; FB2497  ef 66
	cp a, 0x00:i3                                          ; FB2499  c9 d8
	jr nz, .LFB24EB                                      ; FB249B  6e 4e
	pushw 0x04                                           ; FB249D  0b 04 00
	pushw 0x03                                           ; FB24A0  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB24A3  e2 e0 fc 60 21
	push XBC                                             ; FB24A8  39
	call U8Rec16_SetField                                      ; FB24A9  1d 19 62 fb
	lda xbc, (0x60fcf8:24)                               ; FB24AD  f2 f8 fc 60 31
	push XBC                                             ; FB24B2  39
	call SysExXfer_SetPart_SoundOrphan                                      ; FB24B3  1d 29 76 fb
	pushw 0x0c                                           ; FB24B7  0b 0c 00
	lda xbc, (0xf4ff10:24)                               ; FB24BA  f2 10 ff f4 31
	push XBC                                             ; FB24BF  39
	call SysExTx_AppendAndSendOnF7                                      ; FB24C0  1d 7f 6e fb
	lda xbc, (0x60a000:24)                               ; FB24C4  f2 00 a0 60 31
	push XBC                                             ; FB24C9  39
	pushw 0x00                                           ; FB24CA  0b 00 00
	ld XWA,0x00e80000                                    ; FB24CD  40 00 00 e8 00
	push XWA                                             ; FB24D2  38
	call T_Link_SendCommandE2                            ; FB24D3  1d f0 0e f4
	call T_Link_WaitBlockDone                            ; FB24D7  1d 3c 12 f4
	add XSP,0x0000001c                                   ; FB24DB  ef c8 1c 00 00 00
	cp WA,0xffff                                         ; FB24E1  d8 cf ff ff
	jr z, .LFB24EB                                       ; FB24E5  66 04
	call SysExDump_SendFrames                                      ; FB24E7  1d 6b 6f fb
.LFB24EB:
	ret                                                  ; FB24EB  0e

; ---------------------------------------------------------------------
; Remote_E80000_Read32Blocks -- stream remote 0xE80000-0xEBFFFF through 0x60A000
;
; Called from: no absolute reference (`python3 notes/prom_a_xref.py 0xFB24EC`);
;          same searched negative as its sibling above.
; Inputs:  the same (0x60FCD8) guard; (0x60FCE0) and (0x60FCF8), the module's
;          two pointer variables.
; Outputs: 32 blocks of 0x2000 bytes fetched from remote 0xE80000 upward into
;          RAM 0x60A000, each one handed to 0xFB7649 and then to 0xFB6FB2 before
;          the next is fetched; a 12-byte display list from prom_b 0xF4FF1C; and
;          0xFB6F6B on a link timeout.  H, XIX, XBC and WA clobbered.
; Evidence: `ld XIX,0x00E80000` at 0xFB251F, `ldb h,0x1F` at 0xFB2524,
;          `add XIX,0x00002000` at 0xFB2548 and `dec 1,H / cps h,0x00 / jr nz`
;          at 0xFB2546-0xFB2554 -- 31 iterations -- plus ONE more block at
;          0xFB2556-0xFB2560 after the loop.  32 x 0x2000 = 0x40000.
; Unknown:  what the blocks are FOR.  0xFB7649 and 0xFB6FB2 are converted in this
;          module and are still `sub_`; nothing here says whether the stream is
;          being written to disk, checksummed, or copied into another memory.
; ---------------------------------------------------------------------
Remote_E80000_Read32Blocks:
	pushw hl                                             ; FB24EC  2b
	push XIX                                             ; FB24ED  3c
	pushw 0x04                                           ; FB24EE  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB24F1  e2 d8 fc 60 21
	push XBC                                             ; FB24F6  39
	call U8Rec16_GetField                                      ; FB24F7  1d d3 62 fb
	inc 6,XSP                                            ; FB24FB  ef 66
	cp a, 0x00:i3                                          ; FB24FD  c9 d8
	jrl nz, .LFB2580                                     ; FB24FF  7e 7e 00
	pushw 0x05                                           ; FB2502  0b 05 00
	pushw 0x03                                           ; FB2505  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB2508  e2 e0 fc 60 21
	push XBC                                             ; FB250D  39
	call U8Rec16_SetField                                      ; FB250E  1d 19 62 fb
	pushw 0x0c                                           ; FB2512  0b 0c 00
	lda xbc, (0xf4ff1c:24)                               ; FB2515  f2 1c ff f4 31
	push XBC                                             ; FB251A  39
	call SysExTx_AppendAndSendOnF7                                      ; FB251B  1d 7f 6e fb
	ld XIX,0x00e80000                                    ; FB251F  44 00 00 e8 00
	ld h, 0x1f:opc                                          ; FB2524  26 1f
	inc 8,XSP                                            ; FB2526  ef 60
	inc 6,XSP                                            ; FB2528  ef 66
.LFB252A:
	lda xbc, (0x60a000:24)                               ; FB252A  f2 00 a0 60 31
	push XBC                                             ; FB252F  39
	pushw 0x2000                                         ; FB2530  0b 00 20
	push XIX                                             ; FB2533  3c
	call T_Link_SendCommandE2                            ; FB2534  1d f0 0e f4
	lda xbc, (0x60fcf8:24)                               ; FB2538  f2 f8 fc 60 31
	push XBC                                             ; FB253D  39
	call SysExXfer_SetPart_SoundBlock                                      ; FB253E  1d 49 76 fb
	call SysExDump_SendFramesStreamed                                      ; FB2542  1d b2 6f fb
	dec 1,H                                              ; FB2546  ce 69
	add XIX,0x00002000                                   ; FB2548  ec c8 00 20 00 00
	inc 8,XSP                                            ; FB254E  ef 60
	inc 6,XSP                                            ; FB2550  ef 66
	cp h, 0x00:i3                                          ; FB2552  ce d8
	jr nz, .LFB252A                                      ; FB2554  6e d4
	lda xbc, (0x60a000:24)                               ; FB2556  f2 00 a0 60 31
	push XBC                                             ; FB255B  39
	pushw 0x2000                                         ; FB255C  0b 00 20
	push XIX                                             ; FB255F  3c
	call T_Link_SendCommandE2                            ; FB2560  1d f0 0e f4
	lda xbc, (0x60fcf8:24)                               ; FB2564  f2 f8 fc 60 31
	push XBC                                             ; FB2569  39
	call SysExXfer_SetPart_SoundBlock                                      ; FB256A  1d 49 76 fb
	call T_Link_WaitBlockDone                            ; FB256E  1d 3c 12 f4
	inc 8,XSP                                            ; FB2572  ef 60
	inc 6,XSP                                            ; FB2574  ef 66
	cp WA,0xffff                                         ; FB2576  d8 cf ff ff
	jr z, .LFB2580                                       ; FB257A  66 04
	call SysExDump_SendFrames                                      ; FB257C  1d 6b 6f fb
.LFB2580:
	pop XIX                                              ; FB2580  5c
	popw hl                                              ; FB2581  4b
	ret                                                  ; FB2582  0e
	ret                                                  ; FB2583  0e
	ret                                                  ; FB2584  0e
	ret                                                  ; FB2585  0e
	ret                                                  ; FB2586  0e
; SysExDump_SendSequencer: when SysEx_FeatureWordForVariant(3) is not 0xFFFF: parts 1, 2, 3 and SysExDump_SendCategoryDone.
SysExDump_SendSequencer:
	pushw 0x03                                           ; FB2587  0b 03 00
	call SysEx_FeatureWordForVariant                                      ; FB258A  1d f5 5f fb
	popw bc                                              ; FB258E  49
	cp WA,0xffff                                         ; FB258F  d8 cf ff ff
	jr z, .LFB25A1                                       ; FB2593  66 0c
	calr SysExDump_SendSequencerPart1                                      ; FB2595  1e 0a 00
	calr SysExDump_SendSequencerPart2                                      ; FB2598  1e 4c 00
	calr SysExDump_SendSequencerPart3                                      ; FB259B  1e 8e 00
	calr SysExDump_SendCategoryDone                                      ; FB259E  1e dd 01
.LFB25A1:
	ret                                                  ; FB25A1  0e
; SysExDump_SendSequencerPart1: step 0x0B, CPU1 0x603400..0x604000, header prom_b 0xF4FF28.
SysExDump_SendSequencerPart1:
	pushw 0x04                                           ; FB25A2  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB25A5  e2 d8 fc 60 21
	push XBC                                             ; FB25AA  39
	call U8Rec16_GetField                                      ; FB25AB  1d d3 62 fb
	inc 6,XSP                                            ; FB25AF  ef 66
	cp a, 0x00:i3                                          ; FB25B1  c9 d8
	jr nz, .LFB25E6                                      ; FB25B3  6e 31
	pushw 0x0b                                           ; FB25B5  0b 0b 00
	pushw 0x03                                           ; FB25B8  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB25BB  e2 e0 fc 60 21
	push XBC                                             ; FB25C0  39
	call U8Rec16_SetField                                      ; FB25C1  1d 19 62 fb
	lda xbc, (0x60fcf8:24)                               ; FB25C5  f2 f8 fc 60 31
	push XBC                                             ; FB25CA  39
	call SysExXfer_SetPart_Sequencer1                                      ; FB25CB  1d 6f 76 fb
	pushw 0x0c                                           ; FB25CF  0b 0c 00
	lda xbc, (0xf4ff28:24)                               ; FB25D2  f2 28 ff f4 31
	push XBC                                             ; FB25D7  39
	call SysExTx_AppendAndSendOnF7                                      ; FB25D8  1d 7f 6e fb
	call SysExDump_SendFrames                                      ; FB25DC  1d 6b 6f fb
	add XSP,0x00000012                                   ; FB25E0  ef c8 12 00 00 00
.LFB25E6:
	ret                                                  ; FB25E6  0e
; SysExDump_SendSequencerPart2: step 0x0C, CPU1 0x610000..0x617800, header prom_b 0xF4FF34.
SysExDump_SendSequencerPart2:
	pushw 0x04                                           ; FB25E7  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB25EA  e2 d8 fc 60 21
	push XBC                                             ; FB25EF  39
	call U8Rec16_GetField                                      ; FB25F0  1d d3 62 fb
	inc 6,XSP                                            ; FB25F4  ef 66
	cp a, 0x00:i3                                          ; FB25F6  c9 d8
	jr nz, .LFB262B                                      ; FB25F8  6e 31
	pushw 0x0c                                           ; FB25FA  0b 0c 00
	pushw 0x03                                           ; FB25FD  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB2600  e2 e0 fc 60 21
	push XBC                                             ; FB2605  39
	call U8Rec16_SetField                                      ; FB2606  1d 19 62 fb
	lda xbc, (0x60fcf8:24)                               ; FB260A  f2 f8 fc 60 31
	push XBC                                             ; FB260F  39
	call SysExXfer_SetPart_Sequencer2                                      ; FB2610  1d 92 76 fb
	pushw 0x0c                                           ; FB2614  0b 0c 00
	lda xbc, (0xf4ff34:24)                               ; FB2617  f2 34 ff f4 31
	push XBC                                             ; FB261C  39
	call SysExTx_AppendAndSendOnF7                                      ; FB261D  1d 7f 6e fb
	call SysExDump_SendFrames                                      ; FB2621  1d 6b 6f fb
	add XSP,0x00000012                                   ; FB2625  ef c8 12 00 00 00
.LFB262B:
	ret                                                  ; FB262B  0e
; SysExDump_SendSequencerPart3: step 0x0D, CPU1 0x617800.., header prom_b 0xF4FF40 plus the run-time size (SysExTx_AppendRemainingSize).
SysExDump_SendSequencerPart3:
	pushw 0x04                                           ; FB262C  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB262F  e2 d8 fc 60 21
	push XBC                                             ; FB2634  39
	call U8Rec16_GetField                                      ; FB2635  1d d3 62 fb
	inc 6,XSP                                            ; FB2639  ef 66
	cp a, 0x00:i3                                          ; FB263B  c9 d8
	jr nz, .LFB2674                                      ; FB263D  6e 35
	pushw 0x0d                                           ; FB263F  0b 0d 00
	pushw 0x03                                           ; FB2642  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB2645  e2 e0 fc 60 21
	push XBC                                             ; FB264A  39
	call U8Rec16_SetField                                      ; FB264B  1d 19 62 fb
	lda xbc, (0x60fcf8:24)                               ; FB264F  f2 f8 fc 60 31
	push XBC                                             ; FB2654  39
	call SysExXfer_SetPart_Sequencer3                                      ; FB2655  1d b5 76 fb
	pushw 0x09                                           ; FB2659  0b 09 00
	lda xbc, (0xf4ff40:24)                               ; FB265C  f2 40 ff f4 31
	push XBC                                             ; FB2661  39
	call SysExTx_AppendAndSendOnF7                                      ; FB2662  1d 7f 6e fb
	call SysExTx_AppendRemainingSize                                      ; FB2666  1d e9 6e fb
	call SysExDump_SendFrames                                      ; FB266A  1d 6b 6f fb
	add XSP,0x00000012                                   ; FB266E  ef c8 12 00 00 00
.LFB2674:
	ret                                                  ; FB2674  0e
; SysExDump_SendCombination: parts 1 and 2, then SysExDump_SendCategoryDone.
SysExDump_SendCombination:
	calr SysExDump_SendCombinationPart1                                      ; FB2675  1e 07 00
	calr SysExDump_SendCombinationPart2                                      ; FB2678  1e 6c 00
	calr SysExDump_SendCategoryDone                                      ; FB267B  1e 00 01
	ret                                                  ; FB267E  0e
; SysExDump_SendCombinationPart1: step 0x0F, CPU2 flash 0xEC0000..0xEC0300 fetched through T_Link_SendCommandE2, header prom_b 0xF4FF49.
SysExDump_SendCombinationPart1:
	pushw 0x04                                           ; FB267F  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2682  e2 d8 fc 60 21
	push XBC                                             ; FB2687  39
	call U8Rec16_GetField                                      ; FB2688  1d d3 62 fb
	inc 6,XSP                                            ; FB268C  ef 66
	cp a, 0x00:i3                                          ; FB268E  c9 d8
	jr nz, .LFB26E6                                      ; FB2690  6e 54
	pushw 0x0f                                           ; FB2692  0b 0f 00
	pushw 0x03                                           ; FB2695  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB2698  e2 e0 fc 60 21
	push XBC                                             ; FB269D  39
	call U8Rec16_SetField                                      ; FB269E  1d 19 62 fb
	lda xbc, (0x60fcf8:24)                               ; FB26A2  f2 f8 fc 60 31
	push XBC                                             ; FB26A7  39
	call SysExXfer_SetPart_Combination1                                      ; FB26A8  1d f2 76 fb
	pushw 0x0c                                           ; FB26AC  0b 0c 00
	lda xbc, (0xf4ff49:24)                               ; FB26AF  f2 49 ff f4 31
	push XBC                                             ; FB26B4  39
	call SysExTx_AppendAndSendOnF7                                      ; FB26B5  1d 7f 6e fb
	lda xbc, (0x60a000:24)                               ; FB26B9  f2 00 a0 60 31
	sub XBC,0x00000300                                   ; FB26BE  e9 ca 00 03 00 00
	push XBC                                             ; FB26C4  39
	pushw 0x0300                                         ; FB26C5  0b 00 03
	ld XBC,0x00ec0000                                    ; FB26C8  41 00 00 ec 00
	push XBC                                             ; FB26CD  39
	call T_Link_SendCommandE2                            ; FB26CE  1d f0 0e f4
	call T_Link_WaitBlockDone                            ; FB26D2  1d 3c 12 f4
	add XSP,0x0000001c                                   ; FB26D6  ef c8 1c 00 00 00
	cp WA,0xffff                                         ; FB26DC  d8 cf ff ff
	jr z, .LFB26E6                                       ; FB26E0  66 04
	call SysExDump_SendFrames                                      ; FB26E2  1d 6b 6f fb
.LFB26E6:
	ret                                                  ; FB26E6  0e
; SysExDump_SendCombinationPart2: step 0x10, CPU2 flash 0xEC0300.. in 16 blocks of 0x1600, header prom_b 0xF4FF55.
SysExDump_SendCombinationPart2:
	pushw hl                                             ; FB26E7  2b
	push XIX                                             ; FB26E8  3c
	pushw 0x04                                           ; FB26E9  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB26EC  e2 d8 fc 60 21
	push XBC                                             ; FB26F1  39
	call U8Rec16_GetField                                      ; FB26F2  1d d3 62 fb
	inc 6,XSP                                            ; FB26F6  ef 66
	cp a, 0x00:i3                                          ; FB26F8  c9 d8
	jrl nz, .LFB277B                                     ; FB26FA  7e 7e 00
	pushw 0x10                                           ; FB26FD  0b 10 00
	pushw 0x03                                           ; FB2700  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB2703  e2 e0 fc 60 21
	push XBC                                             ; FB2708  39
	call U8Rec16_SetField                                      ; FB2709  1d 19 62 fb
	pushw 0x0c                                           ; FB270D  0b 0c 00
	lda xbc, (0xf4ff55:24)                               ; FB2710  f2 55 ff f4 31
	push XBC                                             ; FB2715  39
	call SysExTx_AppendAndSendOnF7                                      ; FB2716  1d 7f 6e fb
	ld XIX,0x00ec0300                                    ; FB271A  44 00 03 ec 00
	ld h, 0x0f:opc                                          ; FB271F  26 0f
	inc 8,XSP                                            ; FB2721  ef 60
	inc 6,XSP                                            ; FB2723  ef 66
.LFB2725:
	lda xbc, (0x60a000:24)                               ; FB2725  f2 00 a0 60 31
	push XBC                                             ; FB272A  39
	pushw 0x1600                                         ; FB272B  0b 00 16
	push XIX                                             ; FB272E  3c
	call T_Link_SendCommandE2                            ; FB272F  1d f0 0e f4
	lda xbc, (0x60fcf8:24)                               ; FB2733  f2 f8 fc 60 31
	push XBC                                             ; FB2738  39
	call SysExXfer_SetPart_CombinationBlock                                      ; FB2739  1d 22 77 fb
	call SysExDump_SendFramesStreamed                                      ; FB273D  1d b2 6f fb
	dec 1,H                                              ; FB2741  ce 69
	add XIX,0x00001600                                   ; FB2743  ec c8 00 16 00 00
	inc 8,XSP                                            ; FB2749  ef 60
	inc 6,XSP                                            ; FB274B  ef 66
	cp h, 0x00:i3                                          ; FB274D  ce d8
	jr nz, .LFB2725                                      ; FB274F  6e d4
	lda xbc, (0x60a000:24)                               ; FB2751  f2 00 a0 60 31
	push XBC                                             ; FB2756  39
	pushw 0x1600                                         ; FB2757  0b 00 16
	push XIX                                             ; FB275A  3c
	call T_Link_SendCommandE2                            ; FB275B  1d f0 0e f4
	lda xbc, (0x60fcf8:24)                               ; FB275F  f2 f8 fc 60 31
	push XBC                                             ; FB2764  39
	call SysExXfer_SetPart_CombinationBlock                                      ; FB2765  1d 22 77 fb
	call T_Link_WaitBlockDone                            ; FB2769  1d 3c 12 f4
	inc 8,XSP                                            ; FB276D  ef 60
	inc 6,XSP                                            ; FB276F  ef 66
	cp WA,0xffff                                         ; FB2771  d8 cf ff ff
	jr z, .LFB277B                                       ; FB2775  66 04
	call SysExDump_SendFrames                                      ; FB2777  1d 6b 6f fb
.LFB277B:
	pop XIX                                              ; FB277B  5c
	popw hl                                              ; FB277C  4b
	ret                                                  ; FB277D  0e
; SysExDump_SendCategoryDone: step id + 1, send F0 50 27 7E F7 (prom_b 0xF4FEBE), SysExDump_AwaitFrameAck.
SysExDump_SendCategoryDone:
	pushw 0x04                                           ; FB277E  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2781  e2 d8 fc 60 21
	push XBC                                             ; FB2786  39
	call U8Rec16_GetField                                      ; FB2787  1d d3 62 fb
	inc 6,XSP                                            ; FB278B  ef 66
	cp a, 0x00:i3                                          ; FB278D  c9 d8
	jr nz, .LFB27AC                                      ; FB278F  6e 1b
	ld xbc, (0x60fce0:24)                               ; FB2791  e2 e0 fc 60 21
	incm8 0x01, (xbc+0x03)                               ; FB2796  89 03 61
	pushw 0x05                                           ; FB2799  0b 05 00
	lda xbc, (0xf4febe:24)                               ; FB279C  f2 be fe f4 31
	push XBC                                             ; FB27A1  39
	call SysExTx_AppendAndSendOnF7                                      ; FB27A2  1d 7f 6e fb
	call SysExDump_AwaitFrameAck                                      ; FB27A6  1d 26 60 fb
	inc 6,XSP                                            ; FB27AA  ef 66
.LFB27AC:
	ret                                                  ; FB27AC  0e
; SysExDump_SendJobDone: send F0 50 28 7E F7 (0xF4FEC3) and await the ACK; on status 0x18 also send F0 50 29 7E F7 (0xF4FEC8).
SysExDump_SendJobDone:
	push XIX                                             ; FB27AD  3c
	lda xix, (U8Rec16_GetField:24)                             ; FB27AE  f2 d3 62 fb 34
	pushw 0x04                                           ; FB27B3  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB27B6  e2 d8 fc 60 21
	push XBC                                             ; FB27BB  39
	lda xiy, (.LFB27C4:24)                               ; FB27BC  f2 c4 27 fb 35
	push XIY                                             ; FB27C1  3d
	jp (xix)                                             ; FB27C2  b4 d8
.LFB27C4:
	inc 6,XSP                                            ; FB27C4  ef 66
	cp a, 0x00:i3                                          ; FB27C6  c9 d8
	jr nz, .LFB27F7                                      ; FB27C8  6e 2d
	pushw 0x05                                           ; FB27CA  0b 05 00
	lda xbc, (0xf4fec3:24)                               ; FB27CD  f2 c3 fe f4 31
	push XBC                                             ; FB27D2  39
	call SysExTx_AppendAndSendOnF7                                      ; FB27D3  1d 7f 6e fb
	call SysExDump_AwaitFrameAck                                      ; FB27D7  1d 26 60 fb
	pushw 0x04                                           ; FB27DB  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB27DE  e2 d8 fc 60 21
	push XBC                                             ; FB27E3  39
	lda xiy, (.LFB27EC:24)                               ; FB27E4  f2 ec 27 fb 35
	push XIY                                             ; FB27E9  3d
	jp (xix)                                             ; FB27EA  b4 d8
.LFB27EC:
	inc 8,XSP                                            ; FB27EC  ef 60
	inc 4,XSP                                            ; FB27EE  ef 64
	cp A,0x18                                            ; FB27F0  c9 cf 18
	jr nz, .LFB281E                                      ; FB27F3  6e 29
	jr .LFB280F                                          ; FB27F5  68 18
.LFB27F7:
	pushw 0x04                                           ; FB27F7  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB27FA  e2 d8 fc 60 21
	push XBC                                             ; FB27FF  39
	lda xiy, (.LFB2808:24)                               ; FB2800  f2 08 28 fb 35
	push XIY                                             ; FB2805  3d
	jp (xix)                                             ; FB2806  b4 d8
.LFB2808:
	inc 6,XSP                                            ; FB2808  ef 66
	cp A,0x18                                            ; FB280A  c9 cf 18
	jr nz, .LFB281E                                      ; FB280D  6e 0f
.LFB280F:
	pushw 0x05                                           ; FB280F  0b 05 00
	lda xbc, (0xf4fec8:24)                               ; FB2812  f2 c8 fe f4 31
	push XBC                                             ; FB2817  39
	call SysExTx_AppendAndSendOnF7                                      ; FB2818  1d 7f 6e fb
	inc 6,XSP                                            ; FB281C  ef 66
.LFB281E:
	pop XIX                                              ; FB281E  5c
	ret                                                  ; FB281F  0e
; SysExSession_Run: the interrupt table's (PtrTable_F4F800) default, the bulk-transfer session loop.  Only on the SYSEX BULK DUMP
;   screen (UI_ScreenLatch == 0x79) and for commands >= 7; each received message goes to SysExSession_DispatchCommand.
SysExSession_Run:
	push XIX                                             ; FB2820  3c
	lda xix, (0x60fd40:24)                               ; FB2821  f2 40 fd 60 34
	cp	(UI_ScreenLatch:16), 0x79                            ; FB2826  c1 7a 20 3f 79
	jr nz, .LFB2873                                      ; FB282B  6e 46
	pushw 0x00                                           ; FB282D  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB2830  e2 d8 fc 60 21
	push XBC                                             ; FB2835  39
	call U8Rec16_GetField                                      ; FB2836  1d d3 62 fb
	inc 6,XSP                                            ; FB283A  ef 66
	cp a, 0x07:i3                                          ; FB283C  c9 df
	jr c, .LFB2873                                       ; FB283E  67 33
	set 4,(XIX)                                          ; FB2840  b4 bc
	call SysExSession_StartProgressScreen                                      ; FB2842  1d 0b 7b fb
	jr .LFB2867                                          ; FB2846  68 1f
.LFB2848:
	bit 4,(XIX)                                          ; FB2848  b4 cc
	jr z, .LFB286C                                       ; FB284A  66 20
	pushw 0x04                                           ; FB284C  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB284F  e2 d8 fc 60 21
	push XBC                                             ; FB2854  39
	call U8Rec16_GetField                                      ; FB2855  1d d3 62 fb
	inc 6,XSP                                            ; FB2859  ef 66
	cp a, 0x00:i3                                          ; FB285B  c9 d8
	jr z, .LFB2863                                       ; FB285D  66 04
	res 4,(XIX)                                          ; FB285F  b4 b4
	jr .LFB286C                                          ; FB2861  68 09
.LFB2863:
	call SysExRx_AwaitReply                                      ; FB2863  1d 72 60 fb
.LFB2867:
	calr SysExSession_DispatchCommand                                      ; FB2867  1e 0d 00
	jr .LFB2848                                          ; FB286A  68 dc
.LFB286C:
	calr SysExSession_AbortIfFailed                                      ; FB286C  1e c5 09
	call SysExDump_ShowResult                                      ; FB286F  1d fe 7d fb
.LFB2873:
	res 4,(XIX)                                          ; FB2873  b4 b4
	pop XIX                                              ; FB2875  5c
	ret                                                  ; FB2876  0e
; SysExSession_DispatchCommand: status 0 and command < 0x22: PtrTable_F4F916[command]; then SysExSession_AnswerByStatus, SysExSession_RefreshProgressScreen, PanelLed_ToggleActivityLed_SaveRegs2.
SysExSession_DispatchCommand:
	pushw hl                                             ; FB2877  2b
	pushw 0x04                                           ; FB2878  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB287B  e2 d8 fc 60 21
	push XBC                                             ; FB2880  39
	call U8Rec16_GetField                                      ; FB2881  1d d3 62 fb
	inc 6,XSP                                            ; FB2885  ef 66
	cp a, 0x00:i3                                          ; FB2887  c9 d8
	jr nz, .LFB28BC                                      ; FB2889  6e 31
	call SysExSession_RepaintProgressIfChanged_Nop                                      ; FB288B  1d 9a 7e fb
	ld xbc, (0x60fcd8:24)                               ; FB288F  e2 d8 fc 60 21
	ld H,(XBC)                                           ; FB2894  81 26
	cp H,0x22                                            ; FB2896  ce cf 22
	jr nc, .LFB28BC                                      ; FB2899  6f 21
	ld a, 0x04:opc                                          ; FB289B  21 04
	mul wa, h                                          ; FB289D  ce 41
	extz XWA                                             ; FB289F  e8 12
	add XWA,PtrTable_F4F916                              ; FB28A1  e8 c8 16 f9 f4 00
	ld XWA,(XWA)                                         ; FB28A7  a0 20
	lda xiy, (.LFB28B1:24)                               ; FB28A9  f2 b1 28 fb 35
	push XIY                                             ; FB28AE  3d
	jp (xwa)                                             ; FB28AF  b0 d8
.LFB28B1:
	calr SysExSession_AnswerByStatus                                      ; FB28B1  1e 0a 00
	call SysExSession_RefreshProgressScreen                                      ; FB28B4  1d b9 7b fb
	call PanelLed_ToggleActivityLed_SaveRegs2                                      ; FB28B8  1d fe 7a fb
.LFB28BC:
	popw hl                                              ; FB28BC  4b
	ret                                                  ; FB28BD  0e
; SysExSession_AnswerByStatus: with a session open, answers every message from the parse status: 0 -> F0 50 23 7E F7, 0x16 -> F0 50 2A 7E F7,
;   else F0 50 24 7E F7 (README: 'What an open session answers with').
SysExSession_AnswerByStatus:
	pushw hl                                             ; FB28BE  2b
	bit	7, (0x60fd40:24)                             ; FB28BF  f2 40 fd 60 cf
	jr z, .LFB28FD                                       ; FB28C4  66 37
	call SysExTx_SwapBuffers                                      ; FB28C6  1d 81 80 fb
	ld xbc, (0x60fcd8:24)                               ; FB28CA  e2 d8 fc 60 21
	ld H,(XBC+0x04)                                      ; FB28CF  89 04 26
	cp h, 0x00:i3                                          ; FB28D2  ce d8
	jr nz, .LFB28E1                                      ; FB28D4  6e 0b
	pushw 0x05                                           ; FB28D6  0b 05 00
	lda	xwa, (SysExMessageStrings_F4FEB4:24)         ; FB28D9  f2 b4 fe f4 30
	push XWA                                             ; FB28DE  38
	jr .LFB28F7                                          ; FB28DF  68 16
.LFB28E1:
	pushw 0x05                                           ; FB28E1  0b 05 00
	cp H,0x16                                            ; FB28E4  ce cf 16
	jr nz, .LFB28F1                                      ; FB28E7  6e 08
	lda xbc, (0xf4fecd:24)                               ; FB28E9  f2 cd fe f4 31
	push XBC                                             ; FB28EE  39
	jr .LFB28F7                                          ; FB28EF  68 06
.LFB28F1:
	lda xbc, (0xf4feb9:24)                               ; FB28F1  f2 b9 fe f4 31
	push XBC                                             ; FB28F6  39
.LFB28F7:
	call SysExTx_AppendAndSendOnF7                                      ; FB28F7  1d 7f 6e fb
	inc 6,XSP                                            ; FB28FB  ef 66
.LFB28FD:
	popw hl                                              ; FB28FD  4b
	ret                                                  ; FB28FE  0e
; SysExSession_Enquiry: command 0x07, F0 50 21 04 dd 11 F7: handshake state (0x60FD44) 0 -> 1, answer F0 50 22 04 00 11 F7.
SysExSession_Enquiry:
	cp	(0x60fd44:24), 0x00                          ; FB28FF  c2 44 fd 60 3f 00
	jr nz, .LFB291C                                      ; FB2905  6e 15
	ld (0x60fd44:24), 0x01                             ; FB2907  f2 44 fd 60 00 01
	pushw 0x07                                           ; FB290D  0b 07 00
	lda xbc, (0xf4fedc:24)                               ; FB2910  f2 dc fe f4 31
	push XBC                                             ; FB2915  39
	call SysExTx_AppendAndSendOnF7                                      ; FB2916  1d 7f 6e fb
	inc 6,XSP                                            ; FB291A  ef 66
.LFB291C:
	ret                                                  ; FB291C  0e
; SysExSession_StartTransfer: command 0x08, F0 50 22 04 dd 11 F7: state 1 -> 2 and bit 7 of (0x60FD40) set; else status 0x18.
SysExSession_StartTransfer:
	push XIX                                             ; FB291D  3c
	lda xix, (0x60fcd8:24)                               ; FB291E  f2 d8 fc 60 34
	cp	(0x60fd44:24), 0x01                          ; FB2923  c2 44 fd 60 3f 01
	jr nz, .LFB296B                                      ; FB2929  6e 40
	pushw 0x06                                           ; FB292B  0b 06 00
	ld XBC,(XIX)                                         ; FB292E  a4 21
	push XBC                                             ; FB2930  39
	call U8Rec16_GetField                                      ; FB2931  1d d3 62 fb
	ld (0x60fc94:24), a                                 ; FB2935  f2 94 fc 60 41
	pushw 0x07                                           ; FB293A  0b 07 00
	ld XBC,(XIX)                                         ; FB293D  a4 21
	push XBC                                             ; FB293F  39
	call U8Rec16_GetField                                      ; FB2940  1d d3 62 fb
	ld (0x60fc95:24), a                                 ; FB2944  f2 95 fc 60 41
	pushw 0x08                                           ; FB2949  0b 08 00
	ld XBC,(XIX)                                         ; FB294C  a4 21
	push XBC                                             ; FB294E  39
	call U8Rec16_GetField                                      ; FB294F  1d d3 62 fb
	ld (0x60fc96:24), a                                 ; FB2953  f2 96 fc 60 41
	set	7, (0x60fd40:24)                             ; FB2958  f2 40 fd 60 bf
	ld (0x60fd44:24), 0x02                             ; FB295D  f2 44 fd 60 00 02
	add XSP,0x00000012                                   ; FB2963  ef c8 12 00 00 00
	jr .LFB2976                                          ; FB2969  68 0b
.LFB296B:
	ld XBC,(XIX)                                         ; FB296B  a4 21
	ld (XBC+0x04),0x18                                   ; FB296D  b9 04 00 18
	res	4, (0x60fd40:24)                             ; FB2971  f2 40 fd 60 b4
.LFB2976:
	pop XIX                                              ; FB2976  5c
	ret                                                  ; FB2977  0e
; SysExSession_RecvSystemPart1: command 0x0B, 2D header 40 00 00 / 00 00 20.
SysExSession_RecvSystemPart1:
	pushw 0x03                                           ; FB2978  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB297B  e2 dc fc 60 21
	push XBC                                             ; FB2980  39
	call U8Rec16_GetField                                      ; FB2981  1d d3 62 fb
	inc 6,XSP                                            ; FB2985  ef 66
	cp a, 0x00:i3                                          ; FB2987  c9 d8
	jr nz, .LFB29A8                                      ; FB2989  6e 1d
	call ParamImage_WriteHeadersAndSnapshot                                      ; FB298B  1d b6 77 fb
	lda xbc, (0x60fd08:24)                               ; FB298F  f2 08 fd 60 31
	push XBC                                             ; FB2994  39
	call SysExXfer_SetJobTotal_SystemPartMidi                                      ; FB2995  1d d7 74 fb
	lda xbc, (0x60fd18:24)                               ; FB2999  f2 18 fd 60 31
	push XBC                                             ; FB299E  39
	call SysExXfer_SetPart_SystemPart1                                      ; FB299F  1d ba 75 fb
	calr SysExSession_RecvBody_SystemPart1                                      ; FB29A3  1e 07 03
	jr .LFB29B8                                          ; FB29A6  68 10
.LFB29A8:
	pushw 0x19                                           ; FB29A8  0b 19 00
	pushw 0x04                                           ; FB29AB  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB29AE  e2 d8 fc 60 21
	push XBC                                             ; FB29B3  39
	call U8Rec16_SetField                                      ; FB29B4  1d 19 62 fb
.LFB29B8:
	inc 8,XSP                                            ; FB29B8  ef 60
	ret                                                  ; FB29BA  0e
; SysExSession_RecvSystemPart2: command 0x0C, 2D header 40 00 20 / 00 12 60.
SysExSession_RecvSystemPart2:
	pushw 0x03                                           ; FB29BB  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB29BE  e2 dc fc 60 21
	push XBC                                             ; FB29C3  39
	call U8Rec16_GetField                                      ; FB29C4  1d d3 62 fb
	inc 6,XSP                                            ; FB29C8  ef 66
	cp a, 0x02:i3                                          ; FB29CA  c9 da
	jr nz, .LFB29DE                                      ; FB29CC  6e 10
	lda xbc, (0x60fd18:24)                               ; FB29CE  f2 18 fd 60 31
	push XBC                                             ; FB29D3  39
	call SysExXfer_SetPart_SystemPart2                                      ; FB29D4  1d e4 75 fb
	calr SysExSession_RecvBody_SystemPart2                                      ; FB29D8  1e 0c 03
	pop XIY                                              ; FB29DB  5d
	jr .LFB29F0                                          ; FB29DC  68 12
.LFB29DE:
	pushw 0x19                                           ; FB29DE  0b 19 00
	pushw 0x04                                           ; FB29E1  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB29E4  e2 d8 fc 60 21
	push XBC                                             ; FB29E9  39
	call U8Rec16_SetField                                      ; FB29EA  1d 19 62 fb
	inc 8,XSP                                            ; FB29EE  ef 60
.LFB29F0:
	ret                                                  ; FB29F0  0e
; SysExSession_RecvSoundOrphan: command 0x0D, receive half of the uncalled 0xFB248A; no wire sequence reaches it.
SysExSession_RecvSoundOrphan:
	pushw 0x03                                           ; FB29F1  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB29F4  e2 dc fc 60 21
	push XBC                                             ; FB29F9  39
	call U8Rec16_GetField                                      ; FB29FA  1d d3 62 fb
	inc 6,XSP                                            ; FB29FE  ef 66
	cp a, 0x00:i3                                          ; FB2A00  c9 d8
	jr nz, .LFB2A14                                      ; FB2A02  6e 10
	lda xbc, (0x60fd18:24)                               ; FB2A04  f2 18 fd 60 31
	push XBC                                             ; FB2A09  39
	call SysExXfer_SetPart_SoundOrphan                                      ; FB2A0A  1d 29 76 fb
	calr SysExSession_RecvBody_SoundOrphan                                      ; FB2A0E  1e 10 03
	pop XIY                                              ; FB2A11  5d
	jr .LFB2A26                                          ; FB2A12  68 12
.LFB2A14:
	pushw 0x1a                                           ; FB2A14  0b 1a 00
	pushw 0x04                                           ; FB2A17  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2A1A  e2 d8 fc 60 21
	push XBC                                             ; FB2A1F  39
	call U8Rec16_SetField                                      ; FB2A20  1d 19 62 fb
	inc 8,XSP                                            ; FB2A24  ef 60
.LFB2A26:
	ret                                                  ; FB2A26  0e
; SysExSession_RecvSound: command 0x0E, 2D header 20 00 00 / 10 00 00.
SysExSession_RecvSound:
	push XIX                                             ; FB2A27  3c
	pushw 0x03                                           ; FB2A28  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2A2B  e2 dc fc 60 21
	push XBC                                             ; FB2A30  39
	call U8Rec16_GetField                                      ; FB2A31  1d d3 62 fb
	inc 6,XSP                                            ; FB2A35  ef 66
	cp a, 0x00:i3                                          ; FB2A37  c9 d8
	jr nz, .LFB2A67                                      ; FB2A39  6e 2c
	ld XIX,0x00e80000                                    ; FB2A3B  44 00 00 e8 00
	push XIX                                             ; FB2A40  3c
	call T_Link_SendCommand3_WaitTicks                                        ; FB2A41  1d 34 12 f4
	lda xbc, (0x60fd08:24)                               ; FB2A45  f2 08 fd 60 31
	push XBC                                             ; FB2A4A  39
	call SysExXfer_SetJobTotal_Sound                                      ; FB2A4B  1d 1a 75 fb
	lda xbc, (0x60fd18:24)                               ; FB2A4F  f2 18 fd 60 31
	push XBC                                             ; FB2A54  39
	call SysExXfer_SetPart_SoundBlock                                      ; FB2A55  1d 49 76 fb
	push XIX                                             ; FB2A59  3c
	call SysExXfer_InitCpu2Forward                                      ; FB2A5A  1d 63 7a fb
	calr SysExSession_RecvBody_Sound                                      ; FB2A5E  1e 2c 08
	inc 8,XSP                                            ; FB2A61  ef 60
	inc 8,XSP                                            ; FB2A63  ef 60
	jr .LFB2A79                                          ; FB2A65  68 12
.LFB2A67:
	pushw 0x1a                                           ; FB2A67  0b 1a 00
	pushw 0x04                                           ; FB2A6A  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2A6D  e2 d8 fc 60 21
	push XBC                                             ; FB2A72  39
	call U8Rec16_SetField                                      ; FB2A73  1d 19 62 fb
	inc 8,XSP                                            ; FB2A77  ef 60
.LFB2A79:
	pop XIX                                              ; FB2A79  5c
	ret                                                  ; FB2A7A  0e
; SysExSession_RecvStub0F: command 0x0F, one of the three stubbed-out category handlers (steps 0/8/9); unreachable.
SysExSession_RecvStub0F:
	pushw 0x03                                           ; FB2A7B  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2A7E  e2 dc fc 60 21
	push XBC                                             ; FB2A83  39
	call U8Rec16_GetField                                      ; FB2A84  1d d3 62 fb
	inc 6,XSP                                            ; FB2A88  ef 66
	cp a, 0x00:i3                                          ; FB2A8A  c9 d8
	jr nz, .LFB2AAB                                      ; FB2A8C  6e 1d
	call SysExSession_OnAbort_Sound_Nop5                                      ; FB2A8E  1d e3 7e fb
	lda xbc, (0x60fd08:24)                               ; FB2A92  f2 08 fd 60 31
	push XBC                                             ; FB2A97  39
	call SysExXfer_SetJobTotal_Sound_Nop                                      ; FB2A98  1d 3d 75 fb
	lda xbc, (0x60fd18:24)                               ; FB2A9C  f2 18 fd 60 31
	push XBC                                             ; FB2AA1  39
	call SysExXfer_SetPart_SoundBlock_Nop2                                      ; FB2AA2  1d 6c 76 fb
	calr SysExSession_RecvBody_Stub0F                                      ; FB2AA6  1e c9 02
	jr .LFB2ABB                                          ; FB2AA9  68 10
.LFB2AAB:
	pushw 0x1b                                           ; FB2AAB  0b 1b 00
	pushw 0x04                                           ; FB2AAE  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2AB1  e2 d8 fc 60 21
	push XBC                                             ; FB2AB6  39
	call U8Rec16_SetField                                      ; FB2AB7  1d 19 62 fb
.LFB2ABB:
	inc 8,XSP                                            ; FB2ABB  ef 60
	ret                                                  ; FB2ABD  0e
; SysExSession_RecvStub10: command 0x10, as SysExSession_RecvStub0F.
SysExSession_RecvStub10:
	pushw 0x03                                           ; FB2ABE  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2AC1  e2 dc fc 60 21
	push XBC                                             ; FB2AC6  39
	call U8Rec16_GetField                                      ; FB2AC7  1d d3 62 fb
	inc 6,XSP                                            ; FB2ACB  ef 66
	cp A,0x08                                            ; FB2ACD  c9 cf 08
	jr nz, .LFB2AE2                                      ; FB2AD0  6e 10
	lda xbc, (0x60fd18:24)                               ; FB2AD2  f2 18 fd 60 31
	push XBC                                             ; FB2AD7  39
	call SysExXfer_SetPart_SoundBlock_Nop3                                      ; FB2AD8  1d 6d 76 fb
	calr SysExSession_RecvBody_Stub10                                      ; FB2ADC  1e cd 02
	pop XIY                                              ; FB2ADF  5d
	jr .LFB2AF4                                          ; FB2AE0  68 12
.LFB2AE2:
	pushw 0x1b                                           ; FB2AE2  0b 1b 00
	pushw 0x04                                           ; FB2AE5  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2AE8  e2 d8 fc 60 21
	push XBC                                             ; FB2AED  39
	call U8Rec16_SetField                                      ; FB2AEE  1d 19 62 fb
	inc 8,XSP                                            ; FB2AF2  ef 60
.LFB2AF4:
	ret                                                  ; FB2AF4  0e
; SysExSession_RecvStub11: command 0x11, as SysExSession_RecvStub0F.
SysExSession_RecvStub11:
	pushw 0x03                                           ; FB2AF5  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2AF8  e2 dc fc 60 21
	push XBC                                             ; FB2AFD  39
	call U8Rec16_GetField                                      ; FB2AFE  1d d3 62 fb
	inc 6,XSP                                            ; FB2B02  ef 66
	cp A,0x09                                            ; FB2B04  c9 cf 09
	jr nz, .LFB2B1D                                      ; FB2B07  6e 14
	lda xbc, (0x60fd18:24)                               ; FB2B09  f2 18 fd 60 31
	push XBC                                             ; FB2B0E  39
	call SysExXfer_SetPart_SoundBlock_Nop4                                      ; FB2B0F  1d 6e 76 fb
	call SysExRx_SetRunTimeSize                                      ; FB2B13  1d 1a 74 fb
	calr SysExSession_RecvBody_Stub11                                      ; FB2B17  1e cc 02
	pop XIY                                              ; FB2B1A  5d
	jr .LFB2B2F                                          ; FB2B1B  68 12
.LFB2B1D:
	pushw 0x1b                                           ; FB2B1D  0b 1b 00
	pushw 0x04                                           ; FB2B20  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2B23  e2 d8 fc 60 21
	push XBC                                             ; FB2B28  39
	call U8Rec16_SetField                                      ; FB2B29  1d 19 62 fb
	inc 8,XSP                                            ; FB2B2D  ef 60
.LFB2B2F:
	ret                                                  ; FB2B2F  0e
; SysExSession_RecvSequencerPart1: command 0x12, 2D header 60 00 00 / 00 18 00.
SysExSession_RecvSequencerPart1:
	pushw 0x03                                           ; FB2B30  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2B33  e2 dc fc 60 21
	push XBC                                             ; FB2B38  39
	call U8Rec16_GetField                                      ; FB2B39  1d d3 62 fb
	inc 6,XSP                                            ; FB2B3D  ef 66
	cp a, 0x00:i3                                          ; FB2B3F  c9 d8
	jr nz, .LFB2B5C                                      ; FB2B41  6e 19
	lda xbc, (0x60fd08:24)                               ; FB2B43  f2 08 fd 60 31
	push XBC                                             ; FB2B48  39
	call SysExXfer_SetJobTotal_Sequencer                                      ; FB2B49  1d 3e 75 fb
	lda xbc, (0x60fd18:24)                               ; FB2B4D  f2 18 fd 60 31
	push XBC                                             ; FB2B52  39
	call SysExXfer_SetPart_Sequencer1                                      ; FB2B53  1d 6f 76 fb
	calr SysExSession_RecvBody_SequencerPart1                                      ; FB2B57  1e c6 02
	jr .LFB2B6C                                          ; FB2B5A  68 10
.LFB2B5C:
	pushw 0x1c                                           ; FB2B5C  0b 1c 00
	pushw 0x04                                           ; FB2B5F  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2B62  e2 d8 fc 60 21
	push XBC                                             ; FB2B67  39
	call U8Rec16_SetField                                      ; FB2B68  1d 19 62 fb
.LFB2B6C:
	inc 8,XSP                                            ; FB2B6C  ef 60
	ret                                                  ; FB2B6E  0e
; SysExSession_RecvSequencerPart2: command 0x13, 2D header 60 18 00 / 01 70 00.
SysExSession_RecvSequencerPart2:
	pushw 0x03                                           ; FB2B6F  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2B72  e2 dc fc 60 21
	push XBC                                             ; FB2B77  39
	call U8Rec16_GetField                                      ; FB2B78  1d d3 62 fb
	inc 6,XSP                                            ; FB2B7C  ef 66
	cp A,0x0c                                            ; FB2B7E  c9 cf 0c
	jr nz, .LFB2B93                                      ; FB2B81  6e 10
	lda xbc, (0x60fd18:24)                               ; FB2B83  f2 18 fd 60 31
	push XBC                                             ; FB2B88  39
	call SysExXfer_SetPart_Sequencer2                                      ; FB2B89  1d 92 76 fb
	calr SysExSession_RecvBody_SequencerPart2                                      ; FB2B8D  1e d9 02
	pop XIY                                              ; FB2B90  5d
	jr .LFB2BA5                                          ; FB2B91  68 12
.LFB2B93:
	pushw 0x1c                                           ; FB2B93  0b 1c 00
	pushw 0x04                                           ; FB2B96  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2B99  e2 d8 fc 60 21
	push XBC                                             ; FB2B9E  39
	call U8Rec16_SetField                                      ; FB2B9F  1d 19 62 fb
	inc 8,XSP                                            ; FB2BA3  ef 60
.LFB2BA5:
	ret                                                  ; FB2BA5  0e
; SysExSession_RecvSequencerPart3: command 0x14, 2D header 62 08 00 / run-time size.
SysExSession_RecvSequencerPart3:
	pushw 0x03                                           ; FB2BA6  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2BA9  e2 dc fc 60 21
	push XBC                                             ; FB2BAE  39
	call U8Rec16_GetField                                      ; FB2BAF  1d d3 62 fb
	inc 6,XSP                                            ; FB2BB3  ef 66
	cp A,0x0d                                            ; FB2BB5  c9 cf 0d
	jr nz, .LFB2BCE                                      ; FB2BB8  6e 14
	lda xbc, (0x60fd18:24)                               ; FB2BBA  f2 18 fd 60 31
	push XBC                                             ; FB2BBF  39
	call SysExXfer_SetPart_Sequencer3                                      ; FB2BC0  1d b5 76 fb
	call SysExRx_SetRunTimeSize                                      ; FB2BC4  1d 1a 74 fb
	calr SysExSession_RecvBody_SequencerPart3                                      ; FB2BC8  1e e7 02
	pop XIY                                              ; FB2BCB  5d
	jr .LFB2BE0                                          ; FB2BCC  68 12
.LFB2BCE:
	pushw 0x1c                                           ; FB2BCE  0b 1c 00
	pushw 0x04                                           ; FB2BD1  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2BD4  e2 d8 fc 60 21
	push XBC                                             ; FB2BD9  39
	call U8Rec16_SetField                                      ; FB2BDA  1d 19 62 fb
	inc 8,XSP                                            ; FB2BDE  ef 60
.LFB2BE0:
	ret                                                  ; FB2BE0  0e
; SysExSession_RecvCombinationPart1: command 0x15, 2D header 50 00 00 / 00 06 00.
SysExSession_RecvCombinationPart1:
	push XIX                                             ; FB2BE1  3c
	pushw 0x03                                           ; FB2BE2  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2BE5  e2 dc fc 60 21
	push XBC                                             ; FB2BEA  39
	call U8Rec16_GetField                                      ; FB2BEB  1d d3 62 fb
	inc 6,XSP                                            ; FB2BEF  ef 66
	cp a, 0x00:i3                                          ; FB2BF1  c9 d8
	jr nz, .LFB2C21                                      ; FB2BF3  6e 2c
	ld XIX,0x00ec0000                                    ; FB2BF5  44 00 00 ec 00
	push XIX                                             ; FB2BFA  3c
	call T_Link_SendCommand3_WaitTicks                                        ; FB2BFB  1d 34 12 f4
	lda xbc, (0x60fd08:24)                               ; FB2BFF  f2 08 fd 60 31
	push XBC                                             ; FB2C04  39
	call SysExXfer_SetJobTotal_Combination                                      ; FB2C05  1d 8a 75 fb
	lda xbc, (0x60fd18:24)                               ; FB2C09  f2 18 fd 60 31
	push XBC                                             ; FB2C0E  39
	call SysExXfer_SetPart_Combination1                                      ; FB2C0F  1d f2 76 fb
	push XIX                                             ; FB2C13  3c
	call SysExXfer_InitCpu2Forward                                      ; FB2C14  1d 63 7a fb
	calr SysExSession_RecvBody_CombinationPart1                                      ; FB2C18  1e e0 02
	inc 8,XSP                                            ; FB2C1B  ef 60
	inc 8,XSP                                            ; FB2C1D  ef 60
	jr .LFB2C33                                          ; FB2C1F  68 12
.LFB2C21:
	pushw 0x1d                                           ; FB2C21  0b 1d 00
	pushw 0x04                                           ; FB2C24  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2C27  e2 d8 fc 60 21
	push XBC                                             ; FB2C2C  39
	call U8Rec16_SetField                                      ; FB2C2D  1d 19 62 fb
	inc 8,XSP                                            ; FB2C31  ef 60
.LFB2C33:
	pop XIX                                              ; FB2C33  5c
	ret                                                  ; FB2C34  0e
; SysExSession_RecvCombinationPart2: command 0x16, 2D header 50 06 00 / 05 40 00.
SysExSession_RecvCombinationPart2:
	pushw 0x03                                           ; FB2C35  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2C38  e2 dc fc 60 21
	push XBC                                             ; FB2C3D  39
	call U8Rec16_GetField                                      ; FB2C3E  1d d3 62 fb
	inc 6,XSP                                            ; FB2C42  ef 66
	cp A,0x10                                            ; FB2C44  c9 cf 10
	jr nz, .LFB2C59                                      ; FB2C47  6e 10
	lda xbc, (0x60fd18:24)                               ; FB2C49  f2 18 fd 60 31
	push XBC                                             ; FB2C4E  39
	call SysExXfer_SetPart_CombinationBlock                                      ; FB2C4F  1d 22 77 fb
	calr SysExSession_RecvBody_CombinationPart2                                      ; FB2C53  1e df 02
	pop XIY                                              ; FB2C56  5d
	jr .LFB2C6B                                          ; FB2C57  68 12
.LFB2C59:
	pushw 0x1d                                           ; FB2C59  0b 1d 00
	pushw 0x04                                           ; FB2C5C  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2C5F  e2 d8 fc 60 21
	push XBC                                             ; FB2C64  39
	call U8Rec16_SetField                                      ; FB2C65  1d 19 62 fb
	inc 8,XSP                                            ; FB2C69  ef 60
.LFB2C6B:
	ret                                                  ; FB2C6B  0e
; SysExSession_Continuation: command 0x0A, F0 50 7E: continue the transfer of step id (field 3 < 0x12).
SysExSession_Continuation:
	pushw hl                                             ; FB2C6C  2b
	pushw 0x03                                           ; FB2C6D  0b 03 00
	ld xbc, (0x60fcdc:24)                               ; FB2C70  e2 dc fc 60 21
	push XBC                                             ; FB2C75  39
	call U8Rec16_GetField                                      ; FB2C76  1d d3 62 fb
	ld H,A                                               ; FB2C7A  c9 8e
	inc 6,XSP                                            ; FB2C7C  ef 66
	cp A,0x12                                            ; FB2C7E  c9 cf 12
	jr nc, .LFB2C98                                      ; FB2C81  6f 15
	mul A,0x04                                           ; FB2C83  c9 08 04
	extz XWA                                             ; FB2C86  e8 12
	add XWA,SysExSession_ContinuationTable                              ; FB2C88  e8 c8 9e f9 f4 00
	ld XBC,(XWA)                                         ; FB2C8E  a0 21
	lda xiy, (.LFB2C98:24)                               ; FB2C90  f2 98 2c fb 35
	push XIY                                             ; FB2C95  3d
	jp (xbc)                                             ; FB2C96  b1 d8
.LFB2C98:
	popw hl                                              ; FB2C98  4b
	ret                                                  ; FB2C99  0e
; SysExSession_RecvBody_HeaderExpected: SysExSession_ContinuationTable slots 0, 3, 6, 10, 14, 17 -- a header is due,
;   so an F0 50 7E continuation is status 0x13.
SysExSession_RecvBody_HeaderExpected:
	pushw 0x13                                           ; FB2C9A  0b 13 00
	pushw 0x04                                           ; FB2C9D  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB2CA0  e2 d8 fc 60 21
	push XBC                                             ; FB2CA5  39
	call U8Rec16_SetField                                      ; FB2CA6  1d 19 62 fb
	inc 8,XSP                                            ; FB2CAA  ef 60
	ret                                                  ; FB2CAC  0e
; SysExSession_RecvBody_SystemPart1: step 1; SysExRx_UnpackBody; on the last frame (flag, field 15, = 0) step 2.
SysExSession_RecvBody_SystemPart1:
	push XIX                                             ; FB2CAD  3c
	lda xix, (0x60fcd8:24)                               ; FB2CAE  f2 d8 fc 60 34
	pushw 0x01                                           ; FB2CB3  0b 01 00
	pushw 0x03                                           ; FB2CB6  0b 03 00
	ld XBC,(XIX)                                         ; FB2CB9  a4 21
	push XBC                                             ; FB2CBB  39
	call U8Rec16_SetField                                      ; FB2CBC  1d 19 62 fb
	call SysExRx_UnpackBody                                      ; FB2CC0  1d b5 72 fb
	pushw 0x0f                                           ; FB2CC4  0b 0f 00
	ld XBC,(XIX)                                         ; FB2CC7  a4 21
	push XBC                                             ; FB2CC9  39
	call U8Rec16_GetField                                      ; FB2CCA  1d d3 62 fb
	inc 8,XSP                                            ; FB2CCE  ef 60
	inc 6,XSP                                            ; FB2CD0  ef 66
	cp a, 0x00:i3                                          ; FB2CD2  c9 d8
	jr nz, .LFB2CE5                                      ; FB2CD4  6e 0f
	pushw 0x02                                           ; FB2CD6  0b 02 00
	pushw 0x03                                           ; FB2CD9  0b 03 00
	ld XBC,(XIX)                                         ; FB2CDC  a4 21
	push XBC                                             ; FB2CDE  39
	call U8Rec16_SetField                                      ; FB2CDF  1d 19 62 fb
	inc 8,XSP                                            ; FB2CE3  ef 60
.LFB2CE5:
	pop XIX                                              ; FB2CE5  5c
	ret                                                  ; FB2CE6  0e
; SysExSession_RecvBody_SystemPart2: step 2; SysExRx_UnpackBody; on the last frame step 3 (a header is next).
SysExSession_RecvBody_SystemPart2:
	push XIX                                             ; FB2CE7  3c
	lda xix, (0x60fcd8:24)                               ; FB2CE8  f2 d8 fc 60 34
	pushw 0x02                                           ; FB2CED  0b 02 00
	pushw 0x03                                           ; FB2CF0  0b 03 00
	ld XBC,(XIX)                                         ; FB2CF3  a4 21
	push XBC                                             ; FB2CF5  39
	call U8Rec16_SetField                                      ; FB2CF6  1d 19 62 fb
	call SysExRx_UnpackBody                                      ; FB2CFA  1d b5 72 fb
	pushw 0x0f                                           ; FB2CFE  0b 0f 00
	ld XBC,(XIX)                                         ; FB2D01  a4 21
	push XBC                                             ; FB2D03  39
	call U8Rec16_GetField                                      ; FB2D04  1d d3 62 fb
	inc 8,XSP                                            ; FB2D08  ef 60
	inc 6,XSP                                            ; FB2D0A  ef 66
	cp a, 0x00:i3                                          ; FB2D0C  c9 d8
	jr nz, .LFB2D1F                                      ; FB2D0E  6e 0f
	pushw 0x03                                           ; FB2D10  0b 03 00
	pushw 0x03                                           ; FB2D13  0b 03 00
	ld XBC,(XIX)                                         ; FB2D16  a4 21
	push XBC                                             ; FB2D18  39
	call U8Rec16_SetField                                      ; FB2D19  1d 19 62 fb
	inc 8,XSP                                            ; FB2D1D  ef 60
.LFB2D1F:
	pop XIX                                              ; FB2D1F  5c
	ret                                                  ; FB2D20  0e
; SysExSession_RecvBody_SoundOrphan: step 4, the receive half of the uncalled 0xFB248A.
SysExSession_RecvBody_SoundOrphan:
	push XIX                                             ; FB2D21  3c
	lda xix, (0x60fcd8:24)                               ; FB2D22  f2 d8 fc 60 34
	pushw 0x04                                           ; FB2D27  0b 04 00
	pushw 0x03                                           ; FB2D2A  0b 03 00
	ld XBC,(XIX)                                         ; FB2D2D  a4 21
	push XBC                                             ; FB2D2F  39
	call U8Rec16_SetField                                      ; FB2D30  1d 19 62 fb
	call SysExRx_UnpackBody                                      ; FB2D34  1d b5 72 fb
	pushw 0x0f                                           ; FB2D38  0b 0f 00
	ld XBC,(XIX)                                         ; FB2D3B  a4 21
	push XBC                                             ; FB2D3D  39
	call U8Rec16_GetField                                      ; FB2D3E  1d d3 62 fb
	inc 8,XSP                                            ; FB2D42  ef 60
	inc 6,XSP                                            ; FB2D44  ef 66
	cp a, 0x00:i3                                          ; FB2D46  c9 d8
	jr nz, .LFB2D70                                      ; FB2D48  6e 26
	pushw 0x05                                           ; FB2D4A  0b 05 00
	pushw 0x03                                           ; FB2D4D  0b 03 00
	ld XBC,(XIX)                                         ; FB2D50  a4 21
	push XBC                                             ; FB2D52  39
	call U8Rec16_SetField                                      ; FB2D53  1d 19 62 fb
	ld XBC,0x00e80000                                    ; FB2D57  41 00 00 e8 00
	push XBC                                             ; FB2D5C  39
	pushw 0x00                                           ; FB2D5D  0b 00 00
	lda xbc, (0x60a000:24)                               ; FB2D60  f2 00 a0 60 31
	push XBC                                             ; FB2D65  39
	call T_Link_SendCommandE1                            ; FB2D66  1d ec 0e f4
	add XSP,0x00000012                                   ; FB2D6A  ef c8 12 00 00 00
.LFB2D70:
	pop XIX                                              ; FB2D70  5c
	ret                                                  ; FB2D71  0e
; SysExSession_RecvBody_Stub0F: step 7 of the stubbed-out category (SysExSession_RecvStub0F).
SysExSession_RecvBody_Stub0F:
	push XIX                                             ; FB2D72  3c
	lda xix, (0x60fcd8:24)                               ; FB2D73  f2 d8 fc 60 34
	pushw 0x07                                           ; FB2D78  0b 07 00
	pushw 0x03                                           ; FB2D7B  0b 03 00
	ld XBC,(XIX)                                         ; FB2D7E  a4 21
	push XBC                                             ; FB2D80  39
	call U8Rec16_SetField                                      ; FB2D81  1d 19 62 fb
	call SysExRx_UnpackBody                                      ; FB2D85  1d b5 72 fb
	pushw 0x0f                                           ; FB2D89  0b 0f 00
	ld XBC,(XIX)                                         ; FB2D8C  a4 21
	push XBC                                             ; FB2D8E  39
	call U8Rec16_GetField                                      ; FB2D8F  1d d3 62 fb
	inc 8,XSP                                            ; FB2D93  ef 60
	inc 6,XSP                                            ; FB2D95  ef 66
	cp a, 0x00:i3                                          ; FB2D97  c9 d8
	jr nz, .LFB2DAA                                      ; FB2D99  6e 0f
	pushw 0x08                                           ; FB2D9B  0b 08 00
	pushw 0x03                                           ; FB2D9E  0b 03 00
	ld XBC,(XIX)                                         ; FB2DA1  a4 21
	push XBC                                             ; FB2DA3  39
	call U8Rec16_SetField                                      ; FB2DA4  1d 19 62 fb
	inc 8,XSP                                            ; FB2DA8  ef 60
.LFB2DAA:
	pop XIX                                              ; FB2DAA  5c
	ret                                                  ; FB2DAB  0e
; SysExSession_RecvBody_Stub10: step 8, as SysExSession_RecvBody_Stub0F.
SysExSession_RecvBody_Stub10:
	push XIX                                             ; FB2DAC  3c
	lda xix, (0x60fcd8:24)                               ; FB2DAD  f2 d8 fc 60 34
	pushw 0x08                                           ; FB2DB2  0b 08 00
	pushw 0x03                                           ; FB2DB5  0b 03 00
	ld XBC,(XIX)                                         ; FB2DB8  a4 21
	push XBC                                             ; FB2DBA  39
	call U8Rec16_SetField                                      ; FB2DBB  1d 19 62 fb
	call SysExRx_UnpackBody                                      ; FB2DBF  1d b5 72 fb
	pushw 0x0f                                           ; FB2DC3  0b 0f 00
	ld XBC,(XIX)                                         ; FB2DC6  a4 21
	push XBC                                             ; FB2DC8  39
	call U8Rec16_GetField                                      ; FB2DC9  1d d3 62 fb
	inc 8,XSP                                            ; FB2DCD  ef 60
	inc 6,XSP                                            ; FB2DCF  ef 66
	cp a, 0x00:i3                                          ; FB2DD1  c9 d8
	jr nz, .LFB2DE4                                      ; FB2DD3  6e 0f
	pushw 0x09                                           ; FB2DD5  0b 09 00
	pushw 0x03                                           ; FB2DD8  0b 03 00
	ld XBC,(XIX)                                         ; FB2DDB  a4 21
	push XBC                                             ; FB2DDD  39
	call U8Rec16_SetField                                      ; FB2DDE  1d 19 62 fb
	inc 8,XSP                                            ; FB2DE2  ef 60
.LFB2DE4:
	pop XIX                                              ; FB2DE4  5c
	ret                                                  ; FB2DE5  0e
; SysExSession_RecvBody_Stub11: step 9, as SysExSession_RecvBody_Stub0F.
SysExSession_RecvBody_Stub11:
	push XIX                                             ; FB2DE6  3c
	lda xix, (0x60fcd8:24)                               ; FB2DE7  f2 d8 fc 60 34
	pushw 0x09                                           ; FB2DEC  0b 09 00
	pushw 0x03                                           ; FB2DEF  0b 03 00
	ld XBC,(XIX)                                         ; FB2DF2  a4 21
	push XBC                                             ; FB2DF4  39
	call U8Rec16_SetField                                      ; FB2DF5  1d 19 62 fb
	call SysExRx_UnpackBody                                      ; FB2DF9  1d b5 72 fb
	pushw 0x0f                                           ; FB2DFD  0b 0f 00
	ld XBC,(XIX)                                         ; FB2E00  a4 21
	push XBC                                             ; FB2E02  39
	call U8Rec16_GetField                                      ; FB2E03  1d d3 62 fb
	inc 8,XSP                                            ; FB2E07  ef 60
	inc 6,XSP                                            ; FB2E09  ef 66
	cp a, 0x00:i3                                          ; FB2E0B  c9 d8
	jr nz, .LFB2E1E                                      ; FB2E0D  6e 0f
	pushw 0x0a                                           ; FB2E0F  0b 0a 00
	pushw 0x03                                           ; FB2E12  0b 03 00
	ld XBC,(XIX)                                         ; FB2E15  a4 21
	push XBC                                             ; FB2E17  39
	call U8Rec16_SetField                                      ; FB2E18  1d 19 62 fb
	inc 8,XSP                                            ; FB2E1C  ef 60
.LFB2E1E:
	pop XIX                                              ; FB2E1E  5c
	ret                                                  ; FB2E1F  0e
; SysExSession_RecvBody_SequencerPart1: step 0x0B; SysEx_FeatureWordForVariant(3), SysExRx_UnpackBody.
SysExSession_RecvBody_SequencerPart1:
	push XIX                                             ; FB2E20  3c
	lda xix, (0x60fcd8:24)                               ; FB2E21  f2 d8 fc 60 34
	pushw 0x0b                                           ; FB2E26  0b 0b 00
	pushw 0x03                                           ; FB2E29  0b 03 00
	ld XBC,(XIX)                                         ; FB2E2C  a4 21
	push XBC                                             ; FB2E2E  39
	call U8Rec16_SetField                                      ; FB2E2F  1d 19 62 fb
	pushw 0x03                                           ; FB2E33  0b 03 00
	call SysEx_FeatureWordForVariant                                      ; FB2E36  1d f5 5f fb
	inc 8,XSP                                            ; FB2E3A  ef 60
	inc 2,XSP                                            ; FB2E3C  ef 62
	cp WA,0xffff                                         ; FB2E3E  d8 cf ff ff
	jr z, .LFB2E48                                       ; FB2E42  66 04
	call SysExRx_UnpackBody                                      ; FB2E44  1d b5 72 fb
.LFB2E48:
	pushw 0x0f                                           ; FB2E48  0b 0f 00
	ld XBC,(XIX)                                         ; FB2E4B  a4 21
	push XBC                                             ; FB2E4D  39
	call U8Rec16_GetField                                      ; FB2E4E  1d d3 62 fb
	inc 6,XSP                                            ; FB2E52  ef 66
	cp a, 0x00:i3                                          ; FB2E54  c9 d8
	jr nz, .LFB2E67                                      ; FB2E56  6e 0f
	pushw 0x0c                                           ; FB2E58  0b 0c 00
	pushw 0x03                                           ; FB2E5B  0b 03 00
	ld XBC,(XIX)                                         ; FB2E5E  a4 21
	push XBC                                             ; FB2E60  39
	call U8Rec16_SetField                                      ; FB2E61  1d 19 62 fb
	inc 8,XSP                                            ; FB2E65  ef 60
.LFB2E67:
	pop XIX                                              ; FB2E67  5c
	ret                                                  ; FB2E68  0e
; SysExSession_RecvBody_SequencerPart2: step 0x0C, as part 1.
SysExSession_RecvBody_SequencerPart2:
	push XIX                                             ; FB2E69  3c
	lda xix, (0x60fcd8:24)                               ; FB2E6A  f2 d8 fc 60 34
	pushw 0x0c                                           ; FB2E6F  0b 0c 00
	pushw 0x03                                           ; FB2E72  0b 03 00
	ld XBC,(XIX)                                         ; FB2E75  a4 21
	push XBC                                             ; FB2E77  39
	call U8Rec16_SetField                                      ; FB2E78  1d 19 62 fb
	pushw 0x03                                           ; FB2E7C  0b 03 00
	call SysEx_FeatureWordForVariant                                      ; FB2E7F  1d f5 5f fb
	inc 8,XSP                                            ; FB2E83  ef 60
	inc 2,XSP                                            ; FB2E85  ef 62
	cp WA,0xffff                                         ; FB2E87  d8 cf ff ff
	jr z, .LFB2E91                                       ; FB2E8B  66 04
	call SysExRx_UnpackBody                                      ; FB2E8D  1d b5 72 fb
.LFB2E91:
	pushw 0x0f                                           ; FB2E91  0b 0f 00
	ld XBC,(XIX)                                         ; FB2E94  a4 21
	push XBC                                             ; FB2E96  39
	call U8Rec16_GetField                                      ; FB2E97  1d d3 62 fb
	inc 6,XSP                                            ; FB2E9B  ef 66
	cp a, 0x00:i3                                          ; FB2E9D  c9 d8
	jr nz, .LFB2EB0                                      ; FB2E9F  6e 0f
	pushw 0x0d                                           ; FB2EA1  0b 0d 00
	pushw 0x03                                           ; FB2EA4  0b 03 00
	ld XBC,(XIX)                                         ; FB2EA7  a4 21
	push XBC                                             ; FB2EA9  39
	call U8Rec16_SetField                                      ; FB2EAA  1d 19 62 fb
	inc 8,XSP                                            ; FB2EAE  ef 60
.LFB2EB0:
	pop XIX                                              ; FB2EB0  5c
	ret                                                  ; FB2EB1  0e
; SysExSession_RecvBody_SequencerPart3: step 0x0D, as part 1.
SysExSession_RecvBody_SequencerPart3:
	push XIX                                             ; FB2EB2  3c
	lda xix, (0x60fcd8:24)                               ; FB2EB3  f2 d8 fc 60 34
	pushw 0x0d                                           ; FB2EB8  0b 0d 00
	pushw 0x03                                           ; FB2EBB  0b 03 00
	ld XBC,(XIX)                                         ; FB2EBE  a4 21
	push XBC                                             ; FB2EC0  39
	call U8Rec16_SetField                                      ; FB2EC1  1d 19 62 fb
	pushw 0x03                                           ; FB2EC5  0b 03 00
	call SysEx_FeatureWordForVariant                                      ; FB2EC8  1d f5 5f fb
	inc 8,XSP                                            ; FB2ECC  ef 60
	inc 2,XSP                                            ; FB2ECE  ef 62
	cp WA,0xffff                                         ; FB2ED0  d8 cf ff ff
	jr z, .LFB2EDA                                       ; FB2ED4  66 04
	call SysExRx_UnpackBody                                      ; FB2ED6  1d b5 72 fb
.LFB2EDA:
	pushw 0x0f                                           ; FB2EDA  0b 0f 00
	ld XBC,(XIX)                                         ; FB2EDD  a4 21
	push XBC                                             ; FB2EDF  39
	call U8Rec16_GetField                                      ; FB2EE0  1d d3 62 fb
	inc 6,XSP                                            ; FB2EE4  ef 66
	cp a, 0x00:i3                                          ; FB2EE6  c9 d8
	jr nz, .LFB2EF9                                      ; FB2EE8  6e 0f
	pushw 0x0e                                           ; FB2EEA  0b 0e 00
	pushw 0x03                                           ; FB2EED  0b 03 00
	ld XBC,(XIX)                                         ; FB2EF0  a4 21
	push XBC                                             ; FB2EF2  39
	call U8Rec16_SetField                                      ; FB2EF3  1d 19 62 fb
	inc 8,XSP                                            ; FB2EF7  ef 60
.LFB2EF9:
	pop XIX                                              ; FB2EF9  5c
	ret                                                  ; FB2EFA  0e
; SysExSession_RecvBody_CombinationPart1: step 0x0F; SysExRx_UnpackBodyToBlock.
SysExSession_RecvBody_CombinationPart1:
	push XIX                                             ; FB2EFB  3c
	lda xix, (0x60fcd8:24)                               ; FB2EFC  f2 d8 fc 60 34
	pushw 0x0f                                           ; FB2F01  0b 0f 00
	pushw 0x03                                           ; FB2F04  0b 03 00
	ld XBC,(XIX)                                         ; FB2F07  a4 21
	push XBC                                             ; FB2F09  39
	call U8Rec16_SetField                                      ; FB2F0A  1d 19 62 fb
	call SysExRx_UnpackBodyToBlock                                      ; FB2F0E  1d 65 73 fb
	pushw 0x0f                                           ; FB2F12  0b 0f 00
	ld XBC,(XIX)                                         ; FB2F15  a4 21
	push XBC                                             ; FB2F17  39
	call U8Rec16_GetField                                      ; FB2F18  1d d3 62 fb
	inc 8,XSP                                            ; FB2F1C  ef 60
	inc 6,XSP                                            ; FB2F1E  ef 66
	cp a, 0x00:i3                                          ; FB2F20  c9 d8
	jr nz, .LFB2F33                                      ; FB2F22  6e 0f
	pushw 0x10                                           ; FB2F24  0b 10 00
	pushw 0x03                                           ; FB2F27  0b 03 00
	ld XBC,(XIX)                                         ; FB2F2A  a4 21
	push XBC                                             ; FB2F2C  39
	call U8Rec16_SetField                                      ; FB2F2D  1d 19 62 fb
	inc 8,XSP                                            ; FB2F31  ef 60
.LFB2F33:
	pop XIX                                              ; FB2F33  5c
	ret                                                  ; FB2F34  0e
; SysExSession_RecvBody_CombinationPart2: step 0x10; SysExRx_UnpackBodyToBlock, blocks to CPU 2 (T_Link_SendCommandE7).
SysExSession_RecvBody_CombinationPart2:
	link XIZ,0xfff8                                      ; FB2F35  ee 0c f8 ff
	pushw hl                                             ; FB2F39  2b
	push XIX                                             ; FB2F3A  3c
	lda xix, (0x60fd32:24)                               ; FB2F3B  f2 32 fd 60 34
	pushw 0x10                                           ; FB2F40  0b 10 00
	pushw 0x03                                           ; FB2F43  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB2F46  e2 d8 fc 60 21
	push XBC                                             ; FB2F4B  39
	call U8Rec16_SetField                                      ; FB2F4C  1d 19 62 fb
	call SysExRx_UnpackBodyToBlock                                      ; FB2F50  1d 65 73 fb
	inc 8,XSP                                            ; FB2F54  ef 60
	cp WA,0xffff                                         ; FB2F56  d8 cf ff ff
	jrl z, .LFB303C                                      ; FB2F5A  76 df 00
	ld BC,(XIX+0x08)                                     ; FB2F5D  9c 08 21
	cp BC,0x0400                                         ; FB2F60  d9 cf 00 04
	jrl c, .LFB3003                                      ; FB2F64  77 9c 00
	ld C,(XIX+0x0a)                                      ; FB2F67  8c 0a 23
	cp C,0x40                                            ; FB2F6A  cb cf 40
	jr c, .LFB2F86                                       ; FB2F6D  67 17
	ld C,(XIX+0x0b)                                      ; FB2F6F  8c 0b 23
	cp c, 0x01:i3                                          ; FB2F72  cb d9
	jr nc, .LFB2F86                                      ; FB2F74  6f 10
	ld XBC,(XIX+0x04)                                    ; FB2F76  ac 04 21
	push XBC                                             ; FB2F79  39
	call T_Link_SendCommand3_WaitTicks                                        ; FB2F7A  1d 34 12 f4
	ld (XIX+0x0a),0x00                                   ; FB2F7E  bc 0a 00 00
	incm8 0x01, (xix+0x0b)                               ; FB2F82  8c 0b 61
	pop XIY                                              ; FB2F85  5d
.LFB2F86:
	ld BC,(XIX+0x0c)                                     ; FB2F86  9c 0c 21
	cp bc, 0x00:i3                                         ; FB2F89  d9 d8
	jr z, .LFB2F93                                       ; FB2F8B  66 06
	cp bc, 0x01:i3                                         ; FB2F8D  d9 d9
	jr z, .LFB2F93                                       ; FB2F8F  66 02
	jr .LFB2FB6                                          ; FB2F91  68 23
.LFB2F93:
	ld XBC,(XIX+0x04)                                    ; FB2F93  ac 04 21
	push XBC                                             ; FB2F96  39
	ld XBC,(XIX)                                         ; FB2F97  a4 21
	push XBC                                             ; FB2F99  39
	call T_Link_SendCommandE7                            ; FB2F9A  1d 40 12 f4
	subw	(xix+8), 0x0400                      ; FB2F9E  9c 08 3a 00 04
	ld XBC,0x00000400                                    ; FB2FA3  41 00 04 00 00
	add (XIX),XBC                                        ; FB2FA8  a4 89
	ld XBC,0x00000400                                    ; FB2FAA  41 00 04 00 00
	add (XIX+0x04),XBC                                   ; FB2FAF  ac 04 89
	inc 8,XSP                                            ; FB2FB2  ef 60
	jr .LFB2FFD                                          ; FB2FB4  68 47
.LFB2FB6:
	ld XBC,(XIX+0x04)                                    ; FB2FB6  ac 04 21
	push XBC                                             ; FB2FB9  39
	ld XBC,(XIX)                                         ; FB2FBA  a4 21
	push XBC                                             ; FB2FBC  39
	call T_Link_SendCommandE7                            ; FB2FBD  1d 40 12 f4
	subw	(xix+8), 0x0400                      ; FB2FC1  9c 08 3a 00 04
	ld XBC,0x00000400                                    ; FB2FC6  41 00 04 00 00
	add (XIX+0x04),XBC                                   ; FB2FCB  ac 04 89
	ld HL,(XIX+0x08)                                     ; FB2FCE  9c 08 23
	inc 8,XSP                                            ; FB2FD1  ef 60
	cp hl, 0x00:i3                                         ; FB2FD3  db d8
	jr z, .LFB2FF3                                       ; FB2FD5  66 1c
	ld XBC,(XIX)                                         ; FB2FD7  a4 21
	ld (xiz-4), xbc                                      ; FB2FD9  be fc 61
	add XBC,0x00000400                                   ; FB2FDC  e9 c8 00 04 00 00
	ld (xiz-8), xbc                                      ; FB2FE2  be f8 61
	pushw hl                                             ; FB2FE5  2b
	ld xwa, (xiz-4)                                      ; FB2FE6  ae fc 20
	push XWA                                             ; FB2FE9  38
	push XBC                                             ; FB2FEA  39
	call MemCopyWords_Copy                                      ; FB2FEB  1d ce 81 fb
	inc 8,XSP                                            ; FB2FEF  ef 60
	inc 2,XSP                                            ; FB2FF1  ef 62
.LFB2FF3:
	ld XBC,0x00000400                                    ; FB2FF3  41 00 04 00 00
	sub (0x60fd18:24), xbc                           ; FB2FF8  e2 18 fd 60 a9
.LFB2FFD:
	incw 0x01, (xix+0x0c)                                ; FB2FFD  9c 0c 61
	incm8 0x01, (xix+0x0a)                               ; FB3000  8c 0a 61
.LFB3003:
	pushw 0x0f                                           ; FB3003  0b 0f 00
	ld xbc, (0x60fcd8:24)                               ; FB3006  e2 d8 fc 60 21
	push XBC                                             ; FB300B  39
	call U8Rec16_GetField                                      ; FB300C  1d d3 62 fb
	inc 6,XSP                                            ; FB3010  ef 66
	cp a, 0x00:i3                                          ; FB3012  c9 d8
	jr nz, .LFB303C                                      ; FB3014  6e 26
	pushw 0x11                                           ; FB3016  0b 11 00
	pushw 0x03                                           ; FB3019  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB301C  e2 d8 fc 60 21
	push XBC                                             ; FB3021  39
	call U8Rec16_SetField                                      ; FB3022  1d 19 62 fb
	ld BC,(XIX+0x08)                                     ; FB3026  9c 08 21
	inc 8,XSP                                            ; FB3029  ef 60
	cp bc, 0x00:i3                                         ; FB302B  d9 d8
	jr z, .LFB303C                                       ; FB302D  66 0d
	ld XBC,(XIX+0x04)                                    ; FB302F  ac 04 21
	push XBC                                             ; FB3032  39
	ld XBC,(XIX)                                         ; FB3033  a4 21
	push XBC                                             ; FB3035  39
	call T_Link_SendCommandE7                            ; FB3036  1d 40 12 f4
	inc 8,XSP                                            ; FB303A  ef 60
.LFB303C:
	pop XIX                                              ; FB303C  5c
	popw hl                                              ; FB303D  4b
	unlk XIZ                                             ; FB303E  ee 0d
	ret                                                  ; FB3040  0e
; SysExSession_CategoryEnd: command 0x03, F0 50 27 7E F7: by the step id (field 3 < 0x12) through SysExSession_CategoryEndTable.
SysExSession_CategoryEnd:
	pushw hl                                             ; FB3041  2b
	ld xbc, (0x60fcdc:24)                               ; FB3042  e2 dc fc 60 21
	ld H,(XBC+0x03)                                      ; FB3047  89 03 26
	cp H,0x12                                            ; FB304A  ce cf 12
	jr nc, .LFB306A                                      ; FB304D  6f 1b
	ld a, 0x04:opc                                          ; FB304F  21 04
	mul wa, h                                          ; FB3051  ce 41
	extz XWA                                             ; FB3053  e8 12
	add XWA,SysExSession_CategoryEndTable                              ; FB3055  e8 c8 e6 f9 f4 00
	ld XWA,(XWA)                                         ; FB305B  a0 20
	lda xiy, (.LFB3065:24)                               ; FB305D  f2 65 30 fb 35
	push XIY                                             ; FB3062  3d
	jp (xwa)                                             ; FB3063  b0 d8
.LFB3065:
	res	7, (0x60fd42:24)                             ; FB3065  f2 42 fd 60 b7
.LFB306A:
	popw hl                                              ; FB306A  4b
	ret                                                  ; FB306B  0e
; SysExSession_CategoryEnd_WrongStep: an end-of-category message in a step that is not a category end: status 0x1E.
SysExSession_CategoryEnd_WrongStep:
	pushw 0x1e                                           ; FB306C  0b 1e 00
	pushw 0x04                                           ; FB306F  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB3072  e2 d8 fc 60 21
	push XBC                                             ; FB3077  39
	call U8Rec16_SetField                                      ; FB3078  1d 19 62 fb
	inc 8,XSP                                            ; FB307C  ef 60
	ret                                                  ; FB307E  0e
; SysExSession_CategoryEnd_SystemPartMidi: step 3: step 0, bit 7 of (0x60FD41) (categories received).
SysExSession_CategoryEnd_SystemPartMidi:
	pushw 0x00                                           ; FB307F  0b 00 00
	pushw 0x03                                           ; FB3082  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB3085  e2 d8 fc 60 21
	push XBC                                             ; FB308A  39
	call U8Rec16_SetField                                      ; FB308B  1d 19 62 fb
	set	7, (0x60fd41:24)                             ; FB308F  f2 41 fd 60 bf
	inc 8,XSP                                            ; FB3094  ef 60
	ret                                                  ; FB3096  0e
; SysExSession_CategoryEnd_Sound: step 6: step 0, bit 6 of (0x60FD41).
SysExSession_CategoryEnd_Sound:
	pushw 0x00                                           ; FB3097  0b 00 00
	pushw 0x03                                           ; FB309A  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB309D  e2 d8 fc 60 21
	push XBC                                             ; FB30A2  39
	call U8Rec16_SetField                                      ; FB30A3  1d 19 62 fb
	set	6, (0x60fd41:24)                             ; FB30A7  f2 41 fd 60 be
	inc 8,XSP                                            ; FB30AC  ef 60
	ret                                                  ; FB30AE  0e
; SysExSession_CategoryEnd_Stub: step 10, the stubbed-out category: step 0, bit 5 of (0x60FD41).
SysExSession_CategoryEnd_Stub:
	pushw 0x00                                           ; FB30AF  0b 00 00
	pushw 0x03                                           ; FB30B2  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB30B5  e2 d8 fc 60 21
	push XBC                                             ; FB30BA  39
	call U8Rec16_SetField                                      ; FB30BB  1d 19 62 fb
	set	5, (0x60fd41:24)                             ; FB30BF  f2 41 fd 60 bd
	inc 8,XSP                                            ; FB30C4  ef 60
	ret                                                  ; FB30C6  0e
; SysExSession_CategoryEnd_Sequencer: step 14: step 0, bit 4 of (0x60FD41).
SysExSession_CategoryEnd_Sequencer:
	pushw 0x00                                           ; FB30C7  0b 00 00
	pushw 0x03                                           ; FB30CA  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB30CD  e2 d8 fc 60 21
	push XBC                                             ; FB30D2  39
	call U8Rec16_SetField                                      ; FB30D3  1d 19 62 fb
	set	4, (0x60fd41:24)                             ; FB30D7  f2 41 fd 60 bc
	inc 8,XSP                                            ; FB30DC  ef 60
	ret                                                  ; FB30DE  0e
; SysExSession_CategoryEnd_Combination: step 17: step 0, bit 3 of (0x60FD41).
SysExSession_CategoryEnd_Combination:
	pushw 0x00                                           ; FB30DF  0b 00 00
	pushw 0x03                                           ; FB30E2  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB30E5  e2 d8 fc 60 21
	push XBC                                             ; FB30EA  39
	call U8Rec16_SetField                                      ; FB30EB  1d 19 62 fb
	set	3, (0x60fd41:24)                             ; FB30EF  f2 41 fd 60 bb
	inc 8,XSP                                            ; FB30F4  ef 60
	ret                                                  ; FB30F6  0e
; SysExSession_DumpEnd: command 0x04, F0 50 28 7E F7 (end of dump) or 2A 7E (memory full): status 0, end the session.
SysExSession_DumpEnd:
	pushw 0x00                                           ; FB30F7  0b 00 00
	pushw 0x03                                           ; FB30FA  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB30FD  e2 d8 fc 60 21
	push XBC                                             ; FB3102  39
	call U8Rec16_SetField                                      ; FB3103  1d 19 62 fb
	res	4, (0x60fd40:24)                             ; FB3107  f2 40 fd 60 b4
	calr SysExSession_OnEnd_SystemPartMidi                                      ; FB310C  1e 6f 00
	calr SysExSession_OnEnd_Sound                                      ; FB310F  1e ba 00
	calr SysExSession_OnEnd_Sound_Nop                                      ; FB3112  1e ec 00
	calr SysExSession_OnEnd_Sequencer                                      ; FB3115  1e ea 00
	calr SysExSession_ClearCombinationReceived                                      ; FB3118  1e 08 01
	inc 8,XSP                                            ; FB311B  ef 60
	ret                                                  ; FB311D  0e
; ParamImage_WriteHeadersAndSanitize: With XDE / XHL / XIX / XIZ saved: T_ParamImage_WriteRecordHeaders_Entry,
;   T_ParamImage_SanitizeAllAndHook_Entry, the two empty slots T_F401D4 / T_F407A4, then Disk_Flags |= 0x18. The first
;   step of SysExSession_OnEnd_SystemPartMidi ("rewrites the record headers and sanitizes the parameter image");
;   GmMode_ApplyChange runs the same sequence inline. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
ParamImage_WriteHeadersAndSanitize:
	push XDE                                             ; FB311E  3a
	push XHL                                             ; FB311F  3b
	push XIX                                             ; FB3120  3c
	push XIZ                                             ; FB3121  3e
	call T_ParamImage_WriteRecordHeaders_Entry                                        ; FB3122  1d 24 02 f4
	call T_ParamImage_SanitizeAllAndHook_Entry                                        ; FB3126  1d 1c 02 f4
	call T_F401D4                                        ; FB312A  1d d4 01 f4
	call T_F407A4                                        ; FB312E  1d a4 07 f4
	or	(Disk_Flags:16), 0x18                            ; FB3132  c1 e7 21 3e 18
	pop XIZ                                              ; FB3137  5e
	pop XIX                                              ; FB3138  5c
	pop XHL                                              ; FB3139  5b
	pop XDE                                              ; FB313A  5a
	ret                                                  ; FB313B  0e
ParamImage_QueueDiffAll_SaveRegs:
	push XDE                                             ; FB313C  3a
	push XHL                                             ; FB313D  3b
	push XIX                                             ; FB313E  3c
	push XIZ                                             ; FB313F  3e
	call T_ParamImage_QueueDiffAll                                        ; FB3140  1d dc 01 f4
	pop XIZ                                              ; FB3144  5e
	pop XIX                                              ; FB3145  5c
	pop XHL                                              ; FB3146  5b
	pop XDE                                              ; FB3147  5a
	ret                                                  ; FB3148  0e
; Queue2C00_DrainPassBAndPublish: With XDE / XHL / XIX / XIZ saved: T_Queue2C00_DrainPassB, then T_UiEventList_Publish
;   -- the "drains pass B and publishes" step of SysExSession_OnEnd_SystemPartMidi. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Queue2C00_DrainPassBAndPublish:
	push XDE                                             ; FB3149  3a
	push XHL                                             ; FB314A  3b
	push XIX                                             ; FB314B  3c
	push XIZ                                             ; FB314C  3e
	call T_Queue2C00_DrainPassB                          ; FB314D  1d 38 00 f4
	call T_UiEventList_Publish                           ; FB3151  1d 50 0f f4
	pop XIZ                                              ; FB3155  5e
	pop XIX                                              ; FB3156  5c
	pop XHL                                              ; FB3157  5b
	pop XDE                                              ; FB3158  5a
	ret                                                  ; FB3159  0e
	push XDE                                             ; FB315A  3a
	push XHL                                             ; FB315B  3b
	push XIX                                             ; FB315C  3c
	push XIZ                                             ; FB315D  3e
	call T_Queue2C00_DrainPassB                          ; FB315E  1d 38 00 f4
	res	0, (0x124c:16)                               ; FB3162  f1 4c 12 b0
	and	(Disk_Flags:16), 0xe7                            ; FB3166  c1 e7 21 3c e7
	set	4, (0x60f020:24)                             ; FB316B  f2 20 f0 60 bc
	call T_Tempo_ApplyBpm                                        ; FB3170  1d 94 07 f4
	res	4, (0x60f020:24)                             ; FB3174  f2 20 f0 60 b4
	pop XIZ                                              ; FB3179  5e
	pop XIX                                              ; FB317A  5c
	pop XHL                                              ; FB317B  5b
	pop XDE                                              ; FB317C  5a
	ret                                                  ; FB317D  0e
; SysExSession_OnEnd_SystemPartMidi: Dump-end work for the SYSTEM/PART/MIDI category, only when it was received
;   ((0x60FD41) bit 7): rewrites the record headers and sanitizes the parameter image (Disk_Flags |= 0x18), queues the
;   diff of the whole image, drains pass B and publishes, then clears bit 7; between steps it sets (0x124C) bit 0 if
;   the SEQUENCER category also arrived. Basis: caller + body + the CategoryEnd bit map. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_c8.json)
SysExSession_OnEnd_SystemPartMidi:
	push XIX                                             ; FB317E  3c
	lda xix, (.LFB31B3:24)                               ; FB317F  f2 b3 31 fb 34
	bit	7, (0x60fd41:24)                             ; FB3184  f2 41 fd 60 cf
	jr z, .LFB31B1                                       ; FB3189  66 26
	calr ParamImage_WriteHeadersAndSanitize                                      ; FB318B  1e 90 ff
	lda xiy, (.LFB3196:24)                               ; FB318E  f2 96 31 fb 35
	push XIY                                             ; FB3193  3d
	jp (xix)                                             ; FB3194  b4 d8
.LFB3196:
	calr ParamImage_QueueDiffAll_SaveRegs                                      ; FB3196  1e a3 ff
	lda xiy, (.LFB31A1:24)                               ; FB3199  f2 a1 31 fb 35
	push XIY                                             ; FB319E  3d
	jp (xix)                                             ; FB319F  b4 d8
.LFB31A1:
	calr Queue2C00_DrainPassBAndPublish                                      ; FB31A1  1e a5 ff
	lda xiy, (.LFB31AC:24)                               ; FB31A4  f2 ac 31 fb 35
	push XIY                                             ; FB31A9  3d
	jp (xix)                                             ; FB31AA  b4 d8
.LFB31AC:
	res	7, (0x60fd41:24)                             ; FB31AC  f2 41 fd 60 b7
.LFB31B1:
	pop XIX                                              ; FB31B1  5c
	ret                                                  ; FB31B2  0e
.LFB31B3:
	bit	4, (0x60fd41:24)                             ; FB31B3  f2 41 fd 60 cc
	jr z, .LFB31BE                                       ; FB31B8  66 04
	set	0, (0x124c:16)                               ; FB31BA  f1 4c 12 b8
.LFB31BE:
	ret                                                  ; FB31BE  0e
; Msg0716_PostRestageAllParts_SaveRegs: Saves XDE / XHL / XIX / XIZ around T_Msg0716_PostRestageAllParts (Msg0716_PostRestageAllParts, was
;   Msg0716_PostRestageAllParts) -- the call SysExSession_OnEnd_Sound makes after its 88 00 18 link request. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_PostRestageAllParts_SaveRegs:
	push XDE                                             ; FB31BF  3a
	push XHL                                             ; FB31C0  3b
	push XIX                                             ; FB31C1  3c
	push XIZ                                             ; FB31C2  3e
	call T_Msg0716_PostRestageAllParts                                        ; FB31C3  1d ec 0f f4
	pop XIZ                                              ; FB31C7  5e
	pop XIX                                              ; FB31C8  5c
	pop XHL                                              ; FB31C9  5b
	pop XDE                                              ; FB31CA  5a
	ret                                                  ; FB31CB  0e
; SysExSession_OnEnd_Sound: Dump-end work for the SOUND category, only when it was received ((0x60FD41) bit 6): sends
;   the 6-byte CPU-2 link request 88 00 18 00 00 00 (prom_b 0xF4F910) with T_Link_SendBlockIn32ByteChunks, calls
;   T_Msg0716_PostRestageAllParts (Msg0716_PostRestageAllParts, also SysExSession_OnAbort_Sound's last call) and clears bit 6. Basis: caller + body + the
;   CategoryEnd bit map. (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
SysExSession_OnEnd_Sound:
	link XIZ,0xfffa                                      ; FB31CC  ee 0c fa ff
	push XIX                                             ; FB31D0  3c
	ldw bc, 0x03                                         ; FB31D1  31 03 00
	lda xiy, (0xf4f910:24)                               ; FB31D4  f2 10 f9 f4 35
	lda xix, (xiz-6)                                     ; FB31D9  be fa 34
	ldirw                                                ; FB31DC  95 11
	bit	6, (0x60fd41:24)                             ; FB31DE  f2 41 fd 60 ce
	jr z, .LFB31FD                                       ; FB31E3  66 18
	lda xbc, (xiz-6)                                     ; FB31E5  be fa 31
	push XBC                                             ; FB31E8  39
	pushw 0x06                                           ; FB31E9  0b 06 00
	pushw 0x00                                           ; FB31EC  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FB31EF  1d d4 0e f4
	calr Msg0716_PostRestageAllParts_SaveRegs                                      ; FB31F3  1e c9 ff
	res	6, (0x60fd41:24)                             ; FB31F6  f2 41 fd 60 b6
	inc 8,XSP                                            ; FB31FB  ef 60
.LFB31FD:
	pop XIX                                              ; FB31FD  5c
	unlk XIZ                                             ; FB31FE  ee 0d
	ret                                                  ; FB3200  0e
SysExSession_OnEnd_Sound_Nop:
	ret                                                  ; FB3201  0e
; SysExSession_OnEnd_Sequencer: Dump-end work for the SEQUENCER category, only when it was received ((0x60FD41) bit
;   4): ParamImageAlt_SanitizeCombination, T_F401D4 (a nop) and T_SysExDump_RestoreSavedCurrentBank -- prom_b SysExDump_RestoreSavedCurrentBank, which takes the
;   received bank number into BStore_CurrentBank and runs BStore_RebuildFreeListAfterLoad -- then clears bit 4. Basis:
;   caller + body + the CategoryEnd bit map. (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
SysExSession_OnEnd_Sequencer:
	bit	4, (0x60fd41:24)                             ; FB3202  f2 41 fd 60 cc
	jr z, .LFB3222                                       ; FB3207  66 19
	push XDE                                             ; FB3209  3a
	push XHL                                             ; FB320A  3b
	push XIX                                             ; FB320B  3c
	push XIZ                                             ; FB320C  3e
	call T_ParamImageAlt_SanitizeCombination_Entry                                        ; FB320D  1d 28 02 f4
	call T_F401D4                                        ; FB3211  1d d4 01 f4
	call T_SysExDump_RestoreSavedCurrentBank                                        ; FB3215  1d b8 14 f4
	pop XIZ                                              ; FB3219  5e
	pop XIX                                              ; FB321A  5c
	pop XHL                                              ; FB321B  5b
	pop XDE                                              ; FB321C  5a
	res	4, (0x60fd41:24)                             ; FB321D  f2 41 fd 60 b4
.LFB3222:
	ret                                                  ; FB3222  0e
; SysExSession_ClearCombinationReceived: clear bit 3 of (0x60FD41), the bit SysExSession_CategoryEnd_Combination sets.
SysExSession_ClearCombinationReceived:
	bit	3, (0x60fd41:24)                             ; FB3223  f2 41 fd 60 cb
	jr z, .LFB322F                                       ; FB3228  66 05
	res	3, (0x60fd41:24)                             ; FB322A  f2 41 fd 60 b3
.LFB322F:
	ret                                                  ; FB322F  0e
; SysExSession_Ignore: the in-session table's (PtrTable_F4F916) default, a bare ret.
SysExSession_Ignore:
	ret                                                  ; FB3230  0e
SysExSession_Cmd01_Nop:
	ret                                                  ; FB3231  0e
SysExSession_Cmd02_Nop:
	ret                                                  ; FB3232  0e
SysExSession_Cmd06_Nop:
	ret                                                  ; FB3233  0e
; SysExSession_AbortIfFailed: After the bulk-dump session loop ends: when the session record's status field
;   ((0x60FCD8)+4) is non-zero, runs SysExSession_AbortByStep to undo the step in progress; status 0 (a clean
;   SysExSession_DumpEnd) does nothing. Called by SysExSession_Run before SysExDump_ShowResult. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave8_c8.json)
SysExSession_AbortIfFailed:
	ld xbc, (0x60fcd8:24)                               ; FB3234  e2 d8 fc 60 21
	ld A,(XBC+0x04)                                      ; FB3239  89 04 21
	cp a, 0x00:i3                                          ; FB323C  c9 d8
	jr z, .LFB3243                                       ; FB323E  66 03
	calr SysExSession_AbortByStep                                      ; FB3240  1e 0e 00
.LFB3243:
	ret                                                  ; FB3243  0e
; SysExSession_Abort: command 0x05, F0 50 29 7E F7: status 0x17, then SysExSession_AbortByStep.
SysExSession_Abort:
	ld xbc, (0x60fcd8:24)                               ; FB3244  e2 d8 fc 60 21
	ld (XBC+0x04),0x17                                   ; FB3249  b9 04 00 17
	calr SysExSession_AbortByStep                                      ; FB324D  1e 01 00
	ret                                                  ; FB3250  0e
; SysExSession_AbortByStep: step id (RX record field 3) < 0x12 through SysExSession_AbortTable.
SysExSession_AbortByStep:
	pushw hl                                             ; FB3251  2b
	ld xbc, (0x60fcdc:24)                               ; FB3252  e2 dc fc 60 21
	ld H,(XBC+0x03)                                      ; FB3257  89 03 26
	cp H,0x12                                            ; FB325A  ce cf 12
	jr nc, .LFB3275                                      ; FB325D  6f 16
	ld a, 0x04:opc                                          ; FB325F  21 04
	mul wa, h                                          ; FB3261  ce 41
	extz XWA                                             ; FB3263  e8 12
	add XWA,SysExSession_AbortTable                              ; FB3265  e8 c8 2e fa f4 00
	ld XWA,(XWA)                                         ; FB326B  a0 20
	lda xiy, (.LFB3275:24)                               ; FB326D  f2 75 32 fb 35
	push XIY                                             ; FB3272  3d
	jp (xwa)                                             ; FB3273  b0 d8
.LFB3275:
	popw hl                                              ; FB3275  4b
	ret                                                  ; FB3276  0e
; SysExSession_AbortStep_Idle: step 0, nothing to undo.
SysExSession_AbortStep_Idle:
	ret                                                  ; FB3277  0e
SysExSession_AbortStep_SystemPartMidi:
	call SysExSession_OnAbort_SystemPartMidi                                      ; FB3278  1d a8 7e fb
	ret                                                  ; FB327C  0e
SysExSession_AbortStep_Sound:
	call SysExSession_OnAbort_Sound                                      ; FB327D  1d d2 7e fb
	ret                                                  ; FB3281  0e
SysExSession_AbortStep_Stub:
	call SysExSession_OnAbort_Sound_Nop                                      ; FB3282  1d e4 7e fb
	ret                                                  ; FB3286  0e
SysExSession_AbortStep_Sequencer:
	call SysExSession_OnAbort_Sequencer                                      ; FB3287  1d e5 7e fb
	ret                                                  ; FB328B  0e
; SysExSession_AbortStep_Combination: steps 15-17, a bare ret.
SysExSession_AbortStep_Combination:
	ret                                                  ; FB328C  0e
; SysExSession_RecvBody_Sound: step 5; SysExRx_UnpackBodyToBlock, each full block to CPU 2 through the link (T_Link_SendCommandE7).
SysExSession_RecvBody_Sound:
	link XIZ,0xfff8                                      ; FB328D  ee 0c f8 ff
	pushw hl                                             ; FB3291  2b
	push XIX                                             ; FB3292  3c
	lda xix, (0x60fd32:24)                               ; FB3293  f2 32 fd 60 34
	pushw 0x05                                           ; FB3298  0b 05 00
	pushw 0x03                                           ; FB329B  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB329E  e2 d8 fc 60 21
	push XBC                                             ; FB32A3  39
	call U8Rec16_SetField                                      ; FB32A4  1d 19 62 fb
	call SysExRx_UnpackBodyToBlock                                      ; FB32A8  1d 65 73 fb
	inc 8,XSP                                            ; FB32AC  ef 60
	cp WA,0xffff                                         ; FB32AE  d8 cf ff ff
	jrl z, .LFB3350                                      ; FB32B2  76 9b 00
	ld BC,(XIX+0x08)                                     ; FB32B5  9c 08 21
	cp BC,0x0400                                         ; FB32B8  d9 cf 00 04
	jrl c, .LFB332B                                      ; FB32BC  77 6c 00
	ld C,(XIX+0x0a)                                      ; FB32BF  8c 0a 23
	cp C,0x40                                            ; FB32C2  cb cf 40
	jr c, .LFB32DE                                       ; FB32C5  67 17
	ld C,(XIX+0x0b)                                      ; FB32C7  8c 0b 23
	cp c, 0x03:i3                                          ; FB32CA  cb db
	jr nc, .LFB32DE                                      ; FB32CC  6f 10
	ld XBC,(XIX+0x04)                                    ; FB32CE  ac 04 21
	push XBC                                             ; FB32D1  39
	call T_Link_SendCommand3_WaitTicks                                        ; FB32D2  1d 34 12 f4
	ld (XIX+0x0a),0x00                                   ; FB32D6  bc 0a 00 00
	incm8 0x01, (xix+0x0b)                               ; FB32DA  8c 0b 61
	pop XIY                                              ; FB32DD  5d
.LFB32DE:
	ld XBC,(XIX+0x04)                                    ; FB32DE  ac 04 21
	push XBC                                             ; FB32E1  39
	ld XBC,(XIX)                                         ; FB32E2  a4 21
	push XBC                                             ; FB32E4  39
	call T_Link_SendCommandE7                            ; FB32E5  1d 40 12 f4
	subw	(xix+8), 0x0400                      ; FB32E9  9c 08 3a 00 04
	ld XBC,0x00000400                                    ; FB32EE  41 00 04 00 00
	add (XIX+0x04),XBC                                   ; FB32F3  ac 04 89
	ld HL,(XIX+0x08)                                     ; FB32F6  9c 08 23
	inc 8,XSP                                            ; FB32F9  ef 60
	cp hl, 0x00:i3                                         ; FB32FB  db d8
	jr z, .LFB331B                                       ; FB32FD  66 1c
	ld XBC,(XIX)                                         ; FB32FF  a4 21
	ld (xiz-4), xbc                                      ; FB3301  be fc 61
	add XBC,0x00000400                                   ; FB3304  e9 c8 00 04 00 00
	ld (xiz-8), xbc                                      ; FB330A  be f8 61
	pushw hl                                             ; FB330D  2b
	ld xwa, (xiz-4)                                      ; FB330E  ae fc 20
	push XWA                                             ; FB3311  38
	push XBC                                             ; FB3312  39
	call MemCopyWords_Copy                                      ; FB3313  1d ce 81 fb
	inc 8,XSP                                            ; FB3317  ef 60
	inc 2,XSP                                            ; FB3319  ef 62
.LFB331B:
	ld XBC,0x00000400                                    ; FB331B  41 00 04 00 00
	sub (0x60fd18:24), xbc                           ; FB3320  e2 18 fd 60 a9
	incw 0x01, (xix+0x0c)                                ; FB3325  9c 0c 61
	incm8 0x01, (xix+0x0a)                               ; FB3328  8c 0a 61
.LFB332B:
	pushw 0x0f                                           ; FB332B  0b 0f 00
	ld xbc, (0x60fcd8:24)                               ; FB332E  e2 d8 fc 60 21
	push XBC                                             ; FB3333  39
	call U8Rec16_GetField                                      ; FB3334  1d d3 62 fb
	inc 6,XSP                                            ; FB3338  ef 66
	cp a, 0x00:i3                                          ; FB333A  c9 d8
	jr nz, .LFB3350                                      ; FB333C  6e 12
	pushw 0x06                                           ; FB333E  0b 06 00
	pushw 0x03                                           ; FB3341  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB3344  e2 d8 fc 60 21
	push XBC                                             ; FB3349  39
	call U8Rec16_SetField                                      ; FB334A  1d 19 62 fb
	inc 8,XSP                                            ; FB334E  ef 60
.LFB3350:
	pop XIX                                              ; FB3350  5c
	popw hl                                              ; FB3351  4b
	unlk XIZ                                             ; FB3352  ee 0d
	ret                                                  ; FB3354  0e
; SysExTx_Tempo: the tempo transmitter; bounds the value to 0x0028..0x012C like the receiver 0xFB33FE (README, tempo section).
SysExTx_Tempo:
	link XIZ,0xfffd                                      ; FB3355  ee 0c fd ff
	push XIX                                             ; FB3359  3c
	lda xix, (0x60f800:24)                               ; FB335A  f2 00 f8 60 34
	push XIX                                             ; FB335F  3c
	ldw bc, 0x03                                         ; FB3360  31 03 00
	lda xiy, (MidiSysEx_Tail3Init:24)                    ; FB3363  f2 76 fa f4 35
	lda xix, (xiz-3)                                     ; FB3368  be fd 34
	ldir85                                               ; FB336B  85 11
	pop XIX                                              ; FB336D  5c
	pushw 0x05                                           ; FB336E  0b 05 00
	call SysEx_FeatureWordForVariant                                      ; FB3371  1d f5 5f fb
	popw bc                                              ; FB3375  49
	cp WA,0xffff                                         ; FB3376  d8 cf ff ff
	jrl z, .LFB33FA                                      ; FB337A  76 7d 00
	ld c, (0x0922:16)                                   ; FB337D  c1 22 09 23
	and C,0x01                                           ; FB3381  cb cc 01
	jrl nz, .LFB33FA                                     ; FB3384  7e 73 00
	cp	(UI_ScreenLatch:16), 0x79                            ; FB3387  c1 7a 20 3f 79
	jrl z, .LFB33FA                                      ; FB338C  76 6b 00
	ld c, (MidiCfg_ModeBits:16)                                   ; FB338F  c1 32 7f 23
	and C,0x04                                           ; FB3393  cb cc 04
	jr nz, .LFB33FA                                      ; FB3396  6e 62
	ld c, (MidiFilter_Exclusive:16)                                   ; FB3398  c1 38 7f 23
	and C,0x08                                           ; FB339C  cb cc 08
	jr z, .LFB33FA                                       ; FB339F  66 59
	pushw 0x03                                           ; FB33A1  0b 03 00
	lda xbc, (0xf4fee3:24)                               ; FB33A4  f2 e3 fe f4 31
	push XBC                                             ; FB33A9  39
	call SysExTx_AppendAndSendOnF7                                      ; FB33AA  1d 7f 6e fb
	ld BC,(XIX)                                          ; FB33AE  94 21
	inc 6,XSP                                            ; FB33B0  ef 66
	cp BC,0x0028                                         ; FB33B2  d9 cf 28 00
	jr nc, .LFB33BE                                      ; FB33B6  6f 06
	ldw	(xix), 0x0028                                ; FB33B8  b4 02 28 00
	jr .LFB33CA                                          ; FB33BC  68 0c
.LFB33BE:
	ld BC,(XIX)                                          ; FB33BE  94 21
	cp BC,0x012c                                         ; FB33C0  d9 cf 2c 01
	jr ule, .LFB33CA                                     ; FB33C4  63 04
	ldw	(xix), 0x012c                                ; FB33C6  b4 02 2c 01
.LFB33CA:
	ld BC,(XIX)                                          ; FB33CA  94 21
	and C,0x0f                                           ; FB33CC  cb cc 0f
	ld (xiz-3), c                                        ; FB33CF  be fd 43
	ld BC,(XIX)                                          ; FB33D2  94 21
	srl bc, 0x04                                         ; FB33D4  d9 ef 04
	and C,0x1f                                           ; FB33D7  cb cc 1f
	ld (xiz-2), c                                        ; FB33DA  be fe 43
	pushw 0x03                                           ; FB33DD  0b 03 00
	lda xbc, (xiz-3)                                     ; FB33E0  be fd 31
	push XBC                                             ; FB33E3  39
	call SysExTx_Append                                      ; FB33E4  1d 24 6f fb
	ld xbc, (0x60fc88:24)                               ; FB33E8  e2 88 fc 60 21
	push XBC                                             ; FB33ED  39
	call SysExTx_SendFrameBothPorts                                      ; FB33EE  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB33F2  1d 81 80 fb
	inc 8,XSP                                            ; FB33F6  ef 60
	inc 2,XSP                                            ; FB33F8  ef 62
.LFB33FA:
	pop XIX                                              ; FB33FA  5c
	unlk XIZ                                             ; FB33FB  ee 0d
	ret                                                  ; FB33FD  0e
; SysExCmd_TempoReceive: command 0x09, F0 50 25 (tempo; sysex-probes/sysex_command_map.py), gated by SysEx_FeatureWordForVariant(5).
SysExCmd_TempoReceive:
	pushw hl                                             ; FB33FE  2b
	pushw de                                             ; FB33FF  2a
	pushw 0x05                                           ; FB3400  0b 05 00
	call SysEx_FeatureWordForVariant                                      ; FB3403  1d f5 5f fb
	popw bc                                              ; FB3407  49
	cp WA,0xffff                                         ; FB3408  d8 cf ff ff
	jr z, .LFB3468                                       ; FB340C  66 5a
	cp	(UI_ScreenLatch:16), 0x79                            ; FB340E  c1 7a 20 3f 79
	jr z, .LFB3468                                       ; FB3413  66 53
	ld c, (MidiCfg_ModeBits:16)                                   ; FB3415  c1 32 7f 23
	and C,0x04                                           ; FB3419  cb cc 04
	jr nz, .LFB3468                                      ; FB341C  6e 4a
	ld c, (MidiFilter_Exclusive:16)                                   ; FB341E  c1 38 7f 23
	and C,0x08                                           ; FB3422  cb cc 08
	jr z, .LFB3468                                       ; FB3425  66 41
	ld xbc, (0x60fc80:24)                               ; FB3427  e2 80 fc 60 21
	ld L,(XBC+0x11)                                      ; FB342C  89 11 27
	ld H,(XBC+0x12)                                      ; FB342F  89 12 26
	ld A,L                                               ; FB3432  cf 89
	and A,0xf0                                           ; FB3434  c9 cc f0
	jr z, .LFB3440                                       ; FB3437  66 07
	ld A,H                                               ; FB3439  ce 89
	and A,0xe0                                           ; FB343B  c9 cc e0
	jr nz, .LFB3468                                      ; FB343E  6e 28
.LFB3440:
	ld C,H                                               ; FB3440  ce 8b
	extz BC                                              ; FB3442  d9 12
	ld DE,BC                                             ; FB3444  d9 8a
	sll de, 0x04                                         ; FB3446  da ee 04
	ld C,L                                               ; FB3449  cf 8b
	extz BC                                              ; FB344B  d9 12
	ld HL,BC                                             ; FB344D  d9 8b
	or BC,DE                                             ; FB344F  da e1
	ld HL,BC                                             ; FB3451  d9 8b
	cp BC,0x0028                                         ; FB3453  d9 cf 28 00
	jr c, .LFB3468                                       ; FB3457  67 0f
	cp BC,0x012c                                         ; FB3459  d9 cf 2c 01
	jr ugt, .LFB3468                                     ; FB345D  6b 09
	pushw bc                                             ; FB345F  29
	call SysExRx_ApplyTempo                                      ; FB3460  1d ed 57 fb
	calr Queue2C00_RecordAndDrainPassB                                      ; FB3464  1e 04 00
	popw bc                                              ; FB3467  49
.LFB3468:
	popw de                                              ; FB3468  4a
	popw hl                                              ; FB3469  4b
	ret                                                  ; FB346A  0e
; Queue2C00_RecordAndDrainPassB: (0x60F000) := 0, then SeqBuf_RecordQueuedEvents (T_F41F14) and Queue2C00_DrainPassB:
;   the change SysExRx_ApplyTempo just queued at 0x2C00 is encoded into the sequencer ring and run through pass B.
;   SysExCmd_TempoReceive's last step; SysExCmd_ParamWrite does the same inline with DrainPassAB. Basis: caller + body
;   + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
Queue2C00_RecordAndDrainPassB:
	ldw (0x60f000:24), 0x00                             ; FB346B  f2 00 f0 60 02 00 00
	push XDE                                             ; FB3472  3a
	push XHL                                             ; FB3473  3b
	push XIX                                             ; FB3474  3c
	push XIZ                                             ; FB3475  3e
	call T_F41F14                                        ; FB3476  1d 14 1f f4
	call T_Queue2C00_DrainPassB                          ; FB347A  1d 38 00 f4
	pop XIZ                                              ; FB347E  5e
	pop XIX                                              ; FB347F  5c
	pop XHL                                              ; FB3480  5b
	pop XDE                                              ; FB3481  5a
	ret                                                  ; FB3482  0e
; SysExCmd_ThirdRegionWrite: command 0x17, a 2C write to address byte 6 = 10/18/19 (sysex-probes/sysex_param_space.py: prom_b SysExToneImage_WriteByte).
SysExCmd_ThirdRegionWrite:
	ld xbc, (0x60fc80:24)                               ; FB3483  e2 80 fc 60 21
	add XBC,0x0000000e                                   ; FB3488  e9 c8 0e 00 00 00
	push XBC                                             ; FB348E  39
	call T_SysExToneImage_WriteByte                                        ; FB348F  1d 58 12 f4
	pop XBC                                              ; FB3493  59
	ret                                                  ; FB3494  0e
; SysExCmd_ThirdRegionRequest: command 0x19, the 2B request twin of SysExCmd_ThirdRegionWrite (prom_b SysExThirdRegion_AcceptRequest).
SysExCmd_ThirdRegionRequest:
	ld xbc, (0x60fc80:24)                               ; FB3495  e2 80 fc 60 21
	add XBC,0x0000000e                                   ; FB349A  e9 c8 0e 00 00 00
	push XBC                                             ; FB34A0  39
	call T_SysExThirdRegion_AcceptRequest                                        ; FB34A1  1d 54 12 f4
	pop XIY                                              ; FB34A5  5d
	cp wa, 0x00:i3                                         ; FB34A6  d8 d8
	jr z, .LFB34C9                                       ; FB34A8  66 1f
	pushw 0x05                                           ; FB34AA  0b 05 00
	lda xbc, (0xf4fec8:24)                               ; FB34AD  f2 c8 fe f4 31
	push XBC                                             ; FB34B2  39
	call SysExTx_Append                                      ; FB34B3  1d 24 6f fb
	ld xbc, (0x60fc88:24)                               ; FB34B7  e2 88 fc 60 21
	push XBC                                             ; FB34BC  39
	call SysExTx_SendFrameBothPorts                                      ; FB34BD  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB34C1  1d 81 80 fb
	inc 8,XSP                                            ; FB34C5  ef 60
	inc 2,XSP                                            ; FB34C7  ef 62
.LFB34C9:
	ret                                                  ; FB34C9  0e
; SysExCmd_ParamWrite: command 0x18, F0 50 2C one-parameter write: SysExParam_Set_DispatchGroup, then the (0x60F000) follow-up.
SysExCmd_ParamWrite:
	calr SysExParam_Set_DispatchGroup                                      ; FB34CA  1e 24 00
	cpw	(0x60f000:24), 0x0000                        ; FB34CD  d2 00 f0 60 3f 00 00
	jr z, .LFB34F0                                       ; FB34D4  66 1a
	push XDE                                             ; FB34D6  3a
	push XHL                                             ; FB34D7  3b
	push XIX                                             ; FB34D8  3c
	push XIZ                                             ; FB34D9  3e
	ld bc, (0x60f000:24)                                ; FB34DA  d2 00 f0 60 21
	ld (0x60f002:24), bc                                ; FB34DF  f2 02 f0 60 51
	call T_F41F14                                        ; FB34E4  1d 14 1f f4
	call T_Queue2C00_DrainPassAB                         ; FB34E8  1d 18 00 f4
	pop XIZ                                              ; FB34EC  5e
	pop XIX                                              ; FB34ED  5c
	pop XHL                                              ; FB34EE  5b
	pop XDE                                              ; FB34EF  5a
.LFB34F0:
	ret                                                  ; FB34F0  0e
; SysExParam_Set_DispatchGroup: command 0x18 (F0 50 2C, a parameter WRITE): group = parse field 1, 1..7, through SysExParam_Set_GroupTable.
;   Groups by address byte 7 (sysex-probes/sysex_param_space.py): 1 = 00/01, 2 = 08, 3 = 10/11, 4 = none, 5 and 6 = the part blocks 20.., 7 = 60.
SysExParam_Set_DispatchGroup:
	pushw 0x01                                           ; FB34F1  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB34F4  e2 d8 fc 60 21
	push XBC                                             ; FB34F9  39
	call U8Rec16_GetField                                      ; FB34FA  1d d3 62 fb
	extz WA                                              ; FB34FE  d8 12
	inc 6,XSP                                            ; FB3500  ef 66
	extz XWA                                             ; FB3502  e8 12
	dec 1,WA                                             ; FB3504  d8 69
	cp wa, 0x06:i3                                         ; FB3506  d8 de
	jr ugt, .LFB3554                                         ; FB3508  6b 4a
	sll wa, 0x02                                         ; FB350A  d8 ee 02
	add XWA,SysExParam_Set_GroupTable                             ; FB350D  e8 c8 17 35 fb 00
	ld XWA,(XWA)                                         ; FB3513  a0 20
	jp (xwa)                                             ; FB3515  b0 d8

; ---------------------------------------------------------------------
; SysExParam_Set_GroupTable -- 7 LE32 code addresses, an INLINE jump table
;
; Read by: ONE site, `add XWA,0x00FB3517 / ld XWA,(XWA) / jp (XWA)` at
;          0xFB350D-0xFB3515.
; ENTRY COUNT 7: `dec 1,WA / cps wa,0x06 / jr ugt` at 0xFB3504 admits 0..6, so
;          the index is 1-based in the caller.  ★ LAST-ENTRY TEST: entry 6 is
;          0x00FB3551 and 0xFB3517 + 7*4 = 0xFB3533 = entry 0's target.
; Evidence: the base is named by exactly one instruction, the `add Xrr,imm32`
;          quoted above, and the ENTRY COUNT is the ROM's own bound on the
;          index, not a guess at where the values stop looking like
;          addresses; the LAST-ENTRY TEST above is what makes the two agree.
; Unknown:  what the arms DO.  A jump table names its targets, not its
;          operations.
; ---------------------------------------------------------------------
SysExParam_Set_GroupTable:
	.long SysExParam_Set_Group1                                 ; FB3517  [  0]
	.long SysExParam_Set_Group2                                 ; FB351B  [  1]
	.long SysExParam_Set_Group3                                 ; FB351F  [  2]
	.long SysExParam_Set_Group4                                 ; FB3523  [  3]
	.long SysExParam_Set_Group5                                 ; FB3527  [  4]
	.long SysExParam_Set_Group6                                 ; FB352B  [  5]
	.long SysExParam_Set_Group7                                 ; FB352F  [  6]
SysExParam_Set_Group1:   ; entry: named by 1 `.long` operand, first at 0xFB3517
	calr SysExParam_Set_Area00_01                                      ; FB3533  1e 1f 00
	jr .LFB3554                                          ; FB3536  68 1c
SysExParam_Set_Group2:   ; entry: named by 1 `.long` operand, first at 0xFB351B
	calr SysExParam_Set_Area08                                      ; FB3538  1e 6e 00
	jr .LFB3554                                          ; FB353B  68 17
SysExParam_Set_Group3:   ; entry: named by 1 `.long` operand, first at 0xFB351F
	calr SysExParam_Set_Area10_11                                      ; FB353D  1e bc 00
	jr .LFB3554                                          ; FB3540  68 12
; SysExParam_Set_Group4: Arm [3] of SysExParam_Set_GroupTable (parameter WRITE, F0 50 2C, group 4): calls an empty
;   `ret` (SysExParam_Set_Area10_11_Nop) and returns -- group 4 owns no address area (the dispatcher header: '4 = none'). Basis:
;   table index + body. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
SysExParam_Set_Group4:   ; entry: named by 1 `.long` operand, first at 0xFB3523
	calr SysExParam_Set_Area10_11_Nop                                      ; FB3542  1e 0b 01
	jr .LFB3554                                          ; FB3545  68 0d
SysExParam_Set_Group5:   ; entry: named by 1 `.long` operand, first at 0xFB3527
	calr SysExParam_Set_PartGroup5                                      ; FB3547  1e 07 01
	jr .LFB3554                                          ; FB354A  68 08
SysExParam_Set_Group6:   ; entry: named by 1 `.long` operand, first at 0xFB352B
	calr SysExParam_Set_PartGroup6                                      ; FB354C  1e 56 01
	jr .LFB3554                                          ; FB354F  68 03
SysExParam_Set_Group7:   ; entry: named by 1 `.long` operand, first at 0xFB352F
	calr SysExParam_Set_Area60                                      ; FB3551  1e a5 01
.LFB3554:
	ret                                                  ; FB3554  0e
; SysExParam_Set_Area00_01: index = field 2 < 0x17; desc = PtrTable_F51E8E[index]; if SysExParam_CheckConditions(desc) passes, call desc->+0x14.
SysExParam_Set_Area00_01:
	link XIZ,0xfffc                                      ; FB3555  ee 0c fc ff
	pushw hl                                             ; FB3559  2b
	push XIX                                             ; FB355A  3c
	pushw 0x02                                           ; FB355B  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB355E  e2 d8 fc 60 21
	push XBC                                             ; FB3563  39
	call U8Rec16_GetField                                      ; FB3564  1d d3 62 fb
	ld H,A                                               ; FB3568  c9 8e
	inc 6,XSP                                            ; FB356A  ef 66
	cp A,0x17                                            ; FB356C  c9 cf 17
	jr nc, .LFB35A4                                      ; FB356F  6f 33
	mul A,0x04                                           ; FB3571  c9 08 04
	extz XWA                                             ; FB3574  e8 12
	ld XIX,XWA                                           ; FB3576  e8 8c
	add XWA,PtrTable_F51E8E                              ; FB3578  e8 c8 8e 1e f5 00
	ld XBC,(XWA)                                         ; FB357E  a0 21
	push XBC                                             ; FB3580  39
	calr SysExParam_CheckConditions                                          ; FB3581  1e e2 1a
	pop XIY                                              ; FB3584  5d
	cp WA,0xffff                                         ; FB3585  d8 cf ff ff
	jr z, .LFB35A4                                       ; FB3589  66 19
	lda xbc, (PtrTable_F51E8E:24)                        ; FB358B  f2 8e 1e f5 31
	add XBC,XIX                                          ; FB3590  ec 81
	ld XWA,(XBC)                                         ; FB3592  a1 20
	ld (xiz-4), xwa                                      ; FB3594  be fc 60
	push XWA                                             ; FB3597  38
	ld XBC,(XWA+0x14)                                    ; FB3598  a8 14 21
	lda xiy, (.LFB35A3:24)                               ; FB359B  f2 a3 35 fb 35
	push XIY                                             ; FB35A0  3d
	jp (xbc)                                             ; FB35A1  b1 d8
.LFB35A3:
	pop XIY                                              ; FB35A3  5d
.LFB35A4:
	pop XIX                                              ; FB35A4  5c
	popw hl                                              ; FB35A5  4b
	unlk XIZ                                             ; FB35A6  ee 0d
	ret                                                  ; FB35A8  0e
; SysExParam_Set_Area08: as SysExParam_Set_Area00_01 over PtrTable_F51F46, index < 5.
SysExParam_Set_Area08:
	link XIZ,0xfffc                                      ; FB35A9  ee 0c fc ff
	pushw hl                                             ; FB35AD  2b
	push XIX                                             ; FB35AE  3c
	pushw 0x02                                           ; FB35AF  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB35B2  e2 d8 fc 60 21
	push XBC                                             ; FB35B7  39
	call U8Rec16_GetField                                      ; FB35B8  1d d3 62 fb
	ld H,A                                               ; FB35BC  c9 8e
	inc 6,XSP                                            ; FB35BE  ef 66
	cp a, 0x05:i3                                          ; FB35C0  c9 dd
	jr nc, .LFB35F7                                      ; FB35C2  6f 33
	mul A,0x04                                           ; FB35C4  c9 08 04
	extz XWA                                             ; FB35C7  e8 12
	ld XIX,XWA                                           ; FB35C9  e8 8c
	add XWA,PtrTable_F51F46                              ; FB35CB  e8 c8 46 1f f5 00
	ld XBC,(XWA)                                         ; FB35D1  a0 21
	push XBC                                             ; FB35D3  39
	calr SysExParam_CheckConditions                                          ; FB35D4  1e 8f 1a
	pop XIY                                              ; FB35D7  5d
	cp WA,0xffff                                         ; FB35D8  d8 cf ff ff
	jr z, .LFB35F7                                       ; FB35DC  66 19
	lda xbc, (PtrTable_F51F46:24)                        ; FB35DE  f2 46 1f f5 31
	add XBC,XIX                                          ; FB35E3  ec 81
	ld XWA,(XBC)                                         ; FB35E5  a1 20
	ld (xiz-4), xwa                                      ; FB35E7  be fc 60
	push XWA                                             ; FB35EA  38
	ld XBC,(XWA+0x14)                                    ; FB35EB  a8 14 21
	lda xiy, (.LFB35F6:24)                               ; FB35EE  f2 f6 35 fb 35
	push XIY                                             ; FB35F3  3d
	jp (xbc)                                             ; FB35F4  b1 d8
.LFB35F6:
	pop XIY                                              ; FB35F6  5d
.LFB35F7:
	pop XIX                                              ; FB35F7  5c
	popw hl                                              ; FB35F8  4b
	unlk XIZ                                             ; FB35F9  ee 0d
	ret                                                  ; FB35FB  0e
; SysExParam_Set_Area10_11: as SysExParam_Set_Area00_01 over PtrTable_F51F5E, index < 0x19.
SysExParam_Set_Area10_11:
	link XIZ,0xfffc                                      ; FB35FC  ee 0c fc ff
	pushw hl                                             ; FB3600  2b
	push XIX                                             ; FB3601  3c
	pushw 0x02                                           ; FB3602  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB3605  e2 d8 fc 60 21
	push XBC                                             ; FB360A  39
	call U8Rec16_GetField                                      ; FB360B  1d d3 62 fb
	ld H,A                                               ; FB360F  c9 8e
	inc 6,XSP                                            ; FB3611  ef 66
	cp A,0x19                                            ; FB3613  c9 cf 19
	jr nc, .LFB364B                                      ; FB3616  6f 33
	mul A,0x04                                           ; FB3618  c9 08 04
	extz XWA                                             ; FB361B  e8 12
	ld XIX,XWA                                           ; FB361D  e8 8c
	add XWA,PtrTable_F51F5E                              ; FB361F  e8 c8 5e 1f f5 00
	ld XBC,(XWA)                                         ; FB3625  a0 21
	push XBC                                             ; FB3627  39
	calr SysExParam_CheckConditions                                          ; FB3628  1e 3b 1a
	pop XIY                                              ; FB362B  5d
	cp WA,0xffff                                         ; FB362C  d8 cf ff ff
	jr z, .LFB364B                                       ; FB3630  66 19
	lda xbc, (PtrTable_F51F5E:24)                        ; FB3632  f2 5e 1f f5 31
	add XBC,XIX                                          ; FB3637  ec 81
	ld XWA,(XBC)                                         ; FB3639  a1 20
	ld (xiz-4), xwa                                      ; FB363B  be fc 60
	push XWA                                             ; FB363E  38
	ld XBC,(XWA+0x14)                                    ; FB363F  a8 14 21
	lda xiy, (.LFB364A:24)                               ; FB3642  f2 4a 36 fb 35
	push XIY                                             ; FB3647  3d
	jp (xbc)                                             ; FB3648  b1 d8
.LFB364A:
	pop XIY                                              ; FB364A  5d
.LFB364B:
	pop XIX                                              ; FB364B  5c
	popw hl                                              ; FB364C  4b
	unlk XIZ                                             ; FB364D  ee 0d
	ret                                                  ; FB364F  0e
SysExParam_Set_Area10_11_Nop:
	ret                                                  ; FB3650  0e
; SysExParam_Set_PartGroup5: as SysExParam_Set_Area00_01 over PtrTable_F52026, index < 0x13 (18 of a part block's 57 parameters).
SysExParam_Set_PartGroup5:
	link XIZ,0xfffc                                      ; FB3651  ee 0c fc ff
	pushw hl                                             ; FB3655  2b
	push XIX                                             ; FB3656  3c
	pushw 0x02                                           ; FB3657  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB365A  e2 d8 fc 60 21
	push XBC                                             ; FB365F  39
	call U8Rec16_GetField                                      ; FB3660  1d d3 62 fb
	ld H,A                                               ; FB3664  c9 8e
	inc 6,XSP                                            ; FB3666  ef 66
	cp A,0x13                                            ; FB3668  c9 cf 13
	jr nc, .LFB36A0                                      ; FB366B  6f 33
	mul A,0x04                                           ; FB366D  c9 08 04
	extz XWA                                             ; FB3670  e8 12
	ld XIX,XWA                                           ; FB3672  e8 8c
	add XWA,PtrTable_F52026                              ; FB3674  e8 c8 26 20 f5 00
	ld XBC,(XWA)                                         ; FB367A  a0 21
	push XBC                                             ; FB367C  39
	calr SysExParam_CheckConditions                                          ; FB367D  1e e6 19
	pop XIY                                              ; FB3680  5d
	cp WA,0xffff                                         ; FB3681  d8 cf ff ff
	jr z, .LFB36A0                                       ; FB3685  66 19
	lda xbc, (PtrTable_F52026:24)                        ; FB3687  f2 26 20 f5 31
	add XBC,XIX                                          ; FB368C  ec 81
	ld XWA,(XBC)                                         ; FB368E  a1 20
	ld (xiz-4), xwa                                      ; FB3690  be fc 60
	push XWA                                             ; FB3693  38
	ld XBC,(XWA+0x14)                                    ; FB3694  a8 14 21
	lda xiy, (.LFB369F:24)                               ; FB3697  f2 9f 36 fb 35
	push XIY                                             ; FB369C  3d
	jp (xbc)                                             ; FB369D  b1 d8
.LFB369F:
	pop XIY                                              ; FB369F  5d
.LFB36A0:
	pop XIX                                              ; FB36A0  5c
	popw hl                                              ; FB36A1  4b
	unlk XIZ                                             ; FB36A2  ee 0d
	ret                                                  ; FB36A4  0e
; SysExParam_Set_PartGroup6: as SysExParam_Set_Area00_01 over PtrTable_F520BE, index < 0x28 (the other 39).
SysExParam_Set_PartGroup6:
	link XIZ,0xfffc                                      ; FB36A5  ee 0c fc ff
	pushw hl                                             ; FB36A9  2b
	push XIX                                             ; FB36AA  3c
	pushw 0x02                                           ; FB36AB  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB36AE  e2 d8 fc 60 21
	push XBC                                             ; FB36B3  39
	call U8Rec16_GetField                                      ; FB36B4  1d d3 62 fb
	ld H,A                                               ; FB36B8  c9 8e
	inc 6,XSP                                            ; FB36BA  ef 66
	cp A,0x28                                            ; FB36BC  c9 cf 28
	jr nc, .LFB36F4                                      ; FB36BF  6f 33
	mul A,0x04                                           ; FB36C1  c9 08 04
	extz XWA                                             ; FB36C4  e8 12
	ld XIX,XWA                                           ; FB36C6  e8 8c
	add XWA,PtrTable_F520BE                              ; FB36C8  e8 c8 be 20 f5 00
	ld XBC,(XWA)                                         ; FB36CE  a0 21
	push XBC                                             ; FB36D0  39
	calr SysExParam_CheckConditions                                          ; FB36D1  1e 92 19
	pop XIY                                              ; FB36D4  5d
	cp WA,0xffff                                         ; FB36D5  d8 cf ff ff
	jr z, .LFB36F4                                       ; FB36D9  66 19
	lda xbc, (PtrTable_F520BE:24)                        ; FB36DB  f2 be 20 f5 31
	add XBC,XIX                                          ; FB36E0  ec 81
	ld XWA,(XBC)                                         ; FB36E2  a1 20
	ld (xiz-4), xwa                                      ; FB36E4  be fc 60
	push XWA                                             ; FB36E7  38
	ld XBC,(XWA+0x14)                                    ; FB36E8  a8 14 21
	lda xiy, (.LFB36F3:24)                               ; FB36EB  f2 f3 36 fb 35
	push XIY                                             ; FB36F0  3d
	jp (xbc)                                             ; FB36F1  b1 d8
.LFB36F3:
	pop XIY                                              ; FB36F3  5d
.LFB36F4:
	pop XIX                                              ; FB36F4  5c
	popw hl                                              ; FB36F5  4b
	unlk XIZ                                             ; FB36F6  ee 0d
	ret                                                  ; FB36F8  0e
; SysExParam_Set_Area60: as SysExParam_Set_Area00_01 over PtrTable_F521FE, index < 2.
SysExParam_Set_Area60:
	link XIZ,0xfffc                                      ; FB36F9  ee 0c fc ff
	pushw hl                                             ; FB36FD  2b
	push XIX                                             ; FB36FE  3c
	pushw 0x02                                           ; FB36FF  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB3702  e2 d8 fc 60 21
	push XBC                                             ; FB3707  39
	call U8Rec16_GetField                                      ; FB3708  1d d3 62 fb
	ld H,A                                               ; FB370C  c9 8e
	inc 6,XSP                                            ; FB370E  ef 66
	cp a, 0x02:i3                                          ; FB3710  c9 da
	jr nc, .LFB3747                                      ; FB3712  6f 33
	mul A,0x04                                           ; FB3714  c9 08 04
	extz XWA                                             ; FB3717  e8 12
	ld XIX,XWA                                           ; FB3719  e8 8c
	add XWA,PtrTable_F521FE                              ; FB371B  e8 c8 fe 21 f5 00
	ld XBC,(XWA)                                         ; FB3721  a0 21
	push XBC                                             ; FB3723  39
	calr SysExParam_CheckConditions                                          ; FB3724  1e 3f 19
	pop XIY                                              ; FB3727  5d
	cp WA,0xffff                                         ; FB3728  d8 cf ff ff
	jr z, .LFB3747                                       ; FB372C  66 19
	lda xbc, (PtrTable_F521FE:24)                        ; FB372E  f2 fe 21 f5 31
	add XBC,XIX                                          ; FB3733  ec 81
	ld XWA,(XBC)                                         ; FB3735  a1 20
	ld (xiz-4), xwa                                      ; FB3737  be fc 60
	push XWA                                             ; FB373A  38
	ld XBC,(XWA+0x14)                                    ; FB373B  a8 14 21
	lda xiy, (.LFB3746:24)                               ; FB373E  f2 46 37 fb 35
	push XIY                                             ; FB3743  3d
	jp (xbc)                                             ; FB3744  b1 d8
.LFB3746:
	pop XIY                                              ; FB3746  5d
.LFB3747:
	pop XIX                                              ; FB3747  5c
	popw hl                                              ; FB3748  4b
	unlk XIZ                                             ; FB3749  ee 0d
	ret                                                  ; FB374B  0e
; SysExParam_SetPlaceholder: a bare `ret`: the setter of the placeholder descriptor 0xF511F9, index 0 of every descriptor group.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetPlaceholder:
	ret                                                  ; FB374C  0e
; SysExParam_CheckValueWhiteList: walks the six-byte value records at 0xF51E58 and refuses a value not in them (README: the VALUE WHITE-LIST).
SysExParam_CheckValueWhiteList:
	link XIZ,0x0000                                      ; FB374D  ee 0c 00 00
	push XIX                                             ; FB3751  3c
.LFB3752:
	cpw	(xiz+14), 0x0000                             ; FB3752  9e 0e 3f 00 00
	jr z, .LFB3771                                       ; FB3757  66 18
	decm 0x01, (xiz+0x0e)                                ; FB3759  9e 0e 69
	ld XIX,(XIZ+0x0a)                                    ; FB375C  ae 0a 24
	sub XBC,XBC                                          ; FB375F  e9 a1
	inc 1,XBC                                            ; FB3761  e9 61
	add (XIZ+0x0a),XBC                                   ; FB3763  ae 0a 89
	ld A,(XIX)                                           ; FB3766  84 21
	cp (XIZ+0x08),A                                      ; FB3768  8e 08 f9
	jr nz, .LFB3752                                      ; FB376B  6e e5
	sub WA,WA                                            ; FB376D  d8 a0
	jr .LFB3774                                          ; FB376F  68 03
.LFB3771:
	ldw wa, 0xffff                                       ; FB3771  30 ff ff
.LFB3774:
	pop XIX                                              ; FB3774  5c
	unlk XIZ                                             ; FB3775  ee 0d
	ret                                                  ; FB3777  0e
; SysExParam_SetCommonField: the generic COMMON setter: 41 parameters (MASTER TUNING, VELOCITY CURVE ...); fills the record from desc+6 / desc+7.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetCommonField:
	link XIZ,0xfff4                                      ; FB3778  ee 0c f4 ff
	pushw hl                                             ; FB377C  2b
	pushw de                                             ; FB377D  2a
	push XIX                                             ; FB377E  3c
	ld XIX,(XIZ+0x08)                                    ; FB377F  ae 08 24
	ld xbc, (0x60fc80:24)                               ; FB3782  e2 80 fc 60 21
	push XBC                                             ; FB3787  39
	call SysExBuf_ReadNibblePair                                      ; FB3788  1d f3 77 fb
	ld H,A                                               ; FB378C  c9 8e
	ld (xiz-2), a                                        ; FB378E  be fe 41
	ld C,(XIX+0x09)                                      ; FB3791  8c 09 23
	pop XIY                                              ; FB3794  5d
	cp C,H                                               ; FB3795  ce f3
	jrl ugt, .LFB3819                                    ; FB3797  7b 7f 00
	ld H,(XIX+0x0a)                                      ; FB379A  8c 0a 26
	ld l, (xiz-2)                                        ; FB379D  8e fe 27
	cp L,H                                               ; FB37A0  ce f7
	jrl ugt, .LFB3819                                    ; FB37A2  7b 74 00
	ld H,(XIX+0x0e)                                      ; FB37A5  8c 0e 26
	cp H,0xff                                            ; FB37A8  ce cf ff
	jr z, .LFB37E5                                       ; FB37AB  66 38
	cp h, 0x04:i3                                          ; FB37AD  ce dc
	jrl nc, .LFB3819                                     ; FB37AF  7f 67 00
	ld c, 0x06:opc                                          ; FB37B2  23 06
	mul bc, h                                          ; FB37B4  ce 43
	extz XBC                                             ; FB37B6  e9 12
	ld (xiz-8), xbc                                      ; FB37B8  be f8 61
	add XBC,0x00f51e58                                   ; FB37BB  e9 c8 58 1e f5 00
	ld DE,(XBC)                                          ; FB37C1  91 22
	ld xbc, (xiz-8)                                      ; FB37C3  ae f8 21
	inc 2,XBC                                            ; FB37C6  e9 62
	add XBC,0x00f51e58                                   ; FB37C8  e9 c8 58 1e f5 00
	ld XBC,(XBC)                                         ; FB37CE  a1 21
	ld (xiz-12), xbc                                     ; FB37D0  be f4 61
	pushw de                                             ; FB37D3  2a
	push XBC                                             ; FB37D4  39
	ld C,L                                               ; FB37D5  cf 8b
	extz BC                                              ; FB37D7  d9 12
	pushw bc                                             ; FB37D9  29
	calr SysExParam_CheckValueWhiteList                                      ; FB37DA  1e 70 ff
	inc 8,XSP                                            ; FB37DD  ef 60
	cp WA,0xffff                                         ; FB37DF  d8 cf ff ff
	jr z, .LFB3819                                       ; FB37E3  66 34
.LFB37E5:
	ld C,(XIX+0x06)                                      ; FB37E5  8c 06 23
	ld (xiz-4), c                                        ; FB37E8  be fc 43
	ld C,(XIX+0x07)                                      ; FB37EB  8c 07 23
	ld (xiz-3), c                                        ; FB37EE  be fd 43
	ld H,(XIX+0x0b)                                      ; FB37F1  8c 0b 26
	ld c, (xiz-2)                                        ; FB37F4  8e fe 23
	push 0x00                                            ; FB37F7  09 00
	push H                                               ; FB37F9  ce 04
	pushw bc                                             ; FB37FB  29
	call Shl8ByCount                                      ; FB37FC  1d e6 81 fb
	ld L,A                                               ; FB3800  c9 8f
	ld C,(XIX+0x0f)                                      ; FB3802  8c 0f 23
	xor A,C                                              ; FB3805  cb d1
	ld (xiz-2), a                                        ; FB3807  be fe 41
	ld C,(XIX+0x08)                                      ; FB380A  8c 08 23
	ld (xiz-1), c                                        ; FB380D  be ff 43
	lda xbc, (xiz-4)                                     ; FB3810  be fc 31
	push XBC                                             ; FB3813  39
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3814  1d 90 78 fb
	pop XIY                                              ; FB3818  5d
.LFB3819:
	pop XIX                                              ; FB3819  5c
	popw de                                              ; FB381A  4a
	popw hl                                              ; FB381B  4b
	unlk XIZ                                             ; FB381C  ee 0d
	ret                                                  ; FB381E  0e
; SysExParam_SetMainOutEqualizerFreq: setter of MAIN OUT EQUALIZER LOW-FREQ and HIGH-FREQ.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetMainOutEqualizerFreq:
	link XIZ,0xfffa                                      ; FB381F  ee 0c fa ff
	pushw hl                                             ; FB3823  2b
	pushw de                                             ; FB3824  2a
	push XIX                                             ; FB3825  3c
	ld XIX,(XIZ+0x08)                                    ; FB3826  ae 08 24
	ld xbc, (0x60fc80:24)                               ; FB3829  e2 80 fc 60 21
	push XBC                                             ; FB382E  39
	call SysExBuf_ReadNibblePair                                      ; FB382F  1d f3 77 fb
	ld H,A                                               ; FB3833  c9 8e
	ld C,(XIX+0x09)                                      ; FB3835  8c 09 23
	pop XIY                                              ; FB3838  5d
	cp C,A                                               ; FB3839  c9 f3
	jr ugt, .LFB387C                                     ; FB383B  6b 3f
	ld C,(XIX+0x0a)                                      ; FB383D  8c 0a 23
	cp A,C                                               ; FB3840  cb f1
	jr ugt, .LFB387C                                     ; FB3842  6b 38
	extz WA                                              ; FB3844  d8 12
	ld DE,WA                                             ; FB3846  d8 8a
	ld C,(XIX+0x06)                                      ; FB3848  8c 06 23
	ld (xiz-6), c                                        ; FB384B  be fa 43
	ld C,(XIX+0x07)                                      ; FB384E  8c 07 23
	ld (xiz-5), c                                        ; FB3851  be fb 43
	ld C,(XIX+0x0b)                                      ; FB3854  8c 0b 23
	pushw bc                                             ; FB3857  29
	pushw de                                             ; FB3858  2a
	call Shl16ByCount                                      ; FB3859  1d 07 82 fb
	ld (xiz-4), wa                                       ; FB385D  be fc 50
	ld C,(XIX+0x08)                                      ; FB3860  8c 08 23
	extz BC                                              ; FB3863  d9 12
	ld DE,BC                                             ; FB3865  d9 8a
	ld A,(XIX+0x0b)                                      ; FB3867  8c 0b 21
	pushw wa                                             ; FB386A  28
	pushw bc                                             ; FB386B  29
	call Shl16ByCount                                      ; FB386C  1d 07 82 fb
	ld (xiz-2), wa                                       ; FB3870  be fe 50
	lda xbc, (xiz-6)                                     ; FB3873  be fa 31
	push XBC                                             ; FB3876  39
	call IndexedTable_MergeMaskedWordAndPost                                      ; FB3877  1d 1c 79 fb
	pop XIY                                              ; FB387B  5d
.LFB387C:
	pop XIX                                              ; FB387C  5c
	popw de                                              ; FB387D  4a
	popw hl                                              ; FB387E  4b
	unlk XIZ                                             ; FB387F  ee 0d
	ret                                                  ; FB3881  0e
; SysExParam_SetMemoryProtect: setter of SOUND MEMORY PROTECT and COMBINATION MEMORY PROTECT (the pair setter: target from 0xF51E58).
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetMemoryProtect:
	link XIZ,0xfffc                                      ; FB3882  ee 0c fc ff
	pushw hl                                             ; FB3886  2b
	push XIX                                             ; FB3887  3c
	ld XIX,(XIZ+0x08)                                    ; FB3888  ae 08 24
	ld xbc, (0x60fc80:24)                               ; FB388B  e2 80 fc 60 21
	push XBC                                             ; FB3890  39
	call SysExBuf_ReadNibblePair                                      ; FB3891  1d f3 77 fb
	ld H,A                                               ; FB3895  c9 8e
	ld C,(XIX+0x09)                                      ; FB3897  8c 09 23
	pop XIY                                              ; FB389A  5d
	cp C,A                                               ; FB389B  c9 f3
	jr ugt, .LFB38DF                                     ; FB389D  6b 40
	ld C,(XIX+0x0a)                                      ; FB389F  8c 0a 23
	cp A,C                                               ; FB38A2  cb f1
	jr ugt, .LFB38DF                                     ; FB38A4  6b 39
	ld L,(XIX+0x0e)                                      ; FB38A6  8c 0e 27
	cp l, 0x04:i3                                          ; FB38A9  cf dc
	jr nc, .LFB38DF                                      ; FB38AB  6f 32
	ld c, 0x06:opc                                          ; FB38AD  23 06
	mul bc, l                                          ; FB38AF  cf 43
	extz XBC                                             ; FB38B1  e9 12
	inc 2,XBC                                            ; FB38B3  e9 62
	add XBC,0x00f51e58                                   ; FB38B5  e9 c8 58 1e f5 00
	ld XBC,(XBC)                                         ; FB38BB  a1 21
	ld (xiz-4), xbc                                      ; FB38BD  be fc 61
	ld W,(XIX+0x08)                                      ; FB38C0  8c 08 20
; (sub_FB38C3 removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	cpl W                                                ; FB38C3  c8 06
	and (XBC),W                                          ; FB38C5  81 c8
	ld xbc, (xiz-4)                                      ; FB38C7  ae fc 21
	ld L,(XBC)                                           ; FB38CA  81 27
	ld A,(XIX+0x0b)                                      ; FB38CC  8c 0b 21
	pushw wa                                             ; FB38CF  28
	push 0x00                                            ; FB38D0  09 00
	push H                                               ; FB38D2  ce 04
	call Shl8ByCount                                      ; FB38D4  1d e6 81 fb
	or A,L                                               ; FB38D8  cf e1
	ld xbc, (xiz-4)                                      ; FB38DA  ae fc 21
	ld (XBC),A                                           ; FB38DD  b1 41
.LFB38DF:
	pop XIX                                              ; FB38DF  5c
	popw hl                                              ; FB38E0  4b
	unlk XIZ                                             ; FB38E1  ee 0d
	ret                                                  ; FB38E3  0e
; SysExParam_SetPartField: the generic PART setter: 49 parameters (VOLUME, EFFECT1 SEND, REVERB SEND, PANPOT ...); fills the record from desc+6 / desc+7 and ORs the part in.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetPartField:
	link XIZ,0xfff4                                      ; FB38E4  ee 0c f4 ff
	pushw hl                                             ; FB38E8  2b
	pushw de                                             ; FB38E9  2a
	push XIX                                             ; FB38EA  3c
	lda xix, (xiz-4)                                     ; FB38EB  be fc 34
	ld xbc, (0x60fc80:24)                               ; FB38EE  e2 80 fc 60 21
	push XBC                                             ; FB38F3  39
	call SysExBuf_ReadNibblePair                                      ; FB38F4  1d f3 77 fb
	ld H,A                                               ; FB38F8  c9 8e
	ld (XIX+0x02),A                                      ; FB38FA  bc 02 41
	ld XBC,(XIZ+0x08)                                    ; FB38FD  ae 08 21
	ld A,(XBC+0x09)                                      ; FB3900  89 09 21
	pop XIY                                              ; FB3903  5d
	cp A,H                                               ; FB3904  ce f1
	jrl ugt, .LFB399E                                    ; FB3906  7b 95 00
	ld H,(XBC+0x0a)                                      ; FB3909  89 0a 26
	ld L,(XIX+0x02)                                      ; FB390C  8c 02 27
	cp L,H                                               ; FB390F  ce f7
	jrl ugt, .LFB399E                                    ; FB3911  7b 8a 00
	ld H,(XBC+0x0e)                                      ; FB3914  89 0e 26
	cp H,0xff                                            ; FB3917  ce cf ff
	jr z, .LFB3954                                       ; FB391A  66 38
	cp h, 0x04:i3                                          ; FB391C  ce dc
	jrl nc, .LFB399E                                     ; FB391E  7f 7d 00
	ld a, 0x06:opc                                          ; FB3921  21 06
	mul wa, h                                          ; FB3923  ce 41
	extz XWA                                             ; FB3925  e8 12
	ld (xiz-8), xwa                                      ; FB3927  be f8 60
	add XWA,0x00f51e58                                   ; FB392A  e8 c8 58 1e f5 00
	ld DE,(XWA)                                          ; FB3930  90 22
	ld xwa, (xiz-8)                                      ; FB3932  ae f8 20
	inc 2,XWA                                            ; FB3935  e8 62
	add XWA,0x00f51e58                                   ; FB3937  e8 c8 58 1e f5 00
	ld XWA,(XWA)                                         ; FB393D  a0 20
	ld (xiz-12), xwa                                     ; FB393F  be f4 60
	pushw de                                             ; FB3942  2a
	push XWA                                             ; FB3943  38
	ld A,L                                               ; FB3944  cf 89
	extz WA                                              ; FB3946  d8 12
	pushw wa                                             ; FB3948  28
	calr SysExParam_CheckValueWhiteList                                      ; FB3949  1e 01 fe
	inc 8,XSP                                            ; FB394C  ef 60
	cp WA,0xffff                                         ; FB394E  d8 cf ff ff
	jr z, .LFB399E                                       ; FB3952  66 4a
.LFB3954:
	ld XBC,(XIZ+0x08)                                    ; FB3954  ae 08 21
	ld A,(XBC+0x06)                                      ; FB3957  89 06 21
	ld (XIX),A                                           ; FB395A  b4 41
	pushw 0x0a                                           ; FB395C  0b 0a 00
	ld xbc, (0x60fcd8:24)                               ; FB395F  e2 d8 fc 60 21
	push XBC                                             ; FB3964  39
	call U8Rec16_GetField                                      ; FB3965  1d d3 62 fb
	sub A,0x20                                           ; FB3969  c9 ca 20
	or (XIX),A                                           ; FB396C  84 e9
	ld XBC,(XIZ+0x08)                                    ; FB396E  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3971  89 07 21
	ld (XIX+0x01),A                                      ; FB3974  bc 01 41
	ld XBC,(XIZ+0x08)                                    ; FB3977  ae 08 21
	ld H,(XBC+0x0b)                                      ; FB397A  89 0b 26
	ld A,(XIX+0x02)                                      ; FB397D  8c 02 21
	push 0x00                                            ; FB3980  09 00
	push H                                               ; FB3982  ce 04
	pushw wa                                             ; FB3984  28
	call Shl8ByCount                                      ; FB3985  1d e6 81 fb
	ld (XIX+0x02),A                                      ; FB3989  bc 02 41
	ld XBC,(XIZ+0x08)                                    ; FB398C  ae 08 21
	ld A,(XBC+0x08)                                      ; FB398F  89 08 21
	ld (XIX+0x03),A                                      ; FB3992  bc 03 41
; (sub_FB3995 removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	push XIX                                             ; FB3995  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3996  1d 90 78 fb
	inc 8,XSP                                            ; FB399A  ef 60
	inc 2,XSP                                            ; FB399C  ef 62
.LFB399E:
	pop XIX                                              ; FB399E  5c
	popw de                                              ; FB399F  4a
	popw hl                                              ; FB39A0  4b
	unlk XIZ                                             ; FB39A1  ee 0d
	ret                                                  ; FB39A3  0e
; SysExParam_SetProgramChangeAndBank: setter of PROGRAM CHANGE & BANK.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetProgramChangeAndBank:
	link XIZ,0xfffa                                      ; FB39A4  ee 0c fa ff
	pushw hl                                             ; FB39A8  2b
	pushw de                                             ; FB39A9  2a
	push XIX                                             ; FB39AA  3c
	lda xix, (xiz-4)                                     ; FB39AB  be fc 34
	ld xbc, (0x60fc80:24)                               ; FB39AE  e2 80 fc 60 21
	push XBC                                             ; FB39B3  39
	call SysExBuf_ReadNibblePair                                      ; FB39B4  1d f3 77 fb
	ld D,A                                               ; FB39B8  c9 8c
	ld XBC,(XIZ+0x08)                                    ; FB39BA  ae 08 21
	ld W,(XBC+0x09)                                      ; FB39BD  89 09 20
	pop XIY                                              ; FB39C0  5d
	cp W,A                                               ; FB39C1  c9 f0
	jrl ugt, .LFB3ABE                                    ; FB39C3  7b f8 00
	ld W,(XBC+0x0a)                                      ; FB39C6  89 0a 20
	cp A,W                                               ; FB39C9  c8 f1
	jrl ugt, .LFB3ABE                                    ; FB39CB  7b f0 00
	ld xwa, (0x60fc80:24)                               ; FB39CE  e2 80 fc 60 20
	push XWA                                             ; FB39D3  38
	call SysExBuf_ReadNibblePair                                      ; FB39D4  1d f3 77 fb
	extz WA                                              ; FB39D8  d8 12
	sll wa, 0x08                                         ; FB39DA  d8 ee 08
	ld (xiz-6), wa                                       ; FB39DD  be fa 50
	ld xbc, (0x60fc80:24)                               ; FB39E0  e2 80 fc 60 21
	push XBC                                             ; FB39E5  39
	call SysExBuf_ReadNibblePair                                      ; FB39E6  1d f3 77 fb
	extz WA                                              ; FB39EA  d8 12
	ld HL,WA                                             ; FB39EC  d8 8b
	or	hl, (xiz-6)                                  ; FB39EE  9e fa e3
	inc 8,XSP                                            ; FB39F1  ef 60
	cp HL,0x3fff                                         ; FB39F3  db cf ff 3f
	jrl ugt, .LFB3ABE                                    ; FB39F7  7b c4 00
; (sub_FB39FA removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	ld BC,HL                                             ; FB39FA  db 89
	srl bc, 0x04                                         ; FB39FC  d9 ef 04
	and BC,0x003f                                        ; FB39FF  d9 cc 3f 00
	ld (xiz-6), bc                                       ; FB3A03  be fa 51
	pushw 0x0a                                           ; FB3A06  0b 0a 00
	ld xwa, (0x60fcd8:24)                               ; FB3A09  e2 d8 fc 60 20
	push XWA                                             ; FB3A0E  38
	call U8Rec16_GetField                                      ; FB3A0F  1d d3 62 fb
	ld E,A                                               ; FB3A13  c9 8d
	sub E,0x20                                           ; FB3A15  cd ca 20
	ld XBC,(XIZ+0x08)                                    ; FB3A18  ae 08 21
	ld H,(XBC+0x06)                                      ; FB3A1B  89 06 26
	ld A,E                                               ; FB3A1E  cd 89
	or H,A                                               ; FB3A20  c9 e6
	ld (XIX),H                                           ; FB3A22  b4 46
	ld (XIX+0x01),0x01                                   ; FB3A24  bc 01 00 01
	ld e, (xiz-6)                                        ; FB3A28  8e fa 25
	ld (XIX+0x02),E                                      ; FB3A2B  bc 02 45
	ld (XIX+0x03),0x7f                                   ; FB3A2E  bc 03 00 7f
; (sub_FB3A32 removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	push XIX                                             ; FB3A32  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3A33  1d 90 78 fb
	ld (XIX),H                                           ; FB3A37  b4 46
	ld XBC,(XIZ+0x08)                                    ; FB3A39  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3A3C  89 07 21
	ld (XIX+0x01),A                                      ; FB3A3F  bc 01 41
	ld (XIX+0x02),D                                      ; FB3A42  bc 02 44
	ld XBC,(XIZ+0x08)                                    ; FB3A45  ae 08 21
	ld A,(XBC+0x08)                                      ; FB3A48  89 08 21
	ld (XIX+0x03),A                                      ; FB3A4B  bc 03 41
	push XIX                                             ; FB3A4E  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3A4F  1d 90 78 fb
	ld (SoundConv_Arg0:24), d                                 ; FB3A53  f2 10 f0 60 44
	ld (SoundConv_Arg1:24), e                                 ; FB3A58  f2 11 f0 60 45
	ld (SoundConv_Arg2:24), h                                 ; FB3A5D  f2 12 f0 60 46
	push XDE                                             ; FB3A62  3a
	push XHL                                             ; FB3A63  3b
	push XIX                                             ; FB3A64  3c
	push XIZ                                             ; FB3A65  3e
	call T_SoundSel_FromProgramAndBank                                        ; FB3A66  1d 00 10 f4
	pop XIZ                                              ; FB3A6A  5e
	pop XIX                                              ; FB3A6B  5c
	pop XHL                                              ; FB3A6C  5b
	pop XDE                                              ; FB3A6D  5a
	ld L,H                                               ; FB3A6E  ce 8f
	set 0x05,L                                           ; FB3A70  cf 31 05
	ld (XIX),L                                           ; FB3A73  b4 47
	ld (XIX+0x01),0x1b                                   ; FB3A75  bc 01 00 1b
	ld c, (SoundConv_Result0:24)                                 ; FB3A79  c2 14 f0 60 23
	ld (XIX+0x02),C                                      ; FB3A7E  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB3A81  bc 03 00 ff
	push XIX                                             ; FB3A85  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3A86  1d 90 78 fb
	ld (XIX),L                                           ; FB3A8A  b4 47
	ld (XIX+0x01),0x1c                                   ; FB3A8C  bc 01 00 1c
	ld c, (SoundConv_Result1:24)                                 ; FB3A90  c2 15 f0 60 23
	ld (XIX+0x02),C                                      ; FB3A95  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB3A98  bc 03 00 ff
	push XIX                                             ; FB3A9C  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3A9D  1d 90 78 fb
	ld (XIX),L                                           ; FB3AA1  b4 47
	ld (XIX+0x01),0x1d                                   ; FB3AA3  bc 01 00 1d
	ld c, (SoundConv_Result2:24)                                 ; FB3AA7  c2 16 f0 60 23
	ld (XIX+0x02),C                                      ; FB3AAC  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB3AAF  bc 03 00 ff
	push XIX                                             ; FB3AB3  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3AB4  1d 90 78 fb
	add XSP,0x0000001a                                   ; FB3AB8  ef c8 1a 00 00 00
.LFB3ABE:
	pop XIX                                              ; FB3ABE  5c
	popw de                                              ; FB3ABF  4a
	popw hl                                              ; FB3AC0  4b
	unlk XIZ                                             ; FB3AC1  ee 0d
	ret                                                  ; FB3AC3  0e
; SysExParam_SetEffect1Type: setter of EFFECT1 TYPE.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetEffect1Type:
	pushw hl                                             ; FB3AC4  2b
	ld xbc, (0x60fc80:24)                               ; FB3AC5  e2 80 fc 60 21
; (sub_FB3ACA removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	push XBC                                             ; FB3ACA  39
	call SysExBuf_ReadNibblePair                                      ; FB3ACB  1d f3 77 fb
	ld L,A                                               ; FB3ACF  c9 8f
	pushw 0x0b                                           ; FB3AD1  0b 0b 00
	ld xbc, (0x60fcd8:24)                               ; FB3AD4  e2 d8 fc 60 21
	push XBC                                             ; FB3AD9  39
	call U8Rec16_GetField                                      ; FB3ADA  1d d3 62 fb
	extz WA                                              ; FB3ADE  d8 12
	extz XWA                                             ; FB3AE0  e8 12
	add XWA,0x00f4fa9c                                   ; FB3AE2  e8 c8 9c fa f4 00
	ld H,(XWA)                                           ; FB3AE8  80 26
	inc 8,XSP                                            ; FB3AEA  ef 60
	inc 2,XSP                                            ; FB3AEC  ef 62
	cp H,0xff                                            ; FB3AEE  ce cf ff
	jr z, .LFB3B02                                       ; FB3AF1  66 0f
	ld C,L                                               ; FB3AF3  cf 8b
	extz BC                                              ; FB3AF5  d9 12
	pushw bc                                             ; FB3AF7  29
	ld C,H                                               ; FB3AF8  ce 8b
	extz BC                                              ; FB3AFA  d9 12
	pushw bc                                             ; FB3AFC  29
	call T_DspParam_WriteByNumber                                        ; FB3AFD  1d a0 34 f4
	pop XIY                                              ; FB3B01  5d
.LFB3B02:
	popw hl                                              ; FB3B02  4b
	ret                                                  ; FB3B03  0e
; SysExParam_SetMidiMultipleMessagesOutput: setter of the five MIDI MULTIPLE MESSAGES OUTPUT parameters (PROGRAM CHANGE, VOLUME, PANPOT, REVERB DEPTH ...).
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetMidiMultipleMessagesOutput:
	link XIZ,0xfffc                                      ; FB3B04  ee 0c fc ff
	pushw hl                                             ; FB3B08  2b
	pushw de                                             ; FB3B09  2a
	push XIX                                             ; FB3B0A  3c
	ld xbc, (0x60fc80:24)                               ; FB3B0B  e2 80 fc 60 21
	push XBC                                             ; FB3B10  39
	call SysExBuf_ReadNibblePair                                      ; FB3B11  1d f3 77 fb
	ld L,A                                               ; FB3B15  c9 8f
	ld XBC,(XIZ+0x08)                                    ; FB3B17  ae 08 21
	ld W,(XBC+0x09)                                      ; FB3B1A  89 09 20
	pop XIY                                              ; FB3B1D  5d
	cp W,A                                               ; FB3B1E  c9 f0
	jrl ugt, SysExParam_SetMidiMultipleMessagesOutput_Skip                                  ; FB3B20  7b a6 00
	ld W,(XBC+0x0a)                                      ; FB3B23  89 0a 20
	cp A,W                                               ; FB3B26  c8 f1
	jrl ugt, SysExParam_SetMidiMultipleMessagesOutput_Skip                                  ; FB3B28  7b 9e 00
	ld H,(XBC+0x0e)                                      ; FB3B2B  89 0e 26
	cp h, 0x05:i3                                          ; FB3B2E  ce dd
	jrl nc, SysExParam_SetMidiMultipleMessagesOutput_Skip                                   ; FB3B30  7f 96 00
	ld a, 0x04:opc                                          ; FB3B33  21 04
	mul wa, h                                          ; FB3B35  ce 41
	extz XWA                                             ; FB3B37  e8 12
	add XWA,PtrTable_F51E70                              ; FB3B39  e8 c8 70 1e f5 00
	ld XWA,(XWA)                                         ; FB3B3F  a0 20
	ld XIX,XWA                                           ; FB3B41  e8 8c
	pushw 0x0a                                           ; FB3B43  0b 0a 00
	ld xiy, (0x60fcd8:24)                               ; FB3B46  e2 d8 fc 60 25
	push XIY                                             ; FB3B4B  3d
; (sub_FB3B4C removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	call U8Rec16_GetField                                      ; FB3B4C  1d d3 62 fb
	ld D,A                                               ; FB3B50  c9 8c
	sub D,0x20                                           ; FB3B52  cc ca 20
	ld XBC,(XIZ+0x08)                                    ; FB3B55  ae 08 21
	ld H,(XBC+0x06)                                      ; FB3B58  89 06 26
	ld A,D                                               ; FB3B5B  cc 89
	or H,A                                               ; FB3B5D  c9 e6
	ld (xiz-4), h                                        ; FB3B5F  be fc 46
	ld XBC,(XIZ+0x08)                                    ; FB3B62  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3B65  89 07 21
	ld (xiz-3), a                                        ; FB3B68  be fd 41
	inc 6,XSP                                            ; FB3B6B  ef 66
	cp L,0x81                                            ; FB3B6D  cf cf 81
; (sub_FB3B70 removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	jr z, .LFB3B95                                       ; FB3B70  66 23
	ld (xiz-2), l                                        ; FB3B72  be fe 47
	ld XBC,(XIZ+0x08)                                    ; FB3B75  ae 08 21
	ld A,(XBC+0x08)                                      ; FB3B78  89 08 21
	ld (xiz-1), a                                        ; FB3B7B  be ff 41
	lda xbc, (xiz-4)                                     ; FB3B7E  be fc 31
	push XBC                                             ; FB3B81  39
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3B82  1d 90 78 fb
	ld (xiz-4), h                                        ; FB3B86  be fc 46
	ld C,(XIX+0x01)                                      ; FB3B89  8c 01 23
; (sub_FB3B8C removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	ld (xiz-3), c                                        ; FB3B8C  be fd 43
	ld (xiz-2), 0x00                                     ; FB3B8F  be fe 00 00
	jr .LFB3BB9                                          ; FB3B93  68 24
.LFB3B95:
	ld (xiz-2), 0x00                                     ; FB3B95  be fe 00 00
	ld XBC,(XIZ+0x08)                                    ; FB3B99  ae 08 21
	ld A,(XBC+0x08)                                      ; FB3B9C  89 08 21
	ld (xiz-1), a                                        ; FB3B9F  be ff 41
	lda xbc, (xiz-4)                                     ; FB3BA2  be fc 31
	push XBC                                             ; FB3BA5  39
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3BA6  1d 90 78 fb
	ld (xiz-4), h                                        ; FB3BAA  be fc 46
	ld C,(XIX+0x01)                                      ; FB3BAD  8c 01 23
	ld (xiz-3), c                                        ; FB3BB0  be fd 43
	ld C,(XIX+0x02)                                      ; FB3BB3  8c 02 23
	ld (xiz-2), c                                        ; FB3BB6  be fe 43
.LFB3BB9:
	pop XIY                                              ; FB3BB9  5d
	ld C,(XIX+0x03)                                      ; FB3BBA  8c 03 23
	ld (xiz-1), c                                        ; FB3BBD  be ff 43
	lda xbc, (xiz-4)                                     ; FB3BC0  be fc 31
	push XBC                                             ; FB3BC3  39
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3BC4  1d 90 78 fb
	pop XIY                                              ; FB3BC8  5d
SysExParam_SetMidiMultipleMessagesOutput_Skip:
	pop XIX                                              ; FB3BC9  5c
	popw de                                              ; FB3BCA  4a
	popw hl                                              ; FB3BCB  4b
	unlk XIZ                                             ; FB3BCC  ee 0d
	ret                                                  ; FB3BCE  0e
; SysExParam_SetMidiMultipleMessagesOutputBankSelect: setter of MIDI MULTIPLE MESSAGES OUTPUT: BANK SELECT.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetMidiMultipleMessagesOutputBankSelect:
	link XIZ,0xfffc                                      ; FB3BCF  ee 0c fc ff
	pushw hl                                             ; FB3BD3  2b
	pushw de                                             ; FB3BD4  2a
	push XIX                                             ; FB3BD5  3c
	lda xix, (xiz-4)                                     ; FB3BD6  be fc 34
	ld xbc, (0x60fc80:24)                               ; FB3BD9  e2 80 fc 60 21
	push XBC                                             ; FB3BDE  39
	call SysExBuf_ReadNibblePair                                      ; FB3BDF  1d f3 77 fb
	extz WA                                              ; FB3BE3  d8 12
	ld HL,WA                                             ; FB3BE5  d8 8b
	sll hl, 0x08                                         ; FB3BE7  db ee 08
	ld xbc, (0x60fc80:24)                               ; FB3BEA  e2 80 fc 60 21
	push XBC                                             ; FB3BEF  39
	call SysExBuf_ReadNibblePair                                      ; FB3BF0  1d f3 77 fb
	extz WA                                              ; FB3BF4  d8 12
	ld DE,WA                                             ; FB3BF6  d8 8a
	or DE,HL                                             ; FB3BF8  db e2
	ld XBC,(XIZ+0x08)                                    ; FB3BFA  ae 08 21
	ld A,(XBC+0x09)                                      ; FB3BFD  89 09 21
	extz WA                                              ; FB3C00  d8 12
; (sub_FB3C02 removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_CheckValueWhiteList;
;  notes/prom_a_stray_label_removal.py)
	inc 8,XSP                                            ; FB3C02  ef 60
	cp WA,DE                                             ; FB3C04  da f0
	jrl ugt, .LFB3D0D                                    ; FB3C06  7b 04 01
	cp DE,0x4001                                         ; FB3C09  da cf 01 40
	jrl ugt, .LFB3D0D                                    ; FB3C0D  7b fd 00
	pushw 0x0a                                           ; FB3C10  0b 0a 00
	ld xwa, (0x60fcd8:24)                               ; FB3C13  e2 d8 fc 60 20
	push XWA                                             ; FB3C18  38
	call U8Rec16_GetField                                      ; FB3C19  1d d3 62 fb
	ld L,A                                               ; FB3C1D  c9 8f
	sub L,0x20                                           ; FB3C1F  cf ca 20
	ld XBC,(XIZ+0x08)                                    ; FB3C22  ae 08 21
	ld H,(XBC+0x06)                                      ; FB3C25  89 06 26
	ld A,L                                               ; FB3C28  cf 89
	or H,A                                               ; FB3C2A  c9 e6
	inc 6,XSP                                            ; FB3C2C  ef 66
	ld WA,DE                                             ; FB3C2E  da 88
	cp WA,0x4000                                         ; FB3C30  d8 cf 00 40
sub_FB3C34:
	jr z, .LFB3C3F                                       ; FB3C34  66 09
	cp WA,0x4001                                         ; FB3C36  d8 cf 01 40
	jr z, .LFB3C70                                       ; FB3C3A  66 34
	jrl .LFB3CB5                                         ; FB3C3C  78 76 00
.LFB3C3F:
	ld (XIX),H                                           ; FB3C3F  b4 46
	ld XBC,(XIZ+0x08)                                    ; FB3C41  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3C44  89 07 21
	ld (XIX+0x01),A                                      ; FB3C47  bc 01 41
	ld (XIX+0x02),0x80                                   ; FB3C4A  bc 02 00 80
	ld XBC,(XIZ+0x08)                                    ; FB3C4E  ae 08 21
	ld A,(XBC+0x08)                                      ; FB3C51  89 08 21
	ld (XIX+0x03),A                                      ; FB3C54  bc 03 41
	push XIX                                             ; FB3C57  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3C58  1d 90 78 fb
	ld (XIX),H                                           ; FB3C5C  b4 46
	ld XBC,(XIZ+0x08)                                    ; FB3C5E  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3C61  89 07 21
	inc 1,A                                              ; FB3C64  c9 61
	ld (XIX+0x01),A                                      ; FB3C66  bc 01 41
	ld (XIX+0x02),0x00                                   ; FB3C69  bc 02 00 00
	jrl .LFB3CEE                                         ; FB3C6D  78 7e 00
.LFB3C70:
	ld (XIX),H                                           ; FB3C70  b4 46
	ld XBC,(XIZ+0x08)                                    ; FB3C72  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3C75  89 07 21
	ld (XIX+0x01),A                                      ; FB3C78  bc 01 41
	ld (XIX+0x02),0x00                                   ; FB3C7B  bc 02 00 00
	ld XBC,(XIZ+0x08)                                    ; FB3C7F  ae 08 21
	ld A,(XBC+0x08)                                      ; FB3C82  89 08 21
	ld (XIX+0x03),A                                      ; FB3C85  bc 03 41
	push XIX                                             ; FB3C88  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3C89  1d 90 78 fb
	ld (XIX),H                                           ; FB3C8D  b4 46
	ld XBC,(XIZ+0x08)                                    ; FB3C8F  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3C92  89 07 21
	inc 1,A                                              ; FB3C95  c9 61
	ld (XIX+0x01),A                                      ; FB3C97  bc 01 41
	ld (XIX+0x02),0x00                                   ; FB3C9A  bc 02 00 00
	ld (XIX+0x03),0x7f                                   ; FB3C9E  bc 03 00 7f
	push XIX                                             ; FB3CA2  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3CA3  1d 90 78 fb
	ld (XIX),H                                           ; FB3CA7  b4 46
	ld (XIX+0x01),0x15                                   ; FB3CA9  bc 01 00 15
	ld (XIX+0x02),0x20                                   ; FB3CAD  bc 02 00 20
	inc 8,XSP                                            ; FB3CB1  ef 60
	jr .LFB3D03                                          ; FB3CB3  68 4e
.LFB3CB5:
	ld (XIX),H                                           ; FB3CB5  b4 46
	ld XBC,(XIZ+0x08)                                    ; FB3CB7  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3CBA  89 07 21
	ld (XIX+0x01),A                                      ; FB3CBD  bc 01 41
	ld C,E                                               ; FB3CC0  cd 8b
	res 0x07,C                                           ; FB3CC2  cb 30 07
	ld (XIX+0x02),C                                      ; FB3CC5  bc 02 43
	ld XBC,(XIZ+0x08)                                    ; FB3CC8  ae 08 21
	ld A,(XBC+0x08)                                      ; FB3CCB  89 08 21
	ld (XIX+0x03),A                                      ; FB3CCE  bc 03 41
	push XIX                                             ; FB3CD1  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3CD2  1d 90 78 fb
	ld (XIX),H                                           ; FB3CD6  b4 46
	ld XBC,(XIZ+0x08)                                    ; FB3CD8  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3CDB  89 07 21
	inc 1,A                                              ; FB3CDE  c9 61
	ld (XIX+0x01),A                                      ; FB3CE0  bc 01 41
	ld BC,DE                                             ; FB3CE3  da 89
	srl bc, 0x07                                         ; FB3CE5  d9 ef 07
	res 0x07,C                                           ; FB3CE8  cb 30 07
	ld (XIX+0x02),C                                      ; FB3CEB  bc 02 43
.LFB3CEE:
	pop XIY                                              ; FB3CEE  5d
	ld (XIX+0x03),0x7f                                   ; FB3CEF  bc 03 00 7f
	push XIX                                             ; FB3CF3  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3CF4  1d 90 78 fb
	ld (XIX),H                                           ; FB3CF8  b4 46
	ld (XIX+0x01),0x15                                   ; FB3CFA  bc 01 00 15
	ld (XIX+0x02),0x00                                   ; FB3CFE  bc 02 00 00
	pop XIY                                              ; FB3D02  5d
.LFB3D03:
	ld (XIX+0x03),0x20                                   ; FB3D03  bc 03 00 20
	push XIX                                             ; FB3D07  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3D08  1d 90 78 fb
	pop XIY                                              ; FB3D0C  5d
.LFB3D0D:
	pop XIX                                              ; FB3D0D  5c
	popw de                                              ; FB3D0E  4a
	popw hl                                              ; FB3D0F  4b
	unlk XIZ                                             ; FB3D10  ee 0d
	ret                                                  ; FB3D12  0e
; SysExParam_SetEffect2OnOff: setter of EFFECT2 ON/OFF.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetEffect2OnOff:
	link XIZ,0xfffc                                      ; FB3D13  ee 0c fc ff
	pushw hl                                             ; FB3D17  2b
	push XIX                                             ; FB3D18  3c
	ld xbc, (0x60fc80:24)                               ; FB3D19  e2 80 fc 60 21
	push XBC                                             ; FB3D1E  39
	call SysExBuf_ReadNibblePair                                      ; FB3D1F  1d f3 77 fb
	ld L,A                                               ; FB3D23  c9 8f
	ld XBC,(XIZ+0x08)                                    ; FB3D25  ae 08 21
	ld W,(XBC+0x09)                                      ; FB3D28  89 09 20
	pop XIY                                              ; FB3D2B  5d
	cp W,A                                               ; FB3D2C  c9 f0
	jrl ugt, .LFB3DB7                                    ; FB3D2E  7b 86 00
	ld W,(XBC+0x0a)                                      ; FB3D31  89 0a 20
	cp A,W                                               ; FB3D34  c8 f1
	jrl ugt, .LFB3DB7                                    ; FB3D36  7b 7e 00
	ld H,(XBC+0x0e)                                      ; FB3D39  89 0e 26
	cp H,0xff                                            ; FB3D3C  ce cf ff
	jrl z, .LFB3DB7                                      ; FB3D3F  76 75 00
	cp h, 0x01:i3                                          ; FB3D42  ce d9
	jrl nc, .LFB3DB7                                     ; FB3D44  7f 70 00
	ld a, 0x04:opc                                          ; FB3D47  21 04
	mul wa, h                                          ; FB3D49  ce 41
	extz XWA                                             ; FB3D4B  e8 12
	add XWA,Pointer_F51E84                               ; FB3D4D  e8 c8 84 1e f5 00
	ld XWA,(XWA)                                         ; FB3D53  a0 20
	ld XIX,XWA                                           ; FB3D55  e8 8c
	cp l, 0x00:i3                                          ; FB3D57  cf d8
	jr nz, .LFB3D62                                      ; FB3D59  6e 07
	ld C,(XWA)                                           ; FB3D5B  80 23
	ld (xiz-2), c                                        ; FB3D5D  be fe 43
	jr .LFB3D68                                          ; FB3D60  68 06
.LFB3D62:
	ld C,(XIX+0x01)                                      ; FB3D62  8c 01 23
	ld (xiz-2), c                                        ; FB3D65  be fe 43
.LFB3D68:
	ld XBC,(XIZ+0x08)                                    ; FB3D68  ae 08 21
	ld A,(XBC+0x06)                                      ; FB3D6B  89 06 21
	ld (xiz-4), a                                        ; FB3D6E  be fc 41
	pushw 0x0a                                           ; FB3D71  0b 0a 00
	ld xbc, (0x60fcd8:24)                               ; FB3D74  e2 d8 fc 60 21
	push XBC                                             ; FB3D79  39
	call U8Rec16_GetField                                      ; FB3D7A  1d d3 62 fb
	sub A,0x20                                           ; FB3D7E  c9 ca 20
	or (xiz-4), a                                        ; FB3D81  8e fc e9
	ld XBC,(XIZ+0x08)                                    ; FB3D84  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3D87  89 07 21
	ld (xiz-3), a                                        ; FB3D8A  be fd 41
	ld XBC,(XIZ+0x08)                                    ; FB3D8D  ae 08 21
	ld H,(XBC+0x0b)                                      ; FB3D90  89 0b 26
	ld a, (xiz-2)                                        ; FB3D93  8e fe 21
	push 0x00                                            ; FB3D96  09 00
	push H                                               ; FB3D98  ce 04
	pushw wa                                             ; FB3D9A  28
	call Shl8ByCount                                      ; FB3D9B  1d e6 81 fb
	ld (xiz-2), a                                        ; FB3D9F  be fe 41
	ld XBC,(XIZ+0x08)                                    ; FB3DA2  ae 08 21
	ld A,(XBC+0x08)                                      ; FB3DA5  89 08 21
	ld (xiz-1), a                                        ; FB3DA8  be ff 41
	lda xbc, (xiz-4)                                     ; FB3DAB  be fc 31
	push XBC                                             ; FB3DAE  39
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3DAF  1d 90 78 fb
	inc 8,XSP                                            ; FB3DB3  ef 60
	inc 2,XSP                                            ; FB3DB5  ef 62
.LFB3DB7:
	pop XIX                                              ; FB3DB7  5c
	popw hl                                              ; FB3DB8  4b
	unlk XIZ                                             ; FB3DB9  ee 0d
	ret                                                  ; FB3DBB  0e
; SysExInitial_Total: SysExInitial_ItemTable[0] -- SysEx INITIAL (parameter 08 00) value 0 TOTAL: T_ModuleInit_Phase2Veneer, T_F40A00 (notes/FINDINGS-prom_a-initial.md)
SysExInitial_Total:
	push XDE                                             ; FB3DBC  3a
	push XHL                                             ; FB3DBD  3b
	push XIX                                             ; FB3DBE  3c
	push XIZ                                             ; FB3DBF  3e
	call T_ModuleInit_Phase2Veneer                                        ; FB3DC0  1d 34 00 f4
	call T_F40A00                                        ; FB3DC4  1d 00 0a f4
	pop XIZ                                              ; FB3DC8  5e
	pop XIX                                              ; FB3DC9  5c
	pop XHL                                              ; FB3DCA  5b
	pop XDE                                              ; FB3DCB  5a
	ret                                                  ; FB3DCC  0e
; SysExInitial_PartSetting: SysExInitial_ItemTable[1] -- SysEx INITIAL (parameter 08 00) value 1 PART SETTING (notes/FINDINGS-prom_a-initial.md)
SysExInitial_PartSetting:
	call T_PartSettings_ResetToDefault                                        ; FB3DCD  1d 40 34 f4
	ret                                                  ; FB3DD1  0e
; SysExInitial_System: SysExInitial_ItemTable[2] -- SysEx INITIAL (parameter 08 00) value 2 SYSTEM, then a 0x3FFF countdown (notes/FINDINGS-prom_a-initial.md)
SysExInitial_System:
	pushw hl                                             ; FB3DD2  2b
	pushw de                                             ; FB3DD3  2a
	ldw hl, 0x3fff                                       ; FB3DD4  33 ff 3f
	call T_SystemSettings_ResetToDefault                                        ; FB3DD7  1d 44 34 f4
.LFB3DDB:
	ld DE,HL                                             ; FB3DDB  db 8a
	dec 1,HL                                             ; FB3DDD  db 69
	cp de, 0x00:i3                                         ; FB3DDF  da d8
	jr nz, .LFB3DDB                                      ; FB3DE1  6e f8
	popw de                                              ; FB3DE3  4a
	popw hl                                              ; FB3DE4  4b
	ret                                                  ; FB3DE5  0e
; SysExInitial_MidiSetting: SysExInitial_ItemTable[3] -- SysEx INITIAL (parameter 08 00) value 3 MIDI SETTING, then a 0x7FFF countdown (notes/FINDINGS-prom_a-initial.md)
SysExInitial_MidiSetting:
	pushw hl                                             ; FB3DE6  2b
	pushw de                                             ; FB3DE7  2a
	ldw hl, 0x7fff                                       ; FB3DE8  33 ff 7f
	push XDE                                             ; FB3DEB  3a
	push XHL                                             ; FB3DEC  3b
	push XIX                                             ; FB3DED  3c
	push XIZ                                             ; FB3DEE  3e
	call T_MidiSettings_ResetToDefault                                        ; FB3DEF  1d 7c 07 f4
	pop XIZ                                              ; FB3DF3  5e
	pop XIX                                              ; FB3DF4  5c
	pop XHL                                              ; FB3DF5  5b
	pop XDE                                              ; FB3DF6  5a
.LFB3DF7:
	ld DE,HL                                             ; FB3DF7  db 8a
	dec 1,HL                                             ; FB3DF9  db 69
	cp de, 0x00:i3                                         ; FB3DFB  da d8
	jr nz, .LFB3DF7                                      ; FB3DFD  6e f8
	popw de                                              ; FB3DFF  4a
	popw hl                                              ; FB3E00  4b
	ret                                                  ; FB3E01  0e
; SysExInitial_ReMap: SysExInitial_ItemTable[4] -- SysEx INITIAL (parameter 08 00) value 4 RE-MAP: both remap resets, then a 0xFFFF countdown (notes/FINDINGS-prom_a-initial.md)
SysExInitial_ReMap:
	pushw hl                                             ; FB3E02  2b
	pushw de                                             ; FB3E03  2a
	ldw hl, 0xffff                                       ; FB3E04  33 ff ff
	push XDE                                             ; FB3E07  3a
	push XHL                                             ; FB3E08  3b
	push XIX                                             ; FB3E09  3c
	push XIZ                                             ; FB3E0A  3e
	call T_SoundRemap_ResetToDefault                                        ; FB3E0B  1d 48 10 f4
	call T_CombiRemap_ResetToDefault                                        ; FB3E0F  1d 4c 10 f4
	pop XIZ                                              ; FB3E13  5e
	pop XIX                                              ; FB3E14  5c
	pop XHL                                              ; FB3E15  5b
	pop XDE                                              ; FB3E16  5a
.LFB3E17:
	ld DE,HL                                             ; FB3E17  db 8a
	dec 1,HL                                             ; FB3E19  db 69
	cp de, 0x00:i3                                         ; FB3E1B  da d8
	jr nz, .LFB3E17                                      ; FB3E1D  6e f8
	popw de                                              ; FB3E1F  4a
	popw hl                                              ; FB3E20  4b
	ret                                                  ; FB3E21  0e
; SysExInitial_DrumsMap: SysExInitial_ItemTable[5] -- SysEx INITIAL (parameter 08 00) value 5 DRUMS MAP, then a 0xFFFF countdown (notes/FINDINGS-prom_a-initial.md)
SysExInitial_DrumsMap:
	pushw hl                                             ; FB3E22  2b
	pushw de                                             ; FB3E23  2a
	ldw hl, 0xffff                                       ; FB3E24  33 ff ff
	push XDE                                             ; FB3E27  3a
	push XHL                                             ; FB3E28  3b
	push XIX                                             ; FB3E29  3c
	push XIZ                                             ; FB3E2A  3e
	call T_DrumMap_ResetToDefault                                        ; FB3E2B  1d 50 10 f4
	pop XIZ                                              ; FB3E2F  5e
	pop XIX                                              ; FB3E30  5c
	pop XHL                                              ; FB3E31  5b
	pop XDE                                              ; FB3E32  5a
.LFB3E33:
	ld DE,HL                                             ; FB3E33  db 8a
	dec 1,HL                                             ; FB3E35  db 69
	cp de, 0x00:i3                                         ; FB3E37  da d8
	jr nz, .LFB3E33                                      ; FB3E39  6e f8
	popw de                                              ; FB3E3B  4a
	popw hl                                              ; FB3E3C  4b
	ret                                                  ; FB3E3D  0e
; SysExInitial_Sequencer: SysExInitial_ItemTable[6] -- SysEx INITIAL (parameter 08 00) value 6 SEQUENCER, then a 0xFFFF countdown (notes/FINDINGS-prom_a-initial.md)
SysExInitial_Sequencer:
	pushw hl                                             ; FB3E3E  2b
	pushw de                                             ; FB3E3F  2a
	ldw hl, 0xffff                                       ; FB3E40  33 ff ff
	push XDE                                             ; FB3E43  3a
	push XHL                                             ; FB3E44  3b
	push XIX                                             ; FB3E45  3c
	push XIZ                                             ; FB3E46  3e
	call T_Sequencer_ResetToDefault                                        ; FB3E47  1d 18 0a f4
	pop XIZ                                              ; FB3E4B  5e
	pop XIX                                              ; FB3E4C  5c
	pop XHL                                              ; FB3E4D  5b
	pop XDE                                              ; FB3E4E  5a
.LFB3E4F:
	ld DE,HL                                             ; FB3E4F  db 8a
	dec 1,HL                                             ; FB3E51  db 69
	cp de, 0x00:i3                                         ; FB3E53  da d8
	jr nz, .LFB3E4F                                      ; FB3E55  6e f8
	popw de                                              ; FB3E57  4a
	popw hl                                              ; FB3E58  4b
	ret                                                  ; FB3E59  0e
; SysExParam_SetInitial: setter of INITIAL (receive-only): value 0..6 picks the SysExInitial_ItemTable arm, after the status 0x25 message and T_Transport_StopAllRunning.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetInitial:
	pushw hl                                             ; FB3E5A  2b
	ld xbc, (0x60fc80:24)                               ; FB3E5B  e2 80 fc 60 21
	push XBC                                             ; FB3E60  39
	call SysExBuf_ReadNibblePair                                      ; FB3E61  1d f3 77 fb
	ld H,A                                               ; FB3E65  c9 8e
	pop XIY                                              ; FB3E67  5d
	cp a, 0x07:i3                                          ; FB3E68  c9 df
	jr nc, .LFB3EA1                                      ; FB3E6A  6f 35
	ld (UI_StatusCode:16), 0x25                                 ; FB3E6C  f1 80 28 00 25
	call MessageScreen_Paint_SaveRegs                                      ; FB3E71  1d 9b 7e fb
	push XDE                                             ; FB3E75  3a
	push XHL                                             ; FB3E76  3b
	push XIX                                             ; FB3E77  3c
	push XIZ                                             ; FB3E78  3e
	call T_Transport_StopAllRunning                                        ; FB3E79  1d ac 09 f4
	pop XIZ                                              ; FB3E7D  5e
	pop XIX                                              ; FB3E7E  5c
	pop XHL                                              ; FB3E7F  5b
	pop XDE                                              ; FB3E80  5a
	ld c, 0x04:opc                                          ; FB3E81  23 04
	mul bc, h                                          ; FB3E83  ce 43
	extz XBC                                             ; FB3E85  e9 12
	add XBC,SysExInitial_ItemTable                              ; FB3E87  e9 c8 1c fb f4 00
	ld XBC,(XBC)                                         ; FB3E8D  a1 21
	lda xiy, (.LFB3E97:24)                               ; FB3E8F  f2 97 3e fb 35
	push XIY                                             ; FB3E94  3d
	jp (xbc)                                             ; FB3E95  b1 d8
.LFB3E97:
	or	(UI_Request_Hi:16), 0x12                            ; FB3E97  c1 71 20 3e 12
	ld (UI_Request:16), 0x01                                 ; FB3E9C  f1 70 20 00 01
.LFB3EA1:
	popw hl                                              ; FB3EA1  4b
	ret                                                  ; FB3EA2  0e
; SysExParam_SetSoundWriteRequest: setter of SOUND WRITE REQUEST (receive-only).
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetSoundWriteRequest:
	ld xbc, (0x60fc80:24)                               ; FB3EA3  e2 80 fc 60 21
	add XBC,0x0000000e                                   ; FB3EA8  e9 c8 0e 00 00 00
	push XBC                                             ; FB3EAE  39
	call T_SysExParam_ExecSoundWriteRequest                                        ; FB3EAF  1d 5c 12 f4
	pop XIY                                              ; FB3EB3  5d
	cp wa, 0x00:i3                                         ; FB3EB4  d8 d8
	jr z, .LFB3ED7                                       ; FB3EB6  66 1f
	pushw 0x05                                           ; FB3EB8  0b 05 00
	lda xbc, (0xf4fec8:24)                               ; FB3EBB  f2 c8 fe f4 31
	push XBC                                             ; FB3EC0  39
	call SysExTx_Append                                      ; FB3EC1  1d 24 6f fb
	ld xbc, (0x60fc88:24)                               ; FB3EC5  e2 88 fc 60 21
	push XBC                                             ; FB3ECA  39
	call SysExTx_SendFrameBothPorts                                      ; FB3ECB  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB3ECF  1d 81 80 fb
	inc 8,XSP                                            ; FB3ED3  ef 60
	inc 2,XSP                                            ; FB3ED5  ef 62
.LFB3ED7:
	ret                                                  ; FB3ED7  0e
	link XIZ,0xfffc                                      ; FB3ED8  ee 0c fc ff
	pushw hl                                             ; FB3EDC  2b
	push XIX                                             ; FB3EDD  3c
	lda xix, (xiz-4)                                     ; FB3EDE  be fc 34
	ld xbc, (0x60fc80:24)                               ; FB3EE1  e2 80 fc 60 21
	push XBC                                             ; FB3EE6  39
	call SysExBuf_ReadNibblePair                                      ; FB3EE7  1d f3 77 fb
	ld H,A                                               ; FB3EEB  c9 8e
	ld (XIX+0x02),A                                      ; FB3EED  bc 02 41
	ld XBC,(XIZ+0x08)                                    ; FB3EF0  ae 08 21
	ld A,(XBC+0x09)                                      ; FB3EF3  89 09 21
	pop XIY                                              ; FB3EF6  5d
	cp A,H                                               ; FB3EF7  ce f1
	jr ugt, .LFB3F4B                                     ; FB3EF9  6b 50
	ld L,(XBC+0x0a)                                      ; FB3EFB  89 0a 27
	ld H,(XIX+0x02)                                      ; FB3EFE  8c 02 26
	cp H,L                                               ; FB3F01  cf f6
	jr ugt, .LFB3F4B                                     ; FB3F03  6b 46
	cp H,0x40                                            ; FB3F05  ce cf 40
	jr c, .LFB3F1A                                       ; FB3F08  67 10
	ld A,(XBC+0x0b)                                      ; FB3F0A  89 0b 21
	pushw wa                                             ; FB3F0D  28
	pushw 0x01                                           ; FB3F0E  0b 01 00
	call Shl16ByCount                                      ; FB3F11  1d 07 82 fb
	ld (XIX+0x02),A                                      ; FB3F15  bc 02 41
	jr .LFB3F2B                                          ; FB3F18  68 11
.LFB3F1A:
	ld XBC,(XIZ+0x08)                                    ; FB3F1A  ae 08 21
	ld A,(XBC+0x0b)                                      ; FB3F1D  89 0b 21
	pushw wa                                             ; FB3F20  28
	pushw 0x00                                           ; FB3F21  0b 00 00
	call Shl16ByCount                                      ; FB3F24  1d 07 82 fb
	ld (XIX+0x02),A                                      ; FB3F28  bc 02 41
.LFB3F2B:
	ld XBC,(XIZ+0x08)                                    ; FB3F2B  ae 08 21
	ld A,(XBC+0x06)                                      ; FB3F2E  89 06 21
	ld (XIX),A                                           ; FB3F31  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB3F33  ae 08 21
	ld A,(XBC+0x07)                                      ; FB3F36  89 07 21
	ld (XIX+0x01),A                                      ; FB3F39  bc 01 41
	ld XBC,(XIZ+0x08)                                    ; FB3F3C  ae 08 21
	ld A,(XBC+0x08)                                      ; FB3F3F  89 08 21
	ld (XIX+0x03),A                                      ; FB3F42  bc 03 41
	push XIX                                             ; FB3F45  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3F46  1d 90 78 fb
	pop XIY                                              ; FB3F4A  5d
.LFB3F4B:
	pop XIX                                              ; FB3F4B  5c
	popw hl                                              ; FB3F4C  4b
	unlk XIZ                                             ; FB3F4D  ee 0d
	ret                                                  ; FB3F4F  0e
	link XIZ,0x0000                                      ; FB3F50  ee 0c 00 00
	pushw hl                                             ; FB3F54  2b
	push XIX                                             ; FB3F55  3c
	ld XIX,(XIZ+0x08)                                    ; FB3F56  ae 08 24
	ld xbc, (0x60fc80:24)                               ; FB3F59  e2 80 fc 60 21
	push XBC                                             ; FB3F5E  39
	call SysExBuf_ReadNibblePair                                      ; FB3F5F  1d f3 77 fb
	ld H,A                                               ; FB3F63  c9 8e
	ld C,(XIX+0x09)                                      ; FB3F65  8c 09 23
	pop XIY                                              ; FB3F68  5d
	cp C,A                                               ; FB3F69  c9 f3
	jr ugt, .LFB3F98                                     ; FB3F6B  6b 2b
	ld C,(XIX+0x0a)                                      ; FB3F6D  8c 0a 23
	cp A,C                                               ; FB3F70  cb f1
	jr ugt, .LFB3F98                                     ; FB3F72  6b 24
	ld C,(XIX+0x08)                                      ; FB3F74  8c 08 23
	extz BC                                              ; FB3F77  d9 12
	pushw bc                                             ; FB3F79  29
	ld C,(XIX+0x0b)                                      ; FB3F7A  8c 0b 23
	pushw bc                                             ; FB3F7D  29
	pushw wa                                             ; FB3F7E  28
	call Shl8ByCount                                      ; FB3F7F  1d e6 81 fb
	extz WA                                              ; FB3F83  d8 12
	pushw wa                                             ; FB3F85  28
	ld C,(XIX+0x07)                                      ; FB3F86  8c 07 23
	extz BC                                              ; FB3F89  d9 12
	pushw bc                                             ; FB3F8B  29
	ld C,(XIX+0x06)                                      ; FB3F8C  8c 06 23
	extz BC                                              ; FB3F8F  d9 12
	pushw bc                                             ; FB3F91  29
	call T_EventQueue_AppendStackArgs                                        ; FB3F92  1d 14 1b f4
	inc 8,XSP                                            ; FB3F96  ef 60
.LFB3F98:
	pop XIX                                              ; FB3F98  5c
	popw hl                                              ; FB3F99  4b
	unlk XIZ                                             ; FB3F9A  ee 0d
	ret                                                  ; FB3F9C  0e
; SysExParam_SetCombinationNumberAndBank: setter of COMBINATION NUMBER and BANK.
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetCombinationNumberAndBank:
	link XIZ,0xfffc                                      ; FB3F9D  ee 0c fc ff
	pushw hl                                             ; FB3FA1  2b
	push XIX                                             ; FB3FA2  3c
	lda xix, (xiz-4)                                     ; FB3FA3  be fc 34
	cp	(PanelMode:16), 0x02                            ; FB3FA6  c1 78 20 3f 02
	jrl nz, .LFB407E                                     ; FB3FAB  7e d0 00
	ld xbc, (0x60fc80:24)                               ; FB3FAE  e2 80 fc 60 21
	push XBC                                             ; FB3FB3  39
	call SysExBuf_ReadNibblePair                                      ; FB3FB4  1d f3 77 fb
	ld H,A                                               ; FB3FB8  c9 8e
	ld xbc, (0x60fc80:24)                               ; FB3FBA  e2 80 fc 60 21
	push XBC                                             ; FB3FBF  39
	call SysExBuf_ReadNibblePair                                      ; FB3FC0  1d f3 77 fb
	ld L,A                                               ; FB3FC4  c9 8f
	and A,0x01                                           ; FB3FC6  c9 cc 01
	ld L,A                                               ; FB3FC9  c9 8f
	sll a, 0x03                                          ; FB3FCB  c9 ee 03
	ld L,A                                               ; FB3FCE  c9 8f
	ld XBC,(XIZ+0x08)                                    ; FB3FD0  ae 08 21
	ld W,(XBC+0x09)                                      ; FB3FD3  89 09 20
	inc 8,XSP                                            ; FB3FD6  ef 60
	cp W,H                                               ; FB3FD8  ce f0
	jrl ugt, .LFB407E                                    ; FB3FDA  7b a1 00
	ld W,(XBC+0x0a)                                      ; FB3FDD  89 0a 20
	cp H,W                                               ; FB3FE0  c8 f6
	jrl ugt, .LFB407E                                    ; FB3FE2  7b 99 00
	ld W,(XBC+0x06)                                      ; FB3FE5  89 06 20
	ld (XIX),W                                           ; FB3FE8  b4 40
	ld (XIX+0x01),0x02                                   ; FB3FEA  bc 01 00 02
	ld (XIX+0x02),L                                      ; FB3FEE  bc 02 47
	ld (XIX+0x03),0x3f                                   ; FB3FF1  bc 03 00 3f
	push XIX                                             ; FB3FF5  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB3FF6  1d 90 78 fb
	ld XBC,(XIZ+0x08)                                    ; FB3FFA  ae 08 21
	ld A,(XBC+0x06)                                      ; FB3FFD  89 06 21
	ld (XIX),A                                           ; FB4000  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB4002  ae 08 21
	ld A,(XBC+0x07)                                      ; FB4005  89 07 21
	ld (XIX+0x01),A                                      ; FB4008  bc 01 41
	ld (XIX+0x02),H                                      ; FB400B  bc 02 46
	ld XBC,(XIZ+0x08)                                    ; FB400E  ae 08 21
	ld A,(XBC+0x08)                                      ; FB4011  89 08 21
	ld (XIX+0x03),A                                      ; FB4014  bc 03 41
	push XIX                                             ; FB4017  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB4018  1d 90 78 fb
	ld (0x60f189:24), h                                 ; FB401C  f2 89 f1 60 46
	ld (0x60f18a:24), l                                 ; FB4021  f2 8a f1 60 47
	ld (0x60f180:24), 0x98                             ; FB4026  f2 80 f1 60 00 98
	call T_CombiSel_GroupMemberFromNumberAndBank                                        ; FB402C  1d 08 08 f4
	ld (XIX),0x98                                        ; FB4030  b4 00 98
	ld (XIX+0x01),0x06                                   ; FB4033  bc 01 00 06
	ld c, (0x60f18d:24)                                 ; FB4037  c2 8d f1 60 23
	ld (XIX+0x02),C                                      ; FB403C  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB403F  bc 03 00 ff
	push XIX                                             ; FB4043  3c
	call IndexedTable_MergeMaskedByte                                      ; FB4044  1d 2b 78 fb
	ld (XIX),0x98                                        ; FB4048  b4 00 98
	ld (XIX+0x01),0x07                                   ; FB404B  bc 01 00 07
	ld c, (0x60f18e:24)                                 ; FB404F  c2 8e f1 60 23
	ld (XIX+0x02),C                                      ; FB4054  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB4057  bc 03 00 ff
	push XIX                                             ; FB405B  3c
	call IndexedTable_MergeMaskedByte                                      ; FB405C  1d 2b 78 fb
	ld (XIX),0x98                                        ; FB4060  b4 00 98
	ld (XIX+0x01),0x08                                   ; FB4063  bc 01 00 08
	ld c, (0x60f18f:24)                                 ; FB4067  c2 8f f1 60 23
	ld (XIX+0x02),C                                      ; FB406C  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB406F  bc 03 00 ff
	push XIX                                             ; FB4073  3c
	call IndexedTable_MergeMaskedByte                                      ; FB4074  1d 2b 78 fb
	add XSP,0x00000014                                   ; FB4078  ef c8 14 00 00 00
.LFB407E:
	pop XIX                                              ; FB407E  5c
	popw hl                                              ; FB407F  4b
	unlk XIZ                                             ; FB4080  ee 0d
	ret                                                  ; FB4082  0e
	ret                                                  ; FB4083  0e
	link XIZ,0xfffc                                      ; FB4084  ee 0c fc ff
	pushw hl                                             ; FB4088  2b
	push XIX                                             ; FB4089  3c
	lda xbc, (0x60f812:24)                               ; FB408A  f2 12 f8 60 31
	ld (xiz-4), xbc                                      ; FB408F  be fc 61
	ld xwa, (0x60fc80:24)                               ; FB4092  e2 80 fc 60 20
	push XWA                                             ; FB4097  38
	call SysExBuf_ReadNibblePair                                      ; FB4098  1d f3 77 fb
	ld xbc, (xiz-4)                                      ; FB409C  ae fc 21
	ld (XBC),A                                           ; FB409F  b1 41
	ld xix, (xiz-4)                                      ; FB40A1  ae fc 24
	inc 1,XIX                                            ; FB40A4  ec 61
	ld xbc, (0x60fc80:24)                               ; FB40A6  e2 80 fc 60 21
	push XBC                                             ; FB40AB  39
	call SysExBuf_ReadNibblePair                                      ; FB40AC  1d f3 77 fb
	ld H,A                                               ; FB40B0  c9 8e
	ld (XIX),A                                           ; FB40B2  b4 41
	ld C,H                                               ; FB40B4  ce 8b
	and C,0x80                                           ; FB40B6  cb cc 80
	inc 8,XSP                                            ; FB40B9  ef 60
	jr z, .LFB40C7                                       ; FB40BB  66 0a
	and (XIX),0x7f                                       ; FB40BD  84 3c 7f
	ld XBC,XIX                                           ; FB40C0  ec 89
	dec 1,XBC                                            ; FB40C2  e9 69
	or	(xbc), 0x80                                  ; FB40C4  81 3e 80
.LFB40C7:
	call sub_FB3C34_Nop                                      ; FB40C7  1d 23 20 fb
	pop XIX                                              ; FB40CB  5c
	popw hl                                              ; FB40CC  4b
	unlk XIZ                                             ; FB40CD  ee 0d
	ret                                                  ; FB40CF  0e
	link XIZ,0xfffc                                      ; FB40D0  ee 0c fc ff
	pushw hl                                             ; FB40D4  2b
	push XIX                                             ; FB40D5  3c
	ld XIX,(XIZ+0x08)                                    ; FB40D6  ae 08 24
	ld xbc, (0x60fc80:24)                               ; FB40D9  e2 80 fc 60 21
	push XBC                                             ; FB40DE  39
	call SysExBuf_ReadNibblePair                                      ; FB40DF  1d f3 77 fb
	ld H,A                                               ; FB40E3  c9 8e
	ld (xiz-2), a                                        ; FB40E5  be fe 41
	ld C,(XIX+0x09)                                      ; FB40E8  8c 09 23
	pop XIY                                              ; FB40EB  5d
	cp C,H                                               ; FB40EC  ce f3
	jr ugt, .LFB413F                                     ; FB40EE  6b 4f
	ld L,(XIX+0x0a)                                      ; FB40F0  8c 0a 27
	ld h, (xiz-2)                                        ; FB40F3  8e fe 26
	cp H,L                                               ; FB40F6  cf f6
	jr ugt, .LFB413F                                     ; FB40F8  6b 45
	ld C,(XIX+0x0b)                                      ; FB40FA  8c 0b 23
	pushw bc                                             ; FB40FD  29
	push 0x00                                            ; FB40FE  09 00
	push H                                               ; FB4100  ce 04
	call Shl8ByCount                                      ; FB4102  1d e6 81 fb
	ld L,A                                               ; FB4106  c9 8f
	ld (xiz-2), a                                        ; FB4108  be fe 41
	ld C,L                                               ; FB410B  cf 8b
	extz BC                                              ; FB410D  d9 12
	pushw bc                                             ; FB410F  29
	ld C,(XIX+0x06)                                      ; FB4110  8c 06 23
	extz BC                                              ; FB4113  d9 12
	pushw bc                                             ; FB4115  29
	call T_DspEffect_ApplyAlgorithmDefaults                                        ; FB4116  1d 58 2f f4
	pop XIY                                              ; FB411A  5d
	cp WA,0xffff                                         ; FB411B  d8 cf ff ff
	jr z, .LFB413F                                       ; FB411F  66 1e
	ld C,(XIX+0x08)                                      ; FB4121  8c 08 23
	extz BC                                              ; FB4124  d9 12
	pushw bc                                             ; FB4126  29
	ld c, (xiz-2)                                        ; FB4127  8e fe 23
	extz BC                                              ; FB412A  d9 12
	pushw bc                                             ; FB412C  29
	ld C,(XIX+0x07)                                      ; FB412D  8c 07 23
	extz BC                                              ; FB4130  d9 12
	pushw bc                                             ; FB4132  29
	ld C,(XIX+0x06)                                      ; FB4133  8c 06 23
	extz BC                                              ; FB4136  d9 12
	pushw bc                                             ; FB4138  29
	call T_EventQueue_AppendStackArgs                                        ; FB4139  1d 14 1b f4
	inc 8,XSP                                            ; FB413D  ef 60
.LFB413F:
	pop XIX                                              ; FB413F  5c
	popw hl                                              ; FB4140  4b
	unlk XIZ                                             ; FB4141  ee 0d
	ret                                                  ; FB4143  0e
	link XIZ,0xfffc                                      ; FB4144  ee 0c fc ff
	pushw hl                                             ; FB4148  2b
	push XIX                                             ; FB4149  3c
	lda xix, (xiz-4)                                     ; FB414A  be fc 34
	cp	(PanelModeGroup:16), 0x0c                            ; FB414D  c1 76 20 3f 0c
	jr nz, .LFB415C                                      ; FB4152  6e 08
	cp	(PanelModeGroup:16), 0x13                            ; FB4154  c1 76 20 3f 13
	jrl z, .LFB41DA                                      ; FB4159  76 7e 00
.LFB415C:
	ld xbc, (0x60fc80:24)                               ; FB415C  e2 80 fc 60 21
	push XBC                                             ; FB4161  39
	call SysExBuf_ReadNibblePair                                      ; FB4162  1d f3 77 fb
	ld L,A                                               ; FB4166  c9 8f
	ld xbc, (0x60fc80:24)                               ; FB4168  e2 80 fc 60 21
	push XBC                                             ; FB416D  39
	call SysExBuf_ReadNibblePair                                      ; FB416E  1d f3 77 fb
	ld H,A                                               ; FB4172  c9 8e
	and A,0x80                                           ; FB4174  c9 cc 80
	inc 8,XSP                                            ; FB4177  ef 60
	jr z, .LFB4181                                       ; FB4179  66 06
	res 0x07,H                                           ; FB417B  ce 30 07
	set 0x07,L                                           ; FB417E  cf 31 07
.LFB4181:
	ld XBC,(XIZ+0x08)                                    ; FB4181  ae 08 21
	ld A,(XBC+0x09)                                      ; FB4184  89 09 21
	cp A,L                                               ; FB4187  cf f1
	jr ugt, .LFB41DA                                     ; FB4189  6b 4f
	ld A,(XBC+0x0a)                                      ; FB418B  89 0a 21
	cp L,A                                               ; FB418E  c9 f7
	jr ugt, .LFB41DA                                     ; FB4190  6b 48
	and H,0x07                                           ; FB4192  ce cc 07
	ld A,L                                               ; FB4195  cf 89
	and A,0x80                                           ; FB4197  c9 cc 80
	jr z, .LFB419E                                       ; FB419A  66 02
	ld h, 0x00:opc                                          ; FB419C  26 00
.LFB419E:
	ld XBC,(XIZ+0x08)                                    ; FB419E  ae 08 21
	ld A,(XBC+0x06)                                      ; FB41A1  89 06 21
	ld (XIX),A                                           ; FB41A4  b4 41
	ld (XIX+0x01),0x01                                   ; FB41A6  bc 01 00 01
	ld (XIX+0x02),H                                      ; FB41AA  bc 02 46
	ld (XIX+0x03),0x7f                                   ; FB41AD  bc 03 00 7f
	push XIX                                             ; FB41B1  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB41B2  1d 90 78 fb
	ld XBC,(XIZ+0x08)                                    ; FB41B6  ae 08 21
	ld A,(XBC+0x06)                                      ; FB41B9  89 06 21
	ld (XIX),A                                           ; FB41BC  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB41BE  ae 08 21
	ld A,(XBC+0x07)                                      ; FB41C1  89 07 21
	ld (XIX+0x01),A                                      ; FB41C4  bc 01 41
	ld (XIX+0x02),L                                      ; FB41C7  bc 02 47
	ld XBC,(XIZ+0x08)                                    ; FB41CA  ae 08 21
	ld A,(XBC+0x08)                                      ; FB41CD  89 08 21
	ld (XIX+0x03),A                                      ; FB41D0  bc 03 41
	push XIX                                             ; FB41D3  3c
	call IndexedTable_MergeMaskedByteAndPost                                      ; FB41D4  1d 90 78 fb
	inc 8,XSP                                            ; FB41D8  ef 60
.LFB41DA:
	pop XIX                                              ; FB41DA  5c
	popw hl                                              ; FB41DB  4b
	unlk XIZ                                             ; FB41DC  ee 0d
	ret                                                  ; FB41DE  0e
	link XIZ,0x0000                                      ; FB41DF  ee 0c 00 00
	pushw hl                                             ; FB41E3  2b
	push XIX                                             ; FB41E4  3c
	ld XIX,(XIZ+0x08)                                    ; FB41E5  ae 08 24
	ld xbc, (0x60fc80:24)                               ; FB41E8  e2 80 fc 60 21
	push XBC                                             ; FB41ED  39
	call SysExBuf_ReadNibblePair                                      ; FB41EE  1d f3 77 fb
	ld H,A                                               ; FB41F2  c9 8e
	ld C,(XIX+0x0b)                                      ; FB41F4  8c 0b 23
	pushw bc                                             ; FB41F7  29
	pushw wa                                             ; FB41F8  28
	call Shl8ByCount                                      ; FB41F9  1d e6 81 fb
	ld L,A                                               ; FB41FD  c9 8f
	ld (0x60f812:24), a                                 ; FB41FF  f2 12 f8 60 41
	ld C,(XIX+0x09)                                      ; FB4204  8c 09 23
	pop XIY                                              ; FB4207  5d
	cp C,L                                               ; FB4208  cf f3
	jr ugt, .LFB421C                                     ; FB420A  6b 10
	ld H,(XIX+0x0a)                                      ; FB420C  8c 0a 26
	ld c, (0x60f812:24)                                 ; FB420F  c2 12 f8 60 23
	cp C,H                                               ; FB4214  ce f3
	jr ugt, .LFB421C                                     ; FB4216  6b 04
	call sub_FB3C34_Nop2                                      ; FB4218  1d 24 20 fb
.LFB421C:
	pop XIX                                              ; FB421C  5c
	popw hl                                              ; FB421D  4b
	unlk XIZ                                             ; FB421E  ee 0d
	ret                                                  ; FB4220  0e
	ret                                                  ; FB4221  0e
	ret                                                  ; FB4222  0e
; SysExParam_SetPlayModeRequest: setter of PLAY MODE REQUEST (receive-only).
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetPlayModeRequest:
	link XIZ,0xfffc                                      ; FB4223  ee 0c fc ff
	pushw hl                                             ; FB4227  2b
	push XIX                                             ; FB4228  3c
	ld XIX,(XIZ+0x08)                                    ; FB4229  ae 08 24
	ld xbc, (0x60fc80:24)                               ; FB422C  e2 80 fc 60 21
	push XBC                                             ; FB4231  39
	call SysExBuf_ReadNibblePair                                      ; FB4232  1d f3 77 fb
	ld H,A                                               ; FB4236  c9 8e
	ld (xiz-2), a                                        ; FB4238  be fe 41
	ld C,(XIX+0x09)                                      ; FB423B  8c 09 23
	pop XIY                                              ; FB423E  5d
	cp C,H                                               ; FB423F  ce f3
	jrl ugt, .LFB42A6                                    ; FB4241  7b 62 00
	ld L,(XIX+0x0a)                                      ; FB4244  8c 0a 27
	ld h, (xiz-2)                                        ; FB4247  8e fe 26
	cp H,L                                               ; FB424A  cf f6
	jr ugt, .LFB42A6                                     ; FB424C  6b 58
	ld L,(XIX+0x0e)                                      ; FB424E  8c 0e 27
	cp L,0xff                                            ; FB4251  cf cf ff
	jr z, .LFB42A6                                       ; FB4254  66 50
	cp l, 0x01:i3                                          ; FB4256  cf d9
	jr nc, .LFB42A6                                      ; FB4258  6f 4c
	ld C,(XIX+0x0b)                                      ; FB425A  8c 0b 23
	pushw bc                                             ; FB425D  29
	push 0x00                                            ; FB425E  09 00
	push H                                               ; FB4260  ce 04
	call Shl8ByCount                                      ; FB4262  1d e6 81 fb
	extz WA                                              ; FB4266  d8 12
	cp wa, 0x00:i3                                         ; FB4268  d8 d8
	jr z, .LFB4274                                       ; FB426A  66 08
	cp WA,0x0010                                         ; FB426C  d8 cf 10 00
	jr z, .LFB427A                                       ; FB4270  66 08
	jr .LFB427E                                          ; FB4272  68 0a
.LFB4274:
	call Mode_SwitchToSound_SaveRegs                                      ; FB4274  1d f1 7a fb
	jr .LFB427E                                          ; FB4278  68 04
.LFB427A:
	call Mode_SwitchToCombination_SaveRegs                                      ; FB427A  1d e4 7a fb
.LFB427E:
	ld C,(XIX+0x0e)                                      ; FB427E  8c 0e 23
	mul C,0x06                                           ; FB4281  cb 08 06
	extz XBC                                             ; FB4284  e9 12
	inc 2,XBC                                            ; FB4286  e9 62
	add XBC,RecordIndex_Count                            ; FB4288  e9 c8 88 1e f5 00
	ld XBC,(XBC)                                         ; FB428E  a1 21
	ld XIX,XBC                                           ; FB4290  e9 8c
	or	(UI_Request_Hi:16), 0x12                            ; FB4292  c1 71 20 3e 12
	ld a, (xiz-2)                                        ; FB4297  8e fe 21
	extz WA                                              ; FB429A  d8 12
	extz XWA                                             ; FB429C  e8 12
	add XBC,XWA                                          ; FB429E  e8 81
	ld A,(XBC)                                           ; FB42A0  81 21
	ld (UI_Request:16), a                                   ; FB42A2  f1 70 20 41
.LFB42A6:
	pop XIX                                              ; FB42A6  5c
	popw hl                                              ; FB42A7  4b
	unlk XIZ                                             ; FB42A8  ee 0d
	ret                                                  ; FB42AA  0e
; SysExParam_Request_DispatchGroup: command 0x1A, F0 50 2B one-parameter request: group = parse field 1, 1..7, through
;   SysExParam_Request_GroupTable.
SysExParam_Request_DispatchGroup:
	pushw 0x01                                           ; FB42AB  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB42AE  e2 d8 fc 60 21
	push XBC                                             ; FB42B3  39
	call U8Rec16_GetField                                      ; FB42B4  1d d3 62 fb
	extz WA                                              ; FB42B8  d8 12
	inc 6,XSP                                            ; FB42BA  ef 66
	extz XWA                                             ; FB42BC  e8 12
	dec 1,WA                                             ; FB42BE  d8 69
	cp wa, 0x06:i3                                         ; FB42C0  d8 de
	jr ugt, .LFB430E                                         ; FB42C2  6b 4a
	sll wa, 0x02                                         ; FB42C4  d8 ee 02
	add XWA,SysExParam_Request_GroupTable                             ; FB42C7  e8 c8 d1 42 fb 00
	ld XWA,(XWA)                                         ; FB42CD  a0 20
	jp (xwa)                                             ; FB42CF  b0 d8

; ---------------------------------------------------------------------
; SysExParam_Request_GroupTable -- 7 LE32 code addresses, an INLINE jump table
;
; Read by: ONE site, `add XWA,0x00FB42D1 / ld XWA,(XWA) / jp (XWA)` at
;          0xFB42C7-0xFB42CF.
; ENTRY COUNT 7: `dec 1,WA / cps wa,0x06 / jr ugt` at 0xFB42BE.  ★ LAST-ENTRY
;          TEST: entry 6 is 0x00FB430B and 0xFB42D1 + 7*4 = 0xFB42ED = entry 0's
;          target.  ⚠ This dispatcher and SysExParam_Set_GroupTable's have the SAME shape
;          and the same bound; nothing here says the two are copies.
; Evidence: the base is named by exactly one instruction, the `add Xrr,imm32`
;          quoted above, and the ENTRY COUNT is the ROM's own bound on the
;          index, not a guess at where the values stop looking like
;          addresses; the LAST-ENTRY TEST above is what makes the two agree.
; Unknown:  what the arms DO.  A jump table names its targets, not its
;          operations.
; ---------------------------------------------------------------------
SysExParam_Request_GroupTable:
	.long SysExParam_Request_Group1                                 ; FB42D1  [  0]
	.long SysExParam_Request_Group2                                 ; FB42D5  [  1]
	.long SysExParam_Request_Group3                                 ; FB42D9  [  2]
	.long SysExParam_Request_Group4                                 ; FB42DD  [  3]
	.long SysExParam_Request_Group5                                 ; FB42E1  [  4]
	.long SysExParam_Request_Group6                                 ; FB42E5  [  5]
	.long SysExParam_Request_Group7                                 ; FB42E9  [  6]
SysExParam_Request_Group1:   ; entry: named by 1 `.long` operand, first at 0xFB42D1
	calr SysExParam_Request_Area00_01                                      ; FB42ED  1e 1f 00
	jr .LFB430E                                          ; FB42F0  68 1c
SysExParam_Request_Group2:   ; entry: named by 1 `.long` operand, first at 0xFB42D5
	calr SysExParam_Request_Area08                                      ; FB42F2  1e 6e 00
	jr .LFB430E                                          ; FB42F5  68 17
SysExParam_Request_Group3:   ; entry: named by 1 `.long` operand, first at 0xFB42D9
	calr SysExParam_Request_Area10_11                                      ; FB42F7  1e bc 00
	jr .LFB430E                                          ; FB42FA  68 12
; SysExParam_Request_Group4: Arm [3] of SysExParam_Request_GroupTable (parameter REQUEST, F0 50 2B, group 4): calls an
;   empty `ret` (SysExParam_Request_Area10_11_Nop) and returns; the request twin of SysExParam_Set_Group4. Basis: table index + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
SysExParam_Request_Group4:   ; entry: named by 1 `.long` operand, first at 0xFB42DD
	calr SysExParam_Request_Area10_11_Nop                                      ; FB42FC  1e 0b 01
	jr .LFB430E                                          ; FB42FF  68 0d
SysExParam_Request_Group5:   ; entry: named by 1 `.long` operand, first at 0xFB42E1
	calr SysExParam_Request_PartGroup5                                      ; FB4301  1e 07 01
	jr .LFB430E                                          ; FB4304  68 08
SysExParam_Request_Group6:   ; entry: named by 1 `.long` operand, first at 0xFB42E5
	calr SysExParam_Request_PartGroup6                                      ; FB4306  1e 56 01
	jr .LFB430E                                          ; FB4309  68 03
SysExParam_Request_Group7:   ; entry: named by 1 `.long` operand, first at 0xFB42E9
	calr SysExParam_Request_Area60                                      ; FB430B  1e a5 01
.LFB430E:
	ret                                                  ; FB430E  0e
; SysExParam_Request_Area00_01: command 0x1A (F0 50 2B, a parameter REQUEST): desc = PtrTable_F51EEA[field 2 < 0x17];
;   if SysExParam_CheckConditions(desc) passes, call desc->+0x18.
SysExParam_Request_Area00_01:
	link XIZ,0xfffc                                      ; FB430F  ee 0c fc ff
	pushw hl                                             ; FB4313  2b
	push XIX                                             ; FB4314  3c
	pushw 0x02                                           ; FB4315  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB4318  e2 d8 fc 60 21
	push XBC                                             ; FB431D  39
	call U8Rec16_GetField                                      ; FB431E  1d d3 62 fb
	ld H,A                                               ; FB4322  c9 8e
	inc 6,XSP                                            ; FB4324  ef 66
	cp A,0x17                                            ; FB4326  c9 cf 17
	jr nc, .LFB435E                                      ; FB4329  6f 33
	mul A,0x04                                           ; FB432B  c9 08 04
	extz XWA                                             ; FB432E  e8 12
	ld XIX,XWA                                           ; FB4330  e8 8c
	add XWA,PtrTable_F51EEA                              ; FB4332  e8 c8 ea 1e f5 00
	ld XBC,(XWA)                                         ; FB4338  a0 21
	push XBC                                             ; FB433A  39
	calr SysExParam_CheckConditions                                      ; FB433B  1e 28 0d
	pop XIY                                              ; FB433E  5d
	cp WA,0xffff                                         ; FB433F  d8 cf ff ff
	jr z, .LFB435E                                       ; FB4343  66 19
	lda xbc, (PtrTable_F51EEA:24)                        ; FB4345  f2 ea 1e f5 31
	add XBC,XIX                                          ; FB434A  ec 81
	ld XWA,(XBC)                                         ; FB434C  a1 20
	ld (xiz-4), xwa                                      ; FB434E  be fc 60
	push XWA                                             ; FB4351  38
	ld XBC,(XWA+0x18)                                    ; FB4352  a8 18 21
	lda xiy, (.LFB435D:24)                               ; FB4355  f2 5d 43 fb 35
	push XIY                                             ; FB435A  3d
	jp (xbc)                                             ; FB435B  b1 d8
.LFB435D:
	pop XIY                                              ; FB435D  5d
.LFB435E:
	pop XIX                                              ; FB435E  5c
	popw hl                                              ; FB435F  4b
	unlk XIZ                                             ; FB4360  ee 0d
	ret                                                  ; FB4362  0e
; SysExParam_Request_Area08: as SysExParam_Request_Area00_01 over Pointer_F51F5A, index < 1 (only the placeholder: area 08 cannot be requested).
SysExParam_Request_Area08:
	link XIZ,0xfffc                                      ; FB4363  ee 0c fc ff
	pushw hl                                             ; FB4367  2b
	push XIX                                             ; FB4368  3c
	pushw 0x02                                           ; FB4369  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB436C  e2 d8 fc 60 21
	push XBC                                             ; FB4371  39
	call U8Rec16_GetField                                      ; FB4372  1d d3 62 fb
	ld H,A                                               ; FB4376  c9 8e
	inc 6,XSP                                            ; FB4378  ef 66
	cp a, 0x01:i3                                          ; FB437A  c9 d9
	jr nc, .LFB43B1                                      ; FB437C  6f 33
	mul A,0x04                                           ; FB437E  c9 08 04
	extz XWA                                             ; FB4381  e8 12
; (sub_FB4383 removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_Request_Area08;
;  notes/prom_a_stray_label_removal.py)
	ld XIX,XWA                                           ; FB4383  e8 8c
	add XWA,Pointer_F51F5A                               ; FB4385  e8 c8 5a 1f f5 00
	ld XBC,(XWA)                                         ; FB438B  a0 21
	push XBC                                             ; FB438D  39
	calr SysExParam_CheckConditions                                      ; FB438E  1e d5 0c
	pop XIY                                              ; FB4391  5d
	cp WA,0xffff                                         ; FB4392  d8 cf ff ff
	jr z, .LFB43B1                                       ; FB4396  66 19
	lda xbc, (Pointer_F51F5A:24)                         ; FB4398  f2 5a 1f f5 31
	add XBC,XIX                                          ; FB439D  ec 81
	ld XWA,(XBC)                                         ; FB439F  a1 20
	ld (xiz-4), xwa                                      ; FB43A1  be fc 60
	push XWA                                             ; FB43A4  38
	ld XBC,(XWA+0x18)                                    ; FB43A5  a8 18 21
	lda xiy, (.LFB43B0:24)                               ; FB43A8  f2 b0 43 fb 35
	push XIY                                             ; FB43AD  3d
	jp (xbc)                                             ; FB43AE  b1 d8
.LFB43B0:
	pop XIY                                              ; FB43B0  5d
.LFB43B1:
	pop XIX                                              ; FB43B1  5c
	popw hl                                              ; FB43B2  4b
	unlk XIZ                                             ; FB43B3  ee 0d
	ret                                                  ; FB43B5  0e
; SysExParam_Request_Area10_11: as SysExParam_Request_Area00_01 over PtrTable_F51FC2, index < 0x19.
SysExParam_Request_Area10_11:
	link XIZ,0xfffc                                      ; FB43B6  ee 0c fc ff
	pushw hl                                             ; FB43BA  2b
	push XIX                                             ; FB43BB  3c
	pushw 0x02                                           ; FB43BC  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB43BF  e2 d8 fc 60 21
	push XBC                                             ; FB43C4  39
	call U8Rec16_GetField                                      ; FB43C5  1d d3 62 fb
	ld H,A                                               ; FB43C9  c9 8e
	inc 6,XSP                                            ; FB43CB  ef 66
	cp A,0x19                                            ; FB43CD  c9 cf 19
	jr nc, .LFB4405                                      ; FB43D0  6f 33
	mul A,0x04                                           ; FB43D2  c9 08 04
	extz XWA                                             ; FB43D5  e8 12
	ld XIX,XWA                                           ; FB43D7  e8 8c
	add XWA,PtrTable_F51FC2                              ; FB43D9  e8 c8 c2 1f f5 00
	ld XBC,(XWA)                                         ; FB43DF  a0 21
	push XBC                                             ; FB43E1  39
	calr SysExParam_CheckConditions                                      ; FB43E2  1e 81 0c
	pop XIY                                              ; FB43E5  5d
	cp WA,0xffff                                         ; FB43E6  d8 cf ff ff
	jr z, .LFB4405                                       ; FB43EA  66 19
	lda xbc, (PtrTable_F51FC2:24)                        ; FB43EC  f2 c2 1f f5 31
	add XBC,XIX                                          ; FB43F1  ec 81
	ld XWA,(XBC)                                         ; FB43F3  a1 20
	ld (xiz-4), xwa                                      ; FB43F5  be fc 60
	push XWA                                             ; FB43F8  38
	ld XBC,(XWA+0x18)                                    ; FB43F9  a8 18 21
	lda xiy, (.LFB4404:24)                               ; FB43FC  f2 04 44 fb 35
	push XIY                                             ; FB4401  3d
	jp (xbc)                                             ; FB4402  b1 d8
.LFB4404:
	pop XIY                                              ; FB4404  5d
.LFB4405:
	pop XIX                                              ; FB4405  5c
	popw hl                                              ; FB4406  4b
	unlk XIZ                                             ; FB4407  ee 0d
	ret                                                  ; FB4409  0e
SysExParam_Request_Area10_11_Nop:
	ret                                                  ; FB440A  0e
; SysExParam_Request_PartGroup5: as SysExParam_Request_Area00_01 over PtrTable_F52072, index < 0x13.
SysExParam_Request_PartGroup5:
	link XIZ,0xfffc                                      ; FB440B  ee 0c fc ff
	pushw hl                                             ; FB440F  2b
	push XIX                                             ; FB4410  3c
	pushw 0x02                                           ; FB4411  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB4414  e2 d8 fc 60 21
	push XBC                                             ; FB4419  39
	call U8Rec16_GetField                                      ; FB441A  1d d3 62 fb
	ld H,A                                               ; FB441E  c9 8e
	inc 6,XSP                                            ; FB4420  ef 66
	cp A,0x13                                            ; FB4422  c9 cf 13
	jr nc, .LFB445A                                      ; FB4425  6f 33
	mul A,0x04                                           ; FB4427  c9 08 04
	extz XWA                                             ; FB442A  e8 12
	ld XIX,XWA                                           ; FB442C  e8 8c
	add XWA,PtrTable_F52072                              ; FB442E  e8 c8 72 20 f5 00
	ld XBC,(XWA)                                         ; FB4434  a0 21
	push XBC                                             ; FB4436  39
	calr SysExParam_CheckConditions                                      ; FB4437  1e 2c 0c
	pop XIY                                              ; FB443A  5d
	cp WA,0xffff                                         ; FB443B  d8 cf ff ff
	jr z, .LFB445A                                       ; FB443F  66 19
	lda xbc, (PtrTable_F52072:24)                        ; FB4441  f2 72 20 f5 31
	add XBC,XIX                                          ; FB4446  ec 81
	ld XWA,(XBC)                                         ; FB4448  a1 20
	ld (xiz-4), xwa                                      ; FB444A  be fc 60
	push XWA                                             ; FB444D  38
	ld XBC,(XWA+0x18)                                    ; FB444E  a8 18 21
	lda xiy, (.LFB4459:24)                               ; FB4451  f2 59 44 fb 35
	push XIY                                             ; FB4456  3d
	jp (xbc)                                             ; FB4457  b1 d8
.LFB4459:
	pop XIY                                              ; FB4459  5d
.LFB445A:
	pop XIX                                              ; FB445A  5c
	popw hl                                              ; FB445B  4b
	unlk XIZ                                             ; FB445C  ee 0d
	ret                                                  ; FB445E  0e
; SysExParam_Request_PartGroup6: as SysExParam_Request_Area00_01 over PtrTable_F5215E, index < 0x28.
SysExParam_Request_PartGroup6:
	link XIZ,0xfffc                                      ; FB445F  ee 0c fc ff
	pushw hl                                             ; FB4463  2b
	push XIX                                             ; FB4464  3c
	pushw 0x02                                           ; FB4465  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB4468  e2 d8 fc 60 21
	push XBC                                             ; FB446D  39
	call U8Rec16_GetField                                      ; FB446E  1d d3 62 fb
	ld H,A                                               ; FB4472  c9 8e
	inc 6,XSP                                            ; FB4474  ef 66
	cp A,0x28                                            ; FB4476  c9 cf 28
	jr nc, .LFB44AE                                      ; FB4479  6f 33
	mul A,0x04                                           ; FB447B  c9 08 04
	extz XWA                                             ; FB447E  e8 12
	ld XIX,XWA                                           ; FB4480  e8 8c
	add XWA,PtrTable_F5215E                              ; FB4482  e8 c8 5e 21 f5 00
	ld XBC,(XWA)                                         ; FB4488  a0 21
	push XBC                                             ; FB448A  39
	calr SysExParam_CheckConditions                                      ; FB448B  1e d8 0b
	pop XIY                                              ; FB448E  5d
	cp WA,0xffff                                         ; FB448F  d8 cf ff ff
	jr z, .LFB44AE                                       ; FB4493  66 19
	lda xbc, (PtrTable_F5215E:24)                        ; FB4495  f2 5e 21 f5 31
	add XBC,XIX                                          ; FB449A  ec 81
	ld XWA,(XBC)                                         ; FB449C  a1 20
	ld (xiz-4), xwa                                      ; FB449E  be fc 60
	push XWA                                             ; FB44A1  38
	ld XBC,(XWA+0x18)                                    ; FB44A2  a8 18 21
	lda xiy, (.LFB44AD:24)                               ; FB44A5  f2 ad 44 fb 35
	push XIY                                             ; FB44AA  3d
	jp (xbc)                                             ; FB44AB  b1 d8
.LFB44AD:
	pop XIY                                              ; FB44AD  5d
.LFB44AE:
	pop XIX                                              ; FB44AE  5c
	popw hl                                              ; FB44AF  4b
	unlk XIZ                                             ; FB44B0  ee 0d
	ret                                                  ; FB44B2  0e
; SysExParam_Request_Area60: as SysExParam_Request_Area00_01 over PtrTable_F52206, index < 2.
SysExParam_Request_Area60:
	link XIZ,0xfffc                                      ; FB44B3  ee 0c fc ff
	pushw hl                                             ; FB44B7  2b
	push XIX                                             ; FB44B8  3c
	pushw 0x02                                           ; FB44B9  0b 02 00
	ld xbc, (0x60fcd8:24)                               ; FB44BC  e2 d8 fc 60 21
	push XBC                                             ; FB44C1  39
	call U8Rec16_GetField                                      ; FB44C2  1d d3 62 fb
	ld H,A                                               ; FB44C6  c9 8e
	inc 6,XSP                                            ; FB44C8  ef 66
	cp a, 0x02:i3                                          ; FB44CA  c9 da
	jr nc, .LFB4501                                      ; FB44CC  6f 33
	mul A,0x04                                           ; FB44CE  c9 08 04
	extz XWA                                             ; FB44D1  e8 12
	ld XIX,XWA                                           ; FB44D3  e8 8c
	add XWA,PtrTable_F52206                              ; FB44D5  e8 c8 06 22 f5 00
	ld XBC,(XWA)                                         ; FB44DB  a0 21
	push XBC                                             ; FB44DD  39
	calr SysExParam_CheckConditions                                      ; FB44DE  1e 85 0b
	pop XIY                                              ; FB44E1  5d
	cp WA,0xffff                                         ; FB44E2  d8 cf ff ff
	jr z, .LFB4501                                       ; FB44E6  66 19
	lda xbc, (PtrTable_F52206:24)                        ; FB44E8  f2 06 22 f5 31
	add XBC,XIX                                          ; FB44ED  ec 81
	ld XWA,(XBC)                                         ; FB44EF  a1 20
	ld (xiz-4), xwa                                      ; FB44F1  be fc 60
	push XWA                                             ; FB44F4  38
	ld XBC,(XWA+0x18)                                    ; FB44F5  a8 18 21
	lda xiy, (.LFB4500:24)                               ; FB44F8  f2 00 45 fb 35
	push XIY                                             ; FB44FD  3d
	jp (xbc)                                             ; FB44FE  b1 d8
.LFB4500:
	pop XIY                                              ; FB4500  5d
.LFB4501:
	pop XIX                                              ; FB4501  5c
	popw hl                                              ; FB4502  4b
	unlk XIZ                                             ; FB4503  ee 0d
	ret                                                  ; FB4505  0e
; SysExParam_ReceiveOnly: a bare `ret` as the +0x18 reader of INITIAL, PLAY MODE REQUEST, COMBINATION WRITE REQUEST and SOUND WRITE REQUEST -- the four
;  parameters the Reference Guide marks receive-only: a request for them answers nothing.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_ReceiveOnly:
	ret                                                  ; FB4506  0e
; SysExParam_GetMemoryProtect: reader of SOUND / COMBINATION MEMORY PROTECT (target from 0xF51E58, as the pair setter).
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetMemoryProtect:
	link XIZ,0xfff0                                      ; FB4507  ee 0c f0 ff
	pushw hl                                             ; FB450B  2b
	push XIX                                             ; FB450C  3c
	lda xix, (xiz-12)                                    ; FB450D  be f4 34
	ld XBC,(XIZ+0x08)                                    ; FB4510  ae 08 21
	ld H,(XBC+0x0e)                                      ; FB4513  89 0e 26
	cp h, 0x04:i3                                          ; FB4516  ce dc
	jr nc, .LFB455D                                      ; FB4518  6f 43
	ld a, 0x06:opc                                          ; FB451A  21 06
	mul wa, h                                          ; FB451C  ce 41
	extz XWA                                             ; FB451E  e8 12
	inc 2,XWA                                            ; FB4520  e8 62
	add XWA,0x00f51e58                                   ; FB4522  e8 c8 58 1e f5 00
	ld XWA,(XWA)                                         ; FB4528  a0 20
	ld (xiz-16), xwa                                     ; FB452A  be f0 60
	ld A,(XBC+0x06)                                      ; FB452D  89 06 21
	ld (XIX),A                                           ; FB4530  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB4532  ae 08 21
	ld A,(XBC+0x07)                                      ; FB4535  89 07 21
	ld (XIX+0x01),A                                      ; FB4538  bc 01 41
	ld xbc, (xiz-16)                                     ; FB453B  ae f0 21
	ld A,(XBC)                                           ; FB453E  81 21
	ld (XIX+0x02),A                                      ; FB4540  bc 02 41
	ld XBC,(XIZ+0x08)                                    ; FB4543  ae 08 21
	ld A,(XBC+0x08)                                      ; FB4546  89 08 21
	ld (XIX+0x03),A                                      ; FB4549  bc 03 41
	ld (xiz-8), xix                                      ; FB454C  be f8 64
	ld XBC,(XIZ+0x08)                                    ; FB454F  ae 08 21
	ld (xiz-4), xbc                                      ; FB4552  be fc 61
	lda xbc, (xiz-8)                                     ; FB4555  be f8 31
	push XBC                                             ; FB4558  39
	calr SysExTx_SendParamValue                                      ; FB4559  1e 06 08
	pop XIY                                              ; FB455C  5d
.LFB455D:
	pop XIX                                              ; FB455D  5c
	popw hl                                              ; FB455E  4b
	unlk XIZ                                             ; FB455F  ee 0d
	ret                                                  ; FB4561  0e
; SysExParam_GetCommonField: the COMMON reader for a 2B request: IndexedTable_GetByteOr0(desc+6, desc+7), then SysExTx_SendParamValue; 41 parameters.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetCommonField:
	link XIZ,0xfff4                                      ; FB4562  ee 0c f4 ff
	push XIX                                             ; FB4566  3c
	ld XIX,(XIZ+0x08)                                    ; FB4567  ae 08 24
	ld C,(XIX+0x06)                                      ; FB456A  8c 06 23
	ld (xiz-4), c                                        ; FB456D  be fc 43
	ld C,(XIX+0x07)                                      ; FB4570  8c 07 23
	ld (xiz-3), c                                        ; FB4573  be fd 43
	ld C,(XIX+0x07)                                      ; FB4576  8c 07 23
	extz BC                                              ; FB4579  d9 12
	pushw bc                                             ; FB457B  29
	ld C,(XIX+0x06)                                      ; FB457C  8c 06 23
	extz BC                                              ; FB457F  d9 12
	pushw bc                                             ; FB4581  29
	call IndexedTable_GetByteOr0                                      ; FB4582  1d 02 7a fb
	ld (xiz-2), a                                        ; FB4586  be fe 41
	ld C,(XIX+0x08)                                      ; FB4589  8c 08 23
	ld (xiz-1), c                                        ; FB458C  be ff 43
	lda xbc, (xiz-4)                                     ; FB458F  be fc 31
	ld (xiz-12), xbc                                     ; FB4592  be f4 61
	ld (xiz-8), xix                                      ; FB4595  be f8 64
	lda xbc, (xiz-12)                                    ; FB4598  be f4 31
	push XBC                                             ; FB459B  39
	calr SysExTx_SendParamValue                                      ; FB459C  1e c3 07
	inc 8,XSP                                            ; FB459F  ef 60
	pop XIX                                              ; FB45A1  5c
	unlk XIZ                                             ; FB45A2  ee 0d
	ret                                                  ; FB45A4  0e
; SysExParam_GetMainOutEqualizerFreq: reader of MAIN OUT EQUALIZER LOW-FREQ / HIGH-FREQ.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetMainOutEqualizerFreq:
	link XIZ,0xfff2                                      ; FB45A5  ee 0c f2 ff
	pushw hl                                             ; FB45A9  2b
	pushw de                                             ; FB45AA  2a
	push XIX                                             ; FB45AB  3c
	ld XIX,(XIZ+0x08)                                    ; FB45AC  ae 08 24
	ld C,(XIX+0x07)                                      ; FB45AF  8c 07 23
	extz BC                                              ; FB45B2  d9 12
	pushw bc                                             ; FB45B4  29
	ld C,(XIX+0x06)                                      ; FB45B5  8c 06 23
	extz BC                                              ; FB45B8  d9 12
	pushw bc                                             ; FB45BA  29
	call IndexedTable_GetByteOr0                                      ; FB45BB  1d 02 7a fb
	extz WA                                              ; FB45BF  d8 12
	ld HL,WA                                             ; FB45C1  d8 8b
	ld C,(XIX+0x07)                                      ; FB45C3  8c 07 23
	extz BC                                              ; FB45C6  d9 12
	inc 1,BC                                             ; FB45C8  d9 61
	pushw bc                                             ; FB45CA  29
	ld C,(XIX+0x06)                                      ; FB45CB  8c 06 23
	extz BC                                              ; FB45CE  d9 12
	pushw bc                                             ; FB45D0  29
	call IndexedTable_GetByteOr0                                      ; FB45D1  1d 02 7a fb
	extz WA                                              ; FB45D5  d8 12
	sll wa, 0x08                                         ; FB45D7  d8 ee 08
	ld DE,WA                                             ; FB45DA  d8 8a
	or DE,HL                                             ; FB45DC  db e2
	ld C,(XIX+0x06)                                      ; FB45DE  8c 06 23
	ld (xiz-6), c                                        ; FB45E1  be fa 43
	ld C,(XIX+0x07)                                      ; FB45E4  8c 07 23
	ld (xiz-5), c                                        ; FB45E7  be fb 43
	ld (xiz-4), de                                       ; FB45EA  be fc 52
	ld C,(XIX+0x08)                                      ; FB45ED  8c 08 23
	extz BC                                              ; FB45F0  d9 12
	ld HL,BC                                             ; FB45F2  d9 8b
	ld A,(XIX+0x0b)                                      ; FB45F4  8c 0b 21
	pushw wa                                             ; FB45F7  28
	pushw bc                                             ; FB45F8  29
	call Shl16ByCount                                      ; FB45F9  1d 07 82 fb
	ld (xiz-2), wa                                       ; FB45FD  be fe 50
	lda xbc, (xiz-6)                                     ; FB4600  be fa 31
	ld (xiz-14), xbc                                     ; FB4603  be f2 61
	ld (xiz-10), xix                                     ; FB4606  be f6 64
	lda xbc, (xiz-14)                                    ; FB4609  be f2 31
	push XBC                                             ; FB460C  39
	calr SysExTx_SendWordFieldParamValue                                      ; FB460D  1e 10 08
	inc 8,XSP                                            ; FB4610  ef 60
	inc 4,XSP                                            ; FB4612  ef 64
	pop XIX                                              ; FB4614  5c
	popw de                                              ; FB4615  4a
	popw hl                                              ; FB4616  4b
	unlk XIZ                                             ; FB4617  ee 0d
	ret                                                  ; FB4619  0e
; SysExParam_GetCombinationNumberAndBank: reader of COMBINATION NUMBER and BANK.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetCombinationNumberAndBank:
	link XIZ,0xfff4                                      ; FB461A  ee 0c f4 ff
	push XIX                                             ; FB461E  3c
	lda xix, (xiz-12)                                    ; FB461F  be f4 34
	ld XBC,(XIZ+0x08)                                    ; FB4622  ae 08 21
	ld A,(XBC+0x06)                                      ; FB4625  89 06 21
	ld (XIX),A                                           ; FB4628  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB462A  ae 08 21
	ld A,(XBC+0x07)                                      ; FB462D  89 07 21
	ld (XIX+0x01),A                                      ; FB4630  bc 01 41
	ld (XIX+0x02),0x00                                   ; FB4633  bc 02 00 00
	ld XBC,(XIZ+0x08)                                    ; FB4637  ae 08 21
	ld A,(XBC+0x08)                                      ; FB463A  89 08 21
	ld (XIX+0x03),A                                      ; FB463D  bc 03 41
	ld (xiz-8), xix                                      ; FB4640  be f8 64
	ld XBC,(XIZ+0x08)                                    ; FB4643  ae 08 21
	ld (xiz-4), xbc                                      ; FB4646  be fc 61
	lda xbc, (xiz-8)                                     ; FB4649  be f8 31
	push XBC                                             ; FB464C  39
	calr SysExTx_CombinationNumberAndBank                                      ; FB464D  1e 1d 0d
	pop XBC                                              ; FB4650  59
	pop XIX                                              ; FB4651  5c
	unlk XIZ                                             ; FB4652  ee 0d
	ret                                                  ; FB4654  0e
	link XIZ,0xfff4                                      ; FB4655  ee 0c f4 ff
	push XIX                                             ; FB4659  3c
	ld XIX,(XIZ+0x08)                                    ; FB465A  ae 08 24
	ld C,(XIX+0x06)                                      ; FB465D  8c 06 23
	ld (xiz-4), c                                        ; FB4660  be fc 43
	ld C,(XIX+0x07)                                      ; FB4663  8c 07 23
	ld (xiz-3), c                                        ; FB4666  be fd 43
	ld C,(XIX+0x07)                                      ; FB4669  8c 07 23
	extz BC                                              ; FB466C  d9 12
	pushw bc                                             ; FB466E  29
	ld C,(XIX+0x06)                                      ; FB466F  8c 06 23
	extz BC                                              ; FB4672  d9 12
	pushw bc                                             ; FB4674  29
	call IndexedTable_GetByteOr0                                      ; FB4675  1d 02 7a fb
	ld (xiz-2), a                                        ; FB4679  be fe 41
	ld C,(XIX+0x08)                                      ; FB467C  8c 08 23
	ld (xiz-1), c                                        ; FB467F  be ff 43
	lda xbc, (xiz-4)                                     ; FB4682  be fc 31
	ld (xiz-12), xbc                                     ; FB4685  be f4 61
	ld (xiz-8), xix                                      ; FB4688  be f8 64
	lda xbc, (xiz-12)                                    ; FB468B  be f4 31
	push XBC                                             ; FB468E  39
	calr sub_FB4ED4                                      ; FB468F  1e 42 08
	inc 8,XSP                                            ; FB4692  ef 60
	pop XIX                                              ; FB4694  5c
	unlk XIZ                                             ; FB4695  ee 0d
	ret                                                  ; FB4697  0e
; SysExParam_GetPartField: the PART reader for a 2B request: 49 parameters, the ones SysExParam_SetPartField writes.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetPartField:
	link XIZ,0xfff4                                      ; FB4698  ee 0c f4 ff
	pushw hl                                             ; FB469C  2b
	push XIX                                             ; FB469D  3c
	lda xix, (xiz-12)                                    ; FB469E  be f4 34
	pushw 0x0a                                           ; FB46A1  0b 0a 00
	ld xbc, (0x60fcd8:24)                               ; FB46A4  e2 d8 fc 60 21
	push XBC                                             ; FB46A9  39
	call U8Rec16_GetField                                      ; FB46AA  1d d3 62 fb
	ld H,A                                               ; FB46AE  c9 8e
	sub H,0x20                                           ; FB46B0  ce ca 20
	ld XBC,(XIZ+0x08)                                    ; FB46B3  ae 08 21
	ld A,(XBC+0x06)                                      ; FB46B6  89 06 21
	ld L,A                                               ; FB46B9  c9 8f
	or L,H                                               ; FB46BB  ce e7
	ld (XIX),L                                           ; FB46BD  b4 47
	ld XBC,(XIZ+0x08)                                    ; FB46BF  ae 08 21
	ld A,(XBC+0x07)                                      ; FB46C2  89 07 21
	ld (XIX+0x01),A                                      ; FB46C5  bc 01 41
	ld XBC,(XIZ+0x08)                                    ; FB46C8  ae 08 21
	ld A,(XBC+0x07)                                      ; FB46CB  89 07 21
	extz WA                                              ; FB46CE  d8 12
	pushw wa                                             ; FB46D0  28
	ld A,L                                               ; FB46D1  cf 89
	extz WA                                              ; FB46D3  d8 12
	pushw wa                                             ; FB46D5  28
	call IndexedTable_GetByteOr0                                      ; FB46D6  1d 02 7a fb
	ld (XIX+0x02),A                                      ; FB46DA  bc 02 41
	ld XBC,(XIZ+0x08)                                    ; FB46DD  ae 08 21
	ld A,(XBC+0x08)                                      ; FB46E0  89 08 21
	ld (XIX+0x03),A                                      ; FB46E3  bc 03 41
	ld (xiz-8), xix                                      ; FB46E6  be f8 64
	ld XBC,(XIZ+0x08)                                    ; FB46E9  ae 08 21
	ld (xiz-4), xbc                                      ; FB46EC  be fc 61
	lda xbc, (xiz-8)                                     ; FB46EF  be f8 31
	push XBC                                             ; FB46F2  39
	calr SysExTx_SendPartParamValue                                      ; FB46F3  1e 99 08
	inc 8,XSP                                            ; FB46F6  ef 60
	inc 6,XSP                                            ; FB46F8  ef 66
	pop XIX                                              ; FB46FA  5c
	popw hl                                              ; FB46FB  4b
	unlk XIZ                                             ; FB46FC  ee 0d
	ret                                                  ; FB46FE  0e
; SysExParam_GetProgramChangeAndBank: reader of PROGRAM CHANGE & BANK.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetProgramChangeAndBank:
	link XIZ,0xfff4                                      ; FB46FF  ee 0c f4 ff
	pushw hl                                             ; FB4703  2b
	push XIX                                             ; FB4704  3c
	lda xix, (xiz-12)                                    ; FB4705  be f4 34
	pushw 0x0a                                           ; FB4708  0b 0a 00
	ld xbc, (0x60fcd8:24)                               ; FB470B  e2 d8 fc 60 21
	push XBC                                             ; FB4710  39
	call U8Rec16_GetField                                      ; FB4711  1d d3 62 fb
	ld H,A                                               ; FB4715  c9 8e
	sub H,0x20                                           ; FB4717  ce ca 20
	ld XBC,(XIZ+0x08)                                    ; FB471A  ae 08 21
	ld A,(XBC+0x06)                                      ; FB471D  89 06 21
	or A,H                                               ; FB4720  ce e1
	ld (XIX),A                                           ; FB4722  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB4724  ae 08 21
	ld A,(XBC+0x07)                                      ; FB4727  89 07 21
	ld (XIX+0x01),A                                      ; FB472A  bc 01 41
	ld (XIX+0x02),0x00                                   ; FB472D  bc 02 00 00
	ld XBC,(XIZ+0x08)                                    ; FB4731  ae 08 21
	ld A,(XBC+0x08)                                      ; FB4734  89 08 21
	ld (XIX+0x03),A                                      ; FB4737  bc 03 41
	ld (xiz-8), xix                                      ; FB473A  be f8 64
	ld XBC,(XIZ+0x08)                                    ; FB473D  ae 08 21
	ld (xiz-4), xbc                                      ; FB4740  be fc 61
	lda xbc, (xiz-8)                                     ; FB4743  be f8 31
	push XBC                                             ; FB4746  39
	calr SysExTx_ProgramChangeAndBank                                      ; FB4747  1e db 0c
	inc 8,XSP                                            ; FB474A  ef 60
	inc 2,XSP                                            ; FB474C  ef 62
	pop XIX                                              ; FB474E  5c
	popw hl                                              ; FB474F  4b
	unlk XIZ                                             ; FB4750  ee 0d
	ret                                                  ; FB4752  0e
; SysExParam_GetMidiMultipleMessagesOutput: reader of the five MIDI MULTIPLE MESSAGES OUTPUT parameters.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetMidiMultipleMessagesOutput:
	link XIZ,0xfff2                                      ; FB4753  ee 0c f2 ff
	pushw hl                                             ; FB4757  2b
	pushw de                                             ; FB4758  2a
	push XIX                                             ; FB4759  3c
	lda xix, (xiz-3)                                     ; FB475A  be fd 34
	push XIX                                             ; FB475D  3c
	ldw bc, 0x03                                         ; FB475E  31 03 00
	lda xiy, (0xf4fa79:24)                               ; FB4761  f2 79 fa f4 35
	lda xix, (xiz-3)                                     ; FB4766  be fd 34
	ldir85                                               ; FB4769  85 11
	pop XIX                                              ; FB476B  5c
	ld XBC,(XIZ+0x08)                                    ; FB476C  ae 08 21
	ld A,(XBC+0x0e)                                      ; FB476F  89 0e 21
	cp a, 0x05:i3                                          ; FB4772  c9 dd
	jrl nc, .LFB4844                                     ; FB4774  7f cd 00
	push XBC                                             ; FB4777  39
	calr SysExParam_CheckConditions                                      ; FB4778  1e eb 08
	pop XIY                                              ; FB477B  5d
	cp WA,0xffff                                         ; FB477C  d8 cf ff ff
	jrl z, .LFB4844                                      ; FB4780  76 c1 00
	pushw 0x0a                                           ; FB4783  0b 0a 00
	ld xbc, (0x60fcd8:24)                               ; FB4786  e2 d8 fc 60 21
	push XBC                                             ; FB478B  39
	call U8Rec16_GetField                                      ; FB478C  1d d3 62 fb
	ld L,A                                               ; FB4790  c9 8f
	sub L,0x20                                           ; FB4792  cf ca 20
	ld XBC,(XIZ+0x08)                                    ; FB4795  ae 08 21
	ld H,(XBC+0x06)                                      ; FB4798  89 06 26
	ld A,L                                               ; FB479B  cf 89
	or H,A                                               ; FB479D  c9 e6
	ld A,(XBC+0x07)                                      ; FB479F  89 07 21
	extz WA                                              ; FB47A2  d8 12
	pushw wa                                             ; FB47A4  28
	ld A,H                                               ; FB47A5  ce 89
	extz WA                                              ; FB47A7  d8 12
	ld DE,WA                                             ; FB47A9  d8 8a
	pushw wa                                             ; FB47AB  28
	call IndexedTable_GetByteOr0                                      ; FB47AC  1d 02 7a fb
	ld (XIX),A                                           ; FB47B0  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB47B2  ae 08 21
	ld A,(XBC+0x0e)                                      ; FB47B5  89 0e 21
	mul A,0x04                                           ; FB47B8  c9 08 04
	extz XWA                                             ; FB47BB  e8 12
	add XWA,PtrTable_F51E70                              ; FB47BD  e8 c8 70 1e f5 00
	ld XWA,(XWA)                                         ; FB47C3  a0 20
	ld (xiz-14), xwa                                     ; FB47C5  be f2 60
	ld C,(XWA+0x01)                                      ; FB47C8  88 01 23
	extz BC                                              ; FB47CB  d9 12
	pushw bc                                             ; FB47CD  29
	pushw de                                             ; FB47CE  2a
	call IndexedTable_GetByteOr0                                      ; FB47CF  1d 02 7a fb
	ld L,A                                               ; FB47D3  c9 8f
	ld xbc, (xiz-14)                                     ; FB47D5  ae f2 21
	ld W,(XBC+0x03)                                      ; FB47D8  89 03 20
	and A,W                                              ; FB47DB  c8 c1
	inc 8,XSP                                            ; FB47DD  ef 60
	inc 6,XSP                                            ; FB47DF  ef 66
	jr z, .LFB47E6                                       ; FB47E1  66 03
	ld (XIX),0x81                                        ; FB47E3  b4 00 81
.LFB47E6:
	pushw 0x06                                           ; FB47E6  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB47E9  f2 f2 fe f4 31
	push XBC                                             ; FB47EE  39
	call SysExTx_Append                                      ; FB47EF  1d 24 6f fb
	pushw 0x06                                           ; FB47F3  0b 06 00
	lda xbc, (xiz-10)                                    ; FB47F6  be f6 31
	push XBC                                             ; FB47F9  39
	ld XWA,(XIZ+0x08)                                    ; FB47FA  ae 08 20
	push XWA                                             ; FB47FD  38
	call MemCopyWords_Copy                                      ; FB47FE  1d ce 81 fb
	ld C,H                                               ; FB4802  ce 8b
	add C,0x20                                           ; FB4804  cb c8 20
	ld (xiz-9), c                                        ; FB4807  be f7 43
	pushw 0x06                                           ; FB480A  0b 06 00
	lda xbc, (xiz-10)                                    ; FB480D  be f6 31
	push XBC                                             ; FB4810  39
	call SysExTx_Append                                      ; FB4811  1d 24 6f fb
	ld C,(XIX)                                           ; FB4815  84 23
	and C,0x0f                                           ; FB4817  cb cc 0f
	ld (XIX+0x01),C                                      ; FB481A  bc 01 43
	ld C,(XIX)                                           ; FB481D  84 23
	srl c, 0x04                                          ; FB481F  cb ef 04
	ld (XIX),C                                           ; FB4822  b4 43
	pushw 0x03                                           ; FB4824  0b 03 00
	push XIX                                             ; FB4827  3c
	call SysExTx_Append                                      ; FB4828  1d 24 6f fb
	call SysExTx_AppendChecksumF7                                      ; FB482C  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB4830  e2 88 fc 60 21
	push XBC                                             ; FB4835  39
	call SysExTx_SendFrameBothPorts                                      ; FB4836  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB483A  1d 81 80 fb
	add XSP,0x00000020                                   ; FB483E  ef c8 20 00 00 00
.LFB4844:
	pop XIX                                              ; FB4844  5c
	popw de                                              ; FB4845  4a
	popw hl                                              ; FB4846  4b
	unlk XIZ                                             ; FB4847  ee 0d
	ret                                                  ; FB4849  0e
; SysExParam_GetMidiMultipleMessagesOutputBankSelect: reader of MIDI MULTIPLE MESSAGES OUTPUT: BANK SELECT.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetMidiMultipleMessagesOutputBankSelect:
	link XIZ,0xfff4                                      ; FB484A  ee 0c f4 ff
	pushw hl                                             ; FB484E  2b
	pushw de                                             ; FB484F  2a
	push XIX                                             ; FB4850  3c
	lda xix, (xiz-5)                                     ; FB4851  be fb 34
	push XIX                                             ; FB4854  3c
	ldw bc, 0x05                                         ; FB4855  31 05 00
	lda xiy, (0xf4fa7c:24)                               ; FB4858  f2 7c fa f4 35
	lda xix, (xiz-5)                                     ; FB485D  be fb 34
	ldir85                                               ; FB4860  85 11
	pop XIX                                              ; FB4862  5c
	ld XBC,(XIZ+0x08)                                    ; FB4863  ae 08 21
	push XBC                                             ; FB4866  39
	calr SysExParam_CheckConditions                                      ; FB4867  1e fc 07
	pop XIY                                              ; FB486A  5d
	cp WA,0xffff                                         ; FB486B  d8 cf ff ff
	jrl z, .LFB4968                                      ; FB486F  76 f6 00
	pushw 0x0a                                           ; FB4872  0b 0a 00
	ld xbc, (0x60fcd8:24)                               ; FB4875  e2 d8 fc 60 21
	push XBC                                             ; FB487A  39
	call U8Rec16_GetField                                      ; FB487B  1d d3 62 fb
	ld L,A                                               ; FB487F  c9 8f
	sub L,0x20                                           ; FB4881  cf ca 20
	ld XBC,(XIZ+0x08)                                    ; FB4884  ae 08 21
	ld H,(XBC+0x06)                                      ; FB4887  89 06 26
	ld A,L                                               ; FB488A  cf 89
	or H,A                                               ; FB488C  c9 e6
	ld A,(XBC+0x07)                                      ; FB488E  89 07 21
	extz WA                                              ; FB4891  d8 12
	pushw wa                                             ; FB4893  28
	ld A,H                                               ; FB4894  ce 89
	extz WA                                              ; FB4896  d8 12
	ld DE,WA                                             ; FB4898  d8 8a
	pushw wa                                             ; FB489A  28
	call IndexedTable_GetByteOr0                                      ; FB489B  1d 02 7a fb
	ld (XIX+0x02),A                                      ; FB489F  bc 02 41
	ld XBC,(XIZ+0x08)                                    ; FB48A2  ae 08 21
	ld A,(XBC+0x07)                                      ; FB48A5  89 07 21
	extz WA                                              ; FB48A8  d8 12
	inc 1,WA                                             ; FB48AA  d8 61
	pushw wa                                             ; FB48AC  28
	pushw de                                             ; FB48AD  2a
	call IndexedTable_GetByteOr0                                      ; FB48AE  1d 02 7a fb
	res 0x07,A                                           ; FB48B2  c9 30 07
	ld (XIX),A                                           ; FB48B5  b4 41
	pushw 0x15                                           ; FB48B7  0b 15 00
	pushw de                                             ; FB48BA  2a
	call IndexedTable_GetByteOr0                                      ; FB48BB  1d 02 7a fb
	and A,0x20                                           ; FB48BF  c9 cc 20
	add XSP,0x00000012                                   ; FB48C2  ef c8 12 00 00 00
	cp a, 0x00:i3                                          ; FB48C8  c9 d8
	jr z, .LFB48D5                                       ; FB48CA  66 09
	ld (XIX),0x80                                        ; FB48CC  b4 00 80
	ld (XIX+0x02),0x01                                   ; FB48CF  bc 02 00 01
	jr .LFB48E4                                          ; FB48D3  68 0f
.LFB48D5:
	ld C,(XIX+0x02)                                      ; FB48D5  8c 02 23
	and C,0x80                                           ; FB48D8  cb cc 80
	jr z, .LFB48E4                                       ; FB48DB  66 07
	ld (XIX),0x80                                        ; FB48DD  b4 00 80
	ld (XIX+0x02),0x00                                   ; FB48E0  bc 02 00 00
.LFB48E4:
	pushw 0x06                                           ; FB48E4  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB48E7  f2 f2 fe f4 31
	push XBC                                             ; FB48EC  39
	call SysExTx_Append                                      ; FB48ED  1d 24 6f fb
	pushw 0x06                                           ; FB48F1  0b 06 00
	lda xbc, (xiz-12)                                    ; FB48F4  be f4 31
	push XBC                                             ; FB48F7  39
	ld XWA,(XIZ+0x08)                                    ; FB48F8  ae 08 20
	push XWA                                             ; FB48FB  38
	call MemCopyWords_Copy                                      ; FB48FC  1d ce 81 fb
	ld C,H                                               ; FB4900  ce 8b
	add C,0x20                                           ; FB4902  cb c8 20
	ld (xiz-11), c                                       ; FB4905  be f5 43
	pushw 0x06                                           ; FB4908  0b 06 00
	lda xbc, (xiz-12)                                    ; FB490B  be f4 31
	push XBC                                             ; FB490E  39
	call SysExTx_Append                                      ; FB490F  1d 24 6f fb
	ld C,(XIX)                                           ; FB4913  84 23
	and C,0x01                                           ; FB4915  cb cc 01
	sll c, 0x07                                          ; FB4918  cb ee 07
	or (XIX+0x02),C                                      ; FB491B  8c 02 eb
	ld C,(XIX)                                           ; FB491E  84 23
	ld H,C                                               ; FB4920  cb 8e
	srl h, 0x01                                          ; FB4922  ce ef 01
	ld (XIX),H                                           ; FB4925  b4 46
	ld C,H                                               ; FB4927  ce 8b
	and C,0x0f                                           ; FB4929  cb cc 0f
	ld (XIX+0x01),C                                      ; FB492C  bc 01 43
	ld C,(XIX)                                           ; FB492F  84 23
	srl c, 0x04                                          ; FB4931  cb ef 04
	ld (XIX),C                                           ; FB4934  b4 43
	ld C,(XIX+0x02)                                      ; FB4936  8c 02 23
	and C,0x0f                                           ; FB4939  cb cc 0f
	ld (XIX+0x03),C                                      ; FB493C  bc 03 43
	ld C,(XIX+0x02)                                      ; FB493F  8c 02 23
	srl c, 0x04                                          ; FB4942  cb ef 04
	ld (XIX+0x02),C                                      ; FB4945  bc 02 43
	pushw 0x05                                           ; FB4948  0b 05 00
	push XIX                                             ; FB494B  3c
	call SysExTx_Append                                      ; FB494C  1d 24 6f fb
	call SysExTx_AppendChecksumF7                                      ; FB4950  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB4954  e2 88 fc 60 21
	push XBC                                             ; FB4959  39
	call SysExTx_SendFrameBothPorts                                      ; FB495A  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB495E  1d 81 80 fb
	add XSP,0x00000020                                   ; FB4962  ef c8 20 00 00 00
.LFB4968:
	pop XIX                                              ; FB4968  5c
	popw de                                              ; FB4969  4a
	popw hl                                              ; FB496A  4b
	unlk XIZ                                             ; FB496B  ee 0d
	ret                                                  ; FB496D  0e
; SysExParam_GetEffect2OnOff: reader of EFFECT2 ON/OFF.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetEffect2OnOff:
	link XIZ,0xfff0                                      ; FB496E  ee 0c f0 ff
	pushw hl                                             ; FB4972  2b
	pushw de                                             ; FB4973  2a
	push XIX                                             ; FB4974  3c
	ld XIX,(XIZ+0x08)                                    ; FB4975  ae 08 24
	ld C,(XIX+0x0e)                                      ; FB4978  8c 0e 23
	cp C,0xff                                            ; FB497B  cb cf ff
	jrl z, .LFB49F9                                      ; FB497E  76 78 00
	pushw 0x0a                                           ; FB4981  0b 0a 00
	ld xbc, (0x60fcd8:24)                               ; FB4984  e2 d8 fc 60 21
	push XBC                                             ; FB4989  39
	call U8Rec16_GetField                                      ; FB498A  1d d3 62 fb
	ld D,A                                               ; FB498E  c9 8c
	sub D,0x20                                           ; FB4990  cc ca 20
	ld L,(XIX+0x06)                                      ; FB4993  8c 06 27
	ld C,D                                               ; FB4996  cc 8b
	or L,C                                               ; FB4998  cb e7
	ld H,(XIX+0x0e)                                      ; FB499A  8c 0e 26
	inc 6,XSP                                            ; FB499D  ef 66
	cp h, 0x01:i3                                          ; FB499F  ce d9
	jr nc, .LFB49F9                                      ; FB49A1  6f 56
	ld c, 0x04:opc                                          ; FB49A3  23 04
	mul bc, h                                          ; FB49A5  ce 43
	extz XBC                                             ; FB49A7  e9 12
	add XBC,Pointer_F51E84                               ; FB49A9  e9 c8 84 1e f5 00
; (sub_FB49AF removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_Request_Area60;
;  notes/prom_a_stray_label_removal.py)
	ld XBC,(XBC)                                         ; FB49AF  a1 21
	ld (xiz-16), xbc                                     ; FB49B1  be f0 61
	ld A,(XIX+0x07)                                      ; FB49B4  8c 07 21
	extz WA                                              ; FB49B7  d8 12
	pushw wa                                             ; FB49B9  28
	ld A,L                                               ; FB49BA  cf 89
	extz WA                                              ; FB49BC  d8 12
	pushw wa                                             ; FB49BE  28
	call IndexedTable_GetByteOr0                                      ; FB49BF  1d 02 7a fb
	ld H,A                                               ; FB49C3  c9 8e
	ld xbc, (xiz-16)                                     ; FB49C5  ae f0 21
	ld W,(XBC)                                           ; FB49C8  81 20
	pop XIY                                              ; FB49CA  5d
	cp A,W                                               ; FB49CB  c8 f1
	jr ugt, .LFB49D5                                     ; FB49CD  6b 06
	ld (xiz-2), 0x00                                     ; FB49CF  be fe 00 00
	jr .LFB49D9                                          ; FB49D3  68 04
.LFB49D5:
	ld (xiz-2), 0x01                                     ; FB49D5  be fe 00 01
.LFB49D9:
	ld (xiz-4), l                                        ; FB49D9  be fc 47
	ld C,(XIX+0x07)                                      ; FB49DC  8c 07 23
	ld (xiz-3), c                                        ; FB49DF  be fd 43
	ld C,(XIX+0x08)                                      ; FB49E2  8c 08 23
	ld (xiz-1), c                                        ; FB49E5  be ff 43
	lda xbc, (xiz-4)                                     ; FB49E8  be fc 31
	ld (xiz-12), xbc                                     ; FB49EB  be f4 61
	ld (xiz-8), xix                                      ; FB49EE  be f8 64
	lda xbc, (xiz-12)                                    ; FB49F1  be f4 31
	push XBC                                             ; FB49F4  39
	calr SysExTx_SendPartParamValue                                      ; FB49F5  1e 97 05
	pop XIY                                              ; FB49F8  5d
.LFB49F9:
	pop XIX                                              ; FB49F9  5c
	popw de                                              ; FB49FA  4a
	popw hl                                              ; FB49FB  4b
	unlk XIZ                                             ; FB49FC  ee 0d
	ret                                                  ; FB49FE  0e
; SysExParam_GetEffect1Type: reader of EFFECT1 TYPE.
;  Descriptor field: +0x18.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_GetEffect1Type:
	link XIZ,0xfff6                                      ; FB49FF  ee 0c f6 ff
	pushw hl                                             ; FB4A03  2b
	push XIX                                             ; FB4A04  3c
	lda xix, (xiz-3)                                     ; FB4A05  be fd 34
	push XIX                                             ; FB4A08  3c
	ldw bc, 0x03                                         ; FB4A09  31 03 00
	lda xiy, (0xf4fa81:24)                               ; FB4A0C  f2 81 fa f4 35
	lda xix, (xiz-3)                                     ; FB4A11  be fd 34
	ldir85                                               ; FB4A14  85 11
	pop XIX                                              ; FB4A16  5c
	pushw 0x0b                                           ; FB4A17  0b 0b 00
	ld xbc, (0x60fcd8:24)                               ; FB4A1A  e2 d8 fc 60 21
	push XBC                                             ; FB4A1F  39
	call U8Rec16_GetField                                      ; FB4A20  1d d3 62 fb
	extz WA                                              ; FB4A24  d8 12
	extz XWA                                             ; FB4A26  e8 12
	add XWA,0x00f4fa9c                                   ; FB4A28  e8 c8 9c fa f4 00
	ld H,(XWA)                                           ; FB4A2E  80 26
	inc 6,XSP                                            ; FB4A30  ef 66
	cp H,0xff                                            ; FB4A32  ce cf ff
	jrl z, .LFB4ABC                                      ; FB4A35  76 84 00
	push XIX                                             ; FB4A38  3c
	pushw 0x01                                           ; FB4A39  0b 01 00
	ld C,H                                               ; FB4A3C  ce 8b
	extz BC                                              ; FB4A3E  d9 12
	pushw bc                                             ; FB4A40  29
	call T_DspParam_ReadByNumber                                        ; FB4A41  1d a4 34 f4
	ld XBC,(XIZ+0x08)                                    ; FB4A45  ae 08 21
	push XBC                                             ; FB4A48  39
	calr SysExParam_CheckConditions                                      ; FB4A49  1e 1a 06
	inc 8,XSP                                            ; FB4A4C  ef 60
	inc 4,XSP                                            ; FB4A4E  ef 64
	cp WA,0xffff                                         ; FB4A50  d8 cf ff ff
	jr z, .LFB4ABC                                       ; FB4A54  66 66
	pushw 0x06                                           ; FB4A56  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB4A59  f2 f2 fe f4 31
	push XBC                                             ; FB4A5E  39
	call SysExTx_Append                                      ; FB4A5F  1d 24 6f fb
	pushw 0x06                                           ; FB4A63  0b 06 00
	lda xbc, (xiz-10)                                    ; FB4A66  be f6 31
	push XBC                                             ; FB4A69  39
	ld XWA,(XIZ+0x08)                                    ; FB4A6A  ae 08 20
	push XWA                                             ; FB4A6D  38
	call MemCopyWords_Copy                                      ; FB4A6E  1d ce 81 fb
	pushw 0x0b                                           ; FB4A72  0b 0b 00
	ld xbc, (0x60fcd8:24)                               ; FB4A75  e2 d8 fc 60 21
	push XBC                                             ; FB4A7A  39
	call U8Rec16_GetField                                      ; FB4A7B  1d d3 62 fb
	ld (xiz-8), a                                        ; FB4A7F  be f8 41
	pushw 0x06                                           ; FB4A82  0b 06 00
	lda xbc, (xiz-10)                                    ; FB4A85  be f6 31
	push XBC                                             ; FB4A88  39
	call SysExTx_Append                                      ; FB4A89  1d 24 6f fb
	ld C,(XIX)                                           ; FB4A8D  84 23
	and C,0x0f                                           ; FB4A8F  cb cc 0f
	ld (XIX+0x01),C                                      ; FB4A92  bc 01 43
	ld C,(XIX)                                           ; FB4A95  84 23
	srl c, 0x04                                          ; FB4A97  cb ef 04
	ld (XIX),C                                           ; FB4A9A  b4 43
	pushw 0x03                                           ; FB4A9C  0b 03 00
	push XIX                                             ; FB4A9F  3c
	call SysExTx_Append                                      ; FB4AA0  1d 24 6f fb
; (sub_FB4AA4 removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExParam_Request_Area60;
;  notes/prom_a_stray_label_removal.py)
	call SysExTx_AppendChecksumF7                                      ; FB4AA4  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB4AA8  e2 88 fc 60 21
	push XBC                                             ; FB4AAD  39
	call SysExTx_SendFrameBothPorts                                      ; FB4AAE  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB4AB2  1d 81 80 fb
	add XSP,0x00000026                                   ; FB4AB6  ef c8 26 00 00 00
.LFB4ABC:
	pop XIX                                              ; FB4ABC  5c
	popw hl                                              ; FB4ABD  4b
	unlk XIZ                                             ; FB4ABE  ee 0d
	ret                                                  ; FB4AC0  0e
	link XIZ,0xfff4                                      ; FB4AC1  ee 0c f4 ff
	push XIX                                             ; FB4AC5  3c
	ld XIX,(XIZ+0x08)                                    ; FB4AC6  ae 08 24
	ld C,(XIX+0x06)                                      ; FB4AC9  8c 06 23
	ld (xiz-4), c                                        ; FB4ACC  be fc 43
	ld C,(XIX+0x07)                                      ; FB4ACF  8c 07 23
	ld (xiz-3), c                                        ; FB4AD2  be fd 43
	ld C,(XIX+0x07)                                      ; FB4AD5  8c 07 23
	extz BC                                              ; FB4AD8  d9 12
	pushw bc                                             ; FB4ADA  29
	ld C,(XIX+0x06)                                      ; FB4ADB  8c 06 23
	extz BC                                              ; FB4ADE  d9 12
	pushw bc                                             ; FB4AE0  29
	call IndexedTable_GetByteOr0                                      ; FB4AE1  1d 02 7a fb
	ld (xiz-2), a                                        ; FB4AE5  be fe 41
	ld C,(XIX+0x08)                                      ; FB4AE8  8c 08 23
	ld (xiz-1), c                                        ; FB4AEB  be ff 43
	lda xbc, (xiz-4)                                     ; FB4AEE  be fc 31
	ld (xiz-12), xbc                                     ; FB4AF1  be f4 61
	ld (xiz-8), xix                                      ; FB4AF4  be f8 64
	lda xbc, (xiz-12)                                    ; FB4AF7  be f4 31
	push XBC                                             ; FB4AFA  39
	calr sub_FB4AA4_Nop                                      ; FB4AFB  1e 8f 04
	inc 8,XSP                                            ; FB4AFE  ef 60
	pop XIX                                              ; FB4B00  5c
	unlk XIZ                                             ; FB4B01  ee 0d
	ret                                                  ; FB4B03  0e
	link XIZ,0xfff4                                      ; FB4B04  ee 0c f4 ff
	push XIX                                             ; FB4B08  3c
	lda xix, (xiz-12)                                    ; FB4B09  be f4 34
	ld XBC,(XIZ+0x08)                                    ; FB4B0C  ae 08 21
	ld A,(XBC+0x06)                                      ; FB4B0F  89 06 21
	ld (XIX),A                                           ; FB4B12  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB4B14  ae 08 21
	ld A,(XBC+0x07)                                      ; FB4B17  89 07 21
	ld (XIX+0x01),A                                      ; FB4B1A  bc 01 41
	ld c, (0x24f2:16)                                   ; FB4B1D  c1 f2 24 23
	ld (XIX+0x02),C                                      ; FB4B21  bc 02 43
	ld XBC,(XIZ+0x08)                                    ; FB4B24  ae 08 21
	ld A,(XBC+0x08)                                      ; FB4B27  89 08 21
	ld (XIX+0x03),A                                      ; FB4B2A  bc 03 41
	ld (xiz-8), xix                                      ; FB4B2D  be f8 64
	ld XBC,(XIZ+0x08)                                    ; FB4B30  ae 08 21
	ld (xiz-4), xbc                                      ; FB4B33  be fc 61
	lda xbc, (xiz-8)                                     ; FB4B36  be f8 31
	push XBC                                             ; FB4B39  39
	calr SysExTx_SendParamValue                                      ; FB4B3A  1e 25 02
	pop XBC                                              ; FB4B3D  59
	pop XIX                                              ; FB4B3E  5c
	unlk XIZ                                             ; FB4B3F  ee 0d
	ret                                                  ; FB4B41  0e
	link XIZ,0xfff4                                      ; FB4B42  ee 0c f4 ff
	push XIX                                             ; FB4B46  3c
	lda xix, (xiz-12)                                    ; FB4B47  be f4 34
	ld XBC,(XIZ+0x08)                                    ; FB4B4A  ae 08 21
	ld A,(XBC+0x06)                                      ; FB4B4D  89 06 21
	ld (XIX),A                                           ; FB4B50  b4 41
	ld XBC,(XIZ+0x08)                                    ; FB4B52  ae 08 21
	ld A,(XBC+0x07)                                      ; FB4B55  89 07 21
	ld (XIX+0x01),A                                      ; FB4B58  bc 01 41
	ld (XIX+0x02),0x00                                   ; FB4B5B  bc 02 00 00
	ld XBC,(XIZ+0x08)                                    ; FB4B5F  ae 08 21
	ld A,(XBC+0x08)                                      ; FB4B62  89 08 21
	ld (XIX+0x03),A                                      ; FB4B65  bc 03 41
	ld (xiz-8), xix                                      ; FB4B68  be f8 64
	ld XBC,(XIZ+0x08)                                    ; FB4B6B  ae 08 21
	ld (xiz-4), xbc                                      ; FB4B6E  be fc 61
	lda xbc, (xiz-8)                                     ; FB4B71  be f8 31
	push XBC                                             ; FB4B74  39
	calr SysExTx_ProgramChangeAndBank                                      ; FB4B75  1e ad 08
	pop XBC                                              ; FB4B78  59
	pop XIX                                              ; FB4B79  5c
	unlk XIZ                                             ; FB4B7A  ee 0d
	ret                                                  ; FB4B7C  0e
; SysExTx_EmitStagedParams: only when MidiFilter_Exclusive bit 3 is set and (0x0922) bit 0 clear: walk the staged records from
;   0x2C00 + (0x60F002) (StagedQueue_ReadRecord) and call SysExTx_StagedParamHandlers[record number] for numbers < 0xC0.
SysExTx_EmitStagedParams:
	pushw hl                                             ; FB4B7D  2b
	push XIX                                             ; FB4B7E  3c
	ld c, (MidiFilter_Exclusive:16)                                   ; FB4B7F  c1 38 7f 23
	and C,0x08                                           ; FB4B83  cb cc 08
	jr z, .LFB4BDA                                       ; FB4B86  66 52
	ld c, (0x0922:16)                                   ; FB4B88  c1 22 09 23
	and C,0x01                                           ; FB4B8C  cb cc 01
	jr nz, .LFB4BDA                                      ; FB4B8F  6e 49
	ld hl, (0x60f002:24)                                ; FB4B91  d2 02 f0 60 23
	ldw bc, 0x2c00                                       ; FB4B96  31 00 2c
	add BC,HL                                            ; FB4B99  db 81
	extz XBC                                             ; FB4B9B  e9 12
	ld XIX,XBC                                           ; FB4B9D  e9 8c
.LFB4B9F:
	push XIX                                             ; FB4B9F  3c
	call StagedQueue_ReadRecord                                      ; FB4BA0  1d 70 72 fb
	ld (0x60fd45:24), xiy                               ; FB4BA4  f2 45 fd 60 65
	ld h, (0x60fd45:24)                                 ; FB4BA9  c2 45 fd 60 26
	pop XBC                                              ; FB4BAE  59
	cp H,0xff                                            ; FB4BAF  ce cf ff
	jr z, .LFB4BDA                                       ; FB4BB2  66 26
	cp H,0xc0                                            ; FB4BB4  ce cf c0
	jr nc, .LFB4BD6                                      ; FB4BB7  6f 1d
	lda xbc, (0x60fd45:24)                               ; FB4BB9  f2 45 fd 60 31
	push XBC                                             ; FB4BBE  39
	ld a, 0x04:opc                                          ; FB4BBF  21 04
	mul wa, h                                          ; FB4BC1  ce 41
; (sub_FB4BC3 removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExTx_EmitStagedParams;
;  notes/prom_a_stray_label_removal.py)
	extz XWA                                             ; FB4BC3  e8 12
	add XWA,SysExTx_StagedParamHandlers                              ; FB4BC5  e8 c8 38 fb f4 00
	ld XWA,(XWA)                                         ; FB4BCB  a0 20
	lda xiy, (.LFB4BD5:24)                               ; FB4BCD  f2 d5 4b fb 35
	push XIY                                             ; FB4BD2  3d
	jp (xwa)                                             ; FB4BD3  b0 d8
.LFB4BD5:
	pop XIY                                              ; FB4BD5  5d
.LFB4BD6:
	inc 4,XIX                                            ; FB4BD6  ec 64
	jr .LFB4B9F                                          ; FB4BD8  68 c5
.LFB4BDA:
	pop XIX                                              ; FB4BDA  5c
	popw hl                                              ; FB4BDB  4b
	ret                                                  ; FB4BDC  0e
; SysExTx_StagedParam_Ignore: 187 of the 192 SysExTx_StagedParamHandlers slots, a bare ret.
SysExTx_StagedParam_Ignore:
	ret                                                  ; FB4BDD  0e
; SysExTx_StagedParam_Record48: staged parameter record 0x48: look the record up in the list at prom_b 0xF51E14
;   (SysExParamDesc_FindForEvent) and call the descriptor's +0x10 method.
SysExTx_StagedParam_Record48:
	link XIZ,0xfff8                                      ; FB4BDE  ee 0c f8 ff
	push XIX                                             ; FB4BE2  3c
	lda xix, (xiz-8)                                     ; FB4BE3  be f8 34
	lda xbc, (0xf51e14:24)                               ; FB4BE6  f2 14 1e f5 31
	push XBC                                             ; FB4BEB  39
	ld XWA,(XIZ+0x08)                                    ; FB4BEC  ae 08 20
	push XWA                                             ; FB4BEF  38
	calr SysExParamDesc_FindForEvent                                      ; FB4BF0  1e 2d 01
	ld (XIX+0x04),XIY                                    ; FB4BF3  bc 04 65
	ld XBC,(XIZ+0x08)                                    ; FB4BF6  ae 08 21
	ld (XIX),XBC                                         ; FB4BF9  b4 61
	push XIX                                             ; FB4BFB  3c
	ld XBC,(XIX+0x04)                                    ; FB4BFC  ac 04 21
	ld XWA,(XBC+0x10)                                    ; FB4BFF  a9 10 20
	lda xiy, (.LFB4C0A:24)                               ; FB4C02  f2 0a 4c fb 35
	push XIY                                             ; FB4C07  3d
	jp (xwa)                                             ; FB4C08  b0 d8
.LFB4C0A:
	inc 8,XSP                                            ; FB4C0A  ef 60
	inc 4,XSP                                            ; FB4C0C  ef 64
	pop XIX                                              ; FB4C0E  5c
	unlk XIZ                                             ; FB4C0F  ee 0d
	ret                                                  ; FB4C11  0e
SysExTx_StagedParam_Record60:
	link XIZ,0xfff8                                      ; FB4C12  ee 0c f8 ff
	push XIX                                             ; FB4C16  3c
	lda xix, (xiz-8)                                     ; FB4C17  be f8 34
	lda xbc, (0xf51e18:24)                               ; FB4C1A  f2 18 1e f5 31
	push XBC                                             ; FB4C1F  39
	ld XWA,(XIZ+0x08)                                    ; FB4C20  ae 08 20
	push XWA                                             ; FB4C23  38
	calr SysExParamDesc_FindForEvent                                      ; FB4C24  1e f9 00
	ld (XIX+0x04),XIY                                    ; FB4C27  bc 04 65
	ld XBC,(XIZ+0x08)                                    ; FB4C2A  ae 08 21
	ld (XIX),XBC                                         ; FB4C2D  b4 61
	push XIX                                             ; FB4C2F  3c
	ld XBC,(XIX+0x04)                                    ; FB4C30  ac 04 21
	ld XWA,(XBC+0x10)                                    ; FB4C33  a9 10 20
	lda xiy, (.LFB4C3E:24)                               ; FB4C36  f2 3e 4c fb 35
	push XIY                                             ; FB4C3B  3d
	jp (xwa)                                             ; FB4C3C  b0 d8
.LFB4C3E:
	inc 8,XSP                                            ; FB4C3E  ef 60
	inc 4,XSP                                            ; FB4C40  ef 64
	pop XIX                                              ; FB4C42  5c
	unlk XIZ                                             ; FB4C43  ee 0d
	ret                                                  ; FB4C45  0e
SysExTx_StagedParam_Record70:
	link XIZ,0xfff8                                      ; FB4C46  ee 0c f8 ff
; (sub_FB4C4A removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExTx_StagedParam_Record70;
;  notes/prom_a_stray_label_removal.py)
	push XIX                                             ; FB4C4A  3c
	lda xix, (xiz-8)                                     ; FB4C4B  be f8 34
	lda xbc, (Pointer_F51E20:24)                         ; FB4C4E  f2 20 1e f5 31
	push XBC                                             ; FB4C53  39
	ld XWA,(XIZ+0x08)                                    ; FB4C54  ae 08 20
	push XWA                                             ; FB4C57  38
	calr SysExParamDesc_FindForEvent                                      ; FB4C58  1e c5 00
	ld (XIX+0x04),XIY                                    ; FB4C5B  bc 04 65
	ld XBC,(XIZ+0x08)                                    ; FB4C5E  ae 08 21
	ld (XIX),XBC                                         ; FB4C61  b4 61
	push XIX                                             ; FB4C63  3c
	ld XBC,(XIX+0x04)                                    ; FB4C64  ac 04 21
	ld XWA,(XBC+0x10)                                    ; FB4C67  a9 10 20
	lda xiy, (.LFB4C72:24)                               ; FB4C6A  f2 72 4c fb 35
	push XIY                                             ; FB4C6F  3d
	jp (xwa)                                             ; FB4C70  b0 d8
.LFB4C72:
	inc 8,XSP                                            ; FB4C72  ef 60
	inc 4,XSP                                            ; FB4C74  ef 64
	pop XIX                                              ; FB4C76  5c
	unlk XIZ                                             ; FB4C77  ee 0d
	ret                                                  ; FB4C79  0e
SysExTx_StagedParam_Record98:
	link XIZ,0xfff8                                      ; FB4C7A  ee 0c f8 ff
	push XIX                                             ; FB4C7E  3c
	lda xix, (xiz-8)                                     ; FB4C7F  be f8 34
	lda xbc, (Pointer_F51E24:24)                         ; FB4C82  f2 24 1e f5 31
	push XBC                                             ; FB4C87  39
	ld XWA,(XIZ+0x08)                                    ; FB4C88  ae 08 20
	push XWA                                             ; FB4C8B  38
	calr SysExParamDesc_FindForEvent                                      ; FB4C8C  1e 91 00
	ld (XIX+0x04),XIY                                    ; FB4C8F  bc 04 65
	ld XBC,(XIZ+0x08)                                    ; FB4C92  ae 08 21
	ld (XIX),XBC                                         ; FB4C95  b4 61
	push XIX                                             ; FB4C97  3c
	ld XBC,(XIX+0x04)                                    ; FB4C98  ac 04 21
	ld XWA,(XBC+0x10)                                    ; FB4C9B  a9 10 20
	lda xiy, (.LFB4CA6:24)                               ; FB4C9E  f2 a6 4c fb 35
	push XIY                                             ; FB4CA3  3d
	jp (xwa)                                             ; FB4CA4  b0 d8
.LFB4CA6:
	inc 8,XSP                                            ; FB4CA6  ef 60
	inc 4,XSP                                            ; FB4CA8  ef 64
	pop XIX                                              ; FB4CAA  5c
	unlk XIZ                                             ; FB4CAB  ee 0d
	ret                                                  ; FB4CAD  0e
; SysExTx_GmSystemOnOff: transmits F0 7E 7F 09 01 F7 (GM System On) or 09 02 (Off), the literal at 0xF4FEE6 / 0xF4FEEC chosen by the record's
;   byte +1 (README: 'The instrument transmits').
SysExTx_GmSystemOnOff:
	link XIZ,0xfff8                                      ; FB4CAE  ee 0c f8 ff
	pushw hl                                             ; FB4CB2  2b
	push XIX                                             ; FB4CB3  3c
	lda xix, (xiz-8)                                     ; FB4CB4  be f8 34
	ld XBC,(XIZ+0x08)                                    ; FB4CB7  ae 08 21
	ld H,(XBC+0x01)                                      ; FB4CBA  89 01 26
	cp H,0x11                                            ; FB4CBD  ce cf 11
	jr nz, .LFB4CCD                                      ; FB4CC0  6e 0b
	pushw 0x06                                           ; FB4CC2  0b 06 00
	lda xwa, (0xf4fee6:24)                               ; FB4CC5  f2 e6 fe f4 30
	push XWA                                             ; FB4CCA  38
	jr .LFB4CDB                                          ; FB4CCB  68 0e
.LFB4CCD:
	cp H,0x10                                            ; FB4CCD  ce cf 10
	jr nz, .LFB4CF3                                      ; FB4CD0  6e 21
	pushw 0x06                                           ; FB4CD2  0b 06 00
	lda xbc, (0xf4feec:24)                               ; FB4CD5  f2 ec fe f4 31
	push XBC                                             ; FB4CDA  39
.LFB4CDB:
	call SysExTx_Append                                      ; FB4CDB  1d 24 6f fb
	ld xbc, (0x60fc88:24)                               ; FB4CDF  e2 88 fc 60 21
	push XBC                                             ; FB4CE4  39
	call SysExTx_SendFrameBothPorts                                      ; FB4CE5  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB4CE9  1d 81 80 fb
	inc 8,XSP                                            ; FB4CED  ef 60
	inc 2,XSP                                            ; FB4CEF  ef 62
	jr .LFB4D1B                                          ; FB4CF1  68 28
.LFB4CF3:
	lda xbc, (Pointer_F51E28:24)                         ; FB4CF3  f2 28 1e f5 31
	push XBC                                             ; FB4CF8  39
	ld XWA,(XIZ+0x08)                                    ; FB4CF9  ae 08 20
	push XWA                                             ; FB4CFC  38
	calr SysExParamDesc_FindForEvent                                      ; FB4CFD  1e 20 00
	ld (XIX+0x04),XIY                                    ; FB4D00  bc 04 65
	ld XBC,(XIZ+0x08)                                    ; FB4D03  ae 08 21
	ld (XIX),XBC                                         ; FB4D06  b4 61
	push XIX                                             ; FB4D08  3c
	ld XBC,(XIX+0x04)                                    ; FB4D09  ac 04 21
	ld XWA,(XBC+0x10)                                    ; FB4D0C  a9 10 20
	lda xiy, (.LFB4D17:24)                               ; FB4D0F  f2 17 4d fb 35
	push XIY                                             ; FB4D14  3d
	jp (xwa)                                             ; FB4D15  b0 d8
.LFB4D17:
	inc 8,XSP                                            ; FB4D17  ef 60
	inc 4,XSP                                            ; FB4D19  ef 64
.LFB4D1B:
	pop XIX                                              ; FB4D1B  5c
	popw hl                                              ; FB4D1C  4b
	unlk XIZ                                             ; FB4D1D  ee 0d
	ret                                                  ; FB4D1F  0e
; SysExParamDesc_FindForEvent: Walks a descriptor-pointer list and returns (XIY) the first descriptor whose offset
;   (+7) = the event's byte index and whose mask (+8) meets its changed bits; else SysExParamDesc_Placeholder. The
;   SysExTx_StagedParam_* handlers then call that descriptor's +0x10 transmit method. Basis: callers + body +
;   descriptor layout. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_a.json)
SysExParamDesc_FindForEvent:
	link XIZ,0xfff8                                      ; FB4D20  ee 0c f8 ff
	pushw hl                                             ; FB4D24  2b
	push XIX                                             ; FB4D25  3c
.LFB4D26:
	ld XBC,(XIZ+0x0c)                                    ; FB4D26  ae 0c 21
	ld (xiz-4), xbc                                      ; FB4D29  be fc 61
	sub XWA,XWA                                          ; FB4D2C  e8 a0
	inc 4,XWA                                            ; FB4D2E  e8 64
	add (XIZ+0x0c),XWA                                   ; FB4D30  ae 0c 88
	ld XIY,(XBC)                                         ; FB4D33  a1 25
	ld XIX,XIY                                           ; FB4D35  ed 8c
	ld (xiz-8), xiy                                      ; FB4D37  be f8 65
	lda	xbc, (SysExParamDesc_Placeholder:24)         ; FB4D3A  f2 f9 11 f5 31
	cp XIY,XBC                                           ; FB4D3F  e9 f5
	jr z, .LFB4D5A                                       ; FB4D41  66 17
	ld H,(XIX+0x07)                                      ; FB4D43  8c 07 26
	ld XBC,(XIZ+0x08)                                    ; FB4D46  ae 08 21
	ld A,(XBC+0x01)                                      ; FB4D49  89 01 21
	cp A,H                                               ; FB4D4C  ce f1
	jr nz, .LFB4D26                                      ; FB4D4E  6e d6
	ld H,(XIX+0x08)                                      ; FB4D50  8c 08 26
	ld A,(XBC+0x03)                                      ; FB4D53  89 03 21
	and A,H                                              ; FB4D56  ce c1
	jr z, .LFB4D26                                       ; FB4D58  66 cc
.LFB4D5A:
	ld XIY,XIX                                           ; FB4D5A  ec 8d
	pop XIX                                              ; FB4D5C  5c
	popw hl                                              ; FB4D5D  4b
	unlk XIZ                                             ; FB4D5E  ee 0d
	ret                                                  ; FB4D60  0e
; SysExParam_NoTransmitOnChange: a bare `ret` one byte before SysExTx_SendParamValue: the descriptor +0x10 method (called by the staged-parameter
;  transmitter, SysExTx_StagedParam_*) of the 23 parameters that are NOT sent when they change; the other 86 have
;  SysExTx_SendParamValue there.
;  Descriptor field: +0x10.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_NoTransmitOnChange:
	ret                                                  ; FB4D61  0e
; SysExTx_SendParamValue: the family-2B transmitter: the descriptor's +0x18 method reads the instrument's value and calls it (README: 'Direction, three witnesses').
SysExTx_SendParamValue:
	link XIZ,0xfff5                                      ; FB4D62  ee 0c f5 ff
	pushw hl                                             ; FB4D66  2b
	push XIX                                             ; FB4D67  3c
	ld XIX,(XIZ+0x08)                                    ; FB4D68  ae 08 24
	push XIX                                             ; FB4D6B  3c
	ldw bc, 0x03                                         ; FB4D6C  31 03 00
	lda xiy, (0xf4fa84:24)                               ; FB4D6F  f2 84 fa f4 35
	lda xix, (xiz-7)                                     ; FB4D74  be f9 34
	ldir85                                               ; FB4D77  85 11
	pop XIX                                              ; FB4D79  5c
	ld XBC,(XIX+0x04)                                    ; FB4D7A  ac 04 21
	push XBC                                             ; FB4D7D  39
	calr SysExParam_CheckConditions                                      ; FB4D7E  1e e5 02
	pop XIY                                              ; FB4D81  5d
	cp WA,0xffff                                         ; FB4D82  d8 cf ff ff
	jrl z, .LFB4E1B                                      ; FB4D86  76 92 00
	ld XBC,(XIX+0x04)                                    ; FB4D89  ac 04 21
	ld (xiz-4), xbc                                      ; FB4D8C  be fc 61
	ld (xiz-11), xbc                                     ; FB4D8F  be f5 61
	lda	xwa, (SysExParamDesc_Placeholder:24)         ; FB4D92  f2 f9 11 f5 30
	cp XBC,XWA                                           ; FB4D97  e8 f1
	jrl z, .LFB4E1B                                      ; FB4D99  76 7f 00
	ld xbc, (xiz-4)                                      ; FB4D9C  ae fc 21
	ld H,(XBC+0x08)                                      ; FB4D9F  89 08 26
	ld XWA,(XIX)                                         ; FB4DA2  a4 20
	ld C,(XWA+0x03)                                      ; FB4DA4  88 03 23
	and C,H                                              ; FB4DA7  ce c3
	jrl z, .LFB4E1B                                      ; FB4DA9  76 6f 00
	pushw 0x06                                           ; FB4DAC  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB4DAF  f2 f2 fe f4 31
	push XBC                                             ; FB4DB4  39
	call SysExTx_Append                                      ; FB4DB5  1d 24 6f fb
	pushw 0x06                                           ; FB4DB9  0b 06 00
	ld XBC,(XIX+0x04)                                    ; FB4DBC  ac 04 21
	push XBC                                             ; FB4DBF  39
	call SysExTx_Append                                      ; FB4DC0  1d 24 6f fb
	ld XBC,(XIX+0x04)                                    ; FB4DC4  ac 04 21
	ld (xiz-11), xbc                                     ; FB4DC7  be f5 61
	ld H,(XBC+0x08)                                      ; FB4DCA  89 08 26
	ld XWA,(XIX)                                         ; FB4DCD  a4 20
	ld C,(XWA+0x02)                                      ; FB4DCF  88 02 23
	ld L,C                                               ; FB4DD2  cb 8f
	and L,H                                              ; FB4DD4  ce c7
	ld xbc, (xiz-11)                                     ; FB4DD6  ae f5 21
	ld A,(XBC+0x0b)                                      ; FB4DD9  89 0b 21
	pushw wa                                             ; FB4DDC  28
	pushw hl                                             ; FB4DDD  2b
	call Lsr8ByCount                                      ; FB4DDE  1d 28 82 fb
	ld H,A                                               ; FB4DE2  c9 8e
	ld (xiz-7), a                                        ; FB4DE4  be f9 41
	ld C,H                                               ; FB4DE7  ce 8b
	and C,0x0f                                           ; FB4DE9  cb cc 0f
	ld (xiz-6), c                                        ; FB4DEC  be fa 43
	ld c, (xiz-7)                                        ; FB4DEF  8e f9 23
	srl c, 0x04                                          ; FB4DF2  cb ef 04
	ld (xiz-7), c                                        ; FB4DF5  be f9 43
	pushw 0x03                                           ; FB4DF8  0b 03 00
	lda xbc, (xiz-7)                                     ; FB4DFB  be f9 31
	push XBC                                             ; FB4DFE  39
	call SysExTx_Append                                      ; FB4DFF  1d 24 6f fb
	call SysExTx_AppendChecksumF7                                      ; FB4E03  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB4E07  e2 88 fc 60 21
	push XBC                                             ; FB4E0C  39
	call SysExTx_SendFrameBothPorts                                      ; FB4E0D  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB4E11  1d 81 80 fb
	add XSP,0x00000016                                   ; FB4E15  ef c8 16 00 00 00
.LFB4E1B:
	pop XIX                                              ; FB4E1B  5c
	popw hl                                              ; FB4E1C  4b
	unlk XIZ                                             ; FB4E1D  ee 0d
	ret                                                  ; FB4E1F  0e
; SysExTx_SendWordFieldParamValue: 16-bit-field twin of SysExTx_SendParamValue: after SysExParam_CheckConditions and
;   the placeholder test, sends F0 50 2C 04 00 11 + the descriptor's 6 address/count bytes + ((value16 & mask16) >>
;   desc+0x0B) as two nibbles + flag 0, checksum, F7, both ports. Called by SysExParam_GetMainOutEqualizerFreq, whose
;   5-bit fields (mask 0x1F, shift 6) straddle two bytes. Basis: caller + body + twin + descriptor. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
SysExTx_SendWordFieldParamValue:
	link XIZ,0xfff9                                      ; FB4E20  ee 0c f9 ff
	pushw hl                                             ; FB4E24  2b
	pushw de                                             ; FB4E25  2a
	push XIX                                             ; FB4E26  3c
	ld XIX,(XIZ+0x08)                                    ; FB4E27  ae 08 24
	push XIX                                             ; FB4E2A  3c
	ldw bc, 0x03                                         ; FB4E2B  31 03 00
	lda xiy, (0xf4fa87:24)                               ; FB4E2E  f2 87 fa f4 35
	lda xix, (xiz-3)                                     ; FB4E33  be fd 34
	ldir85                                               ; FB4E36  85 11
	pop XIX                                              ; FB4E38  5c
	ld XBC,(XIX+0x04)                                    ; FB4E39  ac 04 21
	push XBC                                             ; FB4E3C  39
	calr SysExParam_CheckConditions                                      ; FB4E3D  1e 26 02
	pop XIY                                              ; FB4E40  5d
	cp WA,0xffff                                         ; FB4E41  d8 cf ff ff
	jrl z, .LFB4ECE                                      ; FB4E45  76 86 00
	ld XBC,(XIX+0x04)                                    ; FB4E48  ac 04 21
	ld (xiz-7), xbc                                      ; FB4E4B  be f9 61
	lda	xwa, (SysExParamDesc_Placeholder:24)         ; FB4E4E  f2 f9 11 f5 30
	cp XBC,XWA                                           ; FB4E53  e8 f1
	jrl z, .LFB4ECE                                      ; FB4E55  76 76 00
	ld XBC,(XIX)                                         ; FB4E58  a4 21
	ld WA,(XBC+0x04)                                     ; FB4E5A  99 04 20
	cp wa, 0x00:i3                                         ; FB4E5D  d8 d8
	jrl z, .LFB4ECE                                      ; FB4E5F  76 6c 00
	pushw 0x06                                           ; FB4E62  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB4E65  f2 f2 fe f4 31
	push XBC                                             ; FB4E6A  39
	call SysExTx_Append                                      ; FB4E6B  1d 24 6f fb
	pushw 0x06                                           ; FB4E6F  0b 06 00
	ld XBC,(XIX+0x04)                                    ; FB4E72  ac 04 21
	push XBC                                             ; FB4E75  39
	call SysExTx_Append                                      ; FB4E76  1d 24 6f fb
	ld XBC,(XIX)                                         ; FB4E7A  a4 21
	ld (xiz-7), xbc                                      ; FB4E7C  be f9 61
	ld HL,(XBC+0x04)                                     ; FB4E7F  99 04 23
	ld WA,(XBC+0x02)                                     ; FB4E82  99 02 20
	ld DE,WA                                             ; FB4E85  d8 8a
	and DE,HL                                            ; FB4E87  db c2
	ld XBC,(XIX+0x04)                                    ; FB4E89  ac 04 21
	ld A,(XBC+0x0b)                                      ; FB4E8C  89 0b 21
	pushw wa                                             ; FB4E8F  28
	pushw de                                             ; FB4E90  2a
	call Lsr16ByCount                                      ; FB4E91  1d 49 82 fb
	ld H,A                                               ; FB4E95  c9 8e
	ld (xiz-3), a                                        ; FB4E97  be fd 41
	ld C,H                                               ; FB4E9A  ce 8b
	and C,0x0f                                           ; FB4E9C  cb cc 0f
	ld (xiz-2), c                                        ; FB4E9F  be fe 43
	ld c, (xiz-3)                                        ; FB4EA2  8e fd 23
	srl c, 0x04                                          ; FB4EA5  cb ef 04
	ld (xiz-3), c                                        ; FB4EA8  be fd 43
	pushw 0x03                                           ; FB4EAB  0b 03 00
	lda xbc, (xiz-3)                                     ; FB4EAE  be fd 31
	push XBC                                             ; FB4EB1  39
	call SysExTx_Append                                      ; FB4EB2  1d 24 6f fb
	call SysExTx_AppendChecksumF7                                      ; FB4EB6  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB4EBA  e2 88 fc 60 21
	push XBC                                             ; FB4EBF  39
	call SysExTx_SendFrameBothPorts                                      ; FB4EC0  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB4EC4  1d 81 80 fb
	add XSP,0x00000016                                   ; FB4EC8  ef c8 16 00 00 00
.LFB4ECE:
	pop XIX                                              ; FB4ECE  5c
	popw de                                              ; FB4ECF  4a
	popw hl                                              ; FB4ED0  4b
	unlk XIZ                                             ; FB4ED1  ee 0d
	ret                                                  ; FB4ED3  0e
sub_FB4ED4:
	link XIZ,0xfff5                                      ; FB4ED4  ee 0c f5 ff
	pushw hl                                             ; FB4ED8  2b
	push XIX                                             ; FB4ED9  3c
	lda xix, (xiz-7)                                     ; FB4EDA  be f9 34
	push XIX                                             ; FB4EDD  3c
	ldw bc, 0x03                                         ; FB4EDE  31 03 00
	lda xiy, (0xf4fa8a:24)                               ; FB4EE1  f2 8a fa f4 35
	lda xix, (xiz-7)                                     ; FB4EE6  be f9 34
	ldir85                                               ; FB4EE9  85 11
	pop XIX                                              ; FB4EEB  5c
	ld XBC,(XIZ+0x08)                                    ; FB4EEC  ae 08 21
	ld XWA,(XBC+0x04)                                    ; FB4EEF  a9 04 20
	push XWA                                             ; FB4EF2  38
	calr SysExParam_CheckConditions                                      ; FB4EF3  1e 70 01
	pop XIY                                              ; FB4EF6  5d
	cp WA,0xffff                                         ; FB4EF7  d8 cf ff ff
	jrl z, .LFB4F87                                      ; FB4EFB  76 89 00
	ld XBC,(XIZ+0x08)                                    ; FB4EFE  ae 08 21
	ld XWA,(XBC+0x04)                                    ; FB4F01  a9 04 20
	ld (xiz-4), xwa                                      ; FB4F04  be fc 60
	ld (xiz-11), xwa                                     ; FB4F07  be f5 60
	lda	xiy, (SysExParamDesc_Placeholder:24)         ; FB4F0A  f2 f9 11 f5 35
	cp XWA,XIY                                           ; FB4F0F  ed f0
	jrl z, .LFB4F87                                      ; FB4F11  76 73 00
	ld xwa, (xiz-4)                                      ; FB4F14  ae fc 20
	ld H,(XWA+0x08)                                      ; FB4F17  88 08 26
	ld XIY,(XBC)                                         ; FB4F1A  a1 25
	ld C,(XIY+0x03)                                      ; FB4F1C  8d 03 23
	and C,H                                              ; FB4F1F  ce c3
	jr z, .LFB4F87                                       ; FB4F21  66 64
	pushw 0x06                                           ; FB4F23  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB4F26  f2 f2 fe f4 31
	push XBC                                             ; FB4F2B  39
	call SysExTx_Append                                      ; FB4F2C  1d 24 6f fb
	pushw 0x06                                           ; FB4F30  0b 06 00
	ld XBC,(XIZ+0x08)                                    ; FB4F33  ae 08 21
	ld XWA,(XBC+0x04)                                    ; FB4F36  a9 04 20
	push XWA                                             ; FB4F39  38
	call SysExTx_Append                                      ; FB4F3A  1d 24 6f fb
	ld (XIX),0x00                                        ; FB4F3E  b4 00 00
	ld XBC,(XIZ+0x08)                                    ; FB4F41  ae 08 21
	ld XWA,(XBC+0x04)                                    ; FB4F44  a9 04 20
	ld H,(XWA+0x08)                                      ; FB4F47  88 08 26
	ld XWA,(XBC)                                         ; FB4F4A  a1 20
	ld C,(XWA+0x02)                                      ; FB4F4C  88 02 23
	and C,H                                              ; FB4F4F  ce c3
	inc 8,XSP                                            ; FB4F51  ef 60
	inc 4,XSP                                            ; FB4F53  ef 64
	jr z, .LFB4F5A                                       ; FB4F55  66 03
	ld (XIX),0x7f                                        ; FB4F57  b4 00 7f
.LFB4F5A:
	ld C,(XIX)                                           ; FB4F5A  84 23
	and C,0x0f                                           ; FB4F5C  cb cc 0f
	ld (XIX+0x01),C                                      ; FB4F5F  bc 01 43
	ld C,(XIX)                                           ; FB4F62  84 23
	srl c, 0x04                                          ; FB4F64  cb ef 04
	ld (XIX),C                                           ; FB4F67  b4 43
	pushw 0x03                                           ; FB4F69  0b 03 00
	push XIX                                             ; FB4F6C  3c
	call SysExTx_Append                                      ; FB4F6D  1d 24 6f fb
	call SysExTx_AppendChecksumF7                                      ; FB4F71  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB4F75  e2 88 fc 60 21
	push XBC                                             ; FB4F7A  39
	call SysExTx_SendFrameBothPorts                                      ; FB4F7B  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB4F7F  1d 81 80 fb
	inc 8,XSP                                            ; FB4F83  ef 60
	inc 2,XSP                                            ; FB4F85  ef 62
.LFB4F87:
	pop XIX                                              ; FB4F87  5c
	popw hl                                              ; FB4F88  4b
	unlk XIZ                                             ; FB4F89  ee 0d
	ret                                                  ; FB4F8B  0e
	ret                                                  ; FB4F8C  0e
sub_FB4AA4_Nop:
	ret                                                  ; FB4F8D  0e
	ret                                                  ; FB4F8E  0e
; SysExTx_SendPartParamValue: The PART variant of SysExTx_SendParamValue (family-2C reply, 1 data byte): same header
;   F0 50 2C 04 00 11, conditions and nibbles, but the descriptor's 6 address bytes are copied and byte 7 patched to
;   0x20 | part (`set 5,A`). Called by the 2B readers SysExParam_GetPartField and SysExParam_GetEffect2OnOff. Basis:
;   callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
SysExTx_SendPartParamValue:
	link XIZ,0xffee                                      ; FB4F8F  ee 0c ee ff
	pushw hl                                             ; FB4F93  2b
	push XIX                                             ; FB4F94  3c
	ld XIX,(XIZ+0x08)                                    ; FB4F95  ae 08 24
	push XIX                                             ; FB4F98  3c
	ldw bc, 0x03                                         ; FB4F99  31 03 00
	lda xiy, (0xf4fa8d:24)                               ; FB4F9C  f2 8d fa f4 35
	lda xix, (xiz-7)                                     ; FB4FA1  be f9 34
	ldir85                                               ; FB4FA4  85 11
	pop XIX                                              ; FB4FA6  5c
	ld XBC,(XIX+0x04)                                    ; FB4FA7  ac 04 21
	push XBC                                             ; FB4FAA  39
	calr SysExParam_CheckConditions                                      ; FB4FAB  1e b8 00
	pop XIY                                              ; FB4FAE  5d
	cp WA,0xffff                                         ; FB4FAF  d8 cf ff ff
	jrl z, .LFB5061                                      ; FB4FB3  76 ab 00
	ld XBC,(XIX+0x04)                                    ; FB4FB6  ac 04 21
	ld (xiz-4), xbc                                      ; FB4FB9  be fc 61
	ld (xiz-18), xbc                                     ; FB4FBC  be ee 61
	lda	xwa, (SysExParamDesc_Placeholder:24)         ; FB4FBF  f2 f9 11 f5 30
	cp XBC,XWA                                           ; FB4FC4  e8 f1
	jrl z, .LFB5061                                      ; FB4FC6  76 98 00
	ld xbc, (xiz-4)                                      ; FB4FC9  ae fc 21
	ld H,(XBC+0x08)                                      ; FB4FCC  89 08 26
	ld XWA,(XIX)                                         ; FB4FCF  a4 20
	ld C,(XWA+0x03)                                      ; FB4FD1  88 03 23
	and C,H                                              ; FB4FD4  ce c3
	jrl z, .LFB5061                                      ; FB4FD6  76 88 00
	pushw 0x06                                           ; FB4FD9  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB4FDC  f2 f2 fe f4 31
	push XBC                                             ; FB4FE1  39
	call SysExTx_Append                                      ; FB4FE2  1d 24 6f fb
	pushw 0x06                                           ; FB4FE6  0b 06 00
	lda xbc, (xiz-14)                                    ; FB4FE9  be f2 31
	push XBC                                             ; FB4FEC  39
	ld XWA,(XIX+0x04)                                    ; FB4FED  ac 04 20
	push XWA                                             ; FB4FF0  38
	call MemCopyWords_Copy                                      ; FB4FF1  1d ce 81 fb
	ld XBC,(XIX)                                         ; FB4FF5  a4 21
	ld A,(XBC)                                           ; FB4FF7  81 21
	set 0x05,A                                           ; FB4FF9  c9 31 05
	ld (xiz-13), a                                       ; FB4FFC  be f3 41
	pushw 0x06                                           ; FB4FFF  0b 06 00
	lda xbc, (xiz-14)                                    ; FB5002  be f2 31
	push XBC                                             ; FB5005  39
	call SysExTx_Append                                      ; FB5006  1d 24 6f fb
	ld XBC,(XIX+0x04)                                    ; FB500A  ac 04 21
	ld (xiz-18), xbc                                     ; FB500D  be ee 61
	ld H,(XBC+0x08)                                      ; FB5010  89 08 26
	ld XWA,(XIX)                                         ; FB5013  a4 20
	ld C,(XWA+0x02)                                      ; FB5015  88 02 23
	ld L,C                                               ; FB5018  cb 8f
	and L,H                                              ; FB501A  ce c7
	ld xbc, (xiz-18)                                     ; FB501C  ae ee 21
	ld A,(XBC+0x0b)                                      ; FB501F  89 0b 21
	pushw wa                                             ; FB5022  28
	pushw hl                                             ; FB5023  2b
	call Lsr8ByCount                                      ; FB5024  1d 28 82 fb
	ld H,A                                               ; FB5028  c9 8e
	ld (xiz-7), a                                        ; FB502A  be f9 41
	ld C,H                                               ; FB502D  ce 8b
	and C,0x0f                                           ; FB502F  cb cc 0f
	ld (xiz-6), c                                        ; FB5032  be fa 43
	ld c, (xiz-7)                                        ; FB5035  8e f9 23
	srl c, 0x04                                          ; FB5038  cb ef 04
	ld (xiz-7), c                                        ; FB503B  be f9 43
	pushw 0x03                                           ; FB503E  0b 03 00
	lda xbc, (xiz-7)                                     ; FB5041  be f9 31
	push XBC                                             ; FB5044  39
	call SysExTx_Append                                      ; FB5045  1d 24 6f fb
	call SysExTx_AppendChecksumF7                                      ; FB5049  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB504D  e2 88 fc 60 21
	push XBC                                             ; FB5052  39
	call SysExTx_SendFrameBothPorts                                      ; FB5053  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB5057  1d 81 80 fb
	add XSP,0x00000020                                   ; FB505B  ef c8 20 00 00 00
.LFB5061:
	pop XIX                                              ; FB5061  5c
	popw hl                                              ; FB5062  4b
	unlk XIZ                                             ; FB5063  ee 0d
	ret                                                  ; FB5065  0e
; SysExParam_CheckConditions(desc): desc+0x0C and desc+0x0D each select a 6-byte {ptr32, mask, value} condition (prom_b 0xF51E34,
;   0xF51E46; 0 = none); WA = 0 when (*ptr & mask) == value for both, else 0xFFFF.
SysExParam_CheckConditions:
	link XIZ,0xfffc                                      ; FB5066  ee 0c fc ff
	pushw hl                                             ; FB506A  2b
	push XIX                                             ; FB506B  3c
	lda xix, (0xf51e46:24)                               ; FB506C  f2 46 1e f5 34
	ld XBC,(XIZ+0x08)                                    ; FB5071  ae 08 21
	ld H,(XBC+0x0c)                                      ; FB5074  89 0c 26
	cp h, 0x00:i3                                          ; FB5077  ce d8
	jr z, .LFB50AF                                       ; FB5079  66 34
	ld a, 0x06:opc                                          ; FB507B  21 06
	mul wa, h                                          ; FB507D  ce 41
	extz XWA                                             ; FB507F  e8 12
	ld (xiz-4), xwa                                      ; FB5081  be fc 60
	inc 4,XWA                                            ; FB5084  e8 64
	add XWA,0x00f51e34                                   ; FB5086  e8 c8 34 1e f5 00
	ld H,(XWA)                                           ; FB508C  80 26
	lda xwa, (0xf51e34:24)                               ; FB508E  f2 34 1e f5 30
	add	xwa, (xiz-4)                                 ; FB5093  ae fc 80
	ld XIY,(XWA)                                         ; FB5096  a0 25
	ld W,(XIY)                                           ; FB5098  85 20
	ld L,W                                               ; FB509A  c8 8f
	and L,H                                              ; FB509C  ce c7
	ld xwa, (xiz-4)                                      ; FB509E  ae fc 20
	inc 5,XWA                                            ; FB50A1  e8 65
	add XWA,0x00f51e34                                   ; FB50A3  e8 c8 34 1e f5 00
	ld W,(XWA)                                           ; FB50A9  80 20
	cp L,W                                               ; FB50AB  c8 f7
	jr nz, .LFB50E2                                      ; FB50AD  6e 33
.LFB50AF:
	ld XBC,(XIZ+0x08)                                    ; FB50AF  ae 08 21
	ld H,(XBC+0x0d)                                      ; FB50B2  89 0d 26
	cp h, 0x00:i3                                          ; FB50B5  ce d8
	jr z, .LFB50E7                                       ; FB50B7  66 2e
	ld a, 0x06:opc                                          ; FB50B9  21 06
	mul wa, h                                          ; FB50BB  ce 41
	extz XWA                                             ; FB50BD  e8 12
	ld (xiz-4), xwa                                      ; FB50BF  be fc 60
	inc 4,XWA                                            ; FB50C2  e8 64
	add XWA,XIX                                          ; FB50C4  ec 80
	ld H,(XWA)                                           ; FB50C6  80 26
	ld XWA,XIX                                           ; FB50C8  ec 88
	add	xwa, (xiz-4)                                 ; FB50CA  ae fc 80
	ld XIY,(XWA)                                         ; FB50CD  a0 25
	ld W,(XIY)                                           ; FB50CF  85 20
	ld L,W                                               ; FB50D1  c8 8f
	and L,H                                              ; FB50D3  ce c7
	ld xwa, (xiz-4)                                      ; FB50D5  ae fc 20
	inc 5,XWA                                            ; FB50D8  e8 65
	add XWA,XIX                                          ; FB50DA  ec 80
	ld C,(XWA)                                           ; FB50DC  80 23
	cp L,C                                               ; FB50DE  cb f7
	jr z, .LFB50E7                                       ; FB50E0  66 05
.LFB50E2:
	ldw wa, 0xffff                                       ; FB50E2  30 ff ff
	jr .LFB50E9                                          ; FB50E5  68 02
.LFB50E7:
	sub WA,WA                                            ; FB50E7  d8 a0
.LFB50E9:
	pop XIX                                              ; FB50E9  5c
	popw hl                                              ; FB50EA  4b
	unlk XIZ                                             ; FB50EB  ee 0d
	ret                                                  ; FB50ED  0e
sub_FB50EE:
	link XIZ,0xfff8                                      ; FB50EE  ee 0c f8 ff
	push XIX                                             ; FB50F2  3c
	lda xix, (xiz-8)                                     ; FB50F3  be f8 34
	lda xbc, (0xf51e30:24)                               ; FB50F6  f2 30 1e f5 31
	push XBC                                             ; FB50FB  39
	ld XWA,(XIZ+0x08)                                    ; FB50FC  ae 08 20
	push XWA                                             ; FB50FF  38
	calr SysExParamDesc_FindForEvent                                      ; FB5100  1e 1d fc
	ld (XIX+0x04),XIY                                    ; FB5103  bc 04 65
	ld XBC,(XIZ+0x08)                                    ; FB5106  ae 08 21
	ld (XIX),XBC                                         ; FB5109  b4 61
	push XIX                                             ; FB510B  3c
	ld XBC,(XIX+0x04)                                    ; FB510C  ac 04 21
	ld XWA,(XBC+0x10)                                    ; FB510F  a9 10 20
	lda xiy, (.LFB511A:24)                               ; FB5112  f2 1a 51 fb 35
	push XIY                                             ; FB5117  3d
	jp (xwa)                                             ; FB5118  b0 d8
.LFB511A:
	inc 8,XSP                                            ; FB511A  ef 60
	inc 4,XSP                                            ; FB511C  ef 64
	pop XIX                                              ; FB511E  5c
	unlk XIZ                                             ; FB511F  ee 0d
	ret                                                  ; FB5121  0e
; SysExCmd_DumpRequest_SystemPartMidi: command 0x1B (2B, area 40): send job 4.
SysExCmd_DumpRequest_SystemPartMidi:
	ld (0x60f802:24), 0x04                             ; FB5122  f2 02 f8 60 00 04
	calr SysExCmd_DumpRequestGate                                      ; FB5128  1e 3f 00
	ret                                                  ; FB512B  0e
; SysExCmd_DumpRequest_Sound: command 0x1C (2B, area 20): send job 3.
SysExCmd_DumpRequest_Sound:
	ld (0x60f802:24), 0x03                             ; FB512C  f2 02 f8 60 00 03
	calr SysExCmd_DumpRequestGate                                      ; FB5132  1e 35 00
	ret                                                  ; FB5135  0e
; SysExCmd_DumpRequest_Job1: command 0x1D, job 1 (SysExDump_Job1_None); no wire sequence reaches it.
SysExCmd_DumpRequest_Job1:
	ld (0x60f802:24), 0x01                             ; FB5136  f2 02 f8 60 00 01
	calr SysExCmd_DumpRequestGate                                      ; FB513C  1e 2b 00
	ret                                                  ; FB513F  0e
; SysExCmd_DumpRequest_Sequencer: command 0x1E (2B, area 60): send job 2.
SysExCmd_DumpRequest_Sequencer:
	ld (0x60f802:24), 0x02                             ; FB5140  f2 02 f8 60 00 02
	calr SysExCmd_DumpRequestGate                                      ; FB5146  1e 21 00
	ret                                                  ; FB5149  0e
; SysExCmd_DumpRequest_Combination: command 0x1F (2B, area 50): send job 5.
SysExCmd_DumpRequest_Combination:
	ld (0x60f802:24), 0x05                             ; FB514A  f2 02 f8 60 00 05
	calr SysExCmd_DumpRequestGate                                      ; FB5150  1e 17 00
	ret                                                  ; FB5153  0e
; SysExDump_StopTransportsAndSend: sets bit 7 of (0x60F802), T_Transport_StopAllRunning with XDE/XHL/XIX/XIZ preserved, then SysExDump_RunSendJob;
;   called from SysExCmd_DumpRequestGate.  Basis: body.
SysExDump_StopTransportsAndSend:
	set	7, (0x60f802:24)                             ; FB5154  f2 02 f8 60 bf
	push XDE                                             ; FB5159  3a
	push XHL                                             ; FB515A  3b
	push XIX                                             ; FB515B  3c
	push XIZ                                             ; FB515C  3e
	call T_Transport_StopAllRunning                                        ; FB515D  1d ac 09 f4
	pop XIZ                                              ; FB5161  5e
	pop XIX                                              ; FB5162  5c
	pop XHL                                              ; FB5163  5b
	pop XDE                                              ; FB5164  5a
	call SysExDump_RunSendJob                                      ; FB5165  1d 49 20 fb
	ret                                                  ; FB5169  0e
; SysExCmd_DumpRequestGate: commands 0x1B-0x1F run SysExDump_StopTransportsAndSend only on the SYSEX BULK DUMP screen (UI_ScreenLatch 0x79) or
;   when PanelModeGroup == 1 and UI_ScreenLatch == 1; otherwise status 0x11 (sysex-probes/sysex_handshake_gate.py).
SysExCmd_DumpRequestGate:
	cp	(UI_ScreenLatch:16), 0x79                            ; FB516A  c1 7a 20 3f 79
	jr z, .LFB517F                                       ; FB516F  66 0e
	cp	(PanelModeGroup:16), 0x01                            ; FB5171  c1 76 20 3f 01
	jr nz, .LFB5184                                      ; FB5176  6e 0c
	cp	(UI_ScreenLatch:16), 0x01                            ; FB5178  c1 7a 20 3f 01
	jr nz, .LFB5184                                      ; FB517D  6e 05
.LFB517F:
	calr SysExDump_StopTransportsAndSend                                      ; FB517F  1e d2 ff
	jr .LFB5196                                          ; FB5182  68 12
.LFB5184:
	pushw 0x11                                           ; FB5184  0b 11 00
	pushw 0x04                                           ; FB5187  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB518A  e2 d8 fc 60 21
	push XBC                                             ; FB518F  39
	call U8Rec16_SetField                                      ; FB5190  1d 19 62 fb
	inc 8,XSP                                            ; FB5194  ef 60
.LFB5196:
	ret                                                  ; FB5196  0e
; SysExRx_AnswerRefused2B2C: for a family 2B or 2C message that is refused: SysExTx_Append of F0 50 29 7E F7 (0xF4FEC8), sent on both ports.
SysExRx_AnswerRefused2B2C:
	pushw hl                                             ; FB5197  2b
	pushw 0x04                                           ; FB5198  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB519B  e2 d8 fc 60 21
	push XBC                                             ; FB51A0  39
	call U8Rec16_GetField                                      ; FB51A1  1d d3 62 fb
	inc 6,XSP                                            ; FB51A5  ef 66
	cp a, 0x00:i3                                          ; FB51A7  c9 d8
	jr z, .LFB51E5                                       ; FB51A9  66 3a
	pushw 0x05                                           ; FB51AB  0b 05 00
	ld xbc, (0x60fcd8:24)                               ; FB51AE  e2 d8 fc 60 21
	push XBC                                             ; FB51B3  39
	call U8Rec16_GetField                                      ; FB51B4  1d d3 62 fb
	ld H,A                                               ; FB51B8  c9 8e
	inc 6,XSP                                            ; FB51BA  ef 66
	cp A,0x2b                                            ; FB51BC  c9 cf 2b
	jr z, .LFB51C6                                       ; FB51BF  66 05
	cp A,0x2c                                            ; FB51C1  c9 cf 2c
	jr nz, .LFB51E5                                      ; FB51C4  6e 1f
.LFB51C6:
	pushw 0x05                                           ; FB51C6  0b 05 00
	lda xbc, (0xf4fec8:24)                               ; FB51C9  f2 c8 fe f4 31
	push XBC                                             ; FB51CE  39
	call SysExTx_Append                                      ; FB51CF  1d 24 6f fb
	ld xbc, (0x60fc88:24)                               ; FB51D3  e2 88 fc 60 21
	push XBC                                             ; FB51D8  39
	call SysExTx_SendFrameBothPorts                                      ; FB51D9  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB51DD  1d 81 80 fb
	inc 8,XSP                                            ; FB51E1  ef 60
	inc 2,XSP                                            ; FB51E3  ef 62
.LFB51E5:
	popw hl                                              ; FB51E5  4b
	ret                                                  ; FB51E6  0e
; SysExCmd_GmSystemOn: command 0x20, F0 7E 7F 09 01 F7: set bit 7 of (0x60F020), set bit 2 (GENERAL MIDI MODE) of (0x7F4D),
;   post {0x91, 3, (0x7F4D), 4} (sysex-probes/decode-findings.json).
SysExCmd_GmSystemOn:
	pushw hl                                             ; FB51E7  2b
	set	7, (0x60f020:24)                             ; FB51E8  f2 20 f0 60 bf
	or	(0x7f4d:16), 0x04                            ; FB51ED  c1 4d 7f 3e 04
	ld h, (0x7f4d:16)                                   ; FB51F2  c1 4d 7f 26
	pushw 0x04                                           ; FB51F6  0b 04 00
	ld C,H                                               ; FB51F9  ce 8b
	extz BC                                              ; FB51FB  d9 12
	pushw bc                                             ; FB51FD  29
	pushw 0x03                                           ; FB51FE  0b 03 00
	pushw 0x91                                           ; FB5201  0b 91 00
	call T_PendingEventQueue_AppendStackArgs                                        ; FB5204  1d 18 1b f4
	inc 8,XSP                                            ; FB5208  ef 60
	popw hl                                              ; FB520A  4b
	ret                                                  ; FB520B  0e
; SysExCmd_GmSystemOff: command 0x21, F0 7E 7F 09 02 F7: when bit 2 of (0x7F4D) is set, clear it and post the same record.
SysExCmd_GmSystemOff:
	pushw hl                                             ; FB520C  2b
	push XIX                                             ; FB520D  3c
	lda xix, (0x7f4a:16)                                ; FB520E  f1 4a 7f 34
	extz XIX                                             ; FB5212  ec 12
	ld C,(XIX+0x03)                                      ; FB5214  8c 03 23
	and C,0x04                                           ; FB5217  cb cc 04
	jr z, .LFB523E                                       ; FB521A  66 22
	set	7, (0x60f020:24)                             ; FB521C  f2 20 f0 60 bf
	extz XIX                                             ; FB5221  ec 12
	and (XIX+0x03),0xfb                                  ; FB5223  8c 03 3c fb
	ld H,(XIX+0x03)                                      ; FB5227  8c 03 26
	pushw 0x04                                           ; FB522A  0b 04 00
	ld C,H                                               ; FB522D  ce 8b
	extz BC                                              ; FB522F  d9 12
	pushw bc                                             ; FB5231  29
	pushw 0x03                                           ; FB5232  0b 03 00
	pushw 0x91                                           ; FB5235  0b 91 00
	call T_PendingEventQueue_AppendStackArgs                                        ; FB5238  1d 18 1b f4
	inc 8,XSP                                            ; FB523C  ef 60
.LFB523E:
	pop XIX                                              ; FB523E  5c
	popw hl                                              ; FB523F  4b
	ret                                                  ; FB5240  0e
; SysExParam_SetCombinationWriteRequest: setter of COMBINATION WRITE REQUEST (receive-only).
;  Descriptor field: +0x14.
;  (notes/sysex-probes/sysex_param_addresses.py descriptors (+0x14 setter, +0x18 reader); names: param_names.json (Technics Reference Guide))
SysExParam_SetCombinationWriteRequest:
	link XIZ,0xfff4                                      ; FB5241  ee 0c f4 ff
	pushw hl                                             ; FB5245  2b
	push XIX                                             ; FB5246  3c
	lda xix, (xiz-4)                                     ; FB5247  be fc 34
	ld c, (0x7fd6:16)                                   ; FB524A  c1 d6 7f 23
	and C,0x02                                           ; FB524E  cb cc 02
	jrl nz, .LFB5364                                     ; FB5251  7e 10 01
	ld xbc, (0x60fc80:24)                               ; FB5254  e2 80 fc 60 21
	push XBC                                             ; FB5259  39
	call SysExBuf_ReadNibblePair                                      ; FB525A  1d f3 77 fb
	ld H,A                                               ; FB525E  c9 8e
	ld XBC,(XIZ+0x08)                                    ; FB5260  ae 08 21
	ld W,(XBC+0x09)                                      ; FB5263  89 09 20
	pop XIY                                              ; FB5266  5d
	cp W,A                                               ; FB5267  c9 f0
	jrl ugt, .LFB5368                                    ; FB5269  7b fc 00
	ld W,(XBC+0x0a)                                      ; FB526C  89 0a 20
	cp A,W                                               ; FB526F  c8 f1
	jrl ugt, .LFB5368                                    ; FB5271  7b f4 00
	ld (UI_StatusCode:16), 0x25                                 ; FB5274  f1 80 28 00 25
	call MessageScreen_Paint_SaveRegs                                      ; FB5279  1d 9b 7e fb
	ld (0x7659:16), 0x00                                 ; FB527D  f1 59 76 00 00
	ld (0x7679:16), 0x00                                 ; FB5282  f1 79 76 00 00
	ld (0x7699:16), 0x00                                 ; FB5287  f1 99 76 00 00
	ld XBC,0x00ec0300                                    ; FB528C  41 00 03 ec 00
	ld (xiz-8), xbc                                      ; FB5291  be f8 61
	ld A,H                                               ; FB5294  ce 89
	extz WA                                              ; FB5296  d8 12
	mul WA,0x02c0                                        ; FB5298  d8 08 c0 02
	add XBC,XWA                                          ; FB529C  e8 81
	ld (xiz-12), xbc                                     ; FB529E  be f4 61
	push XBC                                             ; FB52A1  39
	call T_Link_SendCommand3_WaitTicks                                        ; FB52A2  1d 34 12 f4
	ld xbc, (xiz-12)                                     ; FB52A6  ae f4 21
	push XBC                                             ; FB52A9  39
	pushw 0x02c0                                         ; FB52AA  0b c0 02
	lda xwa, (Combination_Current:16)                                ; FB52AD  f1 20 76 30
	push XWA                                             ; FB52B1  38
	call T_Link_SendCommandE4                            ; FB52B2  1d 30 12 f4
	ld xbc, (xiz-12)                                     ; FB52B6  ae f4 21
	push XBC                                             ; FB52B9  39
	call T_Link_SendCommand5_WaitDone                    ; FB52BA  1d 38 12 f4
	ld l, 0x98:opc                                          ; FB52BE  27 98
	ld (XIX),L                                           ; FB52C0  b4 47
	ld (XIX+0x01),0x02                                   ; FB52C2  bc 01 00 02
	ld (XIX+0x02),0x08                                   ; FB52C6  bc 02 00 08
	ld (XIX+0x03),0x3f                                   ; FB52CA  bc 03 00 3f
	push XIX                                             ; FB52CE  3c
	call IndexedTable_MergeMaskedByte                                      ; FB52CF  1d 2b 78 fb
	ld (XIX),L                                           ; FB52D3  b4 47
	ld (XIX+0x01),0x01                                   ; FB52D5  bc 01 00 01
	ld (XIX+0x02),H                                      ; FB52D9  bc 02 46
	ld (XIX+0x03),0x7f                                   ; FB52DC  bc 03 00 7f
	push XIX                                             ; FB52E0  3c
	call IndexedTable_MergeMaskedByte                                      ; FB52E1  1d 2b 78 fb
	ld (0x60f189:24), h                                 ; FB52E5  f2 89 f1 60 46
	ld (0x60f18a:24), 0x08                             ; FB52EA  f2 8a f1 60 00 08
	ld (0x60f180:24), l                                 ; FB52F0  f2 80 f1 60 47
	call T_CombiSel_GroupMemberFromNumberAndBank                                        ; FB52F5  1d 08 08 f4
	ld (XIX),L                                           ; FB52F9  b4 47
	ld (XIX+0x01),0x06                                   ; FB52FB  bc 01 00 06
	ld c, (0x60f18d:24)                                 ; FB52FF  c2 8d f1 60 23
	ld (XIX+0x02),C                                      ; FB5304  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB5307  bc 03 00 ff
	push XIX                                             ; FB530B  3c
	call IndexedTable_MergeMaskedByte                                      ; FB530C  1d 2b 78 fb
	ld (XIX),L                                           ; FB5310  b4 47
	ld (XIX+0x01),0x07                                   ; FB5312  bc 01 00 07
	ld c, (0x60f18e:24)                                 ; FB5316  c2 8e f1 60 23
	ld (XIX+0x02),C                                      ; FB531B  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB531E  bc 03 00 ff
	push XIX                                             ; FB5322  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5323  1d 2b 78 fb
	ld (XIX),L                                           ; FB5327  b4 47
	ld (XIX+0x01),0x08                                   ; FB5329  bc 01 00 08
	ld c, (0x60f18f:24)                                 ; FB532D  c2 8f f1 60 23
	ld (XIX+0x02),C                                      ; FB5332  bc 02 43
	ld (XIX+0x03),0xff                                   ; FB5335  bc 03 00 ff
	push XIX                                             ; FB5339  3c
	call IndexedTable_MergeMaskedByte                                      ; FB533A  1d 2b 78 fb
	push XDE                                             ; FB533E  3a
	push XHL                                             ; FB533F  3b
	push XIX                                             ; FB5340  3c
	push XIZ                                             ; FB5341  3e
	call T_Combination_Recall                                        ; FB5342  1d 54 02 f4
	call T_Queue2C00_DrainPassB                          ; FB5346  1d 38 00 f4
	pop XIZ                                              ; FB534A  5e
	pop XIX                                              ; FB534B  5c
	pop XHL                                              ; FB534C  5b
	pop XDE                                              ; FB534D  5a
	or	(UI_Request_Hi:16), 0x12                            ; FB534E  c1 71 20 3e 12
	ld (UI_Request:16), 0x02                                 ; FB5353  f1 70 20 00 02
	call SoundGroup_ReloadSelection_SaveRegs                                      ; FB5358  1d 3c 20 fb
	add XSP,0x00000026                                   ; FB535C  ef c8 26 00 00 00
	jr .LFB5368                                          ; FB5362  68 04
.LFB5364:
	call SysExDump_ShowWriteProtectError                                      ; FB5364  1d 38 7e fb
.LFB5368:
	pop XIX                                              ; FB5368  5c
	popw hl                                              ; FB5369  4b
	unlk XIZ                                             ; FB536A  ee 0d
	ret                                                  ; FB536C  0e
; SysExTx_CombinationNumberAndBank: Transmits the F0 50 2C reply for COMBINATION NUMBER and BANK:
;   SysExParam_CheckConditions, placeholder and mask tests, header F0 50 2C 04 00 11, the descriptor's 6 address/count
;   bytes, then (0x7F03) & 0x7F as two nibbles and (0x7F04) bit 3 as 0/1, flag 0, checksum, F7, both ports. Called by
;   SysExParam_GetCombinationNumberAndBank, the descriptor's +0x18 reader; twin of SysExTx_ProgramChangeAndBank.
;   Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
SysExTx_CombinationNumberAndBank:
	link XIZ,0xfff3                                      ; FB536D  ee 0c f3 ff
	pushw hl                                             ; FB5371  2b
	push XIX                                             ; FB5372  3c
	lda xix, (xiz-9)                                     ; FB5373  be f7 34
	push XIX                                             ; FB5376  3c
	ldw bc, 0x05                                         ; FB5377  31 05 00
	lda xiy, (0xf4fa90:24)                               ; FB537A  f2 90 fa f4 35
	lda xix, (xiz-9)                                     ; FB537F  be f7 34
	ldir85                                               ; FB5382  85 11
	pop XIX                                              ; FB5384  5c
	ld XBC,(XIZ+0x08)                                    ; FB5385  ae 08 21
	ld XWA,(XBC+0x04)                                    ; FB5388  a9 04 20
	push XWA                                             ; FB538B  38
	calr SysExParam_CheckConditions                                      ; FB538C  1e d7 fc
	pop XIY                                              ; FB538F  5d
	cp WA,0xffff                                         ; FB5390  d8 cf ff ff
	jrl z, .LFB5420                                      ; FB5394  76 89 00
	ld XBC,(XIZ+0x08)                                    ; FB5397  ae 08 21
	ld XWA,(XBC+0x04)                                    ; FB539A  a9 04 20
	ld (xiz-4), xwa                                      ; FB539D  be fc 60
	ld (xiz-13), xwa                                     ; FB53A0  be f3 60
	lda	xiy, (SysExParamDesc_Placeholder:24)         ; FB53A3  f2 f9 11 f5 35
	cp XWA,XIY                                           ; FB53A8  ed f0
	jrl z, .LFB5420                                      ; FB53AA  76 73 00
	ld xwa, (xiz-4)                                      ; FB53AD  ae fc 20
	ld H,(XWA+0x08)                                      ; FB53B0  88 08 26
	ld XIY,(XBC)                                         ; FB53B3  a1 25
	ld C,(XIY+0x03)                                      ; FB53B5  8d 03 23
	and C,H                                              ; FB53B8  ce c3
	jr z, .LFB5420                                       ; FB53BA  66 64
	pushw 0x06                                           ; FB53BC  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB53BF  f2 f2 fe f4 31
	push XBC                                             ; FB53C4  39
	call SysExTx_Append                                      ; FB53C5  1d 24 6f fb
	pushw 0x06                                           ; FB53C9  0b 06 00
	ld XBC,(XIZ+0x08)                                    ; FB53CC  ae 08 21
	ld XWA,(XBC+0x04)                                    ; FB53CF  a9 04 20
	push XWA                                             ; FB53D2  38
	call SysExTx_Append                                      ; FB53D3  1d 24 6f fb
	ld h, (0x7f03:16)                                   ; FB53D7  c1 03 7f 26
	ld C,H                                               ; FB53DB  ce 8b
	res 0x07,C                                           ; FB53DD  cb 30 07
	srl c, 0x04                                          ; FB53E0  cb ef 04
	ld (XIX),C                                           ; FB53E3  b4 43
	ld C,H                                               ; FB53E5  ce 8b
	and C,0x0f                                           ; FB53E7  cb cc 0f
	ld (XIX+0x01),C                                      ; FB53EA  bc 01 43
	ld h, (0x7f04:16)                                   ; FB53ED  c1 04 7f 26
	ld (XIX+0x02),0x00                                   ; FB53F1  bc 02 00 00
	ld C,H                                               ; FB53F5  ce 8b
	and C,0x08                                           ; FB53F7  cb cc 08
	srl c, 0x03                                          ; FB53FA  cb ef 03
	ld (XIX+0x03),C                                      ; FB53FD  bc 03 43
	pushw 0x05                                           ; FB5400  0b 05 00
	push XIX                                             ; FB5403  3c
	call SysExTx_Append                                      ; FB5404  1d 24 6f fb
	call SysExTx_AppendChecksumF7                                      ; FB5408  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB540C  e2 88 fc 60 21
	push XBC                                             ; FB5411  39
	call SysExTx_SendFrameBothPorts                                      ; FB5412  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB5416  1d 81 80 fb
	add XSP,0x00000016                                   ; FB541A  ef c8 16 00 00 00
.LFB5420:
	pop XIX                                              ; FB5420  5c
	popw hl                                              ; FB5421  4b
	unlk XIZ                                             ; FB5422  ee 0d
	ret                                                  ; FB5424  0e
; SysExTx_ProgramChangeAndBank: Transmits the F0 50 2C reply for PROGRAM CHANGE & BANK: descriptor conditions and part
;   mask checked, header F0 50 2C 04 00 11, address (part + 0x20), then the part's program and bank (IndexedTable
;   record) as seven nibbles, checksum, F7, on both ports. Called by SysExParam_GetProgramChangeAndBank, the
;   descriptor's +0x18 reader. Basis: caller + body + descriptor table. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_h.json)
SysExTx_ProgramChangeAndBank:
	link XIZ,0xffe6                                      ; FB5425  ee 0c e6 ff
	pushw hl                                             ; FB5429  2b
	pushw de                                             ; FB542A  2a
	push XIX                                             ; FB542B  3c
	ldw bc, 0x07                                         ; FB542C  31 07 00
	lda xiy, (0xf4fa95:24)                               ; FB542F  f2 95 fa f4 35
	lda xix, (xiz-11)                                    ; FB5434  be f5 34
	ldir85                                               ; FB5437  85 11
	ld XBC,(XIZ+0x08)                                    ; FB5439  ae 08 21
	ld XWA,(XBC+0x04)                                    ; FB543C  a9 04 20
	push XWA                                             ; FB543F  38
	calr SysExParam_CheckConditions                                      ; FB5440  1e 23 fc
	pop XIY                                              ; FB5443  5d
	cp WA,0xffff                                         ; FB5444  d8 cf ff ff
	jrl z, .LFB5567                                      ; FB5448  76 1c 01
	ld XIX,(XIZ+0x08)                                    ; FB544B  ae 08 24
	ld XBC,(XIX+0x04)                                    ; FB544E  ac 04 21
	ld XIX,XBC                                           ; FB5451  e9 8c
	ld (xiz-22), xbc                                     ; FB5453  be ea 61
	lda	xwa, (SysExParamDesc_Placeholder:24)         ; FB5456  f2 f9 11 f5 30
	cp XBC,XWA                                           ; FB545B  e8 f1
	jrl z, .LFB5567                                      ; FB545D  76 07 01
	ld H,(XIX+0x08)                                      ; FB5460  8c 08 26
	ld XBC,(XIZ+0x08)                                    ; FB5463  ae 08 21
	ld XWA,(XBC)                                         ; FB5466  a1 20
	ld C,(XWA+0x03)                                      ; FB5468  88 03 23
	and C,H                                              ; FB546B  ce c3
	jrl z, .LFB5567                                      ; FB546D  76 f7 00
	pushw 0x06                                           ; FB5470  0b 06 00
	lda xbc, (0xf4fef2:24)                               ; FB5473  f2 f2 fe f4 31
	push XBC                                             ; FB5478  39
	call SysExTx_Append                                      ; FB5479  1d 24 6f fb
	pushw 0x06                                           ; FB547D  0b 06 00
	lda xbc, (xiz-18)                                    ; FB5480  be ee 31
	push XBC                                             ; FB5483  39
	ld XWA,(XIZ+0x08)                                    ; FB5484  ae 08 20
	ld XIY,(XWA+0x04)                                    ; FB5487  a8 04 25
	push XIY                                             ; FB548A  3d
	call MemCopyWords_Copy                                      ; FB548B  1d ce 81 fb
	ld XBC,(XIZ+0x08)                                    ; FB548F  ae 08 21
	ld XWA,(XBC)                                         ; FB5492  a1 20
	ld C,(XWA)                                           ; FB5494  80 23
	add C,0x20                                           ; FB5496  cb c8 20
	ld (xiz-17), c                                       ; FB5499  be ef 43
	pushw 0x06                                           ; FB549C  0b 06 00
	lda xbc, (xiz-18)                                    ; FB549F  be ee 31
	push XBC                                             ; FB54A2  39
	call SysExTx_Append                                      ; FB54A3  1d 24 6f fb
	ld xbc, (IndexedTable_Base:24)                               ; FB54A7  e2 18 f0 60 21
	ld (xiz-4), xbc                                      ; FB54AC  be fc 61
	sub XWA,XWA                                          ; FB54AF  e8 a0
	dec 1,XWA                                            ; FB54B1  e8 69
	ld (xiz-22), xwa                                     ; FB54B3  be ea 60
	ld XIY,(XIZ+0x08)                                    ; FB54B6  ae 08 25
	ld XBC,(XIY)                                         ; FB54B9  a5 21
	ld A,(XBC)                                           ; FB54BB  81 21
	mul A,0x04                                           ; FB54BD  c9 08 04
	extz XWA                                             ; FB54C0  e8 12
	ld (xiz-26), xwa                                     ; FB54C2  be e6 60
	ld xix, (xiz-4)                                      ; FB54C5  ae fc 24
	add XWA,XIX                                          ; FB54C8  ec 80
	ld XBC,(XWA)                                         ; FB54CA  a0 21
	ld XIX,XBC                                           ; FB54CC  e9 8c
	add XSP,0x00000016                                   ; FB54CE  ef c8 16 00 00 00
	cp	xbc, (xiz-22)                                ; FB54D4  ae ea f1
	jrl z, .LFB5567                                      ; FB54D7  76 8d 00
	ld C,(XIX)                                           ; FB54DA  84 23
	res 0x07,C                                           ; FB54DC  cb 30 07
	ld (xiz-11), c                                       ; FB54DF  be f5 43
	ld XBC,(XIZ+0x08)                                    ; FB54E2  ae 08 21
	ld XWA,(XBC)                                         ; FB54E5  a1 20
	ld C,(XWA)                                           ; FB54E7  80 23
	mul C,0x04                                           ; FB54E9  cb 08 04
	extz XBC                                             ; FB54EC  e9 12
	add	xbc, (xiz-4)                                 ; FB54EE  ae fc 81
	ld XWA,(XBC)                                         ; FB54F1  a1 20
	ld H,(XWA+0x01)                                      ; FB54F3  88 01 26
	ld A,H                                               ; FB54F6  ce 89
	and A,0x3f                                           ; FB54F8  c9 cc 3f
	ld L,A                                               ; FB54FB  c9 8f
	srl l, 0x04                                          ; FB54FD  cf ef 04
	ld d, 0x0f:opc                                          ; FB5500  24 0f
	ld A,D                                               ; FB5502  cc 89
	and A,L                                              ; FB5504  cf c1
	ld (xiz-9), a                                        ; FB5506  be f7 41
	ld C,D                                               ; FB5509  cc 8b
	and C,H                                              ; FB550B  ce c3
	sll c, 0x04                                          ; FB550D  cb ee 04
	ld (xiz-7), c                                        ; FB5510  be f9 43
	ld c, (xiz-11)                                       ; FB5513  8e f5 23
	and C,D                                              ; FB5516  cc c3
	ld (xiz-10), c                                       ; FB5518  be f6 43
	ld c, (xiz-11)                                       ; FB551B  8e f5 23
	srl c, 0x04                                          ; FB551E  cb ef 04
	ld (xiz-11), c                                       ; FB5521  be f5 43
	ld c, (xiz-9)                                        ; FB5524  8e f7 23
	and C,D                                              ; FB5527  cc c3
	ld (xiz-8), c                                        ; FB5529  be f8 43
	ld c, (xiz-9)                                        ; FB552C  8e f7 23
	srl c, 0x04                                          ; FB552F  cb ef 04
	ld (xiz-9), c                                        ; FB5532  be f7 43
	ld c, (xiz-7)                                        ; FB5535  8e f9 23
	and C,D                                              ; FB5538  cc c3
	ld (xiz-6), c                                        ; FB553A  be fa 43
	ld c, (xiz-7)                                        ; FB553D  8e f9 23
	srl c, 0x04                                          ; FB5540  cb ef 04
	ld (xiz-7), c                                        ; FB5543  be f9 43
	pushw 0x07                                           ; FB5546  0b 07 00
	lda xbc, (xiz-11)                                    ; FB5549  be f5 31
	push XBC                                             ; FB554C  39
	call SysExTx_Append                                      ; FB554D  1d 24 6f fb
	call SysExTx_AppendChecksumF7                                      ; FB5551  1d 11 71 fb
	ld xbc, (0x60fc88:24)                               ; FB5555  e2 88 fc 60 21
	push XBC                                             ; FB555A  39
	call SysExTx_SendFrameBothPorts                                      ; FB555B  1d bb 71 fb
	call SysExTx_SwapBuffers                                      ; FB555F  1d 81 80 fb
	inc 8,XSP                                            ; FB5563  ef 60
	inc 2,XSP                                            ; FB5565  ef 62
.LFB5567:
	pop XIX                                              ; FB5567  5c
	popw de                                              ; FB5568  4a
	popw hl                                              ; FB5569  4b
	unlk XIZ                                             ; FB556A  ee 0d
	ret                                                  ; FB556C  0e
; GmReset_SwitchToSoundMode: First step of GmMode_ResetToDefaults: in COMBINATION mode ((0x7F02) & 0xF0 == 0x10) calls
;   Mode_SwitchToSound, and if PanelMode is 2 also requests screen 1 (UI_Request_Hi |= 0x12, UI_Request := 1);
;   otherwise nothing. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
GmReset_SwitchToSoundMode:
	ld c, (0x7f02:16)                                   ; FB556D  c1 02 7f 23
	and C,0xf0                                           ; FB5571  cb cc f0
	cp C,0x10                                            ; FB5574  cb cf 10
	jr nz, .LFB558E                                      ; FB5577  6e 15
	call Mode_SwitchToSound_SaveRegs                                      ; FB5579  1d f1 7a fb
	cp	(PanelMode:16), 0x02                            ; FB557D  c1 78 20 3f 02
	jr nz, .LFB558E                                      ; FB5582  6e 0a
	or	(UI_Request_Hi:16), 0x12                            ; FB5584  c1 71 20 3e 12
	ld (UI_Request:16), 0x01                                 ; FB5589  f1 70 20 00 01
.LFB558E:
	ret                                                  ; FB558E  0e
; GmReset_FieldTablesAndEffectAlgorithms: Last step of GmMode_ResetToDefaults: ParamFieldInit_x32_F4FE38's 6 rows each
;   merged into 32 consecutive records (KEY SCALING off; MAIN OUT 1, SUB OUT 0, VELOCITY OFFSET 0x18, ASSIGN MODE 0,
;   MIDI OUT KEY TRANSPOSE 0x40), ParamFieldInit_F4FE50's 6 rows once each (EFFECT COMMON ALGORITHM, DATA LOAD FILTER
;   EFFECT&OUTPUT, EFFECT1/2 OUTPUT SELECT, DRUMS MAP SELECT, record 0x98 +9 bit 0), then
;   DspEffect_ApplyAlgorithmDefaults for blocks 0x61/0x62/0x63 with 1/0x23/0x14. Basis: caller + body + tables + SysEx
;   descriptors. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
GmReset_FieldTablesAndEffectAlgorithms:
	link XIZ,0xfff4                                      ; FB558F  ee 0c f4 ff
	pushw hl                                             ; FB5593  2b
	push XIX                                             ; FB5594  3c
	ld XIX,0x00000000                                    ; FB5595  44 00 00 00 00
	ld l, 0x06:opc                                          ; FB559A  27 06
.LFB559C:
	ld (xiz-8), xix                                      ; FB559C  be f8 64
	lda	xbc, (ParamFieldInit_x32_F4FE38:24)          ; FB559F  f2 38 fe f4 31
	add	xbc, (xiz-8)                                 ; FB55A4  ae f8 81
	ld A,(XBC)                                           ; FB55A7  81 21
	ld (xiz-4), a                                        ; FB55A9  be fc 41
	ld xbc, (xiz-8)                                      ; FB55AC  ae f8 21
	inc 1,XBC                                            ; FB55AF  e9 61
	add	xbc, ParamFieldInit_x32_F4FE38               ; FB55B1  e9 c8 38 fe f4 00
	ld A,(XBC)                                           ; FB55B7  81 21
	ld (xiz-3), a                                        ; FB55B9  be fd 41
	ld xbc, (xiz-8)                                      ; FB55BC  ae f8 21
	inc 2,XBC                                            ; FB55BF  e9 62
	add	xbc, ParamFieldInit_x32_F4FE38               ; FB55C1  e9 c8 38 fe f4 00
	ld A,(XBC)                                           ; FB55C7  81 21
	ld (xiz-2), a                                        ; FB55C9  be fe 41
	ld xbc, (xiz-8)                                      ; FB55CC  ae f8 21
	inc 3,XBC                                            ; FB55CF  e9 63
	add	xbc, ParamFieldInit_x32_F4FE38               ; FB55D1  e9 c8 38 fe f4 00
	ld A,(XBC)                                           ; FB55D7  81 21
	ld (xiz-1), a                                        ; FB55D9  be ff 41
	ld h, 0x20:opc                                          ; FB55DC  26 20
.LFB55DE:
	lda xbc, (xiz-4)                                     ; FB55DE  be fc 31
	push XBC                                             ; FB55E1  39
	call IndexedTable_MergeMaskedByte                                      ; FB55E2  1d 2b 78 fb
	dec 1,H                                              ; FB55E6  ce 69
	incm8 0x01, (xiz-4)                                  ; FB55E8  8e fc 61
	pop XIY                                              ; FB55EB  5d
	cp h, 0x00:i3                                          ; FB55EC  ce d8
	jr nz, .LFB55DE                                      ; FB55EE  6e ee
	inc 4,XIX                                            ; FB55F0  ec 64
	dec 1,L                                              ; FB55F2  cf 69
	cp l, 0x00:i3                                          ; FB55F4  cf d8
	jr nz, .LFB559C                                      ; FB55F6  6e a4
	ld XIX,0x00000000                                    ; FB55F8  44 00 00 00 00
	ld h, 0x06:opc                                          ; FB55FD  26 06
.LFB55FF:
	ld (xiz-8), xix                                      ; FB55FF  be f8 64
	ld xbc, (xiz-8)                                      ; FB5602  ae f8 21
	ld (xiz-12), xbc                                     ; FB5605  be f4 61
	add	xbc, ParamFieldInit_F4FE50                   ; FB5608  e9 c8 50 fe f4 00
	ld A,(XBC)                                           ; FB560E  81 21
	ld (xiz-4), a                                        ; FB5610  be fc 41
	ld xbc, (xiz-12)                                     ; FB5613  ae f4 21
	inc 1,XBC                                            ; FB5616  e9 61
	add	xbc, ParamFieldInit_F4FE50                   ; FB5618  e9 c8 50 fe f4 00
	ld A,(XBC)                                           ; FB561E  81 21
	ld (xiz-3), a                                        ; FB5620  be fd 41
	ld xbc, (xiz-12)                                     ; FB5623  ae f4 21
	inc 2,XBC                                            ; FB5626  e9 62
	add	xbc, ParamFieldInit_F4FE50                   ; FB5628  e9 c8 50 fe f4 00
	ld A,(XBC)                                           ; FB562E  81 21
	ld (xiz-2), a                                        ; FB5630  be fe 41
	ld xbc, (xiz-12)                                     ; FB5633  ae f4 21
	inc 3,XBC                                            ; FB5636  e9 63
	add	xbc, ParamFieldInit_F4FE50                   ; FB5638  e9 c8 50 fe f4 00
	ld A,(XBC)                                           ; FB563E  81 21
	ld (xiz-1), a                                        ; FB5640  be ff 41
	lda xbc, (xiz-4)                                     ; FB5643  be fc 31
	push XBC                                             ; FB5646  39
	call IndexedTable_MergeMaskedByte                                      ; FB5647  1d 2b 78 fb
	ld xix, (xiz-8)                                      ; FB564B  ae f8 24
	inc 4,XIX                                            ; FB564E  ec 64
	dec 1,H                                              ; FB5650  ce 69
	pop XIY                                              ; FB5652  5d
	cp h, 0x00:i3                                          ; FB5653  ce d8
	jr nz, .LFB55FF                                      ; FB5655  6e a8
	pushw 0x01                                           ; FB5657  0b 01 00
	pushw 0x61                                           ; FB565A  0b 61 00
	call T_DspEffect_ApplyAlgorithmDefaults                                        ; FB565D  1d 58 2f f4
	pushw 0x23                                           ; FB5661  0b 23 00
	pushw 0x62                                           ; FB5664  0b 62 00
	call T_DspEffect_ApplyAlgorithmDefaults                                        ; FB5667  1d 58 2f f4
	pushw 0x14                                           ; FB566B  0b 14 00
	pushw 0x63                                           ; FB566E  0b 63 00
	call T_DspEffect_ApplyAlgorithmDefaults                                        ; FB5671  1d 58 2f f4
	inc 8,XSP                                            ; FB5675  ef 60
	inc 4,XSP                                            ; FB5677  ef 64
	pop XIX                                              ; FB5679  5c
	popw hl                                              ; FB567A  4b
	unlk XIZ                                             ; FB567B  ee 0d
	ret                                                  ; FB567D  0e
; GmMode_SaveEffectOutputLoadFilter: On entering GM: (0x7FD7) := ((0x7EE4) & 0x0F) | 0x80 -- saves the DATA LOAD
;   FILTER 'EFFECT & OUTPUT' setting (record 0x7A byte 2, low nibble) with bit 7 as 'saved', before the GM reset
;   zeroes it (ParamFieldInit_F4FE50 row 1). GmMode_RestoreEffectOutputLoadFilter puts it back on leaving GM. Basis:
;   caller + body + descriptor. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
GmMode_SaveEffectOutputLoadFilter:
	ld c, (0x7ee4:16)                                   ; FB567E  c1 e4 7e 23
	and C,0x0f                                           ; FB5682  cb cc 0f
	set 0x07,C                                           ; FB5685  cb 31 07
	ld (0x7fd7:16), c                                   ; FB5688  f1 d7 7f 43
	ret                                                  ; FB568C  0e
; GmMode_RestoreEffectOutputLoadFilter: On leaving GM: if (0x7FD7) bit 7 (saved), clears it and, when the saved value
;   is 0..2 (OFF / COMBI / SOUND&COMBI), merges it back into record 0x7A byte 2 under mask 0x0F
;   (IndexedTable_MergeMaskedByte) -- the DATA LOAD FILTER 'EFFECT & OUTPUT' setting GmMode_SaveEffectOutputLoadFilter
;   saved. Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
GmMode_RestoreEffectOutputLoadFilter:
	link XIZ,0xfffc                                      ; FB568D  ee 0c fc ff
	push XIX                                             ; FB5691  3c
	lda xix, (xiz-4)                                     ; FB5692  be fc 34
	ld c, (0x7fd7:16)                                   ; FB5695  c1 d7 7f 23
	and C,0x80                                           ; FB5699  cb cc 80
	jr z, .LFB56CF                                       ; FB569C  66 31
	and	(0x7fd7:16), 0x0f                            ; FB569E  c1 d7 7f 3c 0f
	ld c, (0x7fd7:16)                                   ; FB56A3  c1 d7 7f 23
	ld (XIX+0x02),C                                      ; FB56A7  bc 02 43
	ld bc, (0x7fd7:16)                                 ; FB56AA  d1 d7 7f 21
	extz BC                                              ; FB56AE  d9 12
	cp bc, 0x00:i3                                         ; FB56B0  d9 d8
	jr z, .LFB56BE                                       ; FB56B2  66 0a
	cp bc, 0x01:i3                                         ; FB56B4  d9 d9
	jr z, .LFB56BE                                       ; FB56B6  66 06
	cp bc, 0x02:i3                                         ; FB56B8  d9 da
	jr z, .LFB56BE                                       ; FB56BA  66 02
	jr .LFB56CF                                          ; FB56BC  68 11
.LFB56BE:
	ld (XIX),0x7a                                        ; FB56BE  b4 00 7a
	ld (XIX+0x01),0x02                                   ; FB56C1  bc 01 00 02
	ld (XIX+0x03),0x0f                                   ; FB56C5  bc 03 00 0f
	push XIX                                             ; FB56C9  3c
	call IndexedTable_MergeMaskedByte                                      ; FB56CA  1d 2b 78 fb
	pop XIY                                              ; FB56CE  5d
.LFB56CF:
	pop XIX                                              ; FB56CF  5c
	unlk XIZ                                             ; FB56D0  ee 0d
	ret                                                  ; FB56D2  0e
; ParamApply_ResetPairTablesForGm: Fills ParamApply_StorePairAndDerive's per-part tables with the GM defaults: the 32
;   word pairs at 0x60F530 := {0x00, 0x1A} and the 32 bytes at 0x60F570 := 0x1A, except the drum parts 9 and 0x19 :=
;   {0x00, 0x20} / 0x20 (bank 0x20, PartSound_FromProgramChange's drum bank). Called by GmMode_ResetToDefaults and
;   ParamApply_ResetPairTablesIfGmNormal. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_i.json)
ParamApply_ResetPairTablesForGm:
	link XIZ,0xfff6                                      ; FB56D3  ee 0c f6 ff
	pushw hl                                             ; FB56D7  2b
	pushw de                                             ; FB56D8  2a
	push XIX                                             ; FB56D9  3c
	lda xix, (0x60f530:24)                               ; FB56DA  f2 30 f5 60 34
	ldw de, 0x00                                         ; FB56DF  32 00 00
	lda xbc, (0x60f56f:24)                               ; FB56E2  f2 6f f5 60 31
	inc 1,XBC                                            ; FB56E7  e9 61
	ld (xiz-4), xbc                                      ; FB56E9  be fc 61
	lda xwa, (0x60f530:24)                               ; FB56EC  f2 30 f5 60 30
	ld (xiz-8), xwa                                      ; FB56F1  be f8 60
	sub XBC,XWA                                          ; FB56F4  e8 a1
	ld HL,BC                                             ; FB56F6  d9 8b
	srl bc, 0x01                                         ; FB56F8  d9 ef 01
	ld HL,BC                                             ; FB56FB  d9 8b
.LFB56FD:
	cp DE,HL                                             ; FB56FD  db f2
	jr nc, .LFB5717                                      ; FB56FF  6f 16
	ld (XIX),0x00                                        ; FB5701  b4 00 00
	ld XBC,XIX                                           ; FB5704  ec 89
	inc 1,XBC                                            ; FB5706  e9 61
	ld (xiz-4), xbc                                      ; FB5708  be fc 61
	ld (XBC),0x1a                                        ; FB570B  b1 00 1a
	ld xix, (xiz-4)                                      ; FB570E  ae fc 24
	inc 1,XIX                                            ; FB5711  ec 61
	inc 1,DE                                             ; FB5713  da 61
	jr .LFB56FD                                          ; FB5715  68 e6
.LFB5717:
	ld (0x60f542:24), 0x00                             ; FB5717  f2 42 f5 60 00 00
	ld (xiz-2), 0x20                                     ; FB571D  be fe 00 20
	ld c, (xiz-2)                                        ; FB5721  8e fe 23
	ld (0x60f543:24), c                                 ; FB5724  f2 43 f5 60 43
	ld (0x60f562:24), 0x00                             ; FB5729  f2 62 f5 60 00 00
	ld a, (xiz-2)                                        ; FB572F  8e fe 21
	ld (0x60f563:24), a                                 ; FB5732  f2 63 f5 60 41
	lda xix, (0x60f570:24)                               ; FB5737  f2 70 f5 60 34
	ldw de, 0x00                                         ; FB573C  32 00 00
	lda xbc, (0x60f58f:24)                               ; FB573F  f2 8f f5 60 31
	inc 1,XBC                                            ; FB5744  e9 61
	ld (xiz-6), xbc                                      ; FB5746  be fa 61
	lda xwa, (0x60f570:24)                               ; FB5749  f2 70 f5 60 30
	ld (xiz-10), xwa                                     ; FB574E  be f6 60
	sub XBC,XWA                                          ; FB5751  e8 a1
	ld HL,BC                                             ; FB5753  d9 8b
.LFB5755:
	cp DE,HL                                             ; FB5755  db f2
	jr nc, .LFB5762                                      ; FB5757  6f 09
	ld (XIX),0x1a                                        ; FB5759  b4 00 1a
	inc 1,XIX                                            ; FB575C  ec 61
	inc 1,DE                                             ; FB575E  da 61
	jr .LFB5755                                          ; FB5760  68 f3
.LFB5762:
	ld h, 0x20:opc                                          ; FB5762  26 20
	ld (0x60f579:24), h                                 ; FB5764  f2 79 f5 60 46
	ld (0x60f589:24), h                                 ; FB5769  f2 89 f5 60 46
	pop XIX                                              ; FB576E  5c
	popw de                                              ; FB576F  4a
	popw hl                                              ; FB5770  4b
	unlk XIZ                                             ; FB5771  ee 0d
	ret                                                  ; FB5773  0e
; ParamApply_ResetPairTablesForGmOff: Zeroes ParamApply's pair table 0x60F530 (32 x 2 bytes) and byte table 0x60F570
;   (32 bytes) -- the GM-off twin of ParamApply_ResetPairTablesForGm's {0, 0x1A} / 0x1A fill -- and sets
;   MidiFilter_BankSelect bit 7. First step of GmMode_ResetForGmOff. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
ParamApply_ResetPairTablesForGmOff:
	link XIZ,0xfff8                                      ; FB5774  ee 0c f8 ff
	pushw hl                                             ; FB5778  2b
	pushw de                                             ; FB5779  2a
	push XIX                                             ; FB577A  3c
	lda xix, (0x60f530:24)                               ; FB577B  f2 30 f5 60 34
	ldw de, 0x00                                         ; FB5780  32 00 00
	lda xbc, (0x60f56f:24)                               ; FB5783  f2 6f f5 60 31
	inc 1,XBC                                            ; FB5788  e9 61
	ld (xiz-4), xbc                                      ; FB578A  be fc 61
	lda xwa, (0x60f530:24)                               ; FB578D  f2 30 f5 60 30
	ld (xiz-8), xwa                                      ; FB5792  be f8 60
	sub XBC,XWA                                          ; FB5795  e8 a1
	ld HL,BC                                             ; FB5797  d9 8b
	srl bc, 0x01                                         ; FB5799  d9 ef 01
	ld HL,BC                                             ; FB579C  d9 8b
.LFB579E:
	cp DE,HL                                             ; FB579E  db f2
	jr nc, .LFB57B8                                      ; FB57A0  6f 16
	ld (XIX),0x00                                        ; FB57A2  b4 00 00
	ld XBC,XIX                                           ; FB57A5  ec 89
	inc 1,XBC                                            ; FB57A7  e9 61
	ld (xiz-4), xbc                                      ; FB57A9  be fc 61
	ld (XBC),0x00                                        ; FB57AC  b1 00 00
	ld xix, (xiz-4)                                      ; FB57AF  ae fc 24
	inc 1,XIX                                            ; FB57B2  ec 61
	inc 1,DE                                             ; FB57B4  da 61
	jr .LFB579E                                          ; FB57B6  68 e6
.LFB57B8:
	lda xix, (0x60f570:24)                               ; FB57B8  f2 70 f5 60 34
	ldw de, 0x00                                         ; FB57BD  32 00 00
	lda xbc, (0x60f58f:24)                               ; FB57C0  f2 8f f5 60 31
	inc 1,XBC                                            ; FB57C5  e9 61
	ld (xiz-4), xbc                                      ; FB57C7  be fc 61
	lda xwa, (0x60f570:24)                               ; FB57CA  f2 70 f5 60 30
	ld (xiz-8), xwa                                      ; FB57CF  be f8 60
	sub XBC,XWA                                          ; FB57D2  e8 a1
	ld HL,BC                                             ; FB57D4  d9 8b
.LFB57D6:
	cp DE,HL                                             ; FB57D6  db f2
	jr nc, .LFB57E3                                      ; FB57D8  6f 09
	ld (XIX),0x00                                        ; FB57DA  b4 00 00
	inc 1,XIX                                            ; FB57DD  ec 61
	inc 1,DE                                             ; FB57DF  da 61
	jr .LFB57D6                                          ; FB57E1  68 f3
.LFB57E3:
	set	7, (MidiFilter_BankSelect:16)                               ; FB57E3  f1 3a 7f bf
	pop XIX                                              ; FB57E7  5c
	popw de                                              ; FB57E8  4a
	popw hl                                              ; FB57E9  4b
	unlk XIZ                                             ; FB57EA  ee 0d
	ret                                                  ; FB57EC  0e
; SysExRx_ApplyTempo: (BPM word): unless MidiCfg_ModeBits bit 4, Tempo (0x7EE2) := its low 9 bits (byte 0 and bit 0 of
;   byte 1), stages the change {0x7A, 0, low byte, 0xFF} and publishes it (Queue2C00_PublishStagedDrainPassB), then
;   Tempo_ApplyBpm with (0x60F020) bit 4 set so the received tempo is not sent back (SysExTx_Tempo). Called by
;   SysExCmd_TempoReceive after its 40..300 check. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
SysExRx_ApplyTempo:
	link XIZ,0x0000                                      ; FB57ED  ee 0c 00 00
	pushw hl                                             ; FB57F1  2b
	pushw de                                             ; FB57F2  2a
	push XIX                                             ; FB57F3  3c
	lda xix, (0x7ee2:16)                                ; FB57F4  f1 e2 7e 34
	ld c, (MidiCfg_ModeBits:16)                                   ; FB57F8  c1 32 7f 23
	and C,0x10                                           ; FB57FC  cb cc 10
	jr nz, .LFB5858                                      ; FB57FF  6e 57
	ld HL,(XIZ+0x08)                                     ; FB5801  9e 08 23
	and HL,0x01ff                                        ; FB5804  db cc ff 01
	ld D,L                                               ; FB5808  cf 8c
	ld (XIX),D                                           ; FB580A  b4 44
	extz XIX                                             ; FB580C  ec 12
	and (XIX+0x01),0xfe                                  ; FB580E  8c 01 3c fe
	ld E,(XIX+0x01)                                      ; FB5812  8c 01 25
	ld BC,HL                                             ; FB5815  db 89
	srl bc, 0x08                                         ; FB5817  d9 ef 08
	or C,E                                               ; FB581A  cd e3
	ld (XIX+0x01),C                                      ; FB581C  bc 01 43
	ld (0x60f080:24), 0x7a                             ; FB581F  f2 80 f0 60 00 7a
	ld (0x60f081:24), 0x00                             ; FB5825  f2 81 f0 60 00 00
	ld (0x60f082:24), d                                 ; FB582B  f2 82 f0 60 44
	ld (0x60f083:24), 0xff                             ; FB5830  f2 83 f0 60 00 ff
	push XDE                                             ; FB5836  3a
	push XHL                                             ; FB5837  3b
	push XIX                                             ; FB5838  3c
	push XIZ                                             ; FB5839  3e
	call T_Queue2C00_PublishStagedDrainPassB             ; FB583A  1d b8 07 f4
	pop XIZ                                              ; FB583E  5e
	pop XIX                                              ; FB583F  5c
	pop XHL                                              ; FB5840  5b
	pop XDE                                              ; FB5841  5a
	set	4, (0x60f020:24)                             ; FB5842  f2 20 f0 60 bc
	push XDE                                             ; FB5847  3a
	push XHL                                             ; FB5848  3b
	push XIX                                             ; FB5849  3c
	push XIZ                                             ; FB584A  3e
	call T_Tempo_ApplyBpm                                        ; FB584B  1d 94 07 f4
	pop XIZ                                              ; FB584F  5e
	pop XIX                                              ; FB5850  5c
	pop XHL                                              ; FB5851  5b
	pop XDE                                              ; FB5852  5a
	res	4, (0x60f020:24)                             ; FB5853  f2 20 f0 60 b4
.LFB5858:
	pop XIX                                              ; FB5858  5c
	popw de                                              ; FB5859  4a
	popw hl                                              ; FB585A  4b
	unlk XIZ                                             ; FB585B  ee 0d
	ret                                                  ; FB585D  0e
; BStore_Workspace_StoreGmModeDefaults: (gm): with GmMode_HandleChange's guard (0x60F01F) bit 0 set, snapshots the
;   parameter image (ParamImage_SnapshotAll), applies GmMode_ResetToDefaults (gm != 0) or GmMode_ResetForGmOff (gm ==
;   0), stores the image into the song workspace (BStore_Workspace_StoreParamImage), then copies the 0x960-byte
;   snapshot back over 0x7620.. so the live image is unchanged. Reached through T_BStore_Workspace_StoreGmModeDefaults from SmfPart_ResetAllRecords
;   (1 in GM mode, else 0). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
BStore_Workspace_StoreGmModeDefaults:
	link XIZ,0xfff4                                      ; FB585E  ee 0c f4 ff
	push XIX                                             ; FB5862  3c
	set	0, (0x60f01f:24)                             ; FB5863  f2 1f f0 60 b8
	push XDE                                             ; FB5868  3a
	push XHL                                             ; FB5869  3b
	push XIX                                             ; FB586A  3c
	push XIZ                                             ; FB586B  3e
	call T_ParamImage_SnapshotAll                                        ; FB586C  1d d8 01 f4
	pop XIZ                                              ; FB5870  5e
	pop XIX                                              ; FB5871  5c
	pop XHL                                              ; FB5872  5b
	pop XDE                                              ; FB5873  5a
	cp (XIZ+0x08),0x00                                   ; FB5874  8e 08 3f 00
	jr z, .LFB587F                                       ; FB5878  66 05
	calr GmMode_ResetToDefaults                                      ; FB587A  1e 4f 00
	jr .LFB5882                                          ; FB587D  68 03
.LFB587F:
	calr GmMode_ResetForGmOff                                      ; FB587F  1e 81 00
.LFB5882:
	call T_BStore_Workspace_StoreParamImage                                        ; FB5882  1d 74 25 f4
	lda xbc, (0x608000:24)                               ; FB5886  f2 00 80 60 31
	ld (xiz-8), xbc                                      ; FB588B  be f8 61
	ldw ix, Combination_Current                                       ; FB588E  34 20 76
	exts XIX                                             ; FB5891  ec 13
	ld (xiz-12), xix                                     ; FB5893  be f4 64
	lda xwa, (0x7f7e:16)                                ; FB5896  f1 7e 7f 30
	sub	xwa, (xiz-12)                                ; FB589A  ae f4 a0
	inc 2,XWA                                            ; FB589D  e8 62
	srl xwa, 0x01                                        ; FB589F  e8 ef 01
	ld (xiz-4), xwa                                      ; FB58A2  be fc 60
.LFB58A5:
	ld xbc, (xiz-4)                                      ; FB58A5  ae fc 21
	or XBC,XBC                                           ; FB58A8  e9 e1
	jr z, .LFB58C3                                       ; FB58AA  66 17
	dec 1,XBC                                            ; FB58AC  e9 69
	ld (xiz-4), xbc                                      ; FB58AE  be fc 61
	ld xwa, (xiz-8)                                      ; FB58B1  ae f8 20
	ld IY,(XWA)                                          ; FB58B4  90 25
	ld (XIX),IY                                          ; FB58B6  b4 55
	sub XBC,XBC                                          ; FB58B8  e9 a1
	inc 2,XBC                                            ; FB58BA  e9 62
	add (xiz-8), xbc                                     ; FB58BC  ae f8 89
	add XIX,XBC                                          ; FB58BF  e9 84
	jr .LFB58A5                                          ; FB58C1  68 e2
.LFB58C3:
	res	0, (0x60f01f:24)                             ; FB58C3  f2 1f f0 60 b0
	pop XIX                                              ; FB58C8  5c
	unlk XIZ                                             ; FB58C9  ee 0d
	ret                                                  ; FB58CB  0e
; GmMode_ResetToDefaults: the GM reset sequence: GmReset_SwitchToSoundMode (SOUND mode when (0x7F02) & 0xF0 is 0x10), GmReset_PartProgramAndBank, ParamApply_ResetPairTablesForGm, the
;   GmReset_Part* steps (volume 100, effect depths 0 / 0 / 90, pan and tuning centred, bend range 2) and further
;   resets.  Called by GmMode_ApplyChange (GmMode_HandleChange's) and BStore_Workspace_StoreGmModeDefaults.
GmMode_ResetToDefaults:
	calr GmReset_SwitchToSoundMode                                      ; FB58CC  1e 9e fc
	calr GmReset_PartProgramAndBank                                      ; FB58CF  1e 45 01
	calr ParamApply_ResetPairTablesForGm                                      ; FB58D2  1e fe fd
	calr GmReset_PartVolume                                      ; FB58D5  1e 92 02
	calr GmReset_PartVolume_Nop                                      ; FB58D8  1e bb 02
	calr GmReset_PartEffect3Depth                                      ; FB58DB  1e b9 02
	calr GmReset_PartByte4Bit6                                      ; FB58DE  1e e2 02
	calr GmReset_PartEffect4Depth                                      ; FB58E1  1e 0b 03
	calr GmReset_PartEffect1Depth                                      ; FB58E4  1e 34 03
	calr GmReset_PartPan                                      ; FB58E7  1e 5d 03
	calr GmReset_PartCoarseTune                                      ; FB58EA  1e 86 03
	calr GmReset_PartFineTune                                      ; FB58ED  1e af 03
	calr GmReset_PartBendRange                                      ; FB58F0  1e d8 03
	calr GmReset_ApplyPatchLists                                      ; FB58F3  1e 01 04
	calr GmReset_ApplyPatchLists_Nop2                                      ; FB58F6  1e 08 04
	calr Tempo_RestoreFromSmfPlay                                      ; FB58F9  1e 06 04
	calr GmReset_PartByte12Bit4                                      ; FB58FC  1e 39 04
	calr GmReset_FieldTablesAndEffectAlgorithms                                      ; FB58FF  1e 8d fc
	ret                                                  ; FB5902  0e
; GmMode_ResetForGmOff: The non-GM counterpart of GmMode_ResetToDefaults: ParamApply_ResetPairTablesForGmOff (zeroes ParamApply's pair tables
;   0x60F530 / 0x60F570, the twin of ParamApply_ResetPairTablesForGm's {0, 0x1A}, and sets MidiFilter_BankSelect bit
;   7), then Tempo_RestoreFromSmfPlay (via Tempo_RestoreFromSmfPlay_Call). Run by GmMode_ApplyChange when GM goes off and by
;   BStore_Workspace_StoreGmModeDefaults with gm = 0. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
GmMode_ResetForGmOff:
	calr ParamApply_ResetPairTablesForGmOff                                      ; FB5903  1e 6e fe
	calr Tempo_RestoreFromSmfPlay_Call                                      ; FB5906  1e 2b 04
	ret                                                  ; FB5909  0e
; GmMode_HandleChange: the only handler of internal event class 0x91 (UiListA_Class91): for byte index 3 -- the GM setting at 0x7F4D, record
;   0x91 payload byte 3 -- applies it (0xFB5F0F) and SysExTx_AnnounceGmMode, guarded against re-entry by (0x60F01F) bit 0.
GmMode_HandleChange:
	push XIX                                             ; FB590A  3c
	lda xix, (UiEvent_Byte2:16)                                ; FB590B  f1 b9 20 34
	cp	(UiEvent_Byte1:16), 0x03                            ; FB590F  c1 b8 20 3f 03
	jr nz, .LFB5970                                      ; FB5914  6e 5a
	ld c, (UiEvent_Byte3:16)                                   ; FB5916  c1 ba 20 23
	and C,0x04                                           ; FB591A  cb cc 04
	jr z, .LFB5960                                       ; FB591D  66 41
	ld c, (0x60f01f:24)                                 ; FB591F  c2 1f f0 60 23
	and C,0x01                                           ; FB5924  cb cc 01
	jr nz, .LFB5970                                      ; FB5927  6e 47
	set	0, (0x60f01f:24)                             ; FB5929  f2 1f f0 60 b8
	ld bc, (0x605068:24)                                ; FB592E  d2 68 50 60 21
	and BC,0x8000                                        ; FB5933  d9 cc 00 80
	jr nz, .LFB5945                                      ; FB5937  6e 0c
	push XDE                                             ; FB5939  3a
	push XHL                                             ; FB593A  3b
	push XIX                                             ; FB593B  3c
	push XIZ                                             ; FB593C  3e
	call T_Transport_StopAllRunning                                        ; FB593D  1d ac 09 f4
	pop XIZ                                              ; FB5941  5e
	pop XIX                                              ; FB5942  5c
	pop XHL                                              ; FB5943  5b
	pop XDE                                              ; FB5944  5a
.LFB5945:
	ld C,(XIX)                                           ; FB5945  84 23
	extz BC                                              ; FB5947  d9 12
	pushw bc                                             ; FB5949  29
	calr GmMode_PostToMsg0716                                      ; FB594A  1e c2 05
	ld C,(XIX)                                           ; FB594D  84 23
	extz BC                                              ; FB594F  d9 12
	pushw bc                                             ; FB5951  29
	calr SysExTx_AnnounceGmMode                                      ; FB5952  1e d9 05
	calr GmMode_ApplyChange                                      ; FB5955  1e 1a 00
	res	0, (0x60f01f:24)                             ; FB5958  f2 1f f0 60 b0
	pop XIY                                              ; FB595D  5d
	jr .LFB5970                                          ; FB595E  68 10
.LFB5960:
	ld C,(XIX)                                           ; FB5960  84 23
	cp c, 0x04:i3                                          ; FB5962  cb dc
	jr nz, .LFB5970                                      ; FB5964  6e 0a
	cp	(UiEvent_Byte3:16), 0x00                            ; FB5966  c1 ba 20 3f 00
	jr nz, .LFB5970                                      ; FB596B  6e 03
	calr GmReset_AllPartsExpression                                      ; FB596D  1e 8a 04
.LFB5970:
	pop XIX                                              ; FB5970  5c
	ret                                                  ; FB5971  0e
; GmMode_ApplyChange: GmMode_HandleChange's body: the parameter image snapshot; entering GM (UiEvent_Byte2 bit 2): GmMode_SaveEffectOutputLoadFilter,
;   GmMode_ResetToDefaults and, unless (0x124C) bit 0, T_BStore_Workspace_StoreParamImage; leaving: GmMode_ResetForGmOff, GmMode_RestoreEffectOutputLoadFilter; then the image
;   re-sanitised and published, the tempo re-applied, and every part's pitch bend, channel pressure,
;   modulation, expression and hold reset (GmReset_AllParts*), with GmReset_AllPartsParamB7 / _ParamB6.
GmMode_ApplyChange:
	push XDE                                             ; FB5972  3a
	push XHL                                             ; FB5973  3b
	push XIX                                             ; FB5974  3c
	push XIZ                                             ; FB5975  3e
	call T_ParamImage_WriteRecordHeaders_Entry                                        ; FB5976  1d 24 02 f4
	call T_ParamImage_SnapshotAll                                        ; FB597A  1d d8 01 f4
	pop XIZ                                              ; FB597E  5e
	pop XIX                                              ; FB597F  5c
	pop XHL                                              ; FB5980  5b
	pop XDE                                              ; FB5981  5a
	ld c, (UiEvent_Byte2:16)                                   ; FB5982  c1 b9 20 23
	and C,0x04                                           ; FB5986  cb cc 04
	jr z, .LFB59A0                                       ; FB5989  66 15
	calr GmMode_SaveEffectOutputLoadFilter                                      ; FB598B  1e f0 fc
	calr GmMode_ResetToDefaults                                      ; FB598E  1e 3b ff
	ld c, (0x124c:16)                                   ; FB5991  c1 4c 12 23
	and C,0x01                                           ; FB5995  cb cc 01
	jr nz, .LFB59A6                                      ; FB5998  6e 0c
	call T_BStore_Workspace_StoreParamImage                                        ; FB599A  1d 74 25 f4
	jr .LFB59A6                                          ; FB599E  68 06
.LFB59A0:
	calr GmMode_ResetForGmOff                                      ; FB59A0  1e 60 ff
	calr GmMode_RestoreEffectOutputLoadFilter                                      ; FB59A3  1e e7 fc
.LFB59A6:
	calr ParamImage_SnapshotMarkPart0ProgramChanged                                      ; FB59A6  1e 58 00
	push XDE                                             ; FB59A9  3a
	push XHL                                             ; FB59AA  3b
	push XIX                                             ; FB59AB  3c
	push XIZ                                             ; FB59AC  3e
	call T_ParamImage_WriteRecordHeaders_Entry                                        ; FB59AD  1d 24 02 f4
	call T_ParamImage_SanitizeAll_Entry                                        ; FB59B1  1d 14 02 f4
	call T_F401EC                                        ; FB59B5  1d ec 01 f4
	call T_F407A4                                        ; FB59B9  1d a4 07 f4
	or	(Disk_Flags:16), 0x18                            ; FB59BD  c1 e7 21 3e 18
	call T_ParamImage_PostAllAsChangeEvents_Call                                        ; FB59C2  1d 74 07 f4
	call T_Queue2C00_DrainPassB                          ; FB59C6  1d 38 00 f4
	call T_UiEventList_Publish                           ; FB59CA  1d 50 0f f4
	and	(Disk_Flags:16), 0xe7                            ; FB59CE  c1 e7 21 3c e7
	set	4, (0x60f020:24)                             ; FB59D3  f2 20 f0 60 bc
	call T_Tempo_ApplyBpm                                        ; FB59D8  1d 94 07 f4
	res	4, (0x60f020:24)                             ; FB59DC  f2 20 f0 60 b4
	pop XIZ                                              ; FB59E1  5e
	pop XIX                                              ; FB59E2  5c
	pop XHL                                              ; FB59E3  5b
	pop XDE                                              ; FB59E4  5a
	calr GmReset_AllPartsPitchBend                                      ; FB59E5  1e 7c 03
	calr GmReset_AllPartsChannelPressure                                      ; FB59E8  1e ab 03
	calr GmReset_AllPartsModulation                                      ; FB59EB  1e da 03
	calr GmReset_AllPartsExpression                                      ; FB59EE  1e 09 04
	calr GmReset_AllPartsHold                                      ; FB59F1  1e 38 04
	calr GmReset_AllPartsParamB7                                      ; FB59F4  1e 67 04
	calr GmReset_AllPartsParamB6                                      ; FB59F7  1e 96 04
	calr GmReset_AllPartsParamB6_Nop                                      ; FB59FA  1e c5 04
	calr GmReset_AllPartsRpnNull                                      ; FB59FD  1e c3 04
	ret                                                  ; FB5A00  0e
; ParamImage_SnapshotMarkPart0ProgramChanged: Writes 0xFF over the snapshot copy (0x608000 + 0x82) of record 0's
;   PROGRAM CHANGE byte (0x76A2), a value no program has, so an image-vs-snapshot compare sees it as changed -- the
;   trick Combination_Recall plays with `cpl` on the same byte. Called by GmMode_ApplyChange after either GM branch,
;   before the image is re-sanitised and posted. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
ParamImage_SnapshotMarkPart0ProgramChanged:
	pushw hl                                             ; FB5A01  2b
	ldw hl, Combination_Current                                       ; FB5A02  33 20 76
	ldw bc, 0x76a2                                       ; FB5A05  31 a2 76
	sub BC,HL                                            ; FB5A08  db a1
	exts XBC                                             ; FB5A0A  e9 13
	add XBC,0x00608000                                   ; FB5A0C  e9 c8 00 80 60 00
	ld (XBC),0xff                                        ; FB5A12  b1 00 ff
	popw hl                                              ; FB5A15  4b
	ret                                                  ; FB5A16  0e
; GmReset_PartProgramAndBank: Step 2 of GmMode_ResetToDefaults: for records 0..31, PROGRAM CHANGE & BANK bytes +0 := 0
;   and +1 := 0, except the drum records 9 and 0x19 (+1 := 0x20); then records 0x20..0x3E bytes 0x1B/0x1C/0x1D :=
;   0/0/0x1A, records 0x29/0x39 := 0/3/0x20 -- the same 0x1A / 0x20 split ParamApply_ResetPairTablesForGm writes.
;   Basis: caller + body + descriptor + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
GmReset_PartProgramAndBank:
	link XIZ,0xfffc                                      ; FB5A17  ee 0c fc ff
	pushw hl                                             ; FB5A1B  2b
	push XIX                                             ; FB5A1C  3c
	lda xix, (xiz-4)                                     ; FB5A1D  be fc 34
	ld (XIX),0x00                                        ; FB5A20  b4 00 00
.LFB5A23:
	ld C,(XIX)                                           ; FB5A23  84 23
	cp C,0x1f                                            ; FB5A25  cb cf 1f
	jr ugt, .LFB5A52                                     ; FB5A28  6b 28
	ld (XIX+0x01),0x00                                   ; FB5A2A  bc 01 00 00
	ld (XIX+0x02),0x00                                   ; FB5A2E  bc 02 00 00
	ld (XIX+0x03),0xff                                   ; FB5A32  bc 03 00 ff
	push XIX                                             ; FB5A36  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5A37  1d 2b 78 fb
	ld (XIX+0x01),0x01                                   ; FB5A3B  bc 01 00 01
	ld (XIX+0x02),0x00                                   ; FB5A3F  bc 02 00 00
	ld (XIX+0x03),0x7f                                   ; FB5A43  bc 03 00 7f
	push XIX                                             ; FB5A47  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5A48  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5A4C  84 61
	inc 8,XSP                                            ; FB5A4E  ef 60
	jr .LFB5A23                                          ; FB5A50  68 d1
.LFB5A52:
	ld (XIX),0x09                                        ; FB5A52  b4 00 09
	ld (XIX+0x01),0x00                                   ; FB5A55  bc 01 00 00
	ld (XIX+0x02),0x00                                   ; FB5A59  bc 02 00 00
	ld (XIX+0x03),0xff                                   ; FB5A5D  bc 03 00 ff
	push XIX                                             ; FB5A61  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5A62  1d 2b 78 fb
	ld (XIX),0x09                                        ; FB5A66  b4 00 09
	ld (XIX+0x01),0x01                                   ; FB5A69  bc 01 00 01
	ld (XIX+0x02),0x20                                   ; FB5A6D  bc 02 00 20
	ld (XIX+0x03),0x7f                                   ; FB5A71  bc 03 00 7f
	push XIX                                             ; FB5A75  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5A76  1d 2b 78 fb
	ld (XIX),0x19                                        ; FB5A7A  b4 00 19
	ld (XIX+0x01),0x00                                   ; FB5A7D  bc 01 00 00
	ld (XIX+0x02),0x00                                   ; FB5A81  bc 02 00 00
	ld (XIX+0x03),0xff                                   ; FB5A85  bc 03 00 ff
	push XIX                                             ; FB5A89  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5A8A  1d 2b 78 fb
	ld (XIX),0x19                                        ; FB5A8E  b4 00 19
	ld (XIX+0x01),0x01                                   ; FB5A91  bc 01 00 01
	ld (XIX+0x02),0x20                                   ; FB5A95  bc 02 00 20
	ld (XIX+0x03),0x7f                                   ; FB5A99  bc 03 00 7f
	push XIX                                             ; FB5A9D  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5A9E  1d 2b 78 fb
	ld (XIX),0x20                                        ; FB5AA2  b4 00 20
	inc 8,XSP                                            ; FB5AA5  ef 60
	inc 8,XSP                                            ; FB5AA7  ef 60
.LFB5AA9:
	ld C,(XIX)                                           ; FB5AA9  84 23
	cp C,0x3e                                            ; FB5AAB  cb cf 3e
	jr ugt, .LFB5AEB                                     ; FB5AAE  6b 3b
	ld (XIX+0x01),0x1b                                   ; FB5AB0  bc 01 00 1b
	ld (XIX+0x02),0x00                                   ; FB5AB4  bc 02 00 00
	ld (XIX+0x03),0xff                                   ; FB5AB8  bc 03 00 ff
	push XIX                                             ; FB5ABC  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5ABD  1d 2b 78 fb
	ld (XIX+0x01),0x1c                                   ; FB5AC1  bc 01 00 1c
	ld (XIX+0x02),0x00                                   ; FB5AC5  bc 02 00 00
	ld (XIX+0x03),0xff                                   ; FB5AC9  bc 03 00 ff
	push XIX                                             ; FB5ACD  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5ACE  1d 2b 78 fb
	ld (XIX+0x01),0x1d                                   ; FB5AD2  bc 01 00 1d
	ld (XIX+0x02),0x1a                                   ; FB5AD6  bc 02 00 1a
	ld (XIX+0x03),0xff                                   ; FB5ADA  bc 03 00 ff
	push XIX                                             ; FB5ADE  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5ADF  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5AE3  84 61
	inc 8,XSP                                            ; FB5AE5  ef 60
	inc 4,XSP                                            ; FB5AE7  ef 64
	jr .LFB5AA9                                          ; FB5AE9  68 be
.LFB5AEB:
	ld (XIX),0x29                                        ; FB5AEB  b4 00 29
	ld (XIX+0x01),0x1b                                   ; FB5AEE  bc 01 00 1b
	ld (XIX+0x02),0x00                                   ; FB5AF2  bc 02 00 00
	ld h, 0xff:opc                                          ; FB5AF6  26 ff
	ld (XIX+0x03),H                                      ; FB5AF8  bc 03 46
	push XIX                                             ; FB5AFB  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5AFC  1d 2b 78 fb
	ld (XIX),0x29                                        ; FB5B00  b4 00 29
	ld (XIX+0x01),0x1c                                   ; FB5B03  bc 01 00 1c
	ld (XIX+0x02),0x03                                   ; FB5B07  bc 02 00 03
	ld (XIX+0x03),H                                      ; FB5B0B  bc 03 46
	push XIX                                             ; FB5B0E  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5B0F  1d 2b 78 fb
	ld (XIX),0x29                                        ; FB5B13  b4 00 29
	ld (XIX+0x01),0x1d                                   ; FB5B16  bc 01 00 1d
	ld (XIX+0x02),0x20                                   ; FB5B1A  bc 02 00 20
	ld (XIX+0x03),H                                      ; FB5B1E  bc 03 46
	push XIX                                             ; FB5B21  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5B22  1d 2b 78 fb
	ld (XIX),0x39                                        ; FB5B26  b4 00 39
	ld (XIX+0x01),0x1b                                   ; FB5B29  bc 01 00 1b
	ld (XIX+0x02),0x00                                   ; FB5B2D  bc 02 00 00
	ld (XIX+0x03),H                                      ; FB5B31  bc 03 46
	push XIX                                             ; FB5B34  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5B35  1d 2b 78 fb
	ld (XIX),0x39                                        ; FB5B39  b4 00 39
	ld (XIX+0x01),0x1c                                   ; FB5B3C  bc 01 00 1c
	ld (XIX+0x02),0x03                                   ; FB5B40  bc 02 00 03
	ld (XIX+0x03),H                                      ; FB5B44  bc 03 46
	push XIX                                             ; FB5B47  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5B48  1d 2b 78 fb
	ld (XIX),0x39                                        ; FB5B4C  b4 00 39
	ld (XIX+0x01),0x1d                                   ; FB5B4F  bc 01 00 1d
	ld (XIX+0x02),0x20                                   ; FB5B53  bc 02 00 20
	ld (XIX+0x03),H                                      ; FB5B57  bc 03 46
	push XIX                                             ; FB5B5A  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5B5B  1d 2b 78 fb
	add XSP,0x00000018                                   ; FB5B5F  ef c8 18 00 00 00
	pop XIX                                              ; FB5B65  5c
	popw hl                                              ; FB5B66  4b
	unlk XIZ                                             ; FB5B67  ee 0d
	ret                                                  ; FB5B69  0e
; GmReset_PartVolume: for records 0..31: IndexedTable_MergeMaskedByte of {record, byte 3, 100 (0x64), mask 0x7F} -- every part's Volume set to the
;   GM default.  One step of GmMode_ResetToDefaults.
GmReset_PartVolume:
	link XIZ,0xfffc                                      ; FB5B6A  ee 0c fc ff
	push XIX                                             ; FB5B6E  3c
	lda xix, (xiz-4)                                     ; FB5B6F  be fc 34
	ld (XIX+0x01),0x03                                   ; FB5B72  bc 01 00 03
	ld (XIX+0x02),0x64                                   ; FB5B76  bc 02 00 64
	ld (XIX+0x03),0x7f                                   ; FB5B7A  bc 03 00 7f
	ld (XIX),0x00                                        ; FB5B7E  b4 00 00
.LFB5B81:
	ld C,(XIX)                                           ; FB5B81  84 23
	cp C,0x1f                                            ; FB5B83  cb cf 1f
	jr ugt, .LFB5B92                                     ; FB5B86  6b 0a
	push XIX                                             ; FB5B88  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5B89  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5B8D  84 61
	pop XIY                                              ; FB5B8F  5d
	jr .LFB5B81                                          ; FB5B90  68 ef
.LFB5B92:
	pop XIX                                              ; FB5B92  5c
	unlk XIZ                                             ; FB5B93  ee 0d
	ret                                                  ; FB5B95  0e
GmReset_PartVolume_Nop:
	ret                                                  ; FB5B96  0e
; GmReset_PartEffect3Depth: for records 0..31: IndexedTable_MergeMaskedByte of {record, byte 5, 0, mask 0x7F} -- every part's Effect3Depth set to the
;   GM default.  One step of GmMode_ResetToDefaults.
GmReset_PartEffect3Depth:
	link XIZ,0xfffc                                      ; FB5B97  ee 0c fc ff
	push XIX                                             ; FB5B9B  3c
	lda xix, (xiz-4)                                     ; FB5B9C  be fc 34
	ld (XIX+0x01),0x05                                   ; FB5B9F  bc 01 00 05
	ld (XIX+0x02),0x00                                   ; FB5BA3  bc 02 00 00
	ld (XIX+0x03),0x7f                                   ; FB5BA7  bc 03 00 7f
	ld (XIX),0x00                                        ; FB5BAB  b4 00 00
.LFB5BAE:
	ld C,(XIX)                                           ; FB5BAE  84 23
	cp C,0x1f                                            ; FB5BB0  cb cf 1f
	jr ugt, .LFB5BBF                                     ; FB5BB3  6b 0a
	push XIX                                             ; FB5BB5  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5BB6  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5BBA  84 61
	pop XIY                                              ; FB5BBC  5d
	jr .LFB5BAE                                          ; FB5BBD  68 ef
.LFB5BBF:
	pop XIX                                              ; FB5BBF  5c
	unlk XIZ                                             ; FB5BC0  ee 0d
	ret                                                  ; FB5BC2  0e
; GmReset_PartByte4Bit6: One step of GmMode_ResetToDefaults: for records 0..31, IndexedTable_MergeMaskedByte {record,
;   byte 4, 0, mask 0x40} -- clears bit 6 of every part record's byte 4 (a field no SysEx descriptor names; meaning
;   not established). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
GmReset_PartByte4Bit6:
	link XIZ,0xfffc                                      ; FB5BC3  ee 0c fc ff
	push XIX                                             ; FB5BC7  3c
	lda xix, (xiz-4)                                     ; FB5BC8  be fc 34
	ld (XIX+0x01),0x04                                   ; FB5BCB  bc 01 00 04
	ld (XIX+0x02),0x00                                   ; FB5BCF  bc 02 00 00
	ld (XIX+0x03),0x40                                   ; FB5BD3  bc 03 00 40
	ld (XIX),0x00                                        ; FB5BD7  b4 00 00
.LFB5BDA:
	ld C,(XIX)                                           ; FB5BDA  84 23
	cp C,0x1f                                            ; FB5BDC  cb cf 1f
	jr ugt, .LFB5BEB                                     ; FB5BDF  6b 0a
	push XIX                                             ; FB5BE1  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5BE2  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5BE6  84 61
	pop XIY                                              ; FB5BE8  5d
	jr .LFB5BDA                                          ; FB5BE9  68 ef
.LFB5BEB:
	pop XIX                                              ; FB5BEB  5c
	unlk XIZ                                             ; FB5BEC  ee 0d
	ret                                                  ; FB5BEE  0e
; GmReset_PartEffect4Depth: for records 0..31: IndexedTable_MergeMaskedByte of {record, byte 6, 0, mask 0x7F} -- every part's Effect4Depth set to the
;   GM default.  One step of GmMode_ResetToDefaults.
GmReset_PartEffect4Depth:
	link XIZ,0xfffc                                      ; FB5BEF  ee 0c fc ff
	push XIX                                             ; FB5BF3  3c
	lda xix, (xiz-4)                                     ; FB5BF4  be fc 34
	ld (XIX+0x01),0x06                                   ; FB5BF7  bc 01 00 06
	ld (XIX+0x02),0x00                                   ; FB5BFB  bc 02 00 00
	ld (XIX+0x03),0x7f                                   ; FB5BFF  bc 03 00 7f
	ld (XIX),0x00                                        ; FB5C03  b4 00 00
.LFB5C06:
	ld C,(XIX)                                           ; FB5C06  84 23
	cp C,0x1f                                            ; FB5C08  cb cf 1f
	jr ugt, .LFB5C17                                     ; FB5C0B  6b 0a
	push XIX                                             ; FB5C0D  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5C0E  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5C12  84 61
	pop XIY                                              ; FB5C14  5d
	jr .LFB5C06                                          ; FB5C15  68 ef
.LFB5C17:
	pop XIX                                              ; FB5C17  5c
	unlk XIZ                                             ; FB5C18  ee 0d
	ret                                                  ; FB5C1A  0e
; GmReset_PartEffect1Depth: for records 0..31: IndexedTable_MergeMaskedByte of {record, byte 7, 90 (0x5A), mask 0x7F} -- every part's Effect1Depth set to the
;   GM default.  One step of GmMode_ResetToDefaults.
GmReset_PartEffect1Depth:
	link XIZ,0xfffc                                      ; FB5C1B  ee 0c fc ff
	push XIX                                             ; FB5C1F  3c
	lda xix, (xiz-4)                                     ; FB5C20  be fc 34
	ld (XIX+0x01),0x07                                   ; FB5C23  bc 01 00 07
	ld (XIX+0x02),0x5a                                   ; FB5C27  bc 02 00 5a
	ld (XIX+0x03),0x7f                                   ; FB5C2B  bc 03 00 7f
	ld (XIX),0x00                                        ; FB5C2F  b4 00 00
.LFB5C32:
	ld C,(XIX)                                           ; FB5C32  84 23
	cp C,0x1f                                            ; FB5C34  cb cf 1f
	jr ugt, .LFB5C43                                     ; FB5C37  6b 0a
	push XIX                                             ; FB5C39  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5C3A  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5C3E  84 61
	pop XIY                                              ; FB5C40  5d
	jr .LFB5C32                                          ; FB5C41  68 ef
.LFB5C43:
	pop XIX                                              ; FB5C43  5c
	unlk XIZ                                             ; FB5C44  ee 0d
	ret                                                  ; FB5C46  0e
; GmReset_PartPan: for records 0..31: IndexedTable_MergeMaskedByte of {record, byte 8, 64 (0x40), centre, mask 0x7F} -- every part's Pan set to the
;   GM default.  One step of GmMode_ResetToDefaults.
GmReset_PartPan:
	link XIZ,0xfffc                                      ; FB5C47  ee 0c fc ff
	push XIX                                             ; FB5C4B  3c
	lda xix, (xiz-4)                                     ; FB5C4C  be fc 34
	ld (XIX+0x01),0x08                                   ; FB5C4F  bc 01 00 08
	ld (XIX+0x02),0x40                                   ; FB5C53  bc 02 00 40
	ld (XIX+0x03),0x7f                                   ; FB5C57  bc 03 00 7f
	ld (XIX),0x00                                        ; FB5C5B  b4 00 00
.LFB5C5E:
	ld C,(XIX)                                           ; FB5C5E  84 23
	cp C,0x1f                                            ; FB5C60  cb cf 1f
	jr ugt, .LFB5C6F                                     ; FB5C63  6b 0a
	push XIX                                             ; FB5C65  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5C66  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5C6A  84 61
	pop XIY                                              ; FB5C6C  5d
	jr .LFB5C5E                                          ; FB5C6D  68 ef
.LFB5C6F:
	pop XIX                                              ; FB5C6F  5c
	unlk XIZ                                             ; FB5C70  ee 0d
	ret                                                  ; FB5C72  0e
; GmReset_PartCoarseTune: for records 0..31: IndexedTable_MergeMaskedByte of {record, byte 9, 64 (0x40), centre} -- every part's CoarseTune set to the
;   GM default.  One step of GmMode_ResetToDefaults.
GmReset_PartCoarseTune:
	link XIZ,0xfffc                                      ; FB5C73  ee 0c fc ff
	push XIX                                             ; FB5C77  3c
	lda xix, (xiz-4)                                     ; FB5C78  be fc 34
	ld (XIX+0x01),0x09                                   ; FB5C7B  bc 01 00 09
	ld (XIX+0x02),0x40                                   ; FB5C7F  bc 02 00 40
	ld (XIX+0x03),0x7f                                   ; FB5C83  bc 03 00 7f
	ld (XIX),0x00                                        ; FB5C87  b4 00 00
.LFB5C8A:
	ld C,(XIX)                                           ; FB5C8A  84 23
	cp C,0x1f                                            ; FB5C8C  cb cf 1f
	jr ugt, .LFB5C9B                                     ; FB5C8F  6b 0a
	push XIX                                             ; FB5C91  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5C92  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5C96  84 61
	pop XIY                                              ; FB5C98  5d
	jr .LFB5C8A                                          ; FB5C99  68 ef
.LFB5C9B:
	pop XIX                                              ; FB5C9B  5c
	unlk XIZ                                             ; FB5C9C  ee 0d
	ret                                                  ; FB5C9E  0e
; GmReset_PartFineTune: for records 0..31: IndexedTable_MergeMaskedByte of {record, byte 10, 128 (0x80), centre, mask 0xFF} -- every part's FineTune set to the
;   GM default.  One step of GmMode_ResetToDefaults.
GmReset_PartFineTune:
	link XIZ,0xfffc                                      ; FB5C9F  ee 0c fc ff
	push XIX                                             ; FB5CA3  3c
	lda xix, (xiz-4)                                     ; FB5CA4  be fc 34
	ld (XIX+0x01),0x0a                                   ; FB5CA7  bc 01 00 0a
	ld (XIX+0x02),0x80                                   ; FB5CAB  bc 02 00 80
	ld (XIX+0x03),0xff                                   ; FB5CAF  bc 03 00 ff
	ld (XIX),0x00                                        ; FB5CB3  b4 00 00
.LFB5CB6:
	ld C,(XIX)                                           ; FB5CB6  84 23
	cp C,0x1f                                            ; FB5CB8  cb cf 1f
	jr ugt, .LFB5CC7                                     ; FB5CBB  6b 0a
	push XIX                                             ; FB5CBD  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5CBE  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5CC2  84 61
	pop XIY                                              ; FB5CC4  5d
	jr .LFB5CB6                                          ; FB5CC5  68 ef
.LFB5CC7:
	pop XIX                                              ; FB5CC7  5c
	unlk XIZ                                             ; FB5CC8  ee 0d
	ret                                                  ; FB5CCA  0e
; GmReset_PartBendRange: for records 0..31: IndexedTable_MergeMaskedByte of {record, byte 11, 2, mask 0x7F} -- every part's BendRange set to the
;   GM default.  One step of GmMode_ResetToDefaults.
GmReset_PartBendRange:
	link XIZ,0xfffc                                      ; FB5CCB  ee 0c fc ff
	push XIX                                             ; FB5CCF  3c
	lda xix, (xiz-4)                                     ; FB5CD0  be fc 34
	ld (XIX+0x01),0x0b                                   ; FB5CD3  bc 01 00 0b
	ld (XIX+0x02),0x02                                   ; FB5CD7  bc 02 00 02
	ld (XIX+0x03),0x7f                                   ; FB5CDB  bc 03 00 7f
	ld (XIX),0x00                                        ; FB5CDF  b4 00 00
.LFB5CE2:
	ld C,(XIX)                                           ; FB5CE2  84 23
	cp C,0x1f                                            ; FB5CE4  cb cf 1f
	jr ugt, .LFB5CF3                                     ; FB5CE7  6b 0a
	push XIX                                             ; FB5CE9  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5CEA  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5CEE  84 61
	pop XIY                                              ; FB5CF0  5d
	jr .LFB5CE2                                          ; FB5CF1  68 ef
.LFB5CF3:
	pop XIX                                              ; FB5CF3  5c
	unlk XIZ                                             ; FB5CF4  ee 0d
	ret                                                  ; FB5CF6  0e
; GmReset_ApplyPatchLists: One step of GmMode_ResetToDefaults: (0x2744) := 0 (patch-list index 0, which also skips the
;   snapshot) and PatchLists_ApplyAll through T_F40840 -- PatchList_RecordField0C, _RecordBytes2B and _Globals7F32.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
GmReset_ApplyPatchLists:
	ld (0x2744:16), 0x00                                 ; FB5CF7  f1 44 27 00 00
	call T_F40840                                        ; FB5CFC  1d 40 08 f4
	ret                                                  ; FB5D00  0e
GmReset_ApplyPatchLists_Nop2:
	ret                                                  ; FB5D01  0e
; Tempo_RestoreFromSmfPlay: If the MIDI file player has set a tempo ((0x605068) bit 15, written by
;   SmfPlay_ApplyTempoAsBpm as BPM | 0x8000), Tempo (0x7EE2) := its 9-bit BPM (byte 0, and bit 0 of byte 1); otherwise
;   nothing. Does not apply it. Called by GmMode_ResetToDefaults and, through Tempo_RestoreFromSmfPlay_Call, by GmMode_ResetForGmOff, so
;   a GM change keeps the file's tempo. Basis: callers + body + writer. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
Tempo_RestoreFromSmfPlay:
	pushw hl                                             ; FB5D02  2b
	pushw de                                             ; FB5D03  2a
	push XIX                                             ; FB5D04  3c
	lda xix, (0x7ee2:16)                                ; FB5D05  f1 e2 7e 34
	ld hl, (0x605068:24)                                ; FB5D09  d2 68 50 60 23
	ld BC,HL                                             ; FB5D0E  db 89
	and BC,0x8000                                        ; FB5D10  d9 cc 00 80
	jr z, .LFB5D30                                       ; FB5D14  66 1a
	ld C,L                                               ; FB5D16  cf 8b
	ld (XIX),C                                           ; FB5D18  b4 43
	extz XIX                                             ; FB5D1A  ec 12
	and (XIX+0x01),0xfe                                  ; FB5D1C  8c 01 3c fe
	ld D,(XIX+0x01)                                      ; FB5D20  8c 01 24
	ld BC,HL                                             ; FB5D23  db 89
	srl bc, 0x08                                         ; FB5D25  d9 ef 08
	and C,0x01                                           ; FB5D28  cb cc 01
	or C,D                                               ; FB5D2B  cc e3
	ld (XIX+0x01),C                                      ; FB5D2D  bc 01 43
.LFB5D30:
	pop XIX                                              ; FB5D30  5c
	popw de                                              ; FB5D31  4a
	popw hl                                              ; FB5D32  4b
	ret                                                  ; FB5D33  0e
; Tempo_RestoreFromSmfPlay_Call: calls Tempo_RestoreFromSmfPlay and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
Tempo_RestoreFromSmfPlay_Call:
	calr Tempo_RestoreFromSmfPlay                                      ; FB5D34  1e cb ff
	ret                                                  ; FB5D37  0e
; GmReset_PartByte12Bit4: One step of GmMode_ResetToDefaults: for records 0..31, IndexedTable_MergeMaskedByte {record,
;   byte 0x0C, 0, mask 0x10} -- clears bit 4 of every part record's byte 0x0C (bit 3 of the same byte is KEY SCALING;
;   bit 4 has no SysEx descriptor, meaning not established). Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
GmReset_PartByte12Bit4:
	link XIZ,0xfffc                                      ; FB5D38  ee 0c fc ff
	push XIX                                             ; FB5D3C  3c
	lda xix, (xiz-4)                                     ; FB5D3D  be fc 34
	ld (XIX),0x00                                        ; FB5D40  b4 00 00
.LFB5D43:
	ld C,(XIX)                                           ; FB5D43  84 23
	cp C,0x1f                                            ; FB5D45  cb cf 1f
	jr ugt, .LFB5D60                                     ; FB5D48  6b 16
	ld (XIX+0x01),0x0c                                   ; FB5D4A  bc 01 00 0c
	ld (XIX+0x02),0x00                                   ; FB5D4E  bc 02 00 00
	ld (XIX+0x03),0x10                                   ; FB5D52  bc 03 00 10
	push XIX                                             ; FB5D56  3c
	call IndexedTable_MergeMaskedByte                                      ; FB5D57  1d 2b 78 fb
	incm8 0x01, (xix)                                    ; FB5D5B  84 61
	pop XIY                                              ; FB5D5D  5d
	jr .LFB5D43                                          ; FB5D5E  68 e3
.LFB5D60:
	pop XIX                                              ; FB5D60  5c
	unlk XIZ                                             ; FB5D61  ee 0d
	ret                                                  ; FB5D63  0e
; GmReset_AllPartsPitchBend: parameter 0xB1 (ParamMsg_B1...) for parts 0..31 with (0x60F082) / (0x60F083) = 0x00 / 0x40 -- the bend centre.  Called by GmMode_ApplyChange
;   (GmMode_HandleChange's) after GmMode_ResetToDefaults.
GmReset_AllPartsPitchBend:
	push XIX                                             ; FB5D64  3c
	lda xix, (0x60f081:24)                               ; FB5D65  f2 81 f0 60 34
	ld (0x60f080:24), 0xb1                             ; FB5D6A  f2 80 f0 60 00 b1
	ld (0x60f082:24), 0x00                             ; FB5D70  f2 82 f0 60 00 00
	ld (XIX),0x00                                        ; FB5D76  b4 00 00
.LFB5D79:
	ld (0x60f083:24), 0x40                             ; FB5D79  f2 83 f0 60 00 40
	push XDE                                             ; FB5D7F  3a
	push XHL                                             ; FB5D80  3b
	push XIX                                             ; FB5D81  3c
	push XIZ                                             ; FB5D82  3e
	call T_Queue2C00_PublishStagedDrainPassB             ; FB5D83  1d b8 07 f4
	pop XIZ                                              ; FB5D87  5e
	pop XIX                                              ; FB5D88  5c
	pop XHL                                              ; FB5D89  5b
	pop XDE                                              ; FB5D8A  5a
	incm8 0x01, (xix)                                    ; FB5D8B  84 61
	ld C,(XIX)                                           ; FB5D8D  84 23
	cp C,0x1f                                            ; FB5D8F  cb cf 1f
	jr ule, .LFB5D79                                     ; FB5D92  63 e5
	pop XIX                                              ; FB5D94  5c
	ret                                                  ; FB5D95  0e
; GmReset_AllPartsChannelPressure: parameter 0xB4 (ParamMsg_B4...) for parts 0..31 with (0x60F082) / (0x60F083) = 0 / 0x7F.  Called by GmMode_ApplyChange
;   (GmMode_HandleChange's) after GmMode_ResetToDefaults.
GmReset_AllPartsChannelPressure:
	push XIX                                             ; FB5D96  3c
	lda xix, (0x60f081:24)                               ; FB5D97  f2 81 f0 60 34
	ld (0x60f080:24), 0xb4                             ; FB5D9C  f2 80 f0 60 00 b4
	ld (0x60f082:24), 0x00                             ; FB5DA2  f2 82 f0 60 00 00
	ld (XIX),0x00                                        ; FB5DA8  b4 00 00
.LFB5DAB:
	ld (0x60f083:24), 0x7f                             ; FB5DAB  f2 83 f0 60 00 7f
	push XDE                                             ; FB5DB1  3a
	push XHL                                             ; FB5DB2  3b
	push XIX                                             ; FB5DB3  3c
	push XIZ                                             ; FB5DB4  3e
	call T_Queue2C00_PublishStagedDrainPassB             ; FB5DB5  1d b8 07 f4
	pop XIZ                                              ; FB5DB9  5e
	pop XIX                                              ; FB5DBA  5c
	pop XHL                                              ; FB5DBB  5b
	pop XDE                                              ; FB5DBC  5a
	incm8 0x01, (xix)                                    ; FB5DBD  84 61
	ld C,(XIX)                                           ; FB5DBF  84 23
	cp C,0x1f                                            ; FB5DC1  cb cf 1f
	jr ule, .LFB5DAB                                     ; FB5DC4  63 e5
	pop XIX                                              ; FB5DC6  5c
	ret                                                  ; FB5DC7  0e
; GmReset_AllPartsModulation: parameter 0xB2 (ParamMsg_B2...) for parts 0..31 with (0x60F082) / (0x60F083) = 0 / 0x7F.  Called by GmMode_ApplyChange
;   (GmMode_HandleChange's) after GmMode_ResetToDefaults.
GmReset_AllPartsModulation:
	push XIX                                             ; FB5DC8  3c
	lda xix, (0x60f081:24)                               ; FB5DC9  f2 81 f0 60 34
	ld (0x60f080:24), 0xb2                             ; FB5DCE  f2 80 f0 60 00 b2
	ld (0x60f082:24), 0x00                             ; FB5DD4  f2 82 f0 60 00 00
	ld (XIX),0x00                                        ; FB5DDA  b4 00 00
.LFB5DDD:
	ld (0x60f083:24), 0x7f                             ; FB5DDD  f2 83 f0 60 00 7f
	push XDE                                             ; FB5DE3  3a
	push XHL                                             ; FB5DE4  3b
	push XIX                                             ; FB5DE5  3c
	push XIZ                                             ; FB5DE6  3e
	call T_Queue2C00_PublishStagedDrainPassB             ; FB5DE7  1d b8 07 f4
	pop XIZ                                              ; FB5DEB  5e
	pop XIX                                              ; FB5DEC  5c
	pop XHL                                              ; FB5DED  5b
	pop XDE                                              ; FB5DEE  5a
	incm8 0x01, (xix)                                    ; FB5DEF  84 61
	ld C,(XIX)                                           ; FB5DF1  84 23
	cp C,0x1f                                            ; FB5DF3  cb cf 1f
	jr ule, .LFB5DDD                                     ; FB5DF6  63 e5
	pop XIX                                              ; FB5DF8  5c
	ret                                                  ; FB5DF9  0e
; GmReset_AllPartsExpression: parameter 0xB3 (ParamMsg_B3...) for parts 0..31 with (0x60F082) / (0x60F083) = 0x7F / 0x7F.  Called by GmMode_ApplyChange
;   (GmMode_HandleChange's) after GmMode_ResetToDefaults.
GmReset_AllPartsExpression:
	push XIX                                             ; FB5DFA  3c
	lda xix, (0x60f081:24)                               ; FB5DFB  f2 81 f0 60 34
	ld (0x60f080:24), 0xb3                             ; FB5E00  f2 80 f0 60 00 b3
	ld (0x60f082:24), 0x7f                             ; FB5E06  f2 82 f0 60 00 7f
	ld (XIX),0x00                                        ; FB5E0C  b4 00 00
.LFB5E0F:
	ld (0x60f083:24), 0x7f                             ; FB5E0F  f2 83 f0 60 00 7f
	push XDE                                             ; FB5E15  3a
	push XHL                                             ; FB5E16  3b
	push XIX                                             ; FB5E17  3c
	push XIZ                                             ; FB5E18  3e
	call T_Queue2C00_PublishStagedDrainPassB             ; FB5E19  1d b8 07 f4
	pop XIZ                                              ; FB5E1D  5e
	pop XIX                                              ; FB5E1E  5c
	pop XHL                                              ; FB5E1F  5b
	pop XDE                                              ; FB5E20  5a
	incm8 0x01, (xix)                                    ; FB5E21  84 61
	ld C,(XIX)                                           ; FB5E23  84 23
	cp C,0x1f                                            ; FB5E25  cb cf 1f
	jr ule, .LFB5E0F                                     ; FB5E28  63 e5
	pop XIX                                              ; FB5E2A  5c
	ret                                                  ; FB5E2B  0e
; GmReset_AllPartsHold: parameter 0xB5 (ParamMsg_B5...) for parts 0..31 with (0x60F082) / (0x60F083) = 0 / 0x7F.  Called by GmMode_ApplyChange
;   (GmMode_HandleChange's) after GmMode_ResetToDefaults.
GmReset_AllPartsHold:
	push XIX                                             ; FB5E2C  3c
	lda xix, (0x60f081:24)                               ; FB5E2D  f2 81 f0 60 34
	ld (0x60f080:24), 0xb5                             ; FB5E32  f2 80 f0 60 00 b5
	ld (0x60f082:24), 0x00                             ; FB5E38  f2 82 f0 60 00 00
	ld (XIX),0x00                                        ; FB5E3E  b4 00 00
.LFB5E41:
	ld (0x60f083:24), 0x7f                             ; FB5E41  f2 83 f0 60 00 7f
	push XDE                                             ; FB5E47  3a
	push XHL                                             ; FB5E48  3b
	push XIX                                             ; FB5E49  3c
	push XIZ                                             ; FB5E4A  3e
	call T_Queue2C00_PublishStagedDrainPassB             ; FB5E4B  1d b8 07 f4
	pop XIZ                                              ; FB5E4F  5e
	pop XIX                                              ; FB5E50  5c
	pop XHL                                              ; FB5E51  5b
	pop XDE                                              ; FB5E52  5a
	incm8 0x01, (xix)                                    ; FB5E53  84 61
	ld C,(XIX)                                           ; FB5E55  84 23
	cp C,0x1f                                            ; FB5E57  cb cf 1f
	jr ule, .LFB5E41                                     ; FB5E5A  63 e5
	pop XIX                                              ; FB5E5C  5c
	ret                                                  ; FB5E5D  0e
; GmReset_AllPartsParamB7: parameter 0xB7 with (0x60F082) = 0, (0x60F083) = 0x7F, for parts 0..31 (Queue2C00_PublishStagedDrainPassB) --
;   GmReset_AllPartsExpression's shape.  The parameter dispatch table maps 0xB7 to Dispatch_By_60F080_Nop64.
GmReset_AllPartsParamB7:
	push XIX                                             ; FB5E5E  3c
	lda xix, (0x60f081:24)                               ; FB5E5F  f2 81 f0 60 34
	ld (0x60f080:24), 0xb7                             ; FB5E64  f2 80 f0 60 00 b7
	ld (0x60f082:24), 0x00                             ; FB5E6A  f2 82 f0 60 00 00
	ld (XIX),0x00                                        ; FB5E70  b4 00 00
.LFB5E73:
	ld (0x60f083:24), 0x7f                             ; FB5E73  f2 83 f0 60 00 7f
	push XDE                                             ; FB5E79  3a
	push XHL                                             ; FB5E7A  3b
	push XIX                                             ; FB5E7B  3c
	push XIZ                                             ; FB5E7C  3e
	call T_Queue2C00_PublishStagedDrainPassB             ; FB5E7D  1d b8 07 f4
	pop XIZ                                              ; FB5E81  5e
	pop XIX                                              ; FB5E82  5c
	pop XHL                                              ; FB5E83  5b
	pop XDE                                              ; FB5E84  5a
	incm8 0x01, (xix)                                    ; FB5E85  84 61
	ld C,(XIX)                                           ; FB5E87  84 23
	cp C,0x1f                                            ; FB5E89  cb cf 1f
	jr ule, .LFB5E73                                     ; FB5E8C  63 e5
	pop XIX                                              ; FB5E8E  5c
	ret                                                  ; FB5E8F  0e
; GmReset_AllPartsParamB6: the same with parameter 0xB6 (also Dispatch_By_60F080_Nop64 in the table).
GmReset_AllPartsParamB6:
	push XIX                                             ; FB5E90  3c
	lda xix, (0x60f081:24)                               ; FB5E91  f2 81 f0 60 34
	ld (0x60f080:24), 0xb6                             ; FB5E96  f2 80 f0 60 00 b6
	ld (0x60f082:24), 0x00                             ; FB5E9C  f2 82 f0 60 00 00
	ld (XIX),0x00                                        ; FB5EA2  b4 00 00
.LFB5EA5:
	ld (0x60f083:24), 0x7f                             ; FB5EA5  f2 83 f0 60 00 7f
	push XDE                                             ; FB5EAB  3a
	push XHL                                             ; FB5EAC  3b
	push XIX                                             ; FB5EAD  3c
	push XIZ                                             ; FB5EAE  3e
	call T_Queue2C00_PublishStagedDrainPassB             ; FB5EAF  1d b8 07 f4
	pop XIZ                                              ; FB5EB3  5e
	pop XIX                                              ; FB5EB4  5c
	pop XHL                                              ; FB5EB5  5b
	pop XDE                                              ; FB5EB6  5a
	incm8 0x01, (xix)                                    ; FB5EB7  84 61
	ld C,(XIX)                                           ; FB5EB9  84 23
	cp C,0x1f                                            ; FB5EBB  cb cf 1f
	jr ule, .LFB5EA5                                     ; FB5EBE  63 e5
	pop XIX                                              ; FB5EC0  5c
	ret                                                  ; FB5EC1  0e
GmReset_AllPartsParamB6_Nop:
	ret                                                  ; FB5EC2  0e
; GmReset_AllPartsRpnNull: Fills 0x1980..0x19BF with 0x7F: all 32 parts' selected-RPN words := 0x7F7F, RPN null. The
;   last step of GmMode_ApplyChange, after the GmReset_AllParts* controller resets;
;   ParamApply_PublishStagedAndPostSeven (Reset All Controllers) does the same for one part. Basis: caller + body +
;   the MIDI-in RPN handlers. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
GmReset_AllPartsRpnNull:
	pushw hl                                             ; FB5EC3  2b
	pushw de                                             ; FB5EC4  2a
	push XIX                                             ; FB5EC5  3c
	lda xix, (0x1980:16)                                ; FB5EC6  f1 80 19 34
	ldw de, 0x1980                                       ; FB5ECA  32 80 19
	ldw bc, 0x19bf                                       ; FB5ECD  31 bf 19
	sub BC,DE                                            ; FB5ED0  da a1
	ld H,C                                               ; FB5ED2  cb 8e
	inc 1,C                                              ; FB5ED4  cb 61
	ld H,C                                               ; FB5ED6  cb 8e
.LFB5ED8:
	cp h, 0x00:i3                                          ; FB5ED8  ce d8
	jr z, .LFB5EE5                                       ; FB5EDA  66 09
	dec 1,H                                              ; FB5EDC  ce 69
	ld (XIX),0x7f                                        ; FB5EDE  b4 00 7f
	inc 1,XIX                                            ; FB5EE1  ec 61
	jr .LFB5ED8                                          ; FB5EE3  68 f3
.LFB5EE5:
	pop XIX                                              ; FB5EE5  5c
	popw de                                              ; FB5EE6  4a
	popw hl                                              ; FB5EE7  4b
	ret                                                  ; FB5EE8  0e
; GmMode_OnEventPassB: T_GmMode_OnEventPassB, UiListB_Class91: byte 3 with the GM bit (0x04) changed, unless GmMode_HandleChange is running
;   (0x60F01F bit 0, its re-entry guard): GmMode_PostToMsg0716(the new value).
GmMode_OnEventPassB:
	ld c, (0x60f01f:24)                                 ; FB5EE9  c2 1f f0 60 23
	and C,0x01                                           ; FB5EEE  cb cc 01
	jr nz, .LFB5F0E                                      ; FB5EF1  6e 1b
	cp	(UiEvent_Byte1:16), 0x03                            ; FB5EF3  c1 b8 20 3f 03
	jr nz, .LFB5F0E                                      ; FB5EF8  6e 14
	ld c, (UiEvent_Byte3:16)                                   ; FB5EFA  c1 ba 20 23
	and C,0x04                                           ; FB5EFE  cb cc 04
	jr z, .LFB5F0E                                       ; FB5F01  66 0b
	ld bc, (UiEvent_Byte2:16)                                 ; FB5F03  d1 b9 20 21
	extz BC                                              ; FB5F07  d9 12
	pushw bc                                             ; FB5F09  29
	calr GmMode_PostToMsg0716                                      ; FB5F0A  1e 02 00
	popw bc                                              ; FB5F0D  49
.LFB5F0E:
	ret                                                  ; FB5F0E  0e
; GmMode_PostToMsg0716: (value): T_Msg0716_PostGmSystemOnOff (Msg0716_PostGmSystemOnOff) with 1 when value bit 2 -- the GM bit -- is set, else 0.  Called by
;   GmMode_HandleChange and GmMode_OnEventPassB.
GmMode_PostToMsg0716:
	link XIZ,0x0000                                      ; FB5F0F  ee 0c 00 00
	pushw hl                                             ; FB5F13  2b
	ld h, 0x00:opc                                          ; FB5F14  26 00
	ld C,(XIZ+0x08)                                      ; FB5F16  8e 08 23
	and C,0x04                                           ; FB5F19  cb cc 04
	jr z, .LFB5F20                                       ; FB5F1C  66 02
	ld h, 0x01:opc                                          ; FB5F1E  26 01
.LFB5F20:
	ld C,H                                               ; FB5F20  ce 8b
	extz BC                                              ; FB5F22  d9 12
	pushw bc                                             ; FB5F24  29
	call T_Msg0716_PostGmSystemOnOff                                        ; FB5F25  1d 5c 10 f4
	popw bc                                              ; FB5F29  49
	popw hl                                              ; FB5F2A  4b
	unlk XIZ                                             ; FB5F2B  ee 0d
	ret                                                  ; FB5F2D  0e
; SysExTx_AnnounceGmMode: unless (0x60F020) bit 7: the record {B0, 0x11 if the argument's bit 2 else 0x10, 00, 7F} to SysExTx_GmSystemOnOff.
SysExTx_AnnounceGmMode:
	link XIZ,0xfffc                                      ; FB5F2E  ee 0c fc ff
	push XIX                                             ; FB5F32  3c
	lda xix, (xiz-4)                                     ; FB5F33  be fc 34
	ld c, (0x60f020:24)                                 ; FB5F36  c2 20 f0 60 23
	and C,0x80                                           ; FB5F3B  cb cc 80
	jr nz, .LFB5F61                                      ; FB5F3E  6e 21
	ld (XIX),0xb0                                        ; FB5F40  b4 00 b0
	ld (XIX+0x02),0x00                                   ; FB5F43  bc 02 00 00
	ld (XIX+0x03),0x7f                                   ; FB5F47  bc 03 00 7f
	ld (XIX+0x01),0x11                                   ; FB5F4B  bc 01 00 11
	ld C,(XIZ+0x08)                                      ; FB5F4F  8e 08 23
	and C,0x04                                           ; FB5F52  cb cc 04
	jr nz, .LFB5F5B                                      ; FB5F55  6e 04
	ld (XIX+0x01),0x10                                   ; FB5F57  bc 01 00 10
.LFB5F5B:
	push XIX                                             ; FB5F5B  3c
	call SysExTx_GmSystemOnOff                                      ; FB5F5C  1d ae 4c fb
	pop XIY                                              ; FB5F60  5d
.LFB5F61:
	pop XIX                                              ; FB5F61  5c
	unlk XIZ                                             ; FB5F62  ee 0d
	ret                                                  ; FB5F64  0e
; SysExTx_PatchModelByteVariant2(buf): only when Variant_Flag == 2 and the command byte is 0x21/0x22/0x2C/0x2D: model byte (message +4) = 1;
;   for 0x2C/0x2D also recompute the checksum (sysex-probes/sysex_model_variant.py).
SysExTx_PatchModelByteVariant2:
	link XIZ,0xfffc                                      ; FB5F65  ee 0c fc ff
	pushw hl                                             ; FB5F69  2b
	push XIX                                             ; FB5F6A  3c
	ld h, 0x00:opc                                          ; FB5F6B  26 00
	cp	(Variant_Flag:8), 0x02                               ; FB5F6D  c0 c4 3f 02
	jrl nz, .LFB5FF0                                     ; FB5F71  7e 7c 00
	ld XBC,(XIZ+0x08)                                    ; FB5F74  ae 08 21
	add XBC,0x0000000e                                   ; FB5F77  e9 c8 0e 00 00 00
	ld (xiz-4), xbc                                      ; FB5F7D  be fc 61
	ld XWA,(XIZ+0x08)                                    ; FB5F80  ae 08 20
	ld C,(XWA+0x10)                                      ; FB5F83  88 10 23
	extz BC                                              ; FB5F86  d9 12
	cp BC,0x0021                                         ; FB5F88  d9 cf 21 00
	jrl z, .LFB5FE9                                      ; FB5F8C  76 5a 00
	cp BC,0x0022                                         ; FB5F8F  d9 cf 22 00
	jr z, .LFB5FE9                                       ; FB5F93  66 54
	cp BC,0x002c                                         ; FB5F95  d9 cf 2c 00
	jr z, .LFB5FA3                                       ; FB5F99  66 08
	cp BC,0x002d                                         ; FB5F9B  d9 cf 2d 00
	jr z, .LFB5FA3                                       ; FB5F9F  66 02
	jr .LFB5FF0                                          ; FB5FA1  68 4d
.LFB5FA3:
	ld xbc, (xiz-4)                                      ; FB5FA3  ae fc 21
	ld (XBC+0x04),0x01                                   ; FB5FA6  b9 04 00 01
	sub XBC,XBC                                          ; FB5FAA  e9 a1
	inc 1,XBC                                            ; FB5FAC  e9 61
	add (xiz-4), xbc                                     ; FB5FAE  ae fc 89
	ld XWA,(XIZ+0x08)                                    ; FB5FB1  ae 08 20
	ld XIY,(XWA+0x0a)                                    ; FB5FB4  a8 0a 25
	dec 2,XIY                                            ; FB5FB7  ed 6a
	ld XIX,XIY                                           ; FB5FB9  ed 8c
.LFB5FBB:
	ld xbc, (xiz-4)                                      ; FB5FBB  ae fc 21
	cp XBC,XIX                                           ; FB5FBE  ec f1
	jr z, .LFB5FD0                                       ; FB5FC0  66 0e
	ld xbc, (xiz-4)                                      ; FB5FC2  ae fc 21
	ld A,(XBC)                                           ; FB5FC5  81 21
	add H,A                                              ; FB5FC7  c9 86
	inc 1,XBC                                            ; FB5FC9  e9 61
	ld (xiz-4), xbc                                      ; FB5FCB  be fc 61
	jr .LFB5FBB                                          ; FB5FCE  68 eb
.LFB5FD0:
	ld C,H                                               ; FB5FD0  ce 8b
	extz BC                                              ; FB5FD2  d9 12
	sub WA,WA                                            ; FB5FD4  d8 a0
	sub WA,BC                                            ; FB5FD6  d9 a0
	ld H,A                                               ; FB5FD8  c9 8e
	res 0x07,H                                           ; FB5FDA  ce 30 07
	ld XBC,(XIZ+0x08)                                    ; FB5FDD  ae 08 21
	ld XWA,(XBC+0x0a)                                    ; FB5FE0  a9 0a 20
	dec 2,XWA                                            ; FB5FE3  e8 6a
	ld (XWA),H                                           ; FB5FE5  b0 46
	jr .LFB5FF0                                          ; FB5FE7  68 07
.LFB5FE9:
	ld xbc, (xiz-4)                                      ; FB5FE9  ae fc 21
	ld (XBC+0x04),0x01                                   ; FB5FEC  b9 04 00 01
.LFB5FF0:
	pop XIX                                              ; FB5FF0  5c
	popw hl                                              ; FB5FF1  4b
	unlk XIZ                                             ; FB5FF2  ee 0d
	ret                                                  ; FB5FF4  0e
; SysEx_FeatureWordForVariant(i): i < 6: word i of prom_b 0xF4FE6A (Variant_Flag == 1) or 0xF4FE76 (else); 0xFFFF = not available.
SysEx_FeatureWordForVariant:
	link XIZ,0x0000                                      ; FB5FF5  ee 0c 00 00
	push XIX                                             ; FB5FF9  3c
	cp (XIZ+0x08),0x06                                   ; FB5FFA  8e 08 3f 06
	jr NC,.LFB601F                                       ; FB5FFE  6f 1f
	cp	(Variant_Flag:8), 0x01                               ; FB6000  c0 c4 3f 01
	jr nz, .LFB600D                                      ; FB6004  6e 07
	lda	xix, (WordTable_F4FE6A:24)                   ; FB6006  f2 6a fe f4 34
	jr .LFB6012                                          ; FB600B  68 05
.LFB600D:
	lda	xix, (WordTable_F4FE76:24)                   ; FB600D  f2 76 fe f4 34
.LFB6012:
	ld c, 0x02:opc                                          ; FB6012  23 02
	mul	bc, (xiz+8)                                  ; FB6014  8e 08 43
	extz XBC                                             ; FB6017  e9 12
	add XBC,XIX                                          ; FB6019  ec 81
	ld WA,(XBC)                                          ; FB601B  91 20
	jr .LFB6022                                          ; FB601D  68 03
.LFB601F:
	ldw wa, 0xffff                                       ; FB601F  30 ff ff
.LFB6022:
	pop XIX                                              ; FB6022  5c
	unlk XIZ                                             ; FB6023  ee 0d
	ret                                                  ; FB6025  0e
; SysExDump_AwaitFrameAck: with the handshake flag (bit 7 of (0x60FD40)): wait for class 1 (ACK); class 6 -> status 0x1F; else resend
;   (0x60FC8C), up to 3 times, then status 0x18.  Without it: Ring601432_SpinUntilEmpty, SysEx_Wait25Ticks.
SysExDump_AwaitFrameAck:
	pushw hl                                             ; FB6026  2b
	push XIX                                             ; FB6027  3c
	lda xix, (0x60fcd8:24)                               ; FB6028  f2 d8 fc 60 34
	bit	7, (0x60fd40:24)                             ; FB602D  f2 40 fd 60 cf
	jr z, .LFB6069                                       ; FB6032  66 35
	ld l, 0x00:opc                                          ; FB6034  27 00
.LFB6036:
	calr SysExRx_AwaitReply                                      ; FB6036  1e 39 00
	ld XBC,(XIX)                                         ; FB6039  a4 21
	ld H,(XBC)                                           ; FB603B  81 26
	cp h, 0x01:i3                                          ; FB603D  ce d9
	jr z, .LFB606F                                       ; FB603F  66 2e
	cp h, 0x06:i3                                          ; FB6041  ce de
	jr nz, .LFB604D                                      ; FB6043  6e 08
	ld XBC,(XIX)                                         ; FB6045  a4 21
	ld (XBC+0x04),0x1f                                   ; FB6047  b9 04 00 1f
	jr .LFB606F                                          ; FB604B  68 22
.LFB604D:
	ld xbc, (0x60fc8c:24)                               ; FB604D  e2 8c fc 60 21
	push XBC                                             ; FB6052  39
	calr SysExTx_SendFrameMidi1                                          ; FB6053  1e 0f 11
	inc 1,L                                              ; FB6056  cf 61
	pop XIY                                              ; FB6058  5d
	cp l, 0x03:i3                                          ; FB6059  cf db
	jr c, .LFB6036                                       ; FB605B  67 d9
	cp l, 0x03:i3                                          ; FB605D  cf db
	jr c, .LFB606F                                       ; FB605F  67 0e
	ld XBC,(XIX)                                         ; FB6061  a4 21
	ld (XBC+0x04),0x18                                   ; FB6063  b9 04 00 18
	jr .LFB606F                                          ; FB6067  68 06
.LFB6069:
	calr Ring601432_SpinUntilEmpty                                      ; FB6069  1e 18 00
	calr SysEx_Wait25Ticks                                          ; FB606C  1e 58 17
.LFB606F:
	pop XIX                                              ; FB606F  5c
	popw hl                                              ; FB6070  4b
	ret                                                  ; FB6071  0e
; SysExRx_AwaitReply: SysExRx_SwapBuffers, Ring601432_SpinUntilEmpty, SysExRx_ReceiveBlocking, SysExRx_ParseMessage, MidiInARing_InitIfPanelMode79.
SysExRx_AwaitReply:
	call SysExRx_SwapBuffers                                      ; FB6072  1d 28 80 fb
	calr Ring601432_SpinUntilEmpty                                      ; FB6076  1e 0b 00
	calr SysExRx_ReceiveBlocking                                      ; FB6079  1e 1c 00
	calr SysExRx_ParseMessage                                          ; FB607C  1e 30 03
	call MidiInARing_InitIfPanelMode79                                      ; FB607F  1d fd 7e fb
	ret                                                  ; FB6083  0e
; ---------------------------------------------------------------------
; Ring601432_SpinUntilEmpty -- polls ring 0x601432 until it is empty, or 65535 times,
;                              whichever comes first
;
; Evidence: 0xFB6085 `ldw HL,0xFFFF` seeds the bound; 0xFB6088 `cps
;           HL,0x00` and 0xFB608A `jr z` leave on exhaustion; 0xFB608C
;           `dec 1,HL` counts down; 0xFB608E `call 0xF41DFC` = prom_b
;           slot T_Ring601432_IsEmpty; 0xFB6092 `cps WA,0x00` and
;           0xFB6094 `jr nz` go round again while the result is
;           non-zero. Ring601432_IsEmpty (0xF8483F) returns 0 only when
;           the read cursor (0x60142A) equals the write cursor
;           (0x60142E), so a non-zero result means the ring still holds
;           data. Called by `calr` at 0xFB6069 (in SysExDump_AwaitFrameAck) and
;           0xFB6076 (in SysExRx_AwaitReply)
; Unknown:  what the 65535-poll bound is for: the routine returns no
;           value, so neither caller can tell a drained ring from an
;           exhausted count
; Was `sub_FB6084`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
Ring601432_SpinUntilEmpty:
	pushw hl                                             ; FB6084  2b
	ldw hl, 0xffff                                       ; FB6085  33 ff ff
.LFB6088:
	cp hl, 0x00:i3                                         ; FB6088  db d8
	jr z, .LFB6096                                       ; FB608A  66 0a
	dec 1,HL                                             ; FB608C  db 69
	call T_Ring601432_IsEmpty                            ; FB608E  1d fc 1d f4
	cp wa, 0x00:i3                                         ; FB6092  d8 d8
	jr nz, .LFB6088                                      ; FB6094  6e f2
.LFB6096:
	popw hl                                              ; FB6096  4b
	ret                                                  ; FB6097  0e
; SysExRx_ReceiveBlocking: read ring 0x601646 (T_Ring601646_Get) into SysExRx_AppendByte until F7, an error status, or SysExRx_CheckReplyTimeout.
SysExRx_ReceiveBlocking:
	pushw hl                                             ; FB6098  2b
	pushw de                                             ; FB6099  2a
	pushw ix                                             ; FB609A  2c
	ld l, 0x00:opc                                          ; FB609B  27 00
	res	5, (0x60fd40:24)                             ; FB609D  f2 40 fd 60 b5
	ld	de, (Tick_Count:8)                                 ; FB60A2  d0 80 22
.LFB60A5:
	bit	5, (0x60fd40:24)                             ; FB60A5  f2 40 fd 60 cd
	jrl nz, .LFB6161                                     ; FB60AA  7e b4 00
	pushw 0x04                                           ; FB60AD  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB60B0  e2 d8 fc 60 21
	push XBC                                             ; FB60B5  39
	calr U8Rec16_GetField                                          ; FB60B6  1e 1a 02
	inc 6,XSP                                            ; FB60B9  ef 66
	cp a, 0x00:i3                                          ; FB60BB  c9 d8
	jrl nz, .LFB6161                                     ; FB60BD  7e a1 00
	call T_Ring601646_Get                                ; FB60C0  1d 38 1e f4
	ld IX,WA                                             ; FB60C4  d8 8c
	cp WA,0xffff                                         ; FB60C6  d8 cf ff ff
	jrl z, .LFB6156                                      ; FB60CA  76 89 00
	ld H,A                                               ; FB60CD  c9 8e
	ld	de, (Tick_Count:8)                                 ; FB60CF  d0 80 22
	ld C,L                                               ; FB60D2  cf 8b
	extz BC                                              ; FB60D4  d9 12
	cp bc, 0x00:i3                                         ; FB60D6  d9 d8
	jr z, .LFB60E0                                       ; FB60D8  66 06
	cp bc, 0x01:i3                                         ; FB60DA  d9 d9
	jr z, .LFB60EE                                       ; FB60DC  66 10
	jr .LFB60FC                                          ; FB60DE  68 1c
.LFB60E0:
	cp H,0xf0                                            ; FB60E0  ce cf f0
	jr nz, .LFB60E9                                      ; FB60E3  6e 04
	ld l, 0x01:opc                                          ; FB60E5  27 01
	jr .LFB6110                                          ; FB60E7  68 27
.LFB60E9:
	pushw 0x01                                           ; FB60E9  0b 01 00
	jr .LFB6145                                          ; FB60EC  68 57
.LFB60EE:
	cp H,0x50                                            ; FB60EE  ce cf 50
	jr nz, .LFB60F7                                      ; FB60F1  6e 04
	ld l, 0x02:opc                                          ; FB60F3  27 02
	jr .LFB6110                                          ; FB60F5  68 19
.LFB60F7:
	pushw 0x02                                           ; FB60F7  0b 02 00
	jr .LFB6145                                          ; FB60FA  68 49
.LFB60FC:
	ld C,H                                               ; FB60FC  ce 8b
	and C,0x80                                           ; FB60FE  cb cc 80
	jr nz, .LFB612C                                      ; FB6101  6e 29
	ld xbc, (0x60fc80:24)                               ; FB6103  e2 80 fc 60 21
	ld WA,(XBC)                                          ; FB6108  91 20
	cp WA,0x00ff                                         ; FB610A  d8 cf ff 00
	jr nc, .LFB611B                                      ; FB610E  6f 0b
.LFB6110:
	ld C,H                                               ; FB6110  ce 8b
	extz BC                                              ; FB6112  d9 12
	pushw bc                                             ; FB6114  29
	calr SysExRx_AppendByte                                      ; FB6115  1e 4d 00
.LFB6118:
	popw bc                                              ; FB6118  49
	jr .LFB6156                                          ; FB6119  68 3b
.LFB611B:
	pushw 0x06                                           ; FB611B  0b 06 00
	pushw 0x04                                           ; FB611E  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB6121  e2 d8 fc 60 21
	push XBC                                             ; FB6126  39
	calr U8Rec16_SetField                                      ; FB6127  1e ef 00
	jr .LFB6154                                          ; FB612A  68 28
.LFB612C:
	cp H,0xf7                                            ; FB612C  ce cf f7
	jr nz, .LFB6142                                      ; FB612F  6e 11
	ld l, 0x00:opc                                          ; FB6131  27 00
	ld C,H                                               ; FB6133  ce 8b
	extz BC                                              ; FB6135  d9 12
	pushw bc                                             ; FB6137  29
	calr SysExRx_AppendByte                                      ; FB6138  1e 2a 00
	set	5, (0x60fd40:24)                             ; FB613B  f2 40 fd 60 bd
	jr .LFB6118                                          ; FB6140  68 d6
.LFB6142:
	pushw 0x03                                           ; FB6142  0b 03 00
.LFB6145:
	pushw 0x04                                           ; FB6145  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB6148  e2 d8 fc 60 21
	push XBC                                             ; FB614D  39
	calr U8Rec16_SetField                                      ; FB614E  1e c8 00
	set	5, (MIDI_RX_SysExState:8)                                   ; FB6151  f0 a9 bd
.LFB6154:
	inc 8,XSP                                            ; FB6154  ef 60
.LFB6156:
	calr SysExRx_CheckMidiErrors                                          ; FB6156  1e 06 16
	pushw de                                             ; FB6159  2a
	calr SysExRx_CheckReplyTimeout                                          ; FB615A  1e 28 16
	popw bc                                              ; FB615D  49
	jrl .LFB60A5                                         ; FB615E  78 44 ff
.LFB6161:
	popw ix                                              ; FB6161  4c
	popw de                                              ; FB6162  4a
	popw hl                                              ; FB6163  4b
	ret                                                  ; FB6164  0e
; SysExRx_AppendByte(b): store b at the receive buffer cursor (0x60FC80)+0x0A, 0xFF after it; count += 1, except 0xF0 sets the count to 1.
SysExRx_AppendByte:
	link XIZ,0xfff8                                      ; FB6165  ee 0c f8 ff
	pushw hl                                             ; FB6169  2b
	push XIX                                             ; FB616A  3c
	lda xix, (0x60fc80:24)                               ; FB616B  f2 80 fc 60 34
	ld XBC,(XIX)                                         ; FB6170  a4 21
	ld XWA,(XBC+0x0a)                                    ; FB6172  a9 0a 20
	ld (xiz-4), xwa                                      ; FB6175  be fc 60
	inc 1,XWA                                            ; FB6178  e8 61
	ld (xiz-8), xwa                                      ; FB617A  be f8 60
	ld XBC,(XIX)                                         ; FB617D  a4 21
	ld (XBC+0x0a),XWA                                    ; FB617F  b9 0a 60
	ld xbc, (xiz-4)                                      ; FB6182  ae fc 21
	ld A,(XIZ+0x08)                                      ; FB6185  8e 08 21
	ld (XBC),A                                           ; FB6188  b1 41
	ld XBC,(XIX)                                         ; FB618A  a4 21
	ld XWA,(XBC+0x0a)                                    ; FB618C  a9 0a 20
	ld (XWA),0xff                                        ; FB618F  b0 00 ff
	cp (XIZ+0x08),0xf0                                   ; FB6192  8e 08 3f f0
	jr nz, .LFB61A0                                      ; FB6196  6e 08
	ld XBC,(XIX)                                         ; FB6198  a4 21
	ldw	(xbc), 0x0001                                ; FB619A  b1 02 01 00
	jr .LFB61AC                                          ; FB619E  68 0c
.LFB61A0:
	ld XBC,(XIX)                                         ; FB61A0  a4 21
	ld WA,(XBC)                                          ; FB61A2  91 20
	ld HL,WA                                             ; FB61A4  d8 8b
	inc 1,HL                                             ; FB61A6  db 61
	ld XBC,(XIX)                                         ; FB61A8  a4 21
	ld (XBC),HL                                          ; FB61AA  b1 53
.LFB61AC:
	pop XIX                                              ; FB61AC  5c
	popw hl                                              ; FB61AD  4b
	unlk XIZ                                             ; FB61AE  ee 0d
	ret                                                  ; FB61B0  0e
; SysExBuf_ReadByte(buf): return the byte at the read cursor buf+2 and advance it; at the 0xFF sentinel return 0xFF without advancing.
SysExBuf_ReadByte:
	link XIZ,0x0000                                      ; FB61B1  ee 0c 00 00
	pushw hl                                             ; FB61B5  2b
	push XIX                                             ; FB61B6  3c
	ld h, 0xff:opc                                          ; FB61B7  26 ff
	ld XIX,(XIZ+0x08)                                    ; FB61B9  ae 08 24
	ld XBC,(XIX+0x02)                                    ; FB61BC  ac 02 21
	ld XIX,XBC                                           ; FB61BF  e9 8c
	ld A,(XBC)                                           ; FB61C1  81 21
	cp A,0xff                                            ; FB61C3  c9 cf ff
	jr z, .LFB61D6                                       ; FB61C6  66 0e
	inc 1,XBC                                            ; FB61C8  e9 61
	ld XWA,(XIZ+0x08)                                    ; FB61CA  ae 08 20
	ld (XWA+0x02),XBC                                    ; FB61CD  b8 02 61
	ld C,(XIX)                                           ; FB61D0  84 23
	ld A,C                                               ; FB61D2  cb 89
	jr .LFB61D8                                          ; FB61D4  68 02
.LFB61D6:
	ld A,H                                               ; FB61D6  ce 89
.LFB61D8:
	pop XIX                                              ; FB61D8  5c
	popw hl                                              ; FB61D9  4b
	unlk XIZ                                             ; FB61DA  ee 0d
	ret                                                  ; FB61DC  0e
	link XIZ,0xfffc                                      ; FB61DD  ee 0c fc ff
	pushw hl                                             ; FB61E1  2b
	push XIX                                             ; FB61E2  3c
	ld XIX,(XIZ+0x0c)                                    ; FB61E3  ae 0c 24
.LFB61E6:
	cpw	(xiz+16), 0x0000                             ; FB61E6  9e 10 3f 00 00
	jr z, .LFB620B                                       ; FB61EB  66 1e
	decm 0x01, (xiz+0x10)                                ; FB61ED  9e 10 69
	ld H,(XIX)                                           ; FB61F0  84 26
	ld XBC,(XIZ+0x08)                                    ; FB61F2  ae 08 21
	ld XWA,(XBC+0x0a)                                    ; FB61F5  a9 0a 20
	ld (xiz-4), xwa                                      ; FB61F8  be fc 60
	sub XIY,XIY                                          ; FB61FB  ed a5
	inc 1,XIY                                            ; FB61FD  ed 61
	add (XBC+0x0a),XIY                                   ; FB61FF  a9 0a 8d
	ld xbc, (xiz-4)                                      ; FB6202  ae fc 21
	ld (XBC),H                                           ; FB6205  b1 46
	inc 1,XIX                                            ; FB6207  ec 61
	jr .LFB61E6                                          ; FB6209  68 db
.LFB620B:
	ld XBC,(XIZ+0x08)                                    ; FB620B  ae 08 21
	ld XWA,(XBC+0x0a)                                    ; FB620E  a9 0a 20
	ld (XWA),0xff                                        ; FB6211  b0 00 ff
	pop XIX                                              ; FB6214  5c
	popw hl                                              ; FB6215  4b
	unlk XIZ                                             ; FB6216  ee 0d
	ret                                                  ; FB6218  0e
; U8Rec16_SetField(u8 *rec, index, value): rec[index] = value for index 0..15 (a compiled 16-arm switch
;   over U8Rec16_SetField_Cases); out of range does nothing.  The SysEx engine uses it on its parse
;   records ((0x60FCD8), (0x60FCDC); wsa1/notes/sysex-probes/README.md).
U8Rec16_SetField:
	link XIZ,0x0000                                      ; FB6219  ee 0c 00 00
	pushw hl                                             ; FB621D  2b
	push XIX                                             ; FB621E  3c
	ld XIX,(XIZ+0x08)                                    ; FB621F  ae 08 24
	ld H,(XIZ+0x0e)                                      ; FB6222  8e 0e 26
	ld BC,(XIZ+0x0c)                                     ; FB6225  9e 0c 21
	extz BC                                              ; FB6228  d9 12
	extz XBC                                             ; FB622A  e9 12
	cp BC,0x000f                                         ; FB622C  d9 cf 0f 00
	jrl ugt, .LFB62CE                                        ; FB6230  7b 9b 00
	sll bc, 0x02                                         ; FB6233  d9 ee 02
	add XBC,U8Rec16_SetField_Cases                             ; FB6236  e9 c8 40 62 fb 00
	ld XBC,(XBC)                                         ; FB623C  a1 21
	jp (xbc)                                             ; FB623E  b1 d8

; ---------------------------------------------------------------------
; U8Rec16_SetField_Cases -- 16 LE32 code addresses, an INLINE jump table
;
; Read by: ONE site, `add XBC,0x00FB6240 / ld XBC,(XBC) / jp (XBC)` at
;          0xFB6236-0xFB623E.
; ENTRY COUNT 16: `cp BC,0x000F / jrl ugt` at 0xFB622C admits 0..15.
;          ★ LAST-ENTRY TEST: 0xFB6240 + 16*4 = 0xFB6280 = entry 0's target, and
;          the sixteen targets run 0x00FB6280..0x00FB62CB stepping by exactly 5
;          bytes -- sixteen five-byte arms, which is what a `jp` plus a two-byte
;          operand costs.
; Evidence: the base is named by exactly one instruction, the `add Xrr,imm32`
;          quoted above, and the ENTRY COUNT is the ROM's own bound on the
;          index, not a guess at where the values stop looking like
;          addresses; the LAST-ENTRY TEST above is what makes the two agree.
; Unknown:  what the arms DO.  A jump table names its targets, not its
;          operations.
; ---------------------------------------------------------------------
U8Rec16_SetField_Cases:
	.long U8Rec16_SetField_Case0                                 ; FB6240  [  0]
	.long U8Rec16_SetField_Case1                                 ; FB6244  [  1]
	.long U8Rec16_SetField_Case2                                 ; FB6248  [  2]
	.long U8Rec16_SetField_Case3                                 ; FB624C  [  3]
	.long U8Rec16_SetField_Case4                                 ; FB6250  [  4]
	.long U8Rec16_SetField_Case5                                 ; FB6254  [  5]
	.long U8Rec16_SetField_Case6                                 ; FB6258  [  6]
	.long U8Rec16_SetField_Case7                                 ; FB625C  [  7]
	.long U8Rec16_SetField_Case8                                 ; FB6260  [  8]
	.long U8Rec16_SetField_Case9                                 ; FB6264  [  9]
	.long U8Rec16_SetField_Case10                                 ; FB6268  [ 10]
	.long U8Rec16_SetField_Case11                                 ; FB626C  [ 11]
	.long U8Rec16_SetField_Case12                                 ; FB6270  [ 12]
	.long U8Rec16_SetField_Case13                                 ; FB6274  [ 13]
	.long U8Rec16_SetField_Case14                                 ; FB6278  [ 14]
	.long U8Rec16_SetField_Case15                                 ; FB627C  [ 15]
U8Rec16_SetField_Case0:   ; entry: named by 1 `.long` operand, first at 0xFB6240
	ld (XIX),H                                           ; FB6280  b4 46
	jrl .LFB62CE                                         ; FB6282  78 49 00
U8Rec16_SetField_Case1:   ; entry: named by 1 `.long` operand, first at 0xFB6244
	ld (XIX+0x01),H                                      ; FB6285  bc 01 46
	jr .LFB62CE                                          ; FB6288  68 44
U8Rec16_SetField_Case2:   ; entry: named by 1 `.long` operand, first at 0xFB6248
	ld (XIX+0x02),H                                      ; FB628A  bc 02 46
	jr .LFB62CE                                          ; FB628D  68 3f
U8Rec16_SetField_Case3:   ; entry: named by 1 `.long` operand, first at 0xFB624C
	ld (XIX+0x03),H                                      ; FB628F  bc 03 46
	jr .LFB62CE                                          ; FB6292  68 3a
U8Rec16_SetField_Case4:   ; entry: named by 1 `.long` operand, first at 0xFB6250
	ld (XIX+0x04),H                                      ; FB6294  bc 04 46
	jr .LFB62CE                                          ; FB6297  68 35
U8Rec16_SetField_Case5:   ; entry: named by 1 `.long` operand, first at 0xFB6254
	ld (XIX+0x05),H                                      ; FB6299  bc 05 46
	jr .LFB62CE                                          ; FB629C  68 30
U8Rec16_SetField_Case6:   ; entry: named by 1 `.long` operand, first at 0xFB6258
	ld (XIX+0x06),H                                      ; FB629E  bc 06 46
	jr .LFB62CE                                          ; FB62A1  68 2b
U8Rec16_SetField_Case7:   ; entry: named by 1 `.long` operand, first at 0xFB625C
	ld (XIX+0x07),H                                      ; FB62A3  bc 07 46
	jr .LFB62CE                                          ; FB62A6  68 26
U8Rec16_SetField_Case8:   ; entry: named by 1 `.long` operand, first at 0xFB6260
	ld (XIX+0x08),H                                      ; FB62A8  bc 08 46
	jr .LFB62CE                                          ; FB62AB  68 21
U8Rec16_SetField_Case9:   ; entry: named by 1 `.long` operand, first at 0xFB6264
	ld (XIX+0x09),H                                      ; FB62AD  bc 09 46
	jr .LFB62CE                                          ; FB62B0  68 1c
U8Rec16_SetField_Case10:   ; entry: named by 1 `.long` operand, first at 0xFB6268
	ld (XIX+0x0a),H                                      ; FB62B2  bc 0a 46
	jr .LFB62CE                                          ; FB62B5  68 17
U8Rec16_SetField_Case11:   ; entry: named by 1 `.long` operand, first at 0xFB626C
	ld (XIX+0x0b),H                                      ; FB62B7  bc 0b 46
	jr .LFB62CE                                          ; FB62BA  68 12
U8Rec16_SetField_Case12:   ; entry: named by 1 `.long` operand, first at 0xFB6270
	ld (XIX+0x0c),H                                      ; FB62BC  bc 0c 46
	jr .LFB62CE                                          ; FB62BF  68 0d
U8Rec16_SetField_Case13:   ; entry: named by 1 `.long` operand, first at 0xFB6274
	ld (XIX+0x0d),H                                      ; FB62C1  bc 0d 46
	jr .LFB62CE                                          ; FB62C4  68 08
U8Rec16_SetField_Case14:   ; entry: named by 1 `.long` operand, first at 0xFB6278
	ld (XIX+0x0e),H                                      ; FB62C6  bc 0e 46
	jr .LFB62CE                                          ; FB62C9  68 03
U8Rec16_SetField_Case15:   ; entry: named by 1 `.long` operand, first at 0xFB627C
	ld (XIX+0x0f),H                                      ; FB62CB  bc 0f 46
.LFB62CE:
	pop XIX                                              ; FB62CE  5c
	popw hl                                              ; FB62CF  4b
	unlk XIZ                                             ; FB62D0  ee 0d
	ret                                                  ; FB62D2  0e
; U8Rec16_GetField(u8 *rec, index): A = rec[index] for index 0..15, the getter of U8Rec16_SetField.
U8Rec16_GetField:
	link XIZ,0x0000                                      ; FB62D3  ee 0c 00 00
	push XIX                                             ; FB62D7  3c
	ld XIX,(XIZ+0x08)                                    ; FB62D8  ae 08 24
	ld BC,(XIZ+0x0c)                                     ; FB62DB  9e 0c 21
	extz BC                                              ; FB62DE  d9 12
	extz XBC                                             ; FB62E0  e9 12
	cp BC,0x000f                                         ; FB62E2  d9 cf 0f 00
	jrl ugt, U8Rec16_GetField_OutOfRange                                        ; FB62E6  7b c0 00
	sll bc, 0x02                                         ; FB62E9  d9 ee 02
	add XBC,U8Rec16_GetField_Cases                             ; FB62EC  e9 c8 f6 62 fb 00
	ld XBC,(XBC)                                         ; FB62F2  a1 21
	jp (xbc)                                             ; FB62F4  b1 d8

; ---------------------------------------------------------------------
; U8Rec16_GetField_Cases -- 16 LE32 code addresses, an INLINE jump table
;
; Read by: ONE site, `add XBC,0x00FB62F6 / ld XBC,(XBC) / jp (XBC)` at
;          0xFB62EC-0xFB62F4.
; ENTRY COUNT 16: `cp BC,0x000F / jrl ugt` at 0xFB62E2.  ★ LAST-ENTRY TEST:
;          0xFB62F6 + 16*4 = 0xFB6336 = entry 0's target.
; Evidence: the base is named by exactly one instruction, the `add Xrr,imm32`
;          quoted above, and the ENTRY COUNT is the ROM's own bound on the
;          index, not a guess at where the values stop looking like
;          addresses; the LAST-ENTRY TEST above is what makes the two agree.
; Unknown:  what the arms DO.  A jump table names its targets, not its
;          operations.
; ---------------------------------------------------------------------
U8Rec16_GetField_Cases:
	.long U8Rec16_GetField_Case0                                 ; FB62F6  [  0]
	.long U8Rec16_GetField_Case1                                 ; FB62FA  [  1]
	.long U8Rec16_GetField_Case2                                 ; FB62FE  [  2]
	.long U8Rec16_GetField_Case3                                 ; FB6302  [  3]
	.long U8Rec16_GetField_Case4                                 ; FB6306  [  4]
	.long U8Rec16_GetField_Case5                                 ; FB630A  [  5]
	.long U8Rec16_GetField_Case6                                 ; FB630E  [  6]
	.long U8Rec16_GetField_Case7                                 ; FB6312  [  7]
	.long U8Rec16_GetField_Case8                                 ; FB6316  [  8]
	.long U8Rec16_GetField_Case9                                 ; FB631A  [  9]
	.long U8Rec16_GetField_Case10                                 ; FB631E  [ 10]
	.long U8Rec16_GetField_Case11                                 ; FB6322  [ 11]
	.long U8Rec16_GetField_Case12                                 ; FB6326  [ 12]
	.long U8Rec16_GetField_Case13                                 ; FB632A  [ 13]
	.long U8Rec16_GetField_Case14                                 ; FB632E  [ 14]
	.long U8Rec16_GetField_Case15                                 ; FB6332  [ 15]
U8Rec16_GetField_Case0:   ; entry: named by 1 `.long` operand, first at 0xFB62F6
	ld C,(XIX)                                           ; FB6336  84 23
	ld A,C                                               ; FB6338  cb 89
	jrl .LFB63AB                                         ; FB633A  78 6e 00
U8Rec16_GetField_Case1:   ; entry: named by 1 `.long` operand, first at 0xFB62FA
	ld C,(XIX+0x01)                                      ; FB633D  8c 01 23
	ld A,C                                               ; FB6340  cb 89
	jrl .LFB63AB                                         ; FB6342  78 66 00
U8Rec16_GetField_Case2:   ; entry: named by 1 `.long` operand, first at 0xFB62FE
	ld C,(XIX+0x02)                                      ; FB6345  8c 02 23
	ld A,C                                               ; FB6348  cb 89
	jrl .LFB63AB                                         ; FB634A  78 5e 00
U8Rec16_GetField_Case3:   ; entry: named by 1 `.long` operand, first at 0xFB6302
	ld C,(XIX+0x03)                                      ; FB634D  8c 03 23
	ld A,C                                               ; FB6350  cb 89
	jrl .LFB63AB                                         ; FB6352  78 56 00
U8Rec16_GetField_Case4:   ; entry: named by 1 `.long` operand, first at 0xFB6306
	ld C,(XIX+0x04)                                      ; FB6355  8c 04 23
	ld A,C                                               ; FB6358  cb 89
	jr .LFB63AB                                          ; FB635A  68 4f
U8Rec16_GetField_Case5:   ; entry: named by 1 `.long` operand, first at 0xFB630A
	ld C,(XIX+0x05)                                      ; FB635C  8c 05 23
	ld A,C                                               ; FB635F  cb 89
	jr .LFB63AB                                          ; FB6361  68 48
U8Rec16_GetField_Case6:   ; entry: named by 1 `.long` operand, first at 0xFB630E
	ld C,(XIX+0x06)                                      ; FB6363  8c 06 23
	ld A,C                                               ; FB6366  cb 89
	jr .LFB63AB                                          ; FB6368  68 41
U8Rec16_GetField_Case7:   ; entry: named by 1 `.long` operand, first at 0xFB6312
	ld C,(XIX+0x07)                                      ; FB636A  8c 07 23
	ld A,C                                               ; FB636D  cb 89
	jr .LFB63AB                                          ; FB636F  68 3a
U8Rec16_GetField_Case8:   ; entry: named by 1 `.long` operand, first at 0xFB6316
	ld C,(XIX+0x08)                                      ; FB6371  8c 08 23
	ld A,C                                               ; FB6374  cb 89
	jr .LFB63AB                                          ; FB6376  68 33
U8Rec16_GetField_Case9:   ; entry: named by 1 `.long` operand, first at 0xFB631A
	ld C,(XIX+0x09)                                      ; FB6378  8c 09 23
	ld A,C                                               ; FB637B  cb 89
	jr .LFB63AB                                          ; FB637D  68 2c
U8Rec16_GetField_Case10:   ; entry: named by 1 `.long` operand, first at 0xFB631E
	ld C,(XIX+0x0a)                                      ; FB637F  8c 0a 23
	ld A,C                                               ; FB6382  cb 89
	jr .LFB63AB                                          ; FB6384  68 25
U8Rec16_GetField_Case11:   ; entry: named by 1 `.long` operand, first at 0xFB6322
	ld C,(XIX+0x0b)                                      ; FB6386  8c 0b 23
	ld A,C                                               ; FB6389  cb 89
	jr .LFB63AB                                          ; FB638B  68 1e
U8Rec16_GetField_Case12:   ; entry: named by 1 `.long` operand, first at 0xFB6326
	ld C,(XIX+0x0c)                                      ; FB638D  8c 0c 23
	ld A,C                                               ; FB6390  cb 89
	jr .LFB63AB                                          ; FB6392  68 17
U8Rec16_GetField_Case13:   ; entry: named by 1 `.long` operand, first at 0xFB632A
	ld C,(XIX+0x0d)                                      ; FB6394  8c 0d 23
	ld A,C                                               ; FB6397  cb 89
	jr .LFB63AB                                          ; FB6399  68 10
U8Rec16_GetField_Case14:   ; entry: named by 1 `.long` operand, first at 0xFB632E
	ld C,(XIX+0x0e)                                      ; FB639B  8c 0e 23
	ld A,C                                               ; FB639E  cb 89
	jr .LFB63AB                                          ; FB63A0  68 09
U8Rec16_GetField_Case15:   ; entry: named by 1 `.long` operand, first at 0xFB6332
	ld C,(XIX+0x0f)                                      ; FB63A2  8c 0f 23
	ld A,C                                               ; FB63A5  cb 89
	jr .LFB63AB                                          ; FB63A7  68 02
U8Rec16_GetField_OutOfRange:
	sub A,A                                              ; FB63A9  c9 a1
.LFB63AB:
	pop XIX                                              ; FB63AB  5c
	unlk XIZ                                             ; FB63AC  ee 0d
	ret                                                  ; FB63AE  0e
; SysExRx_ParseMessage: when the status is 0, SysExRx_MatchTrie, _CheckCommandClass, _CheckAddress, _CheckBodyLength, _VerifyChecksum.
SysExRx_ParseMessage:
	pushw 0x04                                           ; FB63AF  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB63B2  e2 d8 fc 60 21
	push XBC                                             ; FB63B7  39
	calr U8Rec16_GetField                                          ; FB63B8  1e 18 ff
	inc 6,XSP                                            ; FB63BB  ef 66
	cp a, 0x00:i3                                          ; FB63BD  c9 d8
	jr nz, .LFB63D0                                      ; FB63BF  6e 0f
	calr SysExRx_MatchTrie                                      ; FB63C1  1e 0d 00
	calr SysExRx_CheckCommandClass                                      ; FB63C4  1e c0 07
	calr SysExRx_CheckAddress                                      ; FB63C7  1e 2a 08
	calr SysExRx_CheckBodyLength                                      ; FB63CA  1e 2f 09
	calr SysExRx_VerifyChecksum                                      ; FB63CD  1e ed 09
.LFB63D0:
	ret                                                  ; FB63D0  0e
; SysExRx_MatchTrie: skip F0 and the ID byte, walk the trie rooted at prom_b 0xF5115B; matched bytes go to record fields 5.., the command to field 0;
;   a miss stores error 0x07/0x08/0x09/0x0A/0x10 in field 4 (sysex-probes/sysex_grammar_dump.py).
SysExRx_MatchTrie:
	link XIZ,0xfff6                                      ; FB63D1  ee 0c f6 ff
	pushw hl                                             ; FB63D5  2b
	pushw de                                             ; FB63D6  2a
	push XIX                                             ; FB63D7  3c
	ld xbc, (0x60fc80:24)                               ; FB63D8  e2 80 fc 60 21
	sub XWA,XWA                                          ; FB63DD  e8 a0
	inc 2,XWA                                            ; FB63DF  e8 62
	add (XBC+0x02),XWA                                   ; FB63E1  a9 02 88
	ld xbc, (0x60fc80:24)                               ; FB63E4  e2 80 fc 60 21
	push XBC                                             ; FB63E9  39
	calr SysExBuf_ReadByte                                          ; FB63EA  1e c4 fd
	ld H,A                                               ; FB63ED  c9 8e
	ldw de, 0x00                                         ; FB63EF  32 00 00
	ld l, 0x0f:opc                                          ; FB63F2  27 0f
	pop XIY                                              ; FB63F4  5d
.LFB63F5:
	ld BC,DE                                             ; FB63F5  da 89
	extz XBC                                             ; FB63F7  e9 12
	ld (xiz-6), xbc                                      ; FB63F9  be fa 61
	add	xbc, SysExDecodeTree_Root                    ; FB63FC  e9 c8 5b 11 f5 00
	ld A,(XBC)                                           ; FB6402  81 21
	ld (xiz-1), a                                        ; FB6404  be ff 41
	cp A,0xff                                            ; FB6407  c9 cf ff
	jr nz, .LFB6412                                      ; FB640A  6e 06
	pushw 0x07                                           ; FB640C  0b 07 00
	jrl .LFB6ADA                                         ; FB640F  78 c8 06
.LFB6412:
	ld c, (xiz-1)                                        ; FB6412  8e ff 23
	cp C,H                                               ; FB6415  ce f3
	jrl nz, .LFB649A                                     ; FB6417  7e 80 00
	ld C,H                                               ; FB641A  ce 8b
	extz BC                                              ; FB641C  d9 12
	pushw bc                                             ; FB641E  29
	pushw 0x05                                           ; FB641F  0b 05 00
	ld xbc, (0x60fcd8:24)                               ; FB6422  e2 d8 fc 60 21
	push XBC                                             ; FB6427  39
	calr U8Rec16_SetField                                          ; FB6428  1e ee fd
	ld xix, (xiz-6)                                      ; FB642B  ae fa 24
	ld XBC,XIX                                           ; FB642E  ec 89
	inc 1,XBC                                            ; FB6430  e9 61
	add	xbc, SysExDecodeTree_Root                    ; FB6432  e9 c8 5b 11 f5 00
	ld H,(XBC)                                           ; FB6438  81 26
	inc 8,XSP                                            ; FB643A  ef 60
	cp h, 0x00:i3                                          ; FB643C  ce d8
	jr z, .LFB648A                                       ; FB643E  66 4a
	ld C,H                                               ; FB6440  ce 8b
	extz BC                                              ; FB6442  d9 12
	pushw bc                                             ; FB6444  29
	pushw 0x00                                           ; FB6445  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6448  e2 d8 fc 60 21
	push XBC                                             ; FB644D  39
	calr U8Rec16_SetField                                          ; FB644E  1e c8 fd
	ld xix, (xiz-6)                                      ; FB6451  ae fa 24
	inc 2,XIX                                            ; FB6454  ec 62
	lda	xbc, (SysExDecodeTree_Root:24)               ; FB6456  f2 5b 11 f5 31
	add XBC,XIX                                          ; FB645B  ec 81
	ld XWA,(XBC)                                         ; FB645D  a1 20
	ld B,(XWA)                                           ; FB645F  80 22
	ld C,B                                               ; FB6461  ca 8b
	extz BC                                              ; FB6463  d9 12
	pushw bc                                             ; FB6465  29
	pushw 0x01                                           ; FB6466  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB6469  e2 d8 fc 60 21
	push XBC                                             ; FB646E  39
	calr U8Rec16_SetField                                          ; FB646F  1e a7 fd
	lda	xbc, (SysExDecodeTree_Root:24)               ; FB6472  f2 5b 11 f5 31
	add XBC,XIX                                          ; FB6477  ec 81
	ld XWA,(XBC)                                         ; FB6479  a1 20
	ld B,(XWA+0x01)                                      ; FB647B  88 01 22
	ld C,B                                               ; FB647E  ca 8b
	extz BC                                              ; FB6480  d9 12
	inc 8,XSP                                            ; FB6482  ef 60
	inc 8,XSP                                            ; FB6484  ef 60
	pushw bc                                             ; FB6486  29
	jrl .LFB6B6C                                         ; FB6487  78 e2 06
.LFB648A:
	ld XBC,XIX                                           ; FB648A  ec 89
	inc 2,XBC                                            ; FB648C  e9 62
	add	xbc, SysExDecodeTree_Root                    ; FB648E  e9 c8 5b 11 f5 00
	ld XBC,(XBC)                                         ; FB6494  a1 21
	ld XIX,XBC                                           ; FB6496  e9 8c
	jr .LFB64A3                                          ; FB6498  68 09
.LFB649A:
	inc 6,DE                                             ; FB649A  da 66
	dec 1,L                                              ; FB649C  cf 69
	cp l, 0x00:i3                                          ; FB649E  cf d8
	jrl nz, .LFB63F5                                     ; FB64A0  7e 52 ff
.LFB64A3:
	ld xbc, (0x60fc80:24)                               ; FB64A3  e2 80 fc 60 21
	push XBC                                             ; FB64A8  39
	calr SysExBuf_ReadByte                                          ; FB64A9  1e 05 fd
	ld H,A                                               ; FB64AC  c9 8e
	ldw de, 0x00                                         ; FB64AE  32 00 00
	pop XIY                                              ; FB64B1  5d
.LFB64B2:
	ld BC,DE                                             ; FB64B2  da 89
	extz XBC                                             ; FB64B4  e9 12
	add XBC,XIX                                          ; FB64B6  ec 81
	ld L,(XBC)                                           ; FB64B8  81 27
	cp L,0xff                                            ; FB64BA  cf cf ff
	jr nz, .LFB64C5                                      ; FB64BD  6e 06
	pushw 0x08                                           ; FB64BF  0b 08 00
	jrl .LFB6ADA                                         ; FB64C2  78 15 06
.LFB64C5:
	cp H,L                                               ; FB64C5  cf f6
	jr z, .LFB64CF                                       ; FB64C7  66 06
	cp L,0xfe                                            ; FB64C9  cf cf fe
	jrl nz, .LFB6561                                     ; FB64CC  7e 92 00
.LFB64CF:
	ld C,H                                               ; FB64CF  ce 8b
	extz BC                                              ; FB64D1  d9 12
	pushw bc                                             ; FB64D3  29
	pushw 0x06                                           ; FB64D4  0b 06 00
	ld xbc, (0x60fcd8:24)                               ; FB64D7  e2 d8 fc 60 21
	push XBC                                             ; FB64DC  39
	calr U8Rec16_SetField                                          ; FB64DD  1e 39 fd
	ld BC,DE                                             ; FB64E0  da 89
	extz XBC                                             ; FB64E2  e9 12
	ld (xiz-4), xbc                                      ; FB64E4  be fc 61
	inc 1,XBC                                            ; FB64E7  e9 61
	ld (xiz-10), xbc                                     ; FB64E9  be f6 61
	add XBC,XIX                                          ; FB64EC  ec 81
	ld A,(XBC)                                           ; FB64EE  81 21
	extz WA                                              ; FB64F0  d8 12
	pushw wa                                             ; FB64F2  28
	pushw 0x00                                           ; FB64F3  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB64F6  e2 d8 fc 60 21
	push XBC                                             ; FB64FB  39
	calr U8Rec16_SetField                                          ; FB64FC  1e 1a fd
	ld XBC,XIX                                           ; FB64FF  ec 89
	add	xbc, (xiz-10)                                ; FB6501  ae f6 81
	ld H,(XBC)                                           ; FB6504  81 26
	inc 8,XSP                                            ; FB6506  ef 60
	inc 8,XSP                                            ; FB6508  ef 60
	cp h, 0x00:i3                                          ; FB650A  ce d8
	jr z, .LFB6554                                       ; FB650C  66 46
	ld C,H                                               ; FB650E  ce 8b
	extz BC                                              ; FB6510  d9 12
	pushw bc                                             ; FB6512  29
	pushw 0x00                                           ; FB6513  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6516  e2 d8 fc 60 21
	push XBC                                             ; FB651B  39
	calr U8Rec16_SetField                                          ; FB651C  1e fa fc
	ld xbc, (xiz-4)                                      ; FB651F  ae fc 21
	inc 2,XBC                                            ; FB6522  e9 62
	ld (xiz-10), xbc                                     ; FB6524  be f6 61
	add XBC,XIX                                          ; FB6527  ec 81
	ld XWA,(XBC)                                         ; FB6529  a1 20
	ld B,(XWA)                                           ; FB652B  80 22
	ld C,B                                               ; FB652D  ca 8b
	extz BC                                              ; FB652F  d9 12
	pushw bc                                             ; FB6531  29
	pushw 0x01                                           ; FB6532  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB6535  e2 d8 fc 60 21
	push XBC                                             ; FB653A  39
	calr U8Rec16_SetField                                          ; FB653B  1e db fc
	ld XBC,XIX                                           ; FB653E  ec 89
	add	xbc, (xiz-10)                                ; FB6540  ae f6 81
	ld XWA,(XBC)                                         ; FB6543  a1 20
	ld B,(XWA+0x01)                                      ; FB6545  88 01 22
	ld C,B                                               ; FB6548  ca 8b
	extz BC                                              ; FB654A  d9 12
	inc 8,XSP                                            ; FB654C  ef 60
	inc 8,XSP                                            ; FB654E  ef 60
	pushw bc                                             ; FB6550  29
	jrl .LFB6B6C                                         ; FB6551  78 18 06
.LFB6554:
	ld xbc, (xiz-4)                                      ; FB6554  ae fc 21
	inc 2,XBC                                            ; FB6557  e9 62
	add XBC,XIX                                          ; FB6559  ec 81
	ld XWA,(XBC)                                         ; FB655B  a1 20
	ld XIX,XWA                                           ; FB655D  e8 8c
	jr .LFB6566                                          ; FB655F  68 05
.LFB6561:
	inc 6,DE                                             ; FB6561  da 66
	jrl .LFB64B2                                         ; FB6563  78 4c ff
.LFB6566:
	ld xbc, (0x60fc80:24)                               ; FB6566  e2 80 fc 60 21
	push XBC                                             ; FB656B  39
	calr SysExBuf_ReadByte                                          ; FB656C  1e 42 fc
	ld H,A                                               ; FB656F  c9 8e
	ldw de, 0x00                                         ; FB6571  32 00 00
	pop XIY                                              ; FB6574  5d
.LFB6575:
	ld BC,DE                                             ; FB6575  da 89
	extz XBC                                             ; FB6577  e9 12
	add XBC,XIX                                          ; FB6579  ec 81
	ld L,(XBC)                                           ; FB657B  81 27
	cp L,0xff                                            ; FB657D  cf cf ff
	jr nz, .LFB6588                                      ; FB6580  6e 06
	pushw 0x09                                           ; FB6582  0b 09 00
	jrl .LFB6ADA                                         ; FB6585  78 52 05
.LFB6588:
	cp H,L                                               ; FB6588  cf f6
	jr z, .LFB6592                                       ; FB658A  66 06
	cp L,0xfe                                            ; FB658C  cf cf fe
	jrl nz, .LFB6624                                     ; FB658F  7e 92 00
.LFB6592:
	ld C,H                                               ; FB6592  ce 8b
	extz BC                                              ; FB6594  d9 12
	pushw bc                                             ; FB6596  29
	pushw 0x07                                           ; FB6597  0b 07 00
	ld xbc, (0x60fcd8:24)                               ; FB659A  e2 d8 fc 60 21
	push XBC                                             ; FB659F  39
	calr U8Rec16_SetField                                          ; FB65A0  1e 76 fc
	ld BC,DE                                             ; FB65A3  da 89
	extz XBC                                             ; FB65A5  e9 12
	ld (xiz-4), xbc                                      ; FB65A7  be fc 61
	inc 1,XBC                                            ; FB65AA  e9 61
	ld (xiz-10), xbc                                     ; FB65AC  be f6 61
	add XBC,XIX                                          ; FB65AF  ec 81
	ld A,(XBC)                                           ; FB65B1  81 21
	extz WA                                              ; FB65B3  d8 12
	pushw wa                                             ; FB65B5  28
	pushw 0x00                                           ; FB65B6  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB65B9  e2 d8 fc 60 21
	push XBC                                             ; FB65BE  39
	calr U8Rec16_SetField                                          ; FB65BF  1e 57 fc
	ld XBC,XIX                                           ; FB65C2  ec 89
	add	xbc, (xiz-10)                                ; FB65C4  ae f6 81
	ld H,(XBC)                                           ; FB65C7  81 26
	inc 8,XSP                                            ; FB65C9  ef 60
	inc 8,XSP                                            ; FB65CB  ef 60
	cp h, 0x00:i3                                          ; FB65CD  ce d8
	jr z, .LFB6617                                       ; FB65CF  66 46
	ld C,H                                               ; FB65D1  ce 8b
	extz BC                                              ; FB65D3  d9 12
	pushw bc                                             ; FB65D5  29
	pushw 0x00                                           ; FB65D6  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB65D9  e2 d8 fc 60 21
	push XBC                                             ; FB65DE  39
	calr U8Rec16_SetField                                          ; FB65DF  1e 37 fc
	ld xbc, (xiz-4)                                      ; FB65E2  ae fc 21
	inc 2,XBC                                            ; FB65E5  e9 62
	ld (xiz-10), xbc                                     ; FB65E7  be f6 61
	add XBC,XIX                                          ; FB65EA  ec 81
	ld XWA,(XBC)                                         ; FB65EC  a1 20
	ld B,(XWA)                                           ; FB65EE  80 22
	ld C,B                                               ; FB65F0  ca 8b
	extz BC                                              ; FB65F2  d9 12
	pushw bc                                             ; FB65F4  29
	pushw 0x01                                           ; FB65F5  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB65F8  e2 d8 fc 60 21
	push XBC                                             ; FB65FD  39
	calr U8Rec16_SetField                                          ; FB65FE  1e 18 fc
	ld XBC,XIX                                           ; FB6601  ec 89
	add	xbc, (xiz-10)                                ; FB6603  ae f6 81
	ld XWA,(XBC)                                         ; FB6606  a1 20
	ld B,(XWA+0x01)                                      ; FB6608  88 01 22
	ld C,B                                               ; FB660B  ca 8b
	extz BC                                              ; FB660D  d9 12
	inc 8,XSP                                            ; FB660F  ef 60
	inc 8,XSP                                            ; FB6611  ef 60
	pushw bc                                             ; FB6613  29
	jrl .LFB6B6C                                         ; FB6614  78 55 05
.LFB6617:
	ld xbc, (xiz-4)                                      ; FB6617  ae fc 21
	inc 2,XBC                                            ; FB661A  e9 62
	add XBC,XIX                                          ; FB661C  ec 81
	ld XWA,(XBC)                                         ; FB661E  a1 20
	ld XIX,XWA                                           ; FB6620  e8 8c
	jr .LFB6629                                          ; FB6622  68 05
.LFB6624:
	inc 6,DE                                             ; FB6624  da 66
	jrl .LFB6575                                         ; FB6626  78 4c ff
.LFB6629:
	ld xbc, (0x60fc80:24)                               ; FB6629  e2 80 fc 60 21
	push XBC                                             ; FB662E  39
	calr SysExBuf_ReadByte                                          ; FB662F  1e 7f fb
	ld H,A                                               ; FB6632  c9 8e
	ldw de, 0x00                                         ; FB6634  32 00 00
	pop XIY                                              ; FB6637  5d
.LFB6638:
	ld BC,DE                                             ; FB6638  da 89
	extz XBC                                             ; FB663A  e9 12
	add XBC,XIX                                          ; FB663C  ec 81
	ld L,(XBC)                                           ; FB663E  81 27
	cp L,0xff                                            ; FB6640  cf cf ff
	jr nz, .LFB664B                                      ; FB6643  6e 06
	pushw 0x0a                                           ; FB6645  0b 0a 00
	jrl .LFB6ADA                                         ; FB6648  78 8f 04
.LFB664B:
	cp H,L                                               ; FB664B  cf f6
	jr z, .LFB6655                                       ; FB664D  66 06
	cp L,0xfe                                            ; FB664F  cf cf fe
	jrl nz, .LFB66E7                                     ; FB6652  7e 92 00
.LFB6655:
	ld C,H                                               ; FB6655  ce 8b
	extz BC                                              ; FB6657  d9 12
	pushw bc                                             ; FB6659  29
	pushw 0x08                                           ; FB665A  0b 08 00
	ld xbc, (0x60fcd8:24)                               ; FB665D  e2 d8 fc 60 21
	push XBC                                             ; FB6662  39
	calr U8Rec16_SetField                                          ; FB6663  1e b3 fb
	ld BC,DE                                             ; FB6666  da 89
	extz XBC                                             ; FB6668  e9 12
	ld (xiz-4), xbc                                      ; FB666A  be fc 61
	inc 1,XBC                                            ; FB666D  e9 61
	ld (xiz-10), xbc                                     ; FB666F  be f6 61
	add XBC,XIX                                          ; FB6672  ec 81
	ld A,(XBC)                                           ; FB6674  81 21
	extz WA                                              ; FB6676  d8 12
	pushw wa                                             ; FB6678  28
	pushw 0x00                                           ; FB6679  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB667C  e2 d8 fc 60 21
	push XBC                                             ; FB6681  39
	calr U8Rec16_SetField                                          ; FB6682  1e 94 fb
	ld XBC,XIX                                           ; FB6685  ec 89
	add	xbc, (xiz-10)                                ; FB6687  ae f6 81
	ld H,(XBC)                                           ; FB668A  81 26
	inc 8,XSP                                            ; FB668C  ef 60
	inc 8,XSP                                            ; FB668E  ef 60
	cp h, 0x00:i3                                          ; FB6690  ce d8
	jr z, .LFB66DA                                       ; FB6692  66 46
	ld C,H                                               ; FB6694  ce 8b
	extz BC                                              ; FB6696  d9 12
	pushw bc                                             ; FB6698  29
	pushw 0x00                                           ; FB6699  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB669C  e2 d8 fc 60 21
	push XBC                                             ; FB66A1  39
	calr U8Rec16_SetField                                          ; FB66A2  1e 74 fb
	ld xbc, (xiz-4)                                      ; FB66A5  ae fc 21
	inc 2,XBC                                            ; FB66A8  e9 62
	ld (xiz-10), xbc                                     ; FB66AA  be f6 61
	add XBC,XIX                                          ; FB66AD  ec 81
	ld XWA,(XBC)                                         ; FB66AF  a1 20
	ld B,(XWA)                                           ; FB66B1  80 22
	ld C,B                                               ; FB66B3  ca 8b
	extz BC                                              ; FB66B5  d9 12
	pushw bc                                             ; FB66B7  29
	pushw 0x01                                           ; FB66B8  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB66BB  e2 d8 fc 60 21
	push XBC                                             ; FB66C0  39
	calr U8Rec16_SetField                                          ; FB66C1  1e 55 fb
	ld XBC,XIX                                           ; FB66C4  ec 89
	add	xbc, (xiz-10)                                ; FB66C6  ae f6 81
	ld XWA,(XBC)                                         ; FB66C9  a1 20
	ld B,(XWA+0x01)                                      ; FB66CB  88 01 22
	ld C,B                                               ; FB66CE  ca 8b
	extz BC                                              ; FB66D0  d9 12
	inc 8,XSP                                            ; FB66D2  ef 60
	inc 8,XSP                                            ; FB66D4  ef 60
	pushw bc                                             ; FB66D6  29
	jrl .LFB6B6C                                         ; FB66D7  78 92 04
.LFB66DA:
	ld xbc, (xiz-4)                                      ; FB66DA  ae fc 21
	inc 2,XBC                                            ; FB66DD  e9 62
	add XBC,XIX                                          ; FB66DF  ec 81
	ld XWA,(XBC)                                         ; FB66E1  a1 20
	ld XIX,XWA                                           ; FB66E3  e8 8c
	jr .LFB66EC                                          ; FB66E5  68 05
.LFB66E7:
	inc 6,DE                                             ; FB66E7  da 66
	jrl .LFB6638                                         ; FB66E9  78 4c ff
.LFB66EC:
	ld xbc, (0x60fc80:24)                               ; FB66EC  e2 80 fc 60 21
	push XBC                                             ; FB66F1  39
	calr SysExBuf_ReadByte                                          ; FB66F2  1e bc fa
	ld H,A                                               ; FB66F5  c9 8e
	ldw de, 0x00                                         ; FB66F7  32 00 00
	pop XIY                                              ; FB66FA  5d
.LFB66FB:
	ld BC,DE                                             ; FB66FB  da 89
	extz XBC                                             ; FB66FD  e9 12
	add XBC,XIX                                          ; FB66FF  ec 81
	ld L,(XBC)                                           ; FB6701  81 27
	cp L,0xff                                            ; FB6703  cf cf ff
	jr nz, .LFB670E                                      ; FB6706  6e 06
	pushw 0x0b                                           ; FB6708  0b 0b 00
	jrl .LFB6ADA                                         ; FB670B  78 cc 03
.LFB670E:
	cp H,L                                               ; FB670E  cf f6
	jr z, .LFB6718                                       ; FB6710  66 06
	cp L,0xfe                                            ; FB6712  cf cf fe
	jrl nz, .LFB67AA                                     ; FB6715  7e 92 00
.LFB6718:
	ld C,H                                               ; FB6718  ce 8b
	extz BC                                              ; FB671A  d9 12
	pushw bc                                             ; FB671C  29
	pushw 0x09                                           ; FB671D  0b 09 00
	ld xbc, (0x60fcd8:24)                               ; FB6720  e2 d8 fc 60 21
	push XBC                                             ; FB6725  39
	calr U8Rec16_SetField                                          ; FB6726  1e f0 fa
	ld BC,DE                                             ; FB6729  da 89
	extz XBC                                             ; FB672B  e9 12
	ld (xiz-4), xbc                                      ; FB672D  be fc 61
	inc 1,XBC                                            ; FB6730  e9 61
	ld (xiz-10), xbc                                     ; FB6732  be f6 61
	add XBC,XIX                                          ; FB6735  ec 81
	ld A,(XBC)                                           ; FB6737  81 21
	extz WA                                              ; FB6739  d8 12
	pushw wa                                             ; FB673B  28
	pushw 0x00                                           ; FB673C  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB673F  e2 d8 fc 60 21
	push XBC                                             ; FB6744  39
	calr U8Rec16_SetField                                          ; FB6745  1e d1 fa
	ld XBC,XIX                                           ; FB6748  ec 89
	add	xbc, (xiz-10)                                ; FB674A  ae f6 81
	ld H,(XBC)                                           ; FB674D  81 26
	inc 8,XSP                                            ; FB674F  ef 60
	inc 8,XSP                                            ; FB6751  ef 60
	cp h, 0x00:i3                                          ; FB6753  ce d8
	jr z, .LFB679D                                       ; FB6755  66 46
	ld C,H                                               ; FB6757  ce 8b
	extz BC                                              ; FB6759  d9 12
	pushw bc                                             ; FB675B  29
	pushw 0x00                                           ; FB675C  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB675F  e2 d8 fc 60 21
	push XBC                                             ; FB6764  39
	calr U8Rec16_SetField                                          ; FB6765  1e b1 fa
	ld xbc, (xiz-4)                                      ; FB6768  ae fc 21
	inc 2,XBC                                            ; FB676B  e9 62
	ld (xiz-10), xbc                                     ; FB676D  be f6 61
	add XBC,XIX                                          ; FB6770  ec 81
	ld XWA,(XBC)                                         ; FB6772  a1 20
	ld B,(XWA)                                           ; FB6774  80 22
	ld C,B                                               ; FB6776  ca 8b
	extz BC                                              ; FB6778  d9 12
	pushw bc                                             ; FB677A  29
	pushw 0x01                                           ; FB677B  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB677E  e2 d8 fc 60 21
	push XBC                                             ; FB6783  39
	calr U8Rec16_SetField                                          ; FB6784  1e 92 fa
	ld XBC,XIX                                           ; FB6787  ec 89
	add	xbc, (xiz-10)                                ; FB6789  ae f6 81
	ld XWA,(XBC)                                         ; FB678C  a1 20
	ld B,(XWA+0x01)                                      ; FB678E  88 01 22
	ld C,B                                               ; FB6791  ca 8b
	extz BC                                              ; FB6793  d9 12
	inc 8,XSP                                            ; FB6795  ef 60
	inc 8,XSP                                            ; FB6797  ef 60
	pushw bc                                             ; FB6799  29
	jrl .LFB6B6C                                         ; FB679A  78 cf 03
.LFB679D:
	ld xbc, (xiz-4)                                      ; FB679D  ae fc 21
	inc 2,XBC                                            ; FB67A0  e9 62
	add XBC,XIX                                          ; FB67A2  ec 81
	ld XWA,(XBC)                                         ; FB67A4  a1 20
	ld XIX,XWA                                           ; FB67A6  e8 8c
	jr .LFB67AF                                          ; FB67A8  68 05
.LFB67AA:
	inc 6,DE                                             ; FB67AA  da 66
	jrl .LFB66FB                                         ; FB67AC  78 4c ff
.LFB67AF:
	ld xbc, (0x60fc80:24)                               ; FB67AF  e2 80 fc 60 21
	push XBC                                             ; FB67B4  39
	calr SysExBuf_ReadByte                                          ; FB67B5  1e f9 f9
	ld H,A                                               ; FB67B8  c9 8e
	ldw de, 0x00                                         ; FB67BA  32 00 00
	pop XIY                                              ; FB67BD  5d
.LFB67BE:
	ld BC,DE                                             ; FB67BE  da 89
	extz XBC                                             ; FB67C0  e9 12
	add XBC,XIX                                          ; FB67C2  ec 81
	ld L,(XBC)                                           ; FB67C4  81 27
	cp L,0xff                                            ; FB67C6  cf cf ff
	jr nz, .LFB67D1                                      ; FB67C9  6e 06
	pushw 0x0c                                           ; FB67CB  0b 0c 00
	jrl .LFB6ADA                                         ; FB67CE  78 09 03
.LFB67D1:
	cp H,L                                               ; FB67D1  cf f6
	jr z, .LFB67DB                                       ; FB67D3  66 06
	cp L,0xfe                                            ; FB67D5  cf cf fe
	jrl nz, .LFB686D                                     ; FB67D8  7e 92 00
.LFB67DB:
	ld C,H                                               ; FB67DB  ce 8b
	extz BC                                              ; FB67DD  d9 12
	pushw bc                                             ; FB67DF  29
	pushw 0x0a                                           ; FB67E0  0b 0a 00
	ld xbc, (0x60fcd8:24)                               ; FB67E3  e2 d8 fc 60 21
	push XBC                                             ; FB67E8  39
	calr U8Rec16_SetField                                          ; FB67E9  1e 2d fa
	ld BC,DE                                             ; FB67EC  da 89
	extz XBC                                             ; FB67EE  e9 12
	ld (xiz-4), xbc                                      ; FB67F0  be fc 61
	inc 1,XBC                                            ; FB67F3  e9 61
	ld (xiz-10), xbc                                     ; FB67F5  be f6 61
	add XBC,XIX                                          ; FB67F8  ec 81
	ld A,(XBC)                                           ; FB67FA  81 21
	extz WA                                              ; FB67FC  d8 12
	pushw wa                                             ; FB67FE  28
	pushw 0x00                                           ; FB67FF  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6802  e2 d8 fc 60 21
	push XBC                                             ; FB6807  39
	calr U8Rec16_SetField                                          ; FB6808  1e 0e fa
	ld XBC,XIX                                           ; FB680B  ec 89
	add	xbc, (xiz-10)                                ; FB680D  ae f6 81
	ld H,(XBC)                                           ; FB6810  81 26
	inc 8,XSP                                            ; FB6812  ef 60
	inc 8,XSP                                            ; FB6814  ef 60
	cp h, 0x00:i3                                          ; FB6816  ce d8
	jr z, .LFB6860                                       ; FB6818  66 46
	ld C,H                                               ; FB681A  ce 8b
	extz BC                                              ; FB681C  d9 12
	pushw bc                                             ; FB681E  29
	pushw 0x00                                           ; FB681F  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6822  e2 d8 fc 60 21
	push XBC                                             ; FB6827  39
	calr U8Rec16_SetField                                          ; FB6828  1e ee f9
	ld xbc, (xiz-4)                                      ; FB682B  ae fc 21
	inc 2,XBC                                            ; FB682E  e9 62
	ld (xiz-10), xbc                                     ; FB6830  be f6 61
	add XBC,XIX                                          ; FB6833  ec 81
	ld XWA,(XBC)                                         ; FB6835  a1 20
	ld B,(XWA)                                           ; FB6837  80 22
	ld C,B                                               ; FB6839  ca 8b
	extz BC                                              ; FB683B  d9 12
	pushw bc                                             ; FB683D  29
	pushw 0x01                                           ; FB683E  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB6841  e2 d8 fc 60 21
	push XBC                                             ; FB6846  39
	calr U8Rec16_SetField                                          ; FB6847  1e cf f9
	ld XBC,XIX                                           ; FB684A  ec 89
	add	xbc, (xiz-10)                                ; FB684C  ae f6 81
	ld XWA,(XBC)                                         ; FB684F  a1 20
	ld B,(XWA+0x01)                                      ; FB6851  88 01 22
	ld C,B                                               ; FB6854  ca 8b
	extz BC                                              ; FB6856  d9 12
	inc 8,XSP                                            ; FB6858  ef 60
	inc 8,XSP                                            ; FB685A  ef 60
	pushw bc                                             ; FB685C  29
	jrl .LFB6B6C                                         ; FB685D  78 0c 03
.LFB6860:
	ld xbc, (xiz-4)                                      ; FB6860  ae fc 21
	inc 2,XBC                                            ; FB6863  e9 62
	add XBC,XIX                                          ; FB6865  ec 81
	ld XWA,(XBC)                                         ; FB6867  a1 20
	ld XIX,XWA                                           ; FB6869  e8 8c
	jr .LFB6872                                          ; FB686B  68 05
.LFB686D:
	inc 6,DE                                             ; FB686D  da 66
	jrl .LFB67BE                                         ; FB686F  78 4c ff
.LFB6872:
	ld xbc, (0x60fc80:24)                               ; FB6872  e2 80 fc 60 21
	push XBC                                             ; FB6877  39
	calr SysExBuf_ReadByte                                          ; FB6878  1e 36 f9
	ld H,A                                               ; FB687B  c9 8e
	ldw de, 0x00                                         ; FB687D  32 00 00
	pop XIY                                              ; FB6880  5d
.LFB6881:
	ld BC,DE                                             ; FB6881  da 89
	extz XBC                                             ; FB6883  e9 12
	add XBC,XIX                                          ; FB6885  ec 81
	ld L,(XBC)                                           ; FB6887  81 27
	cp L,0xff                                            ; FB6889  cf cf ff
	jr nz, .LFB6894                                      ; FB688C  6e 06
	pushw 0x0d                                           ; FB688E  0b 0d 00
	jrl .LFB6ADA                                         ; FB6891  78 46 02
.LFB6894:
	cp H,L                                               ; FB6894  cf f6
	jr z, .LFB689E                                       ; FB6896  66 06
	cp L,0xfe                                            ; FB6898  cf cf fe
	jrl nz, .LFB6930                                     ; FB689B  7e 92 00
.LFB689E:
	ld C,H                                               ; FB689E  ce 8b
	extz BC                                              ; FB68A0  d9 12
	pushw bc                                             ; FB68A2  29
	pushw 0x0b                                           ; FB68A3  0b 0b 00
	ld xbc, (0x60fcd8:24)                               ; FB68A6  e2 d8 fc 60 21
	push XBC                                             ; FB68AB  39
	calr U8Rec16_SetField                                          ; FB68AC  1e 6a f9
	ld BC,DE                                             ; FB68AF  da 89
	extz XBC                                             ; FB68B1  e9 12
	ld (xiz-4), xbc                                      ; FB68B3  be fc 61
	inc 1,XBC                                            ; FB68B6  e9 61
	ld (xiz-10), xbc                                     ; FB68B8  be f6 61
	add XBC,XIX                                          ; FB68BB  ec 81
	ld A,(XBC)                                           ; FB68BD  81 21
	extz WA                                              ; FB68BF  d8 12
	pushw wa                                             ; FB68C1  28
	pushw 0x00                                           ; FB68C2  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB68C5  e2 d8 fc 60 21
	push XBC                                             ; FB68CA  39
	calr U8Rec16_SetField                                          ; FB68CB  1e 4b f9
	ld XBC,XIX                                           ; FB68CE  ec 89
	add	xbc, (xiz-10)                                ; FB68D0  ae f6 81
	ld H,(XBC)                                           ; FB68D3  81 26
	inc 8,XSP                                            ; FB68D5  ef 60
	inc 8,XSP                                            ; FB68D7  ef 60
	cp h, 0x00:i3                                          ; FB68D9  ce d8
	jr z, .LFB6923                                       ; FB68DB  66 46
	ld C,H                                               ; FB68DD  ce 8b
	extz BC                                              ; FB68DF  d9 12
	pushw bc                                             ; FB68E1  29
	pushw 0x00                                           ; FB68E2  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB68E5  e2 d8 fc 60 21
	push XBC                                             ; FB68EA  39
	calr U8Rec16_SetField                                          ; FB68EB  1e 2b f9
	ld xbc, (xiz-4)                                      ; FB68EE  ae fc 21
	inc 2,XBC                                            ; FB68F1  e9 62
	ld (xiz-10), xbc                                     ; FB68F3  be f6 61
	add XBC,XIX                                          ; FB68F6  ec 81
	ld XWA,(XBC)                                         ; FB68F8  a1 20
	ld B,(XWA)                                           ; FB68FA  80 22
	ld C,B                                               ; FB68FC  ca 8b
	extz BC                                              ; FB68FE  d9 12
	pushw bc                                             ; FB6900  29
	pushw 0x01                                           ; FB6901  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB6904  e2 d8 fc 60 21
	push XBC                                             ; FB6909  39
	calr U8Rec16_SetField                                          ; FB690A  1e 0c f9
	ld XBC,XIX                                           ; FB690D  ec 89
	add	xbc, (xiz-10)                                ; FB690F  ae f6 81
	ld XWA,(XBC)                                         ; FB6912  a1 20
	ld B,(XWA+0x01)                                      ; FB6914  88 01 22
	ld C,B                                               ; FB6917  ca 8b
	extz BC                                              ; FB6919  d9 12
	inc 8,XSP                                            ; FB691B  ef 60
	inc 8,XSP                                            ; FB691D  ef 60
	pushw bc                                             ; FB691F  29
	jrl .LFB6B6C                                         ; FB6920  78 49 02
.LFB6923:
	ld xbc, (xiz-4)                                      ; FB6923  ae fc 21
	inc 2,XBC                                            ; FB6926  e9 62
	add XBC,XIX                                          ; FB6928  ec 81
	ld XWA,(XBC)                                         ; FB692A  a1 20
	ld XIX,XWA                                           ; FB692C  e8 8c
	jr .LFB6935                                          ; FB692E  68 05
.LFB6930:
	inc 6,DE                                             ; FB6930  da 66
	jrl .LFB6881                                         ; FB6932  78 4c ff
.LFB6935:
	ld xbc, (0x60fc80:24)                               ; FB6935  e2 80 fc 60 21
	push XBC                                             ; FB693A  39
	calr SysExBuf_ReadByte                                          ; FB693B  1e 73 f8
	ld H,A                                               ; FB693E  c9 8e
	ldw de, 0x00                                         ; FB6940  32 00 00
	pop XIY                                              ; FB6943  5d
.LFB6944:
	ld BC,DE                                             ; FB6944  da 89
	extz XBC                                             ; FB6946  e9 12
	add XBC,XIX                                          ; FB6948  ec 81
	ld L,(XBC)                                           ; FB694A  81 27
	cp L,0xff                                            ; FB694C  cf cf ff
	jr nz, .LFB6957                                      ; FB694F  6e 06
	pushw 0x0e                                           ; FB6951  0b 0e 00
	jrl .LFB6ADA                                         ; FB6954  78 83 01
.LFB6957:
	cp H,L                                               ; FB6957  cf f6
	jr z, .LFB6961                                       ; FB6959  66 06
	cp L,0xfe                                            ; FB695B  cf cf fe
	jrl nz, .LFB69F3                                     ; FB695E  7e 92 00
.LFB6961:
	ld C,H                                               ; FB6961  ce 8b
	extz BC                                              ; FB6963  d9 12
	pushw bc                                             ; FB6965  29
	pushw 0x0c                                           ; FB6966  0b 0c 00
	ld xbc, (0x60fcd8:24)                               ; FB6969  e2 d8 fc 60 21
	push XBC                                             ; FB696E  39
	calr U8Rec16_SetField                                          ; FB696F  1e a7 f8
	ld BC,DE                                             ; FB6972  da 89
	extz XBC                                             ; FB6974  e9 12
	ld (xiz-4), xbc                                      ; FB6976  be fc 61
	inc 1,XBC                                            ; FB6979  e9 61
	ld (xiz-10), xbc                                     ; FB697B  be f6 61
	add XBC,XIX                                          ; FB697E  ec 81
	ld A,(XBC)                                           ; FB6980  81 21
	extz WA                                              ; FB6982  d8 12
	pushw wa                                             ; FB6984  28
	pushw 0x00                                           ; FB6985  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6988  e2 d8 fc 60 21
	push XBC                                             ; FB698D  39
	calr U8Rec16_SetField                                          ; FB698E  1e 88 f8
	ld XBC,XIX                                           ; FB6991  ec 89
	add	xbc, (xiz-10)                                ; FB6993  ae f6 81
	ld H,(XBC)                                           ; FB6996  81 26
	inc 8,XSP                                            ; FB6998  ef 60
	inc 8,XSP                                            ; FB699A  ef 60
	cp h, 0x00:i3                                          ; FB699C  ce d8
	jr z, .LFB69E6                                       ; FB699E  66 46
	ld C,H                                               ; FB69A0  ce 8b
	extz BC                                              ; FB69A2  d9 12
	pushw bc                                             ; FB69A4  29
	pushw 0x00                                           ; FB69A5  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB69A8  e2 d8 fc 60 21
	push XBC                                             ; FB69AD  39
	calr U8Rec16_SetField                                          ; FB69AE  1e 68 f8
	ld xbc, (xiz-4)                                      ; FB69B1  ae fc 21
	inc 2,XBC                                            ; FB69B4  e9 62
	ld (xiz-10), xbc                                     ; FB69B6  be f6 61
	add XBC,XIX                                          ; FB69B9  ec 81
	ld XWA,(XBC)                                         ; FB69BB  a1 20
	ld B,(XWA)                                           ; FB69BD  80 22
	ld C,B                                               ; FB69BF  ca 8b
	extz BC                                              ; FB69C1  d9 12
	pushw bc                                             ; FB69C3  29
	pushw 0x01                                           ; FB69C4  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB69C7  e2 d8 fc 60 21
	push XBC                                             ; FB69CC  39
	calr U8Rec16_SetField                                          ; FB69CD  1e 49 f8
	ld XBC,XIX                                           ; FB69D0  ec 89
	add	xbc, (xiz-10)                                ; FB69D2  ae f6 81
	ld XWA,(XBC)                                         ; FB69D5  a1 20
	ld B,(XWA+0x01)                                      ; FB69D7  88 01 22
	ld C,B                                               ; FB69DA  ca 8b
	extz BC                                              ; FB69DC  d9 12
	inc 8,XSP                                            ; FB69DE  ef 60
	inc 8,XSP                                            ; FB69E0  ef 60
	pushw bc                                             ; FB69E2  29
	jrl .LFB6B6C                                         ; FB69E3  78 86 01
.LFB69E6:
	ld xbc, (xiz-4)                                      ; FB69E6  ae fc 21
	inc 2,XBC                                            ; FB69E9  e9 62
	add XBC,XIX                                          ; FB69EB  ec 81
	ld XWA,(XBC)                                         ; FB69ED  a1 20
	ld XIX,XWA                                           ; FB69EF  e8 8c
	jr .LFB69F8                                          ; FB69F1  68 05
.LFB69F3:
	inc 6,DE                                             ; FB69F3  da 66
	jrl .LFB6944                                         ; FB69F5  78 4c ff
.LFB69F8:
	ld xbc, (0x60fc80:24)                               ; FB69F8  e2 80 fc 60 21
	push XBC                                             ; FB69FD  39
	calr SysExBuf_ReadByte                                          ; FB69FE  1e b0 f7
	ld H,A                                               ; FB6A01  c9 8e
	ldw de, 0x00                                         ; FB6A03  32 00 00
	pop XIY                                              ; FB6A06  5d
.LFB6A07:
	ld BC,DE                                             ; FB6A07  da 89
	extz XBC                                             ; FB6A09  e9 12
	add XBC,XIX                                          ; FB6A0B  ec 81
	ld L,(XBC)                                           ; FB6A0D  81 27
	cp L,0xff                                            ; FB6A0F  cf cf ff
	jr nz, .LFB6A1A                                      ; FB6A12  6e 06
	pushw 0x0f                                           ; FB6A14  0b 0f 00
	jrl .LFB6ADA                                         ; FB6A17  78 c0 00
.LFB6A1A:
	cp H,L                                               ; FB6A1A  cf f6
	jr z, .LFB6A24                                       ; FB6A1C  66 06
	cp L,0xfe                                            ; FB6A1E  cf cf fe
	jrl nz, .LFB6AB6                                     ; FB6A21  7e 92 00
.LFB6A24:
	ld C,H                                               ; FB6A24  ce 8b
	extz BC                                              ; FB6A26  d9 12
	pushw bc                                             ; FB6A28  29
	pushw 0x0d                                           ; FB6A29  0b 0d 00
	ld xbc, (0x60fcd8:24)                               ; FB6A2C  e2 d8 fc 60 21
	push XBC                                             ; FB6A31  39
	calr U8Rec16_SetField                                          ; FB6A32  1e e4 f7
	ld BC,DE                                             ; FB6A35  da 89
	extz XBC                                             ; FB6A37  e9 12
	ld (xiz-4), xbc                                      ; FB6A39  be fc 61
	inc 1,XBC                                            ; FB6A3C  e9 61
	ld (xiz-10), xbc                                     ; FB6A3E  be f6 61
	add XBC,XIX                                          ; FB6A41  ec 81
	ld A,(XBC)                                           ; FB6A43  81 21
	extz WA                                              ; FB6A45  d8 12
	pushw wa                                             ; FB6A47  28
	pushw 0x00                                           ; FB6A48  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6A4B  e2 d8 fc 60 21
	push XBC                                             ; FB6A50  39
	calr U8Rec16_SetField                                          ; FB6A51  1e c5 f7
	ld XBC,XIX                                           ; FB6A54  ec 89
	add	xbc, (xiz-10)                                ; FB6A56  ae f6 81
	ld H,(XBC)                                           ; FB6A59  81 26
	inc 8,XSP                                            ; FB6A5B  ef 60
	inc 8,XSP                                            ; FB6A5D  ef 60
	cp h, 0x00:i3                                          ; FB6A5F  ce d8
	jr z, .LFB6AA9                                       ; FB6A61  66 46
	ld C,H                                               ; FB6A63  ce 8b
	extz BC                                              ; FB6A65  d9 12
	pushw bc                                             ; FB6A67  29
	pushw 0x00                                           ; FB6A68  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6A6B  e2 d8 fc 60 21
	push XBC                                             ; FB6A70  39
	calr U8Rec16_SetField                                          ; FB6A71  1e a5 f7
	ld xbc, (xiz-4)                                      ; FB6A74  ae fc 21
	inc 2,XBC                                            ; FB6A77  e9 62
	ld (xiz-10), xbc                                     ; FB6A79  be f6 61
	add XBC,XIX                                          ; FB6A7C  ec 81
	ld XWA,(XBC)                                         ; FB6A7E  a1 20
	ld B,(XWA)                                           ; FB6A80  80 22
	ld C,B                                               ; FB6A82  ca 8b
	extz BC                                              ; FB6A84  d9 12
	pushw bc                                             ; FB6A86  29
	pushw 0x01                                           ; FB6A87  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB6A8A  e2 d8 fc 60 21
	push XBC                                             ; FB6A8F  39
	calr U8Rec16_SetField                                          ; FB6A90  1e 86 f7
	ld XBC,XIX                                           ; FB6A93  ec 89
	add	xbc, (xiz-10)                                ; FB6A95  ae f6 81
	ld XWA,(XBC)                                         ; FB6A98  a1 20
	ld B,(XWA+0x01)                                      ; FB6A9A  88 01 22
	ld C,B                                               ; FB6A9D  ca 8b
	extz BC                                              ; FB6A9F  d9 12
	inc 8,XSP                                            ; FB6AA1  ef 60
	inc 8,XSP                                            ; FB6AA3  ef 60
	pushw bc                                             ; FB6AA5  29
	jrl .LFB6B6C                                         ; FB6AA6  78 c3 00
.LFB6AA9:
	ld xbc, (xiz-4)                                      ; FB6AA9  ae fc 21
	inc 2,XBC                                            ; FB6AAC  e9 62
	add XBC,XIX                                          ; FB6AAE  ec 81
	ld XWA,(XBC)                                         ; FB6AB0  a1 20
	ld XIX,XWA                                           ; FB6AB2  e8 8c
	jr .LFB6ABB                                          ; FB6AB4  68 05
.LFB6AB6:
	inc 6,DE                                             ; FB6AB6  da 66
	jrl .LFB6A07                                         ; FB6AB8  78 4c ff
.LFB6ABB:
	ld xbc, (0x60fc80:24)                               ; FB6ABB  e2 80 fc 60 21
	push XBC                                             ; FB6AC0  39
	calr SysExBuf_ReadByte                                          ; FB6AC1  1e ed f6
	ld H,A                                               ; FB6AC4  c9 8e
	ldw de, 0x00                                         ; FB6AC6  32 00 00
	pop XIY                                              ; FB6AC9  5d
.LFB6ACA:
	ld BC,DE                                             ; FB6ACA  da 89
	extz XBC                                             ; FB6ACC  e9 12
	add XBC,XIX                                          ; FB6ACE  ec 81
	ld L,(XBC)                                           ; FB6AD0  81 27
	cp L,0xff                                            ; FB6AD2  cf cf ff
	jr nz, .LFB6AE0                                      ; FB6AD5  6e 09
	pushw 0x10                                           ; FB6AD7  0b 10 00
.LFB6ADA:
	pushw 0x04                                           ; FB6ADA  0b 04 00
	jrl .LFB6B6F                                         ; FB6ADD  78 8f 00
.LFB6AE0:
	cp H,L                                               ; FB6AE0  cf f6
	jr z, .LFB6AEA                                       ; FB6AE2  66 06
	cp L,0xfe                                            ; FB6AE4  cf cf fe
	jrl nz, .LFB6B7C                                     ; FB6AE7  7e 92 00
.LFB6AEA:
	ld C,H                                               ; FB6AEA  ce 8b
	extz BC                                              ; FB6AEC  d9 12
	pushw bc                                             ; FB6AEE  29
	pushw 0x0e                                           ; FB6AEF  0b 0e 00
	ld xbc, (0x60fcd8:24)                               ; FB6AF2  e2 d8 fc 60 21
	push XBC                                             ; FB6AF7  39
	calr U8Rec16_SetField                                          ; FB6AF8  1e 1e f7
	ld BC,DE                                             ; FB6AFB  da 89
	extz XBC                                             ; FB6AFD  e9 12
	ld (xiz-4), xbc                                      ; FB6AFF  be fc 61
	inc 1,XBC                                            ; FB6B02  e9 61
	ld (xiz-10), xbc                                     ; FB6B04  be f6 61
	add XBC,XIX                                          ; FB6B07  ec 81
	ld A,(XBC)                                           ; FB6B09  81 21
	extz WA                                              ; FB6B0B  d8 12
	pushw wa                                             ; FB6B0D  28
	pushw 0x00                                           ; FB6B0E  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6B11  e2 d8 fc 60 21
	push XBC                                             ; FB6B16  39
	calr U8Rec16_SetField                                          ; FB6B17  1e ff f6
	ld XBC,XIX                                           ; FB6B1A  ec 89
	add	xbc, (xiz-10)                                ; FB6B1C  ae f6 81
	ld H,(XBC)                                           ; FB6B1F  81 26
	inc 8,XSP                                            ; FB6B21  ef 60
	inc 8,XSP                                            ; FB6B23  ef 60
	cp h, 0x00:i3                                          ; FB6B25  ce d8
	jr z, .LFB6B81                                       ; FB6B27  66 58
	ld C,H                                               ; FB6B29  ce 8b
	extz BC                                              ; FB6B2B  d9 12
	pushw bc                                             ; FB6B2D  29
	pushw 0x00                                           ; FB6B2E  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6B31  e2 d8 fc 60 21
	push XBC                                             ; FB6B36  39
	calr U8Rec16_SetField                                          ; FB6B37  1e df f6
	ld xbc, (xiz-4)                                      ; FB6B3A  ae fc 21
	inc 2,XBC                                            ; FB6B3D  e9 62
	ld (xiz-10), xbc                                     ; FB6B3F  be f6 61
	add XBC,XIX                                          ; FB6B42  ec 81
	ld XWA,(XBC)                                         ; FB6B44  a1 20
	ld B,(XWA)                                           ; FB6B46  80 22
	ld C,B                                               ; FB6B48  ca 8b
	extz BC                                              ; FB6B4A  d9 12
	pushw bc                                             ; FB6B4C  29
	pushw 0x01                                           ; FB6B4D  0b 01 00
	ld xbc, (0x60fcd8:24)                               ; FB6B50  e2 d8 fc 60 21
	push XBC                                             ; FB6B55  39
	calr U8Rec16_SetField                                          ; FB6B56  1e c0 f6
	ld XBC,XIX                                           ; FB6B59  ec 89
	add	xbc, (xiz-10)                                ; FB6B5B  ae f6 81
	ld XWA,(XBC)                                         ; FB6B5E  a1 20
	ld B,(XWA+0x01)                                      ; FB6B60  88 01 22
	ld C,B                                               ; FB6B63  ca 8b
	extz BC                                              ; FB6B65  d9 12
	inc 8,XSP                                            ; FB6B67  ef 60
	inc 8,XSP                                            ; FB6B69  ef 60
	pushw bc                                             ; FB6B6B  29
.LFB6B6C:
	pushw 0x02                                           ; FB6B6C  0b 02 00
.LFB6B6F:
	ld xbc, (0x60fcd8:24)                               ; FB6B6F  e2 d8 fc 60 21
	push XBC                                             ; FB6B74  39
	calr U8Rec16_SetField                                          ; FB6B75  1e a1 f6
	inc 8,XSP                                            ; FB6B78  ef 60
	jr .LFB6B81                                          ; FB6B7A  68 05
.LFB6B7C:
	inc 6,DE                                             ; FB6B7C  da 66
	jrl .LFB6ACA                                         ; FB6B7E  78 49 ff
.LFB6B81:
	pop XIX                                              ; FB6B81  5c
	popw de                                              ; FB6B82  4a
	popw hl                                              ; FB6B83  4b
	unlk XIZ                                             ; FB6B84  ee 0d
	ret                                                  ; FB6B86  0e
; SysExRx_CheckCommandClass: class = prom_b 0xF4FE82[command]; classes 1/2/3 need bit 1 / bit 0 / either of (0x7FD6), else error 0x21.
SysExRx_CheckCommandClass:
	push XIX                                             ; FB6B87  3c
	lda xix, (0x7fd6:16)                                ; FB6B88  f1 d6 7f 34
	pushw 0x04                                           ; FB6B8C  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB6B8F  e2 d8 fc 60 21
	push XBC                                             ; FB6B94  39
	calr U8Rec16_GetField                                          ; FB6B95  1e 3b f7
	inc 6,XSP                                            ; FB6B98  ef 66
	cp a, 0x00:i3                                          ; FB6B9A  c9 d8
	jr nz, .LFB6BF2                                      ; FB6B9C  6e 54
	pushw 0x00                                           ; FB6B9E  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6BA1  e2 d8 fc 60 21
	push XBC                                             ; FB6BA6  39
	calr U8Rec16_GetField                                          ; FB6BA7  1e 29 f7
	extz WA                                              ; FB6BAA  d8 12
	extz XWA                                             ; FB6BAC  e8 12
	add	xwa, SysExRxClass_ByResult                   ; FB6BAE  e8 c8 82 fe f4 00
	ld C,(XWA)                                           ; FB6BB4  80 23
	extz BC                                              ; FB6BB6  d9 12
	inc 6,XSP                                            ; FB6BB8  ef 66
	cp bc, 0x01:i3                                         ; FB6BBA  d9 d9
	jr z, .LFB6BC8                                       ; FB6BBC  66 0a
	cp bc, 0x02:i3                                         ; FB6BBE  d9 da
	jr z, .LFB6BD1                                       ; FB6BC0  66 0f
	cp bc, 0x03:i3                                         ; FB6BC2  d9 db
	jr z, .LFB6BDA                                       ; FB6BC4  66 14
	jr .LFB6BF2                                          ; FB6BC6  68 2a
.LFB6BC8:
	ld C,(XIX)                                           ; FB6BC8  84 23
	and C,0x02                                           ; FB6BCA  cb cc 02
	jr z, .LFB6BF2                                       ; FB6BCD  66 23
	jr .LFB6BE1                                          ; FB6BCF  68 10
.LFB6BD1:
	ld C,(XIX)                                           ; FB6BD1  84 23
	and C,0x01                                           ; FB6BD3  cb cc 01
	jr z, .LFB6BF2                                       ; FB6BD6  66 1a
	jr .LFB6BE1                                          ; FB6BD8  68 07
.LFB6BDA:
	ld C,(XIX)                                           ; FB6BDA  84 23
	and C,0x03                                           ; FB6BDC  cb cc 03
	jr z, .LFB6BF2                                       ; FB6BDF  66 11
.LFB6BE1:
	pushw 0x21                                           ; FB6BE1  0b 21 00
	pushw 0x04                                           ; FB6BE4  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB6BE7  e2 d8 fc 60 21
	push XBC                                             ; FB6BEC  39
	calr U8Rec16_SetField                                          ; FB6BED  1e 29 f6
	inc 8,XSP                                            ; FB6BF0  ef 60
.LFB6BF2:
	pop XIX                                              ; FB6BF2  5c
	ret                                                  ; FB6BF3  0e
; SysExRx_CheckAddress: commands 0x11/0x14: 3-septet address above 0x50C00 -> error 0x16, else to fields 12-14; commands 0x18/0x1A with field 12
;   == 0xFF: the three bytes ORed must be 1, else error 0x0E.
SysExRx_CheckAddress:
	link XIZ,0xfffc                                      ; FB6BF4  ee 0c fc ff
	pushw hl                                             ; FB6BF8  2b
	pushw de                                             ; FB6BF9  2a
	push XIX                                             ; FB6BFA  3c
	lda xix, (0x60fc80:24)                               ; FB6BFB  f2 80 fc 60 34
	pushw 0x04                                           ; FB6C00  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB6C03  e2 d8 fc 60 21
	push XBC                                             ; FB6C08  39
	calr U8Rec16_GetField                                          ; FB6C09  1e c7 f6
	inc 6,XSP                                            ; FB6C0C  ef 66
	cp a, 0x00:i3                                          ; FB6C0E  c9 d8
	jrl nz, .LFB6CF6                                     ; FB6C10  7e e3 00
	pushw 0x00                                           ; FB6C13  0b 00 00
	ld xbc, (0x60fcd8:24)                               ; FB6C16  e2 d8 fc 60 21
	push XBC                                             ; FB6C1B  39
	calr U8Rec16_GetField                                          ; FB6C1C  1e b4 f6
	ld H,A                                               ; FB6C1F  c9 8e
	inc 6,XSP                                            ; FB6C21  ef 66
	cp A,0x11                                            ; FB6C23  c9 cf 11
	jr z, .LFB6C2E                                       ; FB6C26  66 06
	cp A,0x14                                            ; FB6C28  c9 cf 14
	jrl nz, .LFB6CA6                                     ; FB6C2B  7e 78 00
.LFB6C2E:
	ld XBC,(XIX)                                         ; FB6C2E  a4 21
	push XBC                                             ; FB6C30  39
	calr SysExBuf_ReadByte                                          ; FB6C31  1e 7d f5
	ld D,A                                               ; FB6C34  c9 8c
	ld XBC,(XIX)                                         ; FB6C36  a4 21
	push XBC                                             ; FB6C38  39
	calr SysExBuf_ReadByte                                          ; FB6C39  1e 75 f5
	ld L,A                                               ; FB6C3C  c9 8f
	ld XBC,(XIX)                                         ; FB6C3E  a4 21
	push XBC                                             ; FB6C40  39
	calr SysExBuf_ReadByte                                          ; FB6C41  1e 6d f5
	ld H,A                                               ; FB6C44  c9 8e
	extz WA                                              ; FB6C46  d8 12
	extz XWA                                             ; FB6C48  e8 12
	ld XIX,XWA                                           ; FB6C4A  e8 8c
	ld C,L                                               ; FB6C4C  cf 8b
	extz BC                                              ; FB6C4E  d9 12
	extz XBC                                             ; FB6C50  e9 12
	sll xbc, 0x07                                        ; FB6C52  e9 ee 07
	or XBC,XIX                                           ; FB6C55  ec e1
	ld (xiz-4), xbc                                      ; FB6C57  be fc 61
	ld A,D                                               ; FB6C5A  cc 89
	extz WA                                              ; FB6C5C  d8 12
	extz XWA                                             ; FB6C5E  e8 12
	sll xwa, 0x0e                                        ; FB6C60  e8 ee 0e
	or XBC,XWA                                           ; FB6C63  e8 e1
	inc 8,XSP                                            ; FB6C65  ef 60
	inc 4,XSP                                            ; FB6C67  ef 64
	cp XBC,0x00050c00                                    ; FB6C69  e9 cf 00 0c 05 00
	jr ugt, .LFB6CA1                                     ; FB6C6F  6b 30
	ld C,D                                               ; FB6C71  cc 8b
	extz BC                                              ; FB6C73  d9 12
	pushw bc                                             ; FB6C75  29
	pushw 0x0c                                           ; FB6C76  0b 0c 00
	ld xbc, (0x60fcd8:24)                               ; FB6C79  e2 d8 fc 60 21
	push XBC                                             ; FB6C7E  39
	calr U8Rec16_SetField                                          ; FB6C7F  1e 97 f5
	ld C,L                                               ; FB6C82  cf 8b
	extz BC                                              ; FB6C84  d9 12
	pushw bc                                             ; FB6C86  29
	pushw 0x0d                                           ; FB6C87  0b 0d 00
	ld xbc, (0x60fcd8:24)                               ; FB6C8A  e2 d8 fc 60 21
	push XBC                                             ; FB6C8F  39
	calr U8Rec16_SetField                                          ; FB6C90  1e 86 f5
	ld C,H                                               ; FB6C93  ce 8b
	extz BC                                              ; FB6C95  d9 12
	inc 8,XSP                                            ; FB6C97  ef 60
	inc 8,XSP                                            ; FB6C99  ef 60
	pushw bc                                             ; FB6C9B  29
	pushw 0x0e                                           ; FB6C9C  0b 0e 00
	jr .LFB6CEB                                          ; FB6C9F  68 4a
.LFB6CA1:
	pushw 0x16                                           ; FB6CA1  0b 16 00
	jr .LFB6CE8                                          ; FB6CA4  68 42
.LFB6CA6:
	cp H,0x18                                            ; FB6CA6  ce cf 18
	jr z, .LFB6CB0                                       ; FB6CA9  66 05
	cp H,0x1a                                            ; FB6CAB  ce cf 1a
	jr nz, .LFB6CF6                                      ; FB6CAE  6e 46
.LFB6CB0:
	pushw 0x0c                                           ; FB6CB0  0b 0c 00
	ld xbc, (0x60fcd8:24)                               ; FB6CB3  e2 d8 fc 60 21
	push XBC                                             ; FB6CB8  39
	calr U8Rec16_GetField                                          ; FB6CB9  1e 17 f6
	inc 6,XSP                                            ; FB6CBC  ef 66
	cp A,0xff                                            ; FB6CBE  c9 cf ff
	jr nz, .LFB6CF6                                      ; FB6CC1  6e 33
	ld XBC,(XIX)                                         ; FB6CC3  a4 21
	push XBC                                             ; FB6CC5  39
	calr SysExBuf_ReadByte                                          ; FB6CC6  1e e8 f4
	ld H,A                                               ; FB6CC9  c9 8e
	ld XBC,(XIX)                                         ; FB6CCB  a4 21
	push XBC                                             ; FB6CCD  39
	calr SysExBuf_ReadByte                                          ; FB6CCE  1e e0 f4
	ld L,A                                               ; FB6CD1  c9 8f
	or L,H                                               ; FB6CD3  ce e7
	ld XBC,(XIX)                                         ; FB6CD5  a4 21
	push XBC                                             ; FB6CD7  39
	calr SysExBuf_ReadByte                                          ; FB6CD8  1e d6 f4
	or A,L                                               ; FB6CDB  cf e1
	inc 8,XSP                                            ; FB6CDD  ef 60
	inc 4,XSP                                            ; FB6CDF  ef 64
	cp a, 0x01:i3                                          ; FB6CE1  c9 d9
	jr z, .LFB6CF6                                       ; FB6CE3  66 11
	pushw 0x0e                                           ; FB6CE5  0b 0e 00
.LFB6CE8:
	pushw 0x04                                           ; FB6CE8  0b 04 00
.LFB6CEB:
	ld xbc, (0x60fcd8:24)                               ; FB6CEB  e2 d8 fc 60 21
	push XBC                                             ; FB6CF0  39
	calr U8Rec16_SetField                                          ; FB6CF1  1e 25 f5
	inc 8,XSP                                            ; FB6CF4  ef 60
.LFB6CF6:
	pop XIX                                              ; FB6CF6  5c
	popw de                                              ; FB6CF7  4a
	popw hl                                              ; FB6CF8  4b
	unlk XIZ                                             ; FB6CF9  ee 0d
	ret                                                  ; FB6CFB  0e
; SysExRx_CheckBodyLength: the nibble body must end exactly 3 bytes before the write cursor (flag, checksum, F7); otherwise error 0x11.
SysExRx_CheckBodyLength:
	link XIZ,0xfff4                                      ; FB6CFC  ee 0c f4 ff
	pushw hl                                             ; FB6D00  2b
	push XIX                                             ; FB6D01  3c
	pushw 0x04                                           ; FB6D02  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB6D05  e2 d8 fc 60 21
	push XBC                                             ; FB6D0A  39
	calr U8Rec16_GetField                                          ; FB6D0B  1e c5 f5
	inc 6,XSP                                            ; FB6D0E  ef 66
	cp a, 0x00:i3                                          ; FB6D10  c9 d8
	jrl nz, .LFB6DB8                                     ; FB6D12  7e a3 00
	pushw 0x0c                                           ; FB6D15  0b 0c 00
	ld xbc, (0x60fcd8:24)                               ; FB6D18  e2 d8 fc 60 21
	push XBC                                             ; FB6D1D  39
	calr U8Rec16_GetField                                          ; FB6D1E  1e b2 f5
	ld H,A                                               ; FB6D21  c9 8e
	pushw 0x0d                                           ; FB6D23  0b 0d 00
	ld xbc, (0x60fcd8:24)                               ; FB6D26  e2 d8 fc 60 21
	push XBC                                             ; FB6D2B  39
	calr U8Rec16_GetField                                          ; FB6D2C  1e a4 f5
	ld L,A                                               ; FB6D2F  c9 8f
	or L,H                                               ; FB6D31  ce e7
	pushw 0x0e                                           ; FB6D33  0b 0e 00
	ld xbc, (0x60fcd8:24)                               ; FB6D36  e2 d8 fc 60 21
	push XBC                                             ; FB6D3B  39
	calr U8Rec16_GetField                                          ; FB6D3C  1e 94 f5
	or A,L                                               ; FB6D3F  cf e1
	and A,0xff                                           ; FB6D41  c9 cc ff
	add XSP,0x00000012                                   ; FB6D44  ef c8 12 00 00 00
	cp a, 0x00:i3                                          ; FB6D4A  c9 d8
	jrl z, .LFB6DB8                                      ; FB6D4C  76 69 00
	pushw 0x05                                           ; FB6D4F  0b 05 00
	ld xbc, (0x60fcd8:24)                               ; FB6D52  e2 d8 fc 60 21
	push XBC                                             ; FB6D57  39
	calr U8Rec16_GetField                                          ; FB6D58  1e 78 f5
	ld H,A                                               ; FB6D5B  c9 8e
	inc 6,XSP                                            ; FB6D5D  ef 66
	cp A,0x7e                                            ; FB6D5F  c9 cf 7e
	jr z, .LFB6D6E                                       ; FB6D62  66 0a
	cp A,0x2d                                            ; FB6D64  c9 cf 2d
	jr z, .LFB6D6E                                       ; FB6D67  66 05
	cp A,0x2c                                            ; FB6D69  c9 cf 2c
	jr nz, .LFB6DB8                                      ; FB6D6C  6e 4a
.LFB6D6E:
	ld xbc, (0x60fc80:24)                               ; FB6D6E  e2 80 fc 60 21
	ld XWA,(XBC+0x0a)                                    ; FB6D73  a9 0a 20
	dec 3,XWA                                            ; FB6D76  e8 6b
	ld (xiz-8), xwa                                      ; FB6D78  be f8 60
	ld XIY,(XBC+0x02)                                    ; FB6D7B  a9 02 25
	ld (XBC+0x06),XIY                                    ; FB6D7E  b9 06 65
.LFB6D81:
	ld xbc, (0x60fc80:24)                               ; FB6D81  e2 80 fc 60 21
	ld XWA,(XBC+0x02)                                    ; FB6D86  a9 02 20
	ld (xiz-4), xwa                                      ; FB6D89  be fc 60
	ld (xiz-12), xwa                                     ; FB6D8C  be f4 60
	ld xix, (xiz-8)                                      ; FB6D8F  ae f8 24
	cp XWA,XIX                                           ; FB6D92  ec f0
	jr nc, .LFB6DA0                                      ; FB6D94  6f 0a
	ld xiy, (xiz-4)                                      ; FB6D96  ae fc 25
	inc 2,XIY                                            ; FB6D99  ed 62
	ld (XBC+0x02),XIY                                    ; FB6D9B  b9 02 65
	jr .LFB6D81                                          ; FB6D9E  68 e1
.LFB6DA0:
	ld xbc, (xiz-12)                                     ; FB6DA0  ae f4 21
	cp XBC,XIX                                           ; FB6DA3  ec f1
	jr z, .LFB6DB8                                       ; FB6DA5  66 11
	pushw 0x11                                           ; FB6DA7  0b 11 00
	pushw 0x04                                           ; FB6DAA  0b 04 00
	ld xwa, (0x60fcd8:24)                               ; FB6DAD  e2 d8 fc 60 20
	push XWA                                             ; FB6DB2  38
	calr U8Rec16_SetField                                          ; FB6DB3  1e 63 f4
	inc 8,XSP                                            ; FB6DB6  ef 60
.LFB6DB8:
	pop XIX                                              ; FB6DB8  5c
	popw hl                                              ; FB6DB9  4b
	unlk XIZ                                             ; FB6DBA  ee 0d
	ret                                                  ; FB6DBC  0e
; SysExRx_VerifyChecksum: for field 5 in 0x7E/0x2B/0x2C/0x2D: flag must be 0/1 (else 0x12, kept in field 15); (-sum) & 0x7F of bytes 1..flag must
;   equal the checksum, else error 0x14.
SysExRx_VerifyChecksum:
	link XIZ,0xfffc                                      ; FB6DBD  ee 0c fc ff
	pushw hl                                             ; FB6DC1  2b
	push XIX                                             ; FB6DC2  3c
	ld l, 0x00:opc                                          ; FB6DC3  27 00
	pushw 0x04                                           ; FB6DC5  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB6DC8  e2 d8 fc 60 21
	push XBC                                             ; FB6DCD  39
	calr U8Rec16_GetField                                          ; FB6DCE  1e 02 f5
	inc 6,XSP                                            ; FB6DD1  ef 66
	cp a, 0x00:i3                                          ; FB6DD3  c9 d8
	jrl nz, .LFB6E7A                                     ; FB6DD5  7e a2 00
	pushw 0x05                                           ; FB6DD8  0b 05 00
	ld xbc, (0x60fcd8:24)                               ; FB6DDB  e2 d8 fc 60 21
	push XBC                                             ; FB6DE0  39
	calr U8Rec16_GetField                                          ; FB6DE1  1e ef f4
	ld H,A                                               ; FB6DE4  c9 8e
	inc 6,XSP                                            ; FB6DE6  ef 66
	cp A,0x7e                                            ; FB6DE8  c9 cf 7e
	jr z, .LFB6DFD                                       ; FB6DEB  66 10
	cp A,0x2d                                            ; FB6DED  c9 cf 2d
	jr z, .LFB6DFD                                       ; FB6DF0  66 0b
	cp A,0x2c                                            ; FB6DF2  c9 cf 2c
	jr z, .LFB6DFD                                       ; FB6DF5  66 06
	cp A,0x2b                                            ; FB6DF7  c9 cf 2b
	jrl nz, .LFB6E7A                                     ; FB6DFA  7e 7d 00
.LFB6DFD:
	ld xbc, (0x60fc80:24)                               ; FB6DFD  e2 80 fc 60 21
	push XBC                                             ; FB6E02  39
	calr SysExBuf_ReadByte                                          ; FB6E03  1e ab f3
	ld H,A                                               ; FB6E06  c9 8e
	pop XIY                                              ; FB6E08  5d
	cp a, 0x00:i3                                          ; FB6E09  c9 d8
	jr z, .LFB6E11                                       ; FB6E0B  66 04
	cp a, 0x01:i3                                          ; FB6E0D  c9 d9
	jr nz, .LFB6E69                                      ; FB6E0F  6e 58
.LFB6E11:
	ld C,H                                               ; FB6E11  ce 8b
	extz BC                                              ; FB6E13  d9 12
	pushw bc                                             ; FB6E15  29
	pushw 0x0f                                           ; FB6E16  0b 0f 00
	ld xbc, (0x60fcd8:24)                               ; FB6E19  e2 d8 fc 60 21
	push XBC                                             ; FB6E1E  39
	calr U8Rec16_SetField                                          ; FB6E1F  1e f7 f3
	ld xix, (0x60fc80:24)                               ; FB6E22  e2 80 fc 60 24
	add XIX,0x0000000f                                   ; FB6E27  ec c8 0f 00 00 00
	ld xbc, (0x60fc80:24)                               ; FB6E2D  e2 80 fc 60 21
	ld XWA,(XBC+0x02)                                    ; FB6E32  a9 02 20
	ld (xiz-4), xwa                                      ; FB6E35  be fc 60
	inc 8,XSP                                            ; FB6E38  ef 60
.LFB6E3A:
	ld XBC,XIX                                           ; FB6E3A  ec 89
	cp	xbc, (xiz-4)                                 ; FB6E3C  ae fc f1
	jr z, .LFB6E49                                       ; FB6E3F  66 08
	ld C,(XIX)                                           ; FB6E41  84 23
	add L,C                                              ; FB6E43  cb 87
	inc 1,XIX                                            ; FB6E45  ec 61
	jr .LFB6E3A                                          ; FB6E47  68 f1
.LFB6E49:
	ld C,L                                               ; FB6E49  cf 8b
	extz BC                                              ; FB6E4B  d9 12
	sub WA,WA                                            ; FB6E4D  d8 a0
	sub WA,BC                                            ; FB6E4F  d9 a0
	ld H,A                                               ; FB6E51  c9 8e
	res 0x07,H                                           ; FB6E53  ce 30 07
	ld xbc, (0x60fc80:24)                               ; FB6E56  e2 80 fc 60 21
	push XBC                                             ; FB6E5B  39
	calr SysExBuf_ReadByte                                          ; FB6E5C  1e 52 f3
	pop XIY                                              ; FB6E5F  5d
	cp H,A                                               ; FB6E60  c9 f6
	jr z, .LFB6E7A                                       ; FB6E62  66 16
	pushw 0x14                                           ; FB6E64  0b 14 00
	jr .LFB6E6C                                          ; FB6E67  68 03
.LFB6E69:
	pushw 0x12                                           ; FB6E69  0b 12 00
.LFB6E6C:
	pushw 0x04                                           ; FB6E6C  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB6E6F  e2 d8 fc 60 21
	push XBC                                             ; FB6E74  39
	calr U8Rec16_SetField                                          ; FB6E75  1e a1 f3
	inc 8,XSP                                            ; FB6E78  ef 60
.LFB6E7A:
	pop XIX                                              ; FB6E7A  5c
	popw hl                                              ; FB6E7B  4b
	unlk XIZ                                             ; FB6E7C  ee 0d
	ret                                                  ; FB6E7E  0e
; SysExTx_AppendAndSendOnF7(src, n): SysExTx_Append, and when the last byte is 0xF7 send the frame (SysExTx_SendFrameMidi1), then SysExTx_SwapBuffers.
SysExTx_AppendAndSendOnF7:
	link XIZ,0xfffc                                      ; FB6E7F  ee 0c fc ff
	pushw hl                                             ; FB6E83  2b
	push XIX                                             ; FB6E84  3c
	ld XIX,(XIZ+0x08)                                    ; FB6E85  ae 08 24
.LFB6E88:
	cpw	(xiz+12), 0x0000                             ; FB6E88  9e 0c 3f 00 00
	jr z, .LFB6EB6                                       ; FB6E8D  66 27
	decm 0x01, (xiz+0x0c)                                ; FB6E8F  9e 0c 69
	ld H,(XIX)                                           ; FB6E92  84 26
	ld xbc, (0x60fc88:24)                               ; FB6E94  e2 88 fc 60 21
	ld XWA,(XBC+0x0a)                                    ; FB6E99  a9 0a 20
	ld (xiz-4), xwa                                      ; FB6E9C  be fc 60
	sub XIY,XIY                                          ; FB6E9F  ed a5
	inc 1,XIY                                            ; FB6EA1  ed 61
	add (XBC+0x0a),XIY                                   ; FB6EA3  a9 0a 8d
	ld xbc, (xiz-4)                                      ; FB6EA6  ae fc 21
	ld (XBC),H                                           ; FB6EA9  b1 46
	inc 1,XIX                                            ; FB6EAB  ec 61
	ld xbc, (0x60fc88:24)                               ; FB6EAD  e2 88 fc 60 21
	incw 0x01, (xbc)                                     ; FB6EB2  91 61
	jr .LFB6E88                                          ; FB6EB4  68 d2
.LFB6EB6:
	ld xbc, (0x60fc88:24)                               ; FB6EB6  e2 88 fc 60 21
	ld XWA,(XBC+0x0a)                                    ; FB6EBB  a9 0a 20
	ld (XWA),0xff                                        ; FB6EBE  b0 00 ff
	ld xbc, (0x60fc88:24)                               ; FB6EC1  e2 88 fc 60 21
	ld XWA,(XBC+0x0a)                                    ; FB6EC6  a9 0a 20
	dec 1,XWA                                            ; FB6EC9  e8 69
	ld C,(XWA)                                           ; FB6ECB  80 23
	cp C,0xf7                                            ; FB6ECD  cb cf f7
	jr nz, .LFB6EE4                                      ; FB6ED0  6e 12
	ld xbc, (0x60fc88:24)                               ; FB6ED2  e2 88 fc 60 21
	push XBC                                             ; FB6ED7  39
	calr SysExTx_SendFrameMidi1                                      ; FB6ED8  1e 8a 02
	call SysExSession_RefreshProgressScreen                                      ; FB6EDB  1d b9 7b fb
	call SysExTx_SwapBuffers                                      ; FB6EDF  1d 81 80 fb
	pop XIY                                              ; FB6EE3  5d
.LFB6EE4:
	pop XIX                                              ; FB6EE4  5c
	popw hl                                              ; FB6EE5  4b
	unlk XIZ                                             ; FB6EE6  ee 0d
	ret                                                  ; FB6EE8  0e
; SysExTx_AppendRemainingSize: append the remaining byte count (0x60FD00) as three 7-bit septets, most significant first.
SysExTx_AppendRemainingSize:
	link XIZ,0xfffc                                      ; FB6EE9  ee 0c fc ff
	push XIX                                             ; FB6EED  3c
	lda xix, (xiz-4)                                     ; FB6EEE  be fc 34
	ld xbc, (0x60fd00:24)                               ; FB6EF1  e2 00 fd 60 21
	srl xbc, 0x0e                                        ; FB6EF6  e9 ef 0e
	res 0x07,C                                           ; FB6EF9  cb 30 07
	ld (XIX),C                                           ; FB6EFC  b4 43
	ld xbc, (0x60fd00:24)                               ; FB6EFE  e2 00 fd 60 21
	srl xbc, 0x07                                        ; FB6F03  e9 ef 07
	res 0x07,C                                           ; FB6F06  cb 30 07
	ld (XIX+0x01),C                                      ; FB6F09  bc 01 43
	ld c, (0x60fd00:24)                                 ; FB6F0C  c2 00 fd 60 23
	res 0x07,C                                           ; FB6F11  cb 30 07
	ld (XIX+0x02),C                                      ; FB6F14  bc 02 43
	pushw 0x03                                           ; FB6F17  0b 03 00
	push XIX                                             ; FB6F1A  3c
	calr SysExTx_Append                                      ; FB6F1B  1e 06 00
	inc 6,XSP                                            ; FB6F1E  ef 66
	pop XIX                                              ; FB6F20  5c
	unlk XIZ                                             ; FB6F21  ee 0d
	ret                                                  ; FB6F23  0e
; SysExTx_Append(src, n): append n bytes to the transmit frame (0x60FC88): store at buf+0x0A++, count buf+0 += 1, 0xFF sentinel after (sysex-probes/decode-findings.json).
SysExTx_Append:
	link XIZ,0xfffc                                      ; FB6F24  ee 0c fc ff
	pushw hl                                             ; FB6F28  2b
	push XIX                                             ; FB6F29  3c
	ld XIX,(XIZ+0x08)                                    ; FB6F2A  ae 08 24
.LFB6F2D:
	cpw	(xiz+12), 0x0000                             ; FB6F2D  9e 0c 3f 00 00
	jr z, .LFB6F5B                                       ; FB6F32  66 27
	decm 0x01, (xiz+0x0c)                                ; FB6F34  9e 0c 69
	ld H,(XIX)                                           ; FB6F37  84 26
	ld xbc, (0x60fc88:24)                               ; FB6F39  e2 88 fc 60 21
	ld XWA,(XBC+0x0a)                                    ; FB6F3E  a9 0a 20
	ld (xiz-4), xwa                                      ; FB6F41  be fc 60
	sub XIY,XIY                                          ; FB6F44  ed a5
	inc 1,XIY                                            ; FB6F46  ed 61
	add (XBC+0x0a),XIY                                   ; FB6F48  a9 0a 8d
	ld xbc, (xiz-4)                                      ; FB6F4B  ae fc 21
	ld (XBC),H                                           ; FB6F4E  b1 46
	inc 1,XIX                                            ; FB6F50  ec 61
	ld xbc, (0x60fc88:24)                               ; FB6F52  e2 88 fc 60 21
	incw 0x01, (xbc)                                     ; FB6F57  91 61
	jr .LFB6F2D                                          ; FB6F59  68 d2
.LFB6F5B:
	ld xbc, (0x60fc88:24)                               ; FB6F5B  e2 88 fc 60 21
	ld XWA,(XBC+0x0a)                                    ; FB6F60  a9 0a 20
	ld (XWA),0xff                                        ; FB6F63  b0 00 ff
	pop XIX                                              ; FB6F66  5c
	popw hl                                              ; FB6F67  4b
	unlk XIZ                                             ; FB6F68  ee 0d
	ret                                                  ; FB6F6A  0e
; SysExDump_SendFrames: while the status is 0 and (0x60FD00) is not 0: header if continuing, nibbles, flag, checksum, send (MIDI 1), swap, await ACK.
SysExDump_SendFrames:
	ld xbc, (0x60fcd8:24)                               ; FB6F6B  e2 d8 fc 60 21
	ld A,(XBC+0x04)                                      ; FB6F70  89 04 21
	cp a, 0x00:i3                                          ; FB6F73  c9 d8
	jr nz, .LFB6FB1                                      ; FB6F75  6e 3a
.LFB6F77:
	ld xbc, (0x60fcd8:24)                               ; FB6F77  e2 d8 fc 60 21
	ld A,(XBC+0x04)                                      ; FB6F7C  89 04 21
	cp a, 0x00:i3                                          ; FB6F7F  c9 d8
	jr nz, .LFB6FB1                                      ; FB6F81  6e 2e
	call SysExSession_RepaintProgressIfChanged_Nop                                      ; FB6F83  1d 9a 7e fb
	calr SysExTx_AppendContHeaderIfCont                                      ; FB6F87  1e 9b 00
	calr SysExTx_AppendNibbles                                      ; FB6F8A  1e b3 00
	calr SysExTx_AppendContFlag                                      ; FB6F8D  1e 1e 01
	calr SysExTx_AppendChecksumF7                                      ; FB6F90  1e 7e 01
	ld xbc, (0x60fc88:24)                               ; FB6F93  e2 88 fc 60 21
	push XBC                                             ; FB6F98  39
	calr SysExTx_SendFrameMidi1                                      ; FB6F99  1e c9 01
	call SysExSession_RefreshProgressScreen                                      ; FB6F9C  1d b9 7b fb
	call SysExTx_SwapBuffers                                      ; FB6FA0  1d 81 80 fb
	calr SysExDump_AwaitFrameAck                                          ; FB6FA4  1e 7f f0
	ld xbc, (0x60fd00:24)                               ; FB6FA7  e2 00 fd 60 21
	pop XIY                                              ; FB6FAC  5d
	or XBC,XBC                                           ; FB6FAD  e9 e1
	jr nz, .LFB6F77                                      ; FB6FAF  6e c6
.LFB6FB1:
	ret                                                  ; FB6FB1  0e
; SysExDump_SendFramesStreamed: as SysExDump_SendFrames, with T_Link_WaitBlockDone before each frame (0xFFFF -> status 0x20 in both
;   records) and flag 1 always.
SysExDump_SendFramesStreamed:
	push XIX                                             ; FB6FB2  3c
	lda xix, (0x60fcd8:24)                               ; FB6FB3  f2 d8 fc 60 34
	ld XBC,(XIX)                                         ; FB6FB8  a4 21
	ld A,(XBC+0x04)                                      ; FB6FBA  89 04 21
	cp a, 0x00:i3                                          ; FB6FBD  c9 d8
	jr nz, .LFB7023                                      ; FB6FBF  6e 62
.LFB6FC1:
	ld XBC,(XIX)                                         ; FB6FC1  a4 21
	ld A,(XBC+0x04)                                      ; FB6FC3  89 04 21
	cp a, 0x00:i3                                          ; FB6FC6  c9 d8
	jr nz, .LFB7023                                      ; FB6FC8  6e 59
	call SysExSession_RepaintProgressIfChanged_Nop                                      ; FB6FCA  1d 9a 7e fb
	calr SysExTx_AppendContHeaderIfCont                                      ; FB6FCE  1e 54 00
	call T_Link_WaitBlockDone                            ; FB6FD1  1d 3c 12 f4
	cp WA,0xffff                                         ; FB6FD5  d8 cf ff ff
	jr z, .LFB6FFB                                       ; FB6FD9  66 20
	calr SysExTx_AppendNibbles                                      ; FB6FDB  1e 62 00
	calr SysExTx_AppendContFlagOne                                      ; FB6FDE  1e 05 01
	calr SysExTx_AppendChecksumF7                                      ; FB6FE1  1e 2d 01
	ld xbc, (0x60fc88:24)                               ; FB6FE4  e2 88 fc 60 21
	push XBC                                             ; FB6FE9  39
	calr SysExTx_SendFrameMidi1                                      ; FB6FEA  1e 78 01
	call SysExSession_RefreshProgressScreen                                      ; FB6FED  1d b9 7b fb
	call SysExTx_SwapBuffers                                      ; FB6FF1  1d 81 80 fb
	calr SysExDump_AwaitFrameAck                                          ; FB6FF5  1e 2e f0
	pop XIY                                              ; FB6FF8  5d
	jr .LFB701A                                          ; FB6FF9  68 1f
.LFB6FFB:
	pushw 0x20                                           ; FB6FFB  0b 20 00
	pushw 0x04                                           ; FB6FFE  0b 04 00
	ld xbc, (0x60fce0:24)                               ; FB7001  e2 e0 fc 60 21
	push XBC                                             ; FB7006  39
	calr U8Rec16_SetField                                          ; FB7007  1e 0f f2
	pushw 0x20                                           ; FB700A  0b 20 00
	pushw 0x04                                           ; FB700D  0b 04 00
	ld XBC,(XIX)                                         ; FB7010  a4 21
	push XBC                                             ; FB7012  39
	calr U8Rec16_SetField                                          ; FB7013  1e 03 f2
	inc 8,XSP                                            ; FB7016  ef 60
	inc 8,XSP                                            ; FB7018  ef 60
.LFB701A:
	ld xbc, (0x60fd00:24)                               ; FB701A  e2 00 fd 60 21
	or XBC,XBC                                           ; FB701F  e9 e1
	jr nz, .LFB6FC1                                      ; FB7021  6e 9e
.LFB7023:
	pop XIX                                              ; FB7023  5c
	ret                                                  ; FB7024  0e
; SysExTx_AppendContHeaderIfCont: when the previous frame's continuation flag (record (0x60FCE4) field 15) is 1, start this one with F0 50 7E (prom_b 0xF4FED2).
SysExTx_AppendContHeaderIfCont:
	ld xbc, (0x60fce4:24)                               ; FB7025  e2 e4 fc 60 21
	ld A,(XBC+0x0f)                                      ; FB702A  89 0f 21
	cp a, 0x01:i3                                          ; FB702D  c9 d9
	jr nz, .LFB703F                                      ; FB702F  6e 0e
	pushw 0x03                                           ; FB7031  0b 03 00
	lda xwa, (0xf4fed2:24)                               ; FB7034  f2 d2 fe f4 30
	push XWA                                             ; FB7039  38
	calr SysExTx_AppendAndSendOnF7                                      ; FB703A  1e 42 fe
	inc 6,XSP                                            ; FB703D  ef 66
.LFB703F:
	ret                                                  ; FB703F  0e
; SysExTx_AppendNibbles: each source byte at (0x60FCF8)++ becomes (b >> 4), (b & 0x0F); stops when (0x60FD00) reaches 0 or the frame holds 0xFC bytes.
SysExTx_AppendNibbles:
	link XIZ,0xfffa                                      ; FB7040  ee 0c fa ff
	pushw hl                                             ; FB7044  2b
	push XIX                                             ; FB7045  3c
	lda xix, (xiz-2)                                     ; FB7046  be fe 34
	ld xbc, (0x60fd00:24)                               ; FB7049  e2 00 fd 60 21
	or XBC,XBC                                           ; FB704E  e9 e1
	jr z, .LFB70A9                                       ; FB7050  66 57
.LFB7052:
	ld xbc, (0x60fcf8:24)                               ; FB7052  e2 f8 fc 60 21
	ld (xiz-6), xbc                                      ; FB7057  be fa 61
	sub XWA,XWA                                          ; FB705A  e8 a0
	inc 1,XWA                                            ; FB705C  e8 61
	add (0x60fcf8:24), xwa                              ; FB705E  e2 f8 fc 60 88
	ld xbc, (xiz-6)                                      ; FB7063  ae fa 21
	ld H,(XBC)                                           ; FB7066  81 26
	ld (XIX+0x01),H                                      ; FB7068  bc 01 46
	ld (XIX),H                                           ; FB706B  b4 46
	ld C,H                                               ; FB706D  ce 8b
	srl c, 0x04                                          ; FB706F  cb ef 04
	ld (XIX),C                                           ; FB7072  b4 43
	and (XIX+0x01),0x0f                                  ; FB7074  8c 01 3c 0f
	pushw 0x02                                           ; FB7078  0b 02 00
	push XIX                                             ; FB707B  3c
	calr SysExTx_Append                                      ; FB707C  1e a5 fe
	sub XBC,XBC                                          ; FB707F  e9 a1
	inc 1,XBC                                            ; FB7081  e9 61
	sub (0x60fcf0:24), xbc                           ; FB7083  e2 f0 fc 60 a9
	sub XBC,XBC                                          ; FB7088  e9 a1
	inc 1,XBC                                            ; FB708A  e9 61
	sub (0x60fd00:24), xbc                           ; FB708C  e2 00 fd 60 a9
	ld xbc, (0x60fd00:24)                               ; FB7091  e2 00 fd 60 21
	inc 6,XSP                                            ; FB7096  ef 66
	or XBC,XBC                                           ; FB7098  e9 e1
	jr z, .LFB70A9                                       ; FB709A  66 0d
	ld xbc, (0x60fc88:24)                               ; FB709C  e2 88 fc 60 21
	ld WA,(XBC)                                          ; FB70A1  91 20
	cp WA,0x00fc                                         ; FB70A3  d8 cf fc 00
	jr c, .LFB7052                                       ; FB70A7  67 a9
.LFB70A9:
	pop XIX                                              ; FB70A9  5c
	popw hl                                              ; FB70AA  4b
	unlk XIZ                                             ; FB70AB  ee 0d
	ret                                                  ; FB70AD  0e
; SysExTx_AppendContFlag: append 1 while (0x60FD00) bytes remain, else 0; also stored in transmit record field 15.
SysExTx_AppendContFlag:
	link XIZ,0xffff                                      ; FB70AE  ee 0c ff ff
	ld (xiz-1), 0x01                                     ; FB70B2  be ff 00 01
	ld xbc, (0x60fd00:24)                               ; FB70B6  e2 00 fd 60 21
	or XBC,XBC                                           ; FB70BB  e9 e1
	jr nz, .LFB70C3                                      ; FB70BD  6e 04
	ld (xiz-1), 0x00                                     ; FB70BF  be ff 00 00
.LFB70C3:
	pushw 0x01                                           ; FB70C3  0b 01 00
	lda xbc, (xiz-1)                                     ; FB70C6  be ff 31
	push XBC                                             ; FB70C9  39
	calr SysExTx_Append                                      ; FB70CA  1e 57 fe
	ld bc, (xiz-1)                                       ; FB70CD  9e ff 21
	extz BC                                              ; FB70D0  d9 12
	pushw bc                                             ; FB70D2  29
	pushw 0x0f                                           ; FB70D3  0b 0f 00
	ld xbc, (0x60fce0:24)                               ; FB70D6  e2 e0 fc 60 21
	push XBC                                             ; FB70DB  39
	calr U8Rec16_SetField                                          ; FB70DC  1e 3a f1
	inc 8,XSP                                            ; FB70DF  ef 60
	inc 6,XSP                                            ; FB70E1  ef 66
	unlk XIZ                                             ; FB70E3  ee 0d
	ret                                                  ; FB70E5  0e
; SysExTx_AppendContFlagOne: append continuation flag 1 unconditionally (the streamed loop: another block always follows).
SysExTx_AppendContFlagOne:
	link XIZ,0xffff                                      ; FB70E6  ee 0c ff ff
	ld (xiz-1), 0x01                                     ; FB70EA  be ff 00 01
	pushw 0x01                                           ; FB70EE  0b 01 00
	lda xbc, (xiz-1)                                     ; FB70F1  be ff 31
	push XBC                                             ; FB70F4  39
	calr SysExTx_Append                                      ; FB70F5  1e 2c fe
	ld bc, (xiz-1)                                       ; FB70F8  9e ff 21
	extz BC                                              ; FB70FB  d9 12
	pushw bc                                             ; FB70FD  29
	pushw 0x0f                                           ; FB70FE  0b 0f 00
	ld xbc, (0x60fce0:24)                               ; FB7101  e2 e0 fc 60 21
	push XBC                                             ; FB7106  39
	calr U8Rec16_SetField                                          ; FB7107  1e 0f f1
	inc 8,XSP                                            ; FB710A  ef 60
	inc 6,XSP                                            ; FB710C  ef 66
	unlk XIZ                                             ; FB710E  ee 0d
	ret                                                  ; FB7110  0e
; SysExTx_AppendChecksumF7: append (-sum) & 0x7F of the frame from the byte after F0, then the 0xF7 (byte 1 of the 00 F7 word at prom_b 0xF4FE68).
SysExTx_AppendChecksumF7:
	link XIZ,0xfffa                                      ; FB7111  ee 0c fa ff
	pushw hl                                             ; FB7115  2b
	push XIX                                             ; FB7116  3c
	ld h, 0x00:opc                                          ; FB7117  26 00
	ld bc, (0xf4fe68:24)                                ; FB7119  d2 68 fe f4 21
	ld (xiz-6), bc                                       ; FB711E  be fa 51
	ld xix, (0x60fc88:24)                               ; FB7121  e2 88 fc 60 24
	add XIX,0x0000000f                                   ; FB7126  ec c8 0f 00 00 00
	ld xwa, (0x60fc88:24)                               ; FB712C  e2 88 fc 60 20
	ld XIY,(XWA+0x0a)                                    ; FB7131  a8 0a 25
	ld (xiz-4), xiy                                      ; FB7134  be fc 65
.LFB7137:
	ld XBC,XIX                                           ; FB7137  ec 89
	cp	xbc, (xiz-4)                                 ; FB7139  ae fc f1
	jr z, .LFB7146                                       ; FB713C  66 08
	ld C,(XIX)                                           ; FB713E  84 23
	add H,C                                              ; FB7140  cb 86
	inc 1,XIX                                            ; FB7142  ec 61
	jr .LFB7137                                          ; FB7144  68 f1
.LFB7146:
	ld C,H                                               ; FB7146  ce 8b
	extz BC                                              ; FB7148  d9 12
	sub WA,WA                                            ; FB714A  d8 a0
	sub WA,BC                                            ; FB714C  d9 a0
	res 0x07,A                                           ; FB714E  c9 30 07
	ld (xiz-6), a                                        ; FB7151  be fa 41
	pushw 0x02                                           ; FB7154  0b 02 00
	lda xbc, (xiz-6)                                     ; FB7157  be fa 31
	push XBC                                             ; FB715A  39
	calr SysExTx_Append                                      ; FB715B  1e c6 fd
	inc 6,XSP                                            ; FB715E  ef 66
	pop XIX                                              ; FB7160  5c
	popw hl                                              ; FB7161  4b
	unlk XIZ                                             ; FB7162  ee 0d
	ret                                                  ; FB7164  0e
; SysExTx_SendFrameMidi1(buf): SysExTx_PatchModelByteVariant2, then 0x20-byte chunks into ring 0x601432 (T_Ring601432_PutBlock + T_MIDI_PostSendWork): MIDI 1 only.
SysExTx_SendFrameMidi1:
	link XIZ,0x0000                                      ; FB7165  ee 0c 00 00
	pushw hl                                             ; FB7169  2b
	push XIX                                             ; FB716A  3c
	ld XBC,(XIZ+0x08)                                    ; FB716B  ae 08 21
	ld HL,(XBC)                                          ; FB716E  91 23
	ld (0x9b:8), 0x00:io                                      ; FB7170  08 9b 00
	push XBC                                             ; FB7173  39
	calr SysExTx_PatchModelByteVariant2                                          ; FB7174  1e ee ed
	ld XIX,(XIZ+0x08)                                    ; FB7177  ae 08 24
	add XIX,0x0000000e                                   ; FB717A  ec c8 0e 00 00 00
	pop XIY                                              ; FB7180  5d
	jr .LFB71A0                                          ; FB7181  68 1d
.LFB7183:
	ei 0x06                                              ; FB7183  06 06
	push XIX                                             ; FB7185  3c
	pushw 0x20                                           ; FB7186  0b 20 00
	call T_Ring601432_PutBlock                           ; FB7189  1d f8 1d f4
	call T_MIDI_PostSendWork                             ; FB718D  1d 24 07 f4
	inc 6,XSP                                            ; FB7191  ef 66
	ei 0x00                                              ; FB7193  06 00
	ldw bc, 0x20                                         ; FB7195  31 20 00
	sub HL,BC                                            ; FB7198  d9 a3
	add XIX,0x00000020                                   ; FB719A  ec c8 20 00 00 00
.LFB71A0:
	cp HL,0x0020                                         ; FB71A0  db cf 20 00
	jr ugt, .LFB7183                                     ; FB71A4  6b dd
	ei 0x06                                              ; FB71A6  06 06
	push XIX                                             ; FB71A8  3c
	pushw hl                                             ; FB71A9  2b
	call T_Ring601432_PutBlock                           ; FB71AA  1d f8 1d f4
	call T_MIDI_PostSendWork                             ; FB71AE  1d 24 07 f4
	inc 6,XSP                                            ; FB71B2  ef 66
	ei 0x00                                              ; FB71B4  06 00
	pop XIX                                              ; FB71B6  5c
	popw hl                                              ; FB71B7  4b
	unlk XIZ                                             ; FB71B8  ee 0d
	ret                                                  ; FB71BA  0e
; SysExTx_SendFrameBothPorts(buf): as SysExTx_SendFrameMidi1, each chunk also into ring 0x60153C (T_Ring60153C_PutBlock + T_MIDI_PostSendWork_PortB).
SysExTx_SendFrameBothPorts:
	link XIZ,0x0000                                      ; FB71BB  ee 0c 00 00
	pushw hl                                             ; FB71BF  2b
	push XIX                                             ; FB71C0  3c
	ld XBC,(XIZ+0x08)                                    ; FB71C1  ae 08 21
	ld HL,(XBC)                                          ; FB71C4  91 23
	ld (0x9b:8), 0x00:io                                      ; FB71C6  08 9b 00
	push XBC                                             ; FB71C9  39
	calr SysExTx_PatchModelByteVariant2                                          ; FB71CA  1e 98 ed
	ld XIX,(XIZ+0x08)                                    ; FB71CD  ae 08 24
	add XIX,0x0000000e                                   ; FB71D0  ec c8 0e 00 00 00
	pop XIY                                              ; FB71D6  5d
	jr .LFB7204                                          ; FB71D7  68 2b
.LFB71D9:
	ei 0x06                                              ; FB71D9  06 06
	push XIX                                             ; FB71DB  3c
	pushw 0x20                                           ; FB71DC  0b 20 00
	call T_Ring601432_PutBlock                           ; FB71DF  1d f8 1d f4
	call T_MIDI_PostSendWork                             ; FB71E3  1d 24 07 f4
	push XIX                                             ; FB71E7  3c
	pushw 0x20                                           ; FB71E8  0b 20 00
	call T_Ring60153C_PutBlock                           ; FB71EB  1d 1c 1e f4
	call T_MIDI_PostSendWork_PortB                       ; FB71EF  1d 30 07 f4
	inc 8,XSP                                            ; FB71F3  ef 60
	inc 4,XSP                                            ; FB71F5  ef 64
	ei 0x00                                              ; FB71F7  06 00
	ldw bc, 0x20                                         ; FB71F9  31 20 00
	sub HL,BC                                            ; FB71FC  d9 a3
	add XIX,0x00000020                                   ; FB71FE  ec c8 20 00 00 00
.LFB7204:
	cp HL,0x0020                                         ; FB7204  db cf 20 00
	jr ugt, .LFB71D9                                     ; FB7208  6b cf
	ei 0x06                                              ; FB720A  06 06
	push XIX                                             ; FB720C  3c
	pushw hl                                             ; FB720D  2b
	call T_Ring601432_PutBlock                           ; FB720E  1d f8 1d f4
	call T_MIDI_PostSendWork                             ; FB7212  1d 24 07 f4
	push XIX                                             ; FB7216  3c
	pushw hl                                             ; FB7217  2b
	call T_Ring60153C_PutBlock                           ; FB7218  1d 1c 1e f4
	call T_MIDI_PostSendWork_PortB                       ; FB721C  1d 30 07 f4
	inc 8,XSP                                            ; FB7220  ef 60
	inc 4,XSP                                            ; FB7222  ef 64
	ei 0x00                                              ; FB7224  06 00
	pop XIX                                              ; FB7226  5c
	popw hl                                              ; FB7227  4b
	unlk XIZ                                             ; FB7228  ee 0d
	ret                                                  ; FB722A  0e
	link XIZ,0xfff4                                      ; FB722B  ee 0c f4 ff
	pushw hl                                             ; FB722F  2b
	push XIX                                             ; FB7230  3c
	ld XIX,(XIZ+0x08)                                    ; FB7231  ae 08 24
	ld C,(XIX)                                           ; FB7234  84 23
	ld H,C                                               ; FB7236  cb 8e
	ld XBC,(XIZ+0x0c)                                    ; FB7238  ae 0c 21
	ld (XBC),H                                           ; FB723B  b1 46
	ld XBC,(XIZ+0x0c)                                    ; FB723D  ae 0c 21
	inc 1,XBC                                            ; FB7240  e9 61
	ld (xiz-4), xbc                                      ; FB7242  be fc 61
	ld A,(XIX+0x01)                                      ; FB7245  8c 01 21
	ld (XBC),A                                           ; FB7248  b1 41
	ld xbc, (xiz-4)                                      ; FB724A  ae fc 21
	inc 1,XBC                                            ; FB724D  e9 61
	ld (xiz-8), xbc                                      ; FB724F  be f8 61
	ld A,(XIX+0x02)                                      ; FB7252  8c 02 21
	ld (XBC),A                                           ; FB7255  b1 41
	ld xbc, (xiz-4)                                      ; FB7257  ae fc 21
	inc 2,XBC                                            ; FB725A  e9 62
	ld (xiz-12), xbc                                     ; FB725C  be f4 61
	ld A,(XIX+0x03)                                      ; FB725F  8c 03 21
	ld (XBC),A                                           ; FB7262  b1 41
	ld xbc, (xiz-4)                                      ; FB7264  ae fc 21
	ld (XBC+0x03),0xff                                   ; FB7267  b9 03 00 ff
	pop XIX                                              ; FB726B  5c
	popw hl                                              ; FB726C  4b
	unlk XIZ                                             ; FB726D  ee 0d
	ret                                                  ; FB726F  0e
; StagedQueue_ReadRecord(p): XIY = the 4-byte record {number, offset, value, mask} at p (number 0xFF = end).
StagedQueue_ReadRecord:
	link XIZ,0xfff8                                      ; FB7270  ee 0c f8 ff
	pushw hl                                             ; FB7274  2b
	push XIX                                             ; FB7275  3c
	lda xix, (xiz-4)                                     ; FB7276  be fc 34
	ld XBC,(XIZ+0x08)                                    ; FB7279  ae 08 21
	ld (xiz-8), xbc                                      ; FB727C  be f8 61
	sub XWA,XWA                                          ; FB727F  e8 a0
	inc 1,XWA                                            ; FB7281  e8 61
	add (XIZ+0x08),XWA                                   ; FB7283  ae 08 88
	ld H,(XBC)                                           ; FB7286  81 26
	ld (XIX),H                                           ; FB7288  b4 46
	cp H,0xff                                            ; FB728A  ce cf ff
; (sub_FB728D removed 2026-10-04: no code names it and the line above falls through into it -- part of StagedQueue_ReadRecord;
;  notes/prom_a_stray_label_removal.py)
	jr z, .LFB72AD                                       ; FB728D  66 1e
	ld XBC,(XIZ+0x08)                                    ; FB728F  ae 08 21
	ld A,(XBC)                                           ; FB7292  81 21
	ld (XIX+0x01),A                                      ; FB7294  bc 01 41
	ld XBC,(XIZ+0x08)                                    ; FB7297  ae 08 21
	inc 1,XBC                                            ; FB729A  e9 61
	ld (xiz-8), xbc                                      ; FB729C  be f8 61
	ld A,(XBC)                                           ; FB729F  81 21
	ld (XIX+0x02),A                                      ; FB72A1  bc 02 41
	ld xbc, (xiz-8)                                      ; FB72A4  ae f8 21
	ld A,(XBC+0x01)                                      ; FB72A7  89 01 21
	ld (XIX+0x03),A                                      ; FB72AA  bc 03 41
.LFB72AD:
	ld xiy, (xiz-4)                                      ; FB72AD  ae fc 25
	pop XIX                                              ; FB72B0  5c
	popw hl                                              ; FB72B1  4b
	unlk XIZ                                             ; FB72B2  ee 0d
	ret                                                  ; FB72B4  0e
; SysExRx_UnpackBody: join nibble pairs from the receive cursor (buf+6) into (0x60FD18)++, (0x60FD10) and (0x60FD20) -= 1 each,
;   up to 3 bytes before the write cursor; remaining (0x60FD20) reaching 0 first -> status 0x16 (memory full).
SysExRx_UnpackBody:
	link XIZ,0xffe8                                      ; FB72B5  ee 0c e8 ff
	pushw hl                                             ; FB72B9  2b
	push XIX                                             ; FB72BA  3c
	lda xix, (0x60fc80:24)                               ; FB72BB  f2 80 fc 60 34
	ld XBC,(XIX)                                         ; FB72C0  a4 21
	ld WA,(XBC)                                          ; FB72C2  91 20
	cp wa, 0x00:i3                                         ; FB72C4  d8 d8
	jrl z, .LFB7360                                      ; FB72C6  76 97 00
.LFB72C9:
	ld XBC,(XIX)                                         ; FB72C9  a4 21
	ld XWA,(XBC+0x06)                                    ; FB72CB  a9 06 20
	ld (xiz-4), xwa                                      ; FB72CE  be fc 60
	inc 1,XWA                                            ; FB72D1  e8 61
	ld (xiz-8), xwa                                      ; FB72D3  be f8 60
	ld XBC,(XIX)                                         ; FB72D6  a4 21
	ld (XBC+0x06),XWA                                    ; FB72D8  b9 06 60
	ld xbc, (xiz-4)                                      ; FB72DB  ae fc 21
	ld A,(XBC)                                           ; FB72DE  81 21
	ld H,A                                               ; FB72E0  c9 8e
	sll h, 0x04                                          ; FB72E2  ce ee 04
	ld XBC,(XIX)                                         ; FB72E5  a4 21
	ld XWA,(XBC+0x06)                                    ; FB72E7  a9 06 20
	ld (xiz-12), xwa                                     ; FB72EA  be f4 60
	inc 1,XWA                                            ; FB72ED  e8 61
	ld (xiz-16), xwa                                     ; FB72EF  be f0 60
	ld XBC,(XIX)                                         ; FB72F2  a4 21
	ld (XBC+0x06),XWA                                    ; FB72F4  b9 06 60
	ld xbc, (xiz-12)                                     ; FB72F7  ae f4 21
	ld A,(XBC)                                           ; FB72FA  81 21
	and A,0x0f                                           ; FB72FC  c9 cc 0f
	ld L,A                                               ; FB72FF  c9 8f
	xor L,H                                              ; FB7301  ce d7
	ld xbc, (0x60fd18:24)                               ; FB7303  e2 18 fd 60 21
	ld (xiz-20), xbc                                     ; FB7308  be ec 61
	sub XWA,XWA                                          ; FB730B  e8 a0
	inc 1,XWA                                            ; FB730D  e8 61
	add (0x60fd18:24), xwa                              ; FB730F  e2 18 fd 60 88
	ld xbc, (xiz-20)                                     ; FB7314  ae ec 21
	ld (XBC),L                                           ; FB7317  b1 47
	sub XBC,XBC                                          ; FB7319  e9 a1
	inc 1,XBC                                            ; FB731B  e9 61
	sub (0x60fd10:24), xbc                           ; FB731D  e2 10 fd 60 a9
	sub XBC,XBC                                          ; FB7322  e9 a1
	inc 1,XBC                                            ; FB7324  e9 61
	sub (0x60fd20:24), xbc                           ; FB7326  e2 20 fd 60 a9
	ld XBC,(XIX)                                         ; FB732B  a4 21
	ld XWA,(XBC+0x0a)                                    ; FB732D  a9 0a 20
	dec 3,XWA                                            ; FB7330  e8 6b
	ld (xiz-24), xwa                                     ; FB7332  be e8 60
	ld XBC,(XIX)                                         ; FB7335  a4 21
	ld XIY,(XBC+0x06)                                    ; FB7337  a9 06 25
	cp XIY,XWA                                           ; FB733A  e8 f5
	jr c, .LFB7342                                       ; FB733C  67 04
	sub WA,WA                                            ; FB733E  d8 a0
	jr .LFB7360                                          ; FB7340  68 1e
.LFB7342:
	ld xbc, (0x60fd20:24)                               ; FB7342  e2 20 fd 60 21
	or XBC,XBC                                           ; FB7347  e9 e1
	jrl nz, .LFB72C9                                     ; FB7349  7e 7d ff
	pushw 0x16                                           ; FB734C  0b 16 00
	pushw 0x04                                           ; FB734F  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB7352  e2 d8 fc 60 21
	push XBC                                             ; FB7357  39
	calr U8Rec16_SetField                                          ; FB7358  1e be ee
	inc 8,XSP                                            ; FB735B  ef 60
	ldw wa, 0xffff                                       ; FB735D  30 ff ff
.LFB7360:
	pop XIX                                              ; FB7360  5c
	popw hl                                              ; FB7361  4b
	unlk XIZ                                             ; FB7362  ee 0d
	ret                                                  ; FB7364  0e
; SysExRx_UnpackBodyToBlock: SysExRx_UnpackBody that also counts the block fill in (0x60FD3A).
SysExRx_UnpackBodyToBlock:
	link XIZ,0xffe8                                      ; FB7365  ee 0c e8 ff
	pushw hl                                             ; FB7369  2b
	push XIX                                             ; FB736A  3c
	lda xix, (0x60fc80:24)                               ; FB736B  f2 80 fc 60 34
	ld XBC,(XIX)                                         ; FB7370  a4 21
	ld WA,(XBC)                                          ; FB7372  91 20
	cp wa, 0x00:i3                                         ; FB7374  d8 d8
	jrl z, .LFB7415                                      ; FB7376  76 9c 00
.LFB7379:
	ld XBC,(XIX)                                         ; FB7379  a4 21
	ld XWA,(XBC+0x06)                                    ; FB737B  a9 06 20
	ld (xiz-4), xwa                                      ; FB737E  be fc 60
	inc 1,XWA                                            ; FB7381  e8 61
	ld (xiz-8), xwa                                      ; FB7383  be f8 60
	ld XBC,(XIX)                                         ; FB7386  a4 21
	ld (XBC+0x06),XWA                                    ; FB7388  b9 06 60
	ld xbc, (xiz-4)                                      ; FB738B  ae fc 21
	ld A,(XBC)                                           ; FB738E  81 21
	ld H,A                                               ; FB7390  c9 8e
	sll h, 0x04                                          ; FB7392  ce ee 04
	ld XBC,(XIX)                                         ; FB7395  a4 21
	ld XWA,(XBC+0x06)                                    ; FB7397  a9 06 20
	ld (xiz-12), xwa                                     ; FB739A  be f4 60
	inc 1,XWA                                            ; FB739D  e8 61
	ld (xiz-16), xwa                                     ; FB739F  be f0 60
	ld XBC,(XIX)                                         ; FB73A2  a4 21
	ld (XBC+0x06),XWA                                    ; FB73A4  b9 06 60
	ld xbc, (xiz-12)                                     ; FB73A7  ae f4 21
	ld A,(XBC)                                           ; FB73AA  81 21
	and A,0x0f                                           ; FB73AC  c9 cc 0f
	ld L,A                                               ; FB73AF  c9 8f
	xor L,H                                              ; FB73B1  ce d7
	ld xbc, (0x60fd18:24)                               ; FB73B3  e2 18 fd 60 21
	ld (xiz-20), xbc                                     ; FB73B8  be ec 61
	sub XWA,XWA                                          ; FB73BB  e8 a0
	inc 1,XWA                                            ; FB73BD  e8 61
	add (0x60fd18:24), xwa                              ; FB73BF  e2 18 fd 60 88
	ld xbc, (xiz-20)                                     ; FB73C4  ae ec 21
	ld (XBC),L                                           ; FB73C7  b1 47
	sub XBC,XBC                                          ; FB73C9  e9 a1
	inc 1,XBC                                            ; FB73CB  e9 61
	sub (0x60fd10:24), xbc                           ; FB73CD  e2 10 fd 60 a9
	sub XBC,XBC                                          ; FB73D2  e9 a1
	inc 1,XBC                                            ; FB73D4  e9 61
	sub (0x60fd20:24), xbc                           ; FB73D6  e2 20 fd 60 a9
	incw 0x01, (0x60fd3a:24)                          ; FB73DB  d2 3a fd 60 61
	ld XBC,(XIX)                                         ; FB73E0  a4 21
	ld XWA,(XBC+0x0a)                                    ; FB73E2  a9 0a 20
	dec 3,XWA                                            ; FB73E5  e8 6b
	ld (xiz-24), xwa                                     ; FB73E7  be e8 60
	ld XBC,(XIX)                                         ; FB73EA  a4 21
	ld XIY,(XBC+0x06)                                    ; FB73EC  a9 06 25
	cp XIY,XWA                                           ; FB73EF  e8 f5
	jr c, .LFB73F7                                       ; FB73F1  67 04
	sub WA,WA                                            ; FB73F3  d8 a0
	jr .LFB7415                                          ; FB73F5  68 1e
.LFB73F7:
	ld xbc, (0x60fd20:24)                               ; FB73F7  e2 20 fd 60 21
	or XBC,XBC                                           ; FB73FC  e9 e1
	jrl nz, .LFB7379                                     ; FB73FE  7e 78 ff
	pushw 0x16                                           ; FB7401  0b 16 00
	pushw 0x04                                           ; FB7404  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB7407  e2 d8 fc 60 21
	push XBC                                             ; FB740C  39
	calr U8Rec16_SetField                                          ; FB740D  1e 09 ee
	inc 8,XSP                                            ; FB7410  ef 60
	ldw wa, 0xffff                                       ; FB7412  30 ff ff
.LFB7415:
	pop XIX                                              ; FB7415  5c
	popw hl                                              ; FB7416  4b
	unlk XIZ                                             ; FB7417  ee 0d
	ret                                                  ; FB7419  0e
; SysExRx_SetRunTimeSize: size = field 0x0C << 14 | field 0x0D << 7 | field 0x0E; into the receive descriptors (0x60FD08) and (0x60FD18).
SysExRx_SetRunTimeSize:
	link XIZ,0xffec                                      ; FB741A  ee 0c ec ff
	push XIX                                             ; FB741E  3c
	lda xix, (0x60fd08:24)                               ; FB741F  f2 08 fd 60 34
	pushw 0x0c                                           ; FB7424  0b 0c 00
	ld xbc, (0x60fcd8:24)                               ; FB7427  e2 d8 fc 60 21
	push XBC                                             ; FB742C  39
	calr U8Rec16_GetField                                          ; FB742D  1e a3 ee
	extz WA                                              ; FB7430  d8 12
	extz XWA                                             ; FB7432  e8 12
	sll xwa, 0x0e                                        ; FB7434  e8 ee 0e
	ld (xiz-4), xwa                                      ; FB7437  be fc 60
	pushw 0x0d                                           ; FB743A  0b 0d 00
	ld xbc, (0x60fcd8:24)                               ; FB743D  e2 d8 fc 60 21
	push XBC                                             ; FB7442  39
	calr U8Rec16_GetField                                          ; FB7443  1e 8d ee
	extz WA                                              ; FB7446  d8 12
	extz XWA                                             ; FB7448  e8 12
	sll xwa, 0x07                                        ; FB744A  e8 ee 07
	or	xwa, (xiz-4)                                 ; FB744D  ae fc e0
	ld (xiz-8), xwa                                      ; FB7450  be f8 60
	pushw 0x0e                                           ; FB7453  0b 0e 00
	ld xbc, (0x60fcd8:24)                               ; FB7456  e2 d8 fc 60 21
	push XBC                                             ; FB745B  39
	calr U8Rec16_GetField                                          ; FB745C  1e 74 ee
	extz WA                                              ; FB745F  d8 12
	extz XWA                                             ; FB7461  e8 12
	or	xwa, (xiz-8)                                 ; FB7463  ae f8 e0
	ld (xiz-12), xwa                                     ; FB7466  be f4 60
	ld XBC,(XIX)                                         ; FB7469  a4 21
	ld (xiz-16), xbc                                     ; FB746B  be f0 61
	ld (xiz-20), xwa                                     ; FB746E  be ec 60
	add XBC,XWA                                          ; FB7471  e8 81
	ld (XIX+0x04),XBC                                    ; FB7473  bc 04 61
	ld xbc, (xiz-12)                                     ; FB7476  ae f4 21
	ld (XIX+0x08),XBC                                    ; FB7479  bc 08 61
	ld xbc, (0x60fd18:24)                               ; FB747C  e2 18 fd 60 21
	add	xbc, (xiz-20)                                ; FB7481  ae ec 81
	ld (0x60fd1c:24), xbc                               ; FB7484  f2 1c fd 60 61
	ld xbc, (xiz-12)                                     ; FB7489  ae f4 21
	ld (0x60fd20:24), xbc                               ; FB748C  f2 20 fd 60 61
	add XSP,0x00000012                                   ; FB7491  ef c8 12 00 00 00
	pop XIX                                              ; FB7497  5c
	unlk XIZ                                             ; FB7498  ee 0d
	ret                                                  ; FB749A  0e
; SysExXfer_SetJobTotal_TotalKeyboard(desc): {start, end, size} of the whole TOTAL KEYBOARD job, the sequencer part at its run-time size.
SysExXfer_SetJobTotal_TotalKeyboard:
	link XIZ,0xfff8                                      ; FB749B  ee 0c f8 ff
	pushw hl                                             ; FB749F  2b
	push XIX                                             ; FB74A0  3c
	ld XIX,(XIZ+0x08)                                    ; FB74A1  ae 08 24
	lda xbc, (0x7600:16)                                ; FB74A4  f1 00 76 31
	ld (XIX),XBC                                         ; FB74A8  b4 61
	calr SysExDump_SequencerUsedBytes                                      ; FB74AA  1e 9b 02
	ld (xiz-4), xiy                                      ; FB74AD  be fc 65
	ldw hl, Combination_Current                                       ; FB74B0  33 20 76
	ldw bc, 0x7f7e                                       ; FB74B3  31 7e 7f
	sub BC,HL                                            ; FB74B6  db a1
	exts XBC                                             ; FB74B8  e9 13
	add XBC,XIY                                          ; FB74BA  ed 81
	add XBC,0x00048422                                   ; FB74BC  e9 c8 22 84 04 00
	ld (XIX+0x08),XBC                                    ; FB74C2  bc 08 61
	ld XBC,(XIX+0x08)                                    ; FB74C5  ac 08 21
	ld (xiz-8), xbc                                      ; FB74C8  be f8 61
	ld XWA,(XIX)                                         ; FB74CB  a4 20
	add XWA,XBC                                          ; FB74CD  e9 80
	ld (XIX+0x04),XWA                                    ; FB74CF  bc 04 60
	pop XIX                                              ; FB74D2  5c
	popw hl                                              ; FB74D3  4b
	unlk XIZ                                             ; FB74D4  ee 0d
	ret                                                  ; FB74D6  0e
; SysExXfer_SetJobTotal_SystemPartMidi(desc): {0x7600, .., size} of SYSTEM,PART & MIDI.
SysExXfer_SetJobTotal_SystemPartMidi:
	link XIZ,0xfffc                                      ; FB74D7  ee 0c fc ff
	pushw hl                                             ; FB74DB  2b
	pushw de                                             ; FB74DC  2a
	push XIX                                             ; FB74DD  3c
	ld XIX,(XIZ+0x08)                                    ; FB74DE  ae 08 24
	lda xbc, (0x7600:16)                                ; FB74E1  f1 00 76 31
	ld (XIX),XBC                                         ; FB74E5  b4 61
	lda xbc, (0x7600:16)                                ; FB74E7  f1 00 76 31
	ld (xiz-4), xbc                                      ; FB74EB  be fc 61
	ldw hl, Combination_Current                                       ; FB74EE  33 20 76
	ldw wa, 0x7f7e                                       ; FB74F1  30 7e 7f
	ld DE,WA                                             ; FB74F4  d8 8a
	sub DE,HL                                            ; FB74F6  db a2
	ld WA,DE                                             ; FB74F8  da 88
	exts XWA                                             ; FB74FA  e8 13
	add XWA,0x00000022                                   ; FB74FC  e8 c8 22 00 00 00
	add XBC,XWA                                          ; FB7502  e8 81
	ld (XIX+0x04),XBC                                    ; FB7504  bc 04 61
	ld BC,DE                                             ; FB7507  da 89
	exts XBC                                             ; FB7509  e9 13
	add XBC,0x00000022                                   ; FB750B  e9 c8 22 00 00 00
	ld (XIX+0x08),XBC                                    ; FB7511  bc 08 61
	pop XIX                                              ; FB7514  5c
	popw de                                              ; FB7515  4a
	popw hl                                              ; FB7516  4b
	unlk XIZ                                             ; FB7517  ee 0d
	ret                                                  ; FB7519  0e
; SysExXfer_SetJobTotal_Sound(desc): {0x60A000, 0x64A000, 0x40000}.
SysExXfer_SetJobTotal_Sound:
	link XIZ,0x0000                                      ; FB751A  ee 0c 00 00
	push XIX                                             ; FB751E  3c
	ld XIX,(XIZ+0x08)                                    ; FB751F  ae 08 24
	lda xbc, (0x60a000:24)                               ; FB7522  f2 00 a0 60 31
	ld (XIX),XBC                                         ; FB7527  b4 61
	lda xbc, (0x64a000:24)                               ; FB7529  f2 00 a0 64 31
	ld (XIX+0x04),XBC                                    ; FB752E  bc 04 61
	ld XBC,0x00040000                                    ; FB7531  41 00 00 04 00
	ld (XIX+0x08),XBC                                    ; FB7536  bc 08 61
	pop XIX                                              ; FB7539  5c
	unlk XIZ                                             ; FB753A  ee 0d
	ret                                                  ; FB753C  0e
SysExXfer_SetJobTotal_Sound_Nop:
	ret                                                  ; FB753D  0e
; SysExXfer_SetJobTotal_Sequencer(desc): {0x603400, 0x65C400, 0x59000}; on a SEND (bit 6 of (0x60FD40)) part 3 at its run-time size.
SysExXfer_SetJobTotal_Sequencer:
	link XIZ,0xfff8                                      ; FB753E  ee 0c f8 ff
	push XIX                                             ; FB7542  3c
	ld XIX,(XIZ+0x08)                                    ; FB7543  ae 08 24
	lda xbc, (0x603400:24)                               ; FB7546  f2 00 34 60 31
	ld (XIX),XBC                                         ; FB754B  b4 61
	lda xbc, (0x65c400:24)                               ; FB754D  f2 00 c4 65 31
	ld (XIX+0x04),XBC                                    ; FB7552  bc 04 61
	ld XBC,0x00059000                                    ; FB7555  41 00 90 05 00
	ld (XIX+0x08),XBC                                    ; FB755A  bc 08 61
	bit	6, (0x60fd40:24)                             ; FB755D  f2 40 fd 60 ce
	jr z, .LFB7586                                       ; FB7562  66 22
	calr SysExDump_SequencerUsedBytes                                      ; FB7564  1e e1 01
	ld (xiz-4), xiy                                      ; FB7567  be fc 65
	add XIY,0x00008400                                   ; FB756A  ed c8 00 84 00 00
	ld (xiz-8), xiy                                      ; FB7570  be f8 65
	ld XBC,(XIX)                                         ; FB7573  a4 21
	add XBC,XIY                                          ; FB7575  ed 81
	ld (XIX+0x04),XBC                                    ; FB7577  bc 04 61
	ld xbc, (xiz-4)                                      ; FB757A  ae fc 21
	add XBC,0x00008400                                   ; FB757D  e9 c8 00 84 00 00
	ld (XIX+0x08),XBC                                    ; FB7583  bc 08 61
.LFB7586:
	pop XIX                                              ; FB7586  5c
	unlk XIZ                                             ; FB7587  ee 0d
	ret                                                  ; FB7589  0e
; SysExXfer_SetJobTotal_Combination(desc): {0x60A000 - 0x300, + 0x16300, 0x16300}.
SysExXfer_SetJobTotal_Combination:
	link XIZ,0xfffc                                      ; FB758A  ee 0c fc ff
	push XIX                                             ; FB758E  3c
	ld XIX,(XIZ+0x08)                                    ; FB758F  ae 08 24
	lda xbc, (0x60a000:24)                               ; FB7592  f2 00 a0 60 31
	sub XBC,0x00000300                                   ; FB7597  e9 ca 00 03 00 00
	ld (xiz-4), xbc                                      ; FB759D  be fc 61
	ld (XIX),XBC                                         ; FB75A0  b4 61
	ld xbc, (xiz-4)                                      ; FB75A2  ae fc 21
	add XBC,0x00016300                                   ; FB75A5  e9 c8 00 63 01 00
	ld (XIX+0x04),XBC                                    ; FB75AB  bc 04 61
	ld XBC,0x00016300                                    ; FB75AE  41 00 63 01 00
	ld (XIX+0x08),XBC                                    ; FB75B3  bc 08 61
	pop XIX                                              ; FB75B6  5c
	unlk XIZ                                             ; FB75B7  ee 0d
	ret                                                  ; FB75B9  0e
; SysExXfer_SetPart_SystemPart1(desc): {0x7600, 0x7620, 0x20}.
SysExXfer_SetPart_SystemPart1:
	link XIZ,0xfffc                                      ; FB75BA  ee 0c fc ff
	push XIX                                             ; FB75BE  3c
	ld XIX,(XIZ+0x08)                                    ; FB75BF  ae 08 24
	ldw bc, 0x7600                                       ; FB75C2  31 00 76
	extz XBC                                             ; FB75C5  e9 12
	ld (xiz-4), xbc                                      ; FB75C7  be fc 61
	ld (XIX),XBC                                         ; FB75CA  b4 61
	ld xbc, (xiz-4)                                      ; FB75CC  ae fc 21
	add XBC,0x00000020                                   ; FB75CF  e9 c8 20 00 00 00
	ld (XIX+0x04),XBC                                    ; FB75D5  bc 04 61
	ld XBC,0x00000020                                    ; FB75D8  41 20 00 00 00
	ld (XIX+0x08),XBC                                    ; FB75DD  bc 08 61
	pop XIX                                              ; FB75E0  5c
	unlk XIZ                                             ; FB75E1  ee 0d
	ret                                                  ; FB75E3  0e
; SysExXfer_SetPart_SystemPart2(desc): source 0x7620 .. 0x7F7E + 2 (2400 bytes).
SysExXfer_SetPart_SystemPart2:
	link XIZ,0xfffa                                      ; FB75E4  ee 0c fa ff
	pushw hl                                             ; FB75E8  2b
	pushw de                                             ; FB75E9  2a
	push XIX                                             ; FB75EA  3c
	ld XIX,(XIZ+0x08)                                    ; FB75EB  ae 08 24
	ldw hl, 0x7600                                       ; FB75EE  33 00 76
	ldw de, Combination_Current                                       ; FB75F1  32 20 76
	ld BC,DE                                             ; FB75F4  da 89
	sub BC,HL                                            ; FB75F6  db a1
	ld (xiz-2), bc                                       ; FB75F8  be fe 51
	ldw wa, 0x7600                                       ; FB75FB  30 00 76
	add WA,BC                                            ; FB75FE  d9 80
	extz XWA                                             ; FB7600  e8 12
	ld (xiz-6), xwa                                      ; FB7602  be fa 60
	ld (XIX),XWA                                         ; FB7605  b4 60
	ldw bc, 0x7f7e                                       ; FB7607  31 7e 7f
	ld HL,BC                                             ; FB760A  d9 8b
	sub HL,DE                                            ; FB760C  da a3
	ld BC,HL                                             ; FB760E  db 89
	exts XBC                                             ; FB7610  e9 13
	inc 2,XBC                                            ; FB7612  e9 62
	add	xbc, (xiz-6)                                 ; FB7614  ae fa 81
	ld (XIX+0x04),XBC                                    ; FB7617  bc 04 61
	ld BC,HL                                             ; FB761A  db 89
	exts XBC                                             ; FB761C  e9 13
	inc 2,XBC                                            ; FB761E  e9 62
	ld (XIX+0x08),XBC                                    ; FB7620  bc 08 61
	pop XIX                                              ; FB7623  5c
	popw de                                              ; FB7624  4a
	popw hl                                              ; FB7625  4b
	unlk XIZ                                             ; FB7626  ee 0d
	ret                                                  ; FB7628  0e
; SysExXfer_SetPart_SoundOrphan(desc): {0x60A000, 0x60A000, 0}; used only by the uncalled transmitter at 0xFB248A and its receive twin.
SysExXfer_SetPart_SoundOrphan:
	link XIZ,0x0000                                      ; FB7629  ee 0c 00 00
	push XIX                                             ; FB762D  3c
	ld XIX,(XIZ+0x08)                                    ; FB762E  ae 08 24
	lda xbc, (0x60a000:24)                               ; FB7631  f2 00 a0 60 31
	ld (XIX),XBC                                         ; FB7636  b4 61
	lda xbc, (0x60a000:24)                               ; FB7638  f2 00 a0 60 31
	ld (XIX+0x04),XBC                                    ; FB763D  bc 04 61
	sub XBC,XBC                                          ; FB7640  e9 a1
	ld (XIX+0x08),XBC                                    ; FB7642  bc 08 61
	pop XIX                                              ; FB7645  5c
	unlk XIZ                                             ; FB7646  ee 0d
	ret                                                  ; FB7648  0e
; SysExXfer_SetPart_SoundBlock(desc): {0x60A000, 0x60C000, 0x2000}, one of the 32 SOUND blocks.
SysExXfer_SetPart_SoundBlock:
	link XIZ,0x0000                                      ; FB7649  ee 0c 00 00
	push XIX                                             ; FB764D  3c
	ld XIX,(XIZ+0x08)                                    ; FB764E  ae 08 24
	lda xbc, (0x60a000:24)                               ; FB7651  f2 00 a0 60 31
	ld (XIX),XBC                                         ; FB7656  b4 61
	lda xbc, (0x60c000:24)                               ; FB7658  f2 00 c0 60 31
	ld (XIX+0x04),XBC                                    ; FB765D  bc 04 61
	ld XBC,0x00002000                                    ; FB7660  41 00 20 00 00
	ld (XIX+0x08),XBC                                    ; FB7665  bc 08 61
	pop XIX                                              ; FB7668  5c
	unlk XIZ                                             ; FB7669  ee 0d
	ret                                                  ; FB766B  0e
SysExXfer_SetPart_SoundBlock_Nop2:
	ret                                                  ; FB766C  0e
SysExXfer_SetPart_SoundBlock_Nop3:
	ret                                                  ; FB766D  0e
SysExXfer_SetPart_SoundBlock_Nop4:
	ret                                                  ; FB766E  0e
; SysExXfer_SetPart_Sequencer1(desc): {0x603400, 0x604000, 0xC00}.
SysExXfer_SetPart_Sequencer1:
	link XIZ,0x0000                                      ; FB766F  ee 0c 00 00
	push XIX                                             ; FB7673  3c
	ld XIX,(XIZ+0x08)                                    ; FB7674  ae 08 24
	lda xbc, (0x603400:24)                               ; FB7677  f2 00 34 60 31
	ld (XIX),XBC                                         ; FB767C  b4 61
	lda xbc, (0x604000:24)                               ; FB767E  f2 00 40 60 31
	ld (XIX+0x04),XBC                                    ; FB7683  bc 04 61
	ld XBC,0x00000c00                                    ; FB7686  41 00 0c 00 00
	ld (XIX+0x08),XBC                                    ; FB768B  bc 08 61
	pop XIX                                              ; FB768E  5c
	unlk XIZ                                             ; FB768F  ee 0d
	ret                                                  ; FB7691  0e
; SysExXfer_SetPart_Sequencer2(desc): {0x610000, 0x617800, 0x7800}.
SysExXfer_SetPart_Sequencer2:
	link XIZ,0x0000                                      ; FB7692  ee 0c 00 00
	push XIX                                             ; FB7696  3c
	ld XIX,(XIZ+0x08)                                    ; FB7697  ae 08 24
	lda xbc, (0x610000:24)                               ; FB769A  f2 00 00 61 31
	ld (XIX),XBC                                         ; FB769F  b4 61
	lda xbc, (0x617800:24)                               ; FB76A1  f2 00 78 61 31
	ld (XIX+0x04),XBC                                    ; FB76A6  bc 04 61
	ld XBC,0x00007800                                    ; FB76A9  41 00 78 00 00
	ld (XIX+0x08),XBC                                    ; FB76AE  bc 08 61
	pop XIX                                              ; FB76B1  5c
	unlk XIZ                                             ; FB76B2  ee 0d
	ret                                                  ; FB76B4  0e
; SysExXfer_SetPart_Sequencer3(desc): {0x617800, 0x668400, 0x50C00}; on a SEND the run-time size (SysExDump_SequencerUsedBytes).
SysExXfer_SetPart_Sequencer3:
	link XIZ,0xfffc                                      ; FB76B5  ee 0c fc ff
	push XIX                                             ; FB76B9  3c
	ld XIX,(XIZ+0x08)                                    ; FB76BA  ae 08 24
	lda xbc, (0x617800:24)                               ; FB76BD  f2 00 78 61 31
	ld (XIX),XBC                                         ; FB76C2  b4 61
	lda xbc, (0x668400:24)                               ; FB76C4  f2 00 84 66 31
	ld (XIX+0x04),XBC                                    ; FB76C9  bc 04 61
	ld XBC,0x00050c00                                    ; FB76CC  41 00 0c 05 00
	ld (XIX+0x08),XBC                                    ; FB76D1  bc 08 61
	bit	6, (0x60fd40:24)                             ; FB76D4  f2 40 fd 60 ce
	jr z, .LFB76EE                                       ; FB76D9  66 13
	calr SysExDump_SequencerUsedBytes                                      ; FB76DB  1e 6a 00
	ld (xiz-4), xiy                                      ; FB76DE  be fc 65
	ld XBC,(XIX)                                         ; FB76E1  a4 21
	add XBC,XIY                                          ; FB76E3  ed 81
	ld (XIX+0x04),XBC                                    ; FB76E5  bc 04 61
	ld xbc, (xiz-4)                                      ; FB76E8  ae fc 21
	ld (XIX+0x08),XBC                                    ; FB76EB  bc 08 61
.LFB76EE:
	pop XIX                                              ; FB76EE  5c
	unlk XIZ                                             ; FB76EF  ee 0d
	ret                                                  ; FB76F1  0e
; SysExXfer_SetPart_Combination1(desc): {0x60A000 - 0x300, 0x60A000, 0x300}.
SysExXfer_SetPart_Combination1:
	link XIZ,0xfffc                                      ; FB76F2  ee 0c fc ff
	push XIX                                             ; FB76F6  3c
	ld XIX,(XIZ+0x08)                                    ; FB76F7  ae 08 24
	lda xbc, (0x60a000:24)                               ; FB76FA  f2 00 a0 60 31
	sub XBC,0x00000300                                   ; FB76FF  e9 ca 00 03 00 00
	ld (xiz-4), xbc                                      ; FB7705  be fc 61
	ld (XIX),XBC                                         ; FB7708  b4 61
	ld xbc, (xiz-4)                                      ; FB770A  ae fc 21
	add XBC,0x00000300                                   ; FB770D  e9 c8 00 03 00 00
	ld (XIX+0x04),XBC                                    ; FB7713  bc 04 61
	ld XBC,0x00000300                                    ; FB7716  41 00 03 00 00
	ld (XIX+0x08),XBC                                    ; FB771B  bc 08 61
	pop XIX                                              ; FB771E  5c
	unlk XIZ                                             ; FB771F  ee 0d
	ret                                                  ; FB7721  0e
; SysExXfer_SetPart_CombinationBlock(desc): {0x60A000, 0x60B600, 0x1600}, one of the 16 COMBINATION blocks.
SysExXfer_SetPart_CombinationBlock:
	link XIZ,0x0000                                      ; FB7722  ee 0c 00 00
	push XIX                                             ; FB7726  3c
	ld XIX,(XIZ+0x08)                                    ; FB7727  ae 08 24
	lda xbc, (0x60a000:24)                               ; FB772A  f2 00 a0 60 31
	ld (XIX),XBC                                         ; FB772F  b4 61
	lda xbc, (0x60b600:24)                               ; FB7731  f2 00 b6 60 31
	ld (XIX+0x04),XBC                                    ; FB7736  bc 04 61
	ld XBC,0x00001600                                    ; FB7739  41 00 16 00 00
	ld (XIX+0x08),XBC                                    ; FB773E  bc 08 61
	pop XIX                                              ; FB7741  5c
	unlk XIZ                                             ; FB7742  ee 0d
	ret                                                  ; FB7744  0e
	sub XIY,XIY                                          ; FB7745  ed a5
	ret                                                  ; FB7747  0e
; SysExDump_SequencerUsedBytes: T_SysExDump_PrepareSequencerData, then XIY = 0x10 * (0x603452), the sequencer's own memory-use counter.
SysExDump_SequencerUsedBytes:
	push XDE                                             ; FB7748  3a
	push XHL                                             ; FB7749  3b
	push XIX                                             ; FB774A  3c
	push XIZ                                             ; FB774B  3e
	call T_SysExDump_PrepareSequencerData                                        ; FB774C  1d bc 14 f4
	pop XIZ                                              ; FB7750  5e
	pop XIX                                              ; FB7751  5c
	pop XHL                                              ; FB7752  5b
	pop XDE                                              ; FB7753  5a
	ldw bc, 0x10                                         ; FB7754  31 10 00
	mul	xbc, (0x603452:24)                           ; FB7757  d2 52 34 60 41
	ld XIY,XBC                                           ; FB775C  e9 8d
	ret                                                  ; FB775E  0e
; SysExRx_CheckMidiErrors: when MIDI_RX_Flags & 0x2C: Ring601646_InitIrqMasked, status 4, clear those flag bits.
SysExRx_CheckMidiErrors:
	ei 0x06                                              ; FB775F  06 06
	ld	c, (MIDI_RX_Flags:8)                                      ; FB7761  c0 9e 23
	and C,0x2c                                           ; FB7764  cb cc 2c
	jr z, .LFB7782                                       ; FB7767  66 19
	call Ring601646_InitIrqMasked                                      ; FB7769  1d 0d 7f fb
	pushw 0x04                                           ; FB776D  0b 04 00
	pushw 0x04                                           ; FB7770  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB7773  e2 d8 fc 60 21
	push XBC                                             ; FB7778  39
	calr U8Rec16_SetField                                          ; FB7779  1e 9d ea
	and	(MIDI_RX_Flags:8), 0xd3                               ; FB777C  c0 9e 3c d3
	inc 8,XSP                                            ; FB7780  ef 60
.LFB7782:
	ei 0x00                                              ; FB7782  06 00
	ret                                                  ; FB7784  0e
; SysExRx_CheckReplyTimeout(start): status 5 once Tick_Count - start exceeds 2500 ticks (1000 when bit 2 of (0x60FD40) is set).
SysExRx_CheckReplyTimeout:
	link XIZ,0x0000                                      ; FB7785  ee 0c 00 00
	pushw hl                                             ; FB7789  2b
	ldw hl, 0x09c4                                       ; FB778A  33 c4 09
	bit	2, (0x60fd40:24)                             ; FB778D  f2 40 fd 60 ca
	jr z, .LFB7797                                       ; FB7792  66 03
	ldw hl, 0x03e8                                       ; FB7794  33 e8 03
.LFB7797:
	ld	bc, (Tick_Count:8)                                 ; FB7797  d0 80 21
	sub BC,(XIZ+0x08)                                    ; FB779A  9e 08 a1
	cp BC,HL                                             ; FB779D  db f1
	jr le, .LFB77B2                                      ; FB779F  62 11
	pushw 0x05                                           ; FB77A1  0b 05 00
	pushw 0x04                                           ; FB77A4  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB77A7  e2 d8 fc 60 21
	push XBC                                             ; FB77AC  39
	calr U8Rec16_SetField                                          ; FB77AD  1e 69 ea
	inc 8,XSP                                            ; FB77B0  ef 60
.LFB77B2:
	popw hl                                              ; FB77B2  4b
	unlk XIZ                                             ; FB77B3  ee 0d
	ret                                                  ; FB77B5  0e
; ParamImage_WriteHeadersAndSnapshot: T_ParamImage_WriteRecordHeaders_Entry then T_ParamImage_SnapshotAll, preserving XDE/XHL/XIX/XIZ; called from
;   SysExSession_RecvSystemPart1.  Basis: body.
ParamImage_WriteHeadersAndSnapshot:
	push XDE                                             ; FB77B6  3a
	push XHL                                             ; FB77B7  3b
	push XIX                                             ; FB77B8  3c
	push XIZ                                             ; FB77B9  3e
	call T_ParamImage_WriteRecordHeaders_Entry                                        ; FB77BA  1d 24 02 f4
	call T_ParamImage_SnapshotAll                                        ; FB77BE  1d d8 01 f4
	pop XIZ                                              ; FB77C2  5e
	pop XIX                                              ; FB77C3  5c
	pop XHL                                              ; FB77C4  5b
	pop XDE                                              ; FB77C5  5a
	ret                                                  ; FB77C6  0e
; SysEx_Wait25Ticks: spin until Tick_Count has advanced 0x19 ticks (about 51 ms at 488.28 Hz).
SysEx_Wait25Ticks:
	pushw hl                                             ; FB77C7  2b
	ld	hl, (Tick_Count:8)                                 ; FB77C8  d0 80 23
.LFB77CB:
	ld	bc, (Tick_Count:8)                                 ; FB77CB  d0 80 21
	sub BC,HL                                            ; FB77CE  db a1
	cp BC,0x0019                                         ; FB77D0  d9 cf 19 00
	jr lt, .LFB77CB                                      ; FB77D4  61 f5
	popw hl                                              ; FB77D6  4b
	ret                                                  ; FB77D7  0e
; ------------------------------------------------------------------------------
; 0xFB77D8-0xFB77F2 -- IndexedTable_GetPtr
;
; ★ MOVED to maincpu/shared/indexed_table.s, ONE SOURCE included at BOTH of its
; sites: here and prom_b 0xF55321.  The two copies are byte-identical,
; every reference binds to the nearer of them, and the header that used to sit
; here is in that file, verbatim, under a banner saying it came from this one.
; Why the duplication exists at all -- and why the obvious explanation is wrong
; -- is measured by `python3 notes/maincpu_join_probe.py --callers --nearest`.
; ------------------------------------------------------------------------------
	.include "maincpu/shared/indexed_table.s"
; SysExBuf_ReadNibblePair(buf): two bytes at the cursor buf+6, advanced by 2; A = (b0 << 4) | (b1 & 0x0F).
SysExBuf_ReadNibblePair:
	link XIZ,0xfff8                                      ; FB77F3  ee 0c f8 ff
	pushw hl                                             ; FB77F7  2b
	push XIX                                             ; FB77F8  3c
	ld XIX,(XIZ+0x08)                                    ; FB77F9  ae 08 24
	ld XBC,(XIX+0x06)                                    ; FB77FC  ac 06 21
	ld (xiz-4), xbc                                      ; FB77FF  be fc 61
	inc 1,XBC                                            ; FB7802  e9 61
	ld (xiz-8), xbc                                      ; FB7804  be f8 61
	ld (XIX+0x06),XBC                                    ; FB7807  bc 06 61
	ld xbc, (xiz-4)                                      ; FB780A  ae fc 21
	ld A,(XBC)                                           ; FB780D  81 21
	ld H,A                                               ; FB780F  c9 8e
	sll h, 0x04                                          ; FB7811  ce ee 04
	ld xbc, (xiz-8)                                      ; FB7814  ae f8 21
	inc 1,XBC                                            ; FB7817  e9 61
	ld (XIX+0x06),XBC                                    ; FB7819  bc 06 61
	ld xbc, (xiz-8)                                      ; FB781C  ae f8 21
	ld A,(XBC)                                           ; FB781F  81 21
	and A,0x0f                                           ; FB7821  c9 cc 0f
	or A,H                                               ; FB7824  ce e1
	pop XIX                                              ; FB7826  5c
	popw hl                                              ; FB7827  4b
	unlk XIZ                                             ; FB7828  ee 0d
	ret                                                  ; FB782A  0e
; IndexedTable_MergeMaskedByte(rec): rec = {index, offset, value, mask}; IndexedTable_GetPtr(index)[offset] = (old & ~mask) | (value & mask);
;   WA = 0, or 0xFFFF when the table has no entry (sysex-probes/sysex_param_addresses.py).
IndexedTable_MergeMaskedByte:
	link XIZ,0xfff4                                      ; FB782B  ee 0c f4 ff
	pushw hl                                             ; FB782F  2b
	pushw de                                             ; FB7830  2a
	push XIX                                             ; FB7831  3c
	ld XIX,(XIZ+0x08)                                    ; FB7832  ae 08 24
	ldw hl, 0x00                                         ; FB7835  33 00 00
	sub XBC,XBC                                          ; FB7838  e9 a1
	dec 1,XBC                                            ; FB783A  e9 69
	ld (xiz-8), xbc                                      ; FB783C  be f8 61
	ld A,(XIX)                                           ; FB783F  84 21
	extz WA                                              ; FB7841  d8 12
	pushw wa                                             ; FB7843  28
	calr IndexedTable_GetPtr                                      ; FB7844  1e 91 ff
	ld (xiz-12), xiy                                     ; FB7847  be f4 65
	ld (xiz-4), xiy                                      ; FB784A  be fc 65
	ld xbc, (xiz-12)                                     ; FB784D  ae f4 21
	popw wa                                              ; FB7850  48
	cp	xbc, (xiz-8)                                 ; FB7851  ae f8 f1
	jr z, .LFB7883                                       ; FB7854  66 2d
	ld C,(XIX+0x03)                                      ; FB7856  8c 03 23
	and (XIX+0x02),C                                     ; FB7859  8c 02 cb
	ld C,(XIX+0x03)                                      ; FB785C  8c 03 23
	cpl C                                                ; FB785F  cb 06
	ld D,C                                               ; FB7861  cb 8c
	ld A,(XIX+0x01)                                      ; FB7863  8c 01 21
	extz WA                                              ; FB7866  d8 12
	extz XWA                                             ; FB7868  e8 12
	add	xwa, (xiz-4)                                 ; FB786A  ae fc 80
	and (XWA),C                                          ; FB786D  80 cb
	ld C,(XIX+0x01)                                      ; FB786F  8c 01 23
	extz BC                                              ; FB7872  d9 12
	extz XBC                                             ; FB7874  e9 12
	ld (xiz-8), xbc                                      ; FB7876  be f8 61
	ld A,(XIX+0x02)                                      ; FB7879  8c 02 21
	add	xbc, (xiz-4)                                 ; FB787C  ae fc 81
	or (XBC),A                                           ; FB787F  81 e9
	jr .LFB7888                                          ; FB7881  68 05
.LFB7883:
	ldw wa, 0xffff                                       ; FB7883  30 ff ff
	jr .LFB788A                                          ; FB7886  68 02
.LFB7888:
	ld WA,HL                                             ; FB7888  db 88
.LFB788A:
	pop XIX                                              ; FB788A  5c
	popw de                                              ; FB788B  4a
	popw hl                                              ; FB788C  4b
	unlk XIZ                                             ; FB788D  ee 0d
	ret                                                  ; FB788F  0e
; IndexedTable_MergeMaskedByteAndPost(rec): IndexedTable_MergeMaskedByte, then T_EventQueue_AppendStackArgs(index, offset, new byte, mask).
IndexedTable_MergeMaskedByteAndPost:
	link XIZ,0xfff4                                      ; FB7890  ee 0c f4 ff
	pushw hl                                             ; FB7894  2b
	pushw de                                             ; FB7895  2a
	push XIX                                             ; FB7896  3c
	ld XIX,(XIZ+0x08)                                    ; FB7897  ae 08 24
	ldw hl, 0x00                                         ; FB789A  33 00 00
	sub XBC,XBC                                          ; FB789D  e9 a1
	dec 1,XBC                                            ; FB789F  e9 69
	ld (xiz-8), xbc                                      ; FB78A1  be f8 61
	ld A,(XIX)                                           ; FB78A4  84 21
	extz WA                                              ; FB78A6  d8 12
	pushw wa                                             ; FB78A8  28
	calr IndexedTable_GetPtr                                      ; FB78A9  1e 2c ff
	ld (xiz-12), xiy                                     ; FB78AC  be f4 65
	ld (xiz-4), xiy                                      ; FB78AF  be fc 65
	ld xbc, (xiz-12)                                     ; FB78B2  ae f4 21
	popw wa                                              ; FB78B5  48
	cp	xbc, (xiz-8)                                 ; FB78B6  ae f8 f1
	jr z, .LFB790F                                       ; FB78B9  66 54
	ld C,(XIX+0x03)                                      ; FB78BB  8c 03 23
	and (XIX+0x02),C                                     ; FB78BE  8c 02 cb
	ld C,(XIX+0x03)                                      ; FB78C1  8c 03 23
	cpl C                                                ; FB78C4  cb 06
	ld D,C                                               ; FB78C6  cb 8c
	ld A,(XIX+0x01)                                      ; FB78C8  8c 01 21
	extz WA                                              ; FB78CB  d8 12
	extz XWA                                             ; FB78CD  e8 12
	add	xwa, (xiz-4)                                 ; FB78CF  ae fc 80
	and (XWA),C                                          ; FB78D2  80 cb
	ld C,(XIX+0x01)                                      ; FB78D4  8c 01 23
	extz BC                                              ; FB78D7  d9 12
	extz XBC                                             ; FB78D9  e9 12
	ld (xiz-8), xbc                                      ; FB78DB  be f8 61
	ld A,(XIX+0x02)                                      ; FB78DE  8c 02 21
	add	xbc, (xiz-4)                                 ; FB78E1  ae fc 81
	or (XBC),A                                           ; FB78E4  81 e9
	ld C,(XIX+0x03)                                      ; FB78E6  8c 03 23
	extz BC                                              ; FB78E9  d9 12
	pushw bc                                             ; FB78EB  29
	ld D,(XIX+0x01)                                      ; FB78EC  8c 01 24
	ld C,D                                               ; FB78EF  cc 8b
	extz BC                                              ; FB78F1  d9 12
	extz XBC                                             ; FB78F3  e9 12
	add	xbc, (xiz-4)                                 ; FB78F5  ae fc 81
	ld A,(XBC)                                           ; FB78F8  81 21
	extz WA                                              ; FB78FA  d8 12
	pushw wa                                             ; FB78FC  28
	ld C,D                                               ; FB78FD  cc 8b
	extz BC                                              ; FB78FF  d9 12
	pushw bc                                             ; FB7901  29
	ld C,(XIX)                                           ; FB7902  84 23
	extz BC                                              ; FB7904  d9 12
	pushw bc                                             ; FB7906  29
	call T_EventQueue_AppendStackArgs                                        ; FB7907  1d 14 1b f4
	inc 8,XSP                                            ; FB790B  ef 60
	jr .LFB7914                                          ; FB790D  68 05
.LFB790F:
	ldw wa, 0xffff                                       ; FB790F  30 ff ff
	jr .LFB7916                                          ; FB7912  68 02
.LFB7914:
	ld WA,HL                                             ; FB7914  db 88
.LFB7916:
	pop XIX                                              ; FB7916  5c
	popw de                                              ; FB7917  4a
	popw hl                                              ; FB7918  4b
	unlk XIZ                                             ; FB7919  ee 0d
	ret                                                  ; FB791B  0e
; IndexedTable_MergeMaskedWordAndPost(rec): rec = {index, offset, value16, mask16}; both bytes merged, one event posted per byte.
IndexedTable_MergeMaskedWordAndPost:
	link XIZ,0xfff4                                      ; FB791C  ee 0c f4 ff
	pushw hl                                             ; FB7920  2b
	pushw de                                             ; FB7921  2a
	push XIX                                             ; FB7922  3c
	ld XIX,(XIZ+0x08)                                    ; FB7923  ae 08 24
	ldw hl, 0x00                                         ; FB7926  33 00 00
	sub XBC,XBC                                          ; FB7929  e9 a1
	dec 1,XBC                                            ; FB792B  e9 69
	ld (xiz-8), xbc                                      ; FB792D  be f8 61
	ld A,(XIX)                                           ; FB7930  84 21
	extz WA                                              ; FB7932  d8 12
	pushw wa                                             ; FB7934  28
	calr IndexedTable_GetPtr                                      ; FB7935  1e a0 fe
	ld (xiz-12), xiy                                     ; FB7938  be f4 65
	ld (xiz-4), xiy                                      ; FB793B  be fc 65
	ld xbc, (xiz-12)                                     ; FB793E  ae f4 21
	popw wa                                              ; FB7941  48
	cp	xbc, (xiz-8)                                 ; FB7942  ae f8 f1
	jrl z, .LFB79F5                                      ; FB7945  76 ad 00
	ld BC,(XIX+0x04)                                     ; FB7948  9c 04 21
	and (XIX+0x02),BC                                    ; FB794B  9c 02 c9
	ld C,(XIX+0x04)                                      ; FB794E  8c 04 23
	cpl C                                                ; FB7951  cb 06
	ld D,C                                               ; FB7953  cb 8c
	ld A,(XIX+0x01)                                      ; FB7955  8c 01 21
	extz WA                                              ; FB7958  d8 12
	extz XWA                                             ; FB795A  e8 12
	add	xwa, (xiz-4)                                 ; FB795C  ae fc 80
	and (XWA),C                                          ; FB795F  80 cb
	ld D,(XIX+0x02)                                      ; FB7961  8c 02 24
	ld C,(XIX+0x01)                                      ; FB7964  8c 01 23
	extz BC                                              ; FB7967  d9 12
	extz XBC                                             ; FB7969  e9 12
	add	xbc, (xiz-4)                                 ; FB796B  ae fc 81
	or (XBC),D                                           ; FB796E  81 ec
	ld BC,(XIX+0x04)                                     ; FB7970  9c 04 21
	srl bc, 0x08                                         ; FB7973  d9 ef 08
	cpl C                                                ; FB7976  cb 06
	ld D,C                                               ; FB7978  cb 8c
	ld A,(XIX+0x01)                                      ; FB797A  8c 01 21
	extz WA                                              ; FB797D  d8 12
	extz XWA                                             ; FB797F  e8 12
	inc 1,XWA                                            ; FB7981  e8 61
	add	xwa, (xiz-4)                                 ; FB7983  ae fc 80
	and (XWA),C                                          ; FB7986  80 cb
	ld BC,(XIX+0x02)                                     ; FB7988  9c 02 21
	srl bc, 0x08                                         ; FB798B  d9 ef 08
	ld D,C                                               ; FB798E  cb 8c
	ld A,(XIX+0x01)                                      ; FB7990  8c 01 21
	extz WA                                              ; FB7993  d8 12
	extz XWA                                             ; FB7995  e8 12
	inc 1,XWA                                            ; FB7997  e8 61
	add	xwa, (xiz-4)                                 ; FB7999  ae fc 80
	or (XWA),C                                           ; FB799C  80 eb
	ld C,(XIX+0x04)                                      ; FB799E  8c 04 23
	extz BC                                              ; FB79A1  d9 12
	pushw bc                                             ; FB79A3  29
	ld D,(XIX+0x01)                                      ; FB79A4  8c 01 24
	ld C,D                                               ; FB79A7  cc 8b
	extz BC                                              ; FB79A9  d9 12
	extz XBC                                             ; FB79AB  e9 12
	add	xbc, (xiz-4)                                 ; FB79AD  ae fc 81
	ld A,(XBC)                                           ; FB79B0  81 21
	extz WA                                              ; FB79B2  d8 12
	pushw wa                                             ; FB79B4  28
	ld C,D                                               ; FB79B5  cc 8b
	extz BC                                              ; FB79B7  d9 12
	pushw bc                                             ; FB79B9  29
	ld C,(XIX)                                           ; FB79BA  84 23
	extz BC                                              ; FB79BC  d9 12
	pushw bc                                             ; FB79BE  29
	call T_EventQueue_AppendStackArgs                                        ; FB79BF  1d 14 1b f4
	ld BC,(XIX+0x04)                                     ; FB79C3  9c 04 21
	srl bc, 0x08                                         ; FB79C6  d9 ef 08
	extz BC                                              ; FB79C9  d9 12
	pushw bc                                             ; FB79CB  29
	ld D,(XIX+0x01)                                      ; FB79CC  8c 01 24
	ld C,D                                               ; FB79CF  cc 8b
	extz BC                                              ; FB79D1  d9 12
	extz XBC                                             ; FB79D3  e9 12
	inc 1,XBC                                            ; FB79D5  e9 61
	add	xbc, (xiz-4)                                 ; FB79D7  ae fc 81
	ld A,(XBC)                                           ; FB79DA  81 21
	extz WA                                              ; FB79DC  d8 12
	pushw wa                                             ; FB79DE  28
	ld C,D                                               ; FB79DF  cc 8b
	extz BC                                              ; FB79E1  d9 12
	inc 1,BC                                             ; FB79E3  d9 61
	pushw bc                                             ; FB79E5  29
	ld C,(XIX)                                           ; FB79E6  84 23
	extz BC                                              ; FB79E8  d9 12
	pushw bc                                             ; FB79EA  29
	call T_EventQueue_AppendStackArgs                                        ; FB79EB  1d 14 1b f4
	inc 8,XSP                                            ; FB79EF  ef 60
	inc 8,XSP                                            ; FB79F1  ef 60
	jr .LFB79FA                                          ; FB79F3  68 05
.LFB79F5:
	ldw wa, 0xffff                                       ; FB79F5  30 ff ff
	jr .LFB79FC                                          ; FB79F8  68 02
.LFB79FA:
	ld WA,HL                                             ; FB79FA  db 88
.LFB79FC:
	pop XIX                                              ; FB79FC  5c
	popw de                                              ; FB79FD  4a
	popw hl                                              ; FB79FE  4b
	unlk XIZ                                             ; FB79FF  ee 0d
	ret                                                  ; FB7A01  0e
; IndexedTable_GetByteOr0(index, offset): as IndexedTable_GetByte, but 0 when the table has no entry.
IndexedTable_GetByteOr0:
	link XIZ,0xfff8                                      ; FB7A02  ee 0c f8 ff
	push XIX                                             ; FB7A06  3c
	ld xbc, (IndexedTable_Base:24)                               ; FB7A07  e2 18 f0 60 21
	ld (xiz-4), xbc                                      ; FB7A0C  be fc 61
	sub XWA,XWA                                          ; FB7A0F  e8 a0
	dec 1,XWA                                            ; FB7A11  e8 69
	ld (xiz-8), xwa                                      ; FB7A13  be f8 60
	ld c, 0x04:opc                                          ; FB7A16  23 04
	mul	bc, (xiz+8)                                  ; FB7A18  8e 08 43
	extz XBC                                             ; FB7A1B  e9 12
	add	xbc, (xiz-4)                                 ; FB7A1D  ae fc 81
	ld XIY,(XBC)                                         ; FB7A20  a1 25
	ld XIX,XIY                                           ; FB7A22  ed 8c
	cp XIY,XWA                                           ; FB7A24  e8 f5
	jr z, .LFB7A35                                       ; FB7A26  66 0d
	ld BC,(XIZ+0x0a)                                     ; FB7A28  9e 0a 21
	extz BC                                              ; FB7A2B  d9 12
	extz XBC                                             ; FB7A2D  e9 12
	add XBC,XIX                                          ; FB7A2F  ec 81
	ld A,(XBC)                                           ; FB7A31  81 21
	jr .LFB7A37                                          ; FB7A33  68 02
.LFB7A35:
	sub A,A                                              ; FB7A35  c9 a1
.LFB7A37:
	pop XIX                                              ; FB7A37  5c
	unlk XIZ                                             ; FB7A38  ee 0d
	ret                                                  ; FB7A3A  0e
	link XIZ,0x0000                                      ; FB7A3B  ee 0c 00 00
	push XIX                                             ; FB7A3F  3c
	ld XIX,(XIZ+0x0e)                                    ; FB7A40  ae 0e 24
.LFB7A43:
	cpw	(xiz+12), 0x0000                             ; FB7A43  9e 0c 3f 00 00
	jr z, .LFB7A5F                                       ; FB7A48  66 15
	decm 0x01, (xiz+0x0c)                                ; FB7A4A  9e 0c 69
	ld XBC,(XIZ+0x08)                                    ; FB7A4D  ae 08 21
	ld A,(XBC)                                           ; FB7A50  81 21
	ld (XIX),A                                           ; FB7A52  b4 41
	sub XBC,XBC                                          ; FB7A54  e9 a1
	inc 1,XBC                                            ; FB7A56  e9 61
	add (XIZ+0x08),XBC                                   ; FB7A58  ae 08 89
	add XIX,XBC                                          ; FB7A5B  e9 84
	jr .LFB7A43                                          ; FB7A5D  68 e4
.LFB7A5F:
	pop XIX                                              ; FB7A5F  5c
	unlk XIZ                                             ; FB7A60  ee 0d
	ret                                                  ; FB7A62  0e
; SysExXfer_InitCpu2Forward: Initialises the received-block forwarding descriptor at 0x60FD32: +0 := the staging block
;   base (0x60FD18), +4 := the argument (the CPU-2 destination, 0xE80000 sounds / 0xEC0000 combinations), counters +8,
;   +0x0A, +0x0B, +0x0C := 0. SysExSession_RecvBody_Sound / _CombinationPart1/2 then send each full 0x400-byte block
;   to +4 through T_Link_SendCommandE7 and advance it. Basis: callers + body + the descriptor's readers.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_j.json)
SysExXfer_InitCpu2Forward:
	link XIZ,0x0000                                      ; FB7A63  ee 0c 00 00
	push XIX                                             ; FB7A67  3c
	lda xix, (0x60fd32:24)                               ; FB7A68  f2 32 fd 60 34
	ld xbc, (0x60fd18:24)                               ; FB7A6D  e2 18 fd 60 21
	ld (XIX),XBC                                         ; FB7A72  b4 61
	ld XBC,(XIZ+0x08)                                    ; FB7A74  ae 08 21
	ld (XIX+0x04),XBC                                    ; FB7A77  bc 04 61
	ldw	(xix+8), 0x0000                              ; FB7A7A  bc 08 02 00 00
	ld (XIX+0x0a),0x00                                   ; FB7A7F  bc 0a 00 00
	ld (XIX+0x0b),0x00                                   ; FB7A83  bc 0b 00 00
	ldw	(xix+12), 0x0000                             ; FB7A87  bc 0c 02 00 00
	pop XIX                                              ; FB7A8C  5c
	unlk XIZ                                             ; FB7A8D  ee 0d
	ret                                                  ; FB7A8F  0e
; SysEx_Checksum(msg, len): (-(msg[1] + .. + msg[len-1])) & 0x7F, the frame checksum of SysExTx_AppendChecksumF7.
SysEx_Checksum:
	link XIZ,0x0000                                      ; FB7A90  ee 0c 00 00
	pushw hl                                             ; FB7A94  2b
	pushw de                                             ; FB7A95  2a
	push XIX                                             ; FB7A96  3c
	ld HL,(XIZ+0x0c)                                     ; FB7A97  9e 0c 23
	ld XIX,(XIZ+0x08)                                    ; FB7A9A  ae 08 24
	ld d, 0x00:opc                                          ; FB7A9D  24 00
	inc 1,XIX                                            ; FB7A9F  ec 61
	dec 1,HL                                             ; FB7AA1  db 69
.LFB7AA3:
	cp hl, 0x00:i3                                         ; FB7AA3  db d8
	jr z, .LFB7AB1                                       ; FB7AA5  66 0a
	dec 1,HL                                             ; FB7AA7  db 69
	ld C,(XIX)                                           ; FB7AA9  84 23
	add D,C                                              ; FB7AAB  cb 84
	inc 1,XIX                                            ; FB7AAD  ec 61
	jr .LFB7AA3                                          ; FB7AAF  68 f2
.LFB7AB1:
	ld C,D                                               ; FB7AB1  cc 8b
	extz BC                                              ; FB7AB3  d9 12
	sub WA,WA                                            ; FB7AB5  d8 a0
	sub WA,BC                                            ; FB7AB7  d9 a0
	res 0x07,A                                           ; FB7AB9  c9 30 07
	pop XIX                                              ; FB7ABC  5c
	popw de                                              ; FB7ABD  4a
	popw hl                                              ; FB7ABE  4b
	unlk XIZ                                             ; FB7ABF  ee 0d
	ret                                                  ; FB7AC1  0e
; SysExTx_SendBytes(src, n): SysExTx_Append, SysExTx_SendFrameMidi1, SysExTx_SwapBuffers.
SysExTx_SendBytes:
	link XIZ,0x0000                                      ; FB7AC2  ee 0c 00 00
	pushw	(xiz+12)                                     ; FB7AC6  9e 0c 04
	ld XBC,(XIZ+0x08)                                    ; FB7AC9  ae 08 21
	push XBC                                             ; FB7ACC  39
	calr SysExTx_Append                                      ; FB7ACD  1e 54 f4
	ld xbc, (0x60fc88:24)                               ; FB7AD0  e2 88 fc 60 21
	push XBC                                             ; FB7AD5  39
	calr SysExTx_SendFrameMidi1                                      ; FB7AD6  1e 8c f6
	call SysExTx_SwapBuffers                                      ; FB7AD9  1d 81 80 fb
	inc 8,XSP                                            ; FB7ADD  ef 60
	inc 2,XSP                                            ; FB7ADF  ef 62
	unlk XIZ                                             ; FB7AE1  ee 0d
	ret                                                  ; FB7AE3  0e
Mode_SwitchToCombination_SaveRegs:
	push XDE                                             ; FB7AE4  3a
	push XHL                                             ; FB7AE5  3b
	push XIX                                             ; FB7AE6  3c
	push XIZ                                             ; FB7AE7  3e
	call T_Mode_SwitchToCombination                                        ; FB7AE8  1d c0 15 f4
	pop XIZ                                              ; FB7AEC  5e
	pop XIX                                              ; FB7AED  5c
	pop XHL                                              ; FB7AEE  5b
	pop XDE                                              ; FB7AEF  5a
	ret                                                  ; FB7AF0  0e
Mode_SwitchToSound_SaveRegs:
	push XDE                                             ; FB7AF1  3a
	push XHL                                             ; FB7AF2  3b
	push XIX                                             ; FB7AF3  3c
	push XIZ                                             ; FB7AF4  3e
	call T_Mode_SwitchToSound                                        ; FB7AF5  1d c4 15 f4
	pop XIZ                                              ; FB7AF9  5e
	pop XIX                                              ; FB7AFA  5c
	pop XHL                                              ; FB7AFB  5b
	pop XDE                                              ; FB7AFC  5a
	ret                                                  ; FB7AFD  0e
PanelLed_ToggleActivityLed_SaveRegs2:
	push XDE                                             ; FB7AFE  3a
	push XHL                                             ; FB7AFF  3b
	push XIX                                             ; FB7B00  3c
	push XIZ                                             ; FB7B01  3e
	call T_PanelLed_ToggleActivityLed                                        ; FB7B02  1d a0 06 f4
	pop XIZ                                              ; FB7B06  5e
	pop XIX                                              ; FB7B07  5c
	pop XHL                                              ; FB7B08  5b
	pop XDE                                              ; FB7B09  5a
	ret                                                  ; FB7B0A  0e
; SysExSession_StartProgressScreen: At a SysEx bulk session's start: UI_ScreenId/UI_ScreenLatch -> their _Previous
;   cells, the progress cells 0x60F804..0x60F811 := 0, (0x60F810) := 1 sending / 2 otherwise ((0x60FD40) bit 6), the
;   first progress field := 0x80, then the Sending or SYSTEM EXCLUSIVE PLEASE WAIT screen is painted. Called by
;   SysExDump_RunSendJob and SysExSession_Run. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
SysExSession_StartProgressScreen:
	ld c, (UI_ScreenId:16)                                   ; FB7B0B  c1 7c 20 23
	ld (UI_ScreenId_Previous:16), c                                   ; FB7B0F  f1 7d 20 43
	ld a, (UI_ScreenLatch:16)                                   ; FB7B13  c1 7a 20 21
	ld (UI_ScreenLatch_Previous:16), a                                   ; FB7B17  f1 7b 20 41
	ld (0x60f804:24), 0x00                             ; FB7B1B  f2 04 f8 60 00 00
	ld (0x60f805:24), 0x00                             ; FB7B21  f2 05 f8 60 00 00
	ld (0x60f806:24), 0x00                             ; FB7B27  f2 06 f8 60 00 00
	ld (0x60f807:24), 0x00                             ; FB7B2D  f2 07 f8 60 00 00
	ld (0x60f808:24), 0x00                             ; FB7B33  f2 08 f8 60 00 00
	ld (0x60f809:24), 0x00                             ; FB7B39  f2 09 f8 60 00 00
; (sub_FB7B3F removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExSession_StartProgressScreen;
;  notes/prom_a_stray_label_removal.py)
	ld (0x60f80a:24), 0x00                             ; FB7B3F  f2 0a f8 60 00 00
	ld (0x60f80b:24), 0x00                             ; FB7B45  f2 0b f8 60 00 00
	ld (0x60f80c:24), 0x00                             ; FB7B4B  f2 0c f8 60 00 00
	ld (0x60f80d:24), 0x00                             ; FB7B51  f2 0d f8 60 00 00
	ld (0x60f80e:24), 0x00                             ; FB7B57  f2 0e f8 60 00 00
	ld (0x60f80f:24), 0x00                             ; FB7B5D  f2 0f f8 60 00 00
	ld (0x60f810:24), 0x00                             ; FB7B63  f2 10 f8 60 00 00
	ld (0x60f811:24), 0x00                             ; FB7B69  f2 11 f8 60 00 00
	calr SysExSession_SelectProgressScreen                                      ; FB7B6F  1e 07 00
	calr SysExSession_RequestLabelBlockPaint                                      ; FB7B72  1e 2e 00
	calr SysExSession_RepaintProgressIfChanged                                      ; FB7B75  1e f4 02
	ret                                                  ; FB7B78  0e
; SysExSession_SelectProgressScreen: (0x60F810) := 1 (Sending, (0x60FD40) bit 6) or 2 (SYSTEM EXCLUSIVE PLEASE WAIT);
;   when that differs from (0x60F811), sets the changed flag (0x60FD42) bit 6 and copies it there. Paint_Sending tests
;   (0x60F810) bit 0 to draw its whole screen. Called by SysExSession_StartProgressScreen. Basis: caller + body +
;   reader. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
SysExSession_SelectProgressScreen:
	push XIX                                             ; FB7B79  3c
	lda xix, (0x60f810:24)                               ; FB7B7A  f2 10 f8 60 34
	ld (XIX),0x02                                        ; FB7B7F  b4 00 02
	bit	6, (0x60fd40:24)                             ; FB7B82  f2 40 fd 60 ce
	jr z, .LFB7B8C                                       ; FB7B87  66 03
	ld (XIX),0x01                                        ; FB7B89  b4 00 01
.LFB7B8C:
	ld C,(XIX)                                           ; FB7B8C  84 23
	cp	c, (0x60f811:24)                             ; FB7B8E  c2 11 f8 60 f3
	jr z, .LFB7BA1                                       ; FB7B93  66 0c
	set	6, (0x60fd42:24)                             ; FB7B95  f2 42 fd 60 be
	ld C,(XIX)                                           ; FB7B9A  84 23
	ld (0x60f811:24), c                                 ; FB7B9C  f2 11 f8 60 43
.LFB7BA1:
	pop XIX                                              ; FB7BA1  5c
	ret                                                  ; FB7BA2  0e
; SysExSession_RequestLabelBlockPaint: Sets the section-status field to 0x80 -- (0x60F804) when sending ((0x60FD40)
;   bit 6), else (0x60F80A) -- value 0 with the repaint bit, so the next paint runs
;   Paint_SysPartMidiSoundCombination's value-0 case: the SYS,PART&MIDI / SOUND / COMBINATION label block. Called by
;   SysExSession_StartProgressScreen. Basis: caller + body + reader. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
SysExSession_RequestLabelBlockPaint:
	bit	6, (0x60fd40:24)                             ; FB7BA3  f2 40 fd 60 ce
	jr z, .LFB7BB2                                       ; FB7BA8  66 08
	ld (0x60f804:24), 0x80                             ; FB7BAA  f2 04 f8 60 00 80
	jr .LFB7BB8                                          ; FB7BB0  68 06
.LFB7BB2:
	ld (0x60f80a:24), 0x80                             ; FB7BB2  f2 0a f8 60 00 80
.LFB7BB8:
	ret                                                  ; FB7BB8  0e
; SysExSession_RefreshProgressScreen: While the session status (field 4 of (0x60FCD8)) is 0, recomputes the progress
;   pairs 0x60F804..0x60F80F and, if one changed, repaints the Sending / Please Wait screen. Called after every SysEx
;   frame sent (SysExDump_SendFrames*, SysExTx_AppendAndSendOnF7) and every command handled. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_a.json)
SysExSession_RefreshProgressScreen:
	pushw 0x04                                           ; FB7BB9  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB7BBC  e2 d8 fc 60 21
	push XBC                                             ; FB7BC1  39
	call U8Rec16_GetField                                      ; FB7BC2  1d d3 62 fb
	inc 6,XSP                                            ; FB7BC6  ef 66
	cp a, 0x00:i3                                          ; FB7BC8  c9 d8
	jr nz, .LFB7BDE                                      ; FB7BCA  6e 12
	calr SysExSession_SaveProgressFields                                      ; FB7BCC  1e 10 00
	calr SysExSession_UpdateSectionStatus                                      ; FB7BCF  1e 85 00
	calr SysExSession_InitProgressBarScale                                      ; FB7BD2  1e e8 00
	calr SysExSession_UpdateProgressBarFill                                      ; FB7BD5  1e 31 01
	calr SysExSession_DetectProgressChange                                      ; FB7BD8  1e b6 01
	calr SysExSession_RepaintProgressIfChanged                                      ; FB7BDB  1e 8e 02
.LFB7BDE:
	ret                                                  ; FB7BDE  0e
; SysExSession_SaveProgressFields: Clears bit 7 (repaint) of the three progress fields and copies each into its
;   'previous' byte: (0x60F804/806/808) -> 805/807/809 when sending ((0x60FD40) bit 6), else (0x60F80A/80C/80E) ->
;   80B/80D/80F. First step of SysExSession_RefreshProgressScreen, before the recomputers compare against the previous
;   values. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
SysExSession_SaveProgressFields:
	pushw hl                                             ; FB7BDF  2b
	bit	6, (0x60fd40:24)                             ; FB7BE0  f2 40 fd 60 ce
	jr z, .LFB7C1F                                       ; FB7BE5  66 38
	ld h, (0x60f804:24)                                 ; FB7BE7  c2 04 f8 60 26
	res 0x07,H                                           ; FB7BEC  ce 30 07
	ld (0x60f804:24), h                                 ; FB7BEF  f2 04 f8 60 46
	ld (0x60f805:24), h                                 ; FB7BF4  f2 05 f8 60 46
	ld h, (0x60f806:24)                                 ; FB7BF9  c2 06 f8 60 26
	res 0x07,H                                           ; FB7BFE  ce 30 07
	ld (0x60f806:24), h                                 ; FB7C01  f2 06 f8 60 46
	ld (0x60f807:24), h                                 ; FB7C06  f2 07 f8 60 46
	ld h, (0x60f808:24)                                 ; FB7C0B  c2 08 f8 60 26
	res 0x07,H                                           ; FB7C10  ce 30 07
	ld (0x60f808:24), h                                 ; FB7C13  f2 08 f8 60 46
	ld (0x60f809:24), h                                 ; FB7C18  f2 09 f8 60 46
	jr .LFB7C55                                          ; FB7C1D  68 36
.LFB7C1F:
	ld h, (0x60f80a:24)                                 ; FB7C1F  c2 0a f8 60 26
	res 0x07,H                                           ; FB7C24  ce 30 07
	ld (0x60f80a:24), h                                 ; FB7C27  f2 0a f8 60 46
	ld (0x60f80b:24), h                                 ; FB7C2C  f2 0b f8 60 46
	ld h, (0x60f80c:24)                                 ; FB7C31  c2 0c f8 60 26
	res 0x07,H                                           ; FB7C36  ce 30 07
	ld (0x60f80c:24), h                                 ; FB7C39  f2 0c f8 60 46
	ld (0x60f80d:24), h                                 ; FB7C3E  f2 0d f8 60 46
	ld h, (0x60f80e:24)                                 ; FB7C43  c2 0e f8 60 26
	res 0x07,H                                           ; FB7C48  ce 30 07
	ld (0x60f80e:24), h                                 ; FB7C4B  f2 0e f8 60 46
	ld (0x60f80f:24), h                                 ; FB7C50  f2 0f f8 60 46
.LFB7C55:
	popw hl                                              ; FB7C55  4b
	ret                                                  ; FB7C56  0e
; SysExSession_UpdateSectionStatus: Section-status field (0x60F804 sending / 0x60F80A receiving) := ByteMap
;   0xF511B5[field 3 of the tx (0x60FCE0) / rx (0x60FCD8) record], bit 7 set when it differs from the previous byte.
;   Its values 1..10 pick the '<section> : SENDING' / 'COMPLETED' rows of DLPtrTable_F0D942. Step 2 of
;   SysExSession_RefreshProgressScreen. Basis: caller + body + painter. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
SysExSession_UpdateSectionStatus:
	pushw hl                                             ; FB7C57  2b
	push XIX                                             ; FB7C58  3c
	lda xix, (0x60f80a:24)                               ; FB7C59  f2 0a f8 60 34
	bit	6, (0x60fd40:24)                             ; FB7C5E  f2 40 fd 60 ce
	jr z, .LFB7C93                                       ; FB7C63  66 2e
	pushw 0x03                                           ; FB7C65  0b 03 00
	ld xbc, (0x60fce0:24)                               ; FB7C68  e2 e0 fc 60 21
	push XBC                                             ; FB7C6D  39
	call U8Rec16_GetField                                      ; FB7C6E  1d d3 62 fb
	extz WA                                              ; FB7C72  d8 12
	extz XWA                                             ; FB7C74  e8 12
	add XWA,0x00f511b5                                   ; FB7C76  e8 c8 b5 11 f5 00
	ld H,(XWA)                                           ; FB7C7C  80 26
	ld (0x60f804:24), h                                 ; FB7C7E  f2 04 f8 60 46
	inc 6,XSP                                            ; FB7C83  ef 66
	cp	h, (0x60f805:24)                             ; FB7C85  c2 05 f8 60 f6
	jr z, .LFB7CBA                                       ; FB7C8A  66 2e
	set	7, (0x60f804:24)                             ; FB7C8C  f2 04 f8 60 bf
	jr .LFB7CBA                                          ; FB7C91  68 27
.LFB7C93:
	pushw 0x03                                           ; FB7C93  0b 03 00
	ld xbc, (0x60fcd8:24)                               ; FB7C96  e2 d8 fc 60 21
	push XBC                                             ; FB7C9B  39
	call U8Rec16_GetField                                      ; FB7C9C  1d d3 62 fb
	extz WA                                              ; FB7CA0  d8 12
	extz XWA                                             ; FB7CA2  e8 12
	add XWA,0x00f511b5                                   ; FB7CA4  e8 c8 b5 11 f5 00
	ld H,(XWA)                                           ; FB7CAA  80 26
	ld (XIX),H                                           ; FB7CAC  b4 46
	inc 6,XSP                                            ; FB7CAE  ef 66
	cp	h, (0x60f80b:24)                             ; FB7CB0  c2 0b f8 60 f6
	jr z, .LFB7CBA                                       ; FB7CB5  66 03
	or	(xix), 0x80                                  ; FB7CB7  84 3e 80
.LFB7CBA:
	pop XIX                                              ; FB7CBA  5c
	popw hl                                              ; FB7CBB  4b
	ret                                                  ; FB7CBC  0e
; SysExSession_InitProgressBarScale: Once per session (until (0x60FD42) bit 7): bytes per bar cell := job byte count /
;   32 -- (0x60FCF4) := (0x60FCF0) >> 5 sending, (0x60FD14) := (0x60FD10) >> 5 receiving -- and the bar-length field
;   (0x60F806 / 0x60F80C) := 0xA0 (32 cells + repaint); sets (0x60FD42) bit 7 when the quotient is non-zero. Step 3 of
;   SysExSession_RefreshProgressScreen. Basis: caller + body + painter. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
SysExSession_InitProgressBarScale:
	push XIX                                             ; FB7CBD  3c
	bit	7, (0x60fd42:24)                             ; FB7CBE  f2 42 fd 60 cf
	jr nz, .LFB7D07                                      ; FB7CC3  6e 42
	bit	6, (0x60fd40:24)                             ; FB7CC5  f2 40 fd 60 ce
	jr z, .LFB7CE5                                       ; FB7CCA  66 19
	ld xbc, (0x60fcf0:24)                               ; FB7CCC  e2 f0 fc 60 21
	ld XIX,XBC                                           ; FB7CD1  e9 8c
	srl xbc, 0x05                                        ; FB7CD3  e9 ef 05
	ld XIX,XBC                                           ; FB7CD6  e9 8c
	ld (0x60fcf4:24), xbc                               ; FB7CD8  f2 f4 fc 60 61
	ld (0x60f806:24), 0xa0                             ; FB7CDD  f2 06 f8 60 00 a0
	jr .LFB7CFC                                          ; FB7CE3  68 17
.LFB7CE5:
	ld xbc, (0x60fd10:24)                               ; FB7CE5  e2 10 fd 60 21
	ld XIX,XBC                                           ; FB7CEA  e9 8c
	srl xbc, 0x05                                        ; FB7CEC  e9 ef 05
	ld XIX,XBC                                           ; FB7CEF  e9 8c
	ld (0x60fd14:24), xbc                               ; FB7CF1  f2 14 fd 60 61
	ld (0x60f80c:24), 0xa0                             ; FB7CF6  f2 0c f8 60 00 a0
.LFB7CFC:
	ld XBC,XIX                                           ; FB7CFC  ec 89
	or XBC,XBC                                           ; FB7CFE  e9 e1
	jr z, .LFB7D07                                       ; FB7D00  66 05
	set	7, (0x60fd42:24)                             ; FB7D02  f2 42 fd 60 bf
.LFB7D07:
	pop XIX                                              ; FB7D07  5c
	ret                                                  ; FB7D08  0e
; SysExSession_UpdateProgressBarFill: Filled cells := 32 - remaining bytes / bytes per cell ((0x60FCF0) / (0x60FCF4)
;   sending, (0x60FD10) / (0x60FD14) receiving, Divide32_Unsigned_Quotient_Copy) into the bar-fill field (0x60F808 /
;   0x60F80E), bit 7 set when it changed; skipped while either is 0. Step 4 of SysExSession_RefreshProgressScreen.
;   Basis: caller + body + painter. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
SysExSession_UpdateProgressBarFill:
	link XIZ,0xfffc                                      ; FB7D09  ee 0c fc ff
	pushw hl                                             ; FB7D0D  2b
	push XIX                                             ; FB7D0E  3c
	bit	6, (0x60fd40:24)                             ; FB7D0F  f2 40 fd 60 ce
	jr z, .LFB7D52                                       ; FB7D14  66 3c
	ld xbc, (0x60fcf0:24)                               ; FB7D16  e2 f0 fc 60 21
	ld (xiz-4), xbc                                      ; FB7D1B  be fc 61
	ld xwa, (0x60fcf4:24)                               ; FB7D1E  e2 f4 fc 60 20
	ld XIX,XWA                                           ; FB7D23  e8 8c
	or XBC,XBC                                           ; FB7D25  e9 e1
	jr z, .LFB7D8C                                       ; FB7D27  66 63
	or XWA,XWA                                           ; FB7D29  e8 e0
	jr z, .LFB7D8C                                       ; FB7D2B  66 5f
	push XWA                                             ; FB7D2D  38
	push XBC                                             ; FB7D2E  39
	call Divide32_Unsigned_Quotient_Copy                                      ; FB7D2F  1d 6a 82 fb
	ld_erpb_rr c, 0xf4                                   ; FB7D33  c7 f4 8b   ld C,IYL
	sub C,0x20                                           ; FB7D36  cb ca 20
	cpl C                                                ; FB7D39  cb 06
	ld H,C                                               ; FB7D3B  cb 8e
	inc 1,H                                              ; FB7D3D  ce 61
	ld (0x60f808:24), h                                 ; FB7D3F  f2 08 f8 60 46
	cp	h, (0x60f809:24)                             ; FB7D44  c2 09 f8 60 f6
	jr z, .LFB7D8C                                       ; FB7D49  66 41
	set	7, (0x60f808:24)                             ; FB7D4B  f2 08 f8 60 bf
	jr .LFB7D8C                                          ; FB7D50  68 3a
.LFB7D52:
	ld xbc, (0x60fd10:24)                               ; FB7D52  e2 10 fd 60 21
	ld (xiz-4), xbc                                      ; FB7D57  be fc 61
	ld xwa, (0x60fd14:24)                               ; FB7D5A  e2 14 fd 60 20
	ld XIX,XWA                                           ; FB7D5F  e8 8c
	or XBC,XBC                                           ; FB7D61  e9 e1
	jr z, .LFB7D8C                                       ; FB7D63  66 27
	or XWA,XWA                                           ; FB7D65  e8 e0
	jr z, .LFB7D8C                                       ; FB7D67  66 23
	push XWA                                             ; FB7D69  38
	push XBC                                             ; FB7D6A  39
	call Divide32_Unsigned_Quotient_Copy                                      ; FB7D6B  1d 6a 82 fb
	ld_erpb_rr c, 0xf4                                   ; FB7D6F  c7 f4 8b   ld C,IYL
	sub C,0x20                                           ; FB7D72  cb ca 20
	cpl C                                                ; FB7D75  cb 06
	ld H,C                                               ; FB7D77  cb 8e
	inc 1,H                                              ; FB7D79  ce 61
	ld (0x60f80e:24), h                                 ; FB7D7B  f2 0e f8 60 46
	cp	h, (0x60f80f:24)                             ; FB7D80  c2 0f f8 60 f6
	jr z, .LFB7D8C                                       ; FB7D85  66 05
	set	7, (0x60f80e:24)                             ; FB7D87  f2 0e f8 60 bf
.LFB7D8C:
	pop XIX                                              ; FB7D8C  5c
	popw hl                                              ; FB7D8D  4b
	unlk XIZ                                             ; FB7D8E  ee 0d
	ret                                                  ; FB7D90  0e
; SysExSession_DetectProgressChange: Compares the three progress fields with their previous bytes (0x60F804/806/808 vs
;   805/807/809 sending, 0x60F80A/80C/80E vs 80B/80D/80F receiving) and sets (0x60FD42) bit 6 if any differs -- the
;   flag SysExSession_RepaintProgressIfChanged then acts on. Step 5 of SysExSession_RefreshProgressScreen. Basis:
;   caller + body + consumer. (notes/naming-pilot-2026-10-06/proposals_wave8_d8.json)
SysExSession_DetectProgressChange:
	push XIX                                             ; FB7D91  3c
	lda xix, (0x60fd42:24)                               ; FB7D92  f2 42 fd 60 34
	bit	6, (0x60fd40:24)                             ; FB7D97  f2 40 fd 60 ce
	jr z, .LFB7DCE                                       ; FB7D9C  66 30
	ld c, (0x60f804:24)                                 ; FB7D9E  c2 04 f8 60 23
	cp	c, (0x60f805:24)                             ; FB7DA3  c2 05 f8 60 f3
	jr z, .LFB7DAE                                       ; FB7DA8  66 04
	set 6,(XIX)                                          ; FB7DAA  b4 be
	jr .LFB7DFC                                          ; FB7DAC  68 4e
.LFB7DAE:
	ld c, (0x60f806:24)                                 ; FB7DAE  c2 06 f8 60 23
	cp	c, (0x60f807:24)                             ; FB7DB3  c2 07 f8 60 f3
	jr z, .LFB7DBE                                       ; FB7DB8  66 04
	set 6,(XIX)                                          ; FB7DBA  b4 be
	jr .LFB7DFC                                          ; FB7DBC  68 3e
.LFB7DBE:
	ld c, (0x60f808:24)                                 ; FB7DBE  c2 08 f8 60 23
	cp	c, (0x60f809:24)                             ; FB7DC3  c2 09 f8 60 f3
	jr z, .LFB7DFC                                       ; FB7DC8  66 32
	set 6,(XIX)                                          ; FB7DCA  b4 be
	jr .LFB7DFC                                          ; FB7DCC  68 2e
.LFB7DCE:
	ld c, (0x60f80a:24)                                 ; FB7DCE  c2 0a f8 60 23
	cp	c, (0x60f80b:24)                             ; FB7DD3  c2 0b f8 60 f3
	jr z, .LFB7DDE                                       ; FB7DD8  66 04
	set 6,(XIX)                                          ; FB7DDA  b4 be
	jr .LFB7DFC                                          ; FB7DDC  68 1e
.LFB7DDE:
	ld c, (0x60f80c:24)                                 ; FB7DDE  c2 0c f8 60 23
	cp	c, (0x60f80d:24)                             ; FB7DE3  c2 0d f8 60 f3
	jr z, .LFB7DEE                                       ; FB7DE8  66 04
	set 6,(XIX)                                          ; FB7DEA  b4 be
	jr .LFB7DFC                                          ; FB7DEC  68 0e
.LFB7DEE:
	ld c, (0x60f80e:24)                                 ; FB7DEE  c2 0e f8 60 23
	cp	c, (0x60f80f:24)                             ; FB7DF3  c2 0f f8 60 f3
	jr z, .LFB7DFC                                       ; FB7DF8  66 02
	set 6,(XIX)                                          ; FB7DFA  b4 be
.LFB7DFC:
	pop XIX                                              ; FB7DFC  5c
	ret                                                  ; FB7DFD  0e
; SysExDump_ShowResult: status (field 4) 0 -> SysExDump_ShowCompleted; 0x21 -> SysExDump_ShowWriteProtectError; else SysExDump_ShowStatusMessage.
SysExDump_ShowResult:
	pushw 0x04                                           ; FB7DFE  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB7E01  e2 d8 fc 60 21
	push XBC                                             ; FB7E06  39
	call U8Rec16_GetField                                      ; FB7E07  1d d3 62 fb
	extz WA                                              ; FB7E0B  d8 12
	inc 6,XSP                                            ; FB7E0D  ef 66
	cp wa, 0x00:i3                                         ; FB7E0F  d8 d8
	jr z, .LFB7E1B                                       ; FB7E11  66 08
	cp WA,0x0021                                         ; FB7E13  d8 cf 21 00
	jr z, .LFB7E20                                       ; FB7E17  66 07
	jr .LFB7E25                                          ; FB7E19  68 0a
.LFB7E1B:
	calr SysExDump_ShowCompleted                                      ; FB7E1B  1e 0b 00
	jr .LFB7E28                                          ; FB7E1E  68 08
.LFB7E20:
	calr SysExDump_ShowWriteProtectError                                      ; FB7E20  1e 15 00
	jr .LFB7E28                                          ; FB7E23  68 03
.LFB7E25:
	calr SysExDump_ShowStatusMessage                                      ; FB7E25  1e 1b 00
.LFB7E28:
	ret                                                  ; FB7E28  0e
; SysExDump_ShowCompleted: UI_StatusCode = 0x23 (COMPLETED!), UI_Request = 0xAB.
SysExDump_ShowCompleted:
	ld (UI_StatusCode:16), 0x23                                 ; FB7E29  f1 80 28 00 23
	ld (UI_Request:16), 0xab                                 ; FB7E2E  f1 70 20 00 ab
	set	6, (UI_Request_Hi:16)                               ; FB7E33  f1 71 20 be
	ret                                                  ; FB7E37  0e
; SysExDump_ShowWriteProtectError: UI_Request = 0xB3, no popup.
; SysExDump_ShowWriteProtectError: requests screen 0xB3 -- ScreenEnter_WriteProtectError ("The S0UND or C0MBINATI0N memories
;   are write protected").
SysExDump_ShowWriteProtectError:
	ld (UI_Request:16), 0xb3                                 ; FB7E38  f1 70 20 00 b3
	ld (UI_Request_Hi:16), 0x40                                 ; FB7E3D  f1 71 20 00 40
	ret                                                  ; FB7E42  0e
; SysExDump_ShowStatusMessage: UI_StatusCode = SysExStatus_MessageIdMap[status], UI_Request = 0xAB.
SysExDump_ShowStatusMessage:
	pushw 0x04                                           ; FB7E43  0b 04 00
	ld xbc, (0x60fcd8:24)                               ; FB7E46  e2 d8 fc 60 21
	push XBC                                             ; FB7E4B  39
	call U8Rec16_GetField                                      ; FB7E4C  1d d3 62 fb
	extz WA                                              ; FB7E50  d8 12
	extz XWA                                             ; FB7E52  e8 12
	add XWA,SysExStatus_MessageIdMap                              ; FB7E54  e8 c8 c7 11 f5 00
	ld C,(XWA)                                           ; FB7E5A  80 23
	ld (UI_StatusCode:16), c                                   ; FB7E5C  f1 80 28 43
	ld (UI_Request:16), 0xab                                 ; FB7E60  f1 70 20 00 ab
	set	6, (UI_Request_Hi:16)                               ; FB7E65  f1 71 20 be
	inc 6,XSP                                            ; FB7E69  ef 66
	ret                                                  ; FB7E6B  0e
; SysExSession_RepaintProgressIfChanged: When a progress value changed ((0x60FD42) bit 6, set by the progress
;   recomputers) repaints the Sending screen if (0x60FD40) bit 6 is set, else the SYSTEM EXCLUSIVE PLEASE WAIT screen,
;   then clears the changed bit. The last step of SysExSession_StartProgressScreen and
;   SysExSession_RefreshProgressScreen. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
SysExSession_RepaintProgressIfChanged:
	bit	6, (0x60fd42:24)                             ; FB7E6C  f2 42 fd 60 ce
	jr z, .LFB7E99                                       ; FB7E71  66 26
	bit	6, (0x60fd40:24)                             ; FB7E73  f2 40 fd 60 ce
	jr z, .LFB7E88                                       ; FB7E78  66 0e
	push XDE                                             ; FB7E7A  3a
	push XHL                                             ; FB7E7B  3b
; (sub_FB7E7C removed 2026-10-04: no code names it and the line above falls through into it -- part of SysExSession_RepaintProgressIfChanged;
;  notes/prom_a_stray_label_removal.py)
	push XIX                                             ; FB7E7C  3c
	push XIZ                                             ; FB7E7D  3e
	call T_Paint_Sending_Entry                                        ; FB7E7E  1d 30 17 f4
	pop XIZ                                              ; FB7E82  5e
	pop XIX                                              ; FB7E83  5c
	pop XHL                                              ; FB7E84  5b
	pop XDE                                              ; FB7E85  5a
	jr .LFB7E94                                          ; FB7E86  68 0c
.LFB7E88:
	push XDE                                             ; FB7E88  3a
	push XHL                                             ; FB7E89  3b
	push XIX                                             ; FB7E8A  3c
	push XIZ                                             ; FB7E8B  3e
	call T_Paint_SystemExclusivePleaseWait_Entry                                        ; FB7E8C  1d 34 17 f4
	pop XIZ                                              ; FB7E90  5e
	pop XIX                                              ; FB7E91  5c
	pop XHL                                              ; FB7E92  5b
	pop XDE                                              ; FB7E93  5a
.LFB7E94:
	res	6, (0x60fd42:24)                             ; FB7E94  f2 42 fd 60 b6
.LFB7E99:
	ret                                                  ; FB7E99  0e
SysExSession_RepaintProgressIfChanged_Nop:
	ret                                                  ; FB7E9A  0e
MessageScreen_Paint_SaveRegs:
	push XDE                                             ; FB7E9B  3a
	push XHL                                             ; FB7E9C  3b
	push XIX                                             ; FB7E9D  3c
	push XIZ                                             ; FB7E9E  3e
	call T_MessageScreen_Paint                                        ; FB7E9F  1d 00 16 f4
	pop XIZ                                              ; FB7EA3  5e
	pop XIX                                              ; FB7EA4  5c
	pop XHL                                              ; FB7EA5  5b
	pop XDE                                              ; FB7EA6  5a
	ret                                                  ; FB7EA7  0e
; SysExSession_OnAbort_SystemPartMidi: the abort arm for steps 1-3; bit 4 of (0x60F020) around T_ParamModule_PhaseVector slot +8, T_ParamImage_PostAllAsChangeEvents_Call, T_Tempo_ApplyBpm.
SysExSession_OnAbort_SystemPartMidi:
	set	4, (0x60f020:24)                             ; FB7EA8  f2 20 f0 60 bc
	push XDE                                             ; FB7EAD  3a
	push XHL                                             ; FB7EAE  3b
	push XIX                                             ; FB7EAF  3c
	push XIZ                                             ; FB7EB0  3e
	ld xbc, (T_ParamModule_PhaseVector:24)                               ; FB7EB1  e2 70 07 f4 21
	inc 8,XBC                                            ; FB7EB6  e9 60
	lda xiy, (.LFB7EC0:24)                               ; FB7EB8  f2 c0 7e fb 35
	push XIY                                             ; FB7EBD  3d
	jp (xbc)                                             ; FB7EBE  b1 d8
.LFB7EC0:
	call T_ParamImage_PostAllAsChangeEvents_Call                                        ; FB7EC0  1d 74 07 f4
	call T_Tempo_ApplyBpm                                        ; FB7EC4  1d 94 07 f4
	pop XIZ                                              ; FB7EC8  5e
	pop XIX                                              ; FB7EC9  5c
	pop XHL                                              ; FB7ECA  5b
	pop XDE                                              ; FB7ECB  5a
	res	4, (0x60f020:24)                             ; FB7ECC  f2 20 f0 60 b4
	ret                                                  ; FB7ED1  0e
; SysExSession_OnAbort_Sound: the abort arm for steps 4-6: T_Msg0716_PostClearSoundRamAndRestageAllParts, T_Msg0716_PostRestageAllParts.
SysExSession_OnAbort_Sound:
	push XDE                                             ; FB7ED2  3a
	push XHL                                             ; FB7ED3  3b
	push XIX                                             ; FB7ED4  3c
	push XIZ                                             ; FB7ED5  3e
	call T_Msg0716_PostClearSoundRamAndRestageAllParts                                        ; FB7ED6  1d f0 0f f4
	call T_Msg0716_PostRestageAllParts                                        ; FB7EDA  1d ec 0f f4
	pop XIZ                                              ; FB7EDE  5e
	pop XIX                                              ; FB7EDF  5c
	pop XHL                                              ; FB7EE0  5b
	pop XDE                                              ; FB7EE1  5a
	ret                                                  ; FB7EE2  0e
SysExSession_OnAbort_Sound_Nop5:
	ret                                                  ; FB7EE3  0e
SysExSession_OnAbort_Sound_Nop:
	ret                                                  ; FB7EE4  0e
; SysExSession_OnAbort_Sequencer: the abort arm for steps 11-14: the routine at prom_b 0xF409C0 slot +8.
SysExSession_OnAbort_Sequencer:
	push XDE                                             ; FB7EE5  3a
	push XHL                                             ; FB7EE6  3b
	push XIX                                             ; FB7EE7  3c
	push XIZ                                             ; FB7EE8  3e
	ld xbc, (0xf409c0:24)                               ; FB7EE9  e2 c0 09 f4 21
	inc 8,XBC                                            ; FB7EEE  e9 60
	lda xiy, (.LFB7EF8:24)                               ; FB7EF0  f2 f8 7e fb 35
	push XIY                                             ; FB7EF5  3d
	jp (xbc)                                             ; FB7EF6  b1 d8
.LFB7EF8:
	pop XIZ                                              ; FB7EF8  5e
	pop XIX                                              ; FB7EF9  5c
	pop XHL                                              ; FB7EFA  5b
	pop XDE                                              ; FB7EFB  5a
	ret                                                  ; FB7EFC  0e
; ---------------------------------------------------------------------
; MidiInARing_InitIfPanelMode79 -- re-initialises ring 0x600C1E, with interrupts masked, only
;                                 while the panel mode byte reads 0x79
;
; Evidence: 0xFB7EFD `m_cp_mi8 MB16, 0x207a, 0x79` and 0xFB7F02 `jr nz`
;           gate the whole body; 0xFB7F04 `ei 0x06` raises the mask,
;           0xFB7F06 `call 0xF41DB8` = prom_b slot T_MidiInARing_Init,
;           0xFB7F0A `ei 0x00` lowers it. (0x207A) is this listing's
;           panel mode byte -- PanelState_UpdateScreenLatch (0xF863F5) is
;           headed `(0x207A) := (0x207C) unless the mode is unchanged`.
;           Called by `call` at 0xFB2058, 0xFB20F2, 0xFB21EF and
;           0xFB607F
; Unknown:  what mode 0x79 is. The listing tests (0x207A) against 0x0D,
;           0x13, 0x79, 0xB7 and 0xDB in five different modules and
;           names none of the values
; Was `sub_FB7EFD`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
MidiInARing_InitIfPanelMode79:
	cp	(UI_ScreenLatch:16), 0x79                            ; FB7EFD  c1 7a 20 3f 79
	jr nz, .LFB7F0C                                      ; FB7F02  6e 08
	ei 0x06                                              ; FB7F04  06 06
	call T_MidiInARing_Init                               ; FB7F06  1d b8 1d f4
	ei 0x00                                              ; FB7F0A  06 00
.LFB7F0C:
	ret                                                  ; FB7F0C  0e
; ---------------------------------------------------------------------
; Ring601646_InitIrqMasked -- re-initialises ring 0x601646 with the interrupt mask
;                             raised to 6
;
; Evidence: 0xFB7F0D `ei 0x06`, 0xFB7F0F `call 0xF41E48` = prom_b slot
;           T_Ring601646_Init, 0xFB7F13 `ei 0x00`, 0xFB7F15 `ret`.
;           Called by `call` at 0xFB7769, inside SysExRx_CheckMidiErrors. ★ THE
;           EXTENT HOLDS A SECOND ROUTINE THIS LABEL DOES NOT COVER:
;           0xFB7F16-0xFB7F1E is the same four instructions for
;           T_Ring601432_Init (slot 0xF41E00) and carries no label
;           because nothing in either image references it -- which is
;           why it is described here and not labelled
; Unknown:  why this ring's Init is masked when Ring_InitAllFourteen
;           calls all fourteen unmasked
; Was `sub_FB7F0D`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
Ring601646_InitIrqMasked:
	ei 0x06                                              ; FB7F0D  06 06
	call T_Ring601646_Init                               ; FB7F0F  1d 48 1e f4
	ei 0x00                                              ; FB7F13  06 00
	ret                                                  ; FB7F15  0e
	ei 0x06                                              ; FB7F16  06 06
	call T_Ring601432_Init                               ; FB7F18  1d 00 1e f4
	ei 0x00                                              ; FB7F1C  06 00
	ret                                                  ; FB7F1E  0e
; SysEx_ClearRemoteId: 0xFF into the remote device id triple (0x60FC90..92) and (0x60FC94..96).
SysEx_ClearRemoteId:
	pushw hl                                             ; FB7F1F  2b
	push XIX                                             ; FB7F20  3c
	lda xix, (0x60fc90:24)                               ; FB7F21  f2 90 fc 60 34
	ld h, 0xff:opc                                          ; FB7F26  26 ff
	ld (0x60fc94:24), h                                 ; FB7F28  f2 94 fc 60 46
	ld (0x60fc95:24), h                                 ; FB7F2D  f2 95 fc 60 46
	ld (0x60fc96:24), h                                 ; FB7F32  f2 96 fc 60 46
	ld (XIX),H                                           ; FB7F37  b4 46
	ld (XIX+0x01),H                                      ; FB7F39  bc 01 46
	ld (XIX+0x02),H                                      ; FB7F3C  bc 02 46
	pop XIX                                              ; FB7F3F  5c
	popw hl                                              ; FB7F40  4b
	ret                                                  ; FB7F41  0e
; SysExBuf_InitAll: install the four buffers 0x60F820/0x60F938 (receive) and 0x60FA50/0x60FB68 (transmit) with their records 0x60FC98..0x60FCC8, and reset each.
SysExBuf_InitAll:
	push XIX                                             ; FB7F42  3c
	lda xix, (SysExBuf_Reset:24)                             ; FB7F43  f2 eb 7f fb 34
	lda xbc, (0x60f820:24)                               ; FB7F48  f2 20 f8 60 31
	ld (0x60fc80:24), xbc                               ; FB7F4D  f2 80 fc 60 61
	lda xwa, (0x60fc98:24)                               ; FB7F52  f2 98 fc 60 30
	ld (0x60fcd8:24), xwa                               ; FB7F57  f2 d8 fc 60 60
	lda xiy, (0x60f938:24)                               ; FB7F5C  f2 38 f9 60 35
	ld (0x60fc84:24), xiy                               ; FB7F61  f2 84 fc 60 65
	lda xbc, (0x60fca8:24)                               ; FB7F66  f2 a8 fc 60 31
	ld (0x60fcdc:24), xbc                               ; FB7F6B  f2 dc fc 60 61
	lda xbc, (0x60fa50:24)                               ; FB7F70  f2 50 fa 60 31
	ld (0x60fc88:24), xbc                               ; FB7F75  f2 88 fc 60 61
	lda xbc, (0x60fcb8:24)                               ; FB7F7A  f2 b8 fc 60 31
	ld (0x60fce0:24), xbc                               ; FB7F7F  f2 e0 fc 60 61
	lda xbc, (0x60fb68:24)                               ; FB7F84  f2 68 fb 60 31
	ld (0x60fc8c:24), xbc                               ; FB7F89  f2 8c fc 60 61
	lda xbc, (0x60fcc8:24)                               ; FB7F8E  f2 c8 fc 60 31
	ld (0x60fce4:24), xbc                               ; FB7F93  f2 e4 fc 60 61
	push XWA                                             ; FB7F98  38
	ld xbc, (0x60fc80:24)                               ; FB7F99  e2 80 fc 60 21
	push XBC                                             ; FB7F9E  39
	lda xiy, (.LFB7FA7:24)                               ; FB7F9F  f2 a7 7f fb 35
	push XIY                                             ; FB7FA4  3d
	jp (xix)                                             ; FB7FA5  b4 d8
.LFB7FA7:
	ld xbc, (0x60fcdc:24)                               ; FB7FA7  e2 dc fc 60 21
	push XBC                                             ; FB7FAC  39
	ld xwa, (0x60fc84:24)                               ; FB7FAD  e2 84 fc 60 20
	push XWA                                             ; FB7FB2  38
	lda xiy, (.LFB7FBB:24)                               ; FB7FB3  f2 bb 7f fb 35
	push XIY                                             ; FB7FB8  3d
	jp (xix)                                             ; FB7FB9  b4 d8
.LFB7FBB:
	ld xbc, (0x60fce0:24)                               ; FB7FBB  e2 e0 fc 60 21
	push XBC                                             ; FB7FC0  39
	ld xwa, (0x60fc88:24)                               ; FB7FC1  e2 88 fc 60 20
	push XWA                                             ; FB7FC6  38
	lda xiy, (.LFB7FCF:24)                               ; FB7FC7  f2 cf 7f fb 35
	push XIY                                             ; FB7FCC  3d
	jp (xix)                                             ; FB7FCD  b4 d8
.LFB7FCF:
	ld xbc, (0x60fce4:24)                               ; FB7FCF  e2 e4 fc 60 21
	push XBC                                             ; FB7FD4  39
	ld xwa, (0x60fc8c:24)                               ; FB7FD5  e2 8c fc 60 20
	push XWA                                             ; FB7FDA  38
	lda xiy, (.LFB7FE3:24)                               ; FB7FDB  f2 e3 7f fb 35
	push XIY                                             ; FB7FE0  3d
	jp (xix)                                             ; FB7FE1  b4 d8
.LFB7FE3:
	add XSP,0x00000020                                   ; FB7FE3  ef c8 20 00 00 00
	pop XIX                                              ; FB7FE9  5c
	ret                                                  ; FB7FEA  0e
; SysExBuf_Reset(buf, rec): count buf+0 = 0; cursors buf+2, +6, +0x0A = buf+0x0E with a 0xFF sentinel there; rec = the 16-byte template at prom_b 0xF511E9.
SysExBuf_Reset:
	link XIZ,0xfffc                                      ; FB7FEB  ee 0c fc ff
	push XIX                                             ; FB7FEF  3c
	ld XIX,(XIZ+0x08)                                    ; FB7FF0  ae 08 24
	ldw	(xix), 0x0000                                ; FB7FF3  b4 02 00 00
	ld XBC,XIX                                           ; FB7FF7  ec 89
	add XBC,0x0000000e                                   ; FB7FF9  e9 c8 0e 00 00 00
	ld (xiz-4), xbc                                      ; FB7FFF  be fc 61
	ld (XIX+0x02),XBC                                    ; FB8002  bc 02 61
	ld xbc, (xiz-4)                                      ; FB8005  ae fc 21
	ld (XIX+0x06),XBC                                    ; FB8008  bc 06 61
	ld xbc, (xiz-4)                                      ; FB800B  ae fc 21
	ld (XIX+0x0a),XBC                                    ; FB800E  bc 0a 61
	ld xbc, (xiz-4)                                      ; FB8011  ae fc 21
	ld (XBC),0xff                                        ; FB8014  b1 00 ff
	ld XIX,(XIZ+0x0c)                                    ; FB8017  ae 0c 24
	lda xiy, (0xf511e9:24)                               ; FB801A  f2 e9 11 f5 35
	ldw bc, 0x08                                         ; FB801F  31 08 00
	ldirw                                                ; FB8022  95 11
	pop XIX                                              ; FB8024  5c
	unlk XIZ                                             ; FB8025  ee 0d
	ret                                                  ; FB8027  0e
; SysExRx_SwapBuffers: the receive twin of SysExTx_SwapBuffers on (0x60FCD8)/(0x60FCDC) and (0x60FC80)/(0x60FC84); then SysExRx_ResetBuffer.
SysExRx_SwapBuffers:
	link XIZ,0xfff8                                      ; FB8028  ee 0c f8 ff
	push XIX                                             ; FB802C  3c
	lda xix, (0x60fc80:24)                               ; FB802D  f2 80 fc 60 34
	ld xbc, (0x60fcd8:24)                               ; FB8032  e2 d8 fc 60 21
	ld A,(XBC+0x04)                                      ; FB8037  89 04 21
	cp a, 0x00:i3                                          ; FB803A  c9 d8
	jr nz, .LFB807A                                      ; FB803C  6e 3c
	ld XWA,(XIX)                                         ; FB803E  a4 20
	add XWA,0x0000000e                                   ; FB8040  e8 c8 0e 00 00 00
	ld (xiz-4), xwa                                      ; FB8046  be fc 60
	ld XIY,(XIX)                                         ; FB8049  a4 25
	ld XBC,(XIY+0x0a)                                    ; FB804B  ad 0a 21
	cp XBC,XWA                                           ; FB804E  e8 f1
	jr z, .LFB807A                                       ; FB8050  66 28
	ld xbc, (0x60fcdc:24)                               ; FB8052  e2 dc fc 60 21
	ld (xiz-4), xbc                                      ; FB8057  be fc 61
	ld xwa, (0x60fcd8:24)                               ; FB805A  e2 d8 fc 60 20
	ld (0x60fcdc:24), xwa                               ; FB805F  f2 dc fc 60 60
	ld (0x60fcd8:24), xbc                               ; FB8064  f2 d8 fc 60 61
	ld xiy, (0x60fc84:24)                               ; FB8069  e2 84 fc 60 25
	ld (xiz-8), xiy                                      ; FB806E  be f8 65
	ld XBC,(XIX)                                         ; FB8071  a4 21
	ld (0x60fc84:24), xbc                               ; FB8073  f2 84 fc 60 61
	ld (XIX),XIY                                         ; FB8078  b4 65
.LFB807A:
	calr SysExRx_ResetBuffer                                      ; FB807A  1e 76 00
	pop XIX                                              ; FB807D  5c
	unlk XIZ                                             ; FB807E  ee 0d
	ret                                                  ; FB8080  0e
; SysExTx_SwapBuffers: when the transmit status is 0 and the frame is not empty, swap (0x60FCE0)/(0x60FCE4) and (0x60FC88)/(0x60FC8C), carry the step id
;   (field 3) over; then SysExTx_ResetBuffer.
SysExTx_SwapBuffers:
	link XIZ,0xfff8                                      ; FB8081  ee 0c f8 ff
	pushw hl                                             ; FB8085  2b
	push XIX                                             ; FB8086  3c
	lda xix, (0x60fc88:24)                               ; FB8087  f2 88 fc 60 34
	ld xbc, (0x60fce0:24)                               ; FB808C  e2 e0 fc 60 21
	ld A,(XBC+0x04)                                      ; FB8091  89 04 21
	cp a, 0x00:i3                                          ; FB8094  c9 d8
	jr nz, .LFB80EB                                      ; FB8096  6e 53
	ld XWA,(XIX)                                         ; FB8098  a4 20
	add XWA,0x0000000e                                   ; FB809A  e8 c8 0e 00 00 00
	ld (xiz-4), xwa                                      ; FB80A0  be fc 60
	ld XIY,(XIX)                                         ; FB80A3  a4 25
	ld XBC,(XIY+0x0a)                                    ; FB80A5  ad 0a 21
	cp XBC,XWA                                           ; FB80A8  e8 f1
	jr z, .LFB80EB                                       ; FB80AA  66 3f
	ld xbc, (0x60fce4:24)                               ; FB80AC  e2 e4 fc 60 21
	ld (xiz-4), xbc                                      ; FB80B1  be fc 61
	ld xwa, (0x60fce0:24)                               ; FB80B4  e2 e0 fc 60 20
	ld (0x60fce4:24), xwa                               ; FB80B9  f2 e4 fc 60 60
	ld (0x60fce0:24), xbc                               ; FB80BE  f2 e0 fc 60 61
	ld xiy, (0x60fc8c:24)                               ; FB80C3  e2 8c fc 60 25
	ld (xiz-8), xiy                                      ; FB80C8  be f8 65
	ld XBC,(XIX)                                         ; FB80CB  a4 21
	ld (0x60fc8c:24), xbc                               ; FB80CD  f2 8c fc 60 61
	ld (XIX),XIY                                         ; FB80D2  b4 65
	calr SysExTx_ResetBuffer                                      ; FB80D4  1e 2e 00
	ld xbc, (0x60fce4:24)                               ; FB80D7  e2 e4 fc 60 21
	ld A,(XBC+0x03)                                      ; FB80DC  89 03 21
	ld H,A                                               ; FB80DF  c9 8e
	ld xwa, (0x60fce0:24)                               ; FB80E1  e2 e0 fc 60 20
	ld (XWA+0x03),H                                      ; FB80E6  b8 03 46
	jr .LFB80EE                                          ; FB80E9  68 03
.LFB80EB:
	calr SysExTx_ResetBuffer                                      ; FB80EB  1e 17 00
.LFB80EE:
	pop XIX                                              ; FB80EE  5c
	popw hl                                              ; FB80EF  4b
	unlk XIZ                                             ; FB80F0  ee 0d
	ret                                                  ; FB80F2  0e
; SysExRx_ResetBuffer: SysExBuf_Reset((0x60FC80), (0x60FCD8)).
SysExRx_ResetBuffer:
	ld xbc, (0x60fcd8:24)                               ; FB80F3  e2 d8 fc 60 21
	push XBC                                             ; FB80F8  39
	ld xwa, (0x60fc80:24)                               ; FB80F9  e2 80 fc 60 20
	push XWA                                             ; FB80FE  38
	calr SysExBuf_Reset                                      ; FB80FF  1e e9 fe
	inc 8,XSP                                            ; FB8102  ef 60
	ret                                                  ; FB8104  0e
; SysExTx_ResetBuffer: SysExBuf_Reset((0x60FC88), (0x60FCE0)).
SysExTx_ResetBuffer:
	ld xbc, (0x60fce0:24)                               ; FB8105  e2 e0 fc 60 21
	push XBC                                             ; FB810A  39
	ld xwa, (0x60fc88:24)                               ; FB810B  e2 88 fc 60 20
	push XWA                                             ; FB8110  38
	calr SysExBuf_Reset                                      ; FB8111  1e d7 fe
	inc 8,XSP                                            ; FB8114  ef 60
	ret                                                  ; FB8116  0e
; SysExXfer_ClearJobRecords: Zeroes the four 16-byte transfer records from ZeroBlock16_F4FEA4: 0x60FCE8 (send job:
;   start, end, byte count, bytes per cell), 0x60FCF8 (send cursor: source, remaining), 0x60FD08 and 0x60FD18 (the
;   receive pair). Called by SysEx_ResetSession. Basis: caller + body + users. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_d8.json)
SysExXfer_ClearJobRecords:
	push XIX                                             ; FB8117  3c
	ldw bc, 0x08                                         ; FB8118  31 08 00
	lda	xiy, (ZeroBlock16_F4FEA4:24)                 ; FB811B  f2 a4 fe f4 35
	lda xix, (0x60fce8:24)                               ; FB8120  f2 e8 fc 60 34
	ldirw                                                ; FB8125  95 11
	ldw bc, 0x08                                         ; FB8127  31 08 00
	lda xiy, (0x60fce8:24)                               ; FB812A  f2 e8 fc 60 35
	lda xix, (0x60fcf8:24)                               ; FB812F  f2 f8 fc 60 34
	ldirw                                                ; FB8134  95 11
	ldw bc, 0x08                                         ; FB8136  31 08 00
	lda xiy, (0x60fce8:24)                               ; FB8139  f2 e8 fc 60 35
	lda xix, (0x60fd08:24)                               ; FB813E  f2 08 fd 60 34
	ldirw                                                ; FB8143  95 11
	ldw bc, 0x08                                         ; FB8145  31 08 00
	lda xiy, (0x60fce8:24)                               ; FB8148  f2 e8 fc 60 35
	lda xix, (0x60fd18:24)                               ; FB814D  f2 18 fd 60 34
	ldirw                                                ; FB8152  95 11
	pop XIX                                              ; FB8154  5c
	ret                                                  ; FB8155  0e
; SysEx_ResetSession: SysExBuf_InitAll, SysEx_ClearRemoteId, SysExXfer_ClearJobRecords; clear (0x60FD40..0x60FD44), (0x60F802), (0x60F804).
SysEx_ResetSession:
	calr SysExBuf_InitAll                                      ; FB8156  1e e9 fd
	calr SysEx_ClearRemoteId                                      ; FB8159  1e c3 fd
	calr SysExXfer_ClearJobRecords                                      ; FB815C  1e b8 ff
	ld (0x60fd40:24), 0x00                             ; FB815F  f2 40 fd 60 00 00
	ld (0x60fd41:24), 0x00                             ; FB8165  f2 41 fd 60 00 00
	ld (0x60fd42:24), 0x00                             ; FB816B  f2 42 fd 60 00 00
	ld (0x60fd43:24), 0x00                             ; FB8171  f2 43 fd 60 00 00
	ld (0x60fd44:24), 0x00                             ; FB8177  f2 44 fd 60 00 00
	ld (0x60f802:24), 0x00                             ; FB817D  f2 02 f8 60 00 00
	ld (0x60f804:24), 0x00                             ; FB8183  f2 04 f8 60 00 00
	ret                                                  ; FB8189  0e
; SysEx_ResetSession_Call: calls SysEx_ResetSession and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
SysEx_ResetSession_Call:
	calr SysEx_ResetSession                                      ; FB818A  1e c9 ff
	ret                                                  ; FB818D  0e
	ld XBC,(XSP+0x04)                                    ; FB818E  af 04 21
	ldc_cr32	xbc, CR_DMAD2                        ; FB8191  e9 2e 18
	ld C,(XSP+0x08)                                      ; FB8194  8f 08 23
	ldc_cr8	c, CR_DMAM2                                  ; FB8197  cb 2e 2a
	ret                                                  ; FB819A  0e
	ld XBC,(XSP+0x04)                                    ; FB819B  af 04 21
	ldc_cr32	xbc, CR_DMAS2                        ; FB819E  e9 2e 08
	ld BC,(XSP+0x08)                                     ; FB81A1  9f 08 21
	ldc_cr16	bc, CR_DMAC2                         ; FB81A4  d9 2e 28
	ret                                                  ; FB81A7  0e
	ld XBC,(XSP+0x04)                                    ; FB81A8  af 04 21
	ldc_cr32	xbc, CR_DMAS3                        ; FB81AB  e9 2e 0c
	ld C,(XSP+0x08)                                      ; FB81AE  8f 08 23
	ldc_cr8	c, CR_DMAM3                                  ; FB81B1  cb 2e 2e
	ret                                                  ; FB81B4  0e
	ld XBC,(XSP+0x04)                                    ; FB81B5  af 04 21
	ldc_cr32	xbc, CR_DMAD3                        ; FB81B8  e9 2e 1c
	ld BC,(XSP+0x08)                                     ; FB81BB  9f 08 21
	ldc_cr16	bc, CR_DMAC3                         ; FB81BE  d9 2e 2c
	ret                                                  ; FB81C1  0e
	ldc_16_cr	wa, CR_DMAC2                         ; FB81C2  d8 2f 28
	ret                                                  ; FB81C5  0e
	ldc_16_cr	wa, CR_DMAC3                         ; FB81C6  d8 2f 2c
	ret                                                  ; FB81C9  0e
	ldc_32_cr	xiy, CR_DMAD3                        ; FB81CA  ed 2f 1c
	ret                                                  ; FB81CD  0e
; MemCopyWords_Copy -- a second, byte-identical copy of MemCopyWords
;
; Evidence: 24 of 24 bytes equal to prom_a's MemCopyWords at 0xF8E6E2 and
;          to prom_c's at 0xF9A038 (zero differing on both diffs), and the
;          eleven-instruction mnemonic sequence is identical.  Reproduced
;          by notes/prom_a_understanding_round5.py --twins, which prints
;          the differing count for both diffs.
; Unknown: why the copy exists, and which of the two the callers of this
;          address use.  Neither was established.
; ---------------------------------------------------------------------
MemCopyWords_Copy:
	push XIX                                             ; FB81CE  3c
	ld BC,(XSP+0x10)                                     ; FB81CF  9f 10 21
	ld XIY,(XSP+0x08)                                    ; FB81D2  af 08 25
	ld XIX,(XSP+0x0c)                                    ; FB81D5  af 0c 24
	bit 0x00,BC                                          ; FB81D8  d9 33 00
	jr z, .LFB81DF                                       ; FB81DB  66 02
	ldi85                                                ; FB81DD  85 10
.LFB81DF:
	srl bc, 0x01                                         ; FB81DF  d9 ef 01
	ldirw                                                ; FB81E2  95 11
	pop XIX                                              ; FB81E4  5c
	ret                                                  ; FB81E5  0e
; Shl8ByCount(value, count): value << count, count up to 31 -- shifts by 16 (`sll A,C` with A = 0) when count >> 4 is set, then by count & 0x0F; retd 4.
Shl8ByCount:
	ld C,(XSP+0x04)                                      ; FB81E6  8f 04 23
	ld B,(XSP+0x06)                                      ; FB81E9  8f 06 22
	ld W,B                                               ; FB81EC  ca 88
	srl w, 0x04                                          ; FB81EE  c8 ef 04
	sub A,A                                              ; FB81F1  c9 a1
	cp w, 0x00:i3                                          ; FB81F3  c8 d8
	jr z, .LFB81F9                                       ; FB81F5  66 02
	.byte 0xcb, 0xfe                                     ; FB81F7  cb fe   sll A,C
.LFB81F9:
	ld A,B                                               ; FB81F9  ca 89
	and A,0x0f                                           ; FB81FB  c9 cc 0f
	jr Z,.LFB8202                                        ; FB81FE  66 02
	.byte 0xcb, 0xfe                                     ; FB8200  cb fe   sll A,C
.LFB8202:
	ld A,C                                               ; FB8202  cb 89
	retd 0x0004                                          ; FB8204  0f 04 00
; Shl16ByCount(value, count): the 16-bit (IY) twin of Shl8ByCount.
Shl16ByCount:
	ld IY,(XSP+0x04)                                     ; FB8207  9f 04 25
	ld B,(XSP+0x06)                                      ; FB820A  8f 06 22
	ld W,B                                               ; FB820D  ca 88
	srl w, 0x04                                          ; FB820F  c8 ef 04
	sub A,A                                              ; FB8212  c9 a1
	cp w, 0x00:i3                                          ; FB8214  c8 d8
	jr z, .LFB821A                                       ; FB8216  66 02
	.byte 0xdd, 0xfe                                     ; FB8218  dd fe   sll A,IY
.LFB821A:
	ld A,B                                               ; FB821A  ca 89
	and A,0x0f                                           ; FB821C  c9 cc 0f
	jr z, .LFB8223                                       ; FB821F  66 02
	.byte 0xdd, 0xfe                                     ; FB8221  dd fe   sll A,IY
.LFB8223:
	ld WA,IY                                             ; FB8223  dd 88
	retd 0x0004                                          ; FB8225  0f 04 00
; Lsr8ByCount(value, count): value >> count (logical), count up to 31, as Shl8ByCount with `srl A,C`.
Lsr8ByCount:
	ld C,(XSP+0x04)                                      ; FB8228  8f 04 23
	ld B,(XSP+0x06)                                      ; FB822B  8f 06 22
	ld W,B                                               ; FB822E  ca 88
	srl w, 0x04                                          ; FB8230  c8 ef 04
	sub A,A                                              ; FB8233  c9 a1
	cp w, 0x00:i3                                          ; FB8235  c8 d8
	jr z, .LFB823B                                       ; FB8237  66 02
	.byte 0xcb, 0xff                                     ; FB8239  cb ff   srl A,C
.LFB823B:
	ld A,B                                               ; FB823B  ca 89
	and A,0x0f                                           ; FB823D  c9 cc 0f
	jr z, .LFB8244                                       ; FB8240  66 02
	.byte 0xcb, 0xff                                     ; FB8242  cb ff   srl A,C
.LFB8244:
	ld A,C                                               ; FB8244  cb 89
	retd 0x0004                                          ; FB8246  0f 04 00
; Lsr16ByCount(value, count): the 16-bit (IY) twin of Lsr8ByCount.
Lsr16ByCount:
	ld IY,(XSP+0x04)                                     ; FB8249  9f 04 25
	ld B,(XSP+0x06)                                      ; FB824C  8f 06 22
	ld W,B                                               ; FB824F  ca 88
	srl w, 0x04                                          ; FB8251  c8 ef 04
	sub A,A                                              ; FB8254  c9 a1
	cp w, 0x00:i3                                          ; FB8256  c8 d8
	jr z, .LFB825C                                       ; FB8258  66 02
	.byte 0xdd, 0xff                                     ; FB825A  dd ff   srl A,IY
.LFB825C:
	ld A,B                                               ; FB825C  ca 89
	and A,0x0f                                           ; FB825E  c9 cc 0f
	jr z, .LFB8265                                       ; FB8261  66 02
	.byte 0xdd, 0xff                                     ; FB8263  dd ff   srl A,IY
.LFB8265:
	ld WA,IY                                             ; FB8265  dd 88
	retd 0x0004                                          ; FB8267  0f 04 00
; Divide32_Unsigned_Quotient_Copy: an exact copy of Divide32_Unsigned_Quotient (prom_b 0xF37F3A) -- all 22 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
Divide32_Unsigned_Quotient_Copy:
	link XIZ,0x0000                                      ; FB826A  ee 0c 00 00
	push XIX                                             ; FB826E  3c
	ld b, 0x20:opc                                          ; FB826F  22 20
	sub WA,WA                                            ; FB8271  d8 a0
	sub XIY,XIY                                          ; FB8273  ed a5
	sub XIX,XIX                                          ; FB8275  ec a4
.LFB8277:
	sll xix, 0x01                                        ; FB8277  ec ee 01
	sllw (xiz+0x08)                                      ; FB827A  9e 08 7e   sllw (XIZ+0x08)
	.byte 0xd8, 0x24, 0x00                               ; FB827D  d8 24 00   stcf 0x00,WA
	sllw (xiz+0x0a)                                      ; FB8280  9e 0a 7e   sllw (XIZ+0x0a)
	.byte 0xdc, 0x24, 0x00                               ; FB8283  dc 24 00   stcf 0x00,IX
	add (XIZ+0x0a),WA                                    ; FB8286  9e 0a 88
	sll xiy, 0x01                                        ; FB8289  ed ee 01
	cp XIX,(XIZ+0x0c)                                    ; FB828C  ae 0c f4
	jr c, .LFB8296                                       ; FB828F  67 05
	sub XIX,(XIZ+0x0c)                                   ; FB8291  ae 0c a4
	inc 1,XIY                                            ; FB8294  ed 61
.LFB8296:
	dec 1,B                                              ; FB8296  ca 69
	jr nz, .LFB8277                                      ; FB8298  6e dd
	pop XIX                                              ; FB829A  5c
	unlk XIZ                                             ; FB829B  ee 0d
	retd 0x0008                                          ; FB829D  0f 08 00

; ---------------------------------------------------------------------
; RecordTables_FB82A0 -- 2,566 bytes of DATA at the end of the 0xFB2000 module
;
; ★ THIS BLOCK IS WHY THE DECODE CHECK EXISTS.  Linearly disassembled it looks
; like plausible code, and it round-trips byte-exactly -- the byte gate cannot
; see the difference.  What sees it is
; `notes/prom_a_linear_decode_check.py 0xFB2000 0xFB8CA6 --offenders`: two
; instructions inside the module, at 0xFB846A and 0xFB8770, "call" addresses that
; are not instruction boundaries, and both of those bytes are inside this block.
;
; THE FRAMING, re-derived by notes/prom_a_fb2000_checks.py:
;   0xFB82A0    2 bytes, 0xFB 0x00, that fit no record;
;   0xFB82A2  332 SIX-BYTE RECORDS `[u16][u32]`, tiling EXACTLY to 0xFB8A69
;             (332 x 6 = 1,992 = 0xFB8A6A - 0xFB82A2).  ★ THE ENTRY COUNT COMES
;             FROM THE DATA'S OWN RULE -- every record's u32 is an address inside
;             this module -- and the stop is confirmed by a SECOND, independent
;             signal: the first record whose u32 leaves the module is exactly
;             where a byte ramp starts.  The first records are
;             (0x00FE, 0x00FB8296) (0x0EFF, 0x00FB7048) (0x0000, 0x00FB82A2);
;             the stretch at 0xFB83B6 has its u16 counting 0,1,2,... against a
;             fixed 0x00FB83AA pointer;
;   0xFB8A6A  a byte ramp 00 01 01 02 03 03 04 05 ... and then values in the
;             printable range that are not text;
;   0xFB8AAD onward, records that each hold THREE module pointers -- 0x00FB3C6F
;             or 0x00FB3C70, one of 0x00FB3533/0x00FB3534, and 0x00FB3949 --
;             among small fields.  ⚠ The stride is NOT established: the
;             pointer triples recur about every 0x21 bytes but not exactly.
; ⚠ SO ONLY THE FIRST ARRAY'S FRAMING IS ESTABLISHED, and the block is emitted as
; `.byte`, which is this tree's honest default.  Do not promote any of it to
; `.long`/`.short` without a reader that names that array's base and bound: no
; reader of any of these tables has been found.
; START AND END: the byte before, 0xFB829F, is the last of `retd 8`, the epilogue
; of the routine above; the byte after, 0xFB8CA6, is the first of the module's
; 858-byte 0x0E pad.
; ---------------------------------------------------------------------
RecordTables_FB82A0:
	.byte 0xfb, 0x00, 0xfe, 0x00, 0x96, 0x82, 0xfb, 0x00, 0xff, 0x0e, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00  ; FB82A0
	.byte 0xa2, 0x82, 0xfb, 0x00, 0xff, 0x0d, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0xae, 0x82, 0xfb, 0x00  ; FB82B0
	.byte 0xff, 0x0c, 0x48, 0x70, 0xfb, 0x00, 0xfe, 0x1f, 0x48, 0x70, 0xfb, 0x00, 0xff, 0x10, 0x48, 0x70  ; FB82C0
	.byte 0xfb, 0x00, 0xfe, 0x00, 0xc6, 0x82, 0xfb, 0x00, 0xff, 0x0f, 0x48, 0x70, 0xfb, 0x00, 0xfe, 0x00  ; FB82D0
	.byte 0xd2, 0x82, 0xfb, 0x00, 0xff, 0x0e, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0xde, 0x82, 0xfb, 0x00  ; FB82E0
	.byte 0xff, 0x0d, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0xea, 0x82, 0xfb, 0x00, 0xff, 0x0c, 0x48, 0x70  ; FB82F0
	.byte 0xfb, 0x00, 0xfe, 0x1c, 0x48, 0x70, 0xfb, 0x00, 0xff, 0x10, 0x48, 0x70, 0xfb, 0x00, 0xfe, 0x00  ; FB8300
	.byte 0x02, 0x83, 0xfb, 0x00, 0xff, 0x0f, 0x48, 0x70, 0xfb, 0x00, 0xfe, 0x00, 0x0e, 0x83, 0xfb, 0x00  ; FB8310
	.byte 0xff, 0x0e, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0x1a, 0x83, 0xfb, 0x00, 0xff, 0x0d, 0x48, 0x70  ; FB8320
	.byte 0xfb, 0x00, 0x00, 0x00, 0x26, 0x83, 0xfb, 0x00, 0xff, 0x0c, 0x48, 0x70, 0xfb, 0x00, 0xfe, 0x1b  ; FB8330
	.byte 0x48, 0x70, 0xfb, 0x00, 0xff, 0x10, 0x48, 0x70, 0xfb, 0x00, 0xfe, 0x00, 0x3e, 0x83, 0xfb, 0x00  ; FB8340
	.byte 0xff, 0x0f, 0x48, 0x70, 0xfb, 0x00, 0xfe, 0x00, 0x4a, 0x83, 0xfb, 0x00, 0xff, 0x0e, 0x48, 0x70  ; FB8350
	.byte 0xfb, 0x00, 0x00, 0x00, 0x56, 0x83, 0xfb, 0x00, 0xff, 0x0d, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00  ; FB8360
	.byte 0x62, 0x83, 0xfb, 0x00, 0xff, 0x0c, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0xd6, 0x7b, 0xfb, 0x00  ; FB8370
	.byte 0x08, 0x00, 0xa0, 0x78, 0xfb, 0x00, 0x60, 0x00, 0xe2, 0x75, 0xfb, 0x00, 0xff, 0x0c, 0x48, 0x70  ; FB8380
	.byte 0xfb, 0x00, 0x01, 0x19, 0x48, 0x70, 0xfb, 0x00, 0xff, 0x0e, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00  ; FB8390
	.byte 0x92, 0x83, 0xfb, 0x00, 0xff, 0x0e, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0x9e, 0x83, 0xfb, 0x00  ; FB83A0
	.byte 0xff, 0x0e, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x01, 0x00, 0xaa, 0x83  ; FB83B0
	.byte 0xfb, 0x00, 0x02, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x03, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x04, 0x00  ; FB83C0
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x05, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x06, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB83D0
	.byte 0x07, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x08, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x09, 0x00, 0xaa, 0x83  ; FB83E0
	.byte 0xfb, 0x00, 0x0a, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x0b, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x0c, 0x00  ; FB83F0
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x0d, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x0e, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8400
	.byte 0x0f, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x10, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x11, 0x00, 0xaa, 0x83  ; FB8410
	.byte 0xfb, 0x00, 0x12, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x13, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x14, 0x00  ; FB8420
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x15, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x16, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8430
	.byte 0x17, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x18, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x19, 0x00, 0xaa, 0x83  ; FB8440
	.byte 0xfb, 0x00, 0x1a, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x1b, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x1c, 0x00  ; FB8450
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x1d, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x1e, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8460
	.byte 0x1f, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x20, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x21, 0x00, 0xaa, 0x83  ; FB8470
	.byte 0xfb, 0x00, 0x22, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x23, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x24, 0x00  ; FB8480
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x25, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x26, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8490
	.byte 0x27, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x28, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x29, 0x00, 0xaa, 0x83  ; FB84A0
	.byte 0xfb, 0x00, 0x2a, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x2b, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x2c, 0x00  ; FB84B0
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x2d, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x2e, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB84C0
	.byte 0x2f, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x30, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x31, 0x00, 0xaa, 0x83  ; FB84D0
	.byte 0xfb, 0x00, 0x32, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x33, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x34, 0x00  ; FB84E0
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x35, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x36, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB84F0
	.byte 0x37, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x38, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x39, 0x00, 0xaa, 0x83  ; FB8500
	.byte 0xfb, 0x00, 0x3a, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x3b, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x3c, 0x00  ; FB8510
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x3d, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x3e, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8520
	.byte 0x3f, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x40, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x41, 0x00, 0xaa, 0x83  ; FB8530
	.byte 0xfb, 0x00, 0x42, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x43, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x44, 0x00  ; FB8540
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x45, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x46, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8550
	.byte 0x47, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x48, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x49, 0x00, 0xaa, 0x83  ; FB8560
	.byte 0xfb, 0x00, 0x4a, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x4b, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x4c, 0x00  ; FB8570
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x4d, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x4e, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8580
	.byte 0x4f, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x50, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x51, 0x00, 0xaa, 0x83  ; FB8590
	.byte 0xfb, 0x00, 0x52, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x53, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x54, 0x00  ; FB85A0
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x55, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x56, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB85B0
	.byte 0x57, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x58, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x59, 0x00, 0xaa, 0x83  ; FB85C0
	.byte 0xfb, 0x00, 0x5a, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x5b, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x5c, 0x00  ; FB85D0
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x5d, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x5e, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB85E0
	.byte 0x5f, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x60, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x61, 0x00, 0xaa, 0x83  ; FB85F0
	.byte 0xfb, 0x00, 0x62, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x63, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x64, 0x00  ; FB8600
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x65, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x66, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8610
	.byte 0x67, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x68, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x69, 0x00, 0xaa, 0x83  ; FB8620
	.byte 0xfb, 0x00, 0x6a, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x6b, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x6c, 0x00  ; FB8630
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x6d, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x6e, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8640
	.byte 0x6f, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x70, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x71, 0x00, 0xaa, 0x83  ; FB8650
	.byte 0xfb, 0x00, 0x72, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x73, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x74, 0x00  ; FB8660
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x75, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x76, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB8670
	.byte 0x77, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x78, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x79, 0x00, 0xaa, 0x83  ; FB8680
	.byte 0xfb, 0x00, 0x7a, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x7b, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x7c, 0x00  ; FB8690
	.byte 0xaa, 0x83, 0xfb, 0x00, 0x7d, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0x7e, 0x00, 0xaa, 0x83, 0xfb, 0x00  ; FB86A0
	.byte 0x7f, 0x00, 0xaa, 0x83, 0xfb, 0x00, 0xff, 0x0d, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0xb6, 0x83  ; FB86B0
	.byte 0xfb, 0x00, 0x01, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x02, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x03, 0x00  ; FB86C0
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x04, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x05, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB86D0
	.byte 0x06, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x07, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x08, 0x00, 0xb6, 0x83  ; FB86E0
	.byte 0xfb, 0x00, 0x09, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x0a, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x0b, 0x00  ; FB86F0
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x0c, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x0d, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8700
	.byte 0x0e, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x0f, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x10, 0x00, 0xb6, 0x83  ; FB8710
	.byte 0xfb, 0x00, 0x11, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x12, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x13, 0x00  ; FB8720
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x14, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x15, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8730
	.byte 0x16, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x17, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x18, 0x00, 0xb6, 0x83  ; FB8740
	.byte 0xfb, 0x00, 0x19, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x1a, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x1b, 0x00  ; FB8750
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x1c, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x1d, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8760
	.byte 0x1e, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x1f, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x20, 0x00, 0xb6, 0x83  ; FB8770
	.byte 0xfb, 0x00, 0x21, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x22, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x23, 0x00  ; FB8780
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x24, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x25, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8790
	.byte 0x26, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x27, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x28, 0x00, 0xb6, 0x83  ; FB87A0
	.byte 0xfb, 0x00, 0x29, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x2a, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x2b, 0x00  ; FB87B0
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x2c, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x2d, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB87C0
	.byte 0x2e, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x2f, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x30, 0x00, 0xb6, 0x83  ; FB87D0
	.byte 0xfb, 0x00, 0x31, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x32, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x33, 0x00  ; FB87E0
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x34, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x35, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB87F0
	.byte 0x36, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x37, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x38, 0x00, 0xb6, 0x83  ; FB8800
	.byte 0xfb, 0x00, 0x39, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x3a, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x3b, 0x00  ; FB8810
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x3c, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x3d, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8820
	.byte 0x3e, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x3f, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x40, 0x00, 0xb6, 0x83  ; FB8830
	.byte 0xfb, 0x00, 0x41, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x42, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x43, 0x00  ; FB8840
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x44, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x45, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8850
	.byte 0x46, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x47, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x48, 0x00, 0xb6, 0x83  ; FB8860
	.byte 0xfb, 0x00, 0x49, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x4a, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x4b, 0x00  ; FB8870
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x4c, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x4d, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8880
	.byte 0x4e, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x4f, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x50, 0x00, 0xb6, 0x83  ; FB8890
	.byte 0xfb, 0x00, 0x51, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x52, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x53, 0x00  ; FB88A0
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x54, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x55, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB88B0
	.byte 0x56, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x57, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x58, 0x00, 0xb6, 0x83  ; FB88C0
	.byte 0xfb, 0x00, 0x59, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x5a, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x5b, 0x00  ; FB88D0
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x5c, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x5d, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB88E0
	.byte 0x5e, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x5f, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x60, 0x00, 0xb6, 0x83  ; FB88F0
	.byte 0xfb, 0x00, 0x61, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x62, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x63, 0x00  ; FB8900
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x64, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x65, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8910
	.byte 0x66, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x67, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x68, 0x00, 0xb6, 0x83  ; FB8920
	.byte 0xfb, 0x00, 0x69, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x6a, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x6b, 0x00  ; FB8930
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x6c, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x6d, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8940
	.byte 0x6e, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x6f, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x70, 0x00, 0xb6, 0x83  ; FB8950
	.byte 0xfb, 0x00, 0x71, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x72, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x73, 0x00  ; FB8960
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x74, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x75, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB8970
	.byte 0x76, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x77, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x78, 0x00, 0xb6, 0x83  ; FB8980
	.byte 0xfb, 0x00, 0x79, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x7a, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x7b, 0x00  ; FB8990
	.byte 0xb6, 0x83, 0xfb, 0x00, 0x7c, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x7d, 0x00, 0xb6, 0x83, 0xfb, 0x00  ; FB89A0
	.byte 0x7e, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0x7f, 0x00, 0xb6, 0x83, 0xfb, 0x00, 0xff, 0x0c, 0x48, 0x70  ; FB89B0
	.byte 0xfb, 0x00, 0x00, 0x00, 0x7a, 0x83, 0xfb, 0x00, 0x10, 0x00, 0xbc, 0x86, 0xfb, 0x00, 0x40, 0x00  ; FB89C0
	.byte 0x6e, 0x83, 0xfb, 0x00, 0x20, 0x00, 0x32, 0x83, 0xfb, 0x00, 0x50, 0x00, 0xf6, 0x82, 0xfb, 0x00  ; FB89D0
	.byte 0x60, 0x00, 0xba, 0x82, 0xfb, 0x00, 0xff, 0x0b, 0x48, 0x70, 0xfb, 0x00, 0x11, 0x00, 0xc2, 0x89  ; FB89E0
	.byte 0xfb, 0x00, 0xff, 0x0a, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x00, 0xec, 0x89, 0xfb, 0x00, 0xff, 0x09  ; FB89F0
	.byte 0x48, 0x70, 0xfb, 0x00, 0x04, 0x00, 0xf8, 0x89, 0xfb, 0x00, 0xff, 0x08, 0x48, 0x70, 0xfb, 0x00  ; FB8A00
	.byte 0x25, 0x09, 0x48, 0x70, 0xfb, 0x00, 0x7e, 0x0a, 0x48, 0x70, 0xfb, 0x00, 0x23, 0x00, 0xb4, 0x70  ; FB8A10
	.byte 0xfb, 0x00, 0x24, 0x00, 0xc0, 0x70, 0xfb, 0x00, 0x2d, 0x00, 0xf4, 0x72, 0xfb, 0x00, 0x27, 0x00  ; FB8A20
	.byte 0xcc, 0x70, 0xfb, 0x00, 0x28, 0x00, 0xd8, 0x70, 0xfb, 0x00, 0x2c, 0x00, 0x7e, 0x82, 0xfb, 0x00  ; FB8A30
	.byte 0x2b, 0x00, 0x04, 0x8a, 0xfb, 0x00, 0x7f, 0x00, 0xa8, 0x70, 0xfb, 0x00, 0x29, 0x00, 0xe4, 0x70  ; FB8A40
	.byte 0xfb, 0x00, 0x2a, 0x00, 0xf0, 0x70, 0xfb, 0x00, 0x21, 0x00, 0x66, 0x70, 0xfb, 0x00, 0x22, 0x00  ; FB8A50
	.byte 0x8a, 0x70, 0xfb, 0x00, 0xff, 0x07, 0x48, 0x70, 0xfb, 0x00, 0x00, 0x01, 0x01, 0x02, 0x03, 0x03  ; FB8A60
	.byte 0x04, 0x05, 0x05, 0x05, 0x06, 0x07, 0x07, 0x07, 0x08, 0x09, 0x09, 0x0a, 0x23, 0x21, 0x21, 0x21  ; FB8A70
	.byte 0x21, 0x21, 0x21, 0x21, 0x22, 0x22, 0x22, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21  ; FB8A80
	.byte 0x21, 0x21, 0x0f, 0x21, 0x20, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x20, 0x20, 0x21, 0x00, 0x00  ; FB8A90
	.byte 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x08  ; FB8AA0
	.byte 0x00, 0x00, 0x00, 0x01, 0xb0, 0x01, 0x7f, 0x00, 0x7f, 0x00, 0x00, 0x00, 0x6f, 0x3c, 0xfb, 0x00  ; FB8AB0
	.byte 0x33, 0x35, 0xfb, 0x00, 0x49, 0x39, 0xfb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x91, 0x00  ; FB8AC0
	.byte 0xff, 0x30, 0xc0, 0x00, 0x01, 0x00, 0x6f, 0x3c, 0xfb, 0x00, 0x34, 0x35, 0xfb, 0x00, 0x49, 0x39  ; FB8AD0
	.byte 0xfb, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0x91, 0x02, 0xff, 0x00, 0x01, 0x00, 0x01, 0x00  ; FB8AE0
	.byte 0x6f, 0x3c, 0xfb, 0x00, 0x34, 0x35, 0xfb, 0x00, 0x49, 0x39, 0xfb, 0x00, 0x00, 0x00, 0x02, 0x00  ; FB8AF0
	.byte 0x00, 0x01, 0x70, 0x01, 0xff, 0x00, 0x0b, 0x00, 0x01, 0x00, 0x70, 0x3c, 0xfb, 0x00, 0x34, 0x35  ; FB8B00
	.byte 0xfb, 0x00, 0x49, 0x39, 0xfb, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x93, 0x00, 0x0f, 0x00  ; FB8B10
	.byte 0x09, 0x00, 0x01, 0x00, 0x70, 0x3c, 0xfb, 0x00, 0x34, 0x35, 0xfb, 0x00, 0x49, 0x39, 0xfb, 0x00  ; FB8B20
	.byte 0x00, 0x00, 0x10, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FB8B30
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00, 0x01  ; FB8B40
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FB8B50
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x01, 0xb0, 0x01, 0x7f, 0x00, 0x7f, 0x00  ; FB8B60
	.byte 0x01, 0x00, 0x70, 0x3c, 0xfb, 0x00, 0x0d, 0x36, 0xfb, 0x00, 0x12, 0x3a, 0xfb, 0x00, 0x00, 0x08  ; FB8B70
	.byte 0x08, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FB8B80
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x09, 0x00, 0x00, 0x01, 0x00, 0x00  ; FB8B90
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FB8BA0
	.byte 0x00, 0x00, 0x00, 0x08, 0x10, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; FB8BB0
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x11, 0x00  ; FB8BC0
	.byte 0x00, 0x01, 0x63, 0x00, 0xff, 0x09, 0x1b, 0x00, 0x01, 0x00, 0x6f, 0x3c, 0xfb, 0x00, 0xa7, 0x36  ; FB8BD0
	.byte 0xfb, 0x00, 0x49, 0x39, 0xfb, 0x00, 0x00, 0x08, 0x21, 0x00, 0x00, 0x01, 0x61, 0x00, 0xff, 0x01  ; FB8BE0
	.byte 0x63, 0x00, 0x01, 0x00, 0x6f, 0x3c, 0xfb, 0x00, 0xa7, 0x36, 0xfb, 0x00, 0x49, 0x39, 0xfb, 0x00  ; FB8BF0
	.byte 0x00, 0x08, 0x22, 0x00, 0x00, 0x01, 0x61, 0x15, 0xff, 0x00, 0x63, 0x00, 0x01, 0x00, 0x6f, 0x3c  ; FB8C00
	.byte 0xfb, 0x00, 0x34, 0x35, 0xfb, 0x00, 0x49, 0x39, 0xfb, 0x00, 0xae, 0x8a, 0xfb, 0x00, 0xb2, 0x8b  ; FB8C10
	.byte 0xfb, 0x00, 0xae, 0x8a, 0xfb, 0x00, 0xfc, 0x8a, 0xfb, 0x00, 0xae, 0x8a, 0xfb, 0x00, 0x30, 0x8b  ; FB8C20
	.byte 0xfb, 0x00, 0xae, 0x8a, 0xfb, 0x00, 0x64, 0x8b, 0xfb, 0x00, 0xae, 0x8a, 0xfb, 0x00, 0xae, 0x8a  ; FB8C30
	.byte 0xfb, 0x00, 0x38, 0x7f, 0x00, 0x00, 0x08, 0x08, 0x38, 0x7f, 0x00, 0x00, 0x08, 0x08, 0x38, 0x7f  ; FB8C40
	.byte 0x00, 0x00, 0x04, 0x04, 0x38, 0x7f, 0x00, 0x00, 0x08, 0x08, 0x3b, 0x7f, 0x00, 0x00, 0x20, 0x20  ; FB8C50
	.byte 0x3b, 0x7f, 0x00, 0x00, 0x40, 0x40, 0xae, 0x8a, 0xfb, 0x00, 0xc8, 0x8a, 0xfb, 0x00, 0xe2, 0x8a  ; FB8C60
	.byte 0xfb, 0x00, 0xfc, 0x8a, 0xfb, 0x00, 0x16, 0x8b, 0xfb, 0x00, 0x30, 0x8b, 0xfb, 0x00, 0x4a, 0x8b  ; FB8C70
	.byte 0xfb, 0x00, 0xae, 0x8a, 0xfb, 0x00, 0xae, 0x8a, 0xfb, 0x00, 0xc8, 0x8a, 0xfb, 0x00, 0xe2, 0x8a  ; FB8C80
	.byte 0xfb, 0x00, 0xfc, 0x8a, 0xfb, 0x00, 0x16, 0x8b, 0xfb, 0x00, 0x30, 0x8b, 0xfb, 0x00, 0x4a, 0x8b  ; FB8C90
	.byte 0xfb, 0x00, 0xae, 0x8a, 0xfb, 0x00                                  ; FB8CA0
	ret                                                  ; FB8CA6  0e

; 0xFB8CA7-0xFB8FFF -- 857 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 857, 1, 0x0E
