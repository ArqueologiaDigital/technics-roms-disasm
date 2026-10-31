
; ==========================================================================
; 0xF1B400-0xF27BFF -- THE TWELVE CHARACTER GENERATORS, 51,200 bytes
;
; Twelve glyph tables laid END TO END with no padding.  Each is the font of one
; SWI7 text service in prom_a: the service loads the base as a 32-bit immediate
; and steps the pitch per character, so BOTH numbers are instruction operands and
; neither is inferred.  The WIDTH comes off the blitter, not off the pixels --
; `LCD_BlitGlyph8` writes a glyph's bytes consecutively down one 8-pixel column
; with CSRDIR DOWN; `LCD_BlitGlyph16` writes the EVEN bytes down one column and
; the ODD bytes down the next, so those tables are 16 wide, two bytes per row,
; row-major, left byte first (notes/FINDINGS-fonts.md sec.3).
;
;   svc | base     | pitch | cells | geometry | where prom_a loads the base
;  -----+----------+-------+-------+----------+---------------------------
;   06  | 0xF1B400 |  14   |  200  |  8 x 14  | 0xF8F058
;   07  | 0xF1BEF0 |  16   |  200  |  8 x 16  | 0xF8F14C
;   08  | 0xF1CB70 |  32   |  200  | 16 x 16  | 0xF8F1DF
;   17  | 0xF1E470 |   8   |  200  |  8 x 8   | 0xF90169, 0xF901E0
;   1C  | 0xF1EAB0 |  32   |  200  | 16 x 16  | 0xF902B2, 0xF90352
;   1D  | 0xF203B0 |  32   |  120  | 16 x 16  | 0xF8F2DB
;   16  | 0xF212B0 |  14   |  120  |  8 x 14  | 0xF8F0C2
;   19  | 0xF21940 |  32   |  120  | 16 x 16  | 0xF8F2A9
;   1A  | 0xF22840 |  32   |  240  | 16 x 16  | 0xF8F245
;   1F  | 0xF24640 |  32   |   60  | 16 x 16  | 0xF8F277
;   20  | 0xF24DC0 |  10   |  200  |  8 x 10  | 0xF8F08D
;   21  | 0xF25590 |  48   |  128  | 16 x 24  | 0xF8F213
;
; Cell counts: ELEVEN of the twelve are (next_base - base) / pitch and divide
; exactly -- a wrong base or a wrong pitch would leave a remainder, and six Latin
; faces at five different pitches all land on 200 while the three kana faces all
; land on 120.  The twelfth, service 0x21, has no successor; its 128 is fixed by
; the LAST-CELL TEST -- the last non-zero byte of the whole region (0xF26D7C)
; falls inside cell 127, and the defined codes are exactly 0x21-0x7F.
; ⚠ The rival reading, 180 cells (the whole extent up to the 0x0E pad, which also
; divides by 48), is rejected: base and pad start are both multiples of 48, so
; that division is exact for arithmetic reasons and proves nothing.
;
; Labels are `Font_SvcNN_WxH` because the service number, the width and the pitch
; are all that prom_a PROVES.  Which script each face carries is in its own header
; with the grade notes/FINDINGS-fonts.md gives it.
; Regenerate + re-check: python3 notes/gen_prom_b_fonts.py --selftest
; ==========================================================================

