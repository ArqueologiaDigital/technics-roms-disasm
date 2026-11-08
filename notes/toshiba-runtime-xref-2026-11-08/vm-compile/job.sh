#!/bin/sh
# Runs INSIDE the throwaway VM (run_vm.sh), as root, started by cloud-init.  Never run it on the host.
# Fetches the TLCS-900 C Compiler V4.23 tree (t900.tar), the list of sources (sources.txt) and of option sets
# (options.txt, "label|flags" per line) from the host's httpd.py, compiles every source with every option set under
# Wine (cc900 -S, then
# ASM900 on its output: the IEEE-695 object), and sends back results.tar and job.log.
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

curl -sf "$H/t900.tar" -o t900.tar && curl -sf "$H/sources.txt" -o sources.txt && curl -sf "$H/options.txt" -o options.txt || exit 1
sha256sum t900.tar
[ -d "$WINEPREFIX" ] || wineboot -i >/root/wineboot.log 2>&1
C="$WINEPREFIX/drive_c"
rm -rf -- /root/.wine/drive_c/T900 /root/.wine/drive_c/W /root/results
mkdir -p "$C/W" /root/results
tar -xf t900.tar -C "$C"            # -> drive_c/T900
ls "$C/T900/BIN"
export THOME='C:\T900' THOME900='C:\T900' TMP='C:\W' TEMP='C:\W' WINEPATH='C:\T900\BIN'

while IFS='|' read -r label flags; do
    [ -n "$label" ] || continue
    d="$C/W/$label"; mkdir -p "$d"
    while read -r src; do
        [ -n "$src" ] || continue
        b=${src%.*}
        cp "$C/T900/LIB/SRC/$src" "$d/"
        # cc900 -c fails under Wine (its assembler pass reports "No source file found in invocation"), so the
        # driver stops after the code generator (-S) and ASM900 is run on its output directly, with no options.
        ( cd "$d" && timeout 120 wine 'C:\T900\BIN\CC900.EXE' $flags -I'C:\T900\INCLUDE' -S "$src" \
              >"$d/$b.cc.log" 2>&1; echo "exit $?" >>"$d/$b.cc.log"
          [ -f "$b.asm" ] && timeout 120 wine 'C:\T900\BIN\ASM900.EXE' "$b.asm" >"$d/$b.as.log" 2>&1
          echo "exit $?" >>"$d/$b.as.log" )
        rm -f -- "${d:?}/${src:?}"
    done < sources.txt
    echo "done $label: $flags"
done < options.txt

( cd "$C/W" && tar -cf /root/results/results.tar . )
curl -sf -T /root/results/results.tar "$H/out/results.tar"
echo JOB-OK
