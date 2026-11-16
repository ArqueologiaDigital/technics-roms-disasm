# Shared projects root — override with: make PROJECTS_ROOT=/some/other/path <target>
PROJECTS_ROOT ?= $(HOME)/compartilhado

LLVM_BIN=$(PROJECTS_ROOT)/llvm-project/build/bin
LLVM_MC=$(LLVM_BIN)/llvm-mc
LLVM_LLD=$(LLVM_BIN)/ld.lld -e 0
LLVM_OBJCOPY=$(LLVM_BIN)/llvm-objcopy

# Demo song presets: decompressed sources -> recompressed payloads (see rules below).
DEMO_PRESET_DIR=table_data/includes/demo_presets
DEMO_PRESET_IDS=00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18
DEMO_PRESET_COMPRESSED=$(foreach i,$(DEMO_PRESET_IDS),$(DEMO_PRESET_DIR)/demo_preset_$(i)_compressed.bin)
DEMO_PRESET_MIDI_DIR=$(DEMO_PRESET_DIR)/midi
DEMO_PRESET_SIDECAR_DIR=$(DEMO_PRESET_DIR)/sidecar

# Help databases: decompressed sources -> recompressed SLIDE8K payloads (see rules below).
HELP_DB_DIR=table_data/includes/help_databases
HELP_DB_LANGS=english german french spanish indonesian
HELP_DB_COMPRESSED=$(foreach l,$(HELP_DB_LANGS),$(HELP_DB_DIR)/help_db_$(l)_compressed.bin)
# german_stale is a truncated factory remnant: kn5000_table_data.s emits its
# bytes as a raw slice (see table_data/help_databases.s), so its rebuilt
# payload is used by verify-help-databases only, never by the ROM build.
HELP_DB_STALE_COMPRESSED=$(HELP_DB_DIR)/help_db_german_stale_compressed.bin
# The two remaining "stale-remnant" .incbin slices (table_data/style_records.s
# StyleRecords_Residue + table_data/help_databases.s HelpDB_German_Stale body,
# 17,570 B total) are NOT independent debt: verify_stale_band.py proved they are
# the live English+German SLIDE8K streams duplicated 0x8000 lower in the ROM.
# gen_stale_help_duplicate.py derives them from HELP_DB_COMPRESSED instead of the
# static icons_to_strings.bin blob -- see that script's header for the evidence.
STALE_HELP_DUPLICATE=$(HELP_DB_DIR)/stale_style_records_residue.bin $(HELP_DB_DIR)/stale_help_db_german_head.bin
CLANG=$(LLVM_BIN)/clang

# The raw .bin files the KN5000 picture converters write beside their committed PNGs (git-ignored build
# products; the rule is with the other image rules below).  Defined here, before the first object that
# names it: a prerequisite list is expanded when make reads the rule.
KN5000_IMAGE_BINS := $(shell python3 scripts/build/kn5000_image_outputs.py)
KN5000_IMAGE_CONVERTERS := scripts/build/indexed_images.py scripts/build/mono_images.py scripts/build/se_bitmaps.py \
	scripts/build/kn5000_image_outputs.py v10/maincpu/images/Palette_8bit_RGBA.bin
# ... and the ones hdae5000_images.py and the table_data picture converters write into includes/generated/
HDAE_IMAGE_BINS      := $(shell python3 scripts/build/kn5000_image_outputs.py hdae)
TABLEDATA_IMAGE_BINS := $(shell python3 scripts/build/kn5000_image_outputs.py tabledata)

.PHONY: all llvm-all paramblocks screendata naka clean clean-asl clean-all
.PHONY: wsa1 wsa1-clean everything gate gate-wsa1 gate-all
.PHONY: verify-v8-reference verify-hdae5000-v201-reference verify-subprogram-update-images
.PHONY: kn7000 kn7000-clean gate-kn7000
.PHONY: kn2400 kn6000 kn6500 hdsx3 gate-kn2400 gate-kn6000 gate-kn6500 gate-hdsx3
.PHONY: floppy gate-floppy
.PHONY: mn10300-siblings-clean
.PHONY: llvm-convert llvm-convert-all asl-all gallery issues rom-status website dispatch-census semantic-score doc-quality
.SECONDARY:

.PHONY: decompress-demo-presets rebuild-demo-presets verify-demo-presets demo-midi demo-sidecars
.PHONY: style-events style-midi verify-style-midi
.PHONY: decompress-help-databases rebuild-help-databases verify-help-databases verify-help-db-text
.PHONY: verify-stale-help-duplicate verify-ftbmp
.PHONY: audit-icons-blob
.PHONY: dsp dsp-verify dsp-flowcharts

# Primary build: LLVM assembly (authoritative source)
all: llvm-all
	python scripts/build/compare_roms.py

# ---------------------------------------------------------------- SX-WSA1R
# The WSA1R disassembly was migrated into this tree on 2026-09-01 and lives in
# wsa1/.  It keeps its own Makefile because its four images have their own
# linker scripts and their own assembler invocation; these targets delegate, so
# that one tree builds both products.
#
#   make everything   both products
#   make gate-all     both byte-identity gates -- the only things that certify
#                     either tree.  Neither product is "built" until its gate is
#                     green, so prefer this over `make everything` alone.
wsa1:
	$(MAKE) -C wsa1 all

wsa1-clean:
	$(MAKE) -C wsa1 clean

# ---------------------------------------------------------------- SX-KN7000
# The KN7000 disassembly was migrated into this tree on 2026-10-19 and lives in
# kn7000/.  It has its own toolchain (kn7000/tools/kn7asm.py, an MN10300
# assembler in Python; no LLVM) and its own Makefile, which these targets call.
# Its reference images (kn7000/baserom/, git-ignored) come from the update disks
# and the private romset next to this tree; see kn7000/README.md.
#
#   make kn7000        build the KN7000 images: program + table 941/84, IC19, and the
#                      seven Style Convert Disk converters (src/cnv/*.s; semantic_score.py
#                      reads their sizes)
#   make gate-kn7000   their byte-identity gates, plus the SP7001 set (942/83), table
#                      build 80 (src/b80/table.s), the IC18 boot ROM (src/ic18/boot.s), all of
#                      IC18 with its rhythm data (src/ic18/ic18.s), program builds 935 and 893
#                      (src/b935/, src/b893/, ported from 941), the four wave ROMs (src/wave/),
#                      the nine factory custom-style banks (src/customdata/*.s), Felipe's own IC21
#                      (src/ic21own/ic21.s), and that the GUI menu map
#                      (kn7000/notes/gui-data-region/menu-map.md) is current
kn7000:
	$(MAKE) -C kn7000 build/kn7000_program.rom build/kn7000_table.rom build/kn7000_picture.rom build-cnv

kn7000-clean:
	$(MAKE) -C kn7000 clean

gate-kn7000:
	$(MAKE) -C kn7000 verify verify-sp7001 verify-picture verify-cnv verify-table80 verify-ic18 verify-ic18-full verify-935 verify-893 verify-wave verify-customdata verify-ic21-own verify-gui-map

# ------------------------------------------- the other MN10300 "MILK" firmwares
# Added 2026-10-24, one folder each, made like kn7000/ and using its tools by
# relative path: kn2400/ (SX-KN2400 = SX-KN2600 program, v1.1), kn6000/ (v7.1),
# kn6500/ (v1.3), hdsx3/ (the KN6000/KN6500 expansion board's XAPR plug-in,
# update sx6-113). Their reference images (*/baserom/, not committed) are
# regenerated from the manufacturer's update installers in the private
# ../../ca-software-mirror/files (CA_MIRROR=...), and each Makefile records the SHA-1.
#
#   make kn2400 ...       assemble the image
#   make gate-kn2400 ...  its byte-identity gate (gate-kn2400 also checks that the
#                         KN2600 package ships the same image)
kn2400:
	$(MAKE) -C kn2400 build
kn6000:
	$(MAKE) -C kn6000 build
kn6500:
	$(MAKE) -C kn6500 build
hdsx3:
	$(MAKE) -C hdsx3 build

gate-kn2400:
	$(MAKE) -C kn2400 verify verify-kn2600 verify-gui-map symbols-check
gate-kn6000:
	$(MAKE) -C kn6000 verify verify-customdata verify-gui-map symbols-check
gate-kn6500:
	$(MAKE) -C kn6500 verify verify-gui-map symbols-check
gate-hdsx3:
	$(MAKE) -C hdsx3 verify verify-gui-map symbols-check

mn10300-siblings-clean:
	$(MAKE) -C kn2400 clean
	$(MAKE) -C kn6000 clean
	$(MAKE) -C kn6500 clean
	$(MAKE) -C hdsx3 clean

# floppy/: FAT12 diskette images rebuilt from typed source (floppy/README.md).
floppy:
	$(MAKE) -C floppy all
gate-floppy:
	$(MAKE) -C floppy gate

everything: all wsa1 kn7000 kn2400 kn6000 kn6500 hdsx3 floppy

# ⚠ assert_images_assemble.py runs FIRST and asks the assembler directly, from
# each root source.  The byte gate reads `make`'s answer and therefore inherits
# `make`'s blind spots; on 2026-09-01 an incomplete prerequisite list let it
# certify objects from a toolchain that no longer accepted the sources.
# ⚠ GENERATED PREREQUISITES MUST EXIST BEFORE THE ASSEMBLE CHECK. Sources
# .incbin files that generators produce (round-trip images, the derived
# stale-help duplicate, C-compiled data). On a CLEAN tree those do not exist
# yet, so assert_images_assemble.py fails with "Could not find incbin file"
# on a tree that is perfectly sound -- which is a false red, and a false red
# trains people to ignore the gate. Depending on the generated set fixes it
# without weakening anything: the assemble check still asks the assembler
# directly, it just is not asked before its inputs exist.
# ⚠ CORRECTED 2026-09-02: this dependency used to name only
# $(STALE_HELP_DUPLICATE), and the comment above claimed that covered "the
# generated set". It did not. `make clean-all && make gate-all` on a sound
# tree still went red with 3,790 errors per main-CPU image, all of them
# "Could not find incbin file 'includes/generated/sound_data_*.bin'" -- the
# round-trip sound images, which only `all` produces. Depending on `all` is
# also the honest statement of what the gate needs: assert_byte_identical.py
# compares rebuilt_ROMs/*, so the gate could never have run without it.
# The v141 sub-CPU tree is generated as "v142 + EDITS" and v140 as "v141 + EDITS"; a
# comment-only v142 change keeps all three images byte-identical, so only these checks notice
# that v141 or v140 was not regenerated.
gate: all
	python3 scripts/analysis/assert_images_assemble.py
	python3 scripts/analysis/assert_byte_identical.py
	$(MAKE) --no-print-directory verify-v8-reference verify-v6-reference verify-v5-reference verify-hdae5000-v201-reference verify-hdae5000-v115i-reference verify-hdae5000-v110i-reference verify-subprogram-update-images
	python3 scripts/generators/create_v141_subcpu_source.py --check
	python3 scripts/generators/create_v140_subcpu_source.py --check
	python3 scripts/analysis/hdae5000_obj_constants_check.py
	python3 scripts/analysis/hdae5000_menu_map.py --check
	python3 scripts/analysis/l2_symbol_reference.py --check
	$(MAKE) --no-print-directory gui-check

# The NAKA GUI sources (notes/data-semantics-2026-10-29/gui-kn5000/): the generated class and id
# headers of every tree, the object enums against the records' links, and the menu map.
# menu-map rewrites docs/gui/kn5000-menu-map.md; gui-check fails when anything is stale.
.PHONY: menu-map gui-check gui-census
menu-map: rebuilt_ROMs/kn5000_v10_program.llvm.elf
	python3 scripts/generators/gen_naka_menu_map.py
gui-check: rebuilt_ROMs/kn5000_v10_program.llvm.elf
	python3 scripts/generators/gen_naka_gui_headers.py --check
	python3 scripts/generators/gen_title_mode_index_equs.py --check
	for t in v10 v9 v7 v6 v5; do python3 scripts/converters/naka_asm_records.py --tree $$t --gen --check || exit 1; done
	python3 scripts/analysis/naka_gui_model.py --check
	python3 scripts/converters/naka_gui_symbolize.py --check --tree v10
	python3 scripts/converters/naka_gui_symbolize.py --check --tree v9
	python3 scripts/converters/naka_gui_symbolize.py --check --tree v7
	python3 scripts/converters/naka_gui_symbolize.py --check --tree v6
	python3 scripts/converters/naka_gui_symbolize.py --check --tree v5
	python3 scripts/generators/gen_naka_menu_map.py --check
gui-census:
	python3 scripts/analysis/naka_gui_census.py

# The v1.41 and v1.40 Sub-CPU update images (File Type 007) are also rebuilt from
# v141/subcpu and v140/subcpu above; this independently proves each tracked update image
# decompresses to exactly its tracked plain payload ROM (under 1 s).
# --selftest (about 4 s) shows the check catches one flipped byte, and that the
# other two LZSS scripts agree with the build's decoder.
# The HD-AE5000 GUI menu maps (notes/data-gui-hdae5000-2026-10-29/menu-map-*.md), generated from
# <tree>/hdae5000_ui_tree.s; `make gate` checks they are up to date.
.PHONY: hdae5000-menu-map
hdae5000-menu-map:
	python3 scripts/analysis/hdae5000_menu_map.py

verify-subprogram-update-images:
	python3 scripts/build/verify_subprogram_update_images.py
	python3 scripts/build/verify_subprogram_update_images.py --selftest

gate-wsa1:
	cd wsa1 && python3 scripts/analysis/assert_byte_identical.py
	$(MAKE) -C wsa1 images-check	# every picture and font range is an .incbin of the .bin built from its PNG (lane media-build)
	cd wsa1 && python3 scripts/analysis/gui_menu_map.py --check	# docs/gui-menu-map.md is generated from the sources

gate-all: gate gate-wsa1 gate-kn7000 gate-kn2400 gate-kn6000 gate-kn6500 gate-hdsx3 gate-floppy
	@# A stale object compares green forever: assert the assembler is a
	@# prerequisite of every image before believing either byte gate.
	python3 scripts/analysis/assert_toolchain_is_a_prerequisite.py

# LLVM build targets (primary)
llvm-all: rebuilt_ROMs/kn5000_v10_program.llvm.rom rebuilt_ROMs/kn5000_v9_program.llvm.rom original_ROMs/kn5000_v8_program.rom rebuilt_ROMs/kn5000_v8_program.llvm.rom rebuilt_ROMs/kn5000_v7_program.llvm.rom original_ROMs/kn5000_v6_program.rom rebuilt_ROMs/kn5000_v6_program.llvm.rom original_ROMs/kn5000_v5_program.rom rebuilt_ROMs/kn5000_v5_program.llvm.rom rebuilt_ROMs/kn5000_subprogram_v142.llvm.rom rebuilt_ROMs/kn5000_subprogram_v142_compressed.rom rebuilt_ROMs/kn5000_subprogram_v141.llvm.rom rebuilt_ROMs/kn5000_subprogram_v141_compressed.rom rebuilt_ROMs/kn5000_subprogram_v140.llvm.rom rebuilt_ROMs/kn5000_subprogram_v140_compressed.rom rebuilt_ROMs/kn5000_subcpu_boot.llvm.rom rebuilt_ROMs/hd-ae5000_v2_06i.llvm.rom original_ROMs/hd-ae5000_v2_01i.ic4 rebuilt_ROMs/hd-ae5000_v2_01i.llvm.rom original_ROMs/hd-ae5000_v1_15i.ic4 rebuilt_ROMs/hd-ae5000_v1_15i.llvm.rom original_ROMs/hd-ae5000_v1_10i.ic4 rebuilt_ROMs/hd-ae5000_v1_10i.llvm.rom rebuilt_ROMs/kn5000_table_data.llvm.rom rebuilt_ROMs/kn5000_custom_data.llvm.rom

# ============================================================================
# C-compiled ScreenData paramblocks
# ============================================================================
# C struct source files are compiled to raw binaries, then .incbin'd by assembly.
# This provides type-safe, self-documenting data definitions.

PARAMBLOCK_NAMES = alta altb altc altd alte bal common extended meas medium short value
PARAMBLOCK_BINS = $(patsubst %,v10/maincpu/includes/generated/style_ui_paramblock_%.bin,$(PARAMBLOCK_NAMES))

SCREENDATA_NAMES = ctlonly main meascursor yesctl
SCREENDATA_BINS = $(patsubst %,v10/maincpu/includes/generated/style_ui_screendata_%.bin,$(SCREENDATA_NAMES))

ACCOMP_NAMES = accomp_section_widget accomp_part_widget accomp_display_full
ACCOMP_BINS = $(patsubst %,v10/maincpu/includes/generated/%.bin,$(ACCOMP_NAMES))

