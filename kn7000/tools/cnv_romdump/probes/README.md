# cnv_romdump probes: raw SD sectors from a style converter (program 941)

The ROM dumper runs as a style converter (`.CNV`, loaded at `0x502B8000`, called with
`calls (a0)` on the main task). The firmware's FAT library takes only 8.3 names, so the plan is:
create the dump files with 8.3 names in a folder of our own, close them, then rewrite that folder's
directory sectors with VFAT long-name entries in front of each 8.3 entry. These probes check every
step of that plan on program 941 in the published overlay MAME build, with a copy of the real
KN7000 SD card. They were run on 2026-10-18.

| probe (`.s` + `.cmd`) | question                                                                                                                                                                                                                                                | result                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `sdraw_probe`         | Can a converter read and write raw SD sectors, find a new folder's directory sector, and put long-name entries there that the FAT library keeps?                                                                                                        | **Yes.** `sdfmmkdir("C:\SDRAWDIR")` 0; `fmmopen("SDRAWDIR\FILE1.BIN")` 0, write 16, close 0. Raw read of the root directory (LBA 160, 32 sectors in one call) 0; `SDRAWDIR` at root index 2, cluster `0x12`, LBA `0x2C0` (= 192 + 16 × 32). Raw read of that sector 0: `.`, `..`, `FILE1   BIN`. Raw write of `.`, `..`, three long-name entries, `FILE1`'s 8.3 entry: 0. Then `FILE2.BIN` created through fmm in the same folder: the library put it at entry 6, after the long-name entries. `fatls.py` on the image: `C:\SDRAWDIR\FILE1.BIN [long name: kn7000_program_even_v1.6_b941.ic17]` and `FILE2.BIN`. |
| `sdpath_probe`        | Can the converter read the MBR and boot sector raw before any fmm call? Is the volume record filled then? What does `sdfmmkdir` return for an existing folder? Does `sdfmpath` put `fmmopen`'s file in a folder, and does `sdfmpath(0)` clear it again? | **Yes**, raw read of sector 0 returns 0 and the MBR; its partition starts at LBA `0x61`; the boot sector read from there returns 0. Both are byte-identical to the image. The volume record at `0x50149730` was already filled in when the converter was entered, and it is the same after `sdfmmkdir`. `sdfmmkdir` is 0 the first time and -3 (`0xFFFFFFFD`) the second. After `sdfmpath("C:\SDRAWDIR")`, byte `0x50092504` reads `0x43` (`C`), and `fmmopen("FILE3.BIN")` creates `C:\SDRAWDIR\FILE3.BIN`. After `sdfmpath(0)` the byte reads 0.                                                               |

`lfn_probe.s` + `lfn.cmd` came first: can a converter create a file on the SD card at all, and does the
FAT library keep a long name? `fmmopen("kn7000_program_even_v1.6_b941.ic17", "wb")` returns -3 (nothing
is written, the write after it -100); `fmmopen("SHORT.BIN", "wb")`, a 16-byte write and the close return
0, 16, 0, and `fatls.py` finds `C:\SHORT.BIN` with the marker. Hence the 8.3 files plus the long-name pass.

## How to run them

`B` is `~/compartilhado/kn5000-anotherworld/kn7000/probes/cnv`; `T` is any scratch directory.

    P=~/compartilhado/technics-roms-disasm/kn7000/tools/cnv_romdump/probes
    $B/build_probe.sh $P/sdraw_probe.s $T/sdraw.img
    $B/run_probe.sh $P/sdraw.cmd $T/sdraw.img $T/run1
    python3 -I $P/../fatls.py $T/run1/sd.img
    $B/build_probe.sh $P/sdpath_probe.s $T/sdpath.img
    $B/run_probe.sh $P/sdpath.cmd $T/sdpath.img $T/run2

Each command file walks DISK MENU > STYLE CONVERT > OK and waits 30 s. It then prints the result
words (`PROBE ...`) and writes the probe's result area to `res.bin` next to `cmd.txt`. It also
prints the live volume record and, for `sdraw`, the cache-buffer headers. The converters'
SHA-1s are `sdraw_probe` `a8734d1a…` and `sdpath_probe` `786894c8…`. The SD card copied by
`run_probe.sh` is `kn7000-emulator/sdcard_from_real_kn7000.img`, SHA-1 `3a622729…`. Each run takes
about 3 minutes.

`lfn_bytes.py` generates the long-name entries that `sdraw_probe.s` carries as data (checksum
`0xDB` for `FILE1   BIN`).

The result words, in the order listed at the top of each `.s` file:

    sdraw   PROBE 00000000 00000000 00000010 00000000 00000000 00000012 000002c0 00000000
                  00000001 00000000 00000000 00000010 00000000 00000000 00000000 00000002 end 600df00d
    sdpath  PROBE 00000000 00000061 00000000 00000000 fffffffd 00000000 00000010 00000000
                  00000000 00000043 00000000 end 600df00d

## The firmware routines the probes use (941)

All of these are entered with `calls`.

