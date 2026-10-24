# The CPU 1 module split (2026-10-24, audit work package WP12)

`prom_a/wsa1_prom_a.s` (201,728 lines) and `prom_b/wsa1_prom_b.s` (208,056) each held a whole
512 KiB image, so every lane that touched either image edited the same file.  Since commit
"wsa1: split prom_a and prom_b into one source per firmware module" each is a ROOT -- its header,
the definitions, the generated cross-image equate block -- followed by one `.include` per module:
37 files under `prom_a/modules/`, 42 under `prom_b/modules/`.  The tool is
`scripts/tools/split_cpu1_images.py`; its docstring is the specification.

## Where a module ends

CPU 1's firmware is linked as separately built modules, each padded with `ret` (0x0E) bytes up to an
aligned address before the next one starts.  A module boundary is an address A where the last line
emitting bytes below A is a 0x0E `.fill` ending exactly at A, and A is a multiple of 0x100.  The
pads were already asserted pure 0x0E by the tree's own checks (`notes/prom_a_byte_checks.py`, the
prom_b generators).  Written-out exceptions:

* prom_b `0xF40000-0xF44017` is one object, the routine directory; its empty slots are 0x0E fills
  too and are not module ends.  It is one file, `f40000_f44017_routine_directory.s`.
* prom_a `0xFE0000` starts the application block (its banner, and
  `notes/FINDINGS-prom_a-fcf000-module.md`: "0xFE0000 -- a known boundary"); the bytes
  0xFDE70F-0xFDFFFF below it, after the 0xFCF000 module's last routine, stay in that module's file.
* A part that would hold nothing but 0x0E padding (a whole empty 4 KiB slot) stays with the module
  it pads: `0xFC3000-0xFC3FFF` and `0xFC7000-0xFC7FFF`.
* No 64 KiB-bank cut.  The work package offered bank starts as a fallback where module boundaries
  are unknown; here they are known, and every bank start that is not already a boundary lies inside
  a padded module (0xFA0000, 0xFD0000; 0xF10000, 0xF20000, ...).  The two largest modules therefore
  stay whole: prom_a `0xFCF000-0xFDFFFF` (33,314 lines) and prom_b `0xF0E800-0xF1B3FF` (24,769).

Each module file is named `<start>_<end>_<subject>.s`.  The subject is read off the module's own
banner, or, where the banner is only an address range, off the labels it opens with; the evidence
for each is a comment beside its entry in `MODULE_NAMES` in the tool, and `--plan` prints the banner
and first labels so every name can be re-checked.  A subject names what the module CONTAINS, not a
purpose nobody has shown (`old_copies_and_display_lists`, not a guess at what those copies were).

## Why the cut cannot change a byte, and the proof that it changed no text

Neither image has an `.org` or a second section: emission order is address order.  Every part is a
contiguous run of the old lines, written verbatim, and the root `.include`s it where the run stood;
llvm-mc's `.include` is textual.  Checked three ways:

| check                                              | result                                            |
|----------------------------------------------------|---------------------------------------------------|
| `split_cpu1_images.py --verify <pre-split commit>` | joined listing EQUALS it: 201,728 / 208,056 lines |
| a second `--emit` on the split tree                | 0 files written or changed                        |
| `make gate-wsa1`                                   | PASS, every rebuilt ROM byte-identical            |

Every line address the tool uses comes from assembling a MARKED copy of the joined listing (a label
before every statement) with the real include paths and linker script; that copy is checked
byte-identical to the ROM before any address is believed.

## What the measurements say, before and after

The dispatch census is the strictest: `census_keys.py prom_a,prom_b,prom_c --json` on maps rebuilt
before and after, compared by `scripts/tools/compare_census_json.py`, is identical with `file:line`
strings ignored AND identical with every after-split location mapped back to the pre-split listing:
the same tables, entries, verdicts and stale markers, pointing at the same source lines.

