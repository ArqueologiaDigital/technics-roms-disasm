#!/bin/bash
# Move a list of files back from <tree>/subcpu/cc900/ to <tree>/subcpu/cc900-staged/ (all three trees).
#
# QUESTION ANSWERED / WHY: the reverse of promote_run.sh's first step, for files promoted by mistake before any
# commit (third promotion: promote.py list honoured only its first --except pattern and three jump-table switch
# files went in).  It only moves files (git mv).  The hand sources are then restored and spliced again:
#   git checkout -- v142/subcpu/core      (as its own command; only uncommitted splices are lost)
#   bash notes/cc900-c-subcpu-2026-11-16/promote_run.sh LIST.txt SIZES.tsv
#
#   bash notes/cc900-c-subcpu-2026-11-16/unpromote_run.sh LIST.txt      (repository root)
set -eu
LIST="${1:?list of file names}"
while read -r f; do
    [ -n "$f" ] || continue
    for t in v142 v141 v140; do
        git mv -- "$t/subcpu/cc900/$f" "$t/subcpu/cc900-staged/$f"
    done
done < "$LIST"
