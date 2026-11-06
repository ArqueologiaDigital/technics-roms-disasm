#!/usr/bin/env python3
"""rhythm_kit_tone_fallback: which tone does ToneKeyFind (program 941, 0x4856FC51) fall back to
for the ten kit sounds the IC18 styles ask for that the internal voice archive has no tone for?
(N-83177c3d, notes/ic18-rhythm-rom.md "Drum keys")

Signal read: ToneKeyFind's code, as the probe restates it (src/program/region1_0B.s,
ToneKeyFind .. loc_4856FF72), on the key MSB << 16 | LSB << 8 | program:
  1. the archive sources 1..4 (ToneKeyLookupSrc1..4, each only when VoiceBankSourcePresent);
  2. the internal 'Tone' hash, ToneKeyLookup, with the key itself;
  3. per-MSB rules for MSB 0x20..0x2F, 0x4D..0x5F, 0x21 / 0x23 / 0x24 / 0x27 / 0x68 / 0x69 /
     0x6B; the kit bank MSB 0x26 (38) takes none of them and reaches the general tail
     (loc_4856FF17), which tries in order
       {MSB, LSB & 0xF8, program}, {MSB, 0, program}, {MSB, 0, program & 0xF8}, {MSB, 0, 0},
     and last 0x207F7F (loc_4856FF67), whatever that finds.
The probe applies 2 and 3 to the internal archive (src/table/voices/internal_archive.s, the
tone keys of its 'Tone' hash entries; step 1 needs sound data the stock instrument does not
hold), counts the IC18 drum notes per played kit as rhythm_drum_kit_keys.py does, and
re-measures the share of drum notes whose kit names the key as Standard Kit 1 does, now
with the ten kits resolved.

Expected (2026-11-06): the eight LSB-4 kits fall back to the LSB-0 kit of the same program
({26, 4} -> Analog Kit 2, {32, 4} -> Jazz Kit, {31, 4} -> Techno Kit, {48, 4} -> Orchestral
Kit, {72, 4} -> Bongo&Conga Kit, {27, 4} -> Soul Kit, {0, 4} -> Standard Kit1, {56, 4} ->
Sound Effect Kit) at the first step; {34, 0} -> Jazz Kit (program 32, the third step);
{127, 0} -> Standard Kit1 ({38, 0, 0}, the fourth step: program 120 has no kit).
3,386 notes resolved; agreement 191,448 of 203,802 (93.9 %; without the fallback 188,420 / 92.5 %,
the figure rhythm_drum_kit_keys.py measured on 2026-11-02).

usage (from this directory; needs ../../baserom/kn7000_ic18.rom, which make verify-ic18-full copies):
  python3 -I rhythm_kit_tone_fallback.py
"""
import collections
import importlib.util
import os

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "kitkeys", os.path.join(HERE, "..", "mn10300-names-probes", "rhythm_drum_kit_keys.py"))
K = importlib.util.module_from_spec(spec)
spec.loader.exec_module(K)       # the archive tables: K.tone_key, K.tone_dir, K.kits, K.key_name
R = K.R
# rhythm_drum_kit_keys.py reads a record's name from an `.ascii` line after its label; the voice
# records are VOICE_HEAD "name", ... since the archive's macros (2026-11), so that probe now finds
# no voice name ('?' for every key).  Take the name from either spelling here.
import re  # noqa: E402
K.name = {}
for _i, _x in enumerate(K.L):
    _m = re.match(r"^((?:Voice|Tone)_\w+):", _x)
    if _m:
        _n = re.match(r'\s*(?:\.ascii|VOICE_HEAD|SOUND_NAME_HEAD)\s+"(.*?)"', K.L[_i + 1])
        K.name[_m.group(1)] = _n.group(1).strip() if _n else None


