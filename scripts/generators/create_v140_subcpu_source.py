#!/usr/bin/env python3
r"""create_v140_subcpu_source.py -- derive the v1.40 sub-CPU payload source tree from v1.41.

QUESTION THIS ANSWERS
    What, exactly, is different between sub-CPU payload v1.40 and v1.41?  The raw byte diff
    of the two 196,608-byte images is 56,018 bytes in 2,508 runs; almost all of it is address
    ripple from two code changes.  This script is the complete SEMANTIC delta: it copies the
    v141 tree (itself "v142 + EDITS", scripts/generators/create_v141_subcpu_source.py) and
    applies EDITS below, and the result assembles byte-for-byte to
    original_ROMs/kn5000_subprogram_v140.rom (make gate, section "subcpu payload v140").
    Found with scripts/analysis/subcpu_v141_v142_alignment.py (v141 as reference, v140 as
    other); notes/v140-subcpu-port/README.md has its output and the per-label address map.
      1. the payload version word at 0x00f000: 140 instead of 141;
      2. sub-command 0x24 of the 0x2B inter-CPU message (DSP_Cmd2B_SetParam ->
         DSP_SetVoiceCoefficients) is split differently.  In v1.40 the CALLER looks up the
         part's patch record (ToneDB_Find_ToneRecord on the part's tone selector) and reads
         the {lo, hi} sub-tone reference at +0x27+2*i itself, then passes (lo, hi) to the
         callee; a reference with hi bit 5 set is resolved by ToneDB_Find_ToneRecord(lo, hi).
         v1.41 passes (part, i), does the lookup in the callee, and resolves bit-5 references
         with ToneDB_Find_SubToneRecord(patch record, i, 0xFF) instead.  The v1.40 callee is
         134 bytes shorter (no stack frame), the caller 82 bytes longer, and the jr after
         DSP_Cmd2B_ReadParam5D becomes a jrl (+1);
      3. register allocation in the same compiled function (AUDIO_PROCESS_DSP's message
         loop) differs: v1.40 keeps the 0x2B channel nibble in QIZ and the 14-bit parameter
         index in IZ (DSP_Cmd2B_VoiceParamWrite, +1 byte), and the ring-buffer type word in
         IZ instead of the frame slot (XSP+12) (DSP_Process_ReadNext, -2 bytes; its reader in
         Audio_Process_DSP_MsgSizeCheck takes IZL instead, same length).
    Net -134 bytes after DSP_SetVoiceCoefficients, then -52 after DSP_Process_ReadNext; the
    zero-initialised RAM (Payload_Bss_Start) starts 0x34 lower than in v1.41.  Nothing else
    differs: that is what the byte-exact build proves.

    The v140 tree is maintained as "v141 + these edits" (multi-version sync policy): after a
    v142 change, run create_v141_subcpu_source.py, then this script, and commit all three
    trees; `--check` reports drift.  The long edit (the v1.41 DSP_SetVoiceCoefficients) is
    located by its first and last lines and pinned by the SHA-1 of the v1.41 text it
    replaces, so any upstream change inside it stops the generator instead of being lost.

RUN
    python3 scripts/generators/create_v140_subcpu_source.py           # (re)write v140/subcpu
    python3 scripts/generators/create_v140_subcpu_source.py --check   # exit 1 if v140 drifted
    make rebuilt_ROMs/kn5000_subprogram_v140.llvm.rom && cmp \
        rebuilt_ROMs/kn5000_subprogram_v140.llvm.rom original_ROMs/kn5000_subprogram_v140.rom
"""
import difflib
import hashlib
import os
import shutil
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, "v141/subcpu")
DST = os.path.join(ROOT, "v140/subcpu")
COPY = ["subcpu_data_tables.s", "subcpu_fp_math.s", "subcpu_vectors.s", "subcpu.ld",
        "shared/sfr_tmp94c241.s"]
MAIN_SRC, MAIN_DST = "kn5000_subprogram_v141.s", "kn5000_subprogram_v140.s"
# The core code is split into core/*.s (scripts/tools/split_v142_subcpu_core.py, 2026-10-31).  Every
# file there is copied, and an EDIT or SPAN addressed to MAIN_DST is applied in whichever of the main
# file and core/*.s holds its text (exactly one must).
CORE = "core"


def core_files(src):
    d = os.path.join(src, CORE)
    return sorted(os.path.join(CORE, f) for f in os.listdir(d) if f.endswith(".s")) if os.path.isdir(d) else []


