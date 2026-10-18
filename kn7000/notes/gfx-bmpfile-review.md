# Review of annotations/gfx_bmpfile.ann

The labels and comments for the BMP file helpers BfFile2Struct .. BmpReduceColors
(CPU 0x48421D94 .. 0x4842246A) and Draw2BpFile (0x4842829F .. 0x484284B4) were
written on 2026-10-18 by four annotators, one per group of functions. Each group
then went to an independent reviewer told to assume the file was wrong: re-derive
every doc, note and end-of-line claim from its own dump, redo the caller search
itself, fix the file in place and rebuild until the image was byte-identical.

This file is their record: 46 corrections, the reviewers' verdicts on the names
(including names proposed for routines outside these functions, which are not
applied here), and the doubts each one left open. The open doubts are the natural
next questions; none of them is stated as fact in the annotations. Probes behind
the caller lists and the simulated behaviour: notes/gfx-bmpfile-probes/. Rendered
from the workflow's reports by
`research-scratch/sessions/2026-10-18_kn7000-bmpann/merge/review_notes_bmpfile.py`.

## parse

Functions: BfFile2Struct, BfStruct2File, GetBitmapInfo, BmpUnpackRow.

Corrections (11):

- **48422016 (BmpUnpackRow doc)** -- The claim holds only for count 0 (and -1 at 4 bpp). The
  writer's simulator modelled Malloc as always succeeding and tested only count = 0. In the
  ROM, Malloc_entry rounds the size with an unsigned shift: d2 = ((d0+3) lsr 2) << 2
  (0x4841662F..0x4841664D). No free block is that large (bcc at 0x48416657). The grow path
  asks 0x484165E6 for 8 + d2 (0x48416698). That helper returns -1 when the pool's remaining
  bytes are fewer (0x484165F9..0x484165FD), so Malloc returns 0 (0x484166B9). For sizes
  -4..-10, 8 + d2 wraps to 4 or 0: Malloc then carves 4 bytes and writes an 8-byte header
  with size 0xFFFFFFFC/F8, or, for 0, returns the byte count at (0x500006E4) as a pointer
  (0x484165E9..0x484165EB). LibMemCopy computes end = dest + len and copies while dest <
  end, unsigned (0x487BC00A..0x487BC01B). With dest = 0 and a negative len, end is about 4
  GB, so it copies on from address 0. A negative count can arrive: DrawBitmapFile_Impl sign-
  extends biWidth, divides with divu and truncates the stride to s16
  (0x48424B54..0x48424B72); biWidth -100 at 8 bpp gives stride -100. Model:
  /home/fsanches/compartilhado/tmp/kn7000-bmpann/parse-review/negcount_model.py.
  - was: a count <= 0 still calls Malloc and Free and changes nothing.
  - now: A count of 0 still calls Malloc and Free and changes nothing. A negative count (a
    caller's stride for a negative s16 biWidth) is not rejected: Malloc reads count * 8 /
    bpp as a huge unsigned size and returns NULL (or, for a few small values, a block with a
    corrupt header), and memcpy to NULL then copies on from address 0.
- **48422016 (BmpUnpackRow doc)** -- The output already fills count * 8 / bpp bytes of the
  row. The 4-bpp loop runs to a1 = row + count*2 (0x4842205F, lcs at 0x4842207A), and the
  1-bpp loop to index < count*8 (0x4842214A..0x4842214E). So the over-long memcpy
  (0x4842204E / 0x484220A7) adds no requirement on the row; 'therefore' made a harmless
  over-read sound like a constraint.
  - was: ...and Free it at the end; the row must therefore hold count * 8 / bpp bytes.
  - now: ...(only count of them are packed pixels; the row must hold that many bytes anyway,
    for the output), and Free it at the end.
- **48422016 (BmpUnpackRow doc)** -- My whole-image pointer search finds no 32-bit word
  equal to 0x48422016 or 0x4842201B. The MILK table words 0x487276FC..0x4872771C list its
  neighbours (BfFile2Struct, BfStruct2File, GetBitmapInfo, ConvertBitmapFile, Draw2BpFile
  ...) but not it, and its name lives in kn7000_manual.sym (hand names only).
  - was: (nothing on references)
  - now: No table holds its address (it is not a MILK-named function; the name is ours).
- **48421DE1 (GetBitmapInfo doc)** -- The memcpy at 0x48421E77 writes only n = exth(d0)
  bytes, so the rest of the 1 KB buffer is untouched. That is what makes
  DrawBitmapFile_Impl's 'stale stack bytes' claim true. The pixel pointer adds the full
  32-bit bfOffBits reloaded from (a3) (0x48421E7E, add at 0x48421E81), while the copy length
  was only its low 16 bits (exth at 0x48421E66/0x48421E76). With bfOffBits = 54 + 0x10008 it
  copies 8 bytes of colours but points the pixels 64 KB further on.
  - was: ...copies 1 KB of what follows the headers; then *pixels = file + bfOffBits, and it
    returns 1.
  - now: ...copies 1 KB of what follows the headers; the rest of the buffer keeps its old
    bytes. Then *pixels = file + bfOffBits (all 32 bits), and it returns 1.
- **48421DE1 (GetBitmapInfo doc, caller 0x4858163F)** -- The task asks what 0 means for each
  caller. Here 0x4858167F beq 0x4858168D does clr d0; bra 0x485816B1 (return), the same 0
  that 0x485816B0 returns for a picture of 1..640 x 1..240. Only 0x485816AC returns -0x6D.
  So data that is neither a JPEG nor an accepted BMP passes this check.
  - was: the size check 0x4858163F (after GetJpegSize finds no size)
  - now: the size check 0x4858163F (after GetJpegSize finds no size; 0: it returns 0, the
    value that means the size fits)
- **48421DE1 (GetBitmapInfo doc, caller 0x485816BA)** -- 0x485816E8..0x485816ED: cmp 0, d0;
  bne; clr d0; jmp 0x4858176E (add 0x460, sp; ret). On success it returns (0x2c,sp), the new
  bfSize (0x4858176C).
  - was: and the row-count rewriter 0x485816BA.
  - now: and the row-count rewriter 0x485816BA (0: returns 0).
- **48421DBE (BfStruct2File doc)** -- ConvertBitmapFile's struct is at sp+0x34. Before the
  call it stores bfOffBits = 0x36 + palette bytes to (0x40,sp) (0x48421FDC), bfSize to
  (0x38,sp) (0x48421FE0), and 0 to (0x3c,sp) and (0x3e,sp), i.e. struct+8 and +0xA
  (0x48421FE2..0x48421FE6).
  - was: ConvertBitmapFile (0x48421FEF), after it has moved the pixels and set a new bfSize
    and bfOffBits
  - now: ConvertBitmapFile (0x48421FEF), after it has moved the pixels, set a new bfSize and
    bfOffBits and cleared bfReserved1/2
- **48421D94 (BfFile2Struct doc)** -- The code zeroes them with two byte stores, movbu
  d0,(2,a2) and movbu d0,(3,a2) at 0x48421DA7/0x48421DAA. Nothing shows a u16 field (a u16
  would compile to one movhu), and nothing in these functions reads the bytes.
  - was: +2 u16 pad = 0
  - now: +2 2 pad bytes = 0
- **48421E81 (eol)** -- GetBitmapInfo never checks biHeight's sign (0x48421E17..0x48421E57
  test only biSize, planes, bpp, biClrUsed and compression). For a top-down file (negative
  biHeight), which it accepts, the first stored row is the top one.
  - was: d2 = file + bfOffBits: the bottom pixel row
  - now: d2 = file + bfOffBits: the pixel rows (bottom row first if biHeight > 0)