; --------------------------------------------------------------------------
; Font_Svc06_8x14 -- SWI7 service 0x06's font: 200 cells of 14 bytes,
;   8 x 14 pixels, 0xF1B400-0xF1BEEF.
; Role: Latin, 8 x 14. The FULL face: 0x10-0x1F symbols, 0x21-0xAE and
;   0xB0-0xBC.
; Evidence: prom_a `LCD_Svc_06_DrawText8x14` loads 0x00F1B400 at 0xF8F058
;   and steps 14 bytes per glyph; 17 of its codes above 0x7F are a plain
;   letter's bitmap with an accent in rows 0-1, byte for byte
;   (FINDINGS-fonts.md sec.2).
; Answered 2026-09-02: codes 0xB0-0xBC are the SPANISH accented set --
;   A-acute, E-acute, N-tilde, a-acute, o-acute, u-acute, n-tilde,
;   i-acute, i-grave, inverted question mark, and two cells not settled.
;   They are NOT at their latin-1 code points (inverted question mark is
;   0xBB here and 0xBF there; A-acute 0xB1 here and 0xC1 there) and the
;   offsets are not a constant shift, so this is a private extension.
;   Above 0x7F the whole face is per-language RUNS appended in turn:
;   German 0x80-0x86, music and arrow symbols 0x87-0x91, French
;   0x99-0xA7, more symbols 0xA8-0xAE, one blank cell at 0xAF, then
;   Spanish 0xB0-0xBC.  A block after a gap is a block added later.
;   FINDINGS-fonts.md sec.5.4.
; Unknown: what INDEXES them is still whatever built the localised
;   strings -- the same gap as for the ideographs.
; Entry count: 200 = (0xF1BEF0 - 0xF1B400) / 14, exact.
; --------------------------------------------------------------------------
Font_Svc06_8x14:
	.incbin	"images/fonts/Font_Svc06_8x14.bin", 0, 2800	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc07_8x16 -- SWI7 service 0x07's font: 200 cells of 16 bytes,
;   8 x 16 pixels, 0xF1BEF0-0xF1CB6F.
; Role: Latin, 8 x 16.
; Evidence: prom_a `LCD_Svc_07_*` loads 0x00F1BEF0 at 0xF8F14C; the ASCII
;   test passes (0x20 blank, 0x21-0x7E all drawn).
; Unknown: -
; Entry count: 200 = (0xF1CB70 - 0xF1BEF0) / 16, exact.
; --------------------------------------------------------------------------
Font_Svc07_8x16:
	.incbin	"images/fonts/Font_Svc07_8x16.bin", 0, 3200	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc08_16x16 -- SWI7 service 0x08's font: 200 cells of 32 bytes,
;   16 x 16 pixels, 0xF1CB70-0xF1E46F.
; Role: Latin, 16 x 16.
; Evidence: prom_a loads 0x00F1CB70 at 0xF8F1DF and blits with
;   `LCD_BlitGlyph16`, which is what makes it 16 wide (FINDINGS-fonts.md
;   sec.3).
; Unknown: -
; Entry count: 200 = (0xF1E470 - 0xF1CB70) / 32, exact.
; --------------------------------------------------------------------------
Font_Svc08_16x16:
	.incbin	"images/fonts/Font_Svc08_16x16.bin", 0, 6400	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc17_8x8 -- SWI7 service 0x17's font: 200 cells of 8 bytes,
;   8 x 8 pixels, 0xF1E470-0xF1EAAF.
; Role: Latin, 8 x 8, PROPORTIONAL -- the service advances 6 pixels per
;   character.
; Evidence: prom_a `LCD_Svc_17_DrawText8x8Packed` loads 0x00F1E470 at
;   0xF90169 and 0xF901E0; the 6-pixel advance is `add (0x259e),0x06` at
;   0xF901F5.
; Unknown: -
; Entry count: 200 = (0xF1EAB0 - 0xF1E470) / 8, exact.
; --------------------------------------------------------------------------
Font_Svc17_8x8:
	.incbin	"images/fonts/Font_Svc17_8x8.bin", 0, 1600	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc1C_16x16 -- SWI7 service 0x1C's font: 200 cells of 32 bytes,
