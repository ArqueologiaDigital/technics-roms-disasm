# open4/wsa1-b probes (2026-10-31)

Evidence for the eleven WSA1R emulation-gap items lane open4/wsa1-b closed or blocked
(gaps I, K, N, P, R, W, X and four appendix rows of `notes/WSA1-EMULATION-DISASM-GAPS.md`).
Run from `wsa1/`.  The FDC checks for gaps W and X were added to the existing
`notes/prom_a_fdc_checks.py` (sections 8 and 9) rather than here.

| script                      | question it answers                                                                                                                                                                                        | command                                                                |
|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| `prom_c_ram_cell_census.py` | Gap I: does anything in prom_c read RAM 0x008517?  Appendix: does anything re-arm the key-event flush counter 0x00E2E1 after power-on?  Read off the ROM bytes and the committed linear listing, 18 checks | `python3 notes/open4-b-probes/prom_c_ram_cell_census.py [-v]`          |
| `wsa1_sch_open4_crops.py`   | Gaps N, K, W and the 0x7F0000 / 0x00E00000, AN0-AN3 and hard-disk rows: renders the service-manual crops each reading came from, and pixel-tests that IC1 pin 40 (INT6) is driven by IC9, not tied to +5D | `python3 notes/open4-b-probes/wsa1_sch_open4_crops.py [outdir]`        |
| `../prom_a_fdc_checks.py`   | Gap W: do only 0x80 / 0x00 / 0x02 ever reach 0x7B0004, each on the path the DSR reading predicts?  Gap X: is a SCAN opcode ever stored at Fdc_CommandByte?                                                | `python3 notes/prom_a_fdc_checks.py [-v]`                              |

What each signal means:

* `prom_c_ram_cell_census.py` passes when 0x008517 is spelled only by the `or (0x008517),0x03` at
  0xF997A9, when the only base below it within reach is the 61-entry velocity table at 0x84DA
  (indices 0..60), and when 0x00E2E1's only writers are `decw 1,(0x00e2e1)` at 0xF98CE2 and
  RamImage_Copy (ROM 0xFCB4EA -> RAM 0xE2DF, 0x10D8 bytes; the seed word at ROM 0xFCB4EC is
  0x03E8 = 1000), which only RESET calls.
* `wsa1_sch_open4_crops.py` needs the image-only PDF
  `~/compartilhado/KN7000/service_manual/SX-WSA1R Service Manual.pdf` (not committed; exit 2
  without it).  Its one automated test scans page 19 at 400 dpi, rows 2355-2384, x 4500-5400: the
  dark run from IC9 pin 4 must end at IC1 pin 40's corner (x 5153) and the +5D run must start at
  pin 44's dot (x 5251), with only the three thin pin-41/42/43 verticals between them.  The crops
  it writes are regenerable and are not committed.
* `prom_a_fdc_checks.py` sections 8-9 assert the three spellings of 0x7B0004 (one read, two
  writes), the four callers of Dev7B_WriteDsr_Shadowed and the immediate each pushes, that
  Dev7B_WriteDsr is reached only from two routines with no caller, and the five stores to
  0x605A18 with their values.