| measurement (scripts/analysis/ unless noted)                 | before                          | after                               |
|--------------------------------------------------------------|---------------------------------|-------------------------------------|
| dispatch census framed/used/NOT/stale/staleT, prom_a         | 434 / 431 / 0 / 3 / 13          | 434 / 431 / 0 / 3 / 13              |
| the same, prom_b                                             | 291 / 284 / 0 / 7 / 223         | 291 / 284 / 0 / 7 / 223             |
| `doc_quality_census.py` prom_b routines / with header        | 4,133 / 2,854                   | 4,685 / 3,393 (see below)           |
| `doc_quality_census.py` prom_b routines without header       | 1,279                           | 1,292                               |
| `doc_quality_census.py` prom_a (d) fall-through runs         | 75 runs, 230 B                  | 74 runs, 226 B                      |
| `data_range_census.py` KNOWN-A / KNOWN-B / UNKNOWN           | unchanged                       | unchanged; 24 B move inside KNOWN-B |
| `wsa1/scripts/analysis/source_coverage.py`                   | 457,875 / 452,994 B substantive | identical                           |
| `make images-check` (bitmaps, fonts)                         | 0 changes, guard 3,118          | identical                           |
| the two cross-image symbolisers, dry run and --check-equates | 85 / 0 stale equates            | identical                           |

`doc_quality_census.py` moves because of its own rule, not the content: "a label branched to from
another FILE is a routine (a tail call into another module)".  The routine directory's 552 `jp`
targets in prom_b are now branched to from another file, so they count as routines (xfile_jump
0 -> 552, blocks_jump 641 -> 89); 539 of them already carry a header.  prom_a's directory lives in
prom_b, another image, so nothing moves there.  The prom_a fall-through run that left (d) is at a
file start now.  The `data_range_census.py` shift is a header lookback that now stops at a file start
("descriptive name + header" 74,313 -> 74,289 B, "section header only" 7,642 -> 7,666 B).
The next `make doc-quality` snapshot will show the prom_b step; it comes from the file boundary, not
from any header written or lost, and should be read as such.

## Cross-image references: one direction only

The same lane labelled prom_b targets that prom_a spelled as numbers
(`scripts/tools/label_cross_image_targets.py`: 10 labels, 21 prom_a operands now symbolic).  The
reverse direction -- prom_b operands that point at prom_a addresses with no label -- was **not
attempted**.  A dry run of `../scripts/converters/symbolize_wsa1_rom_addresses.py` (no arguments)
still reports 391 of them: `no-label call->a 48`, `no-label jp->a 5`, `no-label long->a 338`.

## Every tool that read the old files

* `notes/probe_health.py --image prom_a --image prom_b` before the split (on the tree after the
  mechanical migration): prom_a SPLIT-FRAGILE 22 and VACUOUS 3, prom_b SPLIT-FRAGILE 17 and VACUOUS 3
  (`ph-before-split.*`).  Every split-fragile reader was moved onto `notes/asm_source.py`;
  `--regrade` brought 23 of 31 and 17 of 31 non-green rows to UNAFFECTED (`ph-regrade1.*`).
* After the split, a full sweep (`ph-after-split.*`): **SPLIT-FRAGILE 0 in both images.**  What is
  not green is the 2026-08-31 baseline (`notes/probe-health-2026-08-31-prom_a/`,
  `notes/probe-health-prom_b-wave8-2026-08-31/`): the wave-7 review probes and
  `verify_a1_independent_check.py` / `prom_a_understanding_round7.py --apply-strings` (VACUOUS+LOUD 3
  per image), the pre-existing NONDET rows, and the gate-perturbation probes, which WRITE a source on
  purpose and are refused in the instrument's frozen trees (WRITER).
* New in `notes/asm_source.py`: `own_lines()` hands a tool written against one list the image as one
  list (own parts expanded, shared sources kept as their `.include` lines), and `write_own_lines()`
  puts edits back into the file each line came from.  The two symbolisers, the bitmap/font tools,
  the perturbation probes and the WSA1-only scripts under `scripts/` use it.
