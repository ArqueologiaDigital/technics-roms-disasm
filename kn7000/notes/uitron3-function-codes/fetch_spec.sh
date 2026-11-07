#!/bin/sh
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "where is the uITRON 3.0 specification that function_codes.py reads, and is it the
# copy these notes were written against?"  Downloads the TRON Association's plain-text
# "uITRON 3.0 Specification" Ver 3.02.00 (document I-01-02E) into spec/ beside this script
# (git-ignored: the licence allows reproducing it only in its entirety, so no part of it is
# committed), checks the sha256 of the compressed file and decompresses it to
# spec/mitron3.02.txt.
#
#     sh kn7000/notes/uitron3-function-codes/fetch_spec.sh            # download
#     sh kn7000/notes/uitron3-function-codes/fetch_spec.sh COPY.txt.Z # use a copy already downloaded
set -eu
cd "$(dirname "$0")"
mkdir -p spec
if [ $# -ge 1 ]; then
    cp -- "$1" spec/mitron3.02.txt.Z
elif [ ! -f spec/mitron3.02.txt.Z ]; then
    curl -fsSL -o spec/mitron3.02.txt.Z.part https://www.ertl.jp/ITRON/SPEC/FILE/mitron3.02.txt.Z
    mv -- spec/mitron3.02.txt.Z.part spec/mitron3.02.txt.Z
fi
echo "2e0a2201fbd3c92af66a84b8f60b836ac7a7e1643bba0bc4602808e9cf67abdc  spec/mitron3.02.txt.Z" | sha256sum -c -
gzip -dc spec/mitron3.02.txt.Z > spec/mitron3.02.txt
echo "spec/mitron3.02.txt: $(wc -l < spec/mitron3.02.txt) lines"
