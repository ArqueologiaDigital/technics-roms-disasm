#!/usr/bin/env python3
"""A local dashboard of the cc900 model's scores over time.

Question it answers: how did each score of the phase-3a effort move, commit by commit?

    python3 scripts/analysis/cc900/dashboard.py            # writes ~/compartilhado/tmp/cc900-dashboard/index.html
    python3 scripts/analysis/cc900/dashboard.py --serve    # the same, then serves it on http://localhost:8765/
    python3 scripts/analysis/cc900/dashboard.py OUT.html

Signal read: one point per commit that touched scripts/analysis/cc900/model/ or scripts/analysis/cc900/results/ (a
round), whether or not a score moved: the state at that commit of results/model_ledger.md (the rows `sh model/ledger.sh`
prints: "oracle run, compiler/set | corpus | N / M exact") and of results/semcheck.md (its "Totals per option set"
table, column DIFFERENT), taken with `git show <commit>:<file>`.  A round that changes nothing shows as a flat step.  Nothing is measured here; the page is only as fresh as the
last committed ledger.  The output is regenerable and is not committed.

.githooks/post-commit runs this script in the background after every commit that changes either results file, and the
page reloads itself every two minutes, so a tab left open on `--serve` follows the rounds.

A second section, "ROM bytes built from C", charts results/c_build_coverage.md (scripts/analysis/cc900/c_build_coverage.py,
`make cc900-c-coverage`) at every commit that changed it: the bytes of the Technics images that C gives exactly, and
their share of the images' census CODE, one series per toolchain (Toshiba V4.23, the reference model, the LLVM
backend), with the latest per-image table.  Commits before the file existed simply have no point; with no such commit
the section says so.

Three tiles count the rounds, give the time of the last one and the mean time of the last ten, and a chart and a
table column give every round's: a round's time is the wall-clock gap between its
commit and the round commit before it (author dates), so a pause between sessions counts as part of the next round."""
import sys, os, re, json, subprocess, html

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
LEDGER = 'scripts/analysis/cc900/results/model_ledger.md'
SEMCHECK = 'scripts/analysis/cc900/results/semcheck.md'
SETS = ['none', 'O3XS', 'Xr', 'O3XSXr']
SET_LABEL = {'none': 'no options', 'O3XS': '-O3 -XS', 'Xr': '-Xr', 'O3XSXr': '-O3 -XS -Xr'}


def git(*a):
    return subprocess.run(['git', '-C', REPO] + list(a), capture_output=True, text=True, errors='replace').stdout


def commits_of(path):
    out = []
    for line in git('log', '--reverse', '--format=%H%x1f%aI%x1f%s', '--', path).splitlines():
        h, d, s = line.split('\x1f', 2)
        out.append((h, d, s))
    return out


ROW = re.compile(r'^\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(\d+)\s*/\s*(\d+)\s+exact')


def ledger_scores(text):
    """{series: (exact, total)} for one version of model_ledger.md"""
    acc = {}

    def add(k, e, t):
        a = acc.setdefault(k, [0, 0]); a[0] += e; a[1] += t
    for line in text.splitlines():
        m = ROW.match(line)
        if not m: continue
        oracle, corpus, e, t = m.group(1), m.group(2), int(m.group(3)), int(m.group(4))
        sm = re.search(r'\bv423/(none|O3XSXr|O3XS|Xr)\b', oracle)
        if not sm or '--personality' in oracle and '--personality v4.23' not in oracle: continue
        st = sm.group(1)
        if corpus.startswith('random'): add('random/' + st, e, t)
        elif corpus == 'micro/*.c': add('micro/' + st, e, t)
        elif corpus.startswith('probes/'): add('probes/' + st, e, t); acc.setdefault('__probes__', {})[corpus[7:] + ' ' + st] = t
        elif corpus == '1997 LIB/SRC': add('library/' + st, e, t)
    return {k: (v if k == '__probes__' else tuple(v)) for k, v in acc.items()}


def semcheck_scores(text):
    out = {}; on = False
    for line in text.splitlines():
        if line.startswith('## Totals per option set'): on = True; continue
        if on and line.startswith('## '): break
        m = re.match(r'^\|\s*v423/(\w+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|', line) if on else None
        if m: out[m.group(1)] = int(m.group(4))
    return out


ROUND_PATHS = ['scripts/analysis/cc900/model', 'scripts/analysis/cc900/results']


def collect():
    """one row per round commit, with the ledger and the semcheck total as they stood at that commit (parsed once per
    distinct file version: most commits leave one of the two files as it was)"""
    seen = {}

    def at(h, path, parse):
        blob = git('rev-parse', '--verify', '-q', '%s:%s' % (h, path)).strip()
        if not blob: return None
        if blob not in seen: seen[blob] = parse(git('cat-file', 'blob', blob))
        return seen[blob]
    rows = []
    log = git('log', '--reverse', '--format=%H%x1f%aI%x1f%s', '--', *ROUND_PATHS).splitlines()
    for line in log:
        h, d, s = line.split('\x1f', 2)
        sc = at(h, LEDGER, ledger_scores)
        if not sc: continue
        sm = at(h, SEMCHECK, semcheck_scores)
        prev = rows[-1] if rows else None
        sc = dict(sc); rowsets = sc.pop('__probes__', {})          # {"probe.c set": functions}
        old = prev['_rows'] if prev else {}
        names = sorted({k.split(' ')[0] for k, t in rowsets.items() if k not in old})
        grown = sorted({k.split(' ')[0] for k, t in rowsets.items() if k in old and old[k] != t} - set(names))
        added = sum(t for k, t in rowsets.items() if k not in old) + sum(t - old[k] for k, t in rowsets.items() if k in old)
        row = {'h': h[:9], 'date': d, 'subject': s, 'scores': sc, 'semdiff': sum(sm.values()) if sm else None,
               '_rows': rowsets, 'newprobes': names if prev else [], 'grown': grown if prev else [], 'added': added if prev else 0}
        row['moved'] = prev is None or prev['scores'] != sc or prev['semdiff'] != row['semdiff']
        rows.append(row)
    for r in rows: del r['_rows']
    return rows


COVERAGE = 'scripts/analysis/cc900/results/c_build_coverage.md'
TOOLCHAINS = ['V4.23', 'model', 'LLVM']