* The lane tools outside `wsa1/` (`notes/proma-2026-09-25/`, `notes/promb-2026-09-25/`) are moved by
  `scripts/tools/migrate_lane_readers.py`; their one-shot writes now refuse.  ⚠ Still reading the
  root file by path, deliberately or for want of a safe rewrite: `notes/proma-2026-09-25/srcmap.py`
  (its `SRC` is the write target of ~25 already-applied generators), `comment_loss.py`,
  `notes/lanes/wsa1-naming-r*/` and `notes/syntax-convergence-probes/oracle_ab.py`, and the
  `wsa1/notes/wave7-verify-probes/` that hard-code the main checkout's path.  None of them is
  cited as a live check; port one through `asm_source` before re-running it.

## Reproduce

    cd wsa1
    python3 scripts/tools/split_cpu1_images.py --verify <pre-split commit>
    make gate-wsa1
    DISPATCH_CENSUS_DIR=<scratch> python3 ../scripts/analysis/dispatch_table_census/build_maps.py prom_a prom_b prom_c
    DISPATCH_CENSUS_DIR=<scratch> python3 ../scripts/analysis/dispatch_table_census/census_keys.py prom_a,prom_b,prom_c --json <after.json>
    python3 scripts/tools/compare_census_json.py <before.json> <after.json> --map
    python3 notes/probe_health.py --image prom_a --image prom_b --jobs 3

The census dumps (1.8 MB each) are regenerable and not committed; build the before dump in a
worktree at the pre-split commit.

## The modules

prom_a/modules/ -- 37 modules, root prologue 2173 lines

