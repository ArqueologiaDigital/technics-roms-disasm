#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""plugin_regs.py -- QUESTION ANSWERED: "which RegisterObjectTable calls does milk_model.parse_calls see in the SP7001
plug-in's code (src/sp7001/table.s), with the host's (942's) Function-table offsets resolved?"  The class table
(slot 0x2F4, class 0x00040004) must be among them.  RUN (from kn7000/): python3 notes/mn10300-data4-probes/plugin_regs.py"""
# which RegisterObjectTable calls does milk_model.parse_calls see in the SP7001 plug-in's code?
import os, sys
KN7 = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
sys.path.insert(0, os.path.join(KN7, "tools"))
sys.argv = ["gen_data_s.py", "--profile", "sp7001plugin"]
import gen_data_s as G
G.configure("sp7001plugin")
hm, calls = G.host_model("sp7001")
print("host calls 0xec:", calls.get(0xec), "0x174:", calls.get(0x174), "0x250:", calls.get(0x250))
G.MM.HOST_CALLS = dict(calls)
cs = G.MM.parse_calls(G.code_glob(), {**hm.sym_by_name}, mem=None)
for c in cs:
    if c["call"] == "RegisterObjectTable":
        print(c["func"], c["line"], c["call"], hex(c["d0"]) if isinstance(c["d0"], int) else c["d0"], c["a0"], {hex(k): v for k, v in c["stack"].items()})