- **file header comment** -- Same reason as 0x48421E81: a negative biHeight means top-down
  rows, and these parsers accept it.
  - was: the pixel rows at +bfOffBits, bottom row first, each padded
  - now: the pixel rows at +bfOffBits, bottom row first (biHeight > 0), each padded
- **48421DBE, 48421DE1, 48422016 (doc paragraphs), header** -- Style only: the edits above
  left short and over-long lines. Nothing else changed; the pre-reflow copy is at
  /home/fsanches/compartilhado/tmp/kn7000-bmpann/parse-review/gfx_bmpfile_parse.before-
  reflow.ann.
  - was: lines broken around the inserted text
  - now: re-wrapped to <= 80 columns of text (comparisons such as 'biClrUsed <= 256' and
    '{B, G, R, x}' kept on one line)

Names:

- BfFile2Struct, BfStruct2File, GetBitmapInfo: keep. They are firmware names: kn7000.sym is
  generated from the MILK reflection tables, and the table words at 0x487276FC, 0x48727700
  and 0x48727704 hold exactly these three starts (checked).
- BmpUnpackRow: keep. It is accurate (it expands a 1/4-bpp row in place to one byte per
  pixel). It is a hand name; no table holds its address.
- equ BmpSignature 485A28B8: keep. The bytes are 42 4D 00 FF; the only 32-bit reference in
  the image is the mov imm32 at 0x48421DF2 (word at 0x48421DF4). No sym file or annotation
  names that address.
- Labels: all 14 sit on branch targets and describe them correctly: GetBitmapInfo_IsBM /
  _HeaderSizeOk / _OnePlane / _DepthOk / _ColoursOk / _Uncompressed / _CopyColours /
  _Return, and BmpUnpackRow_Not8bpp / _4bpp / _4bppDone / _1bpp / _1bppExpand / _1bppDone.
- Writer's 0x485812EA -> SswLoadImageFile: the behaviour checks out. It opens the file with
  mode 'rb' (bytes at 0x486AFA18 = 'rb\0'), rejects files over 0x4D800 bytes with -0x6D,
  gets the type from 0x48580F66 (0xFF -> -0xC8), and on the BMP path returns -0x6D when
  GetBitmapInfo fails. But two of its five callers (0x4852E7B1, 0x48563430/0x485634C9) lie
  outside the AcSswImgListProc range, so an 'Ssw' prefix may be too narrow (e.g.
  LoadImageFile).
- Writer's 0x4858163F -> SswCheckImageSize: it checks the size against 1..640 x 1..240, but
  it returns 0 ('fits') for data it cannot recognise at all. The name should not suggest it
  validates the file. Its only caller is 0x4858101C.
- Writer's 0x485816BA -> BmpSetRowCount: plausible but tentative. It rewrites bfSize and
  biHeight for a new row count (d1) and then moves rows, skipping those beyond 0xF0. I did
  not trace the row loop fully. Its only caller is 0x4858149A.
- Writer's 0x4858056C -> SswDrawImage: accurate. It calls GetBitmapInfo, then
  ConvertBitmapFile and DrawBitmapFile, else GetJpegSize and DrawJpegFile, else DrawBitmap.
  Its four callers (0x4857FB68, 0x4857FD27, 0x48580A0D, 0x48580A46) are all in the slideshow
  range.

Left open:

- The negative-count behaviour in BmpUnpackRow comes from my reading of the Malloc_entry,
  0x484165E6 and LibMemCopy instructions. I modelled it arithmetically in
  /home/fsanches/compartilhado/tmp/kn7000-bmpann/parse-review/negcount_model.py, assuming
  the pool has under 16 MB left; I did not run it on the ROM. The doc text gives no numbers.
- The same negative-stride problem hits the blitters before BmpUnpackRow:
  DrawBitmapFile_Impl's own Malloc(stride * ppb) at 0x48424B79 and memcpy(row buffer, file
  row, stride) at 0x48424C01, and the same pattern in DrawBitmapFileEx_Impl and
  Draw2BpFile_Impl. gfx_draw.ann's DrawBitmapFile_Impl doc covers a negative height but not
  a negative s16 biWidth. That belongs to those annotations; I did not touch the repo.
- Why BfFile2Struct zeroes struct+2/+3 is still open: either bfType is a char[4] made into a
  string, or it is explicit padding. Nothing in these four functions reads those bytes.
- The sp7001 (build 942) port of equ BmpSignature is not checked, because make program-src-
  sp7001 writes into the repo.
- The writer's side finding, that tools/mn10300_sim.py passes pc+4/pc+6 as the return
  address for 5-byte cd and 7-byte dd calls, is not checked by me. It is outside this file.
