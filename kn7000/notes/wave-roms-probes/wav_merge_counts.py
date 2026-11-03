#!/usr/bin/env python3
"""wav_merge_counts.py -- QUESTION: what did merging the KN7000 WAV files into one per recording, and trimming
each to its recording's end, change, and did any sample change?  (wave-roms-2026-10-29.md, "Recording lines";
the owner's decision of 2026-11-03; lane wav-merge)

BEFORE is a git revision (default 1c5221133, the base of the lane: one WAV per directory start, each from its
start to the next start).  AFTER is the working tree (kn7000/wav/{main,sub}/, kn7000/src/wave/*_wav.tsv), or
another revision with --after.  Per tone generator it prints:
  - the WAV files and their total bytes, before and after;
  - merged:  recordings whose WAV now carries cue points, and the alternate-start WAV files that went
             (each must be a cue label of the recording that absorbed it);
  - trimmed: recordings whose WAV now ends before the end of its last piece before, split by what went
             (the 32-sample run-out, zero words, both) and the sample-data bytes removed;
  - samples: recordings whose data chunk equals the concatenation of the old pieces' data chunks, cut to the
             new length (signal: all of them), and whose removed tail is the run-out plus zeros only;
  - points:  every smpl loop (end inclusive) and every cue read from the new files lies inside the data;
  - with --ffprobe, how many files ffprobe opens with a positive duration.
No ROM image is read: everything comes from the committed WAVs and manifests.

RUN (from the repo root or anywhere inside it):
    python3 -I kn7000/notes/wave-roms-probes/wav_merge_counts.py [--before REV] [--after REV] [--ffprobe]
"""
import argparse
import os
import shutil
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"],
                                    cwd=os.path.dirname(os.path.abspath(__file__)), text=True).strip())


class Git:
    """read files of a revision through one `git cat-file --batch`"""
    def __init__(self, rev):
        self.rev = rev
        self.p = subprocess.Popen(["git", "cat-file", "--batch"], cwd=ROOT, stdin=subprocess.PIPE,
                                  stdout=subprocess.PIPE)

    def read(self, path):
        self.p.stdin.write(f"{self.rev}:{path}\n".encode())
        self.p.stdin.flush()
        head = self.p.stdout.readline().split()
        if head[1] == b"missing":
            raise FileNotFoundError(path)
        n = int(head[2])
        data = self.p.stdout.read(n)
        self.p.stdout.read(1)
        return data

    def ls(self, path):
        out = subprocess.check_output(["git", "ls-tree", "-r", "-l", self.rev, path], cwd=ROOT, text=True)
        return {l.split("\t")[1]: int(l.split()[3]) for l in out.splitlines()}


class Tree:
    def read(self, path):
        return (ROOT / path).read_bytes()

    def ls(self, path):
        return {str(p.relative_to(ROOT)): p.stat().st_size for p in sorted((ROOT / path).glob("*")) if p.is_file()}


def manifest(src, tg):
    lines = src.read(f"kn7000/src/wave/{tg}_wav.tsv").decode("utf-8").splitlines()
    head = lines[0].split("\t")
    return [dict(zip(head, l.split("\t"))) for l in lines[1:] if l.strip()]


