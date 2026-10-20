# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# menu.inc -- the program menu's memory map and constants (menu.s, tramp.s; README.md). The menu is an
# application of KN7LOAD.CNV (../cnv_romdump/kn7cnv.inc, included first): the root KN7APP.BIN.
#
# Everything it writes lies in the RAM a style converter may use, 0x502BA000-0x50379FFF, off the
# firmware's mailbox page 0x5031B000-0x5031BFFF and clear of the loader's resident area below APP_BASE
# (the range Another World measured untouched by the firmware on programs 893 and 941: kn5000-anotherworld
# kn7000/README-CNV.md, "Memory"). layout.py checks this map at every build.

# ---- in the application area (zeroed by the loader before it loads the menu) -----------------------
.equ IMAGE_MAX,     0x502C0000      # the menu's image (header, code, font, icon, trampoline copy) ends below
.equ M_VARS,        0x502C0000      # 1 KB: variables (V_* below)
.equ PROG_TAB,      0x502C1000      # MAX_PROG records of PR_LEN bytes: the programs found
.equ ORDER,         0x502C3800      # MAX_PROG words: record addresses, sorted by name
.equ WORKBUF,       0x502C4000      # 32 KB: directory clusters, the root directory, raw reads
.equ WORK_SECS,     64              #   sectors it holds
.equ FATBUF,        0x502CC000      # 512 bytes: the FAT sector last read (V_FATSEC)
.equ SECBUF,        0x502CC200      # 512 bytes: a file's last, partial sector
.equ TEXTBUF,       0x502CC400      # MAN_MAX + 1 bytes: MANIFEST.TXT
.equ MAN_MAX,       2047
.equ LINEBUF,       0x502CCC00      # 256 bytes: a line being formatted
.equ LFNBUF,        0x502CCD00      # 256 bytes: the long name being put together (LFN_MAX + 1 used)
.equ LFN_MAX,       63
.equ LFN_WORDS,     (LFN_MAX+1)/4
.equ BMPBUF,        0x502CD000      # BMP_MAX bytes: an icon file
.equ BMP_MAX,       0x3000
.equ CRCTAB,        0x502D0000      # 1 KB: CRC-32 table
.equ AREA_END,      0x502D0400      # the end of what the menu uses below LB_ADDR (kn7cnv.inc)
# ---- above the application area (not zeroed by anyone; written before it is read) ----------------
.equ STAGE,         0x502E8000      # the chosen KN7APP.BIN, read and checked here before it is started
.equ STAGE_MAX,     LB_ADDR - APP_BASE   # the most a program may have: up to the launch block
.equ ICONS,         0x50320000      # MAX_PROG x ICON_BYTES: the decoded icons
.equ ICON_W,        32
.equ ICON_BYTES,    ICON_W*ICON_W*2
# ---- the trampoline's region (tramp.s), filled just before a program is started -------------------
.equ T_BASE,        0x50360000
.equ T_SLED,        T_BASE          # SLED_LEN nops and a rets: executed to push every other line out of
.equ SLED_LEN,      0x8000          #   the instruction cache (README.md, "Caches"); the rets is its last 2 bytes
.equ T_CODE,        0x50368000      # tramp.s, assembled to run here (its .mnbase)
.equ T_CODE_MAX,    0x1800
.equ T_DATA,        0x50369800      # what the menu hands the trampoline (TD_* below)
.equ T_END,         0x5036A000
.equ EVICT_FROM,    0x48400000      # the D-cache is emptied by reading EVICT_LEN bytes of program flash
.equ EVICT_LEN,     0x10000         #   one load per 16-byte line

# ---- the trampoline's data block, at T_DATA (filled by the menu) ------------------------------------
.equ TD_RETSP,      0x00            # the stack pointer the loader called the menu with: return there
.equ TD_SIZE,       0x04            # bytes to copy from STAGE to APP_BASE
.equ TD_MS,         0x08            # SV_MSCOUNT (0: none), for the failure screen's hold
.equ TD_STATE,      0x0C            # the failure screen's: 0 first call, then its start (ms or calls)
.equ TD_RESULT,     0x10            # 0 started, else why not (TR_*): the test harness reads it
.equ TD_FG,         0x14            # colours the failure screen draws in
.equ TD_BG,         0x18
.equ TD_LB,         0x20            # LB_LEN bytes: the launch block to install (kn7cnv.inc)
.equ TD_MSG,        0x120           # 96 bytes: the failure screen's first line, NUL-ended
.equ TD_LEN,        0x180
.equ TR_OK,         0
.equ TR_COPY,       1               # what landed at APP_BASE differs from what was checked in STAGE
.equ TR_HEADER,     2               # the header is not the loader's (cannot happen: the menu checked it)

