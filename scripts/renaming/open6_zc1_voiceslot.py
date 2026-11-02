#!/usr/bin/env python3
"""Write the kn5000-zc1 rename sed scripts: the VoiceSlot_* labels of display/scoop_display.s, per tree.

QUESTION IT ANSWERS / WHAT IT DOES
  The VoiceSlot_* labels defined in display/scoop_display.s are the step sequencer's song-memory code: the
  per-track cursor (block number at 0x0C9E + 2 * (track - 1), offset at 0x0CBE + track - 1) into the chain of
  256-byte song blocks (5-byte header: flags, previous link +1, next link +3), its events, and the step-edit
  screens built on them.  None of them is a voice slot.  The routines (labels reached by call / calr / a
  pointer / another file) are named by hand below, each from its body (notes/open6-kn5000-d/naming/README.md,
  section kn5000-zc1, gives the evidence).  Every other VoiceSlot_* label is a branch target inside a routine:
  it is renamed after the routine it sits in (the nearest routine label above it), keeping its old suffix
  (Skip3, Loop, Join2, ...; a leading "Code_" is dropped unless that collides) unless LOCALS names it.  The trees differ (v6 / v5 lack some labels, v7 has
  three more), so one sed script is written per tree; the routine names are the same in every tree.

RUN (repository root):
  python3 scripts/renaming/open6_zc1_voiceslot.py            # writes scripts/renaming/rename_open6_zc1_<tree>.sed
  python3 scripts/renaming/open6_zc1_voiceslot.py --check    # only report (unmapped routines, collisions)
then, per tree:
  sed -i -f scripts/renaming/rename_open6_zc1_<tree>.sed <every .s/.c/.h/.ld of <tree>/maincpu naming VoiceSlot_>
The scripts are generated from the label set before the rename; run this before the sed, not after.
"""
import collections
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ["v10", "v9", "v7", "v6", "v5"]
FILE = "display/scoop_display.s"

# Routines, named from their bodies (v10; the same labels sit on the same code in the other trees,
# scripts/analysis/check_ported_labels.py).
ROUTINES = {
    # the cursor primitives
    "VoiceSlot_UpdateCurrentPointer": "SeqBlock_Select",                 # SEQ_BLOCK_PTR = pool + (IY - 1) * 256
    "VoiceSlot_ComputeWordIndex": "SeqTrack_WordIndex",                  # IZ = 2 * (SEQ_CURSOR_TRACK - 1)
    "VoiceSlot_ComputeIndex": "SeqTrack_TripleIndex",                    # IZ = 3 * (SEQ_CURSOR_TRACK - 1)
    "VoiceSlot_ReadCurrentParams": "SeqTrack_ReadCursorByte",            # A = byte at the cursor
    "VoiceSlot_WriteCurrentParam": "SeqTrack_WriteCursorByte",           # byte at the cursor = W
    "VoiceSlot_FlagCheck": "SeqTrack_PeekNextByte",                      # SeqTrack_PeekAhead with 0x0DF5 = 1
    "VoiceSlot_FlagCheckBody": "SeqTrack_PeekSecondByte",                # ... with 0x0DF5 = 2
    "VoiceSlot_FlagCheckDone": "SeqTrack_PeekAhead",                     # byte (0x0DF5) past the cursor, next block
    "VoiceSlot_FinalRetZ_0x11": "SeqTrack_PeekNextByte_SaveRegs",        # A = E; PeekNextByte, XIY XIZ XHL kept
    "VoiceSlot_FinalRetZ_0x1E": "SeqTrack_ReadCursorByteOfTrack",        # cursor byte of track E (1-based)
    "VoiceSlot_StatusCheck": "SeqEvent_CheckStatusByte",                 # W = 0 when A starts an event
    "VoiceSlot_CompareRet": "SeqTrack_StepEvent",                        # W = 0 one event on, W = 1 one event back
    "VoiceSlot_LoadAndDispatch": "SeqTrack_NextEvent",
    "VoiceSlot_DispatchRet": "SeqTrack_NextEventKeepWrapCount",
    "VoiceSlot_CompareAndBranch": "SeqTrack_PrevEvent",
    "VoiceSlot_StepCursorBack": "SeqTrack_PrevEventKeepWrapCount",
    "VoiceSlot_SubrRetZ": "SeqTrack_DecWrapCount",                       # SQSTEP_WRAP_COUNT - 1, not below 0
    "VoiceSlot_SkipByteAndRead": "SeqTrack_SkipByteAndRead",
    "VoiceSlot_SkipWrapMarkers": "SeqTrack_SkipWrapMarkers",
    "VoiceSlot_TableSetup_Helper": "SeqTrack_SkipWrapMarkers",           # v6 / v5 spelling of the same routine
    "VoiceSlot_CheckCursorAtTrackStart": "SeqTrack_CheckCursorAtStart",
    "VoiceSlot_ReadParamsWithSaveRestore_Helper3": "SeqTrack_CheckEventFollows",
    "VoiceSlot_InitAndProcess": "SeqTrack_WriteBytesAtCursor",           # BC bytes from (0x1101), cursor advanced
    "VoiceSlot_RetZ": "SeqTrack_DeleteBytesAtCursor",                    # W bytes (SqStep_DeleteEventAtCursor)
    # the cursor snapshots (8 slots of 8 bytes at 0x0DFF)
    "VoiceSlot_SaveState": "SeqCursor_Save",
    "VoiceSlot_RestoreState": "SeqCursor_Restore",
    "VoiceSlot_CompareSavedMarkerCount": "SeqCursor_CompareSavedWrapCount",
    # step-edit screens built on them
    "VoiceSlot_TableSetup": "SqStep_RebuildGridRows",                    # bit 0 of 0x0DD3: rows around the cursor
    "VoiceSlot_StatusRet": "SqStep_ShowCursorEventPopup",                # the pop-up for the event at the cursor
    "VoiceSlot_IndexDone": "SqStep_ShowCursorMarkerPopup",               # 0x81 / 0x82 / 0x84 at the cursor
    "VoiceSlot_ReadParamsWithSaveRestore": "SqStep_WritePopupValueToEvent",
    "VoiceSlot_StatusRet_Helper": "SqStep_AuditionCursorNotes",          # 0x90 at the cursor: notes to SeqBuf
    "VoiceSlot_StatusRet_Helper4": "ParamPopup_EmptyStub4",              # lone `ret`s among the ParamPopup_*
    "VoiceSlot_StatusRet_Helper5": "ParamPopup_EmptyStub5",
    "VoiceSlot_StatusRet_Helper6": "ParamPopup_EmptyStub6",
    "VoiceSlot_StatusRet_Helper7": "ParamPopup_EmptyStub7",
    "VoiceSlot_StatusRet_Helper8": "ParamPopup_EmptyStub8",
    "VoiceSlot_StatusRet_Helper10": "ParamPopup_EmptyStub10",            # v6 / v5
    "VoiceSlot_StatusRet_Helper11": "SqStep_ShowTempoPopup",             # v6 / v5: "TEMPO=" line, Str_TempoEq
    "VoiceSlot_StatusRet_Tbl2": "SqStep_ShowCursorEventPopup_NoteCodeMap",  # 12 x u8 -> 0x0D61, note-event case
}

