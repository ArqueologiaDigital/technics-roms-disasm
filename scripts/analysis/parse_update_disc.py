#!/usr/bin/env python3
r"""parse_update_disc.py -- read a KN5000 system-update floppy image the way the firmware does.

QUESTION ANSWERED
-----------------
"What is on this update disc: which update type does the KN5000 see, what does it write where, which
firmware version and which sub-CPU payload does it carry, and are the bytes a known release?"
(tracker kn5000-87m)

Two views are printed side by side, because the firmware does not use the file system:

  FAT12 view      the boot sector's BPB and every directory entry (name, size, first cluster and the
                  logical sector it starts at), read with floppy/tools/fat12lib.py.
  firmware view   what v10's updater reads (v10/maincpu/boot/system_handlers.s):
                  * Detect_Disk_Type reads logical sector 0x21 (33) and compares its first 38 bytes with
                    the eight FILETYPE_SIG_* strings of boot/boot_data_tables.s (read from that source
                    here); a match gives type 1-8, anything else 0xFF;
                  * every handler reads its payload from logical sector 0x24 (36) on, not by name:
                    types 1 and 3 (HANDLE_UPDATE_FILE_TYPE_ID_001h/003h) 1 MB to 0x800000, then 1 MB
                    to 0x900000; type 5 0x800 sectors (1 MB) to Custom Data Flash 0x300000; type 6 0x400
                    sectors (512 KB) to the HD-AE5000 flash 0x280000; type 7 (Program PCK) and type 8
                    (Table PCK) a SLIDE4K stream decompressed into the 0x800000 window
                    (LZ_Decompress_Init: 8 magic bytes, a 24-bit big-endian size, then the stream); type 7
                    then needs a second stream that starts with "SLIDE" right after the first one ends,
                    and copies it verbatim to IC19 0x3E0000 (LZSS_Decompress_ToFlash, after
                    Flash_EraseSectorWithBankSelect of 0x3E0000 and 0x3F0000);
                  * types 2 and 4 (second disc of a two-disc set) are refused (SHOW_ILLEGAL_DISK_MESSAGE).

For a type-7 disc it decompresses stream 1 (stopping, as the firmware does, when the output reaches the
declared size), prints the firmware version byte at image offset 0x1FFFE8 (CPU 0xFFFFE8), and checks the
SHA-1 of the program image and of stream 2 (raw and decompressed) against the known releases: program
v5-v10 (the Makefile's KN5000_V*_SHA1 and the tracked original_ROMs/), sub-CPU payload v1.40-v1.42
(original_ROMs/kn5000_subprogram_v14N{,_compressed}.rom).  For type 6 it checks the 512 KB against the
HD-AE5000 releases (v1.10i, v1.15i, v2.01i, v2.06i).  No checksum is stored on the disc and the firmware
verifies none (it programs the flash without a read-back, flash-programming.md); the SHA-1s here are the
tool's own identification.

RUN
---
    python3 scripts/analysis/parse_update_disc.py IMAGE.img [IMAGE2.img ...] [--extract DIR]

--extract writes, per image, the files of the FAT12 view and the firmware's payload(s): stream1.bin
(decompressed program / table image), stream2.slide (the verbatim sub-CPU stream), stream2.bin (its
decompression), payload.bin (types 1/3/5/6).  Extract into a scratch directory; never commit them.
Exit status 0 when every image was readable, 1 otherwise.
"""
import argparse
import hashlib
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'floppy', 'tools'))
import fat12lib  # noqa: E402

SECTOR = 512
SIG_SECTOR = 0x21           # Detect_Disk_Type: ld xwa, 0x21; ld bc, 1
DATA_SECTOR = 0x24          # every HANDLE_UPDATE_FILE_TYPE_ID_00Nh: ldw wa/bc, 0x24; LZ_Decompress_Init: 36
SIG_LEN = 0x26              # pushw 0x26 before each String_Compare
VERSION_OFFSET = 0x1FFFE8   # FIRMWARE_VERSION, CPU 0xFFFFE8 in the 2 MB program image

