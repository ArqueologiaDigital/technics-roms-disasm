# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# menu_card.s -- the program menu's card reader (included by menu.s): raw sectors through the loader's
# SV_RAWREAD, and a read-only FAT16 reader of its own on top (README.md, "Finding the programs").
# Nothing here writes to the card: the only firmware routine it calls is the sector read.

# RawRead(d0 = card sector, d1 = count 1..WORK_SECS, a1 = buffer) -> d0 = 0, or the routine's code (-1 for
# a count out of range, which is not passed on). A changed card (6) is read once more. V_INREAD,
# V_RDDST and V_RDLEN say, while it runs, where the firmware is writing for us.
RawRead:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d2
    mov     d1, d3
    mov     a1, a2
    mov     -1, d0
    cmp     0, d3
    beq     rr_ret
    cmp     WORK_SECS, d3
    bhi     rr_ret
    mov     a2, (V_RDDST)
    mov     d3, d0
    asl     9, d0
    mov     d0, (V_RDLEN)
    mov     2, d0
    mov     d0, (0x14, sp)          # tries
rr_try:
    mov     1, d0
    mov     d0, (V_INREAD)
    mov     d2, d0
    mov     d3, d1
    mov     a2, a1
    mov     (SVC+SV_RAWREAD), a3
    calls   (a3)
    mov     d0, (V_ERR)
    clr     d1
    mov     d1, (V_INREAD)
    cmp     6, d0                   # the card has changed: once more
    bne     rr_ret
    mov     (0x14, sp), d1
    add     -1, d1
    mov     d1, (0x14, sp)
    bne     rr_try
rr_ret:
    ret     [d2,d3,a2,a3], 0x30

# Geometry -> d0 = 0 with V_PART..V_MAXCL set from the MBR and the boot sector, else 1 and a0 = why not.
# Only what the firmware's FAT library reads: 512-byte sectors, FAT16 (4085 to 65524 clusters).
Geometry:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     str_f_io, a3
    clr     d0                      # sector 0: an MBR, or a boot sector (a card without partitions)
    mov     1, d1
    mov     SECBUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     ge_bad
    clr     d2                      # the partition's first sector
    mov     SECBUF, a0
    movbu   (a0), d0
    cmp     0xEB, d0
    beq     ge_bpb
    cmp     0xE9, d0
    beq     ge_bpb
    mov     SECBUF+0x1C6, a0
    call    Read32U, 0, 0
    mov     d0, d2
    mov     1, d1
    mov     SECBUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     ge_bad
ge_bpb:
    mov     d2, (V_PART)
    mov     SECBUF, a2
    mov     str_f_format, a3        # what the menu does not read
    mov     a2, a0                  # 512 bytes per sector
    add     0x0B, a0
    call    Read16U, 0, 0
    mov     512, d1
    cmp     d1, d0
    bne     ge_bad
    movbu   (0x0D, a2), d0          # sectors per cluster: a power of two, 1..WORK_SECS
    cmp     0, d0
    beq     ge_bad
    cmp     WORK_SECS, d0
    bhi     ge_bad
    mov     d0, d1
    add     -1, d1
    and     d0, d1
    bne     ge_bad
    mov     d0, (V_SPC)
    asl     9, d0
    mov     d0, (V_CLBYTES)
    mov     a2, a0                  # reserved sectors
    add     0x0E, a0
    call    Read16U, 0, 0
    cmp     0, d0
    beq     ge_bad
    add     d2, d0
    mov     d0, (V_FATLBA)
    movbu   (0x10, a2), d3          # FATs: 1 or 2
    cmp     0, d3
    beq     ge_bad
    cmp     2, d3
    bhi     ge_bad
    mov     a2, a0                  # sectors per FAT (16-bit: FAT32 keeps 0 here)
    add     0x16, a0
    call    Read16U, 0, 0
    cmp     0, d0
    beq     ge_bad
    mulu    d3, d0
    mov     (V_FATLBA), d1
    add     d1, d0
    mov     d0, (V_ROOTLBA)
    mov     a2, a0                  # root directory entries -> sectors
    add     0x11, a0
    call    Read16U, 0, 0
    cmp     0, d0
    beq     ge_bad
    add     15, d0
    lsr     4, d0
    mov     d0, (V_ROOTSECS)
    mov     (V_ROOTLBA), d1
    add     d1, d0
    mov     d0, (V_DATALBA)
    mov     a2, a0                  # total sectors: 16-bit, or 32-bit when that is 0
    add     0x13, a0
    call    Read16U, 0, 0
    cmp     0, d0
    bne     ge_total
    mov     a2, a0
    add     0x20, a0
    call    Read32U, 0, 0
ge_total:
    mov     (V_DATALBA), d1         # clusters = (total - (data - partition)) / spc
    sub     d2, d1
    cmp     d1, d0
    bls     ge_bad
    sub     d1, d0
    clr     d1
    mov     d1, mdr
    mov     (V_SPC), d1
    divu    d1, d0
    mov     4085, d1                # FAT16: 4085 to 65524 clusters (FAT12 below, FAT32 above)
    cmp     d1, d0
    bcs     ge_bad
    mov     65525, d1
    cmp     d1, d0
    bcc     ge_bad
    inc     d0
    mov     d0, (V_MAXCL)
    clr     d0
    bra     ge_ret
ge_bad:
    mov     a3, a0
    mov     1, d0
ge_ret:
    ret     [d2,d3,a2,a3], 0x30

