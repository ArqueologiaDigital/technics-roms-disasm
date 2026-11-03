#!/usr/bin/env python3
"""pcm_wav.py -- wave-ROM recordings <-> standalone WAV files, ROUND TRIP.

QUESTION ANSWERED: can every PCM recording of the wave ROMs be a file that an ordinary sound program
opens and plays, and still be the input the ROM is rebuilt from, byte for byte?

The owner's request (2026-10-30): "I want these to be represented as standalone files that could be
opened by the user on normal media viewers / sound apps.  Then included in the source listing (maybe
with a lossless conversion step if necessary)."  And on 2026-10-31: "Images and wav files must be
commited and the conversion must happen as a build step."  So the WAVs ARE committed (waveform/wav/,
kn7000/wav/{main,sub}/) and they are the build's input: `build` turns them into the raw items, a
git-ignored build product, and never reads the reference image.  `extract` is the maintenance step that
writes the WAVs from a reference image (the trees' `waveform-wav` / `wave-wav` targets); a build does not
run it.

    pcm_wav.py extract MANIFEST REF WAVDIR [--missing]   reference -> WAVs (--missing: only absent ones)
    pcm_wav.py build   MANIFEST WAVDIR PCMDIR            WAVs -> the raw items the source .incbin's
    pcm_wav.py verify  MANIFEST REF                      assert REF -> WAV -> raw == REF, in memory
    pcm_wav.py retag   MANIFEST WAVDIR                   rewrite each WAV's header chunks (rate, smpl, INFO)
                                                         from the manifest, keeping its samples exactly

THE MANIFEST is a committed TSV, one row per recording, written by the tree's generator
(kn7000/tools/gen_wave_s.py; scripts/generators/gen_ic307_wav_manifest.py).  It holds no sample
data, only where each recording is and how it is encoded:

    label   the source label; the raw item is PCMDIR/<label>.pcm
    start   byte offset of the recording in REF; end = one past its last byte
    bits    16: one signed 16-bit little-endian sample per word; 8: two signed 8-bit samples per word,
            low byte first (the evidence is the tree's notes; notes/media-files-2026-10-30/README.md)
    rate    the WAV header's sample rate (nominal: the notes say what it is known to be)
    wav     the WAV's file name in WAVDIR (the label, plus the instrument where it is known)
    unity   smpl chunk MIDI unity note as a decimal note number (40.7656 = note 40 + 0.7656 semitone), or `-`
    loops   smpl chunk loops `id:start:end,...` in samples, end inclusive, or `-`
    comment the WAV's LIST/INFO ICMT text
    cues    (optional column) cue points `pos:label:text|pos:label:text...`, pos in samples from the WAV's
            first sample: a `cue ` chunk, and a LIST/adtl chunk with each cue's `labl` (the label) and
            `note` (the text).  The KN7000 manifests use it for the ALTERNATE STARTS: a second directory
            entry into one recording, which the source reads as a slice of that recording's raw item
            (kn7000/notes/wave-roms-2026-10-29.md, "Where a recording ends"); `-` or absent = none

A loop or a cue that does not lie inside the recording is an error (in `extract`, `build`, `verify` and
`retag` alike), so a manifest whose loop points disagree with its lengths cannot produce a WAV.

THE MAPPING IS EXACT BOTH WAYS.
    16-bit: the WAV `data` chunk IS the ROM bytes (WAV 16-bit PCM is signed little-endian).
    8-bit:  WAV 8-bit PCM is unsigned, so each byte is the ROM's signed byte XOR 0x80
            (s8 v -> u8 v + 128), an involution.
`build` refuses a WAV that is not mono PCM of the manifest's bit depth or whose length is not the
recording's: the page layout fixes where every recording starts, so an edited WAV must keep its size.
Other chunks (LIST, smpl, cue, anything an editor adds) are ignored by `build`.
"""
import argparse
import math
import struct
import sys
from pathlib import Path


class WavError(Exception):
    pass


def read_manifest(path):
    rows = []
    with open(path, encoding="utf-8") as f:
        head = f.readline().rstrip("\n").split("\t")
        for line in f:
            if not line.strip() or line.startswith("#"):
                continue
            r = dict(zip(head, line.rstrip("\n").split("\t")))
            r["start"], r["end"] = int(r["start"], 0), int(r["end"], 0)
            r["bits"], r["rate"] = int(r["bits"]), int(r["rate"])
            rows.append(r)
    return rows


def rom_to_wavdata(raw, bits):
    return raw if bits == 16 else bytes(b ^ 0x80 for b in raw)


