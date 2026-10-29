; waveform_macros.inc -- one macro per IC307 record kind.  Layout and evidence: kn5000_waveform_ic307.s.
;
; A directory entry: the parameter record's offset from the page base, and the wave's start in 16-byte
; granules from the page base.
.macro WaveDirEntry base, rec, wave
	.short	\rec - \base, (\wave - \base) / 16
.endm
;
; A parameter record's head word repeats its entry's wave offset (1495 of 1495 records do).
.macro WaveRecHead base, wave
	.short	(\wave - \base) / 16
.endm
;
; Key-split word: flag bits 5..0 clear, value a multiple of 8 up to 0x80.  Values within a record descend;
; against the tone database's zone tables the earlier measurement is key = 1.5 x (value - 0x28), i.e. one
; unit = 1/8 octave (waveform-rom-format.md; measured there, not re-derived here).  mark = flag bit 6,
; end = flag bit 7 (only ever on a record's last word).
.macro WaveSplit value, mark=0, end=0
	.byte	\value, (\end << 7) | (\mark << 6)
.endm
;
; Sequence word: an s8 value (negative in 6494 of 6526) and two 3-bit fields a = flag bits 5..3,
; b = flag bits 2..0, each 0..5 and |a - b| <= 1 in 6128 of 6526.  What the tone generator does with them is
; not known: no CPU reads this ROM.  mark / end as for WaveSplit.
.macro WaveSeq value, a, b, mark=0, end=0
	.byte	(\value) & 0xff, (\end << 7) | (\mark << 6) | (\a << 3) | \b
.endm
