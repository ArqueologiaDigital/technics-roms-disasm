# Probes for tracker kn5000-wxn (WSA1 naming leads)

| script             | question it answers                                                                                                                                                                                                                                                                                                                                                                                   | run                                                                             |
|--------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `wsa1_wxn_refs.py` | R1: does anything outside SMF file-layer copy E (prom_b 0xF77EDB-0xF77FE8) reach it; R2: is the stray `ret` at prom_a 0xFBE134 reached, and is 0xFBE135 only posted from 0xFBDCAC; R3: are copies A / D / E laid out alike and which routines are byte-identical; R4: do the floppy-format readers index rows 4 / 5 of the 0xFF3D39 matrix; R5: does the ROM spell "MIDI FILE L0AD" with a digit zero | `python3 notes/open6-kn5000-d/wsa1/probes/wsa1_wxn_refs.py` (exit 0 = all PASS) |

The signal read: the two CPU-1 images `wsa1/original_ROMs/wsa1_prom_a.ic12` (CPU address 0xF80000 + offset) and
`wsa1_prom_b.ic13` (0xF00000 + offset), scanned at every byte offset for call / jp (opcodes 0x1D / 0x1A + 24-bit
address), calr / jrl (0x1E / 0x1B + signed 16-bit displacement from the next instruction), jr (0x60-0x6F + signed 8-bit)
and bare 24-bit little-endian values.  PASS on R1 means no instruction-shaped reference from outside copy E lands in
it; the remaining 24-bit hits it lists (prom_a 0xFCF65A inside `PanelOpTable_FCF653`, prom_a 0xFD2303 straddling two
instructions before the `jrl` at 0xFD2304, prom_b 0xF7DA67) and the `calr`-shaped prom_b 0xF710CA (the displacement
bytes of `calr SongStore_SeekBlock_Copy` at 0xF710C8) were checked against the source by hand on 2026-11-02 and are
not references.  Output of the 2026-11-02 run: every check PASS.
