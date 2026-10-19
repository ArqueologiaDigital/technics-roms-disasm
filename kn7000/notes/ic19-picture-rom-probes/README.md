# Probes behind `notes/ic19-picture-rom.md`

| script     | question it answers                                                                                        | run                                                                        |
|------------|------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|
| `probe.py` | how big are the 100 pictures and what frame size; what PICTURE number entry 0 gives; the sums tried before | `make verify-picture && python3 -I notes/ic19-picture-rom-probes/probe.py` |

The checks on the read itself (mirroring, directory, JPEG decoding, firmware references) are in the
private ROM repository, `technics_roms` `roms/kn7000/real_dump_v1.3_b893/ic19-analysis/`, beside the read.
