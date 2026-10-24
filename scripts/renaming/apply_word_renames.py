#!/usr/bin/env python3
"""apply_word_renames.py -- run the whole-word `s/\\<OLD\\>/NEW/g` rules of a rename .sed script over .s files.

JOB IT DOES
  The renaming policy is "write a sed script, then run it".  This runs such a script's whole-word rules
  (`s/\\<OLD\\>/NEW/g`, `s/\\bOLD\\b/NEW/g`; comment lines skipped, any other rule refused) over the files
  given, reading and writing them as bytes (latin-1), because the .s files hold raw non-UTF-8 bytes in
  their .ascii lines.  It prints how many replacements each file took.  Same effect as
  `LC_ALL=C sed -i -f SCRIPT FILE...` for these rules.

USAGE
  python3 scripts/renaming/apply_word_renames.py scripts/renaming/rename_wp17_ram.sed FILE...
"""
import re
import sys

RULE = re.compile(r'^s/(?:\\<|\\b)(\w+)(?:\\>|\\b)/(\w+)/g$')


def main():
    rules = []
    for l in open(sys.argv[1]):
        l = l.strip()
        if not l or l.startswith("#"):
            continue
        m = RULE.match(l)
        if not m:
            sys.exit("not a whole-word rule: " + l)
        rules.append((re.compile(r'\b%s\b' % re.escape(m.group(1))), m.group(2)))
    for f in sys.argv[2:]:
        s = open(f, "rb").read().decode("latin-1")
        n = 0
        for pat, new in rules:
            s, k = pat.subn(new, s)
            n += k
        if n:
            open(f, "wb").write(s.encode("latin-1"))
            print("%5d  %s" % (n, f))
    return 0


if __name__ == "__main__":
    sys.exit(main())