| address      | routine                                  | arguments and result                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
|--------------|------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `0x48470348` | SD raw read (`call` entry `0x4847034D`)  | d0 = absolute card sector (the MBR is 0), d1 = count (16-bit), a1 = buffer; 512 bytes per sector. Posts SD worker command 3 through `0x4847030E` → `DiskCmdTransact`, which sleeps until the worker is done. d0 = 0 when it worked. 6 means the card has changed: flag `0x50000CC0` was set; the call clears it and sets `0x50000CC1`, so retry. Other values: 2 read error or out of range, `0x30` card not initialised, `0x40` card not mounted, `0xFB` worker busy, 1 mailbox full or timeout (8000 ticks). |
| `0x4847037B` | SD raw write (`call` entry `0x48470380`) | the same arguments, worker command 4, no card-change check. Other values: `0x2F` write-protected, 3 write error or out of range.                                                                                                                                                                                                                                                                                                                                                                               |
| `0x48565D45` | `sdfmmkdir`                              | a0 = full path, e.g. `"C:\ROMDUMP"`. 0 created; -3 exists (FAT errno `0x500AD390` = `0x15`) or failed; -0xB write-protected (errno `0x1F`).                                                                                                                                                                                                                                                                                                                                                                    |
| `0x48565D84` | `sdfmpath`                               | a0 = full folder path, which is copied into `0x50092504` (0x80 bytes), or 0, which clears it. While the byte is set, the SD `fmmopen` backend `0x4856580E` opens folder + `\` + name instead of `C:\` + name. The firmware sets the folder, opens, then clears it (`0x4856227E`..`0x485622A0`).                                                                                                                                                                                                                |

The FAT library reaches the card through the device entry of drive C, `0x50007A20` (0x28 bytes):
+0x14 is the driver table `0x500079D8`, and +0x20 is the volume record `0x50149730`. In the driver
table, entry 0 is `0x48470328` (mount the card) and entries 4/5 are `0x484704BB`/`0x4847059F`.
These take a request record and split it into calls of at most 0x80 sectors to the raw routines.
Byte +2 bit 0 of the device entry (`0x50007A22`) is set once the volume record is valid. The SD
format code `0x48471EF5` writes its sectors through the same `0x4847030E` (worker command 4).

## The volume record `0x50149730` (filled by the mount `0x4846EDD7`)

The values are from both runs and match the card's boot sector at LBA 97. All sector numbers
are absolute card sectors.

| offset | size | field                                                       | value on the card |
|--------|------|-------------------------------------------------------------|-------------------|
| +0x04  | u32  | bytes per sector - 1                                        | `0x1FF`           |
| +0x08  | u32  | total sectors (BPB 0x13, else 0x20)                         | 247711            |
| +0x10  | u32  | hidden sectors = partition start (BPB 0x1C, read as 16-bit) | 97                |
| +0x14  | u32  | first data sector (cluster 2)                               | 192               |
| +0x18  | u32  | first FAT (hidden + reserved)                               | 98                |
| +0x1C  | u32  | root directory                                              | 160               |
| +0x20  | u32  | sectors per cluster                                         | 32                |
| +0x24  | u16  | FAT mask: `0xFFFF` if BPB 0x36 says `FAT16`, else `0x0FFF`  | `0xFFFF`          |
| +0x26  | u16  | bytes per sector (the library refuses anything but 512)     | 512               |
| +0x28  | u16  | bytes per cluster                                           | `0x4000`          |
| +0x2A  | u16  | reserved sectors                                            | 1                 |
| +0x2C  | u16  | root directory entries                                      | 512               |
| +0x2E  | u16  | root directory sectors                                      | 32                |
| +0x30  | u16  | sectors per FAT                                             | 31                |
| +0x32  | u16  | sectors per track / +0x34 heads                             | 32 / 8            |
| +0x36  | u16  | highest cluster number (clusters + 1)                       | 7739              |
| +0x3A  | u8   | number of FATs / +0x3B media byte                           | 2 / `0xF8`        |

A folder's directory starts at LBA = +0x14 + (cluster - 2) × +0x20. The `.` entry of that sector
holds the folder's own cluster again at +0x1A.

## Cache coherency

The FAT library has 10 shared sector buffers at `0x50149850`, `0x21C` bytes apart. Each holds
+0 the device entry, +4 the sector, +0x18 flags (bit 0 valid, bit 1 dirty, bit 2 FAT sector), +0x19
the owner's file index, and the data at +0x1C. A buffer is looked up by device and sector. Dirty
buffers are written back when they are reused, and on every close (`0x4846E0D5`, reached from
`fmmclose`): a close writes back every dirty buffer and invalidates the closing file's buffers,
except those holding FAT sectors.

What `sdraw_probe` saw: after `fmmclose` the folder sector `0x2C0` sat in buffer 4 with flags
`0x00`, which means invalid. Sectors `0x62` and `0x78`–`0x7F`, which are FAT sectors, stayed
valid with flags `0x05`, and no buffer was dirty. When `FILE2.BIN` was created after the raw
write, the library read `0x2C0` from the card again and kept the long-name entries.

So a raw rewrite of directory sectors is safe after the last `fmmclose`, as long as no file is open.
To be sure, also clear bit 0 at +0x18 of any buffer whose +0 is `0x50007A20` and whose +4 is the
sector being written. Raw writes to FAT sectors are not safe, because their cached copies stay
valid. The card-removal handler's VFS hook `0x48565F64` is an empty `retf` in 941, so it does not clear
the cache either.