TYPE_NAMES = {
    1: 'Program, disc 1 of 2 (uncompressed)', 2: 'Program, disc 2 of 2 (refused: Illegal Disk!)',
    3: 'Table data, disc 1 of 2 (uncompressed)', 4: 'Table data, disc 2 of 2 (refused: Illegal Disk!)',
    5: 'CMPCUSTOMDATA (Custom Data Flash image)', 6: 'HD-AE5000 program (HD-AEPRG)',
    7: 'Program PCK (SLIDE4K program + sub-CPU payload)', 8: 'Table data PCK (SLIDE4K)',
}

# SHA-1 of known release images.  v5/v6/v8: the Makefile's KN5000_V*_SHA1 (dumps kept out of git);
# v7/v9/v10 and the sub-CPU and HD-AE5000 v2.06i images: the tracked original_ROMs/ files.
PROGRAM_SHA1 = {
    '7b69a8aaa84ee3d337acc0c29c34154c5da2df32': 'program v5',
    '51108e2d75b180a034395e90bd40ca2bd2a0adfb': 'program v6',
    '4c682cb248034a2de04c688b0a45654b8726bffb': 'program v7',
    'a10a6f5a35175b74c3cfb42cef3bdf571c2858bb': 'program v8',
    'd9a3b462b1f9302402e8d37aacd15f069f56abd9': 'program v9',
    '1f2abc5b1b7b9e16fdf796f26d939edaceded354': 'program v10',
}
SUBCPU_SHA1 = {
    '13098dd150c5a6083a5d15a63d5d785802d8e8ae': 'sub-CPU v1.40, compressed',
    'ac9791441ceb13748a2196a0a6a400431d6aed5e': 'sub-CPU v1.41, compressed',
    '13718900afd55cb2e5ff0be213ba1f5dd14bc174': 'sub-CPU v1.42, compressed',
    'b7f471522ab3125e5eb42c7368d57a56084ce32a': 'sub-CPU v1.40',
    '39b0dd7b23abd3cdfedce65dd4fef0e2ab16ab69': 'sub-CPU v1.41',
    '5c3a2b9311318c19e1a29ca460dea693bcb2c405': 'sub-CPU v1.42',
}
HDAE_SHA1 = {
    '6019f3c28b6277730418974dde4dc6893fced00e': 'HD-AE5000 v1.10i',
    '581fa58e2cd6fe381cfc312c73771d25ff2e662c': 'HD-AE5000 v1.15i',
    '0160c17baa7b026771872126d8146038a19ef53b': 'HD-AE5000 v2.01i',
    'c4da28f0ad16b1288774af761b3729142e8050b3': 'HD-AE5000 v2.06i',
}


def sha1(b):
    return hashlib.sha1(b).hexdigest()


def known(h, *tables):
    for t in tables:
        if h in t:
            return t[h]
    return 'not a known release'


def signatures():
    """type -> 38-byte signature, from the FILETYPE_SIG_* lines of v10's boot_data_tables.s.  The
    type numbers are the order Detect_Disk_Type tests them in (1, 2, 3, 4, 5, 6, 7, 8 = PROGRAM_1,
    PROGRAM_2, TABLE_1, TABLE_2, CMPCUSTOM, HDAE_PRG, PROGRAM_PCK, TABLE_PCK)."""
    src = open(os.path.join(ROOT, 'v10', 'maincpu', 'boot', 'boot_data_tables.s'), 'rb').read().decode('latin1')
    sig = dict(re.findall(r'^FILETYPE_SIG_(\w+):\s+aligned_string "([^"]*)"', src, re.M))
    order = ['PROGRAM_1', 'PROGRAM_2', 'TABLE_1', 'TABLE_2', 'CMPCUSTOM', 'HDAE_PRG', 'PROGRAM_PCK', 'TABLE_PCK']
    out = {}
    for t, k in enumerate(order, 1):
        s = sig[k].encode('latin1')
        assert len(s) == SIG_LEN, (k, len(s))
        out[t] = s
    return out


