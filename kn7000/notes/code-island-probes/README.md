# code-island probes

Lane `code-island` of the open-items effort (2026-10-30): code that the MN10300 trees emitted as
data.  The notes are `../code-island/README.md`; the generators the lane changed are
`kn7000/tools/gen_program_s.py` (TAIL_CODE), `kn7000/tools/gen_data_s.py` (`tail_code.txt`) and
`kn7000/tools/gen_image_s.py` (re-encoding of long forms).

| script            | question it answers                                                                                                                                                                                                                                                                                                                                                   | run (from the repository root, after a build of the trees it reads)                             |
|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| `code_in_data.py` | In every MN10300 tree (the four KN7000 program builds, the KN6000, KN6500, KN2400 and the HD-SX3 plug-in): is any `call` / `jmp` / branch target, any code-named label or any code pointer of a typed table on a byte the source emits as DATA (opaque or generic `.incbin_range`, reader rows, typed records, `.byte`)? Does any instruction fall through into data? | `python3 kn7000/notes/code-island-probes/code_in_data.py [tree ...]` (`--list` names the trees) |

## What `code_in_data.py` reads

It assembles each tree with `kn7000/tools/kn7asm.py`'s own `Assembler` (no output is written) and
records, for the final pass, which bytes an instruction line emits and which a data directive
(`.byte` / `.word` / `.long` / `.ascii(z)` / `.space` / `.align` / `.incbin(_range)`, a data macro, a
`.zlib` stream), with each byte's CPU address (`.mnbase`).  Its signals, per tree:

| kind    | signal                                                                                                               | what it means when it is not 0                                                         |
|---------|----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| `T`     | a `call` / `calls` / `jmp` / `bra` / `bCC` whose absolute target is a data byte                                      | code the source spells as data                                                         |
| `T-mid` | the same target inside an instruction, not on its first byte                                                         | a wrong split of the code                                                              |
| `F`     | an instruction that can fall through (anything but `ret` / `retf` / `rets` / `rti` / `jmp` / `bra`) followed by data | code running on into bytes the source calls data                                       |
| `L`     | a label named like code (`func_<ADDR>`, `loc_<ADDR>`, `*_entry`, `*_entry_L<hex>`) defined on a data byte            | a name the generators gave code, on data                                               |
| `P`     | a `.long` whose value lands on a data byte a `T` / `L` / `F` case shows is code, or inside an instruction            | a typed table pointing at code that is not emitted as code, or at no instruction start |

The exit status is 1 when any tree has a `T`, `T-mid`, `F` or `L` case.  Targets outside the image
(RAM, the host program, other chips) are not checked.  An instruction the encoder cannot reproduce
and the generator keeps as a `.byte` escape counts as data here, on purpose: it is code emitted as
data.

The figures before and after the lane are in `../code-island/README.md` ("Probe figures").
