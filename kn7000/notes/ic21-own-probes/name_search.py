# name_search.py -- where do the five respelled ONE TOUCH SETTING / style names of Felipe's CUSTOM bank
# come from?  ("Metallic Dance", "Sentimntal Solo", "3/4 Played By 4", "Disco - Techni", "Jazz At 3.00am",
# name_fields.py's "none of these" and "':' written '.'" rows.)
#
# Walks every file under the roots given (default: this repository's original_ROMs, the private romsets
# ~/compartilhado/technics_romsets and ~/compartilhado/technics_roms/roms, and the Club Arena mirror
# ~/compartilhado/ca-software-mirror/files), all read-only, and opens every container it can without
# running anything:
#   zip and self-extracting zip (.exe) members, recursively;
#   .AST files (16-byte header + raw deflate, tools/ast_file.py's format) inflated;
#   PDFs through `pdftotext` (when installed), so the manuals' and leaflets' text is searched too;
#   .cab / .msi through `7z x -so` (when installed);
#   EPROM halves (names differing only in even/odd) interleaved both ways.
# Each blob is searched case-insensitively for every spelling of the five names, the KN5000's own spellings
# included, and the hit is printed with its context.  Nothing is written.
#
#     python3 -I kn7000/notes/ic21-own-probes/name_search.py [root ...]
import io, os, re, shutil, subprocess, sys, zipfile, zlib

PATTERNS = [b"metallic dance", b"metalic dance", b"metallica dance", b"sentimntal solo", b"sentimental solo",
            b"3/4 played by 4", b"disco - techni", b"disco-techni", b"jazz at 3.00am", b"jazz at 3:00am"]
RX = re.compile(b"|".join(re.escape(p) for p in PATTERNS), re.I)
HOME = os.path.expanduser("~/compartilhado")
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
ROOTS = sys.argv[1:] or [os.path.join(REPO, "original_ROMs"), f"{HOME}/technics_romsets", f"{HOME}/technics_roms/roms",
                         f"{HOME}/ca-software-mirror/files"]
hits = {}
nblobs = 0


def search(where, data, depth=0):
    global nblobs
    nblobs += 1
    for m in RX.finditer(data):
        ctx = data[max(0, m.start() - 40):m.end() + 24]
        hits.setdefault(m.group().lower().decode(), []).append((where, m.start(), ctx))
    if depth > 4:
        return
    name = where.lower()
    if data[:2] == b"PK" or name.endswith(".exe") or name.endswith(".zip"):
        try:
            z = zipfile.ZipFile(io.BytesIO(data))
            for i in z.infolist():
                if not i.is_dir():
                    search(f"{where}!{i.filename}", z.read(i), depth + 1)
        except Exception:
            pass
    if name.endswith(".ast") and len(data) > 16:
        try:
            search(f"{where}[inflated]", zlib.decompressobj(-15).decompress(data[16:]), depth + 1)
        except Exception:
            pass
    if data[:5] == b"%PDF-" and shutil.which("pdftotext"):
        r = subprocess.run(["pdftotext", "-q", "-", "-"], input=data, capture_output=True)
        search(f"{where}[pdftotext]", r.stdout, 99)
    if (name.endswith(".cab") or name.endswith(".msi")) and shutil.which("7z"):
        tmp = os.environ.get("TMPDIR", f"{HOME}/tmp")
        d = os.path.join(tmp, f"name_search_{os.getpid()}")
        os.makedirs(d, exist_ok=True)
        f = os.path.join(d, "blob" + os.path.splitext(name)[1])
        open(f, "wb").write(data)
        lst = subprocess.run(["7z", "l", "-slt", f], capture_output=True).stdout.decode("latin1")
        for p in re.findall(r"^Path = (.+)$", lst, re.M)[1:]:
            out = subprocess.run(["7z", "x", "-so", f, p], capture_output=True).stdout
            if out:
                search(f"{where}!{p}", out, depth + 1)
        os.remove(f)
        os.rmdir(d)


def interleave(a, b):
    out = bytearray(len(a) + len(b))
    out[0::2], out[1::2] = a, b
    return bytes(out)


for root in ROOTS:
    for dp, _dn, fn in os.walk(root):
        for f in sorted(fn):
            p = os.path.join(dp, f)
            if os.path.islink(p) or os.path.getsize(p) > 64 << 20:
                continue
            search(p, open(p, "rb").read())
            if "even" in f:
                q = os.path.join(dp, f.replace("even", "odd").replace(".ic17", ".ic16").replace(".ic3", ".ic1"))
                if os.path.exists(q):
                    a, b = open(p, "rb").read(), open(q, "rb").read()
                    if len(a) == len(b):
                        search(f"{p}+odd[interleaved]", interleave(a, b), 99)
                        search(f"{p}+odd[interleaved, odd first]", interleave(b, a), 99)

print(f"{nblobs} blobs searched under {len(ROOTS)} roots")
for p in PATTERNS:
    v = hits.get(p.decode(), [])
    places = sorted({w for w, _, _ in v})
    print(f"\n== {p.decode()!r}: {len(v)} hits in {len(places)} blobs")
    for w in places[:40]:
        first = next(x for x in v if x[0] == w)
        print(f"   {w}  @0x{first[1]:x}  {first[2]!r}")
    if len(places) > 40:
        print(f"   ... {len(places) - 40} more")
