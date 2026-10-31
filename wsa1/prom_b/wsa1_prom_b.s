	.text

; ==============================================================================
; Technics SX-WSA1R -- wsa1_prom_b.ic13
; Target CPU: Toshiba TMP95C061 (TLCS-900/H), "CPU 1" / IC1
; ==============================================================================
;
; IC13, the second program EPROM on CPU 1's bus, base 0xF00000.
;
; ⚠ The base is now CONFIRMED, not inferred.  Four independent proofs are
; written out in prom_b/prom_b.ld; the short form is that prom_a's interrupt
; vectors, its reset path, a PC-relative call across the boundary and the
; expansion-board probe's thunk all land on well-formed code in this image at
; exactly this base, and none of them survives a one-byte error in it.
;
; prom_a + prom_b are ONE contiguous 1 MiB image on CS2.  This half is not a
; boot image: its own file 0x7FF00 holds only 3 vector-shaped words, and its
; 0x7FFF0 -- where the other three images carry a lowercase `wsaX_NNN` build
; tag -- is code.
;
; STATUS: partially converted.  Converted so far, as real assembly:
;   0xF01800-0xF3E15B  129 spans of UI DISPLAY-LIST data (39,329 bytes) -- the
;                      machine's screen text and layout, in records.  Each record
;                      is rendered with the field layout of the interpreter that
;                      RUNS it; there are two, and they do not share a layout.
;                      13 of the gaps between the spans (999 bytes) hold the
;                      operand tables those records point at, and are decoded
;                      here too -- including the 64 eight-character resonator
;                      names at 0xF03241.
;   0xF0E800-0xF0EA9E  the FIELD-BLINK ENGINE -- 16 labels: 11 routines, 4
;                      dispatch arms reached only by `jp`, and a 12-entry
;                      command table.  Blinks at 1.27 Hz; the whole clock chain
;                      is re-derived by notes/prom_b_blink_rate.py.  The two
;                      display-list record TEMPLATES it patches on the stack are
;                      at 0xF78000, below.
;   0xF31800-0xF32708  BOTH display-list interpreters, their handler tables, the
;                      quantiser, 29 value glyphs and 3 fixed bitmaps
;   0xF40000-0xF44017  the THUNK TABLE -- the image's routine directory
;   0xF44018-0xF477FF  THE MODULE THAT OPENS RIGHT AFTER IT -- 128 routines and
;                      two data objects, 14,312 bytes.  64 thunk slots point in,
;                      resolving to 62 distinct targets; three adjacent runs with
;                      the highest summed reference count in the image (129).
;                      Dispatch_3629's 5 pointers (two of them dead) and the
;                      161-byte WorkspaceDefaults that seeds 0x00603400.
;   0xF55000-0xF5535A  nine parameter-edit primitives and table accessors, four
;                      of them named by top-ranked thunk slots
;   0xF5535B-0xF5553E  two more of the same family: IndexedParam_AdjustField and
;                      IndexedParam_SetBit, which resolve their target through
;                      IndexedTable_GetPtr and journal every change
;   0xF5B8B6-0xF5BAB7  two selector dispatchers and their 48-entry tables
;   0xF5BBE7-0xF62BFF  THE 96-STEP ROUNDING MAPS and the code that uses them --
;                      the whole span, 28,697 bytes, closed in one piece.  113
;                      routines, 11 data objects: seven 96-entry maps whose entry
;                      k is `g * round(k / g)` for g = 96, 48, 24, 12, 32, 16 and
;                      8 (with 96 written as 0x7F), their 7-pointer selector
;                      table, a 32-byte identity map, and the two 36-byte lists
;                      of the maps' own step boundaries.  Every one of the 17
;                      thunk slots that point into the span lands on an
;                      instruction boundary of the transcription.
;   0xF62C00-0xF64FFF  THE BLOCK STORE -- a heap of chained 256-byte blocks,
;                      the 3-byte directory at 0x00603500 that names their
;                      chains, and the 3 KiB workspace at 0x00603400 that is
;                      banked to 0x00610000 + n*0xC00.  49 thunk slots point
;                      into it, including the two most-referenced unconverted
;                      targets in the image.  Three data islands inside it are
;                      emitted as .byte; 1,008 bytes of 0x0E tail as .fill.
;   0xF78000-0xF78028  the two interpreter-B record templates and the eight-space
;                      blank the blink engine erases with
;   0xF7D000-0xF7E2D7  a stub/veneer block and 32 tables of 32 routine pointers
;
; ⚠ ADDED 2026-08-25 (round 5), AND THE LIST ABOVE WAS ALREADY THREE MODULES
; STALE when this was written -- 0xF47800-0xF4EFFF (round 3),
; 0xF5A800-0xF5B7FF (round 1) and 0xF65000-0xF6D001 (round 4) are all converted
; in this file and none of them appears above.  A status list nobody owns goes
; stale silently; scripts/analysis/source_coverage.py is the number that cannot.
;   0xF47800-0xF4EFFF  eight modules at the head of the 0x047800 span (round 3)
;   0xF5A800-0xF5B7FF  SERIAL CHANNEL 1 -- one 4 KiB module, three interrupt
;                      vectors (round 1)
;   0xF65000-0xF6D001  three modules at the head of the 0x065000 span (round 4)
;   0xF0EA9F-0xF13D33  THE BLOCK THE FRONTIER'S TOP RUN POINTS INTO -- 21,141
;                      bytes, of which 13,357 BYTES are code, in 21 code
;                      segments holding 5,067 INSTRUCTIONS (2.64 bytes each).
;                      ⚠ CORRECTED 2026-08-25 (round-2 audit F2): this line
;                      read "13,357 of them decoded instructions", which was
;                      the BYTE total of the code segments -- the figure in the
;                      `bytes` column of the LAYOUT table below -- worn as an
;                      instruction count, a 2.6x overstatement.  The
;                      instruction figure comes from
;                      `python3 notes/prom_b_instr_census.py --module f0ea9f`,
;                      which decodes every code segment and checks its starts
;                      against this file's own address comments (0 missing,
;                      0 extra).  135 routines, 23 pointer tables classified
;                      TRANSFER/DEREF/STRIDED/UNKNOWN by what the firmware DOES
;                      with an entry, 6 byte maps and no `.fill` at all.  Every
;                      routine header carries a PROVENANCE GRADE.  Read
;                      notes/FINDINGS-prom_b-f0ea9f-module.md sec.2 before
;                      reusing the 0xF65000 method anywhere: three of its rules
;                      produce false code here and two more had to be switched
;                      off.
;   0xF6D002-0xF77FFF  THE PERFORMANCE / ACCOMPANIMENT SCREEN LAYER (round 6)
;                      -- 45,054 bytes, 44,189 of them substantive and 865 an
;                      asserted `.fill` of 0x0E.  32,569 BYTES of code in 75
;                      segments, holding 11,299 INSTRUCTIONS (2.88 bytes each,
;                      `python3 notes/prom_b_instr_census.py --module f6d002`).
;                      316 routines, 104 data objects, every routine
;                      `sub_XXXXXX`.  ⚠ CHOSEN WITH A DIFFERENT TOOL: the thunk
;                      frontier ranks this span THIRTEENTH (2 slots, extent 4);
;                      notes/prom_b_span_frontier.py ranks it FIRST, on 76
;                      distinct already-proven call targets -- more than every
;                      other unconverted prom_b span put together.  Contains a
;                      STANDARD MIDI FILE reader whose parse is decoded and
;                      checked (notes/prom_b_smf_reader.py, 40 checks).
;   0xF17559-0xF1B3FF  THE COMBINATION / INTERNAL SOUND / MIDI SOUND PARAMETER
;                      SCREENS (round 3, wave 7) -- 16,039 bytes, 299 objects,
;                      no code at all.  297 labels, every header with an
;                      Evidence: line; 33 display lists named from their own
;                      captions.  Carries the EIGHT corrections
;                      notes/prom_b_f17559_reaudit.py established.
;                      notes/gen_prom_b_f17559_module.py, --selftest 53 checks.
;   0xF4F000-0xF54FFF  THE NINE-DRAWBAR ORGAN REGISTRATION SCREEN and the two
;                      table modules in front of it (round 3, wave 7) -- 24,576
;                      bytes, the largest `.incbin` that was left in this image.
;                      118 labels, 76 of them semantic; every header carries an
;                      Evidence: line.  notes/gen_prom_b_f4f000_module.py, whose
;                      --selftest is 104 checks.
;   0xF147AC-0xF14FAB  EffectNames -- 128 entries of 16 characters, 56 real
;                      effect names and 72 `----------` placeholders
;   0xF15024-0xF157A7  EffectParamNames -- the effect parameter labels
;   0xF14FAC-0xF15023  DL_EffectParamPage -- the DSP EFFECT screen's eight
;                      parameter-name rows, eight interpreter-B records of 15
;                      (wave 8).  With EffectParamDescriptors_F12F24 and
;                      DspEffect_LoadParamNames it closes `entry k of
;                      EffectNames is effect algorithm k` --
;                      notes/FINDINGS-prom_b-dsp-effect-parameters.md.
;   0xF3C947-0xF3C991  (wave 2, lane PROMBCONV) the STEP-RECORD "part select"
;                      list's last 5 records -- 4 interpreter-A + 1
;                      interpreter-B -- plus the 4-entry, 7-char string table
;                      (CHORD/MELODY/CONTROL/RHYTHM) the B record's own +7/
;                      +0x0B fields name.  Not a new format; wave 1's naive
;                      interp-A walk did not know interpreter B's op 0x02.
;                      notes/gen_prom_b_f3c947_module.py.
;   0xF3D5E5-0xF3DA6E  (wave 2) a 64-entry FIXED-STRIDE field/pointer array
;                      (15 bytes/entry) plus the three small string tables its
;                      own pointer fields name -- chromatic note letters, 32
;                      chord-quality suffixes, 4 tail suffixes.  Not a new
;                      format either: "op 0x2B" was never an opcode, just the
;                      byte after a fixed 15-byte stride, proved by the walk
;                      landing exactly on the note table regardless of one
;                      entry's stray length-shaped byte.
;                      notes/gen_prom_b_f3d5e5_module.py.
;   0xF3F400-0xF3FFFF  (wave 2) a THIRD record format, cracked: [op,len-of-
;                      payload] back to back, op 0xFF a 2-byte section
;                      terminator.  413 steps with zero drift land exactly on
;                      a verified 672-byte 0x00 pad running to the image's own
;                      end.  64 of the records (op 0x00-0x3F, once each) are a
;                      uniform 32-byte slot table; field semantics deferred.
;                      notes/gen_prom_b_f3f400_module.py.
; â ADDED 2026-09-02 (lane promB1):
;   0xF00C4D-0xF017FF  THE LARGEST `.incbin` THIS IMAGE HAD LEFT -- 2,995 bytes,
;                      28% of prom_b's whole verbatim debt.  Three objects and a
;                      two-byte remainder, not one thing: 21 `.long` closing the
;                      pointer array that starts at 0xF00C46; 2,124 bytes of CODE
;                      in 828 instructions, 0 of them left as `.byte`; a
;                      196-entry pointer array in 18-slot records; and 2 bytes
;                      REFUSED at the site, because the entry they begin cannot
;                      be completed without overrunning the display list at
;                      0xF01800.
;                      â THE CODE IS UNREACHED AND ITS CALL TARGETS ARE NOT
;                      prom_a ENTRY POINTS.  Read the ANOMALY section of
;                      notes/gen_prom_b_f00c4d_module.py before naming anything
;                      in it -- naming a routine after what its target does in
;                      the prom_a we have would invent a whole module of
;                      semantics.  --selftest is 20 checks; the reference census,
;                      with a positive control for each instrument, is
;                      notes/prom_b_f00c4d_xrefs.py.
; Everything else is still .incbin, so it builds byte-exact by construction and
; asserts nothing.  The gate (scripts/analysis/assert_byte_identical.py) must
; print PASS after every edit.
;
; PROVENANCE: this is not a chip read.  It is the publicly redistributed v2
; firmware set (../technics_roms/roms/wsa1/PROVENANCE.md).

