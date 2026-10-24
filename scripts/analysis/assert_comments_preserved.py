#!/usr/bin/env python3
"""Assert that an edit did not lose or reword a single comment.

QUESTION THIS ANSWERS
    A semantic-labelling pass renames labels and rewrites mnemonics.  Those are
    CODE changes, and the byte gate certifies them: if a byte moves it goes red.

    But comments assemble to nothing, so **the byte gate cannot see a comment
    that was dropped, reflowed or reworded**.  This tree's prose is the product
    of months of work and is the actual deliverable of a documentation pass.
    This script is the other half of the gate: it compares the COMMENTS between
    a git revision and the working tree and requires INSERTIONS ONLY.

WHY IT EXISTS
    `wsa1/notes/prom_c_split.py --verify` did this job for the prom_c split, by
    requiring the whole listing to align insertions-only against the pre-split
    commit.  Its own header says that once later rounds edit an extracted file
    it "will report those edits as insertions/deletions, which is correct and is
    the signal to retire it".  On 2026-09-03 four convergence lanes rewrote
    ~3,147 mnemonic spellings in those files and that is exactly what happened.
    It PASSED at a6507fdd, the commit before those merges -- so the split proof
    stands, and this takes over the forward-looking half of its job.

    ⚠ The difference matters: that check pinned one historical commit and proved
    a past event.  This one takes any base and guards the NEXT edit.

HOW IT DECIDES
    For each file it extracts every comment -- whole-line and trailing -- as
    text, in order, and asks whether the base's comment sequence is a
    SUBSEQUENCE of the new one.  Adding comments passes.  Deleting, reordering
    or altering one by a character fails, and the offending comment is printed.

    The test is a greedy subsequence walk (the one `scripts/tools/
    propagate_v10_headers.py --verify` uses): each base comment is matched to
    the EARLIEST equal new comment after the previous match.  Earliest-match
    greed is exact for "is A a subsequence of B", so the verdict has no false
    alarms and no misses.  Until 2026-10-24 this script aligned the two lists
    with difflib.SequenceMatcher instead, which is a heuristic: it reported a
    comment as lost when a new comment equal to a later one landed between two
    repeated comments (base `a a b`, new `a b a b`), although nothing was lost.
    The selftest keeps that case.  A base comment the walk cannot place is
    reported as lost and the walk goes on from the same point, so the list of
    lost comments is a readable diagnosis; only the pass/fail verdict is the
    exact claim.

    Trailing comments survive a mnemonic conversion untouched (the converter
    rewrites the instruction, not the text after `;`), which is why comparing
    comment text alone is the right instrument for a labelling pass.

RUN
    python3 scripts/analysis/assert_comments_preserved.py --base HEAD <paths...>
    python3 scripts/analysis/assert_comments_preserved.py --selftest

    --selftest builds a synthetic file and requires this check to FAIL on a
    deleted comment, FAIL on a reworded one, and PASS on an added one.  A check
    that cannot go red is not evidence.
"""
import argparse
import bisect
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]


def comments_of(text):
    """Every comment in the file, in order, as (line_no, comment_text).

    A `;` inside a string literal is not a comment.  The TLCS-900 sources use
    `"` for .ascii/.asciz operands, so track that one quote form.
    """
    out = []
    for n, line in enumerate(text.split("\n"), 1):
        in_str = False
        for i, ch in enumerate(line):
            if ch == '"':
                in_str = not in_str
            elif ch == ";" and not in_str:
                out.append((n, line[i:].rstrip()))
                break
    return out


def git_show(rev, path):
    rel = pathlib.Path(path).resolve().relative_to(ROOT)
    p = subprocess.run(["git", "show", f"{rev}:{rel}"], cwd=ROOT,
                       capture_output=True)
    if p.returncode:
        return None
    return p.stdout.decode("latin-1")