def tone_key_find(msb, lsb, prog):
    """-> (tone label, step) with ToneKeyFind's internal-hash order for an MSB with no rule (0x26)."""
    tries = [("exact", msb << 16 | lsb << 8 | prog)]
    assert msb == 0x26, "only the kit bank's path is restated here"
    tries += [("LSB & 0xF8", msb << 16 | (lsb & 0xF8) << 8 | prog), ("LSB 0", msb << 16 | prog),
              ("LSB 0, program & 0xF8", msb << 16 | (prog & 0xF8)), ("LSB 0, program 0", msb << 16),
              ("0x207F7F", 0x207F7F)]
    for step, key in tries:
        t = K.tone_key.get(key)
        if t is not None:
            return K.tone_dir[t], step
    return None, "none"


def drum_use():
    """{(program, LSB, MSB): Counter(key -> notes)} over the drum parts 0 and 7 of the 169 styles."""
    d = open(os.path.join(K.KN7, "baserom/kn7000_ic18.rom"), "rb").read()
    u24 = lambda o: (d[o] << 16) | (d[o + 1] << 8) | d[o + 2]  # noqa: E731
    u16 = lambda o: (d[o] << 8) | d[o + 1]  # noqa: E731
    st, ci = 0x10000 + u24(0x10000 + 0x1E), 0x10000 + u24(0x10000 + 0x21)
    use = collections.defaultdict(collections.Counter)
    for i in range((ci - st) // 3):
        r = 0x10000 + u24(st + 3 * i)
        base = {p: tuple(d[r + 0x11 + 15 * p + 2:r + 0x11 + 15 * p + 5]) for p in (0, 7)}
        for j in range(20):
            v = r + u24(r + 0x8A + 3 * j)
            ln, kit = u16(v + 4), dict(base)
            o = v + 6
            while o < v + 6 + ln:
                if d[o] & 0xF0 == 0xC0 and d[o] & 15 in (0, 7):
                    kit[d[o] & 15] = tuple(d[o + 1:o + 4])
                o += R.ev_len(d, o) if d[o] >= 0x80 else 1
            o = v + 9 + ln
            e = o + u24(v + 6 + ln)
            while o < e:
                if d[o] & 0xF0 == 0x90 and d[o] & 15 in (0, 7):
                    use[kit[d[o] & 15]][d[o + 1]] += 1
                o += R.ev_len(d, o) if d[o] >= 0x80 else 1
    return use


def name_in(tone, key):
    a, b, c = K.kits[tone][key]
    ix = K.voice_key.get(c << 16 | b << 8 | (a & 0x7F))
    return K.name.get(K.voice_dir[ix]) if ix is not None and ix < len(K.voice_dir) else None


def agreement(resolve):
    agree = total = 0
    std1 = K.tone_dir[K.tone_key[0x260000]]
    for kit, c in drum_use().items():
        t = resolve(kit)
        for key, n in c.items():
            total += n
            if t in K.kits and name_in(t, key) is not None and name_in(t, key) == name_in(std1, key):
                agree += n
    return agree, total


def main():
    use = drum_use()
    print("== kit sounds with no tone of their own in the internal archive -> ToneKeyFind's fallback")
    resolved = 0
    for kit, c in sorted(use.items(), key=lambda x: -sum(x[1].values())):
        p, lsb, msb = kit
        if K.tone_key.get(msb << 16 | lsb << 8 | p) is not None:
            continue
        t, step = tone_key_find(msb, lsb, p)
        n = sum(c.values())
        resolved += n
        print(f"   {{{p}, {lsb}}} ({n} notes) -> {t} {K.name.get(t)!r} by '{step}'")
    print(f"   {resolved} notes")
    own = lambda kit: (K.tone_dir[K.tone_key[kit[2] << 16 | kit[1] << 8 | kit[0]]]  # noqa: E731
                       if (kit[2] << 16 | kit[1] << 8 | kit[0]) in K.tone_key else None)
    a0, t0 = agreement(own)
    print(f"== drum notes whose own kit names the key as Standard Kit 1 does (no fallback, a named "
          f"voice on both sides): {a0} of {t0} ({100 * a0 / t0:.1f} %)")
    agree, total = agreement(lambda kit: tone_key_find(kit[2], kit[1], kit[0])[0])
    print(f"== drum notes whose kit (after the fallback) names the key as Standard Kit 1 does: "
          f"{agree} of {total} ({100 * agree / total:.1f} %)")


if __name__ == "__main__":
    main()
