#!/usr/bin/env python3
"""respell_ic307_pcm_as_wav.py -- point IC307's PCM items at their WAV files instead of the reference image.

QUESTION ANSWERED: none; a one-shot source edit (lane media-files, 2026-10-30), kept so the edit can be
reviewed and re-run.  It is idempotent.

Before:  P0_W0001_PercOrgan:	.incbin	"kn5000_waveform_rom.ic307", 0x001c30, 2816	; census: opaque -- pcm: ...
After:   P0_W0001_PercOrgan:	.incbin	"pcm/P0_W0001_PercOrgan.pcm", 0, 2816	; census: generated -- scripts/build/pcm_wav.py, from waveform/wav/P0_W0001_PercOrgan.wav (16-bit)

The raw item waveform/build/pcm/<label>.pcm is what scripts/build/pcm_wav.py makes from the WAV, and the
Makefile passes `-I waveform/build`.  It also rewrites the "; wave N: S samples" comment above each item
to the sample count of the item's format, and the PCM section header of each page.  The offsets it
drops are kept in waveform/wav_manifest.tsv (scripts/generators/gen_ic307_wav_manifest.py), which it
reads to check every item against them.  Files are read and written as bytes.

    python3 scripts/converters/respell_ic307_pcm_as_wav.py
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OLD = re.compile(rb'^(\w+):(\s*)\.incbin(\s+)"kn5000_waveform_rom\.ic307",\s*(0x[0-9a-f]+),\s*(\d+)\s*;.*$')
WAVE = re.compile(rb'^; wave (\d+): ([0-9,]+) (?:16-bit |8-bit )?samples \(([0-9,]+) B\)(.*)$')
HEAD_OLD = b"; ---- PCM: signed 16-bit little-endian samples, one item per distinct wave start ----"
HEAD_NEW = (b"; ---- PCM: one item per distinct wave start, each from its WAV file waveform/wav/<label>.wav ----\n"
            b"; scripts/build/pcm_wav.py turns the WAV back into the raw item build/pcm/<label>.pcm (make\n"
            b"; waveform-wav extracts the WAVs from the git-ignored reference image).  IC307 is the Y chip of a\n"
            b"; word-interleaved pair, so an item is every other word of a recording: signed 16-bit little-endian\n"
            b"; samples, or two signed 8-bit samples per word, low byte first (notes/media-files-2026-10-30).")


def main():
    man = {}
    for line in (ROOT / "waveform/wav_manifest.tsv").read_text(encoding="utf-8").splitlines()[1:]:
        f = line.split("\t")
        man[f[0]] = (int(f[1], 0), int(f[2], 0), int(f[3]), f[5])
    n = 0
    for p in range(4):
        path = ROOT / f"waveform/ic307_page{p}.s"
        lines = path.read_bytes().split(b"\n")
        out = []
        for line in lines:
            m = OLD.match(line)
            if m:
                lab = m.group(1).decode()
                start, end, bits, wav = man[lab]
                if (int(m.group(4), 16), int(m.group(5))) != (start, end - start):
                    raise SystemExit(f"{path}: {lab} is not at {start:#x}+{end - start} as the manifest says")
                # the comment above: the sample count in this item's format
                for k in range(len(out) - 1, max(len(out) - 6, -1), -1):
                    w = WAVE.match(out[k])
                    if w:
                        nb = int(w.group(3).replace(b",", b""))
                        ns = nb // 2 if bits == 16 else nb
                        out[k] = b"; wave %s: %s %d-bit samples (%s B)%s" % (w.group(1), f"{ns:,}".encode(), bits,
                                                                            w.group(3), w.group(4))
                        break
                line = (b"%s:%s.incbin%s\"pcm/%s.pcm\", 0, %d\t; census: generated -- scripts/build/pcm_wav.py, "
                        b"from waveform/wav/%s (%d-bit)" % (m.group(1), m.group(2), m.group(3), m.group(1),
                                                           end - start, wav.encode(), bits))
                n += 1
            elif line == HEAD_OLD:
                line = HEAD_NEW
            out.append(line)
        path.write_bytes(b"\n".join(out))
    print(f"respelled {n} PCM items")


if __name__ == "__main__":
    main()