# FatNext(d0 = cluster) -> d0 = the next one in its chain (>= 0xFFF8: the end), or 0 when the FAT sector
# could not be read. FATBUF keeps the FAT sector last read (V_FATSEC).
FatNext:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d2
    lsr     8, d0                   # 256 entries per sector
    mov     (V_FATLBA), d1
    add     d1, d0
    mov     d0, d3
    mov     (V_FATSEC), d1
    cmp     d1, d0
    beq     fn_have
    mov     -1, d0
    mov     d0, (V_FATSEC)
    mov     d3, d0
    mov     1, d1
    mov     FATBUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     fn_err
    mov     d3, (V_FATSEC)
fn_have:
    mov     d2, d0
    and     0xFF, d0
    add     d0, d0
    mov     FATBUF, a0
    add     d0, a0
    movhu   (a0), d0
    bra     fn_ret
fn_err:
    clr     d0
fn_ret:
    ret     [d2,d3,a2,a3], 0x30

# ValidCluster(d0) -> d0 = 0 when 2 <= d0 <= V_MAXCL, else 1. Leaf.
ValidCluster:
    cmp     2, d0
    bcs     vc_no
    mov     (V_MAXCL), d1
    cmp     d1, d0
    bhi     vc_no
    clr     d0
    rets
vc_no:
    mov     1, d0
    rets

# ClusterLba(d0 = cluster) -> d0 = its first sector. Leaf.
ClusterLba:
    add     -2, d0
    mov     (V_SPC), d1
    mulu    d1, d0
    mov     (V_DATALBA), d1
    add     d1, d0
    rets

# ReadCluster(d0 = cluster, d1 = bytes <= V_CLBYTES, a0 = destination) -> d0 = 0, else 1. Whole sectors go
# straight to the destination; a last, partial one through SECBUF, so nothing past the bytes is written.
ReadCluster:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d2
    mov     d1, d3
    mov     a0, a2
    call    ValidCluster, 0, 0
    cmp     0, d0
    bne     rc_bad
    mov     (V_CLBYTES), d0
    cmp     d0, d3
    bhi     rc_bad
    mov     d2, d0
    call    ClusterLba, 0, 0
    mov     d0, d2                  # d2 = the sector
    mov     d3, d0
    lsr     9, d0
    cmp     0, d0
    beq     rc_part
    mov     d0, (0x14, sp)
    mov     d0, d1
    mov     d2, d0
    mov     a2, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     rc_bad
    mov     (0x14, sp), d0
    add     d0, d2
    asl     9, d0
    add     d0, a2
rc_part:
    mov     d3, d0
    and     0x1FF, d0
    beq     rc_ok
    mov     d0, (0x18, sp)
    mov     d2, d0
    mov     1, d1
    mov     SECBUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     rc_bad
    mov     SECBUF, a0
    mov     (0x18, sp), d1
rc_copy:
    movbu   (a0), d0
    movbu   d0, (a2)
    inc     a0
    inc     a2
    add     -1, d1
    bne     rc_copy
rc_ok:
    clr     d0
    bra     rc_ret
rc_bad:
    mov     1, d0
rc_ret:
    ret     [d2,d3,a2,a3], 0x30

# ReadFile(d0 = first cluster, d1 = bytes, a0 = destination) -> d0 = 0 when all of them were read, else 1
# (a bad cluster, a chain shorter than the bytes, more than FILE_MAXCL clusters, a read error).
ReadFile:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d2
    mov     d1, d3
    mov     a0, a2
    clr     d0
    mov     d0, (0x14, sp)          # clusters read
rf_loop:
    cmp     0, d3
    beq     rf_ok
    mov     (0x14, sp), d0
    mov     FILE_MAXCL, d1
    cmp     d1, d0
    bcc     rf_bad
    inc     d0
    mov     d0, (0x14, sp)
    mov     d3, d1                  # this cluster's share
    mov     (V_CLBYTES), d0
    cmp     d0, d1
    bls     rf_take
    mov     d0, d1
rf_take:
    mov     d1, (0x18, sp)
    mov     d2, d0
    mov     a2, a0
    call    ReadCluster, 0, 0
    cmp     0, d0
    bne     rf_bad
    mov     (0x18, sp), d0
    add     d0, a2
    sub     d0, d3
    beq     rf_ok
    mov     d2, d0
    call    FatNext, 0, 0
    mov     d0, d2
    call    ValidCluster, 0, 0
    cmp     0, d0
    bne     rf_bad
    bra     rf_loop
rf_ok:
    clr     d0
    bra     rf_ret
rf_bad:
    mov     1, d0
rf_ret:
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# The directory reader: DirOpen(d0 = first cluster, 0 = the root directory), then DirNext -> a0 = the
# next 32-byte entry (in WORKBUF), or 0 after the last sector (or cluster) read; a read error or a broken
# chain sets V_DR_ERR. Callers stop at an entry whose first byte is 0. Bounded: ROOT_MAXSECS sectors of
# the root, DIR_MAXCL clusters of a folder.
DirOpen:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, (V_DR_CL)
    mov     WORKBUF, d1
    mov     d1, (V_DR_PTR)
    mov     d1, (V_DR_END)
    clr     d1
    mov     d1, (V_DR_ERR)
    mov     d1, (V_DR_LEFT)
    mov     1, d1
    mov     d1, (V_DR_NCL)
    cmp     0, d0
    bne     do_cl
    mov     (V_ROOTLBA), d0
    mov     d0, (V_DR_LBA)
    mov     (V_ROOTSECS), d0
    mov     ROOT_MAXSECS, d1
    cmp     d1, d0
    bls     do_rs
    mov     d1, d0
