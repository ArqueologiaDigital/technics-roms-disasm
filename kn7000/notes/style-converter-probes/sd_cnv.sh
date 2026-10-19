#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# sd_cnv.sh FLOPPY ROUTE OUTDIR -- can DISK MENU > STYLE CONVERT load a .CNV from the SD card?
#
# Puts the marker converter sdmark.s as AW.CNV on a copy of the real KN7000's SD card in three
# places (\AW.CNV tagged ROOT, \PRIVATE\TECHNICS\KN7000\AW.CNV tagged KN7K, and that folder's
# TFLD001\AW.CNV tagged TFLD), boots program 941 (the published overlay build) under
# kn7000_mame's tools/rigs/remote.lua and walks the menus. Prints "SDCNV <step> drive=<fmm drive
# byte 0x5007125A> calls=<marker count> ran=<tag of the copy that ran> title=<main task title>".
#   FLOPPY  none   no disk in the drive
#           blank  a blank disk the KN7000 formatted (no converter on it)
#           flop   that blank disk plus AW.CNV tagged FLOP (the positive control)
#   ROUTE   menu   DISK MENU > STYLE CONVERT > OK
#           sd     SD CARD LOAD first (the SD screen), then DISK MENU > STYLE CONVERT > OK
# Snapshots in OUTDIR/snap. Example:
#   notes/style-converter-probes/sd_cnv.sh blank menu ~/compartilhado/tmp/cnv-sd/blank-menu
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$HERE/../.."
MAME_REPO="${MAME_REPO:-$REPO/../../kn7000_mame}"
SD_MASTER="${SD_MASTER:-$REPO/../kn7000-emulator/sdcard_from_real_kn7000.img}"
FLOP="$1"; ROUTE="$2"; D="$(mkdir -p "$3" && cd "$3" && pwd)"; mkdir -p "$D/snap"
python3 "$REPO/tools/xapasm.py" "$HERE/sdmark.s" -o "$D/sdmark.bin" -m "$D/sdmark.map" >/dev/null
mk() { python3 -I -c "import sys; b=bytearray(open(sys.argv[1],'rb').read()); b[0x40:0x44]=sys.argv[3].encode(); open(sys.argv[2],'wb').write(b)" "$D/sdmark.bin" "$D/$1.CNV" "$1"; }
for t in ROOT KN7K TFLD FLOP; do mk $t; done
cp "$SD_MASTER" "$D/sd.img"; chmod u+w "$D/sd.img"
python3 -I "$REPO/tools/sd_addfile.py" "$D/sd.img" '\AW.CNV' "$D/ROOT.CNV" \
  '\PRIVATE\TECHNICS\KN7000\AW.CNV' "$D/KN7K.CNV" '\PRIVATE\TECHNICS\KN7000\TFLD001\AW.CNV' "$D/TFLD.CNV" >/dev/null
FT="$MAME_REPO/tools/floppy-images"; FARGS=()
if [ "$FLOP" != none ]; then
  gzip -dc "$FT/base/kn7000_formatted.img.gz" > "$D/disk.img"
  if [ "$FLOP" = flop ]; then
    python3 -I -c "import sys,zipfile; z=zipfile.ZipFile(sys.argv[1],'w'); i=zipfile.ZipInfo('AW.CNV',(2026,10,18,0,0,0)); i.external_attr=0x20; z.writestr(i,open(sys.argv[2],'rb').read()); z.close()" "$D/flop.zip" "$D/FLOP.CNV"
    python3 -I "$FT/technics_floppy.py" "$D/disk.img" "$D/flop.zip" "$D/disk2.img" >/dev/null
    mv -- "$D/disk2.img" "$D/disk.img"
  fi
  FARGS=(-flop "$D/disk.img")
fi
R='lua _G.R=function(s) local sp=manager.machine.devices[":maincpu"].spaces["program"] emu.print_error(string.format("SDCNV %s drive=%d calls=%d ran=%s title=%08X/%08X", s, sp:read_u8(0x5007125A), sp:read_u32(0x502E0000), sp:read_u32(0x502E0000)>0 and string.pack("<I4", sp:read_u32(0x502E0008)) or "-", sp:read_u32(0x5000099C), sp:read_u32(0x500009A0))) end'
{
  echo "$R"; echo "wait 30"; echo 'lua _G.R("boot")'; echo snap
  if [ "$ROUTE" = sd ]; then
    echo "press CPR_SEG1 80"; echo "wait 8"; echo 'lua _G.R("sd-screen")'; echo snap
  fi
  echo "press CPR_SEG1 04"; echo "wait 4"; echo 'lua _G.R("disk-menu")'; echo snap
  echo "press CPL_SEG0 20"; echo "wait 8"; echo 'lua _G.R("style-convert")'; echo snap
  echo "press CPR_SEG6 01"; echo "wait 8"; echo 'lua _G.R("after-ok")'; echo snap
  echo exit
} > "$D/cmd.txt"
rm -f -- "$D/cmd.txt.log"
cd "$MAME_REPO"
REMOTE_CMD="$D/cmd.txt" DISPLAY="${DISPLAY:-:0}" ./tools/rig.sh remote kn7000 -s 600 -l "$D/rig.log" -- \
  -snapshot_directory "$D/snap" -harddisk "$D/sd.img" "${FARGS[@]}" > "$D/launch.out" 2>&1 || true
grep '^SDCNV' "$D/rig.log" || { echo "no SDCNV lines; see $D/rig.log"; exit 1; }
