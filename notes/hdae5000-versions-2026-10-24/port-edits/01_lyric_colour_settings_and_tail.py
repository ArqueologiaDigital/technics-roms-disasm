"""Delete the lyric colour settings' strings, case tables and registry entries
(v2.01i has no LyricForeColorCheck / LyricBackColorCheck), and fill the ROM tail with
`.org 0x300000 - 0x280000` instead of a v2.06i-sized `.zero`.

A record of a one-off hand edit of hdae5000_v2_01i/ (see README.md here); it matches
exact text of the tree as it was then and will not apply again.
"""
import os
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
import re
T = os.path.join(ROOT, 'hdae5000_v2_01i') + '/'


def load(f):
    return open(T + f, 'rb').read().split(b'\n')


def save(f, L):
    open(T + f, 'wb').write(b'\n'.join(L))


# 1. the lyric colour settings' strings and case tables: not in v2.01i
L = load('hdae5000_data_tables.s')
a = next(i for i, l in enumerate(L) if l.startswith(b'HDAE5000_TextPtrs_RED_to_YELLOW:'))
b = max(i for i, l in enumerate(L) if b'HDAE5000_LyricBackColorCheck_Ev01E00047 - HDAE5000_LyricBackColorCheck_Ev01E00047' in l)
assert 60 < b - a < 120, (a, b)
del L[a:b + 1]
save('hdae5000_data_tables.s', L)
print('data_tables: deleted', b + 1 - a, 'lines')

# 2. the two registry entries of those settings
L = load('hdae5000_init_data.s')
n0 = len(L)
L = [l for l in L if not re.match(rb'^\s*\.long HDAE5000_(Str_)?Lyric(Fore|Back)ColorCheck\s*$', l)]
print('init_data: deleted', n0 - len(L), 'lines')
# 3. the tail fill: to the end of the ROM, whatever the length of the image before it
k = next(i for i, l in enumerate(L) if l.startswith(b'HDAE5000_Init_Data_End:'))
assert L[k + 2].strip() == b'.zero 24266', L[k + 2]
L[k + 2] = b'\t.org 0x300000 - 0x280000, 0x00\t; 0x00 fill to the end of the 512 KiB ROM'
save('hdae5000_init_data.s', L)
