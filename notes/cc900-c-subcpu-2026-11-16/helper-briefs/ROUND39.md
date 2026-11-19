# Round 39 for lane_sub's helpers (2026-11-19, late; read ROUND23.md first: its reading list and rules all hold)

State: 583 functions per payload tree are built from C (v142/subcpu/cc900/*.c are all matching examples).
README.md beside this directory, sections "Tenth promotion" to "Held back", holds today's lessons; the ones that
matter most:
- The firmware's inline assembly is the lower-case `__asm(" nop");` / `__asm(" jr $+2");`.  V4.23 treats it as
  clobbering the scratch registers, so values live across it go to the XIZ family (XIZ, IZ, QIZH, QIZL, IZH), pushed,
  as in the ROM.  `__ASM` does not.  Never use `__IZ` / `__XIZ` (they can crash V4.23).
- Byte / int / pointer locals that live across a call or `__asm` get the XIZ family; declaration order picks which.
- 8-bit narrowing: `uchar + const`, `uchar * const` (const < 256) are done in 8 bits; the ROM's `extz wa; add wa,K`
  / `extz wa; muls wa,K` need `(int)x + K` / `(int)x * K`.  A constant added to an int index of a LOCAL array is folded
  into the frame address (no spelling has stopped that yet).
- An address the ROM builds in XWA and copies to another register is an address expression: `&arr[0]`,
  `(unsigned char *)(void *)arr`.  A row kept apart from its column: `(unsigned char *)(unsigned long)(base + (int)r *
  stride)` or a struct cast on the record's byte address (`((struct s *)&arr[(int)i * st])->f[j]`).
- A unary plus stops constant folding of a sum (`+(x * K + 0x10) + ptr`); an `unsigned long` global added last is a
  memory operand.
- Odd-size record copies (71, 11, 295 bytes: words plus one `ldi`) are blocked; skip functions that need one.
- Tools: `python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/idiff_full.py LISTING CFILE FUNC` (every
  difference, also in functions that span labels); `span_refs.py` (is a label range one function); `bin/show.py LABEL`.

Files sub_<TAG>_39a.c, _39b.c, _39c.c; one spelling of each function per file; each passing
    bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c
A scratch generator, if you write one, stays in your scratch dir; say its path in the report so lane_sub can keep it.
