# Compiling Toshiba's runtime sources with the 1998 compiler, in a throwaway VM

**Question.** The firmware's copy of Toshiba's C runtime matches neither the 1997 library of the TLCS-900 C Compiler
V4.23 nor the 2003 or 2008 ones (`../README.md`, "The 1998 compiler (V4.23)").  V4.23's own compiler passes (thc1 /
thc2, 1998-06-04) are newer than its library (1997-05-26).  Does that compiler, run on the library's own sources,
produce the firmware's bytes?

**Answer: no.**  With `-O3 -XS -DFLOAT` it rebuilds the 1997 library, 147 of its 156 pieces byte for byte, so these are
the options and the code generator (thc2 V0.8n.04.11) the library was built with.  Its `_ldiv`, `_ultoa`, `_ldexp`
and `__doprnt` come out as the library's, which the firmware does not match, under every one of the seven option
sets tried.  The table and the reading are in `../README.md`, "Running V4.23"; the full comparison is
`../results/vm_compile.md`.

## The runs behind the numbers (2026-11-08)

| run | sources             | options             | `results.tar` SHA-256                                              |
|-----|---------------------|---------------------|--------------------------------------------------------------------|
| 2   | `sources-all-c.txt` | `options-float.txt` | `0c922ada9d8c5b1e8f2f61355f33995a57b28eeedac1f0ffd51126ce7606acd5` |
| 3   | `sources-all-c.txt` | `options-xs.txt`    | `947047a24b91357c77c4c8b0b63caa98397700fba6fbc5f2204d8809ebdb4602` |

Run 1 was a smoke test of eight sources with an earlier `job.sh`, which also tried `cc900 -c`.  That fails under Wine
(see `job.sh`); its `-S` output for `_LDIV.C` at `-O3` is the same as run 2's.  Both runs used the same `t900.tar`
(SHA-256 `b6f5349a1df3a8aaa40a455d60f2cfe7cdb52c0b49605b7f62ea5491d3d205aa`), the guest image
`debian-13-generic-amd64.qcow2` of 2026-11-08 (SHA-256 `ee845b8abcc5107441c452a5454a5711b1dabec34b64bc5f370688003d7bf2ff`)
and Wine 10.0 (Debian 10.0~repack-6).  The objects are not committed (they are compiled Toshiba code); their
SHA-256s are `../results/vm_objects.sha256`.  Every thc1 call prints `THC1-Warning-501: Illegal option` for each
variable Wine adds to the environment (`WINEDATADIR=...`): cc900 hands thc1 its options through the environment, and
thc1 ignores the ones it does not know.  Four compiles failed with a Wine client error (`../README.md` lists them).
The outputs of all three runs are kept in the private repository `~/compartilhado/cc900-oracle/` (never pushed:
they are Toshiba-generated), under `runs/2026-11-08-{1,2,3}-*`.  The VM itself is kept permanently in that
repository's git-ignored `vm/` (Felipe, 2026-11-08).

## How it runs

No Toshiba program runs on the host.  `run_vm.sh` boots a Debian 13 cloud image under QEMU/KVM, with a disk overlay
so the base image is never written.  cloud-init (NoCloud, seeded over HTTP through the SMBIOS serial number) runs
`job.sh` in the guest, which:

1. installs Wine (`wine`, `wine32:i386`) from Debian;
2. fetches `t900.tar` (the V4.23 tree from `upstream_repos/file_archive/devrs.com/ngpcbins`, without `SAMPLE/`),
   `sources.txt` and `options.txt` from the host;
3. compiles every source with every option set (`cc900 <flags> -IC:\T900\INCLUDE -S`, `THOME=C:\T900`), then runs
   `ASM900` with no options on the `.asm` it wrote, which gives the IEEE-695 object (`.rel`);
4. sends `results.tar` and `job.log` back with HTTP PUT, and powers off.

The guest's only channel to the host is `httpd.py` on 127.0.0.1, which serves one directory and accepts uploads of
bare file names into another.

| file                | what it does                                                                                       |
|---------------------|----------------------------------------------------------------------------------------------------|
| `run_vm.sh`         | builds the seed, starts `httpd.py`, boots the VM and waits for it to power off                     |
| `httpd.py`          | the host side of the guest's only channel                                                          |
| `job.sh`            | runs inside the guest (never on the host): Wine, the compile sweep, the upload                     |
| `compare_vm.py`     | compares the objects with the ROM images and with the three libraries                              |
| `summarize.py`      | the per-option-set counts in `../README.md`: `python3 -I -B summarize.py ../results/vm_compile.md` |
| `sources-all-c.txt` | the `LIB/SRC` files a run compiles: all 123 C files                                                |
| `options-*.txt`     | the `cc900` option sets a run uses, one per line: a label, a vertical bar, the flags               |

## Setting it up (no root needed)

QEMU is not installed system-wide; its Debian packages are unpacked beside the VM.  This is how
`~/compartilhado/cc900-oracle/vm/` was made, and how to remake it:

```sh
mkdir -p ~/compartilhado/cc900-oracle/vm/debs && cd ~/compartilhado/cc900-oracle/vm/debs
apt-get download qemu-system-x86 qemu-system-common qemu-system-data qemu-utils seabios ipxe-qemu \
    libcapstone5 libpmem1 libfdt1 librdmacm1t64 libibverbs1 libslirp0 libvdeplug2t64 libaio1t64 libndctl6 libdaxctl1
for d in *.deb; do dpkg -x "$d" ../qemu; done
cd .. && B=https://cloud.debian.org/images/cloud/trixie/latest
curl -fLO $B/SHA512SUMS && curl -fLO $B/debian-13-generic-amd64.qcow2
grep ' debian-13-generic-amd64.qcow2$' SHA512SUMS | sha512sum -c
```

The user needs read/write access to `/dev/kvm`.

## Running it

```sh
W=~/compartilhado/cc900-oracle/vm/home        # the VM's home: its disk overlay keeps Wine between runs
./run_vm.sh $W sources-all-c.txt options-float.txt && mkdir -p $W/x2 && tar -xf $W/out/results.tar -C $W/x2
./run_vm.sh $W sources-all-c.txt options-xs.txt    && mkdir -p $W/x3 && tar -xf $W/out/results.tar -C $W/x3
mkdir -p $W/xall && for d in $W/x2/* $W/x3/*; do ln -sfn "$d" $W/xall/; done
python3 -I -B compare_vm.py $W/xall > ../results/vm_compile.md      # about 2 minutes
python3 -I -B summarize.py ../results/vm_compile.md
```

`compare_vm.py` needs the linked ELFs of the byte-identical rebuilds (`make all`), like `../xref_runtime.py`.

Then copy each run's `out/` contents, `job.log`, `sources.txt` and `options.txt` into a new
`~/compartilhado/cc900-oracle/runs/<date>-<n>-<name>/` and commit them there (that repository's README).