- LoadHpBmp's limits (biWidth <= 160, biHeight <= 100 at 0x4849718C..0x484971A6) are signed
  compares, so a negative size passes them. The doc states only the limits; the sign quirk
  belongs in LoadHpBmp's own annotation.
- Scratch only, nothing committed. These should be harvested into ~/compartilhado/research-
  scratch, and copied into the repo if any number from them is quoted in permanent notes: my
  brute-force xref (/home/fsanches/compartilhado/tmp/kn7000-bmpann/parse-review/xref.py,
  whose output is xref_all.txt), negcount_model.py, and the writer's find_callers.py,
  which_func.py and sim_parse.py under
  /home/fsanches/compartilhado/tmp/kn7000-bmpann/parse/. check.s/check.rom and all.s/all.rom
  are regenerable and disposable.

## convert

Functions: ConvertBitmapFile.

Corrections (15):

- **0x48421E88 (doc, signature)** -- Only LoadHpBmp passes a buffer size (0x42B6 at
  0x484971AF). The slide-show drawer passes the header's bfSize: mov (0x2c,sp), d0 at
  0x485806B0, where (0x2c,sp) is +4 of its own GetBitmapInfo file-header struct at sp+0x28
  (0x485805D7). The size is used in one place only: room = size - 0x36 - P (sub a0, a3 at
  0x48421F04). That bounds the writes, because 0x36 + 4n + P <= size.
  - was: d0 = the bytes it may fill, i.e. its buffer size; 0 = use the header's bfSize
  - now: d0 = size, the most bytes the rewritten file may take; 0 = the header's bfSize
- **0x48421E88 (doc, why the pixels move)** -- The move is dest - src = 0x36 + 4n -
  bfOffBits (0x48421F3D..44 against (0x30,sp)), with n = min((T + E) / 4, 2^bpp), T =
  bfOffBits - 0x36 and E = size - bfOffBits - P. The writer missed two cases. (1) A gap
  after a SHORT table becomes colours and nothing moves: GetBitmapInfo copied the gap bytes
  too (min(T, 0x400) at 0x48421E5A..77), and 0x48421FC0 writes them back as entries. (2) A
  size below bfOffBits + P (E < 0) cuts the table and moves the pixels down.
  - was: So the pixels move down to close a gap after a full 2^bpp table or to drop 1..3 odd
    bytes, and up when the size runs past the pixels (trailing bytes, or a buffer larger
    than the file)
  - now: So n comes from the room, not from biClrUsed or bfOffBits: all the room becomes
    colour table, up to 2^bpp entries. A gap before the pixels turns into colours; room past
    them moves the pixels up and adds entries of stale stack bytes (no valid pixel uses
    them); room past a full table, 1..3 bytes over a multiple of 4, and entries a size short
    of bfOffBits + P cannot hold are dropped, which moves the pixels down if they lay before
    them.