def wavdata_to_rom(data, bits):
    return data if bits == 16 else bytes(b ^ 0x80 for b in data)


def chunk(tag, body):
    return tag + struct.pack("<I", len(body)) + body + (b"\0" if len(body) & 1 else b"")


def info_text(s):
    b = s.encode("latin-1", "replace") + b"\0"
    return b


def parse_loops(row):
    """[(id, start, end)] of a manifest row's `loops` column, in samples, end inclusive"""
    if row.get("loops", "-") in ("", "-"):
        return []
    return [tuple(int(x) for x in l.split(":")) for l in row["loops"].split(",")]


def parse_cues(row):
    """[(pos, label, text)] of a manifest row's `cues` column; [] for `-` or a manifest without it"""
    c = row.get("cues", "-")
    if c in ("", "-"):
        return []
    out = []
    for item in c.split("|"):
        pos, label, text = item.split(":", 2)
        out.append((int(pos), label, text))
    return out


def check_points(row, nsamp, loops, cues):
    """every smpl loop (end inclusive) and every cue lies inside the recording's nsamp samples"""
    for ident, s, e in loops:
        if not 0 <= s <= e < nsamp:
            raise WavError(f"{row['label']}: loop {ident} {s}..{e} does not lie inside its {nsamp} samples")
    for pos, label, _ in cues:
        if not 0 <= pos < nsamp:
            raise WavError(f"{row['label']}: cue {label} at sample {pos} does not lie inside its {nsamp} samples")


