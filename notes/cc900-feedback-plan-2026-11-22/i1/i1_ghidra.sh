#!/bin/sh
# Step I1 of the feedback plan (section 13): analyse one thc1 / thc2 build with Ghidra, headless, and export its
# function table and decompiled C (ExportFunctions.java beside this file).
#
# Usage, from anywhere:
#     notes/cc900-feedback-plan-2026-11-22/i1/i1_ghidra.sh KEY EXE
#   KEY  a name for the build, e.g. thc2-1998 (the program's name in the project and the output directory)
#   EXE  the executable (static reading only; nothing is run)
# Writes, all PRIVATE (they reproduce Toshiba's code; never into a public repository):
#     ~/compartilhado/cc900-oracle/internals/ghidra/cc900.gpr   the Ghidra project (git-ignored there)
#     ~/compartilhado/cc900-oracle/internals/KEY/functions.tsv and decomp/*.c
#     ~/compartilhado/cc900-oracle/internals/KEY/analyze.log
# Tools: Ghidra 12.2 and Temurin JDK 25, unpacked under ~/compartilhado/tools/ from their archived release files
# (~/compartilhado/upstream_repos/file_archive/github.com/NationalSecurityAgency/ghidra-release-12.2 and
# .../adoptium/temurin25-jdk-25.0.5.1; unpack with `unzip` / `tar -xzf` in ~/compartilhado/tools).
set -eu
KEY=${1:?KEY}
EXE=${2:?EXE}
TOOLS=$HOME/compartilhado/tools
INT=$HOME/compartilhado/cc900-oracle/internals
HERE=$(cd "$(dirname "$0")" && pwd)
export JAVA_HOME="$TOOLS/jdk-25.0.5.1+2"
mkdir -p "$INT/ghidra" "$INT/$KEY"
"$TOOLS/ghidra_12.2_PUBLIC/support/analyzeHeadless" "$INT/ghidra" "cc900/$KEY" \
    -import "$EXE" -overwrite -loader PeLoader \
    -scriptPath "$HERE" -postScript ExportFunctions.java "$INT/$KEY" \
    -max-cpu 4 > "$INT/$KEY/analyze.log" 2>&1
tail -n 3 "$INT/$KEY/analyze.log"
wc -l "$INT/$KEY/functions.tsv"
