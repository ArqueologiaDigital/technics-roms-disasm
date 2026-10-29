; =============================================================================
; KN5000 RHYTHM DATA ROM IC14 (4 MB mask ROM, main CPU 0x400000-0x7FFFFF)
; =============================================================================
; First written by scripts/generators/gen_rhythm_data_s.py; this file is now the source.
; Builds the DESCRAMBLED image (SHA-1 fef7f1927935d8fdada2afbdbfac29aac56e1c3c);
; scripts/build/rhythm_rom_address_swap.py turns it into the chip's raw read (A19/A21 swapped).
; Format and evidence: notes/rhythm-data-ic14-2026-10-29/README.md.

	.include	"rhythm_macros.inc"

	.section	.text
RhythmData_Base:
	.include	"style_records.s"
	.include	"patterns/bank_06.s"
	.include	"patterns/bank_07.s"
	.include	"patterns/bank_08.s"
	.include	"patterns/bank_09.s"
	.include	"patterns/bank_0a.s"
	.include	"patterns/bank_0b.s"
	.include	"patterns/bank_0c.s"
	.include	"patterns/bank_0d.s"
	.include	"patterns/bank_0e.s"
	.include	"patterns/bank_0f.s"
	.include	"patterns/bank_10.s"
	.include	"patterns/bank_11.s"
	.include	"patterns/bank_12.s"
	.include	"patterns/bank_13.s"
	.include	"patterns/bank_14.s"
	.include	"patterns/bank_15.s"
	.include	"patterns/bank_16.s"
	.include	"patterns/bank_17.s"
	.include	"patterns/bank_18.s"
	.include	"patterns/bank_19.s"
	.include	"patterns/bank_1a.s"
	.include	"patterns/bank_1b.s"
	.include	"patterns/bank_1c.s"
	.include	"patterns/bank_1d.s"
	.include	"patterns/bank_1e.s"
	.include	"patterns/bank_1f.s"
	.include	"patterns/bank_20.s"
	.include	"patterns/bank_21.s"
	.include	"patterns/bank_22.s"
	.include	"patterns/bank_23.s"
	.include	"patterns/bank_24.s"
	.include	"patterns/bank_25.s"
	.include	"patterns/bank_26.s"
	.include	"patterns/bank_27.s"
	.include	"patterns/bank_28.s"
	.include	"patterns/bank_29.s"
	.include	"patterns/bank_2a.s"
	.include	"patterns/bank_2b.s"
	.include	"patterns/bank_2c.s"
	.include	"patterns/bank_2d.s"
	.include	"patterns/bank_2e.s"
	.include	"patterns/bank_2f.s"
	.include	"patterns/bank_30.s"
	.include	"patterns/bank_31.s"
	.include	"patterns/bank_32.s"
	.include	"patterns/bank_33.s"
	.include	"patterns/bank_34.s"
	.include	"patterns/bank_35.s"
	.include	"patterns/bank_36.s"
	.include	"patterns/bank_37.s"

; Banks 0x38-0x3F: erased (FF).  AccVoice_OffsetTable has 64 bank entries, but no record names a
; bank above 0x37 and the bank 0x37 tracks end at 0x7787FB.
RhythmData_Erased:
	.fill	524288, 1, 0xff
