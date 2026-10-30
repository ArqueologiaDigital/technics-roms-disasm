; =============================================================================
; KN5000 WAVEFORM ROM IC307 (QS6GX3C32008, 4 MB): byte-exact source
; =============================================================================
; Generated once by scripts/generators/gen_waveform_ic307_s.py; hand-edited
; since, and this tree is the authoritative source.  Notes, evidence and open
; questions: notes/waveform-ic307-2026-10-29/README.md.
;
; NO CPU READS THIS ROM.  The tone generator IC303 fetches it on its own bus,
; so no field here has a firmware reader; every rule below is measured from
; the bytes (notes/waveform-ic307-2026-10-29/probes/ic307_layout.py).  The
; image is linked at 0: a label's value is its file offset.
;
; FOUR INDEPENDENT 1 MB PAGES (ic307_page0.s .. ic307_page3.s), each:
;   +0          directory, N x {u16 record offset, u16 wave start / 16}, both
;               relative to the page base; entry 0's record offset is 4 N.
;               N = 198, 168, 1072, 57.
;   +4 N        N parameter records, ascending: a head word that repeats the
;               entry's wave start (1495 of 1495), then [flags:8][value:8]
;               words -- WaveSplit / WaveSeq, waveform_macros.inc.
;               Zero fill up to the next 16-byte boundary.
;   ...         PCM, one labelled item per distinct wave start (1413), each
;               included from its WAV file waveform/wav/<label>.wav through
;               scripts/build/pcm_wav.py (git-ignored; `make waveform-wav`
;               extracts them from the reference image).  IC307 is the Y chip
;               of a word-interleaved pair (the KN7000's wave ROMs hold 1,342
;               of its items in their Y chips), so an item is every other word
;               of a recording: signed 16-bit little-endian samples, or two
;               signed 8-bit samples per word (notes/media-files-2026-10-30).
;   end         0xFF fill: 128 B on pages 0-2, 64 B on page 3.
;
; RECORDING SELECTORS.  A tone-database zone record's +0 word (class << 12) +
; entry goes to tone-generator register +0x040 (WaveSel_StageB_Build_Reg040,
; Sub CPU 0x023849).  For classes 4, 5, 6 and 7 the largest entry the
; factory tables use is exactly N - 1 of pages 0, 1, 2 and 3 (class 6 through
; the drawbar zone records, WaveSel_StageB_Build_Reg040_Footage 0x0238F8);
; classes 0, 1 and 3 use entries beyond pages 0, 1 and 3.  [INFERENCE] page =
; class & 3 and classes 4-7 select this chip.  Each record's comment lists
; the selector's users (probes/tonedb_selector_users.py); a wave is named
; after its source when all its users agree on one.
; =============================================================================

	.text

	.include	"waveform_macros.inc"

	.include	"ic307_page0.s"
	.include	"ic307_page1.s"
	.include	"ic307_page2.s"
	.include	"ic307_page3.s"
