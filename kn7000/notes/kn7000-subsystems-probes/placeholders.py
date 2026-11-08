#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "how many routines of each MN10300 tree are still named only func_<ADDR>?"
#
# Counts the distinct `func_<8 hex digits>:` label definitions (routine starts; the
# func_<ADDR>_entry register-save entries are not counted) in each tree's generated program
# source.  The same figure as `../uitron3-function-codes/function_codes.py --placeholders`, without
# the specification that script needs.  With --rev REV it reads the sources of that commit.
#
#     python3 -I kn7000/notes/kn7000-subsystems-probes/placeholders.py [--rev REV]
#
# (run from the repository root).
import argparse
import glob
import re
import subprocess

TREES = [
    ("941",    ["kn7000/src/program.s", "kn7000/src/program/*.s"]),
    ("942",    ["kn7000/src/sp7001/program.s", "kn7000/src/sp7001/program/*.s"]),
    ("935",    ["kn7000/src/b935/program.s", "kn7000/src/b935/program/*.s"]),
    ("893",    ["kn7000/src/b893/program.s", "kn7000/src/b893/program/*.s"]),
    ("kn6000", ["kn6000/src/program.s", "kn6000/src/program/*.s"]),
    ("kn6500", ["kn6500/src/program.s", "kn6500/src/program/*.s"]),
    ("kn2400", ["kn2400/src/program.s", "kn2400/src/program/*.s"]),
    ("hdsx3",  ["hdsx3/src/program.s", "hdsx3/src/program/*.s"]),
]
LAB = re.compile(rb"^(func_[0-9A-F]{8}):", re.M)


def files(globs, rev):
    if rev is None:
        for g in globs:
            for f in sorted(glob.glob(g)):
                yield open(f, "rb").read()
        return
    ls = subprocess.run(["git", "ls-tree", "-r", "--name-only", rev], capture_output=True,
                        check=True).stdout.decode().split("\n")
    rx = [re.compile("^" + re.escape(g).replace(r"\*", "[^/]*") + "$") for g in globs]
    for f in ls:
        if any(r.match(f) for r in rx):
            yield subprocess.run(["git", "show", f"{rev}:{f}"], capture_output=True, check=True).stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rev")
    a = ap.parse_args()
    for k, globs in TREES:
        s = set()
        for b in files(globs, a.rev):
            s.update(LAB.findall(b))
        print(f"{k:7s} {len(s):6d} func_ routines")


if __name__ == "__main__":
    main()