do_rs:
    mov     d0, (V_DR_LEFT)
    bra     do_ret
do_cl:
    call    ValidCluster, 0, 0
    cmp     0, d0
    beq     do_ok
    mov     1, d0
    mov     d0, (V_DR_ERR)
    bra     do_ret
do_ok:
    mov     (V_DR_CL), d0
    call    ClusterLba, 0, 0
    mov     d0, (V_DR_LBA)
    mov     (V_SPC), d0
    mov     d0, (V_DR_LEFT)
do_ret:
    ret     [d2,d3,a2,a3], 0x30

DirNext:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
dn_loop:
    mov     (V_DR_ERR), d0
    cmp     0, d0
    bne     dn_end
    mov     (V_DR_PTR), a0
    mov     (V_DR_END), a1
    cmp     a1, a0
    bcs     dn_have
    mov     (V_DR_LEFT), d0         # this stretch is used up
    cmp     0, d0
    bne     dn_read
    mov     (V_DR_CL), d0           # the root has no next cluster
    cmp     0, d0
    beq     dn_end
    call    FatNext, 0, 0
    mov     d0, d2
    mov     0xFFF8, d1
    cmp     d1, d0
    bcc     dn_end                  # the chain's end
    call    ValidCluster, 0, 0
    cmp     0, d0
    bne     dn_err
    mov     (V_DR_NCL), d0
    inc     d0
    mov     d0, (V_DR_NCL)
    cmp     DIR_MAXCL, d0
    bhi     dn_end
    mov     d2, (V_DR_CL)
    mov     d2, d0
    call    ClusterLba, 0, 0
    mov     d0, (V_DR_LBA)
    mov     (V_SPC), d0
    mov     d0, (V_DR_LEFT)
dn_read:
    mov     (V_DR_LEFT), d3         # up to WORK_SECS sectors at once
    cmp     WORK_SECS, d3
    bls     dn_n
    mov     WORK_SECS, d3
dn_n:
    mov     (V_DR_LBA), d0
    mov     d3, d1
    mov     WORKBUF, a1
    call    RawRead, 0, 0
    cmp     0, d0
    bne     dn_err
    mov     (V_DR_LBA), d0
    add     d3, d0
    mov     d0, (V_DR_LBA)
    mov     (V_DR_LEFT), d0
    sub     d3, d0
    mov     d0, (V_DR_LEFT)
    mov     WORKBUF, a0
    mov     a0, (V_DR_PTR)
    mov     d3, d0
    asl     9, d0
    add     d0, a0
    mov     a0, (V_DR_END)
    bra     dn_loop
dn_have:
    mov     a0, a1
    add     32, a1
    mov     a1, (V_DR_PTR)
    bra     dn_ret
dn_err:
    mov     1, d0
    mov     d0, (V_DR_ERR)
dn_end:
    mov     0, a0
dn_ret:
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# The scan.

# ScanRoot -> d0 = 0 with the root's folders in PROG_TAB (V_NCAND of them, at most MAX_PROG; their 8.3
# name, first cluster, and the long name when the entries before them give one), else 1 and a0 = why.
ScanRoot:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    clr     d0
    mov     d0, (V_NCAND)
    mov     d0, (V_ROOTFULL)
    call    DirOpen, 0, 0
    call    LfnReset, 0, 0
srt_loop:
    call    DirNext, 0, 0
    cmp     0, a0
    beq     srt_done
    mov     a0, a2
    movbu   (a2), d0
    cmp     0, d0
    beq     srt_done
    cmp     0xE5, d0
    beq     srt_reset
    movbu   (11, a2), d1
    mov     d1, d2
    and     0x3F, d2
    cmp     0x0F, d2
    bne     srt_entry
    mov     a2, a0                  # a long-name entry
    call    LfnAdd, 0, 0
    bra     srt_loop
srt_entry:
    btst    0x08, d1                # a volume label
    bne     srt_reset
    btst    0x10, d1                # a file
    beq     srt_reset
    cmp     0x2E, d0                # "." and ".." (not in the root, but)
    beq     srt_reset
    mov     (V_NCAND), d0
    cmp     MAX_PROG, d0
    bcs     srt_room
    mov     1, d0
    mov     d0, (V_ROOTFULL)
    bra     srt_reset
srt_room:
    mov     a2, a0                  # its first cluster
    add     0x1A, a0
    call    Read16U, 0, 0
    mov     d0, d3
    call    ValidCluster, 0, 0
    cmp     0, d0
    bne     srt_reset
    mov     (V_NCAND), d0
    call    RecAddr, 0, 0
    mov     a0, a3
    mov     PR_LEN/4, d1            # a clean record
    clr     d0
srt_clr:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     srt_clr
    mov     d3, (PR_DIRCL, a3)
    mov     (V_NCAND), d0
    mov     d0, (PR_INDEX, a3)
    mov     DefaultIcon, d0
    mov     d0, (PR_ICONP, a3)
    mov     a2, a0
    mov     a3, a1
    add     PR_DIR, a1
    call    Name83, 0, 0
    mov     a2, a0
    call    LfnValid, 0, 0
    mov     a3, a0
    add     PR_NAME, a0
    cmp     0, d0
    beq     srt_short
    mov     LFNBUF, a1
    call    StrCpy, 0, 0
    mov     (PR_FLAGS, a3), d0
    or      PF_LONG, d0
    mov     d0, (PR_FLAGS, a3)
    bra     srt_named
srt_short:
    mov     a3, a1
    add     PR_DIR, a1
    call    StrCpy, 0, 0
srt_named:
    mov     (V_NCAND), d0
    inc     d0
    mov     d0, (V_NCAND)
