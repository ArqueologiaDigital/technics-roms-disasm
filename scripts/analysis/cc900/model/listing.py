"""cc900 reference model: reading and comparing Toshiba-syntax assembly listings (thc2's `.asm`).

split(text) -> {function name: [normalised lines]}: comments, `public`/`extern`/`module`/`$MAXIMUM`/`end` and blank
lines dropped, whitespace collapsed to one tab between mnemonic and operands.  A function starts at a column-0 label
named `_x` or `.x` and runs to the next such label; section switches and data inside it (string literals, switch
tables) stay in its lines.  `normalise_labels` renames local labels (`L<n>`, `S<n>`) in order of appearance, for
comparisons that ignore label numbering.  `attributes(text)` reads the width class of each symbol (`extern
small|medium|large`, and the section of a symbol the file defines), which split() drops.
"""
import re

SKIP = re.compile(r'^\s*(public|extern|module|end\b|\$MAXIMUM|\$MINIMUM)', re.I)
FUNC = re.compile(r'^([._][A-Za-z0-9_]+):')

def clean(line):
    line = line.rstrip('\r\n')
    if line.lstrip().startswith(';'): return ''
    line = re.sub(r'\s;.*$', '', line)                 # trailing comments ("; 10", label counts)
    line = line.rstrip()
    if not line.strip() or SKIP.match(line): return ''
    if not line[0].isspace(): return line.split()[0] if line.split()[0].endswith(':') else line.strip()
    parts = line.strip().split(None, 1)
    return '\t' + parts[0] + ('\t' + re.sub(r'\s+', ' ', parts[1]) if len(parts) > 1 else '')

def split(text):
    out = {}; cur = None; pending = []
    for raw in text.splitlines():
        l = clean(raw)
        if not l: continue
        m = FUNC.match(l)
        if m:
            cur = m.group(1); out[cur] = pending + [l]; pending = []
            continue
        if cur is None: pending.append(l)                # section line before the first function
        else: out[cur].append(l)
    return out

ATTR_WIDTH = {'small': 8, 'medium': 16, 'large': 24}
EXTERN = re.compile(r'^\s*extern\s+(small|medium|large)\s+(.*?)\s*(;.*)?$', re.I)
SECTION = re.compile(r'^(\w+)\s+section\s+\w+\s+(small|medium|large)\b', re.I)

def attributes(text):
    """{symbol without `_` / `.`: 8, 16 or 24} from a cc900 listing: the attribute of each `extern small|medium|large`
    declaration (__tiny, __near, plain; probe m16) and, for a symbol the file defines, its section's attribute
    (t_area small, n_area medium, f_area large, f_code large)"""
    out = {}; cur = None
    for raw in text.splitlines():
        m = EXTERN.match(raw)
        if m:
            for s in m.group(2).split(','):
                if s.strip(): out[s.strip().lstrip('_.')] = ATTR_WIDTH[m.group(1).lower()]
            continue
        m = SECTION.match(raw)
        if m: cur = ATTR_WIDTH[m.group(2).lower()]; continue
        m = FUNC.match(raw)
        if m and cur is not None: out.setdefault(m.group(1).lstrip('_.'), cur)
    return out

def normalise_labels(lines):
    names = {}
    def sub(m):
        n = m.group(0)
        if n not in names: names[n] = '%s%d' % (n[0], len([k for k in names if k[0] == n[0]]) + 1)
        return names[n]
    return [re.sub(r'\b[LS]\d+\b', sub, l) for l in lines]

def diff_first(a, b):
    """index of the first differing line, or None"""
    for i, (x, y) in enumerate(zip(a, b)):
        if x != y: return i
    return None if len(a) == len(b) else min(len(a), len(b))
