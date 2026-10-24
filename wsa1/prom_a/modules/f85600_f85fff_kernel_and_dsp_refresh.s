
; ---------------------------------------------------------------------
; INTT3_KernelTick -- 8-bit timer 3: post one tick to the kernel's timer queue
;
; Called from: vector slot 0x4C (INTT3).  0xFFFF4C holds 0x00F42D64, a prom_b
;          thunk whose body is `jp 0xF85600`; reproduce with
;          `python3 notes/vector_map.py`, which follows both levels.
; Inputs:  none
; Outputs: (0xBE) incremented; control passed to IRQ_Epilogue, which decides
;          whether to reschedule.  No register is touched -- `inc 1,(mem)` and a
;          jump are the whole handler.
; Evidence: ★ (0xBE) IS THE KERNEL'S PENDING-TICK COUNT, and the kernel says so:
;          Kernel_Dispatch__drain_ticks (0xF85735, converted below) reads (0xBE),
;          and while it is non-zero decrements it by one and calls
;          Kernel_ServiceSoftTimers once per decrement.  A byte census of the
;          three memory-operand prefixes over prom_a and prom_b finds only three
;          real accesses to (0xBE): this increment, that read, and that write
;          back.  So this handler is the producer and the kernel is the sole
;          consumer.
;          It does not RETI: like INTT1_Tick and INTTR4_SequencerTick it exits
;          through IRQ_Epilogue (0xF857B7), whose own header already names this
;          address as one of its three entrants.
; Unknown:  ⚠ the tick RATE.  RESET programs timer 3 somewhere in the still
;          unconverted boot block; notes/FINDINGS-system-clock.md derives timer
;          1's rate, not timer 3's.
;          0xF85606, the byte after this handler, begins an unrelated routine
;          that sets XSP to the boot stack -- it is not part of the handler.
; ---------------------------------------------------------------------
INTT3_KernelTick:
	inc	1, (0xbe:8)                           ; F85600  c0 be 61   unidasm: inc 1,(0xbe)
	jrl IRQ_Epilogue                              ; F85603  78 b1 01

; ==============================================================================
; 0xF85606-0xF85E89 -- ★★ THE MULTITASKING KERNEL, SHARED WITH CPU 2
; ==============================================================================
;
; The 2,180 bytes that used to be written out here are now in kernel/kernel.s,
; ONE source prom_c includes as well: the same kernel runs on BOTH of the
; WSA1R's processors, and every pair of addresses differs by exactly 0x12B65.
; The routine headers that stood here moved there verbatim and now sit beside
; prom_c's headers for the same routines, each under a banner naming its file.
;
; kernel_maincpu.inc below supplies the 21 values that are CPU 1's rather than
; CPU 2's -- the stack top, the kernel RAM map, the array sizes.  Nothing else
; about the two copies differs.
;
; ★ prom_a GAINED 7 CONVERTED BYTES in the move: 0xF85C3D-0xF85C43 were the last
;   `.incbin` inside this block, and prom_c already had those same seven bytes
;   (`bf 0e 02 ff ff 68 f2`, identical in both EPROMs) decoded.
;
; ⚠ The proof is the byte gate, not this comment.  If a single equate were wrong
;   BOTH images would stop rebuilding:
;       python3 scripts/analysis/assert_byte_identical.py
;       python3 notes/kernel_join_probe.py --verify
; ==============================================================================
	.include "kernel/kernel_maincpu.inc"
	.include "kernel/kernel.s"