; ------------------------------------------------------------------------------
; THE TLCS-900 BYTE-EMITTER MACROS -- the same file prom_a and the kernel use.
;
; ★ WHY THIS FILE NOW HAS THEM.  This image was generated with a decoder that
; wrote every operand llvm-mc's tlcs900 backend has no spelling for as a raw
; `.byte` row with the disassembler's text in the comment:
;
;     .byte 0xC1, 0xB8, 0x20, 0x3F, 0x11	; F0003C  cp (0x20b8),0x11   [llvm-mc cannot encode this]
;
; prom_a wrote the SAME BYTES as `m_cp_mi8 MB16, 0x20b8, 0x11`, because prom_a
; developed the macro set.  Sharing that set retires those rows here.  The
; instruction that replaces a row emits exactly the bytes the row held -- the
; byte gate is what says so -- and the `; ADDR <disassembler text>` comment,
; which is the DECODE AUTHORITY for every line in this file, is kept verbatim.
;
; ⚠ The `[llvm-mc cannot encode this]` marker is dropped on a converted row and
;   only there: it explained why the row was a `.byte`, and a row that is no
;   longer a `.byte` no longer needs the excuse.  Every row still spelled
;   `.byte` keeps its marker.  Counted by notes/promb_macro_rewrite.py --census.
; ------------------------------------------------------------------------------
	.include "include/tmp95c061_sfr.inc"
	.include "include/tlcs900_mem_ops.inc"
	.include "include/wsa1_ram.inc"
	.include "include/wsa1_gui.inc"	; the display-list record macros (dl_*, dlb_*) and LCDSVC_* service numbers

