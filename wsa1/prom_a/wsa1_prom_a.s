	.text

; ==============================================================================
; Technics SX-WSA1R -- wsa1_prom_a.ic12
; Target CPU: Toshiba TMP95C061 (TLCS-900/H), "CPU 1" / IC1
; ==============================================================================
;
; IC12, program EPROM, base 0xF80000.  Load address ESTABLISHED: 33 of 64 words
; at file offset 0x7FF00 point into 0xF00000-0xFFFFFF, which is where a
; TMP95C061 fetches its reset PC (0xFFFF00).  The reset word itself is
; 0x00F826A9 and the code there is a textbook TLCS-900 boot block, which settles
; it.
;
; prom_a and prom_b (base 0xF00000) are one contiguous 1 MiB program image on the
; same bus; see prom_b/wsa1_prom_b.s for the four proofs of B's base.
;
; STATUS: partially converted.  Regenerate the figure with
; `python3 scripts/analysis/source_coverage.py`; it is not maintained by hand
; here, because a hand-maintained one in README.md was wrong for a commit.
;
; ⚠ THAT TOOL COUNTS `.fill` AS CONVERTED (round-1 audit, F1), which can inflate
; an image's figure by tens of points, so it now reports SUBSTANTIVE and FILLER
; separately and the substantive column is the one to quote.  Every `.fill` in
; prom_a is 0x0E (RET) module padding, and each is introduced by a comment
; naming the exact range it covers.
;
; ⚠ DO NOT COUNT THEM HERE.  This paragraph has now been wrong twice: it said
; "this file's only `.fill` is the 108-byte RET padding" until the commit that
; added two more, and then "THREE `.fill` runs, 6,122 bytes in total" while the
; file already held eight of them and 10,078 bytes.  A hand-kept list of pads
; rots at exactly the rate pads are added.  The AUTHORITY is
; notes/prom_a_byte_checks.py, which parses this file's own `.fill` lines and
; their range comments and asserts three things about every one: the stated
; range really is uniform 0x0E, its length really is the `.fill`'s, and no
; `.fill` in the file lacks such a comment.  The TOTAL is
; `python3 scripts/analysis/source_coverage.py`'s filler column, and the same
; check asserts that the two agree.
;
; Converted so far, as real assembly (everything else is still .incbin, so it
; builds byte-exact by construction and asserts nothing):
;
;   0xF80000-0xF826A8  9897  ★★ THE BOOT BLOCK -- the 25-module INITIALISATION
;                            DIRECTORY at 0xF82641 that the machine is brought up
;                            by (five phases, one walker, twelve instructions),
;                            five blink-argument tables, a 37-character set, and
;                            ~150 UI veneers that are sub_XXXXXX on purpose
;                            (notes/FINDINGS-prom_a-boot-and-version-screen.md,
;                            notes/prom_a_boot_checks.py -- 90 checks)
;   0xF826A9-0xF827C7   287  RESET, the whole boot path to its jump into prom_b
;   0xF827C8-0xF82CFE  1335  ★★★ THE POWER-ON BLOCK -- and the answer to
;                            EMULATION GAP D.  VersionScreen_Show reads 11 bytes
;                            from remote 0x00F7FFF0 and displays them under the
;                            ASCII label "WSA-D:"; prom_d's last sixteen bytes are
;                            "wsad_54.ssf", and the firmware carries a branch
;                            shaped for that tag and no other.  So prom_d is the
;                            image at CPU 2 0x00F00000-0x00F7FFFF, NOT the
;                            0xE80000 flash.  Also: (0x00C4), the model-variant
;                            flag, comes from PORT B BIT 0; the three power-on
;                            chords and both their variants; and the expansion
;                            board's ASCII magic "WSA1 EXTBD" at remote 0x00C00000
;   0xF92C62-0xF96017 13238  UI screen code and SEVEN pointer tables; answers no
;                            emulation gap, taken because the frontier ranked it.
;                            Carries the service CHECKING DEVICE routine 0xF95137
;                            (gap L) and two panel-shadow dispatchers
;                            (notes/FINDINGS-prom_a-ui-screen-blocks.md)
;   0xF99021-0xFA1403 33763  ★ THE LARGEST SPAN IN THIS IMAGE.  Five of the
;                            frontier's top twelve runs; 132 directory targets,
;                            all on an instruction boundary of one decode; 15
;                            pointer tables that a linear decode would have
;                            emitted as code, found by shape with a null control
;                            (notes/prom_a_ptr_tables.py) and cross-checked
;                            against thirteen readers' own `cp` bounds.  ★ It
;                            names NO device address at all
;                            (notes/prom_a_uiblock_checks.py -- 109 checks)
;   0xF82CFF-0xF830C5   967  INTWD, the unused-vector trap, INTT1 and INTTR4 with
;                            their dispatch tables, the event-buffer append, NMI
;                            (power-fail) and its checksum helper
;   0xF830C6-0xF83215   336  SeqBuf_AppendEvent, the alternate INTTR4 tail, and
;                            the driver for the 0x7F0000 address/data register
;                            pair with its four slot entries
;   0xF84000-0xF842DE   735  ★ the BYTE RING-BUFFER CLASS -- five operations
;                            (Get, Scan, ScanToPut, Put, Init) emitted once per
;                            ring capacity (0x80 0x100 0x200 0x400 0x1000).  Ten
;                            of the 25 have no reference anywhere
;   0xF842DF-0xF84C6B  2445  the INSTANCE BANK: 15 groups of 11 veneers over 14
;                            distinct rings, 126 of them published through the
;                            prom_b directory module T_Ring608A0A_Get (T_F41CD0)
;                            (notes/FINDINGS-prom_a-ring-buffers.md)
;   0xF8BC00-0xF8BF21   802  the ASCII numeric field -- parse, format, clear --
;                            and SignedNibbleDelta_Table, 32 bytes of signed
;                            nibble deltas emitted as data, not decoded
;   0xF8DA00-0xF8DAB9   186  ★ the CALLBACK QUEUE and kernel task 2, which
;                            drains it.  The most heavily referenced module in
;                            prom_a: 329 references into 131 bytes
;   0xF8DC00-0xF8DDE5   486  the ANALOGUE CONTROL SCAN: four A/D channels and
;                            two software ones, one deadband filter.  ⚠ EIGHT
;                            call sites of T_Ctrl_Normalise (T_F405F0) for SIX channels: two of its
;                            routines are emitted twice, byte for byte
;   0xF89800-0xF89FBE  1983  ★★ the CONTINUOUS-CONTROL NORMALISER -- the routine
;                            emulation gap E.3 asks about.  A 32-slot dispatcher
;                            on W, a 34-entry LE32 handler table, TEN live
;                            handlers and EIGHT response-curve tables that tile
;                            0xF89AB4-0xF89FBE.  Group 0 is the on-board analogue
;                            scan (proved by its eight call sites, W = 0..5);
;                            group 3 is four more controls of the same kind, and
;                            prom_b's SC1 receive decoder calls the SAME slot
;                            with a RECEIVED byte -- so the SC1 peer's controls
;                            and the on-board pots share one normalising path.
;                            Carry set = "the cooked value changed".  One curve
;                            (0xF89E34) has NO reference anywhere
;                            (notes/FINDINGS-prom_a-control-normaliser.md,
;                            notes/prom_a_ctrl_checks.py, which PRINTS its own
;                            check count as its first line -- do not copy a
;                            number here, it went stale twice).  A further
;                            65 bytes of 0x0E follow as `.fill`
;   0xF8E000-0xF8E47E  1151  the 0x7C0000 link port's block-transfer layer
;                            (routines mostly still sub_XXXXXX)
;   0xFEF746-0xFF3800 11044  ★ the SCREEN-DRAW module: 56 inline DISPLAY LISTS
;                            whose framing is PROVED (the length bytes walk
;                            from each call site's start immediate onto its end
;                            immediate, 56 of 56), 13 tables including the GM
;                            drum-kit CATEGORY LEGENDS, and 3,956 bytes of the
;                            code that runs them.  Carries much of the machine's
;                            UI text: SEQUENCER, REALTIME, MASTER, REC0RD,
;                            ASSIGN, MEDLEY, NOTE EDIT, DRUM EDIT and two help
;                            panels.  A further 5,526 bytes of 0x0E follow as
;                            `.fill` and are NOT in that figure
;                            (notes/gen_prom_a_screens.py --check,
;                            notes/FINDINGS-prom_a-screen-module.md)
;   0xFE0000-0xFE54B5 21686  ⚠ application code, CONVERTED BUT NOT NAMED.  Real
;                            assembly with certified instruction boundaries and
;                            323 sub_XXXXXX labels; read its banner before
;                            quoting the coverage figure
;   0xFAA000-0xFAD7FF 14336  ★ the 0x60F0xx MESSAGE MODULE -- 34 published
;                            veneers, a 256-entry command dispatcher, four
;                            INLINE jump tables, eight data tables, and TWO
;                            duplicated regions that nothing names
;                            (notes/FINDINGS-prom_a-message-module.md)
;   0xFC5400-0xFC6FFF  7168  its sibling module: one inline jump table, a second
;                            copy of the 32 powers of two, and a 32-entry
;                            dispatch table.  Ends in a 1,979-byte 0x0E pad
;   0xFC0000-0xFC2FFF 12288  ★ the 0x0716 MESSAGE MODULE -- 9,710 substantive
;                            bytes plus a 2,578-byte 0x0E pad.  Two byte-identical
;                            index dispatchers, TEN handler tables that tile
;                            0xFC09CE-0xFC0BD9 exactly (131 entries, count taken
;                            from ten `cp L,A` bounds), 32 eight-byte object
;                            records, a 32-entry RAM-record pointer table with one
;                            deliberate 0x80 step, five default messages and four
;                            fallback strings.  It carries 165 directory slots and
;                            164 distinct targets -- more than any other 12 KiB of
;                            prom_a -- of which 34 are a bare `ret` and five are
;                            not instruction boundaries at all
;                            (notes/FINDINGS-prom_a-msg0716-module.md,
;                            notes/prom_a_fc0000_module_check.py: 128 checks)
;   0xFC8000-0xFCEFFF 18559  ★ the RAM-0x3800 MODULE (a further 10,113 bytes of
;                            0x0E follow as `.fill` and are NOT in that figure).
;                            It carries its own C-RUNTIME INITIALISER -- four
;                            linker-shaped blocks whose every length, source and
;                            destination is a literal -- so its RAM (0x003800-
;                            0x004365, 0x602000-0x6020F3) and its 2,918-byte ROM
;                            data image at 0xFCB3D3 are read off the immediates.
;                            A published SHORT copy of the initialiser reloads
;                            the data image alone.  Nine-entry inline jump table;
;                            a second, differently capped copy of the 32-entry
;                            record-pointer ladder; client of SEVEN of CPU 1's
;                            ring buffers and of the link block sender
;                            (notes/FINDINGS-prom_a-msg0716-module.md,
;                            notes/prom_a_fc8000_module_check.py: 77 checks)
;   0xF85600-0xF85605     6  INTT3_KernelTick, the kernel's timer-3 handler
;   ★ 0xF85606-0xF85E89 IS NOT WRITTEN OUT IN THIS FILE ANY MORE.  Since
;     2026-08-30 the whole kernel is `kernel/kernel.s`, ONE source that prom_c
;     includes too -- the two CPUs run the same kernel and every pair of
;     addresses differs by exactly 0x12B65.  The rows below still describe what
;     is at each address; the text lives there.  kernel_maincpu.inc names the 21
;     values that are CPU 1's rather than CPU 2's.
;   0xF85606-0xF856EB   230  Kernel_InitRam -- the kernel's WHOLE RAM MAP written
;                            out in one pass: 4 task control blocks, 3 ready
;                            queues, 8+4+4 more list heads, 8 free nodes on the
;                            free list, 2 software timers, and the 8 ROM bytes
;                            at 0xF85EBA copied to 0x035C
;                            (notes/FINDINGS-prom_a-kernel-lifecycle.md)
;   0xF856EC-0xF857D5   234  the kernel: idle loop, task switch, software timers,
;                            and IRQ_Epilogue, where every handler exits
;   0xF857D6-0xF85876   161  the task LIFECYCLE -- Kernel_StartTask, which builds
;                            a task's initial stack frame from EntryPoint_Records
;                            and queues it, and Kernel_ExitTask, which unlinks
;                            the running task and gives up the CPU.  ★ This is
;                            also where the kernel's TWO PUBLISHED ABIs become
;                            visible: prom_b 0xF42D6C and 0xF42DAC are the same
;                            API with register and stack arguments
;   0xF85877-0xF85903   141  the scheduler's two queue-rotate primitives, which
;                            are what identify 0x0330 as three READY QUEUES
;   0xF85904-0xF8596C   105  Kernel_BlockSelf and Kernel_ReadyTask -- the pair
;                            that shows QUEUE MEMBERSHIP is what the dispatcher
;                            reads, and the +9 state byte is bookkeeping
;   0xF8596D-0xF85B0C   416  ★ the EIGHT COUNTING SEMAPHORES -- wait, signal,
;                            signal-without-rescheduling and a non-blocking
;                            try-wait, plus a no-reschedule Kernel_ReadyTask.
;                            These identify the eight heads at 0x033C and the
;                            eight count bytes at 0x035C that Kernel_InitRam
;                            creates, and the ROM image at 0xF85EBA turns out to
;                            be their INITIAL COUNTS
;   0xF85C89-0xF85D1B   147  MsgQueue_ReceiveBlocking -- the blocking message
;                            receive, and with it the kernel's queue RAM map
;   0xF85E8A-0xF85F0E   133  EntryPoint_Records (4 x 12 bytes) and the endless
;                            DSP refresh task
;   0xF85F0F-0xF85FF8   234  the DSP channel-register driver -- ★ SHARED SOURCE,
;                            dsp/dsp_channel_regs.s, assembled into prom_c too
;   0xF8E47F-0xF8E6A1   547  INT0, the inter-processor link receiver, INTTC2,
;                            INTTC3 and the link's main-loop service task
;   0xF8E6A2-0xF8E6F9    88  micro-DMA channel setup helpers, and a block copy
;   0xF8E800-0xF8EAC6   711  the SED1330-family LCD controller: entry thunks, the
;                            power-on setup, the SWI7 gateway and its 64-slot table
;   0xF8EAC7-0xF8F038  1394  SWI7 service 0x00 (draw a line) with its six helpers,
;                            0x0B (plot a pixel), 0x03/0x04 (blit a rectangle
;                            column-major, and read one back), the layer selector
;                            and its pointer table, and 0x05 (fill a rectangle)
;   0xF8F039-0xF8F3A3   875  SWI7's TEN TEXT SERVICES, one per font, and their
;                            two glyph blitters (notes/FINDINGS-fonts.md)
;   0xF8F3A4-0xF8F7B7  1044  SWI7's line and box services 0x01 0x02 0x09 0x0A
;                            0x13 0x22, and the two edge-mask helpers and tables
;                            that services 0x01 and 0x05 share
;   0xF8F7B8-0xF8F84F   152  SWI7 services 0x0C and 0x0D, layer visibility
;   0xF8F850-0xF90117  2248  SWI7 services 0x0E 0x1B (erase), 0x0F 0x10 (the TWO
;                            PANEL MODES), 0x11 0x12 0x14 0x15 (the patterned
;                            primitives) and their four mask/dither tables
;   0xF90118-0xF90988  2161  SWI7's two PACKED text services 0x17 and 0x1C -- the
;                            only ones that can start at any pixel column -- their
;                            bit-shift engine and four mask tables, and 0x1E, the
;                            panel SCROLL.  ★ With these, ALL 34 live SWI7
;                            services are converted (notes/swi7_service_table.py)
;   0xFA5418-0xFA570B   756  the MIDI port: both interrupt handlers, the System
;                            Real Time receiver and the tempo tracker
;   0xFE54B6-0xFE68F2  5181  ★★ the FLOPPY DISK CONTROLLER driver, now whole and
;                            in one piece: the five accessors of 0x7B0004/0x7B0005,
;                            the two wait loops, the reset-and-identify sequence,
;                            the request validator, THREE DISK GEOMETRIES, the
;                            command-phase encoder with one arm per uPD765 command,
;                            the ST0/ST1/ST3 decoder, the twelve operations, the
;                            CHS transfer loops, the FORMAT ID-table builder, the
;                            public entry Fdc_Request, micro-DMA channel 0 and the
;                            0x7A0000 data port, INTTC0, INT5 and the programmed-I/O
;                            byte mover -- plus Int_Mul32, the C runtime's
;                            32x32->32 multiply, which shares the block.
;                            ★ THE DEVICE IS NAMED: the driver's own opcode
;                            validator accepts 15 of the 32 five-bit opcode values
;                            and rejects the other 17, and that truth table is
;                            EXACTLY MAME's uPD765 command decoder's
;                            (notes/FINDINGS-prom_a-fdc.md; the checks are in
;                            notes/prom_a_fdc_checks.py, which prints its own
;                            count -- no number is kept here, for the reason the
;                            `.fill` paragraph above gives).  This WITHDRAWS
;                            "do not name it" from FINDINGS-dev7b-and-int5.md
;   0xFE6E3A-0xFE6E83    74  that module's FOUR JUMP TABLES, which tile exactly:
;                            6 + 12 + 7 + 12 = 37 entries, every count taken from
;                            the `cp` bound of its own indexer
;   0xFE68F3-0xFE69BE   204  the 64-bit integer divide runtime.  It shares TWO runs
;                            with the KN5000 sub-CPU: 170 bytes 0xFE68F2-0xFE699B
;                            and 23 bytes 0xFE69A8-0xFE69BE.  The images differ in
;                            exactly one 12-byte window, 0xFE699C-0xFE69A7.
;                            Corrected 2026-08-24: this banner said "byte for byte",
;                            which the body of the file never claimed.  Corrected
;                            2026-08-25 (audit F5): the divergence is 0xFE699C, and
;                            the second run was not mentioned at all.
;   0xFB2000-0xFBFFFF 52962  ★★ FOUR MODULES, and the answer to EMULATION GAP D:
;                            the REMOTE-FLASH READER streams 32 blocks of 0x2000
;                            bytes from remote 0xE80000 through the staging
;                            buffer at RAM 0x60A000 -- 256 KiB, half the prom_d
;                            image -- so nothing ever indexes prom_d's own
;                            directory.  ⚠ This line used to add "it is also the
;                            only converted caller of Link_WaitBlockDone"; that
;                            was wrong -- there are FIFTEEN, in five regions
;                            (audit F1, notes/prom_a_converted_callers.py).
;                            Carries
;                            the SMF magics "MThd"/"MTrk", seven inline jump
;                            tables whose entry counts all come from their own
;                            bound compares, and 332 six-byte records at
;                            0xFB82A2 that a LINEAR DECODE WOULD HAVE EATEN --
;                            found by notes/prom_a_linear_decode_check.py's
;                            offender row, not by the byte gate.  106 directory
;                            targets retired.  ⚠ Most labels are sub_XXXXXX
;                            (notes/FINDINGS-prom_a-remote-flash.md,
;                            notes/prom_a_fb2000_checks.py)
;   0xFCF000-0xFDE70E 63247  ★ THE MODULE THE FRONTIER RANKED FIRST -- 17-entry
;                            dispatch table, 3,427 bytes of tables (including a
;                            96-CHARACTER SET that is not in ASCII order, i.e. an
;                            index-to-glyph map), two 8-entry inline jump tables,
;                            and 59,752 bytes of code in 23,585 instructions
;                            (CORRECTED 2026-08-25, audit F3: this said
;                            60,776 / 23,622, which made the three parts sum
;                            to 64,271 against the module's own 63,247;
;                            68 + 3,427 + 59,752 = 63,247 exactly).
;                            178 published entries, ALL on instruction boundaries
;                            of one decode.  ⚠ It answers no emulation gap and
;                            almost every label in it is sub_XXXXXX.  ★★ The
;                            6,385 bytes 0xFDE70F-0xFDFFFF are deliberately LEFT
;                            `.incbin`: of the 128 possible decode starts in the
;                            last 128 bytes, only two make 0xFE0000 -- a known
;                            boundary -- a boundary, so a linear decode of the
;                            tail would be invented
;                            (notes/FINDINGS-prom_a-fcf000-module.md,
;                            notes/prom_a_fcf000_checks.py)
;   0xFFFF00-0xFFFFFF   256  interrupt vector table, RET padding, build tag
;
; The gate (scripts/analysis/assert_byte_identical.py) must print PASS after
; every edit.  It compares BYTES; it is blind to whether a name or a comment is
; right, so every header below says what its name is evidenced by.
;
; ★ AND THE NUMBERS IN THOSE HEADERS ARE RE-CHECKED TOO.  Every quantified claim
; below -- "exactly five accessors", "82 of those bytes are equal", "eight
; entries", "three entries", "nine bytes", "ten command codes", "38 identical
; bytes", "172 of 172", "13 bytes reordered", every font base and every ASCII
; verdict -- is one of the named checks in notes/prom_a_byte_checks.py, which
; reads them back out of the ROM and exits non-zero if any has drifted.  Run it
; WITH the byte gate; neither catches what the other does.
;
; ⚠ THE COUNT IS NOT WRITTEN HERE ANY MORE.  This line said "232 named checks"
; and the tooling note said "133"; the number that actually ran on 2026-08-25
; was 231.  The script now PRINTS its own count as its first output line, so
; the number a reader quotes is the one that ran.
;
; ⚠ AND THE GATE IS BLIND TO A SEARCHED NEGATIVE TOO.  Round 1 of this file put
; "these 22 bytes have NO counterpart in the KN5000 sub-CPU" in a header, on the
; strength of a tool whose MIN_RUN was 48 and whose silence was read as an
; answer.  The routine is 22 bytes long and the sibling has it.  Any sentence
; below that says something does NOT exist now names the search that failed to
; find it, and notes/prom_a_sibling_short_runs.py and notes/prom_a_addr_census.py
; exist so that those searches are runnable.
;
; TOOLS THAT PRODUCED THE CONVERTED TEXT, all in prom_a/ and all documented in
; their own docstrings:
;   (and in notes/: prom_a_byte_checks.py, prom_a_xref.py, prom_a_addr_census.py,
;    prom_a_sibling_short_runs.py, and -- new with the FDC module --
;    prom_a_fdc_checks.py, prom_a_fdc_callgraph.py, prom_a_unit1_backend_check.py,
;    prom_a_p7_link_census.py, prom_a_codemap.py, prom_a_ctrl_checks.py and the
;    two generators gen_prom_a_fdc_module.py / gen_prom_a_ctrl_module.py;
;    see notes/prom_a-tooling.md)
;   roundtrip.py           bytes -> llvm-mc source, re-assembled and byte-compared
;                          before anything is printed; --block also resolves
;                          branch targets to labels and verifies the whole block
;   insert_region.py       splices a converted region in and fixes the .incbin math
;   kn5000_run_offsets.py  proves the KN5000 payload offset->address mapping that
;                          the transplanted names depend on (--proposals re-runs
;                          the whole transplant with it)
;
; SUBSYSTEM NOTES written from this file:
;   notes/FINDINGS-display-controller.md      the SED1330-family LCD controller
;   notes/FINDINGS-midi-port.md               serial channel 0 and (0xA0)
;   notes/FINDINGS-interprocessor-link.md     INT0 and the micro-DMA hand-off
;   notes/FINDINGS-kn5000-transplant-offset.md  the corrected KN5000 name mapping
;   notes/FINDINGS-interrupt-vectors.md       the 33 vectors and where each ends up
;   notes/FINDINGS-dev7b-and-int5.md          the CS0 device at 0x7A/0x7B
;                                             (its "do not name it" is WITHDRAWN)
;   notes/FINDINGS-prom_a-fdc.md              ★★ that device NAMED: a uPD765-
;                                             family floppy disk controller, and
;                                             the 0x7E0008 device as unit 1 of
;                                             the same block-device layer
;   notes/FINDINGS-prom_a-control-normaliser.md  ★★ 0xF89800: the ten continuous
;                                             controls, their eight response
;                                             curves, and the slot the SC1 peer
;                                             shares with the on-board pots
;   notes/FINDINGS-prom_a-link-receiver-busy.md  ★ every site that moves P7 bit 1
;                                             -- 3 clear, 6 set, 1 test -- and
;                                             what INTTC3 needs before it runs
;   notes/FINDINGS-fonts.md                   the ten fonts and the ASCII test
;   notes/FINDINGS-prom_a-tasks-and-dsp-refresh.md  the entry records, the
;                                             scheduler queues, the DSP tasks
;   notes/FINDINGS-prom_a-kernel-lifecycle.md  the kernel's RAM map, the task
;                                             lifecycle, and the two ABIs
;
; PROVENANCE: this is not a chip read.  It is the publicly redistributed v2
; firmware set (../technics_roms/roms/wsa1/PROVENANCE.md).

	.include "include/tmp95c061_sfr.inc"

