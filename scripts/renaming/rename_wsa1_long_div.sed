# SX-WSA1R prom_a: the C runtime's long-division entries, named by what they return, as in the KN5000 sub-CPU
# (scripts/renaming/rename_subcpu_long_div.sed, 2026-11-16, lane_sub).  The old names had the two the other way
# round: Int_SignedDiv keeps XHL (the quotient) when D = 1 and returns XDE (the remainder) when D = 0, and the
# KN5000 copy's D = 1 entry is what V4.23's `long / long` (C9H_divls) calls (run 2026-11-16-65-sub-r5).
# So, by entry semantics: the D = 0 entry (was Int_SignedDiv_Quotient) is Long_SignedRem, the D = 1 entry (was
# Int_SignedDiv_Remainder) Long_SignedDiv.  Comment lines first, then the names.
# Apply to wsa1/prom_a/modules/fe0000_fe77ff_disk_and_floppy.s.
s/^;   quotient in XHL, remainder in XDE\.  D selects quotient (0) or remainder (1)$/;   quotient in XHL, remainder in XDE.  D selects remainder (0) or quotient (1)/
s/^; Inputs:  XWA:QWA = dividend, XBC:QBC = divisor, D = 0 quotient \/ 1 remainder$/; Inputs:  XWA:QWA = dividend, XBC:QBC = divisor, D = 0 remainder \/ 1 quotient/
s/^; Int_SignedDiv_Quotient \/ _Remainder \/ Int_UnsignedDiv_Remainder -- entries$/; Long_SignedRem \/ Long_SignedDiv \/ Int_UnsignedDiv_Remainder -- entries/
s/^;          selector Int_SignedDiv reads, so the names follow from the$/;          selector Int_SignedDiv reads: D = 0 returns XDE, the remainder, D = 1/
s/^;          immediate: 0 at 0xFE693A, 1 at 0xFE693E\. The sibling's own text is$/;          XHL, the quotient (0 at 0xFE693A, 1 at 0xFE693E; names corrected 2026-11-16). The sibling's own text is/
s/^;          The sibling calls the first of them `Int_SignedDiv_ConstData` and$/;          The sibling called the first of them `Int_SignedDiv_ConstData` (now Long_SignedRem) and/
s/\bInt_SignedDiv_Quotient\b/Long_SignedRem/g
s/\bInt_SignedDiv_Remainder\b/Long_SignedDiv/g
