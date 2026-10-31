#!/usr/bin/env python3
"""apply_v7_c_divergence.py -- relocate the v7 pointers the shared C source gets wrong.

QUESTION ANSWERED: where, and why, does the committed C fail to reproduce the v7 ROM?

76 of v7's data bins are compiled from C shared with v9/v10. 53 match the v7 ROM exactly. The
other 23 differ, and the difference is now EXPLAINED rather than merely recorded:

    2,365 of them are POINTER RELOCATIONS -- a 32-bit little-endian address that the C emits
    with its v9/v10 target, where v7's is lower by a fixed amount. The deltas are piecewise and
    map to disjoint address ranges:

        v9/v10 address range          v7 delta   sites
        0x00F01C29 .. 0x00F35DE9          -0x2A     986   (the known v7 code offset)
        0x00F3ECB3                        -0x1C       8
        0x00F42DF8 .. 0x00F477DA          -0x0E      69
        0x00F4E778 .. 0x00F87614         -0x404     333
        0x00F8784D .. 0x00FB3062         -0x40D     715
        0x00FB8B0B .. 0x00FC6DEE         -0x7CB     309
        0x00FCF11B .. 0x00FCF13C         -0x7D1       4
        0x00003991 .. 0x00003A3C          -0x9C      15   (a RAM-space table)

    1,334 bytes remain raw, and two files fall back to a whole-file byte diff -- one of them
    because v7's version is a different LENGTH (naka_sequencer_channels is 7,894 B against
    v9's 7,936).

A BLIND SCAN-AND-RELOCATE DOES NOT WORK, and was tried: applying the map to every 32-bit value
in range corrupts data that merely looks like an address, reproducing only 8 of 23 files. The
sites are therefore recorded explicitly. That is the honest form -- each entry says "this
offset holds a pointer, move it by D" -- rather than an opaque byte blob.

WHY THIS EXISTS AT ALL. The build used to run extract_v7_bins.py, slicing the ORIGINAL v7 ROM
into its own inputs, so the byte-match gate could not fail for 979,096 B (46.69%) of v7. That
is gone; verify with `python3 scripts/analysis/rom_provenance_poison.py v7`, which must report
0 differing bytes.

    python3 scripts/build/apply_v7_c_divergence.py      (= apply_c_divergence.py v7)

THE REMAINING WORK is to make the C v7-aware so this file empties: the relocations say exactly
which pointers need it. Do NOT grow the raw section to paper over new divergence.

UPDATE 2026-10-06. The figures above are the file as first written. v7's naka_*_link.ld files were
copies of v10's; scripts/generators/generate_v7_naka_link_scripts.py gave 1,105 of their symbols the
v7 address, in each case where every v7 site using the symbol holds exactly that address. Then
scripts/build/regenerate_v7_c_divergence.py recomputed the json from the build's certified bins,
without reading the ROM. Now:
- 1,162 relocations and 1,180 raw bytes remain;
- 8 of the 23 bins need nothing;
- the naka bins still patched are: naka_disk_warning 25, naka_extension_device 150, naka_master_style 27, naka_sequencer_channels 1179 raw,
  naka_sequencer_exit 13, naka_style_bitmaps 1 raw, naka_technichord_strings 40, naka_widget_descriptors 50, naka_widget_names_charmap 1.
The C files without a link script (gui_display_struct_data, tonegen_param_table, sepaout_config,
style_ui_screendata_ctlonly, se_name_editor, sound_config_lookup) still spell their pointers as v10
numbers. Run regenerate_v7_c_divergence.py after any change to v7's C or link scripts.

UPDATE 2026-10-31 (lane media-cleanup). The patching is apply_c_divergence.py's, run on v7: the same
json format, and a stamp that also records the json entry it applied, so a bin without a valid stamp
is compiled again instead of being patched a second time.  The stamps are no longer tracked.
"""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import apply_c_divergence  # noqa: E402


if __name__ == '__main__':
    sys.argv = [sys.argv[0], 'v7']
    apply_c_divergence.main()