; MACRO-PRELUDE-BEGIN
; ★ MOVED 2026-08-30 to include/tlcs900_mem_ops.inc, ONE COPY for prom_a,
;   prom_b and kernel/kernel.s.  The text there is this block, verbatim, under a
;   header saying who includes it and why the KERNEL_MEM_OPS_PROVIDED guard is
;   still needed.  Nothing about the encodings changed; the gate is the proof.
	.include "include/tlcs900_mem_ops.inc"
	.include "include/wsa1_ram.inc"
	.include "include/wsa1_gui.inc"	; the display-list record macros (dl_*, dlb_*) and LCDSVC_* service numbers
; >>> ADDRESS EQUATES RETIRED (scripts/tools/join_maincpu_link.py)
; This block held one `.set Name, <address>` per prom_b label this image references.
; Since 2026-10-31 prom_b and prom_a are linked as ONE program (maincpu/maincpu.ld): such a
; name is left undefined here and ld.lld resolves it to prom_b's own label, which
; prom_b/exports.syms makes global after assembly.  A renamed or missing name fails the link.
; This image's own exports, the names prom_b references, are in prom_a/exports.syms.
; <<< ADDRESS EQUATES RETIRED (scripts/tools/join_maincpu_link.py)
; MACRO-PRELUDE-END

