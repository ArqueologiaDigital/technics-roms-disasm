# floppy-others probes

The scripts that measured what `notes/floppy-others-2026-10-29/README.md` states. Inputs are the softlist
images, unzipped as `<model>/<disk>/<disk>.img` (WSA1R: `wsa1/<disk>.img`) in a scratch directory, or the
build tree `floppy/build/<model>/<disk>/` after `make -C floppy gate`. Run each with `python3 -I` from that
directory unless the row says otherwise.

| script           | question it answers                                                                                  | run (cwd)                                                      |
|------------------|------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|
| `fatls.py`       | what files does a disk hold (name, size, attributes, date)                                           | `fatls.py IMG...`                                              |
| `kinds.py`       | which file kinds a model's disks hold, by count and bytes                                            | `kinds.py wsa1 kn6000 kn7000` (unzipped images)                |
| `ikd_survey.py`  | the magic and version word of every file, per kind                                                   | `ikd_survey.py kn6000 kn7000` (unzipped images)                |
| `z104.c`         | a zlib 1.0.4 compressor (full library) used before `floppy/tools/kd/zdeflate104.c` existed           | build against zlib-1.0.4's objects, see the file               |
| `z104_first.py`  | does zlib 1.0.4, level 6, reproduce the first deflate stream of every file, and is adler32 after it  | `Z104=<z104 binary> z104_first.py kn6000 kn7000` (unzipped)    |
| `lzss_brute2.py` | which LZSS parameters decode a 'J KD' stream: it scores formula families against the known TCMP head | needs `kn7000/ca7001/ca7001.img` under cwd                     |
| `jkd.py`         | the 8 KB-ring LZSS that won, decoding 01SLWLTZ.CMP to exactly its header size                        | needs `kn7000/ca7001/ca7001.img` under cwd                     |
| `tcmp_survey.py` | does every .CMP payload's heap tile, and how big is the typed text (5.3x)                            | `tcmp_survey.py 'kn6000/*/*.cmp.p1.ref'` (floppy/build)        |
| `pmt_tlv.py`     | does a .PMT payload walk as KN5000-style tag/length records (no: every start resynchronises)         | `pmt_tlv.py kn6000/ca6000s/09SUNSHN.pmt.p1.ref` (floppy/build) |
| `sqt_try.py`     | the .SQT event lengths: how many track chains parse to 0x82 under a candidate length table           | `sqt_try.py 'kn*/*/*.sqt'` (floppy/build)                      |

The container round trip itself is `python3 -I floppy/tools/kd/kd.py verify <extracted files>`, run on every
file of the 27 KN6000/KN7000 disks: 397 KD and 15 K1 containers re-encode byte-identical. The disk gate is
`make -C floppy gate-wsa1 gate-kn6000 gate-kn7000`.

## What the signals mean

- `z104_first.py`: `body-ok adler-follows` means the stream body equals zlib 1.0.4's output after its 2-byte
  header was dropped, and the 4 bytes after the stream are its big-endian adler32. A modern zlib gets
  `body-BAD` on every stream of more than 4096 symbols (the block split, `floppy/tools/kd/README.md`).
- `lzss_brute2.py`: the score is the number of positions out of 75 known bytes (the 3 zeros at +0x0D, the
  spaces at +0x31..+0x6E and "Slow Waltz") that a parameter set decodes right. The best of the 4-bit-length
  families reaches 66. The 13-bit position with a 3-bit length (`jkd.py`) decodes all 48,093 bytes and
  consumes the stream exactly.
- `sqt_try.py`: `END` counts the chains that reach an 0x82 under the table. With 0x8n +2, 0x86 +0
  (`floppy/tools/kd/kn_sqt.py`), 412 of 417 do.
