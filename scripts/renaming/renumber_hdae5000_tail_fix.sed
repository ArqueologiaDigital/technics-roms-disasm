# renumber_hdae5000_tail_fix.sed -- put back address order in the two label families that
# fix_hdae5000_tail_loops.sed numbered out of order (reviewer finding, 2026-10-24).
#
# localize_hdae5000_address_locals.py numbers each <Owner>_<Suffix> family in address order
# (none, 2, 3 ...).  The later tail-loop fix renamed a _Loop into a family that was already
# complete, so it took the next free number: HDAE5000_SelectListProc_Join13 sits between Join9
# and Join10, and HDAE5000_Double_Pack_Done2 above Done.  Labels move no bytes (make -j3 gate).
#
# Run (repository root), then regenerate the symbol file:
#   LC_ALL=C sed -i -f scripts/renaming/renumber_hdae5000_tail_fix.sed hdae5000/*.s
#   python3 scripts/analysis/l2_symbol_reference.py --regen
s/\bHDAE5000_SelectListProc_Join13\b/HDAE5000_SelectListProc_JoinTmp10/g
s/\bHDAE5000_SelectListProc_Join10\b/HDAE5000_SelectListProc_JoinTmp11/g
s/\bHDAE5000_SelectListProc_Join11\b/HDAE5000_SelectListProc_JoinTmp12/g
s/\bHDAE5000_SelectListProc_Join12\b/HDAE5000_SelectListProc_JoinTmp13/g
s/\bHDAE5000_SelectListProc_JoinTmp1\([0-3]\)\b/HDAE5000_SelectListProc_Join1\1/g
s/\bHDAE5000_Double_Pack_Done\b/HDAE5000_Double_Pack_DoneTmp2/g
s/\bHDAE5000_Double_Pack_Done2\b/HDAE5000_Double_Pack_Done/g
s/\bHDAE5000_Double_Pack_DoneTmp2\b/HDAE5000_Double_Pack_Done2/g
