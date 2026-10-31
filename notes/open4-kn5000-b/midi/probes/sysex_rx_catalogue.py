#!/usr/bin/env python3
"""Which incoming SysEx byte strings does the KN5000 v10 main CPU recognise, and which routine handles each?

Walks the recognition trie SysExRx_TrieRoot (6-byte entries {u8 key, u8 action, u32 next}; key 0xFF ends a
list, key 0xFE matches any byte) the way MidiSeq_AssignVoiceSlots / MidiSeq_ScanSlot*_Loop do: an entry whose
action is 0 descends into `next`; an entry whose action is non-zero ends the match, and the message id is that
action (field 0 of the active buffer); fields 1 and 2 are the key and action bytes of the entry `next` points at.
For every message id it prints the matched bytes (after F0, which the parser state machine consumes, and the
manufacturer byte -- the root list is the byte after it) and the two routines the id selects:
SeqChan_CommandHandlers[id] (MidiTable_DispatchHelper: bulk-transfer state machine) and SeqData_Handlers[id]
(SeqData_DispatchHandler: parameter / universal messages).  Names come from symbols/maincpu_v10_symbols_reference.txt.

Run:  python3 notes/open4-kn5000-b/midi/probes/sysex_rx_catalogue.py [--md]
"""
import os, struct, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), *[".."] * 4))
B = 0xE00000
rom = open(os.path.join(ROOT, "original_ROMs/kn5000_v10_program.rom"), "rb").read()
sym, name = {}, {}
for line in open(os.path.join(ROOT, "symbols/maincpu_v10_symbols_reference.txt")):
    p = line.split()
    if len(p) == 2 and not line.startswith("#"):
        a = int(p[1], 16)
        sym[p[0]] = a
        name.setdefault(a, p[0])


def u32(a):
    return struct.unpack_from("<I", rom, a - B)[0]


def walk(lst, path, out):
    i = 0
    while True:
        e = lst + 6 * i
        k, act, nxt = rom[e - B], rom[e + 1 - B], u32(e + 2)
        if k == 0xFF:
            return
        key = "xx" if k == 0xFE else "%02X" % k
        if act:
            f1 = f2 = None
            if nxt:
                f1, f2 = rom[nxt - B], rom[nxt + 1 - B]
            out.append((act, path + [key], f1, f2))
        elif nxt:
            walk(nxt, path + [key], out)
        i += 1


out = []
walk(sym["SysExRx_TrieRoot"], [], out)
seqchan, seqdata = sym["SeqChan_CommandHandlers"], sym["SeqData_Handlers"]
rows = []
for act, path, f1, f2 in sorted(out):
    h1 = name.get(u32(seqchan + 4 * act), hex(u32(seqchan + 4 * act)))
    h2 = name.get(u32(seqdata + 4 * act), hex(u32(seqdata + 4 * act)))
    rows.append([str(act), "F0 <id> " + " ".join(path), "%s %s" % (
        "-" if f1 is None else "%02X" % f1, "-" if f2 is None else "%02X" % f2), h1, h2])
hdr = ["id", "bytes matched (F0, manufacturer, then the trie path)", "f1 f2", "SeqChan_CommandHandlers[id]",
       "SeqData_Handlers[id]"]
if "--md" in sys.argv:
    w = [max(len(r[c]) for r in rows + [hdr]) for c in range(len(hdr))]
    fmt = lambda r: "| " + " | ".join(r[c].ljust(w[c]) for c in range(len(r))) + " |"
    print(fmt(hdr))
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in rows:
        print(fmt(r))
else:
    for r in rows:
        print("  ".join(r))
print("%d terminal paths, %d distinct ids" % (len(out), len({o[0] for o in out})), file=sys.stderr)
