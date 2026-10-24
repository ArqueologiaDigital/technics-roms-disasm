# KN2400 layout probes

| script                | question it answers                                                |
|-----------------------|--------------------------------------------------------------------|
| `ram_linked_range.py` | Is file `0x3285be`-`0x3965bb` linked for work RAM at `0x50120000`? |

Run from `kn2400/`, after `make baserom`:

    python3 notes/layout-probes/ram_linked_range.py baserom/kn2400_program.rom ../../tools/unidasm

The signal is where each `call` / `calls` / `jmp` with an absolute target lands. A range
decoded at the wrong link address has PC-relative transfers to code outside the range that
land nowhere. Output on 2026-10-24:

    A. flash code -> RAM window: 6876 transfers, 6876 land on an instruction start of the RAM-linked decode
    B. range decoded at its flash address : 15011 transfers, 14382 land in the image or the RAM window
    B. range decoded at 0x50120000        : 15011 transfers, 15006 land in the image or the RAM window
    C. switch table at 0x48405c48: 0x50145241 (file 0x34d7ff), 0x50145251 (file 0x34d80f), ...
    D. crt0 vector target 0x5018df0b = file 0x3964c9 | 24-byte tail: 0200fadfbe85724800001250...

The two B rows differ only in the transfers from the range back into flash. Their
displacements are right only for the RAM address.
