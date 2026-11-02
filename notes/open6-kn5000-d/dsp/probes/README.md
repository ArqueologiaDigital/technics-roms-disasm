# probes -- sub-lane dsp (lane open6/kn5000-d, 2026-11-02)

| script                     | question it answers                                                                                                                                                         | run (from the repo root)                                           |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| `wsa1_descriptor_cells.py` | Do the SX-WSA1R's DSP records (fields +0/+4/+8) carry tag-0x4C descriptor pokes, so a cross-product descriptor-slot test can be run? Measured: 0 cells in 48 of 48 records. | `python3 notes/open6-kn5000-d/dsp/probes/wsa1_descriptor_cells.py` |

The main instrument of this sub-lane lives beside the code it measures, in the dsp tree:
`dsp/tools/bit11_xprod.py` (row in `dsp/tools/README.md`; output committed as
`dsp/analysis/data/bit11_xprod-2026-11-02.txt`).