srt_reset:
    call    LfnReset, 0, 0
    bra     srt_loop
srt_done:
    mov     (V_DR_ERR), d0
    cmp     0, d0
    bne     srt_io
    clr     d0
    bra     srt_ret
srt_io:
    mov     str_f_io, a0
    mov     1, d0
srt_ret:
    ret     [d2,d3,a2,a3], 0x30

# ScanOne(a0 = record): what its folder holds. KN7APP.BIN and MANIFEST.TXT by their 8.3 names; then the
# manifest is read and parsed, and the icon it names is looked for, read and decoded. Whatever is
# missing or malformed leaves the folder's name and the default icon (and a PF_* flag that says so).
ScanOne:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a3
    mov     a3, (V_REC)
    mov     (V_NFOLDERS), d0
    inc     d0
    mov     d0, (V_NFOLDERS)
    mov     (PR_DIRCL, a3), d0
    call    DirOpen, 0, 0
so_loop:
    call    DirNext, 0, 0
    cmp     0, a0
    beq     so_scanned
    mov     a0, a2
    movbu   (a2), d0
    cmp     0, d0
    beq     so_scanned
    cmp     0xE5, d0
    beq     so_loop
    movbu   (11, a2), d0            # files only: not folders, labels or long-name entries
    and     0x18, d0
    bne     so_loop
    mov     a2, a0
    mov     name_app, a1
    call    Same11, 0, 0
    cmp     0, d0
    beq     so_notapp
    mov     a2, a0
    add     0x1A, a0
    call    Read16U, 0, 0
    mov     d0, (PR_APPCL, a3)
    mov     a2, a0
    add     0x1C, a0
    call    Read32U, 0, 0
    mov     d0, (PR_APPSZ, a3)
    mov     (PR_FLAGS, a3), d0
    or      PF_APP, d0
    mov     d0, (PR_FLAGS, a3)
    bra     so_loop
so_notapp:
    mov     a2, a0
    mov     name_manifest, a1
    call    Same11, 0, 0
    cmp     0, d0
    beq     so_loop
    mov     a2, a0
    add     0x1A, a0
    call    Read16U, 0, 0
    mov     d0, (PR_MANCL, a3)
    mov     a2, a0
    add     0x1C, a0
    call    Read32U, 0, 0
    mov     d0, (PR_MANSZ, a3)
    mov     (PR_FLAGS, a3), d0
    or      PF_MANIFEST, d0
    mov     d0, (PR_FLAGS, a3)
    bra     so_loop
so_scanned:
    mov     (PR_FLAGS, a3), d0
    btst    PF_APP, d0
    beq     so_ret
    btst    PF_MANIFEST, d0
    beq     so_ret
    mov     (PR_MANSZ, a3), d1      # the manifest, up to MAN_MAX bytes
    mov     MAN_MAX, d0
    cmp     d0, d1
    bls     so_mn
    mov     d0, d1
so_mn:
    mov     d1, (0x14, sp)
    mov     (PR_MANCL, a3), d0
    mov     TEXTBUF, a0
    call    ReadFile, 0, 0
    cmp     0, d0
    bne     so_manbad
    mov     TEXTBUF, a0
    mov     (0x14, sp), d0
    add     d0, a0
    clr     d0
    movbu   d0, (a0)
    mov     a3, a0
    call    ParseManifest, 0, 0
    mov     (PR_FLAGS, a3), d0
    btst    PF_ICONNAME, d0
    beq     so_ret
    mov     (PR_DIRCL, a3), d0      # the icon it names, in the same folder
    call    DirOpen, 0, 0
so_icon:
    call    DirNext, 0, 0
    cmp     0, a0
    beq     so_iconbad
    mov     a0, a2
    movbu   (a2), d0
    cmp     0, d0
    beq     so_iconbad
    cmp     0xE5, d0
    beq     so_icon
    movbu   (11, a2), d0
    and     0x18, d0
    bne     so_icon
    mov     a2, a0
    mov     a3, a1
    add     PR_ICON11, a1
    call    Same11, 0, 0
    cmp     0, d0
    beq     so_icon
    mov     a2, a0
    add     0x1A, a0
    call    Read16U, 0, 0
    mov     d0, (PR_ICONCL, a3)
    mov     a2, a0
    add     0x1C, a0
    call    Read32U, 0, 0
    mov     d0, (PR_ICONSZ, a3)
    mov     d0, d1                  # up to BMP_MAX bytes of it
    mov     BMP_MAX, d0
    cmp     d0, d1
    bls     so_bn
    mov     d0, d1
so_bn:
    mov     d1, (0x14, sp)
    mov     (PR_ICONCL, a3), d0
    mov     BMPBUF, a0
    call    ReadFile, 0, 0
    cmp     0, d0
    bne     so_iconbad
    mov     (PR_INDEX, a3), d0      # its slot
    mov     ICON_BYTES, d1
    mulu    d1, d0
    mov     ICONS, a1
    add     d0, a1
    mov     a1, (0x18, sp)
    mov     BMPBUF, a0
    mov     (0x14, sp), d0
    call    DecodeBmp, 0, 0
    cmp     0, d0
    beq     so_iconbad
    mov     (0x18, sp), d0
    mov     d0, (PR_ICONP, a3)
    mov     (PR_FLAGS, a3), d0
    or      PF_ICON, d0
    mov     d0, (PR_FLAGS, a3)
    bra     so_ret
so_iconbad:
    mov     (PR_FLAGS, a3), d0
    or      PF_ICONBAD, d0
    mov     d0, (PR_FLAGS, a3)
    bra     so_ret
