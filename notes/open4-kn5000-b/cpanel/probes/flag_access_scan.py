#!/usr/bin/env python3
"""Which instructions of the v10 main CPU read or write CPANEL_TX_RX_FLAGS (0x8D8C) and
CPANEL_PROTOCOL_FLAGS (0x8D92)?  Scans the linear MAME unidasm listing for absolute operands
and prints each access (or/and/bit/ld/add), so a bit nobody sets, or nobody reads, shows.

    python3 notes/open4-kn5000-b/cpanel/probes/flag_access_scan.py original_ROMs/kn5000_v10_program.rom.unidasm

Caveat: a linear listing can lose sync in data; the symbolic sources were grepped too
(`command grep -rn CPANEL_TX_RX_FLAGS v10/maincpu`), with the same result.
"""
import re, sys
for line in open(sys.argv[1], errors='replace'):
    m = re.search(r'\((0x8d8c|0x8d92)\)', line, re.I)
    if m:
        print(line.rstrip())
