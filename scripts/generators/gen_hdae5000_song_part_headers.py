#!/usr/bin/env python3
"""gen_hdae5000_song_part_headers.py -- header batch for the per-part song routines of the HD-AE5000.

QUESTION IT ANSWERS
  The nine-way families HDAE5000_LoadSong_<part>, _SaveSong_<part>, _CopyFdSongToHd_<part> and
  _DeleteSongPart_<part> (parts LSW PMT SQT CMP TM MSP RCM MD TLX = k 0..8) share one shape; only the slot
  (+36 + 4k of the 76-byte song record), the part byte (+26 + k) and the main-CPU hooks differ.  This prints one
  header per routine that still lacks one, in the batch format of scripts/tools/insert_hdae5000_headers.py: the
  family text with k filled in, plus "Main CPU:" (the RootFn_ / HamaFn_ slots it calls through) and "Calls:" (its
  direct callees but HDAE5000_Multiply) as scripts/analysis/hdae5000_routine_facts.py reads them from the code.
  The RCM and TLX loaders and savers work differently and were written by hand (SKIP).

RUN (repository root)
  python3 scripts/generators/gen_hdae5000_song_part_headers.py LoadSong SaveSong CopyFdSongToHd DeleteSongPart > B
  python3 scripts/tools/insert_hdae5000_headers.py B --apply
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "analysis"))
import hdae5000_call_target_headers as H  # noqa: E402
import hdae5000_routine_facts as F  # noqa: E402

PARTS = ["Lsw", "Pmt", "Sqt", "Cmp", "Tm", "Msp", "Rcm", "Md", "Tlx"]
UP = ["LSW", "PMT", "SQT", "CMP", "TM", "MSP", "RCM", "MD", "TLX"]
SKIP = {"HDAE5000_LoadSong_Rcm", "HDAE5000_LoadSong_Tlx", "HDAE5000_SaveSong_Rcm", "HDAE5000_SaveSong_Tlx"}


def wrap(prefix, items, width=76):
    lines, cur = [], prefix
    for it in items:
        add = (", " if cur != prefix else "") + it
        if len(cur) + len(add) > width:
            lines.append(cur + ",")
            cur = ";      " + it
        else:
            cur += add
    lines.append(cur)
    return lines


def main():
    src = F.load()
    defs, owner = F.index(src)
    have = {r[0] for r in H.survey() if r[2]}
    out = []
    for fam in sys.argv[1:]:
        for k, p in enumerate(PARTS):
            name = "HDAE5000_%s_%s" % (fam, p)
            if name not in defs or name in SKIP or name in have:
                continue
            f = F.facts(src, defs, owner, name)
            calls = [c for c in f["calls"] if c != "HDAE5000_Multiply"]
            fns = list(f["fncalls"])
            slot = 36 + 4 * k
            if fam == "LoadSong":
                text = ["; Load part %d (%s) of a song: when its first-cluster slot (song record" % (k, UP[k]),
                        "; +%d) is not 0xFFFFFFFF, read the chain with HDAE5000_HD_ReadFile and hand" % slot,
                        "; the data to the main CPU through its hooks.  Called by HDAE5000_LoadSong for",
                        "; mask bit %d." % k,
                        "; In:  WA = directory, BC = song",
                        "; Out: HL = 0 when the song has no such part, else HD_ReadFile's result."]
            elif fam == "SaveSong":
                text = ["; Save part %d (%s) of a song from the main CPU's memory (through its hooks)" % (k, UP[k]),
                        "; to a new cluster chain whose first cluster goes to slot +%d of the song" % slot,
                        "; record; the record's part byte +%d is set.  Called by HDAE5000_SaveSong" % (26 + k),
                        "; for mask bit %d." % k,
                        "; In:  WA = directory, BC = song",
                        "; Out: HL = 0, or 0xFFFF on a failure."]
            elif fam == "CopyFdSongToHd":
                text = ["; Copy the floppy file of part %d (%s) into a song: read through the main" % (k, UP[k]),
                        "; CPU's file hooks (HamaFn_fopen_ext with mode \"rb\", HamaFn_fread_ext into",
                        "; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new",
                        "; cluster chain at slot +%d of the song record (the calls below).  Called" % slot,
                        "; by HDAE5000_CopyFdSongToHd.",
                        "; In:  WA = directory, BC = song"]
            elif fam == "DeleteSongPart":
                text = ["; Delete part %d (%s) of a song: when slot +%d of the song record is not" % (k, UP[k], slot),
                        "; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to",
                        "; 0xFFFFFFFF and the part byte +%d to 0." % (26 + k),
                        "; In:  WA = directory, BC = song"]
            else:
                sys.exit("unknown family %s" % fam)
            if fns:
                text += wrap("; Main CPU: ", fns)
            if calls:
                text += wrap("; Calls: ", calls)
            out.append("@@ %s drop-notes" % name)
            out += text
    print("\n".join(out))


if __name__ == "__main__":
    main()