so_manbad:
    mov     (PR_FLAGS, a3), d0
    or      PF_MANBAD, d0
    mov     d0, (PR_FLAGS, a3)
so_ret:
    ret     [d2,d3,a2,a3], 0x30

# Same11(a0, a1) -> d0 = 1 when the 11 bytes at a0 and a1 are equal, else 0.
Same11:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     11, d2
s11_c:
    movbu   (a0), d0
    movbu   (a1), d1
    cmp     d1, d0
    bne     s11_no
    inc     a0
    inc     a1
    add     -1, d2
    bne     s11_c
    mov     1, d0
    bra     s11_ret
s11_no:
    clr     d0
s11_ret:
    ret     [d2,d3,a2,a3], 0x30

# Name83(a0 = directory entry, a1 = out): "NAME.EXT" (or "NAME"), NUL-ended, as the entry holds it. Leaf.
Name83:
    mov     8, d1
n8_b:
    movbu   (a0), d0
    cmp     0x20, d0
    beq     n8_bend
    movbu   d0, (a1)
    inc     a1
    inc     a0
    add     -1, d1
    bne     n8_b
    bra     n8_ext
n8_bend:
    add     d1, a0                  # to the extension
n8_ext:
    movbu   (a0), d0
    cmp     0x20, d0
    beq     n8_end
    mov     0x2E, d0
    movbu   d0, (a1)
    inc     a1
    mov     3, d1
n8_e:
    movbu   (a0), d0
    cmp     0x20, d0
    beq     n8_end
    movbu   d0, (a1)
    inc     a1
    inc     a0
    add     -1, d1
    bne     n8_e
n8_end:
    clr     d0
    movbu   d0, (a1)
    rets

# The long name in front of an 8.3 entry: LfnReset forgets it; LfnAdd(a0 = a long-name entry) adds its 13
# characters at their place (ASCII kept, anything else '?', up to LFN_MAX); LfnValid(a0 = the 8.3 entry)
# -> d0 = 1 when every part was seen and the checksum matches that entry's name.
LfnReset:                           # leaf
    clr     d0
    mov     d0, (V_LFN_N)
    mov     d0, (V_LFN_SEEN)
    rets

LfnAdd:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    movbu   (a2), d2                # the sequence byte
    btst    0x40, d2                # the last part, stored first: start a new name
    beq     lf_part
    mov     d2, d0
    and     0x1F, d0
    cmp     0, d0
    beq     lf_bad
    cmp     20, d0
    bhi     lf_bad
    mov     d0, (V_LFN_N)
    clr     d0
    mov     d0, (V_LFN_SEEN)
    movbu   (13, a2), d0
    mov     d0, (V_LFN_CK)
    mov     LFNBUF, a0
    mov     LFN_WORDS, d1
    clr     d0
lf_clr:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     lf_clr
lf_part:
    mov     (V_LFN_N), d1
    cmp     0, d1
    beq     lf_ret                  # an orphan part
    mov     d2, d0
    and     0x1F, d0
    cmp     0, d0
    beq     lf_bad
    cmp     d1, d0
    bhi     lf_bad
    movbu   (13, a2), d1
    mov     (V_LFN_CK), d3
    cmp     d3, d1
    bne     lf_bad
    add     -1, d0
    mov     d0, d2                  # d2 = the part's number - 1
    mov     1, d1
    asl     d2, d1
    mov     (V_LFN_SEEN), d3
    or      d1, d3
    mov     d3, (V_LFN_SEEN)
    mov     13, d1
    mulu    d1, d2                  # d2 = where its characters go
    mov     LfnOffs, a3
    mov     13, d3
lf_ch:
    movbu   (a3), d0
    mov     a2, a0
    add     d0, a0
    movbu   (a0), d0
    movbu   (1, a0), d1
    asl     8, d1
    or      d1, d0
    cmp     0, d0                   # the end, or the padding after it
    beq     lf_next
    mov     0xFFFF, d1
    cmp     d1, d0
    beq     lf_next
    cmp     LFN_MAX, d2
    bcc     lf_next
    cmp     0x20, d0
    bcs     lf_q
    cmp     0x7F, d0
    bcs     lf_put
lf_q:
    mov     0x3F, d0
lf_put:
    mov     LFNBUF, a0
    add     d2, a0
    movbu   d0, (a0)
lf_next:
    inc     d2
    inc     a3
    add     -1, d3
    bne     lf_ch
    bra     lf_ret
lf_bad:
    clr     d0
    mov     d0, (V_LFN_N)
lf_ret:
    ret     [d2,d3,a2,a3], 0x30

LfnValid:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (V_LFN_N), d1
    cmp     0, d1
    beq     lv_no
    mov     1, d0                   # every part seen
    asl     d1, d0
    add     -1, d0
    mov     (V_LFN_SEEN), d1
    cmp     d1, d0
    bne     lv_no
    clr     d0                      # the 8.3 name's checksum
    mov     11, d2
lv_ck:
    mov     d0, d3
    and     1, d3
    asl     7, d3
    lsr     1, d0
    add     d3, d0
    movbu   (a0), d3
    add     d3, d0
    and     0xFF, d0
    inc     a0
    add     -1, d2
    bne     lv_ck
    mov     (V_LFN_CK), d1
    cmp     d1, d0
    bne     lv_no
    mov     1, d0
    bra     lv_ret
lv_no:
    clr     d0