; ==============================================================================
; 0xF85E8A-0xF85F0E -- the task entry-point records, and the DSP refresh task
; ==============================================================================
;
; ★ THE SAME TABLE EXISTS IN BOTH PROCESSORS.  prom_c's lane already decoded a
;   run of 12-byte {entry, stack, ?} records at prom_c 0xF980EA and named it
;   EntryPoint_Records (prom_c/wsa1_prom_c.s, and the "three records" line of its
;   status header).  prom_a has the same structure at 0xF85E8A with FOUR records,
;   and the two tables agree field for field:
;
;     prom_c  7d 8b f9 00 | f0 ff 00 00 | 00 88 02 00     MAIN
;             db 54 fa 00 | 80 f9 00 00 | 00 88 02 00
;             18 81 f9 00 | 80 f4 00 00 | 00 88 01 00     DSP_ChannelRefresh_Loop
;     prom_a  5c 00 f4 00 | 00 e8 60 00 | 00 88 03 00
;             88 2e f4 00 | 80 e9 60 00 | 00 88 03 00
;             c8 5e f8 00 | 80 ec 60 00 | 00 88 01 00     DSP_RefreshTask (below)
;             c0 33 f4 00 | 00 eb 60 00 | 00 88 03 00
;
;   Seven records across the two images, and the halfword at +8 is 0x8800 in
;   every one of them.  Both tables give 0x0001 at +10 to the endless DSP
;   register-refresh entry and something larger to everything else.
;
; THE FIELDS, and how far each is established:
;   +0  LE32  ENTRY POINT.  All four of prom_a's decode as code; three of them
;             are prom_b thunk slots that `jp` straight back into prom_a --
;             0xF4005C -> 0xF827C8, 0xF42E88 -> 0xF8DA00, 0xF433C0 -> 0xFE02AB --
;             and the fourth, 0xF85EC8, is in prom_a directly, exactly as the
;             DSP entry is in prom_c.
;   +4  LE32  INITIAL STACK POINTER.  All four are in 0x0060E800-0x0060EC80, the
;             CS1 static RAM, and Kernel_Dispatch's own boot stack 0x0060EB80
;             (0xF8572B, converted above) sits inside the same run -- which is
;             what says this column is stacks and not data.
;   +8  LE16  0x8800 in all seven records.  READING, not a proof: a TLCS-900/H
;             status register with S=1 (system mode), MAX=1 and IFF=000 is
;             0x8800.  MAME resets this part to SR = 0xF800 and comments it
;             "system mode, iff set to 111, max mode, register bank 0"
;             (../mame/src/devices/cpu/tlcs900/tlcs900.cpp:218-219), and IFF is
;             the interrupt mask level -- tmp95c061.cpp:481 blocks every
;             interrupt while IFF == 7 and :538 scans levels from IFF upward.
;             So 0x8800 is the reset SR with the interrupt mask released, which
;             is exactly the SR a task should start with, and Kernel_ResumeTask
;             (0xF85763) does `pop SR` before its `ret` -- so a startable task
;             frame needs an SR word and a PC.  ⚠ WHAT IS MISSING: no site in
;             prom_a or prom_b writes the constant 0x8800 or pushes it, and no
;             code anywhere in either image names the address 0xF85E8A, so the
;             consumer of these records has not been found and the reading is
;             unconfirmed.
;   +10 LE16  ★ THE READY-QUEUE INDEX -- i.e. the task's PRIORITY.  0x0003 x3
;             and 0x0001 here; 0x0002 x2 and 0x0001 in prom_c.  The chain, added
;             after Kernel_YieldRotate was converted (0xF85877, above):
;               1. Kernel_Dispatch scans THREE list heads four bytes apart from
;                  0x0330 and takes the first non-empty one, so the heads are
;                  priority levels in scan order (0xF85746-0xF85759);
;               2. Kernel_YieldRotate and Kernel_RotateQueue address a head as
;                  0x032C + A*4, and A = 1, 2, 3 gives exactly 0x0330, 0x0334,
;                  0x0338 -- the same three;
;               3. SoftTimer_RotateLevel3 (0xF85EC2, below) calls Kernel_YieldRotate with
;                  A = 3, so the small integers really are used as that index;
;               4. all SEVEN +10 fields across prom_a and prom_c lie in 1..3 and
;                  never 0 or 4.
;             ⚠ Still a reading, for the same reason as +8: nothing that READS
;             this table has been found, so what is shown is that the values are
;             exactly the right shape for a queue index, not that they are used
;             as one.  1 is the level Kernel_Dispatch reaches FIRST, and 1 is
;             what both images give the endless DSP refresh task.
;
; COUNT = 4, and the last-entry test is what fixes it: a fifth record would
; start at 0xF85EBA, whose first word is 0x01000100 -- not in 0xF00000-0xFFFFFF
; and so not an entry point, while all four of the records above are.  The eight
; bytes from 0xF85EBA to 0xF85EC1 are emitted below as bytes and left
; unidentified; prom_c has a 4-byte trailer of the same flavour (0x01010001) in
; the same place.
;
; ⚠ NOTHING REFERENCES 0xF85E8A.  notes/prom_a_xref.py finds no `call`, `jp`,
;   `lda` or bare 32-bit pointer naming it in either image, and a scan of every
;   PC-relative `calr`/`jr`/`jrl` displacement finds none either.  Recorded as a
;   fact about the search, not as a claim that the table is dead.
; ---------------------------------------------------------------------
; EntryPoint_Records -- 4 x 12 bytes: {entry PC, initial XSP, SR?, ?}
;
; Read by:  nothing found -- see the block header.
; Layout:   +0 LE32 entry, +4 LE32 stack, +8 LE16 0x8800, +10 LE16 small int.
; Count:    4, 48 bytes, 0xF85E8A-0xF85EB9.  Verified by the last-entry test in
;           the block header and by notes/prom_a_byte_checks.py.
; Evidence: field-by-field above; the name is prom_c's, for the same structure
;           in the other processor's image.
; ---------------------------------------------------------------------
EntryPoint_Records:
	.long T_MainTask_Entry, 0x0060E800			; F85E8A  thunk -> 0xF827C8
	.short 0x8800, 0x0003
	.long T_Task2_CallbackDispatcher, 0x0060E980			; F85E96  thunk -> 0xF8DA00
	.short 0x8800, 0x0003
	.long DSP_RefreshTask, 0x0060EC80			; F85EA2  DSP_RefreshTask, in prom_a
	.short 0x8800, 0x0001
	.long T_MidiFileStream_ReaderTask, 0x0060EB00			; F85EAE  thunk -> 0xFE02AB
	.short 0x8800, 0x0003
	; 0xF85EBA-0xF85EC1: IDENTIFIED 2026-08-25 -- it is a ROM IMAGE OF RAM.
	; Kernel_InitRam (0xF85653-0xF85661, converted above) does
	; `ld XHL,0x00F85EBA / ld DE,0x035C / ld BC,0x0008 / ldir`, copying exactly
	; these eight bytes to 0x035C-0x0363.  Still NOT a fifth record --
	; 0x01000100 is not an address -- and what the eight bytes MEAN once they
	; are in RAM is still open; only their destination is established.
	; prom_c has 01 00 01 01 in the same position.
	.byte 0x00, 0x01, 0x00, 0x01			; F85EBA
	.byte 0x00, 0x00, 0x00, 0x00			; F85EBE