# Labels with no reference at all (v7 / v6 / v5 branch to `.Lc_<addr>` aliases beside them) are branch
# targets too.  Labels the reference rule would call routines but that are branch targets inside one (a `call` from dead code
# after a `jp`, or a cross-label `jp`).
NOT_ROUTINES = {"VoiceSlot_StatusRet_Code_Skip24", "VoiceSlot_ProcessedWordRet"}

# Branch targets named by hand (the cursor primitives' arms).
LOCALS = {
    "VoiceSlot_InitLoop": "SeqTrack_WriteBytesAtCursor_FitsBlock",
    "VoiceSlot_ProcessEntry": "SeqTrack_WriteBytesAtCursor_SpillsOver",
    "VoiceSlot_CheckDone": "SeqTrack_WriteBytesAtCursor_Done",
    "VoiceSlot_RetNZ": "SeqTrack_WriteBytesAtCursor_Return",
    "VoiceSlot_ReadParamsErrExit": "SeqTrack_NextEvent_AtEnd",
    "VoiceSlot_DispatchDone": "SeqTrack_NextEvent_Return",
    "VoiceSlot_StoreAndAdvance": "SeqTrack_StepEvent_FwdLoop",
    "VoiceSlot_CopyBlock": "SeqTrack_StepEvent_FwdStore",
    "VoiceSlot_CopyBlockDone": "SeqTrack_StepEvent_FwdWrapMarker",
    "VoiceSlot_LoadFromTable": "SeqTrack_StepEvent_FwdWrapJoin",
    "VoiceSlot_LoadFromTableBody": "SeqTrack_StepEvent_FwdNextBlock",
    "VoiceSlot_DecCountLoop": "SeqTrack_StepEvent_BackLoop",
    "VoiceSlot_CallSubroutine": "SeqTrack_StepEvent_BackStore",
    "VoiceSlot_SubroutineTable": "SeqTrack_StepEvent_BackWrapMarker",
    "VoiceSlot_SubroutineBody": "SeqTrack_StepEvent_BackPrevBlock",
    "VoiceSlot_SubrDone": "SeqTrack_StepEvent_AtEnd",
    "VoiceSlot_SubrRetNZ": "SeqTrack_StepEvent_Return",
    "VoiceSlot_AdvancePointer": "SeqTrack_DecWrapCount_Done",
    "VoiceSlot_FinalCheck": "SeqTrack_PeekAhead_NextBlock",
    "VoiceSlot_FinalDone": "SeqTrack_PeekAhead_AtEnd",
    "VoiceSlot_FinalRetNZ": "SeqTrack_PeekAhead_Return",
    "VoiceSlot_StatusActive": "SeqEvent_CheckStatusByte_InRange",
    "VoiceSlot_SetFFAndContinue": "SeqEvent_CheckStatusByte_No",
    "VoiceSlot_StatusDone": "SeqEvent_CheckStatusByte_Return",
}

