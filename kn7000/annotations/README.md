# annotations/ — labels and comments for converted code

`tools/gen_program_s.py` turns the functions listed in its `CONVERT` set into
real MN10300 assembly in `src/program.s`. On its own that output is bare: numeric
branch targets, no comments. The `*.ann` files here add the interpretation. A
converted function with any annotation in it is emitted as a **labelled listing**:

* its name, and each register-save `_entry` point inside it, become real labels;
* every branch or jump that lands inside it must land on a named label (the
  generator stops with an error listing any that do not);
* an operand that equals a named code address (function, local label) or a
  named data address prints the name — `mov (GfxDrawEnable), d0`, not
  `mov (0x5002a01c), d0`;
* `doc` lines go into the function's header comment, `note` lines above an
  instruction, `eol` text after it.

The bytes never depend on any of this: `kn7asm` resolves every name back to the
same number, and `make verify` still demands a byte-identical image. Labels are
checked too — a label whose name is also an `.equ` (a function name from
`src/symbols.inc`) must land on that `.equ`'s address.

Functions without annotations are emitted exactly as before.

## Format

One item per line. A line starting with `;` is a comment in the `.ann` file
itself. Addresses are **build-941 CPU addresses**, in hex.

```
ADDR doc   TEXT       header comment line for the function that starts at ADDR
ADDR label NAME       a label at ADDR (an identifier)
ADDR note  TEXT       a comment line above the instruction at ADDR
ADDR eol   TEXT       the end-of-line comment of the instruction at ADDR
equ  NAME  ADDR TEXT  a name for a data address (work RAM, I/O, a ROM table)
```

`doc` and `note` repeat, in file order. `ADDR` must be the start of an
instruction inside a converted function (`doc`: the start of a function), or the
generator stops. A label may not reuse a name from the symbol files, nor sit on
an address that already has one: function boundaries and `_entry` points belong
in `kn7000_manual.sym`, local labels belong here.

Naming follows the KN5000 disassembly: `<Function>_<what>` — e.g.
`DrawBitmap_Deferred`, `DrawBitmap_Impl_RowLoop`.

## Other builds

`make program-src-sp7001` carries the annotations to build 942 the way it carries
`FUNC_DOC`: code addresses through the exact offset map, data names through the
symbol porter (a data name with no counterpart is dropped), and CPU addresses
quoted in comment text are translated.

## Working on one file

```
python3 tools/gen_program_s.py --ann annotations/gfx_draw.ann --out /path/to/scratch.s
python3 tools/kn7asm.py /path/to/scratch.s -I . -o /path/to/scratch.rom
cmp /path/to/scratch.rom baserom/kn7000_program.rom
```

`--ann` (repeatable) uses only the named files, so a half-finished file cannot
break anyone else's run.

## Files

| file           | covers                                                                  |
|----------------|-------------------------------------------------------------------------|
| `gfx_draw.ann` | the blitters and text renderer, `DrawBitmap` .. `DrawStringCentered`    |
