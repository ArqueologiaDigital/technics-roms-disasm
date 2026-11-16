#!/usr/bin/env python3
"""Toshiba cc900 V4.23 for the firmware-C build: a cache of its listings, filled by one oracle-VM job per make.

QUESTION ANSWERED: which listing does Toshiba's own compiler, V4.23, write for each firmware C file
(<tree>/cc900/*.c) at the options the file names?  `make` (CC900_COMPILER=v423, the default) builds the firmware C
from these listings: scripts/build/cc900_firmware_c.py --v423 CACHE translates a file's cached listing with
model/to_llvm.py into the bodies the trees include.  CC900_COMPILER=model builds from the Python reference model
instead and never runs this.

usage: python3 -B scripts/build/cc900_v423.py fill CACHE ORACLE FILE.c [FILE.c ...]
       python3 -B scripts/build/cc900_v423.py index CACHE FILE.c [FILE.c ...]     (no VM; see index())
    CACHE   the build's cache directory (git-ignored; the Makefile's CC900_V423_CACHE, build/cc900-v423)
    ORACLE  the oracle tree (CC900_ORACLE; its vm/ holds QEMU, the disk overlay and the lock)
    FILE.c  every firmware C file of every tree

The cache.  CACHE/<key>/ holds one compile: the listing (<base>.asm), the compiler's and assembler's logs and
`status` (OK or FAILED).  The key is the SHA-256 of everything that decides the listing:
  - the C file's bytes and base name;
  - the cc900 flags the file names (`cc900-options:`);
  - every header it includes with #include "..." (none today), by name and bytes;
  - the compiler tree's id, the SHA-256 of its files (compilers.conf's v423 tree, without SAMPLE / manual, as
    run_oracle.sh sends it);
  - oracle/job.sh, which drives the compiler in the guest.
Identical text in two trees is one compile.  The VM's own image (Debian, Wine) is not in the key: it does not
change what the compiler writes.

`index` (run by the Makefile as it reads itself) writes CACHE/index.tsv, one line per FILE.c: path, key, cached or
missing, rewriting it only when it changed.  `fill` (the Makefile's rule for CACHE/filled.stamp, which depends on the
index) hashes every FILE.c, compiles the ones whose key is not cached in ONE VM job (all of them, at their own
options), files the results into CACHE and rewrites the index; so make runs it, and rebuilds bodies, only when a key
changed or a listing went missing.  A fully cached fill does not look at the VM,
so a complete cache builds without it.  When a file is missing and the VM is not usable, fill stops and names what
is missing and the flag that builds without the VM (`make CC900_COMPILER=model`); there is no automatic fallback.
A compile that a Wine fault in the guest lost (page fault, recvmsg reset, "starting debugger"; no THC*-Error) is
never cached as FAILED: fill compiles it again, up to RETRIES more VM jobs, and then stops naming it, with its logs
in CACHE/wine-faults/<key>/; the next make tries again.  An older FAILED entry whose logs show such a fault is
compiled again too.  The compiler tree's id is recorded in CACHE/compiler-id.txt; when the tree itself is absent, fill uses the recorded
id, so a complete cache still builds.

The VM is shared: the job runs in a slot of the VM pool (oracle/vm_slot.sh: VM_POOL_SLOTS slots, each with its own
lock, vm/.runlock[.k], and HTTP port), waiting when all are busy.  Every slot boots the disk overlay with -snapshot
(oracle/run_vm.sh), so a build writes nothing into the oracle tree: not its runs/, not its disk.  The listings are Toshiba's output: they stay in CACHE, which git ignores, and never go
into a commit.
"""
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tarfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
ORACLE_TOOLS = os.path.join(REPO, "scripts", "analysis", "cc900", "oracle")
COMPILER = "v423"
KEY_VERSION = b"cc900-v423-cache 1\n"
EXCLUDE = {"SAMPLE", "sample", "manual", "MANUAL"}       # as run_oracle.sh's tar --exclude
LABEL_RE = re.compile(r"[^A-Za-z0-9_]")
INCLUDE_RE = re.compile(rb'^\s*#\s*include\s*"([^"]+)"', re.M)
MODEL_FLAG = "make CC900_COMPILER=model"