def resolve(texts, f, needle):
    if f != MAIN_DST:
        return f
    hits = [k for k in [MAIN_DST] + [k for k in texts if k.startswith(CORE + "/")] if texts[k].count(needle)]
    if len(hits) != 1:
        sys.exit("EDIT for %s: text found in %d main-family files (want 1): %r" % (f, len(hits), needle[:80]))
    return hits[0]

V141_BANNER = (
    b"; =============================================================================\n"
    b"; KN5000 Sub-CPU Payload ROM v1.41 (192KB)\n"
    b"; =============================================================================\n"
    b"; GENERATED from v142/subcpu by scripts/generators/create_v141_subcpu_source.py, whose\n"
    b"; EDITS list is the whole v1.41 / v1.42 difference.  Edit v142 and re-run that script\n"
    b"; rather than editing this tree by hand (it has --check).\n"
    b"; \xe2\x9a\xa0 ADDRESSES QUOTED IN COMMENTS ARE v1.42 ADDRESSES (the comments are v142's).\n"
    b";   v1.41 address = v1.42 address        for 0x000400-0x01f924 (vectors, tables, RESET)\n"
    b";                 = v1.42 address - 0x17 for 0x01f93b-0x03d2aa (after RESET's v1.42-only stores)\n"
    b";                 = v1.42 address - 0x18 for 0x03d2ac-0x03ee75 (FP_dcmp onward)\n"
    b";   and DRAM in the zero-initialised window (Payload_Bss_Start+offset) is 0x18 lower.\n"
    b"; Labels are what to trust: rebuilt_ROMs/kn5000_subprogram_v141.llvm.elf and\n"
    b"; symbols/subcpu_v141_symbols_reference.txt give the v1.41 address of every name.\n"
    b"; =============================================================================\n")

# The address map below was measured label by label (v142 ELF against v140 ELF) by
# scripts/analysis/subcpu_version_address_map.py; notes/v140-subcpu-port/README.md has it.
V140_BANNER = (
    b"; =============================================================================\n"
    b"; KN5000 Sub-CPU Payload ROM v1.40 (192KB)\n"
    b"; =============================================================================\n"
    b"; GENERATED from v141/subcpu (itself generated from v142/subcpu) by\n"
    b"; scripts/generators/create_v140_subcpu_source.py, whose EDITS list is the whole\n"
    b"; v1.40 / v1.41 difference.  Edit v142, re-run create_v141_subcpu_source.py and then\n"
    b"; that script, rather than editing this tree by hand (both have --check).\n"
    b"; \xe2\x9a\xa0 ADDRESSES QUOTED IN COMMENTS ARE v1.42 ADDRESSES (the comments are v142's).\n"
    b";   v1.40 address = v1.42 address        for 0x000400-0x01f924 (vectors, tables, RESET)\n"
    b";                 = v1.42 address - 0x17 for 0x01f93b-0x03111a (to DSP_SetVoiceCoefficients' entry)\n"
    b";                 = v1.42 address - 0x9d for 0x03122f-0x035cbf (DSP_SetCoeff_CopyDirect to\n"
    b";                                           DSP_Cmd2B_ReadParam5D's entry)\n"
    b";                 = v1.42 address - 0x4a for 0x035cf5-0x035d1e (DSP_Cmd2B_ReadParam11 to\n"
    b";                                           DSP_Cmd2B_VoiceParamWrite's entry)\n"
    b";                 = v1.42 address - 0x49 for 0x035d4a-0x036033 (DSP_Cmd2B_PostProcess to\n"
    b";                                           DSP_Process_ReadNext's entry)\n"
    b";                 = v1.42 address - 0x4b for 0x036044-0x03d2aa (DSP_Process_Exit onward)\n"
    b";                 = v1.42 address - 0x4c for 0x03d2ac-0x03ee75 (FP_dcmp onward)\n"
    b";   and DRAM in the zero-initialised window (Payload_Bss_Start+offset) is 0x4c lower.\n"
    b";   The bodies the v1.40 edits rewrite (DSP_SetVoiceCoefficients, DSP_Cmd2B_SetParam,\n"
    b";   DSP_Cmd2B_VoiceParamWrite, DSP_Process_ReadNext) have no single shift.\n"
    b"; Labels are what to trust: rebuilt_ROMs/kn5000_subprogram_v140.llvm.elf and\n"
    b"; symbols/subcpu_v140_symbols_reference.txt give the v1.40 address of every name.\n"
    b"; =============================================================================\n")

