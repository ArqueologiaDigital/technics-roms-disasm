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
; >>> BEGIN prom_b ADDRESS EQUATES (generated by notes/proma-2026-09-25/symbolize_prom_a_addresses.py)
; prom_b is linked separately: these name the prom_b addresses this file calls or
; points at.  Each name is the label prom_b's own linked ELF defines at that address
; (best non-structural name).  The gate checks every VALUE; `--check-equates`
; checks the NAMES against prom_b after a rename there.  Regenerate, never edit
; the names or values; a trailing comment on an equate is kept.
	.set DLText_OffOn,                            0x00f034d2
	.set DLText_OffOn_F034D8,                     0x00f034d8
	.set DLText_SinTriSqrSaw,                     0x00f05469
	.set DLTable_F0574D,                          0x00f0574d
	.set DLText_NoteNamesCm2ToG8,                 0x00f05b60
	.set ScaleTuningOffsets,                      0x00f06800
	.set ToneGroupNames,                          0x00f068b4
	.set GroupMaxMemberIndex_ToneGroups,          0x00f06eb4
	.set GroupMaxMemberIndex_DrumGroups,          0x00f06ec4
	.set GroupMaxMemberIndex_DrumGroupsSecondWindow, 0x00f06ed4
	.set GroupMaxMemberIndex_ToneGroupsCopy,      0x00f06ee4
	.set SoundCodeByGroupMember_ModeOffsetGroup,  0x00f06ef4
	.set PanelSoundSel_ByProgramAndBank,          0x00f07134
	.set ProgramChangeOut_ByProgramAndBank,       0x00f08514
	.set SoftKeyCol2_SoundEditPitchTune,          0x00f0a162
	.set SoftKeyCol3_SoundEditPitchTune,          0x00f0a1d1
	.set SoftKeyCol4_SoundEditPitchTune,          0x00f0a240
	.set SoftKeyCol6_SoundEditPitchTune,          0x00f0a2ab
	.set LcdKeyRow1_SoundEditPitchTune,           0x00f0a3a1
	.set LcdKeyRow2_SoundEditPitchTune,           0x00f0a3bf
	.set LcdKeyRow3_SoundEditPitchTune,           0x00f0a3db
	.set LcdKeyRow4_SoundEditPitchTune,           0x00f0a404
	.set LcdKeyRow5_SoundEditPitchTune,           0x00f0a451
	.set ExitKey_SoundEditPitchTune,              0x00f0a49e
	.set SoftKeyCol1_SoundEditPitchEnvelope1,     0x00f0a4be
	.set SoftKeyCol2_SoundEditPitchEnvelope1,     0x00f0a4d7
	.set SoftKeyCol3_SoundEditPitchEnvelope1,     0x00f0a4f0
	.set SoftKeyCol4_SoundEditPitchEnvelope1,     0x00f0a509
	.set SoftKeyCol5_SoundEditPitchEnvelope1,     0x00f0a522
	.set SoftKeyCol6_SoundEditPitchEnvelope1,     0x00f0a53b
	.set SoftKeyCol7_SoundEditPitchEnvelope1,     0x00f0a554
	.set LcdKeyRow1_SoundEditPitchEnvelope1,      0x00f0a56d
	.set LcdKeyRow2_SoundEditPitchEnvelope1,      0x00f0a57e
	.set LcdKeyRow3_SoundEditPitchEnvelope1,      0x00f0a5aa
	.set LcdKeyRow4_SoundEditPitchEnvelope1,      0x00f0a5d6
	.set LcdKeyRow5_SoundEditPitchEnvelope1,      0x00f0a604
	.set PageKey_SoundEditPitchEnvelope1,         0x00f0a632
	.set ExitKey_SoundEditPitchEnvelope1,         0x00f0a64a
	.set SoftKeyCol2_SoundEditPitchEnvelope2,     0x00f0a66a
	.set SoftKeyCol3_SoundEditPitchEnvelope2,     0x00f0a67f
	.set SoftKeyCol4_SoundEditPitchEnvelope2,     0x00f0a694
	.set SoftKeyCol5_SoundEditPitchEnvelope2,     0x00f0a6a9
	.set SoftKeyCol7_SoundEditPitchEnvelope2,     0x00f0a6be
	.set SoftKeyCol8_SoundEditPitchEnvelope2,     0x00f0a6d3
	.set LcdKeyRow1_SoundEditPitchEnvelope2,      0x00f0a6e8
	.set LcdKeyRow2_SoundEditPitchEnvelope2,      0x00f0a6f9
	.set LcdKeyRow3_SoundEditPitchEnvelope2,      0x00f0a725
	.set LcdKeyRow4_SoundEditPitchEnvelope2,      0x00f0a751
	.set LcdKeyRow5_SoundEditPitchEnvelope2,      0x00f0a775
	.set PageKey_SoundEditPitchEnvelope2,         0x00f0a799
	.set ExitKey_SoundEditPitchEnvelope2,         0x00f0a7b1
	.set SoftKeyCol2_SoundEditPitchLfo,           0x00f0a7d1
	.set SoftKeyCol3_SoundEditPitchLfo,           0x00f0a7e6
	.set SoftKeyCol4_SoundEditPitchLfo,           0x00f0a7fb
	.set SoftKeyCol5_SoundEditPitchLfo,           0x00f0a810
	.set SoftKeyCol6_SoundEditPitchLfo,           0x00f0a825
	.set SoftKeyCol7_SoundEditPitchLfo,           0x00f0a83a
	.set SoftKeyCol8_SoundEditPitchLfo,           0x00f0a84f
	.set LcdKeyRow1_SoundEditPitchLfo,            0x00f0a864
	.set LcdKeyRow2_SoundEditPitchLfo,            0x00f0a882
	.set LcdKeyRow3_SoundEditPitchLfo,            0x00f0a8a6
	.set LcdKeyRow4_SoundEditPitchLfo,            0x00f0a8be
	.set LcdKeyRow5_SoundEditPitchLfo,            0x00f0a8d6
	.set ExitKey_SoundEditPitchLfo,               0x00f0a8ee
	.set SoftKeyCol2_SoundEditDrumMenu,           0x00f0ab4b
	.set SoftKeyCol3_SoundEditDrumMenu,           0x00f0abb9
	.set SoftKeyCol4_SoundEditDrumMenu,           0x00f0ac43
	.set LcdKeyRow1_SoundEditDrumMenu,            0x00f0acb1
	.set LcdKeyRow2_SoundEditDrumMenu,            0x00f0acce
	.set LcdKeyRow3_SoundEditDrumMenu,            0x00f0ad02
	.set LcdKeyRow4_SoundEditDrumMenu,            0x00f0ad36
	.set LcdKeyRow5_SoundEditDrumMenu,            0x00f0ad75
	.set ExitKey_SoundEditDrumMenu,               0x00f0adbc
	.set SoftKeyCol1_SoundEditDigitalEffect,      0x00f0add4
	.set SoftKeyCol2_SoundEditDigitalEffect,      0x00f0ae9b
	.set SoftKeyCol3_SoundEditDigitalEffect,      0x00f0af66
	.set SoftKeyCol4_SoundEditDigitalEffect,      0x00f0b041
	.set SoftKeyCol5_SoundEditDigitalEffect,      0x00f0b0ff
	.set SoftKeyCol6_SoundEditDigitalEffect,      0x00f0b1a9
	.set SoftKeyCol7_SoundEditDigitalEffect,      0x00f0b228
	.set SoftKeyCol8_SoundEditDigitalEffect,      0x00f0b2e2
	.set LcdKeyRow2_SoundEditDigitalEffect,       0x00f0b39c
	.set LcdKeyRow3_SoundEditDigitalEffect,       0x00f0b462
	.set ExitKey_SoundEditDigitalEffect,          0x00f0b51b
	.set LcdKeyRow1_SoundEditMemoryWrite,         0x00f0b533
	.set LcdKeyRow3_SoundEditMemoryWrite,         0x00f0b578
	.set LcdKeyRow4_SoundEditMemoryWrite,         0x00f0b62f
	.set LcdKeyRow5_SoundEditMemoryWrite,         0x00f0b6d7
	.set ExitKey_SoundEditMemoryWrite,            0x00f0b6ef
	.set SoftKeyCol1_SoundEditNaming,             0x00f0b70f
	.set SoftKeyCol2_SoundEditNaming,             0x00f0b713
	.set SoftKeyCol3_SoundEditNaming,             0x00f0b717
	.set SoftKeyCol4_SoundEditNaming,             0x00f0b71b
	.set SoftKeyCol5_SoundEditNaming,             0x00f0b71f
	.set SoftKeyCol6_SoundEditNaming,             0x00f0b723
	.set SoftKeyCol7_SoundEditNaming,             0x00f0b727
	.set SoftKeyCol8_SoundEditNaming,             0x00f0b747
	.set LcdKeyRow1_SoundEditNaming,              0x00f0b74b
	.set LcdKeyRow2_SoundEditNaming,              0x00f0b80d
	.set ExitKey_SoundEditNaming,                 0x00f0b81d
	.set NameEntry_Begin,                         0x00f0b91c
	.set SoftKeyCol1_SoundEditCopy,               0x00f0c0bb
	.set SoftKeyCol2_SoundEditCopy,               0x00f0c35d
	.set SoftKeyCol3_SoundEditCopy,               0x00f0c3f9
	.set SoftKeyCol4_SoundEditCopy,               0x00f0c47b
	.set SoftKeyCol6_SoundEditCopy,               0x00f0c528
	.set LcdKeyRow4_SoundEditCopy,                0x00f0c616
	.set ExitKey_SoundEditCopy,                   0x00f0c70a
	.set DL_Input0utputFilterMidiT0talM0de,       0x00f0c800
	.set DL_MidiT0talM0deC0nfigurePr0g,           0x00f0c81f
	.set DL_RealtimeMessageInput0utput,           0x00f0c8d5
	.set DL_F0C917,                               0x00f0c917
	.set DL_TotalModeMidiMidiInputMode,           0x00f0c964
	.set DL_LocalTotal,                           0x00f0ca19
	.set DL_MultiSingleOmni,                      0x00f0ca2f
	.set DL_MultiSingle,                          0x00f0ca3e
	.set DL_F0CA4D,                               0x00f0ca4d
	.set MidiTotalMode_PaintSingleChannel_DL,     0x00f0ca5c
	.set DL_NormalTechRemap,                      0x00f0ca6b
	.set DL_F0CA7A,                               0x00f0ca7a
	.set DL_F0CA89,                               0x00f0ca89
	.set DLTable_MultiSingleOmni,                 0x00f0ca9f
	.set DL_RealtimeMessagesMidiRealtimeCommands, 0x00f0cbcf
	.set DL_F0CC75,                               0x00f0cc75
	.set DL_OnOff,                                0x00f0cc83
	.set DL_RealtimeCommandsClock,                0x00f0cc91
	.set DL_F0CCAF,                               0x00f0ccaf
	.set DL_F0CCBA,                               0x00f0ccba
	.set DL_InputOutputFilterMidiPr0gramChange,   0x00f0ccee
	.set DL_F0CDE7,                               0x00f0cde7
	.set DL_F0CDF6,                               0x00f0cdf6
	.set DL_F0CE05,                               0x00f0ce05
	.set DL_F0CE14,                               0x00f0ce14
	.set DL_F0CE23,                               0x00f0ce23
	.set DL_F0CE32,                               0x00f0ce32
	.set DL_F0CE41,                               0x00f0ce41
	.set DL_F0CE50,                               0x00f0ce50
	.set DL_F0CE5F,                               0x00f0ce5f
	.set DLTable_OffOn,                           0x00f0ce75
	.set DL_ProgramChangeMidiOutMidi,             0x00f0cebb
	.set DL_F0CFF6,                               0x00f0cff6
	.set DL_F0D005,                               0x00f0d005
	.set DL_F0D00F,                               0x00f0d00f
	.set DL_F0D019,                               0x00f0d019
	.set MidiOutProgramChange_PaintBankLsb_DL,    0x00f0d023
	.set MidiOutProgramChange_PaintBankSelect_DL, 0x00f0d02d
	.set DL_OffOff,                               0x00f0d036
	.set DL_F0D04B,                               0x00f0d04b
	.set DLBoxes_F0D061,                          0x00f0d061
	.set DL_SysexBulkDumpMidiTotalKeyboard,       0x00f0d6af
	.set DL_SysexBulkDump_SequencerRow,           0x00f0d77f
	.set DL_Sending,                              0x00f0d79c
	.set DL_SystemExclusivePleaseWait,            0x00f0d7a7
	.set DL_Receiving,                            0x00f0d7d5
	.set Paint_SysPartMidiSoundCombination_DL,    0x00f0d7e2
	.set DL_F0D81B,                               0x00f0d81b
	.set DL_F0D82E,                               0x00f0d82e
	.set DLPtrTable_F0D942,                       0x00f0d942
	.set DLPtrTable_F0D96E,                       0x00f0d96e
	.set Chars_F0D99A,                            0x00f0d99a
	.set SysexProgressBar_DrawDots_DL,            0x00f0d99c
	.set DLB_SysexBulkDump_FillSelectedRow,       0x00f0d9a4
	.set DLB_SysexBulkDump_EraseSelectedRow,      0x00f0d9d7
	.set DL_GeneralMidiMidiGeneralMidiMode,       0x00f0d9e2
	.set DL_F0DA73,                               0x00f0da73
	.set DL_F0DA93,                               0x00f0da93
	.set DL_GeneralMidiMidiYesNo,                 0x00f0daa2
	.set PTR_F0DB18,                              0x00f0db18
	.set PTR_F0DB18_ButtonStarts,                 0x00f0db2c
	.set PTR_F0DB18_ButtonStarts2,                0x00f0db40
	.set PTR_F0DB18_TextStarts,                   0x00f0db54
	.set DL_OtherParts,                           0x00f17c08
	.set DL_Solo_F17C2A,                          0x00f17c2a
	.set DL_F17C45,                               0x00f17c45
	.set CombiEditMixer_DrawPartBoxRow_DL4,       0x00f17c4f
	.set DL_Mixer,                                0x00f17c8c
	.set CombiEditMixer_ShowOtherParts_DL1,       0x00f17e2e
	.set DL_Sound,                                0x00f17e42
	.set CombiEditMixer_ShowOtherParts_DL2,       0x00f17e9d
	.set DL_KeyShift,                             0x00f17f07
	.set DL_Midiout,                              0x00f17fa4
	.set CombiEditMixer_ShowOtherParts_DL3,       0x00f1802a
	.set DL_F18044,                               0x00f18044
	.set RecordArray_F18066,                      0x00f18066
	.set DL_Pt1Pt9Pt2Pt3Pt4Pt5Pt6Pt7,             0x00f1814e
	.set DL_Part1Part9Part17Part25Part2,          0x00f181d6
	.set CombiEditMixer_DrawPartBoxRow_DL1,       0x00f1825e
	.set CombiEditMixer_DrawPartBoxRow_DL3,       0x00f18269
	.set CombiEditMixer_DrawPartBoxRow_DL2,       0x00f18274
	.set StringTable_F1828A,                      0x00f1828a
	.set DL_InternalSound_F18A1D,                 0x00f18a1d
	.set DL_CopyFromSoundPlay,                    0x00f18ab7
	.set DL_Part_F18BBA,                          0x00f18bba
	.set DL_CombiEdit,                            0x00f18bce
	.set DL_Solo_F18BE8,                          0x00f18be8
	.set DL_F18C08,                               0x00f18c08
	.set DL_F18C12,                               0x00f18c12
	.set CombiEditSound_PageIndex_DL,             0x00f18c1c
	.set DL_Part_F18C69,                          0x00f18c69
	.set DL_F18CD5,                               0x00f18cd5
	.set DL_InternalSound_F18CDD,                 0x00f18cdd
	.set DL_InternalSound_F18DBD,                 0x00f18dbd
	.set DL_BankSelectMidiIn,                     0x00f18e84
	.set DL_MidiOutFilter_F18F36,                 0x00f18f36
	.set DL_EffectDepth,                          0x00f18f59
	.set DL_MidiOutFilter_F18FC8,                 0x00f18fc8
	.set DL_ReverbDepth,                          0x00f1900f
	.set DL_MidiOutFilter_F190E9,                 0x00f190e9
	.set DL_Modulation1,                          0x00f1910c
	.set DL_MidiOutFilter_F191B1,                 0x00f191b1
	.set DL_F191F8,                               0x00f191f8
	.set DL_F19207,                               0x00f19207
	.set StringTable_F19238,                      0x00f19238
	.set CombiEditSound_MoveLevelsPageRowCursor_DL, 0x00f19481
	.set IndexMap_F19497,                         0x00f19497
	.set CombiEditSound_MoveControllerFilterPageRowCursor_DL, 0x00f19517
	.set IndexMap_F1952D,                         0x00f1952d
	.set CombiEditSound_MoveAssignAndInputFilterPageRowCursor_DL, 0x00f195ad
	.set IndexMap_F195C3,                         0x00f195c3
	.set CombiEditSound_MoveMidiOutPageRowCursor_DL, 0x00f19603
	.set IndexMap_F19619,                         0x00f19619
	.set CombiEditSound_MoveMidiOutFilterPageRowCursor_DL, 0x00f19659
	.set IndexMap_F1966F,                         0x00f1966f
	.set CombiEditSound_MoveMultipleMessagesPageRowCursor_DL, 0x00f196ef
	.set IndexMap_F19705,                         0x00f19705
	.set CombiEdit_TakePartIndex_DL,              0x00f19745
	.set DL_Rd1Rd2Ud1Ud2Ed1,                      0x00f19754
	.set DL_F19772,                               0x00f19772
	.set CombiEditSound_PaintLevelsPage_DL3,      0x00f19781
	.set CombiEditSound_PaintLevelsPage_DL8,      0x00f19790
	.set DL_OffMainSub1Sub2Sub3Eff2,              0x00f1979f
	.set CombiEditSound_PaintLevelsPage_DL1,      0x00f197ae
	.set CombiEditSound_PaintLevelsPage_DL2,      0x00f197b8
	.set CombiEditSound_PaintLevelsPage_DL4,      0x00f197c2
	.set CombiEditSound_PaintLevelsPage_DL5,      0x00f197cc
	.set CombiEditSound_PaintLevelsPage_DL6,      0x00f197d7
	.set CombiEditSound_PaintLevelsPage_DL7,      0x00f197e2
	.set CombiEditSound_PaintControllerFilterPage_DL, 0x00f19818
	.set DL_F198AE,                               0x00f198ae
	.set CombiEditSound_PaintAssignAndInputFilterPage_DL1, 0x00f198bd
	.set CombiEditSound_PaintAssignAndInputFilterPage_DL2, 0x00f198cc
	.set CombiEditSound_PaintAssignAndInputFilterPage_DL3, 0x00f198d7
	.set CombiEditSound_PaintAssignAndInputFilterPage_DL4, 0x00f198e6
	.set CombiEditSound_PaintAssignAndInputFilterPage_DL5, 0x00f198f5
	.set CombiEditSound_PaintMidiOutPage_DL1,     0x00f19904
	.set CombiEditSound_PaintMidiOutPage_DL3,     0x00f19913
	.set CombiEditSound_PaintMidiOutPage_DL5,     0x00f19922
	.set CombiEditSound_PaintMidiOutPage_DL2,     0x00f19931
	.set CombiEditSound_PaintMidiOutPage_DL4,     0x00f19940
	.set CombiEditSound_PaintMidiOutPage_DL6,     0x00f1994f
	.set CombiEditSound_PaintMidiOutFilterPage_DL, 0x00f1995a
	.set DL_F199F0,                               0x00f199f0
	.set CombiEditSound_PaintMultipleMessagesPage_DL1, 0x00f199ff
	.set CombiEditSound_PaintMultipleMessagesPage_DL5, 0x00f19a09
	.set CombiEditSound_PaintMultipleMessagesPage_DL4, 0x00f19a18
	.set CombiEditSound_PaintMultipleMessagesPage_DL3, 0x00f19a22
	.set CombiEditSound_PaintMultipleMessagesPage_DL2, 0x00f19a31
	.set CombiEditSound_PaintMultipleMessagesPage_DL6, 0x00f19a3b
	.set CombiEditSound_PaintMultipleMessagesPage_DL8, 0x00f19a4a
	.set CombiEditSound_PaintMultipleMessagesPage_DL7, 0x00f19a59
	.set CombiEditSound_PaintMultipleMessagesPage_DL9, 0x00f19a63
	.set CombiEditSound_PaintMultipleMessagesPage_DL10, 0x00f19a72
	.set CombiEditSound_PaintMultipleMessagesPage_DL12, 0x00f19a81
	.set CombiEditSound_PaintMultipleMessagesPage_DL11, 0x00f19a90
	.set CombiEditSound_PaintMultipleMessagesPage_DL14, 0x00f19a9a
	.set CombiEditSound_PaintMultipleMessagesPage_DL13, 0x00f19aa9
	.set DL_CombinationNaming_F19ABF,             0x00f19abf
	.set DL_F19BBD,                               0x00f19bbd
	.set DL_CombinationNaming_F19BE5,             0x00f19be5
	.set DL_Configure_F19C39,                     0x00f19c39
	.set DL_Configure_F19D5C,                     0x00f19d5c
	.set DL_Midi,                                 0x00f19dd0
	.set DL_Inter,                                0x00f19dda
	.set DL_KeyLayer,                             0x00f19ed6
	.set DL_VelocityLayer,                        0x00f19f89
	.set ExitKey_CombiEditConfigure_DL2,          0x00f1a019
	.set ExitKey_CombiEditConfigure_DL1,          0x00f1a02d
	.set RecordArray_F1A037,                      0x00f1a037
	.set DL_Pt1Pt2Pt3Pt4Pt5Pt6Pt7Pt8,             0x00f1a0bf
	.set CombiEditConfigure_RepaintMarkedSounds_DL4, 0x00f1a137
	.set CombiEditConfigure_RepaintMarkedSounds_DL3, 0x00f1a14d
	.set ExitKey_CombiEditConfigure_DL3,          0x00f1a158
	.set CombiEditConfigure_RepaintMarkedSounds_DL2, 0x00f1a163
	.set CombiEditConfigure_RepaintMarkedSounds_DL1, 0x00f1a179
	.set CombiEditConfigure_RepaintMarkedSounds_DL5, 0x00f1a183
	.set CombiEditConfigure_DrawMidiSettings_DL,  0x00f1a2ad
	.set StringTable_F1A515,                      0x00f1a515
	.set CombiEditConfigure_DrawKeyLayers_DL,     0x00f1a53f
	.set MidiNoteNames,                           0x00f1a62f
	.set CombiEditConfigure_DrawVelocityLayers_DL, 0x00f1a7af
	.set DL_F1A84F,                               0x00f1a84f
	.set ExitKey_Effect2OutputConflict_DL,        0x00f1a8ef
	.set DL_Err0rTheS0undOrC0mbinati0n,           0x00f1a999
	.set PartParamField_KeyLayerLow,              0x00f1aa7c
	.set PartParamField_KeyLayerHigh,             0x00f1aa85
	.set PartParamField_VelocityLayerLow,         0x00f1aa8e
	.set PartParamField_VelocityLayerHigh,        0x00f1aa97
	.set Record_F1AAA0,                           0x00f1aaa0
	.set Record_F1AAA9,                           0x00f1aaa9
	.set Record_F1AAB5,                           0x00f1aab5
	.set Record_F1AABF,                           0x00f1aabf
	.set Record_F1AAD3,                           0x00f1aad3
	.set Record_F1AADF,                           0x00f1aadf
	.set Record_F1AAEC,                           0x00f1aaec
	.set PartParamStep_Ids00to1F,                 0x00f1ab13
	.set PartParamStep_Ids20to3F,                 0x00f1ab4b
	.set PartParamStep_Ids40to5F,                 0x00f1ab6f
	.set PartParamStep_Ids60to7F,                 0x00f1ab97
	.set PartParamStep_Ids80to9F,                 0x00f1aba3
	.set PartParamStep_IdsA0toBF,                 0x00f1abe7
	.set PartParamEnter_Ids00to1F,                0x00f1ac07
	.set PartParamEnter_Ids20to3F,                0x00f1ac3f
	.set PartParamEnter_Ids40to5F,                0x00f1ac63
	.set PartParamEnter_Ids60to7F,                0x00f1ac8b
	.set PartParamEnter_Ids80to9F,                0x00f1ac97
	.set PartParamEnter_IdsA0toBF,                0x00f1acdb
	.set PartParamField_Volume,                   0x00f1acfb
	.set PartParamField_Panpot,                   0x00f1ad04
	.set PartParamField_KeyShift,                 0x00f1ad0d
	.set PartParamField_FineTune,                 0x00f1ad16
	.set PartParamField_PitchBendRange,           0x00f1ad1f
	.set PartParamField_Effect1Send,              0x00f1ad28
	.set PartParamField_ReverbSend,               0x00f1ad31
	.set PartParamField_LocalControl,             0x00f1ad3a
	.set PartParamField_MidiOutSetting,           0x00f1ad3d
	.set PartParamField_MidiInSetting,            0x00f1ad40
	.set PartParamField_KeyScaling,               0x00f1ad43
	.set PartParamField_MainOut,                  0x00f1ad46
	.set PartParamField_SubOut,                   0x00f1ad4f
	.set PartParamField_AssignMode,               0x00f1ad58
	.set PartParamField_VelocityOffset,           0x00f1ad61
	.set PartParamField_BasicChannel,             0x00f1ad6a
	.set PartParamField_ControllerInternalFilterPitchBend, 0x00f1ad73
	.set PartParamField_ControllerInternalFilterModulation1, 0x00f1ad76
	.set PartParamField_ControllerInternalFilterModulation2, 0x00f1ad79
	.set PartParamField_ControllerInternalFilterRealTimeCreatorX, 0x00f1ad7c
	.set PartParamField_ControllerInternalFilterRealTimeCreatorY, 0x00f1ad7f
	.set PartParamField_ControllerInternalFilterRealTimeControllerX, 0x00f1ad82
	.set PartParamField_ControllerInternalFilterRealTimeControllerY, 0x00f1ad85
	.set PartParamField_ControllerInternalFilterHold1, 0x00f1ad88
	.set PartParamField_ControllerInternalFilterControlPedal, 0x00f1ad8b
	.set PartParamField_ControllerInternalFilterAfterTouch, 0x00f1ad8e
	.set PartParamField_MidiInputFilterProgramChange, 0x00f1ad91
	.set PartParamField_MidiInputFilterBankSelect, 0x00f1ad94
	.set PartParamField_MidiInputFilterVolume,    0x00f1ad97
	.set PartParamField_MidiOutputFilterProgramChange, 0x00f1ad9a
	.set PartParamField_MidiOutputFilterBankSelect, 0x00f1ad9d
	.set PartParamField_MidiOutputFilterVolume,   0x00f1ada0
	.set PartParamField_MidiOutputFilterPanpot,   0x00f1ada3
	.set PartParamField_MidiOutputFilterEffectDepth_F1ADA6, 0x00f1ada6
	.set PartParamField_MidiOutputFilterEffectDepth_F1ADA9, 0x00f1ada9
	.set PartParamField_MidiOutKeyTranspose_F1ADAC, 0x00f1adac
	.set PartParamField_MidiOutputFilterPitchBend, 0x00f1adb5
	.set PartParamField_MidiOutputFilterModulation1, 0x00f1adb8
	.set PartParamField_MidiOutputFilterModulation2, 0x00f1adbb
	.set PartParamField_MidiOutputFilterRealTimeCreatorX, 0x00f1adbe
	.set PartParamField_MidiOutputFilterRealTimeCreatorY, 0x00f1adc1
	.set PartParamField_MidiOutputFilterRealTimeControllerX, 0x00f1adc4
	.set PartParamField_MidiOutputFilterRealTimeControllerY, 0x00f1adc7
	.set PartParamField_MidiOutputFilterHold1,    0x00f1adca
	.set PartParamField_MidiOutputFilterControlPedal, 0x00f1adcd
	.set PartParamField_MidiOutputFilterAfterTouch, 0x00f1add0
	.set PartParamField_MidiMultipleMessagesOutputProgramChange, 0x00f1add3
	.set PartParamField_MidiMultipleMessagesOutputProgramChangeValue, 0x00f1addc
	.set PartParamField_MidiMultipleMessagesOutputBankSelectMsbValue, 0x00f1ade5
	.set PartParamField_MidiMultipleMessagesOutputBankSelectLsbValue, 0x00f1adee
	.set PartParamField_MidiMultipleMessagesOutputVolumeValue, 0x00f1adf7
	.set PartParamField_MidiMultipleMessagesOutputReverbDepthValue, 0x00f1ae00
	.set PartParamField_MidiMultipleMessagesOutputChorusDepthValue, 0x00f1ae09
	.set PartParamField_MidiOutKeyTranspose_F1AE12, 0x00f1ae12
	.set Record_F1AE1B,                           0x00f1ae1b
	.set Record_F1AE24,                           0x00f1ae24
	.set Record_F1AE2D,                           0x00f1ae2d
	.set Record_F1AE36,                           0x00f1ae36
	.set Record_F1AE3F,                           0x00f1ae3f
	.set PtrTable_F1AE71,                         0x00f1ae71
	.set PtrTable_F1AE89,                         0x00f1ae89
	.set BitTable_F1AE95,                         0x00f1ae95
	.set ScreenButtons_CombiEditPartMenu,         0x00f1aeb5
	.set ScreenButtons_CombiEditInternalSound,    0x00f1af11
	.set IndexMap_F1AF6D,                         0x00f1af6d
	.set PtrTable_F1AFA5,                         0x00f1afa5
	.set PtrTable_F1AFBD,                         0x00f1afbd
	.set ScreenButtons_CombiEditMixer,            0x00f1afd5
	.set IndexMap_F1B031,                         0x00f1b031
	.set PtrTable_F1B03F,                         0x00f1b03f
	.set PtrTable_F1B04B,                         0x00f1b04b
	.set PtrTable_F1B06B,                         0x00f1b06b
	.set PtrTable_F1B08B,                         0x00f1b08b
	.set PtrTable_F1B0AB,                         0x00f1b0ab
	.set IndexMap_F1B0CB,                         0x00f1b0cb
	.set IndexMap_F1B0DB,                         0x00f1b0db
	.set IndexMap_F1B0EB,                         0x00f1b0eb
	.set IndexMap_F1B0FB,                         0x00f1b0fb
	.set PtrTable_F1B10B,                         0x00f1b10b
	.set PtrTable_F1B12B,                         0x00f1b12b
	.set ScreenButtons_CombinationNaming,         0x00f1b14b
	.set Record_F1B1A7,                           0x00f1b1a7
	.set ScreenButtons_CombinationNamingWrite,    0x00f1b1b0
	.set IndexMap_F1B230,                         0x00f1b230
	.set ScreenButtons_CombiEditConfigure,        0x00f1b239
	.set ScreenButtons_CombiEditMenu,             0x00f1b295
	.set ScreenButtons_Effect2OutputConflict,     0x00f1b2f1
	.set ScreenButtons_WriteProtectError,         0x00f1b34d
	.set Font_Svc06_8x14,                         0x00f1b400
	.set Font_Svc07_8x16,                         0x00f1bef0
	.set Font_Svc08_16x16,                        0x00f1cb70
	.set Font_Svc17_8x8,                          0x00f1e470
	.set Font_Svc1C_16x16,                        0x00f1eab0
	.set Font_Svc1D_16x16,                        0x00f203b0
	.set Font_Svc16_8x14,                         0x00f212b0
	.set Font_Svc19_16x16,                        0x00f21940
	.set Font_Svc1A_16x16,                        0x00f22840
	.set Font_Svc1F_16x16,                        0x00f24640
	.set Font_Svc20_8x10,                         0x00f24dc0
	.set Font_Svc21_16x24,                        0x00f25590
	.set DL_F27C00,                               0x00f27c00
	.set DL_F28064,                               0x00f28064
	.set DL_F2808C,                               0x00f2808c
	.set Paint_SoundMode_DeadCopy_DL,             0x00f28331
	.set Paint_SoundMode_DL,                      0x00f2833b
	.set DL_Drawbar,                              0x00f2834f
	.set Paint_Drawbar_DL1,                       0x00f28373
	.set Paint_Drawbar_DL2,                       0x00f2837d
	.set Data_F283A7,                             0x00f283a7
	.set C0mbinati0nM0de_RepaintPage1Fields_DL,   0x00f286a2
	.set DL_F286CB,                               0x00f286cb
	.set DL_F286E2,                               0x00f286e2
	.set ModeScreen_PaintDirtyFields2_DL1,        0x00f286f9
	.set DLTable_F28725,                          0x00f28725
	.set ModeScreen_PaintDirtyFields2_DeadCopy_DL, 0x00f287c1
	.set ModeScreen_PaintDirtyFields2_DL2,        0x00f28802
	.set ModeScreen_PaintDirtyFields2_DL6,        0x00f2880c
	.set ModeScreen_PaintDirtyFields2_DL10,       0x00f28816
	.set ModeScreen_PaintDirtyFields2_DL3,        0x00f28820
	.set DLBoxes_F2882B,                          0x00f2882b
	.set ModeScreen_PaintDirtyFields2_DL7,        0x00f2885b
	.set Data_F28866,                             0x00f28866
	.set ModeScreen_PaintDirtyFields2_DL11,       0x00f28896
	.set Data_F288A1,                             0x00f288a1
	.set ModeScreen_PaintDirtyFields2_DL4,        0x00f288d1
	.set ModeScreen_PaintDirtyFields2_DL5,        0x00f288e0
	.set ModeScreen_PaintDirtyFields2_DL8,        0x00f288ef
	.set ModeScreen_PaintDirtyFields2_DL9,        0x00f288fe
	.set ModeScreen_PaintDirtyFields2_DL12,       0x00f2890d
	.set ModeScreen_PaintDirtyFields2_DL13,       0x00f2891c
	.set ModeScreen_DrawGmModeGlyph_DL2,          0x00f2892b
	.set ModeScreen_DrawGmModeGlyph_DL1,          0x00f28930
	.set Paint_C0mbinati0nM0dePage1_DL1,          0x00f28938
	.set Paint_C0mbinati0nM0dePage1_DL2,          0x00f28df3
	.set Paint_C0mbinati0nM0dePage1_DL3,          0x00f28e1b
	.set Paint_C0mbinati0nM0dePage1_DL4,          0x00f29121
	.set DL_C0mbinati0nM0dePage22Sound,           0x00f29135
	.set DL_F29672,                               0x00f29672
	.set DL_F2967C,                               0x00f2967c
	.set DL_F29686,                               0x00f29686
	.set C0mbinati0nM0de_HighlightSoundRow_DL,    0x00f296ae
	.set C0mbinati0nM0de_HighlightIntRow_DL,      0x00f296b8
	.set C0mbinati0nM0de_HighlightPanRow_DL,      0x00f296c2
	.set DL_F296CC,                               0x00f296cc
	.set DL_F29765,                               0x00f29765
	.set Paint_C0mbinati0nM0dePage2Sound1_DL,     0x00f29783
	.set DLText_PartCodes,                        0x00f297a0
	.set Paint_C0mbinati0nM0dePage2Sound2_DL,     0x00f29863
	.set Paint_C0mbinati0nM0dePage2Sound3_DL,     0x00f29880
	.set Paint_C0mbinati0nM0dePage2Sound4_DL,     0x00f2989d
	.set Paint_C0mbinati0nM0dePage2Sound5_DL,     0x00f298ba
	.set Paint_C0mbinati0nM0dePage2Sound6_DL,     0x00f298d7
	.set Paint_C0mbinati0nM0dePage2Sound7_DL,     0x00f298f4
	.set C0mbinati0nM0de_DrawPart8Sound_DL,       0x00f29911
	.set C0mbinati0nM0de_DrawPart1Int_DL,         0x00f2992e
	.set DLTable_F29944,                          0x00f29944
	.set C0mbinati0nM0de_DrawPart2Int_DL,         0x00f29964
	.set DLTable_F2997A,                          0x00f2997a
	.set C0mbinati0nM0de_DrawPart3Int_DL,         0x00f2999a
	.set DLTable_F299B0,                          0x00f299b0
	.set C0mbinati0nM0de_DrawPart4Int_DL,         0x00f299d0
	.set DLTable_F299E6,                          0x00f299e6
	.set C0mbinati0nM0de_DrawPart5Int_DL,         0x00f29a06
	.set DLTable_F29A1C,                          0x00f29a1c
	.set C0mbinati0nM0de_DrawPart6Int_DL,         0x00f29a3c
	.set DLTable_F29A52,                          0x00f29a52
	.set C0mbinati0nM0de_DrawPart7Int_DL,         0x00f29a72
	.set DLTable_F29A88,                          0x00f29a88
	.set C0mbinati0nM0de_DrawPart8Int_DL,         0x00f29aa8
	.set DLTable_F29ABE,                          0x00f29abe
	.set C0mbinati0nM0de_DrawPart1Pan_DL,         0x00f29ade
	.set C0mbinati0nM0de_DrawPart2Pan_DL,         0x00f29aef
	.set C0mbinati0nM0de_DrawPart3Pan_DL,         0x00f29b00
	.set C0mbinati0nM0de_DrawPart4Pan_DL,         0x00f29b11
	.set C0mbinati0nM0de_DrawPart5Pan_DL,         0x00f29b22
	.set C0mbinati0nM0de_DrawPart6Pan_DL,         0x00f29b33
	.set C0mbinati0nM0de_DrawPart7Pan_DL,         0x00f29b44
	.set C0mbinati0nM0de_DrawPart8Pan_DL,         0x00f29b55
	.set C0mbinati0nM0de_DrawPart1Vol_DL,         0x00f29b66
	.set C0mbinati0nM0de_DrawPart2Vol_DL,         0x00f29b72
	.set C0mbinati0nM0de_DrawPart3Vol_DL,         0x00f29b7e
	.set C0mbinati0nM0de_DrawPart4Vol_DL,         0x00f29b8a
	.set C0mbinati0nM0de_DrawPart5Vol_DL,         0x00f29b96
	.set C0mbinati0nM0de_DrawPart6Vol_DL,         0x00f29ba2
	.set C0mbinati0nM0de_DrawPart7Vol_DL,         0x00f29bae
	.set C0mbinati0nM0de_DrawPart8Vol_DL,         0x00f29bba
	.set Draw_CombinationGroupMenuReMap1_DL,      0x00f2ac50
	.set DL_CombinationGroupMenuReMap1,           0x00f2add2
	.set Draw_SoundGroupMenuReMap1ReMap2_DL,      0x00f2af81
	.set DL_SoundGroupMenuReMap1ReMap2,           0x00f2b130
	.set DLTable_F2B2F9,                          0x00f2b2f9
	.set DL_F2B379,                               0x00f2b379
	.set Data_F2B38F,                             0x00f2b38f
	.set DLPtrTable_F2B510,                       0x00f2b510
	.set DL_GroupSoundDisplayHoldGr0up,           0x00f2b574
	.set DL_GroupCombiDisplayHoldGr0up,           0x00f2b736
	.set DisplayHold_DrawHoldHighlight_DL1,       0x00f2ba0c
	.set DisplayHold_DrawHoldHighlight_DL2,       0x00f2ba16
	.set DL_Drum,                                 0x00f2ba20
	.set Paint_Drum_DL1,                          0x00f2ba50
	.set Paint_Drum_DL2,                          0x00f2ba5a
	.set DL_F2BA64,                               0x00f2ba64
	.set DL_Ext1,                                 0x00f2ba73
	.set DL_F2BB03,                               0x00f2bb03
	.set DL_Usr1,                                 0x00f2bd18
	.set BankLegend_DrawUser_DL3,                 0x00f2bd48
	.set BankLegend_DrawUser_DL2,                 0x00f2bd52
	.set DL_Usr2,                                 0x00f2bd66
	.set BankLegend_DrawUser_DL1,                 0x00f2bd96
	.set BankLegend_DrawUser_DL4,                 0x00f2bda0
	.set GroupCombiDisplayHold_DrawNumberRange_DL2, 0x00f2bdb4
	.set GroupCombiDisplayHold_DrawNumberRange_DL1, 0x00f2bdc3
	.set GroupCombiDisplayHold_DrawNumberRange_DL3, 0x00f2bdd2
	.set GroupDisplayHold_ClearNameSlots_DL,      0x00f2bdf5
	.set MsgPad_F2BE35,                           0x00f2be35
	.set DL_GateArrayCheckPleaseCheckWithOsciloscope, 0x00f2c800
	.set DL_PanelCpuCheckPleaseCheckTheCpuPort,   0x00f2c84d
	.set DL_SineWaveCheckCheckMode1SineWaveRomCheck, 0x00f2c88b
	.set Paint_SineWaveCheckMode_DL1,             0x00f2c9c2
	.set Paint_SineWaveCheckMode_DL3,             0x00f2ca0d
	.set Paint_SineWaveCheckMode_DL2,             0x00f2ca15
	.set Paint_SineWaveCheckMode_DL4,             0x00f2ca26
	.set Paint_SineWaveCheckMode_DL5,             0x00f2ca37
	.set DL_PanelSwLedCheckPleasePushAAnyButton,  0x00f2ca54
	.set Bitmap_F2CAC3,                           0x00f2cac3
	.set ScreenFieldListPtrs,                     0x00f2d000
	.set DL_PleaseWait,                           0x00f2d800
	.set DL_DiskFormattingPleaseWait,             0x00f2d810
	.set DL_SavingToDiskPleaseWait,               0x00f2d834
	.set DL_LoadingFromDiskPleaseWait,            0x00f2d857
	.set DL_Error00TheDataOnTheDiskThatYouAre,    0x00f2d87d
	.set DL_Error01AnErrorHasOccuredWhileTheDisk, 0x00f2d8d4
	.set DL_Error02ThereIsNoDiskInTheDiskDrive,   0x00f2d92d
	.set DL_Error03TheFileThatYouTriedToLoad,     0x00f2d961
	.set DL_Error05AnErrorHasOccuredWhileTheDisk, 0x00f2d99e
	.set DL_Error06TheDiskThatYouAreUsingIsWrite, 0x00f2d9f6
	.set DL_Error07TheDiskThatYouAreUsingIsFull,  0x00f2da71
	.set DL_Error08AnErrorHasOccuredWhileTheDisk, 0x00f2dac2
	.set DL_Error10TheDataIsAlreadyCopyProtected, 0x00f2db63
	.set DL_PasswordOk,                           0x00f2db97
	.set DL_ReminderTheInternalMemoryIsRetainedFor, 0x00f2dba6
	.set DL_Error11ThePasswordThatYouEnteredIs,   0x00f2dc3a
	.set DL_CopyProtectedTheDataOnTheDiskIsCopy,  0x00f2dc79
	.set DL_Error20AProblemHasOccuredWithYour,    0x00f2dcd7
	.set DL_Error21MemoryFull,                    0x00f2dd4f
	.set DL_Error22ItIsNecessaryToPressPunchOut,  0x00f2dd6b
	.set DL_Error23ItIsImpossibleToChangeThe,     0x00f2ddbd
	.set DL_Error24ItIsImpossibleToAssignTwo,     0x00f2de3c
	.set DL_F2DE6B,                               0x00f2de6b
	.set DLTable_ARhythmTrackAlreadyExists,       0x00f2de89
	.set DL_Error25ItIsOnlyPossibleToChange,      0x00f2df1c
	.set DL_Error26ItIsOnlyPossibleToMerge,       0x00f2df6d
	.set DL_Error27ItIsImpossibleToCopyFromOr,    0x00f2dfec
	.set DL_Error46ItIsImpossibleToInsertFromOr,  0x00f2e040
	.set DL_Error28ThisSongIsTooLongToBeSaved,    0x00f2e096
	.set DL_Error29TheMidiFileThatYouHaveTried,   0x00f2e0db
	.set DL_Error30ItIsNotPossibleToChangeThe,    0x00f2e185
	.set DL_Error31TheTimeSignatureOfThePattern,  0x00f2e261
	.set DL_Error32MemoryFull,                    0x00f2e36d
	.set DL_CopyCompletedTheIntroFillInsAndEndingOfY, 0x00f2e389
	.set DL_CopyCompletedYourChosenPatternHasBeenCop, 0x00f2e40c
	.set DL_Error40TheIdentificationIdCodeOfThe,  0x00f2e46a
	.set DL_Error41AnErrorHasOccuredDuringSystem, 0x00f2e4e4
	.set DL_Error42AnErrorHasOccuredDuringSystem, 0x00f2e587
	.set DL_Completed,                            0x00f2e615
	.set DL_Error43TheFileThatYouAreTryingToLoad, 0x00f2e623
	.set DL_WriteCompletedYourEditedSoundHasBeenStor, 0x00f2e6ba
	.set DL_Error44ItIsImpossibleToEditADrumKit,  0x00f2e716
	.set DL_AttentionTheChosenParametersDoNot,    0x00f2e79c
	.set DL_NoSequencerData,                      0x00f2e831
	.set DL_FileConvertError,                     0x00f2e847
	.set DL_ThisIsNotAStandardMidiFile,           0x00f2e85e
	.set DL_TheTimebasePpqResolution,             0x00f2e883
	.set DL_PMemSetHasBeenPushFor10Seconds,       0x00f2e8e2
	.set DL_Error,                                0x00f2e910
	.set DL_JpChordTrackAlreadyExists,            0x00f2e91a
	.set DL_ErrorItIsNotPossibleToUse,            0x00f2e9e3
	.set DL_ErrorItIsNotPossibleToRecord,         0x00f2ea8f
	.set DL_PleaseSelectOneOfTheUser,             0x00f2eaeb
	.set DL_Err0rTheTypeOfInsertedDisk,           0x00f2eb40
	.set DL_UsedOnlyTypeInThisMode,               0x00f2eb9c
	.set DL_Err0rTheQuantityOfThisSong,           0x00f2ebd4
	.set DL_ErrorSpecialTracksSuchAs,             0x00f2ecbc
	.set DL_ErrorAut0PunchRecordingHas,           0x00f2edd4
	.set DL_ErrorTheComposerPatternYou,           0x00f2ee9f
	.set DL_ErrorTheSongThatYouHaveTried,         0x00f2f03f
	.set DL_AttentionItIsImpossibleTo,            0x00f2f1ad
	.set DL_ErrorThisIsAFormat1MidiFileDisk,      0x00f2f261
	.set MsgTail_F2F2AF,                          0x00f2f2af
	.set DL_Error22UmDiesenVorgangAbzuschlie,     0x00f2f722
	.set DL_Error23EsIstJetztNichtMehrM,          0x00f2f77b
	.set DL_Error24EsIstNichtMGlichZweiSpuren,    0x00f2f7ed
	.set DL_F2F857,                               0x00f2f857
	.set DL_Error25EsIstNichtMGlichDieVelocity,   0x00f2f875
	.set DL_Error26SpurenWieRhythmChordUndControl, 0x00f2f8ce
	.set DL_Error31DasGeradeKopiertePatternHatEin, 0x00f2fbe6
	.set DL_Error32SpeicherVoll,                  0x00f2fcae
	.set DL_Error40DerIdentifikationsIdCodeDerZu, 0x00f2fcce
	.set DL_CopyCompletedIntroFillInsUndEndingDesVon, 0x00f3006a
	.set DL_CopyCompletedDasVonLhnenGew,          0x00f30105
	.set RamDefault_F30800,                       0x00f30800
	.set RamDefault_SoundRemap,                   0x00f30810
	.set RamDefault_CombiRemap,                   0x00f30e60
	.set RamDefault_DrumMap,                      0x00f314b0
	.set DLText_CtrLRRdm,                         0x00f32a4e
	.set DL_F3934C,                               0x00f3934c
	.set DL_F394E3,                               0x00f394e3
	.set DL_F39551,                               0x00f39551
	.set Data_F39559,                             0x00f39559
	.set DL_F3A0D1,                               0x00f3a0d1
	.set Data_F3A0D9,                             0x00f3a0d9
	.set DL_AreYouSure,                           0x00f3a461
	.set DL_TrackMergeOkTrackTrackTrack,          0x00f3a47f
	.set DL_F3AB9C,                               0x00f3ab9c
	.set DL_QuantizeTrackStrengthFirstMeasure,    0x00f3abdb
	.set DL_N0teChangeTargetNoteTrack,            0x00f3aeaf
	.set Paint_N0teChange_DL1,                    0x00f3afaf
	.set DL_F3AFE7,                               0x00f3afe7
	.set DLBoxes_F3B065,                          0x00f3b065
	.set Paint_N0teChange_DL2,                    0x00f3b0c3
	.set DL_Transp0seTrackFirstMeasure,           0x00f3b102
	.set DL_F3B379,                               0x00f3b379
	.set DL_MeasureC0pyFromTrackToTrack,          0x00f3bba5
	.set Paint_MeasureC0py_DL,                    0x00f3bc93
	.set DL_F3BCCB,                               0x00f3bccb
	.set DL_F3BD07,                               0x00f3bd07
	.set DLBoxes_F3BD58,                          0x00f3bd58
	.set DL_F3BD90,                               0x00f3bd90
	.set DL_MeasureInsertFromTrackToTrack,        0x00f3bdcf
	.set Paint_MeasureInsert_DL,                  0x00f3bebf
	.set DL_F3BEF7,                               0x00f3bef7
	.set DLBoxes_F3BF48,                          0x00f3bf48
	.set DL_S0ngC0pyFromToSongSongOk,             0x00f3bf80
	.set DL_FromToSongNoTrAllSongNoTrAll,         0x00f3bff8
	.set DL_TrackTrack,                           0x00f3c133
	.set DL_AllAll,                               0x00f3c145
	.set S0ngC0py_DrawFromSong_DL2,               0x00f3c15d
	.set S0ngC0py_DrawToSong_DL,                  0x00f3c16c
	.set S0ngC0py_DrawTracks_DL,                  0x00f3c17b
	.set S0ngC0py_DrawFromSong_DL1,               0x00f3c199
	.set DL_S0ngSelectNameKbS0ngName,             0x00f3c1ad
	.set S0ngSelectName_DrawValues_DL,            0x00f3c31e
	.set DL_F3C351,                               0x00f3c351
	.set DL_F3C367,                               0x00f3c367
	.set DLTable_F3C37D,                          0x00f3c37d
	.set DL_ACurrentTrackWillBeClearedAutomaticaly, 0x00f3c4d5
	.set Paint_S0ngC0py_DL,                       0x00f3c530
	.set DLText_ChordApcControlRhythm,            0x00f3c53f
	.set DL_SequencerMedleyStartFirstS0ng,        0x00f3c562
	.set DL_F3C6B3,                               0x00f3c6b3
	.set DL_SelectIntFd,                          0x00f3c721
	.set DL_FirstS0ngLastS0ng,                    0x00f3c778
	.set SequencerMedley_DrawPlayState_DL4,       0x00f3c7ad
	.set SequencerMedley_DrawSourceBox_DL,        0x00f3c7c3
	.set SequencerMedley_DrawFileTypeBox_DL,      0x00f3c7cd
	.set SequencerMedley_DrawPlayState_DL1,       0x00f3c86b
	.set SequencerMedley_DrawPlayState_DL2,       0x00f3c873
	.set SequencerMedley_DrawPlayState_DL3,       0x00f3c89d
	.set DL_StepRecordPartSelectPressTheUpDownButton, 0x00f3c8a7
	.set DL_F3C947,                               0x00f3c947
	.set Paint_StepRecord_DL2,                    0x00f3cf09
	.set DL_MasterStepRecord,                     0x00f3cf32
	.set DL_F3CF57,                               0x00f3cf57
	.set Paint_StepRecord_DL1,                    0x00f3cfc6
	.set DL_StepRecordTrackTrackClrMeas,          0x00f3d016
	.set StepSelectAddrTable_F3D089,              0x00f3d089
	.set DL_F3D1B9,                               0x00f3d1b9
	.set DL_F3D245,                               0x00f3d245
	.set StepRecord_PrevRowNumber_DL,             0x00f3d353
	.set StepRecord_CurrentRowNumber_DL,          0x00f3d35d
	.set StepRecord_NextRowNumber_DL,             0x00f3d367
	.set StepRecord_PrevRowNoNumber_DL,           0x00f3d371
	.set StepRecord_CurrentRowNoNumber_DL,        0x00f3d376
	.set StepRecord_NextRowNoNumber_DL,           0x00f3d37b
	.set DL_F3D380,                               0x00f3d380
	.set StepRecord_MsgLine_DL,                   0x00f3d38a
	.set StepRecord_PrevRow_DL,                   0x00f3d3ad
	.set StepRecord_CurrentRow_DL,                0x00f3d3cb
	.set StepRecord_NextRow_DL,                   0x00f3d3e9
	.set StepRecord_MarkGrid_DL,                  0x00f3d407
	.set DL_F3DA6F,                               0x00f3da6f
	.set Data_F3DA77,                             0x00f3da77
	.set Data_F3DAA2,                             0x00f3daa2
	.set Data_F3DAED,                             0x00f3daed
	.set DL_F3DC00,                               0x00f3dc00
	.set Data_F3DC21,                             0x00f3dc21
	.set Paint_StepRecord_DL3,                    0x00f3de26
	.set DL_F3DEB2,                               0x00f3deb2
	.set DL_MasterTrackClearAttention,            0x00f3e06e
	.set DL_F3E15C,                               0x00f3e15c
	.set Default_Record78,                        0x00f3f400
	.set Default_Record60,                        0x00f3f412
	.set Default_DspEffect1,                      0x00f3f420
	.set Default_DspEffect2,                      0x00f3f440
	.set Default_DspEffect3,                      0x00f3f460
	.set Default_Part00_A,                        0x00f3f480
	.set Default_Part00_B,                        0x00f3f4a0
	.set Default_Part01_A,                        0x00f3f4c0
	.set Default_Part01_B,                        0x00f3f4e0
	.set Default_Part02_A,                        0x00f3f500
	.set Default_Part02_B,                        0x00f3f520
	.set Default_Part03_A,                        0x00f3f540
	.set Default_Part03_B,                        0x00f3f560
	.set Default_Part04_A,                        0x00f3f580
	.set Default_Part04_B,                        0x00f3f5a0
	.set Default_Part05_A,                        0x00f3f5c0
	.set Default_Part05_B,                        0x00f3f5e0
	.set Default_Part06_A,                        0x00f3f600
	.set Default_Part06_B,                        0x00f3f620
	.set Default_Part07_A,                        0x00f3f640
	.set Default_Part07_B,                        0x00f3f660
	.set Default_Record92,                        0x00f3f680
	.set Default_Record79,                        0x00f3f690
	.set Default_Part08_A,                        0x00f3f6c0
	.set Default_Part08_B,                        0x00f3f6e0
	.set Default_Part09_A,                        0x00f3f700
	.set Default_Part09_B,                        0x00f3f720
	.set Default_Part10_A,                        0x00f3f740
	.set Default_Part10_B,                        0x00f3f760
	.set Default_Part11_A,                        0x00f3f780
	.set Default_Part11_B,                        0x00f3f7a0
	.set Default_Part12_A,                        0x00f3f7c0
	.set Default_Part12_B,                        0x00f3f7e0
	.set Default_Part13_A,                        0x00f3f800
	.set Default_Part13_B,                        0x00f3f820
	.set Default_Part14_A,                        0x00f3f840
	.set Default_Part14_B,                        0x00f3f860
	.set Default_Part15_A,                        0x00f3f880
	.set Default_Part15_B,                        0x00f3f8a0
	.set Default_Part16_A,                        0x00f3f8c0
	.set Default_Part16_B,                        0x00f3f8e0
	.set Default_Part17_A,                        0x00f3f900
	.set Default_Part17_B,                        0x00f3f920
	.set Default_Part18_A,                        0x00f3f940
	.set Default_Part18_B,                        0x00f3f960
	.set Default_Part19_A,                        0x00f3f980
	.set Default_Part19_B,                        0x00f3f9a0
	.set Default_Part20_A,                        0x00f3f9c0
	.set Default_Part20_B,                        0x00f3f9e0
	.set Default_Part21_A,                        0x00f3fa00
	.set Default_Part21_B,                        0x00f3fa20
	.set Default_Part22_A,                        0x00f3fa40
	.set Default_Part22_B,                        0x00f3fa60
	.set Default_Part23_A,                        0x00f3fa80
	.set Default_Part23_B,                        0x00f3faa0
	.set Default_Part24_A,                        0x00f3fac0
	.set Default_Part24_B,                        0x00f3fae0
	.set Default_Part25_A,                        0x00f3fb00
	.set Default_Part25_B,                        0x00f3fb20
	.set Default_Part26_A,                        0x00f3fb40
	.set Default_Part26_B,                        0x00f3fb60
	.set Default_Part27_A,                        0x00f3fb80
	.set Default_Part27_B,                        0x00f3fba0
	.set Default_Part28_A,                        0x00f3fbc0
	.set Default_Part28_B,                        0x00f3fbe0
	.set Default_Part29_A,                        0x00f3fc00
	.set Default_Part29_B,                        0x00f3fc20
	.set Default_Part30_A,                        0x00f3fc40
	.set Default_Part30_B,                        0x00f3fc60
	.set Default_Part31_A,                        0x00f3fc80
	.set Default_Part31_B,                        0x00f3fca0
	.set Default_Record7A,                        0x00f3fcc0
	.set Default_Record98,                        0x00f3fce0
	.set Default_Record99,                        0x00f3fcf0
	.set Default_Record80,                        0x00f3fd10
	.set Default_Record91,                        0x00f3fd28
	.set Default_Record93,                        0x00f3fd38
	.set T_MainTask_PhaseVector,                  0x00f40000
	.set T_Dev7F_WriteSlot8_Slot0,                0x00f40004
	.set T_Dev7F_WriteSlot8_Slot1,                0x00f40008
	.set T_Dev7F_WriteSlot8_Slot2,                0x00f4000c
	.set T_Dev7F_WriteSlot8_Slot3,                0x00f40010
	.set T_Queue2C00_DrainPassAB,                 0x00f40018
	.set T_SeqBuf_FlushStaged,                    0x00f40024
	.set T_Queue2C00_DrainPassB,                  0x00f40038
	.set T_MainTask_Entry,                        0x00f4005c
	.set T_LCD_EntryThunks,                       0x00f400a0
	.set T_SWI7_ServiceCall_Dispatch,             0x00f400a4
	.set T_Paint_GateArrayCheck,                  0x00f400d0
	.set T_Paint_PanelCpuCheck,                   0x00f400e0
	.set T_Paint_SineWaveCheckMode,               0x00f400f0
	.set T_Paint_PanelSwLedCheck,                 0x00f40100
	.set T_F40110,                                0x00f40110
	.set T_ScreenEnter_DebugMonitor,              0x00f40130
	.set T_DebugMonitor_PhaseVector,              0x00f40140
	.set T_CheckingDevice_RunSelfTest,            0x00f40144
	.set T_TestMode_SelectFromPowerOnKeys,        0x00f40148
	.set T_TestMode_Tick,                         0x00f4014c
	.set T_F401D0,                                0x00f401d0
	.set T_F401D4,                                0x00f401d4
	.set T_ParamImage_SnapshotAll,                0x00f401d8
	.set T_ParamImage_QueueDiffAll,               0x00f401dc
	.set T_F401E8,                                0x00f401e8
	.set T_F401EC,                                0x00f401ec
	.set T_F40210,                                0x00f40210
	.set T_ParamImage_SanitizeAll_Entry,          0x00f40214
	.set T_ParamImage_SanitizeAllAndHook_Entry,   0x00f4021c
	.set T_ParamImage_ApplyAndMaskTable_Entry,    0x00f40220
	.set T_ParamImage_WriteRecordHeaders_Entry,   0x00f40224
	.set T_ParamImageAlt_SanitizeCombination_Entry, 0x00f40228
	.set T_F40240,                                0x00f40240
	.set T_Combination_RecallOnSelect,            0x00f40244
	.set T_ParamImage_QueueDiffCombination,       0x00f40248
	.set T_ParamImage_SnapshotCombination_Entry,  0x00f4024c
	.set T_Combination_Recall,                    0x00f40254
	.set T_PanelScreen_RequestRedrawIfFieldQueued, 0x00f40290
	.set T_EditScreen_PhaseVector,                0x00f402a0
	.set T_ModeEnter_Sequencer,                   0x00f402a4
	.set T_Paint_Sequencer,                       0x00f402ac
	.set T_ShowScreen_NoteEditPartSelect,         0x00f402bc
	.set T_EditScreen_EnterNoteEdit,              0x00f402cc
	.set T_ShowScreen_DrumEditPartSelect,         0x00f402dc
	.set T_EditScreen_EnterDrumEdit,              0x00f402ec
	.set T_Transport_ResetAndStartBC,             0x00f40304
	.set T_EditScreen_Tick_Call,                  0x00f40308
	.set T_PowerFail_PrepareSongWorkspace,        0x00f4030c
	.set T_Ctrl_Normalise,                        0x00f405f0
	.set T_PanelWire_EntryThunks,                 0x00f40610
	.set T_PanelWire_Service,                     0x00f40614
	.set T_PanelEvent_PhaseVector,                0x00f40630
	.set T_PanelEvent_Service,                    0x00f40634
	.set T_PanelLed_PhaseVector,                  0x00f40660
	.set T_PanelLed_ProcessRequests,              0x00f40664
	.set T_PanelLed_Refresh,                      0x00f40668
	.set T_PanelLed_SendByteUnconditional,        0x00f40670
	.set T_PanelLed_FlashTransportBeat,           0x00f40674
	.set T_PanelLed_SendByte,                     0x00f40678
	.set T_PanelLed_OnPartEvent,                  0x00f4067c
	.set T_PanelLed_OnClass90Event,               0x00f40680
	.set T_F40684,                                0x00f40684
	.set T_F40688,                                0x00f40688
	.set T_PanelLed_OnClassA8Event,               0x00f4068c
	.set T_F40690,                                0x00f40690
	.set T_PanelLed_OnClass98Event,               0x00f40694
	.set T_PanelLed_OnClass20Event,               0x00f40698
	.set T_PanelLed_OnCtrlParamEvent,             0x00f4069c
	.set T_PanelLed_ToggleActivityLed,            0x00f406a0
	.set T_MIDI_EntryThunks,                      0x00f40710
	.set T_MIDI_RX_Byte,                          0x00f40714
	.set T_MIDI_TX_Ready,                         0x00f40718
	.set T_MIDI_Clock_CatchUpIfAnySlot,           0x00f40720
	.set T_MIDI_PostSendWork,                     0x00f40724
	.set T_MIDI_DrainQueue,                       0x00f40728
	.set T_MIDI_SendBankAndProgram,               0x00f4072c
	.set T_MIDI_PostSendWork_PortB,               0x00f40730
	.set T_MIDI_SendAllNotesOff_AllChannels,      0x00f40734
	.set T_MidiIn_EntryThunks,                    0x00f40740
	.set T_MidiIn_PumpPortA,                      0x00f40744
	.set T_MidiOut_ParamChanged,                  0x00f40748
	.set T_MidiIn_ReqRouteRebuild_Msg0D,          0x00f40754
	.set T_MidiIn_ServiceDeferred,                0x00f40758
	.set T_MidiOut_RunPeriodicTimeouts,           0x00f4075c
	.set T_MidiOut_ResyncChangedParts,            0x00f40760
	.set T_ParamModule_PhaseVector,               0x00f40770
	.set T_ParamImage_PostAllAsChangeEvents_Call, 0x00f40774
	.set T_MidiSettings_ResetToDefault,           0x00f4077c
	.set T_List2030_ProcessEvents,                0x00f40780
	.set T_SoundSel_ClampToProgramAndBankRegs,    0x00f4078c
	.set T_SoundSel_FromProgramAndBankRegs,       0x00f40790
	.set T_Tempo_ApplyBpm,                        0x00f40794
	.set T_ParamMsg_RefreshPartMasks,             0x00f40798
	.set T_ProgramChangeMode_OnEvent,             0x00f4079c
	.set T_F407A0,                                0x00f407a0
	.set T_F407A4,                                0x00f407a4
	.set T_ParamImage_LoadFactoryDefaults,        0x00f407ac
	.set T_ParamImage_PostAllAsChangeEvents,      0x00f407b0
	.set T_Queue2C00_PublishStagedIfPending,      0x00f407b4
	.set T_Queue2C00_PublishStagedDrainPassB,     0x00f407b8
	.set T_ParamChange_NotifyClearSource,         0x00f407cc
	.set T_ParamChange_Notify,                    0x00f407d0
	.set T_ParamRecord_WriteFieldAndStage,        0x00f407d4
	.set T_ParamRecord_WriteFieldAndStage_Copy,   0x00f407d8
	.set T_F407E8,                                0x00f407e8
	.set T_ParamB0_PublishField0IfPending,        0x00f407ec
	.set T_SoundSel_ClampToProgramAndBank,        0x00f407f4
	.set T_CombiSel_ClampToNumberAndBankRegs,     0x00f407fc
	.set T_CombiSel_ClampToNumberAndBank,         0x00f40804
	.set T_CombiSel_GroupMemberFromNumberAndBank, 0x00f40808
	.set T_MidiIn_ControlRecord_Dispatch,         0x00f4080c
	.set T_ParamMsg_RefreshMasksOnCtrlFieldChange, 0x00f40810
	.set T_F40840,                                0x00f40840
	.set T_Evt2030_RunList,                       0x00f40850
	.set T_ParamApply_ByModeOfParam80,            0x00f40854
	.set T_ParamApply_MaskedWriteAndPublish,      0x00f40858
	.set T_ParamShadow_SetPitchBend,              0x00f40864
	.set T_ParamShadow_SetModulation1,            0x00f40868
	.set T_ParamShadow_SetExpression,             0x00f4086c
	.set T_ParamApply_StorePairAndDerive,         0x00f40870
	.set T_ParamShadow_SetField3,                 0x00f40874
	.set T_ParamApply_WriteStagedAndPublish,      0x00f40878
	.set T_ParamApply_PublishStagedAndPostSeven,  0x00f4087c
	.set T_ParamApply_PublishStagedPairBCDE,      0x00f40880
	.set T_ParamApply_PublishStagedPair,          0x00f40884
	.set T_ParamApply_WriteStagedAndPublish_Copy, 0x00f40888
	.set T_ParamApply_PublishStagedPair_Copy,     0x00f4088c
	.set T_F40894,                                0x00f40894
	.set T_ParamShadow_FlushAll,                  0x00f40898
	.set T_ParamApply_OneHotOfSix,                0x00f4089c
	.set T_SysExModule_EntryThunks,               0x00f408e0
	.set T_SysExDump_RunSendJob,                  0x00f408e4
	.set T_SysExRx_PollRing601646,                0x00f408e8
	.set T_SysExTx_Tempo,                         0x00f408ec
	.set T_GmMode_HandleChange,                   0x00f408f0
	.set T_GmMode_OnEventPassB,                   0x00f408f4
	.set T_SysExTx_EmitStagedParams,              0x00f40900
	.set T_SysExRx_PollRing601C6E,                0x00f40904
	.set T_MidiFilePlay_Tick,                     0x00f40950
	.set T_MidiFileDirectPlay_LcdKeyRow1,         0x00f40954
	.set T_MidiFileDirectPlay_InitOnEntry,        0x00f40958
	.set T_MidiFileDirectPlay_RestoreOnLeave,     0x00f4095c
	.set T_wsa1_prom_b_Join2,                     0x00f409a0
	.set T_Transport_StartCAndB,                  0x00f409a4
	.set T_Transport_StopAllRunning,              0x00f409ac
	.set T_F409C0,                                0x00f409c0
	.set T_F409C4,                                0x00f409c4
	.set T_Seq_MainLoopService,                   0x00f409c8
	.set T_Seq_RewindAfterSongLoad,               0x00f409cc
	.set T_Seq_RequestRewind,                     0x00f409e0
	.set T_Seq_RewindOnMidiStart,                 0x00f409e4
	.set T_BStore_TrackToPart_SaveBackup,         0x00f409ec
	.set T_BStore_TrackToPart_RestoreBackup,      0x00f409f0
	.set T_F409FC,                                0x00f409fc
	.set T_F40A00,                                0x00f40a00
	.set T_Var34D1_SetBits20,                     0x00f40a08
	.set T_TimedEvents_ClearEndedTrackBits,       0x00f40a0c
	.set T_SeqBufRing_Discard,                    0x00f40a10
	.set T_TimedEventRing_Discard,                0x00f40a14
	.set T_Sequencer_ResetToDefault,              0x00f40a18
	.set T_SeqRecord_StartOnFirstEvent,           0x00f40a24
	.set T_SeqRecord_TerminateTracksIfRecording,  0x00f40a28
	.set T_F40A34_Zeroed,                         0x00f40a34	; prom_b: 8 zero bytes (nop) that run into T_SeqCycle_TickDeferredAction
	.set T_SeqCycle_TickDeferredAction,           0x00f40a3c
	.set T_SeqMasterTrack_UpdateActiveFromSavedMask, 0x00f40a70
	.set T_Seq_ApplySongBeatsPerBar,              0x00f40ac8
	.set T_BStore_SeekChainToMeasure,             0x00f40c5c
	.set T_Seq_BeatsToMeasureAndBeat,             0x00f40c60
	.set T_BStore_AllocBlock_B_Veneer,            0x00f40c88
	.set T_Seq_RequestRewindOnEvent,              0x00f40cbc
	.set T_ModeEnter_SeqPlay_Fwd,                 0x00f40d90
	.set T_ModeEnter_RealtimeRecord_Fwd,          0x00f40d98
	.set T_ScreenEnter_SeqPlayScreen_Fwd,         0x00f40da0
	.set T_ScreenEnter_CyclePlayScreen_Fwd,       0x00f40db0
	.set T_ScreenEnter_RealtimeRecordScreen_Fwd,  0x00f40dc0
	.set T_ScreenEnter_CycleRecordScreen_Fwd,     0x00f40dd0
	.set T_F40DE0,                                0x00f40de0
	.set T_ScreenEnter_CyclePlayEditScreen29_Fwd, 0x00f40df0
	.set T_ScreenEnter_MetronomeBalanceScreen_Fwd, 0x00f40e00
	.set T_RingPutBlock_EntryThunks,              0x00f40ed0
	.set T_Link_SendBlockIn32ByteChunks,          0x00f40ed4
	.set T_Link_ServiceTask,                      0x00f40ed8
	.set T_INT0_LinkByte,                         0x00f40edc
	.set T_INTT2_Reti,                            0x00f40ee0
	.set T_INTTC2_uDMA2Done,                      0x00f40ee4
	.set T_INTTC3_LinkDmaDone,                    0x00f40ee8
	.set T_Link_SendCommandE1,                    0x00f40eec
	.set T_Link_SendCommandE2,                    0x00f40ef0
	.set T_SC1_Vtable,                            0x00f40f00
	.set T_SC1_Service,                           0x00f40f04
	.set T_SC1_TxFlush,                           0x00f40f08
	.set T_INT6_SC1_PeerRequest,                  0x00f40f0c
	.set T_INTRX1_SC1_Dispatch,                   0x00f40f10
	.set T_INTTX1_SC1_Dispatch,                   0x00f40f14
	.set T_SC1_Entry_F40F18_Ret,                  0x00f40f18
	.set T_F40F1C,                                0x00f40f1c
	.set T_F40F20,                                0x00f40f20
	.set T_PanelTask_EntryVectors,                0x00f40f30
	.set T_PanelTask_Step,                        0x00f40f34
	.set T_Queue2C00_AppendRegs,                  0x00f40f38
	.set T_Queue2E00_AppendRegs,                  0x00f40f3c
	.set T_List2030_AppendRegs,                   0x00f40f40
	.set T_PanelTimers_Step,                      0x00f40f44
	.set T_PanelState_CheckRequestAllowed_2,      0x00f40f4c
	.set T_UiEventList_Publish,                   0x00f40f50
	.set T_UiEventList_RunPassA,                  0x00f40f5c
	.set T_UiEventList_RunPassB,                  0x00f40f60
	.set T_UiEventList_RunPassC,                  0x00f40f64
	.set T_PanelHold_Tick,                        0x00f40f74
	.set T_Msg0716_InitAllRecords_Entry,          0x00f40fb0
	.set T_Msg0716_FlushIfPending,                0x00f40fb4
	.set T_Msg0716_AllPartsResetBendAndModulation, 0x00f40fd0
	.set T_Msg0716_PostSysEx50_87_StackArg,       0x00f40fdc
	.set T_Msg0716_PostRestageAllParts,           0x00f40fec
	.set T_Msg0716_PostClearSoundRamAndRestageAllParts, 0x00f40ff0
	.set T_F40FF4,                                0x00f40ff4
	.set T_SoundSel_ToProgramAndBank,             0x00f40ffc
	.set T_SoundSel_FromProgramAndBank,           0x00f41000
	.set T_PartSound_FromProgramChange,           0x00f41004
	.set T_PartSound_ToProgramChange,             0x00f41008
	.set T_Msg0716_PostSysEx50_A3,                0x00f4100c
	.set T_SoundName_Lookup,                      0x00f41010
	.set T_SoundGroupName_Lookup,                 0x00f41018
	.set T_SoundGroup_MaxMemberIndex_Get,         0x00f4101c
	.set T_CombiSel_ToNumberAndBank,              0x00f41024
	.set T_CombiSel_FromNumberAndBank,            0x00f41028
	.set T_CombiName_Lookup,                      0x00f4102c
	.set T_CombiGroupName_Lookup,                 0x00f41030
	.set T_SoundGroup_MaxMemberIndex_GetToneCopy, 0x00f41034
	.set T_CreatorSelect_ReadSlotLabelIds,        0x00f41038
	.set T_Cpu2Query_DrainRecordReplies,          0x00f4103c
	.set T_DrumMap_MapNoteForPart,                0x00f41040
	.set T_DrumMap_MapNoteForPart_StackArgs,      0x00f41044
	.set T_SoundRemap_ResetToDefault,             0x00f41048
	.set T_CombiRemap_ResetToDefault,             0x00f4104c
	.set T_DrumMap_ResetToDefault,                0x00f41050
	.set T_Cpu2Query_RefreshPartSoundRecord,      0x00f41054
	.set T_Msg0716_PostGmSystemOnOff,             0x00f4105c
	.set T_Msg0716_PostSysEx50_92_SaveRegs,       0x00f41060
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_Msg0716_HandlerTables_13, 0x00f41070
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_8_Msg0716_HandlerTables_13, 0x00f41074
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_16_Msg0716_HandlerTables_13, 0x00f41078
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_24_Msg0716_HandlerTables_13, 0x00f4107c
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_32_Msg0716_HandlerTables_13, 0x00f41080
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_40_Msg0716_HandlerTables_13, 0x00f41084
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_48_Msg0716_HandlerTables_13, 0x00f41088
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_56_Msg0716_HandlerTables_13, 0x00f4108c
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_64_Msg0716_HandlerTables_13, 0x00f41090
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_72_Msg0716_HandlerTables_13, 0x00f41094
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_80_Msg0716_HandlerTables_13, 0x00f41098
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_88_Msg0716_HandlerTables_13, 0x00f4109c
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_96_Msg0716_HandlerTables_13, 0x00f410a0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_104_Msg0716_HandlerTables_13, 0x00f410a4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_112_Msg0716_HandlerTables_13, 0x00f410a8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_120_Msg0716_HandlerTables_13, 0x00f410ac
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_128_Msg0716_HandlerTables_13, 0x00f410b0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_136_Msg0716_HandlerTables_13, 0x00f410b4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_144_Msg0716_HandlerTables_13, 0x00f410b8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_152_Msg0716_HandlerTables_13, 0x00f410bc
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_160_Msg0716_HandlerTables_13, 0x00f410c0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_168_Msg0716_HandlerTables_13, 0x00f410c4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_176_Msg0716_HandlerTables_13, 0x00f410c8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_184_Msg0716_HandlerTables_13, 0x00f410cc
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_192_Msg0716_HandlerTables_13, 0x00f410d0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_200_Msg0716_HandlerTables_13, 0x00f410d4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_208_Msg0716_HandlerTables_13, 0x00f410d8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_216_Msg0716_HandlerTables_13, 0x00f410dc
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_224_Msg0716_HandlerTables_13, 0x00f410e0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_232_Msg0716_HandlerTables_13, 0x00f410e4
	.set T_F410E8,                                0x00f410e8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_248_Msg0716_HandlerTables_13, 0x00f410ec
	.set T_F410F0,                                0x00f410f0
	.set T_F410F4,                                0x00f410f4
	.set T_F410F8,                                0x00f410f8
	.set T_F410FC,                                0x00f410fc
	.set T_F41100,                                0x00f41100
	.set T_F41104,                                0x00f41104
	.set T_F41108,                                0x00f41108
	.set T_F4110C,                                0x00f4110c
	.set T_Msg0716_SetPendingBit0,                0x00f41110
	.set T_Msg0716_SetPendingBit1,                0x00f41114
	.set T_Msg0716_SetPendingBit2,                0x00f41118
	.set T_Msg0716_SetPendingBit3,                0x00f4111c
	.set T_F41120,                                0x00f41120
	.set T_F41124,                                0x00f41124
	.set T_F41128,                                0x00f41128
	.set T_F4112C,                                0x00f4112c
	.set T_F41130,                                0x00f41130
	.set T_F41134,                                0x00f41134
	.set T_F41138,                                0x00f41138
	.set T_F4113C,                                0x00f4113c
	.set T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_164_6, 0x00f41140
	.set T_F41144,                                0x00f41144
	.set T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_280_2, 0x00f41148
	.set T_F4114C,                                0x00f4114c
	.set T_F41150,                                0x00f41150
	.set T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_292_14, 0x00f41154
	.set T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_192_13, 0x00f41158
	.set T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_248_7, 0x00f4115c
	.set T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_352_4, 0x00f41160
	.set T_F41164,                                0x00f41164
	.set T_UiListB_Class9A_Nop,                   0x00f41168
	.set T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_372_19, 0x00f4116c
	.set T_F41170,                                0x00f41170
	.set T_F41174,                                0x00f41174
	.set T_F41178,                                0x00f41178
	.set T_F4117C,                                0x00f4117c
	.set T_Msg0716_EventPartPostCC78_AllSoundOff, 0x00f41180
	.set T_NoteRouting_PhaseVector,               0x00f411b0
	.set T_NoteRouting_RebuildIfPending,          0x00f411b4
	.set T_NoteRouting_RebuildForSong,            0x00f411b8
	.set T_NoteRouting_Rebuild,                   0x00f411bc
	.set T_NoteRouting_OnPartMidiEvent,           0x00f411c0
	.set T_NoteRouting_OnPartPlayParamEvent,      0x00f411c4
	.set T_F411C8,                                0x00f411c8
	.set T_F411CC,                                0x00f411cc
	.set T_NoteRouting_OnPlayModeRequest,         0x00f411d0
	.set T_NoteRouting_OnMidiSystemEvent,         0x00f411d4
	.set T_F411D8,                                0x00f411d8
	.set T_F411DC,                                0x00f411dc
	.set T_NoteRouting_SetMidiOutPorts,           0x00f411e0
	.set T_F411E4,                                0x00f411e4
	.set T_F411E8,                                0x00f411e8
	.set T_NoteRouting_SetSoloAndRebuild,         0x00f411ec
	.set T_Link_SendCommandE4,                    0x00f41230
	.set T_Link_SendCommand3_WaitTicks,           0x00f41234
	.set T_Link_SendCommand5_WaitDone,            0x00f41238
	.set T_Link_WaitBlockDone,                    0x00f4123c
	.set T_Link_SendCommandE7,                    0x00f41240
	.set T_SysExThirdRegion_FetchNextChunk,       0x00f41250
	.set T_SysExThirdRegion_AcceptRequest,        0x00f41254
	.set T_SysExToneImage_WriteByte,              0x00f41258
	.set T_SysExParam_ExecSoundWriteRequest,      0x00f4125c
	.set T_SysExThirdRegion_GetReplyDataBuffer,   0x00f41260
	.set T_SysExThirdRegion_SendReplyChunk,       0x00f41264
	.set T_Ram3800_Start_Entry,                   0x00f413b0
	.set T_MidiInA_ProcessRing,                   0x00f413b4
	.set T_F413B8,                                0x00f413b8
	.set T_TimedEvents_ProcessRing,               0x00f413bc
	.set T_PartNotes_ReleaseAllReceivedMidiIn,    0x00f413c0
	.set T_NoteList_ReleaseAllSource0,            0x00f413c4
	.set T_PartNotes_ReleaseAllTrackNotes,        0x00f413c8
	.set T_F413CC,                                0x00f413cc
	.set T_Ram3800_InitDataImage,                 0x00f413d0
	.set T_NoteRouting_ApplyQueuedChanges,        0x00f413d4
	.set T_NoteRouting_DefaultRecordPtrs,         0x00f413dc
	.set T_PartNoteList_NextHeldNote,             0x00f413e0
	.set T_MidiInB_ProcessRing,                   0x00f413f8
	.set T_ToneGen_SendSoundSelNote,              0x00f413fc
	.set T_MidiOut_SendNote,                      0x00f41400
	.set T_BStore_CompactBlocks_Veneer,           0x00f414b0
	.set T_BStore_RebuildFreeListAfterLoad_Veneer, 0x00f414b4
	.set T_SysExDump_RestoreSavedCurrentBank,     0x00f414b8
	.set T_SysExDump_PrepareSequencerData,        0x00f414bc
	.set T_SeqFile_RestoreSavedCurrentBank,       0x00f414c0
	.set T_SeqFile_PrepareSaveAllBanks,           0x00f414c4
	.set T_ModeEnter_Sound,                       0x00f41500
	.set T_ModeEnter_Combination,                 0x00f41508
	.set T_ScreenEnter_PowerOnSplash,             0x00f41510
	.set T_InstallPainter_SoundMode_Entry,        0x00f41520
	.set T_InstallPainter_C0mbinati0nM0de_Entry,  0x00f41530
	.set T_InstallPainter_SoundGroupMenu_Entry,   0x00f41540
	.set T_InstallPainter_GroupSoundDisplayHold_Entry, 0x00f41550
	.set T_InstallPainter_CombinationGroupMenu_Entry, 0x00f41560
	.set T_InstallPainter_CombinationGroupMenu_Entry_5, 0x00f41570
	.set T_InstallPainter_GroupCombiDisplayHold_Entry, 0x00f41580
	.set T_F41590,                                0x00f41590
	.set T_UiEvent_MarkRedrawFromClass20Block,    0x00f415a0
	.set T_GmMode_RepaintModeScreen,              0x00f415a4
	.set T_UiEvent_SyncSoundSelection,            0x00f415a8
	.set T_UiEventClassA8_ShowGroupScreen,        0x00f415ac
	.set T_F415B0,                                0x00f415b0
	.set T_LCD_BlitValueBar,                      0x00f415b4
	.set T_UiEventClass7A_QueueDialValueRedraw,   0x00f415b8
	.set T_Mode_SwitchToCombination,              0x00f415c0
	.set T_Mode_SwitchToSound,                    0x00f415c4
	.set T_SoundGroup_ReloadSelection,            0x00f415c8
	.set T_MessageScreen_Paint,                   0x00f41600
	.set T_InstallPainter_MessageScreen,          0x00f41604
	.set T_PanelMode_MidiEnter,                   0x00f41640
	.set T_Paint_MidiMenu,                        0x00f41650
	.set T_F41660,                                0x00f41660
	.set T_F41670,                                0x00f41670
	.set T_F41680,                                0x00f41680
	.set T_Paint_MidiRealtimeMessages,            0x00f41690
	.set T_F416A0,                                0x00f416a0
	.set T_F416B0,                                0x00f416b0
	.set T_F416C0,                                0x00f416c0
	.set T_F41700,                                0x00f41700
	.set T_Paint_SysexBulkDump_Entry,             0x00f41710
	.set T_Paint_GeneralMidiMode_Entry,           0x00f41720
	.set T_Paint_Sending_Entry,                   0x00f41730
	.set T_Paint_SystemExclusivePleaseWait_Entry, 0x00f41734
	.set T_Paint_MidiTotalMode,                   0x00f4173c
	.set T_Paint_MidiInputOutputFilter,           0x00f4174c
	.set T_Paint_MidiOutProgramChange,            0x00f4175c
	.set T_SysexBulkDump_PhaseVector,             0x00f4176c
	.set T_DisplayList_Run,                       0x00f417f0
	.set T_DisplayListB_Run,                      0x00f417f4
	.set T_DLB_Handler_StringTable,               0x00f417f8
	.set T_DLB_Handler_StringTable2,              0x00f417fc
	.set T_DLB_Handler_Decimal,                   0x00f41800
	.set T_DLB_Handler_Decimal_2,                 0x00f41804
	.set T_DLB_Handler_Decimal2Words,             0x00f4180c
	.set T_DLB_Handler_DecimalSigned2Words,       0x00f41814
	.set T_DLB_Handler_Array8,                    0x00f4181c
	.set T_DLB_Handler_Array8_2,                  0x00f41820
	.set T_DLB_Handler_Array6,                    0x00f41824
	.set T_DLHandler_IX_Text,                     0x00f4182c
	.set T_DrawValueGlyph_24x24,                  0x00f41834
	.set T_ModeEnter_CombiEditPart,               0x00f41840
	.set T_ScreenEnter_CombiEditPartMenu,         0x00f41848
	.set T_ScreenEnter_CombiEditInternalSound,    0x00f41858
	.set T_ScreenEnter_CombiEditConfigure_B2,     0x00f41868
	.set T_ScreenEnter_WriteProtectError,         0x00f41878
	.set T_ScreenEnter_CombiEditInternalSound_B4, 0x00f41888
	.set T_ScreenEnter_CombiEditInternalSound_B5, 0x00f41898
	.set T_ScreenEnter_Effect2OutputConflict,     0x00f418a8
	.set T_ScreenEnterBody_CombiEditMixer,        0x00f418b8
	.set T_CombiEdit_OnPartParamEvent,            0x00f418c8
	.set T_CombiEdit_RunPendingRepaint,           0x00f418cc
	.set T_PanelMode_System_Enter,                0x00f41910
	.set T_Screen_System_Enter,                   0x00f41918
	.set T_Screen_TuneScale_Enter,                0x00f41928
	.set T_Screen_TouchSensitivityOrTest_Enter,   0x00f41938
	.set T_Screen_ControllerAssign_Enter,         0x00f41948
	.set T_Screen_MainOutEqualizer_Enter,         0x00f41958
	.set T_Screen_ReMapEdit_Enter,                0x00f41968
	.set T_Screen_SoundCombinationManager_Enter,  0x00f41978
	.set T_Screen_MemoryProtect_Enter,            0x00f41988
	.set T_Screen_DataLoadFilter_Enter,           0x00f41998
	.set T_Screen_DspEffect_Enter,                0x00f419a8
	.set T_Screen_DrumsMapNaming_Enter,           0x00f419b8
	.set T_CombiEdit_Begin,                       0x00f41a00
	.set T_ScreenEnter_CombiEditMenuRedirect,     0x00f41a08
	.set T_ScreenEnter_CombiEditMenu,             0x00f41a18
	.set T_F41A28,                                0x00f41a28
	.set T_ScreenEnter_CombinationNaming,         0x00f41a38
	.set T_F41A48,                                0x00f41a48
	.set T_F41A58,                                0x00f41a58
	.set T_ScreenEnter_CombiEditDspEffect,        0x00f41a68
	.set T_ScreenEnter_CombiEditMixer,            0x00f41a78
	.set T_F41A88,                                0x00f41a88
	.set T_Screen_CombinationNaming_Enter,        0x00f41a98
	.set T_Value_ToAsciiDigits3_RightJustified,   0x00f41af0
	.set T_Value_ToAsciiDigits3_LeftJustified,    0x00f41af4
	.set T_Value_ToAsciiDigits3,                  0x00f41b00
	.set T_Value_ApplyNibbleDeltaClamped,         0x00f41b04
	.set T_PanelButton_CallTableEntry,            0x00f41b08
	.set T_PanelButton_CallPageTableEntry,        0x00f41b0c
	.set T_FixedEventList_AppendStackArgs,        0x00f41b10
	.set T_EventQueue_AppendStackArgs,            0x00f41b14
	.set T_PendingEventQueue_AppendStackArgs,     0x00f41b18
	.set T_AnalogScan_PhaseVector,                0x00f41b30
	.set T_AnalogScan_All,                        0x00f41b34
	.set T_Ring608A0A_Get,                        0x00f41cd0
	.set T_Ring608A0A_IsEmpty,                    0x00f41cdc
	.set T_Ring608A0A_Init,                       0x00f41ce0
	.set T_Ring60480A_Get,                        0x00f41cf4
	.set T_Ring60480A_Init,                       0x00f41d04
	.set T_Ring60195A_Get,                        0x00f41d18
	.set T_Ring60195A_IsEmpty,                    0x00f41d24
	.set T_Ring60195A_Init,                       0x00f41d28
	.set T_Ring601B64_Init,                       0x00f41d4c
	.set T_TimedEventRing_Put,                    0x00f41d64
	.set T_TimedEventRing_Init,                   0x00f41d70
	.set T_TimedEventRing_ScanRewind,             0x00f41d74
	.set T_TimedEventRing_Scan,                   0x00f41d78
	.set T_SeqBufRing_Get,                        0x00f41d84
	.set T_SeqBufRing_PutBlock,                   0x00f41d8c
	.set T_SeqBufRing_IsEmpty,                    0x00f41d90
	.set T_SeqBufRing_Init,                       0x00f41d94
	.set T_MidiInARing_Put,                       0x00f41dac
	.set T_MidiInARing_PutBlock,                  0x00f41db0
	.set T_MidiInARing_IsEmpty,                   0x00f41db4
	.set T_MidiInARing_Init,                      0x00f41db8
	.set T_MidiInARing_ScanRewind,                0x00f41dbc
	.set T_MidiInARing_Scan,                      0x00f41dc0
	.set T_MidiInBRing_PutBlock,                  0x00f41dd4
	.set T_MidiInBRing_IsEmpty,                   0x00f41dd8
	.set T_MidiInBRing_Init,                      0x00f41ddc
	.set T_MidiInBRing_ScanRewind,                0x00f41de0
	.set T_MidiInBRing_Scan,                      0x00f41de4
	.set T_Ring601432_Get,                        0x00f41df0
	.set T_Ring601432_Put,                        0x00f41df4
	.set T_Ring601432_PutBlock,                   0x00f41df8
	.set T_Ring601432_IsEmpty,                    0x00f41dfc
	.set T_Ring601432_Init,                       0x00f41e00
	.set T_Ring60153C_Get,                        0x00f41e14
	.set T_Ring60153C_PutBlock,                   0x00f41e1c
	.set T_Ring60153C_Init,                       0x00f41e24
	.set T_Ring601646_Get,                        0x00f41e38
	.set T_Ring601646_Put,                        0x00f41e3c
	.set T_Ring601646_PutBlock,                   0x00f41e40
	.set T_Ring601646_Init,                       0x00f41e48
	.set T_Ring601850_Get,                        0x00f41e5c
	.set T_Ring601850_PutBlock,                   0x00f41e64
	.set T_Ring601850_IsEmpty,                    0x00f41e68
	.set T_Ring601850_Init,                       0x00f41e6c
	.set T_Ring60000C_Get,                        0x00f41e80
	.set T_Ring60000C_IsEmpty,                    0x00f41e8c
	.set T_Ring60000C_Init,                       0x00f41e90
	.set T_Ring601C6E_Get,                        0x00f41ea4
	.set T_Ring601C6E_Put,                        0x00f41ea8
	.set T_Ring601C6E_PutBlock,                   0x00f41eac
	.set T_Ring601C6E_IsEmpty,                    0x00f41eb0
	.set T_Ring601C6E_Init,                       0x00f41eb4
	.set T_Dispatch_Code80_Bracketed,             0x00f41ed0
	.set T_Dispatch_Code80,                       0x00f41ed4
	.set T_UiPaint_Solo,                          0x00f41ed8
	.set T_Gfx_EraseRect,                         0x00f41ee0
	.set T_Gfx_DrawLine_Solid,                    0x00f41ee4
	.set T_Gfx_DrawLine_Dashed,                   0x00f41ee8
	.set T_List2030_PostSoundSelection,           0x00f41eec
	.set T_SeqFile_Load,                          0x00f41ef8
	.set T_SeqFile_Save,                          0x00f41efc
	.set T_BStore_GetDiskBankPassword,            0x00f41f00
	.set T_BStore_GetAnyBankPassword,             0x00f41f04
	.set T_F41F10,                                0x00f41f10
	.set T_F41F14,                                0x00f41f14
	.set T_F41F18,                                0x00f41f18
	.set T_F41F30,                                0x00f41f30
	.set T_F41F34,                                0x00f41f34
	.set T_ModeEnter_SoundEdit,                   0x00f41f54
	.set T_ScreenEnter_SoundEditMenu,             0x00f41f5c
	.set T_ToneEditPage_A0_ModelingTop,           0x00f41f6c
	.set T_F41F7C,                                0x00f41f7c
	.set T_F41F8C,                                0x00f41f8c
	.set T_ToneEditPage_A3_PositionParameter,     0x00f41f9c
	.set T_ToneEditPage_A4_PositionMovement,      0x00f41fac
	.set T_ToneEditPage_A5_FittingMutingTuning,   0x00f41fbc
	.set T_ToneEditPage_A6_TouchDepth,            0x00f41fcc
	.set T_ToneEditPage_A7_ResoModeKeyFollow,     0x00f41fdc
	.set T_ToneEditPage_A8_SerialParallel,        0x00f41fec
	.set T_ScreenEnter_SoundEditPitchTune,        0x00f41ffc
	.set T_ScreenEnter_SoundEditPitchEnvelope1,   0x00f4200c
	.set T_ScreenEnter_SoundEditPitchEnvelope2,   0x00f4201c
	.set T_ScreenEnter_SoundEditPitchLfo,         0x00f4202c
	.set T_ScreenEnter_SoundEditAmpLevel1,        0x00f4203c
	.set T_ScreenEnter_SoundEditAmpLevel2,        0x00f4204c
	.set T_ScreenEnter_SoundEditAmpEnvelope1,     0x00f4205c
	.set T_ScreenEnter_SoundEditAmpEnvelope2,     0x00f4206c
	.set T_ScreenEnter_SoundEditAmpLfo,           0x00f4207c
	.set T_ScreenEnter_SoundEditControllerPage1,  0x00f4208c
	.set T_ScreenEnter_SoundEditControllerPage2,  0x00f4209c
	.set T_ScreenEnter_SoundEditDigitalEffectFromMenu, 0x00f420ac
	.set T_ScreenEnter_SoundEditFilterLpf12,      0x00f420bc
	.set T_ScreenEnter_SoundEditFilterHpf12,      0x00f420cc
	.set T_ScreenEnter_SoundEditFilterLpf24,      0x00f420dc
	.set T_ScreenEnter_SoundEditFilterHpf24,      0x00f420ec
	.set T_ScreenEnter_SoundEditFilterBpf,        0x00f420fc
	.set T_ScreenEnter_SoundEditFilterThrough,    0x00f4210c
	.set T_ScreenEnter_SoundEditFilterKeyFollow,  0x00f4211c
	.set T_ScreenEnter_SoundEditFilterEnvelope1,  0x00f4212c
	.set T_ScreenEnter_SoundEditFilterEnvelope2,  0x00f4213c
	.set T_ScreenEnter_SoundEditFilterLfo,        0x00f4214c
	.set T_ScreenEnter_SoundEditModelingToneTemplate, 0x00f4215c
	.set T_ScreenEnter_SoundEditToneLayerPanning, 0x00f4216c
	.set T_ScreenEnter_SoundEditToneLayerKeyLayer, 0x00f4217c
	.set T_ScreenEnter_SoundEditToneLayerVelocityLayer, 0x00f4218c
	.set T_ScreenEnter_SoundEditModelingDriverWaveform, 0x00f4219c
	.set T_DiskScreens_PhaseVector,               0x00f42250
	.set T_ModeEnter_SoundCopy,                   0x00f42254
	.set T_ModeEnter_SoundCopy_Call,              0x00f4225c
	.set T_Paint_DiskMenu,                        0x00f42264
	.set T_Paint_MidiFileDirectPlay,              0x00f42274
	.set T_ScreenEnter_SoundEditDspEffect,        0x00f42320
	.set T_ScreenEnter_SoundEditDrumMenu,         0x00f42330
	.set T_F42340,                                0x00f42340
	.set T_ScreenEnter_SoundEditCopy,             0x00f42350
	.set T_ScreenEnter_SoundEditMemoryWrite,      0x00f42360
	.set T_ScreenEnter_SoundEditNaming,           0x00f42370
	.set T_Ring608A0A_DrainAll,                   0x00f42380
	.set T_Paint_DiskL0adFile,                    0x00f423a0
	.set T_PageDispatch_DiskSaveFile,             0x00f423b0
	.set T_PageDispatch_MidiFileSave,             0x00f423c0
	.set T_Paint_FloppyDiskFormatSelectType,      0x00f423d0
	.set T_PageDispatch_L0adSingleS0und,          0x00f423e0
	.set T_Paint_FloppyDiskFormatAreYouSure,      0x00f423f0
	.set T_Paint_MidiFileL0ad,                    0x00f42400
	.set T_DiskLoad_SetContentTypeFromSelectedEntry, 0x00f42418
	.set T_PageDispatch_L0adSingleC0mbination,    0x00f4241c
	.set T_F42470,                                0x00f42470
	.set T_F42474,                                0x00f42474
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_16_Msg0716_HandlerTables_56_26, 0x00f42478
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_24_Msg0716_HandlerTables_56_26, 0x00f4247c
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_32_Msg0716_HandlerTables_56_26, 0x00f42480
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_40_Msg0716_HandlerTables_56_26, 0x00f42484
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_48_Msg0716_HandlerTables_56_26, 0x00f42488
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_56_Msg0716_HandlerTables_56_26, 0x00f4248c
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_64_Msg0716_HandlerTables_56_26, 0x00f42490
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_72_Msg0716_HandlerTables_56_26, 0x00f42494
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_80_Msg0716_HandlerTables_56_26, 0x00f42498
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_88_Msg0716_HandlerTables_56_26, 0x00f4249c
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_96_Msg0716_HandlerTables_56_26, 0x00f424a0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_104_Msg0716_HandlerTables_56_26, 0x00f424a4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_112_Msg0716_HandlerTables_56_26, 0x00f424a8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_120_Msg0716_HandlerTables_56_26, 0x00f424ac
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_128_Msg0716_HandlerTables_56_26, 0x00f424b0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_136_Msg0716_HandlerTables_56_26, 0x00f424b4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_144_Msg0716_HandlerTables_56_26, 0x00f424b8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_152_Msg0716_HandlerTables_56_26, 0x00f424bc
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_160_Msg0716_HandlerTables_56_26, 0x00f424c0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_168_Msg0716_HandlerTables_56_26, 0x00f424c4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_176_Msg0716_HandlerTables_56_26, 0x00f424c8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_184_Msg0716_HandlerTables_56_26, 0x00f424cc
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_192_Msg0716_HandlerTables_56_26, 0x00f424d0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_200_Msg0716_HandlerTables_56_26, 0x00f424d4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_208_Msg0716_HandlerTables_56_26, 0x00f424d8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_216_Msg0716_HandlerTables_56_26, 0x00f424dc
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_224_Msg0716_HandlerTables_56_26, 0x00f424e0
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_232_Msg0716_HandlerTables_56_26, 0x00f424e4
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_240_Msg0716_HandlerTables_56_26, 0x00f424e8
	.set T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_248_Msg0716_HandlerTables_56_26, 0x00f424ec
	.set T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_452_17, 0x00f424f0
	.set T_Msg0716_OnPitchBendEvent,              0x00f424f4
	.set T_Msg0716_EventPartPostCC01_ModulationIfEnabled, 0x00f424f8
	.set T_Msg0716_EventPartPostCC0B_Expression,  0x00f424fc
	.set T_Msg0716_OnChannelPressureEvent,        0x00f42500
	.set T_Msg0716_EventPartPostCC40_SustainFromValueIfEnabled, 0x00f42504
	.set T_F42508,                                0x00f42508
	.set T_F4250C,                                0x00f4250c
	.set T_Msg0716_EventPartPostCC10_GeneralPurpose1IfEnabled, 0x00f42510
	.set T_Msg0716_EventPartPostCC11_GeneralPurpose2IfEnabled, 0x00f42514
	.set T_Msg0716_EventPartPostCC12_GeneralPurpose3IfEnabled, 0x00f42518
	.set T_Msg0716_EventPartPostCC13_GeneralPurpose4IfEnabled, 0x00f4251c
	.set T_Msg0716_EventPartPostCC02_BreathIfEnabled, 0x00f42520
	.set T_Msg0716_EventPartPostCC04_FootIfEnabled, 0x00f42524
	.set T_Disk_PhaseVector,                      0x00f42570
	.set T_BStore_Workspace_StoreParamImage,      0x00f42574
	.set T_F42578,                                0x00f42578
	.set T_F42580,                                0x00f42580
	.set T_MidiFilePlay_OnSongSelect,             0x00f42584
	.set T_Disk_PortA3_Release_Call_Call,         0x00f42590
	.set T_Playback_StopAllAndIgnoreMidiStart,    0x00f42594
	.set T_DiskApi_ReadFileToWindow_Entry,        0x00f425a8
	.set T_DiskApi_WriteFileFromWindow_Entry,     0x00f425ac
	.set T_DiskApi_DeleteFile_Call,               0x00f425b0
	.set T_DiskLoadScreen_MountAndScanDirectory,  0x00f425b4
	.set T_DiskSaveScreen_MountAndScanDirectory,  0x00f425b8
	.set T_Disk_TickCountdowns,                   0x00f425c4
	.set T_DiskLoadFile_Execute,                  0x00f425c8
	.set T_DiskSaveFile_Execute_Entry,            0x00f425cc
	.set T_MidiFileSave_Page5_LcdKeyRow3,         0x00f425d0
	.set T_NameEdit_MoveCursor_Call,              0x00f425d4
	.set T_NameEdit_StepChar_Call,                0x00f425d8
	.set T_Playback_AcceptMidiStartAgain,         0x00f425dc
	.set T_DiskApi_CloseFile_Call,                0x00f425e4
	.set T_DiskSave_CheckFreeSpace,               0x00f425e8
	.set T_DiskSaveFile_Page5_LcdKeyRow3,         0x00f425f4
	.set T_NameEdit_SyncCharIndex_Call,           0x00f425f8
	.set T_DiskSaveFile_SaveOrConfirmOverwrite_Call, 0x00f42608
	.set T_DiskSaveFile_CheckPasswordThenSave_Call, 0x00f4260c
	.set T_F42610,                                0x00f42610
	.set T_Disk_MountAndScanMidiFilesResetRings,  0x00f42614
	.set T_MidiFileStream_Open,                   0x00f42618
	.set T_MidiFileStream_GetByte,                0x00f4261c
	.set T_MidiFileStream_Close,                  0x00f42620
	.set T_Disk_LoadSqfToWorkspace_Entry,         0x00f42624
	.set T_Disk_LoadSeqToHeap_Entry,              0x00f42628
	.set T_Disk_SaveSqfFromStaging_Entry,         0x00f4262c
	.set T_MidiFileSave_Page3_LcdKeyRow3,         0x00f42634
	.set T_ParamImage_CopyToSongWorkspace,        0x00f42660
	.set T_F42664,                                0x00f42664
	.set T_Screen_Initial_Enter,                  0x00f42670
	.set T_Screen_SoundGroupNaming_Enter,         0x00f42680
	.set T_Screen_CombinationGroupNaming_Enter,   0x00f42690
	.set T_Screen_SoundCopy_Enter,                0x00f426a0
	.set T_Screen_CombinationCopy_Enter,          0x00f426b0
	.set T_SongClear_ClearCurrentBank,            0x00f42708
	.set T_SongGmFlag_OnEventPassB_Veneer,        0x00f42828
	.set T_BStore_LoadSongFromCurrentBank,        0x00f4282c
	.set T_BStore_AppendBytes_Veneer,             0x00f42894
	.set T_MeasureInsert_InitFields,              0x00f429a8
	.set T_MeasureInsert_OnLeave,                 0x00f429ac
	.set T_MeasureInsert_SelectField1,            0x00f429b0
	.set T_MeasureInsert_SelectField2,            0x00f429b4
	.set T_MeasureInsert_SelectField3,            0x00f429b8
	.set T_MeasureInsert_SelectField4,            0x00f429bc
	.set T_MeasureInsert_SelectField5,            0x00f429c0
	.set T_MeasureInsert_SelectField6,            0x00f429c4
	.set T_MeasureInsert_StepFieldUp,             0x00f429c8
	.set T_MeasureInsert_StepFieldDown,           0x00f429cc
	.set T_MeasureInsert_ReturnToStageZero,       0x00f429d0
	.set T_MeasureInsert_LcdKeyRow1,              0x00f429d4
	.set T_MeasureC0py_InitFields,                0x00f429d8
	.set T_MeasureC0py_OnLeave,                   0x00f429dc
	.set T_MeasureC0py_SelectField1,              0x00f429e0
	.set T_MeasureC0py_SelectField2,              0x00f429e4
	.set T_MeasureC0py_SelectField3,              0x00f429e8
	.set T_MeasureC0py_SelectField4,              0x00f429ec
	.set T_MeasureC0py_SelectField5,              0x00f429f0
	.set T_MeasureC0py_SelectField6,              0x00f429f4
	.set T_MeasureC0py_StepFieldUp,               0x00f429f8
	.set T_MeasureC0py_StepFieldDown,             0x00f429fc
	.set T_MeasureC0py_ReturnToStageZero,         0x00f42a00
	.set T_MeasureC0py_LcdKeyRow1,                0x00f42a04
	.set T_S0ngC0py_InitFields,                   0x00f42a08
	.set T_S0ngC0py_StageZero_SoftKeyCol2,        0x00f42a10
	.set T_S0ngC0py_StageZero_SoftKeyCol1,        0x00f42a14
	.set T_S0ngC0py_StageZero_SoftKeyCol4,        0x00f42a18
	.set T_S0ngC0py_StageZero_SoftKeyCol3,        0x00f42a1c
	.set T_S0ngC0py_StageZero_SoftKeyCol6,        0x00f42a20
	.set T_S0ngC0py_StageZero_SoftKeyCol5,        0x00f42a24
	.set T_S0ngC0py_StageZero_SoftKeyCol8,        0x00f42a28
	.set T_S0ngC0py_StageZero_SoftKeyCol7,        0x00f42a2c
	.set T_S0ngC0py_LcdKeyRow2,                   0x00f42a30
	.set T_S0ngC0py_ReturnToStageZero,            0x00f42a34
	.set T_AdvanceDelay_SelectField1,             0x00f42a68
	.set T_AdvanceDelay_SelectField2,             0x00f42a6c
	.set T_AdvanceDelay_SelectField3,             0x00f42a70
	.set T_AdvanceDelay_SelectField4,             0x00f42a74
	.set T_AdvanceDelay_StepFieldUp,              0x00f42a78
	.set T_AdvanceDelay_StepFieldDown,            0x00f42a7c
	.set T_AdvanceDelay_LcdKeyRow3,               0x00f42a80
	.set T_AdvanceDelay_ReturnToStageZero,        0x00f42a84
	.set T_N0teChange_InitFields,                 0x00f42a88
	.set T_N0teChange_OnLeave,                    0x00f42a8c
	.set T_N0teChange_SelectField1,               0x00f42a90
	.set T_N0teChange_SelectField2,               0x00f42a94
	.set T_N0teChange_SelectField3,               0x00f42a98
	.set T_N0teChange_SelectField4,               0x00f42a9c
	.set T_N0teChange_SelectField5,               0x00f42aa0
	.set T_N0teChange_StepSelectedFieldUp,        0x00f42aa4
	.set T_N0teChange_StepFieldDown,              0x00f42aa8
	.set T_N0teChange_LcdKeyRow4,                 0x00f42aac
	.set T_N0teChange_ReturnToStageZero,          0x00f42ab0
	.set T_F42B70,                                0x00f42b70
	.set T_Medley_SelectField1,                   0x00f42b7c
	.set T_Medley_SelectField2,                   0x00f42b80
	.set T_SequencerMedley_StepFieldUp,           0x00f42b84
	.set T_SequencerMedley_StepFieldDown,         0x00f42b88
	.set T_TrackAssign_IsLocalControlDashed,      0x00f42b9c
	.set T_F42BB4,                                0x00f42bb4
	.set T_F42BB8,                                0x00f42bb8
	.set T_StepRecordPartSelect_OpenStepRecord,   0x00f42bbc
	.set T_StepRecordPartSelect_ResetOnEntry,     0x00f42bc4
	.set T_StepRecordPartSelect_OnLeave,          0x00f42bc8
	.set T_SequencerMedley_InitOnEntry,           0x00f42bcc
	.set T_SequencerMedley_OnLeave,               0x00f42bd0
	.set T_SequencerMedley_LcdKeyRow2,            0x00f42bd4
	.set T_SequencerMedley_StopPlayback,          0x00f42bd8
	.set T_SequencerMedley_SetSourceInternal,     0x00f42c18
	.set T_SequencerMedley_SoftKeyCol3,           0x00f42c1c
	.set T_SequencerMedley_SoftKeyCol7,           0x00f42c24
	.set T_SequencerMedley_SoftKeyCol8,           0x00f42c28
	.set T_SequencerMedley_LcdKeyRow4,            0x00f42c2c
	.set T_TableDefault_Ret,                      0x00f42c70
	.set T_PanelCode_ToSlotAndFlags,              0x00f42c74
	.set T_EditValue_StepBitField,                0x00f42c78
	.set T_Queue2C00_Append4,                     0x00f42c80
	.set T_Queue2E00_Append4,                     0x00f42c84
	.set T_List2030_Append4,                      0x00f42c88
	.set T_IndexedTable_GetPtr,                   0x00f42c8c
	.set T_IndexedTable_GetByte,                  0x00f42c90
	.set T_IndexedParam_AdjustField,              0x00f42c94
	.set T_IndexedParam_SetBit,                   0x00f42c98
	.set T_PartIndex_PostChangeEvent,             0x00f42c9c
	.set T_PartSound_CopyNameToDrawScratch,       0x00f42ca0
	.set T_IndexedParam_SetFieldFromAsciiEntry,   0x00f42ca8
	.set T_INT5_Dev7B_Receive_Alias,              0x00f42d28
	.set T_INTTC0_uDMA0Done_Alias,                0x00f42d30
	.set T_Disk_CommandDispatch_SaveRegs_Entry,   0x00f42d34
	.set T_Fdc_Request_SaveRegs_Entry,            0x00f42d38
	.set T_Kernel_InitRam,                        0x00f42d60
	.set T_INTT3_KernelTick,                      0x00f42d64
	.set T_IRQ_Epilogue,                          0x00f42d68
	.set T_Kernel_StartTask,                      0x00f42d6c
	.set T_Kernel_SemaSignal,                     0x00f42d88
	.set T_Kernel_SemaWait,                       0x00f42d90
	.set T_Kernel_KillTask,                       0x00f42da8
	.set T_Kernel_StartTask_StackArg,             0x00f42dac
	.set T_Kernel_ExitTask_2,                     0x00f42db0
	.set T_Kernel_SemaSignal_StackArg,            0x00f42dc0
	.set T_Kernel_SemaWait_StackArg,              0x00f42dc4
	.set T_MsgQueue_Send_StackArg,                0x00f42dc8
	.set T_MsgQueue_ReceiveBlocking,              0x00f42dcc
	.set T_Kernel_SemaTryWait,                    0x00f42dd8
	.set T_MsgQueue_Receive_NoBlock,              0x00f42ddc
	.set T_DSP_ChannelRegs_Write8,                0x00f42de0
	.set T_DisplayList_Run_Stack,                 0x00f42e00
	.set T_DisplayListB_Run_Stack,                0x00f42e04
	.set T_DisplayList_RunOne_Stack,              0x00f42e08
	.set T_DisplayListB_RunOne_Stack,             0x00f42e0c
	.set T_LCD_BlankThenSetPanel3Layer_Copy,      0x00f42e10
	.set T_LCD_ShowAllLayers_StackFrame_Copy,     0x00f42e14
	.set T_UiPaint_PageLabelBackdrop,             0x00f42e18
	.set T_Blink_Command,                         0x00f42e20
	.set T_Blink_Stop,                            0x00f42e24
	.set T_Blink_SetEnable,                       0x00f42e28
	.set T_Blink_Tick,                            0x00f42e2c
	.set T_Blink_GetState,                        0x00f42e30
	.set T_ScreenEnter_DrawbarScreen,             0x00f42e44
	.set T_Drawbar_MarkReloadOnSoundEvent,        0x00f42e54
	.set T_Drawbar_ReloadIfMarked,                0x00f42e60
	.set T_Drawbar_OnCpu2Reply,                   0x00f42e64
	.set T_Drawbar_EnterScreenIfMarked,           0x00f42e68
	.set T_Drawbar_WaitReloadMark,                0x00f42e6c
	.set T_CallbackQueue_Post,                    0x00f42e84
	.set T_Task2_CallbackDispatcher,              0x00f42e88
	.set T_Medley_ToggleMidiFileStream,           0x00f42e90
	.set T_StepRecord_OnEnter,                    0x00f42ec0
	.set T_StepRecord_OnLeave,                    0x00f42ec4
	.set T_StepRecord_MainLoopService,            0x00f42ed0
	.set T_StepRecord_Tick,                       0x00f42edc
	.set T_F42F00,                                0x00f42f00
	.set T_F42F04,                                0x00f42f04
	.set T_ScreenEnterBody_DspEffect,             0x00f42f4c
	.set T_ScreenButtonBody_DspEffect,            0x00f42f50
	.set T_DspEffect_OnParamEvent,                0x00f42f54
	.set T_DspEffect_ApplyAlgorithmDefaults,      0x00f42f58
	.set T_DspEffect_SanitizeBlock,               0x00f42f5c
	.set T_ScreenEnterBody_MainOutEqualizer,      0x00f42f68
	.set T_ScreenButtonBody_MainOutEqualizer,     0x00f42f6c
	.set T_NameEntry_Begin,                       0x00f42f80
	.set T_SoundEditNaming_SoftKeyCol1,           0x00f42f84
	.set T_SoundEditNaming_SoftKeyCol2,           0x00f42f88
	.set T_SoundEditNaming_SoftKeyCol3,           0x00f42f8c
	.set T_SoundEditNaming_SoftKeyCol4,           0x00f42f90
	.set T_SoundEditNaming_SoftKeyCol5,           0x00f42f94
	.set T_SoundEditNaming_SoftKeyCol6,           0x00f42f98
	.set T_SoundEditNaming_SoftKeyCol7,           0x00f42f9c
	.set T_SoundEditNaming_SoftKeyCol8,           0x00f42fa0
	.set T_SoundEditNaming_LcdKeyRow1,            0x00f42fa4
	.set T_SoundEditNaming_LcdKeyRow2,            0x00f42fa8
	.set T_DrumSoundNames_FetchNext,              0x00f42fac
	.set T_Medley_Tick,                           0x00f43020
	.set T_Medley_ScheduleNextMidiFile,           0x00f43028
	.set T_ModeEnter_Edit,                        0x00f43040
	.set T_ModeEnter_StepRecord,                  0x00f43048
	.set T_ScreenEnter_Edit,                      0x00f43050
	.set T_ScreenEnter_SongClear,                 0x00f43060
	.set T_ScreenEnter_TrackClear,                0x00f43070
	.set T_ScreenEnter_Vel0cityChange,            0x00f43080
	.set T_ScreenEnter_Quantize,                  0x00f43090
	.set T_ScreenEnter_TrackMerge,                0x00f430a0
	.set T_ScreenEnter_MeasureErase,              0x00f430b0
	.set T_ScreenEnter_MeasureC0py,               0x00f430c0
	.set T_ScreenEnter_MeasureInsert,             0x00f430d0
	.set T_ScreenEnter_MeasureDelete,             0x00f430e0
	.set T_ScreenEnter_S0ngC0py,                  0x00f430f0
	.set T_ScreenEnter_Transp0se,                 0x00f43100
	.set T_ScreenEnter_AdvanceDelay,              0x00f43110
	.set T_ScreenEnter_N0teChange,                0x00f43120
	.set T_ScreenEnter_PanelWrite,                0x00f43130
	.set T_ScreenEnter_TrackAssign,               0x00f43140
	.set T_ScreenEnter_SequencerMedley,           0x00f43150
	.set T_ScreenEnter_StepRecord,                0x00f43160
	.set T_ScreenEnter_StepRecordPartSelect,      0x00f43170
	.set T_ScreenEnter_AfterT0uchSetting,         0x00f43180
	.set T_ScreenEnter_TrackAssignPresets,        0x00f43190
	.set T_ScreenEnter_S0ngSelectName,            0x00f431a0
	.set T_ScreenCode15_Handler,                  0x00f431d0
	.set T_AsciiDigits3_ToValue,                  0x00f432f0
	.set T_AsciiField_ToSignedValue,              0x00f432f4
	.set T_AsciiField_Clear,                      0x00f432f8
	.set T_UiText_CopyLabel13_To_22F0,            0x00f43330
	.set T_MidiIn_ReqListRebuild_Msg13_16,        0x00f43350
	.set T_MidiIn_ReqRebuild_Msg03_0A,            0x00f43354
	.set T_MidiIn_PumpPortB,                      0x00f43358
	.set T_MidiFileL0ad_LcdKeyRow1,               0x00f43380
	.set T_MidiFileSave_WriteSeqBankSmf,          0x00f43384
	.set T_MidiFileStream_ReaderTask,             0x00f433c0
	.set T_ScreenEnter_SoundEditDigitalEffect,    0x00f433d0
	.set T_F433E0,                                0x00f433e0
	.set T_SoundName_CopyToBuffer,                0x00f43400
	.set T_SoundGroupName_CopyToBuffer,           0x00f43404
	.set T_SoundGroup_MaxMemberIndex_ByStack,     0x00f43408
	.set T_CombiName_CopyToBuffer,                0x00f4340c
	.set T_CombiGroupName_CopyToBuffer,           0x00f43410
	.set T_CombiGroup_MaxMemberIndex_ByStack,     0x00f43414
	.set T_DrumsMap_RefreshSoundColumn,           0x00f43418
	.set T_SoundCopy_HandleReceivedSound,         0x00f4341c
	.set T_TuneScale_KeyScalingCodeToIndex,       0x00f43420
	.set T_DiskFile_CheckSignature,               0x00f43430
	.set T_PartSettings_ResetToDefault,           0x00f43440
	.set T_SystemSettings_ResetToDefault,         0x00f43444
	.set T_ParamRecord_SetPartsField18Bit0,       0x00f4344c
	.set T_Mode_InitSavedPartBlocks,              0x00f43450
	.set T_Queue2E00_PostParam98Fields,           0x00f43454
	.set T_Disk_FormatSelectedMedia,              0x00f43460
	.set T_DspParam_WriteByNumber,                0x00f434a0
	.set T_DspParam_ReadByNumber,                 0x00f434a4
	.set T_Screen_SoundMute_Enter,                0x00f434c0
	.set T_SystemTest_PlayNotesOnPanelKey,        0x00f434d4
	.set T_ScreenEnter_CreatorSelectController,   0x00f434e0
	.set T_CreatorSelectController_OpenOnEvent,   0x00f434f0
	.set T_CreatorSelectController_OnPartEvent,   0x00f434f4
	.set LCD_BlitValueBar_StackArgs,              0x00f4f000
	.set DrawValueGlyph_Veneer,                   0x00f4f017
	.set PartSound_StepBankGroupMember,           0x00f4f02e
	.set PtrTable_F4F800,                         0x00f4f800
	.set PtrTable_F4F888,                         0x00f4f888
	.set PtrTable_F4F916,                         0x00f4f916
	.set SysExSession_ContinuationTable,          0x00f4f99e
	.set SysExSession_CategoryEndTable,           0x00f4f9e6
	.set SysExSession_AbortTable,                 0x00f4fa2e
	.set MidiSysEx_Tail3Init,                     0x00f4fa76
	.set SysExInitial_ItemTable,                  0x00f4fb1c
	.set SysExTx_StagedParamHandlers,             0x00f4fb38
	.set ParamFieldInit_x32_F4FE38,               0x00f4fe38
	.set ParamFieldInit_F4FE50,                   0x00f4fe50
	.set WordTable_F4FE6A,                        0x00f4fe6a
	.set WordTable_F4FE76,                        0x00f4fe76
	.set SysExRxClass_ByResult,                   0x00f4fe82
	.set ZeroBlock16_F4FEA4,                      0x00f4fea4
	.set SysExMessageStrings_F4FEB4,              0x00f4feb4
	.set SysExDecodeTree_Root,                    0x00f5115b
	.set SysExStatus_MessageIdMap,                0x00f511c7
	.set SysExParamDesc_Placeholder,              0x00f511f9
	.set Pointer_F51E20,                          0x00f51e20
	.set Pointer_F51E24,                          0x00f51e24
	.set Pointer_F51E28,                          0x00f51e28
	.set PtrTable_F51E70,                         0x00f51e70
	.set Pointer_F51E84,                          0x00f51e84
	.set RecordIndex_Count,                       0x00f51e88
	.set PtrTable_F51E8E,                         0x00f51e8e
	.set PtrTable_F51EEA,                         0x00f51eea
	.set PtrTable_F51F46,                         0x00f51f46
	.set Pointer_F51F5A,                          0x00f51f5a
	.set PtrTable_F51F5E,                         0x00f51f5e
	.set PtrTable_F51FC2,                         0x00f51fc2
	.set PtrTable_F52026,                         0x00f52026
	.set PtrTable_F52072,                         0x00f52072
	.set PtrTable_F520BE,                         0x00f520be
	.set PtrTable_F5215E,                         0x00f5215e
	.set PtrTable_F521FE,                         0x00f521fe
	.set PtrTable_F52206,                         0x00f52206
	.set LinkSelector1_Table,                     0x00f57d4f
	.set DL_Disk,                                 0x00f58000
	.set DL_DiskDiskL0adDiskSaveMidiFile,         0x00f58014
	.set DL_MidiFileLoadMidiFileSave,             0x00f580b0
	.set DL_LoadSingleSoundLoadSingleCombi,       0x00f58127
	.set DL_F58162,                               0x00f58162
	.set DL_LoadL0adFileLoadL0ad0pti0n,           0x00f581b0
	.set DL_SaveSaveFileSaveSave0pti0n,           0x00f581f8
	.set DL_SaveSaveFileDelSave0pti0n,            0x00f58240
	.set DL_FloppyDisk,                           0x00f58288
	.set DL_F583AB,                               0x00f583ab
	.set DL_FromS0ngNumber,                       0x00f583ba
	.set DL_ToS0ngNumber,                         0x00f583d0
	.set DL_F583E5,                               0x00f583e5
	.set DL_F583F0,                               0x00f583f0
	.set DL_F5840A,                               0x00f5840a
	.set DLTab_F5841F,                            0x00f5841f
	.set DL_F5843F,                               0x00f5843f
	.set DL_F5844A,                               0x00f5844a
	.set DLTab_F58455,                            0x00f58455
	.set DLText_F58625,                           0x00f58625
	.set DLText_F5864D_Blank9,                    0x00f5864d
	.set DL_DiskSaveFileNaming,                   0x00f58656
	.set DL_SaveFileDeletePositionAbc789,         0x00f58671
	.set DL_F58786,                               0x00f58786
	.set DL_F5879C,                               0x00f5879c
	.set CharPalette_F587B2,                      0x00f587b2
	.set DL_MidiFileSaveFileNaming,               0x00f58a21
	.set ScreenEnter_MidiFileSave_Page0_DL,       0x00f58a41
	.set DL_MidiFileSave,                         0x00f58aa5
	.set DL_MidiFileSaveFileDelete,               0x00f58ab7
	.set DL_LoadSingleSoundDiskGr0upSingleFileBankS0undGr0up, 0x00f58ad7
	.set ScreenEnter_L0adSingleS0und_Page1_DL,    0x00f58c49
	.set DL_LoadSingleSoundDiskGr0upSingleFileBankS0und, 0x00f58c53
	.set ScreenEnter_L0adSingleS0und_Page0_DL,    0x00f58df0
	.set DL_LoadSingleCombinationDiskGr0upSingleUser1FileBankUser1S0und, 0x00f58e04
	.set DL_LoadSingleCombinationDiskGr0upSingleUser1FileBankUser1C0mbi, 0x00f58f55
	.set ScreenEnter_L0adSingleC0mbination_Page0_DL, 0x00f590c9
	.set DL_F590DD,                               0x00f590dd
	.set DL_F590E7,                               0x00f590e7
	.set DL_F590F1,                               0x00f590f1
	.set DL_F5910F,                               0x00f5910f
	.set DLText_F59128,                           0x00f59128
	.set DL_F59150,                               0x00f59150
	.set DL_F5915B,                               0x00f5915b
	.set DL_F591A6,                               0x00f591a6
	.set DL_F591B1,                               0x00f591b1
	.set DL_2dd,                                  0x00f591fc
	.set DL_2hd,                                  0x00f59205
	.set DL_F5920E,                               0x00f5920e
	.set ScreenEnter_MidiFileSave_Page1_DL1,      0x00f59218
	.set DL_MidiFileSaveFileSelecti0n,            0x00f59222
	.set ScreenEnter_MidiFileSave_Page1_DL2,      0x00f59301
	.set DL_MidiFileL0adL0ad,                     0x00f5930b
	.set DL_ToS0ngNumberL0adAsGm,                 0x00f5933b
	.set Paint_MidiFileL0ad_DL,                   0x00f593e9
	.set DL_F593F3,                               0x00f593f3
	.set DL_F593FE,                               0x00f593fe
	.set DL_F59409,                               0x00f59409
	.set DL_MidiFileDirectPlayPlayAsGm,           0x00f5944c
	.set DL_Play,                                 0x00f594f9
	.set DL_Stop,                                 0x00f59503
	.set Paint_MidiFileDirectPlay_DL,             0x00f5950d
	.set DL_F59517,                               0x00f59517
	.set DL_F59522,                               0x00f59522
	.set DLText_F59535,                           0x00f59535
	.set DL_F5953B,                               0x00f5953b
	.set DL_F59546,                               0x00f59546
	.set DL_F59567,                               0x00f59567
	.set DL_F59572,                               0x00f59572
	.set DLText_F595CD,                           0x00f595cd
	.set DLText_F59857_MID,                       0x00f59857
	.set DL_FloppyDiskFormatSelectTheF0rmatTypeForYo, 0x00f5985b
	.set DL_ComposerLoad,                         0x00f59904
	.set ScreenEnter_MidiFileSave_Page1_DL3,      0x00f59915
	.set DL_F5993E,                               0x00f5993e
	.set DL_F59948,                               0x00f59948
	.set DL_F59952,                               0x00f59952
	.set DL_F5995C,                               0x00f5995c
	.set DL_DiskSavePasswordSave,                 0x00f59966
	.set DL_F5999A,                               0x00f5999a
	.set DL_PasswordIsAlreadySetPleaseSetThe,     0x00f599b5
	.set CharTable_F599F5,                        0x00f599f5
	.set DL_FloppyDiskFormat,                     0x00f59a35
	.set DL_AttentionUsingDiskFormatWillErase,    0x00f59a4b
	.set DL_DiskSaveFileDelete,                   0x00f59ab5
	.set DL_AttentionUsingFileDeleteWillErase,    0x00f59ad0
	.set DL_DiskSave,                             0x00f59b79
	.set DL_AttentionAFileAlreadyExistsAtThe,     0x00f59b86
	.set DLText_F59C2C,                           0x00f59c2c
	.set DL_F59C4B,                               0x00f59c4b
	.set SoftKeyCol1_TrackClear_StageZero,        0x00f7ecff
	.set SoftKeyCol2_TrackClear_StageZero,        0x00f7ed18
	.set SoftKeyCol3_TrackClear_StageZero,        0x00f7ed31
	.set SoftKeyCol4_TrackClear_StageZero,        0x00f7ed4a
	.set SoftKeyCol5_TrackClear_StageZero,        0x00f7ed63
	.set SoftKeyCol6_TrackClear_StageZero,        0x00f7ed7c
	.set SoftKeyCol7_TrackClear_StageZero,        0x00f7ed95
	.set SoftKeyCol8_TrackClear_StageZero,        0x00f7edae
; <<< END prom_b ADDRESS EQUATES
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
