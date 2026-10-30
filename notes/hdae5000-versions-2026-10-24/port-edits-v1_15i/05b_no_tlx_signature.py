"""HDAE5000_PartSignatureTable has eight records in v1.x: no TLX one, no "TLhd" string.

v1.15i 0x2e0950-0x2e098f: eight {pointer, u16 offset, u16 length} records, LSW .. MD, and
the signature strings follow at 0x2e0990 with "HK" (MD's) first; v2.x has a ninth record
for TLX ("TLhd", offset 0, 4 bytes) and its string in front of "HK".
"""
import re
from _edit import read, write

f = "hdae5000_data_tables.s"
s = read(f)
s, n = re.subn(rb"\t\.long\tHDAE5000_PartSig_TLX\n\t\.short\t0, 4\n", b"", s)
assert n == 1
s, n = re.subn(rb"HDAE5000_PartSig_TLX:\t\.asciz \"TLhd\"\n\t\.balign 2, 0x00[^\n]*\n", b"", s)
assert n == 1
s = s.replace(b"indexed by part (LSW, PMT, SQT, CMP, TM, MSP, RCM, MD, TLX)",
              b"indexed by part (LSW, PMT, SQT, CMP, TM, MSP, RCM, MD; v2.x adds TLX)")
write(f, s)
print("ok")