# --- v1.41 DSP_SetVoiceCoefficients (header + body), replaced as one span -----------------
SVC_FIRST = b"; DSP_SetVoiceCoefficients -- Write DSP voice coefficients\n"
SVC_LAST = b"DSP_SetCoeff_Return:\n\tpop xiz\n\tlda xsp, (xsp + 10)\n\tret\n"
SVC_SHA1 = "0fe564e47f12f3161026a555a4e0a0baf91339b7"   # of the v1.41 span (renamed ToneDB_* cells, 2026-11-16)
SVC_V140 = b"""\
; DSP_SetVoiceCoefficients -- v1.40 form (the v1.41 one takes a part and an index instead)
; Copy the 10-byte ToneDB record named by ONE sub-tone reference into a caller-supplied
; buffer.  Nothing here touches a DSP; the name is v1.42's (see the note there).
; Entry: WA = reference low byte lo, BC = reference high byte hi -- the {lo, hi} pair at
;        patchrec+0x27+2*i, which in v1.40 DSP_Cmd2B_SetParam reads before the call;
;        XDE = destination buffer.
; Exit:  HL = 10 (the byte count, which DSP_Cmd2B_PostProcess turns into the reply length),
;        XIX = source record.
; Body:  hi & 0x20 set -> ToneDB_Find_ToneRecord(WA = lo, BC = hi) supplies the source
;                         record (v1.41: ToneDB_Find_SubToneRecord(patchrec, i, DE = 0xff));
;        otherwise     -> idx = ((hi & 0x1f) << 7) + (lo & 0x7f)
;                         e   = u16[ ToneDB_RelBase + Root->+0x7c + 2*idx ]
;                         src = ToneDB_RelBase + Root->+0xb0 + 10*e
;        Ten bytes are copied src -> XDE.  No stack frame: the destination walks in XIZ.
DSP_SetVoiceCoefficients:
	push	xiz
	ld	xiz, xde
	ld	de, bc
	and	de, 0x20
	cp	de, 0x20
	jr	z, DSP_SetCoeff_DirectLookup
	cp	de, 0:i3
	jr	nz, DSP_SetCoeff_CopyLoop
	and	wa, 0x7f
	ld	de, bc
	and	de, 0x1f
	and	bc, 0xc0
	cp	bc, 0xc0
	jr	z, DSP_SetCoeff_LoadTableBase
	cp	bc, 0x80
	jr	z, DSP_SetCoeff_LoadTableBase
	cp	bc, 0x40
	jr	z, DSP_SetCoeff_LoadTableBase
	cp	bc, 0:i3
	jr	nz, DSP_SetCoeff_ComputeIndex

; Every value of hi & 0xc0 arrives here, so the four-way compare is vestigial.
; XHL = ToneDB_RootPtr->+0x7c, the sub-tone index table.
DSP_SetCoeff_LoadTableBase:
	ld	xbc, (ToneDB_RootPtr:24)
	ld	xhl, (xbc+124)

; e = u16 table[((hi & 0x1f) << 7) | lo]; XIX = ToneDB_RelBase + Root->+0xb0 + 10*e.
DSP_SetCoeff_ComputeIndex:
	ld	bc, de
	sll	bc, 7
	add	bc, wa
	add	bc, bc
	ld	wa, bc
	extz	xwa
	add	xwa, xhl
	add	xwa, (ToneDB_RelBase:24)
	ld	xwa, (xwa)
	ld	bc, wa
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xhl, (xwa+176:16)
	ld	xix, (ToneDB_RelBase:24)
	add	xix, xhl
	ld	wa, bc
	mul	wa, 10
	add	xix, xwa
	jr	DSP_SetCoeff_CopyLoop

; hi bit 5 set: the reference itself (WA = lo, BC = hi, unmasked) is the selector handed to
; ToneDB_Find_ToneRecord.
DSP_SetCoeff_DirectLookup:
	call	ToneDB_Find_ToneRecord
	ld	xix, xhl

; HL = 10, the byte count and the return value.
DSP_SetCoeff_CopyLoop:
	ldw	hl, 10
	ld	bc, 0:i3
	cp	bc, hl
	jr	nc, DSP_SetCoeff_Return

; Byte copy XIX+ -> XIZ+, 10 iterations.
DSP_SetCoeff_CopyRecordByte:
	ld	a, (xix+)
	ld	(xiz+), a
	inc	1, bc
	cp	bc, hl
	jr	c, DSP_SetCoeff_CopyRecordByte

DSP_SetCoeff_Return:
	pop	xiz
	ret
"""