; SoftTimer_RotateLevel3 -- the boot software timer's callback: round-robin ready queue 3
; Evidence: its address is the +4 callback of SoftTimer_Request_Boot (kernel.s 0xF856E4, KERNEL_BOOT_TIMER_CALLBACK = 0x00F85EC2 in kernel/kernel_maincpu.inc), which SoftTimer_Register installs in software-timer slot 1; body `ld A,3 / calr Kernel_YieldRotate` (0xF85877) / `ret`.
; prom_c's same-position callback is SoftTimer_RotateLevel2 with A=2; as there, the `ret` is unreachable because Kernel_YieldRotate leaves through Kernel_Dispatch or Kernel_ResumeTask.
SoftTimer_RotateLevel3:
	ld a, 0x03:opc                                   ; F85EC2  21 03
	calr (0xF85877 - 0xF85EC7)                    ; F85EC4  1e b0 f9   the blocking primitive
	ret                                           ; F85EC7  0e

; ---------------------------------------------------------------------
; DSP_RefreshTask -- for ever: take a block off queue 1, push it to all four
;                    DSP channels
;
; Called from: NOTHING calls it.  Its address is the entry field of the THIRD
;          EntryPoint_Records record (0xF85EA2), paired with the stack
;          0x0060EC80.  That is the only reference to it in either image
;          (notes/prom_a_xref.py 0xF85EC8, plus the PC-relative scan).
; Inputs:  whatever 0xF85C89 hands back in XIY for selector 1; then four
;          consecutive 32-bit pointers read from that block with `ld XIY,(XDE+)`.
; Outputs: never returns.  Each pass writes 8 registers in each of channels
;          0, 1, 2, 3 of the DSP register file at 0x7F0000.
; Evidence: 1. the loop is closed by an unconditional `jr` back to 0xF85ECE,
;             which is INSIDE the frame the `link XIZ,0xFFFC` at 0xF85ECA opened
;             -- a frame built once with the loop below it is an entry point, not
;             a subroutine;
;          2. the four calls are DSP_ChannelRegs_Write8 (0xF85F59,
;             converted below), each `push XIY / pushw channel / call /
;             inc 6,XSP`, which is that routine's stack argument list exactly,
;             with the channel numbers 0,1,2,3 in order;
;          3. it opens with `ei 0x00`, releasing the interrupt mask -- see the
;             note on that below.
;          4. prom_c has the same task at 0xF98118 for its own DSP port, listed
;             in its own EntryPoint_Records with the same 0x0001 at +10
;             (prom_c/wsa1_prom_c.s, DSP_ChannelRefresh_Loop).
; Notes:   ⚠ `ei 0x00` ENABLES interrupts, it does not disable them.  EI sets the
;          IFF mask level (MAME op_EI, 900tbl.hxx:2073-2078: SR bits 6-4 :=
;          imm & 7); tmp95c061.cpp:481 skips interrupt dispatch only while
;          IFF == 7, and :538 scans priority levels from IFF upward, so IFF = 0
;          accepts everything and IFF = 7 is DI.  This file's own kernel agrees:
;          Kernel_Idle (0xF85711) does `ei 0x00` and then spins, and
;          Kernel_ServiceSoftTimers brackets its scan with `ei 0x00` ... `ei 0x06`
;          -- an idle loop does not run with interrupts off, and a critical
;          section is the one that RAISES the number.
;          ⚠ AND llvm-mc IS WHY THAT IS EASY TO GET WRONG: this assembler accepts
;          `di` on tlcs900 and emits `06 00`, byte for byte the same as
;          `ei 0x00`.  The alias says one thing and does the other, and the byte
;          gate cannot tell.  Probe and write-up in
;          notes/llvm-mc-tlcs900-spellings.md.  prom_c/wsa1_prom_c.s uses that
;          spelling and its DSP_ChannelRefresh_Loop header concludes the task
;          "starts by disabling interrupts ... and never re-enables them", which
;          is backwards; flagged here rather than edited, because prom_c is
;          another lane's file.
; Unknown:  what 0xF85C89 selector 1 dequeues, and hence what the four pointers
;          point at; whether anything ever selects this entry point.
; ---------------------------------------------------------------------
DSP_RefreshTask:
	ei 0x00                                       ; F85EC8  06 00   IFF := 0, i.e. accept every interrupt
	link XIZ,0xfffc                               ; F85ECA  ee 0c fc ff   4-byte frame, built ONCE
