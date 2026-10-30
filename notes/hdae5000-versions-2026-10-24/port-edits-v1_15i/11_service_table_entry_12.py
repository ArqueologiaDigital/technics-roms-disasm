"""PC-link service table entry 12 holds the low 12 bits of its handler's address.

v1.15i's HDAE5000_PPORT_ServiceTable entry 12 is the word 0x000005c0 where its stub,
.Lpps_handler_12 (the call of HDAE5000_PPORT_Svc12_WriteFlsBlockToHd), is at 0x2915c0;
v1.10i's is 0x000004c4 with the stub at 0x2914c4 -- in both, the stub's address AND 0xfff.
Every other entry is the stub's full address; v2.x's entry 12 is too.  [INFERENCE] a fault
of the link that built v1.x: a dispatch of service 12 would jump to 0x0005c0.  llvm-mc
cannot spell `label & 0xfff` in data, so the word is written as the number, with this note.
"""
from _edit import replace

replace("hdae5000_ui_display.s", [
    (b"\t.long .Lpps_handler_12\t; entry 12\n",
     b"\t.long 0x000005c0\t\t; entry 12: .Lpps_handler_12's address AND 0xfff, not the address (see the header)\n"),
    (b"\t; 28-entry jump table (entry 0 unused, entries 1-27 = commands)\n",
     b"\t; 28-entry jump table (entry 0 unused, entries 1-27 = commands).  Entry 12 is not a\n"
     b"\t; pointer: it holds .Lpps_handler_12's address AND 0xfff (v1.10i: the same), so service\n"
     b"\t; 12 cannot be dispatched in v1.x; [INFERENCE] a fault of the link.\n"),
])
print("ok")