# ---- a program record, PR_LEN bytes at PROG_TAB ----------------------------------------------------
.equ MAX_PROG,      64
.equ PR_LEN,        0xA0
.equ PR_FLAGS,      0x00            # PF_* below
.equ PR_DIRCL,      0x04            # the folder's first cluster
.equ PR_APPCL,      0x08            # KN7APP.BIN: first cluster, size
.equ PR_APPSZ,      0x0C
.equ PR_MANCL,      0x10            # MANIFEST.TXT
.equ PR_MANSZ,      0x14
.equ PR_ICONCL,     0x18            # the icon file MANIFEST.TXT names
.equ PR_ICONSZ,     0x1C
.equ PR_DIR,        0x20            # 16 bytes: the folder's 8.3 name, "AW" (as LB_DIR)
.equ PR_ICON11,     0x30            # 12 bytes: ICON= as an 11-byte directory name
.equ PR_CHECK,      0x3C            # what the last check of KN7APP.BIN found (CK_*)
.equ PR_NAME,       0x40            # 64 bytes: the name shown
.equ PR_ICONP,      0x80            # its icon: ICONS + index * ICON_BYTES, or DefaultIcon
.equ PR_INDEX,      0x84            # its index in PROG_TAB (the folder's place in the root directory)
.equ PF_APP,        0x01            # KN7APP.BIN is there
.equ PF_MANIFEST,   0x02            # MANIFEST.TXT is there
.equ PF_MNAME,      0x04            # ... and gave a NAME
.equ PF_ICON,       0x08            # the icon was read and decoded (else the default icon)
.equ PF_LONG,       0x10            # the folder has a long name (PR_NAME holds it unless PF_MNAME)
.equ PF_ICONNAME,   0x20            # MANIFEST.TXT gave a valid ICON= name
.equ PF_ICONBAD,    0x40            # ... but the file is missing or not a 32x32 24/32-bit BMP
.equ PF_MANBAD,     0x80            # MANIFEST.TXT could not be read (or holds no line we use)
.equ CK_NONE,       0               # not checked yet
.equ CK_OK,         1
.equ CK_READ,       2               # the card could not be read
.equ CK_SIZE,       3               # empty, or larger than STAGE_MAX
.equ CK_HEADER,     4               # not an application for this loader (magic, base, size, entry)
.equ CK_ABI,        5               # built for another loader version
.equ CK_CRC,        6               # its CRC-32 does not match

