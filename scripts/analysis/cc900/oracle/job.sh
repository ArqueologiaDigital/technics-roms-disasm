#!/bin/sh
# Runs INSIDE the oracle VM (run_oracle.sh), as root, started by cloud-init.  Never run it on the host.
#
# Fetches from the host's httpd.py:
#   compilers.txt  "name|tarball" per line; each tarball holds one cc900 install tree at its top level
#                  (BIN/ or bin/, INCLUDE/ or include/, ...), unpacked to C:\CC\<name>
#   corpus.tar     the C files to compile, unpacked to C:\SRC (subdirectories allowed)
#   sources.txt    paths of the files to compile, relative to the corpus root, with "/"; a line "path|label"
#                  compiles that file at option set <label> only (the firmware-C build, scripts/build/cc900_v423.py)
#   options.txt    "label|cc900 flags" per line
# and, for every compiler x option set x source, runs `cc900 <flags> -I<tree>\INCLUDE -S` and then ASM900 with no
# options on the .asm (a source that is itself .asm is only assembled); and
# options on the .asm (cc900 -c fails under Wine: its assembler pass reports "No source file found in invocation").
# Results go to W\<compiler>\<label>\<source path minus .c>.{asm,rel,cc.log,as.log}, sent back as results.tar.
set -u
H=http://10.0.2.2:${PORT:?}
export DEBIAN_FRONTEND=noninteractive WINEDEBUG=-all WINEDLLOVERRIDES='mscoree,mshtml=' WINEPREFIX=/root/.wine
cd /root

if ! command -v wine >/dev/null; then
    dpkg --add-architecture i386
    apt-get update -q
    apt-get install -y -q --no-install-recommends wine wine32:i386 >/root/apt.log 2>&1 || { tail -40 /root/apt.log; exit 1; }
fi
wine --version
[ -d "$WINEPREFIX" ] || wineboot -i >/root/wineboot.log 2>&1
C="$WINEPREFIX/drive_c"
rm -rf -- /root/.wine/drive_c/CC /root/.wine/drive_c/SRC /root/.wine/drive_c/W /root/.wine/drive_c/T900 /root/results /root/in
mkdir -p "$C/CC" "$C/SRC" "$C/W" /root/results /root/in

for f in compilers.txt corpus.tar sources.txt options.txt; do
    curl -sf "$H/$f" -o "/root/in/$f" || { echo "missing $f"; exit 1; }
done
tar -xf /root/in/corpus.tar -C "$C/SRC"
while IFS='|' read -r name tarball; do
    [ -n "$name" ] || continue
    curl -sf "$H/$tarball" -o "/root/in/$tarball" || { echo "missing $tarball"; exit 1; }
    mkdir -p "$C/CC/$name" && tar -xf "/root/in/$tarball" -C "$C/CC/$name"
    echo "compiler $name: $(sha256sum "/root/in/$tarball" | cut -c1-64) $(ls "$C/CC/$name" | tr '\n' ' ')"
done < /root/in/compilers.txt
sha256sum /root/in/corpus.tar /root/in/sources.txt /root/in/options.txt
export TMP='C:\W' TEMP='C:\W'

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
            case "$file" in *.asm|*.ASM)                  # an assembly listing: assemble it as it is
                ( cd "$d" && timeout 120 wine "C:\\CC\\$name\\BIN\\ASM900.EXE" "$file" >"$base.as.log" 2>&1
                  echo "exit $?" >>"$base.as.log" )
                continue ;;
            esac
            # the source's local headers go beside the copy: cc900 resolves `#include "x.h"` against the directory of
            # the file it compiles, not against -I (THC1-Error-310, run 2026-11-16-46-hd-r2); removed again below
            sdir=$(dirname "$src")
            hdrs=$(cd "$C/SRC/$sdir" && find . -type f \( -name '*.h' -o -name '*.H' \) | sed 's|^\./||')
            for h in $hdrs; do mkdir -p "$d/$(dirname "$h")"; cp "$C/SRC/$sdir/$h" "$d/$h"; done
            winsrc=$(printf '%s' "$src" | tr '/' '\\')
            ( cd "$d" && timeout 120 wine "C:\\CC\\$name\\BIN\\CC900.EXE" $flags -I"C:\\CC\\$name\\INCLUDE" \
                  -I"C:\\SRC\\$(dirname "$winsrc")" -S "$file" >"$base.cc.log" 2>&1; echo "exit $?" >>"$base.cc.log"
              a=$(ls | grep -i -x "$base.asm" | head -1)
              [ -n "$a" ] && timeout 120 wine "C:\\CC\\$name\\BIN\\ASM900.EXE" "$a" >"$base.as.log" 2>&1
              echo "exit $?" >>"$base.as.log" )
            rm -f -- "${d:?}/${file:?}"
            for h in $hdrs; do rm -f -- "${d:?}/${h:?}"; done
        done < /root/in/sources.txt
        echo "done $name $label: $flags"
    done < /root/in/options.txt
done < /root/in/compilers.txt

( cd "$C/W" && tar -cf /root/results/results.tar . )
curl -sf -T /root/results/results.tar "$H/out/results.tar"
echo JOB-OK
