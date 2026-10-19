# Probes behind `notes/ic19-picture-rom.md`

| script     | question it answers                                                                                    | run                                                            |
|------------|--------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|
| `probe.py` | how big are the 100 pictures and what frame size; is entry 0 (`0x00000A37`) a sum, an XOR or a size?   | `make verify-picture && python3 -I notes/ic19-picture-rom-probes/probe.py` |

The checks on the read itself (mirroring, directory, JPEG decoding, firmware references) are in the
private ROM repository, `technics_roms` `roms/kn7000/real_dump_v1.3_b893/ic19-analysis/`, beside the read.