def slide4k_stream(data, pos):
    """Decode the SLIDE4K stream whose 11-byte header starts at data[pos], stopping when the output
    reaches the declared size (the firmware's loop condition).  Returns (header magic, declared size,
    output, offset of the first byte after the stream)."""
    magic = data[pos:pos + 8]
    size = (data[pos + 8] << 16) | (data[pos + 9] << 8) | data[pos + 10]
    i = pos + 11
    window = bytearray(4096)
    wp = 0xFEE
    out = bytearray()
    while len(out) < size and i < len(data):
        flags = data[i]
        i += 1
        for bit in range(8):
            if len(out) >= size or i >= len(data):
                break
            if flags & (1 << bit):
                b = data[i]
                i += 1
                out.append(b)
                window[wp] = b
                wp = (wp + 1) & 0xFFF
            else:
                lo, hi = data[i], data[i + 1]
                i += 2
                off = ((hi & 0xF0) << 4) | lo
                for k in range((hi & 0x0F) + 3):
                    b = window[(off + k) & 0xFFF]
                    out.append(b)
                    window[wp] = b
                    wp = (wp + 1) & 0xFFF
    return magic, size, bytes(out), i


def show(path, extract=None):
    data = open(path, 'rb').read()
    print('=' * 78)
    print('%s  (%d bytes, SHA-1 %s)' % (path, len(data), sha1(data)))
    ok = True
    # ---------------------------------------------------------------- FAT12 view
    try:
        img = fat12lib.Image(data)
        b = img.bpb
        print('FAT12: OEM %r, %d B/sector, %d sectors, %d per cluster, %d FATs x %d sectors, %d root entries,'
              ' media 0x%02X, data area at sector %d'
              % (data[3:11].decode('latin1'), b.bytes_per_sector, b.total_sectors, b.sectors_per_cluster,
                 b.fats, b.sectors_per_fat, b.root_entries, b.media, b.data_offset // SECTOR))
        files = [e for e in img.files() if not e.is_dir]
        for e in files:
            first = img.cluster_offset(e.cluster) // SECTOR if e.cluster else None
            print('  %-14s %9d B  cluster %-4s sector %-4s %s' % (
                e.path(), e.size, e.cluster, first, 'contiguous' if e.chain == list(range(e.cluster, e.cluster + len(e.chain))) else 'FRAGMENTED'))
            if extract:
                os.makedirs(extract, exist_ok=True)
                with open(os.path.join(extract, fat12lib.unit_name(e)), 'wb') as fh:
                    fh.write(img.file_bytes(e))
    except Exception as ex:   # noqa: BLE001 -- report and go on to the firmware view
        print('FAT12: unreadable (%s)' % ex)
        img, files = None, []
    # ---------------------------------------------------------------- firmware view
    sec = data[SIG_SECTOR * SECTOR:SIG_SECTOR * SECTOR + SECTOR]
    sigs = signatures()
    dtype = next((t for t, s in sigs.items() if sec[:SIG_LEN] == s), 0xFF)
    print('firmware: sector 0x21 starts %r' % sec[:64].split(b'\0')[0][:70].decode('latin1'))
    if dtype == 0xFF:
        print('firmware: Detect_Disk_Type -> 0xFF (not an update disc; the updater ignores it)')
        return ok
    print('firmware: Detect_Disk_Type -> type %d, %s' % (dtype, TYPE_NAMES[dtype]))
    owner = None
    if img:
        for e in files:
            if e.cluster and img.cluster_offset(e.cluster) == DATA_SECTOR * SECTOR:
                owner = e
    print('firmware: payload read from logical sector 0x24 (offset 0x%X)%s' % (
        DATA_SECTOR * SECTOR, ', = the start of %s' % owner.path() if owner else ', which no FAT entry starts at'))
    base = DATA_SECTOR * SECTOR
    if dtype in (7, 8):
        magic, size, out, end = slide4k_stream(data, base)
        print('  stream 1: magic %r, declared size %d (0x%X), %d compressed bytes (0x%X-0x%X)%s' % (
            magic, size, size, end - base - 11, base, end - 1, '' if len(out) == size else ', SHORT: %d' % len(out)))
        h = sha1(out)
        print('  stream 1: decompressed SHA-1 %s = %s' % (h, known(h, PROGRAM_SHA1)))
        if dtype == 7 and len(out) > VERSION_OFFSET:
            print('  stream 1: firmware version byte at 0xFFFFE8 = 0x%02X (%d)' % (out[VERSION_OFFSET], out[VERSION_OFFSET]))
        if extract:
            open(os.path.join(extract, 'stream1.bin'), 'wb').write(out)
        if dtype == 7:
            if data[end:end + 5] != b'SLIDE':
                print('  stream 2: none ("SLIDE" missing at 0x%X): LZSS_Decompress_ToFlash returns 0xFFFF and IC19'
                      ' 0x3E0000-0x3FFFFF stays erased' % end)
            else:
                magic2, size2, out2, end2 = slide4k_stream(data, end)
                raw = data[end:end2]
                print('  stream 2: magic %r at 0x%X, declared size %d (0x%X), %d bytes with header' % (
                    magic2, end, size2, size2, len(raw)))
                hr, hd = sha1(raw), sha1(out2)
                print('  stream 2: raw SHA-1 %s = %s (copied verbatim to IC19 0x3E0000)' % (hr, known(hr, SUBCPU_SHA1)))
                print('  stream 2: decompressed SHA-1 %s = %s' % (hd, known(hd, SUBCPU_SHA1)))
                if owner:
                    fend = base + owner.size
                    print('  stream 2: ends at 0x%X; %s ends at 0x%X (%s)' % (
                        end2, owner.path(), fend, 'the file is exactly the two streams' if fend == end2 else
                        'differs by %d bytes' % (fend - end2)))
                tail = data[end2:]
                print('  after stream 2: %d bytes to the end of the image (%s)' % (
                    len(tail), 'all 0x%02X' % tail[0] if tail and tail.count(tail[0]) == len(tail) else 'mixed'))
                if extract:
                    open(os.path.join(extract, 'stream2.slide'), 'wb').write(raw)
                    open(os.path.join(extract, 'stream2.bin'), 'wb').write(out2)
    else:
        n = {1: 0x800, 3: 0x800, 5: 0x800, 6: 0x400}.get(dtype)
        if n:
            payload = data[base:base + n * SECTOR]
            h = sha1(payload)
            print('  payload: %d sectors (%d B) from sector 0x24, SHA-1 %s = %s' % (
                n, len(payload), h, known(h, HDAE_SHA1, PROGRAM_SHA1)))
            if dtype == 6:
                print('  payload: XAPR signature at +0x%X' % payload.find(b'XAPR') if b'XAPR' in payload else '  payload: no XAPR signature')
            if extract:
                open(os.path.join(extract, 'payload.bin'), 'wb').write(payload)
        else:
            print('  (the firmware refuses this disc)')
    return ok


def main():
    ap = argparse.ArgumentParser(description='Read a KN5000 system-update floppy image as the firmware does.')
    ap.add_argument('images', nargs='+')
    ap.add_argument('--extract', metavar='DIR', help='write the files and payloads into DIR/<image name>/')
    a = ap.parse_args()
    ok = True
    for p in a.images:
        try:
            ex = os.path.join(a.extract, os.path.splitext(os.path.basename(p))[0]) if a.extract else None
            ok &= show(p, ex)
        except (OSError, IndexError) as e:
            print('%s: unreadable (%s)' % (p, e))
            ok = False
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
