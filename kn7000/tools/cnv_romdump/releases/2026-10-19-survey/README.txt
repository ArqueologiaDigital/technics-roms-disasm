KN7000 ROM dumper: the rhythm ROM survey (2026-10-19)
=====================================================

Built from technics-roms-disasm kn7000/tools/cnv_romdump (make). SHA1SUMS lists the files; each is
byte-identical to the binary that passed its test in MAME.

  sdcard-pass4-SURVEY/KN7APP.BIN   the SURVEY build: six 8 MB windows of CPU address space, 48 MB
  check_real_dump.py, find_fw.py,  check on the computer what came back from the card;
  find_rhythm.py                   find_rhythm.py looks for the rhythm ROM in it

The floppy is the same as for passes 1 to 3: KN7LOAD.CNV did not change (SHA-1 6b81f382...). Keep
using the write-protected floppy you already have.

Why a survey. The rhythm ROM (IC18; an IC20 flash on early units) holds the accompaniment styles'
data and their 221 names. Nobody knows its CPU address. The firmware finds it at run time: at
every power-on it compares 16 bytes against "Technics Rhythms" at 0x48010000 (the table flash;
your table 80 has nothing there), 0x40610000, 0x40010000, 0x54E10000 and 0x40810000, and if none
matches it uses 0x54E00000 without checking. Your PROGRAM 893 does exactly the same. This build
reads the two whole regions those addresses lie in:

  R4000000.BIN  0x40000000-0x407FFFFF   (CS0: the probes 0x40010000, 0x40610000)
  R4080000.BIN  0x40800000-0x40FFFFFF   (CS0: the probe 0x40810000)
  R5400000.BIN  0x54000000-0x547FFFFF   (CS5)
  R5480000.BIN  0x54800000-0x54FFFFFF   (CS5: 0x54E00000, the probe 0x54E10000)
  R5500000.BIN  0x55000000-0x557FFFFF   (CS5: the top of a 4 MB device at 0x54E00000)
  R5580000.BIN  0x55800000-0x55FFFFFF   (CS5)

Wherever the chip answers, and however its address lines are wired, the result shows it,
mirrors included. Where nothing answers, the file holds whatever the bus returns; that is
harmless and also tells us something.

What it does to the instrument. It only reads, with ordinary CPU reads, like the firmware's
probes at power-on. The firmware reads only a few bytes at each of those addresses; the survey
reads every byte in between, in the same chip selects. Nothing is written anywhere except the
files on the card, and the tone generators are not touched. If the progress bar ever stops
moving for more than a minute, switch the instrument off: nothing but the card has been written.

Before
  1. The SD card needs about 50 MB free.
  2. Remove the pass 3 files (IC203.BIN ... IC208.BIN, DUMPLIST.TXT) from the card's root if
     they are still there.
  3. If convenient, photograph the SOFT VERSION screen first (hold the UP and DOWN caps of
     part-mixer columns 1, 6 and 8 together, at a normal play screen). Its RHYTHM line is a
     number the firmware reads out of this very ROM; nobody has recorded it yet, and
     find_rhythm.py should find the same number in the dump.

On the instrument
  4. Copy sdcard-pass4-SURVEY/KN7APP.BIN to the card's root folder, replacing the previous
     KN7APP.BIN.
  5. Insert the SD card and the floppy. Do not touch the panel during the run.
  6. DISK MENU > STYLE CONVERT, choose KN7LOAD.CNV, OK.
  7. The dumper's screen: the yellow line at the top right must read "KN7000 ROM DUMPER 1.0 SURVEY".
     It lists six windows, survey_40000000.bin to survey_55800000.bin, then four "unused" lines
     shown [SKIP]; the counter reads "ROM n/10" because of those four. 48 MB go to the card:
     about three quarters of pass 3's time.
  8. At "Done", photograph the screen. After about 15 s the firmware asks "Continue Next?":
     answer NO.
  9. On the computer: copy R4000000.BIN, R4080000.BIN, R5400000.BIN, R5480000.BIN, R5500000.BIN,
     R5580000.BIN and DUMPLIST.TXT from the card's root into pass4-run1/, then delete them from
     the card.
 10. Second run, to show the reads are stable: steps 5-9 again, into pass4-run2/.
 11. python3 check_real_dump.py pass4-run1 pass4-run2
     Expect every file whole and identical in both runs. The six windows are not known ROMs, so
     the "known as" column reads "new". At the end it runs find_rhythm.py, which lists each
     "Technics Rhythms" signature it finds, the firmware's own checksum over the data behind it
     (OK, or NG), the RHYTHM version number, and which address the firmware would use.

Afterwards
 12. Keep the dumps private (copyrighted data). Tell me where they are: I will cut the chip image
     out of the windows, and declare it in MAME as c3cbnd000046.ic18.