- **0x48421E88 (doc, added)** -- A well-formed file has T = 4k and E = 0..3, so n = k and
  dest == src: the bcc at 0x48421F6D/0x48421FA3 skips the copy. This is the slide-show case,
  and it is why the drawer calls the function at all: to get the 8-bpp reduction to 0xB0
  colours.
  - was: (absent)
  - now: With size = bfSize a well-formed file keeps its layout: only biClrUsed (set to the
    table's length) and bfReserved change.
- **0x48421E88 (doc, added limit)** -- With d0 = bfSize, a bfSize below 0x36 + P + 4 fails
  the signed room check (blt at 0x48421F08) and the function returns 0. The drawer then
  takes beq 0x485806D0, which is DrawBitmap(point, 0) at 0x485806D3.
  - was: (absent)
  - now: so a file whose bfSize is 0 or too small shows bitmap 0
- **0x48421E88 (doc, BmpReduceColors)** -- BmpReduceColors keeps its histogram in u16 counts
  (movhu/inc/movhu, 0x484221FC..0x48422201). The reduce lane documents that a colour on an
  exact multiple of 65536 pixels counts as unused and can keep an index of 0xB0 or more.
  'Below 0xB0' is therefore not guaranteed for slide-show images, which have no size limit.
  - was: which remaps its pixels to indices below 0xB0
  - now: then remaps the pixels onto the 0xB0 most used colours (its u16 use counts can
    wrap: see its doc)
- **0x48421E88 (doc, top-down bug)** -- The memcpy at 0x48421FC0 writes d3 = 4n bytes, and n
  = min(room/4, 2^bpp) is not always 2^bpp. The overwrite happens exactly when 4n > T. The
  height is movhu + exth (0x48421EF3, 0x48421EF8), i.e. negative as s16. I also dropped a
  negative-biWidth clause I had drafted: a negative width with a negative height gives P >
  0.
  - was: A top-down (negative) or >= 0x8000 biHeight makes P < 0: nothing moves, 2^bpp
    colours overwrite the first pixels when the file had fewer
  - now: A top-down file (biHeight negative as s16) makes P < 0: nothing moves, the 4n
    colour bytes overwrite the first pixel bytes when 4n > bfOffBits - 0x36
- **0x48421E88 (doc, callers)** -- 0x4849718E..0x484971A6 compare with cmp 0x64 / cmp 0xa0
  and the signed ble/bgt, so negative sizes pass. For any accepted file room >= 0x4280 -
  0x3E80 = 0x400, so n = 2^bpp; for 8 bpp that is 256 > 0xB0, so BmpReduceColors always
  runs. FlashProgram128Words(0x9681118C, buf, 0x42B6) is at 0x484971CB..D5. Both callers
  were confirmed by my own whole-ROM scan (xref.py): 0x484971B2 and 0x485806B6, both call32
  to 0x48421E8A. The only other reference is the word at 0x4872770C.
  - was: LoadHpBmp (call at 0x484971B2) passes d0 = 0x42B6 ... (it takes files up to 160 x
    100), so every file there gets 2^bpp colours; on 1 it programs the buffer into flash at
    0x9681118C
  - now: LoadHpBmp (call at 0x484971B2) passes its read buffer's size, 0x42B6 = 0x36 + 0x400
    + 160*100, and on 1 writes all of it to flash at 0x9681118C; it refuses biWidth > 160 or
    biHeight > 100 (signed), so every file there gets 2^bpp colours and every 8-bpp one is
    reduced.
- **0x48421E88 (doc, table)** -- 0x4872770C - 0x487270AC = 0x660 (checked against the table
  dump, which lies between DrawJpegFileR and SetPresetWall). The wording now matches
  DrawFrameSP's doc, '(InitBlockTable + 0xC8)'.
  - was: The address is also in the InitBlockTable pointer table, at 0x4872770C.
  - now: Also in the InitBlockTable function table at 0x4872770C (InitBlockTable + 0x660).
- **0x48421E88 (doc, re-run)** -- Not every 8-bpp file has n > 0xB0. The no-move result also
  holds for the same size: room, and so n, is unchanged, and the new bfOffBits = 0x36 + 4n =
  dest. BmpReduceColors never changes biClrUsed (it writes only the table at +0x36,
  0x48422425, and the pixels), so n stays the same.
  - was: Called again with the new bfSize it moves nothing, but an 8-bpp file keeps n > 0xB0
    and so goes through BmpReduceColors again.
  - now: Run again with the same size or the new bfSize it moves nothing (BmpReduceColors
    still runs if n > 0xB0).
- **0x48421E88 (doc, layout)** -- gfx_draw.ann doc lines are at most 81 columns (p95 77).
  Earlier reviewers reflowed overlong docs the same way.
  - was: lines up to 88 columns
  - now: reflowed to at most 80 columns
- **0x48421F6C / 0x48421FA2 (labels)** -- 'MoveDown8' reads as 'move down by 8'. Each label
  is the dest <= src target of one of the two identical copies, split at 0x48421F4B (8 bpp
  vs ConvertBitmapFile_NotBpp8). The new names say which copy each one belongs to.
  - was: ConvertBitmapFile_MoveDown8 / ConvertBitmapFile_MoveDown
  - now: ConvertBitmapFile_Bpp8_MoveDown / ConvertBitmapFile_NotBpp8_MoveDown
- **0x48421F27 (eol)** -- The old text only restated the register. Both paths arrive here
  with d2 = min(room/4, a1 = 2^bpp) (bls at 0x48421F23).
  - was: d2 = n, the colour count
  - now: d2 = n = min(room / 4, 2^bpp), the colour count
- **0x48421FC0 (eol)** -- GetBitmapInfo copies min(bfOffBits - 0x36, 0x400) bytes, which can
  include gap bytes. The stale boundary is therefore bfOffBits - 0x36, not 'colours the file
  lacked'.
  - was: memcpy(image + 0x36, colours, 4n); any the file lacked are stale
  - now: memcpy(image + 0x36, colour copy, 4n); beyond bfOffBits - 0x36: stale
- **0x48421FFF (eol)** -- n bounds the table, not the pixel values. If the size cuts the
  table below the file's real colour count, pixels can still use indices >= n. The branch
  tests only d2 = n (signed ble).
  - was: n <= 176: every index fits DrawBitmapFile's 176 entries
  - now: n <= 0xB0: all n colours fit DrawBitmapFile's 176 entries
- **0x48422008 (eol)** -- 0x4842200D reloads d0 from (0x20,sp), GetBitmapInfo's 1, so
  whatever BmpReduceColors leaves in d0 is discarded.
  - was: BmpReduceColors(a0 = image, d0 = 0xB0)
  - now: BmpReduceColors(a0 = image, d0 = 0xB0); its d0 is not used

Names:

- ConvertBitmapFile: KEEP. It is the firmware's own name (kn7000.sym, InitBlockTable +
  0x660). The doc describes what it does: a BMP repacker plus the 8-bpp reduction to 176
  colours.
- func_4858056C -> SswDrawImage: ACCEPT, with one correction. The function starts at
  0x4858056A (movm [d2,d3,a2,a3]), and 0x4858056C is the call entry, so the name goes at
  0x4858056A with _entry at 0x4858056C. It has 4 direct callers, all in the AcSswImgListProc
  span: 0x4857FB68, 0x4857FD27, 0x48580A0D, 0x48580A46. It draws a BMP (GetBitmapInfo,
  ConvertBitmapFile, then DrawBitmapFile, or DrawBitmap 0), a JPEG (GetJpegSize,
  DrawJpegFile), or bitmap 0 as a 24-pixel placeholder, at the u16 cursor 0x5009E284/86. It
  aligns by u8 0x5009E28E (0 centre, 2 right, else left, against a width that func_48580282
  returns) and advances x by the width. The strings '<SLIDESHOW>' and 'SSW-ACT-V01' at
  0x486AF889 support the Ssw prefix.
- func_4852EC49 (entry 0x4852EC4E) -> LoadHpBmpFile: CONFIRMED. It opens a file through
  func_48532395 with a1 = 'rb' (0x486643A4), calls LoadHpBmp_entry 0x48497135, closes the
  file with func_485323BF and returns LoadHpBmp's d0. Its only caller is 0x48522417.
- func_4853411C -> 'probably Malloc': CONFIRMED as an allocator, but NOT the main Malloc
  (0x48416625, free list 0x500006E8). It does a first-fit search over its own block list at
  (0x50160600), sentinel 0x501605F8. Headers are 0x10 bytes {u32 size, u8 0xA5 magic, u8 in-
  use, next, prev}; a block is split when more than 0x14 bytes remain; it returns header +
  0x10, or 0. The arena is set up by func_485340BE (0x445C0 bytes at 0x503BB800), and
  func_4853419F frees (it checks 0xA5 at header + 4). Suggested names, tentative:
  WorkArenaReset / WorkArenaAlloc / WorkArenaFree.