;   16 x 16 pixels, 0xF1EAB0-0xF203AF.
; Role: Latin, 11 x 16 drawn in a 16-wide cell, PROPORTIONAL -- 11 pixels
;   per character.
; Evidence: prom_a `LCD_Svc_1C_DrawText16x16Packed` loads 0x00F1EAB0 at
;   0xF902B2 and 0xF90352; `TextShift_LoadGlyph16`'s `and W,0xe0` keeps 3
;   bits of the second byte, 8+3 = 11.
; Callers: nothing calls service 0x1C with a literal service number
;   (notes/swi7_call_sites.py) -- until 2026-09-25 this was filed as the
;   face's open question; display lists are what call it (next note).
; Entry count: 200 = (0xF203B0 - 0xF1EAB0) / 32, exact.
; ⚠ ANSWERED 2026-09-25 (lane promb): the service IS used, through display
;   lists rather than a literal `ld A,0x1C / swi 7`.  An interpreter-A record
;   with op 0x1C runs DLHandler_2Words_Text, which loads A = the op and does
;   `swi 7`; this file frames 149 such records -- the screen titles, e.g.
;   DL_SoundEditWriteCopy's "SOUND EDIT".
; --------------------------------------------------------------------------
Font_Svc1C_16x16:
	.incbin	"images/fonts/Font_Svc1C_16x16.bin", 0, 6400	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc1D_16x16 -- SWI7 service 0x1D's font: 120 cells of 32 bytes,
;   16 x 16 pixels, 0xF203B0-0xF212AF.
; Role: HIRAGANA, 16 x 16. 86 defined cells: 46 gojuon + 9 small + 1
;   prolonged mark + 20 dakuten + 5 handakuten + 5 punctuation.
; Evidence: prom_a loads 0x00F203B0 at 0xF8F2DB. The script identification
;   is FINDINGS-fonts.md sec.4.2: this face and 0xF21940 share EXACTLY six
;   bitmaps, and those six are the prolonged sound mark and the five
;   punctuation cells -- the only cells that belong to neither script.
;   Checked by notes/font_layout_check.py.
; Encoding: private, not JIS (FINDINGS-fonts.md sec.5), and laid out block
;   by block in sec.4.2: 0x10-0x3D the 46 gojuon, 0x3E-0x46 the 9 small kana,
;   0x47 the prolonged mark, 0x48-0x5B the 20 dakuten forms, 0x5C-0x60 the 5
;   handakuten forms, 0x61-0x65 punctuation -- the same code space as the
;   katakana face, with which it shares exactly the six script-neutral cells.
;   ⚠ CORRECTED 2026-09-25: this line used to file the encoding under the
;   open questions; its layout is established by the section it cites.
; Entry count: 120 = (0xF212B0 - 0xF203B0) / 32, exact.
; Used by: DL_JpChordTrackAlreadyExists / DL_JpControlTrackAlreadyExists
;   (op 0x1D records: がすでにあります。, つの, を, に, できません。).
; --------------------------------------------------------------------------
Font_Svc1D_16x16:
	.incbin	"images/fonts/Font_Svc1D_16x16.bin", 0, 3840	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc16_8x14 -- SWI7 service 0x16's font: 120 cells of 14 bytes,
;   8 x 14 pixels, 0xF212B0-0xF2193F.
; Role: HALF-WIDTH KATAKANA, 8 x 14. 0x0F-0x16 marks, 0x21-0x58 the kana.
; Evidence: prom_a loads 0x00F212B0 at 0xF8F0C2. The last defined cell, code
;   0x58, is one horizontal bar and nothing else -- the prolonged sound
;   mark, exactly where the gojuon reading predicts it (FINDINGS-fonts.md
;   sec.4.1, asserted by notes/font_layout_check.py).
; Unknown: code 0x15 is not identified.
; Entry count: 120 = (0xF21940 - 0xF212B0) / 14, exact.
; --------------------------------------------------------------------------
Font_Svc16_8x14:
	.incbin	"images/fonts/Font_Svc16_8x14.bin", 0, 1680	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc19_16x16 -- SWI7 service 0x19's font: 120 cells of 32 bytes,
