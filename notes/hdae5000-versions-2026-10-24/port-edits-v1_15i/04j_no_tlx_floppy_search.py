"""The floppy song search of HDAE5000_CopyToHd_Execute looks for eight part files in v1.x.

It tries <name>.LSW ... <name>.MD with HamaFn__findfirst, setting bit k of the part mask for
each one found, and then calls HDAE5000_FdSong_CheckFiles; v2.x tries <name>.TLX as part 8
as well.  ".TLX" occurs nowhere in v1.15i.  The ninth search and its string go.
"""
from _edit import delete_between, delete_block

delete_between("hdae5000_filesystem.s", ".LFSD__f8", ".LFSD__post_search")
delete_block("hdae5000_data_tables.s", "HDAE5000_Str_TLX")
print("ok")
