#!/usr/bin/env python3
r"""gen_naka_menu_map.py -- the KN5000 GUI as a browsable menu map, generated from the C sources.

QUESTION ANSWERED
-----------------
"What screens does the KN5000 main CPU have, how does one get to each (mode -> menu -> menu ...),
where does EXIT go, and which widgets does each screen hold?"  It reads:

  * the widget records of v10/maincpu/ui_widgets/*.c (scripts/analysis/naka_gui_model.py): class,
    object tree (the OBJ_* links), label strings, title-id fields (letter a: AcTitleMenu.title is
    where a menu entry leads, TtlScreen/Screen.exit where EXIT goes);
  * the RegTitle / RegMode registrations of the v10 source: title id -> view object (the screen a
    title shows), mode -> home title;
  * the TITLE_* comments of v10/maincpu/shared/event_codes.s (what a title is on the instrument).

and writes docs/gui/kn5000-menu-map.md.  A menu path is the shortest chain of menu entries from a
mode's home title; a title no data entry leads to is listed as "reached by code" (its procedure
opens it), not guessed.

RUN (repository root; needs rebuilt_ROMs/kn5000_v10_program.llvm.elf)
    python3 scripts/generators/gen_naka_menu_map.py           # write
    python3 scripts/generators/gen_naka_menu_map.py --check   # exit 1 if the committed map is stale
    make menu-map / make gui-check
"""
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
import naka_gui_model as G               # noqa: E402

OUT = os.path.join(ROOT, 'docs', 'gui', 'kn5000-menu-map.md')


def table(rows, head):
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(len(head))]
    fmt = lambda r: '| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |'
    return [fmt(head), '|' + '|'.join('-' * (x + 2) for x in w) + '|'] + [fmt(r) for r in rows]


def md(s):
    return s.replace('|', '\\|').replace('*', '\\*') if s else s


describe = G.title_description
screen_text = G.title_screen_text


def rect(g, f, r):
    v = r['fields'].get('rect', '')
    m = re.match(r'NAKA_XYWH\((-?\d+), (-?\d+), (-?\d+), (-?\d+)\)', v)
    return '%s,%s %sx%s' % m.groups() if m else v


def widget_lines(g, key, depth, seen, out):
    if key in seen or depth > 12:
        return
    seen.add(key)
    fr = g.rec.get(key)
    if not fr:
        cls, where = g.rom_name(key)
        if cls is None:
            out.append('%s- element %d of slot 0x%X: no record in ROM or in a work-RAM image' % ('  ' * depth, key[1], key[0]))
            return
        lab = g.rom_label(key)
        tgt = [v for f_, (ch, v) in g.rom_fields(key).items() if ch == 'a' and f_ != 'exit' and (v >> 16) == 0x1A0]
        out.append('%s- `%s` %s%s, record outside the C sources%s' % (
            '  ' * depth, where, cls, (' "%s"' % md(lab)) if lab else '',
            ''.join(' -> `%s`' % g.title_name(v) for v in tgt)))
        for c in g.children(key):
            widget_lines(g, c, depth + 1, seen, out)
        return
    f, r = fr
    lab = g.label(f, r)
    extra = []
    lt = dict(g.letters.get(r['cls'], []))
    for fld, letter in lt.items():
        if letter == 'a' and fld in r['fields'] and fld != 'exit':
            v = r['fields'][fld].strip()
            if v.startswith('TITLE_'):
                extra.append('-> `%s`' % v)
    fn = g.menu_function(f, r)
    if fn:
        extra.append('-> by code, `%s`' % fn)
    out.append('%s- `OBJ_%s` %s%s [%s]%s' % ('  ' * depth, r['member'], r['cls'],
                                           (' "%s"' % md(lab)) if lab else '', rect(g, f, r),
                                           (' ' + ' '.join(extra)) if extra else ''))
    for c in g.children(key):
        widget_lines(g, c, depth + 1, seen, out)


def opened_list(g, fn):
    lab = G.func_label(g.m, g.ids.get(fn))
    po = sorted(n for n in g.routine_opens.get(lab, ()) if n.startswith('TT_'))
    return (' (%s)' % ', '.join('`TITLE_%s`' % n[3:] for n in po)) if po else ''


