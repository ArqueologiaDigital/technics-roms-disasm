#!/usr/bin/env python3
"""migrate_lane_readers.py -- point the repository-level lane tools at the prom_a / prom_b IMAGE.

QUESTION IT ANSWERS / JOB IT DOES
  notes/migrate_listing_readers.py migrates the probes under wsa1/ that spell an image as
  `os.path.join(ROOT, "prom_X", "wsa1_prom_X.s")` with ROOT = wsa1/.  The lane tools that live
  OUTSIDE wsa1/ (notes/proma-2026-09-25/, notes/promb-2026-09-25/, notes/lanes/...) spell it with
  the repository root or a WSA1 variable instead:
      SRC = os.path.join(ROOT, "wsa1", "prom_b", "wsa1_prom_b.s")
      SRC = os.path.join(WSA1, "prom_b", "wsa1_prom_b.s")
  and since the CPU 1 module split (scripts/tools/split_cpu1_images.py) that path is the image's
  ROOT FILE, a header plus `.include` lines.  This rewrites each such ASSIGNMENT so the name holds
  the materialised image (asm_source.image_path) -- the read side, one line per site:
      _SRC_PATH = os.path.join(ROOT, "wsa1", "prom_b", "wsa1_prom_b.s")
      SRC = _wsa1_image(_SRC_PATH)
  _wsa1_image() is a three-line helper inserted once per file; it finds wsa1/notes/asm_source.py
  from the path itself (two directories up), so it works whatever ROOT or WSA1 means in the file.

⚠ WRITERS.  If the same name is also WRITTEN in the file (`open(NAME, "w"/"wb")`, os.replace onto
  it, `.write_text`), pointing it at the image would make the write land in the cache file
  notes/.image-*.s and report success -- the silent failure this tree's migration tooling exists
  to prevent.  So in such a file every one of those writes is replaced by a `raise SystemExit`
  that says why; the read is still migrated.  These are one-shot lane writers whose edits are in
  the tree; re-running one means porting its write to asm_source.own_lines()/write_own_lines().

RUN (repository root or anywhere)
    python3 wsa1/scripts/tools/migrate_lane_readers.py            # what would change
    python3 wsa1/scripts/tools/migrate_lane_readers.py --apply
"""
import os
import re
import subprocess
import sys

REPO = subprocess.run(["git", "-C", os.path.dirname(os.path.abspath(__file__)), "rev-parse", "--show-toplevel"],
                      capture_output=True, text=True, check=True).stdout.strip()
DIRS = ("notes/",)            # repository-level lane notes; wsa1/ has its own tool
# ⚠ srcmap.SRC is the WRITE target of ~25 other proma-2026-09-25 generators (`open(srcmap.SRC, "w")`).
#   Migrating its read would hand every one of them the image to write over the root file, so it stays
#   the root file: those generators now find no anchor in it and stop, which is the honest state.
EXCLUDE = {"notes/proma-2026-09-25/srcmap.py"}
_Q = r'["\']'
ASSIGN = re.compile(r'^(?P<ind>[ \t]*)(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?P<expr>os\.path\.join\([^\n]*?'
                    + _Q + r'(?:wsa1/)?prom_[ab]' + _Q + r'?[^\n]*?wsa1_prom_[ab]\.s' + _Q + r'\s*\))\s*$', re.M)
HELPER = '''

def _wsa1_image(path):
    """The IMAGE whose root file is `path` (wsa1/prom_X/wsa1_prom_X.s), materialised by
    wsa1/notes/asm_source.py -- added by wsa1/scripts/tools/migrate_lane_readers.py."""
    wsa1 = os.path.dirname(os.path.dirname(os.path.abspath(path)))
    sys.path.insert(0, os.path.join(wsa1, "notes"))
    from asm_source import image_path
    return image_path(wsa1, os.path.relpath(os.path.abspath(path), wsa1))
'''
REFUSE = ('raise SystemExit("REFUSING to write %s: since the CPU 1 module split it names the IMAGE '
          '(wsa1/scripts/tools/migrate_lane_readers.py).  Port this one-shot write to '
          'asm_source.own_lines()/write_own_lines() before re-running it." % {name!r})')


def write_sites(text, name):
    pats = [r'^(?P<ind>[ \t]*)with open\(\s*%s\s*,\s*["\']w[b]?["\'][^)]*\)\s+as\s+\w+:\n(?P=ind)[ \t]+\w+\.write\([^\n]*\)\n',
            r'^(?P<ind>[ \t]*)open\(\s*%s\s*,\s*["\']w[b]?["\'][^)]*\)\.write\([^\n]*\)\n',
            r'^(?P<ind>[ \t]*)os\.replace\([^\n]*,\s*%s\s*\)\n',
            r'^(?P<ind>[ \t]*)%s\.write_(?:text|bytes)\([^\n]*\)\n']
    return [m for p in pats for m in re.finditer(p % re.escape(name), text, re.M)]


def other_writes(text, name):
    """write shapes this tool cannot rewrite safely -- the file is then left alone"""
    return re.search(r'open\(\s*%s\s*\+|open\(\s*%s\s*,\s*["\'][wa]' % (re.escape(name), re.escape(name)), text)


def migrate(text):
    # re-runnable: an assignment this tool already made (`_NAME_PATH = ...`) is not a site
    sites = [m for m in ASSIGN.finditer(text) if not re.match(r'^_\w+_PATH$', m.group("name"))]
    if not sites:
        return text, []
    notes = []
    for m in reversed(sites):
        name, ind = m.group("name"), m.group("ind")
        new = "%s_%s_PATH = %s\n%s%s = _wsa1_image(_%s_PATH)" % (ind, name, m.group("expr"), ind, name, name)
        text = text[:m.start()] + new + text[m.end():]
        ws = write_sites(text, name)
        for w in sorted(ws, key=lambda w: -w.start()):
            text = text[:w.start()] + w.group("ind") + REFUSE.format(name=name) + "\n" + text[w.end():]
        if other_writes(text, name):
            return None, ["%s: a write to %s this tool cannot rewrite -- left alone" % (name, name)]
        notes.append("%s%s" % (name, " (%d write(s) now refuse)" % len(ws) if ws else ""))
    if "def _wsa1_image(" not in text:
        imp = list(re.finditer(r'^import [^\n]*$', text, re.M))
        at = imp[-1].end()
        text = text[:at] + HELPER + text[at:]
    if not re.search(r'^import\s+[^\n]*\bsys\b', text, re.M):     # column 0: `import sys as _s` in a def does not count
        at = list(re.finditer(r'^import [^\n]*$', text, re.M))[-1].end()
        text = text[:at] + "\nimport sys" + text[at:]
    return text, notes


def main():
    apply = "--apply" in sys.argv
    files = subprocess.run(["git", "-C", REPO, "ls-files"] + list(DIRS), capture_output=True, text=True,
                           check=True).stdout.split()
    n = 0
    for rel in sorted(files):
        if not rel.endswith(".py") or rel in EXCLUDE:
            continue
        p = os.path.join(REPO, rel)
        old = open(p, encoding="utf-8").read()
        new, notes = migrate(old)
        if new is None:
            print("LEFT     %s  %s" % (rel, "; ".join(notes)))
            continue
        if new == old:
            continue
        n += 1
        print("%s %s  %s" % ("REWROTE " if apply else "WOULD   ", rel, ", ".join(notes)))
        if apply:
            open(p, "w", encoding="utf-8").write(new)
    print("%d file(s) %s" % (n, "rewritten" if apply else "would be rewritten"))


if __name__ == "__main__":
    main()