# (file, old, new): each `old` must occur exactly once in the v141 text.
# Spelling rule (cross-version diff minimisation): inside these short edits an instruction
# that v1.41 also has at that spot keeps v1.41's text byte for byte (v141 inherits v142's
# space-after-mnemonic style), so a v141/v140 diff shows only real changes; instructions that
# are new or different use the policy's tab style.  SVC_V140 is the exception: it replaces
# the whole v1.41 function (different registers, no frame) and is written in tab style
# throughout, so a diff of that function shows every line.
# SPAN entries are (file, first_line, last_line, sha1_of_span, new).
EDITS = [
    ("subcpu_data_tables.s",
     b"\t.short 141\t\t; payload version 1.41 (0x008d); see the banner\n",
     b"\t.short 140\t\t; payload version 1.40 (0x008c); see the banner\n"),
    (MAIN_DST, V141_BANNER, V140_BANNER),
    ("SPAN", MAIN_DST, SVC_FIRST, SVC_LAST, SVC_SHA1, SVC_V140),
    # DSP_Cmd2B_SetParam grew by 82 bytes, so DSP_Cmd2B_PostProcess is out of jr range here.
    (MAIN_DST,
     b"\tcall DSP_ReadVoiceParam5D\n\tjr DSP_Cmd2B_PostProcess\n",
     b"\tcall DSP_ReadVoiceParam5D\n\tjrl\tDSP_Cmd2B_PostProcess\n"),
    (MAIN_DST,
     b"; Sub-command 0x24: DSP_SetVoiceCoefficients with the same three arguments.\n"
     b"DSP_Cmd2B_SetParam:\n"
     b"\tld a, (17264:16)\n\tld e, a\n\textz de\n\tld a, (17265:16)\n\tld c, a\n\textz bc\n"
     b"\tld wa, de\n\tld xde, (xsp + 10)\n\tcall DSP_SetVoiceCoefficients\n"
     b"\tjr DSP_Cmd2B_PostProcess\n",
     b"; Sub-command 0x24.  v1.40 resolves the sub-tone reference HERE: part = payload[0]\n"
     b"; (0x4370), i = payload[1] (0x4371); the patch record is ToneDB_Find_ToneRecord of the\n"
     b"; part's tone selector {lo, hi} = bytes Payload_Bss_Start+0x250b/+0x250c + 0x11f*part,\n"
     b"; and the reference is the record's {lo, hi} pair at +0x27+2*i, passed as WA, BC with\n"
     b"; XDE = the reply buffer.  v1.41 passes (part, i) and does this lookup in the callee.\n"
     b"DSP_Cmd2B_SetParam:\n"
     b"\tld a, (17264:16)\n\textz\twa\n\tmuls\twa, 0x11f\n"
     b"\tlda\txbc, (Payload_Bss_Start+0x250b:24)\n\tld\ta, (xbc+wa)\n\tld e, a\n\textz de\n"
     b"\tld a, (17264:16)\n\textz\twa\n\tmuls\twa, 0x11f\n"
     b"\tlda\txbc, (Payload_Bss_Start+0x250c:24)\n\tld\ta, (xbc+wa)\n\tld c, a\n\textz bc\n"
     b"\tld wa, de\n\tcall\tToneDB_Find_ToneRecord\n"
     b"\tld a, (17265:16)\n\textz\twa\n\tadd\twa, wa\n\tadd\twa, 0x27\n"
     b"\tld\ta, (xhl+wa)\n\tld e, a\n\textz de\n"
     b"\tld a, (17265:16)\n\textz\twa\n\tadd\twa, wa\n\tadd\twa, 0x27\n"
     b"\texts\txwa\n\tadd\txwa, xhl\n\tld\ta, (xwa+1)\n\tld c, a\n\textz bc\n"
     b"\tld wa, de\n\tld xde, (xsp + 10)\n\tcall DSP_SetVoiceCoefficients\n"
     b"\tjr DSP_Cmd2B_PostProcess\n"),
    (MAIN_DST,
     b"DSP_Cmd2B_VoiceParamWrite:\n"
     b"\tldto_berp A, 0xFB\n\textz wa\n\tld iz, wa\n\tand iz, 0xF\n"
     b"\tlda xwa, (17256:16)\n\tcalr Extract_14Bit_VoiceParam\n\tldfr_werp HL, 0xFA\n"
     b"\tlda xwa, (17256:16)\n\tcalr Extract_14Bit_PayloadSize\n"
     b"\tlda xwa, (17264:16)\n\tpush xwa\n\tld wa, iz\n\tldto_werp BC, 0xFA\n",
     b"; v1.40 keeps the channel in QIZ (bank word 0xfa) and the parameter index in IZ; v1.41\n"
     b"; swaps the two.  Same arguments either way.\n"
     b"DSP_Cmd2B_VoiceParamWrite:\n"
     b"\tldto_berp A, 0xFB\n\textz wa\n\tldfr_werp\twa, 0xfa\n\tand_erpw\t0xfa, 0x0f, 0x00\n"
     b"\tlda xwa, (17256:16)\n\tcalr Extract_14Bit_VoiceParam\n\tld\tiz, hl\n"
     b"\tlda xwa, (17256:16)\n\tcalr Extract_14Bit_PayloadSize\n"
     b"\tlda xwa, (17264:16)\n\tpush xwa\n\tldto_werp\twa, 0xfa\n\tld\tbc, iz\n"),
    # Same-length change: the type word DSP_Process_ReadNext left in IZ, read back as IZL.
    (MAIN_DST,
     b"\tcalr DSP_Cmd_DequeueHeader\n\tld wa, (xsp + 12)\n",
     b"\tcalr DSP_Cmd_DequeueHeader\n\tldto_berp\ta, 0xf8\t; A = IZL, the type word (v1.41: (XSP+12))\n"),
    (MAIN_DST,
     b"DSP_Process_ReadNext:\n\tld xwa, (xsp + 4)\n\tcalr DSP_RingBuf_Read\n"
     b"\tld (xsp + 12), hl\n\tld wa, (xsp + 12)\n",
     b"; v1.40 holds the type word in IZ; v1.41 spills it to the frame slot (XSP+12).\n"
     b"DSP_Process_ReadNext:\n\tld xwa, (xsp + 4)\n\tcalr DSP_RingBuf_Read\n"
     b"\tld\tiz, hl\n\tld\twa, iz\n"),
]


