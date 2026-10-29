
; ==============================================================================
; 0xFC0000-0xFC2FFF -- the 0x0716 MESSAGE MODULE: an index-dispatched page of
; handlers, each of which stages a short message at RAM 0x0716 and posts it to
; CPU 2 over the 0x7C0000 link
; ==============================================================================
;
; CHOSEN by notes/prom_a_call_graph.py --modules: T_F40FC8-T_F41060 (39 slots,
; reference upper bound 94) is prom_a's second-ranked unconverted module and all
; 39 of its targets land here.  Two more whole modules land here as well --
; T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_Msg0716_HandlerTables_13-T_Msg0716_DispatchIndex_26 (77 slots) and T_F42470-T_F42524 (46 slots) -- so the span
; carries 165 of the directory's prom_a slots and 164 distinct targets, more
; than any other 12 KiB of the image.
;
; ITS BOUNDS ARE THE ROM'S, not a choice: 0xFBFFD4-0xFBFFFF is 44 bytes of 0x0E
; and 0xFC25EE-0xFC2FFF is 2578 more, while the longest run of 0x0E strictly
; inside the module is 11 bytes -- under the 32-byte floor at which
; notes/gen_prom_a_block.py emits `.fill`.  0xFC25ED is the last routine's own
; `ret`, given back to the code by that script's pad rule.
;
; NAMES.  The prefix is `Msg0716_`, after the RAM address the module stages into.
; That is an ADDRESS-DERIVED name of the kind this tree already uses
; (`Ring60000C_Get`, `Dev10C_ChanReset`), and it is deliberate: the mechanism
; below is established byte by byte, but WHAT is being edited is not.  The four
; strings suggest a sound/combi name editor and that is exactly the sort of
; plausible guess this tree prefers a `sub_XXXXXX` over.  Every routine whose
; role is not established keeps its address label.
;
; WHAT IT DOES.  Three things interlock, and each is readable in the bytes:
;
;   1. AN INDEX DISPATCHER, twice.  0xFC0990 and 0xFC09AF are two byte-identical
;      31-byte routines (byte 32 differs, so 31 is maximal):
;
;          ld L,(0x20b8)      ; L := the index
;          cp L,A             ; A := the page's highest legal index
;          jr UGT, ret        ; out of range -> do nothing
;          and (0x070f),0xfd  ; clear bit 1 of the module's flag byte
;          ld XIX,0x00000716  ; XIX := the message staging buffer
;          xor H,H
;          sla 0x02,HL        ; HL := 4 * index
;          ld XWA,(XIY+HL)    ; XWA := handler[index]
;          call T,XWA
;
;      XIY is the page's handler table and A is its last legal index, both
;      loaded by the caller.  72 callers have that exact three-instruction
;      shape, which is exactly the 64 + 8 `calr` sites the two dispatchers have.
;
;   2. TEN HANDLER TABLES that TILE 0xFC09CE-0xFC0BD9 exactly.  Each caller's
;      own `ld A,n` gives its table's length; the ten lengths are 14, 27, 7, 14,
;      8, 3, 15, 5, 20 and 18, they sum to 131 entries = 524 bytes, and
;      0xFC09CE + 524 = 0xFC0BDA, which is the value of entry 0 -- the table
;      ends exactly where the first routine it points at begins.  No gap, no
;      overlap, no count taken by eye.  All 131 entries are instruction
;      boundaries of this module; 50 of them are distinct.
;
;   3. EVERY HANDLER POSTS TO CPU 2.  The handlers build a short byte message at
;      RAM 0x0716 and call one of two senders:
;
;        0xFC1A1E  ld XIX,0x716; push XIX, BC, 0x0000; T_Link_SendBlockIn32ByteChunks
;        0xFC1B09  push XIX (the CALLER's), BC, 0x0001; T_Link_SendBlockIn32ByteChunks
;
;      Their fifteen shared bytes differ at exactly ONE offset, the pushed word.
;      T_Link_SendBlockIn32ByteChunks is prom_a 0xF8E02C, in the converted 0x7C0000 link
;      block-transfer layer.  That routine takes (stream, length, pointer),
;      chops the buffer into 0x20-byte packets and writes one header byte
;      `(stream << 5) | (n - 1)` to the link port -- `sll c,0x05` at 0xF8E0A7,
;      `ld XBC,0x007c0000` at 0xF8E0AF, `ld (XBC),A` at 0xF8E0B7.  So the two
;      senders differ only in which of the eight link streams they use.
;      0xFC1A1A is a `calr`-and-return trampoline onto the first; it is what the
;      module actually calls, 30 times, against 1 direct call on the callee.
;
; THE RAM IT OWNS, read out of the instructions and nowhere else:
;
;   0x0716..     the staged message.  Byte 0 is an opcode.  Nine distinct values
;                are written as `ld (XIX),imm` -- 0x00, 0x80, 0x88, 0x90, 0xB0,
;                0xC0, 0xD0, 0xE0, 0xF0, every one a multiple of 8 -- and five
;                more, 0x80 0x81 0x82 0x83 0x87, arrive by `ldir` from
;                Msg0716_DefaultMessages.  The length passed to a sender is 1 to
;                5 bytes.
;   0x070E,0x070F  two flag bytes.  0x070E's bits 0-3 are set by four
;                nine-byte published entry points at 0xFC065A, 0xFC0663,
;                0xFC066C and 0xFC0675, each of which also sets bit 0 of 0x070F.
;   0x20B8       the index the dispatcher reads; 15 sites name it.
;   0x20B9       the value being edited; 17 sites name it.
;   0x207A       a mode byte, named at 3 sites, all three inside
;                Msg0716_BiasOpcodeByMode.
;   0x76A2 + 0x40*k   32 records of 0x40 bytes, named by the table at 0xFC1162.
;
; WHAT IS **NOT** ESTABLISHED, and is left as `sub_XXXXXX` on purpose:
;   * what any individual handler does.  The four strings in the module --
;     "Sound Name *****", "Combi Name *****", "Combi Group Name", "EXT Silent
;     Group" -- are the only words it contains, and every one of them is used as
;     a FALLBACK, loaded only when a pointer compares equal to an all-ones
;     sentinel or a bit is clear.  They name the object, not the routine.
;   * what CPU 2 does with the messages.  Nothing on this side says.
;   * 0x00C00000, which the loader at 0xFC0076 passes to the link layer and adds
;     to two 16-bit offsets held at RAM 0x0874 and 0x087C.  prom_a and prom_b
;     contain ZERO instructions that dereference 0x00C00000 in any of the twelve
;     absolute-address spellings (`python3 notes/prom_a_addr_census.py
;     0xC00000` -> 0 hits, and the check script re-derives it), so it is an
;     address in the OTHER CPU's space; on CPU 2, 0x00C00000 is the expansion
;     board (notes/FINDINGS-memory-map.md row F5 and the CPU-2 table).  That the
;     two are the same 0xC00000 is an INFERENCE from where the argument goes,
;     not something this module says.
;
; ⚠ FIVE PUBLISHED DIRECTORY SLOTS IN THIS SPAN CANNOT BE ENTRY POINTS.
; T_F41184, T_F4118C, T_F41190, T_F41194 and T_F41198 are well-formed
; `jp 0xFC04xx` instructions, but 0xFC0427, 0xFC043D, 0xFC0452, 0xFC0453 and
; 0xFC0454 all lie INSIDE the 16-byte veneers at 0xFC0420-0xFC0460 and are not
; instruction boundaries of them.  prom_c is not an alternative reading (its
; bytes there decode to unrelated fragments).  All five have a reference upper
; bound of ZERO, and each is published by exactly one slot.
;
; ⚠ AND WHAT "RETIRED" MEANS.  notes/prom_a_frontier_delta.py counts all 164
; targets of this span retired, these five included, because "retired" there
; means the bytes left an `.incbin` -- which they did.  It does NOT mean a
; symbol exists: notes/gen_prom_a_block.py refused to place a label at any of
; the five (it prints them on stderr), because no line defines those addresses.
; Anyone following T_F41184 across finds the byte only through the address
; column of the listing.  The two senses of "retired" are not the same number
; and this is the span where they diverge.  See
; notes/FINDINGS-prom_a-msg0716-module.md.
;
; ⚠ AND 34 OF THE 164 PUBLISHED TARGETS ARE A BARE `ret`.  Their first byte is
; 0x0E and the runs they sit in are shorter than the pad floor, so they stay as
; `ret` instructions in the listing and DO take labels.  A slot count is not a
; count of routines.
; ---------------------------------------------------------------------
; Msg0716_InitAllRecords_Entry -- a PURE WRAPPER for Msg0716_InitAllRecords: it IS that
; routine, so it is named for it.  Its whole extent is
; a single unconditional `jp`, which cannot fall through,
; so the routine is that one instruction.
; Evidence: the `jp` at 0xFC0000 targets 0xFC0018, which carries the
;          label Msg0716_InitAllRecords.  The extent is measured to the next top-level
;          label, never to a source line -- notes/wave7-verify-probes/
;          wave7_r5_prom_a_painter_scope.py records what scoping to a
;          source line cost the round-5 pass.
; ---------------------------------------------------------------------

Msg0716_InitAllRecords_Entry:
	jp Msg0716_InitAllRecords                            ; FC0000  1b 18 00 fc
	ret                                                  ; FC0004  0e
	nop                                                  ; FC0005  00
	nop                                                  ; FC0006  00
	nop                                                  ; FC0007  00
	jp Msg0716_BootPhase2_MemoryLost                                        ; FC0008  1b 8e 01 fc
	jp RemoteImage_LoadHeader                            ; FC000C  1b 76 00 fc
	ret                                                  ; FC0010  0e
	nop                                                  ; FC0011  00
	nop                                                  ; FC0012  00
	nop                                                  ; FC0013  00
	ret                                                  ; FC0014  0e
	nop                                                  ; FC0015  00
	nop                                                  ; FC0016  00
	nop                                                  ; FC0017  00
; ---------------------------------------------------------------------
; Msg0716_InitAllRecords -- one message per record, then three fixed ones
;
; Called from: the module's own entry veneer at 0xFC0000 (`jp 0xFC0018`).  No
;          other site in prom_a or prom_b names 0xFC0018 in any spelling
;          notes/prom_a_ringbuf_map.all_refs() covers -- a searched negative,
;          re-run by notes/prom_a_fc0000_module_check.py.
; Inputs:  none.
; Outputs: 0x0716.. rewritten 35 times; (0x20B9) left at 0x7F.
; Evidence: the loop runs HL from 0 to 0x1F inclusive (`inc 1,HL`,
;          `cp HL,0x001f`, `jr ULE` back to 0xFC001B), writing HL into the
;          message's byte 1 and calling 0xFC15E1 -- 32 iterations, one per
;          record of Msg0716_ObjectRecords.  It then writes the fixed five
;          bytes C0 20 78 20 00, sets BC = 5 and calls the post trampoline;
;          then stages 0x20 with (0x20B9) = 0x64 and hands it to 0xFC151B; then
;          the same with (0x20B9) = 0x7F and hands it to 0xFC1679.
; Unknown: what opcode 0xC0 means to CPU 2, and why the last two stagings go
;          through two different routines instead of the trampoline.
; ---------------------------------------------------------------------
Msg0716_InitAllRecords:
	ldw hl, 0x00                                         ; FC0018  33 00 00
.LFC001B:
	ld XIX,0x00000716                                    ; FC001B  44 16 07 00 00
	ld (UiEvent_Byte2:16), 0x7f                                 ; FC0020  f1 b9 20 00 7f
	ld (XIX+0x01),L                                      ; FC0025  bc 01 47
	pushw hl                                             ; FC0028  2b
	calr Msg0716_PostCtrlInt97                                          ; FC0029  1e b5 15
	popw hl                                              ; FC002C  4b
	inc 1,HL                                             ; FC002D  db 61
	cp HL,0x001f                                         ; FC002F  db cf 1f 00
	jr ule, .LFC001B                                     ; FC0033  63 e6
	ld XIX,0x00000716                                    ; FC0035  44 16 07 00 00
	ld (XIX),0xc0                                        ; FC003A  b4 00 c0
	ld (XIX+0x01),0x20                                   ; FC003D  bc 01 00 20
	ld (XIX+0x02),0x78                                   ; FC0041  bc 02 00 78
	ld (XIX+0x03),0x20                                   ; FC0045  bc 03 00 20
	ld (XIX+0x04),0x00                                   ; FC0049  bc 04 00 00
	ldw bc, 0x05                                         ; FC004D  31 05 00
	calr Msg0716_Post_Trampoline                                          ; FC0050  1e c7 19
	ld XIX,0x00000716                                    ; FC0053  44 16 07 00 00
	ld (UiEvent_Byte2:16), 0x64                                 ; FC0058  f1 b9 20 00 64
	ld (XIX+0x01),0x20                                   ; FC005D  bc 01 00 20
	calr Msg0716_PostCC07_Volume                                          ; FC0061  1e b7 14
	ld XIX,0x00000716                                    ; FC0064  44 16 07 00 00
	ld (UiEvent_Byte2:16), 0x7f                                 ; FC0069  f1 b9 20 00 7f
	ld (XIX+0x01),0x20                                   ; FC006E  bc 01 00 20
	calr Msg0716_PostCC0B_Expression                                          ; FC0072  1e 04 16
	ret                                                  ; FC0075  0e
; ---------------------------------------------------------------------
; RemoteImage_LoadHeader -- fill RAM 0x08C0..0x08EB from a remote 0x00C00000
;
; Called from: the module's entry veneer at 0xFC000C (`jp 0xFC0076`), and
;          nothing else -- same searched negative as above.
; Inputs:  none.
; Outputs: 0x08C0-0x08DF filled with 0xFF; 0x08E0 and 0x08E4 set to
;          0x00C00000 + (0x0874) and + (0x087C); 0x08E8.. copied from 0x0890..
; Evidence: two identical 16-iteration `ld (XIY+),A` loops with A = 0xFF and
;          `cp C,0x10`, at 0xFC0076 over 0x08C0 and at 0xFC008A over 0x08D0.
;          Then `cp (0xc5),0x5a` guards everything after it, and a failure
;          takes `jrl NZ,0xfc018c` to this routine's own `ret`.  The remote read
;          is `ld XIX,0x00000860 / push / push 0x0034 / ld XIX,0x00c00000 /
;          push / call 0xf40ef0`, then `call 0xf4123c` (Link_WaitBlockDone) and
;          `cp WA,0xffff` -- request, wait, test for the 0xFFFF failure code.
; Unknown: everything about the layout at 0x00C00000 except that 0x34 bytes of
;          it are wanted and that two 16-bit fields of the result, at 0x0874 and
;          0x087C, are offsets within the same window.
; ---------------------------------------------------------------------
RemoteImage_LoadHeader:
	ld XIY,0x000008c0                                    ; FC0076  45 c0 08 00 00
	ld c, 0x00:opc                                          ; FC007B  23 00
.LFC007D:
	ld a, 0xff:opc                                          ; FC007D  21 ff
	ld (xiy+), a                                    ; FC007F  f5 f4 41
	add C,0x01                                           ; FC0082  cb c8 01
	cp C,0x10                                            ; FC0085  cb cf 10
	jr c, .LFC007D                                       ; FC0088  67 f3
	ld XIY,0x000008d0                                    ; FC008A  45 d0 08 00 00
	ld c, 0x00:opc                                          ; FC008F  23 00
.LFC0091:
	ld a, 0xff:opc                                          ; FC0091  21 ff
	ld (xiy+), a                                    ; FC0093  f5 f4 41
	add C,0x01                                           ; FC0096  cb c8 01
	cp C,0x10                                            ; FC0099  cb cf 10
	jr c, .LFC0091                                       ; FC009C  67 f3
	cp	(0xc5:8), 0x5a                               ; FC009E  c0 c5 3f 5a
	jrl nz, .LFC018C                                     ; FC00A2  7e e7 00
	ld XIX,0x00000860                                    ; FC00A5  44 60 08 00 00
	push XIX                                             ; FC00AA  3c
	pushw 0x34                                           ; FC00AB  0b 34 00
	ld XIX,0x00c00000                                    ; FC00AE  44 00 00 c0 00
	push XIX                                             ; FC00B3  3c
	call T_Link_SendCommandE2                            ; FC00B4  1d f0 0e f4
	add XSP,0x0000000a                                   ; FC00B8  ef c8 0a 00 00 00
	call T_Link_WaitBlockDone                            ; FC00BE  1d 3c 12 f4
	cp WA,0xffff                                         ; FC00C2  d8 cf ff ff
	jr nz, .LFC00CB                                      ; FC00C6  6e 03
	jrl .LFC018C                                         ; FC00C8  78 c1 00
.LFC00CB:
	ld xwa, (0x0874:16)                                 ; FC00CB  e1 74 08 20
	add XWA,0x00c00000                                   ; FC00CF  e8 c8 00 00 c0 00
	ld (0x08e0:16), xwa                                 ; FC00D5  f1 e0 08 60
	ld xwa, (0x087c:16)                                 ; FC00D9  e1 7c 08 20
	add XWA,0x00c00000                                   ; FC00DD  e8 c8 00 00 c0 00
	ld (0x08e4:16), xwa                                 ; FC00E3  f1 e4 08 60
	ld a, (0x0890:16)                                   ; FC00E7  c1 90 08 21
	ld (0x08e8:16), a                                   ; FC00EB  f1 e8 08 41
	ld a, (0x0891:16)                                   ; FC00EF  c1 91 08 21
	ld (0x08e9:16), a                                   ; FC00F3  f1 e9 08 41
	ld a, (0x0892:16)                                   ; FC00F7  c1 92 08 21
	ld (0x08ea:16), a                                   ; FC00FB  f1 ea 08 41
	ld a, (0x0893:16)                                   ; FC00FF  c1 93 08 21
	ld (0x08eb:16), a                                   ; FC0103  f1 eb 08 41
	ld XIY,0x000008c0                                    ; FC0107  45 c0 08 00 00
	ld a, (0x0891:16)                                   ; FC010C  c1 91 08 21
	cp a, 0x00:i3                                          ; FC0110  c9 d8
	jr z, .LFC0133                                       ; FC0112  66 1f
	set	0, (0x08ec:16)                               ; FC0114  f1 ec 08 b8
.LFC0118:
	cp A,0x08                                            ; FC0118  c9 cf 08
	jr c, .LFC0126                                       ; FC011B  67 09
	ld (xiy+), 0x07                                  ; FC011D  f5 f4 00 07
	sub A,0x08                                           ; FC0121  c9 ca 08
	jr .LFC0118                                          ; FC0124  68 f2
.LFC0126:
	cp XIY,0x000008d0                                    ; FC0126  ed cf d0 08 00 00
	jr ugt, .LFC0133                                     ; FC012C  6b 05
	sub A,0x01                                           ; FC012E  c9 ca 01
	ld (XIY),A                                           ; FC0131  b5 41
.LFC0133:
	ld XIY,0x000008d0                                    ; FC0133  45 d0 08 00 00
	ld a, (0x0893:16)                                   ; FC0138  c1 93 08 21
	cp a, 0x00:i3                                          ; FC013C  c9 d8
	jr z, .LFC015F                                       ; FC013E  66 1f
	set	1, (0x08ec:16)                               ; FC0140  f1 ec 08 b9
.LFC0144:
	cp A,0x08                                            ; FC0144  c9 cf 08
	jr c, .LFC0152                                       ; FC0147  67 09
	ld (xiy+), 0x07                                  ; FC0149  f5 f4 00 07
	sub A,0x08                                           ; FC014D  c9 ca 08
	jr .LFC0144                                          ; FC0150  68 f2
.LFC0152:
	cp XIY,0x000008e0                                    ; FC0152  ed cf e0 08 00 00
	jr ugt, .LFC015F                                     ; FC0158  6b 05
	sub A,0x01                                           ; FC015A  c9 ca 01
	ld (XIY),A                                           ; FC015D  b5 41
.LFC015F:
	cp	(0x0891:16), 0x00                            ; FC015F  c1 91 08 3f 00
	jr z, .LFC018C                                       ; FC0164  66 26
	ld XWA,0x00002f80                                    ; FC0166  40 80 2f 00 00
	push XWA                                             ; FC016B  38
	ld a, (0x0891:16)                                   ; FC016C  c1 91 08 21
	xor W,W                                              ; FC0170  c8 d0
	pushw wa                                             ; FC0172  28
	ld xwa, (0x0878:16)                                 ; FC0173  e1 78 08 20
	add XWA,0x00c00000                                   ; FC0177  e8 c8 00 00 c0 00
	push XWA                                             ; FC017D  38
	call T_Link_SendCommandE2                            ; FC017E  1d f0 0e f4
	add XSP,0x0000000a                                   ; FC0182  ef c8 0a 00 00 00
	call T_Link_WaitBlockDone                            ; FC0188  1d 3c 12 f4
.LFC018C:
	ret                                                  ; FC018C  0e
T_F40FF4_Nop:
	ret                                                  ; FC018D  0e
; Msg0716_BootPhase2_MemoryLost: module 20's boot phase 2 handler -- ModuleInitDirectory_F82641[20]'s vector 0xFC0000, slot 2
;   (phase 1 runs when both power-fail checksums verify, phase 2 when one fails; notes/prom_a_module_boot_phase_names.py).
Msg0716_BootPhase2_MemoryLost:
	calr MapBlocks_ResetDirectory                                      ; FC018E  1e 0a 00
	calr SoundRemap_ResetToDefault                                      ; FC0191  1e 1d 00
	calr CombiRemap_ResetToDefault                                      ; FC0194  1e 30 00
; DrumMap_ResetToDefault_Call: calls DrumMap_ResetToDefault and returns -- `calr DrumMap_ResetToDefault / ret`.
DrumMap_ResetToDefault_Call:
	calr DrumMap_ResetToDefault                                      ; FC0197  1e 43 00
	ret                                                  ; FC019A  0e
; MapBlocks_ResetDirectory: Copies RamDefault_F30800's 16 bytes to RAM 0x5200: the directory of the three map blocks
;   after it, offsets 0x10 / 0x660 / 0xCB0 = SoundRemap_Ram 0x5210, CombiRemap_Ram 0x5860, DrumMap_Ram 0x5EB0. First
;   step of Msg0716_BootPhase2_MemoryLost, before SoundRemap_ / CombiRemap_ / DrumMap_ResetToDefault. Basis: caller +
;   body + the default bytes. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
MapBlocks_ResetDirectory:
	pushw bc                                             ; FC019B  29
	push XIX                                             ; FC019C  3c
	push XIY                                             ; FC019D  3d
	ldw bc, 0x10                                         ; FC019E  31 10 00
	ld XIY,RamDefault_F30800                             ; FC01A1  45 00 08 f3 00
	ld XIX,0x00005200                                    ; FC01A6  44 00 52 00 00
	ldir85                                               ; FC01AB  85 11
	pop XIY                                              ; FC01AD  5d
	pop XIX                                              ; FC01AE  5c
	popw bc                                              ; FC01AF  49
	ret                                                  ; FC01B0  0e
; SoundRemap_ResetToDefault: copies 0x650 bytes from RamDefault_SoundRemap to RAM 0x5210 -- the block DiskLoad_SoundRemap fills from a .SRM file.
;   Called by Msg0716_BootPhase2_MemoryLost.
SoundRemap_ResetToDefault:
	pushw bc                                             ; FC01B1  29
	push XIX                                             ; FC01B2  3c
	push XIY                                             ; FC01B3  3d
	ldw bc, 0x0650                                       ; FC01B4  31 50 06
	ld XIY,RamDefault_SoundRemap                             ; FC01B7  45 10 08 f3 00
	ld XIX,SoundRemap_Ram                                    ; FC01BC  44 10 52 00 00
	ldir85                                               ; FC01C1  85 11
	pop XIY                                              ; FC01C3  5d
	pop XIX                                              ; FC01C4  5c
	popw bc                                              ; FC01C5  49
	ret                                                  ; FC01C6  0e
; CombiRemap_ResetToDefault: copies 0x650 bytes from RamDefault_CombiRemap to RAM 0x5860 -- the block DiskLoad_CombiRemap fills from a .CRM file.
CombiRemap_ResetToDefault:
	pushw bc                                             ; FC01C7  29
	push XIX                                             ; FC01C8  3c
	push XIY                                             ; FC01C9  3d
	ldw bc, 0x0650                                       ; FC01CA  31 50 06
	ld XIY,RamDefault_CombiRemap                             ; FC01CD  45 60 0e f3 00
	ld XIX,CombiRemap_Ram                                    ; FC01D2  44 60 58 00 00
	ldir85                                               ; FC01D7  85 11
	pop XIY                                              ; FC01D9  5d
	pop XIX                                              ; FC01DA  5c
	popw bc                                              ; FC01DB  49
	ret                                                  ; FC01DC  0e
; DrumMap_ResetToDefault: copies 0x1D0 bytes from RamDefault_DrumMap to RAM 0x5EB0 -- the block DiskLoad_DrumMap fills from a .DRM file.
DrumMap_ResetToDefault:
	pushw bc                                             ; FC01DD  29
	push XIX                                             ; FC01DE  3c
	push XIY                                             ; FC01DF  3d
	ldw bc, 0x01d0                                       ; FC01E0  31 d0 01
	ld XIY,RamDefault_DrumMap                             ; FC01E3  45 b0 14 f3 00
	ld XIX,DrumMap_Ram                                    ; FC01E8  44 b0 5e 00 00
	ldir85                                               ; FC01ED  85 11
	pop XIY                                              ; FC01EF  5d
	pop XIX                                              ; FC01F0  5c
	popw bc                                              ; FC01F1  49
	ret                                                  ; FC01F2  0e
; Msg0716_PostClearSoundRamAndRestageAllParts: Msg0716_PostClearSoundRamBanks posts the 6-byte link request 88 00 17 00 00 00 (Msg0716_PostClearSoundRamRequest, stream
;   0) -- CPU 2's query table (request[0] bit 3), arm 0 ToneQuery_Dispatch, opcode 0x17, above its 22-opcode guard --
;   then Msg0716_PostRestageAllParts. The first call of SysExSession_OnAbort_Sound (T_Msg0716_PostClearSoundRamAndRestageAllParts);
;   SysExSession_OnEnd_Sound sends 88 00 18 in its place. What opcode 0x17 means is not established. Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
; CORRECTION (wave 10): 88 00 17 has request[0] bit 3 SET, which selects CPU 2's WRITE table (ToneMsg_Dispatch:
;   `and w, 8` / `jrl z` to the query half); write arm 0 is ToneEdit_Dispatch, whose opcode 0x17 calls
;   SoundRam_ClearFourBanks. So an aborted SOUND dump clears the four WSA SOUND RAM flash banks, then restages every part.
;   The wave-9 header above has the polarity wrong. (notes/naming-pilot-2026-10-06/proposals_wave10_a10.json)
Msg0716_PostClearSoundRamAndRestageAllParts:
	calr Msg0716_PostClearSoundRamBanks                                      ; FC01F3  1e 04 00
	calr Msg0716_PostRestageAllParts                                      ; FC01F6  1e 0d 00
	ret                                                  ; FC01F9  0e
; Msg0716_PostClearSoundRamBanks: XIX := 0x0716, then Msg0716_PostClearSoundRamRequest builds and Msg0716_Post sends (stream 0) the link
;   request 88 00 17 00 00 00. On CPU 2 bit 3 of byte 0 selects ToneMsg_Dispatch's WRITE table, arm 0 =
;   ToneEdit_Dispatch, whose opcode-0x17 arm calls SoundRam_ClearFourBanks (the four 'WSA SOUND RAM S0..S3' flash
;   banks). First step of Msg0716_PostClearSoundRamAndRestageAllParts, i.e. of SysExSession_OnAbort_Sound. Basis: caller + body
;   + CPU-2 dispatch. (notes/naming-pilot-2026-10-06/proposals_wave10_a10.json)
Msg0716_PostClearSoundRamBanks:
	push XIX                                             ; FC01FA  3c
	ld XIX,0x00000716                                    ; FC01FB  44 16 07 00 00
	call Msg0716_PostClearSoundRamRequest                                      ; FC0200  1d e0 19 fc
	pop XIX                                              ; FC0204  5c
	ret                                                  ; FC0205  0e
; Msg0716_PostRestageAllParts: Posts F0 50 92 00 (Msg0716_PostSysEx50_92) -- CPU 2's GlobalSetup_Dispatch arm 0x92
;   (prom_c sub_FB029E) resets each of parts 0..32 to defaults and reloads its tone record and voice parameters --
;   then PartSound_RequeuePart0IfUserBank: if part 0's record (0x76A2) +1, the bank, is 0x08..0x0F, re-queues its bank (byte 1, mask 0x7F)
;   and program (byte 0, mask 0xFF) to Queue2E00. Run when a received SOUND dump ends or aborts. Basis: callers + body
;   + CPU-2 arm. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_PostRestageAllParts:
	push XIX                                             ; FC0206  3c
	calr Msg0716_PostSysEx50_92                                          ; FC0207  1e f5 17
	calr PartSound_RequeuePart0IfUserBank                                      ; FC020A  1e 08 00
	pop XIX                                              ; FC020D  5c
	ret                                                  ; FC020E  0e
; Msg0716_PostSysEx50_92_SaveRegs: calls Msg0716_PostSysEx50_92 with the registers it pushes saved around it -- `push XIX / calr Msg0716_PostSysEx50_92 / pop XIX / ret`.
Msg0716_PostSysEx50_92_SaveRegs:
	push XIX                                             ; FC020F  3c
	calr Msg0716_PostSysEx50_92                                          ; FC0210  1e ec 17
	pop XIX                                              ; FC0213  5c
	ret                                                  ; FC0214  0e
; PartSound_RequeuePart0IfUserBank: XIX := 0x76A2 (part 0's record), E := 0, then PartSound_RequeuePartIfUserBank: if the bank byte (+1) is
;   0x08..0x0F -- SoundSel_Bank's U1/U2 codes -- appends {0, 1, bank, 0x7F} and {0, 0, program, 0xFF} to Queue2E00,
;   the PROGRAM CHANGE & BANK pair shape of ParamImage_QueuePartFieldChange. Last step of Msg0716_PostRestageAllParts
;   (after CPU 2 has restaged every part). Basis: caller + body + bank codes. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_a10.json)
PartSound_RequeuePart0IfUserBank:
	push XIX                                             ; FC0215  3c
	pushw de                                             ; FC0216  2a
	pushw wa                                             ; FC0217  28
	ld XIX,0x000076a2                                    ; FC0218  44 a2 76 00 00
	ld e, 0x00:opc                                          ; FC021D  25 00
	call PartSound_RequeuePartIfUserBank                                      ; FC021F  1d 27 02 fc
	popw wa                                              ; FC0223  48
	popw de                                              ; FC0224  4a
	pop XIX                                              ; FC0225  5c
	ret                                                  ; FC0226  0e
; PartSound_RequeuePartIfUserBank: (XIX = a part record, E = its part key) If the record's bank byte (+1) is
;   0x08..0x0F (SoundSel_Bank's U1/U2 codes), appends {E, 1, bank, 0x7F} and {E, 0, program (+0), 0xFF} to Queue2E00.
;   The body of PartSound_RequeuePart0IfUserBank, which passes part 0's record (0x76A2) and key 0. Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
PartSound_RequeuePartIfUserBank:
	ld A,(XIX+0x01)                                      ; FC0227  8c 01 21
	cp A,0x08                                            ; FC022A  c9 cf 08
	jr c, .LFC024E                                       ; FC022D  67 1f
	cp A,0x10                                            ; FC022F  c9 cf 10
	jr nc, .LFC024E                                      ; FC0232  6f 1a
	ld d, 0x01:opc                                          ; FC0234  24 01
	ld w, 0x7f:opc                                          ; FC0236  20 7f
	ld A,(XIX+0x01)                                      ; FC0238  8c 01 21
	push E                                               ; FC023B  cd 04
	call T_Queue2E00_AppendRegs                          ; FC023D  1d 3c 0f f4
	pop E                                                ; FC0241  cd 05
	ld d, 0x00:opc                                          ; FC0243  24 00
	ld w, 0xff:opc                                          ; FC0245  20 ff
	ld	a, (xix+0:8)                                 ; FC0247  8c 00 21
	call T_Queue2E00_AppendRegs                          ; FC024A  1d 3c 0f f4
.LFC024E:
	ret                                                  ; FC024E  0e
T_F40FF8_Nop:
	ret                                                  ; FC024F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords                         ; FC0250  46 90 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0255  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC025A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC025C  1e 31 07
	ret                                                  ; FC025F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_8_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x8                     ; FC0260  46 98 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0265  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC026A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC026C  1e 21 07
	ret                                                  ; FC026F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_16_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x10                    ; FC0270  46 a0 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0275  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC027A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC027C  1e 11 07
	ret                                                  ; FC027F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_24_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x18                    ; FC0280  46 a8 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0285  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC028A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC028C  1e 01 07
	ret                                                  ; FC028F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_32_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x20                    ; FC0290  46 b0 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0295  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC029A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC029C  1e f1 06
	ret                                                  ; FC029F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_40_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x28                    ; FC02A0  46 b8 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC02A5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC02AA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC02AC  1e e1 06
	ret                                                  ; FC02AF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_48_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x30                    ; FC02B0  46 c0 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC02B5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC02BA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC02BC  1e d1 06
	ret                                                  ; FC02BF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_56_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x38                    ; FC02C0  46 c8 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC02C5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC02CA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC02CC  1e c1 06
	ret                                                  ; FC02CF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_64_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x40                    ; FC02D0  46 d0 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC02D5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC02DA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC02DC  1e b1 06
	ret                                                  ; FC02DF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_72_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x48                    ; FC02E0  46 d8 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC02E5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC02EA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC02EC  1e a1 06
	ret                                                  ; FC02EF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_80_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x50                    ; FC02F0  46 e0 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC02F5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC02FA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC02FC  1e 91 06
	ret                                                  ; FC02FF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_88_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x58                    ; FC0300  46 e8 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0305  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC030A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC030C  1e 81 06
	ret                                                  ; FC030F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_96_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x60                    ; FC0310  46 f0 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0315  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC031A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC031C  1e 71 06
	ret                                                  ; FC031F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_104_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x68                    ; FC0320  46 f8 08 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0325  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC032A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC032C  1e 61 06
	ret                                                  ; FC032F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_112_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x70                    ; FC0330  46 00 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0335  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC033A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC033C  1e 51 06
	ret                                                  ; FC033F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_120_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x78                    ; FC0340  46 08 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0345  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC034A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC034C  1e 41 06
	ret                                                  ; FC034F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_128_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x80                    ; FC0350  46 10 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0355  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC035A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC035C  1e 31 06
	ret                                                  ; FC035F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_136_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x88                    ; FC0360  46 18 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0365  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC036A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC036C  1e 21 06
	ret                                                  ; FC036F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_144_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x90                    ; FC0370  46 20 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0375  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC037A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC037C  1e 11 06
	ret                                                  ; FC037F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_152_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0x98                    ; FC0380  46 28 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0385  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC038A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC038C  1e 01 06
	ret                                                  ; FC038F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_160_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xA0                    ; FC0390  46 30 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0395  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC039A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC039C  1e f1 05
	ret                                                  ; FC039F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_168_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xA8                    ; FC03A0  46 38 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC03A5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC03AA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC03AC  1e e1 05
	ret                                                  ; FC03AF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_176_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xB0                    ; FC03B0  46 40 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC03B5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC03BA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC03BC  1e d1 05
	ret                                                  ; FC03BF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_184_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xB8                    ; FC03C0  46 48 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC03C5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC03CA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC03CC  1e c1 05
	ret                                                  ; FC03CF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_192_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xC0                    ; FC03D0  46 50 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC03D5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC03DA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC03DC  1e b1 05
	ret                                                  ; FC03DF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_200_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xC8                    ; FC03E0  46 58 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC03E5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC03EA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC03EC  1e a1 05
	ret                                                  ; FC03EF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_208_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xD0                    ; FC03F0  46 60 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC03F5  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC03FA  21 0d
	calr Msg0716_DispatchIndex                                          ; FC03FC  1e 91 05
	ret                                                  ; FC03FF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_216_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xD8                    ; FC0400  46 68 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0405  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC040A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC040C  1e 81 05
	ret                                                  ; FC040F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_224_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xE0                    ; FC0410  46 70 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0415  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC041A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC041C  1e 71 05
	ret                                                  ; FC041F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_232_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xE8                    ; FC0420  46 78 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0425  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC042A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC042C  1e 61 05
	ret                                                  ; FC042F  0e
; Msg0716_DispatchIndex_Msg0716_ObjectRecords_240_Msg0716_HandlerTables_13: Event class 0x1E's Msg0716 handler: XIZ =
;   Msg0716_ObjectRecords+0xF0 (object record 30), XIY = Msg0716_HandlerTables, A = 13, falling into
;   Msg0716_DispatchIndex_Entry. The family name of its 31 siblings (records 0..29 and 31, e.g. _224_ for class 0x1C,
;   _248_ for 0x1F). Basis: table index + body + family. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_DispatchIndex_Msg0716_ObjectRecords_240_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xF0                    ; FC0430  46 80 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0435  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC043A  21 0d
; ---------------------------------------------------------------------
; Msg0716_DispatchIndex_Entry -- a PURE WRAPPER for Msg0716_DispatchIndex: it IS that
; routine, so it is named for it.  Its whole extent is
; one `calr` and the `ret` that follows it, and the routine
; ends at 0xFC0440, where the next top-level label begins.
; Evidence: the `calr` at 0xFC043C targets 0xFC0990, which is
;          Msg0716_DispatchIndex -- confirmed by disassembling the site
;          (`calr 0xfc0990`) and by this file's own header 500 lines below,
;          which states that a 33rd object record "would start at 0xFC0990,
;          which is Msg0716_DispatchIndex, reached by 64 calrs".
; ⚠ CORRECTED IN ROUND 11: this wrapper was called Msg0716_DispatchIndex_Entry
;          and its Evidence line asserted that 0xFC0990 "carries the label
;          Msg0716_ObjectRecords". It does not -- Msg0716_ObjectRecords is the
;          DATA TABLE that ENDS at 0xFC0990, and the wrapper never calls it. The
;          tree's own header contradicted the name, and a parser bug that reads
;          the label BEFORE a target rather than AT it is what produced it.
;          The extent is measured to the next top-level label, never to a source
;          line -- notes/wave7-verify-probes/wave7_r5_prom_a_painter_scope.py
;          records what scoping to a source line cost the round-5 pass.
; ---------------------------------------------------------------------

Msg0716_DispatchIndex_Entry:
	calr Msg0716_DispatchIndex                                          ; FC043C  1e 51 05
	ret                                                  ; FC043F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_248_Msg0716_HandlerTables_13:
	ld XIZ,Msg0716_ObjectRecords+0xF8                    ; FC0440  46 88 09 fc 00
	ld XIY,Msg0716_HandlerTables                         ; FC0445  45 ce 09 fc 00
	ld a, 0x0d:opc                                          ; FC044A  21 0d
	calr Msg0716_DispatchIndex                                          ; FC044C  1e 41 05
	ret                                                  ; FC044F  0e
; Msg0716_DispatchIndex_Msg0716_ObjectRecords_Msg0716_HandlerTables_56_26: Event class 0x20's Msg0716 handler: XIZ =
;   Msg0716_ObjectRecords (record 0), then falls into Msg0716_DispatchIndex_Msg0716_HandlerTables_56_26 (XIY =
;   Msg0716_HandlerTables+0x38, A = 26). The family name of its siblings (classes 0x22.. = records 2.. on the same
;   table, e.g. _16_..._56_26). Basis: table index + body + family. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_DispatchIndex_Msg0716_ObjectRecords_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords                         ; FC0450  46 90 08 fc 00
Msg0716_DispatchIndex_Msg0716_HandlerTables_56_26:
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0455  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC045A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC045C  1e 31 05
	ret                                                  ; FC045F  0e
; Msg0716_DispatchIndex_Msg0716_ObjectRecords_8_Msg0716_HandlerTables_56_26: Event class 0x21's Msg0716 handler: XIZ =
;   Msg0716_ObjectRecords+0x8 (record 1), XIY = Msg0716_HandlerTables+0x38, then falls into Msg0716_DispatchIndex_26
;   (A = 26). The family name of its siblings (record 0 = class 0x20, record 2 = class 0x22 ...). Basis: table index +
;   body + family. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_DispatchIndex_Msg0716_ObjectRecords_8_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x8                     ; FC0460  46 98 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0465  45 06 0a fc 00
Msg0716_DispatchIndex_26:
	ld a, 0x1a:opc                                          ; FC046A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC046C  1e 21 05
	ret                                                  ; FC046F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_16_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x10                    ; FC0470  46 a0 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0475  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC047A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC047C  1e 11 05
	ret                                                  ; FC047F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_24_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x18                    ; FC0480  46 a8 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0485  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC048A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC048C  1e 01 05
	ret                                                  ; FC048F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_32_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x20                    ; FC0490  46 b0 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0495  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC049A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC049C  1e f1 04
	ret                                                  ; FC049F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_40_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x28                    ; FC04A0  46 b8 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC04A5  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC04AA  21 1a
	calr Msg0716_DispatchIndex                                          ; FC04AC  1e e1 04
	ret                                                  ; FC04AF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_48_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x30                    ; FC04B0  46 c0 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC04B5  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC04BA  21 1a
	calr Msg0716_DispatchIndex                                          ; FC04BC  1e d1 04
	ret                                                  ; FC04BF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_56_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x38                    ; FC04C0  46 c8 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC04C5  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC04CA  21 1a
	calr Msg0716_DispatchIndex                                          ; FC04CC  1e c1 04
	ret                                                  ; FC04CF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_64_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x40                    ; FC04D0  46 d0 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC04D5  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC04DA  21 1a
	calr Msg0716_DispatchIndex                                          ; FC04DC  1e b1 04
	ret                                                  ; FC04DF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_72_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x48                    ; FC04E0  46 d8 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC04E5  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC04EA  21 1a
	calr Msg0716_DispatchIndex                                          ; FC04EC  1e a1 04
	ret                                                  ; FC04EF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_80_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x50                    ; FC04F0  46 e0 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC04F5  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC04FA  21 1a
	calr Msg0716_DispatchIndex                                          ; FC04FC  1e 91 04
	ret                                                  ; FC04FF  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_88_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x58                    ; FC0500  46 e8 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0505  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC050A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC050C  1e 81 04
	ret                                                  ; FC050F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_96_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x60                    ; FC0510  46 f0 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0515  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC051A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC051C  1e 71 04
	ret                                                  ; FC051F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_104_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x68                    ; FC0520  46 f8 08 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0525  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC052A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC052C  1e 61 04
	ret                                                  ; FC052F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_112_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x70                    ; FC0530  46 00 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0535  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC053A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC053C  1e 51 04
	ret                                                  ; FC053F  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_120_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x78                    ; FC0540  46 08 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0545  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC054A  21 1a
	calr Msg0716_DispatchIndex                                          ; FC054C  1e 41 04
	ret                                                  ; FC054F  0e
	ret                                                  ; FC0550  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_128_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x80                    ; FC0551  46 10 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0556  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC055B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC055D  1e 30 04
	ret                                                  ; FC0560  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_136_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x88                    ; FC0561  46 18 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0566  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC056B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC056D  1e 20 04
	ret                                                  ; FC0570  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_144_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x90                    ; FC0571  46 20 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0576  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC057B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC057D  1e 10 04
	ret                                                  ; FC0580  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_152_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0x98                    ; FC0581  46 28 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0586  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC058B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC058D  1e 00 04
	ret                                                  ; FC0590  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_160_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xA0                    ; FC0591  46 30 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0596  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC059B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC059D  1e f0 03
	ret                                                  ; FC05A0  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_168_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xA8                    ; FC05A1  46 38 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC05A6  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC05AB  21 1a
	calr Msg0716_DispatchIndex                                          ; FC05AD  1e e0 03
	ret                                                  ; FC05B0  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_176_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xB0                    ; FC05B1  46 40 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC05B6  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC05BB  21 1a
	calr Msg0716_DispatchIndex                                          ; FC05BD  1e d0 03
	ret                                                  ; FC05C0  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_184_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xB8                    ; FC05C1  46 48 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC05C6  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC05CB  21 1a
	calr Msg0716_DispatchIndex                                          ; FC05CD  1e c0 03
	ret                                                  ; FC05D0  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_192_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xC0                    ; FC05D1  46 50 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC05D6  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC05DB  21 1a
	calr Msg0716_DispatchIndex                                          ; FC05DD  1e b0 03
	ret                                                  ; FC05E0  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_200_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xC8                    ; FC05E1  46 58 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC05E6  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC05EB  21 1a
	calr Msg0716_DispatchIndex                                          ; FC05ED  1e a0 03
	ret                                                  ; FC05F0  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_208_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xD0                    ; FC05F1  46 60 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC05F6  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC05FB  21 1a
	calr Msg0716_DispatchIndex                                          ; FC05FD  1e 90 03
	ret                                                  ; FC0600  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_216_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xD8                    ; FC0601  46 68 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0606  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC060B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC060D  1e 80 03
	ret                                                  ; FC0610  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_224_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xE0                    ; FC0611  46 70 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0616  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC061B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC061D  1e 70 03
	ret                                                  ; FC0620  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_232_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xE8                    ; FC0621  46 78 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0626  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC062B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC062D  1e 60 03
	ret                                                  ; FC0630  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_240_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xF0                    ; FC0631  46 80 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0636  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC063B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC063D  1e 50 03
	ret                                                  ; FC0640  0e
Msg0716_DispatchIndex_Msg0716_ObjectRecords_248_Msg0716_HandlerTables_56_26:
	ld XIZ,Msg0716_ObjectRecords+0xF8                    ; FC0641  46 88 09 fc 00
	ld XIY,Msg0716_HandlerTables+0x38                    ; FC0646  45 06 0a fc 00
	ld a, 0x1a:opc                                          ; FC064B  21 1a
	calr Msg0716_DispatchIndex                                          ; FC064D  1e 40 03
	ret                                                  ; FC0650  0e
T_F410F0_Nop:
	ret                                                  ; FC0651  0e
	ret                                                  ; FC0652  0e
T_F410F4_Nop:
	ret                                                  ; FC0653  0e
T_F410F8_Nop:
	ret                                                  ; FC0654  0e
T_F410FC_Nop:
	ret                                                  ; FC0655  0e
T_F41100_Nop:
	ret                                                  ; FC0656  0e
T_F41104_Nop:
	ret                                                  ; FC0657  0e
T_F41108_Nop:
	ret                                                  ; FC0658  0e
T_F4110C_Nop:
	ret                                                  ; FC0659  0e
; Msg0716_SetPendingBit0: set bit 0 of (0x070E) and bit 0 of (0x070F), the 0x0716 module's pending flags.
Msg0716_SetPendingBit0:
	set	0, (0x070e:16)                               ; FC065A  f1 0e 07 b8
	set	0, (0x070f:16)                               ; FC065E  f1 0f 07 b8
	ret                                                  ; FC0662  0e
Msg0716_SetPendingBit1:
	set	1, (0x070e:16)                               ; FC0663  f1 0e 07 b9
	set	0, (0x070f:16)                               ; FC0667  f1 0f 07 b8
	ret                                                  ; FC066B  0e
Msg0716_SetPendingBit2:
	set	2, (0x070e:16)                               ; FC066C  f1 0e 07 ba
	set	0, (0x070f:16)                               ; FC0670  f1 0f 07 b8
	ret                                                  ; FC0674  0e
Msg0716_SetPendingBit3:
	set	3, (0x070e:16)                               ; FC0675  f1 0e 07 bb
	set	0, (0x070f:16)                               ; FC0679  f1 0f 07 b8
	ret                                                  ; FC067D  0e
T_F41120_Nop:
	ret                                                  ; FC067E  0e
T_F41124_Nop:
	ret                                                  ; FC067F  0e
T_F41128_Nop:
	ret                                                  ; FC0680  0e
T_F4112C_Nop:
	ret                                                  ; FC0681  0e
T_F41130_Nop:
	ret                                                  ; FC0682  0e
T_F41134_Nop:
	ret                                                  ; FC0683  0e
T_F41138_Nop:
	ret                                                  ; FC0684  0e
T_F4113C_Nop:
	ret                                                  ; FC0685  0e
Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_164_6:
	ld XIY,Msg0716_HandlerTables+0xA4                    ; FC0686  45 72 0a fc 00
	ld a, 0x06:opc                                          ; FC068B  21 06
	calr Msg0716_DispatchIndex_Twin                                          ; FC068D  1e 1f 03
	ret                                                  ; FC0690  0e
T_F41144_Nop:
	ret                                                  ; FC0691  0e
Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_280_2:
	ld XIY,Msg0716_HandlerTables+0x118                   ; FC0692  45 e6 0a fc 00
	ld a, 0x02:opc                                          ; FC0697  21 02
	calr Msg0716_DispatchIndex_Twin                                          ; FC0699  1e 13 03
	ret                                                  ; FC069C  0e
T_F4114C_Nop:
	ret                                                  ; FC069D  0e
T_F41150_Nop:
	ret                                                  ; FC069E  0e
Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_292_14:
	ld XIY,Msg0716_HandlerTables+0x124                   ; FC069F  45 f2 0a fc 00
	ld a, 0x0e:opc                                          ; FC06A4  21 0e
	calr Msg0716_DispatchIndex_Twin                                          ; FC06A6  1e 06 03
	ret                                                  ; FC06A9  0e
Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_192_13:
	ld XIY,Msg0716_HandlerTables+0xC0                    ; FC06AA  45 8e 0a fc 00
	ld a, 0x0d:opc                                          ; FC06AF  21 0d
	calr Msg0716_DispatchIndex_Twin                                          ; FC06B1  1e fb 02
	ret                                                  ; FC06B4  0e
Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_248_7:
	ld XIY,Msg0716_HandlerTables+0xF8                    ; FC06B5  45 c6 0a fc 00
	ld a, 0x07:opc                                          ; FC06BA  21 07
	calr Msg0716_DispatchIndex_Twin                                          ; FC06BC  1e f0 02
	ret                                                  ; FC06BF  0e
Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_352_4:
	ld XIY,Msg0716_HandlerTables+0x160                   ; FC06C0  45 2e 0b fc 00
	ld a, 0x04:opc                                          ; FC06C5  21 04
	calr Msg0716_DispatchIndex_Twin                                          ; FC06C7  1e e5 02
	ret                                                  ; FC06CA  0e
T_F41164_Nop:
	ret                                                  ; FC06CB  0e
; UiListB_Class9A_Nop: The only handler of internal event class 0x9A in pass B (UiListB_Class9A, slot T_UiListB_Class9A_Nop):
;   `calr` to a bare `ret` and return -- it does nothing in this build. Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
UiListB_Class9A_Nop:
	calr Msg0716_PostSysEx50_81_Call_Nop                                          ; FC06CC  1e 86 07
	ret                                                  ; FC06CF  0e
Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_372_19:
	ld XIY,Msg0716_HandlerTables+0x174                   ; FC06D0  45 42 0b fc 00
	ld a, 0x13:opc                                          ; FC06D5  21 13
	calr Msg0716_DispatchIndex_Twin                                          ; FC06D7  1e d5 02
	ret                                                  ; FC06DA  0e
T_F41170_Nop:
	ret                                                  ; FC06DB  0e
T_F41174_Nop:
	ret                                                  ; FC06DC  0e
T_F41178_Nop:
	ret                                                  ; FC06DD  0e
T_F4117C_Nop:
	ret                                                  ; FC06DE  0e
; Msg0716_EventPartPostCC78_AllSoundOff: for the part UiEvent_Byte1 (< 0x20), byte 1 = it and Msg0716_PostCC78_AllSoundOff
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC78_AllSoundOff:
	ld XIX,0x00000716                                    ; FC06DF  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC06E4  c1 b8 20 27
	cp L,0x20                                            ; FC06E8  cf cf 20
	jr nc, .LFC06F3                                      ; FC06EB  6f 06
	ld (XIX+0x01),L                                      ; FC06ED  bc 01 47
	calr Msg0716_PostCC78_AllSoundOff                                          ; FC06F0  1e fb 0f
.LFC06F3:
	ret                                                  ; FC06F3  0e
Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_452_17:
	ld XIY,Msg0716_HandlerTables+0x1C4                   ; FC06F4  45 92 0b fc 00
	ld a, 0x11:opc                                          ; FC06F9  21 11
	calr Msg0716_DispatchIndex_Twin                                          ; FC06FB  1e b1 02
	ret                                                  ; FC06FE  0e
; Msg0716_OnPitchBendEvent: T_Msg0716_OnPitchBendEvent, UiListB_ClassB1 (byte 1 = the part, 0..31): when the part's Msg0716 record (+0x20) has bit 6 at +0x0B,
;   Msg0716_PostPitchBend for it.
Msg0716_OnPitchBendEvent:
	ld XIX,0x00000716                                    ; FC06FF  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC0704  c1 b8 20 27
	cp L,0x20                                            ; FC0708  cf cf 20
	jr nc, .LFC0723                                      ; FC070B  6f 16
	ld W,L                                               ; FC070D  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC070F  1e 3c 0a
	add XIY,0x00000020                                   ; FC0712  ed c8 20 00 00 00
	bit 6,(XIY+0x0b)                                     ; FC0718  bd 0b ce
	jr z, .LFC0723                                       ; FC071B  66 06
	ld (XIX+0x01),L                                      ; FC071D  bc 01 47
	calr Msg0716_PostPitchBend                                          ; FC0720  1e ea 0f
.LFC0723:
	ret                                                  ; FC0723  0e
; Msg0716_EventPartPostCC01_ModulationIfEnabled: for the part UiEvent_Byte1 (< 0x20), when bit 1 of its record's +0x2c (Msg0716_GetRecordPtrByIndex + 0x20) enables the controller, byte 1 = it and Msg0716_PostCC01_Modulation
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC01_ModulationIfEnabled:
	ld XIX,0x00000716                                    ; FC0724  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC0729  c1 b8 20 27
	cp L,0x20                                            ; FC072D  cf cf 20
	jr nc, .LFC0748                                      ; FC0730  6f 16
	ld W,L                                               ; FC0732  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC0734  1e 17 0a
	add XIY,0x00000020                                   ; FC0737  ed c8 20 00 00 00
	bit 1,(XIY+0x0c)                                     ; FC073D  bd 0c c9
	jr z, .LFC0748                                       ; FC0740  66 06
	ld (XIX+0x01),L                                      ; FC0742  bc 01 47
	calr Msg0716_PostCC01_Modulation                                          ; FC0745  1e 24 0f
.LFC0748:
	ret                                                  ; FC0748  0e
; Msg0716_EventPartPostCC0B_Expression: for the part UiEvent_Byte1 (< 0x20), byte 1 = it and Msg0716_PostCC0B_Expression
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC0B_Expression:
	ld XIX,0x00000716                                    ; FC0749  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC074E  c1 b8 20 27
	cp L,0x20                                            ; FC0752  cf cf 20
	jr nc, .LFC075D                                      ; FC0755  6f 06
	ld (XIX+0x01),L                                      ; FC0757  bc 01 47
	calr Msg0716_PostCC0B_Expression                                          ; FC075A  1e 1c 0f
.LFC075D:
	ret                                                  ; FC075D  0e
; Msg0716_OnChannelPressureEvent: T_Msg0716_OnChannelPressureEvent, UiListB_ClassB4 (byte 1 = the part): while (0x7F5F) is nonzero and the part's Msg0716 record (+0x20) has
;   bit 5 at +0x0B, Msg0716_PostChannelPressure for it.
Msg0716_OnChannelPressureEvent:
	cp	(0x7f5f:16), 0x00                            ; FC075E  c1 5f 7f 3f 00
	jr z, .LFC0789                                       ; FC0763  66 24
	ld XIX,0x00000716                                    ; FC0765  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC076A  c1 b8 20 27
	cp L,0x20                                            ; FC076E  cf cf 20
	jr nc, .LFC0789                                      ; FC0771  6f 16
	ld W,L                                               ; FC0773  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC0775  1e d6 09
	add XIY,0x00000020                                   ; FC0778  ed c8 20 00 00 00
	bit 5,(XIY+0x0b)                                     ; FC077E  bd 0b cd
	jr z, .LFC0789                                       ; FC0781  66 06
	ld (XIX+0x01),L                                      ; FC0783  bc 01 47
	calr Msg0716_PostChannelPressure                                          ; FC0786  1e 77 0f
.LFC0789:
	ret                                                  ; FC0789  0e
; Msg0716_EventPartPostCC40_SustainFromValueIfEnabled: for the part UiEvent_Byte1 (< 0x20), when bit 0 of its record's +0x2c (Msg0716_GetRecordPtrByIndex + 0x20) enables the controller, byte 1 = it and Msg0716_PostCC40_SustainFromValue
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC40_SustainFromValueIfEnabled:
	ld XIX,0x00000716                                    ; FC078A  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC078F  c1 b8 20 27
	cp L,0x20                                            ; FC0793  cf cf 20
	jr nc, .LFC07AE                                      ; FC0796  6f 16
	ld W,L                                               ; FC0798  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC079A  1e b1 09
	add XIY,0x00000020                                   ; FC079D  ed c8 20 00 00 00
	bit 0,(XIY+0x0c)                                     ; FC07A3  bd 0c c8
	jr z, .LFC07AE                                       ; FC07A6  66 06
	ld (XIX+0x01),L                                      ; FC07A8  bc 01 47
	calr Msg0716_PostCC40_SustainFromValue                                          ; FC07AB  1e 17 0e
.LFC07AE:
	ret                                                  ; FC07AE  0e
T_F42508_Nop:
	ret                                                  ; FC07AF  0e
T_F4250C_Nop:
	ret                                                  ; FC07B0  0e
; Msg0716_EventPartPostCC10_GeneralPurpose1IfEnabled: for the part UiEvent_Byte1 (< 0x20), when bit 0 of its record's +0x2e (Msg0716_GetRecordPtrByIndex + 0x20) enables the controller, byte 1 = it and Msg0716_PostCC10_GeneralPurpose1
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC10_GeneralPurpose1IfEnabled:
	ld XIX,0x00000716                                    ; FC07B1  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC07B6  c1 b8 20 27
	cp L,0x20                                            ; FC07BA  cf cf 20
	jr nc, .LFC07D5                                      ; FC07BD  6f 16
	ld W,L                                               ; FC07BF  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC07C1  1e 8a 09
	add XIY,0x00000020                                   ; FC07C4  ed c8 20 00 00 00
	bit 0,(XIY+0x0e)                                     ; FC07CA  bd 0e c8
	jr z, .LFC07D5                                       ; FC07CD  66 06
	ld (XIX+0x01),L                                      ; FC07CF  bc 01 47
	calr Msg0716_PostCC10_GeneralPurpose1                                          ; FC07D2  1e b1 0e
.LFC07D5:
	ret                                                  ; FC07D5  0e
; Msg0716_EventPartPostCC11_GeneralPurpose2IfEnabled: for the part UiEvent_Byte1 (< 0x20), when bit 1 of its record's +0x2e (Msg0716_GetRecordPtrByIndex + 0x20) enables the controller, byte 1 = it and Msg0716_PostCC11_GeneralPurpose2
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC11_GeneralPurpose2IfEnabled:
	ld XIX,0x00000716                                    ; FC07D6  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC07DB  c1 b8 20 27
	cp L,0x20                                            ; FC07DF  cf cf 20
	jr nc, .LFC07FA                                      ; FC07E2  6f 16
	ld W,L                                               ; FC07E4  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC07E6  1e 65 09
	add XIY,0x00000020                                   ; FC07E9  ed c8 20 00 00 00
	bit 1,(XIY+0x0e)                                     ; FC07EF  bd 0e c9
	jr z, .LFC07FA                                       ; FC07F2  66 06
	ld (XIX+0x01),L                                      ; FC07F4  bc 01 47
	calr Msg0716_PostCC11_GeneralPurpose2                                          ; FC07F7  1e 99 0e
.LFC07FA:
	ret                                                  ; FC07FA  0e
; Msg0716_EventPartPostCC12_GeneralPurpose3IfEnabled: for the part UiEvent_Byte1 (< 0x20), when bit 2 of its record's +0x2e (Msg0716_GetRecordPtrByIndex + 0x20) enables the controller, byte 1 = it and Msg0716_PostCC12_GeneralPurpose3
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC12_GeneralPurpose3IfEnabled:
	ld XIX,0x00000716                                    ; FC07FB  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC0800  c1 b8 20 27
	cp L,0x20                                            ; FC0804  cf cf 20
	jr nc, .LFC081F                                      ; FC0807  6f 16
	ld W,L                                               ; FC0809  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC080B  1e 40 09
	add XIY,0x00000020                                   ; FC080E  ed c8 20 00 00 00
	bit 2,(XIY+0x0e)                                     ; FC0814  bd 0e ca
	jr z, .LFC081F                                       ; FC0817  66 06
	ld (XIX+0x01),L                                      ; FC0819  bc 01 47
	calr Msg0716_PostCC12_GeneralPurpose3                                          ; FC081C  1e 81 0e
.LFC081F:
	ret                                                  ; FC081F  0e
; Msg0716_EventPartPostCC13_GeneralPurpose4IfEnabled: for the part UiEvent_Byte1 (< 0x20), when bit 3 of its record's +0x2e (Msg0716_GetRecordPtrByIndex + 0x20) enables the controller, byte 1 = it and Msg0716_PostCC13_GeneralPurpose4
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC13_GeneralPurpose4IfEnabled:
	ld XIX,0x00000716                                    ; FC0820  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC0825  c1 b8 20 27
	cp L,0x20                                            ; FC0829  cf cf 20
	jr nc, .LFC0844                                      ; FC082C  6f 16
	ld W,L                                               ; FC082E  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC0830  1e 1b 09
	add XIY,0x00000020                                   ; FC0833  ed c8 20 00 00 00
	bit 3,(XIY+0x0e)                                     ; FC0839  bd 0e cb
	jr z, .LFC0844                                       ; FC083C  66 06
	ld (XIX+0x01),L                                      ; FC083E  bc 01 47
	calr Msg0716_PostCC13_GeneralPurpose4                                          ; FC0841  1e 69 0e
.LFC0844:
	ret                                                  ; FC0844  0e
; Msg0716_EventPartPostCC02_BreathIfEnabled: for the part UiEvent_Byte1 (< 0x20), when bit 4 of its record's +0x2e (Msg0716_GetRecordPtrByIndex + 0x20) enables the controller, byte 1 = it and Msg0716_PostCC02_Breath
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC02_BreathIfEnabled:
	ld XIX,0x00000716                                    ; FC0845  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC084A  c1 b8 20 27
	cp L,0x20                                            ; FC084E  cf cf 20
	jr nc, .LFC0869                                      ; FC0851  6f 16
	ld W,L                                               ; FC0853  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC0855  1e f6 08
	add XIY,0x00000020                                   ; FC0858  ed c8 20 00 00 00
	bit 4,(XIY+0x0e)                                     ; FC085E  bd 0e cc
	jr z, .LFC0869                                       ; FC0861  66 06
	ld (XIX+0x01),L                                      ; FC0863  bc 01 47
	calr Msg0716_PostCC02_Breath                                          ; FC0866  1e 51 0e
.LFC0869:
	ret                                                  ; FC0869  0e
; Msg0716_EventPartPostCC04_FootIfEnabled: for the part UiEvent_Byte1 (< 0x20), when bit 5 of its record's +0x2e (Msg0716_GetRecordPtrByIndex + 0x20) enables the controller, byte 1 = it and Msg0716_PostCC04_Foot
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_EventPartPostCC04_FootIfEnabled:
	ld XIX,0x00000716                                    ; FC086A  44 16 07 00 00
	ld l, (UiEvent_Byte1:16)                                   ; FC086F  c1 b8 20 27
	cp L,0x20                                            ; FC0873  cf cf 20
	jr nc, .LFC088E                                      ; FC0876  6f 16
	ld W,L                                               ; FC0878  cf 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC087A  1e d1 08
	add XIY,0x00000020                                   ; FC087D  ed c8 20 00 00 00
	bit 5,(XIY+0x0e)                                     ; FC0883  bd 0e cd
	jr z, .LFC088E                                       ; FC0886  66 06
	ld (XIX+0x01),L                                      ; FC0888  bc 01 47
	calr Msg0716_PostCC04_Foot                                          ; FC088B  1e 39 0e
.LFC088E:
	ret                                                  ; FC088E  0e
	ret                                                  ; FC088F  0e
; ---------------------------------------------------------------------
; Msg0716_ObjectRecords -- 32 records of 8 bytes, one per addressed object
;
; LAYOUT, field by field, every field constant or a closed formula in the
; record index n = 0..31, and asserted on ALL 32 records:
;
;   +0  byte   8*n mod 256 -- the record's own byte offset from this label
;   +1  byte   0x06, in all 32
;   +2  word   0x0000, in all 32
;   +4  word   1 << (n mod 16), little-endian: a bit position in a 16-bit mask,
;              wrapping once at n = 16
;   +6  byte   n
;   +7  byte   0x0E, in all 32
;
; ENTRY COUNT = 32, established rather than counted:
;   * +6 is the index a reader uses.  0xFC172F does `ld E,(XIZ+0x06) /
;     sla 0x02,DE / ld XIY,0x00fc1162 / ld XIY,(XIY+DE)`, so +6 indexes
;     Msg0716_RecordPtrTable -- which has exactly 32 entries by its own
;     last-entry test.
;   * a 33rd record would start at 0xFC0990, which is Msg0716_DispatchIndex,
;     reached by 64 `calr`s.  There is no room for one.
;   * the module forms record addresses with `ld XIZ,imm32` at 32 sites; the
;     lowest is 0xFC0890 and the highest 0xFC0988 -- the first and the last of
;     the 32 -- every one is 8-byte aligned to this label, and there is no
;     `ld XIZ,imm32` in the module pointing anywhere else at all.
; Evidence: all six statements above are checks in
;          notes/prom_a_fc0000_module_check.py section 4, and the field formulae
;          are asserted on ALL 32 records, record 31 included, not sampled.
; Unknown: what the object is.  The record contains no pointer and no text.
; ---------------------------------------------------------------------
Msg0716_ObjectRecords:
	.byte 0x00, 0x06, 0x00, 0x00, 0x01, 0x00, 0x00, 0x0e, 0x08, 0x06, 0x00, 0x00, 0x02, 0x00, 0x01, 0x0e  ; FC0890
	.byte 0x10, 0x06, 0x00, 0x00, 0x04, 0x00, 0x02, 0x0e, 0x18, 0x06, 0x00, 0x00, 0x08, 0x00, 0x03, 0x0e  ; FC08A0
	.byte 0x20, 0x06, 0x00, 0x00, 0x10, 0x00, 0x04, 0x0e, 0x28, 0x06, 0x00, 0x00, 0x20, 0x00, 0x05, 0x0e  ; FC08B0
	.byte 0x30, 0x06, 0x00, 0x00, 0x40, 0x00, 0x06, 0x0e, 0x38, 0x06, 0x00, 0x00, 0x80, 0x00, 0x07, 0x0e  ; FC08C0
	.byte 0x40, 0x06, 0x00, 0x00, 0x00, 0x01, 0x08, 0x0e, 0x48, 0x06, 0x00, 0x00, 0x00, 0x02, 0x09, 0x0e  ; FC08D0
	.byte 0x50, 0x06, 0x00, 0x00, 0x00, 0x04, 0x0a, 0x0e, 0x58, 0x06, 0x00, 0x00, 0x00, 0x08, 0x0b, 0x0e  ; FC08E0
	.byte 0x60, 0x06, 0x00, 0x00, 0x00, 0x10, 0x0c, 0x0e, 0x68, 0x06, 0x00, 0x00, 0x00, 0x20, 0x0d, 0x0e  ; FC08F0
	.byte 0x70, 0x06, 0x00, 0x00, 0x00, 0x40, 0x0e, 0x0e, 0x78, 0x06, 0x00, 0x00, 0x00, 0x80, 0x0f, 0x0e  ; FC0900
	.byte 0x80, 0x06, 0x00, 0x00, 0x01, 0x00, 0x10, 0x0e, 0x88, 0x06, 0x00, 0x00, 0x02, 0x00, 0x11, 0x0e  ; FC0910
	.byte 0x90, 0x06, 0x00, 0x00, 0x04, 0x00, 0x12, 0x0e, 0x98, 0x06, 0x00, 0x00, 0x08, 0x00, 0x13, 0x0e  ; FC0920
	.byte 0xa0, 0x06, 0x00, 0x00, 0x10, 0x00, 0x14, 0x0e, 0xa8, 0x06, 0x00, 0x00, 0x20, 0x00, 0x15, 0x0e  ; FC0930
	.byte 0xb0, 0x06, 0x00, 0x00, 0x40, 0x00, 0x16, 0x0e, 0xb8, 0x06, 0x00, 0x00, 0x80, 0x00, 0x17, 0x0e  ; FC0940
	.byte 0xc0, 0x06, 0x00, 0x00, 0x00, 0x01, 0x18, 0x0e, 0xc8, 0x06, 0x00, 0x00, 0x00, 0x02, 0x19, 0x0e  ; FC0950
	.byte 0xd0, 0x06, 0x00, 0x00, 0x00, 0x04, 0x1a, 0x0e, 0xd8, 0x06, 0x00, 0x00, 0x00, 0x08, 0x1b, 0x0e  ; FC0960
	.byte 0xe0, 0x06, 0x00, 0x00, 0x00, 0x10, 0x1c, 0x0e, 0xe8, 0x06, 0x00, 0x00, 0x00, 0x20, 0x1d, 0x0e  ; FC0970
	.byte 0xf0, 0x06, 0x00, 0x00, 0x00, 0x40, 0x1e, 0x0e, 0xf8, 0x06, 0x00, 0x00, 0x00, 0x80, 0x1f, 0x0e  ; FC0980
; ---------------------------------------------------------------------
; Msg0716_DispatchIndex -- call handler[(0x20B8)] of the caller's page table
;
; Called from: 64 `calr` sites in this module, counted on DECODED instructions
;          rather than by an opcode scan.
; Inputs:  XIY = the page's 4-byte-entry handler table; A = its highest legal
;          index; RAM (0x20B8) = the index.  XIZ is loaded by some callers and
;          passed through untouched.
; Outputs: bit 1 of (0x070F) cleared; XIX = 0x00000716; the handler called with
;          those registers live.  Nothing happens at all if (0x20B8) > A.
; Evidence: the nine instructions are quoted in the module header above; the
;          bound is the routine's own `cp L,A` / `jr UGT`, and the entry width
;          is its own `sla 0x02,HL`.  Each of those five bytes is a check.
; Unknown: nothing about the mechanism.  What each handler does is not
;          established.
; ---------------------------------------------------------------------
Msg0716_DispatchIndex:
	ld l, (UiEvent_Byte1:16)                                   ; FC0990  c1 b8 20 27
	cp L,A                                               ; FC0994  c9 f7
	jr ugt, .LFC09AE                                     ; FC0996  6b 16
	and	(0x070f:16), 0xfd                            ; FC0998  c1 0f 07 3c fd
	ld XIX,0x00000716                                    ; FC099D  44 16 07 00 00
; (sub_FC09A2 removed 2026-10-04: no code names it and the line above falls through into it -- part of Msg0716_DispatchIndex;
;  notes/prom_a_stray_label_removal.py)
	xor H,H                                              ; FC09A2  ce d6
	sla hl, 0x02                                         ; FC09A4  db ec 02
	ld	xwa, (xiy+hl)                                ; FC09A7  e3 07 f4 ec 20
	call (xwa)                                           ; FC09AC  b0 e8
.LFC09AE:
	ret                                                  ; FC09AE  0e
; ---------------------------------------------------------------------
; Msg0716_DispatchIndex_Twin -- the same 31 bytes again, immediately after
;
; Called from: 8 `calr` sites in this module.
; Inputs/Outputs: identical to Msg0716_DispatchIndex.
; Evidence: the two are byte-identical over all 31 bytes and byte 32 differs, so
;          the run is exactly 31.  Both are live: of the ten handler tables, two
;          are dispatched through the first and eight through this one.
; Unknown: WHY there are two.  Unlike prom_a's other duplicated regions -- the
;          two in the 0xFAA000 message module, whose copies differ in ten bytes
;          and whose four `call` operands differ by exactly 0x896
;          (notes/FINDINGS-prom_a-message-module.md) -- these two do not differ
;          at all, because everything they reach is PC-relative or in RAM.
; ---------------------------------------------------------------------
Msg0716_DispatchIndex_Twin:
	ld l, (UiEvent_Byte1:16)                                   ; FC09AF  c1 b8 20 27
	cp L,A                                               ; FC09B3  c9 f7
	jr ugt, .LFC09CD                                     ; FC09B5  6b 16
	and	(0x070f:16), 0xfd                            ; FC09B7  c1 0f 07 3c fd
	ld XIX,0x00000716                                    ; FC09BC  44 16 07 00 00
	xor H,H                                              ; FC09C1  ce d6
	sla hl, 0x02                                         ; FC09C3  db ec 02
	ld	xwa, (xiy+hl)                                ; FC09C6  e3 07 f4 ec 20
	call (xwa)                                           ; FC09CB  b0 e8
.LFC09CD:
	ret                                                  ; FC09CD  0e
; ---------------------------------------------------------------------
; Msg0716_HandlerTables -- ten index-handler tables, end to end
;
; 131 entries of 4 bytes = 524 bytes, every one an address inside this module
; and every one an instruction boundary of it.  They are not one table: each
; `ld XIY,base / ld A,n / calr dispatcher` caller declares its own base and its
; own highest index, and the ten declared extents TILE this span exactly:
;
;   base       highest index   entries   ends at    dispatcher
;   0xFC09CE   0x0D            14        0xFC0A06   0xFC0990
;   0xFC0A06   0x1A            27        0xFC0A72   0xFC0990
;   0xFC0A72   0x06             7        0xFC0A8E   0xFC09AF
;   0xFC0A8E   0x0D            14        0xFC0AC6   0xFC09AF
;   0xFC0AC6   0x07             8        0xFC0AE6   0xFC09AF
;   0xFC0AE6   0x02             3        0xFC0AF2   0xFC09AF
;   0xFC0AF2   0x0E            15        0xFC0B2E   0xFC09AF
;   0xFC0B2E   0x04             5        0xFC0B42   0xFC09AF
;   0xFC0B42   0x13            20        0xFC0B92   0xFC09AF
;   0xFC0B92   0x11            18        0xFC0BDA   0xFC09AF
;
; THE LAST-ENTRY TEST.  14+27+7+14+8+3+15+5+20+18 = 131, and 0xFC09CE + 131*4
; = 0xFC0BDA -- which is the VALUE of entry 0, the first handler.  A 132nd entry
; would read that handler's first four bytes.  The count therefore comes from
; ten independent `cp L,A` bounds, and the table's end is the ROM's, not a
; reading.  notes/prom_a_fc0000_module_check.py re-derives all of it and asserts
; that these ten are the ONLY (base, limit, dispatcher) declarations in the
; module and that the ten extents leave no gap and no overlap.
;
; ⚠ Only 50 of the 131 entries are distinct: several consecutive indices share
; one handler (0xFC0CE2 twenty times in a row, 0xFC0E20 eighteen, 0xFC0E52
; fourteen).  That is a page with many inert positions, not a decoding error.
; Evidence: the ten declarations are PARSED OUT OF THE DECODE by
;          notes/prom_a_fc0000_module_check.py section 3 -- not typed in -- so a
;          changed literal or an eleventh caller fails the check instead of
;          passing for ever; the tiling, the 131, the entry-0 last-entry test,
;          the "every entry is an instruction boundary" test and the run
;          lengths are all checks there.
; ---------------------------------------------------------------------
Msg0716_HandlerTables:
	.long Msg0716_PartSetProgramLow                                 ; FC09CE  [  0]
	.long Msg0716_PartSetProgramHigh                                 ; FC09D2  [  1]
	.long Msg0716_HandlerTables_Nop2                                 ; FC09D6  [  2]
	.long Msg0716_PartSetVolume                                 ; FC09DA  [  3]
	.long Msg0716_PartPostCC40_Sustain                                 ; FC09DE  [  4]
	.long Msg0716_PartPostCC5D_Effect3Depth                                 ; FC09E2  [  5]
	.long Msg0716_PartPostCtrlInt9B                                 ; FC09E6  [  6]
	.long Msg0716_PartPostCC5B_Effect1Depth                                 ; FC09EA  [  7]
	.long Msg0716_PartPostCC0A_Pan                                 ; FC09EE  [  8]
	.long Msg0716_PartPostCtrlInt82                                 ; FC09F2  [  9]
	.long Msg0716_PartPostCtrlInt81                                 ; FC09F6  [ 10]
	.long Msg0716_PartPostCtrlInt80                                 ; FC09FA  [ 11]
	.long Msg0716_PartPostCtrlInt9C                                 ; FC09FE  [ 12]
	.long Msg0716_HandlerTables_Nop13                                 ; FC0A02  [ 13]
	.long Msg0716_HandlerTables_Nop14                                 ; FC0A06  [ 14]
	.long Msg0716_HandlerTables_Nop14                                 ; FC0A0A  [ 15]
	.long Msg0716_HandlerTables_Nop14                                 ; FC0A0E  [ 16]
	.long Msg0716_PartPostCtrlInt9B_Copy                                 ; FC0A12  [ 17]
	.long Msg0716_PartPostCtrlInt9B_Copy                                 ; FC0A16  [ 18]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A1A  [ 19]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A1E  [ 20]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A22  [ 21]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A26  [ 22]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A2A  [ 23]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A2E  [ 24]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A32  [ 25]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A36  [ 26]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A3A  [ 27]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A3E  [ 28]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A42  [ 29]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A46  [ 30]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A4A  [ 31]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A4E  [ 32]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A52  [ 33]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A56  [ 34]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A5A  [ 35]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A5E  [ 36]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A62  [ 37]
	.long Msg0716_HandlerTables_Nop19                                 ; FC0A66  [ 38]
	.long Msg0716_PartPostCtrlInt9A                                 ; FC0A6A  [ 39]
	.long Msg0716_PartPostCtrlInt99                                 ; FC0A6E  [ 40]
	.long Msg0716_HandlerTables_Nop41                                 ; FC0A72  [ 41]
	.long Msg0716_SetPendingBit4                                 ; FC0A76  [ 42]
	.long Msg0716_SetPendingBit4                                 ; FC0A7A  [ 43]
	.long Msg0716_SetPendingBit4                                 ; FC0A7E  [ 44]
	.long Msg0716_SetPendingBit4                                 ; FC0A82  [ 45]
	.long Msg0716_PostSysEx50_B2_Call                                 ; FC0A86  [ 46]
	.long Msg0716_HandlerTables_Nop47                                 ; FC0A8A  [ 47]
	.long Msg0716_ScaleTuningPostTypeAndSemitones                                 ; FC0A8E  [ 48]
	.long Msg0716_ScaleTuningPostChangedFields                                 ; FC0A92  [ 49]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0A96  [ 50]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0A9A  [ 51]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0A9E  [ 52]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0AA2  [ 53]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0AA6  [ 54]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0AAA  [ 55]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0AAE  [ 56]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0AB2  [ 57]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0AB6  [ 58]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0ABA  [ 59]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0ABE  [ 60]
	.long Msg0716_ScaleTuningPostSemitone                                 ; FC0AC2  [ 61]
	.long Msg0716_PostStream3Op80IfChanged                                 ; FC0AC6  [ 62]
	.long Msg0716_HandlerTables_Nop63                                 ; FC0ACA  [ 63]
	.long Msg0716_PostStream3Op90IfChanged                                 ; FC0ACE  [ 64]
	.long Msg0716_HandlerTables_Nop65                                 ; FC0AD2  [ 65]
	.long Msg0716_HandlerTables_Nop65                                 ; FC0AD6  [ 66]
	.long Msg0716_HandlerTables_Nop65                                 ; FC0ADA  [ 67]
	.long Msg0716_HandlerTables_Nop65                                 ; FC0ADE  [ 68]
	.long Msg0716_HandlerTables_Nop65                                 ; FC0AE2  [ 69]
	.long Msg0716_HandlerTables_Nop70                                 ; FC0AE6  [ 70]
	.long Msg0716_HandlerTables_Nop70                                 ; FC0AEA  [ 71]
	.long Msg0716_HandlerTables_Nop72                                 ; FC0AEE  [ 72]
	.long Msg0716_PostSysEx50_82_Call                                 ; FC0AF2  [ 73]
	.long Msg0716_HandlerTables_Nop74                                 ; FC0AF6  [ 74]
	.long Msg0716_HandlerTables_Nop75                                 ; FC0AFA  [ 75]
	.long Msg0716_HandlerTables_Nop76                                 ; FC0AFE  [ 76]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B02  [ 77]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B06  [ 78]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B0A  [ 79]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B0E  [ 80]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B12  [ 81]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B16  [ 82]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B1A  [ 83]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B1E  [ 84]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B22  [ 85]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B26  [ 86]
	.long Msg0716_HandlerTables_Nop77                                 ; FC0B2A  [ 87]
	.long Msg0716_SetPendingBit6IfHighNibble                                 ; FC0B2E  [ 88]
	.long Msg0716_SetPendingBit5                                 ; FC0B32  [ 89]
	.long Msg0716_SetPendingBit5_B                                 ; FC0B36  [ 90]
	.long Msg0716_PostCC07_VolumePart20                                 ; FC0B3A  [ 91]
	.long Msg0716_HandlerTables_Nop92                                 ; FC0B3E  [ 92]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B42  [ 93]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B46  [ 94]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B4A  [ 95]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B4E  [ 96]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B52  [ 97]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B56  [ 98]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B5A  [ 99]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B5E  [100]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B62  [101]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B66  [102]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B6A  [103]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B6E  [104]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B72  [105]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B76  [106]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B7A  [107]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B7E  [108]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B82  [109]
	.long Msg0716_HandlerTables_Nop93                                 ; FC0B86  [110]
	.long Msg0716_RepostPart0Volume                                 ; FC0B8A  [111]
	.long Msg0716_RepostPart0Pan                                 ; FC0B8E  [112]
	.long Msg0716_PostSysEx50_80_Call                                 ; FC0B92  [113]
	.long Msg0716_PostSysEx50_81_Call                                 ; FC0B96  [114]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0B9A  [115]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0B9E  [116]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BA2  [117]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BA6  [118]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BAA  [119]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BAE  [120]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BB2  [121]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BB6  [122]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BBA  [123]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BBE  [124]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BC2  [125]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BC6  [126]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BCA  [127]
	.long Msg0716_HandlerTables_Nop115                                 ; FC0BCE  [128]
	.long Msg0716_HandlerTables_Nop129                                 ; FC0BD2  [129]
	.long Msg0716_HandlerTables_Nop130                                 ; FC0BD6  [130]
; Msg0716_PartSetProgramLow: table 0 entry 0: the part's RAM slot +0 = UiEvent_Byte2; its bit ORed into (0x0700) (parts 0..15) or (0x0702)
;   (16..31), and (0x070F) bit 0 set -- nothing is posted here.  The pending pass (Msg0716_FlushPending) later sends
;   Msg0716_PartPostProgramChange, whose message carries the slot's +0..+1 word as the program number.
Msg0716_PartSetProgramLow:   ; entry: named by 1 `.long` operand, first at 0xFC09CE
	ld	xiy, (xiz+0:8)                               ; FC0BDA  ae 00 25
	ld BC,(XIZ+0x04)                                     ; FC0BDD  9e 04 21
	ld h, (UiEvent_Byte2:16)                                   ; FC0BE0  c1 b9 20 26
	ld	(xiy+0:8), h                                 ; FC0BE4  bd 00 46
	cp (XIZ+0x06),0x0f                                   ; FC0BE7  8e 06 3f 0f
	jr ugt, .LFC0BF3                                     ; FC0BEB  6b 06
	or	(0x0700:16), bc                      ; FC0BED  d1 00 07 e9
	jr .LFC0BF7                                          ; FC0BF1  68 04
.LFC0BF3:
	or	(0x0702:16), bc                      ; FC0BF3  d1 02 07 e9
.LFC0BF7:
	or	(0x070f:16), 0x01                            ; FC0BF7  c1 0f 07 3e 01
	ret                                                  ; FC0BFC  0e
; Msg0716_PartSetProgramHigh: table 0 entry 1: the same as Msg0716_PartSetProgramLow for slot +1, the program number's high byte.
Msg0716_PartSetProgramHigh:   ; entry: named by 1 `.long` operand, first at 0xFC09D2
	ld	xiy, (xiz+0:8)                               ; FC0BFD  ae 00 25
	ld BC,(XIZ+0x04)                                     ; FC0C00  9e 04 21
	ld h, (UiEvent_Byte2:16)                                   ; FC0C03  c1 b9 20 26
	ld (XIY+0x01),H                                      ; FC0C07  bd 01 46
	cp (XIZ+0x06),0x0f                                   ; FC0C0A  8e 06 3f 0f
	jr ugt, .LFC0C16                                     ; FC0C0E  6b 06
	or	(0x0700:16), bc                      ; FC0C10  d1 00 07 e9
	jr .LFC0C1A                                          ; FC0C14  68 04
.LFC0C16:
	or	(0x0702:16), bc                      ; FC0C16  d1 02 07 e9
.LFC0C1A:
	set	0, (0x070f:16)                               ; FC0C1A  f1 0f 07 b8
	ret                                                  ; FC0C1E  0e
Msg0716_HandlerTables_Nop2:   ; entry: named by 1 `.long` operand, first at 0xFC09D6
	ret                                                  ; FC0C1F  0e
; Msg0716_PartSetVolume: table 0 entry 3: the bits UiEvent_Byte3 selects of the slot's +6 are replaced by UiEvent_Byte2's, then +6 is
;   posted as CC 7 (Msg0716_PostCC07_VolumeWithOffset for part 0, Msg0716_PostCC07_VolumeFromA otherwise).
Msg0716_PartSetVolume:   ; entry: named by 1 `.long` operand, first at 0xFC09DA
	ld	xiy, (xiz+0:8)                               ; FC0C20  ae 00 25
	ld a, (UiEvent_Byte3:16)                                   ; FC0C23  c1 ba 20 21
	xor A,0xff                                           ; FC0C27  c9 cd ff
	and (XIY+0x06),A                                     ; FC0C2A  8d 06 c9
	ld a, (UiEvent_Byte2:16)                                   ; FC0C2D  c1 b9 20 21
	and a, (UiEvent_Byte3:16)                                   ; FC0C31  c1 ba 20 c1
	or (XIY+0x06),A                                      ; FC0C35  8d 06 e9
	ld A,(XIZ+0x06)                                      ; FC0C38  8e 06 21
	ld (XIX+0x01),A                                      ; FC0C3B  bc 01 41
	ld A,(XIY+0x06)                                      ; FC0C3E  8d 06 21
	cp (XIZ+0x06),0x00                                   ; FC0C41  8e 06 3f 00
	jr nz, .LFC0C4C                                      ; FC0C45  6e 05
	calr Msg0716_PostCC07_VolumeWithOffset                                          ; FC0C47  1e fb 08
	jr .LFC0C4F                                          ; FC0C4A  68 03
.LFC0C4C:
	calr Msg0716_PostCC07_VolumeFromA                                          ; FC0C4C  1e d9 08
.LFC0C4F:
	ret                                                  ; FC0C4F  0e
; Msg0716_PartPostCC40_Sustain: table 0 entry 4: when UiEvent_Byte3 bit 3 is set and bit 0 of byte +0x2C of the part's 64-byte record
;   (Msg0716_GetRecordPtrByIndex) is set, Msg0716_PostCC40_Sustain for the part.
Msg0716_PartPostCC40_Sustain:   ; entry: named by 1 `.long` operand, first at 0xFC09DE
	bit	3, (UiEvent_Byte3:16)                               ; FC0C50  f1 ba 20 cb
	jr z, .LFC0C6F                                       ; FC0C54  66 19
	ld W,(XIZ+0x06)                                      ; FC0C56  8e 06 20
	calr Msg0716_GetRecordPtrByIndex                                      ; FC0C59  1e f2 04
	push XIY                                             ; FC0C5C  3d
	add XIY,0x00000020                                   ; FC0C5D  ed c8 20 00 00 00
	bit 0,(XIY+0x0c)                                     ; FC0C63  bd 0c c8
	pop XIY                                              ; FC0C66  5d
	jr z, .LFC0C6F                                       ; FC0C67  66 06
	ld (XIX+0x01),W                                      ; FC0C69  bc 01 40
	calr Msg0716_PostCC40_Sustain                                          ; FC0C6C  1e 49 09
.LFC0C6F:
	ret                                                  ; FC0C6F  0e
; Msg0716_PartPostCC5D_Effect3Depth: a Msg0716 handler-table entry -- byte 1 = the object record's +6 (its number), then
;   Msg0716_PostCC5D_Effect3Depth (notes/prom_a_msg0716_message_names.py).
Msg0716_PartPostCC5D_Effect3Depth:   ; entry: named by 1 `.long` operand, first at 0xFC09E2
	ld A,(XIZ+0x06)                                      ; FC0C70  8e 06 21
	ld (XIX+0x01),A                                      ; FC0C73  bc 01 41
	calr Msg0716_PostCC5D_Effect3Depth                                          ; FC0C76  1e 08 09
	ret                                                  ; FC0C79  0e
; Msg0716_PartPostCtrlInt9B: a Msg0716 handler-table entry -- byte 1 = the object record's +6, then Msg0716_PostCtrlInt9B.
Msg0716_PartPostCtrlInt9B:   ; entry: named by 1 `.long` operand, first at 0xFC09E6
	ld A,(XIZ+0x06)                                      ; FC0C7A  8e 06 21
	ld (XIX+0x01),A                                      ; FC0C7D  bc 01 41
	calr Msg0716_PostCtrlInt9B                                          ; FC0C80  1e a3 0a
	ret                                                  ; FC0C83  0e
; Msg0716_PartPostCC5B_Effect1Depth: a Msg0716 handler-table entry -- byte 1 = the object record's +6 (its number), then
;   Msg0716_PostCC5B_Effect1Depth (notes/prom_a_msg0716_message_names.py).
Msg0716_PartPostCC5B_Effect1Depth:   ; entry: named by 1 `.long` operand, first at 0xFC09EA
	ld A,(XIZ+0x06)                                      ; FC0C84  8e 06 21
	ld (XIX+0x01),A                                      ; FC0C87  bc 01 41
	calr Msg0716_PostCC5B_Effect1Depth                                          ; FC0C8A  1e 01 09
	ret                                                  ; FC0C8D  0e
; Msg0716_PartPostCC0A_Pan: table 0 entry 8: CC 10 for the part -- Msg0716_PostCC0A_PanWithOffset(UiEvent_Byte2 & 0x7F) for part 0, else Msg0716_PostCC0A_Pan.
Msg0716_PartPostCC0A_Pan:   ; entry: named by 1 `.long` operand, first at 0xFC09EE
	ld A,(XIZ+0x06)                                      ; FC0C8E  8e 06 21
	ld (XIX+0x01),A                                      ; FC0C91  bc 01 41
	cp a, 0x00:i3                                          ; FC0C94  c9 d8
	jr nz, .LFC0CA4                                      ; FC0C96  6e 0c
	ld a, (UiEvent_Byte2:16)                                   ; FC0C98  c1 b9 20 21
	and A,0x7f                                           ; FC0C9C  c9 cc 7f
	calr Msg0716_PostCC0A_PanWithOffset                                          ; FC0C9F  1e 7b 09
	jr .LFC0CA7                                          ; FC0CA2  68 03
.LFC0CA4:
	calr Msg0716_PostCC0A_Pan                                          ; FC0CA4  1e 61 09
.LFC0CA7:
	ret                                                  ; FC0CA7  0e
; Msg0716_PartPostCtrlInt82: a Msg0716 handler-table entry -- byte 1 = the object record's +6 (its number), then
;   Msg0716_PostCtrlInt82 (notes/prom_a_msg0716_message_names.py).
Msg0716_PartPostCtrlInt82:   ; entry: named by 1 `.long` operand, first at 0xFC09F2
	ld A,(XIZ+0x06)                                      ; FC0CA8  8e 06 21
	ld (XIX+0x01),A                                      ; FC0CAB  bc 01 41
	calr Msg0716_PostCtrlInt82                                          ; FC0CAE  1e ae 09
	ret                                                  ; FC0CB1  0e
; Msg0716_PartPostCtrlInt81: a Msg0716 handler-table entry -- byte 1 = the object record's +6 (its number), then
;   Msg0716_PostCtrlInt81 (notes/prom_a_msg0716_message_names.py).
Msg0716_PartPostCtrlInt81:   ; entry: named by 1 `.long` operand, first at 0xFC09F6
	ld A,(XIZ+0x06)                                      ; FC0CB2  8e 06 21
	ld (XIX+0x01),A                                      ; FC0CB5  bc 01 41
	calr Msg0716_PostCtrlInt81                                          ; FC0CB8  1e 97 09
	ret                                                  ; FC0CBB  0e
; Msg0716_PartPostCtrlInt80: a Msg0716 handler-table entry -- byte 1 = the object record's +6 (its number), then
;   Msg0716_PostCtrlInt80 (notes/prom_a_msg0716_message_names.py).
Msg0716_PartPostCtrlInt80:   ; entry: named by 1 `.long` operand, first at 0xFC09FA
	ld A,(XIZ+0x06)                                      ; FC0CBC  8e 06 21
	ld (XIX+0x01),A                                      ; FC0CBF  bc 01 41
	calr Msg0716_PostCtrlInt80                                          ; FC0CC2  1e 80 09
	ret                                                  ; FC0CC5  0e
; Msg0716_PartPostCtrlInt9C: table 0 entry 12: when UiEvent_Byte3 bit 3 is set, Msg0716_PostCtrlInt9C for the part.
Msg0716_PartPostCtrlInt9C:   ; entry: named by 1 `.long` operand, first at 0xFC09FE
	bit	3, (UiEvent_Byte3:16)                               ; FC0CC6  f1 ba 20 cb
	jr z, .LFC0CD5                                       ; FC0CCA  66 09
	ld A,(XIZ+0x06)                                      ; FC0CCC  8e 06 21
	ld (XIX+0x01),A                                      ; FC0CCF  bc 01 41
	calr Msg0716_PostCtrlInt9C                                          ; FC0CD2  1e c7 08
.LFC0CD5:
	ret                                                  ; FC0CD5  0e
Msg0716_HandlerTables_Nop13:   ; entry: named by 1 `.long` operand, first at 0xFC0A02
	ret                                                  ; FC0CD6  0e
Msg0716_HandlerTables_Nop14:   ; entry: named by 3 `.long` operands, first at 0xFC0A06
	ret                                                  ; FC0CD7  0e
; Msg0716_PartPostCtrlInt9B_Copy: byte-for-byte Msg0716_PartPostCtrlInt9B, at another handler-table slot.
Msg0716_PartPostCtrlInt9B_Copy:   ; entry: named by 2 `.long` operands, first at 0xFC0A12
	ld A,(XIZ+0x06)                                      ; FC0CD8  8e 06 21
	ld (XIX+0x01),A                                      ; FC0CDB  bc 01 41
	calr Msg0716_PostCtrlInt9B                                          ; FC0CDE  1e 45 0a
	ret                                                  ; FC0CE1  0e
Msg0716_HandlerTables_Nop19:   ; entry: named by 20 `.long` operands, first at 0xFC0A1A
	ret                                                  ; FC0CE2  0e
; Msg0716_PartPostCtrlInt9A: table 1 entry 25: stores the part and calls Msg0716_PostCtrlInt9A, then falls into the `ret` at 0xFC0CEC.
Msg0716_PartPostCtrlInt9A:   ; entry: named by 1 `.long` operand, first at 0xFC0A6A
	ld A,(XIZ+0x06)                                      ; FC0CE3  8e 06 21
	ld (XIX+0x01),A                                      ; FC0CE6  bc 01 41
	calr Msg0716_PostCtrlInt9A                                          ; FC0CE9  1e e8 09
; (sub_FC0CEC removed 2026-10-04: no code names it and the line above falls through into it -- part of Msg0716_PartPostCtrlInt9A;
;  notes/prom_a_stray_label_removal.py)
	ret                                                  ; FC0CEC  0e
; Msg0716_PartPostCtrlInt99: a Msg0716 handler-table entry -- byte 1 = the object record's +6 (its number), then
;   Msg0716_PostCtrlInt99 (notes/prom_a_msg0716_message_names.py).
Msg0716_PartPostCtrlInt99:   ; entry: named by 1 `.long` operand, first at 0xFC0A6E
	ld A,(XIZ+0x06)                                      ; FC0CED  8e 06 21
	ld (XIX+0x01),A                                      ; FC0CF0  bc 01 41
	calr Msg0716_PostCtrlInt99                                          ; FC0CF3  1e eb 09
	ret                                                  ; FC0CF6  0e
	ret                                                  ; FC0CF7  0e
	ret                                                  ; FC0CF8  0e
	ret                                                  ; FC0CF9  0e
	ret                                                  ; FC0CFA  0e
	ret                                                  ; FC0CFB  0e
	ret                                                  ; FC0CFC  0e
	ret                                                  ; FC0CFD  0e
Msg0716_HandlerTables_Nop41:   ; entry: named by 1 `.long` operand, first at 0xFC0A72
	ret                                                  ; FC0CFE  0e
Msg0716_SetPendingBit4:   ; entry: named by 4 `.long` operands, first at 0xFC0A76
	set	4, (0x070e:16)                               ; FC0CFF  f1 0e 07 bc
	set	0, (0x070f:16)                               ; FC0D03  f1 0f 07 b8
	ret                                                  ; FC0D07  0e
Msg0716_PostSysEx50_B2_Call:   ; entry: named by 1 `.long` operand, first at 0xFC0A86
	calr Msg0716_PostSysEx50_B2                                          ; FC0D08  1e 0b 0b
	ret                                                  ; FC0D0B  0e
Msg0716_HandlerTables_Nop47:   ; entry: named by 1 `.long` operand, first at 0xFC0A8A
	ret                                                  ; FC0D0C  0e
	ret                                                  ; FC0D0D  0e
	ret                                                  ; FC0D0E  0e
	ret                                                  ; FC0D0F  0e
	ret                                                  ; FC0D10  0e
	ret                                                  ; FC0D11  0e
; Msg0716_ScaleTuningPostTypeAndSemitones: table 3 entry 0: Msg0716_PostSysEx50_86, then ScaleTuning_PostAllTwelveSemitones.  Table 3 is the scale-tuning
;   page: its entries 2..13 are the twelve semitones (Msg0716_ScaleTuningPostSemitone).
Msg0716_ScaleTuningPostTypeAndSemitones:   ; entry: named by 1 `.long` operand, first at 0xFC0A8E
	calr Msg0716_PostSysEx50_86                                          ; FC0D12  1e b8 0a
	calr ScaleTuning_PostAllTwelveSemitones                                      ; FC0D15  1e 29 00
	ret                                                  ; FC0D18  0e
; Msg0716_ScaleTuningPostChangedFields: table 3 entry 1: UiEvent_Byte3 (the changed bits) low nibble -> ScaleTuning_PostAllTwelveSemitones; bit 7 ->
;   Msg0716_PostSysEx50_B1.
Msg0716_ScaleTuningPostChangedFields:   ; entry: named by 1 `.long` operand, first at 0xFC0A92
	ld a, (UiEvent_Byte3:16)                                   ; FC0D19  c1 ba 20 21
; (sub_FC0D1D removed 2026-10-04: no code names it and the line above falls through into it -- part of Msg0716_ScaleTuningPostChangedFields;
;  notes/prom_a_stray_label_removal.py)
	and A,0x0f                                           ; FC0D1D  c9 cc 0f
	jr z, .LFC0D25                                       ; FC0D20  66 03
	calr ScaleTuning_PostAllTwelveSemitones                                      ; FC0D22  1e 1c 00
.LFC0D25:
	bit	7, (UiEvent_Byte3:16)                               ; FC0D25  f1 ba 20 cf
	jr z, .LFC0D2E                                       ; FC0D29  66 03
	calr Msg0716_PostSysEx50_B1                                          ; FC0D2B  1e d7 0a
.LFC0D2E:
	ret                                                  ; FC0D2E  0e
; Msg0716_ScaleTuningPostSemitone: table 3 entries 2..13: when the temperament (0x78A2) is 0x80, the user copy (ScaleTuning_PostAllTwelveSemitones' RAM arm),
;   ScaleTuning_PostSemitoneFromUserRam(UiEvent_Byte1 - 2) -- semitone 0..11.
Msg0716_ScaleTuningPostSemitone:   ; entry: named by 12 `.long` operands, first at 0xFC0A96
	cp	(0x78a2:16), 0x80                            ; FC0D2F  c1 a2 78 3f 80
	jr nz, .LFC0D40                                      ; FC0D34  6e 0a
	ld a, (UiEvent_Byte1:16)                                   ; FC0D36  c1 b8 20 21
	sub A,0x02                                           ; FC0D3A  c9 ca 02
	calr ScaleTuning_PostSemitoneFromUserRam                                      ; FC0D3D  1e 6f 00
.LFC0D40:
	ret                                                  ; FC0D40  0e
; ---------------------------------------------------------------------
; ScaleTuning_PostAllTwelveSemitones -- posts the twelve semitone offsets of the selected scale,
;                                       from ROM or from the user's RAM copy
;
; Evidence: prom_b's ScaleTuningOffsets header (0xF06800, 15 rows of 12
;           bytes, one row per temperament) already names
;           0xFC0D78-0xFC0D9D as its reader: 0xFC0D7E `ldb w,0x0c` and
;           0xFC0D80 `mul8rr a,w` scale the row index and 0xFC0D84 `ld
;           XHL,0x00f06800` is the base. The row index is the byte
;           (0x78A2) mapped through 0xF43420 (0xFC0D78), except that
;           0xFC0D41 sends 0x80 to the RAM-copy arm and
;           0xFC0D48/0xFC0D4F/0xFC0D56 send 0x40, 0x41 and 0x42 to row
;           0; both loops are bounded `cp A,0x0c`, so twelve semitones
;           each
; Unknown:  the UNIT of an offset -- the same gap prom_b's table header
;           states
; Was `sub_FC0D41`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
ScaleTuning_PostAllTwelveSemitones:
	cp	(0x78a2:16), 0x80                            ; FC0D41  c1 a2 78 3f 80
	jr z, .LFC0D5F                                       ; FC0D46  66 17
	cp	(0x78a2:16), 0x40                            ; FC0D48  c1 a2 78 3f 40
	jr z, .LFC0D6F                                       ; FC0D4D  66 20
	cp	(0x78a2:16), 0x41                            ; FC0D4F  c1 a2 78 3f 41
	jr z, .LFC0D6F                                       ; FC0D54  66 19
	cp	(0x78a2:16), 0x42                            ; FC0D56  c1 a2 78 3f 42
	jr z, .LFC0D6F                                       ; FC0D5B  66 12
	jr .LFC0D73                                          ; FC0D5D  68 14
.LFC0D5F:
	xor A,A                                              ; FC0D5F  c9 d1
.LFC0D61:
	cp A,0x0c                                            ; FC0D61  c9 cf 0c
	jr nc, .LFC0D9D                                      ; FC0D64  6f 37
	pushw wa                                             ; FC0D66  28
	calr ScaleTuning_PostSemitoneFromUserRam                                      ; FC0D67  1e 45 00
	popw wa                                              ; FC0D6A  48
	inc 1,A                                              ; FC0D6B  c9 61
	jr .LFC0D61                                          ; FC0D6D  68 f2
.LFC0D6F:
	ld a, 0x00:opc                                          ; FC0D6F  21 00
	jr .LFC0D77                                          ; FC0D71  68 04
.LFC0D73:
	ld a, (0x78a2:16)                                   ; FC0D73  c1 a2 78 21
.LFC0D77:
	pushw wa                                             ; FC0D77  28
	call T_TuneScale_KeyScalingCodeToIndex                                        ; FC0D78  1d 20 34 f4
	inc 2,XSP                                            ; FC0D7C  ef 62
	ld w, 0x0c:opc                                          ; FC0D7E  20 0c
	mul wa, w                                          ; FC0D80  c8 41
	extz XWA                                             ; FC0D82  e8 12
	ld XHL,ScaleTuningOffsets                            ; FC0D84  43 00 68 f0 00
	add XHL,XWA                                          ; FC0D89  e8 83
	xor A,A                                              ; FC0D8B  c9 d1
.LFC0D8D:
	cp A,0x0c                                            ; FC0D8D  c9 cf 0c
	jr nc, .LFC0D9D                                      ; FC0D90  6f 0b
	pushw wa                                             ; FC0D92  28
	push XHL                                             ; FC0D93  3b
	calr ScaleTuning_PostSemitoneFromRomRow                                      ; FC0D94  1e 07 00
	pop XHL                                              ; FC0D97  5b
	popw wa                                              ; FC0D98  48
	inc 1,A                                              ; FC0D99  c9 61
	jr .LFC0D8D                                          ; FC0D9B  68 f0
.LFC0D9D:
	ret                                                  ; FC0D9D  0e
; ---------------------------------------------------------------------
; ScaleTuning_PostSemitoneFromRomRow -- posts semitone A's offset, read from the ROM row the
;                                       caller passes in XHL
;
; Evidence: 0xFC0D9E `ld (XIX+0x02),A` puts the semitone number in the
;           message at RAM 0x0716 and 0xFC0DA3 reads (XHL + WA) into W,
;           which 0xFC0DA8 writes to +0x03; 0xFC0DAB `calr` resolves to
;           0xFC17DF, the module's sender. XHL is the row
;           ScaleTuning_PostAllTwelveSemitones computed at 0xFC0D84
; Unknown:  what field +2 and +3 of the 0x0716 message mean to CPU 2.
;           notes/FINDINGS-prom_a-msg0716-module.md states that no
;           handler's message layout is established
; Was `sub_FC0D9E`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
ScaleTuning_PostSemitoneFromRomRow:
	ld (XIX+0x02),A                                      ; FC0D9E  bc 02 41
	xor W,W                                              ; FC0DA1  c8 d0
	ld	w, (xhl+wa)                                  ; FC0DA3  c3 07 ec e0 20
	ld (XIX+0x03),W                                      ; FC0DA8  bc 03 40
	calr ScaleTuning_PostPitchClassOffset                                          ; FC0DAB  1e 31 0a
	ret                                                  ; FC0DAE  0e
; ---------------------------------------------------------------------
; ScaleTuning_PostSemitoneFromUserRam -- the same, reading the twelve-byte USER copy at RAM 0x78A4
;                                        instead
;
; Evidence: identical to ScaleTuning_PostSemitoneFromRomRow except
;           0xFC0DB4 `ld XHL,0x000078a4`, which hard-codes the base the
;           ROM row would have supplied; 0xFC0DC1 `calr` resolves to the
;           SAME sender, 0xFC17DF. prom_b's ScaleTuningOffsets header
;           names 0x78A4 as the user copy and this address as the arm
;           that reads it, and row 14 (USER) of the ROM table is flat
;           because the editable copy is this one
; Unknown:  as above
; Was `sub_FC0DAF`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
ScaleTuning_PostSemitoneFromUserRam:
	ld (XIX+0x02),A                                      ; FC0DAF  bc 02 41
	xor W,W                                              ; FC0DB2  c8 d0
	ld XHL,0x000078a4                                    ; FC0DB4  43 a4 78 00 00
	ld	w, (xhl+wa)                                  ; FC0DB9  c3 07 ec e0 20
	ld (XIX+0x03),W                                      ; FC0DBE  bc 03 40
	calr ScaleTuning_PostPitchClassOffset                                          ; FC0DC1  1e 1b 0a
	ret                                                  ; FC0DC4  0e
; Msg0716_PostStream3Op80IfChanged: handler table 4 entry 0: Msg0716_PostStream3Op80 when UiEvent_Byte3 (the changed bits) & 0x0F.
Msg0716_PostStream3Op80IfChanged:   ; entry: named by 1 `.long` operand, first at 0xFC0AC6
	ld a, (UiEvent_Byte3:16)                                   ; FC0DC5  c1 ba 20 21
	and A,0x0f                                           ; FC0DC9  c9 cc 0f
	jr z, .LFC0DD1                                       ; FC0DCC  66 03
	calr Msg0716_PostStream3Op80                                          ; FC0DCE  1e 63 0d
.LFC0DD1:
	ret                                                  ; FC0DD1  0e
Msg0716_HandlerTables_Nop63:   ; entry: named by 1 `.long` operand, first at 0xFC0ACA
	ret                                                  ; FC0DD2  0e
; Msg0716_PostStream3Op90IfChanged: handler table 4 entry 2: Msg0716_PostStream3Op90 when UiEvent_Byte3 & 0x7F.
Msg0716_PostStream3Op90IfChanged:   ; entry: named by 1 `.long` operand, first at 0xFC0ACE
	ld a, (UiEvent_Byte3:16)                                   ; FC0DD3  c1 ba 20 21
	and A,0x7f                                           ; FC0DD7  c9 cc 7f
	jr z, .LFC0DDF                                       ; FC0DDA  66 03
	calr Msg0716_PostStream3Op90                                          ; FC0DDC  1e 6e 0d
.LFC0DDF:
	ret                                                  ; FC0DDF  0e
Msg0716_HandlerTables_Nop65:   ; entry: named by 5 `.long` operands, first at 0xFC0AD2
	ret                                                  ; FC0DE0  0e
Msg0716_HandlerTables_Nop70:   ; entry: named by 2 `.long` operands, first at 0xFC0AE6
	ret                                                  ; FC0DE1  0e
Msg0716_HandlerTables_Nop72:   ; entry: named by 1 `.long` operand, first at 0xFC0AEE
	ret                                                  ; FC0DE2  0e
; Msg0716_PostSysEx50_82_Call: calls Msg0716_PostSysEx50_82 and returns -- `calr Msg0716_PostSysEx50_82 / ret`.
Msg0716_PostSysEx50_82_Call:   ; entry: named by 1 `.long` operand, first at 0xFC0AF2
	calr Msg0716_PostSysEx50_82                                          ; FC0DE3  1e c8 09
	ret                                                  ; FC0DE6  0e
; Msg0716_HandlerTables_Nop74: Msg0716_HandlerTables entry [74]: `calr` to a bare `ret` and return -- it does nothing,
;   like its neighbours [72], [75]-[83] (Msg0716_HandlerTables_Nop72 / _Nop75 / _Nop76 / _Nop77). Basis: table index +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_HandlerTables_Nop74:   ; entry: named by 1 `.long` operand, first at 0xFC0AF6
	calr Msg0716_PostCtrlInt9B_Nop                                          ; FC0DE7  1e 9d 09
	ret                                                  ; FC0DEA  0e
Msg0716_HandlerTables_Nop75:   ; entry: named by 1 `.long` operand, first at 0xFC0AFA
	ret                                                  ; FC0DEB  0e
Msg0716_HandlerTables_Nop76:   ; entry: named by 1 `.long` operand, first at 0xFC0AFE
	ret                                                  ; FC0DEC  0e
Msg0716_HandlerTables_Nop77:   ; entry: named by 11 `.long` operands, first at 0xFC0B02
	ret                                                  ; FC0DED  0e
; Msg0716_SetPendingBit6IfHighNibble: when UiEvent_Byte3 & 0xF0, set bit 6 of (0x070E) and bit 0 of (0x070F).
Msg0716_SetPendingBit6IfHighNibble:   ; entry: named by 1 `.long` operand, first at 0xFC0B2E
	ld a, (UiEvent_Byte3:16)                                   ; FC0DEE  c1 ba 20 21
	and A,0xf0                                           ; FC0DF2  c9 cc f0
	jr z, .LFC0DFF                                       ; FC0DF5  66 08
	set	6, (0x070e:16)                               ; FC0DF7  f1 0e 07 be
	set	0, (0x070f:16)                               ; FC0DFB  f1 0f 07 b8
.LFC0DFF:
	ret                                                  ; FC0DFF  0e
Msg0716_SetPendingBit5:   ; entry: named by 1 `.long` operand, first at 0xFC0B32
	set	5, (0x070e:16)                               ; FC0E00  f1 0e 07 bd
	set	0, (0x070f:16)                               ; FC0E04  f1 0f 07 b8
	ret                                                  ; FC0E08  0e
; Msg0716_SetPendingBit5_B: byte-identical to Msg0716_SetPendingBit5; the handler tables name both.
Msg0716_SetPendingBit5_B:   ; entry: named by 1 `.long` operand, first at 0xFC0B36
	set	5, (0x070e:16)                               ; FC0E09  f1 0e 07 bd
	set	0, (0x070f:16)                               ; FC0E0D  f1 0f 07 b8
	ret                                                  ; FC0E11  0e
; Msg0716_PostCC07_VolumePart20: table 7 entry 3: Msg0716_PostCC07_Volume with part byte 0x20, one past the 32 parts.
Msg0716_PostCC07_VolumePart20:   ; entry: named by 1 `.long` operand, first at 0xFC0B3A
	ld XIX,0x00000716                                    ; FC0E12  44 16 07 00 00
	ld (XIX+0x01),0x20                                   ; FC0E17  bc 01 00 20
	calr Msg0716_PostCC07_Volume                                          ; FC0E1B  1e fd 06
	ret                                                  ; FC0E1E  0e
Msg0716_HandlerTables_Nop92:   ; entry: named by 1 `.long` operand, first at 0xFC0B3E
	ret                                                  ; FC0E1F  0e
Msg0716_HandlerTables_Nop93:   ; entry: named by 18 `.long` operands, first at 0xFC0B42
	ret                                                  ; FC0E20  0e
; Msg0716_RepostPart0Volume: table 8 entry 18: Msg0716_PostCC07_VolumeWithOffset for part 0 with (0x0606), part 0's slot +6 -- the value
;   Msg0716_PartSetVolume keeps there.
Msg0716_RepostPart0Volume:   ; entry: named by 1 `.long` operand, first at 0xFC0B8A
	ld XIY,0x00000600                                    ; FC0E21  45 00 06 00 00
	ld A,(XIY+0x06)                                      ; FC0E26  8d 06 21
	ld XIX,0x00000716                                    ; FC0E29  44 16 07 00 00
	ld (XIX+0x01),0x00                                   ; FC0E2E  bc 01 00 00
	calr Msg0716_PostCC07_VolumeWithOffset                                          ; FC0E32  1e 10 07
	ret                                                  ; FC0E35  0e
; Msg0716_RepostPart0Pan: table 8 entry 19: Msg0716_PostCC0A_PanWithOffset for part 0 with (0x76AA) & 0x7F, byte +8 of part 0's 64-byte
;   record 0x76A2.
Msg0716_RepostPart0Pan:   ; entry: named by 1 `.long` operand, first at 0xFC0B8E
	ld a, (CombiPart_Pan:16)                                   ; FC0E36  c1 aa 76 21
	and A,0x7f                                           ; FC0E3A  c9 cc 7f
	ld XIX,0x00000716                                    ; FC0E3D  44 16 07 00 00
	ld (XIX+0x01),0x00                                   ; FC0E42  bc 01 00 00
	calr Msg0716_PostCC0A_PanWithOffset                                          ; FC0E46  1e d4 07
	ret                                                  ; FC0E49  0e
; Msg0716_PostSysEx50_80_Call: calls Msg0716_PostSysEx50_80 and returns -- `calr Msg0716_PostSysEx50_80 / ret`.
Msg0716_PostSysEx50_80_Call:   ; entry: named by 1 `.long` operand, first at 0xFC0B92
	calr Msg0716_PostSysEx50_80                                          ; FC0E4A  1e 4f 09
	ret                                                  ; FC0E4D  0e
; Msg0716_PostSysEx50_81_Call: calls Msg0716_PostSysEx50_81 and returns -- `calr Msg0716_PostSysEx50_81 / ret`.
Msg0716_PostSysEx50_81_Call:   ; entry: named by 1 `.long` operand, first at 0xFC0B96
	calr Msg0716_PostSysEx50_81                                          ; FC0E4E  1e 3a 09
	ret                                                  ; FC0E51  0e
Msg0716_HandlerTables_Nop115:   ; entry: named by 14 `.long` operands, first at 0xFC0B9A
	ret                                                  ; FC0E52  0e
Msg0716_HandlerTables_Nop129:   ; entry: named by 1 `.long` operand, first at 0xFC0BD2
	ret                                                  ; FC0E53  0e
Msg0716_HandlerTables_Nop130:   ; entry: named by 1 `.long` operand, first at 0xFC0BD6
	ret                                                  ; FC0E54  0e
Msg0716_PostSysEx50_81_Call_Nop:
	ret                                                  ; FC0E55  0e
; Msg0716_FlushIfPending: when (0x070F) bit 0 is set -- the bit every Msg0716_PartSetProgram* sets -- Msg0716_FlushPending and clear it; then
;   (0x60F021) bit 5 is cleared.
Msg0716_FlushIfPending:
	bit	0, (0x070f:16)                               ; FC0E56  f1 0f 07 c8
	jr z, .LFC0E64                                       ; FC0E5A  66 08
	calr Msg0716_FlushPending                                      ; FC0E5C  1e 0c 00
	and	(0x070f:16), 0xfe                            ; FC0E5F  c1 0f 07 3c fe
.LFC0E64:
	and	(0x60f021:24), 0xdf                          ; FC0E64  c2 21 f0 60 3c df
	ret                                                  ; FC0E6A  0e
; Msg0716_FlushPending: the (0x070E) group posts when it is non-zero, then Msg0716_FlushPendingParts0to15 / 16to31 for a non-zero (0x0700) /
;   (0x0702) (after clearing those parts from (0x0706) / (0x0708)), two conditional extras, and finally clears
;   0x0700..0x070E.
Msg0716_FlushPending:
	cp	(0x070e:16), 0x00                            ; FC0E6B  c1 0e 07 3f 00
	jr z, .LFC0E7B                                       ; FC0E70  66 09
	calr Msg0716_FlushPendingBlocks                                      ; FC0E72  1e 50 01
	calr Msg0716_SustainOffParts0to7                                      ; FC0E75  1e ca 01
	calr Msg0716_AllSoundOffParts0to7                                      ; FC0E78  1e 78 01
.LFC0E7B:
	cpw	(0x0700:16), 0x0000                          ; FC0E7B  d1 00 07 3f 00 00
	jr z, .LFC0E92                                       ; FC0E81  66 0f
	ld wa, (0x0700:16)                                 ; FC0E83  d1 00 07 20
	xor WA,0xffff                                        ; FC0E87  d8 cd ff ff
	and	(0x0706:16), wa                      ; FC0E8B  d1 06 07 c8
	calr Msg0716_FlushPendingParts0to15                                      ; FC0E8F  1e bc 00
.LFC0E92:
	cpw	(0x0702:16), 0x0000                          ; FC0E92  d1 02 07 3f 00 00
	jr z, .LFC0EA9                                       ; FC0E98  66 0f
	ld wa, (0x0702:16)                                 ; FC0E9A  d1 02 07 20
	xor WA,0xffff                                        ; FC0E9E  d8 cd ff ff
	and	(0x0708:16), wa                      ; FC0EA2  d1 08 07 c8
	calr Msg0716_FlushPendingParts16to31                                      ; FC0EA6  1e dc 00
.LFC0EA9:
	bit	5, (0x60f021:24)                             ; FC0EA9  f2 21 f0 60 cd
	jr nz, .LFC0ED6                                      ; FC0EAE  6e 26
	ld a, (0x7ee4:16)                                   ; FC0EB0  c1 e4 7e 21
	and A,0x0f                                           ; FC0EB4  c9 cc 0f
	cp a, 0x02:i3                                          ; FC0EB7  c9 da
	jr nz, .LFC0ED6                                      ; FC0EB9  6e 1b
	ld wa, (0x0700:16)                                 ; FC0EBB  d1 00 07 20
	and WA,0x0001                                        ; FC0EBF  d8 cc 01 00
	jr z, .LFC0ED6                                       ; FC0EC3  66 11
	ld a, (0x7f02:16)                                   ; FC0EC5  c1 02 7f 21
	and A,0xf0                                           ; FC0EC9  c9 cc f0
	cp a, 0x00:i3                                          ; FC0ECC  c9 d8
	jr nz, .LFC0ED6                                      ; FC0ECE  6e 06
	ld b, 0x00:opc                                          ; FC0ED0  22 00
	call Cpu2Query_RequestPartSoundRecord                                      ; FC0ED2  1d 0c 12 fc
.LFC0ED6:
	ld wa, (0x0700:16)                                 ; FC0ED6  d1 00 07 20
	and WA,0x0001                                        ; FC0EDA  d8 cc 01 00
	jr z, .LFC0EFB                                       ; FC0EDE  66 1b
	calr SoundMode_ResetLvl                                          ; FC0EE0  1e e3 05
	calr SoundMode_ResetPan                                          ; FC0EE3  1e f9 05
	ld a, (0x7f02:16)                                   ; FC0EE6  c1 02 7f 21
	and A,0xf0                                           ; FC0EEA  c9 cc f0
	cp a, 0x00:i3                                          ; FC0EED  c9 d8
	jr nz, .LFC0EFB                                      ; FC0EEF  6e 0a
	bit	5, (0x60f021:24)                             ; FC0EF1  f2 21 f0 60 cd
	jr nz, .LFC0EFB                                      ; FC0EF6  6e 03
	calr ModeScreen_ResetOct                                          ; FC0EF8  1e fd 05
.LFC0EFB:
	bit	5, (0x60f021:24)                             ; FC0EFB  f2 21 f0 60 cd
	jr nz, .LFC0F24                                      ; FC0F00  6e 22
sub_FC0F02:
	ld a, (0x7ee4:16)                                   ; FC0F02  c1 e4 7e 21
	and A,0xf0                                           ; FC0F06  c9 cc f0
	cp A,0x20                                            ; FC0F09  c9 cf 20
	jr nz, .LFC0F24                                      ; FC0F0C  6e 16
	cpw	(0x0700:16), 0x0000                          ; FC0F0E  d1 00 07 3f 00 00
	jr z, .LFC0F19                                       ; FC0F14  66 03
	calr sub_FC1420                                          ; FC0F16  1e 07 05
.LFC0F19:
	cpw	(0x0702:16), 0x0000                          ; FC0F19  d1 02 07 3f 00 00
	jr z, .LFC0F24                                       ; FC0F1F  66 03
	calr sub_FC143E                                          ; FC0F21  1e 1a 05
.LFC0F24:
	ldw (0x0700:16), 0x00                                ; FC0F24  f1 00 07 02 00 00
	ldw (0x0702:16), 0x00                                ; FC0F2A  f1 02 07 02 00 00
	ldw (0x0704:16), 0x00                                ; FC0F30  f1 04 07 02 00 00
	ldw (0x0706:16), 0x00                                ; FC0F36  f1 06 07 02 00 00
	ldw (0x0708:16), 0x00                                ; FC0F3C  f1 08 07 02 00 00
	ldw (0x070c:16), 0x00                                ; FC0F42  f1 0c 07 02 00 00
	ld (0x070e:16), 0x00                                 ; FC0F48  f1 0e 07 00 00
	ret                                                  ; FC0F4D  0e
; Msg0716_FlushPendingParts0to15: for each part 0..15 whose bit is set in (0x0700): Msg0716_PartPostCC78_AllSoundOff then Msg0716_PartPostProgramChange.
Msg0716_FlushPendingParts0to15:
	ld XIX,0x00000716                                    ; FC0F4E  44 16 07 00 00
	ld XIZ,Msg0716_ObjectRecords                         ; FC0F53  46 90 08 fc 00
	ld c, 0x00:opc                                          ; FC0F58  23 00
	ld de, (0x0700:16)                                 ; FC0F5A  d1 00 07 22
.LFC0F5E:
	ldfr_berp a, 0x3c                                      ; FC0F5E  c7 3c 99   ld RL3,A
	.byte 0xd7, 0x3e, 0x9a                               ; FC0F61  d7 3e 9a   ld QHL3,DE
	ld A,C                                               ; FC0F64  cb 89
	scf                                                  ; FC0F66  11
	.byte 0xd7, 0x3e, 0x2a                               ; FC0F67  d7 3e 2a   xorcf A,QHL3
	ld_erpb_rr a, 0x3c                                   ; FC0F6A  c7 3c 89   ld A,RL3
	jr c, .LFC0F75                                       ; FC0F6D  67 06
	calr Msg0716_PartPostCC78_AllSoundOff                                      ; FC0F6F  1e ac 00
	calr Msg0716_PartPostProgramChange                                          ; FC0F72  1e a3 09
.LFC0F75:
	inc 1,C                                              ; FC0F75  cb 61
	cp C,0x0f                                            ; FC0F77  cb cf 0f
	jr ugt, .LFC0F84                                     ; FC0F7A  6b 08
	add XIZ,0x00000008                                   ; FC0F7C  ee c8 08 00 00 00
	jr .LFC0F5E                                          ; FC0F82  68 da
.LFC0F84:
	ret                                                  ; FC0F84  0e
; Msg0716_FlushPendingParts16to31: the same over (0x0702) and parts 16..31 (Msg0716_ObjectRecords + 0x80).
Msg0716_FlushPendingParts16to31:
	ld XIX,0x00000716                                    ; FC0F85  44 16 07 00 00
	ld XIZ,Msg0716_ObjectRecords+0x80                    ; FC0F8A  46 10 09 fc 00
	ld c, 0x00:opc                                          ; FC0F8F  23 00
	ld de, (0x0702:16)                                 ; FC0F91  d1 02 07 22
.LFC0F95:
	ldfr_berp a, 0x3c                                      ; FC0F95  c7 3c 99   ld RL3,A
	.byte 0xd7, 0x3e, 0x9a                               ; FC0F98  d7 3e 9a   ld QHL3,DE
	ld A,C                                               ; FC0F9B  cb 89
	scf                                                  ; FC0F9D  11
	.byte 0xd7, 0x3e, 0x2a                               ; FC0F9E  d7 3e 2a   xorcf A,QHL3
	ld_erpb_rr a, 0x3c                                   ; FC0FA1  c7 3c 89   ld A,RL3
	jr c, .LFC0FAC                                       ; FC0FA4  67 06
	calr Msg0716_PartPostCC78_AllSoundOff                                      ; FC0FA6  1e 75 00
	calr Msg0716_PartPostProgramChange                                          ; FC0FA9  1e 6c 09
.LFC0FAC:
	inc 1,C                                              ; FC0FAC  cb 61
	cp C,0x0f                                            ; FC0FAE  cb cf 0f
	jr ugt, .LFC0FBB                                     ; FC0FB1  6b 08
	add XIZ,0x00000008                                   ; FC0FB3  ee c8 08 00 00 00
	jr .LFC0F95                                          ; FC0FB9  68 da
.LFC0FBB:
	ret                                                  ; FC0FBB  0e
	ret                                                  ; FC0FBC  0e
T_F40FB8_Nop:
	ret                                                  ; FC0FBD  0e
T_F40FBC_Nop:
	ret                                                  ; FC0FBE  0e
	ret                                                  ; FC0FBF  0e
	ret                                                  ; FC0FC0  0e
	ret                                                  ; FC0FC1  0e
	ret                                                  ; FC0FC2  0e
	ret                                                  ; FC0FC3  0e
	ret                                                  ; FC0FC4  0e
; Msg0716_FlushPendingBlocks: (0x070E) bit 4 -> Msg0716_PostOp87_Bytes78B3, bit 0 -> Msg0716_PostOp80_Byte7634, bits 1..3 ->
;   Msg0716_PostOp81_EffectBlock97 / Op82_EffectBlock98 / Op83_EffectBlock99 -- the bits Msg0716_SetPendingBit0..4 set.
;   Called first by Msg0716_FlushPending.
Msg0716_FlushPendingBlocks:
	bit	4, (0x070e:16)                               ; FC0FC5  f1 0e 07 cc
	jr z, .LFC0FCE                                       ; FC0FC9  66 03
	calr Msg0716_PostOp87_Bytes78B3                                          ; FC0FCB  1e 07 0b
.LFC0FCE:
	bit	0, (0x070e:16)                               ; FC0FCE  f1 0e 07 c8
	jr z, .LFC0FD7                                       ; FC0FD2  66 03
	calr Msg0716_PostOp80_Byte7634                                          ; FC0FD4  1e 5e 0a
.LFC0FD7:
	bit	1, (0x070e:16)                               ; FC0FD7  f1 0e 07 c9
	jr z, .LFC0FE0                                       ; FC0FDB  66 03
	calr Msg0716_PostOp81_EffectBlock97                                          ; FC0FDD  1e 7d 0a
.LFC0FE0:
	bit	2, (0x070e:16)                               ; FC0FE0  f1 0e 07 ca
	jr z, .LFC0FE9                                       ; FC0FE4  66 03
	calr Msg0716_PostOp82_EffectBlock98                                          ; FC0FE6  1e 9c 0a
.LFC0FE9:
	bit	3, (0x070e:16)                               ; FC0FE9  f1 0e 07 cb
	jr z, .LFC0FF2                                       ; FC0FED  66 03
	calr Msg0716_PostOp83_EffectBlock99                                          ; FC0FEF  1e bb 0a
.LFC0FF2:
	ret                                                  ; FC0FF2  0e
; Msg0716_AllSoundOffParts0to7: unless (0x7F0B) bit 0, and only when (0x070E) bit 5 or 6 is set: Msg0716_PostCC78_AllSoundOff for parts 0..7 --
;   the parts Msg0716_PartPostCC78_AllSoundOff skips in that case.  Called last by Msg0716_FlushPending's group posts.
Msg0716_AllSoundOffParts0to7:
	bit	0, (0x7f0b:16)                               ; FC0FF3  f1 0b 7f c8
	jr nz, .LFC101D                                      ; FC0FF7  6e 24
	bit	5, (0x070e:16)                               ; FC0FF9  f1 0e 07 cd
	jr nz, .LFC1005                                      ; FC0FFD  6e 06
	bit	6, (0x070e:16)                               ; FC0FFF  f1 0e 07 ce
	jr z, .LFC101D                                       ; FC1003  66 18
.LFC1005:
	ld XIX,0x00000716                                    ; FC1005  44 16 07 00 00
	ld c, 0x00:opc                                          ; FC100A  23 00
.LFC100C:
	ld (XIX+0x01),C                                      ; FC100C  bc 01 43
	pushw bc                                             ; FC100F  29
	push XIX                                             ; FC1010  3c
	calr Msg0716_PostCC78_AllSoundOff                                          ; FC1011  1e da 06
	pop XIX                                              ; FC1014  5c
	popw bc                                              ; FC1015  49
	add C,0x01                                           ; FC1016  cb c8 01
	cp c, 0x07:i3                                          ; FC1019  cb df
	jr ule, .LFC100C                                     ; FC101B  63 ef
.LFC101D:
	ret                                                  ; FC101D  0e
; Msg0716_PartPostCC78_AllSoundOff: unless (0x7F0B) bit 0, and -- when (0x070E) bit 5 or 6 is set -- only for parts above 7: Msg0716_PostCC78_AllSoundOff
;   for the part.  Called by the pending-part loops before the program change.
Msg0716_PartPostCC78_AllSoundOff:
	bit	0, (0x7f0b:16)                               ; FC101E  f1 0b 7f c8
	jr nz, .LFC1041                                      ; FC1022  6e 1d
	bit	5, (0x070e:16)                               ; FC1024  f1 0e 07 cd
	jr nz, .LFC1030                                      ; FC1028  6e 06
	bit	6, (0x070e:16)                               ; FC102A  f1 0e 07 ce
	jr z, .LFC1036                                       ; FC102E  66 06
.LFC1030:
	cp (XIZ+0x06),0x07                                   ; FC1030  8e 06 3f 07
	jr ule, .LFC1041                                     ; FC1034  63 0b
.LFC1036:
	ld A,(XIZ+0x06)                                      ; FC1036  8e 06 21
	ld (XIX+0x01),A                                      ; FC1039  bc 01 41
	pushw bc                                             ; FC103C  29
	calr Msg0716_PostCC78_AllSoundOff                                          ; FC103D  1e ae 06
	popw bc                                              ; FC1040  49
.LFC1041:
	ret                                                  ; FC1041  0e
; Msg0716_SustainOffParts0to7: With (0x070E) bit 6 pending: Msg0716_PostCC40_SustainOff (B0 part 40 00) for parts
;   0..7. Else with bit 5: mask = parts 0..7 whose record +0x0D has bit 5 clear; (0x0712) := mask, (0x0713) := parts
;   that left it, (0x0714) := parts that joined; Sustain off for each part that left. Msg0716_FlushPending runs it
;   between Msg0716_FlushPendingBlocks and its sibling Msg0716_AllSoundOffParts0to7. Basis: caller + body + sibling.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_SustainOffParts0to7:
	bit	6, (0x070e:16)                               ; FC1042  f1 0e 07 ce
	jrl nz, .LFC10B7                                     ; FC1046  7e 6e 00
	bit	5, (0x070e:16)                               ; FC1049  f1 0e 07 cd
	jrl z, .LFC10D9                                      ; FC104D  76 89 00
	ld XIZ,Msg0716_ObjectRecords                         ; FC1050  46 90 08 fc 00
	ldw de, 0x00                                         ; FC1055  32 00 00
	ld w, 0x00:opc                                          ; FC1058  20 00
.LFC105A:
	calr Msg0716_GetRecordPtrByIndex                                      ; FC105A  1e f1 00
	bit 5,(XIY+0x0d)                                     ; FC105D  bd 0d cd
	jr nz, .LFC1065                                      ; FC1060  6e 03
	or DE,(XIZ+0x04)                                     ; FC1062  9e 04 e2
.LFC1065:
	inc 1,W                                              ; FC1065  c8 61
	cp w, 0x07:i3                                          ; FC1067  c8 df
	jr ugt, .LFC1073                                     ; FC1069  6b 08
	add XIZ,0x00000008                                   ; FC106B  ee c8 08 00 00 00
	jr .LFC105A                                          ; FC1071  68 e7
.LFC1073:
	ld d, (0x0712:16)                                   ; FC1073  c1 12 07 24
	ld (0x0712:16), e                                   ; FC1077  f1 12 07 45
	xor D,E                                              ; FC107B  cd d4
	ld A,E                                               ; FC107D  cd 89
	xor A,0xff                                           ; FC107F  c9 cd ff
	and A,D                                              ; FC1082  cc c1
	ld (0x0713:16), a                                   ; FC1084  f1 13 07 41
	and E,D                                              ; FC1088  cc c5
	ld (0x0714:16), e                                   ; FC108A  f1 14 07 45
	ld XIX,0x00000716                                    ; FC108E  44 16 07 00 00
	ld b, (0x0713:16)                                   ; FC1093  c1 13 07 22
	ld c, 0x00:opc                                          ; FC1097  23 00
	ld XIZ,Msg0716_ObjectRecords                         ; FC1099  46 90 08 fc 00
.LFC109E:
	sra b, 0x01                                          ; FC109E  ca ed 01
	jr nc, .LFC10A9                                      ; FC10A1  6f 06
	pushw bc                                             ; FC10A3  29
	call Msg0716_PostCC40_SustainOff                                      ; FC10A4  1d 75 19 fc
	popw bc                                              ; FC10A8  49
.LFC10A9:
	inc 1,C                                              ; FC10A9  cb 61
	cp c, 0x07:i3                                          ; FC10AB  cb df
	jr ugt, .LFC10D9                                     ; FC10AD  6b 2a
	add XIZ,0x00000008                                   ; FC10AF  ee c8 08 00 00 00
	jr .LFC109E                                          ; FC10B5  68 e7
.LFC10B7:
	ld XIX,0x00000716                                    ; FC10B7  44 16 07 00 00
	ld c, 0x00:opc                                          ; FC10BC  23 00
	ld XIZ,Msg0716_ObjectRecords                         ; FC10BE  46 90 08 fc 00
.LFC10C3:
	push C                                               ; FC10C3  cb 04
	call Msg0716_PostCC40_SustainOff                                      ; FC10C5  1d 75 19 fc
	pop C                                                ; FC10C9  cb 05
	inc 1,C                                              ; FC10CB  cb 61
	cp c, 0x07:i3                                          ; FC10CD  cb df
	jr ugt, .LFC10D9                                     ; FC10CF  6b 08
	add XIZ,0x00000008                                   ; FC10D1  ee c8 08 00 00 00
	jr .LFC10C3                                          ; FC10D7  68 ea
.LFC10D9:
	ret                                                  ; FC10D9  0e
T_F40FE4_Nop:
	ret                                                  ; FC10DA  0e
T_F40FE0_Nop:
	ret                                                  ; FC10DB  0e
	ret                                                  ; FC10DC  0e
; Msg0716_AllPartsResetBendAndModulation: for the 32 object records: Msg0716_PostPitchBendCenter and Msg0716_PostCC01_ModulationZero.  Called by Msg0716_AllPartsResetBendAndModulation_Call
;   and Msg0716_AllPartsResetBendAndModulation_SaveRegs.
Msg0716_AllPartsResetBendAndModulation:
	ld XIX,0x00000716                                    ; FC10DD  44 16 07 00 00
	ld XIZ,Msg0716_ObjectRecords                         ; FC10E2  46 90 08 fc 00
	ldw bc, 0x20                                         ; FC10E7  31 20 00
.LFC10EA:
	pushw bc                                             ; FC10EA  29
	calr Msg0716_PostPitchBendCenter                                          ; FC10EB  1e 57 08
	calr Msg0716_PostCC01_ModulationZero                                          ; FC10EE  1e 6c 08
	popw bc                                              ; FC10F1  49
	add IZ,0x0008                                        ; FC10F2  de c8 08 00
	djnz16 bc, .LFC10EA                                  ; FC10F6  d9 1c f1
	ret                                                  ; FC10F9  0e
; Msg0716_AllPartsSustainOff: for the 32 object records from Msg0716_ObjectRecords (8 bytes each): Msg0716_PostCC40_SustainOff.
Msg0716_AllPartsSustainOff:
	ld XIX,0x00000716                                    ; FC10FA  44 16 07 00 00
	ld XIZ,Msg0716_ObjectRecords                         ; FC10FF  46 90 08 fc 00
	ldw bc, 0x20                                         ; FC1104  31 20 00
.LFC1107:
	pushw bc                                             ; FC1107  29
	calr Msg0716_PostCC40_SustainOff                                          ; FC1108  1e 6a 08
	popw bc                                              ; FC110B  49
	add XIZ,0x00000008                                   ; FC110C  ee c8 08 00 00 00
	djnz16 bc, .LFC1107                                  ; FC1112  d9 1c f2
	ret                                                  ; FC1115  0e
sub_FC1116:
	ld W,(XSP+0x04)                                      ; FC1116  8f 04 20
; PartSound_GetBankAndToneFlag: (W = part) A = byte +1 of the part's record (Msg0716_GetRecordPtrByIndex, 0x76A2 +
;   0x40k: program at +0, bank at +1), with bit 5 set when the bank is 0x10..0x17 (E1 = 0x10) and the byte table at
;   0x2F80 (loaded over the link from 0x00C00000 + (0x0878)) is 1 at the program. Callers take bit 5 as "tone record":
;   CreatorSelect_ReadSlotLabelIds, the part/tone record query and the USER drum-map note map. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
PartSound_GetBankAndToneFlag:
	call PartSound_GetProgramBankPtr                                      ; FC1119  1d 43 11 fc
	ld A,(XIY+0x01)                                      ; FC111D  8d 01 21
	cp A,0x10                                            ; FC1120  c9 cf 10
	jr c, .LFC1142                                       ; FC1123  67 1d
	cp A,0x18                                            ; FC1125  c9 cf 18
	jr nc, .LFC1142                                      ; FC1128  6f 18
	push XIX                                             ; FC112A  3c
	push C                                               ; FC112B  cb 04
	ld C,(XIY)                                           ; FC112D  85 23
	ld XIX,0x00002f80                                    ; FC112F  44 80 2f 00 00
	.byte 0xc3, 0x03, 0xf0, 0xe4, 0x3f, 0x01             ; FC1134  c3 03 f0 e4 3f 01   cp (XIX+C),0x01
	jr nz, .LFC113F                                      ; FC113A  6e 03
	set 0x05,A                                           ; FC113C  c9 31 05
.LFC113F:
	pop C                                                ; FC113F  cb 05
	pop XIX                                              ; FC1141  5c
.LFC1142:
	ret                                                  ; FC1142  0e
; PartSound_GetProgramBankPtr: (W = part) XIY := Msg0716_GetRecordPtrByIndex(W) + 0 -- the part record's PROGRAM
;   CHANGE & BANK field (program at +0, bank at +1). PartSound_GetBankAndToneFlag's first call; it then reads (XIY+1)
;   and (XIY). Basis: caller + body + parameter table. (notes/naming-pilot-2026-10-06/proposals_wave10_a10.json)
PartSound_GetProgramBankPtr:
	call Msg0716_GetRecordPtrByIndex                                      ; FC1143  1d 4e 11 fc
	add XIY,0x00000000                                   ; FC1147  ed c8 00 00 00 00
	ret                                                  ; FC114D  0e
; ---------------------------------------------------------------------
; Msg0716_GetRecordPtrByIndex -- returns Msg0716_RecordPtrTable[W] in XIY
;
; Evidence: 0xFC1153 `sla wa,0x02` scales the index by the table's
;           four-byte entry, 0xFC1156 `ld XIY,0x00fc1162` is
;           Msg0716_RecordPtrTable itself and 0xFC115B loads XIY from
;           XIY+WA. That table's own header, already in this listing,
;           names this routine as one of its exactly two readers -- `the
;           helper at 0xFC114E that is calr-ed 15 times and takes its
;           index in W`
; Unknown:  what a 0x40-byte record holds -- the gap the table's header
;           states. This routine bounds nothing; the bound is the 32
;           records that supply the index
; Was `sub_FC114E`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
Msg0716_GetRecordPtrByIndex:
	pushw wa                                             ; FC114E  28
	ld A,W                                               ; FC114F  c8 89
	xor W,W                                              ; FC1151  c8 d0
	sla wa, 0x02                                         ; FC1153  d8 ec 02
	ld XIY,Msg0716_RecordPtrTable                        ; FC1156  45 62 11 fc 00
	ld	xiy, (xiy+wa)                                ; FC115B  e3 07 f4 e0 25
	popw wa                                              ; FC1160  48
	ret                                                  ; FC1161  0e
; ---------------------------------------------------------------------
; Msg0716_RecordPtrTable -- 32 pointers to 0x40-byte RAM records
;
; Entry k is 0x000076A2 + 0x40*k, WITH ONE EXCEPTION: the step from entry 7
; (0x7862) to entry 8 (0x78E2) is 0x80, so 0x000078A2 is skipped -- the only
; step in the table that is not 0x40.  0x78A2 is not unused RAM: it is named
; directly, by absolute address, at six sites in this module, more often than
; any other address in 0x7600-0x7EFF.  The table indexes the other 32.
;
; ENTRY COUNT = 32, by last-entry test: entry 31 is 0x00007EA2, and the four
; bytes a 33rd entry would occupy, at 0xFC11E2, are 0x03020100 -- the start of
; the byte ramp that follows, not 0x00007EE2.  The arithmetic sequence stops
; there and nowhere else.
;
; READ BY exactly two sites, both `ld XIY,0x00fc1162`: 0xFC1156, inside the
; helper at 0xFC114E that is `calr`ed 15 times and takes its index in W, and
; 0xFC1737, which takes its index from field +6 of Msg0716_ObjectRecords.
; Neither reader bounds the index; the bound is the 32 records that supply it.
;
; Evidence: notes/prom_a_fc0000_module_check.py section 5 re-derives entry 0,
;          entry 31, EVERY step (reporting the one that is not 0x40), the
;          0x03020100 that a 33rd entry would read, the two reader sites and
;          that 0x78A2 is the most-named address in 0x7600-0x7EFF.
; Unknown: what a 0x40-byte record holds.
; ---------------------------------------------------------------------
Msg0716_RecordPtrTable:
	.long 0x000076a2                                 ; FC1162  [  0]
	.long 0x000076e2                                 ; FC1166  [  1]
	.long 0x00007722                                 ; FC116A  [  2]
	.long 0x00007762                                 ; FC116E  [  3]
	.long 0x000077a2                                 ; FC1172  [  4]
	.long 0x000077e2                                 ; FC1176  [  5]
	.long 0x00007822                                 ; FC117A  [  6]
	.long 0x00007862                                 ; FC117E  [  7]
	.long 0x000078e2                                 ; FC1182  [  8]
	.long 0x00007922                                 ; FC1186  [  9]
	.long 0x00007962                                 ; FC118A  [ 10]
	.long 0x000079a2                                 ; FC118E  [ 11]
	.long 0x000079e2                                 ; FC1192  [ 12]
	.long 0x00007a22                                 ; FC1196  [ 13]
	.long 0x00007a62                                 ; FC119A  [ 14]
	.long 0x00007aa2                                 ; FC119E  [ 15]
	.long 0x00007ae2                                 ; FC11A2  [ 16]
	.long 0x00007b22                                 ; FC11A6  [ 17]
	.long 0x00007b62                                 ; FC11AA  [ 18]
	.long 0x00007ba2                                 ; FC11AE  [ 19]
	.long 0x00007be2                                 ; FC11B2  [ 20]
	.long 0x00007c22                                 ; FC11B6  [ 21]
	.long 0x00007c62                                 ; FC11BA  [ 22]
	.long 0x00007ca2                                 ; FC11BE  [ 23]
	.long 0x00007ce2                                 ; FC11C2  [ 24]
	.long 0x00007d22                                 ; FC11C6  [ 25]
	.long 0x00007d62                                 ; FC11CA  [ 26]
	.long 0x00007da2                                 ; FC11CE  [ 27]
	.long 0x00007de2                                 ; FC11D2  [ 28]
	.long 0x00007e22                                 ; FC11D6  [ 29]
	.long 0x00007e62                                 ; FC11DA  [ 30]
	.long 0x00007ea2                                 ; FC11DE  [ 31]
; ---------------------------------------------------------------------
; Msg0716_IdentityRamp_0_24 -- 25 bytes, 0x00 0x01 ... 0x18
;
; Evidence: the bytes are exactly range(0x19); the four before are the last
; entry of Msg0716_RecordPtrTable and the byte after, 0xFC11FB, is a directory
; target (T_Cpu2Query_RefreshPartSoundRecord) that decodes as `ld B,(XSP+0x04)`.
; Unknown: its reader.  ⚠ A SEARCHED NEGATIVE, stated as what the search
;          returned: notes/prom_a_ringbuf_map.all_refs() reports exactly one
;          site for 0xFC11E2, a PC-relative `jrl` displacement computed at
;          0xFC11DF -- which is four bytes inside this table's own last entry
;          and is not an instruction at all.  No call, jp, lda or 32-bit pointer
;          names it.  So whoever indexes the ramp does so from a register.
; ---------------------------------------------------------------------
Msg0716_IdentityRamp_0_24:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f  ; FC11E2
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18                ; FC11F2
; Cpu2Query_RefreshPartSoundRecord: (part = stack byte) Cpu2Query_RequestPartSoundRecord (the part- or tone-record
;   read on the CPU-2 link) then Cpu2Query_DrainRecordReplies, which applies whatever replies ring 0x60000C already
;   holds; XIX / XDE / XHL saved. Slot T_Cpu2Query_RefreshPartSoundRecord: CompareKey_DspEffect calls it with part 0 after re-sending the DSP
;   effect. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Cpu2Query_RefreshPartSoundRecord:
	ld B,(XSP+0x04)                                      ; FC11FB  8f 04 22
	push XIX                                             ; FC11FE  3c
	push XDE                                             ; FC11FF  3a
	push XHL                                             ; FC1200  3b
	call Cpu2Query_RequestPartSoundRecord                                      ; FC1201  1d 0c 12 fc
	calr Cpu2Query_DrainRecordReplies                                          ; FC1205  1e 8a 0b
	pop XHL                                              ; FC1208  5b
	pop XDE                                              ; FC1209  5a
	pop XIX                                              ; FC120A  5c
	ret                                                  ; FC120B  0e
; Cpu2Query_RequestPartSoundRecord: (B = part) If PartSound_GetBankAndToneFlag leaves bit 5 clear: Cpu2Query_RequestPartRecordEffects sends
;   the part-record read [0x81, part, 0x87, 0x49, 4, 0] (Cpu2Query_SendPartRecordRead87); else Cpu2Query_RequestToneRecordEffects sends the
;   tone-record read [0x85, part, 0x52, 0x46, 4, 0] (Cpu2Query_SendToneRecordRead52); both under kernel semaphore 4,
;   header at 0x850. Msg0716_FlushPending calls it for part 0. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
Cpu2Query_RequestPartSoundRecord:
	ld W,B                                               ; FC120C  ca 88
	call PartSound_GetBankAndToneFlag                                      ; FC120E  1d 19 11 fc
	bit 0x05,A                                           ; FC1212  c9 33 05
	jr nz, .LFC121C                                      ; FC1215  6e 05
	calr Cpu2Query_RequestPartRecordEffects                                          ; FC1217  1e ba 0a
	jr .LFC121F                                          ; FC121A  68 03
.LFC121C:
	calr Cpu2Query_RequestToneRecordEffects                                          ; FC121C  1e 03 0b
.LFC121F:
	ret                                                  ; FC121F  0e
; Cpu2Query_ApplyPartRecordEffects: Applies the 0x49-byte 81/87 reply (Cpu2Query_SendPartRecordRead87) to part 0 and
;   the effect area: byte 0's nibbles -> MAIN OUT (0x76C5) / SUB OUT (0x76C6), EFFECT2 ON/OFF (0x76A8) := 0x7F when
;   either is 5, else 0; then EFFECT1 SEND (0x76A7), REVERB SEND (0x76A9), EFFECT1/2 OUTPUT SELECT (0x78B7), EFFECT
;   COMMON (0x7634) and effect blocks 0x7642/0x7662/0x7682, each posted to Queue2E00. Cpu2Query_DrainRecordReplies
;   runs it for an 81/87 reply. Basis: caller + body + parameter addresses. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_a10.json)
Cpu2Query_ApplyPartRecordEffects:
	ld XIY,0x00000860                                    ; FC1220  45 60 08 00 00
	xor DE,DE                                            ; FC1225  da d2
	xor H,H                                              ; FC1227  ce d6
	ld a, (xiy+)                                      ; FC1229  c5 f4 21
	ld W,A                                               ; FC122C  c9 88
	sra w, 0x04                                          ; FC122E  c8 ed 04
	and A,0x0f                                           ; FC1231  c9 cc 0f
	cp a, 0x05:i3                                          ; FC1234  c9 dd
	jr nz, .LFC123C                                      ; FC1236  6e 04
	ld h, 0x7f:opc                                          ; FC1238  26 7f
	jr .LFC123E                                          ; FC123A  68 02
.LFC123C:
	ld E,A                                               ; FC123C  c9 8d
.LFC123E:
	cp w, 0x05:i3                                          ; FC123E  c8 dd
	jr nz, .LFC1246                                      ; FC1240  6e 04
	ld h, 0x7f:opc                                          ; FC1242  26 7f
	jr .LFC1248                                          ; FC1244  68 02
.LFC1246:
	ld D,W                                               ; FC1246  c8 8c
.LFC1248:
	ld (CombiPart_Effect2OnOff:16), h                                   ; FC1248  f1 a8 76 46
	ld (0x76c5:16), e                                   ; FC124C  f1 c5 76 45
	ld (0x76c6:16), d                                   ; FC1250  f1 c6 76 44
	ld a, (xiy+)                                      ; FC1254  c5 f4 21
	ld (CombiPart_Effect1Send:16), a                                   ; FC1257  f1 a7 76 41
	ld a, (xiy+)                                      ; FC125B  c5 f4 21
	ld (CombiPart_ReverbSend:16), a                                   ; FC125E  f1 a9 76 41
	ld a, (xiy+)                                      ; FC1262  c5 f4 21
	ld (0x78b7:16), a                                   ; FC1265  f1 b7 78 41
	ldw bc, 0x01                                         ; FC1269  31 01 00
	ld XIX,0x00007634                                    ; FC126C  44 34 76 00 00
	ldir85                                               ; FC1271  85 11
	ldw bc, 0x17                                         ; FC1273  31 17 00
	ld XIX,0x00007642                                    ; FC1276  44 42 76 00 00
	ldir85                                               ; FC127B  85 11
	ld (XIX),0x00                                        ; FC127D  b4 00 00
	ldw bc, 0x17                                         ; FC1280  31 17 00
	ld XIX,0x00007662                                    ; FC1283  44 62 76 00 00
	ldir85                                               ; FC1288  85 11
	ld (XIX),0x00                                        ; FC128A  b4 00 00
	ldw bc, 0x15                                         ; FC128D  31 15 00
	ld XIX,0x00007682                                    ; FC1290  44 82 76 00 00
	ldir85                                               ; FC1295  85 11
	ldw bc, 0x01                                         ; FC1297  31 01 00
	ld XIX,0x00007698                                    ; FC129A  44 98 76 00 00
	ldir85                                               ; FC129F  85 11
	ld (XIX),0x00                                        ; FC12A1  b4 00 00
	ld d, 0x05:opc                                          ; FC12A4  24 05
	ld e, 0x00:opc                                          ; FC12A6  25 00
	ld a, (CombiPart_Effect1Send:16)                                   ; FC12A8  c1 a7 76 21
	ld w, 0x7f:opc                                          ; FC12AC  20 7f
	call T_Queue2E00_AppendRegs                          ; FC12AE  1d 3c 0f f4
	ld d, 0x06:opc                                          ; FC12B2  24 06
	ld e, 0x00:opc                                          ; FC12B4  25 00
	ld a, (CombiPart_Effect2OnOff:16)                                   ; FC12B6  c1 a8 76 21
	ld w, 0x7f:opc                                          ; FC12BA  20 7f
	call T_Queue2E00_AppendRegs                          ; FC12BC  1d 3c 0f f4
	ld d, 0x07:opc                                          ; FC12C0  24 07
	ld e, 0x00:opc                                          ; FC12C2  25 00
	ld a, (CombiPart_ReverbSend:16)                                   ; FC12C4  c1 a9 76 21
	ld w, 0x7f:opc                                          ; FC12C8  20 7f
	call T_Queue2E00_AppendRegs                          ; FC12CA  1d 3c 0f f4
	ld d, 0x03:opc                                          ; FC12CE  24 03
	ld e, 0x20:opc                                          ; FC12D0  25 20
	ld a, (0x76c5:16)                                   ; FC12D2  c1 c5 76 21
	ld w, 0xff:opc                                          ; FC12D6  20 ff
	call T_Queue2E00_AppendRegs                          ; FC12D8  1d 3c 0f f4
	ld d, 0x04:opc                                          ; FC12DC  24 04
	ld e, 0x20:opc                                          ; FC12DE  25 20
	ld a, (0x76c6:16)                                   ; FC12E0  c1 c6 76 21
	ld w, 0xff:opc                                          ; FC12E4  20 ff
	call T_Queue2E00_AppendRegs                          ; FC12E6  1d 3c 0f f4
	ld d, 0x05:opc                                          ; FC12EA  24 05
	ld e, 0x79:opc                                          ; FC12EC  25 79
	ld a, (0x78b7:16)                                   ; FC12EE  c1 b7 78 21
	ld w, 0xff:opc                                          ; FC12F2  20 ff
	call T_Queue2E00_AppendRegs                          ; FC12F4  1d 3c 0f f4
	ld d, 0x00:opc                                          ; FC12F8  24 00
	ld e, 0x60:opc                                          ; FC12FA  25 60
	ld a, (0x7634:16)                                   ; FC12FC  c1 34 76 21
	ld w, 0xff:opc                                          ; FC1300  20 ff
	call T_Queue2E00_AppendRegs                          ; FC1302  1d 3c 0f f4
	ld d, 0x00:opc                                          ; FC1306  24 00
	ld e, 0x61:opc                                          ; FC1308  25 61
	ld a, (0x7642:16)                                   ; FC130A  c1 42 76 21
	ld w, 0xff:opc                                          ; FC130E  20 ff
	call T_Queue2E00_AppendRegs                          ; FC1310  1d 3c 0f f4
	ld d, 0x00:opc                                          ; FC1314  24 00
	ld e, 0x62:opc                                          ; FC1316  25 62
	ld a, (0x7662:16)                                   ; FC1318  c1 62 76 21
	ld w, 0xff:opc                                          ; FC131C  20 ff
	call T_Queue2E00_AppendRegs                          ; FC131E  1d 3c 0f f4
	ld d, 0x00:opc                                          ; FC1322  24 00
	ld e, 0x63:opc                                          ; FC1324  25 63
	ld a, (0x7682:16)                                   ; FC1326  c1 82 76 21
	ld w, 0xff:opc                                          ; FC132A  20 ff
	call T_Queue2E00_AppendRegs                          ; FC132C  1d 3c 0f f4
	ret                                                  ; FC1330  0e
; Cpu2Query_ApplyToneRecordEffects: Twin of Cpu2Query_ApplyPartRecordEffects for the 0x46-byte 85/52 reply
;   (Cpu2Query_SendToneRecordRead52, used when PartSound_GetBankAndToneFlag sets bit 5): EFFECT2 ON/OFF := 0x7F, MAIN
;   OUT := 1, SUB OUT := 0, EFFECT1 SEND and REVERB SEND := 0x5A, then 0x78B7, 0x7634 and the three effect blocks from
;   the reply, with the same Queue2E00 events. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_a10.json)
Cpu2Query_ApplyToneRecordEffects:
	ld XIY,0x00000860                                    ; FC1331  45 60 08 00 00
	ld (CombiPart_Effect2OnOff:16), 0x7f                                 ; FC1336  f1 a8 76 00 7f
	ld (0x76c5:16), 0x01                                 ; FC133B  f1 c5 76 00 01
	ld (0x76c6:16), 0x00                                 ; FC1340  f1 c6 76 00 00
	ld a, 0x5a:opc                                          ; FC1345  21 5a
	ld (CombiPart_Effect1Send:16), a                                   ; FC1347  f1 a7 76 41
	ld a, 0x5a:opc                                          ; FC134B  21 5a
	ld (CombiPart_ReverbSend:16), a                                   ; FC134D  f1 a9 76 41
	ld a, (xiy+)                                      ; FC1351  c5 f4 21
	ld (0x78b7:16), a                                   ; FC1354  f1 b7 78 41
	ldw bc, 0x01                                         ; FC1358  31 01 00
	ld XIX,0x00007634                                    ; FC135B  44 34 76 00 00
	ldir85                                               ; FC1360  85 11
	ldw bc, 0x17                                         ; FC1362  31 17 00
	ld XIX,0x00007642                                    ; FC1365  44 42 76 00 00
	ldir85                                               ; FC136A  85 11
	ld (XIX),0x00                                        ; FC136C  b4 00 00
	ldw bc, 0x17                                         ; FC136F  31 17 00
	ld XIX,0x00007662                                    ; FC1372  44 62 76 00 00
	ldir85                                               ; FC1377  85 11
	ld (XIX),0x00                                        ; FC1379  b4 00 00
	ldw bc, 0x15                                         ; FC137C  31 15 00
	ld XIX,0x00007682                                    ; FC137F  44 82 76 00 00
	ldir85                                               ; FC1384  85 11
	ldw bc, 0x01                                         ; FC1386  31 01 00
	ld XIX,0x00007698                                    ; FC1389  44 98 76 00 00
	ldir85                                               ; FC138E  85 11
	ld (XIX),0x00                                        ; FC1390  b4 00 00
	ld d, 0x05:opc                                          ; FC1393  24 05
	ld e, 0x00:opc                                          ; FC1395  25 00
	ld a, (CombiPart_Effect1Send:16)                                   ; FC1397  c1 a7 76 21
	ld w, 0x7f:opc                                          ; FC139B  20 7f
	call T_Queue2E00_AppendRegs                          ; FC139D  1d 3c 0f f4
	ld d, 0x06:opc                                          ; FC13A1  24 06
	ld e, 0x00:opc                                          ; FC13A3  25 00
	ld a, (CombiPart_Effect2OnOff:16)                                   ; FC13A5  c1 a8 76 21
	ld w, 0x7f:opc                                          ; FC13A9  20 7f
	call T_Queue2E00_AppendRegs                          ; FC13AB  1d 3c 0f f4
	ld d, 0x07:opc                                          ; FC13AF  24 07
	ld e, 0x00:opc                                          ; FC13B1  25 00
	ld a, (CombiPart_ReverbSend:16)                                   ; FC13B3  c1 a9 76 21
	ld w, 0x7f:opc                                          ; FC13B7  20 7f
	call T_Queue2E00_AppendRegs                          ; FC13B9  1d 3c 0f f4
	ld d, 0x03:opc                                          ; FC13BD  24 03
	ld e, 0x20:opc                                          ; FC13BF  25 20
	ld a, (0x76c5:16)                                   ; FC13C1  c1 c5 76 21
	ld w, 0xff:opc                                          ; FC13C5  20 ff
	call T_Queue2E00_AppendRegs                          ; FC13C7  1d 3c 0f f4
	ld d, 0x04:opc                                          ; FC13CB  24 04
	ld e, 0x20:opc                                          ; FC13CD  25 20
	ld a, (0x76c6:16)                                   ; FC13CF  c1 c6 76 21
	ld w, 0xff:opc                                          ; FC13D3  20 ff
	call T_Queue2E00_AppendRegs                          ; FC13D5  1d 3c 0f f4
	ld d, 0x05:opc                                          ; FC13D9  24 05
	ld e, 0x79:opc                                          ; FC13DB  25 79
	ld a, (0x78b7:16)                                   ; FC13DD  c1 b7 78 21
	ld w, 0xff:opc                                          ; FC13E1  20 ff
	call T_Queue2E00_AppendRegs                          ; FC13E3  1d 3c 0f f4
	ld d, 0x00:opc                                          ; FC13E7  24 00
	ld e, 0x60:opc                                          ; FC13E9  25 60
	ld a, (0x7634:16)                                   ; FC13EB  c1 34 76 21
	ld w, 0xff:opc                                          ; FC13EF  20 ff
	call T_Queue2E00_AppendRegs                          ; FC13F1  1d 3c 0f f4
	ld d, 0x00:opc                                          ; FC13F5  24 00
	ld e, 0x61:opc                                          ; FC13F7  25 61
	ld a, (0x7642:16)                                   ; FC13F9  c1 42 76 21
	ld w, 0xff:opc                                          ; FC13FD  20 ff
	call T_Queue2E00_AppendRegs                          ; FC13FF  1d 3c 0f f4
	ld d, 0x00:opc                                          ; FC1403  24 00
	ld e, 0x62:opc                                          ; FC1405  25 62
	ld a, (0x7662:16)                                   ; FC1407  c1 62 76 21
	ld w, 0xff:opc                                          ; FC140B  20 ff
	call T_Queue2E00_AppendRegs                          ; FC140D  1d 3c 0f f4
	ld d, 0x00:opc                                          ; FC1411  24 00
	ld e, 0x63:opc                                          ; FC1413  25 63
	ld a, (0x7682:16)                                   ; FC1415  c1 82 76 21
	ld w, 0xff:opc                                          ; FC1419  20 ff
	call T_Queue2E00_AppendRegs                          ; FC141B  1d 3c 0f f4
	ret                                                  ; FC141F  0e
sub_FC1420:
	ld c, 0x00:opc                                          ; FC1420  23 00
	ld de, (0x0700:16)                                 ; FC1422  d1 00 07 22
.LFC1426:
	sra de, 0x01                                         ; FC1426  da ed 01
	jr nc, .LFC1434                                      ; FC1429  6f 09
	pushw de                                             ; FC142B  2a
	pushw bc                                             ; FC142C  29
	ld B,C                                               ; FC142D  cb 8a
	calr sub_FC145F                                      ; FC142F  1e 2d 00
	popw bc                                              ; FC1432  49
	popw de                                              ; FC1433  4a
.LFC1434:
	inc 1,C                                              ; FC1434  cb 61
	cp C,0x10                                            ; FC1436  cb cf 10
	jr nc, .LFC143D                                      ; FC1439  6f 02
	jr .LFC1426                                          ; FC143B  68 e9
.LFC143D:
	ret                                                  ; FC143D  0e
sub_FC143E:
	ld c, 0x00:opc                                          ; FC143E  23 00
	ld de, (0x0702:16)                                 ; FC1440  d1 02 07 22
.LFC1444:
	sra de, 0x01                                         ; FC1444  da ed 01
	jr nc, .LFC1455                                      ; FC1447  6f 0c
	pushw de                                             ; FC1449  2a
	pushw bc                                             ; FC144A  29
	ld B,C                                               ; FC144B  cb 8a
	add B,0x10                                           ; FC144D  ca c8 10
	calr sub_FC145F                                      ; FC1450  1e 0c 00
	popw bc                                              ; FC1453  49
	popw de                                              ; FC1454  4a
.LFC1455:
	inc 1,C                                              ; FC1455  cb 61
	cp C,0x10                                            ; FC1457  cb cf 10
	jr nc, .LFC145E                                      ; FC145A  6f 02
	jr .LFC1444                                          ; FC145C  68 e6
.LFC145E:
	ret                                                  ; FC145E  0e
sub_FC145F:
	ld W,B                                               ; FC145F  ca 88
	call PartSound_GetBankAndToneFlag                                      ; FC1461  1d 19 11 fc
	bit 0x05,A                                           ; FC1465  c9 33 05
	jr nz, .LFC1470                                      ; FC1468  6e 06
	call sub_FC1F97                                      ; FC146A  1d 97 1f fc
	jr .LFC1474                                          ; FC146E  68 04
.LFC1470:
	call sub_FC1FBF                                      ; FC1470  1d bf 1f fc
.LFC1474:
	ret                                                  ; FC1474  0e
; Cpu2Query_ApplyCreatorSelectBits: (B = part) For an 81/23 or 85/20 reply (two bytes, already & 0x3F): byte 0 -> part
;   B's second record +0x1A, byte 1 -> +0x19 -- the creator-select bit masks CreatorSelectController_LoadNames reads
;   ((0x2870) = 0 -> +0x1A, 1 -> +0x19) -- each stored and posted {0x20 + B, 0x1A / 0x19, value, 0x3F} to Queue2E00
;   only when it changed. Basis: caller + body + reader. (notes/naming-pilot-2026-10-06/proposals_wave10_a10.json)
Cpu2Query_ApplyCreatorSelectBits:
	ld XIY,0x00000860                                    ; FC1475  45 60 08 00 00
	ld E,B                                               ; FC147A  ca 8d
	add E,0x20                                           ; FC147C  cd c8 20
	push XIY                                             ; FC147F  3d
	ld W,B                                               ; FC1480  ca 88
	calr Msg0716_GetRecordPtrByIndex                                          ; FC1482  1e c9 fc
	ld XIX,XIY                                           ; FC1485  ed 8c
	pop XIY                                              ; FC1487  5d
	push XIX                                             ; FC1488  3c
	ld a, (xiy+)                                      ; FC1489  c5 f4 21
	add XIX,0x0000001a                                   ; FC148C  ec c8 1a 00 00 00
	add XIX,0x00000020                                   ; FC1492  ec c8 20 00 00 00
	cp A,(XIX)                                           ; FC1498  84 f1
	jr z, .LFC14A8                                       ; FC149A  66 0c
	ld (XIX),A                                           ; FC149C  b4 41
	ld d, 0x1a:opc                                          ; FC149E  24 1a
	ld w, 0x3f:opc                                          ; FC14A0  20 3f
	push XIY                                             ; FC14A2  3d
	call T_Queue2E00_AppendRegs                          ; FC14A3  1d 3c 0f f4
	pop XIY                                              ; FC14A7  5d
.LFC14A8:
	pop XIX                                              ; FC14A8  5c
	ld A,(XIY)                                           ; FC14A9  85 21
	add XIX,0x00000019                                   ; FC14AB  ec c8 19 00 00 00
	add XIX,0x00000020                                   ; FC14B1  ec c8 20 00 00 00
	cp A,(XIX)                                           ; FC14B7  84 f1
	jr z, .LFC14C5                                       ; FC14B9  66 0a
	ld (XIX),A                                           ; FC14BB  b4 41
	ld d, 0x19:opc                                          ; FC14BD  24 19
	ld w, 0x3f:opc                                          ; FC14BF  20 3f
	call T_Queue2E00_AppendRegs                          ; FC14C1  1d 3c 0f f4
.LFC14C5:
	ret                                                  ; FC14C5  0e
; SoundMode_ResetLvl: Unless already 0: (0x0710) := 0 -- SOUND MODE's LVL offset, which SoundMode_StepLvl steps within
;   -30..+30 -- and posts {0xA8, 0x12, 0, 0xFF} to Queue2E00. Msg0716_FlushPending runs it when part 0's program
;   change is pending ((0x0700) bit 0). Basis: caller + body + the field's stepper. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
SoundMode_ResetLvl:
	cp	(0x0710:16), 0x00                            ; FC14C6  c1 10 07 3f 00
	jr z, .LFC14DE                                       ; FC14CB  66 11
	ld (0x0710:16), 0x00                                 ; FC14CD  f1 10 07 00 00
	ld e, 0xa8:opc                                          ; FC14D2  25 a8
	ld d, 0x12:opc                                          ; FC14D4  24 12
	ld a, 0x00:opc                                          ; FC14D6  21 00
	ld w, 0xff:opc                                          ; FC14D8  20 ff
	call T_Queue2E00_AppendRegs                          ; FC14DA  1d 3c 0f f4
.LFC14DE:
	ret                                                  ; FC14DE  0e
; SoundMode_ResetPan: Unless already 0x40: (0x0711) := 0x40 (centre) -- SOUND MODE's PAN, which SoundMode_StepPan
;   steps within 0..127 -- and posts {0xA8, 0x13, 0x40, 0xFF} to Queue2E00. Msg0716_FlushPending runs it when part 0's
;   program change is pending ((0x0700) bit 0). Basis: caller + body + the field's stepper. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
SoundMode_ResetPan:
	cp	(0x0711:16), 0x40                            ; FC14DF  c1 11 07 3f 40
	jr z, .LFC14F7                                       ; FC14E4  66 11
	ld (0x0711:16), 0x40                                 ; FC14E6  f1 11 07 00 40
	ld e, 0xa8:opc                                          ; FC14EB  25 a8
	ld d, 0x13:opc                                          ; FC14ED  24 13
	ld a, 0x40:opc                                          ; FC14EF  21 40
	ld w, 0xff:opc                                          ; FC14F1  20 ff
	call T_Queue2E00_AppendRegs                          ; FC14F3  1d 3c 0f f4
.LFC14F7:
	ret                                                  ; FC14F7  0e
; ModeScreen_ResetOct: Unless (0x78B2) & 0x7F is already 0x40: (0x78B2) := its bit 7 | 0x40 and posts {0x79, 0, 0x40,
;   0x7F} to Queue2E00 -- the OCT value SoftKeyCol1_Oct steps (0x1C..0x64) on SOUND MODE and COMBINATION page 1.
;   Msg0716_FlushPending runs it for a pending part-0 program change when (0x7F02) & 0xF0 is 0 and (0x60F021) bit 5 is
;   clear. Basis: caller + body + the field's stepper. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
ModeScreen_ResetOct:
	ld a, (0x78b2:16)                                   ; FC14F8  c1 b2 78 21
	and A,0x7f                                           ; FC14FC  c9 cc 7f
	cp A,0x40                                            ; FC14FF  c9 cf 40
	jr z, .LFC151A                                       ; FC1502  66 16
	and	(0x78b2:16), 0x80                            ; FC1504  c1 b2 78 3c 80
	or	(0x78b2:16), 0x40                            ; FC1509  c1 b2 78 3e 40
	ld e, 0x79:opc                                          ; FC150E  25 79
	ld d, 0x00:opc                                          ; FC1510  24 00
	ld a, 0x40:opc                                          ; FC1512  21 40
	ld w, 0x7f:opc                                          ; FC1514  20 7f
	call T_Queue2E00_AppendRegs                          ; FC1516  1d 3c 0f f4
.LFC151A:
	ret                                                  ; FC151A  0e
; ---------------------------------------------------------------------
; Msg0716_PostCC07_Volume -- REFUSED A NAME, and this is the reason.
; ⚠ SUPERSEDED 2026-10-04: the receiver, prom_c MidiCtrl_Dispatch, reads byte [2] as the MIDI controller
;   number (numbers below 0x80 are MIDI's; >= 0x80 its own MidiCtrl_IntXX) -- notes/prom_a_msg0716_message_names.py.
;
; It is one of a family of 0xFC0000-module handlers that write 0xB0 to
; (XIX), a selector to (XIX+0x02) and (0x20B9) masked by C to
; (XIX+0x03), then post four bytes: 0xFC151B/0xFC15E1/0xFC1679 use
; selectors 0x07, 0x97 and 0x0B with masks 0x7F, 0x07 and 0xFF. 0xB0
; invites reading the selector as a MIDI controller number and the round
; REFUSES to, because 0x97 is 151 and no MIDI controller number exceeds
; 0x7F. So field +2 is not a controller number,
; notes/FINDINGS-prom_a-msg0716-module.md states that no handler's
; meaning is established, and a name here would claim one. The measured
; fact -- three selectors, three masks, one shared sender at 0xFC18CC --
; is worth more than the name would be.
; Refused by notes/prom_a_census_round8.py: `sub_XXXXXX` plus a
; stated gap is worth more than a plausible guess.
; ---------------------------------------------------------------------
; Msg0716_PostCC07_Volume: posts B0 <part> 07 <value> to CPU 2 -- controller 0x07 (MIDI Volume), value through Msg0716_PostValueMasked with limit 0x7F
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC07_Volume:
	ld (XIX),0xb0                                        ; FC151B  b4 00 b0
	ld (XIX+0x02),0x07                                   ; FC151E  bc 02 00 07
	ld c, 0x7f:opc                                          ; FC1522  23 7f
	calr Msg0716_PostValueMasked                                      ; FC1524  1e a5 03
	ret                                                  ; FC1527  0e
; Msg0716_PostCC07_VolumeFromA: B0 <part> 07 <A AND 0x7F>, or 0 when A bit 7 is set.
Msg0716_PostCC07_VolumeFromA:
	ld (XIX),0xb0                                        ; FC1528  b4 00 b0
	ld (XIX+0x02),0x07                                   ; FC152B  bc 02 00 07
	ld (XIX+0x03),0x00                                   ; FC152F  bc 03 00 00
	bit 0x07,A                                           ; FC1533  c9 33 07
	jr nz, .LFC153E                                      ; FC1536  6e 06
	and A,0x7f                                           ; FC1538  c9 cc 7f
	ld (XIX+0x03),A                                      ; FC153B  bc 03 41
.LFC153E:
	ldw bc, 0x04                                         ; FC153E  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1541  1e d6 04
	ret                                                  ; FC1544  0e
; Msg0716_PostCC07_VolumeWithOffset: B0 <part> 07 <A + (0x0710)>, clamped to 0..0x7F (0x7F when it overflows and (0x7F4D) bit 2); A bit 7 set = value 0.
Msg0716_PostCC07_VolumeWithOffset:
	ld (XIX),0xb0                                        ; FC1545  b4 00 b0
	ld (XIX+0x02),0x07                                   ; FC1548  bc 02 00 07
	ld (XIX+0x03),0x00                                   ; FC154C  bc 03 00 00
	bit 0x07,A                                           ; FC1550  c9 33 07
	jr nz, .LFC157A                                      ; FC1553  6e 25
	and A,0x7f                                           ; FC1555  c9 cc 7f
	cp	(0x0710:16), 0x00                            ; FC1558  c1 10 07 3f 00
	jr mi, .LFC156F                                      ; FC155D  65 10
	add a, (0x0710:16)                                   ; FC155F  c1 10 07 81
	jr pl, .LFC1577                                      ; FC1563  6d 12
	bit	2, (0x7f4d:16)                               ; FC1565  f1 4d 7f ca
	jr z, .LFC1577                                       ; FC1569  66 0c
	ld a, 0x7f:opc                                          ; FC156B  21 7f
	jr .LFC1577                                          ; FC156D  68 08
.LFC156F:
	add a, (0x0710:16)                                   ; FC156F  c1 10 07 81
	jr pl, .LFC1577                                      ; FC1573  6d 02
	ld a, 0x00:opc                                          ; FC1575  21 00
.LFC1577:
	ld (XIX+0x03),A                                      ; FC1577  bc 03 41
.LFC157A:
	ldw bc, 0x04                                         ; FC157A  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC157D  1e 9a 04
	ret                                                  ; FC1580  0e
; Msg0716_PostCC5D_Effect3Depth: posts B0 <part> 5D <value> to CPU 2 -- controller 0x5D (MIDI Effect3Depth), value through Msg0716_PostValueMasked with limit 0x7F
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC5D_Effect3Depth:
	ld (XIX),0xb0                                        ; FC1581  b4 00 b0
	ld (XIX+0x02),0x5d                                   ; FC1584  bc 02 00 5d
	ld c, 0x7f:opc                                          ; FC1588  23 7f
	calr Msg0716_PostValueMasked                                      ; FC158A  1e 3f 03
	ret                                                  ; FC158D  0e
; Msg0716_PostCC5B_Effect1Depth: posts B0 <part> 5B <value> to CPU 2 -- controller 0x5B (MIDI Effect1Depth), value through Msg0716_PostValueMasked with limit 0x7F
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC5B_Effect1Depth:
	ld (XIX),0xb0                                        ; FC158E  b4 00 b0
	ld (XIX+0x02),0x5b                                   ; FC1591  bc 02 00 5b
	ld c, 0x7f:opc                                          ; FC1595  23 7f
	calr Msg0716_PostValueMasked                                      ; FC1597  1e 32 03
	ret                                                  ; FC159A  0e
	ret                                                  ; FC159B  0e
; Msg0716_PostCtrlInt9C: B0 <part> 9C <0x7F if UiEvent_Byte2 bit 3 else 0>: the receiver's extension controller 0x9C as a switch.
Msg0716_PostCtrlInt9C:
	ld (XIX),0xb0                                        ; FC159C  b4 00 b0
	ld (XIX+0x02),0x9c                                   ; FC159F  bc 02 00 9c
	ld (XIX+0x03),0x00                                   ; FC15A3  bc 03 00 00
	bit	3, (UiEvent_Byte2:16)                               ; FC15A7  f1 b9 20 cb
	jr z, .LFC15B1                                       ; FC15AB  66 04
	ld (XIX+0x03),0x7f                                   ; FC15AD  bc 03 00 7f
.LFC15B1:
	ldw bc, 0x04                                         ; FC15B1  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC15B4  1e 63 04
	ret                                                  ; FC15B7  0e
; Msg0716_PostCC40_Sustain: posts B0 <part> 40 <value> to CPU 2 -- controller 0x40 (MIDI Sustain), value through Msg0716_PostValueAsSwitch with limit 0x08
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC40_Sustain:
	ld (XIX),0xb0                                        ; FC15B8  b4 00 b0
	ld (XIX+0x02),0x40                                   ; FC15BB  bc 02 00 40
	ld c, 0x08:opc                                          ; FC15BF  23 08
	calr Msg0716_PostValueAsSwitch                                      ; FC15C1  1e 18 03
	ret                                                  ; FC15C4  0e
; Msg0716_PostCC40_SustainFromValue: B0 <part> 40 <0x7F if UiEvent_Byte2 >= 0x40 else 0> -- MIDI's sustain threshold.
Msg0716_PostCC40_SustainFromValue:
	ld (XIX),0xb0                                        ; FC15C5  b4 00 b0
	ld (XIX+0x02),0x40                                   ; FC15C8  bc 02 00 40
	ld a, 0x00:opc                                          ; FC15CC  21 00
	cp	(UiEvent_Byte2:16), 0x40                            ; FC15CE  c1 b9 20 3f 40
	jr c, .LFC15D7                                       ; FC15D3  67 02
	ld a, 0x7f:opc                                          ; FC15D5  21 7f
.LFC15D7:
	ld (XIX+0x03),A                                      ; FC15D7  bc 03 41
	ldw bc, 0x04                                         ; FC15DA  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC15DD  1e 3a 04
	ret                                                  ; FC15E0  0e
; Msg0716_PostCtrlInt97: posts B0 <part> 97 <value> to CPU 2 -- controller 0x97 (not a MIDI number; the receiver's MidiCtrl_Int97), value through Msg0716_PostValueMasked with limit 0x07
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCtrlInt97:
	ld (XIX),0xb0                                        ; FC15E1  b4 00 b0
	ld (XIX+0x02),0x97                                   ; FC15E4  bc 02 00 97
	ld c, 0x07:opc                                          ; FC15E8  23 07
	calr Msg0716_PostValueMasked                                      ; FC15EA  1e df 02
	ret                                                  ; FC15ED  0e
	ld (XIX),0xb0                                        ; FC15EE  b4 00 b0
	ld (XIX+0x02),0x43                                   ; FC15F1  bc 02 00 43
	ld c, 0xff:opc                                          ; FC15F5  23 ff
	calr Msg0716_PostValueMasked                                      ; FC15F7  1e d2 02
	ret                                                  ; FC15FA  0e
	ld (XIX),0xb0                                        ; FC15FB  b4 00 b0
	ld (XIX+0x02),0x42                                   ; FC15FE  bc 02 00 42
	ld c, 0xff:opc                                          ; FC1602  23 ff
	calr Msg0716_PostValueMasked                                      ; FC1604  1e c5 02
	ret                                                  ; FC1607  0e
; Msg0716_PostCC0A_Pan: B0 <part> 0A <UiEvent_Byte2>, controller 10 pan (was Msg0716_Post_Trampoline_Wrap, a positional name; 2026-10-04).
Msg0716_PostCC0A_Pan:
	ld (XIX),0xb0                                        ; FC1608  b4 00 b0
	ld (XIX+0x02),0x0a                                   ; FC160B  bc 02 00 0a
	ld a, (UiEvent_Byte2:16)                                   ; FC160F  c1 b9 20 21
	ld (XIX+0x03),A                                      ; FC1613  bc 03 41
	ldw bc, 0x04                                         ; FC1616  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1619  1e fe 03
	ret                                                  ; FC161C  0e
; Msg0716_PostCC0A_PanWithOffset: B0 <part> 0A <A + (0x0711) - 0x40>, clamped to 0..0x7F (controller 10, pan, which the receiver handles).
Msg0716_PostCC0A_PanWithOffset:
	ld (XIX),0xb0                                        ; FC161D  b4 00 b0
	ld (XIX+0x02),0x0a                                   ; FC1620  bc 02 00 0a
	ld w, (0x0711:16)                                   ; FC1624  c1 11 07 20
	sub W,0x40                                           ; FC1628  c8 ca 40
	jr mi, .LFC1635                                      ; FC162B  65 08
	add A,W                                              ; FC162D  c8 81
	jr pl, .LFC163B                                      ; FC162F  6d 0a
	ld a, 0x7f:opc                                          ; FC1631  21 7f
	jr .LFC163B                                          ; FC1633  68 06
.LFC1635:
	add A,W                                              ; FC1635  c8 81
	jr pl, .LFC163B                                      ; FC1637  6d 02
	ld a, 0x00:opc                                          ; FC1639  21 00
.LFC163B:
	ld (XIX+0x03),A                                      ; FC163B  bc 03 41
	ldw bc, 0x04                                         ; FC163E  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1641  1e d6 03
	ret                                                  ; FC1644  0e
; Msg0716_PostCtrlInt80: posts B0 <part> 80 <value> to CPU 2 -- controller 0x80 (not a MIDI number; the receiver's MidiCtrl_Int80), value through Msg0716_PostValueClamped with limit 0x0C
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCtrlInt80:
	ld (XIX),0xb0                                        ; FC1645  b4 00 b0
	ld (XIX+0x02),0x80                                   ; FC1648  bc 02 00 80
	ld c, 0x0c:opc                                          ; FC164C  23 0c
	calr Msg0716_PostValueClamped                                      ; FC164E  1e a6 02
	ret                                                  ; FC1651  0e
; Msg0716_PostCtrlInt81: posts B0 <part> 81 <value> to CPU 2 -- controller 0x81 (not a MIDI number; the receiver's MidiCtrl_Int81), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCtrlInt81:
	ld (XIX),0xb0                                        ; FC1652  b4 00 b0
	ld (XIX+0x02),0x81                                   ; FC1655  bc 02 00 81
	ld c, 0xff:opc                                          ; FC1659  23 ff
	calr Msg0716_PostValueMasked                                      ; FC165B  1e 6e 02
	ret                                                  ; FC165E  0e
; Msg0716_PostCtrlInt82: posts B0 <part> 82 <value> to CPU 2 -- controller 0x82 (not a MIDI number; the receiver's MidiCtrl_Int82), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCtrlInt82:
	ld (XIX),0xb0                                        ; FC165F  b4 00 b0
	ld (XIX+0x02),0x82                                   ; FC1662  bc 02 00 82
	ld c, 0xff:opc                                          ; FC1666  23 ff
	calr Msg0716_PostValueMasked                                      ; FC1668  1e 61 02
	ret                                                  ; FC166B  0e
; Msg0716_PostCC01_Modulation: posts B0 <part> 01 <value> to CPU 2 -- controller 0x01 (MIDI Modulation), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC01_Modulation:
	ld (XIX),0xb0                                        ; FC166C  b4 00 b0
	ld (XIX+0x02),0x01                                   ; FC166F  bc 02 00 01
	ld c, 0xff:opc                                          ; FC1673  23 ff
	calr Msg0716_PostValueMasked                                      ; FC1675  1e 54 02
	ret                                                  ; FC1678  0e
; Msg0716_PostCC0B_Expression: posts B0 <part> 0B <value> to CPU 2 -- controller 0x0B (MIDI Expression), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC0B_Expression:
	ld (XIX),0xb0                                        ; FC1679  b4 00 b0
	ld (XIX+0x02),0x0b                                   ; FC167C  bc 02 00 0b
	ld c, 0xff:opc                                          ; FC1680  23 ff
	calr Msg0716_PostValueMasked                                      ; FC1682  1e 47 02
	ret                                                  ; FC1685  0e
; Msg0716_PostCC10_GeneralPurpose1: posts B0 <part> 10 <value> to CPU 2 -- controller 0x10 (MIDI GeneralPurpose1), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC10_GeneralPurpose1:
	ld (XIX),0xb0                                        ; FC1686  b4 00 b0
	ld (XIX+0x02),0x10                                   ; FC1689  bc 02 00 10
	ld c, 0xff:opc                                          ; FC168D  23 ff
	calr Msg0716_PostValueMasked                                      ; FC168F  1e 3a 02
	ret                                                  ; FC1692  0e
; Msg0716_PostCC11_GeneralPurpose2: posts B0 <part> 11 <value> to CPU 2 -- controller 0x11 (MIDI GeneralPurpose2), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC11_GeneralPurpose2:
	ld (XIX),0xb0                                        ; FC1693  b4 00 b0
	ld (XIX+0x02),0x11                                   ; FC1696  bc 02 00 11
	ld c, 0xff:opc                                          ; FC169A  23 ff
	calr Msg0716_PostValueMasked                                      ; FC169C  1e 2d 02
	ret                                                  ; FC169F  0e
; Msg0716_PostCC12_GeneralPurpose3: posts B0 <part> 12 <value> to CPU 2 -- controller 0x12 (MIDI GeneralPurpose3), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC12_GeneralPurpose3:
	ld (XIX),0xb0                                        ; FC16A0  b4 00 b0
	ld (XIX+0x02),0x12                                   ; FC16A3  bc 02 00 12
	ld c, 0xff:opc                                          ; FC16A7  23 ff
	calr Msg0716_PostValueMasked                                      ; FC16A9  1e 20 02
	ret                                                  ; FC16AC  0e
; Msg0716_PostCC13_GeneralPurpose4: posts B0 <part> 13 <value> to CPU 2 -- controller 0x13 (MIDI GeneralPurpose4), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC13_GeneralPurpose4:
	ld (XIX),0xb0                                        ; FC16AD  b4 00 b0
	ld (XIX+0x02),0x13                                   ; FC16B0  bc 02 00 13
	ld c, 0xff:opc                                          ; FC16B4  23 ff
	calr Msg0716_PostValueMasked                                      ; FC16B6  1e 13 02
	ret                                                  ; FC16B9  0e
; Msg0716_PostCC02_Breath: posts B0 <part> 02 <value> to CPU 2 -- controller 0x02 (MIDI Breath), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC02_Breath:
	ld (XIX),0xb0                                        ; FC16BA  b4 00 b0
	ld (XIX+0x02),0x02                                   ; FC16BD  bc 02 00 02
	ld c, 0xff:opc                                          ; FC16C1  23 ff
	calr Msg0716_PostValueMasked                                      ; FC16C3  1e 06 02
	ret                                                  ; FC16C6  0e
; Msg0716_PostCC04_Foot: posts B0 <part> 04 <value> to CPU 2 -- controller 0x04 (MIDI Foot), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCC04_Foot:
	ld (XIX),0xb0                                        ; FC16C7  b4 00 b0
	ld (XIX+0x02),0x04                                   ; FC16CA  bc 02 00 04
	ld c, 0xff:opc                                          ; FC16CE  23 ff
	calr Msg0716_PostValueMasked                                      ; FC16D0  1e f9 01
	ret                                                  ; FC16D3  0e
; Msg0716_PostCtrlInt9A: posts B0 <part> 9A <value> to CPU 2 -- controller 0x9A (not a MIDI number; the receiver's MidiCtrl_Int9A), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCtrlInt9A:
	ld (XIX),0xb0                                        ; FC16D4  b4 00 b0
	ld (XIX+0x02),0x9a                                   ; FC16D7  bc 02 00 9a
	ld c, 0xff:opc                                          ; FC16DB  23 ff
	calr Msg0716_PostValueMasked                                      ; FC16DD  1e ec 01
	ret                                                  ; FC16E0  0e
; Msg0716_PostCtrlInt99: posts B0 <part> 99 <value> to CPU 2 -- controller 0x99 (not a MIDI number; the receiver's MidiCtrl_Int99), value through Msg0716_PostValueMasked with limit 0xFF
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostCtrlInt99:
	ld (XIX),0xb0                                        ; FC16E1  b4 00 b0
	ld (XIX+0x02),0x99                                   ; FC16E4  bc 02 00 99
	ld c, 0xff:opc                                          ; FC16E8  23 ff
	calr Msg0716_PostValueMasked                                      ; FC16EA  1e df 01
	ret                                                  ; FC16ED  0e
; Msg0716_PostCC78_AllSoundOff: B0 <part> 78 00, controller 120 All Sound Off, which the receiver handles as MidiCtrl_CC120
;   (it was Msg0716_Post_Trampoline_4, a name for its position; 2026-10-04).
Msg0716_PostCC78_AllSoundOff:
	ld (XIX),0xb0                                        ; FC16EE  b4 00 b0
	ld (XIX+0x02),0x78                                   ; FC16F1  bc 02 00 78
	ld (XIX+0x03),0x00                                   ; FC16F5  bc 03 00 00
	ldw bc, 0x04                                         ; FC16F9  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC16FC  1e 1b 03
	ret                                                  ; FC16FF  0e
; Msg0716_PostChannelPressure: posts D0 <part> 00 <value> (MIDI Channel Pressure) to CPU 2, value through Msg0716_PostValueMasked
;   (notes/prom_a_msg0716_message_names.py).
Msg0716_PostChannelPressure:
	ld (XIX),0xd0                                        ; FC1700  b4 00 d0
	ld (XIX+0x02),0x00                                   ; FC1703  bc 02 00 00
	ld c, 0xff:opc                                          ; FC1707  23 ff
	calr Msg0716_PostValueMasked                                      ; FC1709  1e c0 01
	ret                                                  ; FC170C  0e
; Msg0716_PostPitchBend: E0 <part> <UiEvent_Byte2> <UiEvent_Byte3>, four bytes: MIDI pitch bend, LSB then MSB.
Msg0716_PostPitchBend:
	ld (XIX),0xe0                                        ; FC170D  b4 00 e0
	ld a, (UiEvent_Byte2:16)                                   ; FC1710  c1 b9 20 21
	ld (XIX+0x02),A                                      ; FC1714  bc 02 41
	ld a, (UiEvent_Byte3:16)                                   ; FC1717  c1 ba 20 21
	ld (XIX+0x03),A                                      ; FC171B  bc 03 41
	ldw bc, 0x04                                         ; FC171E  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1721  1e f6 02
	ret                                                  ; FC1724  0e
	ret                                                  ; FC1725  0e
; Msg0716_PostCtrlInt9B: B0 <part> 9B <value from the part's record (Msg0716_RecordPtrTable[(XIZ+6)] and 0x76C2 + its offset)>.
Msg0716_PostCtrlInt9B:
	ld (XIX),0xb0                                        ; FC1726  b4 00 b0
	ld (XIX+0x02),0x9b                                   ; FC1729  bc 02 00 9b
	push XIY                                             ; FC172D  3d
	pushw de                                             ; FC172E  2a
	ld E,(XIZ+0x06)                                      ; FC172F  8e 06 25
	xor D,D                                              ; FC1732  cc d4
	sla de, 0x02                                         ; FC1734  da ec 02
	ld XIY,Msg0716_RecordPtrTable                        ; FC1737  45 62 11 fc 00
	ld	xiy, (xiy+de)                                ; FC173C  e3 07 f4 e8 25
	ld D,(XIY+0x06)                                      ; FC1741  8d 06 24
	cp d, 0x00:i3                                          ; FC1744  cc d8
	jr nz, .LFC174C                                      ; FC1746  6e 04
	ld d, 0x00:opc                                          ; FC1748  24 00
	jr .LFC174E                                          ; FC174A  68 02
.LFC174C:
	ld d, 0x05:opc                                          ; FC174C  24 05
.LFC174E:
	sub XIY,0x000076a2                                   ; FC174E  ed ca a2 76 00 00
	add XIY,0x000076c2                                   ; FC1754  ed c8 c2 76 00 00
	ld A,(XIY+0x03)                                      ; FC175A  8d 03 21
	ld W,(XIY+0x04)                                      ; FC175D  8d 04 20
	cp d, 0x00:i3                                          ; FC1760  cc d8
	jr z, .LFC1776                                       ; FC1762  66 12
	cp a, 0x00:i3                                          ; FC1764  c9 d8
	jr nz, .LFC176C                                      ; FC1766  6e 04
	ld A,D                                               ; FC1768  cc 89
	jr .LFC1776                                          ; FC176A  68 0a
.LFC176C:
	cp w, 0x00:i3                                          ; FC176C  c8 d8
	jr nz, .LFC1774                                      ; FC176E  6e 04
	ld W,D                                               ; FC1770  cc 88
	jr .LFC1776                                          ; FC1772  68 02
.LFC1774:
	ld A,D                                               ; FC1774  cc 89
.LFC1776:
	sla w, 0x04                                          ; FC1776  c8 ec 04
	or A,W                                               ; FC1779  c8 e1
	popw de                                              ; FC177B  4a
	pop XIY                                              ; FC177C  5d
	ld (XIX+0x03),A                                      ; FC177D  bc 03 41
	ldw bc, 0x04                                         ; FC1780  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1783  1e 94 02
	ret                                                  ; FC1786  0e
Msg0716_PostCtrlInt9B_Nop:
	ret                                                  ; FC1787  0e
	ret                                                  ; FC1788  0e
	ret                                                  ; FC1789  0e
	ret                                                  ; FC178A  0e
; Msg0716_PostSysEx50_81: posts F0 50 81 ... to CPU 2 -- a system-exclusive message, manufacturer ID 0x50 (Matsushita),
;   command 0x81, whose meaning is not established here (notes/prom_a_msg0716_message_names.py).
Msg0716_PostSysEx50_81:
	ld (XIX),0xf0                                        ; FC178B  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC178E  bc 01 00 50
	ld (XIX+0x02),0x81                                   ; FC1792  bc 02 00 81
	ld c, 0xff:opc                                          ; FC1796  23 ff
	calr Msg0716_PostValueMasked                                      ; FC1798  1e 31 01
; (sub_FC179B removed 2026-10-04: no code names it and the line above falls through into it -- part of Msg0716_PostSysEx50_81;
;  notes/prom_a_stray_label_removal.py)
	ret                                                  ; FC179B  0e
; Msg0716_PostSysEx50_80: posts F0 50 80 ... to CPU 2 -- a system-exclusive message, manufacturer ID 0x50 (Matsushita),
;   command 0x80, whose meaning is not established here (notes/prom_a_msg0716_message_names.py).
Msg0716_PostSysEx50_80:
	ld (XIX),0xf0                                        ; FC179C  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC179F  bc 01 00 50
	ld (XIX+0x02),0x80                                   ; FC17A3  bc 02 00 80
	ld c, 0xff:opc                                          ; FC17A7  23 ff
	calr Msg0716_PostValueMasked                                      ; FC17A9  1e 20 01
	ret                                                  ; FC17AC  0e
	ret                                                  ; FC17AD  0e
; Msg0716_PostSysEx50_82: posts F0 50 82 ... to CPU 2 -- a system-exclusive message, manufacturer ID 0x50 (Matsushita),
;   command 0x82, whose meaning is not established here (notes/prom_a_msg0716_message_names.py).
Msg0716_PostSysEx50_82:
	ld (XIX),0xf0                                        ; FC17AE  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC17B1  bc 01 00 50
	ld (XIX+0x02),0x82                                   ; FC17B5  bc 02 00 82
	ld a, (UiEvent_Byte2:16)                                   ; FC17B9  c1 b9 20 21
	and A,0xff                                           ; FC17BD  c9 cc ff
	add A,0x40                                           ; FC17C0  c9 c8 40
	ld (XIX+0x03),A                                      ; FC17C3  bc 03 41
	ldw bc, 0x04                                         ; FC17C6  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC17C9  1e 4e 02
	ret                                                  ; FC17CC  0e
; Msg0716_PostSysEx50_86: posts F0 50 86 ... to CPU 2 -- a system-exclusive message, manufacturer ID 0x50 (Matsushita),
;   command 0x86, whose meaning is not established here (notes/prom_a_msg0716_message_names.py).
Msg0716_PostSysEx50_86:
	ld (XIX),0xf0                                        ; FC17CD  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC17D0  bc 01 00 50
	ld (XIX+0x02),0x86                                   ; FC17D4  bc 02 00 86
	ld c, 0xff:opc                                          ; FC17D8  23 ff
	calr Msg0716_PostValueMasked                                      ; FC17DA  1e ef 00
	ret                                                  ; FC17DD  0e
	ret                                                  ; FC17DE  0e
; ScaleTuning_PostPitchClassOffset: Completes the 0x0716 message F0 50 <0xA4 + pitch class> <offset>, pitch class =
;   (semitone + (0x78A3) & 0x0F) mod 12, and posts its 4 bytes to CPU 2, whose arms 0xA4..0xAF store the user-scale
;   detune of pitch class 0..11. The sender of both ScaleTuning_PostSemitone* routines. Basis: callers + body + CPU-2
;   arms. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
ScaleTuning_PostPitchClassOffset:
	ld (XIX),0xf0                                        ; FC17DF  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC17E2  bc 01 00 50
	ld a, (0x78a3:16)                                   ; FC17E6  c1 a3 78 21
	and A,0x0f                                           ; FC17EA  c9 cc 0f
	add A,(XIX+0x02)                                     ; FC17ED  8c 02 81
	cp A,0x0c                                            ; FC17F0  c9 cf 0c
	jr c, .LFC17F8                                       ; FC17F3  67 03
	sub A,0x0c                                           ; FC17F5  c9 ca 0c
.LFC17F8:
	add A,0xa4                                           ; FC17F8  c9 c8 a4
	ld (XIX+0x02),A                                      ; FC17FB  bc 02 41
	ldw bc, 0x04                                         ; FC17FE  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1801  1e 16 02
	ret                                                  ; FC1804  0e
; Msg0716_PostSysEx50_B1: posts F0 50 B1 ... to CPU 2 -- a system-exclusive message, manufacturer ID 0x50 (Matsushita),
;   command 0xB1, whose meaning is not established here (notes/prom_a_msg0716_message_names.py).
Msg0716_PostSysEx50_B1:
	ld (XIX),0xf0                                        ; FC1805  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC1808  bc 01 00 50
	ld (XIX+0x02),0xb1                                   ; FC180C  bc 02 00 b1
	ld c, 0x80:opc                                          ; FC1810  23 80
	calr Msg0716_PostValueAsSwitch                                      ; FC1812  1e c7 00
	ret                                                  ; FC1815  0e
; Msg0716_PostSysEx50_B2: F0 50 B2 <(0x78B7)>, the Matsushita system-exclusive command 0xB2 (was Msg0716_Post_Trampoline_Wrap_2).
Msg0716_PostSysEx50_B2:
	ld (XIX),0xf0                                        ; FC1816  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC1819  bc 01 00 50
	ld (XIX+0x02),0xb2                                   ; FC181D  bc 02 00 b2
	ld a, (0x78b7:16)                                   ; FC1821  c1 b7 78 21
	ld (XIX+0x03),A                                      ; FC1825  bc 03 41
	ldw bc, 0x04                                         ; FC1828  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC182B  1e ec 01
	ret                                                  ; FC182E  0e
; Msg0716_PostGmSystemOnOff: T_Msg0716_PostGmSystemOnOff (on): the 4-byte message F0 7F 09 01 (on) or F0 7F 09 02 (off) at 0x716 through Msg0716_Post_Trampoline
;   -- the GM System On / Off pair (sub-IDs 09 01 / 09 02) -- then Msg0716_AllPartsPostVolume.
Msg0716_PostGmSystemOnOff:
	ld W,(XSP+0x04)                                      ; FC182F  8f 04 20
	push XIX                                             ; FC1832  3c
	ld XIX,0x00000716                                    ; FC1833  44 16 07 00 00
	ld (XIX),0xf0                                        ; FC1838  b4 00 f0
	ld (XIX+0x01),0x7f                                   ; FC183B  bc 01 00 7f
	ld (XIX+0x02),0x09                                   ; FC183F  bc 02 00 09
	ld a, 0x02:opc                                          ; FC1843  21 02
	cp w, 0x00:i3                                          ; FC1845  c8 d8
	jr z, .LFC184B                                       ; FC1847  66 02
	ld a, 0x01:opc                                          ; FC1849  21 01
.LFC184B:
	ld (XIX+0x03),A                                      ; FC184B  bc 03 41
	ldw bc, 0x04                                         ; FC184E  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1851  1e c6 01
	pop XIX                                              ; FC1854  5c
	calr Msg0716_AllPartsPostVolume                                      ; FC1855  1e 01 00
	ret                                                  ; FC1858  0e
; Msg0716_AllPartsPostVolume: For parts 0..31: B0 <part> 07 <record +3> through Msg0716_PostCC07_VolumeFromA (0 when
;   bit 7 is set) -- every part's volume re-sent to CPU 2. The tail of Msg0716_PostGmSystemOnOff, after its GM System
;   On / Off message. Sibling of Msg0716_AllPartsSustainOff. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_AllPartsPostVolume:
	push XIX                                             ; FC1859  3c
	ld w, 0x00:opc                                          ; FC185A  20 00
.LFC185C:
	push W                                               ; FC185C  c8 04
	calr Msg0716_GetRecordPtrByIndex                                          ; FC185E  1e ed f8
	pop W                                                ; FC1861  c8 05
	ld A,(XIY+0x03)                                      ; FC1863  8d 03 21
	ld XIX,0x00000716                                    ; FC1866  44 16 07 00 00
	ld (XIX+0x01),W                                      ; FC186B  bc 01 40
	calr Msg0716_PostCC07_VolumeFromA                                      ; FC186E  1e b7 fc
	cp W,0x1f                                            ; FC1871  c8 cf 1f
	jr nc, .LFC187B                                      ; FC1874  6f 05
	add W,0x01                                           ; FC1876  c8 c8 01
	jr .LFC185C                                          ; FC1879  68 e1
.LFC187B:
	pop XIX                                              ; FC187B  5c
	ret                                                  ; FC187C  0e
	ld (XIX),0xf0                                        ; FC187D  b4 00 f0
	ld (XIX+0x01),0x7f                                   ; FC1880  bc 01 00 7f
	ld (XIX+0x02),0x09                                   ; FC1884  bc 02 00 09
	ldw bc, 0x04                                         ; FC1888  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC188B  1e 8c 01
	ret                                                  ; FC188E  0e
; Msg0716_PostSysEx50_A3: posts F0 50 A3 ... to CPU 2 -- a system-exclusive message, manufacturer ID 0x50 (Matsushita),
;   command 0xA3, whose meaning is not established here (notes/prom_a_msg0716_message_names.py).
Msg0716_PostSysEx50_A3:
	ld XIX,0x00000716                                    ; FC188F  44 16 07 00 00
	ld (XIX),0xf0                                        ; FC1894  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC1897  bc 01 00 50
	ld (XIX+0x02),0xa3                                   ; FC189B  bc 02 00 a3
	ld (XIX+0x03),0x01                                   ; FC189F  bc 03 00 01
	ldw bc, 0x04                                         ; FC18A3  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC18A6  1e 71 01
	ret                                                  ; FC18A9  0e
; Msg0716_PostSysEx50_87_StackArg: A := the byte argument on the stack, then Msg0716_PostSysEx50_87 (F0 50 87 A to CPU
;   2) -- the stack-argument entry of that poster. DiskError_SoundAlertAndWait reaches it through T_Msg0716_PostSysEx50_87_StackArg with 8.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Msg0716_PostSysEx50_87_StackArg:
	ld A,(XSP+0x04)                                      ; FC18AA  8f 04 21
	call Msg0716_PostSysEx50_87                                      ; FC18AD  1d b2 18 fc
	ret                                                  ; FC18B1  0e
; Msg0716_PostSysEx50_87: posts F0 50 87 ... to CPU 2 -- a system-exclusive message, manufacturer ID 0x50 (Matsushita),
;   command 0x87, whose meaning is not established here (notes/prom_a_msg0716_message_names.py).
Msg0716_PostSysEx50_87:
	ld XIX,0x00000716                                    ; FC18B2  44 16 07 00 00
	ld (XIX),0xf0                                        ; FC18B7  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC18BA  bc 01 00 50
	ld (XIX+0x02),0x87                                   ; FC18BE  bc 02 00 87
	ld (XIX+0x03),A                                      ; FC18C2  bc 03 41
	ldw bc, 0x04                                         ; FC18C5  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC18C8  1e 4f 01
	ret                                                  ; FC18CB  0e
; Msg0716_PostValueMasked: the shared tail of the Msg0716 builders -- value = UiEvent_Byte2 AND C, byte 3 of the message at 0x0716, BC = 4,
;   Msg0716_Post_Trampoline (notes/prom_a_msg0716_message_names.py).
Msg0716_PostValueMasked:
	ld a, (UiEvent_Byte2:16)                                   ; FC18CC  c1 b9 20 21
	and A,C                                              ; FC18D0  cb c1
	ld (XIX+0x03),A                                      ; FC18D2  bc 03 41
	ldw bc, 0x04                                         ; FC18D5  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC18D8  1e 3f 01
	ret                                                  ; FC18DB  0e
; Msg0716_PostValueAsSwitch: the shared tail of the Msg0716 builders -- value = 0x7F if UiEvent_Byte2 AND C, else 0, byte 3 of the message at 0x0716, BC = 4,
;   Msg0716_Post_Trampoline (notes/prom_a_msg0716_message_names.py).
Msg0716_PostValueAsSwitch:
	ld (XIX+0x03),0x00                                   ; FC18DC  bc 03 00 00
	ldfr_berp c, 0x3c                                      ; FC18E0  c7 3c 9b   ld RL3,C
	and c, (UiEvent_Byte2:16)                                   ; FC18E3  c1 b9 20 c3
	ld_erpb_rr c, 0x3c                                   ; FC18E7  c7 3c 8b   ld C,RL3
	jr z, .LFC18F0                                       ; FC18EA  66 04
	ld (XIX+0x03),0x7f                                   ; FC18EC  bc 03 00 7f
.LFC18F0:
	ldw bc, 0x04                                         ; FC18F0  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC18F3  1e 24 01
	ret                                                  ; FC18F6  0e
; Msg0716_PostValueClamped: the shared tail of the Msg0716 builders -- value = min(UiEvent_Byte2, C), byte 3 of the message at 0x0716, BC = 4,
;   Msg0716_Post_Trampoline (notes/prom_a_msg0716_message_names.py).
Msg0716_PostValueClamped:
	ld a, (UiEvent_Byte2:16)                                   ; FC18F7  c1 b9 20 21
	cp A,C                                               ; FC18FB  cb f1
	jr ule, .LFC1901                                     ; FC18FD  63 02
	ld A,C                                               ; FC18FF  cb 89
.LFC1901:
	ld (XIX+0x03),A                                      ; FC1901  bc 03 41
	ldw bc, 0x04                                         ; FC1904  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1907  1e 10 01
	ret                                                  ; FC190A  0e
	and A,0x7f                                           ; FC190B  c9 cc 7f
	ld (XIX+0x03),A                                      ; FC190E  bc 03 41
	ldw bc, 0x04                                         ; FC1911  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1914  1e 03 01
	ret                                                  ; FC1917  0e
; Msg0716_PartPostProgramChange: XIY = the part's RAM slot (object record +0), part byte = record +6, then Msg0716_PostProgramChange
;   (C0 <part> <slot +0..+1> 00).  Called by the pending-part loops.
Msg0716_PartPostProgramChange:
	pushw bc                                             ; FC1918  29
	ld	xiy, (xiz+0:8)                               ; FC1919  ae 00 25
	ld A,(XIZ+0x06)                                      ; FC191C  8e 06 21
	ld (XIX+0x01),A                                      ; FC191F  bc 01 41
	calr Msg0716_PostProgramChange                                      ; FC1922  1e 02 00
	popw bc                                              ; FC1925  49
	ret                                                  ; FC1926  0e
; Msg0716_PostProgramChange: C0 <part> <word from (XIY)> 00, five bytes: a program change carrying a 16-bit program number.
Msg0716_PostProgramChange:
	ld (XIX),0xc0                                        ; FC1927  b4 00 c0
	ld	wa, (xiy+0:8)                                ; FC192A  9d 00 20
	ld (XIX+0x02),WA                                     ; FC192D  bc 02 50
	ld (XIX+0x04),0x00                                   ; FC1930  bc 04 00 00
	ldw bc, 0x05                                         ; FC1934  31 05 00
	calr Msg0716_Post_Trampoline                         ; FC1937  1e e0 00
	ret                                                  ; FC193A  0e
	ret                                                  ; FC193B  0e
	ret                                                  ; FC193C  0e
	ret                                                  ; FC193D  0e
	ret                                                  ; FC193E  0e
	ret                                                  ; FC193F  0e
	ret                                                  ; FC1940  0e
	ret                                                  ; FC1941  0e
	ret                                                  ; FC1942  0e
	ret                                                  ; FC1943  0e
	ret                                                  ; FC1944  0e
; Msg0716_PostPitchBendCenter: E0 <part> 00 40 -- pitch bend to the centre value 0x2000 (was Msg0716_Post_Trampoline_Wrap_3).
Msg0716_PostPitchBendCenter:
	ld (XIX),0xe0                                        ; FC1945  b4 00 e0
	ld A,(XIZ+0x06)                                      ; FC1948  8e 06 21
	ld (XIX+0x01),A                                      ; FC194B  bc 01 41
	ld (XIX+0x02),0x00                                   ; FC194E  bc 02 00 00
	ld (XIX+0x03),0x40                                   ; FC1952  bc 03 00 40
	ldw bc, 0x04                                         ; FC1956  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1959  1e be 00
	ret                                                  ; FC195C  0e
; Msg0716_PostCC01_ModulationZero: B0 <part> 01 00, modulation to 0 (was Msg0716_Post_Trampoline_Wrap_4).
Msg0716_PostCC01_ModulationZero:
	ld (XIX),0xb0                                        ; FC195D  b4 00 b0
	ld A,(XIZ+0x06)                                      ; FC1960  8e 06 21
	ld (XIX+0x01),A                                      ; FC1963  bc 01 41
	ld (XIX+0x02),0x01                                   ; FC1966  bc 02 00 01
	ld (XIX+0x03),0x00                                   ; FC196A  bc 03 00 00
	ldw bc, 0x04                                         ; FC196E  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1971  1e a6 00
	ret                                                  ; FC1974  0e
; Msg0716_PostCC40_SustainOff: posts B0 <part (XIZ+6)> 40 00 -- MIDI controller 0x40, Sustain, value 0 -- through Msg0716_Post_Trampoline.
Msg0716_PostCC40_SustainOff:
	ld (XIX),0xb0                                        ; FC1975  b4 00 b0
	ld A,(XIZ+0x06)                                      ; FC1978  8e 06 21
	ld (XIX+0x01),A                                      ; FC197B  bc 01 41
	ld (XIX+0x02),0x40                                   ; FC197E  bc 02 00 40
	ld (XIX+0x03),0x00                                   ; FC1982  bc 03 00 00
	ldw bc, 0x04                                         ; FC1986  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1989  1e 8e 00
	ret                                                  ; FC198C  0e
	ld (XIX),0xb0                                        ; FC198D  b4 00 b0
	ld A,(XIZ+0x06)                                      ; FC1990  8e 06 21
	ld (XIX+0x01),A                                      ; FC1993  bc 01 41
	ld (XIX+0x02),0x0a                                   ; FC1996  bc 02 00 0a
	ld (XIX+0x03),0x40                                   ; FC199A  bc 03 00 40
	ldw bc, 0x04                                         ; FC199E  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC19A1  1e 76 00
	ret                                                  ; FC19A4  0e
	ld (XIX),0xb0                                        ; FC19A5  b4 00 b0
	ld A,(XIZ+0x06)                                      ; FC19A8  8e 06 21
	ld (XIX+0x01),A                                      ; FC19AB  bc 01 41
	ld (XIX+0x02),0x0b                                   ; FC19AE  bc 02 00 0b
	push XIY                                             ; FC19B2  3d
	ld	xiy, (xiz+0:8)                               ; FC19B3  ae 00 25
	ld A,(XIY+0x03)                                      ; FC19B6  8d 03 21
	pop XIY                                              ; FC19B9  5d
	ld (XIX+0x03),A                                      ; FC19BA  bc 03 41
	ldw bc, 0x04                                         ; FC19BD  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC19C0  1e 57 00
	ret                                                  ; FC19C3  0e
	ld (XIX),0xd0                                        ; FC19C4  b4 00 d0
	ld A,(XIZ+0x06)                                      ; FC19C7  8e 06 21
	ld (XIX+0x01),A                                      ; FC19CA  bc 01 41
	ld (XIX+0x02),0x00                                   ; FC19CD  bc 02 00 00
	ld (XIX+0x03),0x00                                   ; FC19D1  bc 03 00 00
	ldw bc, 0x04                                         ; FC19D5  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC19D8  1e 3f 00
	ret                                                  ; FC19DB  0e
T_F40FD8_Nop:
	ret                                                  ; FC19DC  0e
	ret                                                  ; FC19DD  0e
	ret                                                  ; FC19DE  0e
	ret                                                  ; FC19DF  0e
; Msg0716_PostClearSoundRamRequest: Writes the CPU-2 link request 88 00 17 00 00 00 at (XIX) and posts its 6 bytes on
;   stream 0 through Msg0716_Post_Trampoline; on CPU 2 that is ToneEdit_Dispatch opcode 0x17, SoundRam_ClearFourBanks.
;   The body of Msg0716_PostClearSoundRamBanks, which sets XIX := 0x0716. Basis: caller + body + CPU-2 dispatch.
;   (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
Msg0716_PostClearSoundRamRequest:
	ld (XIX),0x88                                        ; FC19E0  b4 00 88
	ld (XIX+0x01),0x00                                   ; FC19E3  bc 01 00 00
	ld (XIX+0x02),0x17                                   ; FC19E7  bc 02 00 17
	ld (XIX+0x03),0x00                                   ; FC19EB  bc 03 00 00
	ld (XIX+0x04),0x00                                   ; FC19EF  bc 04 00 00
	ld (XIX+0x05),0x00                                   ; FC19F3  bc 05 00 00
	ldw bc, 0x06                                         ; FC19F7  31 06 00
	call Msg0716_Post_Trampoline                         ; FC19FA  1d 1a 1a fc
	ret                                                  ; FC19FE  0e
; Msg0716_PostSysEx50_92: posts F0 50 92 ... to CPU 2 -- a system-exclusive message, manufacturer ID 0x50 (Matsushita),
;   command 0x92, whose meaning is not established here (notes/prom_a_msg0716_message_names.py).
Msg0716_PostSysEx50_92:
	ld XIX,0x00000716                                    ; FC19FF  44 16 07 00 00
	ld (XIX),0xf0                                        ; FC1A04  b4 00 f0
	ld (XIX+0x01),0x50                                   ; FC1A07  bc 01 00 50
	ld (XIX+0x02),0x92                                   ; FC1A0B  bc 02 00 92
	ld (XIX+0x03),0x00                                   ; FC1A0F  bc 03 00 00
	ldw bc, 0x04                                         ; FC1A13  31 04 00
	calr Msg0716_Post_Trampoline                         ; FC1A16  1e 01 00
	ret                                                  ; FC1A19  0e
; ---------------------------------------------------------------------
; Msg0716_Post_Trampoline -- `calr Msg0716_Post; ret`, four bytes
;
; Called from: 30 `calr` sites in this module -- the module's busiest internal
;          call, against 1 direct call on the routine it wraps.
; Inputs:  BC = the message length.  Outputs: none of its own.
; Evidence: the whole routine is `1e 01 00 0e`.
; Unknown: why the extra frame exists; the callee is 4 bytes away.
; ---------------------------------------------------------------------
Msg0716_Post_Trampoline:
	calr Msg0716_Post                                    ; FC1A1A  1e 01 00
	ret                                                  ; FC1A1D  0e
; ---------------------------------------------------------------------
; Msg0716_Post -- post BC bytes from RAM 0x0716 on link stream 0
;
; Called from: Msg0716_Post_Trampoline, by `calr`, and nothing else.
; Inputs:  BC = length in bytes.
; Outputs: the link layer's; XIX saved and restored around the call.
; Evidence: `push XIX / ld XIX,0x00000716 / push XIX / push BC / push 0x0000 /
;          call 0xf40ed4 / add XSP,8 / pop XIX / ret`, all 23 bytes checked.
;          The three-argument shape and the meaning of the first argument are
;          read out of the callee, prom_a 0xF8E02C-0xF8E0FD, already converted
;          in this file: it takes the pointer from (XIZ+0x0c), the count from
;          (XIZ+0x0a), and turns the third word into bits 5-7 of the link header
;          byte at 0xF8E0A7.
; Unknown: what CPU 2 does with stream 0.
; ---------------------------------------------------------------------
Msg0716_Post:
	push XIX                                             ; FC1A1E  3c
	ld XIX,0x00000716                                    ; FC1A1F  44 16 07 00 00
	push XIX                                             ; FC1A24  3c
	pushw bc                                             ; FC1A25  29
	pushw 0x00                                           ; FC1A26  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC1A29  1d d4 0e f4
	add XSP,0x00000008                                   ; FC1A2D  ef c8 08 00 00 00
	pop XIX                                              ; FC1A33  5c
	ret                                                  ; FC1A34  0e
; Msg0716_PostOp80_Byte7634: Msg0716_DefaultMessages record 0 (80 00 01), Msg0716_BiasOpcodeByMode, then the byte at 0x7634: 4 bytes on stream 1.
Msg0716_PostOp80_Byte7634:
	ld XIY,Msg0716_DefaultMessages                       ; FC1A35  45 fa 1a fc 00
	ld XIX,0x00000716                                    ; FC1A3A  44 16 07 00 00
	ldw bc, 0x03                                         ; FC1A3F  31 03 00
	ldir85                                               ; FC1A42  85 11
	calr Msg0716_BiasOpcodeByMode                                            ; FC1A44  1e d2 00
	ld XIY,0x00007634                                    ; FC1A47  45 34 76 00 00
	ldw bc, 0x01                                         ; FC1A4C  31 01 00
	ldir85                                               ; FC1A4F  85 11
	ld XIX,0x00000716                                    ; FC1A51  44 16 07 00 00
	ldw bc, 0x04                                         ; FC1A56  31 04 00
	calr Msg0716_PostFromXIX_Stream1                                            ; FC1A59  1e ad 00
	ret                                                  ; FC1A5C  0e
; Msg0716_PostOp81_EffectBlock97: record 1 (81 00 18), the opcode bias, then the 24 bytes at 0x7642 -- effect block 97's payload, the one
;   ParamImage_SanitizeAll hands DspEffect_SanitizeBlock: 27 bytes on stream 1.
Msg0716_PostOp81_EffectBlock97:
	ld XIY,Msg0716_DefaultMessages+0x3                   ; FC1A5D  45 fd 1a fc 00
	ld XIX,0x00000716                                    ; FC1A62  44 16 07 00 00
	ldw bc, 0x03                                         ; FC1A67  31 03 00
	ldir85                                               ; FC1A6A  85 11
	calr Msg0716_BiasOpcodeByMode                                            ; FC1A6C  1e aa 00
	ld XIY,0x00007642                                    ; FC1A6F  45 42 76 00 00
	ldw bc, 0x18                                         ; FC1A74  31 18 00
	ldir85                                               ; FC1A77  85 11
	ld XIX,0x00000716                                    ; FC1A79  44 16 07 00 00
	ldw bc, 0x1b                                         ; FC1A7E  31 1b 00
	calr Msg0716_PostFromXIX_Stream1                                            ; FC1A81  1e 85 00
	ret                                                  ; FC1A84  0e
; Msg0716_PostOp82_EffectBlock98: record 2 (82 00 18), then the 24 bytes at 0x7662, effect block 98: 27 bytes on stream 1.
Msg0716_PostOp82_EffectBlock98:
	ld XIY,Msg0716_DefaultMessages+0x6                   ; FC1A85  45 00 1b fc 00
	ld XIX,0x00000716                                    ; FC1A8A  44 16 07 00 00
	ldw bc, 0x03                                         ; FC1A8F  31 03 00
	ldir85                                               ; FC1A92  85 11
	calr Msg0716_BiasOpcodeByMode                                            ; FC1A94  1e 82 00
	ld XIY,0x00007662                                    ; FC1A97  45 62 76 00 00
	ldw bc, 0x18                                         ; FC1A9C  31 18 00
	ldir85                                               ; FC1A9F  85 11
	ld XIX,0x00000716                                    ; FC1AA1  44 16 07 00 00
	ldw bc, 0x1b                                         ; FC1AA6  31 1b 00
	calr Msg0716_PostFromXIX_Stream1                                            ; FC1AA9  1e 5d 00
	ret                                                  ; FC1AAC  0e
; Msg0716_PostOp83_EffectBlock99: record 3 (83 00 18), then the 24 bytes at 0x7682, effect block 99: 27 bytes on stream 1.
Msg0716_PostOp83_EffectBlock99:
	ld XIY,Msg0716_DefaultMessages+0x9                   ; FC1AAD  45 03 1b fc 00
	ld XIX,0x00000716                                    ; FC1AB2  44 16 07 00 00
	ldw bc, 0x03                                         ; FC1AB7  31 03 00
	ldir85                                               ; FC1ABA  85 11
	calr Msg0716_BiasOpcodeByMode                                            ; FC1ABC  1e 5a 00
	ld XIY,0x00007682                                    ; FC1ABF  45 82 76 00 00
	ldw bc, 0x18                                         ; FC1AC4  31 18 00
	ldir85                                               ; FC1AC7  85 11
	ld XIX,0x00000716                                    ; FC1AC9  44 16 07 00 00
	ldw bc, 0x1b                                         ; FC1ACE  31 1b 00
	calr Msg0716_PostFromXIX_Stream1                                            ; FC1AD1  1e 35 00
	ret                                                  ; FC1AD4  0e
; Msg0716_PostOp87_Bytes78B3: record 4 (87 00 04), no bias, then the 4 bytes at 0x78B3: 7 bytes on stream 1.
Msg0716_PostOp87_Bytes78B3:
	ld XIY,Msg0716_DefaultMessages+0xC                   ; FC1AD5  45 06 1b fc 00
	ld XIX,0x00000716                                    ; FC1ADA  44 16 07 00 00
	ldw bc, 0x03                                         ; FC1ADF  31 03 00
	ldir85                                               ; FC1AE2  85 11
	ld XIY,0x000078b3                                    ; FC1AE4  45 b3 78 00 00
	ldw bc, 0x04                                         ; FC1AE9  31 04 00
	ldir85                                               ; FC1AEC  85 11
	ld XIX,0x00000716                                    ; FC1AEE  44 16 07 00 00
	ldw bc, 0x07                                         ; FC1AF3  31 07 00
	calr Msg0716_PostFromXIX_Stream1                                            ; FC1AF6  1e 10 00
	ret                                                  ; FC1AF9  0e
; ---------------------------------------------------------------------
; Msg0716_DefaultMessages -- five 3-byte messages, one per opcode
;
;   0xFC1AFA   80 00 01
;   0xFC1AFD   81 00 18
;   0xFC1B00   82 00 18
;   0xFC1B03   83 00 18
;   0xFC1B06   87 00 04
;
; RECORD WIDTH AND COUNT are the readers', not a reading: five routines at
; 0xFC1A35, 0xFC1A5D, 0xFC1A85, 0xFC1AAD and 0xFC1AD5 each do
; `ld XIY,<one of the five> / ld XIX,0x00000716 / ld BC,0x0003 / ldir`, so the
; width is their `ld BC,0x0003` and the count is the five distinct bases, which
; are consecutive and 3 apart.  0xFC1B06 + 3 = 0xFC1B09, which is
; Msg0716_PostFromXIX_Stream1 -- the table ends exactly at the next routine, and
; a sixth record would overwrite its first three bytes.
;
; Evidence: the fifteen bytes, the five loader sites, that each loader's
;          `ld BC` really is 0x0003 and its `ld XIX` really is 0x00000716, and
;          that 0xFC1B06 + 3 is Msg0716_PostFromXIX_Stream1 -- all checks in
;          notes/prom_a_fc0000_module_check.py section 6.
; Unknown: what bytes +1 and +2 mean.  +0 is the message opcode, the one
; Msg0716_BiasOpcodeByMode may add 8 to on the very next instruction of four of
; the five callers.
; ANSWERED 2026-10-04: +1..+2 is the PAYLOAD LENGTH, big-endian.  0x0001, 0x0018,
;   0x0018, 0x0018, 0x0004 are exactly the byte counts each loader copies after the
;   record (1 from 0x7634, 24 from each of the effect blocks 0x7642 / 0x7662 /
;   0x7682, 4 from 0x78B3) -- Msg0716_PostOp80_Byte7634 .. Msg0716_PostOp87_Bytes78B3.
; ---------------------------------------------------------------------
Msg0716_DefaultMessages:
	.byte 0x80, 0x00, 0x01, 0x81, 0x00, 0x18, 0x82, 0x00, 0x18, 0x83, 0x00, 0x18, 0x87, 0x00, 0x04  ; FC1AFA
; ---------------------------------------------------------------------
; Msg0716_PostFromXIX_Stream1 -- post BC bytes from XIX on link stream 1
;
; Called from: 5 `calr` sites in this module.
; Inputs:  XIX = the buffer, BC = length.  ⚠ Unlike Msg0716_Post it does NOT
;          load 0x0716 itself; it posts whatever the caller left in XIX -- which
;          in every one of the five callers is 0x0716, put there either by the
;          caller or by the dispatcher.
; Outputs: the link layer's.
; Evidence: the fifteen bytes it shares with Msg0716_Post's tail differ at
;          exactly one offset, the pushed stream word: 0x00 there, 0x01 here.
;          The `ld XIX,0x00000716` and the `pop XIX` are the two instructions it
;          does not have.
; Unknown: what distinguishes stream 1 from stream 0 to CPU 2.
; ---------------------------------------------------------------------
Msg0716_PostFromXIX_Stream1:
	push XIX                                             ; FC1B09  3c
	pushw bc                                             ; FC1B0A  29
	pushw 0x01                                           ; FC1B0B  0b 01 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC1B0E  1d d4 0e f4
	add XSP,0x00000008                                   ; FC1B12  ef c8 08 00 00 00
	ret                                                  ; FC1B18  0e
; ---------------------------------------------------------------------
; Msg0716_BiasOpcodeByMode -- add 8 to the staged opcode for three modes
;
; Called from: 4 `calr` sites, all of them immediately after an `ldir` that
;          copies a 3-byte record of Msg0716_DefaultMessages into 0x0716.
; Inputs:  RAM (0x207A), RAM (0x0716).
; Outputs: (0x0716) += 8 if (0x207A) is 0x39, 0x66 or 0xCA; unchanged otherwise.
; Evidence: three `cp (0x207a),imm` in a row with exactly those three literals,
;          two `jr Z` into one `add (0x0716),0x08`, and a `jr NZ` past it.  All
;          five instructions are checked as bytes.
; Unknown: what 0x39/0x66/0xCA select.  They are compared as a set of three and
;          those three compares are the only sites in the module that name
;          0x207A.  The +8 is consistent with the nine `ld (XIX),imm` opcodes
;          all being multiples of 8, but nothing here says they are the same
;          namespace.
; ---------------------------------------------------------------------
Msg0716_BiasOpcodeByMode:
	cp	(UI_ScreenLatch:16), 0x39                            ; FC1B19  c1 7a 20 3f 39
	jr z, .LFC1B2E                                       ; FC1B1E  66 0e
	cp	(UI_ScreenLatch:16), 0x66                            ; FC1B20  c1 7a 20 3f 66
	jr z, .LFC1B2E                                       ; FC1B25  66 07
	cp	(UI_ScreenLatch:16), 0xca                            ; FC1B27  c1 7a 20 3f ca
	jr nz, .LFC1B33                                      ; FC1B2C  6e 05
.LFC1B2E:
	add	(0x0716:16), 0x08                            ; FC1B2E  c1 16 07 38 08
.LFC1B33:
	ret                                                  ; FC1B33  0e
; Msg0716_PostStream3Op80: 80 <UiEvent_Byte2 & 0x0F>, 2 bytes, on stream 3.
Msg0716_PostStream3Op80:
	ld XIX,0x00000716                                    ; FC1B34  44 16 07 00 00
	ld (XIX),0x80                                        ; FC1B39  b4 00 80
	ld a, (UiEvent_Byte2:16)                                   ; FC1B3C  c1 b9 20 21
	and A,0x0f                                           ; FC1B40  c9 cc 0f
	ld (XIX+0x01),A                                      ; FC1B43  bc 01 41
	ldw bc, 0x02                                         ; FC1B46  31 02 00
	calr Msg0716_PostFromXIX_Stream3                                      ; FC1B49  1e 1a 00
	ret                                                  ; FC1B4C  0e
; Msg0716_PostStream3Op90: 90 <UiEvent_Byte2 & 0x7F>, 2 bytes, on stream 3.
Msg0716_PostStream3Op90:
	ld XIX,0x00000716                                    ; FC1B4D  44 16 07 00 00
	ld (XIX),0x90                                        ; FC1B52  b4 00 90
	ld a, (UiEvent_Byte2:16)                                   ; FC1B55  c1 b9 20 21
	and A,0x7f                                           ; FC1B59  c9 cc 7f
	ld (XIX+0x01),A                                      ; FC1B5C  bc 01 41
	ldw bc, 0x02                                         ; FC1B5F  31 02 00
	calr Msg0716_PostFromXIX_Stream3                                      ; FC1B62  1e 01 00
	ret                                                  ; FC1B65  0e
; Msg0716_PostFromXIX_Stream3: Msg0716_PostFromXIX_Stream1 with stream word 3: push XIX / push BC / push 3 / T_Link_SendBlockIn32ByteChunks.
Msg0716_PostFromXIX_Stream3:
	push XIX                                             ; FC1B66  3c
	pushw bc                                             ; FC1B67  29
	ldw wa, 0x03                                         ; FC1B68  30 03 00
	pushw wa                                             ; FC1B6B  28
sub_FC1B6C:
	call T_Link_SendBlockIn32ByteChunks                                        ; FC1B6C  1d d4 0e f4
	add XSP,0x00000008                                   ; FC1B70  ef c8 08 00 00 00
	ret                                                  ; FC1B76  0e
	ld w, (0x60a000:24)                                 ; FC1B77  c2 00 a0 60 20
	ld a, (0x60a001:24)                                 ; FC1B7C  c2 01 a0 60 21
; ---------------------------------------------------------------------
; SoundName_Lookup -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_b T_SoundName_Lookup (`jp`)
;          prom_a sub_F90989 (`call` through T_SoundName_Lookup) at 0xF90A56
;          prom_a InstallPainter_SoundMode (`call` through T_SoundName_Lookup) at 0xF90E62
;          prom_a C0mbinati0nM0de_ShowSelectedPartSoundName (`call` through T_SoundName_Lookup) at 0xF9190A
;          ... and 2 more
;
;     0xFC1BAE loads 0xFC1C49, where the ROM reads:
;        "Sound Name *****<()*+"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; SoundName_Lookup: T_SoundName_Lookup (W = bank, A = number -- the callers pass a part record's +1 & 0x7F and +0): under semaphore 4,
;   SoundName_SendQuery, then Link_ReceiveEchoedReply for 17 bytes into 0x810.  XIY = 0x810, or Msg0716_Str_SoundName
;   ('Sound Name *****') when CPU 2 does not answer.
SoundName_Lookup:
	push XIX                                             ; FC1B81  3c
	pushw wa                                             ; FC1B82  28
	pushw bc                                             ; FC1B83  29
	pushw de                                             ; FC1B84  2a
	pushw hl                                             ; FC1B85  2b
	push_a                                               ; FC1B86  14
	ld a, 0x04:opc                                          ; FC1B87  21 04
	call T_Kernel_SemaWait                               ; FC1B89  1d 90 2d f4
	pop_a                                                ; FC1B8D  15
	ld XIY,0x00000800                                    ; FC1B8E  45 00 08 00 00
	call SoundName_SendQuery                                      ; FC1B93  1d b9 1b fc
	ldw de, 0x11                                         ; FC1B97  32 11 00
	ld c, 0x00:opc                                          ; FC1B9A  23 00
	call Link_ReceiveEchoedReply                                      ; FC1B9C  1d dc 1b fc
	ld a, 0x04:opc                                          ; FC1BA0  21 04
	call T_Kernel_SemaSignal                             ; FC1BA2  1d 88 2d f4
	cp XIY,0xffffffff                                    ; FC1BA6  ed cf ff ff ff ff
	jr nz, .LFC1BB3                                      ; FC1BAC  6e 05
	ld XIY,Msg0716_Str_SoundName                         ; FC1BAE  45 49 1c fc 00
.LFC1BB3:
	popw hl                                              ; FC1BB3  4b
	popw de                                              ; FC1BB4  4a
	popw bc                                              ; FC1BB5  49
	popw wa                                              ; FC1BB6  48
	pop XIX                                              ; FC1BB7  5c
	ret                                                  ; FC1BB8  0e
; SoundName_SendQuery: the 6-byte link request [0x80, W, 0x04, A, 0, 0] built at XIY (0x800) and sent with T_Link_SendBlockIn32ByteChunks.
SoundName_SendQuery:
	ld (XIY),0x80                                        ; FC1BB9  b5 00 80
	ld (XIY+0x01),W                                      ; FC1BBC  bd 01 40
	ld (XIY+0x02),0x04                                   ; FC1BBF  bd 02 00 04
	ld (XIY+0x03),A                                      ; FC1BC3  bd 03 41
	ld (XIY+0x04),0x00                                   ; FC1BC6  bd 04 00 00
	ld (XIY+0x05),0x00                                   ; FC1BCA  bd 05 00 00
	push XIY                                             ; FC1BCE  3d
	pushw 0x06                                           ; FC1BCF  0b 06 00
	pushw 0x00                                           ; FC1BD2  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC1BD5  1d d4 0e f4
	inc 8,XSP                                            ; FC1BD9  ef 60
	ret                                                  ; FC1BDB  0e
; Link_ReceiveEchoedReply: (C = offset, DE = count): reads the reply from Ring60480A (Ring60480A_GetWithTimeout): first the 6 request bytes
;   echoed back, compared with 0x800.. until they match, then DE bytes into 0x810 + C.  XIY = 0x810, or 0xFFFFFFFF on a
;   timeout.
Link_ReceiveEchoedReply:
	pushw bc                                             ; FC1BDC  29
	ld XIX,0x00000800                                    ; FC1BDD  44 00 08 00 00
	ldw hl, 0x06                                         ; FC1BE2  33 06 00
.LFC1BE5:
	push C                                               ; FC1BE5  cb 04
	call Ring60480A_GetWithTimeout                                      ; FC1BE7  1d 29 1c fc
	pop C                                                ; FC1BEB  cb 05
	cp XIY,0xffffffff                                    ; FC1BED  ed cf ff ff ff ff
	jr z, .LFC1C27                                       ; FC1BF3  66 32
	cp (XIX),A                                           ; FC1BF5  84 f9
	jr nz, .LFC1BE5                                      ; FC1BF7  6e ec
	inc 1,XIX                                            ; FC1BF9  ec 61
	djnz16 hl, .LFC1BE5                                  ; FC1BFB  db 1c e7
	ld XIY,0x00000810                                    ; FC1BFE  45 10 08 00 00
	xor B,B                                              ; FC1C03  ca d2
	extz XBC                                             ; FC1C05  e9 12
	add XIY,XBC                                          ; FC1C07  e9 85
.LFC1C09:
	push C                                               ; FC1C09  cb 04
	call Ring60480A_GetWithTimeout                                      ; FC1C0B  1d 29 1c fc
	pop C                                                ; FC1C0F  cb 05
	cp XIY,0xffffffff                                    ; FC1C11  ed cf ff ff ff ff
	jr z, .LFC1C27                                       ; FC1C17  66 0e
	ld (xiy+), a                                    ; FC1C19  f5 f4 41
	dec 1,DE                                             ; FC1C1C  da 69
	cp de, 0x00:i3                                         ; FC1C1E  da d8
	jr nz, .LFC1C09                                      ; FC1C20  6e e7
	ld XIY,0x00000810                                    ; FC1C22  45 10 08 00 00
.LFC1C27:
	popw bc                                              ; FC1C27  49
	ret                                                  ; FC1C28  0e
; Ring60480A_GetWithTimeout: T_Ring60480A_Get retried up to 0xFFFF times while it returns 0xFFFF; XIY = 0xFFFFFFFF when it never delivers.
Ring60480A_GetWithTimeout:
	ldw bc, 0xffff                                       ; FC1C29  31 ff ff
.LFC1C2C:
	pushw bc                                             ; FC1C2C  29
	push XIY                                             ; FC1C2D  3d
	push XIX                                             ; FC1C2E  3c
	pushw de                                             ; FC1C2F  2a
	pushw hl                                             ; FC1C30  2b
	call T_Ring60480A_Get                                ; FC1C31  1d f4 1c f4
	popw hl                                              ; FC1C35  4b
	popw de                                              ; FC1C36  4a
	pop XIX                                              ; FC1C37  5c
	pop XIY                                              ; FC1C38  5d
	popw bc                                              ; FC1C39  49
	cp WA,0xffff                                         ; FC1C3A  d8 cf ff ff
	jr nz, .LFC1C48                                      ; FC1C3E  6e 08
	djnz16 bc, .LFC1C2C                                  ; FC1C40  d9 1c e9
	ld XIY,0xffffffff                                    ; FC1C43  45 ff ff ff ff
.LFC1C48:
	ret                                                  ; FC1C48  0e
; ---------------------------------------------------------------------
; Msg0716_Str_SoundName -- "Sound Name *****", 16 bytes, no terminator
;
; Evidence: 0xFC1BA6 is `cp XIY,0xffffffff / jr NZ,+5 / ld XIY,0x00fc1c49`, so
; it is the string used when the real name pointer is the all-ones sentinel.
; The length is 16 because the next byte, 0xFC1C59, is a directory target
; (T_CombiName_Lookup) and decodes as `push XIX`; the byte at +16 is 0x3C, not NUL.
; Unknown: which field the caller was trying to name.
; ---------------------------------------------------------------------
Msg0716_Str_SoundName:
	.byte 0x53, 0x6f, 0x75, 0x6e, 0x64, 0x20, 0x4e, 0x61, 0x6d, 0x65, 0x20, 0x2a, 0x2a, 0x2a, 0x2a, 0x2a  ; FC1C49
; ---------------------------------------------------------------------
; CombiName_Lookup -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_b T_CombiName_Lookup (`jp`)
;          prom_a C0mbinati0nM0de_ShowSelectedPartSoundName (`call` through T_CombiName_Lookup) at 0xF91D01
;          prom_a GroupCombiDisplayHold_DrawMemberNames (`call` through T_CombiName_Lookup) at 0xF93F35
;          prom_a CombiName_CopyToBuffer (`call` through T_CombiName_Lookup) at 0xF9F727
;          ... and 1 more
;
;     0xFC1C6C loads 0xFC1CC1, where the ROM reads:
;        "Combi Name *****"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; CombiName_Lookup: T_CombiName_Lookup (W = bank, A = number): CombiName_RequestRead, T_Link_WaitBlockDone.  XIY = the 16 bytes at 0x810, or
;   Msg0716_Str_CombiName ('Combi Name *****') on failure.
CombiName_Lookup:
	push XIX                                             ; FC1C59  3c
	pushw wa                                             ; FC1C5A  28
	pushw bc                                             ; FC1C5B  29
	pushw de                                             ; FC1C5C  2a
	pushw hl                                             ; FC1C5D  2b
	call CombiName_RequestRead                                      ; FC1C5E  1d 77 1c fc
	call T_Link_WaitBlockDone                            ; FC1C62  1d 3c 12 f4
	cp WA,0xffff                                         ; FC1C66  d8 cf ff ff
	jr nz, .LFC1C71                                      ; FC1C6A  6e 05
	ld XIY,Msg0716_Str_CombiName                         ; FC1C6C  45 c1 1c fc 00
.LFC1C71:
	popw hl                                              ; FC1C71  4b
	popw de                                              ; FC1C72  4a
	popw bc                                              ; FC1C73  49
	popw wa                                              ; FC1C74  48
	pop XIX                                              ; FC1C75  5c
	ret                                                  ; FC1C76  0e
; 2026-10-04: CPU 2's addresses, passed in link packets (T_Link_SendCommandE2 reads CPU 2's memory).  They were
;   spelled .LF80300 and wsa1_prom_a, which are THIS image's labels at the same numbers -- a false cross-reference.
;   CPU 2's ROM (prom_c, at CPU-2 0xF80000) holds the preset combinations: number k at 0xF80300 + k x 0x2C0 with
;   its 16-character name at +2 ('Downtown Set', 'ReggaeBass Chord' ...), and their group names at 0xF80200 + k x 16
;   ('FUSION COMBO1', 'JAZZ COMBO' ...).  Checked against original_ROMs/wsa1_prom_c.ic28.  They are PromC_PresetBank_Records / _Header.
; CombiName_RequestRead: T_Link_SendCommandE2 for the 16 name bytes of combination A of bank W into 0x810: CPU 2 address = base + A x
;   0x2C0 + 2, base PromC_PresetBank_Records (W < 8: the preset combinations in CPU 2's ROM), 0xEC0300 (W < 16: CPU 2's
;   flash, the USER bank), or (0x08E4) + 0x300 (W < 24).  The layout: prom_c/data_tables/preset_bank.s READERS.
CombiName_RequestRead:
	cp W,0x08                                            ; FC1C77  c8 cf 08
	jr c, .LFC1C86                                       ; FC1C7A  67 0a
	cp W,0x10                                            ; FC1C7C  c8 cf 10
	jr c, .LFC1C8D                                       ; FC1C7F  67 0c
	cp W,0x18                                            ; FC1C81  c8 cf 18
	jr c, .LFC1C94                                       ; FC1C84  67 0e
.LFC1C86:
	ld XIX,PromC_PresetBank_Records                                     ; FC1C86  44 00 03 f8 00
	jr .LFC1C9E                                          ; FC1C8B  68 11
.LFC1C8D:
	ld XIX,0x00ec0300                                    ; FC1C8D  44 00 03 ec 00
	jr .LFC1C9E                                          ; FC1C92  68 0a
.LFC1C94:
	ld xix, (0x08e4:16)                                 ; FC1C94  e1 e4 08 24
	add XIX,0x00000300                                   ; FC1C98  ec c8 00 03 00 00
.LFC1C9E:
	xor W,W                                              ; FC1C9E  c8 d0
	mul WA,0x02c0                                        ; FC1CA0  d8 08 c0 02
	add XIX,XWA                                          ; FC1CA4  e8 84
	add XIX,0x00000002                                   ; FC1CA6  ec c8 02 00 00 00
	ld XIY,0x00000810                                    ; FC1CAC  45 10 08 00 00
	push XIY                                             ; FC1CB1  3d
	pushw 0x10                                           ; FC1CB2  0b 10 00
	push XIX                                             ; FC1CB5  3c
	call T_Link_SendCommandE2                            ; FC1CB6  1d f0 0e f4
	add XSP,0x0000000a                                   ; FC1CBA  ef c8 0a 00 00 00
	ret                                                  ; FC1CC0  0e
; ---------------------------------------------------------------------
; Msg0716_Str_CombiName -- "Combi Name *****", 16 bytes, no terminator
;
; Evidence: 0xFC1C66 is `cp WA,0xffff / jr NZ,+5 / ld XIY,0x00fc1cc1` -- the
; same sentinel-fallback shape as Msg0716_Str_SoundName, one page along.  The
; byte at +16 is 0x0E and the routine at 0xFC1CD4 begins `push XIX`.
; Unknown: as above.
; ---------------------------------------------------------------------
Msg0716_Str_CombiName:
	.byte 0x43, 0x6f, 0x6d, 0x62, 0x69, 0x20, 0x4e, 0x61, 0x6d, 0x65, 0x20, 0x2a, 0x2a, 0x2a, 0x2a, 0x2a  ; FC1CC1
T_F40FC8_Nop:
	ret                                                  ; FC1CD1  0e
	ret                                                  ; FC1CD2  0e
	ret                                                  ; FC1CD3  0e
; Cpu2Query_RequestPartRecordEffects: Under kernel semaphore 4: Cpu2Query_SendPartRecordRead87 with E = 0x49 and the
;   header at 0x850 -- [0x81, B, 0x87, 0x49, 4, 0], the 73 bytes Cpu2Query_ApplyPartRecordEffects (Cpu2Query_ApplyPartRecordEffects) applies
;   when the reply is drained. Cpu2Query_RequestPartSoundRecord's arm for bit 5 clear. Basis: caller + body + reply
;   handler. (notes/naming-pilot-2026-10-06/proposals_wave10_a10.json)
Cpu2Query_RequestPartRecordEffects:
	push XIX                                             ; FC1CD4  3c
	push W                                               ; FC1CD5  c8 04
	push XBC                                             ; FC1CD7  39
	pushw de                                             ; FC1CD8  2a
	pushw hl                                             ; FC1CD9  2b
	push_a                                               ; FC1CDA  14
	ld a, 0x04:opc                                          ; FC1CDB  21 04
	call T_Kernel_SemaWait                               ; FC1CDD  1d 90 2d f4
	pop_a                                                ; FC1CE1  15
	ldw de, 0x49                                         ; FC1CE2  32 49 00
	ld XIY,0x00000850                                    ; FC1CE5  45 50 08 00 00
	call Cpu2Query_SendPartRecordRead87                                      ; FC1CEA  1d fb 1c fc
	ld a, 0x04:opc                                          ; FC1CEE  21 04
	call T_Kernel_SemaSignal                             ; FC1CF0  1d 88 2d f4
	popw hl                                              ; FC1CF4  4b
	popw de                                              ; FC1CF5  4a
	pop XBC                                              ; FC1CF6  59
	pop W                                                ; FC1CF7  c8 05
	pop XIX                                              ; FC1CF9  5c
	ret                                                  ; FC1CFA  0e
; Cpu2Query_SendPartRecordRead87: [0x81, B, 0x87, E, 4, 0]: E bytes of the part record from offset 0x87, reply channel 4.  What offset 0x87 holds is
;   not established.  Basis: protocol pairing.
Cpu2Query_SendPartRecordRead87:
	pushw de                                             ; FC1CFB  2a
	pushw bc                                             ; FC1CFC  29
	ld (XIY),0x81                                        ; FC1CFD  b5 00 81
	ld (XIY+0x01),B                                      ; FC1D00  bd 01 42
	ld (XIY+0x02),0x87                                   ; FC1D03  bd 02 00 87
	ld (XIY+0x03),E                                      ; FC1D07  bd 03 45
	ld (XIY+0x04),0x04                                   ; FC1D0A  bd 04 00 04
	ld (XIY+0x05),0x00                                   ; FC1D0E  bd 05 00 00
	push XIY                                             ; FC1D12  3d
	pushw 0x06                                           ; FC1D13  0b 06 00
	pushw 0x00                                           ; FC1D16  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC1D19  1d d4 0e f4
	inc 8,XSP                                            ; FC1D1D  ef 60
	popw bc                                              ; FC1D1F  49
	popw de                                              ; FC1D20  4a
	ret                                                  ; FC1D21  0e
; Cpu2Query_RequestToneRecordEffects: Under kernel semaphore 4: Cpu2Query_SendToneRecordRead52 with E = 0x46 and the
;   header at 0x850 -- [0x85, B, 0x52, 0x46, 4, 0], the 70 bytes Cpu2Query_ApplyToneRecordEffects (Cpu2Query_ApplyToneRecordEffects)
;   applies. Cpu2Query_RequestPartSoundRecord's arm for bit 5 set. Basis: caller + body + reply handler.
;   (notes/naming-pilot-2026-10-06/proposals_wave10_a10.json)
Cpu2Query_RequestToneRecordEffects:
	push XIX                                             ; FC1D22  3c
	push W                                               ; FC1D23  c8 04
	push XBC                                             ; FC1D25  39
	pushw de                                             ; FC1D26  2a
	pushw hl                                             ; FC1D27  2b
	push_a                                               ; FC1D28  14
	ld a, 0x04:opc                                          ; FC1D29  21 04
	call T_Kernel_SemaWait                               ; FC1D2B  1d 90 2d f4
	pop_a                                                ; FC1D2F  15
	ldw de, 0x46                                         ; FC1D30  32 46 00
	ld XIY,0x00000850                                    ; FC1D33  45 50 08 00 00
	call Cpu2Query_SendToneRecordRead52                                      ; FC1D38  1d 49 1d fc
	ld a, 0x04:opc                                          ; FC1D3C  21 04
	call T_Kernel_SemaSignal                             ; FC1D3E  1d 88 2d f4
	popw hl                                              ; FC1D42  4b
	popw de                                              ; FC1D43  4a
	pop XBC                                              ; FC1D44  59
	pop W                                                ; FC1D45  c8 05
	pop XIX                                              ; FC1D47  5c
	ret                                                  ; FC1D48  0e
; Cpu2Query_SendToneRecordRead52: [0x85, B, 0x52, E, 4, 0]: E bytes of the tone record from offset 0x52, reply channel 4.  Basis: protocol pairing.
Cpu2Query_SendToneRecordRead52:
	pushw de                                             ; FC1D49  2a
	pushw bc                                             ; FC1D4A  29
	ld (XIY),0x85                                        ; FC1D4B  b5 00 85
	ld (XIY+0x01),B                                      ; FC1D4E  bd 01 42
	ld (XIY+0x02),0x52                                   ; FC1D51  bd 02 00 52
	ld (XIY+0x03),E                                      ; FC1D55  bd 03 45
	ld (XIY+0x04),0x04                                   ; FC1D58  bd 04 00 04
	ld (XIY+0x05),0x00                                   ; FC1D5C  bd 05 00 00
	push XIY                                             ; FC1D60  3d
	pushw 0x06                                           ; FC1D61  0b 06 00
	pushw 0x00                                           ; FC1D64  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC1D67  1d d4 0e f4
	inc 8,XSP                                            ; FC1D6B  ef 60
	popw bc                                              ; FC1D6D  49
	popw de                                              ; FC1D6E  4a
	ret                                                  ; FC1D6F  0e
; ---------------------------------------------------------------------
; Ring60000C_GetWithRetry -- calls ring 0x60000C's Get until it yields a byte, up to
;                            65535 times, and flags exhaustion in XIY
;
; Evidence: 0xFC1D71 `ldw BC,0xFFFF`; 0xFC1D79 `call 0xF41E80` = prom_b
;           slot T_Ring60000C_Get, with XIY, XIX, DE and HL saved across
;           it by 0xFC1D74-0xFC1D78 and restored at 0xFC1D7D-0xFC1D81;
;           0xFC1D82 `cp WA,0xFFFF` and 0xFC1D86 `jr nz` return as soon
;           as the result is not 0xFFFF; 0xFC1D88 `djnz16 BC` retries
;           otherwise; 0xFC1D8B `ld XIY,0xFFFFFFFF` on exhaustion.
;           Ring_Get_0400 (0xF8405D), the class routine every
;           0x400-capacity Get reaches, loads WA=0xFFFF exactly when the
;           read cursor equals the write cursor, so 0xFFFF is its empty
;           marker. All seven call sites are inside Cpu2Query_DrainRecordReplies, the
;           first at 0xFC1D9B
; Unknown:  why exhaustion is reported in XIY when the byte itself comes
;           back in WA, and whether any caller reads XIY
; Was `sub_FC1D70`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
Ring60000C_GetWithRetry:
	pushw bc                                             ; FC1D70  29
	ldw bc, 0xffff                                       ; FC1D71  31 ff ff
.LFC1D74:
	pushw bc                                             ; FC1D74  29
	push XIY                                             ; FC1D75  3d
	push XIX                                             ; FC1D76  3c
	pushw de                                             ; FC1D77  2a
	pushw hl                                             ; FC1D78  2b
	call T_Ring60000C_Get                                ; FC1D79  1d 80 1e f4
	popw hl                                              ; FC1D7D  4b
	popw de                                              ; FC1D7E  4a
	pop XIX                                              ; FC1D7F  5c
	pop XIY                                              ; FC1D80  5d
	popw bc                                              ; FC1D81  49
	cp WA,0xffff                                         ; FC1D82  d8 cf ff ff
	jr nz, .LFC1D90                                      ; FC1D86  6e 08
	djnz16 bc, .LFC1D74                                  ; FC1D88  d9 1c e9
	ld XIY,0xffffffff                                    ; FC1D8B  45 ff ff ff ff
.LFC1D90:
	popw bc                                              ; FC1D90  49
	ret                                                  ; FC1D91  0e
; Cpu2Query_DrainRecordReplies: While ring 0x60000C is not empty: skips to a 0x81 (part-record) or 0x85 (tone-record)
;   reply, reads part, opcode, length and one more header byte, copies the payload to 0x860 (Ring60000C_GetWithRetry)
;   and applies it: 81/87 -> Cpu2Query_ApplyPartRecordEffects, 85/52 -> Cpu2Query_ApplyToneRecordEffects, 81/23 and 85/20 -> Cpu2Query_ApplyCreatorSelectBits (two bytes & 0x3F).
;   MainTask_Loop calls it (T_Cpu2Query_DrainRecordReplies) when the ring is not empty; Cpu2Query_RefreshPartSoundRecord after its request.
;   Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
Cpu2Query_DrainRecordReplies:
	call T_Ring60000C_IsEmpty                            ; FC1D92  1d 8c 1e f4
	cp wa, 0x00:i3                                         ; FC1D96  d8 d8
	jrl z, .LFC1E67                                      ; FC1D98  76 cc 00
.LFC1D9B:
	call Ring60000C_GetWithRetry                                      ; FC1D9B  1d 70 1d fc
	cp XIY,0xffffffff                                    ; FC1D9F  ed cf ff ff ff ff
	jrl z, .LFC1E64                                      ; FC1DA5  76 bc 00
	cp A,0x81                                            ; FC1DA8  c9 cf 81
	jr z, .LFC1DB4                                       ; FC1DAB  66 07
	cp A,0x85                                            ; FC1DAD  c9 cf 85
	jr z, .LFC1DB4                                       ; FC1DB0  66 02
	jr .LFC1D9B                                          ; FC1DB2  68 e7
.LFC1DB4:
	ld D,A                                               ; FC1DB4  c9 8c
	call Ring60000C_GetWithRetry                                      ; FC1DB6  1d 70 1d fc
	cp XIY,0xffffffff                                    ; FC1DBA  ed cf ff ff ff ff
	jrl z, .LFC1E64                                      ; FC1DC0  76 a1 00
	ld B,A                                               ; FC1DC3  c9 8a
	call Ring60000C_GetWithRetry                                      ; FC1DC5  1d 70 1d fc
	cp XIY,0xffffffff                                    ; FC1DC9  ed cf ff ff ff ff
	jrl z, .LFC1E64                                      ; FC1DCF  76 92 00
	ld C,A                                               ; FC1DD2  c9 8b
	call Ring60000C_GetWithRetry                                      ; FC1DD4  1d 70 1d fc
	cp XIY,0xffffffff                                    ; FC1DD8  ed cf ff ff ff ff
	jrl z, .LFC1E64                                      ; FC1DDE  76 83 00
	ld E,A                                               ; FC1DE1  c9 8d
	call Ring60000C_GetWithRetry                                      ; FC1DE3  1d 70 1d fc
	cp XIY,0xffffffff                                    ; FC1DE7  ed cf ff ff ff ff
	jrl z, .LFC1E64                                      ; FC1DED  76 74 00
	call Ring60000C_GetWithRetry                                      ; FC1DF0  1d 70 1d fc
	cp XIY,0xffffffff                                    ; FC1DF4  ed cf ff ff ff ff
	jrl z, .LFC1E64                                      ; FC1DFA  76 67 00
	ld XIY,0x00000860                                    ; FC1DFD  45 60 08 00 00
.LFC1E02:
	call Ring60000C_GetWithRetry                                      ; FC1E02  1d 70 1d fc
	cp XIY,0xffffffff                                    ; FC1E06  ed cf ff ff ff ff
	jr z, .LFC1E64                                       ; FC1E0C  66 56
	ld (xiy+), a                                    ; FC1E0E  f5 f4 41
	sub E,0x01                                           ; FC1E11  cd ca 01
	cp e, 0x00:i3                                          ; FC1E14  cd d8
	jr nz, .LFC1E02                                      ; FC1E16  6e ea
	cp D,0x81                                            ; FC1E18  cc cf 81
	jr z, .LFC1E22                                       ; FC1E1B  66 05
	cp D,0x85                                            ; FC1E1D  cc cf 85
	jr z, .LFC1E44                                       ; FC1E20  66 22
.LFC1E22:
	cp C,0x87                                            ; FC1E22  cb cf 87
	jr z, .LFC1E2E                                       ; FC1E25  66 07
	cp C,0x23                                            ; FC1E27  cb cf 23
	jr z, .LFC1E33                                       ; FC1E2A  66 07
	jr .LFC1E64                                          ; FC1E2C  68 36
.LFC1E2E:
	calr Cpu2Query_ApplyPartRecordEffects                                          ; FC1E2E  1e ef f3
	jr .LFC1E64                                          ; FC1E31  68 31
.LFC1E33:
	ld XIY,0x00000860                                    ; FC1E33  45 60 08 00 00
	and (XIY),0x3f                                       ; FC1E38  85 3c 3f
	and (XIY+0x01),0x3f                                  ; FC1E3B  8d 01 3c 3f
	calr Cpu2Query_ApplyCreatorSelectBits                                          ; FC1E3F  1e 33 f6
	jr .LFC1E64                                          ; FC1E42  68 20
.LFC1E44:
	cp C,0x52                                            ; FC1E44  cb cf 52
	jr z, .LFC1E50                                       ; FC1E47  66 07
	cp C,0x20                                            ; FC1E49  cb cf 20
	jr z, .LFC1E55                                       ; FC1E4C  66 07
	jr .LFC1E64                                          ; FC1E4E  68 14
.LFC1E50:
	calr Cpu2Query_ApplyToneRecordEffects                                          ; FC1E50  1e de f4
	jr .LFC1E64                                          ; FC1E53  68 0f
.LFC1E55:
	ld XIY,0x00000860                                    ; FC1E55  45 60 08 00 00
	and (XIY),0x3f                                       ; FC1E5A  85 3c 3f
	and (XIY+0x01),0x3f                                  ; FC1E5D  8d 01 3c 3f
	calr Cpu2Query_ApplyCreatorSelectBits                                          ; FC1E61  1e 11 f6
.LFC1E64:
	jrl Cpu2Query_DrainRecordReplies                                       ; FC1E64  78 2b ff
.LFC1E67:
	ret                                                  ; FC1E67  0e
; CreatorSelect_ReadSlotLabelIds: (W = part, A = creator-select bits), under kernel semaphore 4: reads from CPU 2 the
;   two label ids of the lowest set bit k -- part record bytes 0x32+6k / 0x35+6k, or tone record 0x2F+6k / 0x32+6k
;   when PartSound_GetBankAndToneFlag sets bit 5 -- & 0x3F; XIY -> the pair at 0x810 (-> two zeros on no bit / timeout).
;   CreatorSelectController_CopyNameLabels and ModeScreen_PaintDirtyFields2 hand (XIY), (XIY+1) to
;   T_UiText_CopyLabel13_To_22F0. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
CreatorSelect_ReadSlotLabelIds:
	push XIX                                             ; FC1E68  3c
	push W                                               ; FC1E69  c8 04
	push XBC                                             ; FC1E6B  39
	pushw de                                             ; FC1E6C  2a
	pushw hl                                             ; FC1E6D  2b
	push_a                                               ; FC1E6E  14
	ld a, 0x04:opc                                          ; FC1E6F  21 04
	call T_Kernel_SemaWait                               ; FC1E71  1d 90 2d f4
	pop_a                                                ; FC1E75  15
	and A,0x3f                                           ; FC1E76  c9 cc 3f
	jrl z, .LFC1F37                                      ; FC1E79  76 bb 00
	ld B,W                                               ; FC1E7C  c8 8a
	bit 0x00,A                                           ; FC1E7E  c9 33 00
	jr z, .LFC1E87                                       ; FC1E81  66 04
	ld a, 0x00:opc                                          ; FC1E83  21 00
	jr .LFC1EAD                                          ; FC1E85  68 26
.LFC1E87:
	bit 0x01,A                                           ; FC1E87  c9 33 01
	jr z, .LFC1E90                                       ; FC1E8A  66 04
	ld a, 0x06:opc                                          ; FC1E8C  21 06
	jr .LFC1EAD                                          ; FC1E8E  68 1d
.LFC1E90:
	bit 0x02,A                                           ; FC1E90  c9 33 02
	jr z, .LFC1E99                                       ; FC1E93  66 04
	ld a, 0x0c:opc                                          ; FC1E95  21 0c
	jr .LFC1EAD                                          ; FC1E97  68 14
.LFC1E99:
	bit 0x03,A                                           ; FC1E99  c9 33 03
	jr z, .LFC1EA2                                       ; FC1E9C  66 04
	ld a, 0x12:opc                                          ; FC1E9E  21 12
	jr .LFC1EAD                                          ; FC1EA0  68 0b
.LFC1EA2:
	bit 0x04,A                                           ; FC1EA2  c9 33 04
	jr z, .LFC1EAB                                       ; FC1EA5  66 04
	ld a, 0x18:opc                                          ; FC1EA7  21 18
	jr .LFC1EAD                                          ; FC1EA9  68 02
.LFC1EAB:
	ld a, 0x1e:opc                                          ; FC1EAB  21 1e
.LFC1EAD:
	push_a                                               ; FC1EAD  14
	call PartSound_GetBankAndToneFlag                                      ; FC1EAE  1d 19 11 fc
	bit 0x05,A                                           ; FC1EB2  c9 33 05
	pop_a                                                ; FC1EB5  15
	jr nz, .LFC1EF4                                      ; FC1EB6  6e 3c
	add A,0x32                                           ; FC1EB8  c9 c8 32
	ld C,A                                               ; FC1EBB  c9 8b
	ldw de, 0x01                                         ; FC1EBD  32 01 00
	ld XIY,0x00000800                                    ; FC1EC0  45 00 08 00 00
	calr Cpu2Query_SendPartRecordRead                                      ; FC1EC5  1e 83 00
	pushw bc                                             ; FC1EC8  29
	ld c, 0x00:opc                                          ; FC1EC9  23 00
	calr Link_ReceiveEchoedReply                                          ; FC1ECB  1e 0e fd
	popw bc                                              ; FC1ECE  49
	cp XIY,0xffffffff                                    ; FC1ECF  ed cf ff ff ff ff
	jr z, .LFC1F37                                       ; FC1ED5  66 60
	add C,0x03                                           ; FC1ED7  cb c8 03
	ldw de, 0x01                                         ; FC1EDA  32 01 00
	ld XIY,0x00000800                                    ; FC1EDD  45 00 08 00 00
	calr Cpu2Query_SendPartRecordRead                                      ; FC1EE2  1e 66 00
	ld c, 0x01:opc                                          ; FC1EE5  23 01
	calr Link_ReceiveEchoedReply                                          ; FC1EE7  1e f2 fc
	cp XIY,0xffffffff                                    ; FC1EEA  ed cf ff ff ff ff
	jr z, .LFC1F37                                       ; FC1EF0  66 45
	jr .LFC1F2E                                          ; FC1EF2  68 3a
.LFC1EF4:
	add A,0x2f                                           ; FC1EF4  c9 c8 2f
	ld C,A                                               ; FC1EF7  c9 8b
	ldw de, 0x01                                         ; FC1EF9  32 01 00
	ld XIY,0x00000800                                    ; FC1EFC  45 00 08 00 00
	calr Cpu2Query_SendToneRecordRead                                      ; FC1F01  1e 6d 00
	pushw bc                                             ; FC1F04  29
	ld c, 0x00:opc                                          ; FC1F05  23 00
	calr Link_ReceiveEchoedReply                                          ; FC1F07  1e d2 fc
	popw bc                                              ; FC1F0A  49
	cp XIY,0xffffffff                                    ; FC1F0B  ed cf ff ff ff ff
	jr z, .LFC1F37                                       ; FC1F11  66 24
	add C,0x03                                           ; FC1F13  cb c8 03
	ldw de, 0x01                                         ; FC1F16  32 01 00
	ld XIY,0x00000800                                    ; FC1F19  45 00 08 00 00
	calr Cpu2Query_SendToneRecordRead                                      ; FC1F1E  1e 50 00
	ld c, 0x01:opc                                          ; FC1F21  23 01
	calr Link_ReceiveEchoedReply                                          ; FC1F23  1e b6 fc
	cp XIY,0xffffffff                                    ; FC1F26  ed cf ff ff ff ff
	jr z, .LFC1F37                                       ; FC1F2C  66 09
.LFC1F2E:
	and (XIY),0x3f                                       ; FC1F2E  85 3c 3f
	and (XIY+0x01),0x3f                                  ; FC1F31  8d 01 3c 3f
	jr .LFC1F3C                                          ; FC1F35  68 05
.LFC1F37:
	ld XIY,sub_FC1E68__FC1F49                                    ; FC1F37  45 49 1f fc 00
.LFC1F3C:
	ld a, 0x04:opc                                          ; FC1F3C  21 04
	call T_Kernel_SemaSignal                             ; FC1F3E  1d 88 2d f4
	popw hl                                              ; FC1F42  4b
	popw de                                              ; FC1F43  4a
	pop XBC                                              ; FC1F44  59
	pop W                                                ; FC1F45  c8 05
	pop XIX                                              ; FC1F47  5c
	ret                                                  ; FC1F48  0e
sub_FC1E68__FC1F49:
	nop                                                  ; FC1F49  00
	nop                                                  ; FC1F4A  00
; Cpu2Query_SendPartRecordRead: the 6-byte link request [0x81, B part, C offset, E count, reply channel 0, 0] at XIY, sent with
;   T_Link_SendBlockIn32ByteChunks.  Server byte 0x81 reaches prom_c's LinkQuery_ReplyPartRecordBytes (ToneMsg_Dispatch:
;   bits 0-2 = query arm 1, bit 3 clear), which returns E bytes of the part's record from offset C.
;   Basis: protocol pairing (notes/prom_ab_link_requests.py).
Cpu2Query_SendPartRecordRead:
	pushw de                                             ; FC1F4B  2a
	pushw bc                                             ; FC1F4C  29
	ld (XIY),0x81                                        ; FC1F4D  b5 00 81
	ld (XIY+0x01),B                                      ; FC1F50  bd 01 42
	ld (XIY+0x02),C                                      ; FC1F53  bd 02 43
	ld (XIY+0x03),E                                      ; FC1F56  bd 03 45
	ld (XIY+0x04),0x00                                   ; FC1F59  bd 04 00 00
	ld (XIY+0x05),0x00                                   ; FC1F5D  bd 05 00 00
	push XIY                                             ; FC1F61  3d
	pushw 0x06                                           ; FC1F62  0b 06 00
	pushw 0x00                                           ; FC1F65  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC1F68  1d d4 0e f4
sub_FC1F6C:
	inc 8,XSP                                            ; FC1F6C  ef 60
	popw bc                                              ; FC1F6E  49
	popw de                                              ; FC1F6F  4a
	ret                                                  ; FC1F70  0e
; Cpu2Query_SendToneRecordRead: [0x85, B, C, E, 0, 0]: the same request to LinkQuery_ReplyToneRecordBytes (query arm 5) -- E bytes of the tone
;   record from offset C.  Basis: protocol pairing.
Cpu2Query_SendToneRecordRead:
	pushw de                                             ; FC1F71  2a
	pushw bc                                             ; FC1F72  29
	ld (XIY),0x85                                        ; FC1F73  b5 00 85
	ld (XIY+0x01),B                                      ; FC1F76  bd 01 42
	ld (XIY+0x02),C                                      ; FC1F79  bd 02 43
	ld (XIY+0x03),E                                      ; FC1F7C  bd 03 45
	ld (XIY+0x04),0x00                                   ; FC1F7F  bd 04 00 00
	ld (XIY+0x05),0x00                                   ; FC1F83  bd 05 00 00
	push XIY                                             ; FC1F87  3d
	pushw 0x06                                           ; FC1F88  0b 06 00
	pushw 0x00                                           ; FC1F8B  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC1F8E  1d d4 0e f4
	inc 8,XSP                                            ; FC1F92  ef 60
	popw bc                                              ; FC1F94  49
	popw de                                              ; FC1F95  4a
	ret                                                  ; FC1F96  0e
sub_FC1F97:
	push XIX                                             ; FC1F97  3c
	push W                                               ; FC1F98  c8 04
	push XBC                                             ; FC1F9A  39
	pushw de                                             ; FC1F9B  2a
	pushw hl                                             ; FC1F9C  2b
	push_a                                               ; FC1F9D  14
	ld a, 0x04:opc                                          ; FC1F9E  21 04
	call T_Kernel_SemaWait                               ; FC1FA0  1d 90 2d f4
	pop_a                                                ; FC1FA4  15
	ld c, 0x23:opc                                          ; FC1FA5  23 23
	ldw de, 0x02                                         ; FC1FA7  32 02 00
	ld XIY,0x00000850                                    ; FC1FAA  45 50 08 00 00
	calr Cpu2Query_SendPartRecordRead_ReplyCh4                                      ; FC1FAF  1e 35 00
	ld a, 0x04:opc                                          ; FC1FB2  21 04
	call T_Kernel_SemaSignal                             ; FC1FB4  1d 88 2d f4
	popw hl                                              ; FC1FB8  4b
	popw de                                              ; FC1FB9  4a
	pop XBC                                              ; FC1FBA  59
	pop W                                                ; FC1FBB  c8 05
	pop XIX                                              ; FC1FBD  5c
	ret                                                  ; FC1FBE  0e
sub_FC1FBF:
	push XIX                                             ; FC1FBF  3c
	push W                                               ; FC1FC0  c8 04
	push XBC                                             ; FC1FC2  39
	pushw de                                             ; FC1FC3  2a
	pushw hl                                             ; FC1FC4  2b
	push_a                                               ; FC1FC5  14
	ld a, 0x04:opc                                          ; FC1FC6  21 04
	call T_Kernel_SemaWait                               ; FC1FC8  1d 90 2d f4
	pop_a                                                ; FC1FCC  15
	ld c, 0x20:opc                                          ; FC1FCD  23 20
	ldw de, 0x02                                         ; FC1FCF  32 02 00
	ld XIY,0x00000850                                    ; FC1FD2  45 50 08 00 00
	calr Cpu2Query_SendToneRecordRead_ReplyCh4                                      ; FC1FD7  1e 33 00
	ld a, 0x04:opc                                          ; FC1FDA  21 04
	call T_Kernel_SemaSignal                             ; FC1FDC  1d 88 2d f4
	popw hl                                              ; FC1FE0  4b
	popw de                                              ; FC1FE1  4a
	pop XBC                                              ; FC1FE2  59
	pop W                                                ; FC1FE3  c8 05
	pop XIX                                              ; FC1FE5  5c
	ret                                                  ; FC1FE6  0e
; Cpu2Query_SendPartRecordRead_ReplyCh4: Cpu2Query_SendPartRecordRead with reply channel 4 at +4.  Basis: protocol pairing.
Cpu2Query_SendPartRecordRead_ReplyCh4:
	pushw de                                             ; FC1FE7  2a
	pushw bc                                             ; FC1FE8  29
	ld (XIY),0x81                                        ; FC1FE9  b5 00 81
	ld (XIY+0x01),B                                      ; FC1FEC  bd 01 42
	ld (XIY+0x02),C                                      ; FC1FEF  bd 02 43
	ld (XIY+0x03),E                                      ; FC1FF2  bd 03 45
	ld (XIY+0x04),0x04                                   ; FC1FF5  bd 04 00 04
	ld (XIY+0x05),0x00                                   ; FC1FF9  bd 05 00 00
	push XIY                                             ; FC1FFD  3d
	pushw 0x06                                           ; FC1FFE  0b 06 00
	pushw 0x00                                           ; FC2001  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC2004  1d d4 0e f4
	inc 8,XSP                                            ; FC2008  ef 60
	popw bc                                              ; FC200A  49
	popw de                                              ; FC200B  4a
	ret                                                  ; FC200C  0e
; Cpu2Query_SendToneRecordRead_ReplyCh4: Cpu2Query_SendToneRecordRead with reply channel 4.  Basis: protocol pairing.
Cpu2Query_SendToneRecordRead_ReplyCh4:
	pushw de                                             ; FC200D  2a
	pushw bc                                             ; FC200E  29
	ld (XIY),0x85                                        ; FC200F  b5 00 85
	ld (XIY+0x01),B                                      ; FC2012  bd 01 42
	ld (XIY+0x02),C                                      ; FC2015  bd 02 43
	ld (XIY+0x03),E                                      ; FC2018  bd 03 45
	ld (XIY+0x04),0x04                                   ; FC201B  bd 04 00 04
	ld (XIY+0x05),0x00                                   ; FC201F  bd 05 00 00
	push XIY                                             ; FC2023  3d
	pushw 0x06                                           ; FC2024  0b 06 00
	pushw 0x00                                           ; FC2027  0b 00 00
	call T_Link_SendBlockIn32ByteChunks                                        ; FC202A  1d d4 0e f4
	inc 8,XSP                                            ; FC202E  ef 60
	popw bc                                              ; FC2030  49
	popw de                                              ; FC2031  4a
	ret                                                  ; FC2032  0e
	normal                                               ; FC2033  01
	normal                                               ; FC2034  01
; ---------------------------------------------------------------------
; SoundGroupName_Lookup -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_b T_SoundGroupName_Lookup (`jp`)
;          prom_a InstallPainter_SoundGroupMenu (`call` through T_SoundGroupName_Lookup) at 0xF92872
;          prom_a InstallPainter_GroupSoundDisplayHold (`call` through T_SoundGroupName_Lookup) at 0xF92D91
;          prom_a SoundGroupName_CopyToBuffer (`call` through T_SoundGroupName_Lookup) at 0xF9F67F
;
;     0xFC2070 loads 0xF068B4, where the ROM reads:
;        "PIANO           E.PIANO         HARPSI. & MALLET"
;     0xFC2077 loads 0xF069B4, where the ROM reads:
;        "BRASS           TRUMPET         DEEP BRASS      "
;     0xFC207E loads 0xF06AB4, where the ROM reads:
;        "DRUMS 1         DRUMS 2         ----------------"
;     0xFC2085 loads 0xF06BB4, where the ROM reads:
;        "DRUMS 1         --------------------------------"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; SoundGroupName_Lookup: T_SoundGroupName_Lookup (W = bank, A = group): XIY = a 16-character group name.  Local tables: ToneGroupNames (W 0, 2-7 and
;   above 0x2F), +0x100 (W 1), +0x200 (W 0x20-0x27), +0x300 (W 0x28-0x2F); RAM 0x5450 (W 0x19), 0x5660 (W 0x1A),
;   0x5240 (the other W 0x18-0x1F).  Read from CPU 2 with SoundGroupName_RequestRead: banks 8 and 0x0A-0x0F at
;   0xE80000 (groups 0-7) / 0xE90000 (8-15), bank 9 at 0xEA0000 / 0xEB0000, banks 0x10-0x17 at (0x08E0) - 0x10
;   while (0x08EC) bit 0 is set.  A failed read gives Msg0716_Str_GroupPair_B.
SoundGroupName_Lookup:
	cp w, 0x01:i3                                          ; FC2035  c8 d9
	jr z, .LFC2077                                       ; FC2037  66 3e
	cp W,0x08                                            ; FC2039  c8 cf 08
	jr c, .LFC2070                                       ; FC203C  67 32
	cp W,0x09                                            ; FC203E  c8 cf 09
	jrl z, .LFC20A9                                      ; FC2041  76 65 00
	cp W,0x10                                            ; FC2044  c8 cf 10
	jr c, .LFC2095                                       ; FC2047  67 4c
	cp W,0x18                                            ; FC2049  c8 cf 18
	jrl c, .LFC20BD                                      ; FC204C  77 6e 00
	cp W,0x19                                            ; FC204F  c8 cf 19
	jrl z, .LFC20FB                                      ; FC2052  76 a6 00
	cp W,0x1a                                            ; FC2055  c8 cf 1a
	jrl z, .LFC2102                                      ; FC2058  76 a7 00
	cp W,0x20                                            ; FC205B  c8 cf 20
	jrl c, .LFC20F4                                      ; FC205E  77 93 00
	cp W,0x28                                            ; FC2061  c8 cf 28
	jr c, .LFC207E                                       ; FC2064  67 18
	cp W,0x29                                            ; FC2066  c8 cf 29
	jr z, .LFC2085                                       ; FC2069  66 1a
	cp W,0x30                                            ; FC206B  c8 cf 30
	jr c, .LFC2085                                       ; FC206E  67 15
.LFC2070:
	ld XIY,ToneGroupNames                                ; FC2070  45 b4 68 f0 00
	jr .LFC208A                                          ; FC2075  68 13
.LFC2077:
	ld XIY,ToneGroupNames+0x100                                   ; FC2077  45 b4 69 f0 00
	jr .LFC208A                                          ; FC207C  68 0c
.LFC207E:
	ld XIY,ToneGroupNames+0x200                                   ; FC207E  45 b4 6a f0 00
	jr .LFC208A                                          ; FC2083  68 05
.LFC2085:
	ld XIY,ToneGroupNames+0x300                                   ; FC2085  45 b4 6b f0 00
.LFC208A:
	push XWA                                             ; FC208A  38
	xor W,W                                              ; FC208B  c8 d0
	mul WA,0x0010                                        ; FC208D  d8 08 10 00
	add XIY,XWA                                          ; FC2091  e8 85
	pop XWA                                              ; FC2093  58
	ret                                                  ; FC2094  0e
.LFC2095:
	ld XIY,0x00e80000                                    ; FC2095  45 00 00 e8 00
	cp A,0x08                                            ; FC209A  c9 cf 08
	jr c, .LFC20D4                                       ; FC209D  67 35
	and A,0x07                                           ; FC209F  c9 cc 07
	ld XIY,0x00e90000                                    ; FC20A2  45 00 00 e9 00
	jr .LFC20D4                                          ; FC20A7  68 2b
.LFC20A9:
	ld XIY,0x00ea0000                                    ; FC20A9  45 00 00 ea 00
	cp A,0x08                                            ; FC20AE  c9 cf 08
	jr c, .LFC20D4                                       ; FC20B1  67 21
	and A,0x07                                           ; FC20B3  c9 cc 07
	ld XIY,0x00eb0000                                    ; FC20B6  45 00 00 eb 00
	jr .LFC20D4                                          ; FC20BB  68 17
.LFC20BD:
	bit	0, (0x08ec:16)                               ; FC20BD  f1 ec 08 c8
	jr nz, .LFC20CA                                      ; FC20C1  6e 07
	ld XIY,Msg0716_Str_GroupPair_A+0x10                  ; FC20C3  45 45 21 fc 00
	jr .LFC20F3                                          ; FC20C8  68 29
.LFC20CA:
	ld xiy, (0x08e0:16)                                 ; FC20CA  e1 e0 08 25
	sub XIY,0x00000010                                   ; FC20CE  ed ca 10 00 00 00
.LFC20D4:
	push XIX                                             ; FC20D4  3c
	pushw wa                                             ; FC20D5  28
	pushw bc                                             ; FC20D6  29
	pushw de                                             ; FC20D7  2a
	pushw hl                                             ; FC20D8  2b
	ld XIX,XIY                                           ; FC20D9  ed 8c
	call SoundGroupName_RequestRead                                      ; FC20DB  1d 12 21 fc
	call T_Link_WaitBlockDone                            ; FC20DF  1d 3c 12 f4
	cp WA,0xffff                                         ; FC20E3  d8 cf ff ff
	jr nz, .LFC20EE                                      ; FC20E7  6e 05
	ld XIY,Msg0716_Str_GroupPair_B                       ; FC20E9  45 f3 21 fc 00
.LFC20EE:
	popw hl                                              ; FC20EE  4b
	popw de                                              ; FC20EF  4a
	popw bc                                              ; FC20F0  49
	popw wa                                              ; FC20F1  48
	pop XIX                                              ; FC20F2  5c
.LFC20F3:
	ret                                                  ; FC20F3  0e
.LFC20F4:
	ld XIY,SoundRemap1_GroupNames                                    ; FC20F4  45 40 52 00 00
	jr .LFC2107                                          ; FC20F9  68 0c
.LFC20FB:
	ld XIY,SoundRemap2_GroupNames                                    ; FC20FB  45 50 54 00 00
	jr .LFC2107                                          ; FC2100  68 05
.LFC2102:
	ld XIY,SoundRemap3_GroupNames                                    ; FC2102  45 60 56 00 00
.LFC2107:
	push XWA                                             ; FC2107  38
	xor W,W                                              ; FC2108  c8 d0
	mul WA,0x0010                                        ; FC210A  d8 08 10 00
	add XIY,XWA                                          ; FC210E  e8 85
	pop XWA                                              ; FC2110  58
	ret                                                  ; FC2111  0e
; SoundGroupName_RequestRead: T_Link_SendCommandE2 for the 16 bytes at CPU-2 XIX + 0x10 + A x 16 into 0x810.
SoundGroupName_RequestRead:
	add XIX,0x00000010                                   ; FC2112  ec c8 10 00 00 00
	xor W,W                                              ; FC2118  c8 d0
	mul WA,0x0010                                        ; FC211A  d8 08 10 00
	add XIX,XWA                                          ; FC211E  e8 84
	ld XIY,0x00000810                                    ; FC2120  45 10 08 00 00
	push XIY                                             ; FC2125  3d
	pushw 0x10                                           ; FC2126  0b 10 00
	push XIX                                             ; FC2129  3c
	call T_Link_SendCommandE2                            ; FC212A  1d f0 0e f4
	add XSP,0x0000000a                                   ; FC212E  ef c8 0a 00 00 00
	ret                                                  ; FC2134  0e
; ---------------------------------------------------------------------
; Msg0716_Str_GroupPair_A -- "Combi Group Name" then "EXT Silent Group"
;
; Two 16-byte strings, no terminators.  Evidence that they are two and not one:
; 0xFC20C3 loads 0x00FC2145 -- the SECOND of them -- as the fallback when bit 0
; of (0x08EC) is clear, so 0xFC2145 is an address the code forms.  0xFC2155 is
; a directory target (T_CombiGroupName_Lookup) and decodes as `cp W,0x08`.
; Unknown: what "EXT" abbreviates.
; ---------------------------------------------------------------------
Msg0716_Str_GroupPair_A:
	.byte 0x43, 0x6f, 0x6d, 0x62, 0x69, 0x20, 0x47, 0x72, 0x6f, 0x75, 0x70, 0x20, 0x4e, 0x61, 0x6d, 0x65  ; FC2135
	.byte 0x45, 0x58, 0x54, 0x20, 0x53, 0x69, 0x6c, 0x65, 0x6e, 0x74, 0x20, 0x47, 0x72, 0x6f, 0x75, 0x70  ; FC2145
; ---------------------------------------------------------------------
; CombiGroupName_Lookup -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_b T_CombiGroupName_Lookup (`jp`)
;          prom_a InstallPainter_CombinationGroupMenu (`call` through T_CombiGroupName_Lookup) at 0xF936A1
;          prom_a InstallPainter_GroupCombiDisplayHold (`call` through T_CombiGroupName_Lookup) at 0xF93961
;          prom_a CombiGroupName_CopyToBuffer (`call` through T_CombiGroupName_Lookup) at 0xF9F785
;
;     0xFC2187 loads 0xFC2203, where the ROM reads:
;        "EXT Silent Group"
;     0xFC21A7 loads 0xFC21F3, where the ROM reads:
;        "Combi Group NameEXT Silent Group"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; CombiGroupName_Lookup: T_CombiGroupName_Lookup (W = bank, A = group -- preset_bank.s calls it the bank name): read from CPU 2 with
;   CombiGroupName_RequestRead -- PromC_PresetBank_Header (W < 8 and W
;   above 0x1F: 0xF80200 + A x 16, 'FUSION COMBO1' ...), 0xEC0000 (W 8-15), (0x08E4) (W 0x10-0x17 while (0x08EC)
;   bit 1 is set); RAM 0x5AA0 (W 0x19), 0x5CB0 (W 0x1A), 0x5890 (the other W 0x18-0x1F).  Failure:
;   Msg0716_Str_GroupPair_B.
CombiGroupName_Lookup:
	cp W,0x08                                            ; FC2155  c8 cf 08
	jr c, .LFC2173                                       ; FC2158  67 19
	cp W,0x10                                            ; FC215A  c8 cf 10
	jr c, .LFC217A                                       ; FC215D  67 1b
	cp W,0x18                                            ; FC215F  c8 cf 18
	jr c, .LFC2181                                       ; FC2162  67 1d
	cp W,0x19                                            ; FC2164  c8 cf 19
	jr z, .LFC21B9                                       ; FC2167  66 50
	cp W,0x1a                                            ; FC2169  c8 cf 1a
	jr z, .LFC21C0                                       ; FC216C  66 52
	cp W,0x20                                            ; FC216E  c8 cf 20
	jr c, .LFC21B2                                       ; FC2171  67 3f
.LFC2173:
	ld XIY,PromC_PresetBank_Header                                   ; FC2173  45 00 00 f8 00
	jr .LFC2192                                          ; FC2178  68 18
.LFC217A:
	ld XIY,0x00ec0000                                    ; FC217A  45 00 00 ec 00
	jr .LFC2192                                          ; FC217F  68 11
.LFC2181:
	bit	1, (0x08ec:16)                               ; FC2181  f1 ec 08 c9
	jr nz, .LFC218E                                      ; FC2185  6e 07
	ld XIY,Msg0716_Str_GroupPair_B+0x10                  ; FC2187  45 03 22 fc 00
	jr .LFC21B1                                          ; FC218C  68 23
.LFC218E:
	ld xiy, (0x08e4:16)                                 ; FC218E  e1 e4 08 25
.LFC2192:
	push XIX                                             ; FC2192  3c
	pushw wa                                             ; FC2193  28
	pushw bc                                             ; FC2194  29
	pushw de                                             ; FC2195  2a
	pushw hl                                             ; FC2196  2b
	ld XIX,XIY                                           ; FC2197  ed 8c
	call CombiGroupName_RequestRead                                      ; FC2199  1d d0 21 fc
	call T_Link_WaitBlockDone                            ; FC219D  1d 3c 12 f4
	cp WA,0xffff                                         ; FC21A1  d8 cf ff ff
	jr nz, .LFC21AC                                      ; FC21A5  6e 05
	ld XIY,Msg0716_Str_GroupPair_B                       ; FC21A7  45 f3 21 fc 00
.LFC21AC:
	popw hl                                              ; FC21AC  4b
	popw de                                              ; FC21AD  4a
	popw bc                                              ; FC21AE  49
	popw wa                                              ; FC21AF  48
	pop XIX                                              ; FC21B0  5c
.LFC21B1:
	ret                                                  ; FC21B1  0e
.LFC21B2:
	ld XIY,CombiRemap1_GroupNames                                    ; FC21B2  45 90 58 00 00
	jr .LFC21C5                                          ; FC21B7  68 0c
.LFC21B9:
	ld XIY,CombiRemap2_GroupNames                                    ; FC21B9  45 a0 5a 00 00
	jr .LFC21C5                                          ; FC21BE  68 05
.LFC21C0:
	ld XIY,CombiRemap3_GroupNames                                    ; FC21C0  45 b0 5c 00 00
.LFC21C5:
	push XWA                                             ; FC21C5  38
	xor W,W                                              ; FC21C6  c8 d0
	mul WA,0x0010                                        ; FC21C8  d8 08 10 00
	add XIY,XWA                                          ; FC21CC  e8 85
	pop XWA                                              ; FC21CE  58
	ret                                                  ; FC21CF  0e
; CombiGroupName_RequestRead: T_Link_SendCommandE2 for the 16 bytes at CPU-2 XIX + 0x200 + A x 16 into 0x810.
CombiGroupName_RequestRead:
	add XIX,0x00000200                                   ; FC21D0  ec c8 00 02 00 00
	xor W,W                                              ; FC21D6  c8 d0
	mul WA,0x0010                                        ; FC21D8  d8 08 10 00
	add XIX,XWA                                          ; FC21DC  e8 84
	ld XIY,0x00000810                                    ; FC21DE  45 10 08 00 00
	push XIY                                             ; FC21E3  3d
	pushw 0x10                                           ; FC21E4  0b 10 00
	push XIX                                             ; FC21E7  3c
	call T_Link_SendCommandE2                            ; FC21E8  1d f0 0e f4
	add XSP,0x0000000a                                   ; FC21EC  ef c8 0a 00 00 00
	ret                                                  ; FC21F2  0e
; ---------------------------------------------------------------------
; Msg0716_Str_GroupPair_B -- a SECOND, byte-identical copy of the pair
;
; Evidence: the 32 bytes at 0xFC21F3 and at 0xFC2135 are equal, compared byte by
; byte.  Both copies are live: 0xFC20E9 and 0xFC21A7 load 0x00FC21F3 as a
; sentinel fallback, 0xFC2187 loads 0x00FC2203, and 0xFC20C3 loads 0x00FC2145
; out of the other copy.  The duplication is in the ROM, not in this listing.
; Unknown: why the module carries the pair twice when one copy would do.
; ---------------------------------------------------------------------
Msg0716_Str_GroupPair_B:
	.byte 0x43, 0x6f, 0x6d, 0x62, 0x69, 0x20, 0x47, 0x72, 0x6f, 0x75, 0x70, 0x20, 0x4e, 0x61, 0x6d, 0x65  ; FC21F3
	.byte 0x45, 0x58, 0x54, 0x20, 0x53, 0x69, 0x6c, 0x65, 0x6e, 0x74, 0x20, 0x47, 0x72, 0x6f, 0x75, 0x70  ; FC2203
sub_FC2213:
	ld a, (0x60a000:24)                                 ; FC2213  c2 00 a0 60 21
	ld b, (0x60a002:24)                                 ; FC2218  c2 02 a0 60 22
	ld w, (0x60a003:24)                                 ; FC221D  c2 03 a0 60 20
; ---------------------------------------------------------------------
; SoundGroup_MaxMemberIndex_Get -- returns the max-member-index byte for a sound group, from
;                                  one of three ROM maps or a RAM one, chosen by the group
;                                  selector in W
;
; Evidence: a `cp W` ladder at 0xFC2226-0xFC225A picks exactly one base:
;           0xFC225C `ld XIX,0x00F06EB4` =
;           GroupMaxMemberIndex_ToneGroups, 0xFC2263 `ld XIX,0x00F06EC4`
;           = GroupMaxMemberIndex_DrumGroups, 0xFC226A `ld
;           XIX,0x00F06ED4` = GroupMaxMemberIndex_DrumGroupsSecondWindow
;           and 0xFC2271 `ld XIX,0x000008C0`, a RAM base; 0xFC2276 `xor
;           W,W` and 0xFC2278 `ld A,(XIX+WA)` then read one byte at the
;           index in A. Those three ROM objects carry the reciprocal
;           citation in prom_b: each of their headers says `Read by:
;           prom_a sub_FC2222 (0xFC2222-0xFC2281)` and quotes the same
;           `ld XIX` immediate. Published by prom_b slot T_F4101C, which
;           eleven prom_a sites call
; Unknown:  the RAM base 0x08C0, which no header in this tree describes;
;           and 'MEMBER' is this tree's word for the second index, not
;           the ROM's -- the string occurs zero times in prom_a and
;           prom_b
; Was `sub_FC2222`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
SoundGroup_MaxMemberIndex_Get:
	push XIX                                             ; FC2222  3c
	pushw hl                                             ; FC2223  2b
	push W                                               ; FC2224  c8 04
	cp w, 0x01:i3                                          ; FC2226  c8 d9
	jr z, .LFC225C                                       ; FC2228  66 32
	cp W,0x08                                            ; FC222A  c8 cf 08
	jr c, .LFC225C                                       ; FC222D  67 2d
	cp W,0x09                                            ; FC222F  c8 cf 09
	jr z, .LFC225C                                       ; FC2232  66 28
	cp W,0x10                                            ; FC2234  c8 cf 10
	jr c, .LFC225C                                       ; FC2237  67 23
	cp W,0x18                                            ; FC2239  c8 cf 18
	jr c, .LFC2271                                       ; FC223C  67 33
	cp W,0x19                                            ; FC223E  c8 cf 19
	jr z, .LFC225C                                       ; FC2241  66 19
	cp W,0x1a                                            ; FC2243  c8 cf 1a
	jr z, .LFC225C                                       ; FC2246  66 14
	cp W,0x20                                            ; FC2248  c8 cf 20
	jr c, .LFC225C                                       ; FC224B  67 0f
	cp W,0x28                                            ; FC224D  c8 cf 28
	jr c, .LFC2263                                       ; FC2250  67 11
	cp W,0x29                                            ; FC2252  c8 cf 29
	jr z, .LFC226A                                       ; FC2255  66 13
	cp W,0x30                                            ; FC2257  c8 cf 30
	jr c, .LFC226A                                       ; FC225A  67 0e
.LFC225C:
	ld XIX,GroupMaxMemberIndex_ToneGroups                ; FC225C  44 b4 6e f0 00
	jr .LFC2276                                          ; FC2261  68 13
.LFC2263:
	ld XIX,GroupMaxMemberIndex_DrumGroups                ; FC2263  44 c4 6e f0 00
	jr .LFC2276                                          ; FC2268  68 0c
.LFC226A:
	ld XIX,GroupMaxMemberIndex_DrumGroupsSecondWindow    ; FC226A  44 d4 6e f0 00
	jr .LFC2276                                          ; FC226F  68 05
.LFC2271:
	ld XIX,0x000008c0                                    ; FC2271  44 c0 08 00 00
.LFC2276:
	xor W,W                                              ; FC2276  c8 d0
	ld	a, (xix+wa)                                  ; FC2278  c3 07 f0 e0 21
	pop W                                                ; FC227D  c8 05
	popw hl                                              ; FC227F  4b
	pop XIX                                              ; FC2280  5c
	ret                                                  ; FC2281  0e
; ---------------------------------------------------------------------
; SoundGroup_MaxMemberIndex_GetToneCopy -- the same lookup against GroupMaxMemberIndex_ToneGroupsCopy
;                                          and a different RAM base, over a SHORTER selector ladder
;
; Evidence: 0xFC22A3 `ld XIX,0x00F06EE4` =
;           GroupMaxMemberIndex_ToneGroupsCopy and 0xFC22AA `ld
;           XIX,0x000008D0`; 0xFC22AF `xor W,W` / 0xFC22B1 `ld
;           A,(XIX+WA)` is the same two-instruction read as
;           SoundGroup_MaxMemberIndex_Get's. Published by prom_b slot
;           T_F41034, which seven prom_a sites call. ⚠ AND THIS CORRECTS
;           A COMMITTED CITATION: prom_b's
;           GroupMaxMemberIndex_ToneGroupsCopy header says `Read by:
;           prom_a sub_FC2222 ... ld XIX,0x00F06EE4`. It is not:
;           0x00F06EE4 is loaded ONCE in all of prom_a, at 0xFC22A3,
;           which is past sub_FC2222's extent end 0xFC2281 and inside
;           THIS routine. prom_b is another lane's file this round, so
;           the fix is reported and not applied
; Unknown:  what distinguishes this arm from
;           SoundGroup_MaxMemberIndex_Get's: the two ladders test
;           overlapping selector ranges and this one has four fewer
;           tests, and nothing decoded here says which caller wants
;           which
; Was `sub_FC2282`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
SoundGroup_MaxMemberIndex_GetToneCopy:
	push XIX                                             ; FC2282  3c
	push W                                               ; FC2283  c8 04
	cp W,0x08                                            ; FC2285  c8 cf 08
	jr c, .LFC22A3                                       ; FC2288  67 19
	cp W,0x10                                            ; FC228A  c8 cf 10
	jr c, .LFC22A3                                       ; FC228D  67 14
	cp W,0x18                                            ; FC228F  c8 cf 18
	jr c, .LFC22AA                                       ; FC2292  67 16
	cp W,0x19                                            ; FC2294  c8 cf 19
	jr z, .LFC22A3                                       ; FC2297  66 0a
	cp W,0x1a                                            ; FC2299  c8 cf 1a
	jr z, .LFC22A3                                       ; FC229C  66 05
	cp W,0x20                                            ; FC229E  c8 cf 20
	jr c, .LFC22A3                                       ; FC22A1  67 00
.LFC22A3:
	ld XIX,GroupMaxMemberIndex_ToneGroupsCopy            ; FC22A3  44 e4 6e f0 00
	jr .LFC22AF                                          ; FC22A8  68 05
.LFC22AA:
	ld XIX,0x000008d0                                    ; FC22AA  44 d0 08 00 00
.LFC22AF:
	xor W,W                                              ; FC22AF  c8 d0
	ld	a, (xix+wa)                                  ; FC22B1  c3 07 f0 e0 21
	pop W                                                ; FC22B6  c8 05
	pop XIX                                              ; FC22B8  5c
	ret                                                  ; FC22B9  0e
; SoundSel_ToProgramAndBank: T_SoundSel_ToProgramAndBank (SoundConv_Arg0 group, _Arg1 member, _Arg3 bank code) -> SoundConv_Result0 program, _Result1 bank: the
;   preset banks (bank & 0x18 == 0: R1 0x00, R2 0x01, RD 0x20) through SoundCode_FromGroupMember_ModeOffset, the
;   RE-MAP banks 0x18-0x1A through SoundSel_ToProgramThroughRemap, the others (U1 / U2 0x08 / 0x09, E1 0x10)
;   through PanelSel_ToNumberDirect.  Basis: body; the bank codes are SoundSel_Bank's.
SoundSel_ToProgramAndBank:
	push XWA                                             ; FC22BA  38
	push XBC                                             ; FC22BB  39
	ld a, (SoundConv_Arg3:24)                                 ; FC22BC  c2 13 f0 60 21
	and A,0x18                                           ; FC22C1  c9 cc 18
	cp a, 0x00:i3                                          ; FC22C4  c9 d8
	jr z, .LFC22D3                                       ; FC22C6  66 0b
	cp A,0x18                                            ; FC22C8  c9 cf 18
	jr z, .LFC22D9                                       ; FC22CB  66 0c
	call PanelSel_ToNumberDirect                                      ; FC22CD  1d 30 23 fc
	jr .LFC22DD                                          ; FC22D1  68 0a
.LFC22D3:
	call SoundCode_FromGroupMember_ModeOffset                                      ; FC22D3  1d e0 22 fc
	jr .LFC22DD                                          ; FC22D7  68 04
.LFC22D9:
	call SoundSel_ToProgramThroughRemap                                      ; FC22D9  1d 4f 23 fc
.LFC22DD:
	pop XBC                                              ; FC22DD  59
	pop XWA                                              ; FC22DE  58
	ret                                                  ; FC22DF  0e
; ---------------------------------------------------------------------
; SoundCode_FromGroupMember_ModeOffset -- reads the (group, member) pair at (0x60F010)/(0x60F011),
;                                         looks the pair up in
;                                         SoundCodeByGroupMember_ModeOffsetGroup with the group
;                                         biased by the mode, and stores the word to
;                                         (0x60F014)/(0x60F015)
;
; Evidence: 0xFC22E0 `ld A,(0x60F010)`; 0xFC22E5-0xFC2307 add 0x10, 0x20
;           or 0x22 to it according to (0x60F013) and bit 2 of (0x7F4D)
;           -- that bias is what `ModeOffset` names; 0xFC230C `mul
;           WA,0x0010` is the 16-byte row stride, 0xFC2310 `ld
;           C,(0x60F011)` and 0xFC2317 `mul BC,0x0002` the 2-byte
;           column; 0xFC231D `add XBC,0x00F06EF4` is the table base,
;           which is SoundCodeByGroupMember_ModeOffsetGroup; 0xFC2325
;           and 0xFC232A store the two halves. prom_b's header for that
;           table carries the reciprocal citation, `Read by: prom_a
;           sub_FC22E0 (0xFC22E0-0xFC232F)`, with the same arithmetic.
;           One call site, 0xFC22D3
; Unknown:  what the 16-bit word ENCODES -- prom_b's own header says the
;           low byte is a kind and the high byte a value, and neither is
;           decoded
; Was `sub_FC22E0`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
SoundCode_FromGroupMember_ModeOffset:
	ld a, (SoundConv_Arg0:24)                                 ; FC22E0  c2 10 f0 60 21
	cp	(SoundConv_Arg3:24), 0x01                          ; FC22E5  c2 13 f0 60 3f 01
	jr z, .LFC22F7                                       ; FC22EB  66 0a
	cp	(SoundConv_Arg3:24), 0x20                          ; FC22ED  c2 13 f0 60 3f 20
	jr z, .LFC22FC                                       ; FC22F3  66 07
	jr .LFC230A                                          ; FC22F5  68 13
.LFC22F7:
	add A,0x10                                           ; FC22F7  c9 c8 10
	jr .LFC230A                                          ; FC22FA  68 0e
.LFC22FC:
	bit	2, (0x7f4d:16)                               ; FC22FC  f1 4d 7f ca
	jr nz, .LFC2307                                      ; FC2300  6e 05
	add A,0x20                                           ; FC2302  c9 c8 20
	jr .LFC230A                                          ; FC2305  68 03
.LFC2307:
	add A,0x22                                           ; FC2307  c9 c8 22
.LFC230A:
	xor W,W                                              ; FC230A  c8 d0
	mul WA,0x0010                                        ; FC230C  d8 08 10 00
	ld c, (SoundConv_Arg1:24)                                 ; FC2310  c2 11 f0 60 23
	xor B,B                                              ; FC2315  ca d2
	mul BC,0x0002                                        ; FC2317  d9 08 02 00
	add XBC,XWA                                          ; FC231B  e8 81
	add XBC,SoundCodeByGroupMember_ModeOffsetGroup       ; FC231D  e9 c8 f4 6e f0 00
	ld WA,(XBC)                                          ; FC2323  91 20
	ld (SoundConv_Result0:24), a                                 ; FC2325  f2 14 f0 60 41
	ld (SoundConv_Result1:24), w                                 ; FC232A  f2 15 f0 60 40
	ret                                                  ; FC232F  0e
; PanelSel_ToNumberDirect: SoundConv_Result0 = SoundConv_Arg0 x 8 + _Arg1 (group x 8 + member), _Result1 = _Arg3 (the bank code).  Shared
;   by SoundSel_ToProgramAndBank and CombiSel_ToNumberAndBank.  Basis: body.
PanelSel_ToNumberDirect:
	ld a, (SoundConv_Arg0:24)                                 ; FC2330  c2 10 f0 60 21
	ld w, (SoundConv_Arg1:24)                                 ; FC2335  c2 11 f0 60 20
	sla a, 0x03                                          ; FC233A  c9 ec 03
	or A,W                                               ; FC233D  c8 e1
	ld (SoundConv_Result0:24), a                                 ; FC233F  f2 14 f0 60 41
	ld a, (SoundConv_Arg3:24)                                 ; FC2344  c2 13 f0 60 21
	ld (SoundConv_Result1:24), a                                 ; FC2349  f2 15 f0 60 41
	ret                                                  ; FC234E  0e
; SoundSel_ToProgramThroughRemap: the word at SoundRemap1_Map / 2 / 3 (bank code 0x18 / 0x19 / 0x1A) + group x 16 + member x 2 ->
;   SoundConv_Result0 (program) / _Result1 (bank).  Basis: body; the maps sit in SoundRemap_Ram after each
;   bank's 16 group names (SoundGroupName_Lookup reads those).
SoundSel_ToProgramThroughRemap:
	ld a, (SoundConv_Arg0:24)                                 ; FC234F  c2 10 f0 60 21
	push XIX                                             ; FC2354  3c
	cp	(SoundConv_Arg3:24), 0x19                          ; FC2355  c2 13 f0 60 3f 19
	jr z, .LFC236C                                       ; FC235B  66 0f
	cp	(SoundConv_Arg3:24), 0x1a                          ; FC235D  c2 13 f0 60 3f 1a
	jr z, .LFC2373                                       ; FC2363  66 0e
	ld XIX,SoundRemap1_Map                                    ; FC2365  44 40 53 00 00
	jr .LFC2378                                          ; FC236A  68 0c
.LFC236C:
	ld XIX,SoundRemap2_Map                                    ; FC236C  44 50 55 00 00
	jr .LFC2378                                          ; FC2371  68 05
.LFC2373:
	ld XIX,SoundRemap3_Map                                    ; FC2373  44 60 57 00 00
.LFC2378:
	xor W,W                                              ; FC2378  c8 d0
	mul WA,0x0010                                        ; FC237A  d8 08 10 00
	ld c, (SoundConv_Arg1:24)                                 ; FC237E  c2 11 f0 60 23
	xor B,B                                              ; FC2383  ca d2
	mul BC,0x0002                                        ; FC2385  d9 08 02 00
	add XBC,XWA                                          ; FC2389  e8 81
	add XIX,XBC                                          ; FC238B  e9 84
	ld WA,(XIX)                                          ; FC238D  94 20
	ld (SoundConv_Result0:24), a                                 ; FC238F  f2 14 f0 60 41
	ld (SoundConv_Result1:24), w                                 ; FC2394  f2 15 f0 60 40
	pop XIX                                              ; FC2399  5c
	ret                                                  ; FC239A  0e
; CombiSel_ToNumberAndBank: T_CombiSel_ToNumberAndBank: the combination twin of SoundSel_ToProgramAndBank -- RE-MAP banks (bank & 0x18 == 0x18) through
;   CombiSel_ToNumberThroughRemap, every other bank PanelSel_ToNumberDirect.  Basis: body.
CombiSel_ToNumberAndBank:
	push XWA                                             ; FC239B  38
	push XBC                                             ; FC239C  39
	ld a, (SoundConv_Arg3:24)                                 ; FC239D  c2 13 f0 60 21
	and A,0x18                                           ; FC23A2  c9 cc 18
	cp A,0x18                                            ; FC23A5  c9 cf 18
	jr z, .LFC23B0                                       ; FC23A8  66 06
	call PanelSel_ToNumberDirect                                      ; FC23AA  1d 30 23 fc
	jr .LFC23B4                                          ; FC23AE  68 04
.LFC23B0:
	call CombiSel_ToNumberThroughRemap                                      ; FC23B0  1d b7 23 fc
.LFC23B4:
	pop XBC                                              ; FC23B4  59
	pop XWA                                              ; FC23B5  58
	ret                                                  ; FC23B6  0e
; CombiSel_ToNumberThroughRemap: the word at CombiRemap1_Map / 2 / 3 (0x5990 / 0x5BA0 / 0x5DB0, bank code 0x18 / 0x19 / 0x1A) + group x 16 +
;   member x 2 -> SoundConv_Result0 / _Result1.  Basis: body; CombiGroupName_Lookup reads the names before each map.
CombiSel_ToNumberThroughRemap:
	ld a, (SoundConv_Arg0:24)                                 ; FC23B7  c2 10 f0 60 21
	push XIX                                             ; FC23BC  3c
	cp	(SoundConv_Arg3:24), 0x19                          ; FC23BD  c2 13 f0 60 3f 19
	jr z, .LFC23D4                                       ; FC23C3  66 0f
	cp	(SoundConv_Arg3:24), 0x1a                          ; FC23C5  c2 13 f0 60 3f 1a
	jr z, .LFC23DB                                       ; FC23CB  66 0e
	ld XIX,CombiRemap1_Map                                    ; FC23CD  44 90 59 00 00
	jr .LFC23E0                                          ; FC23D2  68 0c
.LFC23D4:
	ld XIX,CombiRemap2_Map                                    ; FC23D4  44 a0 5b 00 00
	jr .LFC23E0                                          ; FC23D9  68 05
.LFC23DB:
	ld XIX,CombiRemap3_Map                                    ; FC23DB  44 b0 5d 00 00
.LFC23E0:
	xor W,W                                              ; FC23E0  c8 d0
	mul WA,0x0010                                        ; FC23E2  d8 08 10 00
	ld c, (SoundConv_Arg1:24)                                 ; FC23E6  c2 11 f0 60 23
	xor B,B                                              ; FC23EB  ca d2
	mul BC,0x0002                                        ; FC23ED  d9 08 02 00
	add XBC,XWA                                          ; FC23F1  e8 81
	add XIX,XBC                                          ; FC23F3  e9 84
	ld WA,(XIX)                                          ; FC23F5  94 20
	ld (SoundConv_Result0:24), a                                 ; FC23F7  f2 14 f0 60 41
	ld (SoundConv_Result1:24), w                                 ; FC23FC  f2 15 f0 60 40
	pop XIX                                              ; FC2401  5c
	ret                                                  ; FC2402  0e
; SoundSel_FromProgramAndBank: T_SoundSel_FromProgramAndBank (SoundConv_Arg0 program, _Arg1 bank, _Arg2 part) -> SoundConv_Result0 group, _Result1 member,
;   _Result2 bank code: banks with bits 3-4 (0x08-0x1F) through PanelSel_FromNumberDirect, the preset banks through
;   SoundSel_FromPresetProgramAndBank.  SysExParam_SetProgramChangeAndBank calls it after storing PROGRAM CHANGE &
;   BANK and writes the three results to the part's second record +0x1B / +0x1C / +0x1D, the bytes
;   SoundGroup_LoadSelectionFromPart reads as group / member / bank.  Basis: body + caller.
SoundSel_FromProgramAndBank:
	push XWA                                             ; FC2403  38
	push XBC                                             ; FC2404  39
	push XIX                                             ; FC2405  3c
	ld a, (SoundConv_Arg1:24)                                 ; FC2406  c2 11 f0 60 21
	ld W,A                                               ; FC240B  c9 88
	and A,0x18                                           ; FC240D  c9 cc 18
	cp a, 0x00:i3                                          ; FC2410  c9 d8
	jr z, .LFC241A                                       ; FC2412  66 06
	call PanelSel_FromNumberDirect                                      ; FC2414  1d c1 24 fc
	jr .LFC241E                                          ; FC2418  68 04
.LFC241A:
	call SoundSel_FromPresetProgramAndBank                                      ; FC241A  1d 22 24 fc
.LFC241E:
	pop XIX                                              ; FC241E  5c
	pop XBC                                              ; FC241F  59
	pop XWA                                              ; FC2420  58
	ret                                                  ; FC2421  0e
; ---------------------------------------------------------------------
; SoundSel_FromPresetProgramAndBank -- the same (group, member) -> (0x60F014)/(0x60F015) lookup,
;                                        against PanelSoundSel_ByProgramAndBank, with a RAM table
;                                        searched first when bit 2 of (0x7F4D) is set
;
; Evidence: 0xFC2422 `m_bit 2, MD16, 0x7f4d` chooses the arm. RAM arm:
;           0xFC2432 `ld XIX,0x00005760` and the 0xFC243B loop compare
;           the BC pair against 127 16-bit entries (0xFC2446 `cp
;           WA,0x00FE`). ROM arm: 0xFC245D/0xFC2462 read the same two
;           cells, 0xFC2467 or's 0x80 into the group when bit 5 of
;           (0x60F011) is set -- the FULL BYTE index that `ByteGroup`
;           names -- 0xFC246F `and C,0x07` masks the column, and
;           0xFC2472 `ld XIX,0x00F07134` is
;           PanelSoundSel_ByProgramAndBank's base; 0xFC24B1 and
;           0xFC24B6 store the halves. prom_b's header for that table
;           cites `prom_a 0xFC245D-0xFC2489` for exactly this
;           arithmetic. One call site, 0xFC241A
; Unknown:  what the RAM table at 0x5760 holds and who fills it, and
;           what the 0x1A/0x01/0x20 values loaded into C on the way out
;           select
; Was `sub_FC2422`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
; CORRECTED 2026-10-05 (was SoundCode_FromGroupMember_ByteGroup): it reads (program, bank), not (group, member).
;   SoundConv_Arg0 is the program and _Arg1 the bank (SysExParam_SetProgramChangeAndBank, SoundSel_GroupMemberFromProgramAndBank fill them so).
;   The table row is the program (| 0x80 when bank bit 5 is set), the column bank & 7; the word's low byte is the
;   group across R1 / R2 (+0x10) / RD (+0x20) -- classified into bank code 0x00 / 0x01 / 0x20 -- and its high byte
;   the member.  In GM mode (0x7F4D bit 2) a pair found in SoundRemap3_Map at index i gives group i >> 3, member
;   i & 7, bank 0x1A (RE-MAP 3).  All 272 panel selections of R1 / R2 / RD round-trip through
;   SoundCode_FromGroupMember_ModeOffset and this routine's table: notes/prom_ab_sound_selection_tables.py.
;   Basis: body + callers + ROM round trip.
SoundSel_FromPresetProgramAndBank:
	bit	2, (0x7f4d:16)                               ; FC2422  f1 4d 7f ca
	jr z, .LFC245D                                       ; FC2426  66 35
	ld c, (SoundConv_Arg0:24)                                 ; FC2428  c2 10 f0 60 23
	ld b, (SoundConv_Arg1:24)                                 ; FC242D  c2 11 f0 60 22
	ld XIX,SoundRemap3_Map                                    ; FC2432  44 60 57 00 00
	ld a, 0x00:opc                                          ; FC2437  21 00
	xor W,W                                              ; FC2439  c8 d0
.LFC243B:
	cp	bc, (xix+wa)                         ; FC243B  d3 07 f0 e0 f1
	jr z, .LFC244E                                       ; FC2440  66 0c
	add WA,0x0002                                        ; FC2442  d8 c8 02 00
	cp WA,0x00fe                                         ; FC2446  d8 cf fe 00
	jr ule, .LFC243B                                     ; FC244A  63 ef
	jr .LFC245D                                          ; FC244C  68 0f
.LFC244E:
	sra wa, 0x01                                         ; FC244E  d8 ed 01
	ld W,A                                               ; FC2451  c9 88
	and W,0x07                                           ; FC2453  c8 cc 07
	sra a, 0x03                                          ; FC2456  c9 ed 03
	ld c, 0x1a:opc                                          ; FC2459  23 1a
	jr .LFC24B1                                          ; FC245B  68 54
.LFC245D:
	ld a, (SoundConv_Arg0:24)                                 ; FC245D  c2 10 f0 60 21
	ld c, (SoundConv_Arg1:24)                                 ; FC2462  c2 11 f0 60 23
	bit 0x05,C                                           ; FC2467  cb 33 05
	jr z, .LFC246F                                       ; FC246A  66 03
	or A,0x80                                            ; FC246C  c9 ce 80
.LFC246F:
	and C,0x07                                           ; FC246F  cb cc 07
	ld XIX,PanelSoundSel_ByProgramAndBank              ; FC2472  44 34 71 f0 00
	xor W,W                                              ; FC2477  c8 d0
	extz XWA                                             ; FC2479  e8 12
	mul WA,0x0010                                        ; FC247B  d8 08 10 00
	xor B,B                                              ; FC247F  ca d2
	mul BC,0x0002                                        ; FC2481  d9 08 02 00
	add XBC,XWA                                          ; FC2485  e8 81
	add XIX,XBC                                          ; FC2487  e9 84
	ld WA,(XIX)                                          ; FC2489  94 20
	ld c, 0x00:opc                                          ; FC248B  23 00
	cp A,0x0f                                            ; FC248D  c9 cf 0f
	jr ule, .LFC24B1                                     ; FC2490  63 1f
	cp A,0x1f                                            ; FC2492  c9 cf 1f
	jr ule, .LFC24A5                                     ; FC2495  63 0e
	cp A,0x20                                            ; FC2497  c9 cf 20
	jr ule, .LFC24AC                                     ; FC249A  63 10
	cp A,0x21                                            ; FC249C  c9 cf 21
	jr ule, .LFC24AC                                     ; FC249F  63 0b
	ld a, 0x00:opc                                          ; FC24A1  21 00
	jr .LFC24B1                                          ; FC24A3  68 0c
.LFC24A5:
	sub A,0x10                                           ; FC24A5  c9 ca 10
	ld c, 0x01:opc                                          ; FC24A8  23 01
	jr .LFC24B1                                          ; FC24AA  68 05
.LFC24AC:
	sub A,0x20                                           ; FC24AC  c9 ca 20
	ld c, 0x20:opc                                          ; FC24AF  23 20
.LFC24B1:
	ld (SoundConv_Result0:24), a                                 ; FC24B1  f2 14 f0 60 41
	ld (SoundConv_Result1:24), w                                 ; FC24B6  f2 15 f0 60 40
	ld (SoundConv_Result2:24), c                                 ; FC24BB  f2 16 f0 60 43
	ret                                                  ; FC24C0  0e
; PanelSel_FromNumberDirect: SoundConv_Result0 = SoundConv_Arg0 >> 3 (group), _Result1 = _Arg0 & 7 (member), _Result2 = _Arg1 (the bank
;   code).  Basis: body.
PanelSel_FromNumberDirect:
	ld a, (SoundConv_Arg0:24)                                 ; FC24C1  c2 10 f0 60 21
	ld W,A                                               ; FC24C6  c9 88
	sra a, 0x03                                          ; FC24C8  c9 ed 03
	and W,0x07                                           ; FC24CB  c8 cc 07
	ld (SoundConv_Result0:24), a                                 ; FC24CE  f2 14 f0 60 41
	ld (SoundConv_Result1:24), w                                 ; FC24D3  f2 15 f0 60 40
	ld w, (SoundConv_Arg1:24)                                 ; FC24D8  c2 11 f0 60 20
	ld (SoundConv_Result2:24), w                                 ; FC24DD  f2 16 f0 60 40
	ret                                                  ; FC24E2  0e
; CombiSel_FromNumberAndBank: T_CombiSel_FromNumberAndBank: PanelSel_FromNumberDirect with XWA saved -- for a combination every bank is numbered group x 8 +
;   member.  Callers: ParamApply_Param98Tech and CombiSel_GroupMemberFromNumberAndBank (event class 0x98, COMBINATION NUMBER and BANK).
;   Basis: body + caller.
CombiSel_FromNumberAndBank:
	push XWA                                             ; FC24E3  38
	call PanelSel_FromNumberDirect                                      ; FC24E4  1d c1 24 fc
	pop XWA                                              ; FC24E8  58
	ret                                                  ; FC24E9  0e
	ret                                                  ; FC24EA  0e
; PartSound_FromProgramChange: T_PartSound_FromProgramChange (SoundConv_Arg2 program number, _Arg3 part) -> SoundConv_Result0 / _Result1 = the part's PROGRAM
;   CHANGE & BANK pair: parts 9 / 0x19 (the drum parts) take (the program, bank 0x20); the others the word
;   SoundRemap3_Map[program].  Callers: SmfEvent_ProgramChange / _MultiTrack (SMF playback),
;   ParamApply_PartProgMode3, which stores the pair to the part record's bytes 0 / 1.  Basis: body + callers.
PartSound_FromProgramChange:
	push XIX                                             ; FC24EB  3c
	pushw bc                                             ; FC24EC  29
	pushw wa                                             ; FC24ED  28
	cp	(SoundConv_Arg3:24), 0x09                          ; FC24EE  c2 13 f0 60 3f 09
	jr z, .LFC2500                                       ; FC24F4  66 0a
	cp	(SoundConv_Arg3:24), 0x19                          ; FC24F6  c2 13 f0 60 3f 19
	jr z, .LFC2500                                       ; FC24FC  66 02
	jr T,.LFC2509                                        ; FC24FE  68 09
.LFC2500:
	ld c, (SoundConv_Arg2:24)                                 ; FC2500  c2 12 f0 60 23
	ld b, 0x20:opc                                          ; FC2505  22 20
	jr .LFC251D                                          ; FC2507  68 14
.LFC2509:
	ld XIX,SoundRemap3_Map                                    ; FC2509  44 60 57 00 00
	ld a, (SoundConv_Arg2:24)                                 ; FC250E  c2 12 f0 60 21
	xor W,W                                              ; FC2513  c8 d0
	sla wa, 0x01                                         ; FC2515  d8 ec 01
	ld	bc, (xix+wa)                                 ; FC2518  d3 07 f0 e0 21
.LFC251D:
	ld (SoundConv_Result0:24), bc                                ; FC251D  f2 14 f0 60 51
	popw wa                                              ; FC2522  48
	popw bc                                              ; FC2523  49
	pop XIX                                              ; FC2524  5c
	ret                                                  ; FC2525  0e
; PartSound_ToProgramChange: T_PartSound_ToProgramChange (SoundConv_Arg0 / _Arg1 the part's PROGRAM CHANGE & BANK, _Arg2 part) -> SoundConv_Result0 / _Result1
;   a bank-select pair and _Result2 the program number to transmit: drum parts 9 / 0x19 -> the program, bank select 0;
;   bank above 7 -> 0, 0; a pair found in SoundRemap3_Map at index i -> program i, bank select 0; otherwise
;   ProgramChangeOut_ByProgramAndBank[program x 8 + bank & 7] (low byte the program, high byte to _Result1).  Callers:
;   Smf_WriteFile and its sizing passes, Evt2030_ProgChgMode3_Notify.  Basis: body + callers.
PartSound_ToProgramChange:
	push XIX                                             ; FC2526  3c
	pushw bc                                             ; FC2527  29
	pushw wa                                             ; FC2528  28
	ld bc, (SoundConv_Arg0:24)                                ; FC2529  d2 10 f0 60 21
	cp	(SoundConv_Arg2:24), 0x09                          ; FC252E  c2 12 f0 60 3f 09
	jr z, .LFC2540                                       ; FC2534  66 0a
	cp	(SoundConv_Arg2:24), 0x19                          ; FC2536  c2 12 f0 60 3f 19
	jr z, .LFC2540                                       ; FC253C  66 02
	jr .LFC2546                                          ; FC253E  68 06
.LFC2540:
	ld A,C                                               ; FC2540  cb 89
	xor BC,BC                                            ; FC2542  d9 d1
	jr .LFC2594                                          ; FC2544  68 4e
.LFC2546:
	cp b, 0x07:i3                                          ; FC2546  ca df
	jr ule, .LFC2550                                     ; FC2548  63 06
	xor BC,BC                                            ; FC254A  d9 d1
	ld a, 0x00:opc                                          ; FC254C  21 00
	jr .LFC2594                                          ; FC254E  68 44
.LFC2550:
	ld XIX,SoundRemap3_Map                                    ; FC2550  44 60 57 00 00
	ld a, 0x00:opc                                          ; FC2555  21 00
	xor W,W                                              ; FC2557  c8 d0
.LFC2559:
	cp	bc, (xix+wa)                         ; FC2559  d3 07 f0 e0 f1
	jr z, .LFC256C                                       ; FC255E  66 0c
	add WA,0x0002                                        ; FC2560  d8 c8 02 00
	cp WA,0x00fe                                         ; FC2564  d8 cf fe 00
	jr ule, .LFC2559                                     ; FC2568  63 ef
	jr .LFC2574                                          ; FC256A  68 08
.LFC256C:
	sra wa, 0x01                                         ; FC256C  d8 ed 01
	ldw bc, 0x00                                         ; FC256F  31 00 00
	jr .LFC2594                                          ; FC2572  68 20
.LFC2574:
	and B,0x07                                           ; FC2574  ca cc 07
	and C,0x7f                                           ; FC2577  cb cc 7f
	ld A,B                                               ; FC257A  ca 89
	xor B,B                                              ; FC257C  ca d2
	sla bc, 0x03                                         ; FC257E  d9 ec 03
	or C,A                                               ; FC2581  c9 e3
	sla bc, 0x01                                         ; FC2583  d9 ec 01
	ld XIX,ProgramChangeOut_ByProgramAndBank          ; FC2586  44 14 85 f0 00
	ld	bc, (xix+bc)                                 ; FC258B  d3 07 f0 e4 21
	ld A,C                                               ; FC2590  cb 89
	xor C,C                                              ; FC2592  cb d3
.LFC2594:
	ld (SoundConv_Result0:24), bc                                ; FC2594  f2 14 f0 60 51
	ld (SoundConv_Result2:24), a                                 ; FC2599  f2 16 f0 60 41
	popw wa                                              ; FC259E  48
	popw bc                                              ; FC259F  49
	pop XIX                                              ; FC25A0  5c
	ret                                                  ; FC25A1  0e
; DrumMap_MapNoteForPart_StackArgs: Stack-argument entry of DrumMap_MapNoteForPart: A = note (first word), B = part
;   (second word), then falls into it. Slot T_DrumMap_MapNoteForPart_StackArgs: PartNote_MapForToneGen passes the part block's +0x0E part and
;   the note. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
DrumMap_MapNoteForPart_StackArgs:
	ld A,(XSP+0x04)                                      ; FC25A2  8f 04 21
	ld B,(XSP+0x06)                                      ; FC25A5  8f 06 22
; DrumMap_MapNoteForPart: (A = note, B = part) When PartSound_GetBankAndToneFlag sets bit 5 for the part and the DRUMS
;   MAP code (0x7F4E) is USER1 / 2 / 3 (0x40 / 0x41 / 0x42), A = that user map's byte at the note (0x5EE0 / 0x5F70 /
;   0x6000, inside DrumMap_Ram); otherwise A unchanged. DrumEdit_DrawRowName names the mapped note,
;   PartNote_MapForToneGen sends it. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave9_a9.json)
DrumMap_MapNoteForPart:
	push W                                               ; FC25A8  c8 04
	push XIX                                             ; FC25AA  3c
	ld W,B                                               ; FC25AB  ca 88
	push_a                                               ; FC25AD  14
	call PartSound_GetBankAndToneFlag                                      ; FC25AE  1d 19 11 fc
	bit 0x05,A                                           ; FC25B2  c9 33 05
	pop_a                                                ; FC25B5  15
	jr z, .LFC25EA                                       ; FC25B6  66 32
	ld w, (0x7f4e:16)                                   ; FC25B8  c1 4e 7f 20
	and W,0xff                                           ; FC25BC  c8 cc ff
; (sub_FC25BF removed 2026-10-04: no code names it and the line above falls through into it -- part of DrumMap_MapNoteForPart;
;  notes/prom_a_stray_label_removal.py)
	cp W,0x40                                            ; FC25BF  c8 cf 40
	jr z, .LFC25D0                                       ; FC25C2  66 0c
	cp W,0x41                                            ; FC25C4  c8 cf 41
	jr z, .LFC25D7                                       ; FC25C7  66 0e
	cp W,0x42                                            ; FC25C9  c8 cf 42
	jr z, .LFC25DE                                       ; FC25CC  66 10
	jr .LFC25EA                                          ; FC25CE  68 1a
.LFC25D0:
	ld XIX,0x00005ee0                                    ; FC25D0  44 e0 5e 00 00
	jr .LFC25E3                                          ; FC25D5  68 0c
.LFC25D7:
	ld XIX,0x00005f70                                    ; FC25D7  44 70 5f 00 00
	jr .LFC25E3                                          ; FC25DC  68 05
.LFC25DE:
	ld XIX,0x00006000                                    ; FC25DE  44 00 60 00 00
.LFC25E3:
	xor W,W                                              ; FC25E3  c8 d0
	ld	a, (xix+wa)                                  ; FC25E5  c3 07 f0 e0 21
.LFC25EA:
	pop XIX                                              ; FC25EA  5c
	pop W                                                ; FC25EB  c8 05
	ret                                                  ; FC25ED  0e

; 0xFC25EE-0xFC2FFF -- 2578 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 2578, 1, 0x0E
; 0xFC3000-0xFC3FFF -- 4096 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: verified against original_ROMs/wsa1_prom_a.ic12.
	.fill 4096, 1, 0x0E
