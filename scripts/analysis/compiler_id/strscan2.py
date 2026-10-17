import sys, re
# Usage: strscan2.py FILE PATTERN [minlen]  -- only strings that look like words (>=60% letters/digits/space)
path = sys.argv[1]
pat = re.compile(sys.argv[2].encode(), re.I)
minlen = int(sys.argv[3]) if len(sys.argv) > 3 else 6
data = open(path, 'rb').read()
for m in re.finditer(rb'[\x20-\x7e]{%d,}' % minlen, data):
    s = m.group(0)
    good = sum(1 for c in s if chr(c).isalnum() or c == 0x20)
    if good < 0.75*len(s): continue
    if pat.search(s):
        print('%08x  %s' % (m.start(), s[:200].decode('latin-1')))
