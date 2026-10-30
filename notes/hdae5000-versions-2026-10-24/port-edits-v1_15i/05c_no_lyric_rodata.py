"""The lyrics module's read-only data (hdae5000_data_tables.s): v1.x has none of it.

In v1.15i the language-text pointer table HDAE5000_TextPtrs_LANENG001_to_LANENG006 (0x2cd8aa)
follows the message switch table directly, and the LANENG / LANDEU / LANFRA strings it
points at run up to the boot splash's palette (0x2cd8fe).  v2.x has the strings of the
lyric box and the floppy lyric selector in between ("Reset", "Load", "TESTTEST.TLX",
"Fault : No Lyrics loaded ...", "TLhd", "TLtr", ".TTX", ".MID", "XLT." ...), from
HDAE5000_Str_Blank34 on, with that block's header.
"""
from _edit import delete_routine

gone = delete_routine("hdae5000_data_tables.s", "HDAE5000_Str_Blank34", "HDAE5000_TextPtrs_LANENG001_to_LANENG006")
print("ok: %d lines" % len(gone))
