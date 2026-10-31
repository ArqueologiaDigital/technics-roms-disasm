"""The naming keyboard's two character tables end with a pointer to an empty string.

HDAE5000_TextPtrs_A_to_SPC (and _2) hold 38 string pointers, then a 39th word that points
four bytes on, at a 2-byte zero run right after it: an empty string (v1.15i 0x2ca70a holds
0x002ca70e, 0x2ca7f6 holds 0x002ca7fa; v2.01i 0x002e17a2 likewise).  The v2.x trees spell it
as bytes and a "." string (its high bytes are 2e 00); here it is the pointer it is, with a
label on the empty string.

Since 2026-10-31 the v2.x trees spell it the same way (lane hdae-ledgers), so a replay that starts
from the current hdae5000_v2_01i/ finds the pointer already symbolic and has nothing to do.
"""
from _edit import read, replace

if b"HDAE5000_Str_Empty_AtoSPC_2:\n" in read("hdae5000_data_tables.s"):
    print("ok (already symbolic in the tree the port started from)")
    raise SystemExit(0)
replace("hdae5000_data_tables.s", [
    (b"\t.long\tHDAE5000_Str_SPC\n\t.byte 0xa2, 0x17\n\t.asciz \".\"\n\t.zero 2\n",
     b"\t.long\tHDAE5000_Str_SPC\n\t.long\tHDAE5000_Str_Empty_AtoSPC\t; the table's end: a pointer to the empty string after it\n"
     b"HDAE5000_Str_Empty_AtoSPC:\n\t.zero 2\n"),
    (b"\t.long\tHDAE5000_Str_SPC_2\n\t.byte 0x8e\n\t.asciz \"\\030.\"\n\t.zero 2\n",
     b"\t.long\tHDAE5000_Str_SPC_2\n\t.long\tHDAE5000_Str_Empty_AtoSPC_2\t; the table's end: a pointer to the empty string after it\n"
     b"HDAE5000_Str_Empty_AtoSPC_2:\n\t.zero 2\n"),
])
print("ok")