;   16 x 16 pixels, 0xF21940-0xF2283F.
; Role: KATAKANA, 16 x 16. 87 defined cells -- the hiragana repertoire plus
;   code 0x66.
; Evidence: prom_a loads 0x00F21940 at 0xF8F2A9; same six-shared-bitmap
;   cross-check as service 0x1D above.
; Unknown: code 0x66, a small filled diamond this face alone defines.
; Entry count: 120 = (0xF22840 - 0xF21940) / 32, exact.
; Used by: DL_JpChordTrackAlreadyExists / DL_JpControlTrackAlreadyExists
;   (op 0x19 records), the one Japanese text in the firmware.  Its
;   トラック fixes 0x46 as small ッ, so the small-kana block 0x3E-0x46 reads
;   ァィゥェォャュョッ -- 0x3E's hooked bar (ァ) and 0x46's three strokes (ッ)
;   are checked by notes/promb-2026-09-25/japanese_messages_probe.py.
; --------------------------------------------------------------------------
Font_Svc19_16x16:
	.incbin	"images/fonts/Font_Svc19_16x16.bin", 0, 3840	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc1A_16x16 -- SWI7 service 0x1A's font: 240 cells of 32 bytes,
;   16 x 16 pixels, 0xF22840-0xF2463F.
; Role: Ideographs, set A, 16 x 16. 224 defined cells, 0x10-0xEF, no blank
;   among them.
; Evidence: prom_a loads 0x00F22840 at 0xF8F245. ⚠ 'kanji' is a VISUAL
;   identification (FINDINGS-fonts.md sec.4.3), corroborated only
;   structurally: the same firmware carries hiragana and katakana at these
;   metrics. What IS checked is that all 224 bitmaps are distinct and share
;   none with set B or with either kana face.
; Encoding, 2026-09-02: ALL 224 ideographs are now transcribed, character
;   by character, in notes/fonts-kanji/kanji_transcription.txt.  ⚠
;   CORRECTED 2026-09-25: "they cannot be written here: this source is
;   latin-1" was wrong -- the source is UTF-8 prose that tools READ as
;   latin-1 -- so each cell line below now ends with its character, and
;   notes/promb-2026-09-25/annotate_kanji_cells.py checks all 224 against the
;   transcription (and that the ROM's defined cells are exactly the
;   transcribed codes).  That also settles
;   the 'kanji' identification above -- they are read, not guessed.
;   The transcription is HUMAN OCR of a 16x16 bitmap, so grade a single
;   character as a proposal; one cell, 0x38, is not settled at all.
; ORDER, and this one is measured: the codes were assigned by walking
;   Japanese running text and numbering each new ideograph as it was
;   first met.  72 adjacent code pairs are dictionary words against a
;   shuffle null of 24.8 +/- 4.8 over 10,000 permutations of the same
;   224 characters -- 9.9 sd, 0 of 10,000 reach it -- while distance-2
;   to distance-8 controls sit on the null.  Hence 0x13-0x14 = JOUTAI
;   (state) and 0x1E-0x21 = KOUJOU SHUKKA (factory shipment), a
;   four-character compound across a row boundary.
;   python3 scripts/analysis/kanji_order_hypothesis.py
; Unknown: the TEXT that order came from.  It is not in any of the four
;   images: scripts/analysis/japanese_text_census.py finds no Japanese
;   kana anywhere, under a test that recovers planted sentences.
;   Also still unknown why the firmware keeps two disjoint sets --
;   though set B looks like a second batch collected after this one was
;   closed.  FINDINGS-fonts.md sec.5 and 6.1.
; Entry count: 240 = (0xF24640 - 0xF22840) / 32, exact.
; ⚠ CORRECTED 2026-09-25 (lane promb): "It is not in any of the four images"
;   is wrong for prom_b.  DL_JpChordTrackAlreadyExists and
;   DL_JpControlTrackAlreadyExists (0xF2E91A) are two Japanese messages that
;   use this face (指 0x8D, 定 0x44) with the kana faces; the census looks for
;   RUNS and a display list stores 1..9-character pieces between 4-byte
;   record headers.  Two kanji cannot be the text the ORDER came from, so
;   that question stands.  notes/promb-2026-09-25/japanese_messages_probe.py.
; --------------------------------------------------------------------------
Font_Svc1A_16x16:
	.incbin	"images/fonts/Font_Svc1A_16x16.bin", 0, 7680	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc1F_16x16 -- SWI7 service 0x1F's font: 60 cells of 32 bytes,
