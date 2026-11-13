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
        elif corpus.startswith('probes/'): add('probes/' + st, e, t)
        elif corpus == '1997 LIB/SRC': add('library/' + st, e, t)
    return {k: tuple(v) for k, v in acc.items()}


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
        row = {'h': h[:9], 'date': d, 'subject': s, 'scores': sc, 'semdiff': sum(sm.values()) if sm else None}
        row['moved'] = prev is None or prev['scores'] != sc or prev['semdiff'] != row['semdiff']
        rows.append(row)
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
  --good: #1a7f37; --serious: #b3261e; }
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { color-scheme: dark;
  --page: #121211; --surface-1: #1a1a19; --border: #33322f; --grid: #2a2927;
  --text-primary: #f0efec; --text-secondary: #c3c2b7; --text-muted: #8f8e86;
  --series-1: #3987e5; --series-2: #d95926; --series-3: #199e70; --series-4: #c98500;
  --good: #4cc26b; --serious: #f2867e; } }
:root[data-theme="dark"] { color-scheme: dark;
  --page: #121211; --surface-1: #1a1a19; --border: #33322f; --grid: #2a2927;
  --text-primary: #f0efec; --text-secondary: #c3c2b7; --text-muted: #8f8e86;
  --series-1: #3987e5; --series-2: #d95926; --series-3: #199e70; --series-4: #c98500;
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
<div class="grid" id="charts"></div>
<details><summary>Table view (every commit, newest first)</summary><div class="scroll"><table id="tbl"></table></div></details>
</main>
<script>
const DATA = __DATA__;
const SETS = ["none","O3XS","Xr","O3XSXr"], LABEL = {none:"no options", O3XS:"-O3 -XS", Xr:"-Xr", O3XSXr:"-O3 -XS -Xr"};
const COLOR = {none:"var(--series-1)", O3XS:"var(--series-2)", Xr:"var(--series-3)", O3XSXr:"var(--series-4)"};
const R = DATA.rows, n = R.length;
let AXIS = "commit"; try { AXIS = localStorage.getItem("cc900-axis") || "commit"; } catch (e) {}
const T0 = new Date(R[0].date).getTime(), T1 = new Date(R[n - 1].date).getTime();
const frac = i => n === 1 ? 0.5 : AXIS === "time" && T1 > T0 ? (new Date(R[i].date).getTime() - T0) / (T1 - T0) : i / (n - 1);
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
  const W = 560, H = 250, L = 44, Rm = 96, Tp = 10, B = 26, pw = W - L - Rm, ph = H - Tp - B;
  const card = document.createElement("div"); card.className = "card";
  let lo = Infinity, hi = -Infinity;
  for (const s of series) for (const v of s.v) if (v != null) { lo = Math.min(lo, v); hi = Math.max(hi, v); }
  if (opts.zero) lo = 0; if (opts.max != null) hi = Math.max(hi, opts.max);
  const pad = (hi - lo) * 0.06 || 1; if (!opts.zero) lo = Math.max(0, lo - pad); hi = hi + pad;
  const x = i => L + pw * frac(i), y = v => Tp + ph * (1 - (v - lo) / (hi - lo));
  const step = (() => { const raw = (hi - lo) / 4, p = Math.pow(10, Math.floor(Math.log10(raw))); return [1, 2, 5, 10].map(m => m * p).find(m => m >= raw); })();
  let g = "";
  for (let t = Math.ceil(lo / step) * step; t <= hi; t += step)
    g += `<line x1="${L}" x2="${L + pw}" y1="${y(t)}" y2="${y(t)}" stroke="var(--grid)"/><text x="${L - 6}" y="${y(t) + 4}" text-anchor="end">${opts.pct ? t.toFixed(0) + " %" : opts.cap != null && t >= opts.cap ? "≥ " + t : t}</text>`;
  let lastDay = "", lastX = -99;
  R.forEach((r, i) => { const d = r.date.slice(5, 10); if (d !== lastDay) { lastDay = d;
    if (x(i) - lastX > 28) { g += `<line x1="${x(i)}" x2="${x(i)}" y1="${Tp + ph}" y2="${Tp + ph + 4}" stroke="var(--border)"/><text x="${x(i)}" y="${H - 6}" text-anchor="middle">${d}</text>`; lastX = x(i); } } });
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
  card.innerHTML = `<h2>${title}</h2><p>${note}</p>${legend}<div class="plot"><svg viewBox="0 0 ${W} ${H}" role="img" aria-label="${title}">${g}
    <line class="cross" x1="0" x2="0" y1="${Tp}" y2="${Tp + ph}" stroke="var(--text-muted)" stroke-width="1" visibility="hidden"/>
    <rect x="${L}" y="${Tp}" width="${pw}" height="${ph}" fill="transparent"/></svg><div class="tip"></div></div>`;
  const svg = card.querySelector("svg"), tip = card.querySelector(".tip"), cross = card.querySelector(".cross"), plot = card.querySelector(".plot");
  svg.addEventListener("mousemove", ev => {
    const bb = svg.getBoundingClientRect(), sx = (ev.clientX - bb.left) * W / bb.width;
    let i = 0, best = 1e9; for (let k = 0; k < n; k++) { const dd = Math.abs(x(k) - sx); if (dd < best) { best = dd; i = k; } }
    const r = R[i];
    cross.setAttribute("x1", x(i)); cross.setAttribute("x2", x(i)); cross.setAttribute("visibility", "visible");
    tip.innerHTML = `<div class="s">${r.date.slice(0, 16).replace("T", " ")} · ${r.h}${r.moved ? "" : " · no score changed"}<br>${esc(r.subject.slice(0, 110))}</div>` +
      series.map(s => `<div><i style="background:${s.c}"></i>${esc(s.name)}: <b>${opts.fmt ? opts.fmt(s.tv ? s.tv[i] : s.v[i]) : fmt(s.v[i], opts.pct)}</b>${s.raw && s.raw[i] ? ` <span class="s">(${s.raw[i][0]} / ${s.raw[i][1]})</span>` : ""}</div>`).join("");
    tip.style.display = "block";
    const px = x(i) * bb.width / W; tip.style.left = (px > bb.width / 2 ? px - tip.offsetWidth - 12 : px + 12) + "px"; tip.style.top = "8px";
  });
  svg.addEventListener("mouseleave", () => { tip.style.display = "none"; cross.setAttribute("visibility", "hidden"); });
  document.getElementById("charts").appendChild(card);
}
function drawAll() { document.getElementById("charts").innerHTML = ""; charts(); }
for (const [id, v] of [["ax-commit", "commit"], ["ax-time", "time"]]) document.getElementById(id).addEventListener("click", () => {
  AXIS = v; try { localStorage.setItem("cc900-axis", v); } catch (e) {}
  document.getElementById("ax-commit").setAttribute("aria-pressed", v === "commit"); document.getElementById("ax-time").setAttribute("aria-pressed", v === "time"); drawAll(); });
document.getElementById("ax-commit").setAttribute("aria-pressed", AXIS === "commit"); document.getElementById("ax-time").setAttribute("aria-pressed", AXIS === "time");
const bySet = (prefix, pct) => SETS.map(s => ({ name: LABEL[s], short: LABEL[s], c: COLOR[s],
  v: R.map(r => val(r, prefix + "/" + s, pct)), raw: R.map(r => r.scores[prefix + "/" + s] || null) }));
function charts() {
chart("Random programs: exact functions", "Four generated corpora, 800 functions per option set. Phase 3a asks for 95 % (760).", bySet("random", false), { zero: true, target: 760, max: 760 });
chart("1997 library: exact functions", "Toshiba's own C library sources at -O3 -XS, 248 functions. Phase 3a asks for all of them.",
  [{ name: "-O3 -XS", c: "var(--series-2)", v: R.map(r => val(r, "library/O3XS", false)), raw: R.map(r => r.scores["library/O3XS"] || null) }], { target: 248, max: 248, zero: true });
chart("Micro corpus: exact functions", "The hand-written micro tests, 674 functions per option set. Phase 3a asks for all of them at every set.", bySet("micro", false), { target: 674, max: 674 });
chart("Probes: share of functions exact", "All probe files together. The denominator grows whenever a new probe is added, so a dip usually means a new probe, not a regression.", bySet("probes", true), { pct: true });
chart("Semantic differences from the oracle", "Functions whose model code behaves differently from the oracle's in the checker (all four option sets summed). Lower is better; each remaining one is reviewed.",
  [{ name: "DIFFERENT", c: "var(--series-1)", v: R.map(r => r.semdiff) }], { zero: true });
chart("Probes: functions covered", "How many probe functions the ledger scores per option set: the size of the evidence base.",
  SETS.map(s => ({ name: LABEL[s], short: LABEL[s], c: COLOR[s], v: R.map(r => r.scores["probes/" + s] ? r.scores["probes/" + s][1] : null) })), { zero: true });
chart("Wall-clock time of each round", `Minutes from the round before to this round's commit. A pause between sessions counts as part of the next round, so the plot stops at ${CAP} minutes; the tooltip gives the real time. The second line is the part of each round spent answering the owner's prompts instead of autonomous model work, the third the part the session spent stopped, waiting for a prompt; both from interruptions.tsv (recorded since 2026-11-12 23:10; some intervals are estimates).`,
  [{ name: "round time", short: "round", c: "var(--series-1)", v: GAP.map(g => g == null ? null : Math.min(g, CAP)), tv: GAP },
   { name: "of which on the owner's prompts (dashboard features, questions, tooling asked for)", short: "prompts", c: "var(--series-2)", v: BRK.map(g => g == null ? null : Math.min(g, CAP)), tv: BRK },
   { name: "of which stopped, waiting for a prompt", short: "idle", c: "var(--series-3)", v: IDLE.map(g => g == null ? null : Math.min(g, CAP)), tv: IDLE }],
  { zero: true, cap: CAP, max: CAP, fmt: g => g == null ? "–" : fmtMin(g) });
}
charts();

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
    page = (PAGE.replace('__DATA__', json.dumps({'rows': rows, 'breaks': interruptions()}))
            .replace('__FLAT__', str(sum(1 for r in rows if not r['moved'])))
            .replace('__N__', str(len(rows))).replace('__FIRST__', rows[0]['date'][:10]).replace('__LAST__', rows[-1]['date'][:10])
            .replace('__NOW__', datetime.datetime.now().strftime('%Y-%m-%d %H:%M')))
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    open(out, 'w', encoding='utf-8').write(page)
    last = rows[-1]['scores']
    print('%s: %d commits; latest random/none %s, library/O3XS %s, micro/none %s' % (
        out, len(rows), last.get('random/none'), last.get('library/O3XS'), last.get('micro/none')))
    if '--serve' in sys.argv:
        import http.server, functools
        d = os.path.dirname(os.path.abspath(out))
        handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=d)
        print('serving http://localhost:8765/%s  (Ctrl-C to stop)' % os.path.basename(out))
        http.server.ThreadingHTTPServer(('127.0.0.1', 8765), handler).serve_forever()


if __name__ == '__main__': main()