# ---- variables, at M_VARS ------------------------------------------------------------------------
.equ V_STATE,       M_VARS+0x00     # ST_* below
.equ V_CALLS,       M_VARS+0x04     # converter calls so far
.equ V_PANEL,       M_VARS+0x08     # the firmware's switch bitmaps (CPR; CPL/CPC at +0x30), or 0
.equ V_MS,          M_VARS+0x0C     # the kernel's millisecond counter (SV_MSCOUNT), or 0
.equ V_PART,        M_VARS+0x10     # the card: the partition's first sector
.equ V_SPC,         M_VARS+0x14     # sectors per cluster
.equ V_FATLBA,      M_VARS+0x18     # the first FAT
.equ V_ROOTLBA,     M_VARS+0x1C     # the root directory
.equ V_ROOTSECS,    M_VARS+0x20
.equ V_DATALBA,     M_VARS+0x24     # cluster 2
.equ V_MAXCL,       M_VARS+0x28     # the highest cluster number
.equ V_CLBYTES,     M_VARS+0x2C
.equ V_FATSEC,      M_VARS+0x30     # the FAT sector in FATBUF, or -1
.equ V_NPROG,       M_VARS+0x34     # records in PROG_TAB (folders with a KN7APP.BIN, once the scan is done)
.equ V_NCAND,       M_VARS+0x38     # folders in the root directory (the scan's candidates)
.equ V_SCANI,       M_VARS+0x3C     # the next candidate the scan looks into
.equ V_SEL,         M_VARS+0x40     # the selected program (an index into ORDER)
.equ V_TOP,         M_VARS+0x44     # the first program on the page shown
.equ V_BTN,         M_VARS+0x48     # the buttons down at the last call (B_* bits)
.equ V_REDRAW,      M_VARS+0x4C     # RD_* bits: what to draw at the end of this call
.equ V_LCDSUM,      M_VARS+0x50     # the sampled LCD checksum after our last drawing
.equ V_EXIT_T0,     M_VARS+0x54     # when EXIT went down (ms | 1, or calls | 1), 0 = up
.equ V_FAIL,        M_VARS+0x58     # why the menu cannot go on (a message), in ST_FAIL
.equ V_FAILT0,      M_VARS+0x5C     # when that was shown
.equ V_RUNREC,      M_VARS+0x60     # the record being read to STAGE / started
.equ V_RDCL,        M_VARS+0x64     # reading KN7APP.BIN to STAGE: the next cluster,
.equ V_RDPOS,       M_VARS+0x68     #   the bytes read so far,
.equ V_RDN,         M_VARS+0x6C     #   the clusters read so far
.equ V_ERR,         M_VARS+0x70     # the last raw read's result
.equ V_INREAD,      M_VARS+0x74     # 1 while the firmware reads sectors for us, into
.equ V_RDDST,       M_VARS+0x78     #   [V_RDDST, V_RDDST + V_RDLEN) (the MAME tests' write tap reads these)
.equ V_RDLEN,       M_VARS+0x7C
.equ V_FG,          M_VARS+0x80     # drawing colours (RGB565) and text scale
.equ V_BG,          M_VARS+0x84
.equ V_SCALE,       M_VARS+0x88
.equ V_NREDRAW,     M_VARS+0x8C     # full redraws because the LCD no longer showed ours
.equ V_DR_CL,       M_VARS+0x90     # the directory reader: the cluster in WORKBUF (0 = the root),
.equ V_DR_LBA,      M_VARS+0x94     #   the next sector of the root or of this cluster,
.equ V_DR_LEFT,     M_VARS+0x98     #   sectors left in it,
.equ V_DR_PTR,      M_VARS+0x9C     #   the next entry in WORKBUF,
.equ V_DR_END,      M_VARS+0xA0     #   the end of what WORKBUF holds,
.equ V_DR_NCL,      M_VARS+0xA4     #   clusters read (bounded by DIR_MAXCL)
.equ V_DR_ERR,      M_VARS+0xA8     #   1 when a read failed or the chain broke
.equ V_LFN_CK,      M_VARS+0xAC     # the long-name entries before an 8.3 entry: their checksum,
.equ V_LFN_SEEN,    M_VARS+0xB0     #   the sequence numbers seen (bit n-1), and
.equ V_LFN_N,       M_VARS+0xB4     #   how many there are (from the first one), 0 = none
.equ V_TMP,         M_VARS+0xB8     # scratch for a scan step
.equ V_SCANT0,      M_VARS+0xBC     # when this call's scan began (ms)
.equ V_STEPS,       M_VARS+0xC0     # scan steps done in this call
.equ V_MSGREC,      M_VARS+0xC4     # the record the message line is about (0 = none)
.equ V_MSG,         M_VARS+0xC8     # the message line's text, and its colour
.equ V_MSGCOL,      M_VARS+0xCC
.equ V_NFOLDERS,    M_VARS+0xD0     # folders looked into, for the screen
.equ V_PRESSES,     M_VARS+0xD4     # button presses taken (the MAME tests read it)
.equ V_LASTBTN,     M_VARS+0xD8     # the last one (B_* bit number)
.equ V_LAUNCHES,    M_VARS+0xDC     # 1 once the trampoline has been called
.equ V_ROOTFULL,    M_VARS+0xE0     # 1 when more folders than MAX_PROG were found
.equ V_TRUNC,       M_VARS+0xE4
.equ V_ENTRYSP,     M_VARS+0xE8     # the stack pointer the loader called the menu with (the trampoline returns there)
.equ V_REC,         M_VARS+0xEC     # the record the scan step works on
.equ V_EXITARMED,   M_VARS+0xF0     # 1 once EXIT has been held QUIT_MS: the menu ends when it is let go
.equ V_LEAVEREQ,    M_VARS+0xF4     # 1 once LEAVE went down: the menu ends when it is let go
.equ V_DIRBUF,      M_VARS+0x100    # 16 bytes: an 11-byte name being compared
.equ V_LCDSUM2,     M_VARS+0x110    # the sum read this call (for the tests)