; >>> BEGIN MODULE INCLUDES (generated by scripts/tools/split_cpu1_images.py; do not edit by hand)
; prom_a is assembled from these 37 module sources, in address order.  A module ends where
; its 0x0E (`ret`) padding reaches an aligned address -- the firmware's own link layout;
; the rule, its two written-out exceptions and the proof that the cut changes no byte are
; in scripts/tools/split_cpu1_images.py.  Edit the module files; this block is regenerated.

	.include "prom_a/modules/f80000_f81fff_sequencer_job_button_tables.s"
	.include "prom_a/modules/f82000_f83fff_main_task_reset_and_interrupts.s"
	.include "prom_a/modules/f84000_f855ff_ring_buffers.s"
	.include "prom_a/modules/f85600_f85fff_kernel_and_dsp_refresh.s"
	.include "prom_a/modules/f86000_f897ff_panel_task_and_ui_event_lists.s"
	.include "prom_a/modules/f89800_f89fff_control_normaliser.s"
	.include "prom_a/modules/f8a000_f8bbff_panel_wire_to_group.s"
	.include "prom_a/modules/f8bc00_f8bfff_ascii_numeric_fields.s"
	.include "prom_a/modules/f8c000_f8d9ff_panel_leds.s"
	.include "prom_a/modules/f8da00_f8dbff_callback_queue.s"
	.include "prom_a/modules/f8dc00_f8dfff_analog_scan.s"
	.include "prom_a/modules/f8e000_f8e7ff_link_port.s"
	.include "prom_a/modules/f8e800_f94bff_lcd_swi7_and_combination_screens.s"
	.include "prom_a/modules/f94c00_f993ff_debug_monitor_and_param_scripts.s"
	.include "prom_a/modules/f99400_f997ff_screen_field_redraw_request.s"
	.include "prom_a/modules/f99800_f9bfff_midi_settings_screens.s"
	.include "prom_a/modules/f9c000_fa53ff_system_menu_screens.s"
	.include "prom_a/modules/fa5400_fa5fff_midi_port.s"
	.include "prom_a/modules/fa6000_fa9fff_midi_in_out.s"
	.include "prom_a/modules/faa000_fad7ff_param_message_module.s"
	.include "prom_a/modules/fad800_fb17ff_param_apply_and_event_lists.s"
	.include "prom_a/modules/fb1800_fb1fff_patch_lists.s"
	.include "prom_a/modules/fb2000_fb8fff_sysex_module.s"
	.include "prom_a/modules/fb9000_fbabff_smf_playback.s"
	.include "prom_a/modules/fbac00_fbb7ff_seq_file_load_save.s"
	.include "prom_a/modules/fbb800_fbffff_part_params_and_combi_edit.s"
	.include "prom_a/modules/fc0000_fc3fff_msg0716_module.s"
	.include "prom_a/modules/fc4000_fc53ff_digital_effect_screen_data.s"
	.include "prom_a/modules/fc5400_fc7fff_note_routing.s"
	.include "prom_a/modules/fc8000_fcefff_ram3800_module.s"
	.include "prom_a/modules/fcf000_fdffff_tone_edit_module.s"
	.include "prom_a/modules/fe0000_fe77ff_disk_and_floppy.s"
	.include "prom_a/modules/fe7800_fe7fff_medley.s"
	.include "prom_a/modules/fe8000_ff37ff_edit_screens.s"
	.include "prom_a/modules/ff3800_ff7fff_disk_menu_screens.s"
	.include "prom_a/modules/ff8000_fffeff_splash_bitmaps.s"
	.include "prom_a/modules/ffff00_ffffff_vectors.s"
; <<< END MODULE INCLUDES