DSP_RefreshTask__pass:
	pushw 0x01                                    ; F85ECE  0b 01 00   selector 1
	call MsgQueue_ReceiveBlocking_StackArg                                 ; F85ED1  1d 89 5c f8   dequeue; returns a block in XIY
	inc 2,XSP                                     ; F85ED5  ef 62
	ld XDE,XIY                                    ; F85ED7  ed 8a   XDE walks the block
	ld xiy, (xde+)                             ; F85ED9  e5 ea 25   ld XIY,(XDE+) -- pointer for channel 0
	push XIY                                      ; F85EDC  3d
	pushw 0x00                                    ; F85EDD  0b 00 00
	call DSP_ChannelRegs_Write8           ; F85EE0  1d 59 5f f8
	inc 6,XSP                                     ; F85EE4  ef 66
	ld xiy, (xde+)                             ; F85EE6  e5 ea 25   ld XIY,(XDE+) -- channel 1
	push XIY                                      ; F85EE9  3d
	pushw 0x01                                    ; F85EEA  0b 01 00
	call DSP_ChannelRegs_Write8           ; F85EED  1d 59 5f f8
	inc 6,XSP                                     ; F85EF1  ef 66
	ld xiy, (xde+)                             ; F85EF3  e5 ea 25   ld XIY,(XDE+) -- channel 2
	push XIY                                      ; F85EF6  3d
	pushw 0x02                                    ; F85EF7  0b 02 00
	call DSP_ChannelRegs_Write8           ; F85EFA  1d 59 5f f8
	inc 6,XSP                                     ; F85EFE  ef 66
	ld xiy, (xde+)                             ; F85F00  e5 ea 25   ld XIY,(XDE+) -- channel 3
	push XIY                                      ; F85F03  3d
	pushw 0x03                                    ; F85F04  0b 03 00
	call DSP_ChannelRegs_Write8           ; F85F07  1d 59 5f f8
	inc 6,XSP                                     ; F85F0B  ef 66
	jr DSP_RefreshTask__pass                      ; F85F0D  68 bf   for ever