def chunks(blob):
    pos, out = 12, {}
    while pos + 8 <= len(blob):
        tag, size = blob[pos:pos + 4], struct.unpack_from("<I", blob, pos + 4)[0]
        out.setdefault(tag, []).append(blob[pos + 8: pos + 8 + size])
        pos += 8 + size + (size & 1)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--before", default="1c5221133")
    ap.add_argument("--after", default=None)
    ap.add_argument("--ffprobe", action="store_true")
    o = ap.parse_args()
    old = Git(o.before)
    new = Git(o.after) if o.after else Tree()
    tot = {"before": [0, 0], "after": [0, 0]}
    for tg in ("main", "sub"):
        d = f"kn7000/wav/{tg}"
        lo, ln = old.ls(d), new.ls(d)
        mo, mn = manifest(old, tg), manifest(new, tg)
        byo = {r["label"]: r for r in mo}
        old_starts = sorted((int(r["start"], 0), r["label"]) for r in mo)
        merged = alt = trimmed = same = clean_tail = bad_points = 0
        kinds = {"run-out only": 0, "zero words only": 0, "run-out and zero words": 0}
        removed = 0
        cue_labels = set()
        for r in mn:
            a, e = int(r["start"], 0), int(r["end"], 0)
            pieces = [lab for st, lab in old_starts if a <= st < e]
            if pieces[0] != r["label"]:
                raise SystemExit(f"{r['label']}: its first old piece is {pieces[0]}")
            cues = [] if r.get("cues", "-") in ("", "-") else [c.split(":", 2)[1] for c in r["cues"].split("|")]
            if cues:
                merged += 1
                alt += len(cues)
                cue_labels |= set(cues)
                if cues != pieces[1:]:
                    raise SystemExit(f"{r['label']}: cues {cues} != old pieces {pieces[1:]}")
            old_end = int(byo[pieces[-1]]["end"], 0)
            blob = new.read(f"{d}/{r['wav']}")
            ch = chunks(blob)
            data = ch[b"data"][0]
            olddata = b"".join(chunks(old.read(f"{d}/{byo[x]['wav']}"))[b"data"][0] for x in pieces)
            same += olddata[:len(data)] == data
            if e < old_end:
                trimmed += 1
                removed += old_end - e
                tail = olddata[len(data):]
                bits = int(r["bits"])
                ro = 64 if bits == 16 else 32
                zeros = tail[ro:] if "ends at its loop end" in r["comment"] else tail
                runout = "ends at its loop end" in r["comment"]
                z = bits == 16 and not any(zeros) or bits == 8 and all(b == 0x80 for b in zeros)
                clean_tail += z
                kinds["run-out and zero words" if runout and len(tail) > ro else
                      "run-out only" if runout else "zero words only"] += 1
            # the points, read from the file itself
            n = len(data) * 8 // int(r["bits"])
            ok = True
            for sm in ch.get(b"smpl", []):
                for k in range(struct.unpack_from("<I", sm, 28)[0]):
                    _, _, s0, e0, _, _ = struct.unpack_from("<6I", sm, 36 + 24 * k)
                    ok &= 0 <= s0 <= e0 < n
            for cu in ch.get(b"cue ", []):
                for k in range(struct.unpack_from("<I", cu, 0)[0]):
                    ok &= struct.unpack_from("<6I", cu, 4 + 24 * k)[5] < n
            bad_points += not ok
        gone = sorted(set(byo) - {r["label"] for r in mn})
        print(f"{tg}:")
        print(f"  WAV files              before {len(lo):5d} ({sum(lo.values()):,} B)   after {len(ln):5d} "
              f"({sum(ln.values()):,} B)")
        print(f"  manifest rows          before {len(mo):5d}   after {len(mn):5d}")
        print(f"  merged                 {merged} recordings now carry {alt} cue points; {len(gone)} alternate-start "
              f"WAV files went, {len(set(gone) - cue_labels)} of them not a cue label (must be 0)")
        print(f"  trimmed                {trimmed} recordings, {removed:,} bytes of samples removed: "
              + ", ".join(f"{k} {v}" for k, v in kinds.items()))
        print(f"  samples                {same} of {len(mn)} data chunks equal the old pieces' samples; "
              f"{clean_tail} of {trimmed} removed tails are the run-out plus zero words only")
        print(f"  points                 {len(mn) - bad_points} of {len(mn)} files have every loop and cue inside "
              f"their data")
        if o.ffprobe and shutil.which("ffprobe"):
            okf = 0
            for r in mn:
                p = ROOT / d / r["wav"] if not o.after else None
                if p is None:
                    break
                out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of",
                                      "default=nw=1:nk=1", str(p)], capture_output=True, text=True)
                try:
                    okf += out.returncode == 0 and not out.stderr and float(out.stdout) > 0
                except ValueError:
                    pass
            print(f"  ffprobe                {okf} of {len(mn)} files open with a positive duration")
        tot["before"][0] += len(lo); tot["before"][1] += sum(lo.values())
        tot["after"][0] += len(ln); tot["after"][1] += sum(ln.values())
    print(f"all: WAV files before {tot['before'][0]} ({tot['before'][1]:,} B), after {tot['after'][0]} "
          f"({tot['after'][1]:,} B)")


if __name__ == "__main__":
    sys.exit(main())
