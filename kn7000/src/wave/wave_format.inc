# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# The field constants of the KN7000 wave ROM stream (src/wave/main.s, src/wave/sub.s).
# Format and evidence: notes/wave-roms-2026-10-29.md; probes in notes/wave-roms-probes/.
#
# A page (0x100000 words = 2 MiB of stream) starts with a directory of 8-byte entries:
#   A  the entry's record, in words from the page start (entry 0's A = 4 x the entry count)
#   P  PFMT | E<<4 | [PCM8] | K
#   B  the recording's first sample, in units of 16 words (32 bytes) from the page start
#   Q  a copy of the record's first parameter word
# The record at A is B again, then parameter words [flags:2][code:6][value:8], up to the first word
# with bit 15 set; records are 32-bit aligned, padded with 0.

# ---- directory word P ----------------------------------------------------------------------------
.equ PFMT,       0x1000   # bit 12: set in all 3,974 entries of both pairs (layout_probe.py); meaning unknown
                          # bits 11:4 = E, the pitch exponent (13..19; Main_P00_E0AF also sets bit 9): a period of 2^(E-9) samples
                          #   sounds at the note the firmware's pitch encodes (an inference from emulation:
                          #   kn7000_mame notes/g13-waves-2026-10-20, pitchcheck.py, 478 of 556 voices)
.equ PCM8,       0x0008   # bit 3: two signed 8-bit samples per word, low byte first (format_probe.py)
                          # bits 2:0 = K, the loop granule: segments and loops count in L = 2^(K+4) samples
.equ GRAN_16,    0        #   (loop_probe.py: with this L, 945 of 954 marked loops repeat their first 32
.equ GRAN_32,    1        #    samples after their end; with L/2 or 2L, 0 and 1)
.equ GRAN_64,    2
.equ GRAN_128,   3
.equ GRAN_256,   4
.equ GRAN_512,   5
.equ GRAN_1024,  6
.equ GRAN_2048,  7

# ---- record parameter words --------------------------------------------------------------------
# value (bits 7:0) >= 0x80: a segment of (256 - value) granules, written `256-n`; a run of these
#   lays the recording out from its first sample.
# value < 0x80: a descending list of multiples of 8, the "split list" (written in decimal).  Its
#   meaning is not known (1/8-octave steps of the firmware's pitch, an inference: g13 README).
# code (bits 13:8): only ever non-zero in the records of PCM8 entries (layout census in the notes);
#   in emulation it scales an 8-bit segment by 2^(-(code & 7)/2) (fitted, g13 code8fit.py).  Written
#   `0xNN<<8`.
.equ LOOP_START, 0x4000   # bit 14 on a segment: the loop starts at the segment's end (loop_probe.py)
.equ LOOP_END,   0x8000   # bit 15 on a segment: the loop ends at the segment's end; ends the record
.equ REC_END,    0xc000   # bits 15:14 both: ends a record that has no LOOP_END, on its own (value 0)
                          #   or on the split list's last value
