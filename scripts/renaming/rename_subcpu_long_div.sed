# Sub-CPU payload: the C runtime's long-division entries, named by what they return (2026-11-16, lane_sub).
# Int_SignedDiv sets the result from D: D = 1 keeps XHL from FP_UnsignedDiv, negated when exactly one operand
# is negative (a signed QUOTIENT); D = 0 returns XDE, negated when the dividend is negative (a signed REMAINDER).
# The old comments had the two entries the other way round.  Confirmed by V4.23: DSP_PanScale_Simple and
# DSP_ParamInterp_2Point (`long / long`, Toshiba runtime C9H_divls) match with their call to the D = 1 entry
# (run 2026-11-16-65-sub-r5).  Apply to v142/subcpu/**/*.s, then regenerate v141 / v140.
s/\bInt_SignedDiv_AltEntry\b/Long_SignedDiv/g
s/\bInt_SignedDiv_ConstData\b/Long_SignedRem/g
s/^; Signed 64-bit divide\/modulo helper for the C runtime\. Inputs XWA:QWA (dividend) and$/; Signed 32-bit (long) divide\/modulo helper for the C runtime. Inputs XWA (dividend) and/
s/^; XBC:QBC (divisor); D selects quotient (0) or remainder (1) and is set by the two$/; XBC (divisor); D selects remainder (0) or quotient (1) and is set by the two/
s/^; Entry point "signed quotient": D = 0, jump to Int_SignedDiv\. Despite the name this is$/; Long_SignedRem, the runtime's C9H_remls (long %): D = 0, jump to Int_SignedDiv. Despite its old name (Int_SignedDiv_ConstData) this is/
s/^; Entry point "signed remainder": D = 1, jump to Int_SignedDiv\. The three bytes at$/; Long_SignedDiv, the runtime's C9H_divls (long \/): D = 1, jump to Int_SignedDiv. The three bytes at/