def build(g):
    paths = g.menu_paths()
    # routines that pass each TT_* index, for the titles no traced path reaches (lane kn5000-naka,
    # 2026-11-06): those are opened by code that is itself outside every traced path (panel-button
    # handlers, the self test, the sequencer's play-mode code ...), which the map names instead of
    # saying nothing opens them
    opener = collections.defaultdict(set)
    for rout, ns in g.routine_opens.items():
        for n in ns:
            if rout:
                opener[n].add(rout)
    def openers(tid):
        n = g.title_name(tid)
        return sorted(opener.get('TT_' + n[6:], ())) if n.startswith('TITLE_') else []
    unreached = [t for t in g.titles if t not in paths and openers(t)]
    into = collections.defaultdict(list)
    out_menu = collections.defaultdict(list)
    out_exit = collections.defaultdict(set)
    for frm, key, to, kind, lab in g.edges:
        if kind == 'exit':
            if frm is not None:
                out_exit[frm].add(to)
            continue
        into[to].append((frm, lab))
        if frm is not None:
            out_menu[frm].append((lab, to))
    L = ['# KN5000 GUI menu map (main CPU, program v10)', '',
         'GENERATED by `scripts/generators/gen_naka_menu_map.py` from the C sources of',
         '`v10/maincpu/ui_widgets/` and the `RegTitle` / `RegMode` registrations; do not edit.',
         'Regenerate with `make menu-map`; `make gui-check` fails when this file is stale.', '',
         'A **title** (`TITLE_*`, id `0x01A0xxxx`) is a screen the firmware can show: `RegTitle`',
         'binds it to a view object, the root widget of the screen.  A **mode** (`MD_*`) has a home',
         'title.  A menu entry is an `AcTitleMenu` widget whose `title` field names the title it opens;',
         'a screen\'s `exit` field is where EXIT goes.  The path of a title is the shortest chain of',
         'menu entries from a mode\'s home title; a step "(by Func)" is code that opens the title: a',
         'title\'s procedure, or the function of a menu box, passing the title\'s `TT_*` index to',
         '`UI_ChangeTitleByIndex` / `UI_InterruptTitleByIndex` (`scripts/converters/name_title_index_operands.py`)',
         'or posting `EVT_CHANGE_TITLE` itself.', '',
         '%d titles (%d with a path; %d of the others are opened by code that no traced path reaches),'
         ' %d modes, %d widget records in %d C files, %d menu entries, %d code'
         ' transitions and %d EXIT links.'
         % (len(g.titles), len(paths), len(unreached), len(g.modes), len(g.rec), len(g.files),
            sum(1 for e in g.edges if e[3] == 'menu'), len(g.code_edges),
            sum(1 for e in g.edges if e[3] == 'exit')), '',
         '## Modes', '']
    import name_title_index_operands as N
    mode_by = {}
    for rout, ms in N.opens_by_routine('v10', 'mode').items():
        for x in ms:
            if rout:
                mode_by.setdefault(x, set()).add(rout)
    rows = []
    for mid, md_ in sorted(g.modes.items()):
        by = sorted(mode_by.get(md_['name'], ()))
        rows.append(('`%s`' % md_['name'], ' / '.join(g.mode_button.get(md_['name'], [])) or '-',
                     '`%s`' % g.title_name(md_['home']), md(screen_text(g, md_['home'])) or '-',
                     (', '.join('`%s`' % x for x in by[:3]) + (' +%d' % (len(by) - 3) if len(by) > 3 else '')) or '-'))
    L += table(rows, ('mode', 'panel button', 'home title', 'screen title', 'also entered by code in')) + ['']
    L += ['The panel buttons come from the mode-key maps `PanelButton_ModeKeyCodes*` of',
          '`ui_widgets/naka_extension_device.c`: `PanelButton_ModeKey` (`audio/audio_control_engine.s`) replaces',
          'the button bits with map[lowest set bit] and posts the mode as `EVT_SW_IN_MODE`',
          '(`boot/main_title_ctrl_panel.s`: `NAKA_MODE_MD_PS + payload`).  Button names are the MAME driver\'s',
          'CPL_SEGn / CPR_SEGn port names.  Modes without a button are entered by code (`UI_ChangeModeByIndex`).', '']
    L += ['## Titles by menu path', '']
    order = sorted(g.titles, key=lambda t: (t not in paths, len(paths.get(t, [])),
                                            [str(x) for x in paths.get(t, [])], t))
    for tid in order:
        t = g.titles[tid]
        name = g.title_name(tid)
        st = screen_text(g, tid)
        L.append('### `%s`%s' % (name, (' -- "%s"' % md(st)) if st else ''))
        L.append('')
        d = describe(g, tid)
        if d:
            L.append(md(d))
            L.append('')
        pth = G.title_path(g, tid, paths)
        if pth:
            L.append('- Path: ' + md(pth))
        elif openers(tid):
            L.append('- Path: none found (no data entry opens it; the code that does is reached by no traced path)')
            L.append('- Opened by code in: ' + ', '.join('`%s`' % r for r in openers(tid)))
        else:
            L.append('- Path: none found (no data entry, and no traced code, opens it)')
        L.append('- Registered: `"%s"`, title id 0x%X, function `%s`, %s'
                 % (t['name'], t['index'], g.name_by_value.get(t['func'], '0x%08X' % (t['func'] or 0)),
                    t['file']))
        if t['view'] is not None:
            key = (t['view'] >> 16, t['view'] & 0xFFFF)
            fr = g.rec.get(key)
            if fr:
                L.append('- View: `OBJ_%s` (%s) in `%s`' % (fr[1]['member'], fr[1]['cls'], fr[0].name))
            else:
                L.append('- View: element %d of Viewable slot 0x%X (record outside the C sources)' % (key[1], key[0]))
        ent = out_menu.get(tid, [])
        if ent:
            L.append('- Menu entries: ' + ', '.join('"%s" -> `%s`' % (md(lab) or '?', g.title_name(to))
                                                    for lab, to in ent))
        fe = [(lab, fn) for frm, key, fn, lab in g.func_entries if frm == tid]
        if fe:
            L.append('- Entries that open a title by code: ' + ', '.join(
                '"%s" -> `%s`%s' % (md(lab) or '?', fn, opened_list(g, fn)) for lab, fn in fe))
        proc = G.func_label(g.m, t['func'])
        po = sorted(n for n in g.routine_opens.get(proc, ()) if n.startswith('TT_'))
        if po:
            L.append('- Its procedure `%s` opens: %s' % (proc, ', '.join('`TITLE_%s`' % n[3:] for n in po)))
        ex = out_exit.get(tid)
        if ex:
            L.append('- EXIT -> ' + ', '.join('`%s`' % g.title_name(x) for x in sorted(ex)))
        fr_ = sorted({(g.title_name(f) if f else 'an untitled view', lab) for f, lab in into.get(tid, [])})
        if fr_:
            L.append('- Opened from: ' + ', '.join('`%s` ("%s")' % (a, md(b)) if b else '`%s`' % a for a, b in fr_))
        if t['view'] is not None and (t['view'] >> 16, t['view'] & 0xFFFF) in g.rec:
            L.append('- Widgets:')
            L.append('')
            wl = []
            widget_lines(g, (t['view'] >> 16, t['view'] & 0xFFFF), 1, set(), wl)
            L += wl
        L.append('')
    return '\n'.join(L).rstrip('\n') + '\n'


def main():
    g = G.Graph('v10')
    G.add_code_edges(g)
    text = build(g)
    if '--check' in sys.argv:
        cur = open(OUT, encoding='utf-8').read() if os.path.exists(OUT) else None
        if cur != text:
            print('gen_naka_menu_map: %s is stale; run make menu-map' % os.path.relpath(OUT, ROOT))
            sys.exit(1)
        print('gen_naka_menu_map: %s up to date' % os.path.relpath(OUT, ROOT))
        return
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, 'w', encoding='utf-8').write(text)
    print('wrote %s (%d lines)' % (os.path.relpath(OUT, ROOT), text.count('\n')))


if __name__ == '__main__':
    main()