- func_48532468 -> 'probably a file read': NOT VERIFIED by me. Its use in LoadHpBmp (a0 =
  buffer, d0 = 0x42B6, result exth'd and tested < 0) fits a read, but I did not dump it.

Left open:

- LoadHpBmp calls func_485340BE before it allocates. That function resets the arena at
  0x503BB800 (0x445C0 bytes, list head 0x50160600) to one free block, so any other live
  block in that arena is lost. I did not check whether anything else uses the arena. It
  belongs in LoadHpBmp's annotation, not this file.
- With LoadHpBmp, a file whose bfOffBits + P exceeds 0x42B6 makes the pixel move read past
  the arena buffer, because the file read is cut at 0x42B6. The doc states this as the
  general 'bfOffBits + P is not checked' bug. I did not reproduce it in MAME.
- I did not trace whether the slide-show drawer runs again on the same in-memory image. If
  it does, the 're-run' sentence applies: nothing moves, and BmpReduceColors may re-sort the
  table (the picture stays the same).
- The stride is also cut to s16 (exth d0 at 0x48421EF7). The doc mentions only biHeight's
  low 16 bits, because a stride of 0x8000 bytes or more cannot occur for anything the
  blitters draw.
- I did not trace an indirect call through InitBlockTable + 0x660. The doc says only that
  the address is in the table.
- I did not check the build-942 (sp7001) port of the annotations, because make program-src-
  sp7001 writes into the repo.
- My reference scanner, /home/fsanches/compartilhado/tmp/kn7000-bmpann/convert-
  review/xref.py, is a whole-ROM brute-force decode of call/jmp/calls d16/d32 under both
  mappings, plus a search for the address as a 32-bit word. It confirmed the two direct
  callers and the table word. It exists only in scratch, because this lane may write nowhere
  else; the main agent should harvest it into research-scratch (the writer's find_refs.py as
  well).
- 'Hp' in LoadHpBmp is still unexpanded. The doc states only what the code does.

## reduce

Functions: BmpReduceColors.

Corrections (14):

- **4842215B** -- The map[order[r]] = r loop (0x484222F3..0x48422309) runs before the in-use
  > budget test at 0x48422315, and both outcomes reach the rewrite at 0x48422425. So the
  function compacts the used colours to indices below the in-use count even when nothing is
  merged. That compaction is what lets a 256-entry table with few used colours fit under
  0xB0.
  - was: comb-sorts the 256 palette slots by count, most used first, and gives every index
    its rank as new index. If more than d0 indices are in use, ...
  - now: ... gives every index its rank as new index, so the colours in use always move to
    the front. If more than d0 indices are in use, ...
- **4842215B** -- The nearest-colour loop (0x48422396..0x48422408) only reads
  palette[0..budget-1], and nothing stores into those entries. A merged colour just takes
  the kept colour's index, with no averaging. The tie rule is confirmed: ble at 0x484223FC
  updates only when the distance is strictly smaller, and lower ranks are tried first.
  - was: least dR^2 + dG^2 + dB^2, the more used kept colour on a tie.
  - now: least dR^2 + dG^2 + dB^2, the more used one on a tie; no kept colour is changed.
- **4842215B** -- My own brute-force search
  (/home/fsanches/compartilhado/tmp/kn7000-bmpann/reduce-review/refs_scan.py) finds only
  'call16 at 48422008 -> 4842215D' and no pointer word, so the only-caller claim holds.
  ConvertBitmapFile computes n = min((size - 0x36 - P)/4, 2^bpp) at 0x48421F04..0x48421F25
  and tests n > 0xB0 at 0x48421FFB. LoadHpBmp passes 0x42B6 (0x484971AF) and accepts at most
  160 x 100 (0x4849718C..0x484971A8), so the room is at least 0x400 and n = 256 for every
  8-bpp file. func_4858056C passes (0x2c,sp) = bfSize at 0x485806B0.
  - was: Only caller: ConvertBitmapFile, for an 8-bpp file with more than 0xB0 palette
    entries, with d0 = 0xB0 -- the 176 entries 0x20..0xCF that DrawBitmapFile_Impl loads
    from a file.
  - now: Only caller: ConvertBitmapFile, once it has packed the file (colour table at +0x36,
    biClrUsed = its n entries), for 8 bpp with n > 0xB0, with d0 = 0xB0: the 176 entries
    0x20..0xCF that DrawBitmapFile_Impl loads from a file. From LoadHpBmp that is every
    8-bpp file (its 0x42B6-byte buffer gives n = 256); from the slide-show drawer
    0x4858056C, which passes bfSize, a file whose colour table has more than 0xB0 entries.
- **4842215B** -- The write-back hardcodes image + 0x36 (0x4842242F) and takes its length
  from biClrUsed (0x48422425). The palette was read for bfOffBits - 54 bytes (GetBitmapInfo
  0x48421E5A..0x48421E77). The two agree only after ConvertBitmapFile has set bfOffBits =
  0x36 + 4n and biClrUsed = n. With biClrUsed = 0 (the BMP default), the pixels would be
  remapped but no palette written.
  - was: (no such limit)
  - now: it relies on ConvertBitmapFile's layout, as it writes the palette to image + 0x36
    for biClrUsed entries;
- **4842215B** -- A missed bug. BmpReduceColors reads biHeight with a 32-bit mov (0x480,sp)
  at 0x484221D5, 0x484221E4, 0x48422439 and 0x48422456. ConvertBitmapFile sizes the pixel
  array with movhu (0x4c,sp) + exth (0x48421EF3/0x48421EF8). GetBitmapInfo does not check
  the height, and func_4858056C does not either. LoadHpBmp rejects heights above 100 by a
  signed 32-bit compare at 0x4849718E, but negative width and height together can still give
  a large positive product. The rewrite loop at 0x48422449..0x48422462 stores map[byte] into
  every byte it visits.
  - was: (not mentioned)
  - now: biHeight is read as 32 bits here but as s16 by ConvertBitmapFile's room check, so a
    malformed height (e.g. 0x10010, which that check takes as 16 rows) can make both pixel
    loops run past the file, the second one writing.
- **4842215B** -- func_4858056C goes from GetBitmapInfo (0x485805E3) to
  ConvertBitmapFile(bfSize) (0x485806B6) with no width or height test. ConvertBitmapFile
  only checks that the pixels fit in the size it is given. So a slide-show BMP above 65535
  pixels (e.g. 320 x 240) can wrap a count. The u16 wrap and the 160 x 100 cap were re-
  verified: the movhu store at 0x48422201, and the h <= 100 and w <= 160 compares at
  0x4849718E/0x48497196/0x484971A2. The part of the doc listing the faults now starts with
  'Bugs:'.
  - was: (LoadHpBmp's files, at most 160 x 100, cannot wrap).
  - now: Bugs: ... LoadHpBmp's files (at most 160 x 100) cannot wrap; the slide-show drawer
    sets no size limit of its own.
- **4842215B** -- Zero-count slots take ranks in-use..255 in no fixed order: comb sort swaps
  only on a strict < (0x484222AB) and is not stable. The memcpy at 0x48422432 writes ranks
  0..biClrUsed-1, which include ranks in-use..biClrUsed-1. So stale-stack slots can land
  inside the written table, unused.
  - was: in a valid file no pixel uses them, so they sort into the unused tail.
  - now: no valid pixel uses them, so they sort among the unused colours, and some may be
    copied back into unused table entries below biClrUsed.
- **4842215D** -- The stride is sign-extended (exth 0x484221DA), then stored and read as
  32-bit words (0x484221DB, 0x4842243D, 0x4842245A). The in-use count is accessed with movhu
  (0x48422217, 0x4842230A). order[] and map[] are accessed only with movbu (0x4842220D,
  0x484222B7..0x484222C7, 0x48422301, 0x48422414, 0x48422451). The header slot is
  BfFile2Struct's 16-byte struct (2 + 12 bytes), not the raw 14 bytes.
  - was: Frame: (0x4c,sp) = &palette, (0x58,sp) = s16 row stride, (0x5c,sp) = colours in
    use, ... sp+0x468 = the file header, ... sp+0x6A0 = order[256] (rank -> original index),
    sp+0x7A0 = map[256] (original index -> new index).
  - now: Frame: (0x4c,sp) = &palette copy, (0x58,sp) = row stride (s16, kept as a word),
    (0x5c,sp) = u16 colours in use, ... sp+0x468 = the file header (BfFile2Struct's 16
    bytes), ... sp+0x6A0 = order[256] (u8, rank -> original index), sp+0x7A0 = map[256] (u8,
    original index -> new index).
- **484221D5** -- A 32-bit mov (0x480,sp), against ConvertBitmapFile's movhu at 0x48421EF3.
  This line is the anchor of the height bug above.
  - was: d1 = biHeight
  - now: d1 = biHeight, all 32 bits (ConvertBitmapFile checked the low 16)
- **48422200** -- 0x48422200 is a 32-bit inc d0, which does not wrap. The truncation to 16
  bits happens at the movhu store at 0x48422201.
  - was: eol 'u16: wraps after 65535' (on inc d0)
  - now: (removed)
- **48422201** -- movhu d0, (d3,a1) stores the low 16 bits, which is where the wrap happens.
  - was: count[index] + 1
  - now: count[index] + 1, stored as u16: 65535 + 1 wraps to 0
- **48422237** -- It is the beq target at 0x4842222D in the colours-in-use loop
  (0x48422216..0x4842223A), which skips the in-use increment. 'CountNext' read as the next
  iteration of the pixel-count loop just above (0x484221F1..0x48422205), which has no label.
  - was: label BmpReduceColors_CountNext
  - now: label BmpReduceColors_InUseNext
- **4842229E** -- 'Pass' already means a comb-sort pass in the note at 0x4842223B, so the
  old wording was ambiguous. a2 starts at gap (0x48422290), and the loop runs while
  &count[i] < &count[256 - gap] (0x4842229C, lcs at 0x484222E2). The note was split over two
  lines to keep the usual width.
  - was: note One pair (i, i + gap) per pass of the hardware loop (setlb .. lcs).
  - now: note One pair (i, i + gap) per turn of the hardware loop (setlb .. lcs), / for i =
    0 .. 255 - gap.
- **48422449** -- Same wording as 0x4842229E, for consistency.
  - was: note One byte per pass of the hardware loop (setlb .. llt).
  - now: note One byte per turn of the hardware loop (setlb .. llt).

Names:

- BmpReduceColors: keep. It cuts the colours the pixels use down to d0. It counts each
  index, sorts the slots by count (most used first), maps each dropped colour to the kept
  colour at the least squared RGB distance, and rewrites the palette and pixels in place. It
  always compacts the used colours to the front, but that serves the same goal, so a longer
  name such as BmpSortReducePalette adds nothing.
- Labels: I checked all 18 against their branch sources. 17 are accurate (InitOrder,
  SortPass, GapOne, Gap11, PassStart, SortNext, PassDone, NoSwaps, Sorted, TooMany, Merge,
  MergeLoop, Nearest, NearestNext, MapDropped, Rewrite, Return). I renamed
  BmpReduceColors_CountNext to BmpReduceColors_InUseNext. None collides with gfx_draw.ann or
  the other three lanes' files.

Left open:

- Where the slide-show files come from was not traced. func_4858056C is called with a0 = a
  record's +0x10 pointer (0x4857FB65, 0x4857FD24), an entry of the table at
  (0x50172C90)+0x240 (0x48580A09), and a PICTURE_FLASH (0x57800000) table entry
  (0x48580A38..0x48580A44). With a flash pointer, ConvertBitmapFile and then BmpReduceColors
  would write into flash in place. I did not check whether those files are stored already
  packed and reduced, or whether such writes take effect. I also did not check whether the
  picture import caps the image size, which decides whether the u16 count wrap can happen in
  practice. The doc says only that func_4858056C sets no limit of its own.
- The malformed-height bug (e.g. biHeight = 0x10010) comes from reading the code only, not
  from running it in an emulator. From LoadHpBmp it needs a negative width and a negative
  32-bit height, since that function rejects heights above 100.
- Comb sort is not stable, so among colours with equal counts the order is arbitrary but
  deterministic. This decides which equal-count colour is kept at the d0 boundary. It is not
  stated in the doc.
- The writer's flags doubt at 0x4842234F: on the MN10300, MOV (imm32 to Dn, and Dn to
  memory) leaves PSW unchanged, so the bgt tests 'cmp 0, budget'. I consider this resolved
  but did not cite a manual page for it. It does not matter with budget 0xB0.
- My reference-search script, /home/fsanches/compartilhado/tmp/kn7000-bmpann/reduce-
  review/refs_scan.py, is in ~/compartilhado/tmp only and not harvested into
  ~/compartilhado/research-scratch. I left it there to avoid racing the other lanes on that
  repo; the lead should harvest it. It answers which
  call16/call32/jmp16/jmp32/calls16/calls32 instructions or LE32 words refer to the given
  addresses, with library code also tried at 0x4C000000. Usage: python3 refs_scan.py
  baserom/kn7000_program.rom 4842215B 4842215D. The only statement in the .ann that rests on
  it is 'Only caller: ConvertBitmapFile'.

## draw2bp

Functions: Draw2BpFile, Draw2BpFile_QueuedExec, Draw2BpFile_Impl (and the three stubs after it).

Corrections (6):

- **0x4842829F (Draw2BpFile doc, the caller's read)** -- 0x48532468 copies the device table
  at 0x486646F0 and calls slot [byte 0x5007125A]. Device 0's handler, 0x4853282E, loops
  func_4846DA31(a0 = buf, d0 = 1, d1 = min(remaining, 0x7FFF), a1 = *(0x50071254)) until d0
  bytes are read, or until a short read with flag 0x8000 set at (8,file), i.e. EOF. So it
  reads AT MOST d0 bytes. Its sibling at 0x485328B5 is the write: it gives error -11 when
  (8,file) & 0x7FFF == 0x1F, i.e. disk full. DbBitmapLoadProc discards the return: the call
  at 0x4848873F is followed at once by fmmclose at 0x48488746. Neither GetBitmapInfo nor the
  Impl reads bfSize. 640*240 + 54 + 1024 = 0x25C36 > 0x18000, and BMP rows run bottom-up, so
  what is missing is the image's top rows.
  - was: (fmmopen "rb", then the fmm read 0x48532468 with size 0x18000)
  - now: (fmmopen "rb", then the fmm read 0x48532468 of at most 0x18000 bytes, its count
    unchecked: an 8-bpp 640 x 240 BMP, 0x25C36 bytes with 256 colours, gets its top rows
    from whatever lies past the bytes read)
- **0x4842829F (Draw2BpFile doc, what '2Bp' means)** -- The table slots
  0x48727718..0x4872772C hold GetPaletteRGB4, Draw2BpFile, Check2BitLcd, SetLcdMode,
  GetColorMode and SetColorMode. The name strings 0x485B4E4F..0x485B4E8F are the same six,
  contiguous. CheckColorLcd and GetLcdMode have their strings elsewhere, at 0x485B493F.
  Colour mode 2 is real and reachable: at 0x48414328, func_484142D5 calls SetColorMode(2)
  and SetLcdMode(2) when func_4854D778 (u16 at 0x50005218) is 2. In mode 2, SetPaletteRGB
  (0x4842DA00..0x4842DA60) stores level 0..3 at 0x50122CAC[index], and GetPaletteRGB4 reads
  it. It is read by the screen-output code at 0x48415056 (for bytes whose high nibble is not
  0xD) and by CaptureLcd (0x48415A0E/1C). The code itself rules out 2 bpp.
  - was: The address is also in the MILK reflection table (0x4872771C), between
    GetPaletteRGB4 and Check2BitLcd, which hints that "2Bp" means the 2-bit panel (colour
    mode 2); no code here or in the Impl tests that mode.
  - now: The address is also in the MILK reflection table (0x4872771C). There, and in the
    firmware's name strings (0x485B4E5E), it sits in one run with GetPaletteRGB4,
    Check2BitLcd, SetLcdMode, GetColorMode and SetColorMode: colour mode 2 is a 4-level
    panel whose per-entry levels GetPaletteRGB4 reads. So "2Bp" probably names that 2-bit
    panel, not a pixel format; no code here or in the Impl tests the mode.
- **0x48428305 (Draw2BpFile_Impl doc, the overflow sentence)** -- The old text used y for
  both the point and the screen row. The new one also covers heights <= 240: ble at
  0x48428386 draws every row with no y test. For example, y = 100 and biHeight = 200 put 60
  rows past 0x500F9880 (kn7000.sym PICTURE_PLANE2), where DrawBitmapFile_Impl would cut to
  140 rows. The surrounding lines were reflowed.
  - was: So for y > 0 the rows that land at y >= 240 are written past the end of
    FrameBuffer, into PICTURE_PLANE2 and on;
  - now: So whenever y + rows > 240, the rows that fall below screen row 239 are written
    past the end of FrameBuffer, into PICTURE_PLANE2 (0x500F9880) and on;
- **0x48428305 (Draw2BpFile_Impl doc, last sentences)** -- The only plane written is
  FrameBuffer: add 0x500d4080 at 0x484283BE. GetPaletteRGB4 at 0x4842DB30 is movbu (d0,
  0x50122CAC). Precision only.
  - was: ...the output is one byte per pixel. ... in colour mode 2 it also keeps a level
    0..3 per entry at 0x50122CAC.
  - now: ...the output is one byte per pixel in FrameBuffer. ... in colour mode 2 it also
    keeps a level 0..3 per entry at 0x50122CAC, which GetPaletteRGB4 reads back.
- **0x484283CD (eol)** -- Rows = a2 = biHeight if biHeight <= 240 (signed), else 240, and
  exth at 0x484283B4 makes rows <= 0 only for an s16 height <= 0. Rows land past FrameBuffer
  whenever y + rows > 240, not only for y >= 240. The doc now states this, so the eol keeps
  just the branch's meaning.
  - was: no rows: height <= 0 (y is not tested: y >= 240 draws past FrameBuffer)
  - now: no rows: only when height <= 0 (y is not tested)
- **0x484284AA (note on the stubs)** -- 0x484284B0 is clr d0; retf, so it is not empty. My
  scanner also covers calls d16/d32 (fa ff / fc ff) and 8-bit branches, which the writer's
  did not. Its only raw hit on the stubs, 0x484284B5 -> 0x484284AD, is the movm register
  byte (c0) of InitializeEventQueue, a false positive. Reflowed to 4 lines.
  - was: three empty stubs before InitializeEventQueue (0x484284B4). No call, jump or
    pointer in the build-941 image (library included) reaches any of them.
  - now: three stub functions (two bare retf, one that returns 0) before
    InitializeEventQueue (0x484284B4). No call, calls, jump, branch or pointer in the
    build-941 image (library included) reaches any of them.

Names:

- Draw2BpFile: keep. It is the firmware's own name: string 0x485B4E5E, referenced from the
  reflection name table at 0x48727E10, with the code pointer at 0x4872771C.
- Draw2BpFile_QueuedExec / Draw2BpFile_Impl / Draw2BpFile_Impl_entry (manual sym): accurate.
  The Impl's only callers are 0x484282BB and 0x484282FD; no outside reference exists.
- Labels Draw2BpFile_Deferred, _Return, _QueuedExec_Return, _Impl_Valid, _ClipHeight
  (0x4842839D, a2 = 240), _RowSetup, _RowLoop, _CopyRow, _RowsDone, _PaletteLoop,
  _Impl_Return: each checked against its branch source and accurate. They mirror
  DrawBitmapFile_Impl's label set one for one. Every branch target in the block is labelled
  (the generator accepted it).
- kn7000_manual.sym section header 'the 2-bpp blitter Draw2BpFile' is wrong. Suggest:
  'Draw2BpFile, the DrawBitmapFile twin (1/4/8-bpp BMP -> 8-bpp FrameBuffer) of the debug
  BITMAP LOAD screen'.
- func_48532395 -> fmmopen_entry (fmmopen is 0x48532390 in kn7000_exports_from_942.sym;
  movm, add, then this entry). func_485323BF -> fmmclose_entry (fmmclose 0x485323BC).
  func_485323E9 -> fmmremove_entry (fmmremove 0x485323E4).
- func_48532468 (movm at 0x48532463) -> fmmread: (a0 = buffer, d0 = max bytes) -> d0 = bytes
  read or a negative error, on the file fmmopen opened. I agree with the writer: device 0's
  handler 0x4853282E reads in chunks of at most 0x7FFF and stops at EOF, and the next table
  slot (0x486646FC, handler 0x485328B5) is the write. The name is inferred; 942 does not
  export it.
- func_4842DB41 (movm at 0x4842DB3C) -> e.g. ColorToMono4Level. It maps a 0x00BBGGRR colour
  to the nearest of the greys 0x00/0x80/0xC0/0xFF, returned as 0xFF0000 / 0xFF6060 /
  0xFFA0A0 / 0xFFFFFF. The squared distances are kept in 16 bits (exthu, movhu). When none
  of the four tests wins, the last one falls through to the ret at 0x4842DC85 with d0 = a
  distance, not a colour, so SetPaletteRGB stores no level. The writer's doubt is confirmed.
  ConvPaletteMono4 (kn7000.sym) follows at 0x4842DC88.
- Data 0x50122CAC -> e.g. Palette2BitLevel, u8[256], levels 0..3 written by SetPaletteRGB in
  colour mode 2 and read by GetPaletteRGB4: agree. 0x50007578 -> ColorMode (u16: 0 = colour
  LCD per CheckColorLcd, 2 = 2-bit LCD per Check2BitLcd, set from 0x50005218 at
  0x484142F5..0x4841433B) and 0x5000757A -> LcdMode: agree. Candidate: 0x50005218 ->
  DisplayType (u16 0/1/2, read by func_4854D778, which picks the colour mode).
- 0x485D67C8 -> e.g. DbBitmapLoad_Origin, the point {s16 0, s16 0} followed by "rb" at
  0x485D67CC: agree, but only once DbBitmapLoadProc is annotated. No operand in this file
  uses it, so no equ is needed here.

Left open:

- 'Colour mode 2 is a 4-level panel' is inferred from four facts: the 0..3 levels
  SetPaletteRGB keeps, the GetPaletteRGB4 calls at 0x48415056 / 0x484155D8 / CaptureLcd, the
  four blue-white target colours of func_4842DB41, and the existing kn7000.sym name
  ConvPaletteMono4 (0x4842DC88). I did not trace the code at 0x48415056 out to the LCD
  controller.
- Only device 0's handler behind 0x48532468 was traced (0x4853282E, a read that stops at
  EOF). The handlers for devices 1 and 2 (0x48565AF6, 0x48584212) were not. The doc's 'at
  most 0x18000 bytes' rests on the d0 count all three receive.
- What lies past 0x502B8000 + 0x18000 (the rest of INSTALL_SCRATCH?) was not checked. If
  fmmopen fails, DbBitmapLoadProc still draws whatever the buffer holds on MT_Draw. That
  belongs to DbBitmapLoadProc's annotation, not this file.
- 'Hidden debug BITMAP LOAD screen' is taken from the task context. I verified only the
  title string "BITMAP LOAD" (program ROM offset 0x1D5E7C) and the name string DbBitmapLoad
  (offset 0x1D59AD), not how the screen is reached.
- Why the height clip differs from DrawBitmapFile_Impl's (an older copy, or a deliberate
  change) cannot be told from the code. With the only caller's y = 0 the two behave
  identically.
