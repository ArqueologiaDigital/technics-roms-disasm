# WP16 lane v10-headers-seq (2026-10-24): renames made while writing v10 sequencer headers.
# Apply to v10/v9/v7 maincpu sources (multi-version sync), then regenerate the symbol files with
# python3 scripts/analysis/l2_symbol_reference.py --regen.
#
# PatIdx_Lookup_Return -> DrumParam_ChannelBitTable: not code and not a return.  Its only reader,
# DrumParam_LookupChannelBit, does `ld xix, <table> / ld a, (xix+a) / ld (0x37c9), a` with A =
# (0x39b8), and its seven bytes are 0x01 0x02 0x04 0x08 0x10 0x20 0x40 (respelled from
# normal / push sr / max / ld (P4:8),32:io / .byte 0x40 by
# scripts/tools/respell_drumparam_channel_bit_table.py), i.e. the one-hot part bit stored in 0x37c9.
s/\bPatIdx_Lookup_Return\b/DrumParam_ChannelBitTable/g
