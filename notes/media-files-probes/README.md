# Media-files probes (lane media-files, 2026-10-30)

The scripts behind `../media-files-2026-10-30/README.md`. The wave-ROM probes read the private dumps
read-only (`$KN7000_WAVE_DIR`, default `~/compartilhado/technics_romsets/kn7000`; `$KN5000_IC307`, default
`~/compartilhado/technics_romsets/kn5000/kn5000_waveform_rom.ic307`) and print numbers only: no sample
data is written. They need numpy.

| script                       | question it answers                                                                                                                                                                               | run                                      |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------|
| `media_inventory.py`         | for every census tree, which items are pictures, PCM recordings or MIDI; is each one's media file committed and read directly or converted at build; is any converter output tracked (2026-10-31) | `python3 media_inventory.py [--list]`    |
| `pcm_encoding_probe.py`      | which reading of a recording's words is right: two's complement or offset binary or sign-magnitude, byte order, 16-bit or 8+8                                                                     | `python3 pcm_encoding_probe.py`          |
| `ic307_kn7000_match.py`      | do KN5000 IC307's waves occur in the KN7000's wave chips, in which chip, and what format does the KN7000 directory give them                                                                      | `python3 ic307_kn7000_match.py [--list]` |
| `ic307_records_vs_kn7000.py` | are IC307's parameter records the Y-chip half (words p1, p3, p5 ...) of the KN7000 records that play the same recording                                                                           | `python3 ic307_records_vs_kn7000.py`     |

Run each from the repository root as `python3 notes/media-files-probes/<script>`.

## The signals, and the results of 2026-10-30

- `pcm_encoding_probe.py`. For each recording it counts the steps between neighbouring samples that are
  larger than half the full scale (a wrong reading jumps by about full scale wherever the true signal
  crosses the reading's discontinuity), and the correlation between a word's low and high byte (near 0
  for a 16-bit sample, near 1 for two neighbouring 8-bit samples).
  - KN7000, recordings whose directory says 16-bit: s16le has the fewest jumps in 1,721 of 1,806 (main) and
    911 of 917 (sub); every other recording is a tie (silence). Byte correlation > 0.5 in 0 of 2,720.
  - KN7000, 8-bit (P bit 3): signed 8-bit has the fewest jumps in 426 of 445 and 499 of 514, the rest tie;
    byte correlation > 0.5 in 917 of 959.
  - KN5000 IC307: s16le wins in 1,165 of 1,391, ties 169; 183 items have a byte correlation > 0.5.
  - IC307's 256-word sine `P0_W0000_Sine` is within 0.26 LSB of one period of `32767 sin`, and it is exactly
    the even samples of the KN7000's 512-sample sine `Main_P00_W000`.
- `ic307_kn7000_match.py`. 1,342 of IC307's 1,413 waves (1,391 of 64 B or more were searched) occur verbatim
  in a KN7000 chip: 1,162 in IC203 and 180 in IC207, both Y chips, none in an X chip. 1,327 match over their
  whole length and 1,339 start at a KN7000 recording's first sample. The KN7000 directory plays 1,173 of them
  as 16-bit and 169 as 8-bit. IC307's byte correlation is > 0.5 in 0 of the 1,170 16-bit ones and in 152 of
  the 169 8-bit ones, so the correlation rule that `gen_ic307_wav_manifest.py` uses for the 71 unmatched items
  is calibrated on these.
- `ic307_records_vs_kn7000.py`. Of IC307's 1,495 directory entries, 1,430 have a wave at a KN7000 recording's
  first sample. For 456 of them the record's words after its head equal a partner KN7000 record's parameter
  words p1, p3, p5, ...; for 965 the IC307 record is head-only and a partner has at most one parameter word;
  9 match no partner; none matches the control (p0, p2, p4, ...).

`media_inventory.py`'s result is in the lane notes (section "Inventory"); its 2026-10-31 form, which also
counts untracked media files and tracked derived outputs, is in `../media-build-2026-10-31/README.md`.
