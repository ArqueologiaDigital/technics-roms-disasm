# written by scripts/renaming/fix_hdae5000_tail_loops.py --apply
# run with: LC_ALL=C sed -i -f scripts/renaming/fix_hdae5000_tail_loops.sed hdae5000/*.s
s/\bHDAE5000_SelectListProc_Loop4\b/HDAE5000_SelectListProc_Join13/g
s/\bHDAE5000_Float_Unpack_Loop\b/HDAE5000_Float_Unpack_Done/g
s/\bHDAE5000_Double_Pack_Loop\b/HDAE5000_Double_Pack_Done2/g
s/\bHDAE5000_Double_Pack_Loop2\b/HDAE5000_Double_Pack_Skip/g
s/\bHDAE5000_Unpacked_Div_Loop2\b/HDAE5000_Unpacked_Div_Done/g