RX_DEF = re.compile(r"^([A-Za-z_]\w*):")
RX_TOK = re.compile(r"\b[A-Za-z_]\w*\b")
LOCAL_MN = {"jr", "jrl", "jp", "djnz", "djnz16"}


def read(p):
    return open(p, "rb").read().decode("latin-1")


def tree_files(tree):
    root = os.path.join(REPO, tree, "maincpu")
    for dp, _, fs in os.walk(root):
        for f in fs:
            if f.endswith((".s", ".c", ".h", ".ld")):
                yield os.path.relpath(os.path.join(dp, f), root), os.path.join(dp, f)


def analyse(tree):
    labels_in_file, all_labels = [], set()
    refs = collections.defaultdict(set)          # label -> {(file, mnemonic)}
    for rel, p in tree_files(tree):
        is_s = rel.endswith(".s")
        for line in read(p).splitlines():
            m = RX_DEF.match(line)
            body = line
            if m:
                all_labels.add(m.group(1))
                if rel == FILE:
                    labels_in_file.append(m.group(1))
                body = line[m.end():]
            code = body.split(";", 1)[0] if is_s else body
            toks = code.split()
            mn = toks[0].lower() if toks else ""
            for t in RX_TOK.findall(code):
                refs[t].add((rel, mn if is_s else "c"))
    routine = set()
    for lab in labels_in_file:
        r = refs.get(lab, set())
        if lab in NOT_ROUTINES:
            continue
        if any(f != FILE or mn not in LOCAL_MN for f, mn in r):
            routine.add(lab)
    return labels_in_file, all_labels, routine, {k for k, v in refs.items() if v}


def suffix_of(old):
    s = old[len("VoiceSlot_"):]
    bases = sorted((k[len("VoiceSlot_"):] for k in ROUTINES), key=len, reverse=True)
    for b in bases:
        if s.startswith(b + "_"):
            s = s[len(b) + 1:]
            break
    return s


def plan(tree):
    labels, all_labels, routine, refs_seen = analyse(tree)
    problems, mapping, wanted = [], {}, []
    taken = set(all_labels)
    owner = None
    for lab in labels:
        if lab in routine:
            owner = lab
        if not lab.startswith("VoiceSlot_"):
            continue
        if lab in ROUTINES:
            if lab not in routine and lab in refs_seen:
                problems.append("%s: %s is mapped as a routine but is reached only by branches" % (tree, lab))
            wanted.append((0, lab, [ROUTINES[lab]]))
        elif lab in routine:
            problems.append("%s: routine %s has no hand name; left alone" % (tree, lab))
        elif lab in LOCALS:
            wanted.append((0, lab, [LOCALS[lab]]))
        else:
            base = ROUTINES.get(owner, owner)
            if base is None or base.startswith("VoiceSlot_"):
                problems.append("%s: local %s has no named owner (%s); left alone" % (tree, lab, owner))
                continue
            suf = suffix_of(lab)
            # Labels spelled after their own routine choose first, then the others, then the "Code_" ones
            # (which drop "Code_" unless that collides).
            rank = 1 if lab.startswith(owner + "_") else 2
            if suf.startswith("Code_"):
                wanted.append((3, lab, ["%s_%s" % (base, suf[len("Code_"):]), "%s_%s" % (base, suf)]))
            else:
                wanted.append((rank, lab, ["%s_%s" % (base, suf)]))
    for _, lab, cands in sorted(wanted, key=lambda w: w[0]):
        pick = next((c for c in cands if c not in taken or c == lab), None)
        if pick is None:
            n = 2
            while "%s_%d" % (cands[-1], n) in taken:
                n += 1
            pick = "%s_%d" % (cands[-1], n)
        taken.add(pick)
        mapping[lab] = pick
    return mapping, problems


def main():
    check = "--check" in sys.argv
    for tree in TREES:
        mapping, problems = plan(tree)
        for p in problems:
            print(p)
        print("%s: %d renames" % (tree, len(mapping)))
        if check:
            continue
        out = os.path.join(REPO, "scripts", "renaming", "rename_open6_zc1_%s.sed" % tree)
        with open(out, "w") as f:
            f.write("# kn5000-zc1 (lane open6/kn5000-d naming, 2026-11-02): the VoiceSlot_* song-memory labels of\n"
                    "# %s/maincpu/%s.  Written by scripts/renaming/open6_zc1_voiceslot.py (routines by hand,\n"
                    "# branch targets after their routine); evidence: notes/open6-kn5000-d/naming/README.md.\n"
                    % (tree, FILE))
            for old in sorted(mapping, key=len, reverse=True):
                f.write("s/\\b%s\\b/%s/g\n" % (old, mapping[old]))
        print("  wrote", os.path.relpath(out, REPO))


if __name__ == "__main__":
    main()