def compiler_tree():
    for line in open(os.path.join(ORACLE_TOOLS, "compilers.conf")):
        name, _, path = line.strip().partition("|")
        if name == COMPILER:
            return os.path.expanduser(path)
    sys.exit("cc900_v423: no %s line in %s" % (COMPILER, os.path.join(ORACLE_TOOLS, "compilers.conf")))


def tree_id(root):
    h = hashlib.sha256()
    for dp, dn, fn in os.walk(root):
        dn[:] = sorted(d for d in dn if d not in EXCLUDE)
        for f in sorted(fn):
            if f in EXCLUDE:
                continue
            p = os.path.join(dp, f)
            h.update(os.path.relpath(p, root).encode() + b"\0" + hashlib.sha256(open(p, "rb").read()).digest())
    return h.hexdigest()


def local_headers(path):
    """[(name, bytes)] of the headers FILE.c includes with #include "...", recursively, beside it"""
    d, seen, todo = os.path.dirname(path), {}, [path]
    while todo:
        for m in INCLUDE_RE.finditer(open(todo.pop(), "rb").read()):
            n = m.group(1).decode()
            p = os.path.join(d, n)
            if n not in seen:
                if not os.path.isfile(p):
                    sys.exit("%s: #include \"%s\": no such file beside it" % (path, n))
                seen[n] = open(p, "rb").read()
                todo.append(p)
    return sorted(seen.items())


def flags_of(path):
    sys.path.insert(0, HERE)
    import cc900_firmware_c as fw
    return fw.file_flags(path)


def label_of(flags):
    """the option set's directory name in the job (job.sh's label): the flags without dashes and blanks, e.g.
    -O3 -XS -Xr -> O3XSXr, -O2 -Xr -> O2Xr, no flags -> none (the labels the oracle runs used)"""
    return LABEL_RE.sub("", "".join(f.lstrip("-") for f in flags.split())) or "none"


def key_of(path, compiler_id):
    h = hashlib.sha256(KEY_VERSION)
    h.update(os.path.basename(path).encode() + b"\0")
    h.update(flags_of(path).encode() + b"\0")
    h.update(hashlib.sha256(open(path, "rb").read()).digest())
    for n, b in local_headers(path):
        h.update(n.encode() + b"\0" + hashlib.sha256(b).digest())
    h.update(compiler_id.encode() + b"\0")
    h.update(hashlib.sha256(open(os.path.join(ORACLE_TOOLS, "job.sh"), "rb").read()).digest())
    return h.hexdigest()


def recorded_compiler_id(cache):
    p = os.path.join(cache, "compiler-id.txt")
    return open(p).read().strip() if os.path.exists(p) else None


def listing(cache, path):
    """FILE.c -> (status, listing path, log paths) from the cache, keyed by the compiler id fill recorded; status is
    None when the file is not cached"""
    cid = recorded_compiler_id(cache)
    if cid is None:
        return None, None, []
    d = os.path.join(cache, key_of(path, cid))
    base = os.path.splitext(os.path.basename(path))[0]
    st = os.path.join(d, "status")
    logs = [os.path.join(d, base + x) for x in (".cc.log", ".as.log")]
    return (open(st).read().strip() if os.path.exists(st) else None), os.path.join(d, base + ".asm"), logs


def write_if_changed(path, text):
    if os.path.exists(path) and open(path).read() == text:
        return
    tmp = path + ".tmp"
    open(tmp, "w").write(text)
    os.replace(tmp, path)


def vm_problems(oracle):
    """what the V4.23 job needs and lacks"""
    q = os.path.join(oracle, "vm", "qemu", "usr", "bin", "qemu-system-x86_64")
    need = [(os.path.isdir(oracle), "the oracle tree %s (CC900_ORACLE)" % oracle),
            (os.access(q, os.X_OK), "QEMU %s" % q),
            (os.path.isfile(os.path.join(oracle, "vm", "home", "disk.qcow2")),
             "the VM's disk overlay %s (with Wine; an oracle run makes it)" % os.path.join(oracle, "vm", "home", "disk.qcow2")),
            (os.path.isdir(os.path.join(oracle, "vm", "home")), "the VM work directory %s" % os.path.join(oracle, "vm", "home")),
            (os.access("/dev/kvm", os.R_OK | os.W_OK), "read/write access to /dev/kvm"),
            (os.path.isdir(compiler_tree()), "the V4.23 compiler tree %s (oracle/compilers.conf)" % compiler_tree())]
    return [what for ok, what in need if not ok]


