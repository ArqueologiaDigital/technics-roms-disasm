"""Start v1.10i's zero tail at nothing: the copied v1.15i tree fills to 0x300000 exactly, and
while its layout is not v1.10i's yet the image may grow; 99 (../port-edits-v1_15i/
99_tail_fill.py, with PORT_TREE=hdae5000_v1_10i) sets the count at the end."""
from _edit import replace

replace("hdae5000_init_data.s", [(b"\t.zero 124532\n", b"\t.zero 0\n")])
print("ok")