| file                                               | range             | lines  | why it starts there                       |
|----------------------------------------------------|-------------------|--------|-------------------------------------------|
| `f80000_f81fff_sequencer_job_button_tables.s`      | 0xF80000-0xF81FFF | 3,958  | image start                               |
| `f82000_f83fff_main_task_reset_and_interrupts.s`   | 0xF82000-0xF83FFF | 2,887  | 0x0E pad ends at an 0x100-aligned address |
| `f84000_f855ff_ring_buffers.s`                     | 0xF84000-0xF855FF | 2,077  | 0x0E pad ends at an 0x100-aligned address |
| `f85600_f85fff_kernel_and_dsp_refresh.s`           | 0xF85600-0xF85FFF | 287    | 0x0E pad ends at an 0x100-aligned address |
| `f86000_f897ff_panel_task_and_ui_event_lists.s`    | 0xF86000-0xF897FF | 6,687  | 0x0E pad ends at an 0x100-aligned address |
| `f89800_f89fff_control_normaliser.s`               | 0xF89800-0xF89FFF | 745    | 0x0E pad ends at an 0x100-aligned address |
| `f8a000_f8bbff_panel_wire_to_group.s`              | 0xF8A000-0xF8BBFF | 3,626  | 0x0E pad ends at an 0x100-aligned address |
| `f8bc00_f8bfff_ascii_numeric_fields.s`             | 0xF8BC00-0xF8BFFF | 499    | 0x0E pad ends at an 0x100-aligned address |
| `f8c000_f8d9ff_panel_leds.s`                       | 0xF8C000-0xF8D9FF | 1,051  | 0x0E pad ends at an 0x100-aligned address |
| `f8da00_f8dbff_callback_queue.s`                   | 0xF8DA00-0xF8DBFF | 176    | 0x0E pad ends at an 0x100-aligned address |
| `f8dc00_f8dfff_analog_scan.s`                      | 0xF8DC00-0xF8DFFF | 299    | 0x0E pad ends at an 0x100-aligned address |
| `f8e000_f8e7ff_link_port.s`                        | 0xF8E000-0xF8E7FF | 1,393  | 0x0E pad ends at an 0x100-aligned address |
| `f8e800_f94bff_lcd_swi7_and_combination_screens.s` | 0xF8E800-0xF94BFF | 13,736 | 0x0E pad ends at an 0x100-aligned address |
| `f94c00_f993ff_debug_monitor_and_param_scripts.s`  | 0xF94C00-0xF993FF | 7,182  | 0x0E pad ends at an 0x100-aligned address |
| `f99400_f997ff_screen_field_redraw_request.s`      | 0xF99400-0xF997FF | 49     | 0x0E pad ends at an 0x100-aligned address |
| `f99800_f9bfff_midi_settings_screens.s`            | 0xF99800-0xF9BFFF | 4,442  | 0x0E pad ends at an 0x100-aligned address |
| `f9c000_fa53ff_system_menu_screens.s`              | 0xF9C000-0xFA53FF | 17,230 | 0x0E pad ends at an 0x100-aligned address |
| `fa5400_fa5fff_midi_port.s`                        | 0xFA5400-0xFA5FFF | 1,961  | 0x0E pad ends at an 0x100-aligned address |
| `fa6000_fa9fff_midi_in_out.s`                      | 0xFA6000-0xFA9FFF | 7,583  | 0x0E pad ends at an 0x100-aligned address |
| `faa000_fad7ff_param_message_module.s`             | 0xFAA000-0xFAD7FF | 6,118  | 0x0E pad ends at an 0x100-aligned address |
| `fad800_fb17ff_param_apply_and_event_lists.s`      | 0xFAD800-0xFB17FF | 4,750  | 0x0E pad ends at an 0x100-aligned address |
| `fb1800_fb1fff_patch_lists.s`                      | 0xFB1800-0xFB1FFF | 526    | 0x0E pad ends at an 0x100-aligned address |
| `fb2000_fb8fff_sysex_module.s`                     | 0xFB2000-0xFB8FFF | 11,858 | 0x0E pad ends at an 0x100-aligned address |
| `fb9000_fbabff_smf_playback.s`                     | 0xFB9000-0xFBABFF | 2,113  | 0x0E pad ends at an 0x100-aligned address |
| `fbac00_fbb7ff_seq_file_load_save.s`               | 0xFBAC00-0xFBB7FF | 786    | 0x0E pad ends at an 0x100-aligned address |
| `fbb800_fbffff_part_params_and_combi_edit.s`       | 0xFBB800-0xFBFFFF | 8,526  | 0x0E pad ends at an 0x100-aligned address |
| `fc0000_fc3fff_msg0716_module.s`                   | 0xFC0000-0xFC3FFF | 5,055  | 0x0E pad ends at an 0x100-aligned address |
| `fc4000_fc53ff_digital_effect_screen_data.s`       | 0xFC4000-0xFC53FF | 1,670  | 0x0E pad ends at an 0x100-aligned address |
| `fc5400_fc7fff_note_routing.s`                     | 0xFC5400-0xFC7FFF | 2,030  | 0x0E pad ends at an 0x100-aligned address |
| `fc8000_fcefff_ram3800_module.s`                   | 0xFC8000-0xFCEFFF | 7,185  | 0x0E pad ends at an 0x100-aligned address |
| `fcf000_fdffff_tone_edit_module.s`                 | 0xFCF000-0xFDFFFF | 33,314 | 0x0E pad ends at an 0x100-aligned address |
| `fe0000_fe77ff_disk_and_floppy.s`                  | 0xFE0000-0xFE77FF | 15,308 | forced: application block                 |
| `fe7800_fe7fff_medley.s`                           | 0xFE7800-0xFE7FFF | 301    | 0x0E pad ends at an 0x100-aligned address |
| `fe8000_ff37ff_edit_screens.s`                     | 0xFE8000-0xFF37FF | 12,320 | 0x0E pad ends at an 0x100-aligned address |
| `ff3800_ff7fff_disk_menu_screens.s`                | 0xFF3800-0xFF7FFF | 9,759  | 0x0E pad ends at an 0x100-aligned address |
| `ff8000_fffeff_splash_bitmaps.s`                   | 0xFF8000-0xFFFEFF | 1,967  | 0x0E pad ends at an 0x100-aligned address |
| `ffff00_ffffff_vectors.s`                          | 0xFFFF00-0xFFFFFF | 101    | 0x0E pad ends at an 0x100-aligned address |