def stop_unavailable(misses, problems, cache):
    sys.stderr.write(
        "\nERROR: cc900 V4.23 is not available, and %d firmware C file(s) have no cached V4.23 listing in %s:\n"
        "%s\n"
        "The V4.23 build needs the oracle VM, which lacks:\n%s\n"
        "To build the firmware C with the Python reference model instead (no VM):\n\n    %s\n\n"
        "(add it to every make command, e.g. `%s gate`; or point CC900_ORACLE at the oracle tree).\n\n"
        % (len(misses), cache, "".join("    %s\n" % os.path.relpath(p, REPO) for p in sorted(misses)),
           "".join("    - %s\n" % w for w in problems), MODEL_FLAG, MODEL_FLAG))
    sys.exit(2)


SAFE_CACHE_PARENTS = (REPO, "/home/fsanches/compartilhado/tmp")


def check_cache_root(cache):
    """stop unless CACHE lies strictly inside the repository or the shared scratch directory (so that a mistaken
    CC900_V423_CACHE=/ or =~ cannot make remove_tree delete anything outside them)"""
    c = os.path.realpath(cache)
    if not any(c.startswith(os.path.realpath(p) + os.sep) for p in SAFE_CACHE_PARENTS):
        sys.exit("cc900_v423: refusing the cache directory %s: it must lie inside %s (CC900_V423_CACHE)"
                 % (cache, " or ".join(SAFE_CACHE_PARENTS)))


def remove_tree(path, root):
    """shutil.rmtree(path), only when root is an accepted cache directory and path lies strictly inside it"""
    check_cache_root(root)
    p, r = os.path.realpath(path), os.path.realpath(root)
    assert p != r and p.startswith(r + os.sep), (path, root)
    if os.path.lexists(p):
        shutil.rmtree(p)


