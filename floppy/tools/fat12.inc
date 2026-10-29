; fat12.inc -- typed FAT12 diskette layout for llvm-mc (data only; any triple, the build uses tlcs900).
;
; Used by every floppy/<model>/<disk>/disk.s that floppy/tools/fat12_to_s.py writes.  The macros
; spell the three FAT12 structures by their fields, and assert positions, so a mis-placed unit is an
; assembler error rather than a SHA-1 mismatch somewhere in 1.44 MB.  Reference: Microsoft, "FAT:
; General Overview of On-Disk Format" (fatgen103, 2000), sections 3 (BPB), 4 (FAT), 6 (directory).
;
;   at OFF                    assert the location counter is OFF bytes from disk_base
;   fat12_at_cluster C        assert the location counter is the first byte of data cluster C
;   fat12_begin               start one FAT copy (resets the 12-bit packer)
;   fat12_entry V             one 12-bit FAT entry, packed two-per-three-bytes, little endian
;   fat12_run FIRST, N, LAST  the N entries of a contiguous chain FIRST..FIRST+N-1: each points
;                             to the next cluster; the last holds LAST (0xfff = end of chain,
;                             or the cluster where a fragmented chain continues)
;   fat12_free N              N free entries (0x000)
;   fat12_end BYTES           close a FAT copy of BYTES bytes; asserts every 12-bit slot was written
;   fat_dirent ...            one 32-byte directory entry, fields typed (see the macro)
;   fat_lfn ...               one VFAT long-name entry
;
; The packer is a state machine over three assembler variables: _fat12_n (entries written),
; _fat12_half (1 when an even entry is waiting for its odd neighbour) and _fat12_pend (that entry).
; Entries 2k and 2k+1 occupy bytes 3k..3k+2:  b0 = e0 & 0xff,  b1 = (e0 >> 8) | (e1 & 0x0f) << 4,
; b2 = e1 >> 4.

	.macro	at off
	.if	(. - disk_base) - (\off)
	.error	"floppy layout: location counter is not at the expected disk offset"
	.endif
	.endm

	.macro	fat12_at_cluster c
	at	FAT12_DATA_OFFSET + ((\c) - 2) * FAT12_CLUSTER_BYTES
	.endm

	.macro	fat12_begin
	.set	_fat12_n, 0
	.set	_fat12_half, 0
	.set	_fat12_pend, 0
	.endm

	.macro	fat12_entry v
	.if	_fat12_half
	.byte	_fat12_pend & 0xff, ((_fat12_pend >> 8) & 0x0f) | (((\v) & 0x0f) << 4), ((\v) >> 4) & 0xff
	.set	_fat12_half, 0
	.else
	.set	_fat12_pend, \v
	.set	_fat12_half, 1
	.endif
	.set	_fat12_n, _fat12_n + 1
	.endm

	.macro	fat12_run first, count, last=0xfff
	.if	_fat12_n - (\first)
	.error	"fat12_run: the chain does not start at the next FAT entry"
	.endif
	.rept	(\count) - 1
	fat12_entry	_fat12_n + 1
	.endr
	fat12_entry	\last
	.endm

	.macro	fat12_free count
	.rept	\count
	fat12_entry	0
	.endr
	.endm

	.macro	fat12_end bytes
	.if	_fat12_half
	.error	"fat12_end: odd number of 12-bit entries; spell the last slot explicitly"
	.endif
	.if	(_fat12_n / 2) * 3 - (\bytes)
	.error	"fat12_end: the entries written do not fill the FAT copy exactly"
	.endif
	.endm

; One 32-byte directory entry.
;   name, ext   the 8.3 name, space padded, as strings of exactly 8 and 3 bytes (asserted)
;   attr        FAT_ATTR_* flags
;   hour, min, sec / year, month, day
;               the last-write time and date, decoded: stored as (hour << 11 | min << 5 | sec / 2)
;               and ((year - 1980) << 9 | month << 5 | day).  Every stored value round-trips,
;               including invalid ones (an all-zero date is year 1980, month 0, day 0).
;   cluster     first cluster (0 for an empty file or a volume label)
;   size        file size in bytes (0 for directories and labels)
;   ntres, ctenth, ctime, cdate, adate, clhi
;               the fields DOS 7 / VFAT put in bytes 12..21, raw; 0 on diskettes written by DOS < 7
;               and by the KN-series instruments
	.macro	fat_dirent name, ext, attr, hour, min, sec, year, month, day, cluster, size, ntres=0, ctenth=0, ctime=0, cdate=0, adate=0, clhi=0
.Ldirent_name\@:
	.ascii	"\name"
.Ldirent_ext\@:
	.ascii	"\ext"
.Ldirent_attr\@:
	.if	(.Ldirent_ext\@ - .Ldirent_name\@) - 8
	.error	"fat_dirent: the name field is not 8 bytes"
	.endif
	.if	(.Ldirent_attr\@ - .Ldirent_ext\@) - 3
	.error	"fat_dirent: the extension field is not 3 bytes"
	.endif
	.byte	\attr, \ntres, \ctenth
	.short	\ctime, \cdate, \adate, \clhi
	.short	((\hour) << 11) | ((\min) << 5) | ((\sec) / 2)
	.short	(((\year) - 1980) << 9) | ((\month) << 5) | (\day)
	.short	\cluster
	.long	\size
	.endm

; One VFAT long-file-name entry: sequence byte, checksum of the short name it belongs to, and the
; thirteen UCS-2 code units it carries (0x0000 terminator, 0xffff padding), in on-disk order.
	.macro	fat_lfn seq, chk, u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12
	.byte	\seq
	.short	\u0, \u1, \u2, \u3, \u4
	.byte	FAT_ATTR_LFN, 0, \chk
	.short	\u5, \u6, \u7, \u8, \u9, \u10
	.short	0
	.short	\u11, \u12
	.endm

	.set	FAT_ATTR_READONLY, 0x01
	.set	FAT_ATTR_HIDDEN, 0x02
	.set	FAT_ATTR_SYSTEM, 0x04
	.set	FAT_ATTR_VOLUME, 0x08
	.set	FAT_ATTR_DIRECTORY, 0x10
	.set	FAT_ATTR_ARCHIVE, 0x20
	.set	FAT_ATTR_LFN, 0x0f