prom_b/modules/ -- 42 modules, root prologue 2026 lines

| file                                                    | range             | lines  | why it starts there                       |
|---------------------------------------------------------|-------------------|--------|-------------------------------------------|
| `f00000_f067ff_old_copies_and_display_lists.s`          | 0xF00000-0xF067FF | 14,385 | image start                               |
| `f06800_f097ff_scale_and_sound_group_tables.s`          | 0xF06800-0xF097FF | 1,196  | 0x0E pad ends at an 0x100-aligned address |
| `f09800_f0c7ff_sound_edit_screens.s`                    | 0xF09800-0xF0C7FF | 7,230  | 0x0E pad ends at an 0x100-aligned address |
| `f0c800_f0e7ff_midi_screen_display_lists.s`             | 0xF0C800-0xF0E7FF | 2,687  | 0x0E pad ends at an 0x100-aligned address |
| `f0e800_f1b3ff_blink_and_dsp_effect_editor.s`           | 0xF0E800-0xF1B3FF | 24,769 | 0x0E pad ends at an 0x100-aligned address |
| `f1b400_f27bff_fonts.s`                                 | 0xF1B400-0xF27BFF | 2,272  | 0x0E pad ends at an 0x100-aligned address |
| `f27c00_f2c7ff_mode_screen_display_lists.s`             | 0xF27C00-0xF2C7FF | 7,649  | 0x0E pad ends at an 0x100-aligned address |
| `f2c800_f2cfff_test_mode_display_lists.s`               | 0xF2C800-0xF2CFFF | 282    | 0x0E pad ends at an 0x100-aligned address |
| `f2d000_f2d7ff_screen_field_lists.s`                    | 0xF2D000-0xF2D7FF | 698    | 0x0E pad ends at an 0x100-aligned address |
| `f2d800_f327ff_messages_and_display_list_interpreter.s` | 0xF2D800-0xF327FF | 5,415  | 0x0E pad ends at an 0x100-aligned address |
| `f32800_f33fff_sound_edit_display_lists.s`              | 0xF32800-0xF33FFF | 3,224  | 0x0E pad ends at an 0x100-aligned address |
| `f34000_f367ff_sequencer_display_lists.s`               | 0xF34000-0xF367FF | 2,932  | 0x0E pad ends at an 0x100-aligned address |
| `f36800_f387ff_sysex_param_ranges.s`                    | 0xF36800-0xF387FF | 3,063  | 0x0E pad ends at an 0x100-aligned address |
| `f38800_f38fff_param_image_copy.s`                      | 0xF38800-0xF38FFF | 580    | 0x0E pad ends at an 0x100-aligned address |
| `f39000_f3f3ff_sequencer_job_display_lists.s`           | 0xF39000-0xF3F3FF | 10,264 | 0x0E pad ends at an 0x100-aligned address |
| `f3f400_f3ffff_factory_default_records.s`               | 0xF3F400-0xF3FFFF | 683    | 0x0E pad ends at an 0x100-aligned address |
| `f40000_f44017_routine_directory.s`                     | 0xF40000-0xF44017 | 3,929  | forced: routine directory                 |
| `f44018_f477ff_sequencer_core.s`                        | 0xF44018-0xF477FF | 5,218  | forced: routine directory                 |
| `f47800_f48bff_bstore_cursor_and_seq_cycle.s`           | 0xF47800-0xF48BFF | 2,291  | 0x0E pad ends at an 0x100-aligned address |
| `f48c00_f497ff_disk_file_signature.s`                   | 0xF48C00-0xF497FF | 1,051  | 0x0E pad ends at an 0x100-aligned address |
| `f49800_f4bfff_seq_record.s`                            | 0xF49800-0xF4BFFF | 4,492  | 0x0E pad ends at an 0x100-aligned address |
| `f4c000_f4c7ff_creator_select_controller_screen.s`      | 0xF4C000-0xF4C7FF | 1,113  | 0x0E pad ends at an 0x100-aligned address |
| `f4c800_f4cfff_bstore_compaction.s`                     | 0xF4C800-0xF4CFFF | 671    | 0x0E pad ends at an 0x100-aligned address |
| `f4d000_f4dfff_bstore_track_cursor.s`                   | 0xF4D000-0xF4DFFF | 1,392  | 0x0E pad ends at an 0x100-aligned address |
| `f4e000_f4ebff_track_key_handlers.s`                    | 0xF4E000-0xF4EBFF | 1,070  | 0x0E pad ends at an 0x100-aligned address |
| `f4ec00_f4efff_realtime_record.s`                       | 0xF4EC00-0xF4EFFF | 669    | 0x0E pad ends at an 0x100-aligned address |
| `f4f000_f4f7ff_part_sound_stepping.s`                   | 0xF4F000-0xF4F7FF | 429    | 0x0E pad ends at an 0x100-aligned address |
| `f4f800_f52fff_sysex_param_descriptors.s`               | 0xF4F800-0xF52FFF | 2,842  | 0x0E pad ends at an 0x100-aligned address |
| `f53000_f54fff_drawbar_screen.s`                        | 0xF53000-0xF54FFF | 4,111  | 0x0E pad ends at an 0x100-aligned address |
| `f55000_f557ff_param_edit_primitives.s`                 | 0xF55000-0xF557FF | 1,365  | 0x0E pad ends at an 0x100-aligned address |
| `f55800_f57bff_seq_play_screens.s`                      | 0xF55800-0xF57BFF | 5,969  | 0x0E pad ends at an 0x100-aligned address |
| `f57c00_f57fff_ring_put_block.s`                        | 0xF57C00-0xF57FFF | 486    | 0x0E pad ends at an 0x100-aligned address |
| `f58000_f5b7ff_disk_display_lists_and_sc1_link.s`       | 0xF58000-0xF5B7FF | 5,141  | 0x0E pad ends at an 0x100-aligned address |
| `f5b800_f62bff_song_edit_jobs_and_tone_edit_draws.s`    | 0xF5B800-0xF62BFF | 11,886 | 0x0E pad ends at an 0x100-aligned address |
| `f62c00_f64fff_block_store.s`                           | 0xF62C00-0xF64FFF | 3,652  | 0x0E pad ends at an 0x100-aligned address |
| `f65000_f65bff_song_edit_time_signatures.s`             | 0xF65000-0xF65BFF | 897    | 0x0E pad ends at an 0x100-aligned address |
| `f65c00_f673ff_track_assign_and_medley_screens.s`       | 0xF65C00-0xF673FF | 2,229  | 0x0E pad ends at an 0x100-aligned address |
| `f67400_f6efff_step_record.s`                           | 0xF67400-0xF6EFFF | 19,669 | 0x0E pad ends at an 0x100-aligned address |
| `f6f000_f7a3ff_smf_file_io_and_old_copy.s`              | 0xF6F000-0xF7A3FF | 20,129 | 0x0E pad ends at an 0x100-aligned address |
| `f7a400_f7a9ff_bstore_allocator.s`                      | 0xF7A400-0xF7A9FF | 699    | 0x0E pad ends at an 0x100-aligned address |
| `f7aa00_f7cfff_song_store_commands.s`                   | 0xF7AA00-0xF7CFFF | 6,278  | 0x0E pad ends at an 0x100-aligned address |
| `f7d000_f7ffff_panel_screen_methods.s`                  | 0xF7D000-0xF7FFFF | 11,023 | 0x0E pad ends at an 0x100-aligned address |
