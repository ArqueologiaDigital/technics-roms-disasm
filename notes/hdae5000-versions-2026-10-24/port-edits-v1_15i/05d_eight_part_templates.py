"""HDAE5000_TypeSel_TemplateAllNo: mask 0 and eight part flags of 1, then two pad bytes.

v1.15i 0x2ca404: 00 00, 01 x 8, 00 00 (v2.x: nine flags and one pad byte); the record is
12 bytes either way, as HDAE5000_TypeSel_Init copies it.
"""
from _edit import replace

replace("hdae5000_data_tables.s", [
    (b"\t; a part-selection record template (HDAE5000_TypeSel_Init copies 12 bytes: u16 mask, nine part flags, pad): mask 0, every flag 1 (\"NO \")\n"
     b"\t.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00\n",
     b"\t; a part-selection record template (HDAE5000_TypeSel_Init copies 12 bytes: u16 mask, eight part flags, 2 pad bytes): mask 0, every flag 1 (\"NO \")\n"
     b"\t.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00\n"),
])
print("ok")
