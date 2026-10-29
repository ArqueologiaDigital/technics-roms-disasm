#!/usr/bin/env python3
"""help_db_text.py -- the five KN5000 HELP databases <-> readable text listings, ROUND TRIP.

QUESTION ANSWERED: can the on-screen HELP texts (press HELP, then any panel button) live in the
repo as text a person can read and edit, and still rebuild table_data byte for byte?

Until 2026-10-29 the committed source of each HelpDB_<Lang> block (table_data/help_databases.s)
was help_db_<lang>.bin, the 0x9000-byte decompressed database: a binary file.  This script makes a
UTF-8 text listing, help_db_<lang>.txt, the source, and the .bin a build product that
compress_slide8k.py then packs exactly as before.

THE DECOMPRESSED DATABASE (0x9000 B, decompressed to RAM 0x69800)
  HelpLang_LoadSlide (v10 0xF477BA) and HelpLang_SetFlashAndLoadSlide (0xF4779A) pick the block from
  HelpDB_LanguageTable and call SLIDE_Parse_Header (0xEF41E3) with destination XBC = 0x69800.
  +0x000  200 x u32 LE: absolute RAM pointers (0x69800-based) to NUL-terminated strings
  +0x320  the string pool; then 0x00 up to 0x9000
  Slot = 50 * (page - 1) + topic.  HelpStsCheck (0xF2E669), HelpStsP2Check (0xF2E691),
  HelpStsP3Check (0xF2E6BE) and HelpStsP4Check (0xF2E6EB) answer EVT_GET_LANGUAGE_PTR with
  0x69800 + 4 * (RAM 0x296E) + 0 / 200 / 400 / 600 - 4 * HELP_LANGUAGE: pages 1-4 of the topic in
  RAM 0x296E.  (The `- 4 * HELP_LANGUAGE` only makes sense if the caller adds 4 * language back to
  the base it gets; that part is an inference.)  The topic's title is
  HelpTtlFunc_LookupSlide_PtrTable[topic - 1], topic 0 using entry 49 (HelpTtlFunc_DecrementPage,
  0xF2E94D, and HelpTtlFunc_LookupSlide, 0xF2E962): topic 0 is DEMO, 1 is AUTO PLAY CHORD.
MEASURED on all five live databases (scripts/build/help_db_text.py verify, and
notes/kn5000-existing-includes-2026-10-29/probes/help_db_layout_probe.py):
  * every empty page points at one empty string, the pool's first, at 0x69B20;
  * every other slot has a string of its own (no two slots share one);
  * the pool holds the empty string and then the texts in topic-major order (topic 0 pages 1-4,
    topic 1 pages 1-4, ...); each string starts on an even address and a string whose NUL lands on
    an even address is followed by one 0x00 pad byte;
  * the only escape is "~0d", the renderer's newline; there are no control bytes; the accented
    letters are Latin-1.
The stale German block (help_db_german_stale.bin) is a truncated factory remnant whose decoded
tail is garbage; it is not in this format, is not a ROM input (only verify-help-databases uses it)
and stays a .bin.

THE LISTING (help_db_<lang>.txt, UTF-8)
  `#` lines are comments.  An entry starts with `@ topic T page P` (anything after it, the title,
  is a comment).  The text follows on the next lines: the listing breaks the line after every
  "~0d" and the line break is not part of the text, so every line of an entry but the last must end
  in "~0d".  A blank line ends the entry.  A page with no entry is empty.

    python3 scripts/build/help_db_text.py export   # help_db_<lang>.bin -> .txt (run once)
    python3 scripts/build/help_db_text.py build    # .txt -> help_db_<lang>.bin (build step)
    python3 scripts/build/help_db_text.py verify   # .txt rebuilds the factory database exactly
"""
import pathlib
import struct
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
DIR = REPO / 'table_data' / 'includes' / 'help_databases'
LANGS = ['english', 'german', 'french', 'spanish', 'indonesian']
SIZE = 0x9000
BASE = 0x69800          # RAM destination of SLIDE_Parse_Header in HelpLang_LoadSlide
SLOTS = 200
TOPICS = 50
POOL = BASE + 4 * SLOTS  # 0x69B20
NL = '~0d'
V10 = REPO / 'original_ROMs' / 'kn5000_v10_program.rom'
TITLE_TABLE = 0xE343EE   # HelpTtlFunc_LookupSlide_PtrTable (v10)


def titles():
    """The 50 topic titles, from the program ROM (export only: the listing's titles are comments)."""
    r = V10.read_bytes()
    pt = struct.unpack('<50I', r[TITLE_TABLE - 0xE00000:TITLE_TABLE - 0xE00000 + 200])
    t = [r[p - 0xE00000:r.index(b'\0', p - 0xE00000)].decode('latin-1') for p in pt]
    return [t[(topic - 1) % TOPICS] for topic in range(TOPICS)]