lv_ret:
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# MANIFEST.TXT (README.md, "The manifest"): lines KEY=VALUE, keys NAME and ICON in any case, blanks around
# them ignored, '#' lines and other keys ignored, CR LF or LF, a UTF-8 byte-order mark skipped.

# ParseManifest(a0 = record): TEXTBUF (NUL-ended) into PR_NAME (PF_MNAME) and PR_ICON11 (PF_ICONNAME).
ParseManifest:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a3
    mov     TEXTBUF, a2
    movbu   (a2), d0                # a byte-order mark
    cmp     0xEF, d0
    bne     pm_line
    movbu   (1, a2), d0
    cmp     0xBB, d0
    bne     pm_line
    movbu   (2, a2), d0
    cmp     0xBF, d0
    bne     pm_line
    add     3, a2
pm_line:
    movbu   (a2), d0                # blanks before the key
    cmp     0x20, d0
    beq     pm_blank
    cmp     9, d0
    bne     pm_key
pm_blank:
    inc     a2
    bra     pm_line
pm_key:
    cmp     0, d0
    beq     pm_done
    cmp     0x0A, d0
    beq     pm_eol
    cmp     0x0D, d0
    beq     pm_eol
    cmp     0x23, d0                # a comment
    beq     pm_skip
    mov     a2, a0
    mov     key_name, a1
    call    KeyIs, 0, 0             # -> d0 = 1, a0 = the value
    cmp     0, d0
    beq     pm_icon
    mov     LINEBUF, a1
    mov     LFN_MAX, d0
    call    CopyValue, 0, 0
    cmp     0, d0
    beq     pm_skip                 # an empty NAME= keeps the folder's name
    mov     a3, a0
    add     PR_NAME, a0
    mov     LINEBUF, a1
    call    StrCpy, 0, 0
    mov     (PR_FLAGS, a3), d0
    or      PF_MNAME, d0
    mov     d0, (PR_FLAGS, a3)
    bra     pm_skip
pm_icon:
    mov     a2, a0
    mov     key_icon, a1
    call    KeyIs, 0, 0
    cmp     0, d0
    beq     pm_skip
    mov     LINEBUF, a1
    mov     15, d0
    call    CopyValue, 0, 0
    mov     LINEBUF, a0
    mov     a3, a1
    add     PR_ICON11, a1
    call    Make11, 0, 0
    cmp     0, d0
    beq     pm_skip
    mov     (PR_FLAGS, a3), d0
    or      PF_ICONNAME, d0
    mov     d0, (PR_FLAGS, a3)
pm_skip:                            # to the end of the line
    movbu   (a2), d0
    cmp     0, d0
    beq     pm_done
    cmp     0x0A, d0
    beq     pm_eol
    cmp     0x0D, d0
    beq     pm_eol
    inc     a2
    bra     pm_skip
pm_eol:
    inc     a2
    bra     pm_line
pm_done:
    ret     [d2,d3,a2,a3], 0x30

# KeyIs(a0 = a line, a1 = a key, upper case, NUL-ended) -> d0 = 1 and a0 = its value (after the '=' and
# the blanks around it) when the line starts with that key, in any case; else d0 = 0. Leaf.
KeyIs:
    movbu   (a1), d1
    cmp     0, d1
    beq     ki_eq
    movbu   (a0), d0
    cmp     0x61, d0
    bcs     ki_u
    cmp     0x7B, d0
    bcc     ki_u
    add     -0x20, d0
ki_u:
    cmp     d1, d0
    bne     ki_no
    inc     a0
    inc     a1
    bra     KeyIs
ki_eq:
    movbu   (a0), d0
    cmp     0x20, d0
    beq     ki_b1
    cmp     9, d0
    bne     ki_is
ki_b1:
    inc     a0
    bra     ki_eq
ki_is:
    cmp     0x3D, d0                # '='
    bne     ki_no
    inc     a0
ki_val:
    movbu   (a0), d0
    cmp     0x20, d0
    beq     ki_b2
    cmp     9, d0
    bne     ki_yes
ki_b2:
    inc     a0
    bra     ki_val
ki_yes:
    mov     1, d0
    rets
ki_no:
    clr     d0
    rets

# CopyValue(a0 = the value, a1 = out, d0 = the most characters) -> d0 = its length: up to the end of the
# line, blanks at its end dropped, anything outside ASCII 0x20-0x7E as '?' (a tab as a blank), NUL-ended.
CopyValue:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d3
    clr     d2
cv_c:
    movbu   (a0), d0
    cmp     0, d0
    beq     cv_end
    cmp     0x0A, d0
    beq     cv_end
    cmp     0x0D, d0
    beq     cv_end
    cmp     d3, d2
    bcc     cv_end
    cmp     9, d0
    bne     cv_nt
    mov     0x20, d0
cv_nt:
    cmp     0x20, d0
    bcs     cv_q
    cmp     0x7F, d0
    bcs     cv_put
cv_q:
    mov     0x3F, d0
cv_put:
    movbu   d0, (a1)
    inc     a1
    inc     d2
    inc     a0
    bra     cv_c
cv_end:
    cmp     0, d2                   # blanks at the end
    beq     cv_nul
    movbu   (-1, a1), d0
    cmp     0x20, d0
    bne     cv_nul
    add     -1, a1
    add     -1, d2
    bra     cv_end
cv_nul:
    clr     d0
    movbu   d0, (a1)
    mov     d2, d0
    ret     [d2,d3,a2,a3], 0x30

# Make11(a0 = an 8.3 name, NUL-ended, a1 = out 11 bytes) -> d0 = 1 with the directory form ("ICON    BMP")
# when it is a valid 8.3 name (1-8 characters, then optionally '.' and 0-3; letters, digits and
# !#$%&'()-@^_`{}~; lower case taken as upper), else 0.
Make11:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a1, a3
    mov     11, d1
    mov     0x20, d0
