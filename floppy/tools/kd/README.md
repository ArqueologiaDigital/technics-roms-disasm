# floppy/tools/kd -- the file containers of the SX-KN6000 and SX-KN7000 disks

Most files a KN6000 or KN7000 writes to a diskette are wrapped in a small header and compressed. These tools
take such a file apart and put it back together byte for byte. They let a disk's sources hold the
**uncompressed** payload, typed, and generate the compressed bytes.

| file                 | question it answers                                                                 | how to run                                        |
|----------------------|-------------------------------------------------------------------------------------|---------------------------------------------------|
| `kd.py`              | how is a file wrapped; does every wrapper re-encode from its payload                | `python3 -I kd.py verify FILE...`                 |
| `lzss_j.py`          | the 'J KD' (KN7000) LZSS: decoder, and the encoder that reproduces the disks        | `python3 -I lzss_j.py encode IN OUT`              |

## The containers

The first byte names the model: `I` = KN6000, `J` = KN7000. `kd.py`'s docstring gives the byte layout. In
short:

| magic                        | files                               | parts | codec                       |
|------------------------------|-------------------------------------|-------|-----------------------------|
| `I KD`, `IK D`               | .CMP .TM .PMT .EFC; .SQT .LSW       | 1; 2  | deflate, zlib 1.0.4 level 6 |
| `J KD`                       | .CMP .PMT .MSP; .SQT .LSW           | 1; 2  | LZSS, 8 KB ring (lzss_j.py) |
| `I K\x01`, `J K\x01`         | .AST (custom-data flash), .CST      | 1     | deflate, zlib 1.0.4 level 6 |
| `IK \0`, `JK \0`, and others | .HMP .FAV .MD; .JPG .CNV .TXT .ACT  | 0     | stored                      |

A deflate part is the zlib stream **without** its 2-byte header (78 9C) and **with** its 4-byte big-endian
adler32. The header's compressed size counts the absent two bytes. So the instrument wrote a full zlib stream
and dropped the first two bytes.

## Why zlib 1.0.4

The KN7000 program links zlib 1.0.4 (`kn7000/kn7000_manual.sym`, section "zlib 1.0.4 (deflate and
inflate)"; `deflateInit2_` checks the version string "1.0.4"). Its writers call `deflateInit_(strm, level,
...)`, which means windowBits 15, memLevel 8 and the default strategy.

A modern zlib at the same settings reproduces every **single-block** part. It fails on every part longer than
4096 symbols. The blocks show why: the disks' first block ends after exactly 4096 symbols, while modern zlib
writes one block. zlib 1.0.4's `_tr_tally()` ends a block early at each multiple of 4096 symbols when its size
estimate says that pays. zlib 1.1 and later compile that test only under `-DTRUNCATE_BLOCK`, and at multiples of
8192. So no later release can reproduce these files.

The coder is `kn7000/tools/zlib10_deflate.py`, lane customdata's pure-Python transcription of 1.0.4's deflate,
the repository's only one. `kd.py encode deflate104` appends the adler32. Until 2026-10-29 this directory vendored
zlib 1.0.4's C deflate (zlib.net/fossils `zlib-1.0.4.tar.gz`, SHA-256
`e5c260cd3db1370fb3e0c193e9cbd9f127a9bd055d622b3fb55b82747f6e5b24`), which gives the same bytes on every part
of the 27 disks. It was dropped so that there is one implementation. The C version was 40 times faster
(0.1 s against 3.7 s for a 1.9 MB custom-data image), but it needed a compiler and third-party sources in the tree.

## Measured

`python3 -I kd.py verify` over every file of the 21 KN6000 and 6 KN7000 softlist disks (2026-10-29):
397 KD and 15 K1 containers rebuild byte-identical, and 122 files are stored as is. The 15 K1 files are
10 .AST and 5 .CST. That includes all 10 custom-data images: each .AST inflates to the SHA-1 of one
`*.ic21` (KN7000) or `01ctmini.ic18` (KN6000) dump, and re-deflates to the disk's bytes. The recipe is
`notes/floppy-others-2026-10-29/probes/README.md`.
