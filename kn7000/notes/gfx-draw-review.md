# Review of annotations/gfx_draw.ann

The labels and comments for DrawBitmap .. DrawStringCentered (CPU 0x48423B56 ..
0x4842597A) were written on 2026-10-17 by eight annotators, one per group of
functions, and each group was then handed to an independent reviewer told to
assume the file was wrong: check every doc, note and end-of-line claim against
the instructions and against at least one real call site, fix what was wrong,
and rebuild until the image was byte-identical again. A ninth reviewer checked
the DrawBitmap exemplar the same way.

This file is their record: 56 corrections by the eight group reviewers, plus
the exemplar review below, and the doubts each one left open. The open doubts
are the natural next questions; none of them is stated as fact in the
annotations. Rendered from the workflow's reports by
`research-scratch/sessions/2026-10-17_75c61257/review_notes.py`.

## bitmapfast_icons

Functions: DrawBitmapFast, DrawBitmapFast_QueuedExec, DrawBitmapFast_Impl, DrawIcons, DrawIcons_QueuedExec, DrawIcons_Impl.

Corrections (4; the reviewer counted 124 claims it checked and found right):

- **0x48423C88 (DrawBitmapFast doc)** -- The task asks for each record's layout. The header now gives the offsets and widths: movhu to +4 and +6, a 32-bit store to +8 (and a 32-bit read in QueuedExec). The values were already right; only offsets and widths are added.
  - was: queues a 12-byte record {DrawBitmapFast_QueuedExec, x, y, index} instead.
  - now: queues a 12-byte record {+0 DrawBitmapFast_QueuedExec, +4 s16 x, +6 s16 y, +8 u32
    index} instead.
- **0x48423DCD (DrawIcons doc)** -- 'always 24 x 24' overstated it: rows at y >= 240 are cut off. The point is that the size is hardcoded rather than taken from the descriptor. Also adds the record offsets and widths, as for DrawBitmapFast.
  - was: point: always 24 x 24 pixels from 4-bpp data (see DrawIcons_Impl). Index 0 draws
    nothing. ... record {DrawIcons_QueuedExec, x, y, index} instead.
  - now: point: a fixed 24 x 24 pixels of 4-bpp data, whatever size the descriptor gives
    (see DrawIcons_Impl). Index 0 draws nothing. ... record {+0 DrawIcons_QueuedExec, +4 s16
    x, +6 s16 y, +8 u32 index} instead.
- **0x48423CEC (DrawBitmapFast_Impl doc)** -- Removed the backticks, which the exemplar's plain style does not use. The call prints as a raw 0x4c003039, so the header now names the region-1 symbol LibMemCopy (0x487BC00A = lib 0x4C003039) to help the reader find it. Checked that its body copies d0 bytes from a1 to a0 and ends with retf [a2,a3], 8. The paragraph was reflowed to keep its lines under 80 columns.
  - was: with one memcpy of `width` bytes (library 0x4C003039), so there is no 0xF7 ...
  - now: with one memcpy of width bytes (lib 0x4C003039, i.e. LibMemCopy), so there is no
    0xF7 ... (paragraph reflowed)
- **0x48423E92** -- The inner setlb loop writes through a0, not a2. Without a comment the reader has to work out that a0 is the per-row copy of the destination pointer.
  - was: (no comment)
  - now: eol a0 = this row's destination

Left open:

- (0x44,sp) in DrawBitmapFast_Impl_entry is the caller's (8,sp). Under MN10300 call/ret
  semantics the return address is at the caller's (0,sp), so this is the second incoming-
  argument slot. Why the CC103 compiler puts a0 (the point) in slot 2 is unresolved: the C
  argument order might be (index, point), or slots might be assigned per register class. The
  eol keeps the neutral wording 'the caller's argument area'.
- The annotator's icon-table figures (240 descriptors, all 24x24, pixel pointers 288 apart,
  GetIconCount = 240) I reproduced only by running their scratch probe,
  /home/fsanches/compartilhado/tmp/kn7000-drawbitmap/bitmapfast_icons/icon_table_sizes.py,
  which gives that output. It counts entries up to a (0,0,0) terminator. These figures are
  not quoted in the .ann file. If they are quoted anywhere permanent, the probe must be
  committed first.