def decode(blob):
    """blob -> {(topic, page): text} ; asserts the layout described in the docstring."""
    assert len(blob) == SIZE
    ptr = struct.unpack(f'<{SLOTS}I', blob[:4 * SLOTS])
    out = {}
    for slot, p in enumerate(ptr):
        if p == POOL:
            continue
        o = p - BASE
        out[(slot % TOPICS, slot // TOPICS + 1)] = blob[o:blob.index(b'\0', o)].decode('latin-1')
    return out


def encode(entries):
    """{(topic, page): text} -> the 0x9000-byte database."""
    pool = bytearray(b'\0\0')                     # the empty string at 0x69B20, padded to even
    ptr = [POOL] * SLOTS
    for topic, page in sorted(entries):           # topic-major, as the factory pool is
        s = entries[(topic, page)].encode('latin-1')
        assert s and b'\0' not in s
        ptr[(page - 1) * TOPICS + topic] = POOL + len(pool)
        pool += s + b'\0'
        if len(pool) % 2:
            pool += b'\0'
    blob = struct.pack(f'<{SLOTS}I', *ptr) + pool
    assert len(blob) <= SIZE, f'pool overflows the 0x9000-byte database by {len(blob) - SIZE} B'
    return bytes(blob + b'\0' * (SIZE - len(blob)))


def to_text(lang, entries):
    t = titles()
    head = [f'# KN5000 HELP database, {lang.capitalize()} (table_data/help_databases.s, HelpDB_{lang.capitalize()}).',
            '# SOURCE of help_db_%s.bin: scripts/build/help_db_text.py build; that script\'s docstring' % lang,
            '# gives the format and the evidence.  "@ topic T page P" starts an entry (the title after it is',
            '# a comment); the line break after each "~0d" (the renderer\'s newline) is not part of the',
            '# text; a blank line ends the entry; a page with no entry is empty.', '']
    body = []
    for (topic, page) in sorted(entries):
        body.append(f'@ topic {topic} page {page}  {t[topic]}')
        s = entries[(topic, page)]
        parts = s.split(NL)
        lines = [p + NL for p in parts[:-1]] + ([parts[-1]] if parts[-1] else [])
        body.extend(lines)
        body.append('')
    return '\n'.join(head + body)


def from_text(txt):
    entries, key, lines = {}, None, []

    def close():
        if key is not None:
            for ln in lines[:-1]:
                assert ln.endswith(NL), f'{key}: a line that does not end in "~0d" is not last: {ln!r}'
            assert lines, f'{key}: empty entry'
            assert key not in entries, f'{key}: listed twice'
            entries[key] = ''.join(lines)

    for raw in txt.split('\n'):
        if key is None and (raw.startswith('#') or raw == ''):
            continue
        if raw.startswith('@ '):
            close()
            w = raw.split()
            assert w[1] == 'topic' and w[3] == 'page', raw
            key, lines = (int(w[2]), int(w[4])), []
            assert 0 <= key[0] < TOPICS and 1 <= key[1] <= SLOTS // TOPICS, raw
        elif raw == '':
            close()
            key, lines = None, []
        else:
            assert key is not None, f'text outside an entry: {raw!r}'
            lines.append(raw)
    close()
    return entries


def export():
    for lang in LANGS:
        blob = (DIR / f'help_db_{lang}.bin').read_bytes()
        e = decode(blob)
        assert encode(e) == blob, f'{lang}: the layout model does not reproduce the database'
        (DIR / f'help_db_{lang}.txt').write_text(to_text(lang, e), encoding='utf-8')
        print(f'exported {lang}: {len(e)} pages')


def build():
    for lang in LANGS:
        blob = encode(from_text((DIR / f'help_db_{lang}.txt').read_text(encoding='utf-8')))
        out = DIR / f'help_db_{lang}.bin'
        if not out.exists() or out.read_bytes() != blob:
            out.write_bytes(blob)
        else:
            out.touch()
        print(f'built {out.relative_to(REPO)}')


def verify():
    """Each listing rebuilds the database the factory stream decompresses to."""
    sys.path.insert(0, str(REPO / 'scripts' / 'build'))
    import decompress_slide8k as d8
    ok = True
    for lang in LANGS:
        blob = encode(from_text((DIR / f'help_db_{lang}.txt').read_text(encoding='utf-8')))
        ref = REPO / 'original_ROMs' / f'help_db_{lang}_compressed.original.bin'
        hdr = d8.MAGIC + SIZE.to_bytes(3, 'big')
        factory, _ = d8.decompress_slide8k(hdr + ref.read_bytes())
        good = blob == factory
        ok &= good
        print(f'  {"ok  " if good else "FAIL"} {lang:<11} {SIZE:,} B from help_db_{lang}.txt')
    print('ROUND TRIP EXACT' if ok else 'ROUND TRIP BROKEN')
    return ok


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'export':
        export()
    elif cmd == 'build':
        build()
    elif cmd == 'verify':
        sys.exit(0 if verify() else 1)
    else:
        sys.exit(__doc__)