def run_job(cache, oracle, misses):
    """compile {key: FILE.c} in one VM job; file each result into CACHE/<key>/.  Returns {key: FILE.c} of the
    compiles a Wine fault lost (not cached; their logs go to CACHE/wine-faults/<key>/)"""
    transient = {}
    work = os.path.join(cache, "vm-job")
    remove_tree(work, cache)
    serve, out, corpus, res = (os.path.join(work, x) for x in ("serve", "out", "corpus", "results"))
    for d in (serve, out, corpus, res):
        os.makedirs(d)
    sources, labels = [], {}
    for key, path in sorted(misses.items()):
        sub = os.path.join(corpus, key[:20])
        os.makedirs(sub)
        shutil.copyfile(path, os.path.join(sub, os.path.basename(path)))
        for n, b in local_headers(path):
            os.makedirs(os.path.dirname(os.path.join(sub, n)), exist_ok=True)
            open(os.path.join(sub, n), "wb").write(b)
        flags = flags_of(path)
        if labels.get(label_of(flags), flags) != flags:
            sys.exit("cc900_v423: the option sets %r and %r get the same label %s" % (flags, labels[label_of(flags)],
                                                                                     label_of(flags)))
        labels[label_of(flags)] = flags
        sources.append("%s/%s|%s" % (key[:20], os.path.basename(path), label_of(flags)))
    open(os.path.join(serve, "sources.txt"), "w").write("".join(s + "\n" for s in sources))
    open(os.path.join(serve, "options.txt"), "w").write("".join("%s|%s\n" % kv for kv in sorted(labels.items())))
    open(os.path.join(serve, "compilers.txt"), "w").write("%s|cc-%s.tar\n" % (COMPILER, COMPILER))
    with tarfile.open(os.path.join(serve, "cc-%s.tar" % COMPILER), "w") as t:
        t.add(compiler_tree(), arcname=".", filter=lambda ti: None if os.path.basename(ti.name) in EXCLUDE else ti)
    with tarfile.open(os.path.join(serve, "corpus.tar"), "w") as t:
        t.add(corpus, arcname=".")
    shutil.copyfile(os.path.join(ORACLE_TOOLS, "job.sh"), os.path.join(serve, "job.sh"))

    # a slot of the VM pool (oracle/vm_slot.sh: the first free one, else it waits); the slot's port goes to run_vm.sh,
    # but the job's serve / out directories stay here in the cache, so the build writes nothing into the oracle tree
    print("cc900 V4.23: compiling %d firmware C file(s) in the oracle VM ..." % len(misses), flush=True)
    t0 = time.time()
    env = dict(os.environ, ORACLE=oracle)
    env.pop("VM_SLOT", None)
    r = subprocess.run(["bash", os.path.join(ORACLE_TOOLS, "vm_slot.sh"), "bash", os.path.join(ORACLE_TOOLS, "run_vm.sh"),
                        serve, out], env=env)
    print("cc900 V4.23: the VM job took %.0f s" % (time.time() - t0), flush=True)
    if r.returncode:
        sys.exit("cc900 V4.23: the VM job failed (exit %d); its logs are in %s" % (r.returncode, out))
    with tarfile.open(os.path.join(out, "results.tar")) as t:
        for m in t.getmembers():
            if not (m.isfile() or m.isdir()) or m.name.startswith("/") or ".." in m.name.split("/"):
                sys.exit("cc900 V4.23: unexpected member %r in results.tar" % m.name)
        t.extractall(res, filter="data")
    for key, path in sorted(misses.items()):
        base = os.path.splitext(os.path.basename(path))[0]
        src = os.path.join(res, COMPILER, label_of(flags_of(path)), key[:20])
        dst_tmp = os.path.join(work, "file-" + key)
        os.makedirs(dst_tmp)
        for x in (".asm", ".cc.log", ".as.log"):
            if os.path.exists(os.path.join(src, base + x)):
                shutil.copyfile(os.path.join(src, base + x), os.path.join(dst_tmp, base + x))
        cc = open(os.path.join(dst_tmp, base + ".cc.log"), encoding="latin-1").read() \
            if os.path.exists(os.path.join(dst_tmp, base + ".cc.log")) else ""
        asl = open(os.path.join(dst_tmp, base + ".as.log"), encoding="latin-1").read() \
            if os.path.exists(os.path.join(dst_tmp, base + ".as.log")) else ""
        ok = (os.path.exists(os.path.join(dst_tmp, base + ".asm")) and cc.rstrip().endswith("exit 0")
              and asl.rstrip().endswith("exit 0") and not re.search(r"-Error-", cc))
        if not ok and wine_fault(cc + asl) and not re.search(r"-Error-", cc + asl):
            transient[key] = path                         # Wine broke, not the compiler: never cached as FAILED
            faults = os.path.join(cache, "wine-faults", key)  # its logs, for the error message if retries run out
            remove_tree(faults, cache)
            os.makedirs(os.path.dirname(faults), exist_ok=True)
            os.rename(dst_tmp, faults)
            continue
        open(os.path.join(dst_tmp, "status"), "w").write("OK\n" if ok else "FAILED\n")
        open(os.path.join(dst_tmp, "key.txt"), "w").write(
            "file %s\nflags %s\ncompiler %s %s\n" % (os.path.relpath(path, REPO), flags_of(path), COMPILER,
                                                    recorded_compiler_id(cache)))
        final = os.path.join(cache, key)
        remove_tree(final, cache)
        os.rename(dst_tmp, final)
    remove_tree(work, cache)
    return transient


# Wine faults inside the VM (main's gate after the call-relax merge: ASM900 "Unhandled page fault on write access";
# lane_sub run 2026-11-16-47: "wine client error: recvmsg: Connection reset by peer").  They are not the compiler's
# verdict: such a compile is retried, and never cached as FAILED.  A THC*-Error in the logs still fails at once.
WINE_FAULT_RE = re.compile(r"Unhandled page fault|wine client error|recvmsg|starting debugger", re.I)
RETRIES = 2


def wine_fault(log):
    return bool(WINE_FAULT_RE.search(log))