def apply_edit(texts, e):
    if e[0] == "SPAN":
        _, f, first, last, sha1, new = e
        f = resolve(texts, f, first)
        t = texts[f]
        if t.count(first) != 1 or t.count(last) != 1:
            sys.exit("SPAN for %s: first/last line match %d/%d times (want 1/1)"
                     % (f, t.count(first), t.count(last)))
        i = t.index(first)
        j = t.index(last, i) + len(last)
        got = hashlib.sha1(t[i:j]).hexdigest()
        if got != sha1:
            sys.exit("SPAN for %s starting %r changed upstream (sha1 %s, pinned %s): review the\n"
                     "v1.41 text, port the change into the v1.40 replacement if it applies, and\n"
                     "update the pin." % (f, first[:60], got, sha1))
        texts[f] = t[:i] + new + t[j:]
        return
    f, old, new = e
    f = resolve(texts, f, old)
    n = texts[f].count(old)
    if n != 1:
        sys.exit("EDIT for %s matches %d times (want 1): %r" % (f, n, old[:80]))
    texts[f] = texts[f].replace(old, new)


def generate(dst):
    os.makedirs(os.path.join(dst, "shared"), exist_ok=True)
    os.makedirs(os.path.join(dst, CORE), exist_ok=True)
    texts = {}
    for f in COPY + core_files(SRC):
        texts[f] = open(os.path.join(SRC, f), "rb").read()
    texts[MAIN_DST] = open(os.path.join(SRC, MAIN_SRC), "rb").read()
    for e in EDITS:
        apply_edit(texts, e)
    for f, data in texts.items():
        open(os.path.join(dst, f), "wb").write(data)


def main():
    if sys.argv[1:] == ["--check"]:
        scratch = os.environ.get("TMPDIR") or os.path.expanduser("~/compartilhado/tmp")
        d = tempfile.mkdtemp(prefix="v140gen_", dir=scratch)
        try:
            generate(d)
            drift = 0
            if core_files(DST) != core_files(d):
                drift += 1
                print("DRIFT core/: %r vs generated %r" % (core_files(DST), core_files(d)))
            for f in COPY + [MAIN_DST] + core_files(d):
                p = os.path.join(DST, f)
                a = open(p, "rb").read() if os.path.exists(p) else b""
                b = open(os.path.join(d, f), "rb").read()
                if a != b:
                    drift += 1
                    print("DRIFT %s" % f)
                    for ln in list(difflib.unified_diff(a.decode("latin-1").split("\n"),
                                                        b.decode("latin-1").split("\n"),
                                                        "v140/subcpu/" + f, "generated/" + f,
                                                        lineterm="", n=1))[:40]:
                        print(ln)
            print("v140 tree %s" % ("IN SYNC with v141 + EDITS" if not drift else "DRIFTED (%d files)" % drift))
            sys.exit(1 if drift else 0)
        finally:
            assert os.path.basename(d).startswith("v140gen_") and os.path.dirname(d) == scratch
            shutil.rmtree(d)
    elif sys.argv[1:]:
        sys.exit(__doc__)
    generate(DST)
    print("wrote %s" % os.path.relpath(DST, ROOT))


if __name__ == "__main__":
    main()
