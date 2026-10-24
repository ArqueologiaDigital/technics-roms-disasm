#!/usr/bin/env python3
"""comment_check_difflib_probe.py -- did the old difflib comment check give false alarms on a real commit?

QUESTION IT ANSWERS
  "On commit REV, how many comments does assert_comments_preserved.py's current test (a greedy subsequence
   walk) report as lost between REV^ and REV, and how many did the difflib.SequenceMatcher alignment it used
   until 2026-10-24 report?"  The two differ only when difflib misaligns repeated comments: base `a a b`,
  new `a b a b` reads as one `a` lost although base is a subsequence of new.  The greedy count is exact; a
  difflib count above it is false alarms.

  Measured 2026-10-24 on 1b6fe98c7 (v9/v7: v10's routine headers carried over, which
  scripts/tools/propagate_v10_headers.py --verify proved insertions-only): 125 .s files; difflib 3 comments
  'lost' in 1 file, greedy subsequence 0.

RUN (repository root)
  python3 scripts/analysis/comment_check_difflib_probe.py 1b6fe98c7
"""
import difflib
import importlib.util
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    commit = sys.argv[1]
    spec = importlib.util.spec_from_file_location(
        "acp", os.path.join(ROOT, "scripts/analysis/assert_comments_preserved.py"))
    acp = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(acp)
    files = subprocess.run(["git", "diff", "--name-only", commit + "^", commit], cwd=ROOT, capture_output=True,
                           text=True, check=True).stdout.split()
    tot = dl_files = gr_files = dl_lost = gr_lost = 0
    for f in files:
        if not f.endswith(".s"):
            continue
        old = subprocess.run(["git", "show", "%s^:%s" % (commit, f)], cwd=ROOT, capture_output=True)
        new = subprocess.run(["git", "show", "%s:%s" % (commit, f)], cwd=ROOT, capture_output=True)
        if old.returncode or new.returncode:
            continue                        # added or deleted file: nothing to align
        b = [c for _, c in acp.comments_of(old.stdout.decode("latin-1"))]
        n = [c for _, c in acp.comments_of(new.stdout.decode("latin-1"))]
        sm = difflib.SequenceMatcher(None, b, n, autojunk=False)
        dl = sum(i2 - i1 for t, i1, i2, _, _ in sm.get_opcodes() if t in ("delete", "replace"))
        gr = len(acp.unmatched(b, n))
        if dl != gr:
            print("  %-60s difflib %d, greedy %d" % (f, dl, gr))
        tot += 1
        dl_files += bool(dl)
        gr_files += bool(gr)
        dl_lost += dl
        gr_lost += gr
    print("%s: %d .s files; difflib: %d file(s) / %d comment(s) 'lost'; greedy subsequence: %d file(s) / %d lost"
          % (commit, tot, dl_files, dl_lost, gr_files, gr_lost))


if __name__ == "__main__":
    main()