def apply_renames(text, renames):
    """Substitute old label names for new ones, longest name first.

    Longest-first matters: `sub_F9ADB5` is a prefix of `sub_F9ADB5__F9AE48`,
    and substituting the short one first would leave `P7Block_Run__F9AE48`
    spelled as `P7Block_Run__F9AE48` only by luck and mangle other pairs.
    """
    if not renames:
        return text
    pat = re.compile(r"\b(" + "|".join(
        re.escape(k) for k in sorted(renames, key=len, reverse=True)) + r")\b")
    return pat.sub(lambda m: renames[m.group(1)], text)


def check(base_text, new_text, renames=None):
    """Return the list of comments present in base and missing/altered in new.

    With `renames`, a base comment also matches if it becomes the new comment
    once renamed labels are substituted. ⚠ THIS IS A NARROW EXEMPTION AND IT
    MUST STAY NARROW: it permits exactly the substitution of a label this pass
    renamed, and nothing else. A reworded sentence still fails, because the
    renamed base still will not equal it.

    It exists because a labelling pass rewrites GENERATED cross-reference
    comments (`Calls:`, `Called from:`, `Arms:`) as a matter of course, and
    forbidding that leaves the tree with comments that contradict the code --
    which is a worse documentation outcome than the one this check defends
    against. Two lanes hit exactly that on 2026-09-03 and correctly stopped
    rather than reword.
    """
    base = [c for _, c in comments_of(base_text)]
    if renames:
        base = [apply_renames(c, renames) for c in base]
    new = [c for _, c in comments_of(new_text)]
    return unmatched(base, new), len(base), len(new)


def unmatched(base, new):
    """The base items a greedy subsequence walk cannot place in `new`, in order.

    Each base item takes the earliest equal item of `new` after the previous match.  The
    result is empty exactly when `base` is a subsequence of `new` (earliest-match greed is
    optimal for that question).  An item that finds no match is reported and consumes
    nothing, so the walk resumes from the same position for the next base item.
    """
    pos = {}
    for j, c in enumerate(new):
        pos.setdefault(c, []).append(j)
    lost, j = [], 0
    for c in base:
        js = pos.get(c, ())
        k = bisect.bisect_left(js, j)
        if k == len(js):
            lost.append(c)
        else:
            j = js[k] + 1
    return lost