SE_NAMES = se_drumkit_display se_rhythm_transport_tables se_name_editor se_compare_screen se_parameter_grid se_transport_display se_setup_sel3 se_apply_confirm se_general_edit se_setup_editor_full se_setup_sel4 se_setup_ctrl_full se_setup_ctrl_list se_setup_env se_setup_labels se_setup_nav_full se_setup_params_full se_setup_rhythm se_setup_sel1 se_setup_sel2 se_setup_sel_rects se_setup_transport se_setup_waveform
# Every name in SE_NAMES is .incbin'd by assembly: se_apply_confirm from
# storage/flash_floppy_handlers.s, the rest from audio/sound_editor_ui.s.
# se_setup_editor_full and se_setup_sel4 (276 B) ARE now built: lane v10se
# proved them byte-exact against the ROM
# (scripts/lanes/v10se/se_c_descriptor_vs_rom.py) but could not integrate them
# because their spans live in storage/flash_floppy_handlers.s; lane v10storage
# owns that file and .incbin'd them there. Part of that span had been fake
# code -- `ld xix, 0x4d414e59` is the ASCII "MANY".
# ⚠ They are in SE_NAMES, not SE_V10_NAMES, because they are pre-existing
# descriptors rather than v10-derived ones. SE_NAMES is patsubst'd into v7/ and
# v9/, so the .bin is built for those images too; only v10's
# flash_floppy_handlers.s references it, and the 13-image gate is the check
# that this is harmless.
# v10-ONLY screen descriptors, found by scripts/lanes/v10se/se_generate_new_screendata.py.
# They are kept OUT of SE_NAMES because that list is patsubst'd into v7/ and v9/
# as well, and these blocks were derived from the v10 ROM alone -- the same
# addresses mean nothing in the other two images.
SE_V10_NAMES = se_screen_f11f83 se_screen_f129d1 se_screen_f12d33 se_screen_f140ef
SE_BINS = $(patsubst %,v10/maincpu/includes/generated/%.bin,$(SE_NAMES) $(SE_V10_NAMES))
SE_LINK_LD = v10/maincpu/audio/sound_editor_screens/se_screens_link.ld
ACCOMP_LINK_LD = v10/maincpu/sequencer/accomp_screens/accomp_screens_link.ld

NAKA_LINK_LD = v10/maincpu/ui_widgets/naka_ctrl_menu_link.ld
NAKA_TYPES_H = v10/maincpu/ui_widgets/naka_types.h v10/maincpu/ui_widgets/naka_classes.h v10/maincpu/ui_widgets/naka_ids.h v10/maincpu/ui_widgets/naka_ram_cells.h
NAKA_BINS = v10/maincpu/includes/generated/naka_control_menu_header.bin v10/maincpu/includes/generated/naka_ctrl_menu_body.bin v10/maincpu/includes/generated/naka_perf_style.bin v10/maincpu/includes/generated/naka_msp_recording.bin v10/maincpu/includes/generated/naka_effects_seq.bin v10/maincpu/includes/generated/naka_midi_reverb.bin v10/maincpu/includes/generated/naka_composer_style.bin v10/maincpu/includes/generated/naka_direct_play.bin v10/maincpu/includes/generated/naka_technichord_part.bin v10/maincpu/includes/generated/naka_disk_menu_file_io.bin v10/maincpu/includes/generated/naka_debug_naming.bin v10/maincpu/includes/generated/naka_disk_warning.bin v10/maincpu/includes/generated/naka_extension_device.bin v10/maincpu/includes/generated/naka_normal_mode.bin v10/maincpu/includes/generated/naka_widget_tables_1.bin v10/maincpu/includes/generated/naka_master_style.bin v10/maincpu/includes/generated/naka_sound_menu_drawbar.bin v10/maincpu/includes/generated/naka_sequencer_exit.bin v10/maincpu/includes/generated/naka_sequencer_channels.bin v10/maincpu/includes/generated/naka_block_007.bin v10/maincpu/includes/generated/naka_block_012.bin v10/maincpu/includes/generated/naka_widget_names_charmap.bin v10/maincpu/includes/generated/naka_technichord_strings.bin v10/maincpu/includes/generated/naka_widget_tables_2.bin v10/maincpu/includes/generated/naka_style_bitmaps.bin v10/maincpu/includes/generated/naka_widget_descriptors.bin v10/maincpu/includes/generated/naka_accomp7_widgets.bin

VOICE_BINS = v10/maincpu/includes/generated/voice_factory_presets.bin
AUDIO_BINS = v10/maincpu/includes/generated/tonegen_param_table.bin
SOUND_DATA_BINS = v10/maincpu/includes/generated/sound_data_organ_accordion.bin v10/maincpu/includes/generated/sound_data_orchestral_pad.bin v10/maincpu/includes/generated/sound_data_synth.bin v10/maincpu/includes/generated/sound_data_bass.bin v10/maincpu/includes/generated/sound_data_accordion_reg.bin v10/maincpu/includes/generated/sound_data_digital_drawbar.bin v10/maincpu/includes/generated/sound_data_gm_special.bin v10/maincpu/includes/generated/sound_data_guitar.bin v10/maincpu/includes/generated/sound_data_sax_reed.bin v10/maincpu/includes/generated/sound_data_drum_kits.bin v10/maincpu/includes/generated/sound_data_piano.bin v10/maincpu/includes/generated/sound_data_strings_vocal.bin v10/maincpu/includes/generated/sound_data_flute.bin v10/maincpu/includes/generated/sound_data_flute_extra.bin v10/maincpu/includes/generated/sound_data_mallet_orch_perc.bin
SEPAOUT_BINS = v10/maincpu/includes/generated/sepaout_config.bin
GUI_BINS = v10/maincpu/includes/generated/gui_display_struct_data.bin
TONEKIT_BINS = v10/maincpu/includes/generated/tonekit_param_blocks.bin
SOUNDCFG_BINS = v10/maincpu/includes/generated/sound_config_lookup.bin
MSP_BINS = v10/maincpu/includes/generated/msp_factory_defaults.bin

# 18-byte sound-parameter descriptor runs (v10 ONLY -- v7 and v9 carry a
# different, much smaller extension_data.s, so these runs do not exist there
# at the same addresses).  See v10/maincpu/audio/sndparam_records/.
SNDPARAM_NAMES = run_edbac0 run_edbc9e run_edc2a4 run_edc634 run_edc7fa run_edc8a4 run_edc980 run_ede9fc run_ee0010
SNDPARAM_BINS = $(patsubst %,v10/maincpu/includes/generated/sndparam_%.bin,$(SNDPARAM_NAMES))
C_DATA_BINS = $(PARAMBLOCK_BINS) $(VOICE_BINS) $(AUDIO_BINS) $(SOUND_DATA_BINS) $(SCREENDATA_BINS) $(ACCOMP_BINS) $(SE_BINS) $(NAKA_BINS) $(SEPAOUT_BINS) $(GUI_BINS) $(TONEKIT_BINS) $(SOUNDCFG_BINS) $(MSP_BINS) $(SNDPARAM_BINS)

# V9 C data bins (compiled from v9/maincpu sources)
V9_PARAMBLOCK_BINS = $(patsubst %,v9/maincpu/includes/generated/style_ui_paramblock_%.bin,$(PARAMBLOCK_NAMES))
V9_SCREENDATA_BINS = $(patsubst %,v9/maincpu/includes/generated/style_ui_screendata_%.bin,$(SCREENDATA_NAMES))
V9_ACCOMP_BINS = $(patsubst %,v9/maincpu/includes/generated/%.bin,$(ACCOMP_NAMES))
V9_SE_BINS = $(patsubst %,v9/maincpu/includes/generated/%.bin,$(SE_NAMES))
V9_SE_LINK_LD = v9/maincpu/audio/sound_editor_screens/se_screens_link.ld
V9_ACCOMP_LINK_LD = v9/maincpu/sequencer/accomp_screens/accomp_screens_link.ld
V9_NAKA_LINK_LD = v9/maincpu/ui_widgets/naka_ctrl_menu_link.ld
V9_NAKA_TYPES_H = v9/maincpu/ui_widgets/naka_types.h v9/maincpu/ui_widgets/naka_classes.h v9/maincpu/ui_widgets/naka_ids.h v9/maincpu/ui_widgets/naka_ram_cells.h
V9_NAKA_BINS = $(patsubst v10/%,v9/%,$(NAKA_BINS))
V9_VOICE_BINS = v9/maincpu/includes/generated/voice_factory_presets.bin
V9_AUDIO_BINS = v9/maincpu/includes/generated/tonegen_param_table.bin
V9_SOUND_DATA_BINS = $(patsubst v10/%,v9/%,$(SOUND_DATA_BINS))
V9_SEPAOUT_BINS = v9/maincpu/includes/generated/sepaout_config.bin
V9_GUI_BINS = v9/maincpu/includes/generated/gui_display_struct_data.bin
V9_TONEKIT_BINS = v9/maincpu/includes/generated/tonekit_param_blocks.bin
V9_SOUNDCFG_BINS = v9/maincpu/includes/generated/sound_config_lookup.bin
V9_MSP_BINS = v9/maincpu/includes/generated/msp_factory_defaults.bin
V9_C_DATA_BINS = $(V9_PARAMBLOCK_BINS) $(V9_VOICE_BINS) $(V9_AUDIO_BINS) $(V9_SOUND_DATA_BINS) $(V9_SCREENDATA_BINS) $(V9_ACCOMP_BINS) $(V9_SE_BINS) $(V9_NAKA_BINS) $(V9_SEPAOUT_BINS) $(V9_GUI_BINS) $(V9_TONEKIT_BINS) $(V9_SOUNDCFG_BINS) $(V9_MSP_BINS)

# V7 C data bins (compiled from v7/maincpu sources)
V7_PARAMBLOCK_BINS = $(patsubst %,v7/maincpu/includes/generated/style_ui_paramblock_%.bin,$(PARAMBLOCK_NAMES))
V7_SCREENDATA_BINS = $(patsubst %,v7/maincpu/includes/generated/style_ui_screendata_%.bin,$(SCREENDATA_NAMES))
V7_ACCOMP_BINS = $(patsubst %,v7/maincpu/includes/generated/%.bin,$(ACCOMP_NAMES))
V7_SE_BINS = $(patsubst %,v7/maincpu/includes/generated/%.bin,$(SE_NAMES))
V7_SE_LINK_LD = v7/maincpu/audio/sound_editor_screens/se_screens_link.ld
V7_ACCOMP_LINK_LD = v7/maincpu/sequencer/accomp_screens/accomp_screens_link.ld
V7_NAKA_LINK_LD = v7/maincpu/ui_widgets/naka_ctrl_menu_link.ld
V7_NAKA_TYPES_H = v7/maincpu/ui_widgets/naka_types.h v7/maincpu/ui_widgets/naka_classes.h v7/maincpu/ui_widgets/naka_ids.h v7/maincpu/ui_widgets/naka_ram_cells.h
V7_NAKA_BINS = $(patsubst v10/%,v7/%,$(NAKA_BINS))
V7_VOICE_BINS = v7/maincpu/includes/generated/voice_factory_presets.bin
V7_AUDIO_BINS = v7/maincpu/includes/generated/tonegen_param_table.bin
V7_SOUND_DATA_BINS = $(patsubst v10/%,v7/%,$(SOUND_DATA_BINS))
V7_SEPAOUT_BINS = v7/maincpu/includes/generated/sepaout_config.bin
V7_GUI_BINS = v7/maincpu/includes/generated/gui_display_struct_data.bin
V7_TONEKIT_BINS = v7/maincpu/includes/generated/tonekit_param_blocks.bin
V7_SOUNDCFG_BINS = v7/maincpu/includes/generated/sound_config_lookup.bin
V7_MSP_BINS = v7/maincpu/includes/generated/msp_factory_defaults.bin
V7_C_DATA_BINS = $(V7_PARAMBLOCK_BINS) $(V7_VOICE_BINS) $(V7_AUDIO_BINS) $(V7_SOUND_DATA_BINS) $(V7_SCREENDATA_BINS) $(V7_ACCOMP_BINS) $(V7_SE_BINS) $(V7_NAKA_BINS) $(V7_SEPAOUT_BINS) $(V7_GUI_BINS) $(V7_TONEKIT_BINS) $(V7_SOUNDCFG_BINS) $(V7_MSP_BINS)

v10/maincpu/includes/generated/style_ui_paramblock_%.bin: v10/maincpu/style_ui/paramblock/%.c v10/maincpu/style_ui/screendata_types.h
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/style_ui -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

# ctlonly uses linker to resolve extern symbol addresses from scoop_display.s
v10/maincpu/includes/generated/style_ui_screendata_ctlonly.bin: v10/maincpu/style_ui/ctlonly.c v10/maincpu/style_ui/screendata_types.h v10/maincpu/style_ui/ctlonly_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/style_ui/ctlonly_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/style_ui_screendata_%.bin: v10/maincpu/style_ui/%.c v10/maincpu/style_ui/screendata_types.h
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/style_ui -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