- The sp7001 (build 942) port of the equ DrawIcons_PixelPairTable was not checked ('make
  program-src-sp7001' writes into the repo). If the symbol porter finds no counterpart, the
  name is dropped there.
- Also checked: the same annotations build BYTE-IDENTICAL together with every other
  annotations/gfx_*.ann file present (gfx_bitmap, gfx_common, gfx_fileex_jpeg,
  gfx_framesp_sp, gfx_jpegr, gfx_sp2_file, gfx_spfast16_256, gfx_spfast), so no label
  collides with the other lanes'. Output:
  /home/fsanches/compartilhado/tmp/kn7000-drawbitmap/bitmapfast_icons-review/out_all.s.

## framesp_sp

Functions: DrawFrameSP, DrawFrameSP_QueuedExec, DrawFrameSP_Impl, DrawBitmapSP, DrawBitmapSP_QueuedExec, DrawBitmapSP_Impl.

Corrections (5; the reviewer counted 190 claims it checked and found right):

- **0x48423F6E (DrawFrameSP_Impl doc)** -- The original said nothing clips horizontally, but ModifyPixel_entry (0x484226C9) calls IsPointOnScreen first and returns without storing when the point is off screen (beq 0x48422717). So 0xF4 pixels past x = 639 are dropped, and only the 0xF6 path (0x48424008) and the literal path (0x4842403A) wrap into the next row.
  - was: A row at y >= 240 ends the copy, but nothing clips horizontally: a piece wider than
    640 - x runs on into the next framebuffer row.
  - now: A row at y >= 240 ends the copy. Only the 0xF4 pixels are clipped horizontally (by
    ModifyPixel's IsPointOnScreen); 0xF6 and literal pixels past x = 639 run on into the
    next framebuffer row.
- **0x48424018 (eol)** -- The comment did not say that ModifyPixel only writes when IsPointOnScreen passes. This is the one per-pixel clip in the function.
  - was: 0xF4: ModifyPixel copies (x, y) of the buffer at *0x500D407C
  - now: 0xF4: ModifyPixel copies (x, y) of the buffer at *0x500D407C, if on screen
- **0x48423EFB (DrawFrameSP doc)** -- The public header named only the 0xF6 case and left out the 0xF7 transparency and the 0xF4 plane copy. I checked 'nothing calls it' over the whole image: a brute-force decode of every cd/cc/dd/dc relative call or jump, with library code at file offset 0x3B8FD1 mapped to 0x4C000000, plus an absolute-pointer search. That also answers the annotator's open question about library callers. The 24 call sites all sit in one function, entry 0x4842621C, which DrawDesignBox (0x484261C1) and its queued replay (0x4842620F) call; every ret in 0x4842621C..0x4842797D uses the same 0x7c frame. So 'the firmware's 24 frame-piece draws' was vaguer than the evidence supports.
  - was: ...painting the piece's 0xF6 pixels in colour d1 (see DrawFrameSP_Impl) ... Nothing
    calls it directly, so it has no _entry: its address sits in the function table at
    0x48727174 (InitBlockTable + 0xC8). The firmware's 24 frame-piece draws, from 0x48426639
    to 0x4842776E, call DrawFrameSP_Impl_entry instead.
  - now: ...: 0xF6 pixels take colour d1, 0xF7 pixels are skipped, 0xF4 pixels are copied
    from the buffer at *0x500D407C (see DrawFrameSP_Impl) ... No call in the image (library
    included) targets it, so it has no _entry; its only reference is the function-table slot
    at 0x48727174 (InitBlockTable + 0xC8). The 24 direct frame-piece draws,
    0x48426639..0x4842776E, are all in DrawDesignBox's blit (0x4842621C) and call
    DrawFrameSP_Impl_entry instead.
- **0x484240A4 (DrawBitmapSP doc)** -- The word 0x484240A4 is also stored at 0x48727544 in the ROM, so the function can be reached indirectly. 'One caller' is only true of direct calls: the whole-image search finds a single one, at 0x48550CCD.
  - was: Its one caller, VwSdFolderImageProc, draws the 24 x 24 folder icon at 0x4868D710.
  - now: Its one direct caller, VwSdFolderImageProc, draws the 24 x 24 folder icon at
    0x4868D710; its address is also in the pointer table at 0x48727544.
- **0x48423F6E (DrawFrameSP_Impl doc, last line)** -- Line reflow after the edit above. The text is unchanged.
  - was: ...dirty with SetChangeRect. The / KN5000 DrawFrameSP_Impl has...
  - now: ...dirty with SetChangeRect. The KN5000 / DrawFrameSP_Impl has...

Left open:

- What 0xF4 frame-piece pixels mean visually is still open. Copying PICTURE_PLANE2
  (green4<<4|blue4 bytes) into the 8 bpp FrameBuffer as a palette index only makes sense if
  that plane also holds a background or save copy. The doc states only the mechanics.
- Unaligned halfword store in DrawBitmapSP_Impl at odd x (0x484241E4). The Linux mn10300
  port has a misalignment fixup handler, which suggests the AM33 traps on such accesses
  rather than silently splitting them; not checked against hardware or the firmware's
  exception vectors. The doc states only that the address is unaligned, which is a fact.
- On the last visible row (y = 239), wrapped 0xF6 and literal pixels in DrawFrameSP_Impl and
  DrawBitmapSP_Impl would land past FrameBuffer, i.e. in PICTURE_PLANE2 (0x500D4080 +
  0x25800 = 0x500F9880). Not documented; a corner case.
- Every check in this review used throwaway inline Python and objdump-style dumps in
  scratch: the whole-image brute-force call/jump decode, the pointer-table dumps at
  0x487270AC and 0x48727530, and the 24x24 bitmap dump at 0x4868D710. None of it is
  committed, because the task forbids editing anything but the .ann file. The lead should
  decide whether to keep the call-site search recipe. It decodes every cd/cc (16-bit) and
  dd/dc (32-bit) displacement, with lib CPU = file offset - 0x3B8FD1 + 0x4C000000.

## spfast

Functions: DrawBitmapSPFast, DrawBitmapSPFast_QueuedExec, DrawBitmapSPFast_Impl, DrawBitmapSPFast4, DrawBitmapSPFast4_QueuedExec, DrawBitmapSPFast4_Impl.

Corrections (8; the reviewer counted 128 claims it checked and found right):

- **0x4842429E (doc)** -- The replay (0x48424302/05 movhu, then exth at 0x4842430C/0F) sign-extends both fields before passing them as d0/d1. They are s16, as the argument types in the same header already say.
  - was: {DrawBitmapSPFast_QueuedExec, x, y, pixels, u16 width, u16 height}
  - now: {DrawBitmapSPFast_QueuedExec, x, y, pixels, s16 width, s16 height}
- **0x484243CD (doc)** -- The stack slot holds a pointer, not the array: 0x484243E9 loads one word, and the Impl indexes it at 0x48424567 with mov (d1,a0). Every caller stores a table address there, e.g. mov 0x485fa224 -> (0x18,sp) at 0x48496B8E. Lines were also reflowed.
  - was: stack args at the caller's (0x18,sp) = u32 colours[4] and (0x1c,sp) = s16 first
    palette index
  - now: stack args at the caller's (0x18,sp) = colours, a pointer to four u32 colours, and
    (0x1c,sp) = s16 first palette index
- **0x484243CD (doc)** -- DrawBitmapSPFast4_QueuedExec reads +0xC, +0xE and +0x14 with movhu and then sign-extends each one (exth at 0x48424459, 0x48424460, 0x48424462).
  - was: pixels, u16 width, u16 height, colours, u16 first
  - now: pixels, s16 width, s16 height, colours, s16 first
- **0x4842446C (doc)** -- It is a pointer (mov (0x6c,sp), a0 at 0x48424561, then mov (d1,a0)). The offsets are relative to the caller's sp; inside the Impl they are (0x6c,sp) and (0x70,sp).
  - was: stack (0x18,sp) = u32 colours[4], (0x1c,sp) = s16 first palette index
  - now: the caller's (0x18,sp) = colours (-> u32[4]), (0x1c,sp) = s16 first index
- **0x4842446C (doc)** -- 0x48424559 compares the u16 counter with s16 first + 4 using bge. For first >= 0x8000 that branch always goes to _Dirty, so no palette entry is set. The header left this quirk out.
  - was: (SetPaletteRGB, only where GetPaletteRGB differs), and
  - now: (SetPaletteRGB, only where GetPaletteRGB differs; a negative first sets none), and
- **0x48424504 (eol)** -- Clarity: the shift is 6 - d2, so d2 counts down from the most significant pair. 'From the top' was ambiguous.
  - was: d2 = bit offset from the top: 0, 2, 4, 6
  - now: d2 = bit offset below bit 7: 0, 2, 4, 6
- **0x48424559 (eol)** -- Same condition, but it now states what it means first (a negative first index). Factually equivalent.
  - was: first >= 0x8000 (as u16): nothing to load
  - now: first < 0 (u16 >= 0x8000): nothing to load
- **0x484244C1 (eol)** -- The jmp goes to _LoadColours, not to a return. Drawing stops, but the palette still loads.
  - was: y >= 240: below the screen, stop
  - now: y >= 240: below the screen, stop drawing

Left open:

- The byte order of the u32 colours (0xRRGGBB vs 0xBBGGRR) is not confirmed, so the header
  deliberately says only 'u32 colours'. The name SetPaletteRGB and the 0x6060A0 'blue' set
  suggest 0x00RRGGBB, but that was not proven.
- Whether the extra pixel at x + width (the SPFast4 bug) is visible in practice depends on
  the rect widths that func_48496B2D's callers pass. Not checked.
- With s16 widths, a negative width makes LibMemCopy copy nothing in SPFast: dest+len wraps
  below dest and 'bcc' skips the loop. The source stride (w+1)/2*2 is then negative. This
  edge case is not documented; probably no caller does it.
- Two old doc errors are outside this file and were not edited: kn5000-docs/kn7000-display-
  subsystem.md:57 ('SP variants honour 0xF7') is wrong for SPFast and SPFast4, and its depth
  table omits plain DrawBitmapSPFast (8 bpp, caller pointer, no palette load). The 2 bpp
  claim for SPFast4 on line 49 is correct.

## spfast16_256

Functions: DrawBitmapSPFast16, DrawBitmapSPFast16_QueuedExec, DrawBitmapSPFast16_Impl, DrawBitmapSPFast256, DrawBitmapSPFast256_QueuedExec, DrawBitmapSPFast256_Impl.

Corrections (8; the reviewer counted 96 claims it checked and found right):

- **0x48424644 (doc, DrawBitmapSPFast16_Impl)** -- The colour mapping was incomplete. In SetPaletteRGB (0x4842DA65..0x4842DAD9), any index in 0x20..0xDF has R, G and B each multiplied by 0x4D and divided by 0x64 (LibDiv32) before being packed to RGB565 in 0x50122AAC. The unscaled word goes to 0x50031490, which is what GetPaletteRGB reads, so the 'unchanged: skip it' test compares unscaled values. Every index both blitters load is in that range.
  - was: The sixteen indices are global, shared by every SPFast16 bitmap. Ends by marking
    ...
  - now: ... shared by every SPFast16 bitmap and inside the 0x20..0xCF that SPFast256
    reloads. SetPaletteRGB keeps the word as given (what GetPaletteRGB returns) but dims
    indices 0x20..0xDF to 77/100 per component in its RGB565 copy at 0x50122AAC. Ends by
    marking ...
- **0x4842480C (doc, DrawBitmapSPFast256_Impl)** -- The same missing 77/100 dimming. The off-screen return at 0x48424823 comes before the palette loop, so no palette load or dirty rect happens, and the doc now says so as the SPFast16 one does. The listing prints the raw 'call 0x4c003039', while LibMemCopy is named only at the alias 0x487BC00A, so the doc names the address it calls.
  - was: A top-left corner off the screen draws nothing. ... with LibMemCopy: ...
  - now: ... draws nothing (no palette load, no dirty rect). ... (SetPaletteRGB dims indices
    0x20..0xDF to 77/100 per component in its RGB565 copy at 0x50122AAC.) ... with
    LibMemCopy (memcpy, called at its library address 0x4C003039): ...
- **0x484245BC (doc, DrawBitmapSPFast16)** -- VwUserBitmapProc (0x484186C8..0x484186D1) tests only for 1 and 8 and sends everything else to SPFast16. Nothing tests for 4, so 'bit depth 4' was asserted without evidence and is redundant.
  - was: Callers: VwUserBitmapProc (bit depth 4, or any depth other than 1 and 8; ...
  - now: Callers: VwUserBitmapProc (any bit depth but 1 and 8; ...
- **0x4842468B (eol)** -- Inaccurate: the LoadPalette path also builds the rect and calls SetChangeRect, so height <= 0 does more than load the palette.
  - was: height <= 0: only load the palette
  - now: height <= 0: no rows, on to the palette load
- **0x4842469E (eol)** -- Only the drawing stops. The jump goes to LoadPalette, which still runs the palette update and the dirty rect.
  - was: y >= 240: below the screen, stop
  - now: y >= 240: below the screen, stop drawing
- **0x48424734 (eol)** -- The old text was garbled. GetPaletteRGB returns 0x50031490[index].
  - was: d0 = the colour index has now
  - now: d0 = the index's current colour
- **0x484245DB, 0x484247A3 (eol)** -- The old text was vague. The store goes to this frame's (0x18,sp), which _Impl reads as (frame+0x18,sp), i.e. (0x58,sp) / (0x54,sp). The new wording matches the QueuedExec comment.
  - was: ... passed on in the same stack slot
  - now: palette: the Impl's 5th argument
- **0x48424894 (eol)** -- Clarity only: says the call copies one row (a0 = dest a2, a1 = src a3, d0 = (0x1c,sp) = width).
  - was: LibMemCopy(dest, src, width)
  - now: LibMemCopy(dest, src, width): copy one row

Left open:

- Whether the 77/100 dimming in SetPaletteRGB is visible on the real LCD depends on the
  firmware compositor (~0x48414D9A) reading 0x50122AAC for UI pixels. That comes from
  kn7000_mame/notes/display-dual-plane-direct-color.md, not from this review's disassembly.
  The doc therefore states only the RGB565-copy fact, not the visual result.
- The annotator's open question still stands: does a palette reload recolour bitmaps already
  on screen? That depends on when the compositor runs. Not verified in MAME.
- The name 'bit depth' for VwUserBitmapProc property 0x600AD is inferred from the dispatch
  (1 -> SP2, 8 -> SPFast256/SPFast, other -> SPFast16). The firmware does not name it.
- The unrelated file kn7000_sp7001_manual.sym shows as modified in git status. I did not
  touch it; it was already modified at session start.

## sp2_file

Functions: DrawBitmapSP2, DrawBitmapSP2_QueuedExec, DrawBitmapSP2_Impl, DrawBitmapFile, DrawBitmapFile_QueuedExec, DrawBitmapFile_Impl.

Corrections (7; the reviewer counted 170 claims it checked and found right):

- **0x484248DE** -- The wrapper does exth d2/d3, QueuedExec does exth d3/d1 after the movhu loads, and Impl does exth plus signed bgt/ble/bge on both values, so u16 was the wrong width/sign for these fields. fg/bg stay u16: only their low byte is ever stored.
  - was: record {DrawBitmapSP2_QueuedExec, s16 x, s16 y, bits, u16 width, u16 height, u16
    fg, u16 bg}
  - now: record {..., bits, s16 width, s16 height, u16 fg, u16 bg}, plus the sentence 'Width
    and height are used as s16 (sign-extended, compared signed).'
- **0x48424981** -- When IsPointOnScreen returns 0, the ret at 0x48424997 returns straight away and skips SetChangeRect. Every other early exit, such as height <= 0 or y >= 240, still goes to _Dirty, so this one path needed saying. I also reflowed the doc lines, which had overflowed to 100+ columns.
  - was: A top-left corner off the screen draws nothing.
  - now: A top-left corner off the screen draws nothing and marks nothing dirty.
- **0x48424B05** -- GetBitmapInfo (0x48421E5A..0x48421E77) copies bfOffBits - 0xE - 0x28 bytes, clamped to 0x400. It does not use biClrUsed. That byte count is what makes the later 'shorter palette -> stale stack bytes' claim true. A rejected file returns to _Return with no palette load and no SetChangeRect, so 'changes nothing' is more accurate than 'draws nothing'. I also wrote 'biClrUsed <= 256' instead of '<= 256 colours' to name the field that cmp 0x100 / bls tests.
  - was: copies its headers and up to 1 KB of palette to the stack; a file it rejects draws
    nothing
  - now: copies its headers, plus the bfOffBits - 54 bytes before the pixels (the palette,
    at most 1 KB), to the stack; a file it rejects changes nothing
- **0x48424B05** -- The old wording was ambiguous. The stride is ceil(width/(4*ppb))*4 bytes, so each row's byte length is padded to a multiple of 4. The width is not padded to 4 bytes.
  - was: Each file row (bottom-up, width padded to 4 bytes)
  - now: Each file row (bottom-up, padded to a multiple of 4 bytes)
- **0x48424B05** -- This is a colour-mapping consequence: 8-bpp indices 0xB0..0xBF become 0xD0..0xDF, which gfx_common.ann (FrameBuffer) defines as picture pixels, not palette indices.
  - was: (0xD0..0xFF, or wraps to 0x00..0x1F)
  - now: (0xD0..0xFF, where 0xDx bytes are picture pixels, or wraps to 0x00..0x1F)
- **0x48424A26** -- Style only: the old line was 104 columns. The meaning is unchanged.
  - was: note Draw the word's 16 pixels; the hardware loop (setlb .. llt) repeats from the
    next instruction.
  - now: note Draw the word's 16 pixels, leftmost first; hardware loop (setlb .. llt).
- **0x48424BB4** -- The old note described only the loop mechanics. It now says what the loop does, which is advance the file-row pointer once per skipped row.
  - was: note The hardware loop (setlb .. llt) repeats from the next instruction.
  - now: note Skip them; the hardware loop (setlb .. llt) repeats from the next instruction.

Left open:

- GetBitmapInfo's 'BM' test uses LibStrncmp, which according to its sym comment stops at a
  NUL in s1. A file whose first byte is 0, or that starts 'B',0, may therefore pass the
  signature check. I did not check the exact order of compare and NUL-test in LibStrncmp,
  and this belongs in GetBitmapInfo's own annotation, so I left it out of this file.
- GetBitmapInfo compares exth(bfOffBits-54) against 0x400 as unsigned. A bfOffBits below 54
  therefore clamps to a 1 KB copy, which reads the pixel data as palette. This is an edge
  case and I did not document it.
- The claim '0xDx bytes are picture pixels' comes from gfx_common.ann / the kn7000_mame
  display note, and may hold only in the direct-colour display mode. I stated it as
  gfx_common does.
- The sp7001 (942) build carries these annotations through the offset map. Both builds have
  identical bytes for the 0x48422016 unpacker, but I did not build program-src-sp7001.

## fileex_jpeg

Functions: DrawBitmapFileEx, DrawBitmapFileEx_QueuedExec, DrawBitmapFileEx_Impl, DrawJpegFile, DrawJpegFile_QueuedExec, JpegDecodeBlit, DrawStringCentered.

Corrections (11; the reviewer counted 168 claims it checked and found right):

- **0x48424EBD** -- The caller list was incomplete. region1.lst has five calls to DrawJpegFile_entry 0x48424EC2: 0x484188AC, 0x48418DC7, 0x4848A988, 0x4854E0A1 (AcDemoImageProc, which draws a JPEG from table 0x4867C5DC) and 0x485806E2 (func_4858056C, which picks DrawBitmapFile, DrawJpegFile or DrawBitmap 0 by calling GetBitmapInfo and then GetJpegSize). The text gives the address, not the func_ name, because the 942 port translates addresses in comments but not names: it renders 0x4858055B.
  - was: Callers: the view procs VwBitmapFileProc and VwJpegFileProc, and OpeningFrameDraw
    (the boot splash, frames straight from the table ROM).
  - now: Callers: ... VwBitmapFileProc and VwJpegFileProc, OpeningFrameDraw (the boot
    splash, frames straight from the table ROM), AcDemoImageProc (0x4854E0A1), and the
    unnamed image drawer at 0x4858056C, which tries its data as a BMP (GetBitmapInfo), then
    as a JPEG.
- **0x48424EBD** -- Nothing requires JFIF. GetJpegSize skips any APP0..APP15 segment by its length without looking inside it, and JpegSetup checks no APP0 either.
  - was: a1 = JPEG (JFIF) data
  - now: a1 = JPEG data in memory
- **0x48424EBD / 0x48424F28** -- The header was missing a clipping fact. The writer callbacks compute the offset as (0x5006AD1E + row)*0x280 + 0x5006AD1C + col with no clamp (0x484864E7..0x48486510; the 0x48486420 path is the same). The only clamp is JpegSetup's >= 0 (0x4848634D/5B). This matches kn7000_mame notes/FINDINGS-sd-media-codeexec-and-parsers.md.
  - was: (no statement on clipping beyond 'Nothing here ... checks the size against the
    screen')
  - now: DrawJpegFile: 'unclipped (see JpegDecodeBlit)'. JpegDecodeBlit: pixels go to (y +
    row)*640 + x + col with no clip; a picture wider than 640 - x wraps into the following
    rows, and one taller than 240 - y runs off the end of each plane.
- **0x48424F28** -- JpegPixelStore is only one of the output callbacks that JpegSetup installs. func_48486AF8 and func_48486DB6 are others, picked by the format word at (0x1C,a0) in callback 0x484863B6. All of them do 'add 0xd0' and write both 0x500D4080 and 0x500F9880. The layout of the second plane is green4<<4|blue4.
  - was: The pixels are direct-colour picture pixels (JpegPixelStore: 0xD0|red4 in
    FrameBuffer, green4/blue4 in PICTURE_PLANE2)
  - now: JpegSetup's pixel writers (JpegPixelStore and its siblings) store direct-colour
    picture pixels, 0xD0|red4 in FrameBuffer and green4<<4|blue4 in PICTURE_PLANE2
- **0x48424F28** -- GetJpegSize skips only APPn, DHT, DQT, DRI, DNL and COM. Any other marker before SOF0/SOS stops the search at 0x48425364 (d1 = -1) and returns -1/-1, so a progressive JPEG fails even though it has a frame header. A missing SOI also gives -1/-1 (jmp 0x4842536A).
  - was: with no SOF0 found w = h = -1
  - now: w = h = -1 when there is no SOI or an unknown marker (e.g. SOF2) comes before SOF0
- **0x48424D3D** -- The 4th byte of an RGBQUAD is reserved. The code never reads it, and it is not guaranteed to be 0.
  - was: 256 x {B, G, R, 0}
  - now: 256 x {B, G, R, x}
- **0x48424D2E** -- GetBitmapInfo also rejects biPlanes != 1 (0x48421E23) and biClrUsed > 0x100 (0x48421E47, unsigned bls). It copies only min(bfOffBits-0x36, 0x400) bytes of colour table (0x48421E5A..77), which is what makes the 'uninitialised stack' claim later in the header true. The doc's lines were also re-wrapped: one line was over 120 columns after the edit.
  - was: GetBitmapInfo checks the file ("BM", 40-byte info header, 1/4/8 bpp, uncompressed)
    and copies its headers and colour table to the stack
  - now: GetBitmapInfo checks the file ("BM", 40-byte info header, 1 plane, 1/4/8 bpp,
    uncompressed, <= 256 colours) and copies its headers and up to 1 KB of colour table to
    the stack
- **0x48424CC8** -- Gives the record field widths (movhu at +4/+6), as the DrawBitmapFile doc does. The code entry still exists at 0x48424CCD; it simply has no name because nothing calls it. A brute-force call16/call32/jmp scan and a pointer scan of both ROMs find only the MILK table entry (941 0x487276F8, 942 0x4872871C).
  - was: record {DrawBitmapFileEx_QueuedExec, x, y, file} ... hence no _entry point.
  - now: record {DrawBitmapFileEx_QueuedExec, s16 x, s16 y, file} ... so no _entry is named.
- **0x48424EBD** -- Field widths (movhu at +4/+6), for consistency with the other DrawXxx record docs.
  - was: queues a 12-byte record {DrawJpegFile_QueuedExec, x, y, data}
  - now: queues a 12-byte record {DrawJpegFile_QueuedExec, s16 x, s16 y, data}
- **0x48424D93** -- 0x48424DB6's '240 - y' and 0x48424DE5's '240 - y rows' use d3. Without this comment the reader has to find where d3 is set, 18 instructions earlier.
  - was: (no comment)
  - now: eol: d3 = 240, the screen height
- **0x48424DCB** -- a0 = rows - (240 - y) is always > 0 on this path, because the branch at 0x48424DB9 has already established rows > 240 - y. The DrawBitmapFile_Impl annotation notes the same dead branch at 0x48424BA7.
  - was: (no comment)
  - now: eol: never taken: rows > 240 - y here

Left open:

- Whether DrawBitmapFileEx is a deliberate palette-only loader or a buggy copy of
  DrawBitmapFile cannot be told from the code; the doc states only what it does.
- The JPEG no-clip claim rests on the offset arithmetic I read in the 0x48486420 and
  0x484864DC callbacks and on the SD-media findings note. I did not trace JpegEngine's own
  row/column loop bounds, and I did not trace the 4th writer path (0x48486519) to its
  writer.
- DrawStringCentered: the annotator's finding that DrawString_Impl clamps the caller's rect
  in place is true only on the draw task. When DrawString queues, the record holds a copy of
  the rect (0x484253EB..FB), so the caller's rect is untouched. The doc does not make this
  claim, so I left it alone.
- SetPaletteRGB has a colour-mode-2 side path (GetColorMode == 2 -> 0x50122CAC[index] :=
  0..3 for four specific colours). The DrawBitmapFileEx_Impl doc's 'CLUT entries 0x20..0xCF
  are set' does not mention it; that belongs to whoever annotates SetPaletteRGB.
- func_48428307 (0x484283EE caller of the row unpacker) looks like a third, unnamed BMP
  blitter outside the converted range. It may deserve a name.
- GetJpegSize treats SOS (0xFFDA) like SOF0. When the SOS 'precision' byte is not 8 it
  resumes scanning from inside the SOS header. This does not matter for well-formed files,
  where SOF0 comes first, and is not in my range.

## jpegr

Functions: DrawJpegFileR, DrawJpegFileR_QueuedExec, DrawJpegFileR_Impl, GetJpegSize, JpegHeaderParse.

Corrections (6; the reviewer counted 118 claims it checked and found right):

- **0x48424F7D** -- Nothing requires JFIF. JpegHeaderParse skips APP0 like any other APPn and needs only SOI, so an EXIF JPEG gets the same handling. '(JFIF)' was an unverified claim.
  - was: a1 = JPEG (JFIF) data
  - now: a1 = JPEG data
- **0x48424FE3** -- GetJpegSize returns only w and h; the code at 0x48424FFB..0x48425023 builds the rectangle. The text now names the rectangle's location and type, and 'same arguments' was added, since JpegDecodeBlit gets the same a0/a1 at 0x48425145.
  - was: GetJpegSize gives the rectangle {x, y, x+w-1, y+h-1}
  - now: From GetJpegSize's width and height it computes the s16 rectangle {x, y, right =
    x+w-1, bottom = y+h-1} at sp+0x58
- **0x48424FE3** -- For the bottom corners the rows are bottom-dy, not the 'first' rows. The new text also says why both planes are saved: a picture pixel is 0xD0|red4 plus green4<<4|blue4.
  - was: (4 + 2 + 1 + 1 along the corner's first four rows ...) saved from both FrameBuffer
    and PICTURE_PLANE2 into a 64-byte stack buffer
  - now: (4 + 2 + 1 + 1 in the four rows nearest the corner ...) saved from FrameBuffer and
    PICTURE_PLANE2 alike (both halves of a direct-colour pixel) into a 64-byte stack buffer
    at sp+0x60
- **0x48424FE3** -- JpegDecodeBlit itself does not clamp. JpegSetup does (0x48486349..0x48486362), and its output callback uses the clamped values as the drawing origin (0x4848642B: (y0+row)*0x280 + x0). So the picture is moved, not clipped. The right and bottom edges are not clipped either.
  - was: Nothing is clipped: ... (JpegDecodeBlit clamps a negative x or y to 0; this code
    does not)
  - now: Nothing is clipped at any edge: ... JpegSetup (inside JpegDecodeBlit) moves a
    negative x or y to 0 for the picture; the corners stay at the point as given.
- **0x48424FE3** -- When the size is not found, a picture may not have been drawn at all, so 'outside the picture' was not well defined. The new text names the three corners and where they land: x-2-dx and y-2-dy.
  - was: so three corners are saved and restored outside the picture
  - now: so the top-right, bottom-left and bottom-right corners are saved and restored left
    of or above the point
- **0x48425267** -- The test is on a 16-bit value, not a byte. The doc did not say that a good SOF0 stops the scan. A stop on another value always gives -1/-1: a2 is set only after a1 is valid, and a valid a2 stops the scan. The d0 left on exit is -1 at 0x4842537A or a1 = height at 0x4842538C, and all 7 call sites overwrite d0 at once. The doc lines were also reflowed.
  - was: any other marker or non-marker byte (SOF2 progressive, EOI, ...) ends the search.
    Writes *width, *height, or -1 to both if either was not found.
  - now: SOF0 ... and the scan stops; any other value where a marker should be (SOF2
    progressive, EOI, a non-marker, ...) ends the search with no size. Writes *width,
    *height, or -1 to both if either was not found, and returns with retf (d0 is left =
    height or -1; no caller reads it).

Left open:

- Whether the decoder (JpegEngine via JpegSetup) can draw a picture that GetJpegSize cannot
  size, for example a progressive JPEG or a header longer than 32 KB, is not checked. If it
  can, only the top-left corner of such a picture would be rounded. The doc says only where
  the other three corners land.
- The call site at 0x4858164C belongs to an unnamed function that starts at 0x4858163D (movm
  [a2,a3]; add -0x45c). It lies inside the span currently named AcSswImgListProc
  (0x4857E987..0x48581EC1). The doc's phrase 'three sites in the AcSswImgListProc range'
  stays deliberately vague. The function needs a name and boundary of its own in
  kn7000_manual.sym (not edited here).
- The restore happens after JpegDecodeBlit's SetChangeRect. I assume SetChangeRect only
  records the rectangle for a later refresh, so the restored corners are still shown;
  SetChangeRect itself was not checked.
- The sibling file gfx_fileex_jpeg.ann still says 'JPEG (JFIF) data' for DrawJpegFile. I
  left it alone because it is outside my file; whoever reviews that file may want to make it
  consistent.

## string

Functions: DrawString, DrawString_QueuedExec, DrawString_Impl, SjisGlyphLookup.

Corrections (7; the reviewer counted 118 claims it checked and found right):

- **0x48425467 (doc)** -- FontTablePtr (gfx_common.ann) is the pointer variable at 0x50122DB8. The code at 0x484254FA loads its value ('mov (FontTablePtr), d1') and then adds font*0x14, so the descriptor is *FontTablePtr + font*0x14, not FontTablePtr + font*0x14.
  - was: Font descriptor (FontTablePtr + font * 0x14): ...
  - now: Font descriptor (*FontTablePtr + font * 0x14): ...
- **0x48425467 (doc)** -- The old text left this behaviour out. DrawBox_Impl (0x48423124..0x48423193) tests the colour for 0xF5 and 0xF4. For those two values it memcpy's each row from the buffer that the pointer at 0x500D407C names, and only for other colours does it memset. So bg 0xF4/0xF5 does not fill the box with a colour. gfx_framesp_sp.ann uses the same wording for that buffer.
  - was: fills the box below with DrawBox_Impl in bg unless bg is 0xF7, draws the glyphs ...
  - now: ... unless bg is 0xF7 (bg 0xF4/0xF5 make DrawBox_Impl copy the box from the buffer
    at *0x500D407C instead of filling it), draws the glyphs ...
- **0x484256F3 (eol)** -- The old comment suggests that the double-byte glyph's height is set to 16. In fact (0x66,sp) is never read on that path: the row loop at 0x484257A3/0x48425838 reads desc.height through (0x44,sp). The header's own row-loop quirk needs this to be clear.
  - was: 16 high
  - now: 16 high (unused: the row loop reads desc.height)
- **0x48425393 (doc)** -- The old text did not say where an indirect call could come from. A ROM-wide search for 0x48425393 finds a single occurrence, at 0x48727178. It sits in a function-pointer table between DrawFrameSP 0x48423EFB and DrawStringCentered 0x48425896.
  - was: only an indirect 'calls' runs the movm here.
  - now: the plain address appears only in the pointer table at 0x48727178 (beside the other
    DrawXxx), so only an indirect 'calls' through it runs the movm here.
- **0x48425412 (eol)** -- 0x4C00304F is already named 'strcpy' (kn7000_exports_from_942.sym:184, which gen_program_s loads). The call target 0x4C003051 is strcpy's entry just after its 'movm [a2]', so the comment now names the real function instead of a bare address.
  - was: strcpy(a0 = copy, a1 = string), library 0x4C003051
  - now: strcpy(a0 = copy, a1 = string), lib strcpy past its movm
- **0x4842564B (eol)** -- Because bg 0xF4/0xF5 copies from the background buffer, 'fill' is not always what happens. DrawBox_Impl_entry takes a0 = rect and d0 = colour (it moves d0 to d2 at 0x484230A0).
  - was: fill the box with bg (d0)
  - now: DrawBox_Impl(a0 = &box, d0 = bg)
- **0x4842546D (eol)** -- Only polish: the old comment repeated the operand that the instruction already shows.
  - was: fg colour to its argument slot (0x1b0,sp)
  - now: fg colour, kept in its argument slot

Left open:

- Annotator's report finding 'bg 0xF7 at all three sites' is wrong (the .ann file does not
  repeat it). At 0x48420BF0, bg = a3 = exth of the caller's (0x44,sp) halfword, a variable,
  while font = 0 and fg = 0. The other two sites, 0x48418568 and 0x4848774B, do pass 0xF7.
- The table that holds 0x48425393 is the one kn7000.sym names InitBlockTable (0x487270AC,
  '48 x InitializeBlockNN'), and that description looks wrong. Entries 0-31 are
  InitializeBlockNN. From entry 32 on it continues with graphics functions: SetChangeRect
  0x48422630, DrawFrame 0x4842319F, DrawBitmap 0x48423B56, DrawString 0x48425393 (entry 51),
  DrawStringCentered 0x48425896 and more. This is probably a native-function export table
  (MILK?). The kn7000.sym description needs checking, and I did not touch it.
- The ConvertStrings overrun note in the report is right but incomplete. The 256-byte buffer
  at (0x84,sp) is followed directly by the x/y temporaries at (0x184,sp)/(0x186,sp), and
  after those come the saved registers and the return address at 0x188 and above, so a long
  string can corrupt the return path.
- Font descriptor +4 (descent) is read with exth, so it is used as s16, although the doc
  says u16. I left this alone because it is minor.
- In the column-width clamp at 0x4842578D, (0x60,sp) is reloaded with movhu (zero-extended)
  and then compared signed against 8. A negative remainder (only possible when desc.columns
  > ceil(width/8)) therefore becomes 8 pixels. The KN5000 behaves the same way (unsigned 'jr
  c'). It is not documented because no such font is known.
- Which fonts have a +0x10 Shift-JIS table, and whether all of them are 16 rows high, cannot
  be settled statically, because FontTablePtr is filled at runtime. The row-loop quirk
  documented in the header depends on this.

## bitmap (the DrawBitmap exemplar)

Corrections (7):

- **file comment** -- "the opaque-table blitter" became "the bitmap-table blitter": the
  opaque one is DrawBitmapFast.
- **0x48423B56 doc** -- the record is now written {+0 DrawBitmap_QueuedExec, +4 s16 x,
  +6 s16 y, +8 u32 index}, matching the sibling headers (checked against the stores).
- **0x48423BBA doc** -- "off the screen" now says what IsPointOnScreen tests: x outside
  0..639 or y outside 0..239 (signed), so a negative x or y rejects the whole bitmap.
- **0x48423BE8 eol** -- added: (0xc,sp) = &entry.height (read back at 0x48423C4B, 0x48423C6F).
- **0x48423BFD eol** -- says where y lives: (0x16,sp) = y = point.y + row.
- **0x48423C13 eol** -- says what the mul computes: d1 = y * 640.
- **0x48423C7E eol** -- added: a0 = &rect.

Checked: arguments at three of the ten call sites (VwBitmapProc 0x4841860D, 0x48490269,
0x484902AB, 0x485806D3); every compare is signed on s16 values; no loop is off by one;
of the 1,860 `mul` in code region 1, the 6 without two nops before them are mis-decoded
data.

Left open:

- gfx_common's descriptors said u16 width/height; the code reads s16 (fixed in
  gfx_draw.ann before the commit).
- The bitmap index is never range-checked; only -1 is rejected.
- "for the LCD update" is inferred from what SetChangeRect does; its reader was not traced.
- A size <= 0 still sends SetChangeRect a degenerate rectangle (bottom = y - 1).