; >>> ADDRESS EQUATES RETIRED (scripts/tools/join_maincpu_link.py)
; This block held one `.set Name, <address>` per prom_a label this image references.
; Since 2026-10-31 prom_b and prom_a are linked as ONE program (maincpu/maincpu.ld): such a
; name is left undefined here and ld.lld resolves it to prom_a's own label, which
; prom_a/exports.syms makes global after assembly.  A renamed or missing name fails the link.
; This image's own exports, the names prom_a references, are in prom_b/exports.syms.
; <<< ADDRESS EQUATES RETIRED (scripts/tools/join_maincpu_link.py)
.equ KERNEL_MEM_OPS_PROVIDED, 1	; records "already provided"; this image does not include the kernel

; >>> BEGIN MODULE INCLUDES (generated by scripts/tools/split_cpu1_images.py; do not edit by hand)
; prom_b is assembled from these 42 module sources, in address order.  A module ends where
; its 0x0E (`ret`) padding reaches an aligned address -- the firmware's own link layout;
; the rule, its two written-out exceptions and the proof that the cut changes no byte are
; in scripts/tools/split_cpu1_images.py.  Edit the module files; this block is regenerated.

	.include "prom_b/modules/f00000_f067ff_old_copies_and_display_lists.s"
	.include "prom_b/modules/f06800_f097ff_scale_and_sound_group_tables.s"
	.include "prom_b/modules/f09800_f0c7ff_sound_edit_screens.s"
	.include "prom_b/modules/f0c800_f0e7ff_midi_screen_display_lists.s"
	.include "prom_b/modules/f0e800_f1b3ff_blink_and_dsp_effect_editor.s"
	.include "prom_b/modules/f1b400_f27bff_fonts.s"
	.include "prom_b/modules/f27c00_f2c7ff_mode_screen_display_lists.s"
	.include "prom_b/modules/f2c800_f2cfff_test_mode_display_lists.s"
	.include "prom_b/modules/f2d000_f2d7ff_screen_field_lists.s"
	.include "prom_b/modules/f2d800_f327ff_messages_and_display_list_interpreter.s"
	.include "prom_b/modules/f32800_f33fff_sound_edit_display_lists.s"
	.include "prom_b/modules/f34000_f367ff_sequencer_display_lists.s"
	.include "prom_b/modules/f36800_f387ff_sysex_param_ranges.s"
	.include "prom_b/modules/f38800_f38fff_param_image_copy.s"
	.include "prom_b/modules/f39000_f3f3ff_sequencer_job_display_lists.s"
	.include "prom_b/modules/f3f400_f3ffff_factory_default_records.s"
	.include "prom_b/modules/f40000_f44017_routine_directory.s"
	.include "prom_b/modules/f44018_f477ff_sequencer_core.s"
	.include "prom_b/modules/f47800_f48bff_bstore_cursor_and_seq_cycle.s"
	.include "prom_b/modules/f48c00_f497ff_disk_file_signature.s"
	.include "prom_b/modules/f49800_f4bfff_seq_record.s"
	.include "prom_b/modules/f4c000_f4c7ff_creator_select_controller_screen.s"
	.include "prom_b/modules/f4c800_f4cfff_bstore_compaction.s"
	.include "prom_b/modules/f4d000_f4dfff_bstore_track_cursor.s"
	.include "prom_b/modules/f4e000_f4ebff_track_key_handlers.s"
	.include "prom_b/modules/f4ec00_f4efff_realtime_record.s"
	.include "prom_b/modules/f4f000_f4f7ff_part_sound_stepping.s"
	.include "prom_b/modules/f4f800_f52fff_sysex_param_descriptors.s"
	.include "prom_b/modules/f53000_f54fff_drawbar_screen.s"
	.include "prom_b/modules/f55000_f557ff_param_edit_primitives.s"
	.include "prom_b/modules/f55800_f57bff_seq_play_screens.s"
	.include "prom_b/modules/f57c00_f57fff_ring_put_block.s"
	.include "prom_b/modules/f58000_f5b7ff_disk_display_lists_and_sc1_link.s"
	.include "prom_b/modules/f5b800_f62bff_song_edit_jobs_and_tone_edit_draws.s"
	.include "prom_b/modules/f62c00_f64fff_block_store.s"
	.include "prom_b/modules/f65000_f65bff_song_edit_time_signatures.s"
	.include "prom_b/modules/f65c00_f673ff_track_assign_and_medley_screens.s"
	.include "prom_b/modules/f67400_f6efff_step_record.s"
	.include "prom_b/modules/f6f000_f7a3ff_smf_file_io_and_old_copy.s"
	.include "prom_b/modules/f7a400_f7a9ff_bstore_allocator.s"
	.include "prom_b/modules/f7aa00_f7cfff_song_store_commands.s"
	.include "prom_b/modules/f7d000_f7ffff_panel_screen_methods.s"
; <<< END MODULE INCLUDES