mk_fill:
    movbu   d0, (a1)
    inc     a1
    add     -1, d1
    bne     mk_fill
    mov     a3, a2                  # where the next character goes
    clr     d2                      # characters in this part
    clr     d3                      # 0 = the name, 1 = the extension
mk_c:
    movbu   (a0), d0
    inc     a0
    cmp     0, d0
    beq     mk_end
    cmp     0x2E, d0
    bne     mk_ch
    cmp     0, d3                   # one dot, after at least one character
    bne     mk_no
    cmp     0, d2
    beq     mk_no
    mov     1, d3
    clr     d2
    mov     a3, a2
    add     8, a2
    bra     mk_c
mk_ch:
    cmp     0x61, d0
    bcs     mk_up
    cmp     0x7B, d0
    bcc     mk_up
    add     -0x20, d0
mk_up:
    call    Char83, 0, 0            # d1 = 1 when allowed (keeps d0, a0)
    cmp     0, d1
    beq     mk_no
    mov     8, d1
    cmp     0, d3
    beq     mk_lim
    mov     3, d1
mk_lim:
    cmp     d1, d2
    bcc     mk_no
    movbu   d0, (a2)
    inc     a2
    inc     d2
    bra     mk_c
mk_end:
    cmp     0, d3
    bne     mk_yes
    cmp     0, d2
    beq     mk_no
mk_yes:
    mov     1, d0
    bra     mk_ret
mk_no:
    clr     d0
mk_ret:
    ret     [d2,d3,a2,a3], 0x30

# Char83(d0 = a character, upper case) -> d1 = 1 when an 8.3 name may hold it. Leaf: keeps d0 and a0.
Char83:
    cmp     0x41, d0
    bcs     c8_dig
    cmp     0x5B, d0
    bcs     c8_yes
c8_dig:
    cmp     0x30, d0
    bcs     c8_punct
    cmp     0x3A, d0
    bcs     c8_yes
c8_punct:
    mov     str_83punct, a1
c8_p:
    movbu   (a1), d1
    cmp     0, d1
    beq     c8_no
    cmp     d1, d0
    beq     c8_yes
    inc     a1
    bra     c8_p
c8_yes:
    mov     1, d1
    rets
c8_no:
    clr     d1
    rets

# ================================================================================================
# The icon (README.md, "The icon"): a BMP of exactly ICON_W x ICON_W pixels, 24 or 32 bits per pixel,
# uncompressed (BI_RGB), rows bottom-up or top-down. DecodeBmp(a0 = the file, d0 = its bytes, a1 = out)
# -> d0 = 1 with ICON_W x ICON_W RGB565 pixels at a1, else 0 (the default icon is used then).
DecodeBmp:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     a1, a3
    mov     d0, (0x14, sp)          # the file's bytes
    mov     54, d1
    cmp     d1, d0
    bcs     db_no
    movbu   (a2), d0                # "BM"
    cmp     0x42, d0
    bne     db_no
    movbu   (1, a2), d0
    cmp     0x4D, d0
    bne     db_no
    mov     a2, a0                  # BITMAPINFOHEADER or a later one
    add     14, a0
    call    Read32U, 0, 0
    cmp     40, d0
    bcs     db_no
    mov     a2, a0                  # width
    add     18, a0
    call    Read32U, 0, 0
    cmp     ICON_W, d0
    bne     db_no
    mov     a2, a0                  # height: +32 bottom-up, -32 top-down
    add     22, a0
    call    Read32U, 0, 0
    mov     d0, d2
    cmp     ICON_W, d0
    beq     db_h
    mov     -ICON_W, d1
    cmp     d1, d0
    bne     db_no
db_h:
    mov     a2, a0                  # one plane
    add     26, a0
    call    Read16U, 0, 0
    cmp     1, d0
    bne     db_no
    mov     a2, a0                  # 24 or 32 bits per pixel
    add     28, a0
    call    Read16U, 0, 0
    mov     3, d3
    cmp     24, d0
    beq     db_bpp
    mov     4, d3
    cmp     32, d0
    bne     db_no
db_bpp:
    mov     d3, (0x18, sp)          # bytes per pixel
    mov     a2, a0                  # BI_RGB
    add     30, a0
    call    Read32U, 0, 0
    cmp     0, d0
    bne     db_no
    mov     a2, a0                  # where the pixels start
    add     10, a0
    call    Read32U, 0, 0
    mov     (0x14, sp), d1
    cmp     d1, d0
    bcc     db_no
    mov     d0, a1                  # a1 = the offset
    mov     d3, d0                  # a row: ICON_W * bytes per pixel (a multiple of 4)
    mov     ICON_W, d1
    mulu    d1, d0
    mov     d0, d3                  # d3 = the row's bytes
    mov     ICON_W, d1
    mulu    d3, d1                  # all rows
    add     a1, d1
    mov     (0x14, sp), d0
    cmp     d0, d1
    bhi     db_no                   # the file is too short
    mov     a2, a0                  # the first row shown: the file's last (bottom-up) or first
    add     a1, a0
    mov     d3, (0x1C, sp)          # the step from row to row
    cmp     ICON_W, d2
    bne     db_rows
    mov     d3, d0
    mov     ICON_W-1, d1
    mulu    d1, d0
    add     d0, a0
    clr     d0
    sub     d3, d0
    mov     d0, (0x1C, sp)