def md_tables(text):
    """{section heading: [{column: cell}]} for every Markdown table of a file"""
    out, head, cols = {}, None, None
    for line in text.splitlines():
        if line.startswith('## '): head, cols = line[3:].strip(), None; continue
        if not line.startswith('|'): cols = None; continue
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if cols is None: cols = cells; out.setdefault(head, []); continue
        if all(set(c) <= set('-:') for c in cells): continue
        out[head].append(dict(zip(cols, cells)))
    return out


def coverage_scores(text):
    """one version of c_build_coverage.md -> {'tot': {toolchain: [bytes, code bytes]}, 'fw' / 'lib': {toolchain: bytes},
    'code': all images' CODE bytes, 'images': [[image, size, code, category, items, {toolchain: [b, cb]}, unchecked]]}"""
    t = md_tables(text).get('Per image', [])
    if not t: return None
    num = lambda c: int(re.sub(r'[^0-9]', '', c) or 0)
    pair = lambda c: [num(x) for x in (c.split('/') + ['0'])[:2]]
    d = {'tot': {k: [0, 0] for k in TOOLCHAINS}, 'fw': {k: 0 for k in TOOLCHAINS}, 'lib': {k: 0 for k in TOOLCHAINS},
         'code': 0, 'size': 0, 'unchecked': 0, 'images': []}
    seen = set()
    for r in t:
        img = r.get('image', '')
        if img not in seen:
            seen.add(img); d['code'] += num(r.get('code', '0')); d['size'] += num(r.get('size', '0'))
        v = {k: pair(r.get('%s bytes / code' % k, '0 / 0')) for k in TOOLCHAINS}
        for k in TOOLCHAINS:
            d['tot'][k][0] += v[k][0]; d['tot'][k][1] += v[k][1]
            if r.get('category') == 'firmware C': d['fw'][k] += v[k][0]
            elif r.get('category') == 'library C': d['lib'][k] += v[k][0]
        un = num(r.get('V4.23 not yet checked', '0')); d['unchecked'] += un
        d['images'].append([img, num(r.get('size', '0')), num(r.get('code', '0')), r.get('category', '-'),
                            num(r.get('items', '0')), v, un])
    return d


PROGRESS = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'results', 'c_progress.tsv')


def collect_progress():
    """results/c_progress.tsv (c_progress.py record): one point per V4.23 run of the firmware-C work, built + staged"""
    out, prev = [], None
    if os.path.exists(PROGRESS):
        for line in open(PROGRESS, encoding='utf-8'):
            f = line.rstrip('\n').split('\t')
            if line.startswith('time\t') or len(f) < 8: continue
            v = [int(x) for x in f[2:8]]
            out.append(dict(date=f[0], h=f[1][:24], subject='V4.23 run ' + f[1], moved=(prev is None or v != prev),
                            built_fn=v[0], built_b=v[1], staged_fn=v[2], staged_b=v[3], v10_fn=v[4], v10_b=v[5],
                            images={k: [int(x) for x in val.split('/')] for k, val in
                                    (kv.split('=') for kv in (f[8].split(';') if len(f) > 8 and f[8] else []))}))
            prev = v
    return out


STAGES = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'results', 'stage_scores.tsv')


def collect_stages():
    """results/stage_scores.tsv (stages/stage_scores.py): one point per measurement of a back-end stage (S1-S4)"""
    out = []
    if os.path.exists(STAGES):
        for line in open(STAGES, encoding='utf-8'):
            f = line.rstrip('\n').split('\t')
            if line.startswith('time\t') or len(f) < 6: continue
            subj = git('log', '-1', '--format=%s', f[1]).strip() if f[1] else ''
            out.append(dict(date=f[0], h=f[1], subject=('%s %s / %s %s%s. ' % (f[2], f[3], f[4], f[5],
                            (' (' + f[6] + ')') if len(f) > 6 and f[6] else '')) + subj, moved=True,
                            stage=f[2], exact=int(f[3]), total=int(f[4]), unit=f[5]))
    out.sort(key=lambda r: r['date'])
    return out


def collect_coverage():
    """one row per commit that changed c_build_coverage.md, with its figures; none before the file existed"""
    rows = []
    for line in git('log', '--reverse', '--format=%H%x1f%aI%x1f%s', '--', COVERAGE).splitlines():
        h, d, s = line.split('\x1f', 2)
        blob = git('show', '%s:%s' % (h, COVERAGE))
        sc = coverage_scores(blob) if blob else None
        if sc: rows.append(dict(h=h[:9], date=d, subject=s, moved=True, **sc))
    return rows