def selftest():
    body = ('; header comment\n'
            'Label_A:\n'
            '\tld\ta, 1\t; trailing one\n'
            '\tld\tb, 2\t; trailing two\n'
            '; a whole-line note\n'
            '\tret\n')
    cases = [
        ("a faithful rename",
         body.replace("Label_A:", "Voice_Allocate:"), True),
        ("a rename plus new documentation",
         "; NEW: what this routine does\n" + body.replace("Label_A:", "Voice_Allocate:"), True),
        ("a mnemonic conversion under an untouched comment",
         body.replace("\tld\ta, 1\t", "\tld\ta, (0x10:16)\t"), True),
        ("A DELETED COMMENT", body.replace("; a whole-line note\n", ""), False),
        ("A REWORDED COMMENT", body.replace("; trailing two", "; trailing 2"), False),
        ("A COMMENT MOVED OUT OF ORDER",
         body.replace("\tld\ta, 1\t; trailing one\n", "")
             .replace("\tret\n", "\tld\ta, 1\t; trailing one\n\tret\n"), False),
    ]
    ok = True
    print("  --selftest")
    for name, new, want_pass in cases:
        lost, _, _ = check(body, new)
        got_pass = not lost
        verdict = "ok" if got_pass == want_pass else "WRONG"
        if got_pass != want_pass:
            ok = False
        print(f"    {name:<48} {'passes' if got_pass else 'FAILS ':<7} "
              f"(want {'pass' if want_pass else 'fail'})   {verdict}")

    # --- the case difflib got wrong: base comments `a a b`, new `a b a b` (a copy of the
    #     `; Returns` line lands between two repeated rule lines).  Nothing is lost, yet a
    #     difflib alignment reported one rule line as lost; the subsequence walk must pass it,
    #     and must still fail when a rule line really goes.
    rep = '; ----\n; ----\n; Returns: A\n\tret\n'
    dcases = [
        ("a comment inserted between repeated comments",
         '; ----\n; Returns: A\n; ----\n; Returns: A\n\tret\n', True),
        ("ONE OF TWO REPEATED COMMENTS DELETED",
         '; ----\n; Returns: A\n\tret\n', False),
    ]
    for name, new, want_pass in dcases:
        lost, _, _ = check(rep, new)
        got_pass = not lost
        if got_pass != want_pass:
            ok = False
        print(f"    {name:<48} {'passes' if got_pass else 'FAILS ':<7} "
              f"(want {'pass' if want_pass else 'fail'})   "
              f"{'ok' if got_pass == want_pass else 'WRONG'}")

    # --- controls for --rename-map, which is an EXEMPTION and so needs its own
    #     proof that it did not become a licence to reword anything.
    ren = {"sub_F9ADB5": "P7Block_Run"}
    xref = ('; Calls: sub_F9ADB5\n'
            'sub_F9ADB5:\n'
            '\tret\t; the only exit\n')
    rcases = [
        ("rename mode: the cross-reference follows the label",
         xref.replace("sub_F9ADB5", "P7Block_Run"), ren, True),
        ("rename mode: an UNRELATED reword still FAILS",
         xref.replace("sub_F9ADB5", "P7Block_Run")
             .replace("the only exit", "the sole exit"), ren, False),
        ("rename mode: a DELETION still FAILS",
         xref.replace("; Calls: sub_F9ADB5\n", ""), ren, False),
        ("WITHOUT the map, the same rename FAILS",
         xref.replace("sub_F9ADB5", "P7Block_Run"), None, False),
    ]
    for name, new, rmap, want_pass in rcases:
        lost, _, _ = check(xref, new, rmap)
        got_pass = not lost
        if got_pass != want_pass:
            ok = False
        print(f"    {name:<48} {'passes' if got_pass else 'FAILS ':<7} "
              f"(want {'pass' if want_pass else 'fail'})   "
              f"{'ok' if got_pass == want_pass else 'WRONG'}")
    return ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="*")
    ap.add_argument("--base", default="HEAD",
                    help="git revision to compare against (default HEAD)")
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--rename-map", default=None, metavar="FILE",
                    help="file of old=new label renames; a base comment may "
                         "differ from the new one ONLY by these substitutions")
    a = ap.parse_args()

    if a.selftest:
        return 0 if selftest() else 1
    if not a.paths:
        ap.error("give at least one path, or --selftest")

    renames = {}
    if a.rename_map:
        for line in pathlib.Path(a.rename_map).read_text().splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                renames[k.strip()] = v.strip()
        print(f"  rename map: {len(renames)} label(s)\n")

    failures = []
    total_base = total_new = 0
    for path in a.paths:
        base_text = git_show(a.base, path)
        if base_text is None:
            print(f"  {path:<52} not in {a.base} -- new file, skipped")
            continue
        new_text = pathlib.Path(path).read_text(encoding="latin-1")
        lost, nb, nn = check(base_text, new_text, renames)
        total_base += nb
        total_new += nn
        status = "ok" if not lost else f"{len(lost)} LOST"
        print(f"  {pathlib.Path(path).name:<44} {nb:>7,} -> {nn:>7,}  {status}")
        for c in lost[:5]:
            print(f"        lost: {c[:100]}")
        if len(lost) > 5:
            print(f"        ... and {len(lost) - 5} more")
        if lost:
            failures.append((path, len(lost)))

    print(f"\n  {total_base:,} comments at {a.base} -> {total_new:,} now "
          f"({total_new - total_base:+,})")
    if failures:
        print("\nFAIL: comments were lost or altered:")
        for path, n in failures:
            print(f"  {path}: {n}")
        return 1
    print("\nPASS: every comment survives, in order, unaltered.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