;   16 x 16 pixels, 0xF24640-0xF24DBF.
; Role: Ideographs, set B, 16 x 16. 43 defined cells, 0x10-0x3A.
; Evidence: prom_a loads 0x00F24640 at 0xF8F277; disjointness from set A is
;   checked by notes/font_layout_check.py.
; Encoding, 2026-09-02: all 43 are transcribed in
;   notes/fonts-kanji/kanji_transcription.txt, and (2026-09-25) written on
;   their cell lines below, checked by
;   notes/promb-2026-09-25/annotate_kanji_cells.py.  The same ordering test
;   points the same way here -- 6 adjacent pairs are dictionary words
;   against a null of 2.6 +/- 1.5 -- but at 43 cells that is p = 0.04
;   and NOT conclusive on its own.  Recorded because a weak result is
;   still a result.  FINDINGS-fonts.md sec.5.2.
; Unknown: same as set A -- the text.
; Entry count: 60 = (0xF24DC0 - 0xF24640) / 32, exact.
; --------------------------------------------------------------------------
Font_Svc1F_16x16:
	.incbin	"images/fonts/Font_Svc1F_16x16.bin", 0, 1920	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc20_8x10 -- SWI7 service 0x20's font: 200 cells of 10 bytes,
;   8 x 10 pixels, 0xF24DC0-0xF2558F.
; Role: Latin, 8 x 10.
; Evidence: prom_a loads 0x00F24DC0 at 0xF8F08D; ASCII test passes.
; Unknown: -
; Entry count: 200 = (0xF25590 - 0xF24DC0) / 10, exact.
; --------------------------------------------------------------------------
Font_Svc20_8x10:
	.incbin	"images/fonts/Font_Svc20_8x10.bin", 0, 2000	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; Font_Svc21_16x24 -- SWI7 service 0x21's font: 128 cells of 48 bytes,
;   16 x 24 pixels, 0xF25590-0xF26D8F.
; Role: Latin, 16 x 24 -- the largest face, and the only table whose cell
;   count is not fixed by a successor.
; Evidence: prom_a loads 0x00F25590 at 0xF8F213. 128 cells: the last
;   non-zero byte of the whole font region, 0xF26D7C, falls inside cell 127,
;   and the defined codes are exactly the contiguous printable range
;   0x21-0x7F. See this script's docstring for why the rival 180-cell
;   reading is rejected.
; Unknown: -
; Entry count: 128 = (0xF26D90 - 0xF25590) / 48, exact.
; --------------------------------------------------------------------------
Font_Svc21_16x24:
	.incbin	"images/fonts/Font_Svc21_16x24.bin", 0, 6144	; census: generated -- scripts/build/wsa1_fonts.py, from the .png beside it

; --------------------------------------------------------------------------
; 0xF26D90-0xF2774F -- 2496 zero bytes.  Nothing points into them and the
;   last table stops before them: the last non-zero byte of the whole font
;   region is 0xF26D7C.  Padding, emitted as padding.
; --------------------------------------------------------------------------
	.fill	2496, 1, 0x00

; --------------------------------------------------------------------------
; 0xF27750-0xF27BFF -- 1200 bytes of 0x0E, the `ret` pad this build uses
;   between blocks.  ⚠ It is NOT glyph data: an early draft of
;   notes/FINDINGS-fonts.md read it as cells of the 16x24 face because 0x0E is
;   non-zero, and that is where the retracted 'runs to code 0x1FF' came from.
; --------------------------------------------------------------------------
	.fill	1200, 1, 0x0E