PAGE = r'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="120">
<title>cc900 model scores</title>
<style>
:root { color-scheme: light;
  --page: #f6f5f2; --surface-1: #fcfcfb; --border: #dddbd4; --grid: #e7e5df;
  --text-primary: #0b0b0b; --text-secondary: #52514e; --text-muted: #7b7a74;
  --series-1: #2a78d6; --series-2: #eb6834; --series-3: #1baf7a; --series-4: #eda100;
  --series-5: #8e5cd9; --series-6: #d6457a; --series-7: #0f7f8c; --series-8: #8c5a2b; --series-9: #5b6b84; --series-10: #6f8a1c;
  --good: #1a7f37; --serious: #b3261e; }
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { color-scheme: dark;
  --page: #121211; --surface-1: #1a1a19; --border: #33322f; --grid: #2a2927;
  --text-primary: #f0efec; --text-secondary: #c3c2b7; --text-muted: #8f8e86;
  --series-1: #3987e5; --series-2: #d95926; --series-3: #199e70; --series-4: #c98500;
  --series-5: #a47de8; --series-6: #e8689a; --series-7: #2aa5b3; --series-8: #b98450; --series-9: #8a9ab5; --series-10: #97b33a;
  --good: #4cc26b; --serious: #f2867e; } }
:root[data-theme="dark"] { color-scheme: dark;
  --page: #121211; --surface-1: #1a1a19; --border: #33322f; --grid: #2a2927;
  --text-primary: #f0efec; --text-secondary: #c3c2b7; --text-muted: #8f8e86;
  --series-1: #3987e5; --series-2: #d95926; --series-3: #199e70; --series-4: #c98500;
  --series-5: #a47de8; --series-6: #e8689a; --series-7: #2aa5b3; --series-8: #b98450; --series-9: #8a9ab5; --series-10: #97b33a;
  --good: #4cc26b; --serious: #f2867e; }
* { box-sizing: border-box; }
body { margin: 0; background: var(--page); color: var(--text-primary);
  font: 14px/1.45 system-ui, -apple-system, "Segoe UI", sans-serif; }
main { max-width: 1180px; margin: 0 auto; padding: 24px 16px 48px; }
h1 { font-size: 22px; margin: 0 0 4px; } h2 { font-size: 15px; margin: 0 0 2px; }
p.sub { margin: 0 0 20px; color: var(--text-secondary); }
.bar { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin: 0 0 16px; color: var(--text-secondary); font-size: 13px; }
.bar button { font: inherit; padding: 4px 10px; border-radius: 6px; border: 1px solid var(--border); background: var(--surface-1);
  color: var(--text-primary); cursor: pointer; }
.bar button[aria-pressed="true"] { border-color: var(--text-primary); font-weight: 600; }
.bar .note { color: var(--text-muted); margin-left: 8px; }
.tiles { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; margin-bottom: 20px; }
.tile, .card { background: var(--surface-1); border: 1px solid var(--border); border-radius: 8px; padding: 14px 16px; }
.dir { display: inline-block; font-size: 12px; font-weight: 600; padding: 2px 8px; border-radius: 10px; border: 1px solid var(--border); color: var(--text-secondary); margin: 2px 0 6px; }
.tile .k { color: var(--text-secondary); font-size: 12px; }
.tile .v { font-size: 28px; font-weight: 650; font-variant-numeric: tabular-nums; margin: 2px 0; }
.tile .t { color: var(--text-muted); font-size: 12px; }
.tile .d { font-size: 12px; font-variant-numeric: tabular-nums; }
.up { color: var(--good); } .down { color: var(--serious); }
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(520px, 1fr)); gap: 12px; }
@media (max-width: 600px) { .grid { grid-template-columns: 1fr; } }
.card p { margin: 0 0 8px; color: var(--text-secondary); font-size: 12.5px; }
.legend { display: flex; flex-wrap: wrap; gap: 4px 14px; font-size: 12px; color: var(--text-secondary); margin-bottom: 4px; }
.legend i { display: inline-block; width: 14px; height: 3px; border-radius: 2px; vertical-align: middle; margin-right: 5px; }
.plot { position: relative; }
svg { display: block; width: 100%; height: auto; overflow: visible; }
svg text { fill: var(--text-muted); font-size: 11px; font-variant-numeric: tabular-nums; }
svg .lab { fill: var(--text-secondary); font-size: 11.5px; }
.tip { position: absolute; pointer-events: none; background: var(--surface-1); border: 1px solid var(--border);
  border-radius: 6px; padding: 8px 10px; font-size: 12px; box-shadow: 0 4px 14px rgba(0,0,0,.14); display: none;
  max-width: 340px; z-index: 2; }
.tip b { font-variant-numeric: tabular-nums; } .tip .s { color: var(--text-muted); margin-bottom: 4px; }
.tip i { display: inline-block; width: 10px; height: 3px; border-radius: 2px; vertical-align: middle; margin-right: 6px; }
details { margin-top: 16px; } summary { cursor: pointer; color: var(--text-secondary); }
table { border-collapse: collapse; font-size: 12px; font-variant-numeric: tabular-nums; margin-top: 8px; }
th, td { padding: 3px 8px; border-bottom: 1px solid var(--grid); text-align: right; white-space: nowrap; }
th:first-child, td:first-child, th:nth-child(2), td:nth-child(2) { text-align: left; }
td.sj { max-width: 380px; overflow: hidden; text-overflow: ellipsis; text-align: left; }
.scroll { overflow-x: auto; }
h1.sec { font-size: 18px; margin: 32px 0 4px; } p.empty { color: var(--text-muted); }
</style></head>
<body><main>
<h1>cc900 model: scores over time</h1>
<p class="sub">Exact-match counts of the Python model against Toshiba cc900 V4.23, one point per round: every
commit that changed the model or its results (__N__ rounds, __FIRST__ to __LAST__). Generated __NOW__ from git history; nothing here is measured live. The page is rebuilt after every such
commit and reloads itself every two minutes.</p>
<div class="bar"><span>Horizontal axis:</span>
<button id="ax-commit" aria-pressed="true">one step per round</button><button id="ax-time" aria-pressed="false">real time</button>
<span class="note">__FLAT__ of the __N__ rounds changed no score; they are plotted too, as flat steps.</span></div>
<div class="tiles" id="tiles"></div>
<h1 class="sec" id="stages">Back-end rebuild along thc1 / thc2's seam (stages S1-S4)</h1>
<p class="sub">The model rebuilt stage by stage, each stage fed Toshiba V4.23's own output of the stage before and
checked against its own output after it (firmware C, <code>-Xr</code>): S1 thc1's IR to thc2's <code>-zio</code>, S2
<code>-zio</code> to <code>-zim</code>, S3 register allocation of named variables against <code>-g</code>, S4 the code
(instruction selection, temporaries' registers, frames). One point per measurement (results/stage_scores.tsv,
<code>stages/*_check.py --record</code>; earlier points from the numbers the stage commits quoted).</p>
<div class="grid" id="stage-charts"></div>
<div class="grid" id="charts"></div>
<details><summary>Table view (every commit, newest first)</summary><div class="scroll"><table id="tbl"></table></div></details>
<h1 class="sec" id="c-coverage">ROM bytes built from C</h1>
<p class="sub">How many bytes of the Technics ROM images (KN5000 and SX-WSA1R, every version counted on its own) C gives
exactly, checked byte for byte against each image, per toolchain: Toshiba's own V4.23 compiler, our Python reference
model (what <code>make</code> builds today), and our LLVM backend with <code>-mcc900-compat</code> (not working yet:
0 until it is). Firmware C is Matsushita's functions rebuilt in phase 6 and built into the image; library C is
Toshiba's runtime routines linked into the images, checked but not yet built from C. One point per commit that changed
<code>results/c_build_coverage.md</code> (<code>make cc900-c-coverage</code>).</p>
<div class="tiles" id="cov-tiles"></div>
<div class="grid" id="cov-charts"></div>
<div class="card" style="margin-top:12px"><h2>Per image, at the latest commit</h2><p id="cov-note"></p><div class="scroll"><table id="cov-tbl"></table></div></div>
</main>
<script>
const DATA = __DATA__;
const SETS = ["none","O3XS","Xr","O3XSXr"], LABEL = {none:"no options", O3XS:"-O3 -XS", Xr:"-Xr", O3XSXr:"-O3 -XS -Xr"};
const COLOR = {none:"var(--series-1)", O3XS:"var(--series-2)", Xr:"var(--series-3)", O3XSXr:"var(--series-4)"};
const R = DATA.rows, n = R.length;
let AXIS = "commit"; try { AXIS = localStorage.getItem("cc900-axis") || "commit"; } catch (e) {}
const T0 = new Date(R[0].date).getTime(), T1 = new Date(R[n - 1].date).getTime();
const fracOf = (RR, i) => { const m = RR.length, a = new Date(RR[0].date).getTime(), b = new Date(RR[m - 1].date).getTime();
  return m === 1 ? 0.5 : AXIS === "time" && b > a ? (new Date(RR[i].date).getTime() - a) / (b - a) : i / (m - 1); };
const frac = i => fracOf(R, i);
const val = (r, key, pct) => { const s = r.scores[key]; if (!s) return null; return pct ? 100 * s[0] / s[1] : s[0]; };
const fmt = (v, pct) => v == null ? "–" : pct ? v.toFixed(1) + " %" : String(v);
const esc = s => s.replace(/[&<>]/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;"}[c]));

// ---- stat tiles: the plan's phase 3a criteria, latest against a day earlier
function tile(k, v, target, delta, goodUp) {
  const cls = delta == null || delta === 0 ? "" : ((delta > 0) === goodUp ? "up" : "down");
  const d = delta == null ? "" : `<div class="d ${cls}">${delta > 0 ? "▲ +" : delta < 0 ? "▼ " : "■ "}${delta} since ${DATA.since}</div>`;
  return `<div class="tile"><div class="k">${k}</div><div class="v">${v}</div><div class="t">${target}</div>${d}</div>`;
}
(function () {
  const last = R[n - 1], cut = new Date(new Date(last.date).getTime() - 24 * 3600e3);
  let prev = R[0]; for (const r of R) if (new Date(r.date) <= cut) prev = r;
  DATA.since = prev.date.slice(0, 10);
  const g = (r, k) => r.scores[k] ? r.scores[k][0] : null, t = (r, k) => r.scores[k] ? r.scores[k][1] : null;
  const dl = k => g(last, k) == null || g(prev, k) == null ? null : g(last, k) - g(prev, k);
  const T = [];
  T.push(tile("Random programs exact, no options", `${g(last,"random/none")} / ${t(last,"random/none")}`,
    `target 95 % · now ${(100*g(last,"random/none")/t(last,"random/none")).toFixed(1)} %`, dl("random/none"), true));
  T.push(tile("1997 library exact, -O3 -XS", `${g(last,"library/O3XS")} / ${t(last,"library/O3XS")}`, "target 100 %", dl("library/O3XS"), true));
  T.push(tile("Micro corpus exact, no options", `${g(last,"micro/none")} / ${t(last,"micro/none")}`, "target 100 % at every option set", dl("micro/none"), true));
  const pe = SETS.reduce((a, s) => a + (g(last, "probes/" + s) || 0), 0), pt = SETS.reduce((a, s) => a + (t(last, "probes/" + s) || 0), 0);
  const pp = SETS.reduce((a, s) => a + (g(prev, "probes/" + s) || 0), 0);
  T.push(tile("Probe functions exact, all option sets", `${(100*pe/pt).toFixed(1)} %`, `${pe} of ${pt} · probes are added as rules are studied`, pe - pp, true));
  T.push(tile("Semantic differences from the oracle", last.semdiff == null ? "–" : last.semdiff, "all reviewed; target: no wrong code",
    last.semdiff == null || prev.semdiff == null ? null : last.semdiff - prev.semdiff, false));
  // rounds, and what one costs: a round's time is the wall-clock gap between its commit and the round before it
  const gaps = []; for (let i = 1; i < n; i++) gaps.push(Math.max(0, (new Date(R[i].date) - new Date(R[i - 1].date)) / 60e3));
  const fmt = m => m >= 90 ? `${Math.floor(m / 60)} h ${String(Math.round(m % 60)).padStart(2, "0")} min` : `${Math.round(m)} min`;
  const mean = a => a.reduce((x, y) => x + y, 0) / a.length;
  const l10 = gaps.slice(-10), p10 = gaps.slice(-20, -10);
  const flat = R.filter(r => !r.moved).length;
  T.push(tile("Rounds so far", n, `${n - flat} moved a score · ${flat} did not`, null, true));
  T.push(tile("Time of the last round", gaps.length ? fmt(gaps[gaps.length - 1]) : "–",
    gaps.length ? `${R[n - 2].date.slice(11, 16)} to ${R[n - 1].date.slice(11, 16)} on ${R[n - 1].date.slice(0, 10)} · ${R[n - 1].h}` +
      (gaps.length > 1 ? ` · the one before: ${fmt(gaps[gaps.length - 2])}` : "") : "", null, false));
  T.push(tile(`Time per round, mean of the last ${l10.length}`, l10.length ? fmt(mean(l10)) : "–",
    "commit to commit, wall clock" + (p10.length ? ` · the ${p10.length} before: ${fmt(mean(p10))}` : ""), null, false));
  document.getElementById("tiles").innerHTML = T.join("");
})();

// ---- the wall-clock time of each round: the gap to the round commit before it, in minutes
const GAP = R.map((r, i) => i ? Math.max(0, (new Date(r.date) - new Date(R[i - 1].date)) / 60e3) : null), CAP = 120;   // (a commit authored before its parent counts as 0)
// the part of each round spent on the owner's prompts: the overlap of interruptions.tsv's intervals with the round
const BRK0 = Math.min(...(DATA.breaks || []).map(k => new Date(k[0]).getTime()));   // nothing was recorded before this
const BRK = R.map((r, i) => { if (!i) return null; const a = new Date(R[i - 1].date).getTime(), b = new Date(r.date).getTime(); let t = 0;
  if (!(b > BRK0)) return null;
  for (const k of (DATA.breaks || [])) if (k[2] !== "idle") t += Math.max(0, Math.min(b, new Date(k[1]).getTime()) - Math.max(a, new Date(k[0]).getTime()));
  return t / 60e3; });
const IDLE = R.map((r, i) => { if (!i) return null; const a = new Date(R[i - 1].date).getTime(), b = new Date(r.date).getTime(); let t = 0;
  if (!(b > BRK0)) return null;
  for (const k of (DATA.breaks || [])) if (k[2] === "idle") t += Math.max(0, Math.min(b, new Date(k[1]).getTime()) - Math.max(a, new Date(k[0]).getTime()));
  return t / 60e3; });
const fmtMin = m => m >= 90 ? `${Math.floor(m / 60)} h ${String(Math.round(m % 60)).padStart(2, "0")} min` : m < 10 ? `${m.toFixed(1)} min` : `${Math.round(m)} min`;

// ---- line charts
function chart(title, note, series, opts) {
  opts = opts || {};
  const RR = opts.rows || R, nn = RR.length;
  const W = 560, H = 250, L = opts.left || 44, Rm = opts.right || 96, Tp = 10, B = 26, pw = W - L - Rm, ph = H - Tp - B;
  const card = document.createElement("div"); card.className = "card";
  let lo = Infinity, hi = -Infinity;
  for (const s of series) for (const v of s.v) if (v != null) { lo = Math.min(lo, v); hi = Math.max(hi, v); }
  if (opts.zero) lo = 0; if (opts.max != null) hi = Math.max(hi, opts.max);
  const pad = (hi - lo) * 0.06 || 1; if (!opts.zero) lo = Math.max(0, lo - pad); hi = hi + pad;
  const x = i => L + pw * fracOf(RR, i), y = v => Tp + ph * (1 - (v - lo) / (hi - lo));
  const step = (() => { const raw = (hi - lo) / 4, p = Math.pow(10, Math.floor(Math.log10(raw))); return [1, 2, 5, 10].map(m => m * p).find(m => m >= raw); })();
  let g = "";
  for (let t = Math.ceil(lo / step) * step; t <= hi; t += step)
    g += `<line x1="${L}" x2="${L + pw}" y1="${y(t)}" y2="${y(t)}" stroke="var(--grid)"/><text x="${L - 6}" y="${y(t) + 4}" text-anchor="end">${opts.pct ? +t.toFixed(4) + " %" : opts.cap != null && t >= opts.cap ? "≥ " + t : t}</text>`;
  let lastDay = "", lastX = -99;
  RR.forEach((r, i) => { const d = r.date.slice(5, 10); if (d !== lastDay) { lastDay = d;
    if (x(i) - lastX > 28) { g += `<line x1="${x(i)}" x2="${x(i)}" y1="${Tp + ph}" y2="${Tp + ph + 4}" stroke="var(--border)"/><text x="${x(i)}" y="${H - 6}" text-anchor="middle">${d}</text>`; lastX = x(i); } } });
  if (opts.marks) R.forEach((r, i) => { if (r.newprobes && (r.newprobes.length || r.grown.length))
    g += `<line x1="${x(i)}" x2="${x(i)}" y1="${Tp}" y2="${Tp + ph}" stroke="var(--text-muted)" stroke-width="1" stroke-dasharray="2 3" opacity="0.7"/>`; });
  if (opts.target != null && opts.target <= hi) g += `<line x1="${L}" x2="${L + pw}" y1="${y(opts.target)}" y2="${y(opts.target)}" stroke="var(--text-muted)" stroke-dasharray="4 4"/><text class="lab" x="${L + 6}" y="${y(opts.target) - 5}">target ${opts.target}</text>`;
  const ends = [];
  for (const s of series) {
    let dpath = "", pen = false, li = -1;
    s.v.forEach((v, i) => { if (v == null) { pen = false; return; } dpath += (pen ? "L" : "M") + x(i).toFixed(1) + " " + y(v).toFixed(1); pen = true; li = i; });
    g += `<path d="${dpath}" fill="none" stroke="${s.c}" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>`;
    if (li >= 0) { g += `<circle cx="${x(li)}" cy="${y(s.v[li])}" r="4" fill="${s.c}" stroke="var(--surface-1)" stroke-width="2"/>`; ends.push({ s, yy: y(s.v[li]), v: s.v[li] }); }
  }
  ends.sort((a, b) => a.yy - b.yy); for (let i = 1; i < ends.length; i++) if (ends[i].yy - ends[i - 1].yy < 13) ends[i].yy = ends[i - 1].yy + 13;
  for (const e of ends) g += `<text class="lab" x="${L + pw + 8}" y="${e.yy + 4}">${esc(e.s.short || e.s.name)} ${opts.fmt ? opts.fmt(e.s.tv ? e.s.tv[e.s.tv.length - 1] : e.v) : fmt(e.v, opts.pct)}</text>`;
  const legend = series.length > 1 ? `<div class="legend">${series.map(s => `<span><i style="background:${s.c}"></i>${esc(s.name)}</span>`).join("")}</div>` : "";
  const dir = opts.good ? `<div class="dir up">${esc(opts.good)}</div>` : "";
  card.innerHTML = `<h2>${title}</h2>${dir}<p>${note}</p>${legend}<div class="plot"><svg viewBox="0 0 ${W} ${H}" role="img" aria-label="${title}">${g}
    <line class="cross" x1="0" x2="0" y1="${Tp}" y2="${Tp + ph}" stroke="var(--text-muted)" stroke-width="1" visibility="hidden"/>
    <rect x="${L}" y="${Tp}" width="${pw}" height="${ph}" fill="transparent"/></svg><div class="tip"></div></div>`;
  const svg = card.querySelector("svg"), tip = card.querySelector(".tip"), cross = card.querySelector(".cross"), plot = card.querySelector(".plot");
  svg.addEventListener("mousemove", ev => {
    const bb = svg.getBoundingClientRect(), sx = (ev.clientX - bb.left) * W / bb.width;
    let i = 0, best = 1e9; for (let k = 0; k < nn; k++) { const dd = Math.abs(x(k) - sx); if (dd < best) { best = dd; i = k; } }
    const r = RR[i];
    cross.setAttribute("x1", x(i)); cross.setAttribute("x2", x(i)); cross.setAttribute("visibility", "visible");
    tip.innerHTML = `<div class="s">${r.date.slice(0, 16).replace("T", " ")} · ${r.h}${r.moved ? "" : " · no score changed"}<br>${esc(r.subject.slice(0, 110))}</div>` +
      (opts.marks && r.newprobes && (r.newprobes.length || r.grown.length) ? `<div class="s"><b>probe rows added here</b> (+${r.added} functions): ${esc(r.newprobes.concat(r.grown.map(x => x + " (more sets)")).join(", ").slice(0, 160))}</div>` : "") +
      series.map(s => `<div><i style="background:${s.c}"></i>${esc(s.name)}: <b>${opts.fmt ? opts.fmt(s.tv ? s.tv[i] : s.v[i]) : fmt(s.v[i], opts.pct)}</b>${s.raw && s.raw[i] ? ` <span class="s">(${s.raw[i][0]} / ${s.raw[i][1]})</span>` : ""}${s.extra ? ` <span class="s">${s.extra(i)}</span>` : ""}</div>`).join("");
    tip.style.display = "block";
    const px = x(i) * bb.width / W; tip.style.left = (px > bb.width / 2 ? px - tip.offsetWidth - 12 : px + 12) + "px"; tip.style.top = "8px";
  });
  svg.addEventListener("mouseleave", () => { tip.style.display = "none"; cross.setAttribute("visibility", "hidden"); });
  document.getElementById(opts.into || "charts").appendChild(card);
}
function drawAll() { document.getElementById("charts").innerHTML = ""; document.getElementById("cov-charts").innerHTML = ""; document.getElementById("stage-charts").innerHTML = ""; stageCharts(); charts(); covCharts(); }
for (const [id, v] of [["ax-commit", "commit"], ["ax-time", "time"]]) document.getElementById(id).addEventListener("click", () => {
  AXIS = v; try { localStorage.setItem("cc900-axis", v); } catch (e) {}
  document.getElementById("ax-commit").setAttribute("aria-pressed", v === "commit"); document.getElementById("ax-time").setAttribute("aria-pressed", v === "time"); drawAll(); });
document.getElementById("ax-commit").setAttribute("aria-pressed", AXIS === "commit"); document.getElementById("ax-time").setAttribute("aria-pressed", AXIS === "time");
const bySet = (prefix, pct) => SETS.map(s => ({ name: LABEL[s], short: LABEL[s], c: COLOR[s],
  v: R.map(r => val(r, prefix + "/" + s, pct)), raw: R.map(r => r.scores[prefix + "/" + s] || null) }));
function stageCharts() {
  const ST = DATA.stages || [];
  if (!ST.length) { document.getElementById("stage-charts").innerHTML = "<p>No stage measurement recorded yet.</p>"; return; }
  const NAMES = [...new Set(ST.map(r => r.stage))].sort();
  const DESC = {S1: "S1 IR -> -zio, functions", S2: "S2 -zio -> -zim, functions", S3: "S3 named variables' registers", S4: "S4 code, functions"};
  const cur = {};
  const vals = ST.map(r => { cur[r.stage] = r; return Object.assign({}, cur); });
  chart("Stages: share exact", "Each stage's exact share against V4.23's own output, given V4.23's own input. A point is one measurement of one stage; the other lines carry their last value forward. The tooltip gives the counts.",
    NAMES.map((k, j) => ({ name: DESC[k] || k, short: k, c: `var(--series-${(j % 10) + 1})`,
      v: vals.map(m => m[k] ? 100 * m[k].exact / m[k].total : null),
      extra: i => vals[i][k] ? `${vals[i][k].exact} / ${vals[i][k].total} ${vals[i][k].unit}` : "–" })),
    { rows: ST, zero: true, pct: true, fmt: v => v == null ? "–" : v.toFixed(1) + " %", into: "stage-charts", right: 110, good: "▲ progress = lines going up; S4 is the code itself" });
}
stageCharts();
function charts() {
chart("Random programs: exact functions", "Four generated corpora, 800 functions per option set. Phase 3a asks for 95 % (760).", bySet("random", false), { zero: true, target: 760, max: 760, good: "▲ progress = lines going up, to the dashed target (760 of 800)" });
chart("1997 library: exact functions", "Toshiba's own C library sources at -O3 -XS, 248 functions. Phase 3a asks for all of them.",
  [{ name: "-O3 -XS", c: "var(--series-2)", v: R.map(r => val(r, "library/O3XS", false)), raw: R.map(r => r.scores["library/O3XS"] || null) }], { target: 248, max: 248, zero: true, good: "▲ progress = the line going up, to the dashed target (248 of 248)" });
chart("Micro corpus: exact functions", "The hand-written micro tests, 674 functions per option set. Phase 3a asks for all of them at every set.", bySet("micro", false), { target: 674, max: 674, good: "▲ progress = every line at the dashed target (674); any drop is a regression" });
chart("Probes: share of functions exact", "All probe files together. The denominator grows whenever a new probe is added: each dotted vertical line is a round whose ledger gained probe rows, and the tooltip names them. A dip on such a line is the new probe; a dip anywhere else is a regression.", bySet("probes", true), { pct: true, marks: true, good: "▲ progress = lines going up; a drop on a dotted vertical line is a new probe added (hover for its name), any other drop is lost ground" });
chart("Semantic differences from the oracle", "Functions whose model code behaves differently from the oracle's in the checker (all four option sets summed). Lower is better; each remaining one is reviewed.",
  [{ name: "DIFFERENT", c: "var(--series-1)", v: R.map(r => r.semdiff) }], { zero: true, good: "▼ progress = the line going down; a rise is wrong code found and has to come back down" });
chart("Probes: functions covered", "How many probe functions the ledger scores per option set: the size of the evidence base.",
  SETS.map(s => ({ name: LABEL[s], short: LABEL[s], c: COLOR[s], v: R.map(r => r.scores["probes/" + s] ? r.scores["probes/" + s][1] : null) })), { zero: true, marks: true, good: "▲ more evidence, not a score: each step up is a new probe (dotted vertical lines) the model is then measured on" });
chart("Wall-clock time of each round", `Minutes from the round before to this round's commit. A pause between sessions counts as part of the next round, so the plot stops at ${CAP} minutes; the tooltip gives the real time. The second line is the part of each round spent answering the owner's prompts instead of autonomous model work, the third the part the session spent stopped, waiting for a prompt; both from interruptions.tsv (recorded since 2026-11-12 23:10; some intervals are estimates).`,
  [{ name: "round time", short: "round", c: "var(--series-1)", v: GAP.map(g => g == null ? null : Math.min(g, CAP)), tv: GAP },
   { name: "of which on the owner's prompts (dashboard features, questions, tooling asked for)", short: "prompts", c: "var(--series-2)", v: BRK.map(g => g == null ? null : Math.min(g, CAP)), tv: BRK },
   { name: "of which stopped, waiting for a prompt", short: "idle", c: "var(--series-3)", v: IDLE.map(g => g == null ? null : Math.min(g, CAP)), tv: IDLE }],
  { zero: true, cap: CAP, max: CAP, fmt: g => g == null ? "–" : fmtMin(g), good: "▼ progress = shorter rounds; the prompts and idle lines show time that was not model work" });
}
charts();

// ---- ROM bytes built from C (results/c_build_coverage.md over the commits that changed it)
const CV = DATA.coverage || [], TC = ["V4.23", "model", "LLVM"];
const TCNAME = {"V4.23": "Toshiba V4.23", model: "reference model", LLVM: "LLVM backend (-mcc900-compat)"};
const TCCOL = {"V4.23": "var(--series-2)", model: "var(--series-1)", LLVM: "var(--series-3)"};
const pct3 = v => v == null ? "–" : (v > 0 && v < 0.01 ? v.toFixed(4) : v.toFixed(3)) + " %";
function covCharts() {
  const PG = DATA.progress || [];
  if (PG.length) {
    // percentages of ROM size (owner, 2026-11-16): sizes from the newest c_build_coverage.md's per-image table
    const LASTCV = CV.length ? CV[CV.length - 1] : null, SIZE = {};
    if (LASTCV) for (const im of LASTCV.images) SIZE[im[0]] = im[1];
    const ALL = Object.values(SIZE).reduce((a, b) => a + b, 0);
    const P = (b, n) => n ? 100 * b / n : null;
    chart("Firmware C confirmed by Toshiba V4.23, % of all ROM bytes", `Bytes of firmware functions whose C Toshiba V4.23 compiles to exactly the ROM's bytes, as a share of all ${Object.keys(SIZE).length} ROM images' bytes (${ALL} B): built into the images, and confirmed but still staged on the C lanes' branches (results/c_progress.tsv, one point per V4.23 run, even when nothing moved). Library C is not included. The tooltip gives bytes and functions.`,
      [{ name: "built + staged", short: "total", c: "var(--series-2)", v: PG.map(r => P(r.built_b + r.staged_b, ALL)), extra: i => `${PG[i].built_b + PG[i].staged_b} B · ${PG[i].built_fn + PG[i].staged_fn} functions` },
       { name: "built into the images", short: "built", c: "var(--series-1)", v: PG.map(r => P(r.built_b, ALL)), extra: i => `${PG[i].built_b} B · ${PG[i].built_fn} functions` },
       { name: "staged, not yet built", short: "staged", c: "var(--series-3)", v: PG.map(r => P(r.staged_b, ALL)), extra: i => `${PG[i].staged_b} B · ${PG[i].staged_fn} functions` }],
      { rows: PG, zero: true, pct: true, fmt: pct3, into: "cov-charts", right: 110, good: "▲ progress = lines going up; staged moves into built at each merge" });
    const IMG = [...new Set(PG.flatMap(r => Object.keys(r.images || {})).concat(["v10"]))].sort((a, b) => a.localeCompare(b, undefined, {numeric: true}));
    const IMGCOL = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => `var(--series-${i})`);
    chart("Firmware C confirmed by V4.23, % of each ROM", "Built + staged bytes for each ROM image (main-CPU versions, sub-CPU payloads, HD-AE5000) as a share of that image's size. Points before the per-image column existed show v10 only. The tooltip gives bytes and functions.",
      IMG.map((k, j) => ({ name: k, short: k, c: IMGCOL[j % IMGCOL.length],
        v: PG.map(r => { const e = r.images && r.images[k]; const b = e ? e[1] : (k === "v10" ? r.v10_b : null); return b == null ? null : P(b, SIZE[k]); }),
        extra: i => { const e = PG[i].images && PG[i].images[k]; return e ? `${e[1]} B of ${SIZE[k]} B · ${e[0]} functions` : (k === "v10" ? `${PG[i].v10_b} B · ${PG[i].v10_fn} functions` : "–"); } })),
      { rows: PG, zero: true, pct: true, fmt: pct3, into: "cov-charts", right: 110, good: "▲ progress = lines going up; one line per ROM" });
  }
  if (!CV.length) return;
  const ROMB = r => r.images.reduce((a, im) => a + im[1], 0);
  chart("Built from C, % of all ROM bytes", "ROM bytes that C, through each toolchain, gives exactly (firmware C built into the images plus the Toshiba library routines checked in them), as a share of all the images' bytes. The tooltip gives the bytes, split into the two.",
    TC.map(k => ({ name: TCNAME[k], short: k, c: TCCOL[k], v: CV.map(r => ROMB(r) ? 100 * r.tot[k][0] / ROMB(r) : null),
      extra: i => `${CV[i].tot[k][0]} B: firmware ${CV[i].fw[k]} B · library ${CV[i].lib[k]} B` })),
    { rows: CV, zero: true, pct: true, fmt: pct3, into: "cov-charts", right: 130, good: "▲ progress = lines going up; LLVM joins the other two once phase 3b works" });
  chart("Share of the images' code built from C", "Bytes from C that the census calls CODE, as a share of all the images' CODE bytes.",
    TC.map(k => ({ name: TCNAME[k], short: k, c: TCCOL[k], v: CV.map(r => r.code ? 100 * r.tot[k][1] / r.code : null), raw: CV.map(r => [r.tot[k][1], r.code]) })),
    { rows: CV, zero: true, pct: true, into: "cov-charts", right: 130, fmt: pct3, good: "▲ progress = lines going up" });
}
(function () {
  const note = document.getElementById("cov-note");
  if (!CV.length) { document.getElementById("cov-tiles").innerHTML = `<p class="empty">No results/c_build_coverage.md has been committed yet: run <code>make cc900-c-coverage</code> and commit its results.</p>`; return; }
  const last = CV[CV.length - 1], prev = CV.length > 1 ? CV[CV.length - 2] : null;
  const T = [];
  for (const k of TC) {
    const d = prev ? last.tot[k][0] - prev.tot[k][0] : null, cls = d ? (d > 0 ? "up" : "down") : "";
    T.push(`<div class="tile"><div class="k">Bytes from C, ${esc(TCNAME[k])}</div><div class="v">${last.tot[k][0]} B</div><div class="t">${pct3(last.code ? 100 * last.tot[k][1] / last.code : 0)} of all code · firmware ${last.fw[k]} B · library ${last.lib[k]} B</div>` +
      (d == null ? "" : `<div class="d ${cls}">${d > 0 ? "▲ +" : d < 0 ? "▼ " : "■ "}${d} B since the commit before</div>`) + `</div>`);
  }
  T.push(`<div class="tile"><div class="k">Firmware C functions V4.23 has not checked</div><div class="v">${last.unchecked}</div><div class="t">each needs an oracle run of its C (c_build_coverage.py --v423-corpus)</div></div>`);
  document.getElementById("cov-tiles").innerHTML = T.join("");
  covCharts();
  note.innerHTML = `${last.date.slice(0, 16).replace("T", " ")} · ${last.h} · ${esc(last.subject.slice(0, 120))}. Each cell: bytes from C / of them census CODE; the % is of the image's CODE.`;
  let h = "<tr><th>image</th><th>category</th><th>size</th><th>code</th><th>items</th>" + TC.map(k => `<th>${esc(TCNAME[k])}</th><th>%</th>`).join("") + "<th>V4.23 not yet checked</th></tr>";
  for (const [img, size, code, cat, items, v, un] of last.images)
    h += `<tr><td>${esc(img)}</td><td>${esc(cat)}</td><td>${size}</td><td>${code}</td><td>${items}</td>` +
      TC.map(k => `<td>${v[k][0]} / ${v[k][1]}</td><td>${pct3(code ? 100 * v[k][1] / code : 0)}</td>`).join("") + `<td>${un}</td></tr>`;
  document.getElementById("cov-tbl").innerHTML = h;
})();

// ---- table view
(function () {
  const cols = [["random/none", "random none"], ["random/O3XS", "random -O3 -XS"], ["random/Xr", "random -Xr"], ["random/O3XSXr", "random -O3 -XS -Xr"],
    ["library/O3XS", "library"], ["micro/none", "micro none"], ["micro/O3XS", "micro -O3 -XS"], ["micro/Xr", "micro -Xr"], ["micro/O3XSXr", "micro -O3 -XS -Xr"]];
  let h = "<tr><th>commit time</th><th>commit</th>" + cols.map(c => `<th>${c[1]}</th>`).join("") + "<th>probes exact</th><th>sem. diff.</th><th>round time</th><th>on prompts</th><th>idle</th></tr>";
  for (let i = n - 1; i >= 0; i--) { const r = R[i];
    const pe = SETS.reduce((a, s) => a + (r.scores["probes/" + s] ? r.scores["probes/" + s][0] : 0), 0), pt = SETS.reduce((a, s) => a + (r.scores["probes/" + s] ? r.scores["probes/" + s][1] : 0), 0);
    h += `<tr><td>${r.date.slice(0, 16).replace("T", " ")}</td><td class="sj" title="${esc(r.subject)}">${r.h} ${esc(r.subject)}</td>` +
      cols.map(c => `<td>${r.scores[c[0]] ? r.scores[c[0]][0] + " / " + r.scores[c[0]][1] : "–"}</td>`).join("") + `<td>${pt ? pe + " / " + pt : "–"}</td><td>${r.semdiff == null ? "–" : r.semdiff}</td><td>${GAP[i] == null ? "–" : fmtMin(GAP[i])}</td><td>${BRK[i] ? fmtMin(BRK[i]) : "–"}</td><td>${IDLE[i] ? fmtMin(IDLE[i]) : "–"}</td></tr>`; }
  document.getElementById("tbl").innerHTML = h;
})();
</script></body></html>
'''


def interruptions():
    """the intervals of interruptions.tsv (beside this file): [start, end, source, what]"""
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'interruptions.tsv'); out = []
    if os.path.exists(p):
        for line in open(p, encoding='utf-8'):
            f = line.rstrip('\n').split('\t')
            if line.startswith('#') or len(f) < 4: continue
            out.append(f[:4])
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    out = args[0] if args else os.path.expanduser('~/compartilhado/tmp/cc900-dashboard/index.html')
    rows = collect()
    if not rows: sys.exit('no ledger history found')
    import datetime
    cov = collect_coverage()
    page = (PAGE.replace('__DATA__', json.dumps({'rows': rows, 'breaks': interruptions(), 'coverage': cov, 'progress': collect_progress(),
                                              'stages': collect_stages()}))
            .replace('__FLAT__', str(sum(1 for r in rows if not r['moved'])))
            .replace('__N__', str(len(rows))).replace('__FIRST__', rows[0]['date'][:10]).replace('__LAST__', rows[-1]['date'][:10])
            .replace('__NOW__', datetime.datetime.now().strftime('%Y-%m-%d %H:%M')))
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    open(out, 'w', encoding='utf-8').write(page)
    last = rows[-1]['scores']
    print('%s: %d commits; latest random/none %s, library/O3XS %s, micro/none %s' % (
        out, len(rows), last.get('random/none'), last.get('library/O3XS'), last.get('micro/none')))
    if cov:
        print('C build coverage: %d commits; latest bytes from C: %s' % (
            len(cov), ', '.join('%s %d' % (k, cov[-1]['tot'][k][0]) for k in TOOLCHAINS)))
    if '--serve' in sys.argv:
        import http.server, functools
        d = os.path.dirname(os.path.abspath(out))
        handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=d)
        print('serving http://localhost:8765/%s  (Ctrl-C to stop)' % os.path.basename(out))
        http.server.ThreadingHTTPServer(('127.0.0.1', 8765), handler).serve_forever()


if __name__ == '__main__': main()
