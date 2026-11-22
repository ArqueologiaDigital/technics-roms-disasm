#!/bin/sh
# Feedback plan step I2: a guest job for the oracle VM (run_oracle.sh with JOB=this file).  Runs INSIDE the VM, as
# root; never on the host.
#
# QUESTION: what do thc2's hidden options (-zim, -zio, -zl, -zh, -zperf, -g<letters>; I2's reading of the option
# table) print?  The cc900 driver cannot pass them on, so for every compiler x option set x source this job
#   1. runs `cc900 <flags> -S` as job.sh does, under Wine's process trace (for thc2's command line), with Wine's
#      Temp directory append-only so that thc1's intermediate file (the temporary file thc2 reads) survives, and
#      copies it;
#   2. re-runs THC2.EXE itself on that copy with the driver's own thc2 arguments: once unchanged (`plain`, which must
#      give the same .asm as the driver: the check that the copy is complete) and once per line of asmflags.txt,
#      read here as "dlabel|extra thc2 options" (inserted before the input file).
# Inputs as job.sh (compilers.txt, corpus.tar, sources.txt with optional "path|label", options.txt, asmflags.txt),
# C sources only, local headers handled as job.sh does.
# Results: W\<compiler>\<label>\<source dir>\<base>.{asm,cc.log,thc2args.txt,inter} and <base>_<dlabel>.{asm,out} (stdout+stderr
# of THC2.EXE), sent back as results.tar.
set -u
H=http://10.0.2.2:${PORT:?}
export DEBIAN_FRONTEND=noninteractive WINEDEBUG=-all WINEDLLOVERRIDES='mscoree,mshtml=' WINEPREFIX=/root/.wine
cd /root
command -v wine >/dev/null || { echo "no wine in the overlay"; exit 1; }
[ -d "$WINEPREFIX" ] || wineboot -i >/root/wineboot.log 2>&1
C="$WINEPREFIX/drive_c"
rm -rf -- /root/.wine/drive_c/CC /root/.wine/drive_c/SRC /root/.wine/drive_c/W /root/results /root/in
mkdir -p "$C/CC" "$C/SRC" "$C/W" /root/results /root/in
for f in compilers.txt corpus.tar sources.txt options.txt; do
    curl -sf "$H/$f" -o "/root/in/$f" || { echo "missing $f"; exit 1; }
done
curl -sf "$H/asmflags.txt" -o /root/in/asmflags.txt || : > /root/in/asmflags.txt
tar -xf /root/in/corpus.tar -C "$C/SRC"
while IFS='|' read -r name tarball; do
    [ -n "$name" ] || continue
    curl -sf "$H/$tarball" -o "/root/in/$tarball" || { echo "missing $tarball"; exit 1; }
    mkdir -p "$C/CC/$name" && tar -xf "/root/in/$tarball" -C "$C/CC/$name"
done < /root/in/compilers.txt
TEMPDIR="$C/users/root/AppData/Local/Temp"
mkdir -p "$TEMPDIR"

while IFS='|' read -r name tarball; do
    [ -n "$name" ] || continue
    export THOME="C:\\CC\\$name" THOME900="C:\\CC\\$name" WINEPATH="C:\\CC\\$name\\BIN"
    while IFS='|' read -r label flags; do
        [ -n "$label" ] || continue
        while IFS='|' read -r src only; do
            [ -n "$src" ] || continue
            [ -z "$only" ] || [ "$only" = "$label" ] || continue
            rel=${src%.*}; dir=$(dirname "$rel"); base=$(basename "$rel"); file=$(basename "$src")
            d="$C/W/$name/$label/$dir"; mkdir -p "$d"
            cp "$C/SRC/$src" "$d/$file"
            # the source's local headers beside the copy, as job.sh does (cc900 resolves #include "x.h" there)
            sdir=$(dirname "$src")
            hdrs=$(cd "$C/SRC/$sdir" && find . -type f \( -name '*.h' -o -name '*.H' \) | sed 's|^\./||')
            for h in $hdrs; do mkdir -p "$d/$(dirname "$h")"; cp "$C/SRC/$sdir/$h" "$d/$h"; done
            winsrc=$(printf '%s' "$src" | tr '/' '\\')
            # thc1's output: Wine's Temp directory is append-only while the driver runs (chattr +a, root in the guest),
            # so the driver cannot delete its temporary files; the one thc2 read is copied below and the directory
            # emptied by this job.  (A watcher that hard-linked new files lost about 15 % of them: runs 46-49.)
            chattr -a "$TEMPDIR"; find "$TEMPDIR" -maxdepth 1 -type f -delete; chattr +a "$TEMPDIR"
            ( cd "$d" && WINEDEBUG=+process timeout 120 wine "C:\\CC\\$name\\BIN\\CC900.EXE" $flags \
                  -I"C:\\CC\\$name\\INCLUDE" \
                  -I"C:\\SRC\\$(dirname "$winsrc")" -S "$file" >"$base.trace" 2>&1; echo "exit $?" >"$base.cc.log" )
            chattr -a "$TEMPDIR"
            grep -a -o 'cmdline L"thc2 [^"]*"' "$d/$base.trace" | head -1 \
                | sed 's/^cmdline L"thc2 //; s/"$//; s/\\\\/\\/g' > "$d/$base.thc2args.txt"
            grep -a -v ':trace:' "$d/$base.trace" >> "$d/$base.cc.log"
            rm -f -- "${d:?}/${base:?}.trace" "${d:?}/${file:?}"
            for h in $hdrs; do rm -f -- "${d:?}/${h:?}"; done
            [ -s "$d/$base.thc2args.txt" ] || { echo "no thc2 command line for $name $label $src"; continue; }
            tin=$(awk '{ print $(NF - 1) }' "$d/$base.thc2args.txt" | sed 's/.*\\//')
            [ -n "$tin" ] && [ -s "$TEMPDIR/$tin" ] && cp "$TEMPDIR/$tin" "$d/$base.inter"
            find "$TEMPDIR" -maxdepth 1 -type f -delete
            [ -s "$d/$base.inter" ] || { echo "no intermediate for $name $label $src"; continue; }
            # the driver's thc2 arguments without the last two (input, output)
            args=$(awk '{ for (i = 1; i <= NF - 2; i++) printf "%s ", $i }' "$d/$base.thc2args.txt")
            ( printf 'plain|\n'; cat /root/in/asmflags.txt ) | while IFS='|' read -r dl extra; do
                [ -n "$dl" ] || continue
                ( cd "$d" && timeout 120 wine "C:\\CC\\$name\\BIN\\THC2.EXE" $args $extra "$base.inter" \
                      "${base}_$dl.asm" >"${base}_$dl.out" 2>&1 </dev/null; echo "exit $?" >>"${base}_$dl.out" )
            done
        done < /root/in/sources.txt
        echo "done $name $label: $flags"
    done < /root/in/options.txt
done < /root/in/compilers.txt

( cd "$C/W" && tar -cf /root/results/results.tar . )
curl -sf -T /root/results/results.tar "$H/out/results.tar"
echo JOB-OK
