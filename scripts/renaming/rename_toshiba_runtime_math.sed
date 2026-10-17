# v10 / v9 / v7: the 32-bit multiply / divide entry points of Toshiba's C runtime (c900ml.lib; LMULL.ASM / LDIVL.ASM,
# matched instruction for instruction by scripts/analysis/compiler_id/verify_toshiba_runtime.sh).  The signed
# divide/modulo core and its internal labels had been named after free(), which precedes them (Free_ClearByte ..);
# DivMod32 returns only the unsigned remainder; Math_MultiplyAccumulate is a plain 32x32 multiply.
s/\bFree_ClearByte2\b/Math_RemainderSigned32/g
s/\bFree_ClearByte\b/Math_DivModSigned32/g
s/\bFree_Block4\b/Math_DivModSigned32_PlusA/g
s/\bFree_Prologue\b/Math_DivModSigned32_PlusB/g
s/\bFree_Compare3\b/Math_DivModSigned32_Divi/g
s/\bFree_OrBits2\b/Math_DivModSigned32_Fin/g
s/\bDivMod32\b/Math_RemainderU32/g
s/\bMath_MultiplyAccumulate\b/Math_Multiply32/g