def cached_wine_failure(cache, key):
    """a FAILED entry an older fill cached although its logs show a Wine fault: compiled again"""
    d = os.path.join(cache, key)
    st = os.path.join(d, "status")
    if not os.path.exists(st) or open(st).read().strip() != "FAILED":
        return False
    logs = "".join(open(os.path.join(d, f), encoding="latin-1").read() for f in os.listdir(d) if f.endswith(".log"))
    return wine_fault(logs) and not re.search(r"-Error-", logs)


def fill(cache, oracle, files):
    cache, oracle = os.path.abspath(cache), os.path.abspath(oracle)
    check_cache_root(cache)
    os.makedirs(cache, exist_ok=True)
    ct = compiler_tree()
    if os.path.isdir(ct):
        write_if_changed(os.path.join(cache, "compiler-id.txt"), tree_id(ct) + "\n")
    keys = {}
    misses = {}                                            # {key: one FILE.c with that text}
    missing = set()                                        # every FILE.c whose listing is not cached
    cid = recorded_compiler_id(cache)
    for f in files:
        f = os.path.abspath(f)
        if cid is None:
            misses[f] = f
            missing.add(f)
            continue
        k = key_of(f, cid)
        keys[f] = k
        if not os.path.exists(os.path.join(cache, k, "status")) or cached_wine_failure(cache, k):
            misses[k] = f
            missing.add(f)
    compiled = len(set(misses.values()))
    if misses:
        problems = vm_problems(oracle)
        if problems:
            stop_unavailable(missing, problems, cache)
        todo = dict(misses)
        for attempt in range(1 + RETRIES):                 # the first job, then up to RETRIES for Wine faults
            todo = run_job(cache, oracle, todo)
            if not todo:
                break
            print("cc900 V4.23: a Wine fault in the VM lost %d listing(s): %s; %s"
                  % (len(todo), " ".join(os.path.relpath(p, REPO) for p in sorted(todo.values())),
                     "compiling them again" if attempt < RETRIES else "no retry left"), flush=True)
        if todo:
            sys.exit("cc900 V4.23: Wine faulted in the VM %d times on:\n%s(not cached; their logs are in %s).  The "
                     "next make tries again." % (1 + RETRIES, "".join("    %s\n" % os.path.relpath(p, REPO)
                                                                      for p in sorted(todo.values())),
                                                 os.path.join(cache, "wine-faults")))
    failed = []
    for f, k in sorted(keys.items()):
        st, _, logs = listing(cache, f)
        if st != "OK":
            failed.append((f, logs))
    if failed:
        sys.exit("cc900 V4.23 does not compile:\n%s" % "".join(
            "    %s (logs: %s)\n" % (os.path.relpath(f, REPO), " ".join(logs)) for f, logs in failed))
    index(cache, files)
    print("cc900 V4.23: %d firmware C file(s), %d compiled now, the rest cached in %s"
          % (len(files), compiled, os.path.relpath(cache, REPO)))


def index(cache, files):
    """write CACHE/index.tsv -- per FILE.c its key and whether the cache holds it -- only when that changed.  No VM.
    The Makefile runs this while it reads itself, so the fill rule (which depends on the index) runs exactly when a
    key changed or a listing is missing, and `make -q` sees an up-to-date tree as up to date."""
    cache = os.path.abspath(cache)
    check_cache_root(cache)
    os.makedirs(cache, exist_ok=True)
    ct = compiler_tree()
    if os.path.isdir(ct):
        write_if_changed(os.path.join(cache, "compiler-id.txt"), tree_id(ct) + "\n")
    cid = recorded_compiler_id(cache)
    rows = []
    for f in sorted(os.path.abspath(f) for f in files):
        k = key_of(f, cid) if cid else "no-compiler-id"
        st = "cached" if cid and os.path.exists(os.path.join(cache, k, "status")) else "missing"
        rows.append("%s\t%s\t%s\n" % (os.path.relpath(f, REPO), k, st))
    write_if_changed(os.path.join(cache, "index.tsv"), "".join(rows))


def main():
    a = sys.argv[1:]
    if len(a) >= 2 and a[0] == "index":
        return index(a[1], a[2:])
    if len(a) < 3 or a[0] != "fill":
        sys.exit(__doc__)
    fill(a[1], a[2], a[3:])


if __name__ == "__main__":
    main()