def make_wav(raw, row):
    bits, rate = row["bits"], row["rate"]
    ba = bits // 8
    fmt = struct.pack("<HHIIHH", 1, 1, rate, rate * ba, ba, bits)
    info = b"INFO" + chunk(b"INAM", info_text(row["label"]))
    if row.get("comment"):
        info += chunk(b"ICMT", info_text(row["comment"]))
    info += chunk(b"ISFT", info_text("technics-roms-disasm scripts/build/pcm_wav.py"))
    body = chunk(b"fmt ", fmt) + chunk(b"LIST", info) + chunk(b"data", rom_to_wavdata(raw, bits))
    loops = parse_loops(row)
    cues = parse_cues(row)
    check_points(row, len(raw) // ba, loops, cues)
    unity = row.get("unity", "-")
    if loops or unity not in ("", "-"):
        note, frac = 60, 0
        if unity not in ("", "-"):
            u = float(unity)
            note = int(math.floor(u))
            if not 0 <= note < 128:
                raise WavError(f"{row['label']}: unity note {u} is not a MIDI note")
            frac = min(int(round((u - note) * 2 ** 32)), 2 ** 32 - 1)
        smpl = struct.pack("<9I", 0, 0, round(1e9 / rate), note, frac, 0, 0, len(loops), 0)
        for ident, s, e in loops:
            smpl += struct.pack("<6I", ident, 0, s, e, 0, 0)
        body += chunk(b"smpl", smpl)
    if cues:
        cue = struct.pack("<I", len(cues))
        adtl = b"adtl"
        for ident, (pos, label, text) in enumerate(cues, 1):
            cue += struct.pack("<II4sIII", ident, pos, b"data", 0, 0, pos)
            adtl += chunk(b"labl", struct.pack("<I", ident) + info_text(label))
            if text:
                adtl += chunk(b"note", struct.pack("<I", ident) + info_text(text))
        body += chunk(b"cue ", cue) + chunk(b"LIST", adtl)
    return b"RIFF" + struct.pack("<I", 4 + len(body)) + b"WAVE" + body


def parse_wav(blob, name):
    """(channels, rate, bits, data) of a PCM WAV; every other chunk is skipped"""
    if blob[:4] != b"RIFF" or blob[8:12] != b"WAVE":
        raise WavError(f"{name}: not a RIFF WAVE file")
    pos, fmt, data = 12, None, None
    while pos + 8 <= len(blob):
        tag, size = blob[pos:pos + 4], struct.unpack_from("<I", blob, pos + 4)[0]
        body = blob[pos + 8:pos + 8 + size]
        if tag == b"fmt ":
            fmt = struct.unpack_from("<HHIIHH", body)
        elif tag == b"data":
            data = body
        pos += 8 + size + (size & 1)
    if fmt is None or data is None:
        raise WavError(f"{name}: no fmt or data chunk")
    tagfmt, ch, rate, _, _, bits = fmt
    if tagfmt != 1:
        raise WavError(f"{name}: format tag {tagfmt}, expected 1 (integer PCM)")
    return ch, rate, bits, data


def wav_to_rom(blob, row, name):
    ch, rate, bits, data = parse_wav(blob, name)
    if ch != 1:
        raise WavError(f"{name}: {ch} channels, expected mono")
    if bits != row["bits"]:
        raise WavError(f"{name}: {bits}-bit, but {row['label']} is stored as {row['bits']}-bit samples")
    n = row["end"] - row["start"]
    if len(data) != n:
        raise WavError(f"{name}: {len(data)} data bytes, but {row['label']} occupies {n} bytes of the ROM "
                       f"(the next recording starts there; keep the length)")
    check_points(row, n * 8 // bits, parse_loops(row), parse_cues(row))
    return wavdata_to_rom(data, bits)


def extract(manifest, ref, wavdir, missing=False):
    rows = read_manifest(manifest)
    img = Path(ref).read_bytes()
    wavdir = Path(wavdir)
    wavdir.mkdir(parents=True, exist_ok=True)
    n = 0
    for r in rows:
        out = wavdir / r["wav"]
        if missing and out.exists():
            continue
        tmp = out.with_suffix(".wav.tmp")
        tmp.write_bytes(make_wav(img[r["start"]:r["end"]], r))
        tmp.replace(out)
        n += 1
    print(f"pcm_wav.py: wrote {n} WAV file(s) into {wavdir} ({len(rows)} in {manifest})")


def build(manifest, wavdir, pcmdir):
    """WAVs -> raw items; reads only the manifest and the (committed) WAVs, never a reference image"""
    rows = read_manifest(manifest)
    wavdir, pcmdir = Path(wavdir), Path(pcmdir)
    absent = [r for r in rows if not (wavdir / r["wav"]).exists()]
    if absent:
        raise WavError(f"{len(absent)} WAV file(s) missing from {wavdir}, e.g. {absent[0]['wav']}; they are "
                       f"committed: `git checkout -- {wavdir}` restores them (the tree's `*-wav` make target "
                       f"re-extracts them from a reference image)")
    pcmdir.mkdir(parents=True, exist_ok=True)
    total = 0
    for r in rows:
        p = wavdir / r["wav"]
        raw = wav_to_rom(p.read_bytes(), r, str(p))
        (pcmdir / (r["label"] + ".pcm")).write_bytes(raw)
        total += len(raw)
    print(f"pcm_wav.py: {len(rows)} WAV file(s) from {wavdir} -> {pcmdir} ({total:,} bytes of samples)")


def retag(manifest, wavdir):
    """WAVs -> the same WAVs with the manifest's header metadata; the samples (the build's input) stay as
    they are, and each rewritten file is checked to give back the same raw item"""
    rows = read_manifest(manifest)
    wavdir = Path(wavdir)
    n = 0
    for r in rows:
        p = wavdir / r["wav"]
        old = p.read_bytes()
        raw = wav_to_rom(old, r, str(p))
        new = make_wav(raw, r)
        if wav_to_rom(new, r, str(p)) != raw:
            raise WavError(f"{p}: retag would change the samples")
        if new != old:
            tmp = p.with_suffix(".wav.tmp")
            tmp.write_bytes(new)
            tmp.replace(p)
            n += 1
    print(f"pcm_wav.py retag: {n} of {len(rows)} WAV file(s) in {wavdir} rewritten, samples unchanged")


def verify(manifest, ref):
    rows = read_manifest(manifest)
    img = Path(ref).read_bytes()
    bad = 0
    for r in rows:
        raw = img[r["start"]:r["end"]]
        if wav_to_rom(make_wav(raw, r), r, r["wav"]) != raw:
            bad += 1
            print(f"FAIL  {r['label']}: the WAV round trip changes the bytes")
    print(f"pcm_wav.py verify: {len(rows) - bad} of {len(rows)} recordings round-trip exactly")
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("extract"); a.add_argument("manifest"); a.add_argument("ref"); a.add_argument("wavdir")
    a.add_argument("--missing", action="store_true")
    b = sub.add_parser("build"); b.add_argument("manifest"); b.add_argument("wavdir"); b.add_argument("pcmdir")
    v = sub.add_parser("verify"); v.add_argument("manifest"); v.add_argument("ref")
    t = sub.add_parser("retag"); t.add_argument("manifest"); t.add_argument("wavdir")
    o = ap.parse_args()
    try:
        if o.cmd == "extract":
            extract(o.manifest, o.ref, o.wavdir, o.missing)
        elif o.cmd == "build":
            build(o.manifest, o.wavdir, o.pcmdir)
        elif o.cmd == "retag":
            retag(o.manifest, o.wavdir)
        else:
            return verify(o.manifest, o.ref)
    except WavError as e:
        sys.exit(f"pcm_wav.py: {e}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