db_rows:
    mov     a0, a2                  # a2 = this row in the file
    mov     ICON_W, d2
db_row:
    mov     a2, a0
    mov     ICON_W, d3
db_px:
    movbu   (2, a0), d0             # R
    and     0xF8, d0
    asl     8, d0
    movbu   (1, a0), d1             # G
    and     0xFC, d1
    asl     3, d1
    or      d1, d0
    movbu   (a0), d1                # B
    lsr     3, d1
    or      d1, d0
    movhu   d0, (a3)
    add     2, a3
    mov     (0x18, sp), d1
    add     d1, a0
    add     -1, d3
    bne     db_px
    mov     (0x1C, sp), d1
    add     d1, a2
    add     -1, d2
    bne     db_row
    mov     1, d0
    bra     db_ret
db_no:
    clr     d0
db_ret:
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# The list: ORDER holds the records of the folders with a KN7APP.BIN, sorted by the name shown (ASCII,
# case ignored); V_NPROG of them.
SortPrograms:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    clr     d2
    clr     d3
sp_c:
    mov     (V_NCAND), d0
    cmp     d0, d2
    bcc     sp_sort
    mov     d2, d0
    call    RecAddr, 0, 0
    mov     (PR_FLAGS, a0), d0
    btst    PF_APP, d0
    beq     sp_n
    mov     d3, d0
    asl     2, d0
    mov     ORDER, a1
    add     d0, a1
    mov     a0, (a1)
    inc     d3
sp_n:
    inc     d2
    bra     sp_c
sp_sort:
    mov     d3, (V_NPROG)
    mov     1, d2                   # insertion sort
sp_i:
    mov     (V_NPROG), d0
    cmp     d0, d2
    bcc     sp_ret
    mov     d2, d0
    asl     2, d0
    mov     ORDER, a2
    add     d0, a2                  # a2 = the slot being filled
    mov     (a2), a3                # a3 = the record being placed
sp_j:
    mov     ORDER, d0
    cmp     d0, a2
    beq     sp_place
    mov     (-4, a2), a0
    add     PR_NAME, a0
    mov     a3, a1
    add     PR_NAME, a1
    call    StrCmpI, 0, 0
    cmp     0, d0
    ble     sp_place
    mov     (-4, a2), a0
    mov     a0, (a2)
    add     -4, a2
    bra     sp_j
sp_place:
    mov     a3, (a2)
    inc     d2
    bra     sp_i
sp_ret:
    ret     [d2,d3,a2,a3], 0x30

# StrCmpI(a0, a1) -> d0 < 0, 0, > 0 as the first string sorts before, with, after the second (ASCII,
# case ignored). Leaf.
StrCmpI:
    movbu   (a0), d0
    cmp     0x61, d0
    bcs     sc_u0
    cmp     0x7B, d0
    bcc     sc_u0
    add     -0x20, d0
sc_u0:
    movbu   (a1), d1
    cmp     0x61, d1
    bcs     sc_u1
    cmp     0x7B, d1
    bcc     sc_u1
    add     -0x20, d1
sc_u1:
    cmp     d1, d0
    bne     sc_diff
    cmp     0, d0
    beq     sc_eq
    inc     a0
    inc     a1
    bra     StrCmpI
sc_diff:
    sub     d1, d0
    rets
sc_eq:
    clr     d0
    rets

# ================================================================================================
# CRC-32 (reflected, 0xEDB88320), by table: InitCrc fills CRCTAB; Crc32(a0 = data, d0 = bytes) -> d0.
InitCrc:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     CRCTAB, a0
    clr     d2
ic_n:
    mov     d2, d0
    mov     8, d1
ic_b:
    btst    1, d0
    beq     ic_e
    lsr     1, d0
    xor     0xEDB88320, d0
    bra     ic_nx
ic_e:
    lsr     1, d0
ic_nx:
    add     -1, d1
    bne     ic_b
    mov     d0, (a0)
    add     4, a0
    inc     d2
    cmp     256, d2
    bcs     ic_n
    ret     [d2,d3,a2,a3], 0x30

Crc32:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d3
    mov     -1, d0
    cmp     0, d3
    beq     cr_end
cr_b:
    movbu   (a0), d1
    xor     d0, d1
    and     0xFF, d1
    asl     2, d1
    mov     CRCTAB, a1
    add     d1, a1
    mov     (a1), d1
    lsr     8, d0
    xor     d1, d0
    inc     a0
    add     -1, d3
    bne     cr_b
cr_end:
    not     d0
    ret     [d2,d3,a2,a3], 0x30

# StrCpy(a0 = out, a1 = text) -> a0 at the NUL it copied. Leaf.
StrCpy:
    movbu   (a1), d0
    movbu   d0, (a0)
    cmp     0, d0
    beq     sy_end
    inc     a0
    inc     a1
    bra     StrCpy
sy_end:
    rets

# PutDec(a0 = out, d0 = value) -> a0 at the NUL. Leaf (its digits are built at the end of LINEBUF).
PutDec:
    mov     LINEBUF+0xFF, a1
    clr     d1
    movbu   d1, (a1)
pd_dig:
    clr     d1
    mov     d1, mdr
    mov     10, d1
    divu    d1, d0
    mov     mdr, d1
    add     0x30, d1
    add     -1, a1
    movbu   d1, (a1)
    cmp     0, d0
    bne     pd_dig
pd_cpy:
    movbu   (a1), d0
    movbu   d0, (a0)
    cmp     0, d0
    beq     pd_end
    inc     a0
    inc     a1
    bra     pd_cpy
pd_end:
    rets