; ==============================================================================
; 0xF85F0F-0xF85FF8 -- ★★ THE DSP CHANNEL-REGISTER DRIVER, SHARED WITH prom_c
; ==============================================================================
;
; These 234 bytes are no longer written out here.  They are dsp/dsp_channel_regs.s,
; ONE source that assembles into prom_a at 0xF85F0F AND into prom_c at 0xF98000 --
; 231 of the 234 bytes are the same byte in the two EPROMs, and the three that
; are not are A23..A16 of each routine's base literal, 0x7F on this processor and
; 0xE0 on the other.  That is the whole difference between the two copies.
;
; The routine headers that stood here moved there verbatim and now sit beside
; prom_c's headers for the same four routines, each under a banner naming its
; file.  So does the 0xF85F59 region banner that documented 0x7F0000.
;
; dsp/dsp_channel_regs_maincpu.inc below supplies the ONE value that is CPU 1's
; rather than CPU 2's: DSP_REGS_BASE, the register file's address.  Nothing else
; about the two copies differs, so there is no conditional anywhere in the body.
;
; ★ prom_a GAINS AN HONEST NUMBER in the move: it wrote `inc 0,XSP` at 0xF85FA3,
;   which spells the ENCODED FIELD; prom_c wrote `inc 8, xsp`, which spells the
;   +8 the CPU performs.  Both assemble to ef 60 and the merged source takes
;   prom_c's.  prom_a's spelling is preserved on that line as `a: inc 0,XSP`.
;
; ⚠ The proof is the byte gate, not this comment.  If the equate were wrong THIS
;   image would stop rebuilding:
;       python3 scripts/analysis/assert_byte_identical.py
;       python3 notes/sound/wsa1_dsp_join_probe.py --verify
; ==============================================================================
	.include "dsp/dsp_channel_regs_maincpu.inc"
	.include "dsp/dsp_channel_regs.s"
; ==== 0xF85FF9-0xF89800 -- emitted by notes/gen_prom_a_f85ff9_module.py ====
; Layout from notes/prom_a_f85ff9_layout.py; audited by notes/prom_a_f85ff9_verify.py
; ("NOT REFUTED AS A LAYOUT, REFUTED AS A DOSSIER"), so the tiling is taken and
; the prose is re-derived here.  `--selftest` reproduces every number below.
; This text was assembled and byte-compared with the ROM before printing.

; --- 0xF85FF9-0xF85FFF  pad (7 bytes) ---
	.fill 7, 1, 0x0E