# SE screens use shared linker script to resolve extern handler symbols
v10/maincpu/includes/generated/se_%.bin: v10/maincpu/audio/sound_editor_screens/se_%.c v10/maincpu/style_ui/screendata_types.h $(SE_LINK_LD)
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T $(SE_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

# Accomp screens use shared linker script to resolve extern handler symbols
v10/maincpu/includes/generated/accomp_%.bin: v10/maincpu/sequencer/accomp_screens/accomp_%.c v10/maincpu/style_ui/screendata_types.h $(ACCOMP_LINK_LD)
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T $(ACCOMP_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

# NAKA widget descriptors — compiled C structs with named fields
v10/maincpu/includes/generated/naka_control_menu_header.bin: v10/maincpu/ui_widgets/control_menu_header.c $(NAKA_TYPES_H) $(NAKA_LINK_LD)
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T $(NAKA_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_ctrl_menu_body.bin: v10/maincpu/ui_widgets/naka_ctrl_menu_body.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_ctrl_menu_body_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_ctrl_menu_body_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_perf_style.bin: v10/maincpu/ui_widgets/naka_perf_style.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_perf_style_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_perf_style_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_msp_recording.bin: v10/maincpu/ui_widgets/naka_msp_recording.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_msp_recording_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_msp_recording_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_effects_seq.bin: v10/maincpu/ui_widgets/naka_effects_seq.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_effects_seq_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_effects_seq_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_midi_reverb.bin: v10/maincpu/ui_widgets/naka_midi_reverb.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_midi_reverb_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_midi_reverb_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_composer_style.bin: v10/maincpu/ui_widgets/naka_composer_style.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_composer_style_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_composer_style_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_direct_play.bin: v10/maincpu/ui_widgets/naka_direct_play.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_direct_play_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_direct_play_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_technichord_part.bin: v10/maincpu/ui_widgets/naka_technichord_part.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_technichord_part_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_technichord_part_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_disk_menu_file_io.bin: v10/maincpu/ui_widgets/naka_disk_menu_file_io.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_disk_menu_file_io_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_disk_menu_file_io_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_debug_naming.bin: v10/maincpu/ui_widgets/naka_debug_naming.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_debug_naming_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_debug_naming_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_disk_warning.bin: v10/maincpu/ui_widgets/naka_disk_warning.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_disk_warning_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_disk_warning_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_extension_device.bin: v10/maincpu/ui_widgets/naka_extension_device.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_extension_device_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_extension_device_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_normal_mode.bin: v10/maincpu/ui_widgets/naka_normal_mode.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_normal_mode_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_normal_mode_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_widget_tables_1.bin: v10/maincpu/ui_widgets/naka_widget_tables_1.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_widget_tables_1_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_widget_tables_1_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_master_style.bin: v10/maincpu/ui_widgets/naka_master_style.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_master_style_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_master_style_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_sound_menu_drawbar.bin: v10/maincpu/ui_widgets/naka_sound_menu_drawbar.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_sound_menu_drawbar_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_sound_menu_drawbar_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_sequencer_exit.bin: v10/maincpu/ui_widgets/naka_sequencer_exit.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_sequencer_exit_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_sequencer_exit_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_sequencer_channels.bin: v10/maincpu/ui_widgets/naka_sequencer_channels.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_sequencer_channels_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_sequencer_channels_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_block_007.bin: v10/maincpu/ui_widgets/naka_block_007.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_block_007_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_block_007_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_block_012.bin: v10/maincpu/ui_widgets/naka_block_012.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_block_012_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_block_012_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_widget_names_charmap.bin: v10/maincpu/ui_widgets/naka_widget_names_charmap.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_widget_names_charmap_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_widget_names_charmap_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_technichord_strings.bin: v10/maincpu/ui_widgets/naka_technichord_strings.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_technichord_strings_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_technichord_strings_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_widget_tables_2.bin: v10/maincpu/ui_widgets/naka_widget_tables_2.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_widget_tables_2_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_widget_tables_2_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_style_bitmaps.bin: v10/maincpu/ui_widgets/naka_style_bitmaps.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_style_bitmaps_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_style_bitmaps_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v10/maincpu/includes/generated/naka_widget_descriptors.bin: v10/maincpu/ui_widgets/naka_widget_descriptors.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_widget_descriptors_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_widget_descriptors_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf


v10/maincpu/includes/generated/naka_accomp7_widgets.bin: v10/maincpu/ui_widgets/naka_accomp7_widgets.c $(NAKA_TYPES_H) v10/maincpu/ui_widgets/naka_accomp7_widgets_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui_widgets/naka_accomp7_widgets_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

# ToneKit parameter blocks — 118 blocks of 6-byte sound parameter records
v10/maincpu/includes/generated/tonekit_param_blocks.bin: v10/maincpu/ui_widgets/tonekit_param_blocks.c
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

# Sound config lookup — 25 x 234-byte channel configuration records
v10/maincpu/includes/generated/sound_config_lookup.bin: v10/maincpu/ui_widgets/sound_config_lookup.c
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v10/maincpu/includes/generated/sndparam_%.bin: v10/maincpu/audio/sndparam_records/%.c v10/maincpu/audio/sndparam_records/sndparam_types.h
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v10/maincpu/audio/sndparam_records -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v10/maincpu/includes/generated/msp_factory_defaults.bin: v10/maincpu/msp_factory_defaults.c
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v10/maincpu/includes/generated/voice_factory_presets.bin: v10/maincpu/audio/voice_factory_presets.c
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v10/maincpu/includes/generated/tonegen_param_table.bin: v10/maincpu/audio/tonegen_param_table.c
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

# Sound data C struct files — compiled to raw binaries, .incbin'd by assembly
v10/maincpu/includes/generated/sound_data_%.bin: v10/maincpu/audio/sound_data_%.c
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

# SepaOut config — compiled C struct with linker script for symbol resolution
v10/maincpu/includes/generated/sepaout_config.bin: v10/maincpu/ui/sepaout_config.c v10/maincpu/ui/sepaout_config_link.ld
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_LLD) -T v10/maincpu/ui/sepaout_config_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

# GUI display struct data — compiled C struct
v10/maincpu/includes/generated/gui_display_struct_data.bin: v10/maincpu/includes/gui_display_struct_data.c
	@mkdir -p v10/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o


# V9 C data compilation rules (mirror v10 rules with v9 paths)
v9/maincpu/includes/generated/style_ui_paramblock_%.bin: v9/maincpu/style_ui/paramblock/%.c v9/maincpu/style_ui/screendata_types.h
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v9/maincpu/style_ui -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v9/maincpu/includes/generated/style_ui_screendata_ctlonly.bin: v9/maincpu/style_ui/ctlonly.c v9/maincpu/style_ui/screendata_types.h v9/maincpu/style_ui/ctlonly_link.ld
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v9/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T v9/maincpu/style_ui/ctlonly_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v9/maincpu/includes/generated/style_ui_screendata_%.bin: v9/maincpu/style_ui/%.c v9/maincpu/style_ui/screendata_types.h
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v9/maincpu/style_ui -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v9/maincpu/includes/generated/se_%.bin: v9/maincpu/audio/sound_editor_screens/se_%.c v9/maincpu/style_ui/screendata_types.h $(V9_SE_LINK_LD)
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v9/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T $(V9_SE_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v9/maincpu/includes/generated/accomp_%.bin: v9/maincpu/sequencer/accomp_screens/accomp_%.c v9/maincpu/style_ui/screendata_types.h $(V9_ACCOMP_LINK_LD)
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v9/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T $(V9_ACCOMP_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

# V9 NAKA widget descriptors - generic rule for all naka bins
v9/maincpu/includes/generated/naka_%.bin: v9/maincpu/ui_widgets/naka_%.c $(V9_NAKA_TYPES_H) v9/maincpu/ui_widgets/naka_%_link.ld
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v9/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v9/maincpu/ui_widgets/naka_$*_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v9/maincpu/includes/generated/naka_control_menu_header.bin: v9/maincpu/ui_widgets/control_menu_header.c $(V9_NAKA_TYPES_H) $(V9_NAKA_LINK_LD)
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v9/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T $(V9_NAKA_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v9/maincpu/includes/generated/msp_factory_defaults.bin: v9/maincpu/msp_factory_defaults.c
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v9/maincpu/includes/generated/voice_factory_presets.bin: v9/maincpu/audio/voice_factory_presets.c
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v9/maincpu/includes/generated/tonegen_param_table.bin: v9/maincpu/audio/tonegen_param_table.c
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v9/maincpu/includes/generated/sound_data_%.bin: v9/maincpu/audio/sound_data_%.c
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v9/maincpu/includes/generated/sepaout_config.bin: v9/maincpu/ui/sepaout_config.c v9/maincpu/ui/sepaout_config_link.ld
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_LLD) -T v9/maincpu/ui/sepaout_config_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v9/maincpu/includes/generated/gui_display_struct_data.bin: v9/maincpu/includes/gui_display_struct_data.c
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v9/maincpu/includes/generated/tonekit_param_blocks.bin: v9/maincpu/ui_widgets/tonekit_param_blocks.c
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v9/maincpu/includes/generated/sound_config_lookup.bin: v9/maincpu/ui_widgets/sound_config_lookup.c
	@mkdir -p v9/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o


# V7 C data compilation rules (mirror v9 rules with v7 paths)
v7/maincpu/includes/generated/style_ui_paramblock_%.bin: v7/maincpu/style_ui/paramblock/%.c v7/maincpu/style_ui/screendata_types.h
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v7/maincpu/style_ui -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v7/maincpu/includes/generated/style_ui_screendata_ctlonly.bin: v7/maincpu/style_ui/ctlonly.c v7/maincpu/style_ui/screendata_types.h v7/maincpu/style_ui/ctlonly_link.ld
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v7/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T v7/maincpu/style_ui/ctlonly_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v7/maincpu/includes/generated/style_ui_screendata_%.bin: v7/maincpu/style_ui/%.c v7/maincpu/style_ui/screendata_types.h
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v7/maincpu/style_ui -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v7/maincpu/includes/generated/se_%.bin: v7/maincpu/audio/sound_editor_screens/se_%.c v7/maincpu/style_ui/screendata_types.h $(V7_SE_LINK_LD)
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v7/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T $(V7_SE_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v7/maincpu/includes/generated/accomp_%.bin: v7/maincpu/sequencer/accomp_screens/accomp_%.c v7/maincpu/style_ui/screendata_types.h $(V7_ACCOMP_LINK_LD)
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v7/maincpu/style_ui -o $@.o $<
	$(LLVM_LLD) -T $(V7_ACCOMP_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

# V7 NAKA widget descriptors - generic rule for all naka bins
v7/maincpu/includes/generated/naka_%.bin: v7/maincpu/ui_widgets/naka_%.c $(V7_NAKA_TYPES_H) v7/maincpu/ui_widgets/naka_%_link.ld
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v7/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T v7/maincpu/ui_widgets/naka_$*_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v7/maincpu/includes/generated/naka_control_menu_header.bin: v7/maincpu/ui_widgets/control_menu_header.c $(V7_NAKA_TYPES_H) $(V7_NAKA_LINK_LD)
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I v7/maincpu/ui_widgets -o $@.o $<
	$(LLVM_LLD) -T $(V7_NAKA_LINK_LD) -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v7/maincpu/includes/generated/msp_factory_defaults.bin: v7/maincpu/msp_factory_defaults.c
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v7/maincpu/includes/generated/voice_factory_presets.bin: v7/maincpu/audio/voice_factory_presets.c
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v7/maincpu/includes/generated/tonegen_param_table.bin: v7/maincpu/audio/tonegen_param_table.c
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v7/maincpu/includes/generated/sound_data_%.bin: v7/maincpu/audio/sound_data_%.c
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v7/maincpu/includes/generated/sepaout_config.bin: v7/maincpu/ui/sepaout_config.c v7/maincpu/ui/sepaout_config_link.ld
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_LLD) -T v7/maincpu/ui/sepaout_config_link.ld -o $@.elf $@.o
	$(LLVM_OBJCOPY) -O binary -j .text $@.elf $@
	@rm -f $@.o $@.elf

v7/maincpu/includes/generated/gui_display_struct_data.bin: v7/maincpu/includes/gui_display_struct_data.c
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v7/maincpu/includes/generated/tonekit_param_blocks.bin: v7/maincpu/ui_widgets/tonekit_param_blocks.c
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

v7/maincpu/includes/generated/sound_config_lookup.bin: v7/maincpu/ui_widgets/sound_config_lookup.c
	@mkdir -p v7/maincpu/includes/generated
	$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $@.o $<
	$(LLVM_OBJCOPY) -O binary -j .text $@.o $@
	@rm -f $@.o

paramblocks: $(PARAMBLOCK_BINS)
screendata: $(SCREENDATA_BINS)
naka: $(NAKA_BINS)

# --------------------------------------------------------------- include deps
# ⚠ AN IMAGE'S OBJECT DEPENDS ON EVERY .s THE ROOT INCLUDES, NOT JUST THE ROOT.
# Until 2026-09-01 each rule below named only its root file, so a change to any
# of the ~150 included sources left the object stale and `make all` did nothing.
# assert_byte_identical.py rebuilds before comparing precisely so that it cannot
# certify stale artefacts -- but an incomplete prerequisite list defeats that,
# and it did: after the toolchain pin moved to 95f7f2d40428 (which refuses an
# immediate that does not fit) four KN5000 images stopped assembling, and the
# gate stayed green on objects dated 2026-08-23.  $(LLVM_MC) is a prerequisite
# for the same reason: a new assembler must invalidate every object it produced.
V10_SRC = $(wildcard v10/maincpu/*.s v10/maincpu/*/*.s v10/maincpu/*/*/*.s)
V9_SRC  = $(wildcard v9/maincpu/*.s v9/maincpu/*/*.s v9/maincpu/*/*/*.s)
V7_SRC  = $(wildcard v7/maincpu/*.s v7/maincpu/*/*.s v7/maincpu/*/*/*.s)
V142_SRC = $(wildcard v142/subcpu/*.s v142/subcpu/*/*.s)
V141_SRC = $(wildcard v141/subcpu/*.s v141/subcpu/*/*.s)
V140_SRC = $(wildcard v140/subcpu/*.s v140/subcpu/*/*.s)
# The sub-CPU kernel is wsa1/kernel/kernel.s, shared with both SX-WSA1R CPUs since 2026-11-06
# (wsa1/notes/open9-a3-probes/README.md); every payload version includes it through -I wsa1/kernel.
SUBCPU_KERNEL_SRC = wsa1/kernel/kernel.s wsa1/kernel/kernel_kn5000_subcpu.inc
# ...and the main-CPU programs' (v10, v9 and its v8 build, v7) since the same day: KERNEL_KN5000 = 2
# (lane open10/kernel4, wsa1/notes/open10-kernel4-probes/README.md).
MAINCPU_KERNEL_SRC = wsa1/kernel/kernel.s wsa1/kernel/kernel_kn5000_maincpu.inc
SUBBOOT_SRC = $(wildcard subcpu/boot/*.s subcpu/boot/*/*.s)
HDAE_SRC = $(wildcard hdae5000/*.s hdae5000/*/*.s)
TABLEDATA_SRC = $(wildcard table_data/*.s table_data/*/*.s)
CUSTOMDATA_SRC = $(wildcard custom_data/*.s custom_data/*/*.s)

# --- Firmware C code (cc900 phase 6; notes/cc900-phase6-2026-11-16/README.md) ---
# <tree>/cc900/*.c is C for firmware functions.  scripts/build/cc900_firmware_c.py turns each file into one body per
# function, includes/generated/cc900/<function>.s, which the tree includes on the function's label line in place of
# its hand-written instructions.  The byte gate is the proof that the C, the compiler and the translator give the
# firmware's bytes.  Every main-CPU tree has its own C (the v9 tree's also builds v8): the trees differ in RAM cell
# addresses.  The stamp depends on the tree's sources because the generator reads the tree's .equ values (they
# choose an operand's 16- or 24-bit width).  C that V4.23 does not reproduce is not built: <tree>/cc900/unbuilt/.
#
# CC900_COMPILER chooses the compiler (the bodies are the same either way; `make gate` passes with both):
#   v423   (the default) Toshiba cc900 V4.23, the firmware's own compiler, run in the oracle VM
#          ($(CC900_ORACLE)/vm, scripts/analysis/cc900/oracle/run_vm.sh) by scripts/build/cc900_v423.py.  Its
#          listings are cached in $(CC900_V423_CACHE) (git-ignored), keyed by the C text, its options and headers,
#          the compiler tree and the guest's job.sh.  A make compiles all uncached files in ONE VM job, in a slot of
#          the VM pool (oracle/vm_slot.sh); a fully cached make never touches the VM, so it builds without one.  The listing goes through
#          model/to_llvm.py into our llvm-mc syntax.  There is no automatic fallback: when a file is not cached and
#          the VM is unusable, the build stops, names what is missing and the flag below.
#   model  our Python reference model of cc900 (scripts/analysis/cc900/model/, with the generator's FIRMWARE_RULES)
#          and model/to_llvm.py: our own tools only, no VM.  `make CC900_COMPILER=model gate`.
# Changing CC900_COMPILER rebuilds every body (rebuilt_ROMs/cc900-compiler.txt records the last choice).
CC900_COMPILER ?= v423
CC900_ORACLE ?= $(PROJECTS_ROOT)/cc900-oracle
CC900_V423_CACHE ?= build/cc900-v423
CC900_MODEL_SRC = $(wildcard scripts/analysis/cc900/model/*.py)
CC900_FW_GEN = scripts/build/cc900_firmware_c.py
CC900_TRANSLATE_SRC = scripts/analysis/cc900/model/to_llvm.py scripts/analysis/cc900/model/listing.py
CC900_CHOICE = rebuilt_ROMs/cc900-compiler.txt
CC900_V423_INDEX = $(CC900_V423_CACHE)/index.tsv
CC900_V423_DONE = $(CC900_V423_CACHE)/filled.stamp
CC900_ALL_C = $(foreach t,v10 v9 v7 v6 v5,$(wildcard $(t)/maincpu/cc900/*.c))
# The compiler choice and (for V4.23) the cache index are written while make reads this file, each only when its
# content changes; so the bodies are rebuilt exactly when the choice or a V4.23 cache key changed, and `make -q`
# (assert_byte_identical.py's staleness check) sees an up-to-date tree as up to date.  Both take well under a second.
$(shell mkdir -p rebuilt_ROMs; echo '$(CC900_COMPILER)' | cmp -s - $(CC900_CHOICE) || echo '$(CC900_COMPILER)' > $(CC900_CHOICE))
ifeq ($(CC900_COMPILER),v423)
CC900_GEN_DEPS = $(CC900_V423_DONE) $(CC900_TRANSLATE_SRC) scripts/build/cc900_v423.py
CC900_GEN_CMD = python3 -B $(CC900_FW_GEN) --v423 $(CC900_V423_CACHE)
$(shell python3 -B scripts/build/cc900_v423.py index $(CC900_V423_CACHE) $(CC900_ALL_C) >&2)
ifneq ($(.SHELLSTATUS),0)
$(error cc900_v423.py index failed (above))
endif
else ifeq ($(CC900_COMPILER),model)
CC900_GEN_DEPS = $(CC900_MODEL_SRC) $(CLANG)
CC900_GEN_CMD = CC900_MODEL_CLANG=$(CLANG) python3 -B $(CC900_FW_GEN)
else
$(error CC900_COMPILER=$(CC900_COMPILER): choose v423 (Toshiba V4.23 in the oracle VM, the default) or model (the Python reference model))
endif
# The one VM job: runs when the index changed (a new key, or a listing missing from the cache).
$(CC900_V423_DONE): $(CC900_V423_INDEX)
	python3 -B scripts/build/cc900_v423.py fill $(CC900_V423_CACHE) $(CC900_ORACLE) $(CC900_ALL_C)
	touch $@
$(CC900_V423_INDEX): ;
cc900_stamps = $(patsubst $(1)/maincpu/cc900/%.c,$(1)/maincpu/includes/generated/cc900/%.stamp,$(wildcard $(1)/maincpu/cc900/*.c))
V10_CC900_STAMPS = $(call cc900_stamps,v10)
V9_CC900_STAMPS = $(call cc900_stamps,v9)
V7_CC900_STAMPS = $(call cc900_stamps,v7)
V6_CC900_STAMPS = $(call cc900_stamps,v6)
V5_CC900_STAMPS = $(call cc900_stamps,v5)
# $(1) the tree (v10), $(2) the variable naming its sources (V10_SRC); eval'd once that variable exists
define CC900_FIRMWARE_C
$(1)/maincpu/includes/generated/cc900/%.stamp: $(1)/maincpu/cc900/%.c $$($(2)) $$(CC900_GEN_DEPS) $$(CC900_FW_GEN) $$(CC900_CHOICE) $$(LLVM_MC)
	$$(CC900_GEN_CMD) $(1)/maincpu $$< $(1)/maincpu/includes/generated/cc900 $$@
endef
$(eval $(call CC900_FIRMWARE_C,v10,V10_SRC))
$(eval $(call CC900_FIRMWARE_C,v9,V9_SRC))
$(eval $(call CC900_FIRMWARE_C,v7,V7_SRC))
.PHONY: cc900-firmware-c
cc900-firmware-c: $(V10_CC900_STAMPS) $(V9_CC900_STAMPS) $(V7_CC900_STAMPS) $(V6_CC900_STAMPS) $(V5_CC900_STAMPS)

# --- Maincpu ---
rebuilt_ROMs/kn5000_v10_program.llvm.o: $(V10_SRC) $(V10_CC900_STAMPS) $(MAINCPU_KERNEL_SRC) original_ROMs/kn5000_v10_program.rom $(C_DATA_BINS) $(KN5000_IMAGE_BINS) $(INDEXED_IMAGE_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I v10/maincpu -I wsa1/kernel -o $@ v10/maincpu/kn5000_v10_program.s

rebuilt_ROMs/kn5000_v10_program.llvm.elf: rebuilt_ROMs/kn5000_v10_program.llvm.o v10/maincpu/maincpu.ld
	$(LLVM_LLD) -T v10/maincpu/maincpu.ld -o $@ $<

rebuilt_ROMs/kn5000_v10_program.llvm.rom: rebuilt_ROMs/kn5000_v10_program.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- V9 Maincpu ---
rebuilt_ROMs/kn5000_v9_program.llvm.o: $(V9_SRC) $(V9_CC900_STAMPS) $(MAINCPU_KERNEL_SRC) original_ROMs/kn5000_v9_program.rom $(V9_C_DATA_BINS) $(KN5000_IMAGE_BINS) $(INDEXED_IMAGE_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I v9/maincpu -I wsa1/kernel -o $@ v9/maincpu/kn5000_v9_program.s

rebuilt_ROMs/kn5000_v9_program.llvm.elf: rebuilt_ROMs/kn5000_v9_program.llvm.o v9/maincpu/maincpu.ld
	$(LLVM_LLD) -T v9/maincpu/maincpu.ld -o $@ $<

rebuilt_ROMs/kn5000_v9_program.llvm.rom: rebuilt_ROMs/kn5000_v9_program.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- V8 Maincpu: the v9 sources with the version byte preset ---
# The v8 program ROM differs from v9 in exactly one byte, FIRMWARE_VERSION at
# 0xFFFFE8 (file offset 0x1FFFE8): 0x08 instead of 0x09.  So v8 has no source
# tree of its own: it is v9/maincpu assembled with --defsym FW_VERSION_BYTE=0x08,
# which v9/maincpu/boot/rom_end_structure.s honours through `.ifndef`.
#
# The reference image is not committed.  The older dumps in original_ROMs/
# (v7, v9, v10, the Sub-CPU payloads) are tracked, but new dumps are taken
# from the private romset and kept out of this public repository by choice.
# It is copied, git-ignored, from that romset; override the source with
#   make KN5000_V8_REF=/path/to/kn5000_v8_program.rom ...
# The copy is refused unless its SHA-1 is KN5000_V8_SHA1, and a missing source
# stops the build with a message instead of silently skipping v8.
KN5000_V8_REF  ?= $(PROJECTS_ROOT)/technics_roms/roms/kn5000/kn5000_v8_program.rom
KN5000_V8_SHA1 := a10a6f5a35175b74c3cfb42cef3bdf571c2858bb

original_ROMs/kn5000_v8_program.rom:
	@if [ ! -f "$(KN5000_V8_REF)" ]; then \
	  echo "ERROR: the KN5000 v8 reference image is missing: $(KN5000_V8_REF)"; \
	  echo "       It is not in git (new dumps come from the private romset). Point KN5000_V8_REF at a copy whose"; \
	  echo "       SHA-1 is $(KN5000_V8_SHA1), e.g. make KN5000_V8_REF=/path/kn5000_v8_program.rom"; \
	  exit 1; fi
	@got=$$(sha1sum < "$(KN5000_V8_REF)" | cut -d' ' -f1); \
	 if [ "$$got" != "$(KN5000_V8_SHA1)" ]; then \
	  echo "ERROR: $(KN5000_V8_REF) has SHA-1 $$got, expected $(KN5000_V8_SHA1)"; exit 1; fi
	cp "$(KN5000_V8_REF)" $@.tmp
	mv $@.tmp $@

# Re-checks the copy already in original_ROMs/ (it may predate a change of source).
verify-v8-reference: original_ROMs/kn5000_v8_program.rom
	@got=$$(sha1sum < $< | cut -d' ' -f1); \
	 if [ "$$got" = "$(KN5000_V8_SHA1)" ]; then echo "OK    $< has SHA-1 $(KN5000_V8_SHA1)"; \
	 else echo "FAIL  $< has SHA-1 $$got, expected $(KN5000_V8_SHA1)"; exit 1; fi

rebuilt_ROMs/kn5000_v8_program.llvm.o: $(V9_SRC) $(V9_CC900_STAMPS) $(MAINCPU_KERNEL_SRC) $(V9_C_DATA_BINS) $(KN5000_IMAGE_BINS) $(INDEXED_IMAGE_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj --defsym FW_VERSION_BYTE=0x08 -I v9/maincpu -I wsa1/kernel -o $@ v9/maincpu/kn5000_v9_program.s

rebuilt_ROMs/kn5000_v8_program.llvm.elf: rebuilt_ROMs/kn5000_v8_program.llvm.o v9/maincpu/maincpu.ld
	$(LLVM_LLD) -T v9/maincpu/maincpu.ld -o $@ $<

rebuilt_ROMs/kn5000_v8_program.llvm.rom: rebuilt_ROMs/kn5000_v8_program.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- V7 Maincpu ---
# V7 bins are extracted from the v7 ROM, not compiled from C.
# Two-pass build: first pass uses v9 ELF for address fallback,
# second pass re-extracts using v7 ELF for correct transplant addresses.
# THE V7 ROM IS NOT AN INPUT TO ITS OWN RECONSTRUCTION.
# This used to run extract_v7_bins.py -- twice -- slicing original_ROMs/kn5000_v7_program.rom
# into the build's own inputs, so the byte-match gate could not fail for 979,096 B (46.69%).
# Verify with: python3 scripts/analysis/rom_provenance_poison.py v7   (must report 0)
# The bytes that have no source are COMMITTED now instead of re-sliced every build:
#   288 pure ROM slices (136,775 B) -> v7/maincpu/includes/romslices/
#   5,118 bytes where the committed C does not reproduce the ROM
#                                   -> v7/maincpu/includes/v7_c_divergence.json
v7-extract-bins: $(V7_C_DATA_BINS)
	python3 scripts/build/apply_v7_c_divergence.py

# the compiled bins before the json patches them (scripts/tools/port_symbolize_pointers.py relink --tree v7)
v7-c-bins-raw: $(V7_C_DATA_BINS)
v7-c-bins: v7-extract-bins

rebuilt_ROMs/kn5000_v7_program.llvm.o: $(V7_SRC) $(V7_CC900_STAMPS) $(MAINCPU_KERNEL_SRC) v7-extract-bins $(KN5000_IMAGE_BINS) $(INDEXED_IMAGE_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I v7/maincpu -I wsa1/kernel -o $@ v7/maincpu/kn5000_v7_program.s

rebuilt_ROMs/kn5000_v7_program.llvm.elf: rebuilt_ROMs/kn5000_v7_program.llvm.o v7/maincpu/maincpu.ld
	$(LLVM_LLD) -T v7/maincpu/maincpu.ld -o $@ $<

rebuilt_ROMs/kn5000_v7_program.llvm.rom: rebuilt_ROMs/kn5000_v7_program.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- Ported maincpu versions: v6 (from v7), v5 (from v6) ---
# v6/maincpu was generated from v7/maincpu by scripts/converters/port_maincpu_version.py
# (see v6/maincpu/README.md): v7's text where the v6 bytes match it, its operands rewritten
# where only an operand moved, and `.byte` rows marked TODO(port) where no v7 line maps.
# The C data sources are v7's; TREE_c_divergence.json patches the bins where v6 differs
# (scripts/build/apply_c_divergence.py).
# The reference images are NOT committed (new dumps stay out of the public repository, like
# v8's): each is copied, git-ignored, from the private romset and refused unless its SHA-1
# matches.  Override the source with make KN5000_V6_REF=/path/kn5000_v6_program.rom.
KN5000_V6_REF  ?= $(PROJECTS_ROOT)/technics_roms/roms/kn5000/kn5000_v6_program.rom
KN5000_V6_SHA1 := 51108e2d75b180a034395e90bd40ca2bd2a0adfb
KN5000_V5_REF  ?= $(PROJECTS_ROOT)/technics_roms/roms/kn5000/kn5000_v5_program.rom
KN5000_V5_SHA1 := 7b69a8aaa84ee3d337acc0c29c34154c5da2df32

# $(1) = tree (v6), $(2) = upper-case prefix (V6)
define PORTED_MAINCPU
$(2)_SRC = $$(wildcard $(1)/maincpu/*.s $(1)/maincpu/*/*.s $(1)/maincpu/*/*/*.s)
$(2)_GEN = $(1)/maincpu/includes/generated
$(2)_C_DATA_BINS = $$(patsubst %,$$($(2)_GEN)/style_ui_paramblock_%.bin,$$(PARAMBLOCK_NAMES)) \
	$$($(2)_GEN)/voice_factory_presets.bin $$($(2)_GEN)/tonegen_param_table.bin \
	$$(patsubst v10/%,$(1)/%,$$(SOUND_DATA_BINS)) \
	$$(patsubst %,$$($(2)_GEN)/style_ui_screendata_%.bin,$$(SCREENDATA_NAMES)) \
	$$(patsubst %,$$($(2)_GEN)/%.bin,$$(ACCOMP_NAMES)) $$(patsubst %,$$($(2)_GEN)/%.bin,$$(SE_NAMES)) \
	$$(patsubst v10/%,$(1)/%,$$(NAKA_BINS)) $$($(2)_GEN)/sepaout_config.bin \
	$$($(2)_GEN)/gui_display_struct_data.bin $$($(2)_GEN)/tonekit_param_blocks.bin \
	$$($(2)_GEN)/sound_config_lookup.bin $$($(2)_GEN)/msp_factory_defaults.bin

$$($(2)_GEN)/style_ui_paramblock_%.bin: $(1)/maincpu/style_ui/paramblock/%.c $(1)/maincpu/style_ui/screendata_types.h
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I $(1)/maincpu/style_ui -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

$$($(2)_GEN)/style_ui_screendata_ctlonly.bin: $(1)/maincpu/style_ui/ctlonly.c $(1)/maincpu/style_ui/screendata_types.h $(1)/maincpu/style_ui/ctlonly_link.ld
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I $(1)/maincpu/style_ui -o $$@.o $$<
	$$(LLVM_LLD) -T $(1)/maincpu/style_ui/ctlonly_link.ld -o $$@.elf $$@.o
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.elf $$@
	@rm -f $$@.o $$@.elf

$$($(2)_GEN)/style_ui_screendata_%.bin: $(1)/maincpu/style_ui/%.c $(1)/maincpu/style_ui/screendata_types.h
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I $(1)/maincpu/style_ui -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

$$($(2)_GEN)/se_%.bin: $(1)/maincpu/audio/sound_editor_screens/se_%.c $(1)/maincpu/style_ui/screendata_types.h $(1)/maincpu/audio/sound_editor_screens/se_screens_link.ld
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I $(1)/maincpu/style_ui -o $$@.o $$<
	$$(LLVM_LLD) -T $(1)/maincpu/audio/sound_editor_screens/se_screens_link.ld -o $$@.elf $$@.o
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.elf $$@
	@rm -f $$@.o $$@.elf

$$($(2)_GEN)/accomp_%.bin: $(1)/maincpu/sequencer/accomp_screens/accomp_%.c $(1)/maincpu/style_ui/screendata_types.h $(1)/maincpu/sequencer/accomp_screens/accomp_screens_link.ld
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I $(1)/maincpu/style_ui -o $$@.o $$<
	$$(LLVM_LLD) -T $(1)/maincpu/sequencer/accomp_screens/accomp_screens_link.ld -o $$@.elf $$@.o
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.elf $$@
	@rm -f $$@.o $$@.elf

$$($(2)_GEN)/naka_%.bin: $(1)/maincpu/ui_widgets/naka_%.c $(1)/maincpu/ui_widgets/naka_types.h $(1)/maincpu/ui_widgets/naka_classes.h $(1)/maincpu/ui_widgets/naka_ids.h $(1)/maincpu/ui_widgets/naka_ram_cells.h $(1)/maincpu/ui_widgets/naka_%_link.ld
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I $(1)/maincpu/ui_widgets -o $$@.o $$<
	$$(LLVM_LLD) -T $(1)/maincpu/ui_widgets/naka_$$*_link.ld -o $$@.elf $$@.o
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.elf $$@
	@rm -f $$@.o $$@.elf

$$($(2)_GEN)/naka_control_menu_header.bin: $(1)/maincpu/ui_widgets/control_menu_header.c $(1)/maincpu/ui_widgets/naka_types.h $(1)/maincpu/ui_widgets/naka_classes.h $(1)/maincpu/ui_widgets/naka_ids.h $(1)/maincpu/ui_widgets/naka_ram_cells.h $(1)/maincpu/ui_widgets/naka_ctrl_menu_link.ld
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -I $(1)/maincpu/ui_widgets -o $$@.o $$<
	$$(LLVM_LLD) -T $(1)/maincpu/ui_widgets/naka_ctrl_menu_link.ld -o $$@.elf $$@.o
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.elf $$@
	@rm -f $$@.o $$@.elf

$$($(2)_GEN)/msp_factory_defaults.bin: $(1)/maincpu/msp_factory_defaults.c
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

$$($(2)_GEN)/voice_factory_presets.bin: $(1)/maincpu/audio/voice_factory_presets.c
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

$$($(2)_GEN)/tonegen_param_table.bin: $(1)/maincpu/audio/tonegen_param_table.c
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

$$($(2)_GEN)/sound_data_%.bin: $(1)/maincpu/audio/sound_data_%.c
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

$$($(2)_GEN)/sepaout_config.bin: $(1)/maincpu/ui/sepaout_config.c $(1)/maincpu/ui/sepaout_config_link.ld
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $$@.o $$<
	$$(LLVM_LLD) -T $(1)/maincpu/ui/sepaout_config_link.ld -o $$@.elf $$@.o
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.elf $$@
	@rm -f $$@.o $$@.elf

$$($(2)_GEN)/gui_display_struct_data.bin: $(1)/maincpu/includes/gui_display_struct_data.c
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

$$($(2)_GEN)/tonekit_param_blocks.bin: $(1)/maincpu/ui_widgets/tonekit_param_blocks.c
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

$$($(2)_GEN)/sound_config_lookup.bin: $(1)/maincpu/ui_widgets/sound_config_lookup.c
	@mkdir -p $$($(2)_GEN)
	$$(CLANG) -target tlcs900 -ffreestanding -c -O2 -o $$@.o $$<
	$$(LLVM_OBJCOPY) -O binary -j .text $$@.o $$@
	@rm -f $$@.o

original_ROMs/kn5000_$(1)_program.rom:
	@if [ ! -f "$$(KN5000_$(2)_REF)" ]; then \
	  echo "ERROR: the KN5000 $(1) reference image is missing: $$(KN5000_$(2)_REF)"; \
	  echo "       It is not in git (new dumps come from the private romset). Point KN5000_$(2)_REF at a copy whose"; \
	  echo "       SHA-1 is $$(KN5000_$(2)_SHA1), e.g. make KN5000_$(2)_REF=/path/kn5000_$(1)_program.rom"; \
	  exit 1; fi
	@got=$$$$(sha1sum < "$$(KN5000_$(2)_REF)" | cut -d' ' -f1); \
	 if [ "$$$$got" != "$$(KN5000_$(2)_SHA1)" ]; then \
	  echo "ERROR: $$(KN5000_$(2)_REF) has SHA-1 $$$$got, expected $$(KN5000_$(2)_SHA1)"; exit 1; fi
	cp "$$(KN5000_$(2)_REF)" $$@.tmp
	mv $$@.tmp $$@

verify-$(1)-reference: original_ROMs/kn5000_$(1)_program.rom
	@got=$$$$(sha1sum < $$< | cut -d' ' -f1); \
	 if [ "$$$$got" = "$$(KN5000_$(2)_SHA1)" ]; then echo "OK    $$< has SHA-1 $$(KN5000_$(2)_SHA1)"; \
	 else echo "FAIL  $$< has SHA-1 $$$$got, expected $$(KN5000_$(2)_SHA1)"; exit 1; fi

$(1)-c-bins-raw: $$($(2)_C_DATA_BINS)

$(1)-c-bins: $(1)-c-bins-raw
	python3 scripts/build/apply_c_divergence.py $(1)

rebuilt_ROMs/kn5000_$(1)_program.llvm.o: $$($(2)_SRC) $$($(2)_CC900_STAMPS) $(1)-c-bins $$(KN5000_IMAGE_BINS) $$(wildcard $(1)/maincpu/images/*.png) $$(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$$(LLVM_MC) -triple=tlcs900 -filetype=obj -I $(1)/maincpu -o $$@ $(1)/maincpu/kn5000_$(1)_program.s

rebuilt_ROMs/kn5000_$(1)_program.llvm.elf: rebuilt_ROMs/kn5000_$(1)_program.llvm.o $(1)/maincpu/maincpu.ld
	$$(LLVM_LLD) -T $(1)/maincpu/maincpu.ld -o $$@ $$<

rebuilt_ROMs/kn5000_$(1)_program.llvm.rom: rebuilt_ROMs/kn5000_$(1)_program.llvm.elf
	$$(LLVM_OBJCOPY) -O binary $$< $$@

# Not in `make gate` until byte-identical: prints how much of the image matches.
$(1)-progress: rebuilt_ROMs/kn5000_$(1)_program.llvm.rom original_ROMs/kn5000_$(1)_program.rom
	@python3 -c "import sys; a, b = (open(f, 'rb').read() for f in sys.argv[1:3]); n = sum(x == y for x, y in zip(a, b)); print('$(1): %d of %d bytes match (%.2f%%)%s' % (n, len(b), 100.0 * n / len(b), '' if len(a) == len(b) else ', size %d' % len(a)))" rebuilt_ROMs/kn5000_$(1)_program.llvm.rom original_ROMs/kn5000_$(1)_program.rom
endef

$(eval $(call PORTED_MAINCPU,v6,V6))
$(eval $(call PORTED_MAINCPU,v5,V5))
$(eval $(call CC900_FIRMWARE_C,v6,V6_SRC))
$(eval $(call CC900_FIRMWARE_C,v5,V5_SRC))
# v6-c-bins (and v5-c-bins) is deliberately not .PHONY: like v7-extract-bins it is an intermediate with no file, so
# `make -q` (assert_byte_identical.py's staleness check) does not call the ROM out of date.
.PHONY: v6-progress verify-v6-reference v5-progress verify-v5-reference

# --- Subcpu payload ---
rebuilt_ROMs/kn5000_subprogram_v142.llvm.o: $(V142_SRC) $(SUBCPU_KERNEL_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I v142/subcpu -I wsa1/kernel -o $@ v142/subcpu/kn5000_subprogram_v142.s

rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf: rebuilt_ROMs/kn5000_subprogram_v142.llvm.o v142/subcpu/subcpu.ld
	$(LLVM_LLD) -T v142/subcpu/subcpu.ld -o $@ $<

rebuilt_ROMs/kn5000_subprogram_v142.llvm.rom: rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@.full
	dd if=$@.full of=$@.part_a bs=1 count=256 2>/dev/null || exit 1
	dd if=$@.full of=$@.part_b bs=1 skip=60416 2>/dev/null || exit 1
	sync
	cat $@.part_a $@.part_b > $@
	rm -f $@.full $@.part_a $@.part_b

# --- Subcpu payload firmware-update image (whole-file SLIDE4K) ---
# original_ROMs/kn5000_subprogram_v142_compressed.rom is the v1.42 Sub-CPU
# payload as shipped on firmware-update disks ("Program DATA FILE PCK" /
# File Type 007, flashed to Custom Data 0x3E0000 by
# HANDLE_UPDATE_FILE_TYPE_ID_007h): an 11-byte header ("SLIDE4K\0" magic +
# 24-bit BIG-endian decompressed size, here 03 00 00 = 196,608) followed by
# the LZSS stream. The payload is already source-built, and compress_lzss.py
# encodes it with the factory SLIDE4K encoder (lzss_j.encode, N = 4096, F = 18;
# no reference is read), which must reproduce the update image byte-for-byte:
# the cmp seals whole-file byte-identity.
rebuilt_ROMs/kn5000_subprogram_v142_compressed.rom: rebuilt_ROMs/kn5000_subprogram_v142.llvm.rom original_ROMs/kn5000_subprogram_v142_compressed.rom scripts/build/compress_lzss.py floppy/tools/kd/lzss_j.py
	python3 scripts/build/compress_lzss.py $< $@ --with-header
	cmp $@ original_ROMs/kn5000_subprogram_v142_compressed.rom
	@echo "  subprogram v142 update image OK (byte-identical)"

# --- Subcpu payload v1.41 ---
# Ported from the v1.42 tree (scripts/generators/create_v141_subcpu_source.py records
# the semantic delta; notes/v141-subcpu-port/README.md says how it was measured).
# Same layout as v142: image = [0x400..0x4FF] + [0xF000..0x3EEFF].
rebuilt_ROMs/kn5000_subprogram_v141.llvm.o: $(V141_SRC) $(SUBCPU_KERNEL_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I v141/subcpu -I wsa1/kernel -o $@ v141/subcpu/kn5000_subprogram_v141.s

rebuilt_ROMs/kn5000_subprogram_v141.llvm.elf: rebuilt_ROMs/kn5000_subprogram_v141.llvm.o v141/subcpu/subcpu.ld
	$(LLVM_LLD) -T v141/subcpu/subcpu.ld -o $@ $<

rebuilt_ROMs/kn5000_subprogram_v141.llvm.rom: rebuilt_ROMs/kn5000_subprogram_v141.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@.full
	dd if=$@.full of=$@.part_a bs=1 count=256 2>/dev/null || exit 1
	dd if=$@.full of=$@.part_b bs=1 skip=60416 2>/dev/null || exit 1
	sync
	cat $@.part_a $@.part_b > $@
	rm -f $@.full $@.part_a $@.part_b

# --- Subcpu payload v1.41 firmware-update image (whole-file SLIDE4K) ---
# Same guarantee as the v142 rule above: encoding the source-built v1.41
# payload with the factory encoder must reproduce
# original_ROMs/kn5000_subprogram_v141_compressed.rom (93,181 B) byte-for-byte.
rebuilt_ROMs/kn5000_subprogram_v141_compressed.rom: rebuilt_ROMs/kn5000_subprogram_v141.llvm.rom original_ROMs/kn5000_subprogram_v141_compressed.rom scripts/build/compress_lzss.py floppy/tools/kd/lzss_j.py
	python3 scripts/build/compress_lzss.py $< $@ --with-header
	cmp $@ original_ROMs/kn5000_subprogram_v141_compressed.rom
	@echo "  subprogram v141 update image OK (byte-identical)"

# --- Subcpu payload v1.40 ---
# Ported from the v1.41 tree (scripts/generators/create_v140_subcpu_source.py records
# the semantic delta; notes/v140-subcpu-port/README.md says what the code change does).
# Same layout as v142: image = [0x400..0x4FF] + [0xF000..0x3EEFF].
rebuilt_ROMs/kn5000_subprogram_v140.llvm.o: $(V140_SRC) $(SUBCPU_KERNEL_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I v140/subcpu -I wsa1/kernel -o $@ v140/subcpu/kn5000_subprogram_v140.s

rebuilt_ROMs/kn5000_subprogram_v140.llvm.elf: rebuilt_ROMs/kn5000_subprogram_v140.llvm.o v140/subcpu/subcpu.ld
	$(LLVM_LLD) -T v140/subcpu/subcpu.ld -o $@ $<

rebuilt_ROMs/kn5000_subprogram_v140.llvm.rom: rebuilt_ROMs/kn5000_subprogram_v140.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@.full
	dd if=$@.full of=$@.part_a bs=1 count=256 2>/dev/null || exit 1
	dd if=$@.full of=$@.part_b bs=1 skip=60416 2>/dev/null || exit 1
	sync
	cat $@.part_a $@.part_b > $@
	rm -f $@.full $@.part_a $@.part_b

# --- Subcpu payload v1.40 firmware-update image (whole-file SLIDE4K) ---
# Same guarantee as the v142 rule above: encoding the source-built v1.40
# payload with the factory encoder must reproduce
# original_ROMs/kn5000_subprogram_v140_compressed.rom (93,124 B) byte-for-byte.
rebuilt_ROMs/kn5000_subprogram_v140_compressed.rom: rebuilt_ROMs/kn5000_subprogram_v140.llvm.rom original_ROMs/kn5000_subprogram_v140_compressed.rom scripts/build/compress_lzss.py floppy/tools/kd/lzss_j.py
	python3 scripts/build/compress_lzss.py $< $@ --with-header
	cmp $@ original_ROMs/kn5000_subprogram_v140_compressed.rom
	@echo "  subprogram v140 update image OK (byte-identical)"

# --- Subcpu boot ---
rebuilt_ROMs/kn5000_subcpu_boot.llvm.o: $(SUBBOOT_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I subcpu/boot -o $@ subcpu/boot/kn5000_subcpu_boot.s

rebuilt_ROMs/kn5000_subcpu_boot.llvm.elf: rebuilt_ROMs/kn5000_subcpu_boot.llvm.o subcpu/boot/subcpu_boot.ld
	$(LLVM_LLD) -T subcpu/boot/subcpu_boot.ld -o $@ $<

rebuilt_ROMs/kn5000_subcpu_boot.llvm.rom: rebuilt_ROMs/kn5000_subcpu_boot.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- HDAE5000 ---
# The board's graphics are built FROM the committed PNGs and palette text files, not
# incbin'd out of a ROM slice. scripts/build/hdae5000_images.py verify asserts the round
# trip is byte-exact, so the readable form is the source rather than a view of a blob.
# ⚠ THE .bin FILES MUST BE REAL PREREQUISITES, NOT A BARE `style-events`.
# This rule used to be `style-events:` with no output files, and the .o rules named
# `style-events` as a prerequisite.  That does NOT force a rebuild in this Makefile:
# `.SECONDARY:` is declared with no prerequisites, which marks every target
# intermediate, and make then reports
#     Prerequisite 'style-events' of target '...custom_data.llvm.o' does not exist.
#     No need to remake target '...custom_data.llvm.o'.
# MEASURED 2026-09-02: with one NOTE pitch changed in custom_data/styles/section_0.styles
# -- a change that really does move ROM byte 0x1409 -- `make gate` printed
# `kn5000_custom_data IDENTICAL` and exited 0, on an already-built tree.  It only went
# red after `touch custom_data/kn5000_custom_data.s` forced the object.  The style
# listings are the committed SOURCE of the accompaniment styles, so the gate was not
# certifying them at all.
# Naming the outputs fixes it and keeps the build incremental.
# ⚠ The same shape is still present for `indexed-images`, `tabledata-images` and
# `hdae5000-images`, which are also output-less and also named as prerequisites. They
# belong to other lanes' files and are left alone here; see
# notes/sound/FINDINGS-audio-and-music-ranges-2026-09-02.md section 10.
STYLE_EVENT_BINS = custom_data/includes/section_0.bin \
                   custom_data/includes/section_1_2.bin \
                   custom_data/includes/section_3_4.bin \
                   custom_data/includes/section_5_6.bin \
                   table_data/includes/generated/Composer_FactoryMemoryImage.bin
STYLE_EVENT_SRC = $(wildcard custom_data/styles/*.styles)

# `&:` is a GROUPED target (GNU make >= 4.3): one recipe produces all five, so the
# script runs once rather than once per output.
$(STYLE_EVENT_BINS) &: $(STYLE_EVENT_SRC) scripts/build/style_events.py scripts/build/style_bank_layout.py
	python3 scripts/build/style_events.py build

style-events: $(STYLE_EVENT_BINS)

# The 240 factory accompaniment styles as Standard MIDI Files, one per directory
# record. DERIVED AND PLAYABLE, NOT A BUILD INPUT: `custom_data/styles/*.styles` is
# what the ROM is built from and it holds what MIDI cannot (cell allocation and link
# topology, the PAD bytes after 0x83, explicit-vs-running status). Deliberately NOT a
# prerequisite of any ROM target, so a change here can never move a ROM byte.
style-midi:
	python3 scripts/build/style_to_midi.py build

verify-style-midi:
	python3 scripts/build/style_to_midi.py verify

# ⚠ THE PNG SOURCES MUST BE REAL PREREQUISITES OF THE OBJECTS.
# `indexed-images`, `hdae5000-images` and `tabledata-images` produce many .bin
# files under generated/ and name none of them, exactly like `style-events` did.
# `.SECONDARY:` is declared with no prerequisites, so every target is
# intermediate and make reports "does not exist / no need to remake" for a bare
# rule name -- MEASURED 2026-09-02 on style-events, where a one-note edit that
# really moved ROM byte 0x1409 printed IDENTICAL and exited 0.
# Enumerating every generated .bin here would be brittle, so instead the OBJECTS
# depend on the PNG and palette SOURCES: touch a committed image and the object
# is out of date, the phony rule regenerates the .bin, and the gate can see it.
INDEXED_IMAGE_SRC  := $(shell find v10/maincpu/images -name '*.png' 2>/dev/null)
TABLEDATA_IMAGE_SRC:= $(shell find table_data/images  -name '*.png' 2>/dev/null)
HDAE_IMAGE_SRC     := $(shell find hdae5000/images    -name '*.png' 2>/dev/null)

# The KN5000 pictures that the assembly `.incbin`s as raw bytes (KN5000_IMAGE_BINS, defined at the top
# of this file because the objects above name it): each .bin is written beside its committed PNG by
# indexed_images.py, mono_images.py or se_bitmaps.py, and is a git-ignored build product (lane
# media-build, 2026-10-31).  These are real targets: a changed PNG, a changed converter or a deleted
# .bin rebuilds them.
$(KN5000_IMAGE_BINS) &: $(KN5000_IMAGE_BINS:.bin=.png) $(KN5000_IMAGE_CONVERTERS)
	python3 scripts/build/indexed_images.py build
	python3 scripts/build/mono_images.py build
	python3 scripts/build/se_bitmaps.py build
	@touch $(KN5000_IMAGE_BINS)
indexed-images: $(KN5000_IMAGE_BINS)

# The pictures the NAKA GUI C holds as initializers come from <tree>/maincpu/images/*.png.  The C
# holds no pixels: each initializer is `#include "../includes/generated/pictures/<name>.inc"`, and
# scripts/build/c_bitmaps.py writes those git-ignored .inc files from the PNGs before clang compiles
# the C (lane media-files 2026-10-30; the .inc form, lane media-build 2026-10-31).  One stamp per
# revision, inside the generated directory, so deleting it rebuilds them.
C_BITMAP_TREES := v10 v9 v7 v6 v5
define C_BITMAP_RULES
$(1)/maincpu/includes/generated/pictures/.stamp: $$(wildcard $(1)/maincpu/images/*.png) v10/maincpu/images/Palette_8bit_RGBA.bin scripts/build/c_bitmaps.py
	python3 scripts/build/c_bitmaps.py build $(1)
	@touch $$@
$$(addprefix $(1)/maincpu/includes/generated/,naka_technichord_strings.bin naka_style_bitmaps.bin \
	naka_widget_tables_2.bin naka_widget_descriptors.bin naka_disk_warning.bin): $(1)/maincpu/includes/generated/pictures/.stamp
endef
$(foreach t,$(C_BITMAP_TREES),$(eval $(call C_BITMAP_RULES,$(t))))

# The HD-AE5000 pictures and palettes (hdae5000_images.py) and the table_data UI bitmaps, icons and fonts:
# real grouped outputs since lane media-build (2026-10-31), so a deleted one is rebuilt (`media`, below);
# `hdae5000-images` / `tabledata-images` stay as the names the objects use.
$(HDAE_IMAGE_BINS) &: $(wildcard hdae5000*/images/*.png hdae5000*/images/*.txt) hdae5000/images/row_padding.json \
		scripts/build/hdae5000_images.py
	python3 scripts/build/hdae5000_images.py build
	@touch $(HDAE_IMAGE_BINS)
# HDAE5000_Bitmap_Button01 comes from its PNG through indexed_images.py (lane media-files)
hdae5000-images: $(HDAE_IMAGE_BINS) $(KN5000_IMAGE_BINS)

$(TABLEDATA_IMAGE_BINS) &: $(wildcard table_data/images/ui_bitmaps/*.png table_data/images/icons_png/*.png \
		table_data/images/fonts/*.png) table_data/images/ui_bitmaps_manifest.json table_data/images/ui_bitmaps_padding.json \
		table_data/fonts.s v10/maincpu/images/Palette_8bit_RGBA.bin \
		scripts/build/ui_bitmaps_images.py scripts/build/icon_images.py scripts/build/font_images.py
	python3 scripts/build/ui_bitmaps_images.py build
	python3 scripts/build/icon_images.py build
	python3 scripts/build/font_images.py build
	@touch $(TABLEDATA_IMAGE_BINS)
# The wallpapers are built from their committed PNGs the same way; see
# scripts/build/indexed_images.py, whose `verify` asserts the round trip.
tabledata-images: $(TABLEDATA_IMAGE_BINS) $(KN5000_IMAGE_BINS)

rebuilt_ROMs/hd-ae5000_v2_06i.llvm.o: $(HDAE_SRC) hdae5000-images $(HDAE_IMAGE_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I hdae5000 -o $@ hdae5000/hd-ae5000_v2_06i.s

rebuilt_ROMs/hd-ae5000_v2_06i.llvm.elf: rebuilt_ROMs/hd-ae5000_v2_06i.llvm.o hdae5000/hdae5000.ld
	$(LLVM_LLD) -T hdae5000/hdae5000.ld -o $@ $<

rebuilt_ROMs/hd-ae5000_v2_06i.llvm.rom: rebuilt_ROMs/hd-ae5000_v2_06i.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- HDAE5000 v2.01i ---
# Its own tree, hdae5000_v2_01i/, ported from hdae5000/ (v2.06i) by
# scripts/tools/port_hdae5000_version.py and then edited by hand;
# notes/hdae5000-versions-2026-10-24/README.md says what differs.  What it does
# not hold itself -- shared/event_codes.s and the pictures that did not change --
# it takes from hdae5000/ through the second -I, so the order of the two -I
# matters.  Its one changed picture (the file-selection backdrop) is built from
# hdae5000_v2_01i/images/ by the same hdae5000-images step.
#
# The reference image is not committed (the v8 convention, above): it is copied,
# git-ignored, from the private romset, and refused unless its SHA-1 is
# HDAE5000_V201_SHA1.  Override the source with
#   make HDAE5000_V201_REF=/path/to/hd-ae5000_v2_01i.ic4 ...
HDAE_V201_SRC       = $(wildcard hdae5000_v2_01i/*.s)
HDAE_V201_IMAGE_SRC := $(shell find hdae5000_v2_01i/images -name '*.png' -o -name '*.txt' 2>/dev/null)
HDAE5000_V201_REF  ?= $(PROJECTS_ROOT)/technics_roms/roms/kn5000/hd-ae5000_v2_01i.ic4
HDAE5000_V201_SHA1 := 0160c17baa7b026771872126d8146038a19ef53b

original_ROMs/hd-ae5000_v2_01i.ic4:
	@if [ ! -f "$(HDAE5000_V201_REF)" ]; then \
	  echo "ERROR: the HD-AE5000 v2.01i reference image is missing: $(HDAE5000_V201_REF)"; \
	  echo "       It is not in git (new dumps come from the private romset). Point HDAE5000_V201_REF at a copy"; \
	  echo "       whose SHA-1 is $(HDAE5000_V201_SHA1), e.g. make HDAE5000_V201_REF=/path/hd-ae5000_v2_01i.ic4"; \
	  exit 1; fi
	@got=$$(sha1sum < "$(HDAE5000_V201_REF)" | cut -d' ' -f1); \
	 if [ "$$got" != "$(HDAE5000_V201_SHA1)" ]; then \
	  echo "ERROR: $(HDAE5000_V201_REF) has SHA-1 $$got, expected $(HDAE5000_V201_SHA1)"; exit 1; fi
	cp "$(HDAE5000_V201_REF)" $@.tmp
	mv $@.tmp $@

# Re-checks the copy already in original_ROMs/ (it may predate a change of source).
verify-hdae5000-v201-reference: original_ROMs/hd-ae5000_v2_01i.ic4
	@got=$$(sha1sum < $< | cut -d' ' -f1); \
	 if [ "$$got" = "$(HDAE5000_V201_SHA1)" ]; then echo "OK    $< has SHA-1 $(HDAE5000_V201_SHA1)"; \
	 else echo "FAIL  $< has SHA-1 $$got, expected $(HDAE5000_V201_SHA1)"; exit 1; fi

rebuilt_ROMs/hd-ae5000_v2_01i.llvm.o: $(HDAE_V201_SRC) $(HDAE_SRC) hdae5000-images $(HDAE_IMAGE_SRC) $(HDAE_V201_IMAGE_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I hdae5000_v2_01i -I hdae5000 -o $@ hdae5000_v2_01i/hd-ae5000_v2_01i.s

rebuilt_ROMs/hd-ae5000_v2_01i.llvm.elf: rebuilt_ROMs/hd-ae5000_v2_01i.llvm.o hdae5000_v2_01i/hdae5000.ld
	$(LLVM_LLD) -T hdae5000_v2_01i/hdae5000.ld -o $@ $<

rebuilt_ROMs/hd-ae5000_v2_01i.llvm.rom: rebuilt_ROMs/hd-ae5000_v2_01i.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- HDAE5000 v1.15i and v1.10i ---
# Their reference images, copied git-ignored from the private romset and refused unless
# the SHA-1 matches (the v2.01i convention, above).  hd-ae5000.ic4 in the romset is the
# same bytes as v1.15i.  notes/hdae5000-versions-2026-10-24/README.md describes the trees.
#   make HDAE5000_V115_REF=/path/hd-ae5000_v1_15i.ic4 HDAE5000_V110_REF=/path/hd-ae5000_v1_10i.ic4
HDAE5000_V115_REF  ?= $(PROJECTS_ROOT)/technics_roms/roms/kn5000/hd-ae5000_v1_15i.ic4
HDAE5000_V115_SHA1 := 581fa58e2cd6fe381cfc312c73771d25ff2e662c
HDAE5000_V110_REF  ?= $(PROJECTS_ROOT)/technics_roms/roms/kn5000/hd-ae5000_v1_10i.ic4
HDAE5000_V110_SHA1 := 6019f3c28b6277730418974dde4dc6893fced00e

# $(1) = v1_15i / v1_10i, $(2) = the REF variable, $(3) = the SHA-1 variable
define HDAE_V1_REFERENCE
original_ROMs/hd-ae5000_$(1).ic4:
	@if [ ! -f "$$($(2))" ]; then \
	  echo "ERROR: the HD-AE5000 $(1) reference image is missing: $$($(2))"; \
	  echo "       It is not in git (new dumps come from the private romset). Point $(2) at a copy"; \
	  echo "       whose SHA-1 is $$($(3)), e.g. make $(2)=/path/hd-ae5000_$(1).ic4"; \
	  exit 1; fi
	@got=$$$$(sha1sum < "$$($(2))" | cut -d' ' -f1); \
	 if [ "$$$$got" != "$$($(3))" ]; then \
	  echo "ERROR: $$($(2)) has SHA-1 $$$$got, expected $$($(3))"; exit 1; fi
	cp "$$($(2))" $$@.tmp
	mv $$@.tmp $$@

verify-hdae5000-$(subst _,,$(1))-reference: original_ROMs/hd-ae5000_$(1).ic4
	@got=$$$$(sha1sum < $$< | cut -d' ' -f1); \
	 if [ "$$$$got" = "$$($(3))" ]; then echo "OK    $$< has SHA-1 $$($(3))"; \
	 else echo "FAIL  $$< has SHA-1 $$$$got, expected $$($(3))"; exit 1; fi
endef
$(eval $(call HDAE_V1_REFERENCE,v1_15i,HDAE5000_V115_REF,HDAE5000_V115_SHA1))
$(eval $(call HDAE_V1_REFERENCE,v1_10i,HDAE5000_V110_REF,HDAE5000_V110_SHA1))
.PHONY: verify-hdae5000-v115i-reference verify-hdae5000-v110i-reference

# The v1.15i tree, hdae5000_v1_15i/, ported from hdae5000_v2_01i/ by
# notes/hdae5000-versions-2026-10-24/port-edits-v1_15i/replay.sh.  Its own shared/event_codes.s
# (v1.x numbers the HD-AE5000's messages differently) shadows hdae5000/'s; the rest of shared/
# and the unchanged pictures come from hdae5000/ through the second -I.  Its boot splash is
# built from hdae5000_v1_15i/images/ by the hdae5000-images step.
HDAE_V115_SRC       = $(wildcard hdae5000_v1_15i/*.s hdae5000_v1_15i/shared/*.s)
HDAE_V115_IMAGE_SRC := $(shell find hdae5000_v1_15i/images -name '*.png' -o -name '*.txt' 2>/dev/null)

rebuilt_ROMs/hd-ae5000_v1_15i.llvm.o: $(HDAE_V115_SRC) $(HDAE_SRC) hdae5000-images $(HDAE_IMAGE_SRC) $(HDAE_V115_IMAGE_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I hdae5000_v1_15i -I hdae5000 -o $@ hdae5000_v1_15i/hd-ae5000_v1_15i.s

rebuilt_ROMs/hd-ae5000_v1_15i.llvm.elf: rebuilt_ROMs/hd-ae5000_v1_15i.llvm.o hdae5000_v1_15i/hdae5000.ld
	$(LLVM_LLD) -T hdae5000_v1_15i/hdae5000.ld -o $@ $<

rebuilt_ROMs/hd-ae5000_v1_15i.llvm.rom: rebuilt_ROMs/hd-ae5000_v1_15i.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# The v1.10i tree, hdae5000_v1_10i/, ported from hdae5000_v1_15i/ by
# notes/hdae5000-versions-2026-10-24/port-edits-v1_10i/replay.sh.  It takes v1.x's
# shared/event_codes.s and the boot splash from hdae5000_v1_15i/ (second -I), the rest from
# hdae5000/ (third -I).
HDAE_V110_SRC = $(wildcard hdae5000_v1_10i/*.s)

rebuilt_ROMs/hd-ae5000_v1_10i.llvm.o: $(HDAE_V110_SRC) $(HDAE_V115_SRC) $(HDAE_SRC) hdae5000-images $(HDAE_IMAGE_SRC) $(HDAE_V115_IMAGE_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I hdae5000_v1_10i -I hdae5000_v1_15i -I hdae5000 -o $@ hdae5000_v1_10i/hd-ae5000_v1_10i.s

rebuilt_ROMs/hd-ae5000_v1_10i.llvm.elf: rebuilt_ROMs/hd-ae5000_v1_10i.llvm.o hdae5000_v1_10i/hdae5000.ld
	$(LLVM_LLD) -T hdae5000_v1_10i/hdae5000.ld -o $@ $<

rebuilt_ROMs/hd-ae5000_v1_10i.llvm.rom: rebuilt_ROMs/hd-ae5000_v1_10i.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# The six Feature Demo BMPs (FTBMP01..06.BMP) are built from their committed PNGs
# plus the header fields in ftbmp_headers.json; scripts/build/ftbmp_images.py
# `verify` asserts the round trip against the built .BMP and the ROM.  The
# .BMP files are git-ignored build products (lane media-build, 2026-10-31), like
# Wallpaper_*.bin, named here as real outputs (not behind the output-less `tabledata-images`): an edited
# PNG makes them, and then the table_data object, out of date.  `build` touches an
# output whose bytes did not change, so a checkout's mtime order cannot make this
# rule rerun on every invocation.
FTBMP_BMPS = $(foreach n,1 2 3 4 5 6,table_data/images/FTBMP0$(n).BMP)
FTBMP_SRC  = $(FTBMP_BMPS:.BMP=.png) table_data/images/ftbmp_headers.json

$(FTBMP_BMPS) &: $(FTBMP_SRC) scripts/build/ftbmp_images.py
	python3 scripts/build/ftbmp_images.py build

verify-ftbmp:
	python3 scripts/build/ftbmp_images.py verify

# --- Table data ---
rebuilt_ROMs/kn5000_table_data.llvm.o: $(TABLEDATA_SRC) original_ROMs/kn5000_table_data.rom $(DEMO_PRESET_COMPRESSED) $(HELP_DB_COMPRESSED) $(STALE_HELP_DUPLICATE) tabledata-images $(TABLEDATA_IMAGE_SRC) $(INDEXED_IMAGE_SRC) $(STYLE_EVENT_BINS) $(FTBMP_BMPS) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I table_data -o $@ table_data/kn5000_table_data.s

rebuilt_ROMs/kn5000_table_data.llvm.elf: rebuilt_ROMs/kn5000_table_data.llvm.o table_data/table_data.ld
	$(LLVM_LLD) -T table_data/table_data.ld -o $@ $<

rebuilt_ROMs/kn5000_table_data.llvm.rom: rebuilt_ROMs/kn5000_table_data.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- Rhythm data ROM IC14 (rhythm_data/) ---
# The 4 MB style/pattern mask ROM the main CPU maps at 0x400000.  rhythm_data/ builds the
# DESCRAMBLED image; the chip read we hold has address lines A19 and A21 swapped, and
# verify-rhythm-data-raw proves that swapping them back in the rebuilt image gives that read byte
# for byte (scripts/build/rhythm_rom_address_swap.py).  Both references are git-ignored copies from
# the private romset, checked by SHA-1 like KN5000_V8_REF.  Notes:
# notes/rhythm-data-ic14-2026-10-29/README.md.
KN5000_RHYTHM_REF      ?= $(PROJECTS_ROOT)/technics_roms/roms/kn5000/kn5000_rhythm_data_rom.ic14
KN5000_RHYTHM_SHA1     := fef7f1927935d8fdada2afbdbfac29aac56e1c3c
KN5000_RHYTHM_RAW_REF  ?= $(PROJECTS_ROOT)/technics_roms/roms/kn5000/kn5000_rhythm_data_rom.ic14.as-read-a19a21-swapped
KN5000_RHYTHM_RAW_SHA1 := e4b572d318c9fe7ba00e5b44ea783e89da9c68bd
RHYTHMDATA_SRC = $(wildcard rhythm_data/*.s rhythm_data/*.inc rhythm_data/*/*.s)

original_ROMs/kn5000_rhythm_data_rom.ic14:
	@if [ ! -f "$(KN5000_RHYTHM_REF)" ]; then \
	  echo "ERROR: the KN5000 rhythm data ROM (IC14) reference is missing: $(KN5000_RHYTHM_REF)"; \
	  echo "       Point KN5000_RHYTHM_REF at the descrambled image, SHA-1 $(KN5000_RHYTHM_SHA1)"; exit 1; fi
	@got=$$(sha1sum < "$(KN5000_RHYTHM_REF)" | cut -d' ' -f1); \
	 if [ "$$got" != "$(KN5000_RHYTHM_SHA1)" ]; then \
	  echo "ERROR: $(KN5000_RHYTHM_REF) has SHA-1 $$got, expected $(KN5000_RHYTHM_SHA1)"; exit 1; fi
	cp "$(KN5000_RHYTHM_REF)" $@.tmp
	mv $@.tmp $@

original_ROMs/kn5000_rhythm_data_rom.ic14.as-read-a19a21-swapped:
	@if [ ! -f "$(KN5000_RHYTHM_RAW_REF)" ]; then \
	  echo "ERROR: the KN5000 rhythm data ROM (IC14) raw read is missing: $(KN5000_RHYTHM_RAW_REF)"; \
	  echo "       Point KN5000_RHYTHM_RAW_REF at it, SHA-1 $(KN5000_RHYTHM_RAW_SHA1)"; exit 1; fi
	@got=$$(sha1sum < "$(KN5000_RHYTHM_RAW_REF)" | cut -d' ' -f1); \
	 if [ "$$got" != "$(KN5000_RHYTHM_RAW_SHA1)" ]; then \
	  echo "ERROR: $(KN5000_RHYTHM_RAW_REF) has SHA-1 $$got, expected $(KN5000_RHYTHM_RAW_SHA1)"; exit 1; fi
	cp "$(KN5000_RHYTHM_RAW_REF)" $@.tmp
	mv $@.tmp $@

rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.o: $(RHYTHMDATA_SRC) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I rhythm_data -o $@ rhythm_data/kn5000_rhythm_data.s

rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.elf: rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.o rhythm_data/rhythm_data.ld
	$(LLVM_LLD) -T rhythm_data/rhythm_data.ld -o $@ $<

rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.rom: rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

llvm-all: original_ROMs/kn5000_rhythm_data_rom.ic14 rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.rom

.PHONY: verify-rhythm-data-raw
verify-rhythm-data-raw: rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.rom original_ROMs/kn5000_rhythm_data_rom.ic14.as-read-a19a21-swapped
	@got=$$(sha1sum < original_ROMs/kn5000_rhythm_data_rom.ic14 | cut -d' ' -f1); \
	 if [ "$$got" = "$(KN5000_RHYTHM_SHA1)" ]; then echo "OK    original_ROMs/kn5000_rhythm_data_rom.ic14 has SHA-1 $(KN5000_RHYTHM_SHA1)"; \
	 else echo "FAIL  original_ROMs/kn5000_rhythm_data_rom.ic14 has SHA-1 $$got, expected $(KN5000_RHYTHM_SHA1)"; exit 1; fi
	python3 scripts/build/rhythm_rom_address_swap.py --check rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.rom \
	  original_ROMs/kn5000_rhythm_data_rom.ic14.as-read-a19a21-swapped --sha1 $(KN5000_RHYTHM_RAW_SHA1)

gate: verify-rhythm-data-raw

# --- Custom data ---
rebuilt_ROMs/kn5000_custom_data.llvm.o: $(CUSTOMDATA_SRC) $(STYLE_EVENT_BINS) $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I custom_data -o $@ custom_data/kn5000_custom_data.s

rebuilt_ROMs/kn5000_custom_data.llvm.elf: rebuilt_ROMs/kn5000_custom_data.llvm.o custom_data/custom_data.ld
	$(LLVM_LLD) -T custom_data/custom_data.ld -o $@ $<

rebuilt_ROMs/kn5000_custom_data.llvm.rom: rebuilt_ROMs/kn5000_custom_data.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

# --- Waveform ROM IC307 (waveform/, lane kn5000-waveform 2026-10-29) ---
# The reference image is not committed (a private dump, kept out of this public
# repository like v8's).  `make` copies it, git-ignored, from the private romset
# and refuses a copy whose SHA-1 differs; override the source with
#   make KN5000_IC307_REF=/path/to/kn5000_waveform_rom.ic307 ...
# The directory, the parameter records, the alignment and the 0xFF tails are
# typed source.  Each PCM item is a WAV file in waveform/wav/, committed (the owner,
# 2026-10-31: "Images and wav files must be commited and the conversion must happen as
# a build step"); scripts/build/pcm_wav.py turns the WAVs into the raw items
# waveform/build/pcm/ (git-ignored) that the source `.incbin`s, and reads no reference
# image to do it.  The manifest waveform/wav_manifest.tsv says where each item is and
# how it is encoded.  The reference image is needed only for the byte compare and for
# the maintenance target `waveform-wav`.  Notes: notes/waveform-ic307-2026-10-29/
# README.md, notes/media-files-2026-10-30/README.md, notes/media-build-2026-10-31/README.md.
KN5000_IC307_REF  ?= $(PROJECTS_ROOT)/technics_romsets/kn5000/kn5000_waveform_rom.ic307
KN5000_IC307_SHA1 := 4b511bff6625f4655cabd96a263bf548d2ef4bf7
WAVEFORM_SRC = $(wildcard waveform/*.s waveform/*.inc)
IC307_WAV_MANIFEST := waveform/wav_manifest.tsv
# every WAV the manifest names (column 6), so a missing one stops make instead of being skipped
IC307_WAVS := $(addprefix waveform/wav/,$(shell tail -n +2 $(IC307_WAV_MANIFEST) | cut -f6))

waveform/build/pcm/.built: $(IC307_WAVS) $(IC307_WAV_MANIFEST) scripts/build/pcm_wav.py
	python3 scripts/build/pcm_wav.py build $(IC307_WAV_MANIFEST) waveform/wav waveform/build/pcm
	@touch $@

# MAINTENANCE, not a build step: write the WAVs that are missing from the reference image
# (an edited WAV is never overwritten).  The WAVs are committed; run this only to recover one.
waveform-wav: original_ROMs/kn5000_waveform_rom.ic307
	python3 scripts/build/pcm_wav.py extract --missing $(IC307_WAV_MANIFEST) $< waveform/wav

original_ROMs/kn5000_waveform_rom.ic307:
	@if [ ! -f "$(KN5000_IC307_REF)" ]; then \
	  echo "ERROR: the KN5000 waveform ROM IC307 reference image is missing: $(KN5000_IC307_REF)"; \
	  echo "       Point KN5000_IC307_REF at a copy whose SHA-1 is $(KN5000_IC307_SHA1)"; \
	  exit 1; fi
	@got=$$(sha1sum < "$(KN5000_IC307_REF)" | cut -d' ' -f1); \
	 if [ "$$got" != "$(KN5000_IC307_SHA1)" ]; then \
	  echo "ERROR: $(KN5000_IC307_REF) has SHA-1 $$got, expected $(KN5000_IC307_SHA1)"; exit 1; fi
	cp "$(KN5000_IC307_REF)" $@.tmp
	mv $@.tmp $@

verify-ic307-reference: original_ROMs/kn5000_waveform_rom.ic307
	@got=$$(sha1sum < $< | cut -d' ' -f1); \
	 if [ "$$got" = "$(KN5000_IC307_SHA1)" ]; then echo "OK    $< has SHA-1 $(KN5000_IC307_SHA1)"; \
	 else echo "FAIL  $< has SHA-1 $$got, expected $(KN5000_IC307_SHA1)"; exit 1; fi

rebuilt_ROMs/kn5000_waveform_ic307.llvm.o: $(WAVEFORM_SRC) waveform/build/pcm/.built $(LLVM_MC)
	mkdir -p rebuilt_ROMs
	$(LLVM_MC) -triple=tlcs900 -filetype=obj -I waveform -I waveform/build -o $@ waveform/kn5000_waveform_ic307.s

rebuilt_ROMs/kn5000_waveform_ic307.llvm.elf: rebuilt_ROMs/kn5000_waveform_ic307.llvm.o waveform/waveform.ld
	$(LLVM_LLD) -T waveform/waveform.ld -o $@ $<

rebuilt_ROMs/kn5000_waveform_ic307.llvm.rom: rebuilt_ROMs/kn5000_waveform_ic307.llvm.elf
	$(LLVM_OBJCOPY) -O binary $< $@

llvm-all: original_ROMs/kn5000_waveform_rom.ic307 rebuilt_ROMs/kn5000_waveform_ic307.llvm.rom

# Every KN5000 media conversion's output (lane media-build, 2026-10-31).  `all` names them so that a
# deleted one is made again: `.SECONDARY:` marks every target intermediate, and make does not remake a
# missing intermediate for an object that is otherwise up to date -- while assert_images_assemble.py,
# which assembles the sources directly, needs every file they `.incbin`.
.PHONY: media
media: $(KN5000_IMAGE_BINS) $(HDAE_IMAGE_BINS) $(TABLEDATA_IMAGE_BINS) $(FTBMP_BMPS) waveform/build/pcm/.built \
	$(foreach t,$(C_BITMAP_TREES),$(t)/maincpu/includes/generated/pictures/.stamp)
llvm-all: media
gate: verify-ic307-reference
clean: clean-waveform
clean-waveform:
	rm -f rebuilt_ROMs/kn5000_waveform_ic307.llvm.*
	rm -rf waveform/build
.PHONY: verify-ic307-reference clean-waveform waveform-wav

# ============================================================================
# LLVM conversion targets (regenerate .s from ASL sources)
# ============================================================================
# These targets convert the ARCHIVED ASL .asm sources to LLVM .s files and write
# them OVER the authoritative trees (v10/maincpu, v142/subcpu, subcpu/boot,
# hdae5000, table_data, custom_data).  archive/asl/ is the pre-rename snapshot
# taken when LLVM became authoritative (38e7d9f): running any of these would
# replace every semantic label, comment and C conversion made since with the old
# LABEL_* text.  They are kept only for archaeology and refuse to run unless
# ALLOW_ASL_RECONVERT=1 is given on the command line -- and then only inside a
# throw-away worktree.

.PHONY: llvm-convert-subcpu llvm-convert-boot llvm-convert-hdae5000 llvm-convert-tabledata llvm-convert-customdata
.PHONY: asl-reconvert-guard
asl-reconvert-guard:
ifneq ($(ALLOW_ASL_RECONVERT),1)
	@echo "REFUSED: llvm-convert* regenerates the authoritative .s trees from the archived," >&2
	@echo "pre-rename ASL sources in archive/asl/ and would overwrite all work done since the" >&2
	@echo "LLVM sources became authoritative.  The .s files are edited directly now." >&2
	@echo "If you really want the old conversion (archaeology, in a scratch worktree), run:" >&2
	@echo "    make ALLOW_ASL_RECONVERT=1 $(MAKECMDGOALS)" >&2
	@exit 1
endif

llvm-convert: asl-reconvert-guard scripts/converters/asl_to_llvm.py archive/asl/maincpu/kn5000_v10_program.asm archive/asl/tmp94c241.inc
	python scripts/converters/asl_to_llvm.py archive/asl/maincpu/kn5000_v10_program.asm --output-dir v10/maincpu

llvm-convert-subcpu: asl-reconvert-guard scripts/converters/asl_to_llvm.py archive/asl/subcpu/kn5000_subprogram_v142.asm archive/asl/tmp94c241.inc rebuilt_ROMs/kn5000_subprogram_v142.full
	python scripts/converters/asl_to_llvm.py archive/asl/subcpu/kn5000_subprogram_v142.asm --rom-base 0x0400 --rom-size 0x3EB00 --rom-file rebuilt_ROMs/kn5000_subprogram_v142.full --output-dir v142/subcpu

llvm-convert-boot: asl-reconvert-guard scripts/converters/asl_to_llvm.py archive/asl/subcpu/boot/kn5000_subcpu_boot.asm archive/asl/tmp94c241.inc
	python scripts/converters/asl_to_llvm.py archive/asl/subcpu/boot/kn5000_subcpu_boot.asm --rom-base 0xFE0000 --rom-size 0x20000 --rom-file original_ROMs/kn5000_subcpu_boot.ic30 --output-dir subcpu/boot

llvm-convert-hdae5000: asl-reconvert-guard scripts/converters/asl_to_llvm.py archive/asl/hdae5000/hd-ae5000_v2_06i.asm archive/asl/tmp94c241.inc
	python scripts/converters/asl_to_llvm.py archive/asl/hdae5000/hd-ae5000_v2_06i.asm --rom-base 0x280000 --rom-size 0x80000 --rom-file original_ROMs/hd-ae5000_v2_06i.ic4 --output-dir hdae5000

llvm-convert-tabledata: asl-reconvert-guard scripts/converters/asl_to_llvm.py archive/asl/table_data/kn5000_table_data.asm archive/asl/tmp94c241.inc
	python scripts/converters/asl_to_llvm.py archive/asl/table_data/kn5000_table_data.asm --rom-base 0x800000 --rom-size 0x200000 --rom-file original_ROMs/kn5000_table_data.rom --output-dir table_data

llvm-convert-customdata: asl-reconvert-guard scripts/converters/asl_to_llvm.py archive/asl/custom_data/kn5000_custom_data.asm archive/asl/tmp94c241.inc
	python scripts/converters/asl_to_llvm.py archive/asl/custom_data/kn5000_custom_data.asm --rom-base 0x300000 --rom-size 0x100000 --rom-file original_ROMs/kn5000_custom_data.ic19 --output-dir custom_data

llvm-convert-all: asl-reconvert-guard llvm-convert llvm-convert-subcpu llvm-convert-boot llvm-convert-hdae5000 llvm-convert-tabledata llvm-convert-customdata

# ============================================================================
# Legacy ASL build targets (archived sources)
# ============================================================================
ASL_PATH=../tools/asl
ASL=$(ASL_PATH)/asl -w
P2BIN=$(ASL_PATH)/p2bin

# ----------------------------------------------------------------------------
# Demo song presets (19 SLIDE4K-compressed blocks)
# ----------------------------------------------------------------------------
# Entries 0-17 live at 0x9C4050-0x9F94CA, entry 18 (the Feature Presentation) at
# 0x8E0000. Each block is an 8-byte "SLIDE4K\0" magic + a 24-bit BIG-ENDIAN
# uncompressed size, followed by the LZSS payload. (Endianness evidence: the
# v142 Sub-CPU update image's size field is 03 00 00 = 0x030000 = 196,608; the
# in-ROM demo blocks all have endian-symmetric size fields like 00 95 00.)
#
# CHECKED-IN SOURCE: midi/*.mid + sidecar/*.yaml
#   .mid   the musical content -- editable in any DAW
#   .yaml  everything MIDI cannot express: song header, cell topology, padding,
#          the exact stream order, running-status flags, and the few durations
#          MIDI cannot round-trip
#
#   .mid + .yaml -> demo_preset_NN.bin -> demo_preset_NN_compressed.bin -> ROM
#
# Both .bin stages are generated (and .gitignore'd).  compress_lzss.py encodes each
# stream with the factory SLIDE4K encoder (lzss_j.encode, Okumura's LZSS.C with
# N = 4096, F = 18: notes/misc2-2026-11-02/probes/slide4k_encode_exact.py shows it
# makes every factory stream byte); no reference is read.  DEMO_PRESET_PAD_NN is the
# alignment byte six blocks carry after their stream (each block ends on an even
# address), which the decoder never reads: its value is the factory image's.  An
# edit that changes the music changes the table data image, so `make gate` (the
# byte compare) and verify-demo-presets catch it.  Demo songs 17 and 18 are followed
# by the stale end of an older stream, which table_data/kn5000_table_data.s declares
# opaque (DemoSongPreset17_StaleStreamTail / DemoSongPreset18_StaleStreamTail).
DEMO_PRESET_PAD_01 := 0x00
DEMO_PRESET_PAD_06 := 0x7d
DEMO_PRESET_PAD_07 := 0x7d
DEMO_PRESET_PAD_08 := 0xc5
DEMO_PRESET_PAD_10 := 0x43
DEMO_PRESET_PAD_12 := 0x0b

$(DEMO_PRESET_DIR)/demo_preset_%.bin: $(DEMO_PRESET_MIDI_DIR)/demo_preset_%.mid $(DEMO_PRESET_SIDECAR_DIR)/demo_preset_%.yaml
	python3 scripts/build/midi_to_preset.py --midi $< \
		--sidecar $(DEMO_PRESET_SIDECAR_DIR)/demo_preset_$*.yaml -o $@

$(DEMO_PRESET_DIR)/demo_preset_%_compressed.bin: $(DEMO_PRESET_DIR)/demo_preset_%.bin scripts/build/compress_lzss.py floppy/tools/kd/lzss_j.py
	python3 scripts/build/compress_lzss.py $< $@ $(if $(DEMO_PRESET_PAD_$*),--pad $(DEMO_PRESET_PAD_$*))

rebuild-demo-presets: $(DEMO_PRESET_COMPRESSED)

# Check every payload against the factory slice byte-for-byte.  The slices of
# demo songs 17 and 18 run on past their stream (the stale tails above), so the
# payload is compared with the slice's first bytes, and the slice must be no
# shorter; exit status 1 on any mismatch.
verify-demo-presets: $(DEMO_PRESET_COMPRESSED)
	@bad=0; for i in $(DEMO_PRESET_IDS); do \
		f=$(DEMO_PRESET_DIR)/demo_preset_$${i}_compressed.bin; \
		r=original_ROMs/demo_preset_$${i}_compressed.original.bin; \
		n=$$(stat -c %s $$f); m=$$(stat -c %s $$r); \
		if [ $$n -le $$m ] && cmp -s -n $$n $$f $$r; then \
		  echo "  preset $$i OK ($$n of the slice's $$m bytes)"; \
		else echo "  preset $$i MISMATCH"; bad=1; fi; \
	done; exit $$bad

# --- bootstrap ---------------------------------------------------------------
# Re-derive the checked-in source from the factory ROM. Only needed if the
# extraction itself changes; the results are committed.

decompress-demo-presets: original_ROMs/kn5000_table_data.rom
	python3 scripts/build/decompress_demo_presets.py --rom $< \
		--output-dir $(DEMO_PRESET_DIR) --emit-references

demo-midi: decompress-demo-presets
	python3 scripts/build/demo_preset_to_midi.py \
		$(foreach i,$(DEMO_PRESET_IDS),$(DEMO_PRESET_DIR)/demo_preset_$(i).bin) \
		-o $(DEMO_PRESET_MIDI_DIR) --drum-type 0x0C

demo-sidecars: decompress-demo-presets
	python3 scripts/build/preset_sidecar.py \
		$(foreach i,$(DEMO_PRESET_IDS),$(DEMO_PRESET_DIR)/demo_preset_$(i).bin) \
		-o $(DEMO_PRESET_SIDECAR_DIR)

# ----------------------------------------------------------------------------
# Help databases (6 SLIDE8K-compressed multilingual help-text blocks)
# ----------------------------------------------------------------------------
# Five live blocks (english/german/french/spanish/indonesian) live at ROM
# 0x988690/0x98BB3A/0x98F0DA/0x992A0C/0x9963FA inside the range the deleted
# table_data/includes/icons_to_strings.bin held (its file offsets 0x43918/0x46DC2/
# 0x4A362/0x4DC94/0x51682); a sixth, german_stale, is a truncated remnant at
# ROM 0x983B3A (file offset 0x3EDC2).  Each block is an 11-byte "SLIDE8K\0"
# header + 24-bit BIG-endian decompressed size (always 0x9000) + an LZSS
# stream + ONE alignment pad byte of arbitrary value.  The checked-in source
# is the decompressed database in $(HELP_DB_DIR); the compressed payload
# (stream + pad, no header -- the header is emitted by help_databases.s) is
# rebuilt with compress_slide8k.py --strict --reference, which replays the
# factory encoder's decisions so the output is byte-identical (the final flag
# bytes have nonzero unused bits, so a plain re-encode would NOT byte-match).
#
#   help_db_<lang>.bin -> help_db_<lang>_compressed.bin -> ROM
#
# The original payload slices live in original_ROMs/help_db_*_compressed.
# original.bin (sliced once from that range at the offsets above, header
# excluded, pad byte included).

# The five live decompressed databases are themselves build products since 2026-10-29: their
# source is the text listing help_db_<lang>.txt (scripts/build/help_db_text.py, whose `verify`
# rebuilds each one equal to what the factory stream decompresses to).  german_stale stays a
# committed .bin: a truncated remnant, not a ROM input.
HELP_DB_PLAIN = $(foreach l,$(HELP_DB_LANGS),$(HELP_DB_DIR)/help_db_$(l).bin)
$(HELP_DB_PLAIN) &: $(HELP_DB_PLAIN:.bin=.txt) scripts/build/help_db_text.py
	python3 scripts/build/help_db_text.py build

verify-help-db-text:
	python3 scripts/build/help_db_text.py verify

# The five live streams are encoded from source with the factory encoder (compress_slide8k.py: lzss_j.encode,
# Okumura's LZSS.C, which notes/misc-2026-10-31/probes/slide8k_vs_lzss_j.py shows makes every factory decision);
# no reference is read.  HELP_DB_PAD_<lang> is the alignment byte after each stream, which the decoder never reads
# (its value is the factory image's; nothing derives it).  verify-help-databases compares with the factory slices.
HELP_DB_PAD_english    := 0x20
HELP_DB_PAD_german     := 0x7f
HELP_DB_PAD_french     := 0xcf
HELP_DB_PAD_spanish    := 0xcd
HELP_DB_PAD_indonesian := 0xce
$(HELP_DB_COMPRESSED): $(HELP_DB_DIR)/help_db_%_compressed.bin: $(HELP_DB_DIR)/help_db_%.bin scripts/build/compress_slide8k.py floppy/tools/kd/lzss_j.py
	python3 scripts/build/compress_slide8k.py $< $@ --pad $(HELP_DB_PAD_$*)
# german_stale is cut at output 0x55E0 (help_databases.s), so its stream past that point encodes no source:
# it is replayed from the factory slice, for verify-help-databases only.
$(HELP_DB_STALE_COMPRESSED): $(HELP_DB_DIR)/help_db_german_stale.bin original_ROMs/help_db_german_stale_compressed.original.bin
	python3 scripts/build/compress_slide8k.py $< $@ --strict --reference original_ROMs/help_db_german_stale_compressed.original.bin

rebuild-help-databases: $(HELP_DB_COMPRESSED) $(HELP_DB_STALE_COMPRESSED)
	@echo "Help databases recompressed (byte-identical via --strict --reference)."

# The two stale-remnant .incbin slices in style_records.s / help_databases.s: derived
# from the live English+German compressed streams, not from a raw blob. See
# scripts/generators/gen_stale_help_duplicate.py.
$(HELP_DB_DIR)/stale_style_records_residue.bin $(HELP_DB_DIR)/stale_help_db_german_head.bin &: \
		$(HELP_DB_DIR)/help_db_english_compressed.bin $(HELP_DB_DIR)/help_db_german_compressed.bin \
		scripts/generators/gen_stale_help_duplicate.py
	python3 scripts/generators/gen_stale_help_duplicate.py build

verify-stale-help-duplicate: $(STALE_HELP_DUPLICATE)
	python3 scripts/generators/gen_stale_help_duplicate.py verify

verify-help-databases: $(HELP_DB_COMPRESSED) $(HELP_DB_STALE_COMPRESSED)
	@for l in $(HELP_DB_LANGS) german_stale; do \
		cmp -s $(HELP_DB_DIR)/help_db_$${l}_compressed.bin \
		       original_ROMs/help_db_$${l}_compressed.original.bin \
		  && echo "  help db $$l OK" || echo "  help db $$l MISMATCH"; \
	done

# Regenerate the decompressed databases from the factory streams in the reference image (one-shot,
# maintenance only; the offsets are ROM addresses minus 0x800000.  They used to be read from the
# deleted table_data/includes/icons_to_strings.bin, at its file offsets 0x3EDC2.. = ROM 0x983B3A..).
decompress-help-databases:
	python3 scripts/build/decompress_slide8k.py original_ROMs/kn5000_table_data.rom --offset 0x183B3A --expected-size 0x9000 --output $(HELP_DB_DIR)/help_db_german_stale.bin
	python3 scripts/build/decompress_slide8k.py original_ROMs/kn5000_table_data.rom --offset 0x188690 --expected-size 0x9000 --output $(HELP_DB_DIR)/help_db_english.bin
	python3 scripts/build/decompress_slide8k.py original_ROMs/kn5000_table_data.rom --offset 0x18BB3A --expected-size 0x9000 --output $(HELP_DB_DIR)/help_db_german.bin
	python3 scripts/build/decompress_slide8k.py original_ROMs/kn5000_table_data.rom --offset 0x18F0DA --expected-size 0x9000 --output $(HELP_DB_DIR)/help_db_french.bin
	python3 scripts/build/decompress_slide8k.py original_ROMs/kn5000_table_data.rom --offset 0x192A0C --expected-size 0x9000 --output $(HELP_DB_DIR)/help_db_spanish.bin
	python3 scripts/build/decompress_slide8k.py original_ROMs/kn5000_table_data.rom --offset 0x1963FA --expected-size 0x9000 --output $(HELP_DB_DIR)/help_db_indonesian.bin

# ----------------------------------------------------------------------------
# Blob coverage audit (ROM 0x944D78.., the deleted table_data/includes/icons_to_strings.bin)
# ----------------------------------------------------------------------------
# Reads that range from the reference image (scripts/build/retired_blobs.py).
# Re-derives from the tree which bytes of the blob any build still reads, and
# re-proves that its 221,104-byte tail past file offset 0x7F2D8 is the stale
# demo-preset duplicate documented in table_data/kn5000_table_data.s.  Fails
# if the blob stops matching the factory dump, if a new .incbin slice reaches
# past the extent the ASL mirror bincludes, or if the tail stops being that
# duplicate.  Not part of `all`.
audit-icons-blob:
	python3 scripts/analysis/audit_icons_blob_coverage.py -v

asl-all: rebuilt_ROMs/kn5000_v10_program.rebuilt.rom rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.rom rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.rom rebuilt_ROMs/kn5000_table_data.rebuilt.rom rebuilt_ROMs/kn5000_custom_data.rebuilt.rom rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.rom

rebuilt_ROMs/kn5000_v10_program.rebuilt.p: archive/asl/tmp94c241.inc archive/asl/maincpu/kn5000_v10_program.asm
	mkdir -p rebuilt_ROMs
	rm -f rebuilt_ROMs/kn5000_v10_program.rebuilt.p
	$(ASL) -i v10/maincpu archive/asl/maincpu/kn5000_v10_program.asm -o rebuilt_ROMs/kn5000_v10_program.rebuilt.p

rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.p: archive/asl/tmp94c241.inc archive/asl/subcpu/kn5000_subprogram_v142.asm
	mkdir -p rebuilt_ROMs
	rm -f rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.p
	$(ASL) -i v142/subcpu archive/asl/subcpu/kn5000_subprogram_v142.asm -o rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.p

rebuilt_ROMs/kn5000_table_data.rebuilt.p: archive/asl/tmp94c241.inc archive/asl/table_data/kn5000_table_data.asm $(DEMO_PRESET_COMPRESSED)
	mkdir -p rebuilt_ROMs
	rm -f rebuilt_ROMs/kn5000_table_data.rebuilt.p
	$(ASL) -i table_data archive/asl/table_data/kn5000_table_data.asm -o rebuilt_ROMs/kn5000_table_data.rebuilt.p

rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.p: archive/asl/tmp94c241.inc archive/asl/subcpu/boot/kn5000_subcpu_boot.asm subcpu/boot/subcpu_boot_data_8000.bin
	mkdir -p rebuilt_ROMs
	rm -f rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.p
	$(ASL) -i subcpu/boot archive/asl/subcpu/boot/kn5000_subcpu_boot.asm -o rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.p

rebuilt_ROMs/kn5000_v10_program.rebuilt.rom: rebuilt_ROMs/kn5000_v10_program.rebuilt.p
	$(P2BIN) rebuilt_ROMs/kn5000_v10_program.rebuilt.p rebuilt_ROMs/kn5000_v10_program.rebuilt.rom

rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.rom: rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.p
	$(P2BIN) rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.p rebuilt_ROMs/kn5000_subprogram_v142.full
	dd if=rebuilt_ROMs/kn5000_subprogram_v142.full of=part_a.rom bs=1 count=256
	dd if=rebuilt_ROMs/kn5000_subprogram_v142.full of=part_b.rom bs=1 skip=60416
	cat part_a.rom part_b.rom > rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.rom

rebuilt_ROMs/kn5000_table_data.rebuilt.rom: rebuilt_ROMs/kn5000_table_data.rebuilt.p
	$(P2BIN) rebuilt_ROMs/kn5000_table_data.rebuilt.p rebuilt_ROMs/kn5000_table_data.rebuilt.rom

rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.rom: rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.p
	$(P2BIN) rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.p rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.rom

rebuilt_ROMs/kn5000_custom_data.rebuilt.p: archive/asl/tmp94c241.inc archive/asl/custom_data/kn5000_custom_data.asm
	mkdir -p rebuilt_ROMs
	rm -f rebuilt_ROMs/kn5000_custom_data.rebuilt.p
	$(ASL) -i custom_data archive/asl/custom_data/kn5000_custom_data.asm -o rebuilt_ROMs/kn5000_custom_data.rebuilt.p

# The archived ASL source bincludes five verbatim slices of the ROM (includes/code_*.bin).  They used
# to be tracked blobs; since 2026-10-31 (lane media-cleanup) they are written here, git-ignored, from
# the tracked reference image by scripts/build/retired_blobs.py, which checks each against the SHA-256
# the deleted file had.  So this legacy mirror copies those ranges of the reference, as it always did.
ASL_HDAE_SLICES := $(foreach n,code_2803c2_28f542 code_28f90c_2953e1 code_295642_2971a2 code_2971b7_29ae9e \
	code_29af2d_2fffff,rebuilt_ROMs/asl-hdae5000/includes/$(n).bin)
$(ASL_HDAE_SLICES): rebuilt_ROMs/asl-hdae5000/includes/%.bin: original_ROMs/hd-ae5000_v2_06i.ic4 scripts/build/retired_blobs.py
	@mkdir -p $(@D)
	python3 scripts/build/retired_blobs.py write $* $@

rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.p: archive/asl/tmp94c241.inc archive/asl/hdae5000/hd-ae5000_v2_06i.asm $(ASL_HDAE_SLICES)
	mkdir -p rebuilt_ROMs
	rm -f rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.p
	$(ASL) -i hdae5000:rebuilt_ROMs/asl-hdae5000 archive/asl/hdae5000/hd-ae5000_v2_06i.asm -o rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.p

rebuilt_ROMs/kn5000_custom_data.rebuilt.rom: rebuilt_ROMs/kn5000_custom_data.rebuilt.p
	$(P2BIN) rebuilt_ROMs/kn5000_custom_data.rebuilt.p rebuilt_ROMs/kn5000_custom_data.rebuilt.rom

rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.rom: rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.p
	$(P2BIN) rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.p rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.rom

# ============================================================================
# Documentation website targets
# ============================================================================
# The website checkout (override: make rom-status DOCS_DIR=/abs/path/technics-docs,
# e.g. from a worktree, where ../technics-docs does not exist).
DOCS_DIR ?= ../technics-docs
DOCS_GALLERY=$(DOCS_DIR)/assets/images/gallery

gallery:
	python scripts/build/convert_images.py $(DOCS_GALLERY)
	python3 scripts/analysis/extract_icons.py --sheet $(DOCS_GALLERY)/IconSpriteSheet.png

# Retired.  This target used to cd into a different project (kn5000_project) and
# export ITS issues.jsonl, not this repo's.  The website has had no issues page
# since technics-docs f6fcaa6 (2026-09-04, "Retire the frozen issue-tracker
# dump"); its CLAUDE.md says there should not be one.  The task list is
# .beads/issues.jsonl, read directly.  scripts/build/export_issues_to_website.py
# still renders it to a Markdown file named on its command line.
issues:
	@echo "REFUSED: the website has no issues page since technics-docs f6fcaa6 (2026-09-04)." >&2
	@echo "Read .beads/issues.jsonl directly, or render it to a file of your choice with:" >&2
	@echo "    python3 scripts/build/export_issues_to_website.py OUT.md" >&2
	@exit 1

# Classes come from scripts/analysis/data_range_census.py (see the script's docstring).
rom-status:
	python3 scripts/build/generate_rom_status_diagram.py --docs-dir $(DOCS_DIR)

# Code-coverage evidence ledger (CLAUDE.md "Code-Coverage Evidence Ledger"): rebuild the address maps in scratch,
# compare with the newest committed snapshot (exit 1 if a figure rose), then write today's snapshot to docs/coverage/.
dispatch-census:
	python3 scripts/analysis/dispatch_table_census/build_maps.py
	python3 scripts/analysis/dispatch_table_census/census.py --compare $$(git ls-files 'docs/coverage/dispatch-census-*.json' | sort | tail -1)
	python3 scripts/analysis/dispatch_table_census/census.py --snapshot docs/coverage

# Documentation-quality ledger (CLAUDE.md "Code-Coverage Evidence Ledger"; rules in the script's docstring):
# per image of all three models, routine headers, numeric addresses, address-only locals, .byte runs in code and
# placeholder names.  Compares with the newest committed snapshot (exit 1 if a debt count rose), then writes
# today's snapshot to docs/coverage/.  Reads sources only; no build needed.
doc-quality:
	python3 scripts/analysis/doc_quality_census.py --compare --snapshot docs/coverage

# The semantic score and the README badges in docs/badges/ (scripts/analysis/semantic_score.py: what each
# component measures). Needs a built tree; runs the data census (~2 min). Commit docs/badges/ afterwards.
semantic-score:
	python3 scripts/analysis/semantic_score.py

# How much of each image is built from C, per toolchain (Toshiba V4.23, the cc900 reference model, our LLVM backend):
# scripts/analysis/cc900/c_build_coverage.py, whose docstring defines it.  Needs a built tree (make all), the 1997
# library copy CC900_LIBCOPY (as in scripts/analysis/cc900/results/model_ledger.md) and the private oracle repo.
# Refreshes the model's and V4.23's library-pair results (pairs_model.py, about 1.5 min each, run side by side),
# then writes scripts/analysis/cc900/results/c_build_coverage.md (the census is cached in $TMPDIR; a cold census took
# 7 min on 2026-11-16, a warm run 8 s).  Commit the three results files; the cc900 dashboard charts
# c_build_coverage.md over commits.  Needs `make wsa1` too: the census assembles the SX-WSA1R images.
CC900_LIBCOPY ?= $(PROJECTS_ROOT)/tmp/cc900-corpus-libsrc97
CC900_V423_LIBRUN ?= $(PROJECTS_ROOT)/cc900-oracle/runs/2026-11-08-5-libsrc97-O3XS/out/v423/O3XS/libsrc
.PHONY: cc900-c-coverage
cc900-c-coverage:
	cd scripts/analysis/cc900/model && \
	  { python3 -I -B pairs_model.py ../results/pairs.tsv $(CC900_LIBCOPY) > ../results/pairs_model_kn5000.tsv & m=$$!; \
	    python3 -I -B pairs_model.py ../results/pairs.tsv $(CC900_LIBCOPY) --listings $(CC900_V423_LIBRUN) \
	      > ../results/pairs_v423_llvm_kn5000.tsv & v=$$!; wait $$m && wait $$v; }
	python3 -B scripts/analysis/cc900/c_build_coverage.py

website: gallery rom-status
	@echo "Website content updated. Don't forget to commit technics-docs."

# ============================================================================
# Clean targets
# ============================================================================
clean:
	rm -f rebuilt_ROMs/kn5000_v10_program.llvm.*
	rm -f rebuilt_ROMs/kn5000_v9_program.llvm.*
	rm -f rebuilt_ROMs/kn5000_v8_program.llvm.*
	rm -rf v9/maincpu/includes/generated/
	rm -f rebuilt_ROMs/kn5000_v7_program.llvm.*
	rm -rf v7/maincpu/includes/generated/
	rm -f rebuilt_ROMs/kn5000_v6_program.llvm.*
	rm -rf v6/maincpu/includes/generated/
	rm -f rebuilt_ROMs/kn5000_v5_program.llvm.*
	rm -rf v5/maincpu/includes/generated/
	rm -f rebuilt_ROMs/kn5000_subprogram_v142.llvm.*
	rm -f rebuilt_ROMs/kn5000_subprogram_v142_compressed.rom
	rm -f rebuilt_ROMs/kn5000_subprogram_v141.llvm.*
	rm -f rebuilt_ROMs/kn5000_subprogram_v141_compressed.rom
	rm -f rebuilt_ROMs/kn5000_subprogram_v140.llvm.*
	rm -f rebuilt_ROMs/kn5000_subprogram_v140_compressed.rom
	rm -f rebuilt_ROMs/kn5000_subcpu_boot.llvm.*
	rm -f rebuilt_ROMs/hd-ae5000_v2_06i.llvm.*
	rm -f rebuilt_ROMs/hd-ae5000_v2_01i.llvm.*
	rm -f rebuilt_ROMs/hd-ae5000_v1_15i.llvm.* rebuilt_ROMs/hd-ae5000_v1_10i.llvm.*
	rm -f rebuilt_ROMs/kn5000_table_data.llvm.*
	rm -f rebuilt_ROMs/kn5000_custom_data.llvm.*
	rm -rf v10/maincpu/includes/generated/

clean-asl:
	rm -f rebuilt_ROMs/kn5000_v10_program.rebuilt.*
	rm -f rebuilt_ROMs/kn5000_subprogram_v142.rebuilt.* rebuilt_ROMs/kn5000_subprogram_v142.full
	rm -f rebuilt_ROMs/kn5000_subcpu_boot.rebuilt.*
	rm -f rebuilt_ROMs/kn5000_table_data.rebuilt.*
	rm -f rebuilt_ROMs/kn5000_custom_data.rebuilt.*
	rm -f rebuilt_ROMs/hd-ae5000_v2_06i.rebuilt.*
	rm -f part_a.rom part_b.rom

clean-all: clean clean-asl

# ============================================================================
# Effects-DSP (NEC uPD6383GF, IC311) microprogram disassembly tree -- dsp/
# ============================================================================
# Regenerate the annotated per-program listings + manifest from the Sub CPU ROM
# and the reverse-engineering tools, then byte-match-verify against the ROM.
# Both are deterministic; `make dsp && git diff --exit-code dsp/disasm` is a
# drift check.  See dsp/README.md.  Override the reused research tools with
# TOOLS=<path to kn7000_mame/tools> if they are not at ~/compartilhado.
TOOLS ?= $(HOME)/compartilhado/kn7000_mame/tools

dsp:
	python3 dsp/tools/gen_dsp_disasm.py --tools $(TOOLS)

dsp-verify:
	python3 dsp/verify.py --tools $(TOOLS)

# Regenerate the per-program STRUCTURAL flowcharts (Mermaid) in dsp/flowcharts/.
# Same inputs as `dsp`; shows signal flow, not a per-instruction dump.  Does not
# touch the .dsm listings, so it cannot affect the byte-match (dsp-verify).
dsp-flowcharts:
	python3 dsp/tools/gen_dsp_flowcharts.py --tools $(TOOLS)