- DrawQueue_Alloc's result is stored through without a NULL test. I did not check whether it
  can return NULL. gfx_draw.ann is silent on this for every sibling, so the doc stays silent
  too.
- The repo text at kn7000_manual.sym:2576 says 'the 2-bpp blitter Draw2BpFile'. The code
  refutes this: it takes 1/4/8 bpp and writes 8 bpp. The same header's 'DrawBitmapFile twin'
  is right. The BmpUnpackRow comment (kn7000_manual.sym:2505) still names its third user
  only as 0x484283EE, which is Draw2BpFile_Impl. I did not edit either, since the lane may
  not touch the repo.
- Scratch producer not yet harvested:
  /home/fsanches/compartilhado/tmp/kn7000-bmpann/draw2bp-review/refs.py answers 'who calls,
  calls-s, jumps, branches to or points into [LO, HI)?' by brute force over the image, with
  the library at file offset 0x3B8FD1 = CPU 0x4C000000. Run it from the repo root as:
  python3 /home/fsanches/compartilhado/tmp/kn7000-bmpann/draw2bp-review/refs.py
  baserom/kn7000_program.rom 0x4842829F 0x484284B4. Real hits: 0x4848878D call32 ->
  Draw2BpFile_entry; word 0x4842829F at 0x4872771C; word 0x484282E7 at 0x484282CB, which is
  the mov imm32 inside Draw2BpFile. False positives: 0x484284B5 and 0x48428955. The lead
  should harvest it into ~/compartilhado/research-scratch (this lane may write only under
  its scratch directory). The normalised Impl diff (dbf.n / d2bp.n in the same directory)
  can be regenerated from dump_range.py and is disposable.