.equ RD_ALL,        1               # V_REDRAW: the whole screen
.equ RD_STATUS,     2               #   the progress screen's status lines only
.equ ST_INIT,       0               # first call: the loader's table, the screen
.equ ST_PANEL,      1               # the panel bitmaps, by signature (one search per call)
.equ ST_ROOT,       2               # the card's geometry and the root directory: the candidate folders
.equ ST_SCAN,       3               # each candidate: KN7APP.BIN, MANIFEST.TXT, the icon
.equ ST_MENU,       4               # the list: waiting for the buttons
.equ ST_READ,       5               # reading the chosen KN7APP.BIN to STAGE, a cluster or so per call
.equ ST_FAIL,       6               # cannot go on: the reason stays on screen; EXIT, or 15 s, ends it
.equ ST_END,        7               # answered 0xFE

# ---- limits (every loop is bounded) ----------------------------------------------------------------
.equ DIR_MAXCL,     64              # clusters of one folder's directory looked at
.equ ROOT_MAXSECS,  256             # root directory sectors looked at (8192 entries)
.equ FILE_MAXCL,    0x2E000/512+1   # clusters of a file followed (a program, at 512-byte clusters)
.equ SCAN_MS,       120             # scan work per call before the firmware gets the main task back
.equ HOLD_MS,       15000           # a failure stays on screen this long when EXIT cannot be read
.equ HOLD_CALLS,    300             # ... or this many calls (request 5: about 20 a second)
.equ QUIT_MS,       1500            # hold EXIT this long to leave
.equ QUIT_CALLS,    30
.equ RQ_SHOW,       5               # the request the menu answers: show the text, call again

# ---- the buttons, as B_* bit numbers (ButtonTab in menu.s) ----------------------------------------
.equ B_L1,          0               # LCDL 1..5: the five rows
.equ B_L5,          4
.equ B_R1,          5               # LCDR 1: page up
.equ B_R2,          6               # LCDR 2: page down
.equ B_R4,          8               # LCDR 4: leave
.equ B_R5,          9               # LCDR 5: RUN
.equ B_EXIT,        10              # EXIT (held QUIT_MS: leave)
.equ B_PGUP,        11
.equ B_PGDN,        12
.equ B_PREV,        13              # PART SELECT LEFT
.equ B_NEXT,        14              # PART SELECT RIGHT 1
.equ NBUTTONS,      15
.equ M_UP,          (1<<B_R1)|(1<<B_PGUP)   # the buttons that turn a page back
.equ M_DOWN,        (1<<B_R2)|(1<<B_PGDN)   # and forward
# The buttons the menu reads. Each one was pressed while the menu ran, in MAME, and changed no setting
# and drew nothing (test/buttons.lua, README.md "Buttons"); R3 is read for the test but left out here.
.ifndef BUTTONS_USED                # (test/run_menu_tests.sh buttons builds a menu that reads none: -D BUTTONS_USED=0)
.equ BUTTONS_USED,  0x7FFF - (1<<7)
.endif

# ---- the screen ----------------------------------------------------------------------------------
.equ TITLE_H,       28              # the title bar, as the firmware's screens have it
.equ ROWS,          5               # programs per page, one beside each left button (LCDL 1..5),
.equ ROW_H,         42              #   rows of ROW_H from TITLE_H, as the firmware lays out its buttons
.equ LIST_W,        512             # the list's width; the right buttons' labels after it
.equ LABEL_X,       520
.equ LABEL_W,       116
.equ NAME_CHARS,    (LIST_W-56)/8   # the characters of a name a row shows
.equ ICON_DY,       (ROW_H-ICON_W)/2
.equ MARK_DY,       (ROW_H-10)/2
.equ TEXT_DY,       (ROW_H-13)/2
.equ C_BG,          0x0000
.equ C_TITLE,       0x0010          # the loader's dark blue
.equ C_TEXT,        0xFFFF
.equ C_DIM,         0x8410
.equ C_SEL,         0x0230          # the selected row
.equ C_PANEL,       0x0008          # the progress and failure screens' background
.equ C_SELTXT,      0xFFFF
.equ C_LABEL,       0x3186          # a button's label box
.equ C_RUN,         0x0400          # RUN's
.equ C_BAD,         0xF800
.equ C_WARN,        0xFFE0
.equ C_OK,          0x07E0
.equ C_LINE,        0x4208
.equ C_MARK,        0xFC00          # the firmware's orange marker by a button's label
